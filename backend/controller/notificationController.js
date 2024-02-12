const pool = require("../db");

const showNotifications = async (req,res) => {
  user_id=req.params.user_id;
  try {
    const notifications = await pool.query("SELECT * FROM notifications where receiver_id=$1",[user_id]);
    res.status(200).json(notifications.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

module.exports={showNotifications};