const Ap = require("../models/apPower");
const whereami = require("../services/whereami/predict");
const fs = require("fs"),
  RandomForestClassifier =
    require("random-forest-classifier").RandomForestClassifier;
const rf = new RandomForestClassifier({
  n_estimators: 20,
});

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
  Ap.find().then((data, err) => {
    console.log("--- Read all ---");
    if (err) {
      console.log(err);
    } else {
      let allData = data.map((d) => {
        return {
          name: d.name,
          point: d.point,
        };
      });
      // console.log(allData);
      allData = allData.map((d) => {
        const newData = {
          spot: d.name,
        };
        d.point.forEach((item) => {
          const key = Object.keys(item)[0];
          newData[key] = Math.abs(Number(item[key]));
        });
        return newData;
      });
      // console.log(allData);

      let allKeys = new Set();

      allData.forEach((data) => {
        Object.keys(data).forEach((key) => allKeys.add(key));
      });
      allKeys.delete("spot");

      // console.log(allKeys);

      allData.forEach((data) => {
        for (const pointToCheck of allKeys) {
          if (!data.hasOwnProperty(pointToCheck)) {
            data[pointToCheck] = 0;
          }
        }
      });

      allData.forEach((data) => {
        console.log(Object.keys(data).length);
      });

      rf.fit(allData, null, "spot", function (err, trees) {
        let data = req.body;
        for (const pointToCheck of allKeys) {
          const pointIndex = data.findIndex(
            (point) => Object.keys(point)[0] === pointToCheck
          );
          if (pointIndex === -1) {
            data.push({ [pointToCheck]: 0 });
          }
        }
        const newData = {};
        data.forEach((item) => {
          const key = Object.keys(item)[0];
          newData[key] = Math.abs(Number(item[key]));
        });
        console.log(Object.keys(newData).length);
        const pred = rf.predict(newData, trees);
        console.log(pred);
      });
    }
  });
};
