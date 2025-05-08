const express = require("express");
const { MongoClient } = require("mongodb");
const app = express();
const port = 3001;

app.use(express.json());

const mongoUrl = "mongodb://mongo-service:27017";
const dbName = "mydb";
let db;

async function connectToDatabase() {
  try {
    const client = await MongoClient.connect(mongoUrl, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    db = client.db(dbName);
    console.log("Connected to MongoDB");
  } catch (error) {
    console.error("Error connecting to MongoDB:", error);
  }
}

connectToDatabase();

app.get("/ping", (req, res) => {
  console.log("mikroserwis_b received ping");
  res.send("pong");
});

app.post("/items", async (req, res) => {
  if (!db) {
    return res.status(500).json({ error: "Database not connected" });
  }
  try {
    const item = req.body;
    const collection = db.collection("items");
    const result = await collection.insertOne(item);
    res.status(201).json({ ...item, _id: result.insertedId });
  } catch (error) {
    console.error("Error inserting item:", error);
    res.status(500).json({ error: "Error inserting item" });
  }
});

app.get("/items", async (req, res) => {
  if (!db) {
    return res.status(500).json({ error: "Database not connected" });
  }
  try {
    const collection = db.collection("items");
    const items = await collection.find({}).toArray();
    res.json(items);
  } catch (error) {
    console.error("Error fetching items:", error);
    res.status(500).json({ error: "Error fetching items" });
  }
});

app.listen(port, () => {
  console.log(`mikroserwis_b listening at http://localhost:${port}`);
});
