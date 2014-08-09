ent = require("ent")

module.exports.start = (io, i18n) ->

  data = 
    'gameList': [] 
    'gameListPlayers': []
    'firstToPlayList': []
  
  io.sockets.on 'connection', (socket) ->
    socket.emit 'getGameList', data.gameList

    socket.on 'submitNewGame', (gameName, pseudo) ->
      gameName = ent.decode gameName.trim()
      pseudo = ent.decode pseudo.trim()
      if gameName == '' || pseudo == ''
        socket.emit 'errorSubmitNewGame', i18n.__('form.error.allRequired')
      else if data.gameList.indexOf(gameName) != -1
        socket.emit 'errorSubmitNewGame', i18n.__('form.error.uniqueGameName')
      else
        length = data.gameList.push gameName
        data.gameListPlayers[length - 1] = [pseudo]

        # Determine which player starts
        if Math.round(Math.random() * 2) == 0
          firstToPlay = pseudo
        else
          firstToPlay = '???'
        data.firstToPlayList[length - 1] = firstToPlay

        socket.join encodeURIComponent(gameName)
        socket.emit 'successSubmitNewGame', gameName, pseudo, firstToPlay
        socket.broadcast.emit 'newGame', gameName

    socket.on 'submitJoinGame', (gameName, pseudo) ->
      gameListPlayers = data.gameListPlayers[data.gameList.indexOf gameName]
      pseudo = ent.decode pseudo.trim()
      if pseudo == ''
        socket.emit 'errorSubmitJoinGame', i18n.__('form.error.pseudoRequired')
      else if gameListPlayers.indexOf(pseudo) != -1
        socket.emit 'errorSubmitJoinGame', i18n.__('form.error.uniquePseudo')
      else
        pseudoFirstPlayer = data.gameListPlayers[data.gameList.indexOf gameName][0]
        firstToPlay = data.firstToPlayList[data.gameList.indexOf gameName]
        if firstToPlay == '???' then firstToPlay = pseudo
        socket.join encodeURIComponent(gameName)
        socket.emit 'successSubmitJoinGame', gameName, pseudo, firstToPlay, pseudoFirstPlayer
        socket.broadcast.to(encodeURIComponent(gameName)).emit 'secondPlayerArrived', pseudo

        # Remove the game from lists
        data.firstToPlayList.splice(data.gameList.indexOf(gameName), 1)
        data.gameListPlayers.splice(data.gameList.indexOf(gameName), 1)
        data.gameList.splice(data.gameList.indexOf(gameName), 1)
        io.sockets.emit 'maxPlayers', gameName

    # socket.on 'getFirstToPlay', (gameName, pseudo) ->
    #   socket.emit 'firstToPlay'
