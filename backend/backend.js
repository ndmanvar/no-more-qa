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

app.get('/gettest/:projId/:session', function (req, res) {
  const { exec } = require('child_process');

  /* I must be crazy to use ruby and invoke shell from node. This must be redone at some point, to something intelligent... */
  exec('cd ../test_creation && ruby create_spec.rb ' + req.params.projId + ' ' + req.params.session +
  ' && ruby spec_to_test.rb', function (err, stdout, stderr) {
    if (err) {
      console.log(`stderr: ${stderr}`);
      // node couldn't execute the command
      return;
    }
    // the *entire* stdout and stderr (buffered)
    console.log(`stdout: ${stdout}`);

    res.writeHead(200, {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    });
    res.end(JSON.stringify({ test: stdout }));
  });
});

app.get('/getsafe/:session', function (req, res) {
  // TODO
});

process.on('SIGINT', function () { // TODO: might need to also do for SIGTERM
  try {
    connection.end();
  } finally {
    process.exit();
  }
});

app.listen(3000);
