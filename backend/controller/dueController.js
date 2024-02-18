const pool = require("../db");

const validator = require("validator");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const createDue = async (req, res) => {
    const username=req.params.username;
    const reqID=req.params.reqID;
    const dueDate=req.body.dueDate;

    if(!dueDate){
        return res.status(400).json({ error: "Due date is required" });
    }

    const dueDateArr=dueDate.split("-");
    const dueDateObj=new Date(dueDateArr[0],dueDateArr[1]-1,dueDateArr[2]);
    const currentDate=new Date();
    if(dueDateObj<currentDate){
        return res.status(400).json({ error: "Due date cannot be in the past" });
    }
    try{
        const user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
        const duestatus=await pool.query("SELECT * from due_statuses where status_name='Pending'");
        // let quantity=request.rows[0].quantity;
        // let equipment_id=request.rows[0].equipment_id;
        // let location_id=request.rows[0].location_id;
        const due=await pool.query("INSERT INTO dues(req_id,due_date,alloter_id,due_status) values($1,$2,$3,$4) RETURNING *",[reqID,dueDateObj,user_id.rows[0].user_id,duestatus.rows[0].due_status]);
        res.status(200).json(due.rows[0]);
    }catch(err){
        res.status(400).json({ error: err.message });
    }

};

module.exports={createDue}