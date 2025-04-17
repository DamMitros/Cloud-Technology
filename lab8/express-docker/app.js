const express=require('express');
const {createClient} = require('redis');
const { Pool } = require('pg');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

const redisClient = createClient({
  url: 'redis://redis:6379'
});

(async () => {
  try {
    await redisClient.connect();
    console.log('Connected to Redis');
  } catch (err) {
    console.error('Error connecting to Redis:', err);
  }
})();

const pool = new Pool({
  host: 'postgres',
  user: 'postgres',
  password: 'postgres123',
  database: 'userdb',
  port: 5432
});

pool.query(`
           CREATE TABLE IF NOT EXISTS users (
              id SERIAL PRIMARY KEY,
              username VARCHAR(100) NOT NULL,
              email VARCHAR(100) NOT NULL
           )`).catch(err=> console.error('Error creating table:', err));

app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Express App</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 40px; line-height: 1.6; }
          h1 { color: #333; }
          .endpoint { background: #f4f4f4; padding: 10px; margin-bottom: 10px; border-radius: 5px; }
        </style>
      </head>
      <body>
        <h1> Witaj na stronie Express Dcoker!</h1>
        <p> Express.js działa z Dockerem i Redisem!</p>

        <h2> Dostępne endpointy:</h2>
        <div class="endpoint">
          <h3>Wiadomości Redis:</h3>
          <p>GET /messages/:key - Pobierz wiadomość z Redis</p>
          <p>POST /messages - Dodaj wiadomość do Redis</p>
        </div>

        <div class="endpoint">
          <h3>Użytkownicy PostgreSQL:</h3>
          <p>GET /users - Lista wszystkich użytkowników</p>
          <p>POST /users - Dodaj nowego użytkownika</p>
        </div>
      </body>
    </html>        
        `)});

//Redis
app.post('/messages', async (req, res) => {
  try {
    const { key, message } = req.body;
    await redisClient.set(key, message);
    res.status(201).json({ success: true, message: `Wiadomośc zapisana z kluczem id: ${key}` });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/messages/:key', async (req, res) => {
  try {
    const { key } = req.params;
    const message = await redisClient.get(key);
    
    if (message) {
      res.json({ success: true, key, message });
    } else {
      res.status(404).json({ success: false, message: 'Wiadomośc nie znaleziona' });
    }
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

//PostgreSQL
app.post('/users', async (req, res) => {
  try {
    const { username, email } = req.body;
    const result = await pool.query(
      'INSERT INTO users (username, email) VALUES ($1, $2) RETURNING id',
      [username, email]
    );
    res.status(201).json({ success: true, userId: result.rows[0].id, message: 'Użytkownik dodany' });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.get('/users', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM users');
    res.json({ success: true, users: result.rows });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

app.listen(port, ()=> {
  console.log(`Serwer działa na http://localhost:${port}`);
  console.log('Redis i PostgreSQL są uruchomione');
  console.log('Aplikacja Express.js działa');
})