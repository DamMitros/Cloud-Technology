const http = require('http');

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/html');
  res.end(`
    <html>
      <body>
        <h1>Node.js działa przez Nginx!</h1><p>Data i czas: ' + new Date() + '</p>
      </body>
    </html>`
  )});

server.listen(3000, '0.0.0.0', () => {
  console.log('Serwer Node.js uruchomiony na porcie 3000');
});