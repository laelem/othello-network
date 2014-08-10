getGameElemList = (gameName) ->
  data = '<li><a class="bg-info" href="#" data-gameName="' + encodeURIComponent(gameName)
  data+= '">' + gameName + '</a></li>'
  return data

getGameBoard = (params) ->
  $.post '/play', {params: params}, (data) ->
    $(document).prop 'title', $(document).prop('title') + ' >> ' + params.gameName
    $('#main').html(data.html)
    $('#tchat textarea').focus()

tryToJoinGame = (socket) ->
  gameName = decodeURIComponent $('#modalJoinGame .submit').attr('data-gameName')
  pseudo = $('#modalJoinGame input[name="pseudo"]').val()
  socket.emit 'submitJoinGame', gameName, pseudo

addTchatMessage = (pseudo, message) ->
  elem = '<li><span class="pseudo">' + pseudo + ':</span> ' + message + '</li>'
  $('#tchat .writing').before(elem)


(($) ->
  socket = io.connect(window.location.href)
  window.pseudo = ''
  window.pseudoOtherPlayer = ''
  window.gameName = ''

  socket.on 'getGameList', (gameList) ->
    $('#joinGame .loading').remove()
    if gameList.length > 0
      $.each gameList, (i, gameName) ->
        $('#joinGame ul').append getGameElemList(gameName)
    else
      $('#joinGame .noGame').removeClass('hidden')

  $('#newGame [type="submit"]').on 'click', ->
    socket.emit 'submitNewGame',
      $('#newGame input[name="gameName"]').val(),
      $('#newGame input[name="pseudo"]').val()
    return false

  socket.on 'errorSubmitNewGame', (errorMessage) ->
    $('#newGame .error').html(errorMessage).removeClass('hidden')

  socket.on 'successSubmitNewGame', (gameName, pseudo, firstToPlay) ->
    window.gameName = gameName
    window.pseudo = pseudo
    params = 
      gameName: gameName
      pseudoFirst: pseudo
      pseudoSecond: '???'
      firstPlayer: true
      firstToPlay: firstToPlay
    getGameBoard params
    
  socket.on 'newGame', (gameName) ->
    if $('#joinGame li').length == 0
      $('#joinGame .noGame').addClass('hidden')
    $('#joinGame ul').append getGameElemList(gameName) 

  $('#joinGame').on 'click', 'a', (event) ->
    event.preventDefault()
    gameName = decodeURIComponent $(this).attr('data-gameName')
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

  socket.on 'successSubmitJoinGame', (gameName, pseudo, firstToPlay, pseudoFirstPlayer) ->
    window.gameName = gameName
    window.pseudo = pseudo
    window.pseudoOtherPlayer = pseudoFirstPlayer
    $('#modalJoinGame').modal('hide')
    params = 
      gameName: gameName
      pseudoFirst: pseudoFirstPlayer
      pseudoSecond: pseudo
      firstPlayer: false
      firstToPlay: firstToPlay
    getGameBoard params

  socket.on 'removeGame', (gameName) ->
    $('#joinGame a[data-gameName="' + encodeURIComponent(gameName) + '"]').parent('li').remove()
    if $('#joinGame li').length == 0
      $('#joinGame .noGame').removeClass('hidden')

  socket.on 'secondPlayerArrived', (pseudo) ->
    window.pseudoOtherPlayer = pseudo
    $('.pseudoToReplace').text pseudo
    $('#tchat .showOnLoad').removeClass 'hidden'

  socket.on 'otherPlayerQuit', ->
    window.pseudoOtherPlayer = ''
    $('#modalOtherPlayerQuit').modal()

  $('body').on 'click', '#modalOtherPlayerQuit .linkBackToHome', ->
    window.location.href = '/'


  # Tchat
  $('body').on 'keyup', '#tchat textarea', (event) ->
      if $.trim($(this).val()) != ''
        if event.keyCode == 13 
          event.preventDefault()
          message = $.trim $(this).val()
          $(this).val('')
          addTchatMessage window.pseudo, message
          socket.emit 'tchatNotWriting', window.gameName, window.pseudo
          socket.emit 'tchatMessage', window.gameName, window.pseudo, message
        else
          socket.emit 'tchatWriting', window.gameName, window.pseudo
      else
          socket.emit 'tchatNotWriting', window.gameName, window.pseudo

  socket.on 'receiveTchatMessage', (pseudo, message) ->
    addTchatMessage pseudo, message

  socket.on 'tchatWriting', (pseudo) ->
    $('#tchat .writing .pseudo').text pseudo
    $('#tchat .writing').removeClass 'hidden'

  socket.on 'tchatNotWriting', (pseudo) ->
    $('#tchat .writing').addClass 'hidden'

) jQuery
