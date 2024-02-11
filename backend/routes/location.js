const express = require("express");

const pool = require("../db");

const router = express.Router();

const {
  seePendingRegistrations,
  assignLocation,
  showUsers,
  getLabs,
} = require("../controller/locationController");

router.get("/seependingregistrations", seePendingRegistrations);
router.post("/assignlocation/:user_id", assignLocation);
router.get("/showusers", showUsers);
router.get("/getlabs", getLabs);

module.exports = router;
