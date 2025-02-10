USE PEYSAZ ;
SET GLOBAL event_scheduler = ON ;
DELIMITER //
CREATE EVENT cancel_and_block_unpaid_carts
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    UPDATE PEYSAZ.PRODUCT P
    JOIN PEYSAZ.ADDED_TO A ON P.ID = A.Product_ID
    JOIN PEYSAZ.LOCKED_SHOPPING_CART L ON A.LCID = L.LCID AND A.Cart_number = L.Cart_number AND A.Locked_Number = L.CNumber
    LEFT JOIN PEYSAZ.ISSUED_FOR I ON L.LCID = I.IID AND L.Cart_number = I.ICart_number AND L.CNumber = I.ILocked_Number
    LEFT JOIN PEYSAZ.TRANSACTIONS T ON I.ITracking_code = T.Tracking_code
    -- REVEAL THE PRODUCTS 
    SET P.Stock_count = P.Stock_count + A.Quantity
    -- CHECK ALL THE CARTS AND IF IT IS NOT SUCCESSFULL LOCKED FOR MORE THAN 3 DAYS THEN 
    WHERE L.CTimestamp < NOW() - INTERVAL 3 DAY
    AND (T.transaction_status IS NULL OR T.transaction_status != 'successful');

    -- BLOCKED THE CARTS
    UPDATE PEYSAZ.SHOPPING_CART S
    JOIN PEYSAZ.LOCKED_SHOPPING_CART L ON S.CID = L.LCID AND S.CNumber = L.Cart_number
    LEFT JOIN PEYSAZ.ISSUED_FOR I ON L.LCID = I.IID AND L.Cart_number = I.ICart_number AND L.CNumber = I.ILocked_Number
    LEFT JOIN PEYSAZ.TRANSACTIONS T ON I.ITracking_code = T.Tracking_code
    SET S.status = 'blocked'
    WHERE L.CTimestamp < NOW() - INTERVAL 3 DAY
    AND (T.transaction_status IS NULL OR T.transaction_status != 'successful');

    -- UPDATE THE BLOCKED TIME FOR LOCKED_SHOPPING_CART
    UPDATE PEYSAZ.LOCKED_SHOPPING_CART
    SET CTimestamp = NOW()
    WHERE CTimestamp < NOW() - INTERVAL 3 DAY;

END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE EVENT unblock_carts_after_7_days
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    -- MAKE FREE THE BLOCKED SHOPPING CARD
    UPDATE PEYSAZ.SHOPPING_CART
    SET Cstatus = 'active'
    WHERE Cstatus = 'blocked' AND CNumber IN (
        SELECT Cart_number 
        FROM PEYSAZ.LOCKED_SHOPPING_CART
        WHERE CTimestamp < NOW() - INTERVAL 7 DAY AND LCID IN (
        SELECT VID
        FROM PEYSAZ.VIP_CLIENTS 
        )
    );
    -- UPDATE THE FREE TIME FOR LOCKED_SHOPPING_CART
    UPDATE PEYSAZ.LOCKED_SHOPPING_CART
    SET CTimestamp = NOW()
    WHERE CTimestamp < NOW() - INTERVAL 7 DAY;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE EVENT expire_vip_subscription
ON SCHEDULE EVERY 1 MINUTE
DO
BEGIN
    -- CHECK IF EXPIRE 
    DELETE FROM PEYSAZ.VIP_CLIENTS
    WHERE  Subscription_expiration_time <= CURRENT_TIMESTAMP;
END ;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE EVENT Monthly_VIP_Wallet_Return
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    DECLARE vid CHAR(10);
    DECLARE cnumber     INT;
    DECLARE clnumber   INT;
    DECLARE total_spent DECIMAL(10,2) DEFAULT 0;
    DECLARE spent_for_cart DECIMAL(10,2) DEFAULT 0;
    DECLARE done BOOLEAN DEFAULT FALSE;

    DECLARE cur CURSOR FOR 
        SELECT VID 
        FROM VIP_CLIENTS 
        WHERE Subscription_expiration_time >= CURRENT_TIMESTAMP;

    DECLARE cur2 CURSOR FOR
        SELECT Cart_number, Locked_Number
        FROM APPLIED_TO JOIN ISSUED_FOR ON LCID = IID AND ICart_number = Cart_number AND ILocked_Number = Locked_Number
        WHERE LCID = vid AND ITracking_code IN (
            SELECT Tracking_code 
            FROM TRANSACTIONS
            WHERE transaction_status = 'successful'
            AND TTimestamp >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 MONTH)
          );
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    OPEN cur;


    read_loop: LOOP
        FETCH cur INTO vid;
        IF done THEN
            LEAVE read_loop;
        END IF;
        OPEN cur2;

        numbers_loop: LOOP
            FETCH cur2 INTO cnumber, clnumber;
            IF done THEN
                LEAVE numbers_loop;
            END IF;
            SET spent_for_cart = 0;

            CALL cart_price(vid, cnumber, clnumber, spent_for_cart);
            SET total_spent = total_spent + spent_for_cart;
        END LOOP;
        CLOSE cur2;
        SET done = FALSE;

        UPDATE COSTUMER
        SET Wallet_balance = Wallet_balance + (total_spent* 0.15)
        WHERE ID = vid;

        SET total_spent = 0;
    END LOOP;
    CLOSE cur;
END;
//
DELIMITER ;
