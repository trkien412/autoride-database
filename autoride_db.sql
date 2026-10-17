-- AUTORIDE: database schema migration and workflow simulation
-- MySQL 8.0+
-- The ALTER TABLE migration below is intended for the supplied legacy schema.
-- Run it once on an existing legacy database.

CREATE DATABASE IF NOT EXISTS autoride_db;
USE autoride_db;

-- Legacy tables: these CREATE statements support a fresh database.
CREATE TABLE IF NOT EXISTS Cars (
    car_id INT AUTO_INCREMENT PRIMARY KEY,
    model_name VARCHAR(100) NOT NULL,
    license_plate VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS Rentals (
    rental_id INT AUTO_INCREMENT PRIMARY KEY,
    car_id INT,
    customer_name VARCHAR(100) NOT NULL,
    rent_date DATETIME NOT NULL,
    return_date DATETIME NULL,
    status VARCHAR(50) DEFAULT 'BOOKED',
    CONSTRAINT fk_rentals_car
        FOREIGN KEY (car_id) REFERENCES Cars(car_id)
);

-- MIGRATION: replace legacy status and add financial fields.
-- Execute this ALTER only once against the original legacy Rentals table.
ALTER TABLE Rentals
    MODIFY COLUMN status ENUM('BOOKED', 'ACTIVE', 'COMPLETED', 'CANCELLED')
        NOT NULL DEFAULT 'BOOKED',
    ADD COLUMN security_deposit DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ADD COLUMN late_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    ADD COLUMN damage_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00;

-- A rental may have multiple inspections (e.g. check-out and check-in).
CREATE TABLE IF NOT EXISTS Inspections (
    inspection_id INT AUTO_INCREMENT PRIMARY KEY,
    rental_id INT NOT NULL,
    inspection_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    damage_description TEXT NOT NULL,
    inspector_name VARCHAR(100) NOT NULL,
    CONSTRAINT fk_inspections_rental
        FOREIGN KEY (rental_id) REFERENCES Rentals(rental_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- Demo scenario: Nguyen Van A rents a car and pays a 10,000,000 VND deposit.
INSERT INTO Cars (model_name, license_plate)
VALUES ('Toyota Vios', '30A-12345')
ON DUPLICATE KEY UPDATE model_name = VALUES(model_name);

SET @demo_car_id = (
    SELECT car_id FROM Cars WHERE license_plate = '30A-12345' LIMIT 1
);

INSERT INTO Rentals (
    car_id, customer_name, rent_date, status,
    security_deposit, late_fee, damage_fee
)
VALUES (
    @demo_car_id, 'Nguyen Van A', '2026-10-17 08:00:00', 'ACTIVE',
    10000000.00, 0.00, 0.00
);

SET @demo_rental_id = LAST_INSERT_ID();

-- Vehicle returned; inspection finds a broken left headlight.
INSERT INTO Inspections (
    rental_id, inspection_date, damage_description, inspector_name
)
VALUES (
    @demo_rental_id, '2026-10-19 08:00:00',
    'Vo den pha trai', 'Tran Van B'
);

UPDATE Rentals
SET status = 'COMPLETED',
    return_date = '2026-10-19 08:00:00',
    late_fee = 0.00,
    damage_fee = 2000000.00
WHERE rental_id = @demo_rental_id;

-- Check the recorded inspection and refund amount.
SELECT r.rental_id, r.customer_name, r.status,
       r.security_deposit, r.late_fee, r.damage_fee,
       (r.security_deposit - r.late_fee - r.damage_fee) AS refund_amount,
       i.damage_description, i.inspector_name, i.inspection_date
FROM Rentals AS r
LEFT JOIN Inspections AS i ON i.rental_id = r.rental_id
WHERE r.rental_id = @demo_rental_id;

-- Optional database safeguard:
-- Prevent inspections before the rental is ACTIVE or after it is CANCELLED.
-- This trigger is created after the demo INSERT above.
DROP TRIGGER IF EXISTS trg_inspection_rental_active;
DELIMITER $$
CREATE TRIGGER trg_inspection_rental_active
BEFORE INSERT ON Inspections
FOR EACH ROW
BEGIN
    DECLARE rental_status VARCHAR(20);
    SELECT status INTO rental_status
    FROM Rentals
    WHERE rental_id = NEW.rental_id;

    IF rental_status IS NULL OR rental_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Chi duoc kiem tra xe khi hop dong dang ACTIVE';
    END IF;
END$$
DELIMITER ;

-- Trigger test: try inserting an inspection for a BOOKED or COMPLETED rental.
-- The database should reject the insert.
