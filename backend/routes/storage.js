const express = require("express");

const pool = require("../db");

const router = express.Router();

const { updateStorage } = require("../controller/storageController");

router.put("/updatestorage/:username", updateStorage);

module.exports = router;
