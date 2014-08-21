define ['jquery'], ($) ->

  class GuiTchat

    constructor: (@room, @pseudo, @pseudoOther) ->
      $('#tchat textarea')
        .removeAttr('disabled')
        .attr('placeholder', $('#tchat textarea').attr('data-placeholder'))
        .focus()

    writesSomething: (elem) ->
      if $.trim(elem.val()) != ''
        if event.keyCode == 13
          event.preventDefault()
          message = $.trim elem.val()
          elem.val('')
          @addMessage @pseudo, message
          return {type: 'sendMessage', message: message}
        else return {type: 'isWriting'}
      else return {type: 'isNotWriting'}

    addMessage: (pseudo, message) ->
      elem = $('<li>', {class: 'message'})
      elem.append $('<span>', {text: pseudo + ': ', class: 'pseudo'})
      elem.append $('<span>', {text: message, class: 'textMessage'})
      $('#tchat .writing').before elem

    showTheOtherIsWriting: ->
      $('#tchat .writing .pseudo').text @pseudoOther
      $('#tchat .writing').removeClass 'hidden'

    showTheOtherIsNotWriting: ->
      $('#tchat .writing').addClass 'hidden'


  return GuiTchat