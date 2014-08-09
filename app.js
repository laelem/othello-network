(function() {
  var app, assets, bodyParser, coffee, cookieParser, express, i18n, io, path, reload, routes, server, sockets, socketsManagement;

  express = require('express');

  app = express();

  reload = require('reload');

  path = require('path');

  cookieParser = require('cookie-parser');

  bodyParser = require('body-parser');

  sockets = require('socket.io');

  i18n = require("i18n");

  assets = require('connect-assets');

  coffee = require('coffee-script');

  coffee.register();

  routes = require(path.join(__dirname, 'routes', 'index'));

  socketsManagement = require(path.join(__dirname, 'sockets'));

  app.set('port', process.env.PORT || 8888);

  app.set('views', path.join(__dirname, 'views'));

  app.set('view engine', 'jade');

  app.use(bodyParser.json());

  app.use(bodyParser.urlencoded());

  app.use(cookieParser());

  i18n.configure({
    locales: ['en', 'fr'],
    objectNotation: true,
    directory: path.join(__dirname, 'locales')
  });

  app.use(i18n.init);

  app.use(assets());

  app.use(express.static(path.join(__dirname, 'public')));

  app.use('/', routes);

  app.use(function(req, res, next) {
    var err;
    err = new Error('Not Found');
    err.status = 404;
    return next(err);
  });

  if (app.get('env') === 'development') {
    app.use(function(err, req, res, next) {
      res.status(err.status || 500);
      return res.render('error', {
        message: err.message,
        error: err
      });
    });
  }

  app.use(function(err, req, res, next) {
    res.status(err.status || 500);
    return res.render('error', {
      message: err.message,
      error: {}
    });
  });

  server = app.listen(app.get('port'), function() {
    return console.log('Listening on port %d', server.address().port);
  });

  io = sockets.listen(server);

  socketsManagement.start(io, i18n);

}).call(this);
