CREATE DATABASE IF NOT EXISTS microservices_demo;
USE microservices_demo;

CREATE TABLE IF NOT EXISTS demo_data (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO demo_data (name, description) VALUES 
  ('Item 1', 'Chicken'),
  ('Item 2', 'Banana'),
  ('Item 3', 'Turkish');