CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;

CREATE TABLE IF NOT EXISTS orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(100) NOT NULL,
  product VARCHAR(100) NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  order_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO orders (customer_name, product, amount, order_time) VALUES
('Ali Khan',     'Laptop',     950.00, NOW() - INTERVAL 50 MINUTE),
('Sara Ahmed',   'Headphones',  45.50, NOW() - INTERVAL 40 MINUTE),
('Usman Raza',   'Keyboard',    30.00, NOW() - INTERVAL 30 MINUTE),
('Ayesha Malik', 'Monitor',    210.00, NOW() - INTERVAL 20 MINUTE),
('Hassan Ali',   'Mouse',       15.99, NOW() - INTERVAL 10 MINUTE),
('Zara Sheikh',  'Webcam',      60.00, NOW() - INTERVAL 5 MINUTE);

CREATE USER IF NOT EXISTS 'report_user'@'localhost' IDENTIFIED BY 'Report@123';
GRANT SELECT ON company_db.orders TO 'report_user'@'localhost';
FLUSH PRIVILEGES;
