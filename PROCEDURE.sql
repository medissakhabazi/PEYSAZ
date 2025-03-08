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
    DECLARE Discount_type  ENUM('percentage', 'fixed');
  
  
	SET DiscountAmount = 50 / POW(2, Level - 1);
    IF DiscountAmount < 1 THEN
        SET DiscountAmount = 50000;
    END IF;
		
        CALL Generate_Unique_Code(DiscountCode); 
    
		-- Insert the discount code into the DISCOUNT_CODE 
			INSERT INTO DISCOUNT_CODE (DCODE, Amount, DLimit, Usage_count, Expiration_date)
			VALUES (DiscountCode, DiscountAmount, 1000000, 0, DATE_ADD(CURRENT_DATE, INTERVAL 1 WEEK));

        -- Assign the discount code to the referrer
			INSERT INTO PRIVATE_CODE (DCODE, DID, DTimestamp)
			VALUES (DiscountCode, ReferrerID, CURRENT_TIMESTAMP);

    -- Recursive generate discount codes for the next level 
    IF EXISTS (SELECT 1 FROM REFERS WHERE Referee = ReferrerID) THEN
        CALL Generate_Referral_Discount((SELECT Referrer FROM REFERS WHERE Referee = ReferrerID), Level + 1);
    END IF;

END ;
//
DELIMITER ;
-- =============================================================================================================
DELIMITER //

CREATE PROCEDURE Determine_Discount_Type(IN discount_amount INT, OUT discount_type ENUM('percentage', 'fixed'))
BEGIN
    IF discount_amount <= 100 THEN
        SET discount_type = 'percentage';
    ELSE
        SET discount_type = 'fixed';
    END IF;
END ; 
//
DELIMITER ;

-- =======================================================================================================================
DELIMITER //

CREATE PROCEDURE cart_price (IN user_id INTEGER, IN shopping_cart_number INTEGER, IN locked_cart_number INTEGER, OUT final BIGINT)
BEGIN
    DECLARE total_price BIGINT;
    DECLARE final_price BIGINT;
    DECLARE discount_amount DECIMAL;
    DECLARE discount_limit INTEGER;
    DECLARE current_code INTEGER;
    DECLARE endloop TINYINT DEFAULT FALSE;
    DECLARE discount_type ENUM('percentage', 'fixed'); -- ?????????

    DECLARE code_list CURSOR FOR  
        SELECT ACODE 
        FROM APPLIED_TO AS apllied
        WHERE user_id = apllied.LCID AND shopping_cart_number = apllied.Cart_number AND locked_cart_number = apllied.Locked_Number 
        ORDER BY apllied.ATimestamp; 
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET endloop = TRUE;
 
    SELECT SUM(cart_price * Quantity) 
    INTO total_price 
    FROM ADDED_TO
    WHERE user_id = LCID AND locked_cart_number = Locked_Number AND shopping_cart_number = Cart_number;

    SET final_price = total_price; 
    

    OPEN code_list;
    process_discounts:
    LOOP
        FETCH NEXT FROM code_list INTO current_code;
        IF endloop THEN 
            LEAVE process_discounts;
        END IF;

        SELECT discode.Amount, discode.DLimit
        INTO discount_amount, discount_limit 
        FROM DISCOUNT_CODE AS discode
        WHERE current_code = discode.DCODE;
        
		 CALL Determine_Discount_Type(discount_amount, discount_type);
        
        IF discount_type = 'percentage' THEN
			IF ((total_price * discount_amount / 100) > discount_limit) THEN
				SET final_price = final_price - discount_limit; 
			ELSE
				SET final_price = final_price - (final_price * discount_amount / 100);
			END IF;
		ELSE 
			SET final_price = final_price - discount_amount;

		END IF;
    END LOOP;
    CLOSE code_list;
    
    SET final = final_price;
END ;
//
DELIMITER ;