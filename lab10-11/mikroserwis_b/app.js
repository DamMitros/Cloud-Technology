const express = require("express");
const { MongoClient } = require("mongodb");
const app = express();
const port = 3001;

app.use(express.json());

const mongoHost = process.env.MONGO_SERVICE_HOST || 'localhost';
const mongoPort = process.env.MONGO_SERVICE_PORT || '27017';
const mongoUser = process.env.MONGO_USER;
const mongoPass = process.env.MONGO_PASS;
const dbName = 'mydb'; 

let mongoUrl;
if (mongoUser && mongoPass) {
  mongoUrl = `mongodb://${mongoUser}:${mongoPass}@${mongoHost}:${mongoPort}/${dbName}?authSource=admin`;
} else {
  mongoUrl = `mongodb://${mongoHost}:${mongoPort}/${dbName}`;
  console.warn('Connecting to MongoDB without authentication. MONGO_USER and/or MONGO_PASS not set.');
}

let db;

async function connectToDatabase() {
  try {
    const client = new MongoClient(mongoUrl);
    await client.connect();
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
