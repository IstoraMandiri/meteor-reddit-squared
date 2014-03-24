Router.configure 
  layout: 'layout'
  loadingTemplate: 'loading'
  notFoundTemplate: 'notFound'

Router.map ->
  @route 'hotness_d3',
    path: '/'
    template: 'hotness_graph_d3'
    data: 
      posts: -> collections.Posts.find({},{sort:{'latest.rank':1}}).fetch()

Router.map ->
  @route 'score-lines',
    path: '/lines'
    template: 'score_line_list'
    data: 
      posts: -> collections.Posts.find({},{sort:{'latest.rank':1}}).fetch()

Router.map ->
  @route 'hotness',
    path: '/hot'
    template: 'hotness_graph'
    data: 
      posts: -> collections.Posts.find({},{sort:{'latest.rank':1}}).fetch()
