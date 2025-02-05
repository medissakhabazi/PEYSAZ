USE PEYSAZ ;
ALTER TABLE PEYSAZ.LOCKED_SHOPPING_CART -- TO AVOID DIRECT CHANGING LOCKED SHOPPINT CART.
ADD CONSTRAINT chk_locked_cart 
CHECK (CNumber IS NOT NULL);
-- ==========================================================================================================
DELIMITER //
CREATE TRIGGER prevent_adding_to_blocked_cart
BEFORE INSERT ON PEYSAZ.ADDED_TO
FOR EACH ROW
BEGIN
    DECLARE cart_status ENUM('active', 'blocked', 'locked');

    -- CHECK THE STATUS
    SELECT Cstatus INTO cart_status
    FROM PEYSAZ.SHOPPING_CART
    WHERE CID = NEW.LCID AND CNumber = NEW.Cart_number;

    IF cart_status = 'blocked' AND cart_status = 'locked' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'سبد خرید مسدود شده است و امکان افزودن محصول به آن وجود ندارد.';
    END IF;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE TRIGGER prevent_checkout_blocked_cart
BEFORE INSERT ON PEYSAZ.ISSUED_FOR
FOR EACH ROW
BEGIN
    DECLARE cart_status ENUM('active', 'blocked', 'locked');
    SELECT Cstatus INTO cart_status
    FROM PEYSAZ.SHOPPING_CART
    WHERE CID = NEW.IID AND CNumber = NEW.ICart_number;

    -- AVOID TRANSACTION
    IF cart_status = 'blocked' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'این سبد خرید مسدود شده است و امکان نهایی کردن سفارش وجود ندارد.';
    END IF;
END;
//
DELIMITER ;
-- ==========================================================================================================

DELIMITER //
CREATE TRIGGER prevent_discount_on_blocked_cart
BEFORE INSERT ON PEYSAZ.APPLIED_TO
FOR EACH ROW
BEGIN
    DECLARE cart_status ENUM('active', 'blocked', 'locked');
    -- STATUS
    SELECT Cstatus INTO cart_status
    FROM PEYSAZ.SHOPPING_CART
    WHERE CID = NEW.LCID AND CNumber = NEW.Cart_number;

    -- AVOID ADDING DISCOUNT CODE
    IF cart_status = 'blocked' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'سبد خرید مسدود شده است و امکان اعمال تخفیف روی آن وجود ندارد.';
    END IF;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE TRIGGER update_stock_after_adding_to_cart
AFTER INSERT ON PEYSAZ.ADDED_TO
FOR EACH ROW
BEGIN
    DECLARE current_stock INT;

    --  NUMBER OF PROCUCTS
    SELECT Stock_count INTO current_stock
    FROM PEYSAZ.PRODUCT
    WHERE ID = NEW.Product_ID;

    -- DECREASE NUMBER OF PRODUCTS
    IF current_stock >= NEW.Quantity THEN
        UPDATE PEYSAZ.PRODUCT
        SET Stock_count = Stock_count - NEW.Quantity
        WHERE ID = NEW.Product_ID;
    ELSE
        -- PRODUCT DOES NOT EXIST 
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'موجودی کافی برای افزودن به سبد خرید وجود ندارد.';
    END IF;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE TRIGGER prevent_expired_discount
BEFORE INSERT ON PEYSAZ.APPLIED_TO
FOR EACH ROW
BEGIN
    DECLARE expiration_date DATETIME;
    SELECT Expiration_date INTO expiration_date
    FROM PEYSAZ.DISCOUNT_CODE
    WHERE DCODE = NEW.ACODE;

    -- IS EXPIRED OR NOT
    IF expiration_date IS NOT NULL AND expiration_date < NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'این کد تخفیف منقضی شده است و قابل استفاده نیست.';
    END IF;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE TRIGGER prevent_exceeding_discount_limit
BEFORE INSERT ON PEYSAZ.APPLIED_TO
FOR EACH ROW
BEGIN
    DECLARE current_usage INT;
    DECLARE max_use INT;
    -- MAX USE
    SELECT Usage_count INTO max_use
    FROM PEYSAZ.DISCOUNT_CODE
    WHERE DCODE = NEW.ACODE;

    -- HOW MANY USED BEFORE
    SELECT COUNT(*) INTO current_usage
    FROM PEYSAZ.APPLIED_TO
    WHERE ACODE = NEW.ACODE;

    -- IS IT FINISHED OR NOT
    IF current_usage >= max_use THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'این کد تخفیف به حداکثر تعداد دفعات استفاده خود رسیده است و دیگر قابل استفاده نیست.';
    END IF;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE TRIGGER after_successful_transaction
AFTER INSERT ON PEYSAZ.TRANSACTIONS -- UPDATE
FOR EACH ROW
BEGIN
	DECLARE cart_cid CHAR(10);
	DECLARE cart_number INT;
    IF  NEW.transaction_status = 'successful' THEN
    
     --  finding which cart is 
	SELECT IIC , ICart_number INTO cart_cid , cart_number
	FROM PEYSAZ.ISSUED_FOR
	WHERE ITracking_code = NEW.Tracking_code;
    
	UPDATE PEYSAZ.SHOPPING_CART
	SET status = 'active'
	WHERE CID = cart_cid AND CNumber = cart_number;
    END IF;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE TRIGGER limit_shopping_cart_for_regular_and_vip_costumer
BEFORE INSERT ON PEYSAZ.SHOPPING_CART
FOR EACH ROW
BEGIN
    DECLARE user_type INT;
    DECLARE cart_count INT;
    
    -- CHECK IF IS VIP OR NOT
    SELECT COUNT(*) INTO user_type
    FROM PEYSAZ.VIP_CLIENTS
    WHERE VID = NEW.CID;
    
    -- COUNTING NUMBER OF CARTS FOR EACH ID
    SELECT COUNT(*) INTO cart_count
    FROM PEYSAZ.SHOPPING_CART
    WHERE CID = NEW.CID;
    
    -- REGULARE CONSTRAINT
    IF user_type = 0 AND cart_count >= 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'کاربران عادی فقط می‌توانند یک سبد خرید داشته باشند.';
    END IF;
    
    -- VIP CONSTRAINT 
    IF user_type > 0 AND cart_count >= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'کاربران ویژه فقط می‌توانند پنج سبد خرید داشته باشند.';
    END IF;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE TRIGGER enforce_discount_limit 
BEFORE INSERT ON PEYSAZ.APPLIED_TO
FOR EACH ROW
BEGIN
    DECLARE discount_amount INT;
    DECLARE discount_limit INT;
    DECLARE total_price DECIMAL(10,2);
    DECLARE discount_type ENUM('percentage', 'fixed');
    DECLARE applied_discount DECIMAL(10,2);

    -- FIND DISCOUNT AMOUNT AND THE LIMIT OF THEM
    SELECT Amount, DLimit INTO discount_amount, discount_limit
    FROM PEYSAZ.DISCOUNT_CODE 
    WHERE DCODE = NEW.ACODE;

    -- TOTAL PRICE OF THE CART
    SELECT  SUM(Cart_price * Quantity) INTO total_price -- Quantity ?
    FROM PEYSAZ.ADDED_TO
    WHERE LCID = NEW.LCID AND Cart_number = NEW.Cart_number AND Locked_Number = NEW.Locked_Number;

    -- DETECT TYPE OF DISCOUNT
    IF discount_amount <= 100 THEN
        SET discount_type = 'percentage';
        SET applied_discount = (total_price * discount_amount / 100);
    ELSE
        SET discount_type = 'fixed';
        SET applied_discount = discount_amount;
    END IF;

    -- CHECK THE LIMIT OF DISCOUNT
    IF applied_discount > discount_limit THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Discount exceeds allowed limit';
    END IF;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE TRIGGER discount_code_difference
AFTER INSERT ON PEYSAZ.COSTUMER
FOR EACH ROW
BEGIN
    DECLARE referrer_id CHAR(10);
    DECLARE discount_amount DECIMAL(5,2);
    DECLARE discount_level INT DEFAULT 1;
    DECLARE discount_code VARCHAR(7);
    DECLARE discount_limit DECIMAL(10,2);
    DECLARE discount_expiration DATETIME;
    DECLARE current_referrer_id CHAR(10);


    SET referrer_id = NEW.Referral_code;
    IF referrer_id IS NOT NULL THEN
        WHILE referrer_id IS NOT NULL DO
            SET discount_amount = 50.00 / POW(2, discount_level - 1);
             SET discount_limit = 1000000; 
            IF discount_amount < 1 THEN
                SET discount_amount = 50000;
            END IF;

            SET discount_expiration = NOW() + INTERVAL 7 DAY;  -- no idea ??

            INSERT INTO PEYSAZ.DISCOUNT_CODE (DCODE, Amount, DLimit, Usage_count, Expiration_date)
            VALUES (Referral_code, discount_amount, discount_limit, 0, discount_expiration); -- 0 is okay?? need to be check

            SELECT Referrer INTO current_referrer_id
            FROM PEYSAZ.REFERS
            WHERE Referee = referrer_id;
            SET referrer_id = current_referrer_id;
            SET discount_level = discount_level + 1;
        END WHILE;

    END IF;
END ;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE TRIGGER subscriber_to_VIP
AFTER INSERT ON PEYSAZ.SUBSCRIBES
FOR EACH ROW
BEGIN
	DECLARE expiration DATETIME;
    SET expiration = NOW() + INTERVAL 1 MONTH;
    INSERT INTO PEYSAZ.VIP_CLIENT (VID , Subscription_expiration_time)
    VALUE(NEW.SID , expiration);
    UPDATE PEYSAZ.VIP_CLIENT
    SET Subscription_expiration_time = expiration;
    
    -- need event for return back

END;
//
DELIMITER;
-- ================================================
-- -----------------------------------------------
DELIMITER //
CREATE TRIGGER charge_digital_wallet
AFTER INSERT ON  PEYSAZ.DEPOSITS_INTO_WALLET
FOR EACH ROW
BEGIN
	UPDATE PEYSAZ.COSTUMER
    SET Wallet_balance = NEW.Amount
    WHERE ID = NEW.DID;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //
CREATE TRIGGER decrease_digital_wallet_subscribe
AFTER INSERT ON PEYSAZ.SUBSCRIBES
FOR EACH ROW
BEGIN
    DECLARE sub_price DECIMAL(10,2);
    SET sub_price = 9999.99; -- price??
    UPDATE PEYSAZ.COSTUMER
    SET Wallet_balance = Wallet_balance - sub_price
    WHERE ID = NEW.SID;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //
CREATE TRIGGER decrease_digital_wallet_cart
AFTER INSERT ON PEYSAZ.ISSUED_FOR
FOR EACH ROW
BEGIN
    DECLARE price DECIMAL(10,2);
    SELECT SUM (Quantity * Cart_price) INTO price
    FROM PEYSAZ.ADDED_TO
    WHERE Cart_number = NEW.ICart_number AND LCID = NEW.IID AND Locked_Number = NEW.ILocked_Number;
    UPDATE PEYSAZ.COSTUMER
    SET Wallet_balance = Wallet_balance - price
    WHERE ID = NEW.IID;
END; 
// 
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE TRIGGER Return_To_Wallet_After_Transaction
AFTER INSERT ON TRANSACTIONS
FOR EACH ROW
BEGIN
	DECLARE customer_id CHAR(10);
	DECLARE transaction_amount DECIMAL(10, 2);
	DECLARE is_vip INT;
    -- CHECK THE TRANSACTION
    IF NEW.transaction_status = 'successful' THEN

        -- FIND COSTUMER IN ISSUED_FOR
        SELECT IID INTO customer_id
        FROM  ISSUED_FOR
        WHERE ITracking_code = NEW.Tracking_code
        LIMIT 1;

        -- CHECK IS VIP OR NOT 
        SELECT COUNT(*) INTO is_vip
        FROM  VIP_CLIENTS
        WHERE VID = customer_id;

        -- IF VIP ADD 15% IN WALLET
        IF is_vip > 0 THEN
            -- TOTAL PRICE
            SELECT SUM(Quantity * Cart_price)
            INTO  transaction_amount
            FROM  ADDED_TO
            WHERE LCID = customer_id;
            UPDATE COSTUMER
            SET Wallet_balance = Wallet_balance + (transaction_amount * 0.15)
            WHERE ID = customer_id;
        END IF;
    END IF;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

-- BLOCKING EXTRA CARTS 
CREATE TRIGGER Block_Additional_Carts_On_VIP_Expiration
AFTER UPDATE ON VIP_CLIENTS
FOR EACH ROW
BEGIN
    -- CHECK IF EXPIRE 
    IF NEW.Subscription_expiration_time <= CURRENT_TIMESTAMP THEN
        -- BLOCK ALL CARTS EXEPT NUMBER 1
        UPDATE SHOPPING_CART
        SET status = 'blocked'
        WHERE CID = NEW.VID
          AND CNumber != 1
          AND status != 'locked'; 
    END IF;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE TRIGGER Block_Locked_Cart_After_Purchase
AFTER UPDATE ON LOCKED_SHOPPING_CART
FOR EACH ROW
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM ADDED_TO
        WHERE LCID = NEW.LCID
          AND Cart_number = NEW.Cart_number
          AND Locked_Number = NEW.CNumber
    ) THEN
        UPDATE SHOPPING_CART
        SET status = 'blocked'
        WHERE CID = NEW.LCID
          AND CNumber = NEW.Cart_number;
    END IF;
END;
//
DELIMITER ;

