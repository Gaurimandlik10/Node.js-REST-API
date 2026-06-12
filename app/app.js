const express = require("express");
const bodyParser = require("body-parser");
const mongoose = require("mongoose");
const cors = require("cors");
// Import Creds
const mongo = require("./credentials/mongo");
// Imports for Routes
const todoRoutes = require("./routes/todo");
// Create an Express App
const app = express();
// Handle MongoDB Connection
mongoose
  .connect(process.env.MONGO_URI || mongo.localConnString, {
    useNewUrlParser: true
  })
  .then(() => {
    console.log("Connected to database!");
  })
  .catch(() => {
    console.log("Connection failed!");
  });
// Use body-parser to parse incoming requests
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
  extended: false
}));
// Use Cors to avoid annoying CORS Errors
app.use(cors());

// Health probe endpoints — required for Kubernetes probes
app.get('/health/live', (req, res) => {
  res.status(200).json({ status: 'alive' });
});

app.get('/health/ready', (req, res) => {
  res.status(200).json({ status: 'ready' });
});

// Send basic info about the API
app.use("/api/info", (req, res, next) => {
  res.status(200).json({
    name: "TODO Api",
    version: "1.0",
    description: "RESTful API Designed in Node.js for TODO application.",
    methodsAllowed: "GET, POST, PUT, PATCH, DELETE",
    authType: "None",
    rootEndPoint: req.protocol + '://' + req.get('host') + '/api/v1',
    documentation: "https://github.com/toslimarif/todo-api"
  });
});
// Set up API Routes
app.use("/api/v1/todo", todoRoutes);
module.exports = app;
