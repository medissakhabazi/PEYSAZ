USE PEYSAZ ;

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
    DECLARE total_spent DECIMAL(10,2);
    DECLARE done INT DEFAULT 0;
    DECLARE cur CURSOR FOR 
        SELECT VID 
        FROM VIP_CLIENTS 
        WHERE Subscription_expiration_time >= CURRENT_TIMESTAMP;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO vid;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- CALCULATE COST IN A MONTH
        SELECT SUM(A.Cart_price* 0.15) 
        INTO total_spent
        FROM ISSUED_FOR AS I
        JOIN LOCKED_SHOPPING_CART AS L
            ON I.IID = L.LCID AND I.ICart_number = L.Cart_number
        JOIN ADDED_TO AS A
            ON L.LCID = A.LCID AND L.Cart_number = A.Cart_number AND L.CNumber = A.Locked_Number
        WHERE I.IID = vid
          AND I.ITracking_code IN (
              SELECT Tracking_code 
              FROM TRANSACTIONS
              WHERE transaction_status = 'successful'
                AND TTimestamp >= DATE_SUB(CURRENT_TIMESTAMP, INTERVAL 1 MONTH)
          );

        -- ADD 15% OF EACH CART PRICE IN ONE MONTH
        IF total_spent IS NOT NULL THEN
            UPDATE COSTUMER
            SET Wallet_balance = Wallet_balance + total_spent
            WHERE ID = vid;
        END IF;
    END LOOP;
    CLOSE cur;
END;
//
DELIMITER ;
