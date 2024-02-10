const pool = require("../db");

const seePendingRegistrations = async (req, res) => {
    try {
        const pendingRegistrations = await pool.query(
            "SELECT user_id,first_name,last_name,role FROM users WHERE assigned=0 AND (role='Lab assistant' OR role='Teacher');"
        );
        res.status(200).json(pendingRegistrations.rows);
    } catch (error) {
        res.status(400).json({error:error.message});
    }
};

const showUsers = async (req, res) => {
    try {
        const users = await pool.query(
            "SELECT * FROM users"
        );
        res.status(200).json(users.rows);
    } catch (err) {
        res.status(400).json({error:error.message});
    }
}

const assignLocation = async (req, res) => {
    const user_id=req.params.user_id;
    const location_id=req.body.location_id;
    try {
        let role=await pool.query(
            "SELECT role,assigned FROM users WHERE user_id=$1",
            [user_id]
        );
        let assigned=role.rows[0].assigned;
        role=role.rows[0].role;
        const assign = await pool.query(
            "UPDATE users SET assigned=1 WHERE user_id=$1 RETURNING *",
            [user_id]
        );
        if(assigned==0)
        {
            const assignloc=await pool.query(
                "INSERT INTO users_in_locations (user_id,location_id,role) VALUES ($1,$2,$3) RETURNING *",
                [user_id,location_id,role]
            );
            res.status(200).json(assignloc.rows[0]);
        }
        else
        {
            const assignloc=await pool.query(
                "UPDATE users_in_locations SET location_id=$1 WHERE user_id=$2 RETURNING *",
                [location_id,user_id]
            )
            res.status(200).json(assignloc.rows[0]);
        }
    } catch (error) {
        res.status(400).json({error:error.message});
    }
};

module.exports = {seePendingRegistrations,assignLocation,showUsers};