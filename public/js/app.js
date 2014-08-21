requirejs.config({
    "baseUrl": "js/lib",
    "paths": {
      "controllers": "../controllers",
      "models": "../models",
      "views": "../views",
      "jquery": "//cdnjs.cloudflare.com/ajax/libs/jquery/2.1.1/jquery.min",
      "bootstrap": "//maxcdn.bootstrapcdn.com/bootstrap/3.2.0/js/bootstrap.min",
      "socket.io": "/socket.io/socket.io"
    }
});

requirejs(["cs!controllers/main"]);
