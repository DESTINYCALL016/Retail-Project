Create Database Internship
use Internship

Select * from Customer_raw
Select * from Orders_Payment_Raw
Select * from Orders_Raw
Select * from OrdersRating_Review_Raw
Select * from Products_Info_Raw
Select * from Store_info_Raw

-----------------------------------------------Customer level--------------------------------------------------------- 
-- 1. How many distinct customers are in the dataset?

Select Distinct count(Custid) as total_customer from Customer_Raw 

-- 2. Are there any duplicate customer IDs?

Select Custid as Duplicate_Records, count(custid) as Duplicate_Count
from 
Customer_Raw
group by Custid
having count(custid)>1
order by  Duplicate_Count desc

-- 3. What is the distribution of customers across states?

Select customer_state, count(custid) as customer_per_state
from
Customer_Raw
group by customer_state
order by customer_per_state desc

-- 4. What is the overall gender split among customers?

Select gender, count(custid) as customer_count
from 
Customer_Raw
group by gender
order by customer_count desc

-- 5. What is the state-wise gender distribution?
With State_Total_Cust as 
	(Select customer_state	, count(custid) as customer_per_state 
	from 
	Customer_Raw
	group by customer_state
	)

Select c.customer_state,gender,count(custid) as Cust_count, 
Cast(round((count(custid)*100.0)/customer_per_state,2)as numeric(10,2)) as Percent_Distribution
from 
Customer_Raw as C
join 
State_Total_Cust as ST
on
C.customer_state=ST.customer_state
group by c.customer_state,gender, customer_per_state
order by customer_per_state desc

-------------------------------------------------Order level---------------------------------------------

-- 1. How many distinct orders are in the dataset?

Select count(distinct order_id) as distinct_order
from 
Orders_Raw

-- 2. Are there any duplicate order_ids?

Select order_id, count(order_id) as Duplicate
from
Orders_Raw
group by order_id
having count(order_id)>1
order by Duplicate desc

-- 3. Are there NULLs in key order fields (e.g., customer ID, order date, channel)?

Select *
from Orders_Raw
Where
    Customer_id IS NULL OR
    Product_id IS NULL OR TRIM(Product_id) = '' OR
    Channel IS NULL OR TRIM(Channel) = '' OR
    Delivered_StoreID IS NULL OR TRIM(Delivered_StoreID) = '' OR
    Bill_date_timestamp IS NULL OR TRIM(Bill_date_timestamp) = '' OR
    Quantity IS NULL OR
    Cost_Per_Unit IS NULL OR
    MRP IS NULL OR
    Discount IS NULL OR
    Total_Amount IS NULL;

-- 4. Is the current data type of Customer_id appropriate for long-term storage and reporting? Should it be converted from INT to VARCHAR?

Alter table Orders_raw
Add Customer_id_str Varchar(20)

Update Orders_Raw
Set customer_id_str =Cast(customer_id as varchar(20))

-- 5. Is the Bill_date_timestamp column stored as proper DATETIME type, or does it exist in inconsistent text formats?

Alter table Orders_raw
Add order_date date

Alter table Orders_raw
Add order_time time 
Update Orders_Raw
set order_date= convert(date,bill_date_timestamp,101)

Update Orders_Raw
set order_time= convert(time,bill_date_timestamp,101)

Select * from Orders_Raw

-- 6. Does the order amount = quantity × price?

Select Order_id, product_id, Total_Amount,(Quantity*Cost_Per_Unit)*(1 - (discount/100.0)) as net_price
from 
Orders_Raw 
where Total_Amount<> (Quantity*Cost_Per_Unit)*(1 - (discount/100.0))

-- 7. What is the distribution of orders by channel (e.g., Online vs Offline)?

Select Channel,count(order_id) as channel_distribution
from
Orders_Raw
group by Channel
order by channel_distribution desc

-- 8. Can we categorize customers as "Nighthawk" or "DawnSparrow" based on order time?

Alter table Orders_raw
add cust_type varchar(15)

Update Orders_Raw
set cust_type ='Nighthawk'
where order_time between '00:00:00' and '05:00:00'

Update Orders_Raw
set cust_type='DawnSparrow' 
where cust_type is Null

select * from Orders_Raw

-- 9. What is the Nighthawk vs DawnSparrow split by gender?

Select cust_type, gender,count(order_id) as Night_Dawn_Count
from 
Orders_Raw as O
join
Customer_Raw as C
on
O.Customer_id=c.Custid
group by cust_type,gender
order by Night_Dawn_Count desc

-- 10. What is the store-wise share of orders?

Select Delivered_StoreID, Count(order_id) as Traffic
from
Orders_Raw
group by Delivered_StoreID
order by Traffic desc

-- 11. What are the quarterly trends in order quantity?

Select YEAR(order_date) as [year], DATEPART(QUARTER,order_date) as Q, sum(quantity) as Quantity
from
Orders_Raw
group by YEAR(order_date), DATEPART(QUARTER,order_date)
order by Quantity desc

-------------------------------------------LoyaltyAnalysis--------------------------------------------

-- 1. How many customers are frequent customers(frequency>3)?

Select Customer_id,count(customer_id) as Total_Visit 
from 
Orders_Raw
group by Customer_id
having count(customer_id)>2
order by Total_Visit desc

-- 2. Which states have the highest loyal customer base?

With State_total_reviews as ( 
    Select C.customer_state ,Count(orat.order_id) as TotalReviews
    from
    OrdersRating_Review_Raw as ORat
    join Orders_raw as O
    on
    Orat.order_id=o.order_id
    join 
    Customer_Raw as C
    on
    C.Custid=o.Customer_id
    group by C.customer_state
    )
Select c.customer_state, Count(orat.order_id) as State_Loyalty_Base,st.TotalReviews
from
OrdersRating_Review_Raw as ORat
join Orders_raw as O
on
Orat.order_id=o.order_id
join 
Customer_Raw as C
on
C.Custid=o.Customer_id
join
State_total_reviews as St
on
st.customer_state=c.customer_state
where orat.Customer_Satisfaction_Score>=4
group by C.customer_state, st.TotalReviews
order by st.TotalReviews desc

-- 3. Which stores have high customer loyalty?

With Store_TotalReviews as (
    Select Delivered_StoreID, count(orat.order_id) as Total_Reviews
    from
    OrdersRating_Review_Raw as Orat
    join
    Orders_Raw as o
    on
    o.order_id=orat.order_id
    group by Delivered_StoreID)
Select o.Delivered_StoreID,count(orat.order_id) as Store_loyalty_base,st.Total_Reviews,
Cast(Round((Count(orat.order_id) * 100.0) / st.Total_Reviews, 2) As Numeric(5,2)) As Loyalty_Percentage
from
OrdersRating_Review_Raw as Orat
join
Orders_Raw as o
on
o.order_id=orat.order_id
join
Store_TotalReviews as St
on
o.Delivered_StoreID=st.Delivered_StoreID
where orat.Customer_Satisfaction_Score>3
group by o.Delivered_StoreID,Total_Reviews
order by Loyalty_Percentage desc

-- 4. What are the most liked products?

With TotalReviews as(
    Select pro.product_id,count(orat.order_id) as TotalProductReview
    from
    OrdersRating_Review_Raw as Orat
    join 
    Orders_Raw as O
    on
    O.order_id= orat.order_id
    join
    Products_Info_Raw as Pro
    on
    pro.product_id= o.product_id
    group by pro.product_id
    )
Select o.product_id, pro.Category,Count(orat.order_id) as Loyalty_base,Tr.TotalProductReview,
Round((count(orat.order_id)/cast(tr.TotalProductReview as float))*100.0,2) as Loyalty_percent
from 
OrdersRating_Review_Raw as Orat
join 
Orders_Raw as O
on
O.order_id= orat.order_id
join
Products_Info_Raw as Pro
on
pro.product_id= o.product_id
join
TotalReviews as TR
on
TR.product_id=o.product_id
where Orat.Customer_Satisfaction_Score>3
group by o.product_id,pro.Category,tr.TotalProductReview
order by TotalProductReview desc, Loyalty_percent desc


-- 5. Which channels are preferred by loyal customers?
With TotalReviewCustomer as(
    Select Channel, count(orat.order_id) as TotalCustomer
    from
    OrdersRating_Review_Raw as Orat
    join
    Orders_Raw as O
    on
    o.order_id=orat.order_id
    group by Channel
    )
Select o.Channel,count(orat.order_id) as Loyal_Cust_Channel,TotalCustomer,
round((count(orat.order_id)/cast(TotalCustomer as float))*100.0,2) as Loyalty_Percent
from
OrdersRating_Review_Raw as Orat
join
Orders_Raw as O
on
o.order_id=orat.order_id
join
TotalReviewCustomer as Trc
on
o.Channel=Trc.Channel
where orat.Customer_Satisfaction_Score>3
group by O.Channel,TotalCustomer
order by Loyalty_Percent desc



---------------------------------------------Store_Level_Analysis----------------------------------------

-- 1. What is the traffic per store (i.e., no. of customers per store)?
Select Delivered_StoreID,count(distinct Customer_id) as Traffic
from 
Orders_Raw
group by Delivered_StoreID
order by Traffic desc

-- 2. How are customers spread across regions?

Select Region, count(distinct Customer_id) as Traffic
from
Orders_Raw as o
join
Store_info_Raw as St
on
o.Delivered_StoreID=st.StoreID
group by Region
order by Traffic desc

-- 3. What are the region-wise sales figures?

Select Region,Round(Sum(Total_Amount),2) as Sales
from
Orders_Raw as O
join
Store_info_Raw as st
on
o.Delivered_StoreID= st.StoreID
group by Region
order by Sales desc

-----------------------------------------------OrderPayments_Level---------------------------------------

Select * from Orders_Payment_Raw

-- 1. What is the percentage share of payment types?

Select payment_type, round(Cast((count(order_id)*100.0/(Select count(order_id) from Orders_Payment_Raw)) as numeric(5,2)),2) as OrderShare,
round((sum(payment_value)/(Select sum(payment_value) from orders_payment_raw) )*100.0,2) as SaleShare
from
Orders_Payment_Raw 
group by payment_type

-- 2. What are the total payment values by payment type?
Select payment_type,Cast(sum(payment_value) as numeric(15,2)) as sales
from
Orders_Payment_Raw
group by payment_type

-- 3. What is the state-wise distribution of payment types?

With State_Total_transactions as (
    Select c.customer_state,count(opr.order_id) as TotalStateTransactions
    from
    Orders_Payment_Raw as Opr
    join
    Orders_Raw as O
    on 
    o.order_id= opr.order_id
    join
    Customer_Raw as C
    on
    c.Custid=o.Customer_id
    group by c.customer_state
    )

Select C.customer_state, payment_type, count(opr.order_id) as State_wise_distribution,
cast((count(opr.order_id)*100.0/totalstatetransactions) as numeric(5,2)) as OrderShare

from
Orders_Payment_Raw as Opr
join
Orders_Raw as O
on 
o.order_id= opr.order_id
join
Customer_Raw as C
on
c.Custid=o.Customer_id
join
State_Total_Transactions as St
on
st.customer_state= c.customer_state

group by c.customer_state, payment_type, totalStateTransactions
order by TotalStateTransactions desc, Customer_state, State_wise_distribution desc














--------------------------------------------------------------------------------------------------------------------












