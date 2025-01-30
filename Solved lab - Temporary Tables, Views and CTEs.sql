USE sakila;

-- Creating a Customer Summary Report

-- In this exercise, you will create a customer summary report that summarizes key information about customers in the Sakila database, including their rental history and payment details. The report will be generated using a combination of views, CTEs, and temporary tables.

-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM 
    customer c
INNER JOIN 
    rental r USING (customer_id)
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email;
    
CREATE VIEW rental_count AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM 
    customer c
INNER JOIN 
    rental r USING (customer_id)
GROUP BY 
    c.customer_id, c.first_name, c.last_name, c.email;   

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE temp_customer_payments AS
SELECT 
    rc.customer_id,
    rc.first_name,
    rc.last_name,
    rc.email,
    SUM(p.amount) AS total_amount
FROM 
    rental_count rc
INNER JOIN 
    payment p USING (customer_id)
GROUP BY 
    rc.customer_id, rc.first_name, rc.last_name, rc.email;
    
SELECT * FROM temp_customer_payments;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

WITH customer_summary AS (
    SELECT 
        rc.customer_id,
        rc.first_name,
        rc.last_name,
        rc.email,
        rc.rental_count,
        t.total_amount
    FROM 
        rental_count rc
    INNER JOIN 
        temp_customer_payments t USING (customer_id)
)
SELECT 
    customer_id,
    first_name,
    last_name,
    email,
    rental_count,
    total_amount
FROM 
    customer_summary;

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH customer_summary AS (
    SELECT 
        rc.customer_id,
        rc.first_name,
        rc.last_name,
        rc.email,
        rc.rental_count,
        t.total_amount
    FROM 
        rental_count rc
    INNER JOIN 
        temp_customer_payments t USING (customer_id)
)
SELECT 
    CONCAT(first_name, ' ', last_name) AS customer_name,
    email,
    rental_count,
    total_amount AS total_paid,
    CASE 
        WHEN rental_count > 0 THEN total_amount / rental_count
        ELSE 0
    END AS average_payment_per_rental
FROM 
    customer_summary;