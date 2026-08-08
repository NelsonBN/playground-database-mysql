DELETE FROM order_details;
DELETE FROM orders;
DELETE FROM products;
DELETE FROM customers;
DELETE FROM suppliers;
UPDATE employees SET reports_to = NULL;
DELETE FROM employees;
DELETE FROM shippers;
DELETE FROM categories;
DELETE FROM countries;

ALTER TABLE shippers       AUTO_INCREMENT = 1;
ALTER TABLE customers      AUTO_INCREMENT = 1;
ALTER TABLE employees      AUTO_INCREMENT = 1;
ALTER TABLE suppliers      AUTO_INCREMENT = 1;
ALTER TABLE products       AUTO_INCREMENT = 1;
ALTER TABLE orders         AUTO_INCREMENT = 1;
ALTER TABLE order_details  AUTO_INCREMENT = 1;
