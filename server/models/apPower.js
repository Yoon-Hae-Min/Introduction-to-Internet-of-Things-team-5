const mongoose = require("mongoose");

const apSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    point: {
      type: Array,
      required: true,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model("ap", apSchema);
