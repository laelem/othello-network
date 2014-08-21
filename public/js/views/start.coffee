define ['jquery'], ($) ->
  
  class StartGui

    showGameList: (gameList) ->
      $('#joinGame .loading').remove()
      if gameList.length > 0
        for gameName in gameList
          elem = @getGameElemList(gameName)
          $('#joinGame ul').append elem
      else
        $('#joinGame .noGame').removeClass('hidden')

    getGameElemList: (gameName) ->
      elem = $('<li>')
      elem.append $('<a>', {
        class: 'bg-info'
        href: '#'
        text: gameName
        'data-gameName': gameName
      })
      return elem

    getParamsNewGame: ->
      return {    
        gameName: $('#newGame input[name="gameName"]').val()
        pseudo: $('#newGame input[name="pseudo"]').val()
      }

    showErrorSubmitNewGame: (errorMessage) ->
      $('#newGame .error').html(errorMessage).removeClass('hidden')

    showNewGame: (gameName) ->
      if $('#joinGame li').length == 0
        $('#joinGame .noGame').addClass('hidden')
      $('#joinGame ul').append @getGameElemList(gameName)

    showGameTemplate: (gameName, html) ->      
      $(document).prop 'title', $(document).prop('title') + ' >> ' + gameName
      $('#main').html(html)
      $('#tchat textarea').focus()

    showJoinGameModal: (link) ->
      gameName = link.attr('data-gameName')
      title = $('#modalJoinGame .modal-title').attr 'data-title'
      $('#modalJoinGame .modal-title').text title.replace('%s', gameName)
      $('#modalJoinGame .submit').attr 'data-gameName', gameName
      $('#modalJoinGame').modal()

    showErrorSubmitJoinGame: (errorMessage) ->
       $('#modalJoinGame .error').html(errorMessage).removeClass('hidden')

    hideJoinGameModal: ->
      $('#modalJoinGame').modal('hide')

    focusJoinGameModal: ->
      $('#pseudoJoinGame').focus()

    getParamsJoinGame: (event) ->
      return {      
        gameName: $('#modalJoinGame .submit').attr('data-gameName')
        pseudo: $('#modalJoinGame input[name="pseudo"]').val()
      }

    removeGame: (gameName) ->
      $('#joinGame a[data-gameName="' + gameName + '"]').parent('li').remove()
      if $('#joinGame li').length == 0
        $('#joinGame .noGame').removeClass('hidden')

    showOtherPlayerArrived: ->
      $('#alertMessage').html(
        $('#alertMessageList .alertAnotherPlayer').clone()
          .addClass('animated bounceIn')
      )

  return StartGui






