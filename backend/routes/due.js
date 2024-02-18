const express = require("express");

const pool = require("../db");

const router = express.Router();

const { createDue } = require("../controller/dueController");

router.post("/createdue/:username/:reqID", createDue);

module.exports = router;