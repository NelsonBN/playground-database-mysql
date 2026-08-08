CREATE TABLE `countries` (
  `country_code` CHAR(2) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`country_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `categories` (
  `category_id` CHAR(5) NOT NULL,
  `category_name` VARCHAR(30) NOT NULL,
  `description` VARCHAR(150) DEFAULT NULL,
  PRIMARY KEY (`category_id`),
  UNIQUE KEY `uq__categories__category_name` (`category_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `shippers` (
  `shipper_id` INT NOT NULL AUTO_INCREMENT,
  `company_name` VARCHAR(40) NOT NULL,
  `address` VARCHAR(60) NOT NULL,
  `city` VARCHAR(15) NOT NULL,
  `region` VARCHAR(15) NOT NULL,
  `postal_code` VARCHAR(10) NOT NULL,
  `country` CHAR(2) NOT NULL,
  `phone` VARCHAR(24) DEFAULT NULL,
  `email` VARCHAR(150) NOT NULL,
  PRIMARY KEY (`shipper_id`),
  UNIQUE KEY `uq__shippers__company_name` (`company_name`),
  KEY `fk__shippers__country` (`country`),
  CONSTRAINT `fk__shippers__country` FOREIGN KEY (`country`) REFERENCES `countries` (`country_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `customers` (
  `customer_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `address` VARCHAR(60) NOT NULL,
  `city` VARCHAR(15) NOT NULL,
  `region` VARCHAR(15) NOT NULL,
  `postal_code` VARCHAR(10) NOT NULL,
  `country` CHAR(2) NOT NULL,
  `phone` VARCHAR(24) DEFAULT NULL,
  `email` VARCHAR(150) NOT NULL,
  PRIMARY KEY (`customer_id`),
  KEY `fk__customers__country` (`country`),
  CONSTRAINT `fk__customers__country` FOREIGN KEY (`country`) REFERENCES `countries` (`country_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `employees` (
  `employee_id` INT NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(50) NOT NULL,
  `last_name` VARCHAR(50) NOT NULL,
  `title` VARCHAR(30) DEFAULT NULL,
  `title_of_courtesy` VARCHAR(25) DEFAULT NULL,
  `birth_date` DATE DEFAULT NULL,
  `hire_date` DATE DEFAULT NULL,
  `address` VARCHAR(60) NOT NULL,
  `city` VARCHAR(15) NOT NULL,
  `region` VARCHAR(15) NOT NULL,
  `postal_code` VARCHAR(10) NOT NULL,
  `country` CHAR(2) NOT NULL,
  `home_phone` VARCHAR(24) DEFAULT NULL,
  `email` VARCHAR(150) DEFAULT NULL,
  `photo_path` VARCHAR(255) DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  `reports_to` INT DEFAULT NULL,
  PRIMARY KEY (`employee_id`),
  KEY `fk__employees__reports_to` (`reports_to`),
  KEY `idx__employees__last_name` (`last_name`),
  KEY `idx__employees__first_name` (`first_name`),
  KEY `fk__employees__country` (`country`),
  CONSTRAINT `fk__employees__reports_to` FOREIGN KEY (`reports_to`) REFERENCES `employees` (`employee_id`),
  CONSTRAINT `fk__employees__country` FOREIGN KEY (`country`) REFERENCES `countries` (`country_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `suppliers` (
  `supplier_id` INT NOT NULL AUTO_INCREMENT,
  `company_name` VARCHAR(40) NOT NULL,
  `contact_name` VARCHAR(30) DEFAULT NULL,
  `contact_title` VARCHAR(30) DEFAULT NULL,
  `address` VARCHAR(60) NOT NULL,
  `city` VARCHAR(15) NOT NULL,
  `region` VARCHAR(15) NOT NULL,
  `postal_code` VARCHAR(10) NOT NULL,
  `country` CHAR(2) NOT NULL,
  `phone` VARCHAR(24) DEFAULT NULL,
  `email` VARCHAR(150) NOT NULL,
  PRIMARY KEY (`supplier_id`),
  UNIQUE KEY `uq__suppliers__company_name` (`company_name`),
  KEY `fk__suppliers__country` (`country`),
  CONSTRAINT `fk__suppliers__country` FOREIGN KEY (`country`) REFERENCES `countries` (`country_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `products` (
  `product_id` INT NOT NULL AUTO_INCREMENT,
  `product_name` VARCHAR(40) NOT NULL,
  `supplier_id` INT NOT NULL,
  `category_id` CHAR(5) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `photo_path` VARCHAR(255) DEFAULT NULL,
  `unit_price` DECIMAL(10,4) NOT NULL,
  `units_in_stock` SMALLINT NOT NULL,
  `discontinued` BIT(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `uq__products__product_name` (`product_name`),
  KEY `fk__products__supplier_id` (`supplier_id`),
  KEY `fk__products__category_id` (`category_id`),
  CONSTRAINT `fk__products__category_id` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`),
  CONSTRAINT `fk__products__supplier_id` FOREIGN KEY (`supplier_id`) REFERENCES `suppliers` (`supplier_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `orders` (
  `order_id` INT NOT NULL AUTO_INCREMENT,
  `customer_id` INT NOT NULL,
  `employee_id` INT NOT NULL,
  `order_date` DATE DEFAULT NULL,
  `required_date` DATE NOT NULL,
  `shipped_date` DATE NOT NULL,
  `ship_via` INT NOT NULL,
  `freight` DECIMAL(10,4) DEFAULT NULL,
  `ship_name` VARCHAR(40) DEFAULT NULL,
  `ship_address` VARCHAR(60) NOT NULL,
  `ship_city` VARCHAR(15) NOT NULL,
  `ship_region` VARCHAR(15) NOT NULL,
  `ship_postal_code` VARCHAR(10) NOT NULL,
  `ship_country` CHAR(2) NOT NULL,
  PRIMARY KEY (`order_id`),
  KEY `fk__orders__ship_via` (`ship_via`),
  KEY `fk__orders__customer_id` (`customer_id`),
  KEY `fk__orders__employee_id` (`employee_id`),
  KEY `idx__orders__order_date` (`order_date`),
  KEY `fk__orders__ship_country` (`ship_country`),
  CONSTRAINT `fk__orders__customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk__orders__employee_id` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`),
  CONSTRAINT `fk__orders__ship_via` FOREIGN KEY (`ship_via`) REFERENCES `shippers` (`shipper_id`),
  CONSTRAINT `fk__orders__ship_country` FOREIGN KEY (`ship_country`) REFERENCES `countries` (`country_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


CREATE TABLE `order_details` (
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `unit_price` DECIMAL(10,4) NOT NULL,
  `quantity` SMALLINT NOT NULL,
  `discount` DECIMAL(4,3) NOT NULL DEFAULT 0.000,
  PRIMARY KEY (`order_id`,`product_id`),
  KEY `fk__order_details__product_id` (`product_id`),
  KEY `fk__order_details__order_id` (`order_id`),
  CONSTRAINT `fk__order_details__order_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `fk__order_details__product_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
