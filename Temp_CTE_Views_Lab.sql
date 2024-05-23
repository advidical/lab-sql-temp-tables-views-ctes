-- In this exercise, you will create a customer summary report that summarizes key information
-- about customers in the Sakila database, 
-- including their rental history and payment details. 
-- The report will be generated using a combination of views, CTEs, and temporary tables.
-- • Step 1: Create a View 
--  summarizes rental information for each customer. 
--  The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE OR REPLACE VIEW customer_rental_summary AS
SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM 
    customer c
JOIN 
    rental r ON r.customer_id = c.customer_id
GROUP BY 
    c.customer_id;
SELECT * from customer_rental_summary;

-- • Step 2: Create a Temporary Table 
-- that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 
-- to join with the payment table and calculate the total amount paid by each customer.
DROP TABLE sakila.total_amount_customer;
CREATE TABLE sakila.total_amount_customer
SELECT pay.customer_id,
	   rs.customer_name,
       SUM(pay.amount) as total_paid
FROM customer_rental_summary rs
JOIN sakila.payment pay 
ON pay.customer_id = rs.customer_id
GROUP BY pay.customer_id;

SELECT * FROM sakila.total_amount_customer;

--    • Step 3: Create a CTE and the Customer Summary Report 
-- Create a CTE that joins the rental summary View with 
-- the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.
-- Next, using the CTE, 
-- create the query to generate the final customer summary report, 
-- which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, 
-- the last column is a derived column from total_paid and rental_count.

WITH customer_rental_info AS (
	SELECT tac.customer_name, crs.email, crs.rental_count, tac.total_paid 
    FROM sakila.total_amount_customer tac
    JOIN customer_rental_summary crs ON crs.customer_id = tac.customer_id
    )
SELECT 
	cri.customer_name,
    cri.email,
    cri.rental_count,
    cri.total_paid,
    round(cri.total_paid / cri.rental_count,2) AS average_payment_per_rental
FROM customer_rental_info cri
GROUP BY cri.customer_name, cri.email, cri.rental_count, cri.total_paid;