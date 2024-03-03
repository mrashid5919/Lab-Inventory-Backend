const express = require("express");

const pool = require("../db");

const router = express.Router();

const { createRequisition,
    viewRequisitionsLabAssistant,
    viewRequisitionsInventoryManager,
    approveRequisition,
    rejectRequisition,
fulfilRequisition } = require("../controller/requisitionController");

router.post("/createrequisition/:username", createRequisition);
router.get("/viewrequisitionslabassistant/:username", viewRequisitionsLabAssistant);
router.get("/viewrequisitionsinventorymanager/:username", viewRequisitionsInventoryManager);
router.post("/approverequisition/:username/:requisition_id", approveRequisition);
router.post("/rejectrequisition/:username/:requisition_id", rejectRequisition);
router.post("/fulfilrequisition/:username/:requisition_id", fulfilRequisition);

module.exports = router;