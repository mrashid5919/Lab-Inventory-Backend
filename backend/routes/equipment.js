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
  getLocations,
  getInventories,
  showInventoryEquipments,
  getEquipmentQuantity
} = require("../controller/equipmentController");

router.get("/", showEquipmentsStudent);

router.get("/showinventoryequipments", showInventoryEquipments);

router.get("/:username", showEquipmentsManager);

router.get("/labassistant/:username", showEquipmentsLabAssistant);

router.post("/addnewequipment", addNewEquipment);

router.get("/equipment/:id", getIndividualEquipment);

router.get("/equipment/:id/locations", getLocations);

router.get("/equipment/:id/inventories", getInventories);

router.get("/equipment/:equipment_name/:username", getEquipmentQuantity);

module.exports = router;
