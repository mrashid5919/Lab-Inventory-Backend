const pool = require("../db");

const updateStorage=async (req,res)=>{
    if(!req.body.name || !req.body.quantity){
        return res.status(400).json({error:"All fields are required"});
    }
    const equipmentName=req.body.name;
    const equipmentIDquery = await pool.query(
        "SELECT equipment_id FROM equipments WHERE equipment_name = $1",
        [equipmentName]
      );

      if (equipmentIDquery.rows.length == 0) {
        throw Error("Wrong equipment name");
      }
      const equipmentID=equipmentIDquery.rows[0].equipment_id;

    const username=req.body.username;
    const location_IDquery=await pool.query(
        "SELECT location_id FROM users_in_locations WHERE user_id = (SELECT user_id FROM users WHERE username = $1)",
        [username]
      );

    if (location_IDquery.rows.length == 0) {
        throw Error("Wrong username");
    }
    const location_ID=location_IDquery.rows[0].location_id;
    const quantity=req.body.quantity;
    try{  
      await pool.query("SELECT update_storage($1,$2,$3)",[equipmentID,location_ID,quantity]);
      res.status(200).json({msg:"Update successfully"});
    }catch(error){
      res.status(400).json({error:error.message});
    }
  };

  module.exports={updateStorage};