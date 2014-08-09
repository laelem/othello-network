express = require('express')
router = express.Router()
ent = require("ent")
i18n = require("i18n")
config = require('../config')

router.get '/', (req, res) ->
  res.render 'start'

router.post '/play', (req, res) ->
  params = req.body.params
  params.firstPlayer = (params.firstPlayer == 'true' ? true : false)

  params.youStart = false
  if ((params.firstPlayer && params.firstToPlay == params.pseudoFirst) || 
  (params.firstPlayer == false && params.firstToPlay == params.pseudoSecond))
    params.youStart = true
  
  params.gameboard_size = config.default_gameboard_size
  params.middle1 = params.gameboard_size/2 - 1 
  params.middle2 = params.gameboard_size/2
  res.app.render 'index', {'params': params, '__': i18n.__}, (err, html) ->
    res.send({html: html})

module.exports = router
