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
      for i,row of @game
        for j,frame of row
          index1 = (parseInt(i, 10) + 1).toString()
          index2 = (parseInt(j, 10) + 1).toString()
          elem = $('#gameboard .row:nth-child('+index1+') .case:nth-child('+index2+')')
          if frame != ''
            if frame == 'black' then blackScore += 1 else whiteScore += 1
            elem.html $('<span>', {class: 'piece '+frame})
          else
            elem.html('')
      @blackScore = blackScore
      @whiteScore = whiteScore
      $('.score .black .number').text blackScore
      $('.score .white .number').text whiteScore

    playShot: (elem) ->
      if @pseudoOther isnt null && @turn == @color && elem.has('.piece').length == 0
        frame = elem.index()
        row = elem.parent().index()
        pieces = @shot(row, frame, @color, false)
        if pieces.length > 0
          @game[row][frame] = @color
          @lastPiecePlayed.row = row
          @lastPiecePlayed.frame = frame
          $('#gameboard .case').removeClass 'lastPlayed'
          elem.addClass 'lastPlayed'
          for piece in pieces
            @game[piece.row][piece.frame] = @color
          @endTurn()

    showLastPiecePlayed: ->
      row = (parseInt(@lastPiecePlayed.row, 10) + 1).toString()
      frame = (parseInt(@lastPiecePlayed.frame, 10) + 1).toString()
      elem = $('#gameboard .row:nth-child('+row+') .case:nth-child('+frame+')')
      $('#gameboard .case').removeClass 'lastPlayed'
      elem.addClass 'lastPlayed'

    shot: (row, frame, color, possibility) ->
      pieces = []
      for nearCase in @nearCases
        dist = 0
        tmpPieces = []
        loop
          dist++
          gameCaseRow = @game[row + nearCase.y * dist] || null
          gameCase = if gameCaseRow then gameCaseRow[frame + nearCase.x * dist] || null else null
          if gameCase && gameCase != ''
            if gameCase != color
              tmpPieces.push {row: row + nearCase.y * dist, frame: frame + nearCase.x * dist}
            else
              if tmpPieces.length > 0
                if possibility then return true
                pieces = pieces.concat tmpPieces
              break
          else
            break
      if possibility then return false else return pieces

    hasPossibleShot: (color) ->
      for row in [0...@gameboardSize]
        for frame in [0...@gameboardSize]
          if @game[row][frame] == '' && @shot(row, frame, color, true)
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
