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
checkClearanceRequests } = require("../controller/dueController");

router.post("/createdue/:username/:reqID", createDue);
router.get("/viewduesstudent/:username", viewDuesStudent);
router.get("/viewdueslocation/:username", viewDuesLocation);
router.post("/cleardue/:username/:dueID", clearDue);
router.get("/checkclearanceeligibility/:userID", checkClearanceEligibility);
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
module.exports = router;