/********************************************************************
* File: demo_products_schema.sql
* Description: Bootstrap script for DEMO_DB.PRODUCTS_DEMO schema.
*    - Creates dimension/fact tables for demo e‑commerce dataset
*    - Adds primary & foreign keys plus inline documentation
*    - Seeds each table with deterministic sample rows
*
* Author: Fetch Rewards – Data Engineering (@k.paul)
* Created: 2025‑06‑19
* Target Warehouse: Snowflake
********************************************************************/

-- ───────────────────────────────
-- 0. Ensure database & schema exist
-- ───────────────────────────────
CREATE DATABASE IF NOT EXISTS DEMO_DB;
CREATE SCHEMA IF NOT EXISTS DEMO_DB.PRODUCTS_DEMO;
USE SCHEMA DEMO_DB.PRODUCTS_DEMO;

-- ───────────────────────────────
-- 1. CUSTOMERS
-- ───────────────────────────────
CREATE OR REPLACE TABLE customers (
    customer_id INTEGER      NOT NULL
        COMMENT 'Surrogate primary key; uniquely identifies each customer',
    name        VARCHAR(255) NOT NULL
        COMMENT 'Full legal name of the customer',
    email       VARCHAR(255) NOT NULL
        COMMENT 'Primary contact e‑mail (assumed unique)',
    signup_date DATE         NOT NULL
        COMMENT 'UTC date the customer first registered',
    PRIMARY KEY (customer_id)
)
COMMENT = 'Master list of customers who have registered for the service';

-- ───────────────────────────────
-- 2. PRODUCTS
-- ───────────────────────────────
CREATE OR REPLACE TABLE products (
    product_id   INTEGER      NOT NULL
        COMMENT 'Surrogate primary key for each sellable product',
    product_name VARCHAR(255) NOT NULL
        COMMENT 'Human‑readable product name shown in the catalog',
    category     VARCHAR(100) NOT NULL
        COMMENT 'High‑level product category (e.g., Electronics, Furniture)',
    price        NUMBER(10,2) NOT NULL
        COMMENT 'Unit list price in USD; two‑decimal precision',
    PRIMARY KEY (product_id)
)
COMMENT = 'Dimensional table holding catalog information for every product we sell';

-- ───────────────────────────────
-- 3. ORDERS
-- ───────────────────────────────
CREATE OR REPLACE TABLE orders (
    order_id    INTEGER NOT NULL
        COMMENT 'Surrogate primary key for an order (cart/checkout event)',
    customer_id INTEGER NOT NULL
        COMMENT 'FK → customers.customer_id; owner of the order',
    order_date  DATE    NOT NULL
        COMMENT 'UTC date the order was placed (checkout completed)',
    PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
)
COMMENT = 'Fact table capturing a single checkout transaction per record';

-- ───────────────────────────────
-- 4. ORDER_ITEMS
-- ───────────────────────────────
CREATE OR REPLACE TABLE order_items (
    order_id    INTEGER NOT NULL
        COMMENT 'FK → orders.order_id; groups all line items for one order',
    product_id  INTEGER NOT NULL
        COMMENT 'FK → products.product_id; the SKU purchased',
    quantity    INTEGER NOT NULL
        COMMENT 'Number of units of the product in this line item',
    total_price NUMBER(12,2) NOT NULL
        COMMENT 'Extended price = quantity × product price at time of sale',
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id),
    CONSTRAINT fk_items_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
)
COMMENT = 'Bridge table (order lines) detailing which products and how many per order';

-- ───────────────────────────────
-- 5. PAYMENTS
-- ───────────────────────────────
CREATE OR REPLACE TABLE payments (
    payment_id     INTEGER NOT NULL
        COMMENT 'Surrogate primary key for each payment record',
    order_id       INTEGER NOT NULL
        COMMENT 'FK → orders.order_id; the order this payment settles',
    payment_method VARCHAR(50) NOT NULL
        COMMENT 'Tender type (e.g., Credit Card, PayPal, Bank Transfer)',
    payment_date   DATE       NOT NULL
        COMMENT 'UTC date the payment was successfully processed',
    amount         NUMBER(12,2) NOT NULL
        COMMENT 'Total amount collected for the order in USD',
    PRIMARY KEY (payment_id),
    CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
)
COMMENT = 'Clearing table listing how each order was paid and for how much';

-- ───────────────────────────────
-- 6. SEED DATA
--    Insert deterministic demo rows
-- ───────────────────────────────

-- Customers
INSERT INTO customers (customer_id, name, email, signup_date) VALUES
    (1, 'Victoria Thomas', 'grosario@jackson.biz', '2024-03-26'),
    (2, 'Dana Stewart',    'leonardjoshua@yahoo.com', '2023-06-29'),
    (3, 'Kyle Gonzalez',   'andersonashley@cox-mcgee.com', '2024-05-01'),
    (4, 'Jonathan Wilson', 'sharon03@anderson.biz', '2024-04-22'),
    (5, 'Robert Garza',    'laurenjacobs@hotmail.com', '2024-05-31');

-- Products
INSERT INTO products (product_id, product_name, category, price) VALUES
    (101, 'Product_101', 'Electronics', 161.82),
    (102, 'Product_102', 'Furniture', 34.22),
    (103, 'Product_103', 'Clothing', 282.99),
    (104, 'Product_104', 'Toys', 113.17),
    (105, 'Product_105', 'Kitchen', 133.67);

-- Orders
INSERT INTO orders (order_id, customer_id, order_date) VALUES
    (1001, 1, '2025-06-13'),
    (1002, 2, '2025-06-13'),
    (1003, 3, '2025-06-13'),
    (1004, 4, '2025-06-13'),
    (1005, 5, '2025-06-13');

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, total_price) VALUES
    (1001, 105, 3, 401.01),
    (1001, 101, 2, 323.64),
    (1002, 102, 1, 34.22),
    (1002, 101, 3, 485.46),
    (1003, 101, 3, 485.46),
    (1003, 104, 1, 113.17),
    (1004, 105, 1, 133.67),
    (1004, 104, 2, 226.34),
    (1005, 103, 3, 848.97),
    (1005, 101, 1, 161.82);

-- Payments
INSERT INTO payments (payment_id, order_id, payment_method, payment_date, amount) VALUES
    (401, 1001, 'Bank Transfer', '2025-06-13', 724.65),
    (402, 1002, 'PayPal',        '2025-06-13', 519.68),
    (403, 1003, 'Bank Transfer', '2025-06-13', 598.63),
    (404, 1004, 'PayPal',        '2025-06-13', 360.01),
    (405, 1005, 'PayPal',        '2025-06-13', 1010.79);

-- ───────────────────────────────
-- 7. VERIFICATION (optional)
-- ───────────────────────────────
SELECT
    t.table_name,
    row_count
FROM information_schema.tables t
WHERE table_schema = 'PRODUCTS_DEMO'
    AND table_name IN ('CUSTOMERS','PRODUCTS','ORDERS','ORDER_ITEMS','PAYMENTS')
ORDER BY table_name;

SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM payments;

-- End of script
