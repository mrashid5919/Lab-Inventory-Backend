const express=require("express");

const pool=require("../db");

const router=express.Router();

const {seePendingRegistrations}=require("../controller/locationController");

router.get("/seependingregistrations",seePendingRegistrations);

module.exports=router;