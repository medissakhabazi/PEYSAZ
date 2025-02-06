USE PEYSAZ ;
DELIMITER //
CREATE VIEW guest_view_product AS
SELECT ID, Image, Category, Current_price, Stock_count, Brand, Model
FROM  PEYSAZ.PRODUCT
WHERE Stock_count > 0;

END;
//
DELIMITER ;
-- ==========================================================================================================
DELIMITER //

CREATE VIEW unblocked_view_carts AS
SELECT CID,CNumber
FROM  PEYSAZ.SHOPPING_CART
WHERE Cstatus !='blocked';

END;
//
DELIMITER ;