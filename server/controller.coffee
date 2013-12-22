
request = Meteor.require 'request' 

totalPosts = -> collections.Posts.find().count()

insertFrame = (postData) ->
  postDocument = collections.Posts.findOne({id:postData.id})
  newInsert = false
  if !postDocument
    newInsert = true
    postDocument = collections.Posts.insert({id:postData.id,latest:postData})
  else 
    collections.Posts.update({_id:postDocument._id},{$set:{latest:postData}})
  postDocumentId = postDocument._id || postDocument
  collections.Posts.update({_id:postDocumentId},{$push:{history:postData}})
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

  console.log 'new scrape', completedScrape
  collections.Scrapes.insert completedScrape

Meteor.startup ->
  # scrapeReddit()
  # Meteor.setInterval ->
  #   scrapeReddit()
  # , 1000 * 15 # 15 second intervals