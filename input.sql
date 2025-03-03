USE peysaz;

INSERT INTO COSTUMER (First_name, Last_name, ID, Phone_number, Wallet_balance, Referral_code, CTimestamp) VALUES
('John', 'Doe', 1, '1234567890', 2000, 'REF1', '2025-01-01'),
('Jane', 'Smith', 2, '0987654321', 2000, 'REF2', '2025-01-02'),
('Bob', 'Brown', 3, '1231231234', 1500, 'REF3', '2025-01-03'),
('Alice', 'Green', 4, '3213214321', 3000, 'REF4', '2025-01-04'),
('Tom', 'Hanks', 5, '4564564567', 500, 'REF5', '2025-01-05'),
('Emma', 'Stone', 6, '7897897890', 2500, 'REF6', '2025-01-06'),
('Chris', 'Evans', 7, '1472583690', 3500, 'REF7', '2025-01-07'),
('Scarlett', 'Johansson', 8, '9638527410', 4000, 'REF8', '2025-01-08'),
('Robert', 'Downey', 9, '2583691470', 4500, 'REF9', '2025-01-09'),
('Jennifer', 'Lawrence', 10, '3692581470', 6000, 'REF10', '2025-01-10');

INSERT INTO REFERS (Referee, Referrer)
VALUES 
(2, 1), 
(3, 1),  
(4, 2),  
(5, 2);  

-- Insert ADDRESS data
INSERT INTO ADDRESS (AID, Province, Remainder) VALUES
(1, 'Province1', 'Address1'),
(2, 'Province2', 'Address2'),
(3, 'Province3', 'Address3'),
(4, 'Province4', 'Address4'),
(5, 'Province5', 'Address5'),
(6, 'Province6', 'Address6'),
(7, 'Province7', 'Address7'),
(8, 'Province8', 'Address8'),
(9, 'Province9', 'Address9'),
(10, 'Province10', 'Address10');
 
INSERT INTO TRANSACTIONS (Tracking_code, transaction_status, TTimestamp) VALUES
(1001, 'unsuccessful', '2025-02-15'),
(1002, 'successful', '2025-01-10'),
(1003, 'successful', '2025-02-15'),
(1004, 'unsuccessful', '2024-05-30'),
(1005, 'successful', '2025-01-20'),
(1006, 'partially_successful', '2025-03-01'),
(1007, 'partially_successful', '2025-12-15'),
(1008, 'successful', '2025-02-24'),
(1009, 'unsuccessful', '2024-06-30'),
(1010, 'successful', '2024-01-12');

-- Insert BANK_TRANSACTION data
INSERT INTO BANK_TRANSACTION (BTracking_code, Card_number) VALUES
(1001, '1111222233'),
(1002, '5555666677'),
(1003, '9999000011'),
(1004, '3333444455'),
(1005, '7777888899');

-- Insert WALLET_TRANSACTION data
INSERT INTO WALLET_TRANSACTION (WTracking_code) VALUES
(1006),
(1007),
(1008),
(1009),
(1010);

-- Insert SUBSCRIBES data
INSERT INTO SUBSCRIBES (STracking_code, SID) VALUES
(1001, 1),
(1002, 2),
(1003, 3),
(1004, 4),
(1005, 5);

-- Insert DEPOSITS_INTO_WALLET data
INSERT INTO DEPOSITS_INTO_WALLET (DTracking_code, DID, Amount) VALUES
(1006, 6, 500),
(1007, 7, 700),
(1008, 8, 300),
(1009, 9, 1000),
(1010, 10, 1200);

-- Insert VIP_CLIENTS data
INSERT INTO VIP_CLIENTS (VID, Subscription_expiration_time) VALUES
(1, '2025-12-31'),
(2, '2025-11-30'),
(3, '2025-10-31');

-- Insert SHOPPING_CART data
INSERT INTO SHOPPING_CART (CID, CNumber, Cstatus) VALUES
(1, 1, 'blocked'),
(1, 2, 'blocked'),
(1, 3, 'blocked'),
(1, 4, 'blocked'),
(1, 5, 'blocked'),

(2, 1, 'blocked'),
(2, 2, 'blocked'),
(2, 3, 'active'),
(2, 4, 'active'),
(2, 5, 'locked'),

(3, 1, 'blocked'),
(3, 2, 'locked'),
(3, 3, 'blocked'),
(3, 4, 'active'),
(3, 5, 'active'),

(4, 4, 'active'),
(5, 5, 'active');

-- Insert DISCOUNT_CODE data
INSERT INTO DISCOUNT_CODE (DCODE, Amount, DLimit, Usage_count, Expiration_date) VALUES
(101, 10, 100, 5, '2025-12-31'),
(102, 20, 50, 2, '2025-11-30'),
(103, 15, 80, 3, '2025-10-31'),
(104, 5, 30, 1, '2025-09-30'),
(105, 25, 60, 4, '2025-08-31'),
(106, 500, 10, 5, '2026-08-31');

-- Insert PRIVATE_CODE data
INSERT INTO PRIVATE_CODE (DCODE, DID, DTimestamp) VALUES
(101, 1, '2025-02-27 10:00:00'),
(102, 2, '2025-03-16 11:00:00'),
(103, 3, '2025-04-17 12:00:00'),
(104, 1, '2025-03-01 13:00:00'),
(105, 5, '2025-02-19 14:00:00');



-- Insert LOCKED_SHOPPING_CART data
INSERT INTO LOCKED_SHOPPING_CART (LCID, Cart_number, CNumber, CTimestamp) VALUES
(1, 1, 1, '2025-01-20 12:00:00'),
(2, 2, 2, '2025-01-21 13:00:00'),
(3, 3, 3, '2025-01-22 14:00:00'),
(4, 4, 4, '2025-01-23 15:00:00'),
(5, 5, 5, '2025-01-24 16:00:00');

-- Insert ISSUED_FOR data
INSERT INTO ISSUED_FOR (ITracking_code, IID, ICart_number, ILocked_number) VALUES
(1001, 1, 1, 1),
(1006, 1, 1, 1),
(1008, 1, 1, 1),
(1002, 2, 2, 2),
(1003, 3, 3, 3),
(1004, 4, 4, 4),
(1005, 5, 5, 5);


INSERT INTO PEYSAZ.PRODUCT (ID, Category,Image, Current_price, Stock_count, Brand, Model) VALUES
(1,'GPU', null , 499.99, 10, 'NVIDIA', 'RTX 3070'),
(2,'GPU', null , 699.99, 5, 'AMD', 'RX 6800'),
(3,'CPU', null , 299.99, 15, 'Intel', 'i7-12700K'),
(4,'CPU', null ,199.99, 20, 'AMD', 'Ryzen 5 5600X'),
(5,'Motherboard', null , 149.99, 25, 'ASUS', 'B550-F'),
(6,'Motherboard', null , 199.99, 10, 'MSI', 'Z690 PRO'),
(7,'RAM', null , 79.99, 30, 'Corsair', 'Vengeance LPX 16GB'),
(8,'RAM', null , 89.99, 25, 'G.Skill', 'Trident Z 16GB'),
(9,'SSD', null ,99.99, 50, 'Samsung', '970 EVO 1TB'),
(10,'Power Supply', null , 129.99, 15, 'Corsair', 'RM750'),
(11,'Cooler', null , 59.99, 40, 'Noctua', 'NH-D15');


-- Insert ADDED_TO data
INSERT INTO ADDED_TO (LCID, Cart_number, Locked_number, Product_ID, Quantity, Cart_price) VALUES
(1, 1, 1, 1, 2, 1000),
(2, 2, 2, 2, 3, 900),
(3, 3, 3, 3, 1, 700),
(4, 4, 4, 4, 1, 1000),
(5, 5, 5, 5, 2, 100);

INSERT INTO APPLIED_TO (LCID, Cart_number, Locked_number, ACODE, ATimestamp) VALUES 
(1, 1, 1, 101, NOW()),
(1, 1, 1, 106, NOW()),
(1, 1, 1, 105, NOW());



INSERT INTO PEYSAZ.COOLER (PID, Maximum_rotational_speed, Fan_size, Cooling_method, Wattage, Height, Width, Depth) VALUES
(11, 1500, 140, 'Air', 8, 165, 150, 135);

INSERT INTO PEYSAZ.POWER_SUPPLY (PID, Supported_wattage, Height, Width, Depth) VALUES
(10, 750, 86, 150, 140);

INSERT INTO PEYSAZ.SSD (PID, Wattage, Capacity) VALUES
(9, 5, 1000);
INSERT INTO PEYSAZ.RAM_STICK (PID, Frequency, Generation, Wattage, Capacity, Height, Width, Depth) VALUES
(7, 3200, 'DDR4', 10, 16, 5, 133, 34),
(8, 3600, 'DDR4', 12, 16, 5, 133, 34);

INSERT INTO PEYSAZ.MOTHERBOARD (PID, Chipset, Memory_speed_range, Number_of_memory_slot, Wattage, Height, Width, Depth) VALUES
(5, 'B550', 3200, 4, 75, 30, 244, 244),
(6, 'Z690', 4800, 4, 85, 30, 244, 244);

INSERT INTO PEYSAZ.PCPU (PID, Maximum_addressable_memory_limit, Boost_frequency, Base_frequency, Number_of_cores, Number_of_Threads, Microarchitecture, Generation, Wattage) VALUES
(3, 128, 5000, 3600, 12, 24, 'Alder Lake', '12th Gen', 125),
(4, 64, 4600, 3700, 6, 12, 'Zen 3', '5000 Series', 65);

INSERT INTO PEYSAZ.GPU (PID, Clock_speed, Ram_size, Number_of_fans, Wattage, Height, Width, Depth) VALUES
(1, 1800, 8, 2, 220, 50, 120, 250),
(2, 1700, 16, 3, 250, 55, 125, 260);


INSERT INTO PEYSAZ.CONNECTOR_COMPATIBLE_WITH (GPU_ID, Power_ID) VALUES
(1, 10), -- RTX 3070 ↔️ RM750
(2, 10); -- RX 6800 ↔️ RM750

INSERT INTO PEYSAZ.SM_SLOT_COMPATIBLE_WITH (SSD_ID, Motherboard_ID) VALUES
(9, 5),  -- 970 EVO ↔️ B550-F
(9, 6);  -- 970 EVO ↔️ Z690 PRO

INSERT INTO PEYSAZ.RM_SLOT_COMPATIBLE_WITH (RAM_ID, Motherboard_ID) VALUES
(7, 5),  -- Vengeance LPX ↔️ B550-F
(8, 6);  -- Trident Z ↔️ Z690 PRO

INSERT INTO PEYSAZ.MC_SOCKET_COMPATIBLE_WITH (CPU_ID, Motherboard_ID) VALUES
(3, 6),  -- i7-12700K ↔️ Z690 PRO
(4, 5);  -- Ryzen 5 5600X ↔️ B550-F

INSERT INTO PEYSAZ.CC_SOCKET_COMPATIBLE_WITH (CPU_ID, Cooler_ID) VALUES
(3, 11),  -- i7-12700K ↔️ NH-D15
(4, 11);  -- Ryzen 5 5600X ↔️ NH-D15