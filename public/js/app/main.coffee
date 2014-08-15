define ['socket.io', 'jquery', 'cs!app/game'], (io, $, Game) ->

  $(() ->

    socket = window.socket = io.connect(window.location.href)

    requirejs(['bootstrap'])
    requirejs(['cs!app/tchat'])

    socket.on 'init', (gameList) ->
      $('#joinGame .loading').remove()
      if gameList.length > 0
        $.each gameList, (i, gameName) ->
          $('#joinGame ul').append getGameElemList(gameName)
      else
        $('#joinGame .noGame').removeClass('hidden')

    $('#newGame [type="submit"]').on 'click', ->
      params =
        gameName: $('#newGame input[name="gameName"]').val()
        pseudo: $('#newGame input[name="pseudo"]').val()
      socket.emit 'submitNewGame', params
      return false

    socket.on 'errorSubmitNewGame', (errorMessage) ->
      $('#newGame .error').html(errorMessage).removeClass('hidden')

    socket.on 'successSubmitNewGame', (params) ->
      params.firstPlayer = true
      params.pseudoOther = null
      window.game = new Game params
      getGameBoard params

    socket.on 'newGame', (gameName) ->
      if $('#joinGame li').length == 0
        $('#joinGame .noGame').addClass('hidden')
      $('#joinGame ul').append getGameElemList(gameName)

    $('#joinGame').on 'click', 'a', (event) ->
      event.preventDefault()
      gameName = $(this).attr('data-gameName')
      title = $('#modalJoinGame .modal-title').attr 'data-title'
      $('#modalJoinGame .modal-title').text title.replace('%s', gameName)
      $('#modalJoinGame .submit').attr 'data-gameName', gameName
      $('#modalJoinGame').modal()

    $('#modalJoinGame').on 'shown.bs.modal', (e) ->
      $('#pseudoJoinGame').focus()

    $('#modalJoinGame .submit').on 'click', ->
      tryToJoinGame socket
      return false

    $('#modalJoinGame input').keydown (event) ->
        if event.keyCode == 13
          event.preventDefault()
          tryToJoinGame socket

    socket.on 'errorSubmitJoinGame', (errorMessage) ->
      $('#modalJoinGame .error').html(errorMessage).removeClass('hidden')

    socket.on 'successSubmitJoinGame', (params) ->
      params.firstPlayer = false
      window.game = new Game params
      $('#modalJoinGame').modal('hide')
      getGameBoard params

    socket.on 'removeGame', (gameName) ->
      $('#joinGame a[data-gameName="' + gameName + '"]').parent('li').remove()
      if $('#joinGame li').length == 0
        $('#joinGame .noGame').removeClass('hidden')

    socket.on 'otherPlayerArrived', (pseudo) ->
      window.game.setPseudoOther pseudo
      $('.pseudoToReplace').text pseudo
      $('#alertMessage').html(
        $('#alertMessageList .alertAnotherPlayer').clone()
          .addClass('animated bounceIn')
      )
      $('#tchat textarea')
        .removeAttr('disabled')
        .attr('placeholder', $('#tchat textarea').attr('data-placeholder'))
        .focus()

    socket.on 'otherPlayerQuit', ->
      $('#modalOtherPlayerQuit').modal()

    $('body').on 'click', '#modalOtherPlayerQuit .linkBackToHome', ->
      window.location.href = '/'

    $('body').on 'click', '#modalQuit .submit', ->
      window.location.href = '/'


    $('body').on 'click', '#gameboard .case', (event) ->
      action = window.game.playShot $(this)
      if action 
        socket.emit 'endTurn', window.game.gameName, window.game.game, window.game.lastPiecePlayed
      switch action
        when 'otherCanPlay' 
          socket.emit 'otherCanPlay', window.game.gameName
        when 'impossiblePlayOther' 
          socket.emit 'impossiblePlayOther', window.game.gameName
        when 'endGame' 
          socket.emit 'endGame', window.game.gameName

    socket.on 'endTurnOther', (game, lastPiecePlayed) ->
      window.game.endTurnOther game, lastPiecePlayed

    socket.on 'myTurn', ->
      window.game.myTurn()

    socket.on 'impossiblePlay', ->
      window.game.impossiblePlay()

    socket.on 'endGame', ->
      window.game.endGame()

    $('body').on 'click', '#actions .restart', ->
      $('#modalRestart').modal()

    $('body').on 'click', '#modalRestart .submit', ->
      socket.emit 'restart', window.game.gameName, window.game.pseudo, window.game.pseudoOther

    socket.on 'restart', (playerWhoRestart, firstToPlay) ->
      window.game.restart playerWhoRestart, firstToPlay
      $('#modalRestart').modal('hide')


    getGameElemList = (gameName) ->
      elem = $('<li>')
      elem.append $('<a>', {
        class: 'bg-info'
        href: '#'
        text: gameName
        'data-gameName': gameName
      })
      return elem

    getGameBoard = (params) ->
      $.post '/play', {params: params}, (data) ->
        $(document).prop 'title', $(document).prop('title') + ' >> ' + params.gameName
        $('#main').html(data.html)
        $('#tchat textarea').focus()
        window.game.updateGameBoard()

    tryToJoinGame = (socket) ->
      params =
        gameName: $('#modalJoinGame .submit').attr('data-gameName')
        pseudo: $('#modalJoinGame input[name="pseudo"]').val()
      socket.emit 'submitJoinGame', params

  )
