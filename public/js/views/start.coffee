define ['jquery'], ($) ->
  
  class StartGui

    showGameList: (activeGameList, inactiveGameList) ->
      $('#joinGame .loading').remove()
      if activeGameList.length > 0
        for gameName in activeGameList
          $('#joinGame ul').prepend @getActiveGameElemList(gameName)
      if inactiveGameList.length > 0
        for gameName in inactiveGameList
          $('#joinGame ul').append @getInactiveGameElemList(gameName)
      if activeGameList.length == 0 && inactiveGameList.length == 0
        $('#joinGame .noGame').removeClass('hidden')

    getActiveGameElemList: (gameName) ->
      elem = $('#joinGame li.active.hidden').clone()
      elem.find('a').attr('data-gameName', gameName).text(gameName)
      return elem.removeClass('hidden')

    getInactiveGameElemList: (gameName) ->
      elem = $('#joinGame li.inactive.hidden').clone()
      elem.find('div').attr('data-gameName', gameName)
      elem.find('.gameName').text(gameName)
      return elem.removeClass('hidden')

    getParamsNewGame: ->
      return {    
        gameName: $('#newGame input[name="gameName"]').val()
        pseudo: $('#newGame input[name="pseudo"]').val()
      }

    showErrorSubmitNewGame: (errorMessage) ->
      $('#newGame .error').html(errorMessage).removeClass('hidden')

    showNewGame: (gameName) ->
      if $('#joinGame li:visible').length == 0
        $('#joinGame .noGame').addClass('hidden')
      $('#joinGame ul').prepend @getActiveGameElemList(gameName)

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
      $('#joinGame [data-gameName="' + gameName + '"]').parent('li').remove()
      if $('#joinGame li:visible').length == 0
        $('#joinGame .noGame').removeClass('hidden')

    fullGame: (gameName) ->
      $('#joinGame [data-gameName="' + gameName + '"]').parent('li').remove()
      $('#joinGame ul').append @getInactiveGameElemList(gameName)

    showOtherPlayerArrived: ->
      $('#alertMessage').html(
        $('#alertMessageList .alertAnotherPlayer').clone()
          .addClass('animated bounceIn')
      )

  return StartGui






