define ['jquery'], ($) ->

  return () ->
    
    socket = window.socket

    $('body').on 'keyup', '#tchat textarea', (event) ->
      action = guiTchat.writesSomething $(this)
      switch action.type
        when 'sendMessage'
          socket.emit 'tchatNotWriting', guiTchat.room
          socket.emit 'tchatMessage', guiTchat.room, action.message
        when 'isWriting'
          socket.emit 'tchatWriting', guiTchat.room
        when 'isNotWriting'
          socket.emit 'tchatNotWriting', guiTchat.room

    socket.on 'receiveTchatMessage', (message) ->
      guiTchat.addMessage guiTchat.pseudoOther, message

    socket.on 'tchatWriting', ->
      guiTchat.showTheOtherIsWriting()

    socket.on 'tchatNotWriting', ->
      guiTchat.showTheOtherIsNotWriting()
      


  