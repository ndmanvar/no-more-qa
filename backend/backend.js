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
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    });
    // res.write(JSON.stringify({ status: OK })); // don't think I need this
    res.end();
  });
});

app.get('/getevents/:session', function (req, res) {
  connection.query('SELECT * FROM events WHERE event_uid = ?', req.params.session, function (error, results, fields) {
    if (error) throw error; // Need to implement proper error handler, otherwise request will show as pending
    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    });
    res.end(JSON.stringify(results));
  });
});

app.get('/gettest/:session', function (req, res) {
  const { exec } = require('child_process');

  /* I must be crazy to use ruby and invoke shell from node. This must be redone at some point, to something intelligent... */
  exec('pwd && cd ../test_creation && ruby create_test.rb ' + req.params.session, function (err, stdout, stderr) {
    if (err) {
      console.log(`stderr: ${stderr}`);
      // node couldn't execute the command
      return;
    }
    // the *entire* stdout and stderr (buffered)
    console.log(`stdout: ${stdout}`);
    console.log(`stderr: ${stderr}`);

    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    });

    res.end(JSON.stringify({ test: stdout }));
  });
});

app.get('/getallevents', function (req, res) {
  connection.query('SELECT * FROM events', function (error, results, fields) {
    if (error) throw error; // Need to implement proper error handler, otherwise request will show as pending
    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    });
    res.end(JSON.stringify(results));
  });
});

app.get('/getallsessions', function (req, res) {
  connection.query('SELECT DISTINCT(event_uid) AS event_uid FROM events;', function (error, results, fields) {
    if (error) throw error; // Need to implement proper error handler, otherwise request will show as pending
    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    });
    res.end(JSON.stringify(results));
  });
});


app.get('/getsafe/:session', function (req, res) {
  connection.query('SELECT * FROM events WHERE event_uid = ? and event_safe = 0', req.params.session, function (error, results, fields) {
    if (error) throw error; // Need to implement proper error handler, otherwise request will show as pending
    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
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
process.on('SIGINT', function () { // TODO: might need to also do for SIGTERM
  gracefulExit();
});

app.listen(3000);
