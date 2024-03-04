const express = require("express");

const pool = require("../db");

const router = express.Router();

const { createDue,
viewDuesStudent,
viewDuesLocation,
clearDue,
checkClearanceEligibility,
reportLostorDamaged,
viewLostorDamaged,
showEstimateDue,
createMonetaryDue,
viewMonetaryDueStudent,
MonetaryDuesLocation,
clearMonetaryDue,
createClearanceRequest,
checkClearanceExistence,
checkClearanceRequests,
acceptClearance,
rejectClearance,
finalCallforClearance,
dueDateAlert } = require("../controller/dueController");

router.post("/createdue/:username/:reqID", createDue);
router.get("/viewduesstudent/:username", viewDuesStudent);
router.get("/viewdueslocation/:username", viewDuesLocation);
router.post("/cleardue/:username/:dueID", clearDue);
router.get("/checkclearanceeligibility/:username", checkClearanceEligibility);
router.post("/duedatealert/:username", dueDateAlert);
router.post("/reportlostordamaged/:username/:dueID", reportLostorDamaged);
router.get("/viewlostordamaged/:username",viewLostorDamaged);
router.get("/showestimatedue/:username/:dueID", showEstimateDue);
router.post("/createmonetarydue/:username/:dueID", createMonetaryDue);
router.get("/viewmonetaryduesstudent/:username", viewMonetaryDueStudent);
router.get("/monetarydueslocation/:username", MonetaryDuesLocation);
router.post("/clearmonetarydue/:username/:dueID", clearMonetaryDue);
router.post("/createclearancerequest/:username", createClearanceRequest);
router.get("/checkclearanceexistence/:username", checkClearanceExistence);
router.get("/checkclearancerequests", checkClearanceRequests);
router.post("/acceptclearance/:username/:clearance_req_id", acceptClearance);
router.post("/rejectclearance/:username/:clearance_req_id", rejectClearance);
router.post("/finalcallforclearance/:username/:clearance_req_id", finalCallforClearance);

module.exports = router;