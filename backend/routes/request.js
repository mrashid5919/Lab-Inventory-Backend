const express = require("express");

const pool = require("../db");

const router = express.Router();

const {
  createRequest,
  sendRequesttoInventoryManager,
  showRequestsLabAssistant,
  showRequestsDeptHead,
  showSentRequests,
  acceptRequest,
  declineRequest,
  addComment,
  deleteRequest,
  forwardRequesttoSupervisor,
  getSupervisors,
  selectSupervisors,
  showRequestsSupervisor,
  cancelForwardRequesttoSupervisor,
  forwardRequesttoHead,
} = require("../controller/requestController");

router.post("/createrequest/:username/:equipmentID", createRequest);

router.post(
  "/sendrequesttoinventorymanager/:username/:equipmentID",
  sendRequesttoInventoryManager
);

router.get("/showrequests/:username", showRequestsLabAssistant);

router.get("/showsentrequests/:username", showSentRequests);

router.get("/showrequestsdepthead",showRequestsDeptHead);

router.get("/getsupervisors/:username", getSupervisors);

router.put("/acceptrequest/:reqID/:username", acceptRequest);

router.put("/declinerequest/:reqID/:username", declineRequest);

router.post("/addcomment/:reqID/:username", addComment);

router.delete("/deleterequest/:reqID", deleteRequest);

router.put("/forwardrequest/:reqID/:username", forwardRequesttoSupervisor);

router.post("/selectsupervisors/:reqID/:username", selectSupervisors);

router.get("/showrequestssupervisor/:username", showRequestsSupervisor);

router.put(
  "/cancelforwardrequest/:reqID/:username",
  cancelForwardRequesttoSupervisor
);

router.put("/forwardrequesttohead/:reqID/:username", forwardRequesttoHead);

module.exports = router;
