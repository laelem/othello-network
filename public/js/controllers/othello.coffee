define ['jquery'], ($) ->

  return () ->

    socket = window.socket


    socket.on 'otherPlayerQuit', ->
      socket.emit 'leaveGame', window.game.gameName
      window.game.gui.showOtherPlayerQuitModal()

    $('body').on 'hide.bs.modal', '#modalOtherPlayerQuit', ->
      window.location.href = '/'

    $('body').on 'click', '#modalOtherPlayerQuit .linkBackToHome', ->
      window.location.href = '/'

    $('body').on 'click', '#modalQuit .submit', ->
      window.location.href = '/'

    $('body').on 'click', '#gameboard rect', (event) ->
      game = window.game
      action = game.playShot $(this)
      if action 
        socket.emit('endTurn', game.gameName, game.game, game.lastPiecePlayed, game.score)
      switch action
        when 'otherCanPlay' 
          socket.emit 'otherCanPlay', game.gameName
        when 'impossiblePlayOther' 
          socket.emit 'impossiblePlayOther', game.gameName
        when 'endGame' 
          socket.emit 'endGame', game.gameName

    socket.on 'endTurnOther', (game, lastPiecePlayed, score) ->
      window.game.endTurnOther game, lastPiecePlayed, score

    socket.on 'myTurn', ->
      window.game.myTurn()

    socket.on 'impossiblePlay', ->
      window.game.gui.showImpossiblePlay()

    socket.on 'endGame', ->
      window.game.endGame()

    $('body').on 'click', '#actions .restart', ->
      window.game.gui.showRestartModal()

    $('body').on 'click', '#modalRestart .submit', ->
      game = window.game
      socket.emit 'restart', game.gameName, game.pseudo, game.pseudoOther

    socket.on 'restart', (playerWhoRestart, firstToPlay) ->
      window.game.restart playerWhoRestart, firstToPlay
