const express = require("express");

const pool = require("../db");

const router = express.Router();

const { signUpUser, loginUser } = require("../controller/userController");

//signup a new user
router.post("/signup", signUpUser);

//login a user
router.post("/login", loginUser);

//export this router to other files
module.exports = router;
