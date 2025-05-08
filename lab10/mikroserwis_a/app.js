const express = require('express');
const axios = require('axios');
const app = express();
const port = 3000;

const mikroserwisBItemsUrl = 'http://mikroserwis-b-service:3001/items';
const mikroserwisBPingUrl = 'http://mikroserwis-b-service:3001/ping';

app.use(express.json());

app.get('/call-ping', async (req, res) => {
  try {
    console.log('Calling mikroserwis_b...');
    const response = await axios.get(mikroserwisBPingUrl);
    console.log('Response from mikroserwis_b:', response.data);
    res.json({ message: 'Response from mikroserwis_b', data: response.data });
  } catch (error) {
    console.error('Error calling mikroserwis_b:', error.message);
    res.status(500).json({ error: 'Error calling mikroserwis_b' });
  }
});

app.post('/items', async (req, res) => {
  try {
    console.log('Sending item to mikroserwis_b...');
    const response = await axios.post(mikroserwisBItemsUrl, req.body);
    console.log('Response from mikroserwis_b:', response.data);
    res.status(201).json(response.data);
  } catch (error) {
    console.error('Error sending item to mikroserwis_b:', error.message);
    res.status(500).json({ error: 'Error sending item to mikroserwis_b' });
  }
});

app.get('/items', async (req, res) => {
  try {
    console.log('Fetching items from mikroserwis_b...');
    const response = await axios.get(mikroserwisBItemsUrl);
    console.log('Response from mikroserwis_b:', response.data);
    res.json(response.data);
  } catch (error) {
    console.error('Error fetching items from mikroserwis_b:', error.message);
    res.status(500).json({ error: 'Error fetching items from mikroserwis_b' });
  }
});

app.listen(port, () => {
  console.log(`mikroserwis_a listening at http://localhost:${port}`);
});