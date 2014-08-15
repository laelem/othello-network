(function() {
  var app, bodyParser, coffee, express, i18n, io, nib, path, routes, server, sockets, socketsManagement, stylus;

  express = require('express');

  app = express();

  path = require('path');

  bodyParser = require('body-parser');

  sockets = require('socket.io');

  i18n = require("i18n");

  coffee = require('coffee-script');

  stylus = require('stylus');

  nib = require('nib');

  coffee.register();

  routes = require(path.join(__dirname, 'routes', 'index'));

  socketsManagement = require(path.join(__dirname, 'sockets'));

  app.set('port', process.env.PORT || 8888);

  app.set('views', path.join(__dirname, 'views'));

  app.set('view engine', 'jade');

  app.use(bodyParser.json());

  app.use(bodyParser.urlencoded());

  i18n.configure({
    locales: ['en', 'fr'],
    objectNotation: true,
    directory: path.join(__dirname, 'locales')
  });

  app.use(i18n.init);

  app.use(stylus.middleware({
    src: path.join(__dirname, 'assets'),
    dest: path.join(__dirname, 'public'),
    compile: function(str, pathname) {
      return stylus(str).set('filename', pathname).set('compress', true).use(nib());
    }
  }));

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
