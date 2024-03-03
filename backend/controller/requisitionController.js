const pool = require("../db");

const createRequisition = async (req, res) => {
    const username=req.params.username;
    const {equipment_name,quantity}=req.body;
    try {
        const user=await pool.query("SELECT * FROM users WHERE username=$1",[username]);
        //console.log("here");
        const location_id=await pool.query(`SELECT location_id FROM users_in_locations WHERE user_id=$1`,[user.rows[0].user_id]);
        const requis_status=await pool.query("SELECT * FROM requisition_statuses WHERE status_name='Pending'");
        const notif_type=await pool.query("SELECT * FROM notification_types WHERE type_name='Requisition'");
        //console.log(requis_status.rows[0]);
        const newRequisition = await pool.query(
            "INSERT INTO requisitions (equipment_name,location_id,quantity,req_date,user_id,req_status) VALUES ($1,$2,$3,CURRENT_DATE,$4,$5) RETURNING *",
            [equipment_name,location_id.rows[0].location_id,parseInt(quantity,10),user.rows[0].user_id,requis_status.rows[0].req_status]
        );
        const inventory_manager=await pool.query("SELECT user_id from users where role='Inventory Manager'");
        for(let i=0;i<inventory_manager.rows.length;i++){
            const notification=await pool.query(
                "INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",
            [
                inventory_manager.rows[i].user_id,
                username,
                "Lab Assistant",
                "A new requisition has been made",
                notif_type.rows[0].notification_type,
                newRequisition.rows[0].req_id,
            ]
            );
        }
        res.status(200).json(newRequisition.rows[0]);
    } catch (error) {
        res.status(400).json({ error: error.message });
    }
};

const viewRequisitionsLabAssistant = async (req, res) => {
    const username=req.params.username;
    try{
        const user=await pool.query("SELECT * FROM users WHERE username=$1",[username]);
        const requisitions=await pool.query(`SELECT r.requisition_id,r.equipment_name,r.quantity,r.verdictor,r.req_date,rs.status_name FROM requisitions r
        JOIN requisition_statuses rs ON r.req_status=rs.req_status
        WHERE r.user_id=$1`,[user.rows[0].user_id]);
        res.status(200).json(requisitions.rows);
    }
    catch(error){
        res.status(400).json({error:error.message});
    }
};

const viewRequisitionsInventoryManager = async (req, res) => {
    const username=req.params.username;
    try{
        const user=await pool.query("SELECT * FROM users WHERE username=$1",[username]);
        const requ_status=await pool.query("SELECT * FROM requisition_statuses WHERE status_name='Pending'");
        const requisitions=await pool.query(`SELECT r.requisition_id,r.equipment_name,r.quantity,r.verdictor,r.req_date,rs.status_name,u.username,l.location_name FROM requisitions r
        JOIN requisition_statuses rs ON r.req_status=rs.req_status
        JOIN users u ON r.user_id=u.user_id
        JOIN locations l ON r.location_id=l.location_id
        WHERE r.req_status=$1 OR r.verdictor=$2`,[requ_status.rows[0].req_status,user.rows[0].user_id]);
        res.status(200).json(requisitions.rows);
    }catch(error){
        res.status(400).json({error:error.message});
    }
};

const approveRequisition = async (req, res) => {
    const username=req.params.username;
    const requisition_id=req.params.requisition_id;
    try{
        const user=await pool.query("SELECT * FROM users WHERE username=$1",[username]);
        const requis_status=await pool.query("SELECT * FROM requisition_statuses WHERE status_name='Collect from Inventory'");
        const notif_type=await pool.query("SELECT * FROM notification_types WHERE type_name='Requisition'");
        const requisition=await pool.query("UPDATE requisitions SET req_status=$1,verdictor=$2,approve_date=CURRENT_DATE WHERE requisition_id=$3 RETURNING *",[requis_status.rows[0].req_status,user.rows[0].user_id,requisition_id]);
        
        const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",
        [
            requisition.rows[0].user_id,
            username,
            "Inventory Manager",
            "Your requisition has been approved",
            notif_type.rows[0].notification_type,
            requisition.rows[0].requisition_id,
        ]);
        res.status(200).json(requisition.rows[0]);
    }catch(error){
        res.status(400).json({error:error.message});
    }
};

const rejectRequisition = async (req, res) => {
    const username=req.params.username;
    const requisition_id=req.params.requisition_id;
    try{
        const user=await pool.query("SELECT * FROM users WHERE username=$1",[username]);
        const requis_status=await pool.query("SELECT * FROM requisition_statuses WHERE status_name='Rejected'");
        const notif_type=await pool.query("SELECT * FROM notification_types WHERE type_name='Requisition'");
        const requisition=await pool.query("UPDATE requisitions SET req_status=$1,verdictor=$2,verdict_date=CURRENT_DATE WHERE requisition_id=$3 RETURNING *",[requis_status.rows[0].req_status,user.rows[0].user_id,requisition_id]);
        
        const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",
        [
            requisition.rows[0].user_id,
            username,
            "Inventory Manager",
            "Your requisition has been rejected",
            notif_type.rows[0].notification_type,
            requisition.rows[0].requisition_id,
        ]);
        res.status(200).json(requisition.rows[0]);
    }catch(error){
        res.status(400).json({error:error.message});
    }
};

const fulfilRequisition = async (req, res) => {
    const username=req.params.username;
    const requisition_id=req.params.requisition_id;
    const quantity=parseInt(req.body.quantity,10);
    try{
        const user=await pool.query("SELECT * FROM users WHERE username=$1",[username]);
        const sel_requisition=await pool.query("SELECT * FROM requisitions WHERE requisition_id=$1",[requisition_id]);
        const requis_status=await pool.query("SELECT * FROM requisition_statuses WHERE status_name='Fulfilled'");
        const notif_type=await pool.query("SELECT * FROM notification_types WHERE type_name='Requisition'");
        const user_location=await pool.query("SELECT location_id FROM users_in_locations WHERE user_id=$1",[user.rows[0].user_id]);
        const equipment=await pool.query("SELECT * FROM equipments where equipment_name=$1",[sel_requisition.rows[0].equipment_name]);
        const requisition=await pool.query("UPDATE requisitions SET req_status=$1,verdictor=$2,quantity=$3,verdict_date=CURRENT_DATE WHERE requisition_id=$4 RETURNING *",[requis_status.rows[0].req_status,user.rows[0].user_id,quantity,requisition_id]);
        const equip_in_inventory=await pool.query("UPDATE equipments_in_locations SET available=available-$1 WHERE equipment_id=$2 AND location_id=$3",[quantity,equipment.rows[0].equipment_id,user_location.rows[0].location_id]);
        const check_lab=await pool.query("SELECT * FROM equipments_in_locations WHERE equipment_id=$1 AND location_id=$2",[equipment.rows[0].equipment_id,sel_requisition.rows[0].location_id]);
        if(check_lab.rows.length==0){
            const equip_in_lab=await pool.query("INSERT INTO equipments_in_locations(equipment_id,location_id,available,borrowed) VALUES ($1,$2,$3,$4)",[equipment.rows[0].equipment_id,sel_requisition.rows[0].location_id,quantity,0]);
        }
        else{
            const equip_in_lab=await pool.query("UPDATE equipments_in_locations SET available=available+$1 WHERE equipment_id=$2 AND location_id=$3",[quantity,equipment.rows[0].equipment_id,sel_requisition.rows[0].location_id]);
        }
        //const equip_in_lab=await pool.query("UPDATE equipments_in_locations SET available=available+$1 WHERE equipment_id=$2 AND location_id=$3",[quantity,equipment.rows[0].equipment_id,sel_requisition.rows[0].location_id]);
        if(sel_requisition.rows[0].quantity>quantity){
            const requis_status_2=await pool.query("SELECT * FROM requisition_statuses WHERE status_name='Pending'");
            const newRequisition = await pool.query(
                "INSERT INTO requisitions (equipment_name,location_id,quantity,req_date,user_id,req_status) VALUES ($1,$2,$3,CURRENT_DATE,$4,$5) RETURNING *",
                [sel_requisition.rows[0].equipment_name,sel_requisition.rows[0].location_id,sel_requisition.rows[0].quantity-quantity,sel_requisition.rows[0].user_id,requis_status_2.rows[0].req_status]
            );
            const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",
            [
                requisition.rows[0].user_id,
                username,
                "Inventory Manager",
                "Your requisition has been partially fulfilled and a new requisition has been made",
                notif_type.rows[0].notification_type,
                requisition.rows[0].requisition_id,
            ]);
            res.status(200).json(requisition.rows[0]);
        }
        else
        {
            const notification=await pool.query("INSERT INTO notifications(receiver_id,sender_name,sender_role,notification,notification_time,notification_type,type_id) VALUES ($1,$2,$3,$4,now(),$5,$6) RETURNING *",
            [
                requisition.rows[0].user_id,
                username,
                "Inventory Manager",
                "Your requisition has been fulfilled",
                notif_type.rows[0].notification_type,
                requisition.rows[0].requisition_id,
            ]);
            res.status(200).json(requisition.rows[0]);
        }
    }
    catch(error){
        res.status(400).json({error:error.message});
    }
};

module.exports={createRequisition,
    viewRequisitionsLabAssistant,
    viewRequisitionsInventoryManager,
    approveRequisition,
    rejectRequisition,
    fulfilRequisition};