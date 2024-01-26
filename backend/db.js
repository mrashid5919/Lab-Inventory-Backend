const Pool = require("pg").Pool;

const pool = new Pool({
  host: "localhost",
  user: "postgres",
  password: "mr1234",
  port: 5432,
  database: "labinventory",
});

module.exports = pool;
