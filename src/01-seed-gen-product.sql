USE northwind;

SET @records_to_insert = 1000000;

SET @supplier_count = (SELECT COUNT(*) FROM suppliers);
SET @category_count = (SELECT COUNT(*) FROM categories);

SET @product_count_before = (SELECT COUNT(*) FROM products);

INSERT IGNORE INTO products
(
    `product_name`,
    `supplier_id`,
    `category_id`,
    `description`,
    `photo_path`,
    `unit_price`,
    `units_in_stock`,
    `discontinued`
)
WITH digits AS (
    SELECT 0 AS d UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
),
product_bases (id, name, family) AS (
    SELECT  1, 'Chai',              'tea'       UNION ALL
    SELECT  2, 'Matcha',            'tea'       UNION ALL
    SELECT  3, 'Green Tea',         'tea'       UNION ALL
    SELECT  4, 'Black Tea',         'tea'       UNION ALL
    SELECT  5, 'Earl Grey',         'tea'       UNION ALL
    SELECT  6, 'Espresso',          'coffee'    UNION ALL
    SELECT  7, 'Americano',         'coffee'    UNION ALL
    SELECT  8, 'Cappuccino',        'coffee'    UNION ALL
    SELECT  9, 'Latte',             'coffee'    UNION ALL
    SELECT 10, 'Mocha',             'coffee'    UNION ALL
    SELECT 11, 'Cola',              'soft drink' UNION ALL
    SELECT 12, 'Lemon Soda',        'soft drink' UNION ALL
    SELECT 13, 'Ginger Ale',        'soft drink' UNION ALL
    SELECT 14, 'Sparkling Water',   'water'     UNION ALL
    SELECT 15, 'Still Water',       'water'     UNION ALL
    SELECT 16, 'Orange Juice',      'juice'     UNION ALL
    SELECT 17, 'Apple Juice',       'juice'     UNION ALL
    SELECT 18, 'Grape Juice',       'juice'     UNION ALL
    SELECT 19, 'Cranberry Juice',   'juice'     UNION ALL
    SELECT 20, 'Kombucha',          'fermented drink' UNION ALL
    SELECT 21, 'Oat Milk',          'dairy alternative' UNION ALL
    SELECT 22, 'Whole Milk',        'dairy'     UNION ALL
    SELECT 23, 'Yogurt',            'dairy'     UNION ALL
    SELECT 24, 'Cheese',            'dairy'     UNION ALL
    SELECT 25, 'Butter',            'dairy'     UNION ALL
    SELECT 26, 'Olive Oil',         'pantry'    UNION ALL
    SELECT 27, 'Pasta',             'pantry'    UNION ALL
    SELECT 28, 'Rice',              'pantry'    UNION ALL
    SELECT 29, 'Bread',             'bakery'    UNION ALL
    SELECT 30, 'Granola',           'snack'     UNION ALL
    SELECT 31, 'Cookies',           'snack'     UNION ALL
    SELECT 32, 'Brownies',          'snack'     UNION ALL
    SELECT 33, 'Chocolate',         'snack'     UNION ALL
    SELECT 34, 'Honey',             'sweetener' UNION ALL
    SELECT 35, 'Jam',               'sweetener' UNION ALL
    SELECT 36, 'Nuts',              'snack'     UNION ALL
    SELECT 37, 'Seeds',             'snack'     UNION ALL
    SELECT 38, 'Salsa',             'condiment' UNION ALL
    SELECT 39, 'Soup',              'prepared food' UNION ALL
    SELECT 40, 'Salad',             'prepared food' UNION ALL
    SELECT 41, 'Shrimp',            'seafood'
),
product_styles (id, name, price_factor, tone) AS (
    SELECT  1, 'Classic',   0.95, 'balanced and familiar' UNION ALL
    SELECT  2, 'Fresh',     1.00, 'freshly prepared' UNION ALL
    SELECT  3, 'Premium',   1.18, 'higher quality' UNION ALL
    SELECT  4, 'Organic',   1.22, 'organic ingredients' UNION ALL
    SELECT  5, 'Artisan',   1.15, 'small-batch crafted' UNION ALL
    SELECT  6, 'Signature', 1.20, 'signature house blend' UNION ALL
    SELECT  7, 'Reserve',   1.28, 'limited reserve selection' UNION ALL
    SELECT  8, 'Light',     0.90, 'lighter profile' UNION ALL
    SELECT  9, 'Bold',      1.08, 'bold flavor' UNION ALL
    SELECT 10, 'Deluxe',    1.25, 'deluxe finish'
),
product_sizes (id, name, price_factor, stock_factor) AS (
    SELECT 1, 'S',  0.90, 0.65 UNION ALL
    SELECT 2, 'M',  1.00, 1.00 UNION ALL
    SELECT 3, 'L',  1.12, 1.25 UNION ALL
    SELECT 4, 'XL', 1.25, 1.55
),
product_notes (id, note) AS (
    SELECT  1, 'clean finish' UNION ALL
    SELECT  2, 'smooth texture' UNION ALL
    SELECT  3, 'natural sweetness' UNION ALL
    SELECT  4, 'bright aroma' UNION ALL
    SELECT  5, 'rich mouthfeel' UNION ALL
    SELECT  6, 'balanced acidity' UNION ALL
    SELECT  7, 'fresh grain notes' UNION ALL
    SELECT  8, 'creamy finish' UNION ALL
    SELECT  9, 'toasted undertones' UNION ALL
    SELECT 10, 'fruity profile' UNION ALL
    SELECT 11, 'soft spice finish' UNION ALL
    SELECT 12, 'slow-cooked depth' UNION ALL
    SELECT 13, 'bright citrus lift' UNION ALL
    SELECT 14, 'earthy body' UNION ALL
    SELECT 15, 'snack-friendly crunch' UNION ALL
    SELECT 16, 'fresh market taste'
),
supplier_ids (supplier_id, rn) AS (
    SELECT supplier_id, ROW_NUMBER() OVER (ORDER BY supplier_id) AS rn
    FROM suppliers
),
category_ids (category_id, rn) AS (
    SELECT category_id, ROW_NUMBER() OVER (ORDER BY category_id) AS rn
    FROM categories
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
    CONCAT(pb.name, ' ', ps.name, ' ', sz.name, ' #', LPAD(n, 6, '0')) AS product_name,
    sup.supplier_id AS supplier_id,
    cat.category_id AS category_id,
    CONCAT(
        pb.name, ' ', ps.name, ' ', sz.name, ' #', LPAD(n, 6, '0'),
        ' is a ', ps.tone, ' ', pb.family,
        ' with ', pn.note,
        ' and a ', sz.name, ' format.'
    ) AS description,
    IF(
        MOD(n, 3) = 0,
        CONCAT('/images/products/food/', LOWER(REPLACE(pb.name, ' ', '_')), '_', LPAD(n, 6, '0'), '.jpg'),
        NULL
    ) AS photo_path,
    ROUND(
        (CASE ps.id
            WHEN 1 THEN 1.49
            WHEN 2 THEN 2.29
            WHEN 3 THEN 4.99
            WHEN 4 THEN 6.49
            WHEN 5 THEN 7.99
            WHEN 6 THEN 9.49
            WHEN 7 THEN 12.99
            WHEN 8 THEN 3.99
            WHEN 9 THEN 5.49
            ELSE 10.99
        END) * ps.price_factor * sz.price_factor * (0.92 + RAND(n * 17) * 0.25),
        4
    ) AS unit_price,
    FLOOR((20 + RAND(n * 19) * 480) * sz.stock_factor) AS units_in_stock,
    IF(RAND(n * 23) < 0.08, b'1', b'0') AS discontinued
FROM numbers
JOIN product_bases pb
    ON pb.id = MOD(n - 1, 41) + 1
JOIN product_styles ps
    ON ps.id = MOD(n - 1, 10) + 1
JOIN product_sizes sz
    ON sz.id = MOD(n - 1, 4) + 1
JOIN product_notes pn
    ON pn.id = MOD(n - 1, 16) + 1
JOIN supplier_ids sup
    ON sup.rn = MOD(n - 1, @supplier_count) + 1
JOIN category_ids cat
    ON cat.rn = MOD(n - 1, @category_count) + 1
WHERE n <= @records_to_insert;

SET @product_count_after = (SELECT COUNT(*) FROM products);

SELECT @product_count_after - @product_count_before AS inserted_products;
