USE sakila;
   ##Get number of monthly active customers.
SELECT * FROM customer;

SELECT count(customer_id) as total_customer, 
date_format(convert(create_date,date),'%M') AS active_month
FROM customer
WHERE active = 1
group by active_month;

SELECT*FROM rental;

SELECT count(customer_id) as total_customer2, 
date_format(convert(rental_date,date),'%M') AS active_month2,
date_format(convert(rental_date,date),'%m') AS active_month_num
FROM rental
group by active_month2 , active_month_num
order by active_month2 , active_month_num ;

##Active users in the previous month.


DROP VIEW IF exists active_user_month;
CREATE OR REPLACE VIEW active_user_month AS
SELECT count(customer_id) as active_users ,
date_format(convert(rental_date,date),'%M') AS active_month2,
date_format(convert(rental_date,date),'%m') AS active_month_num
FROM rental
group by active_month2 , active_month_num
order by active_month2 , active_month_num ;

SELECT * FROM active_user_month ;

SELECT active_month2, active_month_num , active_users,
LAG(ACTIVE_USERS,1)
OVER ( order by active_month_num ) AS active_users_month
FROM active_user_month;



##Percentage change in the number of active customers.

with cte_view as(
SELECT active_month2, active_month_num , active_users,
LAG(ACTIVE_USERS,1)
OVER ( order by active_month_num ) AS active_users_month
FROM active_user_month
)
SELECT active_month2, active_month_num , active_users,active_users_month,
( active_users - active_users_month/ active_users_month)*100 AS PERCENTAGE
FROM cte_view;

##Retained customers every month.

create or replace view distinct_users as
SELECT distinct active_users as ACTIVE_id ,active_month2,active_month_num
FROM active_user_month;


 SELECT d1.active_month2, d1.active_month_num,
 count(distinct d1.ACTIVE_id) as RETAINED_users 
 FROM distinct_users d1
 JOIN  distinct_users d2
 ON d1.active_id = d2.active_id
 and d2.active_month_num = d1.active_month_num+1
 group by d1.active_month2,d1.active_month_num;
 
 