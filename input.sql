use PEYSAZ;
INSERT INTO PEYSAZ.COSTUMER (Phone_number, First_name, Last_name, Wallet_balance, Referral_code)
VALUES  
('1234567890', 'Ali', 'Reza', 500.00, 'ABC123'),
('9876543210', 'Sara', 'Mohammadi', 1200.50, NULL),
('5678901234', 'Hassan', 'Karimi', 350.75, 'XYZ789'),
('4567890123', 'Mina', 'Taheri', 800.00, 'LMN456'),
('3456789012', 'Amir', 'Rahmani', 50.25, NULL),
('2345678901', 'Fatemeh', 'Shahbazi', 620.90, 'PQR234'),
('8765432109', 'Reza', 'Azimi', 999.99, NULL),
('7654321098', 'Leila', 'Farsi', 1500.00, 'GHJ678'),
('6543210987', 'Kian', 'Jafari', 75.30, NULL),
('5432109876', 'Elham', 'Nasiri', 200.40, 'TUV345');



INSERT INTO PEYSAZ.VIP_CLIENTS (VID, Subscription_expiration_time)
VALUES 
(1, '2025-12-31 23:59:59'),  -- Ali
(2, '2024-06-15 12:00:00'),  -- Sara
(4, '2026-01-01 00:00:00'),  -- Mina
(6, '2025-08-20 18:30:00'),  -- Fatemeh
(8, '2024-11-10 09:45:00'),  -- Leila
(10, '2026-07-05 14:00:00'), -- Elham
(3, '2025-05-22 17:15:00'),  -- Hassan
(5, '2024-09-30 23:59:59'),  -- Amir
(7, '2026-03-10 06:20:00'),  -- Reza
(9, '2024-12-25 20:00:00');  -- Kian