-- unique email
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TABLE customers (
  customer_id SERIAL PRIMARY KEY,
  firstname VARCHAR (50) NOT NULL,
  lastname VARCHAR (50) NOT NULL,
  email CITEXT UNIQUE
);


CREATE TABLE items(
	name VARCHAR(255),
	cost NUMERIC(6, 2) NOT NULL,
	seller_id INTEGER ,	
	bids INTEGER DEFAULT 0,
    item_id SERIAL PRIMARY KEY,
	CONSTRAINT fk_seller
     FOREIGN KEY(seller_id)
	  REFERENCES customers(customer_id)
	  ON DELETE CASCADE
	  ON UPDATE CASCADE
);



CREATE OR REPLACE FUNCTION pounds(amount numeric(6,2)) 
RETURNS money as
$body$
	SELECT amount::double precision::numeric::money
$body$
LANGUAGE SQL



INSERT INTO items(name,cost,seller_id  )
values
('7 boxes of frogs', 15, 19);

-- reg ex
select name from items where name 
SIMILAR TO
'[1-5] boxes of frogs';

-- full text search examples
-- search for "baby" and NOT "coat"
SELECT name, pounds(cost) 
FROM items 
WHERE to_tsvector(name) @@ to_tsquery('(baby ) &  (!coat)');
-- subquery 
-- find the items greater than the average price of products

-- find the total number of listing per seller
WITH seller_details AS (
   SELECT 
		CONCAT (firstname, ' ',lastname) seller,
		COUNT(item_id) item_count
	FROM items i
	JOIN customers c ON c.customer_id = i.seller_id
	GROUP BY seller 
	ORDER BY seller, item_count 
)
SELECT * FROM seller_details;

-- find items less than the average price of all products
WITH avg_items_cost AS (SELECT AVG(cost) avg_cost FROM items)

SELECT name, pounds(cost) price, pounds(avg_cost) average_price
FROM items, avg_items_cost
WHERE cost > avg_cost
ORDER BY price 
-- a function that finds the sellar statistics
CREATE OR REPLACE FUNCTION seller_statistics(sellers_id INTEGER)
   RETURNS TABLE (
        min_cost money,
        max_cost money,
		avg_cost money
) 
AS 
$$
   SELECT
   pounds(MIN(cost)),
   pounds(MAX(cost)), 
   pounds(AVG(cost)) 
   FROM items 
   WHERE seller_id = sellers_id;
$$
LANGUAGE sql;

-- find a seller's item below their average selling price:
CREATE OR REPLACE FUNCTION seller_below_avg_items(sellers_id INTEGER)
   RETURNS TABLE (
        product_name VARCHAR,
        item_price money
) 
AS 
$$
	   WITH avg_items_cost AS
	(SELECT AVG(cost) avg_cost FROM items WHERE seller_id = sellers_id)
	
	SELECT name product_name, pounds(cost) item_price
	FROM items, avg_items_cost
	WHERE seller_id = sellers_id 
	 AND cost < avg_cost
	GROUP BY name, cost;
$$
LANGUAGE sql;


SELECT * FROM seller_below_avg_items(24); 
SELECT * FROM seller_statistics(24);



