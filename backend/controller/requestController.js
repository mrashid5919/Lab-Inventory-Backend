const pool = require("../db");

const validator = require("validator");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");

const createRequest = async (req, res) => {
  const username = req.params.username;
  const equipmentID = req.params.equipmentID;
  const { quantity, location } = req.body;
  if (!quantity || !location) {
    return res.status(400).json({ error: "All fields are required" });
  }
  const locationID = parseInt(location, 10);
  const quant = parseInt(quantity, 10);
  let equip_in_locations = await pool.query(
    "SELECT available FROM equipments_in_locations WHERE equipment_id=$1 AND location_id=$2",
    [equipmentID, locationID]
  );
  equip_in_locations = parseInt(equip_in_locations.rows[0].available, 10);
  if (quant > equip_in_locations) {
    return res
      .status(400)
      .json({ error: "Requested quantity is not available in this location" });
  }
  let userID = await pool.query("SELECT user_id FROM users WHERE username=$1", [
    username,
  ]);
  userID = userID.rows[0].user_id;
  let req_status = await pool.query(
    "SELECT req_status FROM request_status WHERE status_name='Waiting for Lab Assistant approval'"
  );
  req_status = req_status.rows[0].req_status;
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
  const username = req.params.username;
  try {
    locationID = await pool.query(
      `SELECT ul.location_id
        FROM users_in_locations ul
        JOIN users u
        ON ul.user_id=u.user_id
        WHERE u.username=$1;`,
      [username]
    );
    locationID = locationID.rows[0].location_id;

    requests = await pool.query(
      `SELECT e.equipment_name, e.permit, el.available, r.req_id, u.username, r.quantity, rs.status_name, r.req_time
        FROM requests r
        JOIN request_status rs ON r.req_status = rs.req_status
        JOIN equipments e ON r.equipment_id = e.equipment_id
        JOIN equipments_in_locations el ON r.location_id = el.location_id AND r.equipment_id = el.equipment_id
        JOIN users u ON r.user_id = u.user_id
        WHERE r.location_id = $1;
        `,
      [locationID]
    );
    res.status(200).json(requests.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const showRequestsSupervisor = async (req, res) => {
  const username = req.params.username;

  try {
    // locationID=await pool.query(`SELECT ul.location_id
    // FROM users_in_locations ul
    // JOIN users u
    // ON ul.user_id=u.user_id
    // WHERE u.username=$1;`,[username]);
    // locationID=locationID.rows[0].location_id;
    let supervisor_id = await pool.query(
      "SELECT user_id FROM users WHERE username=$1",
      [username]
    );
    supervisor_id = supervisor_id.rows[0].user_id;
    //console.log(supervisor_id)

    requests = await pool.query(
      `SELECT e.equipment_name, e.permit, el.available, r.req_id, u.username, r.quantity, rs.status_name, r.req_time
        FROM requests r
        JOIN request_status rs ON r.req_status = rs.req_status
        JOIN equipments e ON r.equipment_id = e.equipment_id
        JOIN equipments_in_locations el ON r.location_id = el.location_id AND r.equipment_id = el.equipment_id
        JOIN users u ON r.user_id = u.user_id
        JOIN request_supervisors rsu ON r.req_id = rsu.req_id and rsu.supervisor_id=$1;
        `,
      [supervisor_id]
    );
    //console.log(requests.rows.length)
    res.status(200).json(requests.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const acceptRequest = async (req, res) => {
  //console.log("here");
  const reqID = req.params.reqID;
  const username = req.params.username;
  let userID = await pool.query(
    "SELECT user_id,role FROM users WHERE username=$1",
    [username]
  );
  let role = userID.rows[0].role;
  userID = userID.rows[0].user_id;

  let req_status = await pool.query(
    "SELECT req_status FROM request_status WHERE status_name='Accepted'"
  );
  req_status = req_status.rows[0].req_status;
  try {
    let request = await pool.query(
      "UPDATE requests SET req_status=$1, verdictor=$2 WHERE req_id=$3 RETURNING *",
      [req_status, userID, reqID]
    );
    //console.log(request.rows[0])
    //console.log(role);
    if (role == "Lab Assistant") {
      request = await pool.query(
        "UPDATE requests SET lab_assistant=$1 WHERE req_id=$2 RETURNING *",
        [userID, reqID]
      );
      //console.log(request.rows[0]);
      equip = await pool.query(
        "SELECT * FROM equipments WHERE equipment_id = $1",
        [request.rows[0].equipment_id]
      );
      //console.log(equip.rows[0].available, equip.rows[0].borrowed);
      await pool.query(
        "UPDATE equipments SET available = $1, borrowed = $2 WHERE equipment_id = $3",
        [
          equip.rows[0].available - request.rows[0].quantity,
          equip.rows[0].borrowed + request.rows[0].quantity,
          request.rows[0].equipment_id,
        ]
      );
      equipm_in_locations = await pool.query(
        "SELECT * FROM equipments_in_locations WHERE equipment_id = $1 AND location_id = $2",
        [request.rows[0].equipment_id, request.rows[0].location_id]
      );
      await pool.query(
        "UPDATE equipments_in_locations SET available = $1, borrowed = $2 WHERE equipment_id = $3 AND location_id = $4",
        [
          equipm_in_locations.rows[0].available - request.rows[0].quantity,
          equipm_in_locations.rows[0].borrowed + request.rows[0].quantity,
          request.rows[0].equipment_id,
          request.rows[0].location_id,
        ]
      );
    } else if (role == "Inventory Manager") {
      //console.log("here");
      request = await pool.query(
        "UPDATE requests SET inventory_manager=$1 WHERE req_id=$2",
        [userID, reqID]
      );
      // equip = await pool.query(
      //     "SELECT * FROM equipments WHERE equipment_id = $1",
      //     [request.rows[0].equipment_id]
      //   );
      //   //console.log(equip.rows[0].available, equip.rows[0].borrowed);
      //   await pool.query(
      //     "UPDATE equipments SET available = $1, borrowed = $2 WHERE equipment_id = $3",
      //     [equip.rows[0].available - request.rows[0].quantity, equip.rows[0].borrowed + request.rows[0].quantity, request.rows[0].equipment_id]
      //   );
      //console.log("here");
      request = await pool.query("SELECT * FROM requests WHERE req_id=$1", [
        reqID,
      ]);
      //console.log(request.rows[0]);
      equipm_in_locations = await pool.query(
        "SELECT * FROM equipments_in_locations WHERE equipment_id = $1 AND location_id = $2",
        [request.rows[0].equipment_id, request.rows[0].location_id]
      );
      await pool.query(
        "UPDATE equipments_in_locations SET available = $1 WHERE equipment_id = $2 AND location_id = $3",
        [
          equipm_in_locations.rows[0].available - request.rows[0].quantity,
          request.rows[0].equipment_id,
          request.rows[0].location_id,
        ]
      );
      //console.log("here");
      //console.log(request.rows[0].user_id);
      let lab_location = await pool.query(
        `SELECT ul.location_id
              FROM users_in_locations ul
              WHERE ul.user_id=$1;`,
        [request.rows[0].user_id]
      );
      //console.log(lab_location.rows[0]);
      lab_location = lab_location.rows[0].location_id;
      //console.log(lab_location);
      equipm_in_locations = await pool.query(
        "SELECT * FROM equipments_in_locations WHERE equipment_id = $1 AND location_id = $2",
        [request.rows[0].equipment_id, lab_location]
      );
      if (equipm_in_locations.rows[0] == undefined) {
        //console.log("here");
        await pool.query(
          "INSERT INTO equipments_in_locations (equipment_id, location_id, available) VALUES ($1, $2, $3)",
          [request.rows[0].equipment_id, lab_location, request.rows[0].quantity]
        );
      } else {
        await pool.query(
          "UPDATE equipments_in_locations SET available = $1 WHERE equipment_id = $2 AND location_id = $3",
          [
            equipm_in_locations.rows[0].available + request.rows[0].quantity,
            request.rows[0].equipment_id,
            lab_location,
          ]
        );
      }
    } else if (role == "Teacher") {
      await pool.query(
        "UPDATE requests SET lab_supervisor=$1 WHERE req_id=$2",
        [userID, reqID]
      );
    }
    res.status(200).json(request.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const declineRequest = async (req, res) => {
  const reqID = req.params.reqID;
  const username = req.params.username;
  let userID = await pool.query(
    "SELECT user_id,role FROM users WHERE username=$1",
    [username]
  );
  let role = userID.rows[0].role;
  userID = userID.rows[0].user_id;

  let req_status = await pool.query(
    "SELECT req_status FROM request_status WHERE status_name='Rejected'"
  );
  req_status = req_status.rows[0].req_status;
  try {
    let request = await pool.query(
      "UPDATE requests SET req_status=$1, verdictor=$2 WHERE req_id=$3 RETURNING *",
      [req_status, userID, reqID]
    );
    if (role != "Lab Assistant" && role != "Inventory Manager") {
      if (role == "Teacher") {
        request = await pool.query(
          "UPDATE requests SET lab_supervisor=$1 WHERE req_id=$2 RETURNING *",
          [userID, reqID]
        );
      }
      request = await pool.query("SELECT * FROM requests WHERE req_id=$1", [
        reqID,
      ]);
      equip = await pool.query(
        "SELECT * FROM equipments WHERE equipment_id = $1",
        [request.rows[0].equipment_id]
      );
      //console.log(equip.rows[0].available, equip.rows[0].borrowed);
      await pool.query(
        "UPDATE equipments SET available = $1, borrowed = $2 WHERE equipment_id = $3",
        [
          equip.rows[0].available + request.rows[0].quantity,
          equip.rows[0].borrowed - request.rows[0].quantity,
          request.rows[0].equipment_id,
        ]
      );
      equipm_in_locations = await pool.query(
        "SELECT * FROM equipments_in_locations WHERE equipment_id = $1 AND location_id = $2",
        [request.rows[0].equipment_id, request.rows[0].location_id]
      );
      await pool.query(
        "UPDATE equipments_in_locations SET available = $1, borrowed = $2 WHERE equipment_id = $3 AND location_id = $4",
        [
          equipm_in_locations.rows[0].available + request.rows[0].quantity,
          equipm_in_locations.rows[0].borrowed - request.rows[0].quantity,
          request.rows[0].equipment_id,
          request.rows[0].location_id,
        ]
      );
    } else if (role == "Lab Assistant") {
      await pool.query("UPDATE requests SET lab_assistant=$1 WHERE req_id=$2", [
        userID,
        reqID,
      ]);
    } else if (role == "Inventory Manager") {
      await pool.query(
        "UPDATE requests SET inventory_manager=$1 WHERE req_id=$2",
        [userID, reqID]
      );
    }
    res.status(200).json(request.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const addComment = async (req, res) => {
  const reqID = req.params.reqID;
  const username = req.params.username;
  const comment = req.body.comment;
  let userID = await pool.query("SELECT user_id FROM users WHERE username=$1", [
    username,
  ]);
  userID = userID.rows[0].user_id;
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
  const reqID = req.params.reqID;
  try {
    await pool.query("DELETE FROM request_supervisors WHERE req_id=$1", [
      reqID,
    ]);
    const request = await pool.query(
      "DELETE FROM requests WHERE req_id=$1 RETURNING *",
      [reqID]
    );

    res.status(200).json(request.rows[0]);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const getSupervisors = async (req, res) => {
  const username = req.params.username;
  try {
    locationID = await pool.query(
      `SELECT ul.location_id
        FROM users_in_locations ul
        JOIN users u
        ON ul.user_id=u.user_id
        WHERE u.username=$1;`,
      [username]
    );
    locationID = locationID.rows[0].location_id;

    supervisors = await pool.query(
      `SELECT u.user_id,u.username,u.first_name,u.last_name
        FROM users u
        JOIN users_in_locations ul
        ON ul.user_id=u.user_id
        WHERE ul.location_id=$1 AND ul.role='Teacher';
        `,
      [locationID]
    );
    res.status(200).json(supervisors.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const forwardRequesttoSupervisor = async (req, res) => {
  const reqID = req.params.reqID;
  const username = req.params.username;
  let quant = await pool.query(
    "SELECT quantity FROM requests WHERE req_id=$1",
    [reqID]
  );
  quant = quant.rows[0].quantity;
  quant = parseInt(quant, 10);
  let userID = await pool.query("SELECT user_id FROM users WHERE username=$1", [
    username,
  ]);
  userID = userID.rows[0].user_id;
  let reqstatus = await pool.query(
    "SELECT req_status FROM request_status WHERE status_name='Waiting for Supervisor approval'"
  );
  reqstatus = reqstatus.rows[0].req_status;
  //console.log(reqstatus);
  let equipmentID = await pool.query(
    "SELECT equipment_id FROM requests WHERE req_id=$1",
    [reqID]
  );
  equipmentID = equipmentID.rows[0].equipment_id;
  try {
    let request = await pool.query(
      "UPDATE requests SET req_status=$1, lab_assistant=$2 WHERE req_id=$3 RETURNING *",
      [reqstatus, userID, reqID]
    );
    //console.log(request.rows[0]);
    equip = await pool.query(
      "SELECT * FROM equipments WHERE equipment_id = $1",
      [equipmentID]
    );
    //console.log(equip.rows[0].available, equip.rows[0].borrowed);
    await pool.query(
      "UPDATE equipments SET available = $1, borrowed = $2 WHERE equipment_id = $3",
      [
        equip.rows[0].available - quant,
        equip.rows[0].borrowed + quant,
        equipmentID,
      ]
    );
    equipm_in_locations = await pool.query(
      "SELECT * FROM equipments_in_locations WHERE equipment_id = $1 AND location_id = $2",
      [equipmentID, request.rows[0].location_id]
    );
    await pool.query(
      "UPDATE equipments_in_locations SET available = $1, borrowed = $2 WHERE equipment_id = $3 AND location_id = $4",
      [
        equipm_in_locations.rows[0].available - quant,
        equipm_in_locations.rows[0].borrowed + quant,
        equipmentID,
        request.rows[0].location_id,
      ]
    );
    locationID = await pool.query(
      `SELECT ul.location_id
          FROM users_in_locations ul
          JOIN users u
          ON ul.user_id=u.user_id
          WHERE u.username=$1;`,
      [username]
    );
    locationID = locationID.rows[0].location_id;

    request = await pool.query(
      `SELECT e.equipment_name, e.permit, el.available, r.req_id, u.username, r.quantity, rs.status_name, r.req_time
          FROM requests r
          JOIN request_status rs ON r.req_status = rs.req_status
          JOIN equipments e ON r.equipment_id = e.equipment_id
          JOIN equipments_in_locations el ON r.location_id = el.location_id AND r.equipment_id = el.equipment_id
          JOIN users u ON r.user_id = u.user_id
          WHERE r.location_id = $1;
          `,
      [locationID]
    );
    res.status(200).json(request.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const cancelForwardRequesttoSupervisor = async (req, res) => {
  const reqID = req.params.reqID;
  const username = req.params.username;
  let quant = await pool.query(
    "SELECT quantity FROM requests WHERE req_id=$1",
    [reqID]
  );
  quant = quant.rows[0].quantity;
  quant = parseInt(quant, 10);
  let userID = await pool.query("SELECT user_id FROM users WHERE username=$1", [
    username,
  ]);
  userID = userID.rows[0].user_id;
  let reqstatus = await pool.query(
    "SELECT req_status FROM request_status WHERE status_name='Waiting for Lab Assistant approval'"
  );
  reqstatus = reqstatus.rows[0].req_status;
  //console.log(reqstatus);
  let equipmentID = await pool.query(
    "SELECT equipment_id FROM requests WHERE req_id=$1",
    [reqID]
  );
  equipmentID = equipmentID.rows[0].equipment_id;
  try {
    let request = await pool.query(
      "UPDATE requests SET req_status=$1, lab_assistant=$2 WHERE req_id=$3 RETURNING *",
      [reqstatus, null, reqID]
    );
    //console.log(request.rows[0]);
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
      [equipmentID, request.rows[0].location_id]
    );
    await pool.query(
      "UPDATE equipments_in_locations SET available = $1, borrowed = $2 WHERE equipment_id = $3 AND location_id = $4",
      [
        equipm_in_locations.rows[0].available + quant,
        equipm_in_locations.rows[0].borrowed - quant,
        equipmentID,
        request.rows[0].location_id,
      ]
    );
    locationID = await pool.query(
      `SELECT ul.location_id
          FROM users_in_locations ul
          JOIN users u
          ON ul.user_id=u.user_id
          WHERE u.username=$1;`,
      [username]
    );
    locationID = locationID.rows[0].location_id;

    request = await pool.query(
      `SELECT e.equipment_name, e.permit, el.available, r.req_id, u.username, r.quantity, rs.status_name, r.req_time
          FROM requests r
          JOIN request_status rs ON r.req_status = rs.req_status
          JOIN equipments e ON r.equipment_id = e.equipment_id
          JOIN equipments_in_locations el ON r.location_id = el.location_id AND r.equipment_id = el.equipment_id
          JOIN users u ON r.user_id = u.user_id
          WHERE r.location_id = $1;
          `,
      [locationID]
    );
    res.status(200).json(request.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const selectSupervisors = async (req, res) => {
  const reqID = req.params.reqID;
  const supervisors = req.body.supervisors;
  const username = req.params.username;
  //console.log(supervisors);
  try {
    for (i = 0; i < supervisors.length; i++) {
      userID = supervisors[i];
      await pool.query(
        "INSERT INTO request_supervisors (req_id, supervisor_id) VALUES ($1, $2)",
        [reqID, userID]
      );
      //console.log("here");
    }
    if (supervisors == null) {
      const reqID = req.params.reqID;
      const username = req.params.username;
      let quant = await pool.query(
        "SELECT quantity FROM requests WHERE req_id=$1",
        [reqID]
      );
      quant = quant.rows[0].quantity;
      quant = parseInt(quant, 10);
      let userID = await pool.query(
        "SELECT user_id FROM users WHERE username=$1",
        [username]
      );
      userID = userID.rows[0].user_id;
      let reqstatus = await pool.query(
        "SELECT req_status FROM request_status WHERE status_name='Waiting for Lab Assistant approval'"
      );
      reqstatus = reqstatus.rows[0].req_status;
      //console.log(reqstatus);
      let equipmentID = await pool.query(
        "SELECT equipment_id FROM requests WHERE req_id=$1",
        [reqID]
      );
      equipmentID = equipmentID.rows[0].equipment_id;
      let request = await pool.query(
        "UPDATE requests SET req_status=$1, lab_assistant=$2 WHERE req_id=$3 RETURNING *",
        [reqstatus, null, reqID]
      );
      //console.log(request.rows[0]);
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
        [equipmentID, request.rows[0].location_id]
      );
      await pool.query(
        "UPDATE equipments_in_locations SET available = $1, borrowed = $2 WHERE equipment_id = $3 AND location_id = $4",
        [
          equipm_in_locations.rows[0].available + quant,
          equipm_in_locations.rows[0].borrowed - quant,
          equipmentID,
          request.rows[0].location_id,
        ]
      );
    }
    //console.log("here");
    locationID = await pool.query(
      `SELECT ul.location_id
            FROM users_in_locations ul
            JOIN users u
            ON ul.user_id=u.user_id
            WHERE u.username=$1;`,
      [username]
    );
    //console.log(locationID.rows[0]);
    locationID = locationID.rows[0].location_id;

    request = await pool.query(
      `SELECT e.equipment_name, e.permit, el.available, r.req_id, u.username, r.quantity, rs.status_name, r.req_time
            FROM requests r
            JOIN request_status rs ON r.req_status = rs.req_status
            JOIN equipments e ON r.equipment_id = e.equipment_id
            JOIN equipments_in_locations el ON r.location_id = el.location_id AND r.equipment_id = el.equipment_id
            JOIN users u ON r.user_id = u.user_id
            WHERE r.location_id = $1;
            `,
      [locationID]
    );
    res.status(200).json(request.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const forwardRequesttoHead = async (req, res) => {
  const reqID = req.params.reqID;
  const username = req.params.username;
  try {
    let userID = await pool.query(
      "SELECT user_id,role FROM users WHERE username=$1",
      [username]
    );
    userID = userID.rows[0].user_id;
    let reqstatus = await pool.query(
      "SELECT req_status FROM request_status WHERE status_name='Waiting for Head of Department approval'"
    );
    reqstatus = reqstatus.rows[0].req_status;
    await pool.query(
      "UPDATE requests SET req_status=$1, lab_supervisor=$2 WHERE req_id=$3 RETURNING *",
      [reqstatus, userID, reqID]
    );
    let requests = await pool.query(
      `SELECT e.equipment_name, e.permit, el.available, r.req_id, u.username, r.quantity, rs.status_name, r.req_time
        FROM requests r
        JOIN request_status rs ON r.req_status = rs.req_status
        JOIN equipments e ON r.equipment_id = e.equipment_id
        JOIN equipments_in_locations el ON r.location_id = el.location_id AND r.equipment_id = el.equipment_id
        JOIN users u ON r.user_id = u.user_id
        JOIN request_supervisors rsu ON r.req_id = rsu.req_id and rsu.supervisor_id=$1;
        `,
      [userID]
    );
    //console.log(requests.rows.length)
    res.status(200).json(requests.rows);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const sendRequesttoInventoryManager = async (req, res) => {
  const username = req.params.username;
  const equipmentID = req.params.equipmentID;
  const { quantity, location } = req.body;
  if (!quantity || !location) {
    return res.status(400).json({ error: "All fields are required" });
  }
  const locationID = parseInt(location, 10);
  const quant = parseInt(quantity, 10);
  let equip_in_locations = await pool.query(
    "SELECT available FROM equipments_in_locations WHERE equipment_id=$1 AND location_id=$2",
    [equipmentID, locationID]
  );
  equip_in_locations = parseInt(equip_in_locations.rows[0].available, 10);
  if (quant > equip_in_locations) {
    return res
      .status(400)
      .json({ error: "Requested quantity is not available in this location" });
  }
  let userID = await pool.query("SELECT user_id FROM users WHERE username=$1", [
    username,
  ]);
  userID = userID.rows[0].user_id;
  let req_status = await pool.query(
    "SELECT req_status FROM request_status WHERE status_name='Waiting for inventory manager approval'"
  );
  req_status = req_status.rows[0].req_status;
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

module.exports = {
  createRequest,
  showRequestsLabAssistant,
  acceptRequest,
  declineRequest,
  addComment,
  deleteRequest,
  forwardRequesttoSupervisor,
  getSupervisors,
  selectSupervisors,
  showRequestsSupervisor,
  cancelForwardRequesttoSupervisor,
  forwardRequesttoHead,
  sendRequesttoInventoryManager,
};
