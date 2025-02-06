-- USING TA'S TABLES
CREATE SCHEMA PEYSAZ ;
CREATE TABLE PEYSAZ.PRODUCT (
ID            CHAR(9)       NOT NULL ,
Image         BLOB ,
Category      VARCHAR(20)   NOT NULL ,
Current_price DECIMAL(10,2) NOT NULL ,
Stock_count   INT           NOT NULL ,
Brand         VARCHAR(30)   NOT NULL ,
Model         VARCHAR(30)   NOT NULL ,
PRIMARY KEY(ID));
CREATE TABLE PEYSAZ.HDD (
PID        char(9)     NOT NULL ,
Rotational_speed INT   NOT NULL ,
Wattage   INT          NOT NULL ,
Capacity  INT          NOT NULL ,
Height    INT          NOT NULL ,
Width     INT          NOT NULL ,
Depth     INT          NOT NULL ,
PRIMARY KEY (PID) ,
FOREIGN KEY (PID) REFERENCES PRODUCT(ID));
CREATE TABLE PEYSAZ.PCASE (
PID       char(9)       NOT NULL ,
Number_of_fans INT      NOT NULL ,
Fan_size   INT          NOT NULL ,
Wattage    INT          NOT NULL ,
PType      VARCHAR(20)  NOT NULL ,
Material   VARCHAR(100) NOT NULL ,  
Color      VARCHAR(20)  NOT NULL ,
Height     INT          NOT NULL ,
Width      INT          NOT NULL ,
Depth      INT          NOT NULL ,
PRIMARY KEY (PID) ,
FOREIGN KEY (PID) REFERENCES PRODUCT(ID));
CREATE TABLE PEYSAZ.POWER_SUPPLY (
PID        char(9)      NOT NULL ,
Supported_wattage INT   NOT NULL ,
Height     INT          NOT NULL ,
Width      INT          NOT NULL ,
Depth      INT          NOT NULL ,
PRIMARY KEY (PID) ,
FOREIGN KEY (PID) REFERENCES PRODUCT(ID));
CREATE TABLE PEYSAZ.GPU (
PID        char(9)      NOT NULL ,
Clock_speed INT         NOT NULL ,
Ram_size    INT         NOT NULL ,
Number_of_fans INT      NOT NULL ,
Wattage    INT          NOT NULL ,
Height     INT          NOT NULL ,
Width      INT          NOT NULL ,
Depth      INT          NOT NULL ,
PRIMARY KEY (PID) ,
FOREIGN KEY (PID) REFERENCES PRODUCT(ID));
CREATE TABLE PEYSAZ.SSD (
PID       char(9)      NOT NULL ,
Wattage   INT          NOT NULL ,
Capacity  INT          NOT NULL ,
PRIMARY KEY (PID) ,
FOREIGN KEY (PID) REFERENCES PRODUCT(ID));
CREATE TABLE PEYSAZ.RAM_STICK (
PID        char(9)      NOT NULL ,
Frequency  INT          NOT NULL ,
Generation VARCHAR(50)  NOT NULL ,  
Wattage    INT          NOT NULL ,
Capacity   INT          NOT NULL ,
Height     INT          NOT NULL ,
Width      INT          NOT NULL ,
Depth      INT          NOT NULL ,
PRIMARY KEY (PID) ,
FOREIGN KEY (PID) REFERENCES PRODUCT(ID));
CREATE TABLE PEYSAZ.MOTHERBOARD (   
PID        char(9)        NOT NULL ,
Chipset    VARCHAR(100)   NOT NULL , 
Memory_speed_range    INT NOT NULL ,
Number_of_memory_slot INT NOT NULL ,
Wattage    INT            NOT NULL ,
Height     INT            NOT NULL ,
Width      INT            NOT NULL ,
Depth      INT            NOT NULL ,
PRIMARY KEY (PID) ,
FOREIGN KEY (PID) REFERENCES PRODUCT(ID));
CREATE TABLE PEYSAZ.PCPU (
PID              char(9)       NOT NULL ,
Maximum_addressable_memory_limit
					INT        NOT NULL ,
Boost_frequency     INT        NOT NULL ,
Base_frequency      INT        NOT NULL ,
Number_of_cores     INT        NOT NULL ,
Number_of_Threads   INT        NOT NULL ,
Microarchitecture VARCHAR(15)  NOT NULL ,
Generation        VARCHAR(50)  NOT NULL ,  
Wattage             INT        NOT NULL ,
PRIMARY KEY (PID) ,
FOREIGN KEY (PID) REFERENCES PRODUCT(ID));
CREATE TABLE PEYSAZ.COOLER (
PID              char(9)       NOT NULL ,
Maximum_rotational_speed INT   NOT NULL ,
Fan_size         INT           NOT NULL ,
Cooling_method   VARCHAR(6)    NOT NULL ,
Wattage          INT           NOT NULL ,
Height           INT           NOT NULL ,
Width            INT           NOT NULL ,
Depth            INT           NOT NULL ,
PRIMARY KEY (PID) ,
FOREIGN KEY (PID) REFERENCES PRODUCT(ID));
CREATE TABLE PEYSAZ.CONNECTOR_COMPATIBLE_WITH (
GPU_ID       char(9)       NOT NULL ,
Power_ID     char(9)       NOT NULL ,
PRIMARY KEY (GPU_ID , Power_ID) ,
FOREIGN KEY (GPU_ID) REFERENCES GPU(PID) ,
FOREIGN KEY (Power_ID) REFERENCES POWER_SUPPLY(PID));
CREATE TABLE PEYSAZ.SM_SLOT_COMPATIBLE_WITH (
SSD_ID             char(9)       NOT NULL ,
Motherboard_ID     char(9)       NOT NULL ,
PRIMARY KEY (SSD_ID , Motherboard_ID) ,
FOREIGN KEY (SSD_ID) REFERENCES SSD(PID) ,
FOREIGN KEY (Motherboard_ID) REFERENCES MOTHERBOARD(PID));
CREATE TABLE PEYSAZ.RM_SLOT_COMPATIBLE_WITH (
RAM_ID             char(9)       NOT NULL ,
Motherboard_ID     char(9)       NOT NULL ,
PRIMARY KEY (RAM_ID , Motherboard_ID) ,
FOREIGN KEY (RAM_ID) REFERENCES RAM_STICK(PID) ,
FOREIGN KEY (Motherboard_ID) REFERENCES MOTHERBOARD(PID));
CREATE TABLE PEYSAZ.CC_SOCKET_COMPATIBLE_WITH (
CPU_ID       char(9)       NOT NULL ,
Cooler_ID     char(9)       NOT NULL ,
PRIMARY KEY (CPU_ID , Cooler_ID) ,
FOREIGN KEY (CPU_ID) REFERENCES PCPU(PID) ,
FOREIGN KEY (Cooler_ID) REFERENCES COOLER(PID));
CREATE TABLE PEYSAZ.MC_SOCKET_COMPATIBLE_WITH (
CPU_ID             char(9)       NOT NULL ,
Motherboard_ID     char(9)       NOT NULL ,
PRIMARY KEY (CPU_ID , Motherboard_ID) ,
FOREIGN KEY (CPU_ID) REFERENCES PCPU(PID) ,
FOREIGN KEY (Motherboard_ID) REFERENCES MOTHERBOARD(PID));
CREATE TABLE PEYSAZ.GM_SLOT_COMPATIBLE_WITH (
GPU_ID             char(9)       NOT NULL ,
Motherboard_ID     char(9)       NOT NULL ,
PRIMARY KEY (GPU_ID , Motherboard_ID) ,
FOREIGN KEY (GPU_ID) REFERENCES GPU(PID) ,
FOREIGN KEY (Motherboard_ID) REFERENCES MOTHERBOARD(PID));
CREATE TABLE PEYSAZ.COSTUMER (
ID             CHAR(10)     NOT NULL ,
Phone_number   VARCHAR(20)  NOT NULL ,
First_name     VARCHAR(15)  NOT NULL ,
Last_name      VARCHAR(15)  NOT NULL ,
Wallet_balance DECIMAL(10,2)   NOT NULL ,
CTimestamp  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
Referral_code  CHAR(6) ,       
PRIMARY KEY (ID),
UNIQUE (Phone_number));
CREATE TABLE PEYSAZ.SHOPPING_CART (
CID      CHAR(10)    NOT NULL,
CNumber  INT         NOT NULL,
Cstatus   ENUM('active', 'blocked', 'locked') DEFAULT 'active',-- R check
PRIMARY KEY (CID, CNumber),
UNIQUE (CNumber),
FOREIGN KEY (CID) REFERENCES COSTUMER(ID));
CREATE TABLE PEYSAZ.LOCKED_SHOPPING_CART (
LCID        CHAR(10)  NOT NULL,
Cart_number INT       NOT NULL,
CNumber     INT       NOT NULL,
CTimestamp  DATETIME DEFAULT CURRENT_TIMESTAMP,  -- R TIMESTAMP?
PRIMARY KEY (LCID, Cart_number, CNumber),
FOREIGN KEY (LCID, Cart_number) REFERENCES SHOPPING_CART(CID, CNumber));
CREATE TABLE PEYSAZ.ADDED_TO (
LCID            CHAR(10)      NOT NULL ,
Cart_number     INT           NOT NULL ,
Locked_Number   INT           NOT NULL ,
Product_ID      CHAR(9)       NOT NULL ,
Quantity        INT ,
Cart_price      DECIMAL(10,2) NOT NULL ,
PRIMARY KEY (LCID, Cart_number, Locked_Number , Product_ID) ,
FOREIGN KEY (LCID, Cart_number, Locked_Number) REFERENCES LOCKED_SHOPPING_CART(LCID, Cart_number, CNumber) ,
FOREIGN KEY (Product_ID) REFERENCES PRODUCT(ID));
CREATE TABLE PEYSAZ.VIP_CLIENTS (
VID             CHAR(10)               NOT NULL ,
Subscription_expiration_time DATETIME  NOT NULL , 
PRIMARY KEY (VID) ,
FOREIGN KEY (VID) REFERENCES COSTUMER(ID));
CREATE TABLE PEYSAZ.TRANSACTIONS (
Tracking_code      VARCHAR(20)   NOT NULL,
transaction_status ENUM ('successful', 'partially_successful', 'unsuccessful') DEFAULT 'unsuccessful',  -- R CHECK
TTimestamp         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (Tracking_code));
CREATE TABLE PEYSAZ.BANK_TRANSACTION (
BTracking_code  VARCHAR(20)   NOT NULL ,
Card_number     CHAR(12)      NOT NULL , -- INT constraint
PRIMARY KEY (BTracking_code) ,
FOREIGN KEY (BTracking_code) REFERENCES TRANSACTIONS(Tracking_code));
CREATE TABLE PEYSAZ.WALLET_TRANSACTION (
WTracking_code  VARCHAR(20)   NOT NULL ,
PRIMARY KEY (WTracking_code) ,
FOREIGN KEY (WTracking_code) REFERENCES TRANSACTIONS(Tracking_code));
CREATE TABLE PEYSAZ.SUBSCRIBES (
SID             CHAR(10)      NOT NULL ,
STracking_code  VARCHAR(20)   NOT NULL ,
PRIMARY KEY (STracking_code) ,
FOREIGN KEY (SID) REFERENCES COSTUMER(ID) ,
FOREIGN KEY (STracking_code) REFERENCES TRANSACTIONS(Tracking_code));
CREATE TABLE PEYSAZ.ADDRESS (
AID         CHAR(10)         NOT NULL ,
Province    VARCHAR(10)      NOT NULL ,
Remainder   VARCHAR(100) ,
PRIMARY KEY (AID , Province , Remainder) ,
FOREIGN KEY (AID) REFERENCES COSTUMER(ID));
CREATE TABLE PEYSAZ.DEPOSITS_INTO_WALLET (
DID              CHAR(10)      NOT NULL ,
DTracking_code  VARCHAR(20)   NOT NULL ,
Amount           DECIMAL(10,2) ,
PRIMARY KEY (DTracking_code) ,
FOREIGN KEY (DID) REFERENCES COSTUMER(ID) ,
FOREIGN KEY (DTracking_code) REFERENCES TRANSACTIONS(Tracking_code));
CREATE TABLE PEYSAZ.ISSUED_FOR (
ITracking_code   VARCHAR(20)   NOT NULL ,  -- char?
IID              CHAR(10)      NOT NULL ,
ICart_number     INT           NOT NULL ,
ILocked_Number   INT           NOT NULL ,
PRIMARY KEY (ITracking_code) ,
FOREIGN KEY (ITracking_code) REFERENCES TRANSACTIONS(Tracking_code) ,
FOREIGN KEY (IID, ICart_number, ILocked_Number) REFERENCES LOCKED_SHOPPING_CART(LCID, Cart_number, CNumber));
CREATE TABLE PEYSAZ.DISCOUNT_CODE (
DCODE         CHAR(7)     NOT NULL ,
Amount        INT     NOT NULL , -- CHECK
DLimit        INT     NOT NULL ,
Usage_count   INT     NOT NULL ,
Expiration_date       DATETIME ,
PRIMARY KEY (DCODE));
CREATE TABLE PEYSAZ.PRIVATE_CODE (
DCODE   CHAR(7)     NOT NULL ,
DID     CHAR(10)      NOT NULL ,
DTimestamp            DATETIME ,
PRIMARY KEY (DCODE) ,
FOREIGN KEY (DID) REFERENCES COSTUMER(ID) ,
FOREIGN KEY (DCODE) REFERENCES DISCOUNT_CODE(DCODE));
CREATE TABLE PEYSAZ.REFERS (
Referee     CHAR(10)     NOT NULL ,
Referrer    CHAR(10)     NOT NULL ,
PRIMARY KEY (Referee) ,
FOREIGN KEY (Referee)  REFERENCES COSTUMER(ID)  ON DELETE CASCADE ,
FOREIGN KEY (Referrer) REFERENCES COSTUMER(ID)  ON DELETE CASCADE);
CREATE TABLE PEYSAZ.APPLIED_TO (
LCID            CHAR(10)      NOT NULL ,
Cart_number     INT           NOT NULL ,
Locked_Number   INT           NOT NULL ,
ACODE          VARCHAR(7)     NOT NULL ,
ATimestamp     DATETIME ,
PRIMARY KEY (LCID, Cart_number, Locked_Number , ACODE) ,
FOREIGN KEY (LCID, Cart_number, Locked_Number) REFERENCES LOCKED_SHOPPING_CART(LCID, Cart_number, CNumber) ,
FOREIGN KEY (ACODE) REFERENCES DISCOUNT_CODE(DCODE));

