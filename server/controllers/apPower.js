const Ap = require("../models/apPower");
const whereami = require("../services/whereami/predict");

exports.createAPPower = async (req, res) => {
  if (!req.body || !req.body.name || !req.body.data) {
    res.status(400).send({
      message: "Data is empty!",
    });
    return;
  }
  // Set document
  const data = req.body;
  const apModel = new Ap({
    name: data.name,
    point: data.data,
  });

  const result = await apModel.save();

  return result;
};

exports.predictAP = (req, res) => {
  return whereami(req.body);
};
