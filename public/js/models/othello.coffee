define ['cs!views/othello'], (OthelloGui) ->

  class OthelloModel

    constructor: (params) ->
      @gameboardSize = params.gameboardSize
      @gameName = params.gameName
      @pseudo = params.pseudo
      @pseudoOther = params.pseudoOther
      @firstToPlay = params.firstToPlay
      @firstPlayer = params.firstPlayer
      @nearCases = [
        {'x': -1, 'y': -1},
        {'x': -1, 'y': 0},
        {'x': -1, 'y': 1},
        {'x': 0, 'y': -1},
        {'x': 0, 'y': 0},
        {'x': 0, 'y': 1},
        {'x': 1, 'y': -1},
        {'x': 1, 'y': 0},
        {'x': 1, 'y': 1}
      ]
      @gui = new OthelloGui()

    initGame: ->
    # Turn
      @turnColor = 'black'
      @gui.showNewTurn 'white', 'black', @firstToPlay
    # Scores
      @score = {white: 2, black: 2}
      @gui.setScore(@score)
    # Last piece played
      @lastPiecePlayed = ''
      @gui.showLastPiecePlayed(@lastPiecePlayed)
    # Pseudo colors
      if @firstToPlay == @pseudo
        @color = 'black' 
        @gui.setPseudoColor {black: @pseudo, white: @pseudoOther}        
      else
        @color = 'white'
        @gui.setPseudoColor {white: @pseudo, black: @pseudoOther}
    # Game matrice
      @game = ('' for _ in [0...@gameboardSize] for _ in [0...@gameboardSize])
      @game[@gameboardSize/2 - 1][@gameboardSize/2 - 1] = 'black'
      @game[@gameboardSize/2][@gameboardSize/2] = 'black'
      @game[@gameboardSize/2 - 1][@gameboardSize/2] = 'white'
      @game[@gameboardSize/2][@gameboardSize/2 - 1] = 'white'
      @gui.setGameboard @game

    setPseudoOther: (pseudo) ->
      @pseudoOther = pseudo
      @gui.setPseudoOther @pseudoOther
      if @color == 'white' then @gui.setPseudoColor {black: @pseudoOther} 
      else @gui.setPseudoColor {white: @pseudoOther} 
      if @firstToPlay is null 
        @firstToPlay = pseudo
        @gui.showNewTurn '', @turnColor, @firstToPlay

    playShot: (elem) ->
      if @pseudoOther isnt null && @turnColor == @color && pos = @gui.getEmptyCasePosition(elem)
        pieces = @shot(pos.y, pos.x, @color, false)
        if pieces.length > 0          
          @game[pos.y][pos.x] = @color
          for piece in pieces
            @game[piece.y][piece.x] = @color
          @lastPiecePlayed = 'y'+pos.y+'-x'+pos.x
          @gui.showLastPiecePlayed @lastPiecePlayed
          @setScore pieces.length
          @endTurn()

    setScore: (returnedPieces) ->
      @score[@color] += returnedPieces + 1
      @score[@oppositeColor(@color)] -= returnedPieces
      @gui.setScore @score

    shot: (y, x, color, possibility) ->
      pieces = []
      for nearCase in @nearCases
        dist = 0
        tmpPieces = []
        loop
          dist++
          gameCaseRow = @game[y + nearCase.y * dist] || null
          gameCase = if gameCaseRow then gameCaseRow[x + nearCase.x * dist] || null else null
          if gameCase && gameCase != ''
            if gameCase != color
              tmpPieces.push {y: y + nearCase.y * dist, x: x + nearCase.x * dist}
            else
              if tmpPieces.length > 0
                if possibility then return true
                pieces = pieces.concat tmpPieces
              break
          else
            break
      if possibility then return false else return pieces

    hasPossibleShot: (color) ->
      for y in [0...@gameboardSize]
        for x in [0...@gameboardSize]
          if @game[y][x] == '' && @shot(y, x, color, true)
            return true
      return false

    endTurn: ->
      @gui.setGameboard @game
      if @hasPossibleShot(@oppositeColor(@turnColor))
        @turnColor = @oppositeColor(@turnColor)
        @gui.showOtherTurn @oppositeColor(@turnColor), @turnColor, @pseudoOther
        return 'otherCanPlay'
      else if @hasPossibleShot(@turnColor)
        @gui.showImpossiblePlayOther()
        return 'impossiblePlayOther'
      else
        @endGame()
        return 'endGame'

    endTurnOther: (game, lastPiecePlayed, score) ->
      @game = game
      @gui.setGameboard @game
      @lastPiecePlayed = lastPiecePlayed
      @gui.showLastPiecePlayed @lastPiecePlayed
      @score = score
      @gui.setScore @score
      
    myTurn: ->
      @turnColor = @oppositeColor(@turnColor)
      @gui.showMyTurn @oppositeColor(@turnColor), @turnColor, @pseudo

    endGame: ->
      if @score.black == @score.white
        @gui.showEndGameEqual()
      else
        winnerColor = if @score.white > @score.black then 'white' else 'black' 
        for y,row of @game
          for x,frame of row
            if frame == '' then @score[winnerColor] += 1
        @gui.setScore @score
        winner = if @color == winnerColor then @pseudo else @pseudoOther
        @gui.showEndGame winner

    restart: (playerWhoRestart, firstToPlay) ->
      @firstToPlay = firstToPlay
      @initGame()
      @gui.alertRestart playerWhoRestart, firstToPlay, @pseudo, @pseudoOther
      
    oppositeColor: (color) ->
      return if color == 'black' then 'white' else 'black'


  return OthelloModel
