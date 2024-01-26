const express = require("express");

const pool = require("../db");

const router = express.Router();

const {showEquipments}=require("../controller/equipmentController");

router.get("/",showEquipments);

module.exports=router;