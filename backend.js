var express = require('express');
var app = express();

var mysql      = require('mysql');
var connection = mysql.createConnection({
    host     : 'localhost',
    user     : 'root',
    password : 'password',
    database : 'no-more-qa'
});

var bodyParser = require('body-parser');
app.use(bodyParser.json()); // support json encoded bodies
app.use(bodyParser.urlencoded({ extended: true })); // npm upport encoded bodies

connection.connect();

app.post('/event', function (req, res) {
  var obj = {
      event_type: req.body.type,
      event_value: req.body.key || null,
      event_uid: req.body.uid,
      event_testId: req.body.testId,
  };
  
  connection.query('INSERT INTO events SET ?', obj, function (error, results, fields) {
    if (error) throw error;
    console.log(results.insertId); // TODO
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
