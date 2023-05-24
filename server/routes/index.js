var express = require("express");
var router = express.Router();
const whereami = require("../services/whereami/predict");
const apController = require("../controllers/apPower");

/* GET home page. */

// ap 세기를 받아서 가장 가까운 위치를 전송해주는 api
router.get("/point", async function (req, res, next) {
  console.log(req.body);
  try {
    const result = await apController.predictAP(req, res);
    return res.status(200).json({ data: result });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ data: err });
  }
});

// ap 세기를 등록하는 api
router.post("/point", async function (req, res, next) {
  try {
    const result = apController.createAPPower(req, res);
    return res.status(200).json({ data: result });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ data: err });
  }
});

module.exports = router;
