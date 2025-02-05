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
        WHERE CTimestamp < NOW() - INTERVAL 7 DAY
    );
    -- UPDATE THE FREE TIME FOR LOCKED_SHOPPING_CART
    UPDATE PEYSAZ.LOCKED_SHOPPING_CART
    SET CTimestamp = NOW()
    WHERE CTimestamp < NOW() - INTERVAL 7 DAY;
END;
//
DELIMITER ;
-- ===========================================================================
DELIMITER //

CREATE EVENT expire_vip_subscription
ON SCHEDULE EVERY 1 MINUTE
DO
BEGIN
    -- CHECK IF EXPIRE 
    DELETE FROM PEYSAZ.VIP_CLIENTS
    WHERE NEW.Subscription_expiration_time <= CURRENT_TIMESTAMP;
END ;
//
DELIMITER ;
