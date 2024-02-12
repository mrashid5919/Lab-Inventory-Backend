const express = require("express");

const pool = require("../db");

const router = express.Router();

const { showNotifications } = require("../controller/notificationController");

router.get("/shownotifications/:user_id", showNotifications);

module.exports = router;