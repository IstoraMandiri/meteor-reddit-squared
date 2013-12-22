
drawMovementGraph = (canvas, history) ->
  height = 30
  padding = 3
  color = '#fff'
  thickness = 4

  ctx = canvas.getContext '2d' 
  canvas.width = $(canvas).parent().width()
  canvas.height = height

  ctx.strokeStyle = color
  ctx.lineWidth = thickness

  ctx.beginPath();
  
  # calculate base / top
  limits =
    upper:0
    lower:Infinity
  
  for snapshot in history
    limits.upper = snapshot.score if snapshot.score > limits.upper
    limits.lower = snapshot.score if snapshot.score < limits.lower

  limitDifference = (limits.upper - limits.lower) || 1

  scale = (canvas.height - padding*2) / limitDifference

  for snapshot, i in history
    xPos = (i+1)*10# plot by time please
    yPos = ((snapshot.score - limits.lower) * scale) + padding
    if i is 0 # first
      ctx.moveTo xPos, yPos
    else
      ctx.lineTo xPos, yPos
  

  ctx.stroke();
  ctx.closePath();

  # draw circle
  latestSnapshot = history[history.length-1]

  ctx.beginPath();
  ctx.arc((history.length)*10, ((snapshot.score - limits.lower) * scale) + padding, thickness, 0, 2 * Math.PI, false);
  ctx.fillStyle = color;
  ctx.fill();



Handlebars.registerHelper 'epochToDate', (epoch) -> new Date(epoch*1000);

Template.post_list.posts = -> 
  collections.Posts.find({},{sort:{'latest._createdAt':-1,'latest.rank':1}}).fetch()

Template.history_graph.rendered = -> 
  console.log 'workig with', @
  drawMovementGraph @.find('canvas'), @.data
