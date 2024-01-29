const pool = require("../db");

const validator = require("validator");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const createToken = (user_id) => {
  return jwt.sign({ user_id }, process.env.JWT_SECRET_TOKEN, {
    expiresIn: "2h",
  });
};

const checkValidity = async (req) => {
  const { username, first_name, last_name, email, password, role, phone_no } =
    req.body;

  if (
    !username ||
    !first_name ||
    !last_name ||
    !email ||
    !password ||
    !role ||
    !phone_no
  ) {
    throw Error("All fields are required");
  }

  if (!validator.isEmail(email)) {
    throw Error("Email is not valid");
  }

  const userByEmail = await pool.query("SELECT * FROM users WHERE email = $1", [
    email,
  ]);

  if (userByEmail.rows.length > 0) {
    throw Error("This email already exists");
  }

  const userByName = await pool.query(
    "SELECT * FROM users WHERE username = $1",
    [username]
  );

  if (userByName.rows.length > 0) {
    throw Error("Username already exists");
  }

  const salt = await bcrypt.genSalt(10);
  const hashed_password = await bcrypt.hash(password, salt);
  //console.log(hashed_password);

  let newUser = await pool.query(
    "INSERT INTO users (username, first_name, last_name, email, password, role, phone_no) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *",
    [username, first_name, last_name, email, hashed_password, role, phone_no]
  );

  return newUser;
};

const checkAuthenticity = async (username, password) => {
  //console.log(username, password);
  if (!username || !password) {
    throw Error("All fields are required");
  }

  const user = await pool.query("SELECT * FROM users WHERE username = $1", [
    username,
  ]);

  if (user.rows.length === 0) {
    throw Error("Wrong username");
  }

  const validPassword = await bcrypt.compare(password, user.rows[0].password);

  if (!validPassword) {
    throw Error("Wrong Password");
  }

  return user;
};

const signUpUser = async (req, res) => {
  try {
    const newUser = await checkValidity(req);

    const token = createToken(newUser.rows[0].user_id);
    const username=newUser.rows[0].username;
    const role=newUser.rows[0].role;

    res.json({ token });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const loginUser = async (req, res) => {
  const { username, password } = req.body;

  try {
    const user = await checkAuthenticity(username, password);
    const token = createToken(user.rows[0].user_id); //the _id is added when the user was first created
    const role = user.rows[0].role;

    res.status(200).json({ username, token , role});
  } catch (error) {
    res.status(400).json({ error: error.message });
  }

  //res.json({ msg: "login req received" });
};

module.exports = { signUpUser, loginUser };
