const express=require("express");

const pool=require("../db");

const router=express.Router();

const {createRequest,showRequestsLabAssistant,acceptRequest,declineRequest,addComment,deleteRequest,forwardRequesttoSupervisor,getSupervisors,selectSupervisors}=require("../controller/requestController");

router.post("/createrequest/:username/:equipmentID",createRequest);

router.get("/showrequests/:username",showRequestsLabAssistant);

router.get("/getsupervisors/:username",getSupervisors);

router.put("/acceptrequest/:reqID/:username",acceptRequest);

router.put("/declinerequest/:reqID/:username",declineRequest);

router.post("/addcomment/:reqID/:username",addComment);

router.delete("/deleterequest/:reqID",deleteRequest);

router.put("/forwardrequest/:reqID/:username",forwardRequesttoSupervisor);

router.post("/selectsupervisors/:reqID",selectSupervisors);

module.exports=router;