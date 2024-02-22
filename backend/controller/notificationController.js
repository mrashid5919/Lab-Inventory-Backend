const pool = require("../db");

const showNotifications = async (req,res) => {
  username=req.params.username;
  user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
  try {
    const notifications = await pool.query("SELECT * FROM notifications where receiver_id=$1",[user_id.rows[0].user_id]);
    const update_count=await pool.query("UPDATE viewed_notification SET viewed_notification_count=total_notification_count WHERE user_id=$1",[user_id.rows[0].user_id]);
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

const getUnseenNotificationCount = async (req,res) => {
  username=req.params.username;
  user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
  try{
    const count=await pool.query("SELECT total_notification_count-viewed_notification_count AS unseen_notification_count FROM viewed_notification WHERE user_id=$1",[user_id.rows[0].user_id]);
    res.status(200).json(count.rows[0]);
  }
  catch(error){
    res.status(400).json({ error: error.message });
  }
};

module.exports={showNotifications,selectIndividualNotification,getUnseenNotificationCount};