define ['cs!views/start', 'cs!views/tchat', 'cs!models/othello', 'socket.io', 'jquery'], (StartGui, GuiTchat, OthelloModel, io, $) ->

  return () ->

    socket = window.socket = io.connect(window.location.href)
    startGui = new StartGui


    # Init

    socket.on 'init', (gameList) ->
      startGui.showGameList gameList
      

    # Create new game
    
    $('#newGame [type="submit"]').on 'click', ->
      params = startGui.getParamsNewGame()
      socket.emit 'submitNewGame', params
      return false

    socket.on 'errorSubmitNewGame', (errorMessage) ->
      startGui.showErrorSubmitNewGame errorMessage

    socket.on 'successSubmitNewGame', (params) ->
      params.firstPlayer = true
      params.pseudoOther = null
      $.post '/play', {params: params}, (data) ->
        startGui.showGameTemplate params.gameName, data.html
        window.game = new OthelloModel params
        window.game.initGame()

    socket.on 'newGame', (gameName) ->
      startGui.showNewGame gameName

    socket.on 'otherPlayerArrived', (pseudo) ->
      window.game.setPseudoOther pseudo
      startGui.showOtherPlayerArrived()
      window.guiTchat = new GuiTchat(window.game.gameName, window.game.pseudo, window.game.pseudoOther)
      

    # Join game

    $('#joinGame').on 'click', 'a', (event) ->
      event.preventDefault()
      startGui.showJoinGameModal $(this)

    $('#modalJoinGame').on 'shown.bs.modal', ->
      startGui.focusJoinGameModal()

    $('#modalJoinGame .submit').on 'click', ->
      params = startGui.getParamsJoinGame()
      socket.emit 'submitJoinGame', params
      return false

    $('#modalJoinGame input').keydown (event) ->
        if event.keyCode == 13
          event.preventDefault()
          params = startGui.getParamsJoinGame event
          socket.emit 'submitJoinGame', params

    socket.on 'errorSubmitJoinGame', (errorMessage) ->
      startGui.showErrorSubmitJoinGame errorMessage

    socket.on 'successSubmitJoinGame', (params) ->
      params.firstPlayer = false
      startGui.hideJoinGameModal()
      $.post '/play', {params: params}, (data) ->
        startGui.showGameTemplate params.gameName, data.html
        window.game = new OthelloModel params
        window.game.initGame()
        window.guiTchat = new GuiTchat(window.game.gameName, window.game.pseudo, window.game.pseudoOther)

    socket.on 'removeGame', (gameName) ->
      startGui.removeGame gameName


    require(['cs!controllers/othello'], (othello) -> return othello())
    require(['cs!controllers/tchat'], (tchat) -> return tchat())


    

