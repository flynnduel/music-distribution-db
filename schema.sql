-- =============================================================
-- Music Distribution Database — Schema
-- Relational database for a vinyl record distribution company
-- Originally built on MySQL (MIST 4610, UGA Terry)
-- Reconstructed from the original ER diagram and data dictionary
-- =============================================================

CREATE TABLE artist (
    idartist     INT          NOT NULL AUTO_INCREMENT,
    artistname   VARCHAR(45),
    country      VARCHAR(300),
    bio          VARCHAR(300),
    PRIMARY KEY (idartist)
);

CREATE TABLE genre (
    idgenre      INT          NOT NULL AUTO_INCREMENT,
    genrename    VARCHAR(200),
    PRIMARY KEY (idgenre)
);

CREATE TABLE inventory (
    idinventory     INT       NOT NULL AUTO_INCREMENT,
    quantityinstock INT,
    reorderlevel    INT,
    PRIMARY KEY (idinventory)
);

CREATE TABLE customer (
    idcustomer   INT          NOT NULL AUTO_INCREMENT,
    firstname    VARCHAR(45),
    lastname     VARCHAR(45),
    email        VARCHAR(200),
    phone_number VARCHAR(20),          
    address      VARCHAR(300),
    city         VARCHAR(100),
    state        VARCHAR(100),
    postalcode   VARCHAR(10),          
    PRIMARY KEY (idcustomer)
);

CREATE TABLE supplier (
    idsupplier    INT         NOT NULL AUTO_INCREMENT,
    suppliername  VARCHAR(45),
    contactperson VARCHAR(45),
    phonenumber   VARCHAR(20),         
    address       VARCHAR(300),
    city          VARCHAR(300),
    state         VARCHAR(200),
    postalcode    VARCHAR(10),
    PRIMARY KEY (idsupplier)
);

-- Employee references itself for the reporting (boss) hierarchy

CREATE TABLE employee (
    idemployee           INT          NOT NULL AUTO_INCREMENT,
    firstname            VARCHAR(45),
    lastname             VARCHAR(45),
    position             VARCHAR(45),
    hiredate             DATETIME,           
    salary               DECIMAL(10,2),
    employee_idemployee  INT,                 -- self-referencing FK: this employee's boss
    PRIMARY KEY (idemployee),
    FOREIGN KEY (employee_idemployee) REFERENCES employee (idemployee)
);

-- Record sits at the center of the product side of the business

CREATE TABLE record (
    idrecord       INT          NOT NULL AUTO_INCREMENT,
    title          VARCHAR(250),
    release_year   INT,
    MSRP           DECIMAL(10,2),
    stockquantity  INT,
    artist_idartist INT         NOT NULL,
    genre_idgenre  INT          NOT NULL,
    PRIMARY KEY (idrecord),
    FOREIGN KEY (artist_idartist) REFERENCES artist (idartist),
    FOREIGN KEY (genre_idgenre)   REFERENCES genre (idgenre)
);

-- Shipment is the one-to-one partner of an order

CREATE TABLE shipment (
    idshipment      INT          NOT NULL AUTO_INCREMENT,
    shipped_date    DATETIME,
    shippingaddress VARCHAR(300),
    city            VARCHAR(200),
    state           VARCHAR(200),
    postalcode      VARCHAR(10),
    shippingcost    DECIMAL(10,2),
    PRIMARY KEY (idshipment)
);

-- Promotion references itself for chained holiday promotions

CREATE TABLE promotion (
    idpromotion          INT          NOT NULL AUTO_INCREMENT,
    promotiondescription VARCHAR(300),
    discountpercentage   INT,
    startdate            DATETIME,
    enddate              DATETIME,
    related_promotion    INT,                 -- self-referencing FK: links a holiday promo to its base promo
    PRIMARY KEY (idpromotion),
    FOREIGN KEY (related_promotion) REFERENCES promotion (idpromotion)
);

-- Order ties together customer, employee, and shipment (financial side)

CREATE TABLE `order` (
    idorder              INT          NOT NULL AUTO_INCREMENT,
    orderdate            DATETIME,
    totalamount          DECIMAL(10,2),
    paymentmethod        VARCHAR(45),
    orderstatus          VARCHAR(45),
    customer_idcustomer  INT          NOT NULL,
    shipment_idshipment  INT          NOT NULL,
    employee_idemployee  INT          NOT NULL,
    PRIMARY KEY (idorder),
    FOREIGN KEY (customer_idcustomer) REFERENCES customer (idcustomer),
    FOREIGN KEY (shipment_idshipment) REFERENCES shipment (idshipment),
    FOREIGN KEY (employee_idemployee) REFERENCES employee (idemployee)
);

-- Order detail: the line items linking an order to specific records

CREATE TABLE orderdetail (
    idorderdetail   INT          NOT NULL AUTO_INCREMENT,
    quantity        INT,
    MSRP            DECIMAL(10,2),
    order_idorder   INT          NOT NULL,
    record_idrecord INT          NOT NULL,
    PRIMARY KEY (idorderdetail),
    FOREIGN KEY (order_idorder)   REFERENCES `order` (idorder),
    FOREIGN KEY (record_idrecord) REFERENCES record (idrecord)
);

-- Loyalty program: one per customer, tied to a promotion

CREATE TABLE loyalty_program (
    customer_idcustomer   INT         NOT NULL,
    points                INT,
    start_date            DATETIME,
    promotion_idpromotion INT         NOT NULL,
    PRIMARY KEY (customer_idcustomer),
    FOREIGN KEY (customer_idcustomer)   REFERENCES customer (idcustomer),
    FOREIGN KEY (promotion_idpromotion) REFERENCES promotion (idpromotion)
);

-- Junction tables for the two many-to-many relationships

CREATE TABLE supplier_has_record (
    supplier_idsupplier  INT          NOT NULL,
    record_idrecord      INT          NOT NULL,
    inventory_idinventory INT         NOT NULL,
    unitprice            DECIMAL(10,2),
    PRIMARY KEY (supplier_idsupplier, record_idrecord, inventory_idinventory),
    FOREIGN KEY (supplier_idsupplier)   REFERENCES supplier (idsupplier),
    FOREIGN KEY (record_idrecord)       REFERENCES record (idrecord),
    FOREIGN KEY (inventory_idinventory) REFERENCES inventory (idinventory)
);

CREATE TABLE promotion_has_record (
    promotion_idpromotion INT         NOT NULL,
    record_idrecord       INT         NOT NULL,
    PRIMARY KEY (promotion_idpromotion, record_idrecord),
    FOREIGN KEY (promotion_idpromotion) REFERENCES promotion (idpromotion),
    FOREIGN KEY (record_idrecord)       REFERENCES record (idrecord)
);

