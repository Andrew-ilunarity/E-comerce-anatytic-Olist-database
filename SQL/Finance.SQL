create or replace view "Eeeee-c".CEO as(
with Title as(
select
	pi.product_id as "Product ID",
	case 
		when pcnt.product_category_name_english is null then 'unknown'
		else lower(pcnt.product_category_name_english)
	end as "Title"
from "Eeeee-c".product_inf as pi
join "Eeeee-c".product_category_name_translation pcnt 
	on pi.product_category_name = pcnt.product_category_name),
----
Count_time_geo as(
select 
	si.order_id as "Order ID", 
	t.payment_type "Payment type",
	count(si.order_item_id) as "Total units sell",
	si.product_id as "Product ID",
	os.order_status as "Order status",
	sc."Seller ID",
	sc."City",
	sc."State",
	to_timestamp(os.order_purchase_timestamp, 'YYYY-MM-DD H24:MI') as "Purchase time",
	to_timestamp(os.order_approved_at, 'YYYY-MM-DD H24:MI') as "Aproved time",
	t.payment_value as "Payment",
	si.price as "Price",
	si.freight_value as "Delivery cost"
FROM "Eeeee-c".sell_inf as si
join "Eeeee-c".payments_inf t
	on si.order_id = t.order_id
join "Eeeee-c".order_status os 
	on si.order_id = os.order_id 
join "Eeeee-c".suport_ceo as sc
	on si.order_id = sc."Order ID"
group by 
	si.order_id,
	t.payment_type,
	si.product_id,
	os.order_status,
	sc."Seller ID",
	sc."City",
	sc."State",
	os.order_purchase_timestamp,
	os.order_approved_at,
	t.payment_value,
	si.price, 
	si.freight_value)
----
select 
	ctg."Order ID",
	ctg."Payment type",
	ctg."Total units sell",
	t."Title",
	ctg."Order status",
	ctg."Seller ID",
	ctg."City",
	ctg."State",
	ctg."Purchase time",
	case
		when extract(year from ctg."Aproved time") < '2016' or extract(year from ctg."Aproved time") > '2100' 
			then null
		else ctg."Aproved time"
	end as "Aproved time",
	ctg."Payment",
	ctg."Price" * ctg."Total units sell"::real as "Price",
	ctg."Delivery cost"
from Count_time_geo as ctg
join Title as t
	on ctg."Product ID" = t."Product ID"
where ctg."Order status" in ('shipped','delivered')
order by "Purchase time" asc);
