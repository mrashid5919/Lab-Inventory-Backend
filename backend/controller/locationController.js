const pool = require("../db");

const seePendingRegistrations = async (req, res) => {
  try {
    const pendingRegistrations = await pool.query(
      "SELECT user_id,first_name,last_name,role FROM users WHERE assigned=3 AND (role='Lab Assistant' OR role='Teacher' or role='Inventory Manager');"
    );
    res.status(200).json(pendingRegistrations.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const seePendingRegistrationsAll = async (req,res) => {
  try {
    const pendingRegistrations = await pool.query(
      "SELECT user_id,username,first_name,last_name,role,email FROM users WHERE assigned=0;"
    );
    res.status(200).json(pendingRegistrations.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

const showUsers = async (req, res) => {
  try {
    const users = await pool.query(
      `SELECT u.user_id,u.username,u.first_name,u.last_name,u.email,u.role,u.phone_no,l.location_name
            FROM users u
            JOIN users_in_locations ul ON u.user_id=ul.user_id
            JOIN locations l ON l.location_id=ul.location_id`
    );
    res.status(200).json(users.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const assignLocation = async (req, res) => {
  //console.log("here");
  let user_id = req.params.user_id;
  let location_id = req.body.location_id;
  location_id = parseInt(location_id);
  user_id = parseInt(user_id);
  //console.log(location_id);
  try {
    let role = await pool.query(
      "SELECT role,assigned FROM users WHERE user_id=$1",
      [user_id]
    );
    //console.log(role.rows[0]);
    let assigned = role.rows[0].assigned;
    role = role.rows[0].role;

    if (assigned == 0 || assigned==3) {
      //console.log("here");
      const assignloc = await pool.query(
        "INSERT INTO users_in_locations (user_id,location_id,role) VALUES ($1,$2,$3) RETURNING *",
        [user_id, location_id, role]
      );
      //console.log("here");
      //console.log(assignloc.rows[0]);
      const assign = await pool.query(
        "UPDATE users SET assigned=$1 WHERE user_id=$2 RETURNING *",
        [1, user_id]
      );
      //console.log(assignloc);
      //console.log(assign.rows[0]);
      res.status(200).json(assignloc.rows[0]);
    } else {
      //console.log(location_id, user_id);
      const assignloc = await pool.query(
        "UPDATE users_in_locations SET location_id=$1 WHERE user_id=$2 RETURNING *",
        [location_id, user_id]
      );
      //console.log("hobi kina bol");
      console.log(assignloc);
      res.status(200).json(assignloc.rows[0]);
    }
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const getLabs = async (req, res) => {
  try {
    let location_type = await pool.query(
      "SELECT * FROM LOCATION_TYPES WHERE location_type_name='Lab';"
    );
    location_type = location_type.rows[0].location_type_id;
    const labs = await pool.query(
      "SELECT * FROM locations WHERE location_type=$1",
      [location_type]
    );
    res.status(200).json(labs.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const acceptUser = async (req,res) => {
  const user_id=req.params.user_id;
  try{
    const u=await pool.query("SELECT * from USERS WHERE user_id=$1",[user_id]);
    if(u.rows[0].role=="Lab Assistant" || u.rows[0].role=="Teacher" || u.rows[0].role=="Inventory Manager")
    {
      const user=await pool.query("UPDATE USERS set assigned=3 WHERE user_id=$1 RETURNING *",[user_id]);
      res.status(200).json(user.rows[0]);
    }  
    else
    {
      const user=await pool.query("UPDATE USERS set assigned=1 WHERE user_id=$1 RETURNING *",[user_id]);
      res.status(200).json(user.rows[0]);
    }    
  }
  catch(error){
    res.status(400).json({ error: error.message });
  }
}

const rejectUser = async (req,res) => {
  const user_id=req.params.user_id;
  try{
    const user=await pool.query("UPDATE USERS set assigned=2 WHERE user_id=$1 RETURNING *",[user_id]);
    res.status(200).json(user.rows[0]);
  }
  catch(error){
    res.status(400).json({ error: error.message });
  }
}

module.exports = {
  seePendingRegistrations,
  assignLocation,
  showUsers,
  getLabs,
  seePendingRegistrationsAll,
  acceptUser,
  rejectUser
};
