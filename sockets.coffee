config = require('./config')

data =
  'gameList': []
  'gameListPlayers': []
  'firstToPlayList': []
  'gameboardSize': config.defaultGameboardSize

module.exports.start = (io, i18n) ->

  io.sockets.on 'connection', (socket) ->
    socket.emit 'init', data.gameList

    socket.on 'submitNewGame', (p) ->
      p.gameName = p.gameName.trim()
      p.pseudo = p.pseudo.trim()
      if p.gameName == '' || p.pseudo == ''
        socket.emit 'errorSubmitNewGame', i18n.__('form.error.allRequired')
      else if data.gameList.indexOf(p.gameName) != -1
        socket.emit 'errorSubmitNewGame', i18n.__('form.error.uniqueGameName')
      else
        length = data.gameList.push p.gameName
        data.gameListPlayers[length - 1] = [p.pseudo]
        p.firstToPlay = if Math.random() < 0.5 then p.pseudo else null
        data.firstToPlayList[length - 1] = p.firstToPlay
        p.gameboardSize = data.gameboardSize
        socket.join p.gameName
        socket.emit 'successSubmitNewGame', p
        socket.broadcast.emit 'newGame', p.gameName

    socket.on 'submitJoinGame', (p) ->
      indexGame = data.gameList.indexOf p.gameName
      gameListPlayers = data.gameListPlayers[indexGame]
      p.pseudo = p.pseudo.trim()
      if p.pseudo == ''
        socket.emit 'errorSubmitJoinGame', i18n.__('form.error.pseudoRequired')
      else if gameListPlayers.indexOf(p.pseudo) != -1
        socket.emit 'errorSubmitJoinGame', i18n.__('form.error.uniquePseudo')
      else if gameListPlayers.length == 1
        data.gameListPlayers[indexGame].push p.pseudo
        p.pseudoOther = data.gameListPlayers[indexGame][0]
        p.firstToPlay = data.firstToPlayList[indexGame] || p.pseudo
        p.gameboardSize = data.gameboardSize
        socket.join p.gameName
        socket.emit 'successSubmitJoinGame', p
        socket.broadcast.to(p.gameName).emit 'otherPlayerArrived', p.pseudo
        socket.broadcast.emit 'removeGame', p.gameName

    socket.on 'disconnect', ->
      rooms = socket.rooms.slice(1)
      for gameName in rooms
        if data.gameListPlayers[data.gameList.indexOf gameName]
          stillOnePlayer = data.gameListPlayers[data.gameList.indexOf gameName].length == 2
          data.firstToPlayList.splice(data.gameList.indexOf(gameName), 1)
          data.gameListPlayers.splice(data.gameList.indexOf(gameName), 1)
          data.gameList.splice(data.gameList.indexOf(gameName), 1)
          socket.broadcast.emit 'removeGame', gameName
          if stillOnePlayer
            socket.broadcast.to(gameName).emit 'otherPlayerQuit'

    # Tchat
    socket.on 'tchatMessage', (gameName, message) ->
      socket.broadcast.to(gameName).emit 'receiveTchatMessage', message

    socket.on 'tchatWriting', (gameName) ->
      socket.broadcast.to(gameName).emit 'tchatWriting'

    socket.on 'tchatNotWriting', (gameName) ->
      socket.broadcast.to(gameName).emit 'tchatNotWriting'


    #Game
    socket.on 'endTurn', (gameName, game, lastPiecePlayed) ->
      socket.broadcast.to(gameName).emit 'endTurnOther', game, lastPiecePlayed

    socket.on 'otherCanPlay', (gameName) ->
      socket.broadcast.to(gameName).emit 'myTurn'

    socket.on 'impossiblePlayOther', (gameName) ->
      socket.broadcast.to(gameName).emit 'impossiblePlay'

    socket.on 'endGame', (gameName) ->
      socket.broadcast.to(gameName).emit 'endGame'

    socket.on 'restart', (gameName, pseudo, pseudoOther) ->
      playerWhoRestart = pseudo
      firstToPlay = if Math.random() < 0.5 then pseudo else pseudoOther
      io.sockets.to(gameName).emit 'restart', playerWhoRestart, firstToPlay
