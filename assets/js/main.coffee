getGameElemList = (gameName) ->
  data = '<li><a class="bg-info" href="#" data-gameName="' + encodeURIComponent(gameName)
  data+= '">' + gameName + '</a></li>'
  return data

getGameBoard = (params) ->
  $.post '/play', {params: params}, (data) ->
    $(document).prop 'title', $(document).prop('title') + ' >> ' + params.gameName
    $('#main').html(data.html);

(($) ->
  socket = io.connect(window.location.href)

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

  $('#modalJoinGame .submit').on 'click', ->
    gameName = decodeURIComponent $('#modalJoinGame .submit').attr('data-gameName')
    pseudo = $('#modalJoinGame input[name="pseudo"]').val()
    socket.emit 'submitJoinGame', gameName, pseudo

  socket.on 'errorSubmitJoinGame', (errorMessage) ->
    $('#modalJoinGame .error').html(errorMessage).removeClass('hidden')

  socket.on 'successSubmitJoinGame', (gameName, pseudo, firstToPlay, pseudoFirstPlayer) ->
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
    $('.pseudoToReplace').text pseudo
    $('#tchat .hidden').removeClass 'hidden'

  socket.on 'otherPlayerQuit', ->
    $('#modalOtherPlayerQuit').modal()

  $('body').on 'click', '#modalOtherPlayerQuit .linkBackToHome', ->
    window.location.href = '/'

) jQuery
