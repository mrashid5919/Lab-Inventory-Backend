require("dotenv").config();

//require
const express = require("express");
const cors = require('cors');

//start the app

const userRoute = require("./routes/user");
const equipmentRoute=require("./routes/equipment");
const storageRoute=require("./routes/storage");

const app = express();

app.use(express.json());

app.use(cors());

app.use("/api/user", userRoute);
app.use("/api/equipments",equipmentRoute);
app.use("/api/storage",storageRoute);

app.get("/home", (req, res) => {
  res.send("hello world");
});

app.listen(5000, () => {
  console.log("server is running on port 5000!!!");
});
