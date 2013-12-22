

Template.post_list.posts = -> collections.Posts.find({},{sort:{'latest.score':-1}}).fetch()

Template.post.title = -> console.log @