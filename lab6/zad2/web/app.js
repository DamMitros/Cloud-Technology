const express = require('express');
const mysql = require('mysql2/promise');
const app = express();
const port = 3000;

const dbConfig = {
  host: 'db',
  user: 'root',
  password: 'password',
  database: 'microservices_demo'
};

const connectWithRetry = async (retries = 5, delay = 5000) => {
  let lastError;
  
  for (let i = 0; i < retries; i++) {
    try {
      console.log(`Attempting database connection (attempt ${i + 1}/${retries})...`);
      const connection = await mysql.createConnection(dbConfig);
      console.log('Database connection successful!');
      return connection;
    } catch (error) {
      console.error(`Connection attempt ${i + 1} failed:`, error.message);
      lastError = error;
      
      if (i < retries - 1) {
        console.log(`Retrying in ${delay/1000} seconds...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw new Error(`Failed to connect to database after ${retries} attempts: ${lastError.message}`);
};

app.get('/', async (req, res) => {
  try {
    const connection = await connectWithRetry();
    const [rows] = await connection.execute('SELECT * FROM demo_data');
    
    let responseHtml = `
      <html>
      <head>
      <title>Demo Mikroserwisów</title>
      <style>
        body { font-family: 'Segoe UI', Tahoma, sans-serif; margin: 30px; background-color: #f8f9fa; }
        h1 { color: #4a86e8; margin-bottom: 20px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        th { background-color: #f2f2f2; }
        tr:hover { background-color: #f5f5f5; }
        .connection-info { background-color: #e8f4f8; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
      </style>
      </head>
      <body>
      <h1>Demo Mikroserwisów</h1>
      <div class="connection-info">
        <h2>Informacje o połączeniu</h2>
        <p>Połączono z bazą MySQL na <strong>db:${dbConfig.port || 3306}</strong></p>
        <p>Nazwa bazy: <strong>${dbConfig.database}</strong></p>
      </div>
      <h2>Dane z bazy:</h2>
      <table>
        <tr>
        <th>ID</th>
        <th>Nazwa</th>
        <th>Opis</th>
        <th>Data utworzenia</th>
        </tr>`;
        
    rows.forEach(row => {
      responseHtml += `
      <tr>
        <td>${row.id}</td>
        <td>${row.name}</td>
        <td>${row.description}</td>
        <td>${row.created_at}</td>
      </tr>`;
    });
    
    responseHtml += `
      </table>
      </body>
      </html>`;
    
    res.send(responseHtml);

    await connection.end();
    
  } catch (error) {
    console.error('Database connection error:', error);
  }
});

app.listen(port, '0.0.0.0', () => {
  console.log(`Web service listening at http://0.0.0.0:${port}`);
});