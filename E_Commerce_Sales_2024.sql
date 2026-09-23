use sales_2024_e_commerce;

select * from cleaned_customer_details;
select count(*) from cleaned_customer_details;

select * from cleaned_product_details;
select count(*) from cleaned_product_details;

select * from cleaned_ecommerce_details_2024;
select count(*) from cleaned_ecommerce_details_2024;

/*Create table Customer DImension*/
create table dim_customer (customer_key int  auto_increment primary key,
cust_id varchar(50) unique,age int,gender varchar(20),location varchar(100),subscription_status varchar(30)
);

insert into dim_customer (cust_id,age,gender,location,subscription_status)
select distinct customer_id,age,gender,location,subscription_status
from cleaned_customer_details where customer_id is not null;

select * from dim_customer;
select count(*) from dim_customer;

#create dim Products
create table dim_products (product_key int  auto_increment primary key,
product_id varchar(100) unique not null,product_name varchar(255),category varchar(400),
upc_ean_code varchar(250),selling_price decimal(10,2),model_number varchar(100),is_amazon_seller char(1),
weight_value decimal(10,3),weight_unit varchar(20),weight_lb decimal(10,3)
);

insert into dim_products (product_id,product_name,category,upc_ean_code,selling_price,model_number,is_amazon_seller,
weight_value,weight_unit,weight_lb)
select distinct unique_id,product_name,category,upc_ean_code,selling_price,model_number,is_amazon_seller,
weight_value,weight_unit,weight_lb from cleaned_product_details where unique_id is not null;

select * from dim_products;
select count(*) from dim_products;

/*Dim Date*/
create table dim_date(
date_key int primary key,full_date date not null unique,year int,quarter int,month int,
month_name varchar(20),week int,day_of_month int,day_name varchar(20),is_weekend boolean);

insert into dim_date
(date_key,full_date,year,quarter,month,month_name,week,day_of_month,day_name,is_weekend)
with recursive dates as(
select min(date(time_stamp)) as dt from cleaned_ecommerce_details_2024
union all
select date_add(dt,interval 1 day) from dates
where dt < (select max(date(time_stamp)) from cleaned_ecommerce_details_2024)
)
select year(dt) * 10000 + month(dt) * 100 + day(dt) as date_key,
dt as full_date,year(dt) as year,quarter(dt) as quarter,month(dt) as month,monthname(dt) as month_name,
week(dt) as week,day(dt) as day_of_month,dayname(dt) as day_name,
case when dayofweek(dt) in (1,7) then 1 else 0 end as is_weekend
from  dates;

select * from dim_date;
select count(*) from dim_date;

/*Create table dim_promotions*/
create table dim_promotions(
promotion_key int auto_increment primary key,
promo_code varchar(100),discount_applied boolean);

insert into dim_promotions (promo_code,discount_applied)
select distinct promo_code_used,
case when discount_applied = 'Yes' then true else false end
from cleaned_customer_details;

select * from dim_promotions;
select count(*) from dim_promotions;

/*Create table dim_shipping*/
create table dim_shipping(
shipping_key int auto_increment primary key,
shipping_type varchar(50) unique);

insert into dim_shipping (shipping_type)
select distinct shipping_type
from cleaned_customer_details where shipping_type is not null;

select * from dim_shipping;
select count(*) from dim_shipping;

#Dim Item
create table dim_item(
item_key int auto_increment primary key,
item_name varchar(100) unique not null,category varchar(100));

insert into dim_item (item_name,category)
select distinct item_purchased,category
from cleaned_customer_details where item_purchased is not null;

select * from dim_item;
select count(*) from dim_item;

#fact Sales
create table fact_sales(
sales_key bigint auto_increment primary key,
customer_key int not null,item_key int not null,promotion_key int,shipping_key int,
purchase_amount decimal(10,2),review_rating decimal(3,2),previous_purchases int,
payment_method varchar(50),frequency_of_purchase varchar(50),
foreign key (customer_key) references dim_customer(customer_key),
foreign key (item_key) references dim_item(item_key),
foreign key (promotion_key) references dim_promotions(promotion_key),
foreign key (shipping_key) references dim_shipping(shipping_key)
);

insert into fact_sales (customer_key,item_key,promotion_key,shipping_key,purchase_amount,review_rating,previous_purchases
,payment_method,frequency_of_purchase)
select c.customer_key,i.item_key,p.promotion_key,s.shipping_key,
cs.`purchase_amount_(usd)`,cs.review_rating,cs.previous_purchases
,cs.payment_method,cs.frequency_of_purchases
from cleaned_customer_details cs 
join dim_customer c on cs.customer_id = c.cust_id
join dim_item i on cs.item_purchased = i.item_name
left join dim_promotions p on cs.promo_code_used = p.promo_code
left join dim_shipping s on cs.shipping_type = s.shipping_type;

select * from fact_sales;
select count(*) from fact_sales;

#fact interaction
create table fact_interaction(
interaction_key bigint auto_increment primary key,
customer_key int,product_key int,date_key int,
interaction_type varchar(50),interaction_timestamp timestamp(3),previous_purchases int,
foreign key (customer_key) references dim_customer(customer_key),
foreign key (product_key) references dim_products(product_key),
foreign key (date_key) references dim_date(date_key));

insert into fact_interaction (customer_key,product_key,date_key,interaction_type,interaction_timestamp)
select c.customer_key,p.product_key,d.date_key,e.interaction_type,e.time_stamp
from cleaned_ecommerce_details_2024 e
left join dim_customer c on e.user_id = c.cust_id
left join dim_products p on e.product_id = p.product_id
left join dim_date d on date(e.time_stamp) = d.full_date;

select * from fact_interaction;
select count(*) from fact_interaction;

#Overall performance of the e-commerce business by measuring total transactions, total sales revenue, average
# purchase amount and average customer review rating
select count(*) as total_transaction,sum(purchase_amount) as total_sales,
round(avg(purchase_amount),2) as avg_purchase_amount,round(avg(review_rating),2) as avg_rating
from fact_sales;

#Customer Ranking
select c.cust_id, sum(f.purchase_amount) as total_spend,
dense_rank() over (order by sum(f.purchase_amount) desc) as Customer_Rank
from fact_sales f
join dim_customer c on f.customer_key = c.customer_key group by c.cust_id;

#Rank categories by sales
select category,total_sales,rank() over (order by total_sales desc) as sales_rank
from (select i.category,sum(f.purchase_amount) as total_sales from fact_Sales f
join dim_item i on f.item_key = i.item_key
group by i.category) x;

#Promotion Analysis
select p.promo_code,p.discount_applied,count(*) as tranactions,sum(f.purchase_amount) as total_sales,
avg(f.purchase_amount) as avg_purchase from fact_sales f
join dim_promotions p on f.promotion_key = p.promotion_key
group by p.promotion_key,p.promo_code,p.discount_applied
order by total_sales desc;

#Shipping Analysis
select s.shipping_key,s.shipping_type,count(*) as tranactions,sum(f.purchase_amount) as total_sales,
avg(f.purchase_amount) as avg_purchase from fact_sales f
join dim_shipping s on f.shipping_key = s.shipping_key
group by s.shipping_key,s.shipping_type
order by total_sales desc;


#Repeat Customer Analysis
select
case when f.previous_purchases = 0 then 'New Customer' else 'Repeat Customer' end as Customer_Type,
count(*) as transactions,sum(f.purchase_amount) as total_sales,avg(f.purchase_amount) as avg_purchase
from fact_sales f
group by customer_type;

#Interaction Analysis
select interaction_type,count(*) as interaction_count from fact_interaction
group by interaction_type
order by interaction_count desc;

# Interaction by Product
select p.product_name,p.category,count(*) as interactions from fact_interaction f
join dim_products p on f.product_key = p.product_key
group by p.product_key,p.product_name,p.category
order by interactions desc
limit 10;

#Do subscribers generate more revenue than non subscribers?
select c.subscription_status,count(*) as total_subscription,sum(f.purchase_amount) as total_revenue,
avg(f.purchase_amount) as avg_purchase_value
from fact_sales f join dim_customer c on f.customer_key = c.customer_key
group by c.subscription_status
order by total_revenue desc;

#Which customer segment contributes the most revenue?
select c.subscription_status,c.gender,c.location,
case when c.age < 25 then '18-24'
when c.age between 25 and 34 then '25-34'
when c.age between 35 and 44 then '35-44'
when c.age between 45 and 54 then '45-54'
else '55+' end as  age_group,
sum(f.purchase_amount) as total_revenue from fact_sales f join dim_customer c on f.customer_key = c.customer_key
group by c.subscription_status,c.gender,c.location,
case when c.age < 25 then '18-24'
when c.age between 25 and 34 then '25-34'
when c.age between 35 and 44 then '35-44'
when c.age between 45 and 54 then '45-54'
else '55+' end
order by total_revenue desc;

#Which months have the highest customer interactions?
select d.year,d.month,d.month_name,count(fi.interaction_key) as total_interactions from fact_interaction fi
join dim_date d on fi.date_key = d.date_key
group by d.year,d.month,d.month_name
order by total_interactions desc;

#Which item/category has the highest purchase?
select i.category, count(f.sales_key) as total_purchase, sum(f.purchase_amount) as total_sales
from fact_sales f join dim_item i on f.item_key = i.item_key
group by i.category
order by total_purchase desc;

#Item Level analysis
select i.item_name,i.category, count(f.sales_key) as total_purchase, sum(f.purchase_amount) as total_sales
from fact_sales f join dim_item i on f.item_key = i.item_key
group by i.item_key,i.category
order by total_sales desc;

#Within each product category which item has the highest & lowest purchase volume?
with item_purchase as (
select i.category,i.item_key,i.item_name,count(f.sales_key) as purchase_volumne from fact_sales f
join dim_item i on f.item_key = i.item_key
group by i.category, i.item_key,i.item_name),
ranked as (
select *, first_value(item_name) over (partition by category order by purchase_volumne desc) as highest_purchase_item,
first_value(purchase_volumne) over (partition by category order by purchase_volumne desc) as highest_purchase_count,
last_value(item_name) over (partition by category order by purchase_volumne desc
rows between unbounded preceding and unbounded following) as lowest_purchase_item,
last_value(purchase_volumne) over (partition by category order by purchase_volumne desc
rows between unbounded preceding and unbounded following) as lowest_purchase_count
from item_purchase
)
select distinct category,highest_purchase_item,highest_purchase_count,
lowest_purchase_item,lowest_purchase_count from ranked order by category;


#Monthly interaction count & Growth Analysis
with monthly_interaction as(
select dd.year,dd.month,dd.month_name,fi.interaction_type,count(*) as interaction_count,
count(distinct fi.customer_key) as unique_customers,count(distinct fi.product_key) as unique_products
from fact_interaction fi
join dim_date dd on fi.date_key = dd.date_key
group by dd.year,dd.month,dd.month_name,fi.interaction_type),
interaction_growth as(
select year,month,month_name,interaction_type,interaction_count,unique_customers,unique_products,
lag(interaction_count) over (partition by interaction_type order by year,month) as previous_month_interactions
from monthly_interaction
)
select year,month,month_name,interaction_type,interaction_count,unique_customers,unique_products,
round(interaction_count/nullif(unique_customers,0),2) as interaction_per_customer,
previous_month_interactions,
round((interaction_count - previous_month_interactions) /nullif(previous_month_interactions, 0) * 100, 2) as MoM_growth_percent
from interaction_growth
order by year,month,interaction_type;




