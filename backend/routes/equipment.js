const express = require("express");

const pool = require("../db");

const router = express.Router();

const {showEquipments,showEquipmentsManager,addNewEquipment}=require("../controller/equipmentController");

router.get("/",showEquipments);

router.get("/:username",showEquipmentsManager);

router.post("/addnewequipment",addNewEquipment);

module.exports=router;