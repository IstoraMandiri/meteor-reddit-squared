


@filters =
  historyPost : (post) ->
    fields = ['score', 'downs', 'ups', 'num_comments', '_createdAt','edited','banned_by','hotness','rank']
    result = {}
    for field in fields
      if post[field] 
        result[field] = post[field]
    result._s = new Date(result._createdAt).getSeconds()
    return result



request = Meteor.require 'request' 

totalPosts = -> collections.Posts.find().count()

insertFrame = (postData) ->
  postDocument = collections.Posts.findOne({id:postData.id})
  newInsert = false
  if !postDocument
    newInsert = true
    postDocument = collections.Posts.insert({id:postData.id,latest:postData,_createdAt:postData._createdAt})
  else 
    collections.Posts.update({_id:postDocument._id},{$set:{latest:postData}})
  
  postDocumentId = postDocument._id || postDocument

  collections.Posts.update({_id:postDocumentId},{$push:{history:filters.historyPost postData}})
  return newInsert 

scrapeReddit = ->
  req = Async.runSync (callback) ->
    request.get
      url: 'http://www.reddit.com/.json?limit=100'
      json: true
    , (err,response) -> 
      console.log err if err?
      callback err, response
  theTime = new Date()
  newPosts = 0
  for post, i in req.result.body.data.children
    post.data._createdAt = theTime
    post.data.rank = i + 1
    post.data.hotness = helpers.calculateHotness post.data.score, post.data.created_utc
    
    if insertFrame post.data
      newPosts++
  collections.Scrapes.insert 
    totalPosts: totalPosts()
    newPosts: newPosts 
    recorded: req.result.body.data.children.length
    _createdAt: theTime

Meteor.startup -> 

  nextTick = ->
    nextMinute = Math.ceil(new Date()/(5 * 1000)) * (5 * 1000)
    return nextMinute - new Date()

  scrapeCycle = ->
    console.log 'nt:', nextTick(), ' || now:', new Date()
    Meteor.setTimeout -> 
      try scrapeReddit() 
      scrapeCycle()
    , nextTick() # default to 1 minute

  scrapeCycle()

