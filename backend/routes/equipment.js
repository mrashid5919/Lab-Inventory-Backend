const express = require("express");

const pool = require("../db");

const router = express.Router();

const {
  showEquipments,
  showEquipmentsManager,
  addNewEquipment,
  showEquipmentsStudent,
  showEquipmentsLabAssistant,
  getIndividualEquipment,
} = require("../controller/equipmentController");

router.get("/", showEquipmentsStudent);

router.get("/:username", showEquipmentsManager);

router.get("/labassistant/:username", showEquipmentsLabAssistant);

router.post("/addnewequipment", addNewEquipment);

router.get("/equipment/:id", getIndividualEquipment);

module.exports = router;
