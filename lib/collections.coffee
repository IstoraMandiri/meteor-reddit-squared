


@collections = 
  Posts : new Meteor.Collection 'posts'
  Scrapes : new Meteor.Collection 'scrapes'


if Meteor.isServer

  Meteor.publish "latestPosts", -> 
    collections.Posts.find({},{sort:{'latest._createdAt':-1,'latest.rank':1},limit:35})

if Meteor.isClient
  # public subscriptions
  Deps.autorun ->
    Meteor.subscribe "latestPosts" # lots


