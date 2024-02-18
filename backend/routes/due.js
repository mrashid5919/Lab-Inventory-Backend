const express = require("express");

const pool = require("../db");

const router = express.Router();

const { createDue,
viewDuesStudent,
viewDuesLocation } = require("../controller/dueController");

router.post("/createdue/:username/:reqID", createDue);
router.get("/viewduesstudent/:username", viewDuesStudent);
router.get("/viewdueslocation/:username", viewDuesLocation);

module.exports = router;