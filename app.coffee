express = require('express')
app = express()

path = require('path')
bodyParser = require('body-parser')
sockets = require('socket.io')
i18n = require("i18n")
coffee = require('coffee-script')
stylus = require('stylus')
nib = require('nib')

coffee.register()

routes = require(path.join(__dirname, 'routes', 'index'))
socketsManagement = require(path.join(__dirname, 'sockets'))

app.set 'port', process.env.PORT || 8888

# view engine setup
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'jade'

app.use bodyParser.json()
app.use bodyParser.urlencoded()

# i18n
i18n.configure {
  locales:['fr'],
  defaultLocale: 'fr',
  objectNotation: true,
  directory: path.join(__dirname, 'locales')
}
app.use i18n.init

# Assets
app.use stylus.middleware(
  src: path.join(__dirname, 'assets')
  dest: path.join(__dirname, 'public')
  compile: (str, pathname) ->
    stylus(str)
      .set('include css', true)
      .set('filename', pathname)
      .set('compress', true)
      .use(nib())
)
app.use express.static(path.join(__dirname, 'public'))

app.use '/', routes

# catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error('Not Found')
  err.status = 404
  next(err)


## error handlers

# development error handler
# will print stacktrace
if app.get('env') == 'development'
  app.use (err, req, res, next) ->
    res.status(err.status || 500)
    res.render 'error', {
      message: err.message,
      error: err
    }

# production error handler
# no stacktraces leaked to user
app.use (err, req, res, next) ->
  res.status(err.status || 500)
  res.render 'error', {
    message: err.message,
    error: {}
  }


# Start server
server = app.listen app.get('port'), ->
  console.log 'Listening on port %d', server.address().port

# Sockets
io = sockets.listen server
socketsManagement.start io, i18n
