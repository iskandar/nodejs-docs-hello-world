
// Set up App Insights first
const appInsights = require("applicationinsights");
appInsights.setup(process.env.AI_INSTRUMENTATION_KEY ? process.env.AI_INSTRUMENTATION_KEY : 'none');
appInsights.start();
let aiClient = appInsights.defaultClient;
appInsights.defaultClient.commonProperties = {
    environment: process.env.ENVIRONMENT,
    nodeEnv: process.env.NODE_ENV,
    siteName: process.env.WEBSITE_IIS_SITE_NAME
};

var http = require('http');
var properties = require ("properties-parser");

// Read our build properties file
var buildProperties = properties.read("build.properties");

function startServer(error, buildProperties) {
    if (error) return console.error(error);
    
    // Dump our build and run-time variables
    console.log("build properties", buildProperties);
    console.log("env config", process.env);

    var server = http.createServer(function (request, response) {
        aiClient.trackNodeHttpRequest({request: req, response: res}); 
        response.writeHead(200, { "Content-Type": "text/html" });
        response.write("<h1>Hello World!</h1>");
        response.write("<h2>Build Properties</h2>");
        response.write("<textarea style='width: 100%; height: 300px;'>" + JSON.stringify(buildProperties, null, 2) + "</textarea>");
        response.write("<h2>Env Vars</h2>");
        response.write("<textarea style='width: 100%; height: 600px;'>" + JSON.stringify(process.env, null, 2) + "</textarea>");
        response.end();
    });

    var port = process.env.PORT || 1337;

    server.listen(port);

    console.log("Server running at http://localhost:%d", port);
}

startServer(null, buildProperties);