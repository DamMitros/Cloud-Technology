const express = require("express");
const mongoose = require("mongoose");
const app = express();

app.use(express.json());

mongoose.connect("mongodb://mongo-container:27017/zad3", {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const User = mongoose.model("users", {
  name: String,
  email: String,
  createdAt: { type: Date, default: Date.now },
});

app.post("/users", async (req, res) => {
  try {
    const { name, email } = req.body;
    const user = new User({ name, email });
    await user.save();
    res.json(user);
  } catch (error) {
    res.status(500).json(error);
  }
});

app.get("/users", async (req, res) => {
  try {
    const users = await User.find();
    res.json(users);
  } catch (error) {
    res.status(500).json(error);
  }
});

app.listen(8080, () => {
  console.log("Server działa na http://localhost:8080");
});
