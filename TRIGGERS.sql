USE PEYSAZ ;
ALTER TABLE PEYSAZ.LOCKED_SHOPPING_CART -- TO AVOID DIRECT CHANGING LOCKED SHOPPINT CART.
ADD CONSTRAINT chk_locked_cart 
CHECK (CNumber IS NOT NULL);

DELIMITER //
CREATE TRIGGER prevent_adding_to_locked_cart
BEFORE INSERT ON PEYSAZ.ADDED_TO
FOR EACH ROW
BEGIN
    DECLARE is_locked INT;

    -- IS IT BLOCKED OR NOT
    SELECT COUNT(*) INTO is_locked 
    FROM PEYSAZ.LOCKED_SHOPPING_CART 
    WHERE LCID = NEW.LCID AND Cart_number = NEW.Cart_number AND CNumber = NEW.Locked_Number;
    -- IF BLOCKED THEN STOP
    IF is_locked > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'سبد خرید مسدود شده است و امکان افزودن آیتم جدید وجود ندارد.';
    END IF;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER prevent_transaction_on_locked_cart
BEFORE INSERT ON PEYSAZ.ISSUED_FOR
FOR EACH ROW
BEGIN
    DECLARE is_locked INT;

    -- CHECK THE STATUS OF CART
    SELECT COUNT(*) INTO is_locked 
    FROM PEYSAZ.LOCKED_SHOPPING_CART 
    WHERE LCID = NEW.IID AND Cart_number = NEW.ICart_number AND CNumber = NEW.ILocked_Number;

    -- IF IT BLOCKED NO TRANSACTION ALLOW
    IF is_locked > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'سبد خرید مسدود شده است و امکان ثبت تراکنش وجود ندارد.';
    END IF;
END;
//
DELIMITER ;

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

DELIMITER //

CREATE TRIGGER prevent_exceeding_discount_limit
BEFORE INSERT ON PEYSAZ.APPLIED_TO
FOR EACH ROW
BEGIN
    DECLARE max_usage INT;
    DECLARE current_usage INT;

    -- MAX USE
    SELECT DLimit INTO max_usage
    FROM PEYSAZ.DISCOUNT_CODE
    WHERE DCODE = NEW.ACODE;

    -- HOW MANY USED BEFORE
    SELECT COUNT(*) INTO current_usage
    FROM PEYSAZ.APPLIED_TO
    WHERE ACODE = NEW.ACODE;

    -- IS IT FINISHED OR NOT
    IF current_usage >= max_usage THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'این کد تخفیف به حداکثر تعداد دفعات استفاده خود رسیده است و دیگر قابل استفاده نیست.';
    END IF;
END;
//
DELIMITER ;

