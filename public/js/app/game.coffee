define ['jquery'], ($) ->

  class Game

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
      @initGame()

    initGame: ->
      @turn = 'black'
      @lastPiecePlayed = {}
      @color = if @firstToPlay == @pseudo then 'black' else 'white'
      @whiteScore = @blackScore = 0
      @game = ('' for _ in [0...@gameboardSize] for _ in [0...@gameboardSize])
      @game[@gameboardSize/2 - 1][@gameboardSize/2 - 1] = 'black'
      @game[@gameboardSize/2][@gameboardSize/2] = 'black'
      @game[@gameboardSize/2 - 1][@gameboardSize/2] = 'white'
      @game[@gameboardSize/2][@gameboardSize/2 - 1] = 'white'

    setPseudoOther: (pseudo) ->
      @pseudoOther = pseudo
      if @firstToPlay is null then @firstToPlay = pseudo

    updateGameBoard: ->
      whiteScore = blackScore = 0
      for y,row of @game
        for x,frame of row
          if frame == 'black' then blackScore += 1 
          else if frame == 'white' then whiteScore += 1
          $('#gameboard circle[data-position="y'+y+'-x'+x+'"]').attr 'data-color', frame
      @blackScore = blackScore
      @whiteScore = whiteScore
      $('.score .black .number').text blackScore
      $('.score .white .number').text whiteScore

    playShot: (elem) ->
      if @pseudoOther isnt null && @turn == @color 
        position = elem.attr('data-position') 
        if $('#gameboard circle[data-position="'+position+'"]').attr('data-color') == ''
          y = parseInt(elem.attr('data-y'), 10)
          x = parseInt(elem.attr('data-x'), 10)
          pieces = @shot(y, x, @color, false)
          if pieces.length > 0
            @game[y][x] = @color
            @lastPiecePlayed = 'y'+y+'-x'+x
            @showLastPiecePlayed()
            for piece in pieces
              @game[piece.y][piece.x] = @color
            @endTurn()

    showLastPiecePlayed: ->
      $('#gameboard [data-last-played="true"]').attr('data-last-played', 'false')
      $('#gameboard rect[data-position="'+@lastPiecePlayed+'"]').attr('data-last-played', 'true')

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
      @updateGameBoard(@game)
      if @hasPossibleShot(@oppositeTurn(@turn))
        @turn = @oppositeTurn(@turn)
        $('#data .turn').removeClass(@oppositeTurn(@turn)).addClass(@turn)
        $('#data .turn .pseudo').text @pseudoOther
        $('#alertMessage').html(
          $('#alertMessageList .theOtherTurn').clone()
            .addClass('animated bounceIn')
        )
        return 'otherCanPlay'
      else if @hasPossibleShot(@turn)
        $('#alertMessage').html(
          $('#alertMessageList .impossiblePlayOther').clone()
            .addClass('animated bounceIn')
        )
        return 'impossiblePlayOther'
      else
        @endGame()
        return 'endGame'

    endTurnOther: (game, lastPiecePlayed) ->
      @lastPiecePlayed = lastPiecePlayed
      @showLastPiecePlayed()
      @game = game
      @updateGameBoard()
      
    myTurn: ->
      @turn = @oppositeTurn(@turn)
      $('#data .turn').removeClass(@oppositeTurn(@turn)).addClass(@turn)
      $('#data .turn .pseudo').text @pseudo
      $('#alertMessage').html(
        $('#alertMessageList .yourTurn').clone()
          .addClass('animated bounceIn')
      )

    impossiblePlay: ->
      $('#alertMessage').html(
        $('#alertMessageList .impossiblePlay').clone()
          .addClass('animated bounceIn')
      )

    endGame: ->
      if @whiteScore == @blackScore
        $('#alertMessage').html(
          $('#alertMessageList .endGameEqual').clone()
            .addClass('animated bounceIn')
        )
      else
        winnerColor = if @whiteScore > @blackScore then 'white' else 'black' 
        winner = if @color == winnerColor then @pseudo else @pseudoOther
        message = $('#alertMessageList .endGame').text()
        $('#alertMessage').html(
          $('#alertMessageList .endGame').clone()
            .text message.replace('%s', winner)
            .addClass('animated bounceIn')
        )

    restart: (playerWhoRestart, firstToPlay) ->
      @firstToPlay = firstToPlay
      @initGame()
      @updateGameBoard()
      $('#gameboard [data-last-played="true"]').attr('data-last-played', 'false')
      $('#data .turn').removeClass(@oppositeTurn(@turn)).addClass(@turn)
      $('#alertMessageList .restart > span').addClass 'hidden'

      if playerWhoRestart == @pseudoOther
        message = $('#alertMessageList .restart .theOtherRestarted').text()
        $('#alertMessageList .restart .theOtherRestarted')
          .text message.replace('%s', @pseudoOther)
          .removeClass 'hidden'

      if firstToPlay == @pseudo
        $('#data .turn .pseudo').text @pseudo
        $('.score .black .pseudo').text @pseudo
        $('.score .white .pseudo').text @pseudoOther
        message = $('#alertMessageList .restart .youStart').text()
        $('#alertMessageList .restart .youStart')
          .removeClass 'hidden'
      else
        $('#data .turn .pseudo').text @pseudoOther
        $('.score .black .pseudo').text @pseudoOther
        $('.score .white .pseudo').text @pseudo
        message = $('#alertMessageList .restart .theOtherStarts').text()
        $('#alertMessageList .restart .theOtherStarts')
          .text message.replace('%s', @pseudoOther)
          .removeClass 'hidden'

      $('#alertMessage').html(
        $('#alertMessageList .restart').clone()
          .addClass('animated bounceIn')
      )

    oppositeTurn: (turn) ->
      return if turn == 'black' then 'white' else 'black'

  return Game
