var http = require('http');

var server = http.createServer(function(request, response) {

    response.writeHead(200, {"Content-Type": "text/html"});
    response.end("<h1>Hello World!</h1>");

});

var port = process.env.PORT || 1337;

// Dump ALL of the environment vars
console.log("env config", process.env);

server.listen(port);

console.log("Server running at http://localhost:%d", port);
