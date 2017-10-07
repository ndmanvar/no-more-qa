var express = require('express');
var app = express();

var mysql = require('mysql');
var connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'password',
  database: 'no-more-qa'
});

var bodyParser = require('body-parser');
app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({
  extended: true
})); // npm upport encoded bodies

connection.connect();

app.post('/event', function (req, res) {
  var obj = {
    event_type: req.body.type,
    event_value: req.body.key || null,
    event_uid: req.body.uid,
    event_testId: req.body.testId,
    event_safe: req.body.safe
  };

  connection.query('INSERT INTO events SET ?', obj, function (error, results, fields) {
    if (error) throw error; // Need to implement proper error handler, otherwise request will show as pending

    res.writeHead(200, {
      'Content-Type': 'application/json'
    });
    // res.write(JSON.stringify({ status: OK })); // don't think I need this
    res.end();
  });


});

app.get('/getevents/:session', function (req, res) {
  connection.query('SELECT * FROM events WHERE event_uid = ?', req.params.session, function (error, results, fields) {
    if (error) throw error; // Need to implement proper error handler, otherwise request will show as pending
    res.writeHead(200, {
      'Content-Type': 'application/json'
    });
    res.end(JSON.stringify(results));
  });
});

app.get('/getsafe/:session', function (req, res) {
  connection.query('SELECT * FROM events WHERE event_uid = ? and event_safe = 0', req.params.session, function (error, results, fields) {
    if (error) throw error; // Need to implement proper error handler, otherwise request will show as pending
    res.writeHead(200, {
      'Content-Type': 'application/json'
    });
    res.end(JSON.stringify({
      safe: !results.length
    }));
  });
});

function gracefulExit() {
  try {
    connection.end();
  } finally {
    process.exit();
  }
}
process.on('SIGINT', function () { // might need to also do for SIGTERM
  gracefulExit();
});

app.listen(3000);
