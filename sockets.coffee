data = 
  'gameList': [] 
  'gameListPlayers': []
  'firstToPlayList': []

# Determine which player starts
defineWhoStarts = (pseudo) ->
  if Math.round(Math.random() * 2) == 0
    return pseudo
  return '???'

module.exports.start = (io, i18n) ->
  
  io.sockets.on 'connection', (socket) ->
    socket.emit 'getGameList', data.gameList

    socket.on 'submitNewGame', (gameName, pseudo) ->
      gameName = gameName.trim()
      pseudo = pseudo.trim()
      if gameName == '' || pseudo == ''
        socket.emit 'errorSubmitNewGame', i18n.__('form.error.allRequired')
      else if data.gameList.indexOf(gameName) != -1
        socket.emit 'errorSubmitNewGame', i18n.__('form.error.uniqueGameName')
      else
        length = data.gameList.push gameName
        data.gameListPlayers[length - 1] = [pseudo]
        data.firstToPlayList[length - 1] = firstToPlay = defineWhoStarts(pseudo)
        socket.join gameName
        socket.emit 'successSubmitNewGame', gameName, pseudo, firstToPlay
        socket.broadcast.emit 'newGame', gameName

    socket.on 'submitJoinGame', (gameName, pseudo) ->
      gameListPlayers = data.gameListPlayers[data.gameList.indexOf gameName]
      pseudo = pseudo.trim()
      if pseudo == ''
        socket.emit 'errorSubmitJoinGame', i18n.__('form.error.pseudoRequired')
      else if gameListPlayers.indexOf(pseudo) != -1
        socket.emit 'errorSubmitJoinGame', i18n.__('form.error.uniquePseudo')
      else if gameListPlayers.length == 1
        data.gameListPlayers[data.gameList.indexOf gameName].push pseudo
        pseudoFirstPlayer = data.gameListPlayers[data.gameList.indexOf gameName][0]
        firstToPlay = data.firstToPlayList[data.gameList.indexOf gameName]
        if firstToPlay == '???' then firstToPlay = pseudo
        socket.join gameName
        socket.emit 'successSubmitJoinGame', gameName, pseudo, firstToPlay, pseudoFirstPlayer
        socket.broadcast.to(gameName).emit 'secondPlayerArrived', pseudo
        socket.broadcast.emit 'removeGame', gameName

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
    socket.on 'tchatMessage', (gameName, pseudo, message) ->
      socket.broadcast.to(gameName).emit 'receiveTchatMessage', pseudo, message

    socket.on 'tchatWriting', (gameName, pseudo) ->
      socket.broadcast.to(gameName).emit 'tchatWriting', pseudo

    socket.on 'tchatNotWriting', (gameName, pseudo) ->
      socket.broadcast.to(gameName).emit 'tchatNotWriting', pseudo
