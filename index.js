var http = require('http');
var _ = require('lodash');

var server = http.createServer(function(request, response) {

    response.writeHead(200, {"Content-Type": "text/html"});
    response.write("<h1>Hello World!</h1>");
    response.write("<h2>Env vars:</h2>");
    response.write("<textarea style='width: 100%; height: 600px;'>" + JSON.stringify(process.env, null, 2) + "</textarea>");
    response.end();
});

var port = process.env.PORT || 1337;

// Dump ALL of the environment vars
console.log("env config", process.env);

server.listen(port);

console.log("Server running at http://localhost:%d", port);
