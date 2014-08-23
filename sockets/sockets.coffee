config = require('../config')

data =
  'gameList': []
  'gameStatusList': []
  'playersList': []
  'firstToPlayList': []
  'gameboardSize': config.defaultGameboardSize

module.exports.start = (io, i18n) ->

  io.sockets.on 'connection', (socket) ->
    activeGameList = data.gameList.filter (x) -> data.gameStatusList[data.gameList.indexOf(x)] == true
    inactiveGameList = data.gameList.filter (x) -> data.gameStatusList[data.gameList.indexOf(x)] == false
    socket.emit 'init', activeGameList, inactiveGameList

    socket.on 'submitNewGame', (p) ->
      p.gameName = p.gameName.trim()
      p.pseudo = p.pseudo.trim()
      if p.gameName == '' || p.pseudo == ''
        socket.emit 'errorSubmitNewGame', i18n.__('form.error.allRequired')
      else if data.gameList.indexOf(p.gameName) != -1
        socket.emit 'errorSubmitNewGame', i18n.__('form.error.uniqueGameName')
      else
        data.gameList.push p.gameName
        data.gameStatusList.push true
        data.playersList.push [p.pseudo]
        p.firstToPlay = if Math.random() < 0.5 then p.pseudo else null
        data.firstToPlayList.push p.firstToPlay
        p.gameboardSize = data.gameboardSize
        socket.join p.gameName
        socket.emit 'successSubmitNewGame', p
        socket.broadcast.emit 'newGame', p.gameName

    socket.on 'submitJoinGame', (p) ->
      indexGame = data.gameList.indexOf p.gameName
      playersList = data.playersList[indexGame]
      p.pseudo = p.pseudo.trim()
      if p.pseudo == ''
        socket.emit 'errorSubmitJoinGame', i18n.__('form.error.pseudoRequired')
      else if playersList.indexOf(p.pseudo) != -1
        socket.emit 'errorSubmitJoinGame', i18n.__('form.error.uniquePseudo')
      else if playersList.length == 1
        data.playersList[indexGame].push p.pseudo
        data.gameStatusList[indexGame] = false
        p.pseudoOther = data.playersList[indexGame][0]
        p.firstToPlay = data.firstToPlayList[indexGame] || p.pseudo
        p.gameboardSize = data.gameboardSize
        socket.join p.gameName
        socket.emit 'successSubmitJoinGame', p
        socket.broadcast.to(p.gameName).emit 'otherPlayerArrived', p.pseudo
        socket.broadcast.emit 'fullGame', p.gameName

    socket.on 'disconnect', ->
      rooms = socket.rooms.slice(1)
      for gameName in rooms
        indexGame = data.gameList.indexOf gameName
        if data.playersList[indexGame]
          stillOnePlayer = data.playersList[indexGame].length == 2
          data.firstToPlayList.splice(indexGame, 1)
          data.playersList.splice(indexGame, 1)
          data.gameStatusList.splice(indexGame, 1)
          data.gameList.splice(indexGame, 1)
          socket.broadcast.emit 'removeGame', gameName
          if stillOnePlayer
            socket.broadcast.to(gameName).emit 'otherPlayerQuit'

    socket.on 'leaveGame', (gameName) ->
      socket.leave gameName


    # Tchat
    socket.on 'tchatMessage', (gameName, message) ->
      socket.broadcast.to(gameName).emit 'receiveTchatMessage', message

    socket.on 'tchatWriting', (gameName) ->
      socket.broadcast.to(gameName).emit 'tchatWriting'

    socket.on 'tchatNotWriting', (gameName) ->
      socket.broadcast.to(gameName).emit 'tchatNotWriting'


    #Game
    socket.on 'endTurn', (gameName, game, lastPiecePlayed, score) ->
      socket.broadcast.to(gameName).emit 'endTurnOther', game, lastPiecePlayed, score

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
