const pool = require("../db");

const showNotifications = async (req,res) => {
  username=req.params.username;
  user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
  try {
    const notifications = await pool.query("SELECT * FROM notifications where receiver_id=$1",[user_id.rows[0].user_id]);
    res.status(200).json(notifications.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

const selectIndividualNotification = async (req,res) => {
  notification_id=req.params.notification_id;
  try {
    const notification = await pool.query("SELECT * FROM notifications where notification_id=$1",[notification_id]);
    const notif_type=await pool.query("SELECT * FROM notification_types where notification_type=$1",[notification.rows[0].notification_type]);
    res.status(200).json(notification.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
}

module.exports={showNotifications,selectIndividualNotification};