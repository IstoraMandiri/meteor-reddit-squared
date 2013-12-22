
@collections = 
  Posts : new Meteor.Collection 'posts'
  Scrapes : new Meteor.Collection 'scrapes'


if Meteor.isServer

  Meteor.publish "latestPosts", -> collections.Posts.find({},{fields:{latest:1}})

if Meteor.isClient
  # public subscriptions
  Deps.autorun ->
    Meteor.subscribe "latestPosts" # lots


