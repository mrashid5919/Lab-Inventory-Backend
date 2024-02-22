const express = require("express");

const pool = require("../db");

const router = express.Router();

const { showNotifications,selectIndividualNotification,getUnseenNotificationCount } = require("../controller/notificationController");

router.get("/shownotifications/:username", showNotifications);

router.get("/selectindividualnotification/:notification_id", selectIndividualNotification);

router.get("/getunseennotificationcount/:username", getUnseenNotificationCount);

module.exports = router;