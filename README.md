# Music Distribution Database

A relational database for a vinyl record distribution company, built to support real operational decisions rather than just demonstrate a schema.

*Group project for MIST 4610 at UGA Terry. I led the data model design and wrote the SQL queries. The schema and queries here were reconstructed from the original ER diagram, data dictionary, and query output, since the live database ran on a university server I no longer have access to. Attribution note at the bottom.*

---

## Business context

A vinyl store runs on three things: inventory management, supplier relationships, and knowing which customers are worth keeping. This database gives management visibility into all of them, and every query was built around a decision someone would actually have to make.

---

## What it supports

Inventory alerts flag any record that drops below the 20-unit restock threshold, broken out by supplier, so you catch a shortage before it becomes a stockout instead of after.

Revenue by genre ranks genres by total revenue, which lets management stock toward demand instead of guessing. Pop led the dataset at $1,736 in total revenue, with Rock and Alternative close behind.

Employee performance gets two views. One ranks employees by revenue generated. The other identifies who's handling the most complex orders, the ones with three or more records, because those aren't always the same people.

Promotion targeting maps active promotions to records by the artist's country, which supports region-specific marketing.

Customer value ranks customers by total spend. That's the starting point for any retention or loyalty strategy.

---

## Data model

Thirteen tables. The structural problem the model had to solve: inventory and suppliers sit on one side of the business, while customers, orders, and employees sit on the other. The `orderdetail` table is the bridge, tying specific records to specific transactions.

The decisions that mattered:
- `supplier` and `record` connect many-to-many through `supplier_has_record`, because a supplier only matters if they carry what's in stock, and stock only matters if a supplier can replenish it
- `order` to `shipment` is one-to-one, since a shipment goes out once
- `employee` references itself for the management hierarchy, so you can see who reports to whom
- `promotion` references itself so holiday promotions chain off an existing base promotion instead of spawning duplicate records
- `record` and `promotion` connect many-to-many so the system validates that a discount belongs to a product before applying it
- `loyalty_program` links to both `customer` and `promotion`, which is where retention meets offer eligibility

See [`schema.sql`](schema.sql) for the full table definitions and foreign keys.

---

## Design notes

A few things I'd build differently now, and fixed in this version:

Phone numbers and postal codes were originally typed as `INT`. That's a common beginner trap: they look like numbers but they're not arithmetic, and `INT` silently drops leading zeros. They're `VARCHAR` here.

The original `employee.hiredate` was typed `DECIMAL` in the data dictionary and `DATETIME` in the diagram. A hire date is a date, so `DATETIME` it is.

The `record` table carried a `recordlabel_idrecordlabel` foreign key, but no record-label table was ever defined for it to point at. A foreign key with no target is a broken reference, so I dropped it here rather than leave it dangling. The clean fix would be to add a `record_label` table; that's noted but not built, since it wasn't in scope for the original.

Calling these out because reading a schema critically is part of the job, and these are the kinds of issues a real review would surface.

---

## Analytical queries

All five live in [`queries.sql`](queries.sql). In the original project they were stored procedures called as `CALL TP_Q1()` through `CALL TP_Q5()`; here they're plain `SELECT` statements so they read without the wrapper.

```sql
-- Query 1: records below the 20-unit restock threshold, with supplier contact
-- Query 2: total revenue by genre, descending
-- Query 3: employees ranked by revenue from orders they processed
-- Query 4: employees handling orders of 3+ records
-- Query 5: active promotions on records by artist country
```

One bug worth flagging: the original employee-revenue query threw an error because `order` is a reserved SQL keyword and needs backticks (`` `order` ``). Fixed in this version.

Each query answers a management question, not a textbook prompt.

---

## Tableau dashboards

Three visualizations complemented the SQL layer:



<img width="1472" height="436" alt="image" src="https://github.com/user-attachments/assets/b9eda19a-0954-4acd-9a10-7af6bb698d3a" />
Top 5 genres by average revenue per order, where the point is that average order value and total volume tell two different stories.



<img width="1498" height="1160" alt="image" src="https://github.com/user-attachments/assets/cff55bd5-1d7e-42d2-95ab-b2bbe0572ec9" />
Customer spend ranking by total purchase history, the starting point for picking out high-value accounts.



<img width="1336" height="874" alt="image" src="https://github.com/user-attachments/assets/76eaef4d-75ac-4e8b-a7c4-85366b91224b" />
Units sold by year. The trend line is the whole point: flat or declining sales across several years is the signal that something has to change.

---

## Attribution

Five-person group project for MIST 4610 at UGA Terry. I owned the data model design and wrote the SQL analytical queries. Teammates contributed to data population, the written report, and parts of the Tableau work. Full team: Anna Pachon, Jeremiah Doherty, Geetika Polkam, Krutee Pillay.

---

## Files

```
music-distribution-db/
├── schema.sql       # All 13 tables, keys, and relationships
├── queries.sql      # The 5 analytical queries
└── README.md
```

---

## Tools

MySQL, Tableau, SQL
