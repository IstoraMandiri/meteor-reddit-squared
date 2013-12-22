
@filters =
  historyPost : (post) ->
    fields = ['score', 'downs', 'ups', 'num_comments', '_createdAt','edited','banned_by']
    result = {}
    for field in fields
      if post[field] 
        result[field] = post[field]
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
  # calculate top, bottom etc,
  collections.Posts.update({_id:postDocumentId},{$push:{history:filters.historyPost postData}})
  return newInsert 

scrapeReddit = ->
  req = Async.runSync (callback) ->
    request.get
      url: 'http://www.reddit.com/.json?limit=100'
      json: true
    , (err,response) -> callback err, response
  theTime = new Date()
  newPosts = 0
  for post in req.result.body.data.children
    post.data._createdAt = theTime
    if insertFrame post.data
      newPosts++

  completedScrape = 
    totalPosts: totalPosts()
    newPosts: newPosts
    recorded: req.result.body.data.children.length
    _createdAt: theTime

  collections.Scrapes.insert completedScrape

Meteor.startup ->
  # Meteor.setTimeout ->
    scrapeReddit()
    Meteor.setInterval ->
      scrapeReddit()
    # , 1000 * 10 # second intervals
    , 1000 * 10 # default to 90 seconds
  # , 10 * 1000 # 10 second delay

