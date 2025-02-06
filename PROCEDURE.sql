USE PEYSAZ ;
DELIMITER //
CREATE PROCEDURE Generate_Unique_Code(OUT new_code CHAR(7))
BEGIN
    DECLARE is_unique BOOLEAN DEFAULT FALSE;
    DECLARE temp_code CHAR(7);
    WHILE is_unique = FALSE DO
        -- GENERATE 7 CHAR DISCOUNT CODE
        SET temp_code = CONCAT(
            CHAR(FLOOR(RAND() * 26) + 65),  -- A-Z
            CHAR(FLOOR(RAND() * 26) + 65),
            CHAR(FLOOR(RAND() * 10) + 48),  -- 0-9
            CHAR(FLOOR(RAND() * 26) + 65),
            CHAR(FLOOR(RAND() * 26) + 65),
            CHAR(FLOOR(RAND() * 10) + 48),
            CHAR(FLOOR(RAND() * 26) + 65)
        );
        -- CHECK IF IT IS UNIQUE IN DISCOUNT_CODE 
        IF NOT EXISTS (SELECT 1 FROM PEYSAZ.DISCOUNT_CODE WHERE DCODE = temp_code) THEN
            SET is_unique = TRUE;
        END IF;
    END WHILE;
    -- RETURN CODE
    SET new_code = temp_code;
END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE PROCEDURE Generate_Referral_Discount(IN ReferrerID CHAR(10), IN Level INT)
BEGIN
    DECLARE DiscountAmount DECIMAL(10, 2);
    DECLARE DiscountCode   CHAR(7);
    DECLARE TotalDiscount  DECIMAL(10, 2); -- ؟؟؟؟ WTF

    SET DiscountAmount = 50 / POW(2, Level - 1);
    IF DiscountAmount < 1 THEN
        SET DiscountAmount = 50000;
    END IF;

    CALL GenerateUniqueCode(7, DiscountCode);
    
    IF TotalDiscount + DiscountAmount <= 1000000 THEN
        -- Insert the discount code into the DISCOUNT_CODE 
        INSERT INTO DISCOUNT_CODE (DCODE, Amount, DLimit, Usage_count, Expiration_date)
        VALUES (DiscountCode, DiscountAmount, 1, 0, DATE_ADD(CURRENT_DATE, INTERVAL 1 MONTH));

        -- Assign the discount code to the referrer
        INSERT INTO PRIVATE_CODE (DCODE, DID, DTimestamp)
        VALUES (DiscountCode, ReferrerID, CURRENT_TIMESTAMP);
    END IF;

    -- Recursive generate discount codes for the next level 
    IF EXISTS (SELECT 1 FROM REFERS WHERE Referee = ReferrerID) THEN
        CALL Generate_Referral_Discount((SELECT Referrer FROM REFERS WHERE Referee = ReferrerID), Level + 1);
    END IF;

END //

DELIMITER ;
