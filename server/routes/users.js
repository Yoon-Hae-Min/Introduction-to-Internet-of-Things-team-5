var express = require("express");
var router = express.Router();
const whereami = require("../services/whereami/predict");

/* GET users listing. */
router.get("/", async function (req, res, next) {
  const result = await whereami([
    { "iptime409 90:9f:33:5c:28:3c": 100 },
    { "iptime409 90:9f:33:5c:28:3c": 100 },
    { "iptime409 90:9f:33:5c:28:3c": 100 },
  ]);
  console.log(result);
  return res.status(200).json({ body: result });
});

module.exports = router;
