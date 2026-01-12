const database = require('./db');

database.query('SELECT * FROM user')
  .then(res => console.log(res.rows))
  .catch(err => console.error('Error executing query', err));