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

