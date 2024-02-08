const express=require("express");

const pool=require("../db");

const router=express.Router();

const {createRequest,showRequestsLabAssistant,acceptRequest,declineRequest,addComment,deleteRequest,forwardRequesttoSupervisor}=require("../controller/requestController");

router.post("/createrequest/:username/:equipmentID",createRequest);

router.get("/showrequests/:username",showRequestsLabAssistant);

router.put("/acceptrequest/:reqID/:username",acceptRequest);

router.put("/declinerequest/:reqID/:username",declineRequest);

router.post("/addcomment/:reqID/:username",addComment);

router.delete("/deleterequest/:reqID",deleteRequest);

router.put("/forwardrequest/:reqID/:username",forwardRequesttoSupervisor);

module.exports=router;