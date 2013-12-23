
subredditColorString = 'subreddit_id' # subreddit or +_id ?

Handlebars.registerHelper 'epochToDate', (epoch) -> new Date(epoch*1000);

drawMovementGraph = (canvas, post) ->
  history = post.history
  height = 50
  padding = 4
  color = helpers.generateColourFromString post.latest[subredditColorString]
  thickness = 3

  ctx = canvas.getContext '2d' 
  canvas.width = $(canvas).parent().width()
  canvas.height = height

  ctx.strokeStyle = color
  ctx.lineWidth = thickness

  ctx.beginPath();
  
  #
  # for time based
  #
  # xLimits = 
  #   first:
  #   last:   

  yLimits =
    upper:0
    lower:Infinity
  
  for snapshot in history
    yLimits.upper = snapshot.score if snapshot.score > yLimits.upper
    yLimits.lower = snapshot.score if snapshot.score < yLimits.lower

  limitDifference = (yLimits.upper - yLimits.lower) || 1

  scale = (canvas.height - padding*2) / limitDifference

  for snapshot, i in history
    # from left
    # xPos = (i+1)*6# plot by time please
    # from right
    xPos = (canvas.width + (i+1)*6) - ((history.length+1)*6)
        
    yPos = canvas.height - (((snapshot.score - yLimits.lower) * scale) + padding)
    
    if i is 0 # first
      ctx.moveTo xPos, yPos
    else
      ctx.lineTo xPos, yPos
  

  ctx.stroke();
  ctx.closePath();

  # draw circle
  latestSnapshot = history[history.length-1]
  
  # xPos = (history.length)*6 # plot by time?
  xPos = (canvas.width + (i+1)*6) - ((history.length+1)*6)

  ctx.beginPath();
  ctx.arc(xPos - 6, ((snapshot.score - yLimits.lower) * scale) + padding, thickness+1, 0, 2 * Math.PI, false);
  ctx.fillStyle = color;
  ctx.fill();




Template.score_line_list.posts = -> 
  collections.Posts.find({},{sort:{'latest._createdAt':-1,'latest.rank':1}}).fetch()

Template.score_line.subredditColor = -> helpers.generateColourFromString @.latest[subredditColorString]

Template.score_line.thumbnailURL = -> if @.latest.thumbnail.indexOf('http') is 0 then @.latest.thumbnail

Template.score_line_graph.rendered = ->  drawMovementGraph @.find('canvas'), @.data




