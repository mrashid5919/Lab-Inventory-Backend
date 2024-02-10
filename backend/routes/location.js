const express=require("express");

const pool=require("../db");

const router=express.Router();

const {seePendingRegistrations,assignLocation,showUsers}=require("../controller/locationController");

router.get("/seependingregistrations",seePendingRegistrations);
router.put("/assignlocation/:user_id",assignLocation);
router.get("/showusers",showUsers);

module.exports=router;