1. SELECT user_id, room_no
FROM (
    SELECT 
        user_id,
        room_no,
        booking_date,
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) AS rn
    FROM bookings
) t
WHERE rn = 1;





2.SELECT 
    bc.booking_id,
    SUM(bc.item_quantity * i.item_rate) AS total_bill
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 11 
  AND YEAR(bc.bill_date) = 2021
GROUP BY bc.booking_id;




3.SELECT 
    bc.bill_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 10 
  AND YEAR(bc.bill_date) = 2021
GROUP BY bc.bill_id
HAVING SUM(bc.item_quantity * i.item_rate) > 1000;




4.WITH item_orders AS (
    SELECT 
        MONTH(bc.bill_date) AS month,
        i.item_name,
        SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY month, i.item_name
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS rnk_desc,
           RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS rnk_asc
    FROM item_orders
)
SELECT *
FROM ranked
WHERE rnk_desc = 1 OR rnk_asc = 1;




5.WITH monthly_bills AS (
    SELECT 
        u.user_id,
        MONTH(bc.bill_date) AS month,
        SUM(bc.item_quantity * i.item_rate) AS total_bill
    FROM booking_commercials bc
    JOIN bookings b ON bc.booking_id = b.booking_id
    JOIN users u ON b.user_id = u.user_id
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY u.user_id, month
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total_bill DESC) AS rnk
    FROM monthly_bills
)
SELECT *
FROM ranked
WHERE rnk = 2;


Clinic Management System (Part B)

1.SELECT 
    sales_channel,
    SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;




2.SELECT 
    uid,
    SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;




3.WITH revenue AS (
    SELECT 
        MONTH(datetime) AS month,
        SUM(amount) AS revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
    GROUP BY month
),
expenses_cte AS (
    SELECT 
        MONTH(datetime) AS month,
        SUM(amount) AS expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY month
)
SELECT 
    r.month,
    r.revenue,
    e.expense,
    (r.revenue - e.expense) AS profit,
    CASE 
        WHEN (r.revenue - e.expense) > 0 THEN 'Profitable'
        ELSE 'Not Profitable'
    END AS status
FROM revenue r
LEFT JOIN expenses_cte e ON r.month = e.month;




4.WITH clinic_profit AS (
    SELECT 
        c.city,
        cs.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinics c
    JOIN clinic_sales cs ON c.cid = cs.cid
    LEFT JOIN expenses e 
        ON c.cid = e.cid 
        AND MONTH(e.datetime) = 9 -- example month
    WHERE MONTH(cs.datetime) = 9
    GROUP BY c.city, cs.cid
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM clinic_profit
)
SELECT *
FROM ranked
WHERE rnk = 1;





5.WITH clinic_profit AS (
    SELECT 
        c.state,
        cs.cid,
        SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinics c
    JOIN clinic_sales cs ON c.cid = cs.cid
    LEFT JOIN expenses e 
        ON c.cid = e.cid 
        AND MONTH(e.datetime) = 9
    WHERE MONTH(cs.datetime) = 9
    GROUP BY c.state, cs.cid
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM clinic_profit
)
SELECT *
FROM ranked
WHERE rnk = 2;












