const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const PORT = 3000;
const MONGO_URL = process.env.MONGO_URL;

let db;

MongoClient.connect(MONGO_URL, { useUnifiedTopology: true })
  .then(client => {
    db = client.db('test');
    app.listen(PORT, () => console.log(`Server successfully connected to MongoDB\n Running on port ${PORT}`));
  })
  .catch(err => (console.error('Failed to connect to MongoDB', err)));

app.get('/users', async (req, res) => {
  try {
    const users = await db.collection('users').find().toArray();
    res.json(users);
  } catch (err) {
    res.status(500).send('Error fetching users');
  }
});