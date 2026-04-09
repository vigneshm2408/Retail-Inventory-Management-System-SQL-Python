Create Database Aadai;
use Aadai;
Show tables;
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15) UNIQUE,
    city VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   
);
CREATE TABLE brands (
    brand_id INT AUTO_INCREMENT PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL
);
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);
CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact VARCHAR(15),
    city VARCHAR(50)
);
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    size VARCHAR(10),
    color VARCHAR(30),
    stock_qty INT DEFAULT 0,
    category_id INT,
    brand_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (category_id) REFERENCES categories(category_id)
    ON UPDATE CASCADE 
    ON DELETE CASCADE,
    FOREIGN KEY (brand_id) REFERENCES brands(brand_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);
CREATE TABLE purchases (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT,
    purchase_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),

    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
	ON UPDATE CASCADE
	ON DELETE CASCADE   
    
);
CREATE TABLE purchase_items (
    purchase_item_id INT AUTO_INCREMENT PRIMARY KEY,
    purchase_id INT,
    product_id INT,
    quantity INT NOT NULL,
    cost_price DECIMAL(10,2),

    FOREIGN KEY (purchase_id) REFERENCES purchases(purchase_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2),

    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE

);
CREATE TABLE order_items (
    order_item INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL, 
    price DECIMAL(10,2),
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE

);
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    payment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL (10,2),
    
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE

);
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    role VARCHAR(50),        
    phone VARCHAR(15),
    salary DECIMAL(10,2)
);


-- SALES    

DELIMITER $$

CREATE TRIGGER update_stock_after_order
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_qty = stock_qty - NEW.quantity
    WHERE product_id = NEW.product_id;
END $$

DELIMITER ;
    
-- INSERT STOCK    
DELIMITER $$

CREATE TRIGGER trg_purchase_insert
AFTER INSERT ON purchase_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_qty = stock_qty + NEW.quantity
    WHERE product_id = NEW.product_id;
END $$

DELIMITER ;
    
-- UPDATE STOCK  
DELIMITER $$

CREATE TRIGGER trg_purchase_update
AFTER UPDATE ON purchase_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_qty = stock_qty - OLD.quantity + NEW.quantity
    WHERE product_id = NEW.product_id;
END $$

DELIMITER ;

-- DELETE STOCK
DELIMITER $$

CREATE TRIGGER trg_purchase_delete
AFTER DELETE ON purchase_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_qty = stock_qty - OLD.quantity
    WHERE product_id = OLD.product_id;
END $$

DELIMITER ;
  
  
  
  
-- Queries
Show Tables;

SELECT * FROM BRANDS; 
SELECT * FROM CATEGORIES;
SELECT * FROM CUSTOMERS;
SELECT * FROM EMPLOYEES;
SELECT * FROM ORDER_ITEMS;
SELECT * FROM ORDERS;
SELECT * FROM PAYMENTS;
SELECT * FROM PRODUCTS;
SELECT * FROM PURCHASE_ITEMS;
SELECT * FROM PURCHASES;
SELECT * FROM SUPPLIERS; 
  
-- DROP  
DROP DATABASE AADAI;  
DROP TRIGGER update_stock_after_order;
DROP TRIGGER trg_purchase_insert;
DROP TRIGGER trg_purchase_update;
DROP TRIGGER trg_purchase_delete;


-- VIEW FULL ORDER DETAILS 
SELECT 
    o.order_id,
    c.name AS customer,
    p.product_name,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) AS total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- TOTAL SALES PER CUSTOMER
SELECT 
    c.name,
    SUM(o.total_amount) AS total_spent
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.name;

-- LOW STOCK PRODUCTS 
SELECT product_name, stock_qty
FROM products
WHERE stock_qty < 20;

-- SUPPLIER PURCHASE SUMMARY 
SELECT 
    s.supplier_name,
    SUM(p.total_amount) AS total_purchase
FROM purchases p
JOIN suppliers s ON p.supplier_id = s.supplier_id
GROUP BY s.supplier_name;

-- FULL BILL VIEW 
SELECT 
    o.order_id,
    c.name,
    p.product_name,
    oi.quantity,
    oi.price,
    (oi.quantity * oi.price) AS total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- Insert values 

INSERT INTO customers (name, email, phone, city) VALUES
('Vignesh M', 'vigneshm@gmail.com', '9000000001', 'Chennai'),
('Arun Kumar', 'arunkumar@gmail.com', '9000000002', 'Madurai'),
('Karthik Raj', 'karthikraj@gmail.com', '9000000003', 'Coimbatore'),
('Divya S', 'divyas@gmail.com', '9000000004', 'Trichy'),
('Meena Lakshmi', 'meenalakshmi@gmail.com', '9000000005', 'Salem'),
('Praveen K', 'praveenk@gmail.com', '9000000006', 'Erode'),
('Sathish R', 'sathishr@gmail.com', '9000000007', 'Tirunelveli'),
('Nisha P', 'nishap@gmail.com', '9000000008', 'Vellore'),
('Rahul S', 'rahuls@gmail.com', '9000000009', 'Thanjavur'),
('Keerthana M', 'keerthanam@gmail.com', '9000000010', 'Kanyakumari');

 INSERT INTO brands (brand_name) VALUES
('Levis'),
('Puma'),
('Nike'),
('Adidas'),
('Zara'),
('H&M'),
('Allen Solly'),
('Peter England'),
('Van Heusen'),
('Raymond');
  
 INSERT INTO categories (category_name) VALUES
('Shirts'),
('T-Shirts'),
('Jeans'),
('Trousers'),
('Kurtas'),
('Sarees'),
('Jackets'),
('Shorts'),
('Track Pants'),
('Hoodies');

INSERT INTO suppliers (supplier_name, contact, city) VALUES
('Sri Garments', '9000011111', 'Chennai'),
('Fashion Hub', '9000011112', 'Madurai'),
('Style Tex', '9000011113', 'Coimbatore'),
('Classic Wear', '9000011114', 'Tiruppur'),
('Urban Cloth Co', '9000011115', 'Salem'),
('Elite Fabrics', '9000011116', 'Erode'),
('Trendy Collections', '9000011117', 'Trichy'),
('Royal Textiles', '9000011118', 'Kanchipuram'),
('Modern Outfitters', '9000011119', 'Vellore'),
('South India Fashion', '9000011120', 'Tirunelveli');

INSERT INTO products 
(product_name, price, size, color, stock_qty, category_id, brand_id)
VALUES
('Men Slim Fit Shirt', 1499.00, 'M', 'Blue', 50, 1, 7),
('Casual T-Shirt', 799.00, 'L', 'Black', 80, 2, 3),
('Regular Fit Jeans', 1999.00, '32', 'Navy', 40, 3, 1),
('Formal Trousers', 1799.00, '34', 'Grey', 35, 4, 9),
('Cotton Kurta', 1299.00, 'L', 'White', 60, 5, 8),
('Designer Saree', 2499.00, 'Free', 'Red', 25, 6, 10),
('Winter Jacket', 2999.00, 'XL', 'Brown', 20, 7, 2),
('Sports Shorts', 699.00, 'M', 'Green', 70, 8, 4),
('Track Pants', 999.00, 'L', 'Black', 55, 9, 2),
('Hooded Sweatshirt', 1599.00, 'XL', 'Maroon', 45, 10, 5);

INSERT INTO purchases (supplier_id, purchase_date, total_amount) VALUES
(1, NOW(), 15000.00),
(2, NOW(), 18000.00),
(3, NOW(), 12000.00),
(4, NOW(), 22000.00),
(5, NOW(), 14000.00),
(6, NOW(), 16000.00),
(7, NOW(), 20000.00),
(8, NOW(), 17500.00),
(9, NOW(), 19000.00),
(10, NOW(), 21000.00);

INSERT INTO purchase_items (purchase_id, product_id, quantity, cost_price) VALUES
(1, 1, 20, 1200.00),
(2, 2, 30, 600.00),
(3, 3, 15, 1500.00),
(4, 4, 25, 1400.00),
(5, 5, 18, 1000.00),
(6, 6, 10, 2000.00),
(7, 7, 12, 2500.00),
(8, 8, 22, 500.00),
(9, 9, 28, 800.00),
(10, 10, 16, 1300.00);

INSERT INTO orders (customer_id, order_date, total_amount) VALUES
(1, NOW(), 3000.00),
(2, NOW(), 2500.00),
(3, NOW(), 4000.00),
(4, NOW(), 2800.00),
(5, NOW(), 3500.00),
(6, NOW(), 2200.00),
(7, NOW(), 4500.00),
(8, NOW(), 2600.00),
(9, NOW(), 3200.00),
(10, NOW(), 3800.00);

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 2, 1500.00),
(2, 2, 3, 800.00),
(3, 3, 2, 2000.00),
(4, 4, 2, 1400.00),
(5, 5, 3, 1200.00),
(6, 6, 1, 2200.00),
(7, 7, 2, 2300.00),
(8, 8, 4, 650.00),
(9, 9, 3, 1000.00),
(10, 10, 2, 1900.00);

INSERT INTO payments (order_id, payment_method, payment_status, payment_date, amount) VALUES
(1, 'Cash', 'PAID', NOW(), 3000.00),
(2, 'UPI', 'PAID', NOW(), 2500.00),
(3, 'Card', 'PAID', NOW(), 4000.00),
(4, 'Cash', 'PAID', NOW(), 2800.00),
(5, 'UPI', 'PAID', NOW(), 3500.00),
(6, 'Card', 'PENDING', NOW(), 2200.00),
(7, 'UPI', 'PAID', NOW(), 4500.00),
(8, 'Cash', 'PAID', NOW(), 2600.00),
(9, 'Card', 'PAID', NOW(), 3200.00),
(10, 'UPI', 'PAID', NOW(), 3800.00);

INSERT INTO employees (name, role, phone, salary) VALUES
('Ravi Kumar', 'Manager', '9876543210', 35000.00),
('Arun Prakash', 'Sales Executive', '9123456789', 22000.00),
('Divya S', 'Cashier', '9000012345', 18000.00);

delete from customers where phone = '1';    