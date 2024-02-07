const pool = require("../db");

const validator = require("validator");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const showEquipments = async (req, res) => {
  try {
    const equipments = await pool.query("SELECT * FROM equipments");
    res.status(200).json(equipments.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const showEquipmentsManager = async (req, res) => {
  const username = req.params.username;
  //console.log(username);
  try {
    const equipments = await pool.query(
      `SELECT e.EQUIPMENT_NAME, el.EQUIPMENT_ID, el.available, el.borrowed
      FROM EQUIPMENTS e
      JOIN EQUIPMENTS_IN_LOCATIONS el ON e.EQUIPMENT_ID = el.EQUIPMENT_ID
      JOIN LOCATIONS l ON l.LOCATION_ID = el.LOCATION_ID
      JOIN USERS_IN_LOCATIONS ul ON ul.LOCATION_ID = l.LOCATION_ID
      JOIN USERS u ON u.USER_ID = ul.USER_ID
      WHERE u.username = $1`,
      [username]
    );
    res.status(200).json(equipments.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const showEquipmentsLabAssistant = async (req, res) => {
  const username = req.params.username;
  //console.log(username);
  try {
    const equipments = await pool.query(
      `SELECT e.EQUIPMENT_NAME, el.EQUIPMENT_ID, el.available, el.borrowed
      FROM EQUIPMENTS e
      JOIN EQUIPMENTS_IN_LOCATIONS el ON e.EQUIPMENT_ID = el.EQUIPMENT_ID
      JOIN LOCATIONS l ON l.LOCATION_ID = el.LOCATION_ID
      JOIN USERS_IN_LOCATIONS ul ON ul.LOCATION_ID = l.LOCATION_ID
      JOIN USERS u ON u.USER_ID = ul.USER_ID
      WHERE u.username = $1`,
      [username]
    );
    res.status(200).json(equipments.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const showEquipmentsStudent = async (req, res) => {
  //console.log(username);
  try {
    const equipments = await pool.query(
      "SELECT * FROM equipments WHERE available > 0"
    );
    res.status(200).json(equipments.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const getIndividualEquipment = async (req, res) => {
  const id = req.params.id;
  try {
    const equipments = await pool.query(
      "SELECT * FROM equipments WHERE equipment_id = $1",
      [id]
    );
    res.status(200).json(equipments.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const addNewEquipment = async (req, res) => {
  const { name, quantity, category, cost, description, permit, image } =
    req.body;
  if (!name || !quantity || !category || !cost || !description || !permit) {
    return res.status(400).json({ error: "All fields are required" });
  }
  const quant = parseInt(quantity, 10);
  let NewEquipment = await pool.query(
    "INSERT INTO equipments (equipment_name, type, cost, descript, borrowed, available, demand, permit) VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *",
    [name, category, cost, description, 0, quant, 1, permit]
  );
  await pool.query(
    "INSERT INTO equipments_in_locations (equipment_id, location_id, available, borrowed) VALUES ($1, $2, $3, $4)",
    [NewEquipment.rows[0].equipment_id, 1, quant, 0]
  );
  try {
    res.status(200).json(NewEquipment.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

module.exports = {
  showEquipments,
  showEquipmentsManager,
  showEquipmentsLabAssistant,
  addNewEquipment,
  showEquipmentsStudent,
  getIndividualEquipment,
};
