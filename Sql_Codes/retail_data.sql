Create database Retail_Data
use Retail_Data
-----------------------------------------------------------------------------------------------------------------
--Customer

Select count(*) as [rows] from Customer_Raw
Select count(*) as [rows] from Orders_Raw
Select count(*) as [rows] from Products_Info_Raw
Select count(*) as [rows] from Orders_Payment_Raw
Select count(*) as [rows] from OrdersRating_Review_Raw
Select count(*) as [rows] from Store_info_Raw

-----------------------------------------------------------------------------------------------------------------------

Select * into customer_fix from Customer_Raw
Select * into Order_Fix from Orders_Raw
Select * into product_fix from Products_Info_Raw
Select * into order_payment_fix from Orders_Payment_Raw
Select * into orders_review_fix from OrdersRating_Review_Raw
Select * into store_fix from Store_info_Raw

--------------------------------------------------------------------------------------------------------------------------

Select Column_name,Data_type
from
INFORMATION_SCHEMA.COLUMNS
where table_name='customer_raw'

Select Custid, count(*) as duplicate
from 
customer_fix
group by Custid
having count(*)>1
order by duplicate desc

Select * 
from
Customer_Raw
where Custid is null or
	  customer_city is null or
	  customer_state is null or
	  gender is null 

Select distinct Gender
from
Customer_Raw

Select distinct customer_city
from
Customer_Raw

Select distinct customer_state 
from
Customer_Raw

Select customer_state , count(Distinct Customer_city) as CityCountPerState, Count(Distinct Custid) as CustomerCountPerState, 
	   cast((Count(Distinct Custid)*100.0)/count(Distinct Customer_city) as numeric(20,2)) AverageCustomerPerCity
from
Customer_Raw
group by customer_state
order by AverageCustomerPerCity desc


-----------------------------------------------------------------------------------------------------------------
--Orders

Select *
from
Orders_Raw

Select COLUMN_NAME, DATA_TYPE
from
INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Orders_Raw'

Select DATEPART(HOUR,Bill_date_timestamp) as [Hours], Bill_date_timestamp
from
Orders_Raw

Select * 
from
Orders_Raw
where Customer_id is null or
	  product_id is null or
	  order_id is null or
	  Bill_date_timestamp is null or
	  Delivered_StoreID is null or
	  channel is null or
	  Quantity is null or
	  Cost_Per_Unit is null or
	  MRP is null or
	  Discount is null or
	  Total_Amount is null

Select *
from
Orders_Raw
where MRP<Cost_Per_Unit

Select Min(total_amount) as LowerOutlier,  AVG(Total_amount) as mean  ,Max(total_amount) as UpperOutlier
from 
Orders_raw;

With Order_product_id as(
	Select order_id, product_id , count(*) as order_count
	from
	Orders_Raw
	group by order_id, product_id
	Having count(*)>1
	)
	Select o.* ,op.order_count
	from
	Orders_Raw as o
	join
	Order_product_id as op
	on
	o.order_id=op.order_id and
	o.product_id=op.product_id
	order by op.order_count desc
	
WITH Order_product_id AS (
    SELECT order_id, product_id, COUNT(*) AS order_count
    FROM orders_raw
    GROUP BY order_id, product_id
    HAVING COUNT(*) > 1
)

    SELECT o.*, op.order_count
    FROM Orders_Raw AS o
    JOIN Order_product_id AS op
      ON o.order_id = op.order_id 
     AND o.product_id = op.product_id
	 order by order_count desc

Select * 
from
Orders_Raw
where Bill_date_timestamp not  between '2021-09-1' and '2023-10-31'
	
With customer_order_id_issue as ( Select order_id
								  from
								  Orders_Raw
								  group by Order_id
								  Having count(Distinct Customer_id)>1
								  )
Select o.order_id,o.Customer_id,o.product_id,o.Bill_date_timestamp,o.Quantity,o.Channel,o.Delivered_StoreID,o.Cost_Per_Unit,o.MRP,o.Discount,o.Total_Amount
from
Orders_Raw as o
join
customer_order_id_issue as coi
on
o.order_id=coi.order_id 
order by o.order_id,o.Customer_id

 

 With billdate_order_id_issue as ( Select order_id
								  from
								  Orders_Raw
								  group by Order_id
								  Having count(Distinct Bill_date_timestamp)>1
								  )
Select o.order_id,o.Customer_id,o.product_id,o.Bill_date_timestamp,o.Quantity,o.Channel,o.Delivered_StoreID,o.Cost_Per_Unit,o.MRP,o.Discount,o.Total_Amount
from
Orders_Raw as o
join
billdate_order_id_issue as boi
on
o.order_id=boi.order_id 
order by o.order_id,o.Bill_date_timestamp

Select Distinct Channel from Orders_Raw;

 With Channel_order_id_issue as ( Select order_id,Customer_id,Bill_date_timestamp
								  from
								  Order_Fix
								  Where channel='Instore'
								  group by Order_id,Customer_id,Bill_date_timestamp
								  Having count(Distinct Delivered_StoreID)>1
								  )
Select Distinct o.order_id,o.Delivered_StoreID,o.Customer_id,o.Channel,o.Bill_date_timestamp
from
Order_Fix as o
join
Channel_order_id_issue as coi
on
o.order_id=coi.order_id 
order by o.order_id,o.Delivered_StoreID

Select * from Orders_Raw
	
----------------------------------------------------------------------------------------------------------------------------------------------
--Product

Select * from Products_Info_Raw
	 
Select product_id, Count(*) as duplicate
from
Products_Info_Raw
group by product_id
having Count(*)>1
order by duplicate desc
 
 With ProductCountPerCategories as(
	Select Category, count(product_id) as CategoryProductCount
	from
	Products_Info_Raw
	group by Category

	), ProductPerCategoriesOrdered as (
	Select p.Category,Count(distinct o.product_id) as productcount
	from
	Orders_Raw as o
	join
	Products_Info_Raw as p
	on
	o.product_id=p.product_id
	group by p.Category
	)
Select pco.Category,pcc.CategoryProductCount as Availablecount,pco.productcount as orderedcount
from
ProductCountPerCategories as pcc
join
ProductPerCategoriesOrdered as pco
on
pcc.Category=pco.Category
group by pco.Category,pcc.CategoryProductCount,pco.productcount
order by Availablecount desc

Select * from Products_Info_Raw

Select * from
Products_Info_Raw
Where product_description_lenght is null or
	  product_name_lenght is null or
	  product_photos_qty is null or
	  product_weight_g is null or
	  product_length_cm is null or
	  product_height_cm is null or
	  product_width_cm is null or
	  product_description_lenght<=0 or
	  product_name_lenght <=0 or 
	  product_photos_qty <=0 or
	  product_weight_g<=0 or
	  product_length_cm <=0 or
	  product_height_cm <=0 or
	  product_width_cm <=0

Select * from
Products_Info_Raw
Where product_description_lenght <=0 or
	  product_name_lenght <=0 or 
	  product_photos_qty <=0 or
	  product_weight_g<=0 or
	  product_length_cm <=0 or
	  product_height_cm <=0 or
	  product_width_cm <=0

------------------------------------------------------------------------------------------------------------
--Store

Select Distinct Storeid from Store_info_Raw

Select StoreID,count(*) as duplicate
from
Store_info_Raw
group by StoreID
having count(*)>1
order by duplicate desc

Select Distinct seller_city from Store_info_Raw

Select seller_state,Count(Distinct seller_city) as CitiesPerState
from
Store_info_Raw
group by seller_state
order by CitiesPerState desc

Select C.* 
from
Store_info_Raw as st
Right join
Customer_Raw as c
on
st.seller_state=c.customer_state
where st.seller_state is null

Select *
from
Store_info_Raw as st
left join
Customer_Raw as c
on
st.seller_state=c.customer_state
where c.customer_state is null

Select Region,Count(Distinct seller_city) as CitiesPerState
from
Store_info_Raw
group by Region
order by CitiesPerState desc

-------------------------------------------------------------------------------------------------------
--orderrating_reviews
Select * 
from OrdersRating_Review_Raw

Select * 
from OrdersRating_Review_Raw
where order_id is null or
	  Customer_Satisfaction_Score is Null

Select order_id,Customer_Satisfaction_Score,count(*) as duplicate
from
OrdersRating_Review_Raw
group by order_id,Customer_Satisfaction_Score
having count(*)>1
order by duplicate desc

Select order_id,count(*) as duplicate
from
OrdersRating_Review_Raw
group by order_id
having count(*)>1
order by duplicate desc

Select *
from
OrdersRating_Review_Raw as orr
Right join 
Orders_Raw as o
on
orr.order_id=o.order_id
where orr.order_id is null

Select *
from
OrdersRating_Review_Raw as orr
left join 
Orders_Raw as o
on
orr.order_id=o.order_id
where o.order_id is null

-----------------------------------------------------------------------------------------------------
--orders payment

select *
from 
Orders_Payment_Raw

Select *
from 
Orders_Payment_Raw
where order_id is null or
	  payment_type is null or
	  payment_value is null or
	  payment_value<=0
;
With Bill_Amount as (
	Select order_id, Cast(sum(total_amount) as numeric(10,2)) as total_bill
	from
	Orders_Raw
	group by order_id
	), Paid_Amount as (
	Select order_id ,Sum(payment_value) as total_paid
	from
	Orders_Payment_Raw 
	group by order_id)
Select *
from
Bill_Amount as Ba
join

Paid_Amount as Pa
on
Ba.order_id=pa.order_id
where Abs(Total_bill-Total_paid)>2

Select *
from
Orders_Payment_Raw as op
right join
Orders_Raw as o
on
o.order_id=op.order_id
where op.order_id is null

Select *
from
Orders_Payment_Raw as op
left join
Orders_Raw as o
on
o.order_id=op.order_id
where o.order_id is null

------------------------------------------------------Data Cleaning---------------------------------
Select *
from
Order_Fix

Alter table Order_Fix
Alter Column customer_id Varchar(50)

Select COLUMN_NAME ,DATA_TYPE
from
INFORMATION_SCHEMA.columns
where TABLE_NAME ='Order_Fix'

With RedundantColumn as (
	Select *,
	ROW_NUMBER() over (partition by order_id, Product_id,Customer_id order by Quantity desc) as Ranks

	from
	Order_Fix
	)
	Delete o
	from
	Order_Fix as o
	join
	RedundantColumn as rc
	on
	Rc.order_id=o.order_id and
	rc.product_id=o.product_id and
	rc.Customer_id=o.Customer_id and
	rc.Delivered_StoreID=o.Delivered_StoreID and
	Rc.Channel=o.Channel and
	rc.Bill_date_timestamp=o.Bill_date_timestamp 
	Where Ranks!=1
	
		
WITH Order_product_id AS (
    SELECT order_id, product_id, COUNT(*) AS order_count
    FROM Order_Fix
    GROUP BY order_id, product_id
    HAVING COUNT(*) > 1
)

    SELECT o.*, op.order_count
    FROM Order_Fix AS o
    JOIN Order_product_id AS op
      ON o.order_id = op.order_id 
     AND o.product_id = op.product_id
	 order by order_count desc


/*  1687730899	001d8f0e34a38c37f7dba2a37d4eba8b
	2095414187  003324c70b19a16798817b2b3640e721
	8409877817  003f201cdd39cdd59b6447cff2195456
	4636293460	005d9a5423d47281ac463a968b3936fb
*/
	
Delete 
from Order_Fix
where (Customer_id='1687730899' and order_id='001d8f0e34a38c37f7dba2a37d4eba8b') or
	  (Customer_id='2095414187' and order_id='003324c70b19a16798817b2b3640e721') or
	  (Customer_id='8409877817' and order_id='003f201cdd39cdd59b6447cff2195456') or
	  (Customer_id='4636293460' and order_id='005d9a5423d47281ac463a968b3936fb') 

Select * 
from
Order_Fix
where Bill_date_timestamp not  between '2021-09-1' and '2023-10-31'

Delete 
from Order_Fix
where (Customer_id='8278151534' and order_id='13bdf405f961a6deec817d817f5c6624') or
	  (Customer_id='1165186169' and order_id='9c94a4ea2f7876660fa6f1b59b69c8e6') 


/*
Drop table Order_Fix
Select * into Order_Fix from ordersBackup
Select * into ordersBackup from Order_Fix
;
WITH Bill_Amount AS (
    SELECT 
        order_id, 
        CAST(SUM(total_amount) AS NUMERIC(10,2)) AS total_bill
    FROM Order_Fix
    GROUP BY order_id
),
Paid_Amount AS (
    SELECT 
        order_id, 
        Cast(SUM(payment_value) as Numeric(20,2)) AS total_paid
    FROM Orders_Payment_Raw
    GROUP BY order_id
),
Issue_OrderIDs AS (
    SELECT Ba.order_id
    FROM Bill_Amount AS Ba
    JOIN Paid_Amount AS Pa 
        ON Ba.order_id = Pa.order_id
    WHERE ABS(Ba.total_bill - Pa.total_paid) > 2
)
DELETE o
FROM Order_Fix AS o
JOIN Issue_OrderIDs AS i 
    ON o.order_id = i.order_id;

Select Distinct Order_id from Order_Fix
*/

WITH MultiStoreIssue AS (
    SELECT 
        order_id,
        COUNT(DISTINCT Delivered_StoreID) AS StoreCount
    FROM Order_Fix
    WHERE channel = 'Instore'
    GROUP BY order_id
    HAVING COUNT(DISTINCT Delivered_StoreID) > 1
),
RankedOrders AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY Delivered_StoreID ASC
        ) AS StoreRank
    FROM Order_Fix
    WHERE order_id IN (
        SELECT order_id FROM MultiStoreIssue
    ) AND channel = 'Instore'
)
DELETE o
FROM Order_Fix AS o
JOIN RankedOrders AS r 
    ON o.order_id = r.order_id
    AND o.Customer_id = r.Customer_id
    AND o.product_id = r.product_id
    AND o.Bill_date_timestamp = r.Bill_date_timestamp
    AND o.Delivered_StoreID = r.Delivered_StoreID
    AND o.Channel = r.Channel
WHERE r.StoreRank > 1; 

Select * from order_fix

Select * from product_fix
Select Distinct category from product_fix

Update product_fix
set Category='Unclassified'
where Category='#N/A'

Drop table store_fix

Select Distinct * into store_fix
from Store_info_Raw

Select order_id, avg(customer_satisfaction_score) as customer_satisfaction_score into orders_review_fix
from 
OrdersRating_Review_Raw
group by order_id

Select order_id, count(*) duplicacy  from orders_review_fix group by order_id order by count(*) desc

Select orr.* 
from 
orders_review_fix as orr
inner join 
order_fix as o
on o.order_id=orr.order_id
group by o.order_id,orr.order_id,orr.Customer_Satisfaction_Score;

Select orr.*
from
order_fix as o
right join
orders_review_fix as orr
on
o.order_id=orr.order_id
where o.order_id is null



Select o.order_id
from
order_fix as o
left join
orders_review_fix as orr
on
o.order_id=orr.order_id
where orr.order_id is null

With Paid_Amount as(
	Select order_id,
	cast(sum(payment_value) as numeric(30,2) )as Total_Paid
	from
	orders_payment_fix
	group by order_id
	),Amount_ToBe_Paid as
	(Select order_id, cast(sum(total_amount) as numeric(30,2))as Total_bill
	from
	order_fix
	group by order_id)

Select 
	PA.order_id, 
	Total_bill,Total_Paid, 
	(Total_bill-Total_Paid) as Difference,
	
	Case 
		when (Total_bill-Total_Paid)<-5 then 'OverPaid'
		when (Total_bill-Total_Paid)>5 then 'UnderPaid'
		else 'No Problem'
	end as Payment_status

from
	Amount_tobe_paid as Ap
	join
	Paid_amount as PA
	on
	Ap.order_id =PA.order_id

where abs(Total_bill-total_Paid)>5
order by ABS(Total_bill-Total_Paid) desc


Select order_id,product_id, Quantity, count(*) as duplicate
from
order_fix
group by order_id, product_id,Quantity
having count(*)>1
order by duplicate desc

Select * into duplicate_order_fix from order_fix;
Drop table order_fix
Select * into order_fix from duplicate_order_fix;

Select   order_id, count(*) as order_count   from order_fix group by order_id having count(*)>1 

Select customer_id , count(*) as order_count  from order_fix group by Customer_id having count(*)>1


WITH Paid AS (
    SELECT order_id, CAST(SUM(payment_value) AS NUMERIC(30, 2)) AS Total_Paid
    FROM orders_payment_fix
    GROUP BY order_id
),
RowLevelBill AS (
    SELECT 
        o.*, 
        CAST(o.total_amount AS NUMERIC(30,2)) AS Line_Amount
    FROM order_fix o
),
Joined AS (
    SELECT 
        r.*,
        p.Total_Paid,
        COUNT(*) OVER(PARTITION BY r.order_id) AS Product_Count
    FROM RowLevelBill r
    JOIN Paid p ON r.order_id = p.order_id
)

DELETE o
FROM order_fix o
JOIN (
    SELECT 
        order_id, 
        product_id
    FROM Joined
    WHERE ABS(Line_Amount - (Total_Paid / Product_Count)) > 5
) AS faulty
ON o.order_id = faulty.order_id AND o.product_id = faulty.product_id;

Select * from order_fix
Select * from order_
------------------------------
Select * into custormerbackup from customer_fix
select * into orderbackup from order_fix
select * into productbackup from product_fix
select * into storebackup from store_fix
select * into orderratingbackup from orders_review_fix
select * into orderpaymentbackup from order_payment_fix
---------------------------------------------
Delete o 
from
Order_Fix as o
Right join
Customer_Fix as c
on
o.Customer_id=c.Custid
where c.Custid is null

Delete c 
from
Order_Fix as o
left join
Customer_Fix as c
on
o.Customer_id=c.Custid
where o.Customer_id is null

Delete op
from
Order_Fix as o
right join
Orders_Payment_Fix as op
on
o.order_id=op.order_id
where o.order_id is null



update orders_review_fix
set order_id=o.order_id, customer_satisfaction_score=1
from
Order_Fix as o
left join
Orders_Review_Fix as orr
on
o.order_id=orr.order_id
where orr.order_id is null

Delete orr
from
order_fix as o
right join
orders_review_fix as orr
on
o.order_id=orr.order_id
where o.order_id is null

Delete o 
from
Order_Fix as o
right join
Store_fix as st
on
st.StoreID=o.Delivered_StoreID
where st.StoreID is null

Delete st 
from
Order_Fix as o
left join
Store_fix as st
on
st.StoreID=o.Delivered_StoreID
where o.Delivered_StoreID is null


Delete p
from
Order_Fix as o
left join
Product_Fix as p
on
p.product_id=o.product_id
where o.product_id is null
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	With QuarterCount as (
	Select Customer_id,datepart(quarter,bill_date_timestamp) as Quarters, count(*) as orderscount
	from
	Order_Fix
	group by Customer_id, datepart(quarter,bill_date_timestamp)
	), PreferedQuarter as(
	Select *,
	ROW_NUMBER() over (partition by customer_id order by orderscount desc) as Ranks
	from
	quartercount
	),FavQuarter as(
	Select customer_id,Quarters as preferedQuarter
	from
	preferedquarter
	where ranks=1
	),Category as ( 
	select customer_id,category,count(*) as order_count
	from
	Order_Fix as o
	join
	Product_Fix as p
	on
	o.product_id=p.product_id
	group by Customer_id,Category
	),Rankedcategory as(
	Select *,
	ROW_NUMBER() over (partition by customer_id order by order_count desc) as ranks
	from
	Category),Preferecategory as(
	select  Customer_id, Category
	from
	Rankedcategory
	where ranks=1
	), channel as(
	select Customer_id, Channel, count(*) as order_count
	from
	Order_Fix
	group by Customer_id,channel
	),Rankedchannel as(
	Select *,
	ROW_NUMBER() over (partition by customer_id order by order_count desc) as ranks
	from
	channel), preferechannel as(
	Select customer_id, channel as preferedchannel
	from
	Rankedchannel
	where ranks=1),payment_mode as (
	Select Customer_id,op.payment_type,count(*) as order_count
	from
	Order_Fix as o
	join
	Orders_Payment_Fix as op
	on
	o.order_id=op.order_id
	group by customer_id, op.payment_type
	), Rankedmode as(
	Select *,
	ROW_NUMBER() over (partition by customer_id order by order_count desc) as ranks
	from
	payment_mode),preferedMode as(
	Select Customer_id,payment_type as preferedmode
	from
	Rankedmode
	where ranks=1
	),Nighthawk_Dawnsparrow as(
	Select Customer_id, case 
							when datepart(hour,bill_date_timestamp)>22 or datepart(hour,bill_date_timestamp)<06 then 'NightHawk'
							else 'DawnSparrow'
						end as ActiveType, count(*) as order_count
	from
	Order_Fix
	group by Customer_id,case 
							when datepart(hour,bill_date_timestamp)>22 or datepart(hour,bill_date_timestamp)<06 then 'NightHawk'
							else 'DawnSparrow'
						end
	), RankedType as (
	Select *,
	ROW_NUMBER() over (partition by  customer_id order by order_count desc) as ranks
	from
	Nighthawk_Dawnsparrow), preferedtype as(
	Select
	customer_id, ActiveType 
	from
	Rankedtype
	where 
	ranks=1
	), 
	Region as (
    select o.Customer_id, st.Region, count(*) as order_count
    from Order_Fix o
    join Store_Fix st on o.Delivered_StoreID = st.StoreID
    group by o.Customer_id, st.Region
),
RankedRegion as (
    select *,
           row_number() over (partition by customer_id order by order_count desc) as rnk
    from Region
),
FinalRegion as (
    select customer_id, Region
    from RankedRegion
    where rnk = 1
),PaymentSummary AS (
  SELECT 
    o.order_id, 
    SUM(op.payment_value) AS payment_value,
    MAX(CASE WHEN DATEPART(weekday, o.bill_date_timestamp) IN (1, 7) THEN 1 ELSE 0 END) AS is_weekend
  FROM Orders_Payment_Fix op
  JOIN Order_Fix o ON o.order_id = op.order_id
  GROUP BY o.order_id
)





Select 	
			c.custid,
			c.Gender,
			c.customer_city,
			c.customer_state,
			fr.Region,

			count(Distinct o.order_id) as ordercount,

			Sum(Distinct ps.payment_value) as Totalspent,

			SUM(
			CASE
				WHEN ps.is_weekend = 1 THEN ps.payment_value 
				ELSE 0 
			END) AS WeekSpent,
 
					
			AVG(ps.payment_value)  as averagespent,

			min(convert(Date,o.bill_date_timestamp,101)) as firstorderdate,

			max(convert(Date,o.bill_date_timestamp,101)) as lastorderdate,

			case 
				when max(convert(Date,o.bill_date_timestamp,101))>Dateadd(month,-6,(Select max(bill_date_timestamp) from Order_Fix)) then 'Active'
				else 'Inactive'
			end as customerstatus,


			
			Case 
				when fq.preferedQuarter!=1 then fq.preferedQuarter-1
				else 4
			end as Preferedquarter,
			pc.Category as preferedcategory,
			pch.preferedchannel,
			pm.preferedmode,
			pt.Activetype,
			avg(
			case
				when o.order_id=orr.order_id then orr.Customer_Satisfaction_Score
			end) as averagerating

	into customer1_360

	from Customer_Fix as c
	left join Order_Fix as o on c.Custid = o.Customer_id
	left join FinalRegion as fr on fr.Customer_id = c.Custid
	left join PaymentSummary as ps on ps.order_id = o.order_id
	left join FavQuarter as fq on fq.Customer_id = c.Custid
	left join Preferecategory as pc on pc.Customer_id = c.Custid
	left join preferechannel as pch on pch.Customer_id = c.Custid
	left join preferedMode as pm on pm.Customer_id = c.Custid
	left join preferedtype as pt on pt.Customer_id = c.Custid
	left join Orders_Review_Fix as orr on orr.order_id = o.order_id

	
	

	group by c.Custid,c.Gender, c.customer_city,c.customer_state,fr.Region,fq.preferedQuarter,pc.Category,pch.preferedchannel,pm.preferedmode,pt.ActiveType
	
	Select* from customer1_360

	Select * from customer1_360 where custid is null or
								 gender is null or
								 customer_city is null or
								 region is null or
								 ordercount is null or
								 totalspent is null or
								 WeekSpent is null or
								 averagespent is null or
								 firstorderdate is null or
								 lastorderdate is null or
								 customerstatus is null or
								 Preferedquarter is null or
								 preferedcategory is null or
								 preferedchannel is null or
								 preferedmode is null or
								 ActiveType is null or
								 averagerating is null


With Payment_mode as (Select op.order_id,op.payment_type,count(*) as mode_count
	  from
	  Orders_Payment_Fix as Op
	  
	  group by op.order_id,op.payment_type
	  ),
	  
	  RankedMode as (
	  Select *,
	  ROW_NUMBER() over (partition by order_id order by mode_count desc) as Ranks
	  from
	  Payment_mode),preferedmode as(
	  Select order_id, payment_type as preferedmode
	  from
	  RankedMode
	  where ranks=1
	  ),
	  
	  total_amount_per_order as (
	  Select order_id , sum(total_amount) as total_amount
	  from
	  Order_Fix 
	  group by order_id
	  ),
	  
	  preferedmode_amount as(
	  Select op.order_id,sum(op.payment_value) as Mode_amount
	  from
	  preferedmode as pm
	  join
	  Orders_Payment_Fix as op
	  on
	  op.order_id=pm.order_id and op.payment_type=pm.preferedmode
	  group by op.order_id
	  ),
	  
	  Total_discount_per_order as (
	  Select order_id, sum(discount) as totaldiscount 
	  from
	  Order_Fix 
	  group by order_id
	  ), 
	  
	Region as (
	select o.Customer_id, st.Region, count(*) as order_count
	from Order_Fix o
	join Store_Fix st on o.Delivered_StoreID = st.StoreID
	group by o.Customer_id, st.Region
	),
	RankedRegion as (
	select *,
	       row_number() over (partition by customer_id order by order_count desc) as rnk
	from Region
	),
	FinalRegion as (
	select customer_id, Region
	from RankedRegion
	where rnk = 1
	),
	  
	Channel as( 
	Select order_id,Channel,count(*) as order_count
	from
	Order_Fix 
	group by order_id,channel
	),
	
	Rankedchannel as (
	Select *,
	ROW_NUMBER() over (partition by order_id order by order_count desc) as Ranks
	from
	Channel),
	
	preferedchannel as (
	Select order_id, channel
	from
	Rankedchannel
	where ranks=1
	)



					
		Select 

						o.order_id,
						
						c.Custid,
						c.Gender,
						pc.Channel as preferedchannel,

						count(distinct p.product_id) as distinctproductcount,
						count(distinct o.Delivered_StoreID) as distinctstorecount,
						count(distinct p.Category) as distinctcategorycount,

						c.customer_city as customercity,
						st.seller_city as StoreCity,
						Case
							when c.customer_city=st.seller_city then 'IntraCity'
							else 'InterCity'
						end as Inter_Intra_City,

						c.customer_state as customerstate,
						st.seller_state as sellerstate,
						Case 
							when c.customer_state=st.seller_state then 'IntraState'
							else 'InterState'
						end as Inter_Intra_State,

						fr.Region as customerregion,
						st.Region as storeregion,
						Case 
							when fr.Region=St.Region then 'IntraRegion'
							else 'InterRegion'
						end As Inter_Intra_Region,

						tdo.totaldiscount as Totaldiscount,
						tao.total_amount as TotalAmount,
						pm.preferedmode as preferedmode,
						(pmm.Mode_amount*100.0)/tao.total_amount  as preferedmodepercent,
						Case
							when Datepart(weekday,o.bill_date_timestamp) not in (1,7) then 'Weekday'
							else 'Weekend'
						end as Week_day_end,
						Datepart(hour,o.bill_date_timestamp) as Orderhour,
						case 
							when Datepart(hour,o.bill_date_timestamp)>6 and Datepart(hour,o.bill_date_timestamp)<22
							then 'Day'
							else 'Night'
						end as night_day,
						case
							when Datepart(quarter, o.bill_date_timestamp)!=1 then Datepart(quarter,o.bill_date_timestamp)-1
							else 4
						end as Quarters,
						orr.Customer_Satisfaction_Score as Satisfaction_score
						 


into orders_360										

from
Order_Fix as o
left join
Customer_Fix as c
on
o.Customer_id=c.Custid
left join
total_amount_per_order as TAO
on
tao.order_id=o.order_id
left join
Store_fix as st
on
st.StoreID = o.Delivered_StoreID
left join 
Orders_Payment_Fix as op
on
op.order_id=o.order_id
left join
Orders_Review_Fix as orr
on
orr.order_id=o.order_id
left join
Product_Fix as p
on
p.product_id= o.product_id
left join
preferedmode as pm
on
pm.order_id=o.order_id
left join
preferedmode_amount as pmm
on
pmm.order_id=o.order_id
left join
Total_discount_per_order as Tdo
on
o.order_id=tdo.order_id
left join
FinalRegion as fr
on
fr.Customer_id=c.Custid
left join
preferedchannel as pc
on
pc.order_id=o.order_id

group by o.order_id,c.custid,o.bill_date_timestamp,orr.Customer_Satisfaction_Score,c.gender,c.customer_city,st.seller_city,c.customer_state, st.seller_state,fr.Region,st.region,pm.preferedmode,pmm.Mode_amount,tao.total_amount,tdo.totaldiscount, pc.Channel


Select * from orders_360 where 
									order_id is null or 
									custid is null or
									gender is null or
									preferedchannel is null or
									distinctproductcount is null or
									distinctstorecount is null or
									distinctcategorycount is null or
									customercity is null or
									StoreCity is null or
									customerstate is null or
									sellerstate is null or
									customerregion is null or
									storeregion is null or
									totaldiscount is null or
									totalamount is null or 
									preferedmode is null or
									preferedmodepercent is null or 
									week_day_end is null or
									orderhour is null or
									night_day is null or
									Quarters is null or
									satisfaction_score is null









With Category as (
				  Select StoreID,Category,count(*) as Productscount
				  from
				  Store_fix as st
				  join
				  Order_Fix as o
				  on
				  o.Delivered_StoreID=st.StoreID
				  join
				  Product_Fix as p
				  on
				  p.product_id=o.product_id

				  group by StoreID, Category
				  ),RankedCategory as (
				  Select * ,
				  ROW_NUMBER() over (partition by storeid order by productscount desc) as ranks
				  from
				  Category
				  ), most_sold_category as (
				  Select Storeid, Category
				  from
				  RankedCategory
				  where ranks=1
				  ),Quarters as ( 
				  Select Delivered_StoreID, DATEPART(quarter, bill_date_timestamp) as Quarters, count(*) as order_count
				  from 
				  Order_Fix as o
				  group by Delivered_StoreID, DATEPART(QUARTER,bill_date_timestamp)
				  ),CountRankedQuart as (
				  Select *,
				  ROW_NUMBER() over (partition by Delivered_storeid order by order_count desc) as ranks
				  from
				  Quarters), PeakOrdersQuarter as (
				  Select Delivered_StoreID,Quarters
				  from
				  CountRankedQuart
				  where ranks=1), payment_type as (
				  Select o.Delivered_StoreID, op.payment_type, count(op.order_id) as payment_count
				  from
				  Order_Fix as o
				  join
				  Orders_Payment_Fix as op
				  on
				  o.order_id=op.order_id
				  group by o.Delivered_StoreID, op.payment_type
				  ),rankedPayment as (
				  Select * ,
				  ROW_NUMBER() over (partition by Delivered_storeid order by payment_count desc) as ranks
				  from payment_type), MostPreferredMode as (
				  Select Delivered_StoreID,payment_type
				  from
				  rankedPayment
				  where ranks=1
				  ),Hrs as (
				  Select Delivered_StoreID, Datepart(hour,bill_date_timestamp) as Hrs, count(*) as order_count
				  from
				  Order_Fix as o
				  group by Delivered_StoreID,Datepart(hour,bill_date_timestamp)
				  ), RankedHrs as(
				  Select *,
				  ROW_NUMBER() over (partition by Delivered_storeid order by order_count desc) as ranks
				  from
				  hrs), MostActiveHrs as (
				  Select 
				  Delivered_StoreID , Hrs
				  from
				  RankedHrs
				  where ranks=1)
				  

Select				st.StoreID,
					st.seller_city,
					st.seller_state,
					st.Region,

					count(Distinct 
					Case
						when st.StoreID=o.Delivered_StoreID then o.order_id
						else Null
					end) as total_orders,

					count(Distinct 
					Case
						when st.StoreID=o.Delivered_StoreID then  o.customer_id
						else Null
					end) as total_customers_served,

					Sum(
					Case
						when st.StoreID=o.Delivered_StoreID then o.Total_Amount
					end) as Total_Revenue,

					Sum(
					Case
						when st.StoreID=o.Delivered_StoreID then o.Discount
					end) as Total_discount_given,

					Avg(
					Case
						when st.StoreID=o.Delivered_StoreID then o.Total_Amount
					end) as avg_order_value,

					msc.Category as most_sold_category,
					
					Count(Distinct
					Case
						when o.Delivered_StoreID=st.StoreID then o.product_id
					end) as total_products_sold,

					poq.Quarters as peak_quarter,

					Avg(
					Case
						when o.Delivered_StoreID=st.StoreID then orr.Customer_Satisfaction_Score*1.0
					end) as Avg_customer_satisfaction,
					mpm.payment_type as most_preferred_payment_method,
					Mah.Hrs as most_active_hours

into store_360
from
Store_fix as st
join
Order_Fix as o
on
st.StoreID=o.Delivered_StoreID
join 
most_sold_category as Msc
on
Msc.StoreID=st.StoreID
join
Orders_Review_Fix as orr
on
orr.order_id=o.order_id
join
PeakOrdersQuarter as poq
on
poq.Delivered_StoreID=st.StoreID
join
MostPreferredMode as mpm
on
mpm.Delivered_StoreID=st.StoreID
join
MostActiveHrs as MaH
on
MaH.Delivered_StoreID=st.StoreID

group by st.StoreID, st.seller_city,st.seller_state,st.Region,msc.Category,poq.Quarters, mpm.payment_type,Mah.Hrs
order by total_customers_served desc

Select * from store_360 where storeid is null or
							 seller_city is null or
							 seller_state is null or
							 Region is null or
							 total_orders is null or
							 total_customers_served is null or
							 total_discount_given is null or
							 total_revenue is null or
							 avg_order_value is null or
							 most_sold_category is null or
							 total_products_sold is null or
							 peak_quarter is null or
							 Avg_customer_satisfaction is null or
							 most_preferred_payment_method is null or
							 most_active_hours is null

Drop table customer1_360


Select * from customer_360

Select * from orders_360

Select * from store_360

-- Numbers of orders
Select sum(ordercount) as total_orders
from
customer_360

-- Total Discount
Select sum(Totaldiscount) as Total_discount
from
orders_360

-- Average Discount per customer/per order
Select ((Select sum(Totaldiscount) as Total_discount
from
orders_360)*1.0/Count(*)) as Average_Discount_Per_Customer
from
customer_360

-- Average Discount per order
Select ((Select sum(Totaldiscount) as Total_discount
from
orders_360)*1.0/Count(*)) as Average_Discount_Per_Order
from
orders_360

-- Average Sale Value per customer
Select ((Select sum(TotalAmount) as Total_discount
from
orders_360)*1.0/Count(*)) as Average_Bill_Per_Customer
from
customer_360

-- Average Bill Value per order
Select ((Select sum(TotalAmount) as Total_discount
from
orders_360)*1.0/Count(*)) as Average_Discount_Per_Order
from
orders_360

-- Average Category per order
Select
AVG(distinctcategorycount*1.00000000000) as Average_Category_Per_Order
from
orders_360

-- Average Item per order
Select
AVG(distinctproductcount*1.000000000000) as Average_Category_Per_Order
from
orders_360

--Number of customers
Select Count(*) as Customers_count
from
customer_360

-- Average Transaction per customer
Select AVG(ordercount*1.00000000000) as Average_Transaction_Per_Customer
from
customer_360

-- Total Revenue
Select Sum(Totalspent) as Revenue
from
customer_360

Select Sum(TotalAmount) as Revenue
from
orders_360

Select sum(total_Revenue) as Revenue
from
store_360

-- Total Product 
Select sum(distinctproductcount) as Total_Product
from
orders_360

-- Total Categories
Select sum(distinctcategorycount) as Total_Category
from
orders_360

-- Total Stores
Select Count(*) total_stores
from
store_360

-- Percent Discount
Select (sum(Totaldiscount)*100.00/sum(TotalAmount)) Percent_Discount
from
orders_360

-- Repeat Purchase Percent
Select 
   ((Select Count(*) as RepeatPurshase
	from
	customer_360
	where ordercount>1)*100.0)/count(*) as RepeatPurchasePercent
from
customer_360

-- one time buyer
Select 
   ((Select Count(*) as OneTimerCustomer
	from
	customer_360
	where ordercount=1)*100.0)/count(*) as OneTimerCustomerPercent
from
customer_360

-- New customer per month

Select * from customer_360

Select Format(firstorderdate,'M/yyyy') month_year, count(*) as new_customer_per_month
from
customer_360
group by Year(firstorderdate), Month(firstorderdate),Format(firstorderdate,'M/yyyy')
order by Year(firstorderdate), Month(firstorderdate)

-- Existing/new customer revenue monthly

Select Format(firstorderdate,'M/yyyy') month_year, sum(Totalamount)
from
customer_360 as c
join
orders_360 as o
on
c.custid=o.Custid
/*Date column bana in orders_360*/

group by Year(firstorderdate), Month(firstorderdate),Format(firstorderdate,'M/yyyy')
order by Year(firstorderdate), Month(firstorderdate)

--Adding Date column in orders_360
Alter Table orders_360
Add Order_date Datetime

Update o360
set o360.order_date=o.Bill_date_timestamp
from
orders_360 as o360
join
order_fix as o
on
o360.order_id=o.order_id

-- Adding Profit column

Alter Table orders_360
Add Total_Profit float

Update o360
set o360.total_profit=o.Total_Amount-(o.Cost_Per_Unit*o.Quantity)
from
orders_360 as o360
join
order_fix as o
on
o360.order_id=o.order_id

Select * from orders_360
order by total_profit desc

-- Adding profit columns in customer_360

Alter table customer_360
add total_profit float

With Cust_Profit as (
	Select
		Custid, Sum(Total_Profit) as Total_Profit_sum
	from
	orders_360
	group by Custid)

update c
set c.total_profit=cp.Total_Profit_sum 
from
customer_360 as c
join
Cust_Profit as cp
on
c.custid=cp.Custid


--Average profit per customer
Select avg(Total_Profit) Average_Profit_per_customer
from
customer_360

Select avg(total_profit) average_profit_per_order
from
orders_360

-- Total Profit
Select Sum(Total_Profit) Total_Profit
from
customer_360

Select Sum(Totalspent)
from
customer_360

-- Adding Total_Cost
Alter table orders_360
add Total_Cost Float

With cost_per_order as (
	Select order_id,sum(Cost_Per_Unit*Quantity) as cost
	from
	order_fix
	group by order_id
	)
Update o_360
set Total_cost=Co.cost
from
orders_360 as o_360
join
cost_per_order as co
on
o_360.order_id=co.order_id


-- Total Cost
Select sum(Total_cost) as Total_Cost
from
orders_360 

--Add Total Quantity in order_360/customer360
alter table orders_360
add total_Quantity int

alter table customer_360
add total_Quantity int

With Quantity_per_order as(
	Select order_id, sum(Quantity) as Quantity_per_order
	from
	order_fix
	group by order_id)
Update o
set Total_quantity= q.quantity_per_order
from
orders_360 as o
join
quantity_per_order as q
on
o.order_id=q.order_id







With Quantity_per_customer as(
	Select Customer_id, sum(Quantity) as Quantity_per_customer
	from
	order_fix
	group by Customer_id)
update c
set Total_Quantity= q.Quantity_per_customer
from
customer_360 as c
join
Quantity_per_customer as q
on
c.custid=q.Customer_id

-- Total Quantity 

Select Sum(Total_Quantity) TotalQuantity from orders_360
Select Sum(Total_Quantity) TotalQuantity from customer_360

-- Total store count
Select sum(distinctstorecount) as Total_store_count
from
orders_360

-- Adding Distinct Region per order.
alter table orders_360
add DistinctRegion Int

--Average number of days between two transactions


With RankedDate as(
	Select custid,Cast(order_date as date )as OrderDate ,
	ROW_NUMBER() over (partition by custid order by order_date desc) as Ranks
	from
	orders_360
	group by Custid, order_date
), Average_Days as ( 
	Select a.custid,Avg(DATEDIFF(Day,A.orderDate,B.orderDate)) as Average_Days
	from 
	RankedDate a
	join
	rankeddate b
	on
	a.custid=b.custid and a.ranks=B.Ranks+1
	group by a.custid
	)
Select *
from
Average_Days


--percent profit
Select (sum(Total_profit)*100.00/Sum(TotalAmount)) as percent_Profit
from
orders_360

--percent Discount
Select (sum(TotalDiscount)*100.00/Sum(TotalAmount)) as percent_Discount
from
orders_360

Select * from orders_360
Select * from customer_360

-- Repeat Customer Rate per month
With Repeat_new_Customer as (
	Select 
	o.custid, Format(Cast(order_date as Date), 'MM/yyyy') as month_year, 
					Case
						When Format(c.firstorderdate,'MM/yyyy')=Format(Cast(order_date as Date), 'MM/yyyy')
						then'New customer'
						else'Repeat customer'
					end as Customer_Type

	from
	orders_360 as o
	join
	customer_360 as c
	on
	c.custid=o.custid
	), Monthly_Customer_counts as (
	Select month_year, 
	count(distinct custid) as Total_Customers,
	count(distinct case when Customer_Type = 'Repeat customer' then custid end) as Repeat_Customers
	from Repeat_new_Customer
	group by month_year
	)
	Select month_year,
	Repeat_Customers,
	Total_Customers,
	CAST(Repeat_Customers * 100.0 / Total_Customers AS DECIMAL(5,2)) as Repeat_Customer_Rate
from Monthly_Customer_Counts


-- Cross selling category
With OrderCategories as (
	Select o360.order_id, p.Category
	from
	orders_360 as o360
	join
	order_fix as o
	on
	o360.order_id=o.order_id
	join
	product_fix as p
	on
	o.product_id=p.product_id
	group by o360.order_id,p.Category
	),CategoryPair as(
	Select
		a.category as category1,
		b.category as category2
	from
	OrderCategories as a
	join
	OrderCategories as b
	on
	a.order_id=b.order_id and a.category< b.category
	)
	Select category1, category2, count(*) as Frequency
	from
	CategoryPair
	group by category1,category2
	order by Frequency desc

-- top 10 expensive products
 
With top_10_product as (
	Select top 10 a.order_id,b.product_id,b.MRP,a.TotalAmount
	from
	orders_360 as a
	join
	order_fix as b
	on
	a.order_id=b.order_id
	group by a.order_id,b.product_id,b.MRP, a.TotalAmount
	order by B.MRP desc)
	
	Select Sum(TotalAmount)*100.00/(Select sum(totalamount) as total_sales from orders_360) as Sales_Percent_Contribution
	
	from
	top_10_product

-- Categories Rating
Select p.Category, cast(avg(orr.customer_satisfaction_score*1.0) as float) as averageRating
from
product_fix as p
join
order_fix as o
on
p.product_id=o.product_id
join
orders_review_fix as orr
on
orr.order_id=o.order_id
group by p.Category
order by averageRating desc

-- Average rating per city , state , region

Select Inter_Intra_City as Inter_Intra_City_Sate_Region,avg(satisfaction_score*1.0) as Avgrating
from
orders_360
group by Inter_Intra_City

union all
Select Inter_Intra_State,avg(satisfaction_score*1.0) as Avgrating
from
orders_360
group by Inter_Intra_State

union all
Select Inter_Intra_Region,avg(satisfaction_score*1.0) as Avgrating
from
orders_360
group by Inter_Intra_Region