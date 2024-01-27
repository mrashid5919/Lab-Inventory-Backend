const pool = require("../db");

const validator = require("validator");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const showEquipments = async (req,res) => {
    try{
      const equipments = await pool.query("SELECT * FROM equipments");
      res.status(200).json(equipments.rows);
    }
    catch (error) {
      res.status(400).json({ error: error.message });
    }
  };

  const showEquipmentsManager = async (req,res) => {
    const username= req.params.username;
    //console.log(username);
    try{
      const equipments=await pool.query(`SELECT e.EQUIPMENT_NAME, el.EQUIPMENT_ID, el.quantity, el.LOAN
      FROM EQUIPMENTS e
      JOIN EQUIPMENTS_IN_LOCATIONS el ON e.EQUIPMENT_ID = el.EQUIPMENT_ID
      JOIN LOCATIONS l ON l.LOCATION_ID = el.LOCATION_ID
      JOIN USERS_IN_LOCATIONS ul ON ul.LOCATION_ID = l.LOCATION_ID
      JOIN USERS u ON u.USER_ID = ul.USER_ID
      WHERE u.username = $1`, [username]);
      res.status(200).json(equipments.rows);
    }
    catch (error) {
      res.status(400).json({ error: error.message });
    }
  };

  module.exports = { showEquipments , showEquipmentsManager};