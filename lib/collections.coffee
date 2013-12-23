


@collections = 
  Posts : new Meteor.Collection 'posts'
  Scrapes : new Meteor.Collection 'scrapes'

latestScrape = -> collections.Scrapes.findOne({},{sort:{'_createdAt':-1}})

if Meteor.isServer

  Meteor.publish "frontPage", ->
    limit = 25
    collections.Posts.find({'latest._createdAt':latestScrape()?._createdAt},{sort:{'latest.rank':1},limit:limit})

if Meteor.isClient
  # public subscriptions
  Deps.autorun ->
    Meteor.subscribe "frontPage" # lots


