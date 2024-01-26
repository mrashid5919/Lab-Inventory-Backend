const pool = require("../db");

const validator = require("validator");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const showEquipments = async (req,res) => {
    try{
      const equipments = await pool.query("SELECT * FROM equipments");
      res.status(200).json({equipments: equipments.rows});
    }
    catch (error) {
      res.status(400).json({ error: error.message });
    }
  };

  module.exports = { showEquipments };