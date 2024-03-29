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
      `SELECT e.EQUIPMENT_NAME, el.EQUIPMENT_ID, el.available, el.borrowed, e.image_link
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
      `SELECT e.EQUIPMENT_NAME, el.EQUIPMENT_ID, el.available, el.borrowed, e.image_link
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

const showInventoryEquipments = async (req, res) => {
  //console.log(req)
  //console.log("ashchi")
  try {
    const equipments = await pool.query(
      `SELECT e.equipment_id,e.equipment_name,e.type,e.cost,e.descript,sum(el.available) as available,sum(el.borrowed) as borrowed,e.demand,e.permit,e.image_link
      FROM equipments e
      JOIN equipments_in_locations el
      ON e.equipment_id=el.equipment_id
      JOIN locations l
      ON el.location_id=l.location_id
      JOIN location_types lt
      ON l.location_type=lt.location_type_id
      WHERE lt.location_type_name='Inventory'
      GROUP BY e.equipment_id,e.equipment_name,e.type,e.cost,e.descript,e.demand,e.permit;`
    );
    //console.log("here");
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
    "INSERT INTO equipments (equipment_name, type, cost, descript, borrowed, available, demand, permit,image_link) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *",
    [name, category, cost, description, 0, quant, 1, permit,image]
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

const getLocations = async (req, res) => {
  equipment_id = req.params.id;
  try {
    const locations = await pool.query(`SELECT l.location_id,l.location_name,el.available
    FROM locations l
    JOIN equipments_in_locations el
    ON l.location_id=el.location_id
    WHERE el.equipment_id=$1 AND l.location_id!=1;`,[equipment_id]);
    res.status(200).json(locations.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const getInventories = async (req, res) => {
  equipment_id = req.params.id;
  try {
    const locations = await pool.query(`SELECT l.location_id,l.location_name,el.available
    FROM locations l
    JOIN equipments_in_locations el
    ON l.location_id=el.location_id
    WHERE el.equipment_id=$1 AND l.location_type=1;`,[equipment_id]);
    res.status(200).json(locations.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const getEquipmentQuantity = async (req, res) => {
  username=req.params.username; 
  equipment_name=req.params.equipment_name;
  try {
    const user=await pool.query("SELECT * FROM users WHERE username=$1",[username]);
    const location_id=await pool.query(`SELECT location_id FROM users_in_locations WHERE user_id=$1`,[user.rows[0].user_id]);
    const equipment=await pool.query(`SELECT e.equipment_id,el.available FROM equipments e
    JOIN equipments_in_locations el
    ON e.equipment_id=el.equipment_id
    WHERE e.equipment_name=$1 AND el.location_id=$2`,[equipment_name,location_id.rows[0].location_id]);
    res.status(200).json(equipment.rows[0]);
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
  getLocations,
  showInventoryEquipments,
  getInventories,
  getEquipmentQuantity
};
