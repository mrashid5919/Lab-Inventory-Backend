const pool = require("../db");

const updateStorage = async (req, res) => {
  console.log("keu nehi hota");

  if (!req.body.name || !req.body.quantity) {
    return res.status(400).json({ error: "All fields are required" });
  }

  console.log("kfdkljsdf");
  console.log(typeof req.body.quantity);
  const equipmentName = req.body.name;
  const equipmentIDquery = await pool.query(
    "SELECT equipment_id FROM equipments WHERE equipment_name = $1",
    [equipmentName]
  );

  if (equipmentIDquery.rows.length == 0) {
    throw Error("Wrong equipment name");
  }
  const equipmentID = equipmentIDquery.rows[0].equipment_id;

  const username = req.params.username;
  const location_IDquery = await pool.query(
    "SELECT location_id FROM users_in_locations WHERE user_id = (SELECT user_id FROM users WHERE username = $1)",
    [username]
  );

  if (location_IDquery.rows.length == 0) {
    throw Error("Wrong username");
  }
  const location_ID = location_IDquery.rows[0].location_id;
  console.log(location_ID)

  const quant = parseInt(req.body.quantity, 10);

  try {
    equip = await pool.query(
      "SELECT * FROM equipments WHERE equipment_id = $1",
      [equipmentID]
    );
    //console.log(equip.rows[0]);
    await pool.query(
      "UPDATE equipments SET available = $1 WHERE equipment_id = $2",
      [equip.rows[0].available + quant, equipmentID]
    );

    //console.log("upadate wewwwwwwwwwwwwwww");
    //console.log(updatedEquipment.rows[0]);

    equip = await pool.query(
      "SELECT * FROM equipments_in_locations WHERE equipment_id = $1 AND location_id = $2",
      [equipmentID,location_ID]
    );
    //console.log(equip.rows[0]);
    let check=await pool.query(
      "UPDATE equipments_in_locations SET available = $1 WHERE equipment_id = $2 AND location_id = $3 RETURNING *",
      [equip.rows[0].available + quant, equipmentID, location_ID]
    );
    //console.log(check.rows[0])

    const updatedEquipment = await pool.query(
      `SELECT el.available,e.equipment_id,e.equipment_name,e.image_link,el.borrowed
      FROM equipments e
      JOIN equipments_in_locations el
      ON e.equipment_id=el.equipment_id AND el.location_id = $1
      WHERE e.equipment_id = $2`,
      [location_ID,equipmentID]
    );
    //const updatedEquipment=await pool.query("SELECT update_storage($1,$2,$3)",[equipmentID,location_ID,quantity]);
    //console.log(updatedEquipment.rows[0]);
    res.status(200).json(updatedEquipment.rows[0]);
  } catch (error) {
    //console.log("for surely");
    res.status(400).json({ error: error.message });
  }
};

module.exports = { updateStorage };
