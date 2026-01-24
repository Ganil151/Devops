const { Pool } = require('pg');

const pool = new Pool({
  user: 'admin',
  password: 'admin3773',
  host: 'localhost',
  database: 'call_center_crm',
  port: 5432,
});

pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('Error connecting to the database', err);
  } else {
    console.log('Connected to the database successfully:', res.rows[0]);
    pool.end();
  }
});

module.exports = {
  query: (text, params) => pool.query(text, params),
}