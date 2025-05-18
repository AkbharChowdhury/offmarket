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



WITH seller_details AS (
   SELECT 
		CONCAT (c.firstname, ' ', c.lastname) seller,
		COUNT(i.item_id) item_count
	FROM items i
	JOIN customers c ON c.customer_id = i.seller_id
	GROUP BY seller 
	HAVING COUNT(i.item_id) <3
)

SELECT seller, item_count
FROM seller_details
ORDER BY seller, item_count 

