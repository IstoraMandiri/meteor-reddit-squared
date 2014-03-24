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
  
  $graph = $('#hotness-graph-d3')

  margin =
    top: 50
    right: 50
    bottom: 50
    left: 80

  width = $graph.width() - margin.left - margin.right
  height = $graph.height() - margin.top - margin.bottom
  
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
  .append("svg")
  .attr("width", width + margin.left + margin.right)
  .attr("height", height + margin.top + margin.bottom)
  .append("g")
  .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

  # x & y axis
  svg.append("g").attr("class", "x axis").attr("transform", "translate(0," + height + ")").call xAxis
  svg.append("g").attr("class", "y axis").call yAxis


  hoverLineGroup = svg.append("g").attr("class", "hover-line")
  hoverLine = hoverLineGroup.append("line").attr("x1", 10).attr("x2", 10).attr("y1", 0).attr("y2", height)
  
  # date formatting
  hoverDate = hoverLineGroup.append("text").attr("class", "hover-text")
  .attr("y", height - 20)
  .attr("text-anchor", "end")

  # Hide hover line by default.
  hoverLineGroup.style "opacity", 1e-6



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
  .style("stroke", (d) -> helpers.generateColourFromString d.latest[CONFIG.subredditColorString])
  .style("opacity", (d) ->
    console.log d.history.length
    100 * 100 / (d.history.length * d.history.length/1.7)
    # 100 / d.history.length
  )
  .attr("d", (d) -> valueline(d.history))

  d3.select(".d3-canvas")
  .on("mousemove", ->
    mouse_x = d3.mouse(this)[0] - margin.left
    mouse_y = d3.mouse(this)[1]
    graph_y = y.invert(mouse_y)
    graph_x = x.invert(mouse_x)
    format = d3.time.format("%e %b")
    hoverDate.text(graph_x).style("font-size","18px").style('stroke-width':0)
    hoverDate.style 'al'
    hoverDate.attr "x", mouse_x - 20
    hoverLine.attr("x1", mouse_x).attr "x2", mouse_x
    hoverLineGroup.style "opacity", 1
  ).on "mouseout", ->
    hoverLineGroup.style "opacity", 1e-6

  # $graph.on 'mousemove', ->
  #   console.log 'hello'
  # svg.on "mouseover", -> console.log 'mouseover'
  # svg.on "mousemove", ->
  #   console.log('mousemove', d3.mouse(this));
    # var x = d3.mouse(this)[0];
    # hoverLine.attr("x1", x).attr("x2", x).style("opacity", 1);
  # }).on("mouseout", function() {
  #   console.log('mouseout');
  #   hoverLine.style("opacity", 1e-6);
  # });

  # on mousemove, create line with exact value





