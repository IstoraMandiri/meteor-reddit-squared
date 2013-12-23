
@collections = 
  Posts : new Meteor.Collection 'posts'
  Scrapes : new Meteor.Collection 'scrapes'


if Meteor.isServer

  Meteor.publish "frontPage", ->
    limit = 50
    collections.Posts.find({},{sort:{'latest._createdAt':-1,'latest.rank':1},limit:limit})

  Meteor.publish "latestScrape", -> collections.Scrapes.find({},{sort:{_createdAt:-1},limit:1})

if Meteor.isClient

  @subscriptions =
    frontPage: Meteor.subscribe "frontPage" # lots
    latestScrape: Meteor.subscribe "latestScrape" # lots


