USE northwind;

SET @orders_to_insert = 100000;

SET @customer_count = GREATEST(1, (SELECT COUNT(*) FROM customers));
SET @employee_count = GREATEST(1, (SELECT COUNT(*) FROM employees));
SET @shipper_count = GREATEST(1, (SELECT COUNT(*) FROM shippers));
SET @product_count = GREATEST(1, (SELECT COUNT(*) FROM products));
SET @country_count = GREATEST(1, (SELECT COUNT(*) FROM countries));

SET @orders_count_before = (SELECT COUNT(*) FROM orders);
SET @order_details_count_before = (SELECT COUNT(*) FROM order_details);

-- Capture the current max order_id so order_details can reference the new rows by offset
SET @base_order_id = (SELECT COALESCE(MAX(order_id), 0) FROM orders);

-- ── Orders ────────────────────────────────────────────────────────────────────

INSERT INTO orders
(
  `customer_id`,
  `employee_id`,
  `order_date`,
  `required_date`,
  `shipped_date`,
  `ship_via`,
  `freight`,
  `ship_name`,
  `ship_address`,
  `ship_city`,
  `ship_region`,
  `ship_postal_code`,
  `ship_country`
)
WITH digits AS (
    SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
),
-- 6 digit tables => 1,000,000 raw combinations (was 8 tables = 100,000,000 for a
-- 100,000-row target, i.e. 99.9% wasted rows). Filtered down to @orders_to_insert
-- in `numbers` below. Need more than 1,000,000? Add one more digits CROSS JOIN
-- and a `+ dN.d * 1000000` term.
raw_numbers AS (
    SELECT
        d0.d
      + d1.d * 10
      + d2.d * 100
      + d3.d * 1000
      + d4.d * 10000
      + d5.d * 100000
      + 1 AS n
    FROM digits d0
        CROSS JOIN digits d1
        CROSS JOIN digits d2
        CROSS JOIN digits d3
        CROSS JOIN digits d4
        CROSS JOIN digits d5
),
numbers AS (
    SELECT n FROM raw_numbers WHERE n <= @orders_to_insert
),
customer_ids (customer_id, rn) AS (
    SELECT customer_id, ROW_NUMBER() OVER (ORDER BY customer_id) AS rn
    FROM customers
),
employee_ids (employee_id, rn) AS (
    SELECT employee_id, ROW_NUMBER() OVER (ORDER BY employee_id) AS rn
    FROM employees
),
shipper_ids (shipper_id, rn) AS (
    SELECT shipper_id, ROW_NUMBER() OVER (ORDER BY shipper_id) AS rn
    FROM shippers
),
country_codes (country_code, rn) AS (
    SELECT country_code, ROW_NUMBER() OVER (ORDER BY country_code) AS rn
    FROM countries
),
company_names (id, name) AS (
    SELECT 1, 'Northwind'   UNION ALL
    SELECT 2, 'Harbor'      UNION ALL
    SELECT 3, 'Atlas'       UNION ALL
    SELECT 4, 'Summit'      UNION ALL
    SELECT 5, 'Blue River'  UNION ALL
    SELECT 6, 'Sunline'     UNION ALL
    SELECT 7, 'Metro'       UNION ALL
    SELECT 8, 'Evergreen'   UNION ALL
    SELECT 9, 'North Star'  UNION ALL
    SELECT 10, 'Peak'
),
street_names (id, name) AS (
    SELECT 1, 'Oak'        UNION ALL
    SELECT 2, 'Maple'      UNION ALL
    SELECT 3, 'Cedar'      UNION ALL
    SELECT 4, 'Pine'       UNION ALL
    SELECT 5, 'Elm'        UNION ALL
    SELECT 6, 'Washington' UNION ALL
    SELECT 7, 'Park'       UNION ALL
    SELECT 8, 'Lake'       UNION ALL
    SELECT 9, 'Hill'       UNION ALL
    SELECT 10, 'River'
),
street_types (id, name) AS (
    SELECT 1, 'Ave' UNION ALL SELECT 2, 'Blvd' UNION ALL SELECT 3, 'St' UNION ALL
    SELECT 4, 'Dr' UNION ALL SELECT 5, 'Rd' UNION ALL SELECT 6, 'Ln'
),
cities (id, name) AS (
    SELECT 1, 'Springfield' UNION ALL SELECT 2, 'Franklin' UNION ALL SELECT 3, 'Madison' UNION ALL
    SELECT 4, 'Clinton' UNION ALL SELECT 5, 'Salem' UNION ALL SELECT 6, 'Dover' UNION ALL
    SELECT 7, 'Auburn' UNION ALL SELECT 8, 'Bristol' UNION ALL SELECT 9, 'Oxford' UNION ALL
    SELECT 10, 'Arlington'
),
regions (id, name) AS (
    SELECT 1, 'California' UNION ALL SELECT 2, 'Texas' UNION ALL SELECT 3, 'Florida' UNION ALL
    SELECT 4, 'New York' UNION ALL SELECT 5, 'Illinois' UNION ALL SELECT 6, 'Ohio' UNION ALL
    SELECT 7, 'Georgia' UNION ALL SELECT 8, 'Michigan' UNION ALL SELECT 9, 'Arizona' UNION ALL
    SELECT 10, 'Virginia'
),
-- order_date computed once per n instead of being re-evaluated 3x inline
dated AS (
    SELECT n, DATE_ADD('2019-01-01', INTERVAL MOD(n * 31, 2500) DAY) AS order_date
    FROM numbers
)
SELECT
    c.customer_id,
    e.employee_id,
    dt.order_date,
    DATE_ADD(dt.order_date, INTERVAL 10 + MOD(dt.n * 37, 15) DAY),
    DATE_ADD(dt.order_date, INTERVAL 1 + MOD(dt.n * 41, 9) DAY),
    s.shipper_id,
    ROUND(5 + MOD(dt.n * 43, 90000) / 100, 4),
    CONCAT(
        ELT(MOD(dt.n - 1, 10) + 1, 'Northwind', 'Harbor', 'Atlas', 'Summit', 'Blue River',
                                'Sunline', 'Metro', 'Evergreen', 'North Star', 'Peak'),
        ' ',
        ELT(MOD(dt.n - 1, 5) + 1, 'Logistics', 'Freight', 'Carriers', 'Supply', 'Transit')
    ),
    CONCAT(
        FLOOR(1 + MOD(dt.n * 47, 9999)),
        ' ',
        sn.name,
        ' ',
        st.name
    ),
    cty.name,
    reg.name,
    LPAD(10000 + MOD(dt.n * 53, 90000), 5, '0'),
    cc.country_code
FROM dated dt
JOIN customer_ids c
    ON c.rn = MOD(dt.n - 1, @customer_count) + 1
JOIN employee_ids e
    ON e.rn = MOD(dt.n - 1, @employee_count) + 1
JOIN shipper_ids s
    ON s.rn = MOD(dt.n - 1, @shipper_count) + 1
JOIN country_codes cc
    ON cc.rn = MOD(dt.n - 1, @country_count) + 1
JOIN street_names sn
    ON sn.id = MOD(dt.n - 1, 10) + 1
JOIN street_types st
    ON st.id = MOD(dt.n - 1, 6) + 1
JOIN cities cty
    ON cty.id = MOD(dt.n - 1, 10) + 1
JOIN regions reg
    ON reg.id = MOD(dt.n - 1, 10) + 1;

SELECT ROW_COUNT() AS inserted_orders;


-- ── Order Details ──────────────────────────────────────────────────────────────
-- Every order gets 2 to 4 lines (line_no <= 2 + MOD(n,3), minimum is always 2).
-- Product offset is (line_no - 1) = 0..3, so within one order, distinct line_nos
-- always map to distinct products as long as the catalog has >= 4 products.
-- That removes intra-order PK collisions, so no order can silently end up with
-- 0 rows because INSERT IGNORE ate all of its lines. IGNORE is kept only as a
-- defensive fallback for very small catalogs (< 4 products).

INSERT IGNORE INTO order_details (`order_id`, `product_id`, `unit_price`, `quantity`, `discount`)
WITH digits AS (
    SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
),
product_ids (product_id, rn) AS (
    SELECT product_id, ROW_NUMBER() OVER (ORDER BY product_id) AS rn
    FROM products
),
line_items (line_no) AS (
    SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
),
raw_numbers AS (
    SELECT
        d0.d
      + d1.d * 10
      + d2.d * 100
      + d3.d * 1000
      + d4.d * 10000
      + d5.d * 100000
      + 1 AS n
    FROM digits d0 CROSS JOIN digits d1 CROSS JOIN digits d2 CROSS JOIN digits d3
         CROSS JOIN digits d4 CROSS JOIN digits d5
),
numbers AS (
    SELECT n FROM raw_numbers WHERE n <= @orders_to_insert
)
SELECT
    @base_order_id + n,
    prod.product_id,
    ROUND(1 + MOD(n * 97 + li.line_no * 13, 50000) / 100, 4),
    1 + MOD(n * 101 + li.line_no * 7, 40),
    ELT(li.line_no, 0.000, 0.050, 0.100, 0.150)
FROM numbers
JOIN line_items li
    ON li.line_no <= 2 + MOD(n, 3)
JOIN product_ids prod
    ON prod.rn = MOD((n - 1) * 17 + (li.line_no - 1), @product_count) + 1;

SET @order_count_after = (SELECT COUNT(*) FROM orders);
SET @order_details_count_after = (SELECT COUNT(*) FROM order_details);

SELECT
    @order_count_after - @orders_count_before AS orders_total,
    @order_details_count_after - @order_details_count_before AS order_details_total,
    (
        -- Sanity check: any newly-inserted order with zero order_details? Should be 0.
        SELECT COUNT(*) AS orders_missing_details
        FROM orders o
        LEFT JOIN order_details od ON od.order_id = o.order_id
        WHERE o.order_id > @base_order_id
            AND od.order_id IS NULL
    ) AS orders_missing_details;
