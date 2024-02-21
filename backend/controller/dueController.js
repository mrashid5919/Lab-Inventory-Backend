const pool = require("../db");

const validator = require("validator");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const createDue = async (req, res) => {
    const username=req.params.username;
    const reqID=req.params.reqID;
    const dueDate=req.body.dueDate;



    const dueExist=await pool.query("SELECT * from dues where req_id=$1",[reqID]);

    if(!dueDate){
        return res.status(400).json({ error: "Due date is required" });
    }

    const dueDateArr=dueDate.split("-");
    const dueDateObj=new Date(dueDateArr[0],dueDateArr[1]-1,dueDateArr[2]);
    const currentDate=new Date();
    if(dueDateObj<currentDate){
        return res.status(400).json({ error: "Due date cannot be in the past" });
    }
    const user_role=await pool.query("SELECT role FROM users WHERE username=$1",[username]);
    const requ=await pool.query("SELECT * from requests where req_id=$1",[reqID]);
    const notif_type=await pool.query("SELECT * from notification_types where type_name='Dues'");
    try{
        if(dueExist.rows.length==0){
            const user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
            const duestatus=await pool.query("SELECT * from due_statuses where status_name='Pending'");
            // let quantity=request.rows[0].quantity;
            // let equipment_id=request.rows[0].equipment_id;
            // let location_id=request.rows[0].location_id;
            const due=await pool.query("INSERT INTO dues(req_id,due_date,alloter_id,due_status,issue_date) values($1,$2,$3,$4,CURRENT_DATE) RETURNING *",[reqID,dueDateObj,user_id.rows[0].user_id,duestatus.rows[0].due_status]);
            //const d=await pool.query("SELECT due_id from dues where req_id=$1",[reqID]);
            //console.log(due.rows[0]);
            const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",[requ.rows[0].user_id,username,user_role.rows[0].role,'A due has been updated',notif_type.rows[0].notification_type,due.rows[0].due_id]);
            
            res.status(200).json(due.rows[0]);
        }
        else
        {
            const due=await pool.query("UPDATE dues SET due_date=$1 where req_id=$2 RETURNING *",[dueDateObj,reqID]);
            //const d=await pool.query("SELECT due_id from dues where req_id=$1",[reqID]);
            //console.log(due.rows[0]);
            const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",[requ.rows[0].user_id,username,user_role.rows[0].role,'A due has been updated',notif_type.rows[0].notification_type,due.rows[0].due_id]);
            //console.log(due.rows[0]);
            res.status(200).json(due.rows[0]);
        }
        
    }catch(err){
        res.status(400).json({ error: err.message });
    }

};

const viewDuesStudent = async (req, res) => {
    const username=req.params.username;
    try{
        const user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
        const dues=await pool.query(`SELECT d.due_id,d.due_date,d.issue_date,ds.status_name,e.equipment_name,l.location_name,r.quantity from dues d
        join requests r on d.req_id=r.req_id
        join equipments e on r.equipment_id=e.equipment_id
        join locations l on r.location_id=l.location_id
        join due_statuses ds on d.due_status=ds.due_status
        where r.user_id=$1`,[user_id.rows[0].user_id]);
        res.status(200).json(dues.rows);
    }catch(err){
        res.status(400).json({ error: err.message });
    }
};

const viewDuesLocation = async (req, res) => {
    const username=req.params.username;
    try{
        const dues=await pool.query(`SELECT d.due_id,d.due_date,d.issue_date,ds.status_name,e.equipment_name,u1.username,r.quantity from dues d
        join requests r on d.req_id=r.req_id
        join equipments e on r.equipment_id=e.equipment_id
        join users_in_locations ul on r.location_id=ul.location_id
        join due_statuses ds on d.due_status=ds.due_status
        join users u1 on r.user_id=u1.user_id
        join users u on ul.user_id=u.user_id
        where u.username=$1`,[username]);
        res.status(200).json(dues.rows);
    }catch(err){
        res.status(400).json({ error: err.message });
    }
};

module.exports={createDue,
    viewDuesStudent,
    viewDuesLocation}