USE northwind;
SELECT
    FORMAT((Select count(*) from countries), 0) as countries,
    FORMAT((Select count(*) from categories), 0) as categories,
    FORMAT((Select count(*) from shippers), 0) as shippers,
    FORMAT((Select count(*) from customers), 0) as customers,
    FORMAT((Select count(*) from employees), 0) as employees,
    FORMAT((Select count(*) from suppliers), 0) as suppliers,
    FORMAT((Select count(*) from products), 0) as products,
    FORMAT((Select count(*) from orders), 0) as orders,
    FORMAT((Select count(*) from order_details), 0) as order_details;
