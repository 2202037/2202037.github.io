-- ============================================================
-- Ayur Healthcare App — Complete Database Schema + Seed Data
-- ============================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

CREATE DATABASE IF NOT EXISTS `ayur_db`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `ayur_db`;

-- ------------------------------------------------------------
-- users
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`          VARCHAR(150)  NOT NULL,
  `email`         VARCHAR(191)  NOT NULL,
  `password_hash` VARCHAR(255)  NOT NULL,
  `role`          ENUM('patient','doctor','clinic','pharmacy','admin') NOT NULL DEFAULT 'patient',
  `phone`         VARCHAR(20)   DEFAULT NULL,
  `profile_image` VARCHAR(500)  DEFAULT NULL,
  `address`       TEXT          DEFAULT NULL,
  `created_at`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- clinics
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `clinics` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`         VARCHAR(200)   NOT NULL,
  `address`      TEXT           NOT NULL,
  `phone`        VARCHAR(20)    DEFAULT NULL,
  `email`        VARCHAR(191)   DEFAULT NULL,
  `latitude`     DECIMAL(10,7)  DEFAULT NULL,
  `longitude`    DECIMAL(10,7)  DEFAULT NULL,
  `opening_time` TIME           DEFAULT NULL,
  `closing_time` TIME           DEFAULT NULL,
  `image_url`    VARCHAR(500)   DEFAULT NULL,
  `rating`       DECIMAL(3,2)   DEFAULT 0.00,
  `created_at`   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   DATETIME       NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- doctors
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `doctors` (
  `id`               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`          INT UNSIGNED NOT NULL,
  `specialty`        VARCHAR(150)  NOT NULL,
  `clinic_id`        INT UNSIGNED  DEFAULT NULL,
  `fee`              DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `bio`              TEXT          DEFAULT NULL,
  `experience_years` TINYINT UNSIGNED NOT NULL DEFAULT 0,
  `image_url`        VARCHAR(500)  DEFAULT NULL,
  `is_available`     TINYINT(1)   NOT NULL DEFAULT 1,
  `rating`           DECIMAL(3,2) NOT NULL DEFAULT 0.00,
  `latitude`         DECIMAL(10,7) DEFAULT NULL,
  `longitude`        DECIMAL(10,7) DEFAULT NULL,
  `created_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_doctors_user` (`user_id`),
  KEY `idx_doctors_clinic` (`clinic_id`),
  KEY `idx_doctors_specialty` (`specialty`),
  CONSTRAINT `fk_doctors_user`   FOREIGN KEY (`user_id`)   REFERENCES `users`   (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_doctors_clinic` FOREIGN KEY (`clinic_id`) REFERENCES `clinics` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- appointments
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `appointments` (
  `id`               INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `patient_id`       INT UNSIGNED NOT NULL,
  `doctor_id`        INT UNSIGNED NOT NULL,
  `appointment_date` DATE         NOT NULL,
  `appointment_time` TIME         NOT NULL,
  `status`           ENUM('pending','confirmed','completed','cancelled') NOT NULL DEFAULT 'pending',
  `payment_status`   ENUM('unpaid','paid','refunded') NOT NULL DEFAULT 'unpaid',
  `notes`            TEXT         DEFAULT NULL,
  `created_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_appt_patient` (`patient_id`),
  KEY `idx_appt_doctor`  (`doctor_id`),
  KEY `idx_appt_date`    (`appointment_date`),
  CONSTRAINT `fk_appt_patient` FOREIGN KEY (`patient_id`) REFERENCES `users`   (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_appt_doctor`  FOREIGN KEY (`doctor_id`)  REFERENCES `doctors` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- blood_inventory
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `blood_inventory` (
  `id`           INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `blood_group`  VARCHAR(5)   NOT NULL,
  `quantity`     INT          NOT NULL DEFAULT 0,
  `last_updated` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_blood_group` (`blood_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- blood_requests
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `blood_requests` (
  `id`            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `requester_id`  INT UNSIGNED NOT NULL,
  `blood_group`   VARCHAR(5)   NOT NULL,
  `quantity`      INT          NOT NULL DEFAULT 1,
  `urgency`       ENUM('normal','urgent','critical') NOT NULL DEFAULT 'normal',
  `status`        ENUM('pending','fulfilled','rejected') NOT NULL DEFAULT 'pending',
  `hospital_name` VARCHAR(200) DEFAULT NULL,
  `notes`         TEXT         DEFAULT NULL,
  `created_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_blood_req_user`  (`requester_id`),
  KEY `idx_blood_req_group` (`blood_group`),
  CONSTRAINT `fk_blood_req_user` FOREIGN KEY (`requester_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- pharmacy_products
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `pharmacy_products` (
  `id`             INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name`           VARCHAR(200)  NOT NULL,
  `description`    TEXT          DEFAULT NULL,
  `price`          DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `stock_quantity` INT           NOT NULL DEFAULT 0,
  `category`       VARCHAR(100)  DEFAULT NULL,
  `image_url`      VARCHAR(500)  DEFAULT NULL,
  `is_active`      TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_products_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- cart
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `cart` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    INT UNSIGNED NOT NULL,
  `product_id` INT UNSIGNED NOT NULL,
  `quantity`   INT          NOT NULL DEFAULT 1,
  `added_at`   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cart_user_product` (`user_id`, `product_id`),
  KEY `idx_cart_user`    (`user_id`),
  KEY `idx_cart_product` (`product_id`),
  CONSTRAINT `fk_cart_user`    FOREIGN KEY (`user_id`)    REFERENCES `users`             (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cart_product` FOREIGN KEY (`product_id`) REFERENCES `pharmacy_products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- orders
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `orders` (
  `id`               INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`          INT UNSIGNED  NOT NULL,
  `total_amount`     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `status`           ENUM('pending','processing','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
  `delivery_address` TEXT          DEFAULT NULL,
  `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_orders_user` (`user_id`),
  CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- order_items
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `order_items` (
  `id`         INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `order_id`   INT UNSIGNED  NOT NULL,
  `product_id` INT UNSIGNED  NOT NULL,
  `quantity`   INT           NOT NULL DEFAULT 1,
  `price`      DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `idx_order_items_order`   (`order_id`),
  KEY `idx_order_items_product` (`product_id`),
  CONSTRAINT `fk_oi_order`   FOREIGN KEY (`order_id`)   REFERENCES `orders`            (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_oi_product` FOREIGN KEY (`product_id`) REFERENCES `pharmacy_products` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- payments
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `payments` (
  `id`             INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `user_id`        INT UNSIGNED  NOT NULL,
  `appointment_id` INT UNSIGNED  DEFAULT NULL,
  `amount`         DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `status`         ENUM('pending','completed','failed') NOT NULL DEFAULT 'pending',
  `transaction_id` VARCHAR(191)  DEFAULT NULL,
  `payment_method` VARCHAR(50)   DEFAULT NULL,
  `created_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_payments_user`        (`user_id`),
  KEY `idx_payments_appointment` (`appointment_id`),
  CONSTRAINT `fk_payments_user`        FOREIGN KEY (`user_id`)        REFERENCES `users`        (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_payments_appointment` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- notifications
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `notifications` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    INT UNSIGNED NOT NULL,
  `title`      VARCHAR(255) NOT NULL,
  `body`       TEXT         NOT NULL,
  `type`       VARCHAR(50)  DEFAULT 'general',
  `is_read`    TINYINT(1)  NOT NULL DEFAULT 0,
  `created_at` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notif_user`    (`user_id`),
  KEY `idx_notif_is_read` (`is_read`),
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- device_tokens
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `device_tokens` (
  `id`         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    INT UNSIGNED NOT NULL,
  `token`      VARCHAR(500) NOT NULL,
  `platform`   ENUM('android','ios','web') NOT NULL DEFAULT 'android',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_device_token` (`token`(191)),
  KEY `idx_device_tokens_user` (`user_id`),
  CONSTRAINT `fk_device_token_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- audit_logs
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id`         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`    INT UNSIGNED    DEFAULT NULL,
  `action`     VARCHAR(20)     NOT NULL,
  `table_name` VARCHAR(64)     NOT NULL,
  `record_id`  INT UNSIGNED    DEFAULT NULL,
  `old_data`   JSON            DEFAULT NULL,
  `new_data`   JSON            DEFAULT NULL,
  `created_at` DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_audit_user`   (`user_id`),
  KEY `idx_audit_table`  (`table_name`),
  KEY `idx_audit_record` (`record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TRIGGERS — audit logging for appointments
-- ============================================================

DELIMITER $$

CREATE TRIGGER `trg_appointments_after_update`
AFTER UPDATE ON `appointments`
FOR EACH ROW
BEGIN
  INSERT INTO `audit_logs` (`action`, `table_name`, `record_id`, `old_data`, `new_data`)
  VALUES (
    'UPDATE',
    'appointments',
    NEW.id,
    JSON_OBJECT(
      'status',         OLD.status,
      'payment_status', OLD.payment_status,
      'notes',          OLD.notes
    ),
    JSON_OBJECT(
      'status',         NEW.status,
      'payment_status', NEW.payment_status,
      'notes',          NEW.notes
    )
  );
END$$

CREATE TRIGGER `trg_appointments_after_insert`
AFTER INSERT ON `appointments`
FOR EACH ROW
BEGIN
  INSERT INTO `audit_logs` (`action`, `table_name`, `record_id`, `new_data`)
  VALUES (
    'INSERT',
    'appointments',
    NEW.id,
    JSON_OBJECT(
      'patient_id',       NEW.patient_id,
      'doctor_id',        NEW.doctor_id,
      'appointment_date', NEW.appointment_date,
      'appointment_time', NEW.appointment_time,
      'status',           NEW.status
    )
  );
END$$

CREATE TRIGGER `trg_appointments_after_delete`
AFTER DELETE ON `appointments`
FOR EACH ROW
BEGIN
  INSERT INTO `audit_logs` (`action`, `table_name`, `record_id`, `old_data`)
  VALUES (
    'DELETE',
    'appointments',
    OLD.id,
    JSON_OBJECT(
      'patient_id',       OLD.patient_id,
      'doctor_id',        OLD.doctor_id,
      'appointment_date', OLD.appointment_date,
      'status',           OLD.status
    )
  );
END$$

DELIMITER ;

-- ============================================================
-- SEED DATA
-- ============================================================

-- Admin user  (change password immediately after first login)
INSERT INTO `users` (`name`, `email`, `password_hash`, `role`, `phone`, `address`) VALUES
('Admin User',    'admin@ayur.com',    '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin',   '+91-9000000000', 'Ayur HQ, Bengaluru, Karnataka');

-- Doctor seed accounts  (change passwords after first login)
INSERT INTO `users` (`name`, `email`, `password_hash`, `role`, `phone`, `address`) VALUES
('Dr. Priya Sharma',   'dr.priya@ayur.com',   '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'doctor',  '+91-9111111111', 'Koramangala, Bengaluru'),
('Dr. Rahul Verma',    'dr.rahul@ayur.com',   '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'doctor',  '+91-9222222222', 'Indiranagar, Bengaluru'),
('Dr. Ananya Nair',    'dr.ananya@ayur.com',  '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'doctor',  '+91-9333333333', 'Jayanagar, Bengaluru');

-- Clinics
INSERT INTO `clinics` (`name`, `address`, `phone`, `email`, `latitude`, `longitude`, `opening_time`, `closing_time`, `image_url`, `rating`) VALUES
('Ayur Wellness Clinic',   '12 MG Road, Bengaluru, Karnataka 560001',          '+91-8011111111', 'wellness@ayur.com',  12.9716000, 77.5946000, '08:00:00', '20:00:00', 'https://example.com/clinic1.jpg', 4.50),
('City Health Centre',      '45 Residency Road, Bengaluru, Karnataka 560025',  '+91-8022222222', 'city@ayur.com',      12.9740000, 77.6000000, '09:00:00', '21:00:00', 'https://example.com/clinic2.jpg', 4.20);

-- Doctors (linked to user_id 2,3,4 and clinics 1,2,1)
INSERT INTO `doctors` (`user_id`, `specialty`, `clinic_id`, `fee`, `bio`, `experience_years`, `image_url`, `is_available`, `rating`, `latitude`, `longitude`) VALUES
(2, 'Cardiology',           1, 800.00,  'Senior cardiologist with 12 years of experience in interventional cardiology.', 12, 'https://example.com/dr_priya.jpg',  1, 4.80, 12.9716000, 77.5946000),
(3, 'Orthopedics',          2, 700.00,  'Expert orthopedic surgeon specialising in joint replacements and sports injuries.',  9, 'https://example.com/dr_rahul.jpg',  1, 4.60, 12.9740000, 77.6000000),
(4, 'General Medicine',     1, 500.00,  'Experienced general physician providing holistic primary care.',                    7, 'https://example.com/dr_ananya.jpg', 1, 4.70, 12.9716000, 77.5946000);

-- Blood inventory (all 8 groups)
INSERT INTO `blood_inventory` (`blood_group`, `quantity`) VALUES
('A+',  45),
('A-',  18),
('B+',  52),
('B-',  12),
('AB+', 23),
('AB-',  8),
('O+',  60),
('O-',  15);

-- Pharmacy products (5 products)
INSERT INTO `pharmacy_products` (`name`, `description`, `price`, `stock_quantity`, `category`, `image_url`) VALUES
('Paracetamol 500mg',    'Effective fever and pain relief tablet. Pack of 10.',     25.00,  500, 'Pain Relief',   'https://example.com/paracetamol.jpg'),
('Vitamin D3 1000 IU',   'Supports bone health and immune function. 60 capsules.',  350.00, 200, 'Vitamins',      'https://example.com/vitd3.jpg'),
('Cetirizine 10mg',      'Antihistamine for allergy relief. Pack of 10 tablets.',   45.00,  300, 'Allergy',       'https://example.com/cetirizine.jpg'),
('Omeprazole 20mg',      'Proton pump inhibitor for acidity and GERD. 14 capsules.',120.00, 150, 'Gastro',        'https://example.com/omeprazole.jpg'),
('Azithromycin 500mg',   'Broad-spectrum antibiotic. Pack of 3 tablets.',           180.00,  80, 'Antibiotics',   'https://example.com/azithromycin.jpg');
