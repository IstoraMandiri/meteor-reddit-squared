@helpers =
  generateColourFromString: (str) ->
    i = 0
    hash = 0
    while i < str.length
      hash = str.charCodeAt(i++) + ((hash << 5) - hash)
    i = 0
    colour = "#"
    while i < 3
      colour += ("00" + ((hash >> i++ * 8) & 0xFF).toString(16)).slice(-2)
    colour

  calculateHotness : (votes, created) ->
    order = Math.log(Math.max(Math.abs(votes), 1)) / Math.LN10;
    sign = 0
    if votes > 0
      sign = 1
    else if votes < 0
      sign = -1

    seconds = created - 1134028003;
    product = order + sign * seconds / 45000;
    return Math.round(product*10000000)/10000000;

