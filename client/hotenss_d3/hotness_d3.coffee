Router.map ->
  @route 'hotness_d3',
    path: '/hot_d3'
    template: 'hotness_graph_d3'
    data: 
      posts: -> collections.Posts.find({},{sort:{'latest.rank':1}}).fetch()

Template.hotness_graph_d3.lastScrape = -> collections.Scrapes.find({},{sort:{_createdAt:-1,limit:1}}).fetch()?[0]?._createdAt

Template.hotness_graph_d3.rendered = -> drawHotenssGraph_d3 @.data.posts()

drawHotenssGraph_d3 = (posts) ->
  data = posts[0].history
  margin =
    top: 50
    right: 50
    bottom: 40
    left: 80

  width = $('#hotness-graph-d3').width() - margin.left - margin.right
  height = $('#hotness-graph-d3').height() - margin.top - margin.bottom
  
  x = d3.time.scale().range([0, width])
  y = d3.scale.linear().range([height, 0])

  xAxis = d3.svg.axis().scale(x).orient("bottom").ticks(10)
  yAxis = d3.svg.axis().scale(y).orient("left").ticks(10)
  
  getRange = (key) ->
    [(d3.min posts, (c) -> d3.min c.history, (v) -> v[key]),(d3.max posts, (c) -> d3.max c.history, (v) -> v[key])]

  x.domain getRange '_createdAt'
  y.domain getRange 'score'

  # construct canvas
  svg = d3.select(".d3-canvas")
  .append("svg").
  attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  # x & y axis
  svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call xAxis
  svg.append("g").attr("class", "y axis").call yAxis

  # valueline for each data
  valueline = d3.svg.line().interpolate("basis")
  .x((d) -> x d._createdAt)
  .y((d) -> y d.score)

  # populate paths
  post = svg.selectAll(".post").data(posts)
  .enter() # magic
  .append("g").attr("class", "post")
  .append("path")
  .attr("class", "line")
  .style("opacity", 0.5)
  .attr("d", (d) -> valueline(d.history))





