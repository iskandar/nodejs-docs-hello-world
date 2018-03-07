var http = require('http');
var _ = require('lodash');
var properties = require ("properties");
 
var buildProperties = { oops: "not found" };
properties.parse ("build.properties", { path: true }, function (error, obj){
    if (error) return console.error (error);
    buildProperties = obj;
  });

var server = http.createServer(function(request, response) {

    response.writeHead(200, {"Content-Type": "text/html"});
    response.write("<h1>Hello World!</h1>");
    response.write("<h2>Build Properties</h2>");
    response.write("<textarea style='width: 100%; height: 300px;'>" + JSON.stringify(buildProperties, null, 2) + "</textarea>");
    response.write("<h2>Env Vars</h2>");
    response.write("<textarea style='width: 100%; height: 600px;'>" + JSON.stringify(process.env, null, 2) + "</textarea>");
    response.end();
});

var port = process.env.PORT || 1337;

// Dump ALL of the environment vars
console.log("env config", process.env);

server.listen(port);

console.log("Server running at http://localhost:%d", port);
