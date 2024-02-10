const pool = require("../db");

const seePendingRegistrations = async (req, res) => {
    try {
        const pendingRegistrations = await pool.query(
            "SELECT user_id,first_name,last_name,role FROM users WHERE assigned=0 AND (role='Lab assistant' OR role='Teacher');"
        );
        res.json(pendingRegistrations.rows);
    } catch (err) {
        console.error(err.message);
    }
};

module.exports = {seePendingRegistrations};