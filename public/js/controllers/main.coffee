define ['jquery'], ($) ->

  $(() ->

    require(['bootstrap'])
    require(['cs!controllers/start'], (start) -> return start())

  )
