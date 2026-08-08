USE northwind;

SET @records_to_insert = 100000;

SET @country_count = GREATEST(1, (SELECT COUNT(*) FROM countries));
SET @customer_count_before = (SELECT COUNT(*) FROM customers);

INSERT INTO customers
(
  `first_name`,
  `last_name`,
  `address`,
  `city`,
  `region`,
  `postal_code`,
  `country`,
  `phone`,
  `email`
)
WITH digits AS (
    SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
),
first_names (id, name) AS (
  SELECT  1, 'James'    UNION ALL
  SELECT  2, 'Mary'     UNION ALL
  SELECT  3, 'Robert'   UNION ALL
  SELECT  4, 'Patricia' UNION ALL
  SELECT  5, 'John'     UNION ALL
  SELECT  6, 'Jennifer' UNION ALL
  SELECT  7, 'Michael'  UNION ALL
  SELECT  8, 'Linda'    UNION ALL
  SELECT  9, 'William'  UNION ALL
  SELECT 10, 'Barbara'  UNION ALL
  SELECT 11, 'David'    UNION ALL
  SELECT 12, 'Susan'    UNION ALL
  SELECT 13, 'Richard'  UNION ALL
  SELECT 14, 'Jessica'  UNION ALL
  SELECT 15, 'Joseph'   UNION ALL
  SELECT 16, 'Sarah'    UNION ALL
  SELECT 17, 'Thomas'   UNION ALL
  SELECT 18, 'Karen'    UNION ALL
  SELECT 19, 'Charles'  UNION ALL
  SELECT 20, 'Lisa'
),
last_names (id, name) AS (
  SELECT  1, 'Smith'     UNION ALL
  SELECT  2, 'Johnson'   UNION ALL
  SELECT  3, 'Williams'  UNION ALL
  SELECT  4, 'Brown'     UNION ALL
  SELECT  5, 'Jones'     UNION ALL
  SELECT  6, 'Garcia'    UNION ALL
  SELECT  7, 'Miller'    UNION ALL
  SELECT  8, 'Davis'     UNION ALL
  SELECT  9, 'Rodriguez' UNION ALL
  SELECT 10, 'Martinez'  UNION ALL
  SELECT 11, 'Hernandez' UNION ALL
  SELECT 12, 'Lopez'     UNION ALL
  SELECT 13, 'Gonzalez'  UNION ALL
  SELECT 14, 'Wilson'    UNION ALL
  SELECT 15, 'Anderson'  UNION ALL
  SELECT 16, 'Thomas'    UNION ALL
  SELECT 17, 'Taylor'    UNION ALL
  SELECT 18, 'Moore'     UNION ALL
  SELECT 19, 'Jackson'   UNION ALL
  SELECT 20, 'Martin'
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
email_domains (id, name) AS (
  SELECT 1, 'mail.com' UNION ALL SELECT 2, 'example.com' UNION ALL SELECT 3, 'corp-mail.com' UNION ALL SELECT 4, 'bizmail.net'
),
country_codes (country_code, rn) AS (
  SELECT country_code, ROW_NUMBER() OVER (ORDER BY country_code) AS rn
  FROM countries
),
numbers AS (
    SELECT
        d0.d
      + d1.d * 10
      + d2.d * 100
      + d3.d * 1000
      + d4.d * 10000
      + d5.d * 100000
      + d6.d * 1000000
      + d7.d * 10000000
      + 1 AS n
    FROM digits d0
        CROSS JOIN digits d1
        CROSS JOIN digits d2
        CROSS JOIN digits d3
        CROSS JOIN digits d4
        CROSS JOIN digits d5
        CROSS JOIN digits d6
        CROSS JOIN digits d7
)
SELECT
  fn.name,
  ln.name,
  CONCAT(
    FLOOR(1 + MOD(n * 3, 9999)),
    ' ',
    sn.name,
    ' ',
    st.name,
    IF(MOD(n, 4) = 0, CONCAT(' Apt. ', LPAD(MOD(n * 5, 999), 3, '0')), '')
  ),
  c.name,
  r.name,
  LPAD(10000 + MOD(n * 7, 90000), 5, '0'),
  cc.country_code,
  CONCAT(
      '(', LPAD(200 + MOD(n * 11, 800), 3, '0'), ')',
      LPAD(100 + MOD(n * 13, 900), 3, '0'),
      '-',
      LPAD(1000 + MOD(n * 17, 9000), 4, '0')
  ),
  LOWER(CONCAT(
      fn.name,
      '.',
      ln.name,
      '.',
      LPAD(n, 4, '0'),
      '@',
      ed.name
  ))
FROM numbers
JOIN first_names fn
  ON fn.id = MOD(n - 1, 20) + 1
JOIN last_names ln
  ON ln.id = MOD(n + 9, 20) + 1
JOIN street_names sn
  ON sn.id = MOD(n - 1, 10) + 1
JOIN street_types st
  ON st.id = MOD(n - 1, 6) + 1
JOIN cities c
  ON c.id = MOD(n - 1, 10) + 1
JOIN regions r
  ON r.id = MOD(n - 1, 10) + 1
JOIN email_domains ed
  ON ed.id = MOD(n - 1, 4) + 1
JOIN country_codes cc
  ON cc.rn = MOD(n - 1, @country_count) + 1
WHERE n <= @records_to_insert;

SET @customer_count_after = (SELECT COUNT(*) FROM customers);

SELECT @customer_count_after - @customer_count_before AS inserted_customers;
