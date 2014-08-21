define ['jquery'], ($) ->
  
  class OthelloGui

    setScore: (score) ->
      for color, number of score
        $('.score .'+color+' .number').text number

    setPseudoColor: (params) ->
      for color,pseudo of params
        $('.score .'+color+' .pseudo').text(pseudo || '???')

    setPseudoOther: (pseudo) ->
      $('.pseudoToReplace').text pseudo 

    setGameboard: (game) ->
      for y,row of game
        for x,frame of row
          $('#gameboard circle[data-position="y'+y+'-x'+x+'"]').attr 'data-color', frame

    getEmptyCasePosition: (elem) ->
      position = elem.attr('data-position') 
      if $('#gameboard circle[data-position="'+position+'"]').attr('data-color') == ''
        return {
          y: parseInt(elem.attr('data-y'), 10)
          x: parseInt(elem.attr('data-x'), 10)
        }
      return null

    showLastPiecePlayed: (lastPiecePlayed) ->
      $('#gameboard [data-last-played="true"]').attr('data-last-played', 'false')
      if lastPiecePlayed != ''
        $('#gameboard rect[data-position="'+lastPiecePlayed+'"]').attr('data-last-played', 'true')

    showNewTurn: (oldTurn, newTurn, pseudo) ->
      $('#data .turn')
        .removeClass oldTurn
        .addClass newTurn
      $('#data .turn .pseudo').text(pseudo || '???')

    showOtherTurn: (oldTurn, newTurn, pseudoOther) ->
      @showNewTurn oldTurn, newTurn, pseudoOther
      $('#alertMessage').html(
        $('#alertMessageList .theOtherTurn')
          .clone()
          .addClass('animated bounceIn')
      )

    showMyTurn: (oldTurn, newTurn, pseudo) ->
      @showNewTurn oldTurn, newTurn, pseudo
      $('#alertMessage').html(
        $('#alertMessageList .yourTurn').clone()
          .addClass('animated bounceIn')
      )

    showImpossiblePlay: ->
      $('#alertMessage').html(
        $('#alertMessageList .impossiblePlay')
          .clone()
          .addClass('animated bounceIn')
      )

    showImpossiblePlayOther: ->
      $('#alertMessage').html(
        $('#alertMessageList .impossiblePlayOther')
          .clone()
          .addClass('animated bounceIn')
      )

    showEndGameEqual: ->
      $('#alertMessage').html(
        $('#alertMessageList .endGameEqual').clone()
          .addClass('animated bounceIn')
      )

    showEndGame: (winner) ->
      message = $('#alertMessageList .endGame').text()
      $('#alertMessage').html(
        $('#alertMessageList .endGame').clone()
          .text message.replace('%s', winner)
          .addClass('animated bounceIn')
      )

    showOtherPlayerQuitModal: ->
      $('#modalOtherPlayerQuit').modal()
    
    showRestartModal: ->
      $('#modalRestart').modal()

    alertRestart: (playerWhoRestart, firstToPlay, pseudo, pseudoOther) ->
      $('#modalRestart').modal('hide')
      $('#alertMessageList .restart > span').addClass 'hidden'

      if playerWhoRestart == pseudoOther
        message = $('#alertMessageList .restart .theOtherRestarted').text()
        $('#alertMessageList .restart .theOtherRestarted')
          .text message.replace('%s', pseudoOther)
          .removeClass 'hidden'

      if firstToPlay == pseudo
        message = $('#alertMessageList .restart .youStart').text()
        $('#alertMessageList .restart .youStart')
          .removeClass 'hidden'
      else
        message = $('#alertMessageList .restart .theOtherStarts').text()
        $('#alertMessageList .restart .theOtherStarts')
          .text message.replace('%s', pseudoOther)
          .removeClass 'hidden'

      $('#alertMessage').html(
        $('#alertMessageList .restart').clone()
          .addClass('animated bounceIn')
      )


  return OthelloGui

