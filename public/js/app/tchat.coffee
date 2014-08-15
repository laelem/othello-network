define [], () ->

  socket = window.socket

  $('body').on 'keyup', '#tchat textarea', (event) ->
    if $.trim($(this).val()) != ''
      if event.keyCode == 13
        event.preventDefault()
        message = $.trim $(this).val()
        $(this).val('')
        addTchatMessage window.game.pseudo, message
        socket.emit 'tchatNotWriting', window.game.gameName
        socket.emit 'tchatMessage', window.game.gameName, message
      else
        socket.emit 'tchatWriting', window.game.gameName
    else
      socket.emit 'tchatNotWriting', window.game.gameName

  socket.on 'receiveTchatMessage', (message) ->
    addTchatMessage window.game.pseudoOther, message

  socket.on 'tchatWriting', ->
    $('#tchat .writing .pseudo').text window.game.pseudoOther
    $('#tchat .writing').removeClass 'hidden'

  socket.on 'tchatNotWriting', ->
    $('#tchat .writing').addClass 'hidden'


  addTchatMessage = (pseudo, message) ->
    elem = $('<li>', {class: 'message'})
    elem.append $('<span>', {text: pseudo + ': ', class: 'pseudo'})
    elem.append $('<span>', {text: message, class: 'textMessage'})
    $('#tchat .writing').before elem
