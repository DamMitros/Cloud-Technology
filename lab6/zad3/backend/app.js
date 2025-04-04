const express = require("express");
const { Pool } = require("pg");
const app = express();
const port = 3000;

app.use(express.json());

const pool = new Pool({
  host: "database",
  user: "myuser",
  password: "mypassword",
  database: "mydatabase",
  port: 5432,
});

app.get("/api/health", (req, res) => {
  res.json({ status: "OK" });
});

app.get("/api/data", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM users");
    res.json(result.rows);
  } catch (error) {
    console.error("Database error:", error);
    res.status(500).json({ error: "Database connection failed" });
  }
});

app.listen(port, "0.0.0.0", () => {
  console.log(`Backend service running at http://0.0.0.0:${port}`);
});
