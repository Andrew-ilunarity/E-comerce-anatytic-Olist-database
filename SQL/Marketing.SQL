create or replace view "Eeeee-c".Purchase_alive as(
with first as(
select
	os.customer_id as "ID",
	ci.customer_unique_id as "UID",
	ci.customer_city as "City",
	ci.customer_state as "State",
	to_timestamp(order_purchase_timestamp, 'YYYY-MM-DD H24:MI') as "Order Time",
	t.payment_value as "Payment"
from order_status as os
join customers_inf ci 
	on os.customer_id = ci.customer_id
join payments_inf t 
	on os.order_id = t.order_id
group by "ID", "UID", "City", "State", "Order Time", "Payment")
----
select 
	"ID", "City", "State", "Order Time", "Payment",
	dense_rank() over(
		partition by "UID"
		order by "Order Time" asc) as "Number of purchase"
from first);
