const express = require("express");

const pool = require("../db");

const router = express.Router();

const {
  seePendingRegistrations,
  assignLocation,
  showUsers,
  getLabs,
  seePendingRegistrationsAll,
  acceptUser,
  rejectUser,
  showEquipments,
  showRequests,
  showDues,
  showMonetaryDues
} = require("../controller/locationController");

router.get("/seependingregistrations", seePendingRegistrations);
router.get("/seependingregistrationsall",seePendingRegistrationsAll);
router.post("/assignlocation/:user_id", assignLocation);
router.get("/showusers", showUsers);
router.get("/getlabs", getLabs);
router.post("/acceptuser/:user_id",acceptUser);
router.post("/rejectuser/:user_id",rejectUser);
router.get("/showequipments",showEquipments);
router.get("/showrequests",showRequests);
router.get("/showdues",showDues);
router.get("/showmonetarydues",showMonetaryDues);

module.exports = router;
