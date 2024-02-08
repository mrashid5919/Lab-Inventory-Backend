const pool = require("../db");

const validator = require("validator");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const createRequest = async (req, res) => {
    const username=req.params.username;
    const equipmentID=req.params.equipmentID;
    const {quantity, location}=req.body;
    if(!quantity || !location){
        return res.status(400).json({error:"All fields are required"});
    }
    const locationID=parseInt(location,10);
    const quant=parseInt(quantity,10);
    let equip_in_locations=await pool.query("SELECT available FROM equipments_in_locations WHERE equipment_id=$1 AND location_id=$2",[equipmentID,locationID]);
    equip_in_locations=parseInt(equip_in_locations.rows[0].available,10);
    if(quant>equip_in_locations){
        return res.status(400).json({error:"Requested quantity is not available in this location"});
    }
    let userID=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
    userID=userID.rows[0].user_id;
    let req_status=await pool.query("SELECT req_status FROM request_status WHERE status_name='Waiting for Lab Assistant approval'");
    req_status=req_status.rows[0].req_status;
    try {
        const request = await pool.query(
            "INSERT INTO requests (user_id, equipment_id, quantity, location_id, req_status, req_time) VALUES ($1, $2, $3, $4, $5, CURRENT_DATE) RETURNING *",
            [userID, equipmentID, quant, locationID, req_status]
        );
        res.status(200).json(request.rows[0]);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const showRequestsLabAssistant = async (req, res) => {
    const username=req.params.username;
    try {
        locationID=await pool.query(`SELECT ul.location_id
        FROM users_in_locations ul
        JOIN users u
        ON ul.user_id=u.user_id
        WHERE u.username=$1;`,[username]);
        locationID=locationID.rows[0].location_id;

        requests=await pool.query(`SELECT e.equipment_name,e.permit,el.available,r.req_id,u.username,r.quantity,rs.status_name,r.req_time
        FROM requests r
        JOIN request_status rs
        ON r.req_status=rs.req_status
        JOIN equipments e
        ON r.equipment_id=e.equipment_id
        JOIN equipments_in_locations el
        ON r.location_id=el.location_id
        JOIN users u
        ON r.user_id=u.user_id
        WHERE r.location_id=$1;
        `, [locationID]);
        res.status(200).json(requests.rows);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
}

const acceptRequest = async (req, res) => {
    const reqID=req.params.reqID;
    const username=req.params.username;
    let userID=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
    userID=userID.rows[0].user_id;
    let req_status=await pool.query("SELECT req_status FROM request_status WHERE status_name='Accepted'");
    req_status=req_status.rows[0].req_status;
    try {
        const request = await pool.query(
            "UPDATE requests SET req_status=$1, verdictor=$2 WHERE req_id=$3 RETURNING *",
            [req_status,userID,reqID]
        );
        res.status(200).json(request.rows[0]);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const declineRequest = async (req, res) => {
    const reqID=req.params.reqID;
    const username=req.params.username;
    let userID=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
    userID=userID.rows[0].user_id;
    let req_status=await pool.query("SELECT req_status FROM request_status WHERE status_name='Rejected'");
    req_status=req_status.rows[0].req_status;
    try {
        const request = await pool.query(
            "UPDATE requests SET req_status=$1, verdictor=$2 WHERE req_id=$3 RETURNING *",
            [req_status,userID,reqID]
        );

        res.status(200).json(request.rows[0]);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const addComment = async (req, res) => {
    const reqID=req.params.reqID;
    const username=req.params.username;
    const comment=req.body.comment;
    let userID=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
    userID=userID.rows[0].user_id;
    try {
        const request = await pool.query(
            "INSERT INTO request_comments (req_id, commenter_id, comment, comment_time) VALUES ($1, $2, $3, CURRENT_DATE) RETURNING *",
            [reqID, userID, comment]
        );

        res.status(200).json(request.rows[0]);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const deleteRequest = async (req, res) => {
    const reqID=req.params.reqID;
    try {
        const request = await pool.query(
            "DELETE FROM requests WHERE req_id=$1 RETURNING *",
            [reqID]
        );

        res.status(200).json(request.rows[0]);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const forwardRequesttoSupervisor = async (req, res) => {
    const reqID=req.params.reqID;
    const username=req.params.username;
    let userID=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
    userID=userID.rows[0].user_id;
    let req_status=await pool.query("SELECT req_status FROM request_status WHERE status_name='Waiting for Supervisor approval'");
    req_status=req_status.rows[0].req_status;
    try {
        const request = await pool.query(
            "UPDATE requests SET req_status=$1, lab_assistant=$2 WHERE req_id=$3 RETURNING *",
            [req_status,userID,reqID]
        );

        res.status(200).json(request.rows[0]);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

module.exports={createRequest,showRequestsLabAssistant,acceptRequest,declineRequest,addComment,deleteRequest,forwardRequesttoSupervisor}