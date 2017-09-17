var mysql      = require('mysql');
var connection = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : 'password',
  database : 'no-more-qa'
});

connection.connect();

connection.query('SELECT * FROM sessions', function (error, results, fields) {
  if (error) throw error;
  console.log(results);
});

connection.end();
