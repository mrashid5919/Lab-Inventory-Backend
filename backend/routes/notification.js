const express = require("express");

const pool = require("../db");

const router = express.Router();

const { showNotifications,selectIndividualNotification } = require("../controller/notificationController");

router.get("/shownotifications/:username", showNotifications);

router.get("/selectindividualnotification/:notification_id", selectIndividualNotification)

module.exports = router;