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
            const due=await pool.query("INSERT INTO dues(req_id,due_date,alloter_id,due_status,issue_date,quantity,damage_quantity) values($1,$2,$3,$4,CURRENT_DATE,$5,$6) RETURNING *",[reqID,dueDateObj,user_id.rows[0].user_id,duestatus.rows[0].due_status,requ.rows[0].quantity,0]);
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
        const dues=await pool.query(`SELECT d.due_id,d.due_date,d.issue_date,ds.status_name,e.equipment_name,l.location_name,d.quantity,d.clear_date,d.damage_quantity from dues d
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
        const dues=await pool.query(`SELECT d.due_id,d.due_date,d.issue_date,ds.status_name,e.equipment_name,u1.username,d.quantity,d.clear_date,d.damage_quantity from dues d
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

const clearDue = async (req,res) => {
    const username=req.params.username;
    const dueID=req.params.dueID;
    try{
        const due=await pool.query("SELECT * from dues where due_id=$1",[dueID]);
        const requ=await pool.query("SELECT * from requests where req_id=$1",[due.rows[0].req_id]);
        const user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
        const duestatus=await pool.query("SELECT * from due_statuses where status_name='Cleared'");
        const notif_type=await pool.query("SELECT * from notification_types where type_name='Dues'");
        const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",[requ.rows[0].user_id,username,'Lab Assistant','A due has been cleared',notif_type.rows[0].notification_type,dueID]);
        const clear=await pool.query("UPDATE dues SET due_status=$1,clear_date=CURRENT_DATE,receiver_id=$2 where due_id=$3 RETURNING *",[duestatus.rows[0].due_status,user_id.rows[0].user_id,dueID]);
        let equipmentID=requ.rows[0].equipment_id;
        let location_id=requ.rows[0].location_id;
        const quant=due.rows[0].quantity-due.rows[0].damage_quantity;
        equip = await pool.query(
            "SELECT * FROM equipments WHERE equipment_id = $1",
            [equipmentID]
          );
          //console.log(equip.rows[0].available, equip.rows[0].borrowed);
          await pool.query(
            "UPDATE equipments SET available = $1, borrowed = $2 WHERE equipment_id = $3",
            [
              equip.rows[0].available + quant,
              equip.rows[0].borrowed - quant,
              equipmentID,
            ]
          );
          equipm_in_locations = await pool.query(
            "SELECT * FROM equipments_in_locations WHERE equipment_id = $1 AND location_id = $2",
            [equipmentID, location_id]
          );
          await pool.query(
            "UPDATE equipments_in_locations SET available = $1, borrowed = $2 WHERE equipment_id = $3 AND location_id = $4",
            [
              equipm_in_locations.rows[0].available + quant,
              equipm_in_locations.rows[0].borrowed - quant,
              equipmentID,
              location_id,
            ]
          );

        res.status(200).json(clear.rows[0]);
    }
    catch(err){
        res.status(400).json({ error: err.message });
    }
};

const reportLostorDamaged = async (req,res) => {
    const username=req.params.username;
    const dueID=req.params.dueID;
    const quant=parseInt(req.body.quantity,10);
    const comment=req.body.comment;
    try{
        const due=await pool.query("SELECT * from dues where due_id=$1",[dueID]);
        const requ=await pool.query("SELECT * from requests where req_id=$1",[due.rows[0].req_id]);
        const user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
        const duestatus=await pool.query("SELECT * from due_statuses where status_name='LostOrDamaged'");
        const notif_type=await pool.query("SELECT * from notification_types where type_name='Dues'");
        const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",[due.rows[0].alloter_id,username,'Student',comment,notif_type.rows[0].notification_type,dueID]);
        const clear=await pool.query("UPDATE dues SET due_status=$1, damage_quantity=$2 where due_id=$3 RETURNING *",[duestatus.rows[0].due_status,due.rows[0].damage_quantity+quant,dueID]);
        res.status(200).json(clear.rows[0]);
    }
    catch(err){
        res.status(400).json({ error: err.message });
    }

};

const checkClearanceEligibility = async (req,res) => {
    const username=req.params.username;
    try{
        const duestatus=await pool.query("SELECT * from due_statuses where status_name='Pending'");
        let dues=await pool.query(`SELECT d.due_id from DUES d
        join requests r on d.req_id=r.req_id
        join users u on u.user_id=r.user_id
        where d.due_status=$1 and u.username=$2
        `,[duestatus.rows[0].due_status,username]);
        dues=dues.rows;
        let monetary_dues=await pool.query(`SELECT m.monetary_due_id from monetary_dues m
        join requests r on m.req_id=r.req_id
        join users u on u.user_id=r.user_id
        where m.due_status=$1 and u.username=$2
        `,[duestatus.rows[0].due_status,username]);
        monetary_dues=monetary_dues.rows;
        res.status(200).json({dues,monetary_dues})
    }
    catch(err){
        res.status(400).json({ error: err.message });
    }
};

const viewLostorDamaged = async(req,res)=>{
    const username=req.params.username;
    try{
        const dues=await pool.query(`SELECT d.due_id,d.due_date,d.issue_date,ds.status_name,e.equipment_name,u1.username,d.quantity,d.clear_date,d.damage_quantity from dues d
        join requests r on d.req_id=r.req_id
        join equipments e on r.equipment_id=e.equipment_id
        join users_in_locations ul on r.location_id=ul.location_id
        join due_statuses ds on d.due_status=ds.due_status
        join users u1 on r.user_id=u1.user_id
        join users u on ul.user_id=u.user_id
        where u.username=$1 and ds.status_name='LostOrDamaged'`,[username]);
        res.status(200).json(dues.rows);
    }catch(err){
        res.status(400).json({ error: err.message });
    }
};

const showEstimateDue = async (req,res) => {
    const username=req.params.username;
    const dueID=req.params.dueID;
    try{
        const due=await pool.query("SELECT * from dues where due_id=$1",[dueID]);
        const user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
        const equipment_cost=await pool.query(`SELECT e.cost*d.damage_quantity AS estimated_cost FROM equipments e
        JOIN requests r on e.equipment_id=r.equipment_id
        JOIN dues d on r.req_id=d.req_id
        WHERE r.req_id=$1`,[due.rows[0].req_id]);
        res.status(200).json(equipment_cost.rows[0]);
    }catch(err){
        res.status(400).json({ error: err.message });
    }
};

const createMonetaryDue = async (req,res) => {
    const username=req.params.username;
    const dueID=req.params.dueID;
    const dueDate=req.body.dueDate;
    const amount=parseInt(req.body.amount,10);
    try{
        const due=await pool.query("SELECT * from dues where due_id=$1",[dueID]);
        const dueExist=await pool.query("SELECT * from monetary_dues where req_id=$1",[due.rows[0].req_id]);

        if(!dueDate){
            return res.status(400).json({ error: "Due date is required" });
        }

        const dueDateArr=dueDate.split("-");
        const dueDateObj=new Date(dueDateArr[0],dueDateArr[1]-1,dueDateArr[2]);
        const currentDate=new Date();
        if(dueDateObj<currentDate){
            return res.status(400).json({ error: "Due date cannot be in the past" });
        }
        if(dueExist.rows.length==0){
            const requ=await pool.query("SELECT * from requests where req_id=$1",[due.rows[0].req_id]);
            const duestatus=await pool.query("SELECT * from due_statuses where status_name='Pending'");
            const monetary_due=await pool.query("INSERT INTO monetary_dues(req_id,user_id,creater_id,amount,due_status,issue_date,due_date) values($1,$2,$3,$4,$5,now(),$6) RETURNING *",[due.rows[0].req_id,requ.rows[0].user_id,due.rows[0].alloter_id,amount,duestatus.rows[0].due_status,dueDateObj]);
            const notif_status=await pool.query("SELECT * from notification_types where type_name='MonetaryDues'");
            const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",[requ.rows[0].user_id,username,'Lab Assistant','A monetary due has been created',notif_status.rows[0].notification_type,monetary_due.rows[0].monetary_due_id]);
            res.status(200).json(monetary_due.rows[0]);
        }
        else
        {
            const monetary_due=await pool.query("UPDATE monetary_dues SET amount=$1,due_date=$2 where req_id=$3 RETURNING *",[amount,dueDateObj,due.rows[0].req_id]);
            const notif_status=await pool.query("SELECT * from notification_types where type_name='MonetaryDues'");
            const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",[requ.rows[0].user_id,username,'Lab Assistant','A monetary due has been updated',notif_status.rows[0].notification_type,monetary_due.rows[0].monetary_due_id]);
            res.status(200).json(monetary_due.rows[0]);
        }
    }catch(err){
        res.status(400).json({ error: err.message });
    }
};

const viewMonetaryDueStudent = async (req,res) => {
    const username=req.params.username;
    try{
        const user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
        const monetary_dues=await pool.query(`SELECT m.monetary_due_id,m.issue_date,m.due_date,m.amount,ds.status_name,l.location_name,u.username from monetary_dues m
        join requests r on m.req_id=r.req_id
        join equipments e on r.equipment_id=e.equipment_id
        join locations l on r.location_id=l.location_id
        join users u on m.creater_id=u.user_id
        join due_statuses ds on m.due_status=ds.due_status
        where r.user_id=$1`,[user_id.rows[0].user_id]);
        res.status(200).json(monetary_dues.rows);
    }catch(err){
        res.status(400).json({error: err.message});
    }
};

const MonetaryDuesLocation = async (req,res) => {
    const username=req.params.username;
    try{
        const dues=await pool.query(`SELECT m.monetary_due_id,m.due_date,m.issue_date,ds.status_name,e.equipment_name,u1.username,m.amount,m.clear_date from monetary_dues m
        join requests r on m.req_id=r.req_id
        join equipments e on r.equipment_id=e.equipment_id
        join users_in_locations ul on r.location_id=ul.location_id
        join due_statuses ds on m.due_status=ds.due_status
        join users u1 on r.user_id=u1.user_id
        join users u on ul.user_id=u.user_id
        where u.username=$1`,[username]);
        res.status(200).json(dues.rows);
    }catch(err){
        res.status(400).json({ error: err.message });
    }
};

const clearMonetaryDue = async (req,res) => {
    const username=req.params.username;
    const dueID=req.params.dueID;
    try{
        const due=await pool.query("SELECT * from monetary_dues where monetary_due_id=$1",[dueID]);
        const requ=await pool.query("SELECT * from requests where req_id=$1",[due.rows[0].req_id]);
        const user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
        const duestatus=await pool.query("SELECT * from due_statuses where status_name='Cleared'");
        const notif_type=await pool.query("SELECT * from notification_types where type_name='MonetaryDues'");
        const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",[requ.rows[0].user_id,username,'Lab Assistant','A monetary due has been cleared',notif_type.rows[0].notification_type,dueID]);
        const clear=await pool.query("UPDATE monetary_dues SET due_status=$1,clear_date=CURRENT_DATE,receiver_id=$2 where monetary_due_id=$3 RETURNING *",[duestatus.rows[0].due_status,user_id.rows[0].user_id,dueID]);
        res.status(200).json(clear.rows[0]);
    }
    catch(err){
        res.status(400).json({ error: err.message });
    }
};

const createClearanceRequest = async (req,res) => {
    const username=req.params.username;
    const level=parseInt(req.body.level,10);
    const term=parseInt(req.body.term,10);
    const user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
    const superadmin=await pool.query("SELECT * from users where role='Super Admin'");
    //console.log(superadmin.rows[0])
    const clearance_status=await pool.query("SELECT * from clearance_request_status where status_name='Waiting for Superadmin Approval'")
    try{
    const clearance=await pool.query("INSERT INTO clearance_request(user_id,level,term,request_date,clearance_status) values($1,$2,$3,CURRENT_DATE,$4) RETURNING *",[user_id.rows[0].user_id,level,term,clearance_status.rows[0].clearance_status]);
    const notif_type=await pool.query("SELECT * from notification_types where type_name='Clearance'");
    //console.log(notif_type);
    const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",[superadmin.rows[0].user_id,username,'Student','A clearance request has been sent',notif_type.rows[0].notification_type,clearance.rows[0].clearance_req_id]);
    res.status(200).json(clearance.rows[0]);
    }catch(error)
    {
        res.status(400).json({ error: error.message });
    
    }
};

const checkClearanceExistence = async (req,res) => {
    const username=req.params.username;
    try{
        const user_id=await pool.query("SELECT user_id FROM users WHERE username=$1",[username]);
        const clearances=await pool.query("SELECT * from clearance_request where user_id=$1",[user_id.rows[0].user_id]);
        res.status(200).json(clearances.rows);
    }catch(err){
        res.status(400).json({ error: err.message });
    }
}

const checkClearanceRequests = async (req,res)=>{
    try{
        const clearances=await pool.query("SELECT c.clearance_req_id,u.username,c.level,c.term,c.request_date,cr.status_name from clearance_request c join users u on c.user_id=u.user_id join clearance_request_status cr on c.clearance_status=cr.clearance_status");
        res.status(200).json(clearances.rows);
    }
    catch(err){
        res.status(400).json({ error: err.message });
    }
}

module.exports={createDue,
    viewDuesStudent,
    viewDuesLocation,
    clearDue,
    checkClearanceEligibility,
    reportLostorDamaged,
    viewLostorDamaged,
    createClearanceRequest,
    checkClearanceExistence,
    checkClearanceRequests,
    showEstimateDue,
    createMonetaryDue,
    clearMonetaryDue,
    viewMonetaryDueStudent,
    MonetaryDuesLocation
}