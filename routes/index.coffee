express = require('express')
router = express.Router()
i18n = require("i18n")
config = require('../config')

router.get '/', (req, res) ->
  res.render 'start'

router.post '/play', (req, res) ->
  params = req.body.params
  params.linkRules = config.linkRules
  params.firstToPlay = params.firstToPlay || '???'
  params.pseudoOther = params.pseudoOther || '???'
  params.firstPlayer = if params.firstPlayer == 'true' then true else false
  res.app.render 'index', {'params': params, '__': i18n.__}, (err, html) ->
    res.send({html: html})

module.exports = router
