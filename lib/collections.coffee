
@collections = 
  Posts : new Meteor.Collection 'posts'
  Scrapes : new Meteor.Collection 'scrapes'


if Meteor.isServer

  Meteor.publish "frontPage", ->
    limit = 25
    collections.Posts.find({},{sort:{'latest._createdAt':-1,'latest.rank':1},limit:limit})

if Meteor.isClient

  @subscriptions =
    Meteor.subscribe "frontPage" # lots


