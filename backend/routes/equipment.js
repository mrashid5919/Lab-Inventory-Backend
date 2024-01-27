const express = require("express");

const pool = require("../db");

const router = express.Router();

const {showEquipments,showEquipmentsManager}=require("../controller/equipmentController");

router.get("/",showEquipments);

router.get("/:username",showEquipmentsManager);

module.exports=router;