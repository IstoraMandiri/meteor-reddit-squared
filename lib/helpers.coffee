@helpers =
  calculateHotness : (votes, created) ->
    # s = ups - downs
    # order = Math.log(Math.max(Math.abs(s), 1))
    # sign = if s > 0 then 1 else if s < 0 is -1 else 0
    # seconds = created - 1134028003
    # return (order + sign * seconds / 45000).toFixed(7)

    order = Math.log(Math.max(Math.abs(votes), 1)) / Math.LN10;
    sign = 0
    if votes > 0
      sign = 1
    else if votes < 0
      sign = -1

    seconds = created - 1134028003;
    product = order + sign * seconds / 45000;
    return Math.round(product*10000000)/10000000;
