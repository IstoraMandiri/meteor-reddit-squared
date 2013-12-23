Router.map ->
  @route 'hotness',
    path: '/hot'
    template: 'hotness_graph'
    data: 
      posts: -> collections.Posts.find({},{sort:{'latest.rank':1}}).fetch()

Template.hotness_graph.rendered = ->  drawHotenssGraph @.find('canvas'), @.data.posts()

drawHotenssGraph = (canvas, posts) ->
  $canvas = $(canvas)
  
  padding = 50
  thickness = 3

  canvas.width = $canvas.parent().width() - 20
  canvas.height = $canvas.parent().height() - 20

  ctx = canvas.getContext '2d' 

      # calculate canvas scale 
  xLimits = 
    upper:0
    lower:Infinity

  yLimits = 
    upper:0
    lower:Infinity

  for post in posts 
    for snapshot in post.history
      xLimits.upper = snapshot._createdAt if snapshot._createdAt > xLimits.upper
      xLimits.lower = snapshot._createdAt if snapshot._createdAt < xLimits.lower
      yLimits.upper = snapshot.hotness if snapshot.hotness > yLimits.upper
      yLimits.lower = snapshot.hotness if snapshot.hotness < yLimits.lower

  xLimitDifference = (xLimits.upper - xLimits.lower) || 1
  yLimitDifference = (yLimits.upper - yLimits.lower) || 1
  xScale = canvas.width / xLimitDifference
  yScale = canvas.height / yLimitDifference

  calcX = (snapshot) -> (snapshot._createdAt - xLimits.lower) * xScale
  calcY = (snapshot) -> canvas.height - (snapshot.hotness - yLimits.lower) * yScale

  for post in posts
    color = helpers.generateColourFromString post.latest[CONFIG.subredditColorString]
    ctx.strokeStyle = color
    ctx.fillStyle = color
    ctx.lineWidth = thickness

    # # draw line
    ctx.beginPath();
    
    for snapshot, i in post.history
      xPos = calcX snapshot
      yPos = calcY snapshot
      
      if i is 0
        ctx.moveTo xPos, yPos
      else
        ctx.lineTo xPos, yPos
 
      console.log 'x',xPos,'y',yPos

    ctx.stroke()
    ctx.closePath()

    # draw head
    latestSnapshot = post.history[post.history.length-1]
    xPos = calcX(latestSnapshot)
    yPos = calcY(latestSnapshot)
    
    ctx.beginPath()
    ctx.arc xPos, yPos, thickness+1, 0, 2 * Math.PI, false
    ctx.fill()
    ctx.closePath()

    # add text
    ctx.font = 'bold 20px Helvetica Neue'
    ctx.textAlign = 'right'
    ctx.fillText(post.latest.score, xPos-30, yPos+25)







