-- =============================================================
-- Music Distribution Database — Analytical Queries
-- Five business questions, each tied to a management decision.
-- In the original project these were stored procedures (CALL TP_QX()).
-- Written here as plain SELECT statements so they're readable
-- =============================================================


-- -------------------------------------------------------------
-- Query 1 — Low stock alert
-- Question: Which records have dropped below the restock threshold of 20 units, and who supplies them?
-- Decision: restock proactively instead of waiting for zero.
-- -------------------------------------------------------------
SELECT
    r.title          AS RecordTitle,
    r.stockquantity  AS CurrentStock,
    s.suppliername   AS SupplierName,
    s.contactperson  AS SupplierContact,
    s.phonenumber    AS SupplierPhone
FROM record r
JOIN supplier_has_record sr ON r.idrecord = sr.record_idrecord
JOIN supplier s             ON sr.supplier_idsupplier = s.idsupplier
WHERE r.stockquantity < 20
ORDER BY r.stockquantity ASC;


-- -------------------------------------------------------------
-- Query 2 — Revenue by genre
-- Question: Which genres generate the most revenue?
-- Decision: stock and market toward proven demand.
-- -------------------------------------------------------------
SELECT
    g.genrename,
    SUM(od.quantity * od.MSRP) AS total_revenue
FROM genre g
JOIN record r       ON g.idgenre = r.genre_idgenre
JOIN orderdetail od ON r.idrecord = od.record_idrecord
GROUP BY g.idgenre, g.genrename
ORDER BY total_revenue DESC;


-- -------------------------------------------------------------
-- Query 3 — Employee revenue ranking
-- Question: Which employees generate the most revenue from the orders they process?
-- Decision: recognize top performers; surface who to support.
-- -------------------------------------------------------------
SELECT
    e.firstname,
    e.lastname,
    SUM(od.quantity * od.MSRP) AS total_revenue
FROM employee e
JOIN `order` o      ON e.idemployee = o.employee_idemployee
JOIN orderdetail od ON o.idorder = od.order_idorder
GROUP BY e.idemployee, e.firstname, e.lastname
ORDER BY total_revenue DESC;


-- -------------------------------------------------------------
-- Query 4 — Employees handling large orders
-- Question: Which employees processed shipments tied to orders containing at least three records?
-- Decision: spot who handles complex orders; balance workload.
-- -------------------------------------------------------------
SELECT DISTINCT
    e.firstname,
    e.lastname,
    o.idorder,
    SUM(od.quantity) AS total_records_in_order
FROM employee e
JOIN `order` o      ON e.idemployee = o.employee_idemployee
JOIN shipment sh    ON o.shipment_idshipment = sh.idshipment
JOIN orderdetail od ON o.idorder = od.order_idorder
GROUP BY e.idemployee, e.firstname, e.lastname, o.idorder
HAVING SUM(od.quantity) >= 3
ORDER BY total_records_in_order DESC;


-- -------------------------------------------------------------
-- Query 5 — Promotions by artist country
-- Question: Which active promotions apply to records by artists from a given country?
-- Decision: tailor marketing to regional / domestic talent.
-- -------------------------------------------------------------
SELECT
    a.artistname,
    a.country,
    r.title              AS RecordTitle,
    p.promotiondescription,
    p.discountpercentage
FROM promotion p
JOIN promotion_has_record pr ON p.idpromotion = pr.promotion_idpromotion
JOIN record r                ON pr.record_idrecord = r.idrecord
JOIN artist a                ON r.artist_idartist = a.idartist
WHERE a.country = 'USA'
ORDER BY p.discountpercentage DESC;
