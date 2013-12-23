Router.map ->
  @route 'score-lines',
    path: '/'
    template: 'score_line_list'
    data: 
      posts: -> collections.Posts.find({},{sort:{'latest.rank':1}}).fetch()

drawScoreLineGraph = (canvas, post) ->
  history = post.history?= []
  height = 50
  padding = 4
  color = helpers.generateColourFromString post.latest[CONFIG.subredditColorString]
  thickness = 3

  ctx = canvas.getContext '2d' 
  canvas.width = $(canvas).parent().width()
  canvas.height = height

  # draw line
  ctx.strokeStyle = color
  ctx.lineWidth = thickness
  ctx.beginPath();

  yLimits =
    upper:0
    lower:Infinity
  
  for snapshot in history
    yLimits.upper = snapshot.score if snapshot.score > yLimits.upper
    yLimits.lower = snapshot.score if snapshot.score < yLimits.lower

  limitDifference = (yLimits.upper - yLimits.lower) || 1

  scale = (canvas.height - padding*2) / limitDifference

  for snapshot, i in history
    xPos = (canvas.width + (i+1)*6) - ((history.length+1)*6)
    yPos = canvas.height - (((snapshot.score - yLimits.lower) * scale) + padding)
    
    if i is 0
      ctx.moveTo xPos, yPos
    else
      ctx.lineTo xPos, yPos
  
  ctx.stroke();
  ctx.closePath();

  # draw head
  xPos = (canvas.width + (i+1)*6) - ((history.length+1)*6) - 6
  yPos = canvas.height - (((history[history.length-1].score - yLimits.lower) * scale) + padding)

  ctx.beginPath();
  ctx.arc(xPos, yPos, thickness+1, 0, 2 * Math.PI, false);
  ctx.fillStyle = color;
  ctx.fill();



Template.score_line.subredditColor = -> helpers.generateColourFromString @.latest[CONFIG.subredditColorString]

Template.score_line.thumbnailURL = -> if @.latest.thumbnail.indexOf('http') is 0 then @.latest.thumbnail

Template.score_line_graph.rendered = ->  drawScoreLineGraph @.find('canvas'), @.data




