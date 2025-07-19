Create Database metadata
use metadata

Select * from Customer_Raw
Select * from Orders_Raw
Select * from Products_Info_Raw
Select * from Store_info_Raw
Select * from Orders_Payment_Raw
Select * from OrdersRating_Review_Raw

Alter Table Orders_Raw
Add FixDateTime DateTime

Update Orders_Raw
Set FixDateTime= Convert(DateTime,Bill_Date_timestamp,101)

Alter Table Orders_Raw
Drop column Bill_Date_Timestamp

With RankedOrders as(
	Select *, 
	ROW_NUMBER() over (partition by Order_id, Product_id, Customer_id, Channel,Delivered_StoreID, FixDateTime order by Quantity Desc) as Ranks
	
	from Orders_Raw
	)
Delete O
from
Orders_Raw as O
join
RankedOrders as RaO
On
	O.order_id=Rao.order_id And
	O.product_id=Rao.product_id And
	O.Customer_id=Rao.Customer_id And
	O.Channel=Rao.channel And
	O.Delivered_StoreID=Rao.Delivered_StoreID And
	O.fixDateTime=Rao.FixDateTime
Where 
Ranks!=1


Delete
from
Products_Info_Raw
where Category='#N/A'

Select Distinct Category
from
Products_Info_Raw



Select *
from
Products_Info_Raw

Delete p
from
Products_Info_Raw as P
left join
Orders_Raw as O
on
p.product_id=o.product_id
where o.product_id is null

Delete o
from 
Orders_Raw as o
left join
Products_Info_Raw as p
on
o.product_id=p.product_id
where p.product_id is null



With RankedOrders as
	(Select *,
	ROW_NUMBER() over (Partition by Customer_id, order_id, Product_id Order by Quantity) as Ranks
	from
	Orders_Raw
	)
Select *
from
RankedOrders
Where Ranks > 1


With RankedOrders as
	(Select *,
	ROW_NUMBER() over (Partition by Customer_id, order_id Order by Delivered_Storeid) as Ranks
	from
	Orders_Raw
	)
Select *
from
RankedOrders
where Ranks>1

With RankedOrders as
	(Select *,
	ROW_NUMBER() over (Partition by order_id, Product_id Order by Delivered_Storeid) as Ranks
	from
	Orders_Raw
	)
Select *
from
RankedOrders
where Ranks>1


Select *
from
Orders_raw
where order_id in ('001d8f0e34a38c37f7dba2a37d4eba8b','003324c70b19a16798817b2b3640e721'
					,'003f201cdd39cdd59b6447cff2195456','005d9a5423d47281ac463a968b3936fb')





With Issue as(
	Select Distinct order_id
	from
	Orders_raw
	where order_id in ('001d8f0e34a38c37f7dba2a37d4eba8b','003324c70b19a16798817b2b3640e721'
						,'003f201cdd39cdd59b6447cff2195456','005d9a5423d47281ac463a968b3936fb')
	
	), RankedIssue as
	(Select o.*,
	ROW_NUMBER() over (partition by o.order_id,  o.total_amount order by O.Total_Amount desc) Ranks
	from Orders_Raw as O
	join
	issue as I
	on
	o.order_id=i.order_id 
	)
Select ri.*
from
Orders_Raw as O
join
RankedIssue as ri
on
o.order_id=ri.order_id



Delete from Orders_Raw
where (order_id='001d8f0e34a38c37f7dba2a37d4eba8b' and Customer_id='1687730899') or
	  (order_id='003324c70b19a16798817b2b3640e721' and Customer_id='2095414187') or
	  (order_id='003f201cdd39cdd59b6447cff2195456' and Customer_id='8409877817')

Select Distinct* 
from Orders_Raw
-----------------------------------------------------------Orders is cleaned----------------------------------------


delete C 
from 
Customer_Raw as C
left join
Orders_Raw as o
on 
c.Custid=o.Customer_id
where o.Customer_id is null

Delete Op
from
Orders_Payment_Raw as Op
left join
Orders_Raw as o
on
op.order_id	= o.order_id
where o.order_id is null

Delete Orr
from
OrdersRating_Review_Raw as Orr
left join
Orders_Raw as o
on
o.order_id=orr.order_id
where o.order_id is null

Delete St
from
Store_info_Raw as st
left join
Orders_Raw as o
on
o.Delivered_StoreID=st.StoreID
where o.Delivered_StoreID is null





--- final data check
Select Custid, count(*) dulicate
from
Customer_Raw
group by Custid
having count(Custid)>1
order by dulicate desc
---- customer is okay

Select order_id,Customer_Satisfaction_Score ,count(*) as Faulty
from
OrdersRating_Review_Raw
group by order_id, Customer_Satisfaction_Score
having count(order_id) >1
order by Faulty desc

With RankedScore as(
	Select *,
	ROW_NUMBER() over (partition by order_id order by customer_Satisfaction_score ) as Ranks
	from
	OrdersRating_Review_Raw
	)
Delete Orr
from
OrdersRating_Review_Raw as Orr
join
RankedScore as Rs
on
Orr.order_id=Rs.order_id
where Ranks!=1





With Paid_Amount as(
	Select order_id,
	cast(sum(payment_value) as numeric(30,2) )as Total_Paid
	from
	Orders_Payment_Raw
	group by order_id
	),Amount_ToBe_Paid as
	(Select order_id, cast(sum(total_amount) as numeric(30,2))as Total_bill
	from
	Orders_Raw
	group by order_id),Payment_Status as

	(Select PA.order_id, Total_bill,Total_Paid, (Total_bill-Total_Paid) as Difference,
		
		Case 
			when (Total_bill-Total_Paid)<-1 then 'OverPaid'
			when (Total_bill-Total_Paid)>1 then 'UnderPaid'
			else 'No Problem'
		end as PaymentStatus
	
	from
	Amount_tobe_paid as Ap
	join
	Paid_amount as PA
	on
	Ap.order_id =PA.order_id
	
	where Abs(Total_bill-Total_paid)>1
	
	)
Select PaymentStatus, count(paymentStatus) as Issues_count,Sum(abs(Difference)) as Issue_Worth
from Payment_Status
group by PaymentStatus
Order by Issues_count desc

Select * 
into Orders_Backup
from
Orders_Raw

Select * from Orders_Backup

Select * into 
Orders_Raw 
from
Orders_Backup



	

	
	
With Paid_Amount as(
	Select order_id,
	cast(sum(payment_value) as numeric(30,2) )as Total_Paid
	from
	Orders_Payment_Raw
	group by order_id
	),Amount_ToBe_Paid as
	(Select order_id, cast(sum(total_amount) as numeric(30,2))as Total_bill
	from
	Orders_Raw
	group by order_id),Payment_Status as

	(Select PA.order_id, Total_bill,Total_Paid, (Total_bill-Total_Paid) as Difference,
		
		Case 
			when (Total_bill-Total_Paid)<-1 then 'OverPaid'
			when (Total_bill-Total_Paid)>1 then 'UnderPaid'
			else 'No Problem'
		end as PaymentStatus
	
	from
	Amount_tobe_paid as Ap
	join
	Paid_amount as PA
	on
	Ap.order_id =PA.order_id
	
	where Abs(Total_bill-Total_paid)>1
	
	)
Select * into
error
from Payment_Status


Delete O
from 
Orders_Raw as O
join
error as E
On
O.order_id=E.order_id

Select Storeid , count(*) as duplicate
from
Store_fix
group by storeid
having count(*) >1
order by duplicate desc

Drop table Store_fix


With DistinctStore as(
	Select Distinct *
	from 
	Store_info_Raw
	)
Select * into
Store_fix
from DistinctStore


-------------------------------------------------------everything is perfectly cleaned-----------------------------

-- Select * into Customer_Fix from Customer_Raw
-- Select * into Order_Fix from Orders_Raw
-- Select * into Product_Fix from Products_Info_Raw
-- Select * into Store_Fix from Store_info_Raw
-- Select * into Orders_Payment_Fix from Orders_Payment_Raw
-- Select * into Orders_Review_Fix from OrdersRating_Review_Raw

Select * from Customer_Fix
Select * from Order_Fix

Delete C
from
Customer_Fix as C
left join
Order_Fix as O
on
C.Custid=o.Customer_id
where o.Customer_id is null

Delete Op
from
Orders_Payment_Fix as Op
left join
Order_Fix as O
on
op.order_id=o.order_id
where o.order_id is null

Delete Orr
from
Orders_Review_Fix as Orr
left join
Order_Fix as O
on
orr.order_id=o.order_id
where o.order_id is null

Delete St
from
Store_fix as St
left join
Order_Fix as o
on
st.StoreID=o.Delivered_StoreID
where o.Delivered_StoreID is null

Delete P
from
Product_Fix as P
left join
Order_Fix as O
on
P.product_id=o.product_id
where o.product_id is null

Select * from Customer_Fix
Select * from Order_Fix

Select * from Product_Fix
Select * from Store_fix


Select * from Orders_Payment_Fix


Select * from Orders_Review_Fix



	

------------------------------------------------EDA------------------------------------------------------------------------------
Drop table Customer_360
drop table customer_360backup


Create Table Customer_360 (
	customer_id varchar(50),
	gender varchar(50),
	city varchar(50),
	region varchar(50),
	ordercount Int,
	totalspent float,
	Weekend float,
	averagespent float,
	firstorderdate Date,
	lastorderdate Date,
	customerstatus varchar(50),
	preferedquater varchar(50),
	preferedcateagory varchar(50),
	preferedchannel varchar(50),
	preferedpaymentmode varchar(50),
	activetime varchar(50),
	averagerating float

	)

Select * into customer_360backup from customer_360	


With QuarterCount as (
	Select Customer_id,datepart(quarter,FixDateTime) as Quarters, count(*) as orderscount
	from
	Order_Fix
	group by Customer_id, datepart(quarter,fixdatetime)
	), PreferedQuarter as(
	Select *,
	ROW_NUMBER() over (partition by customer_id order by orderscount desc) as Ranks
	from
	quartercount
	)
	Select customer_id,Quarters as preferedQuarter
	from
	preferedquarter
	where ranks=1


	With Category as ( 
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
	Category)
	select  Customer_id, Category
	from
	Rankedcategory
	where ranks=1



	With channel as(
	select Customer_id, Channel, count(*) as order_count
	from
	Order_Fix
	group by Customer_id,channel
	),Rankedchannel as(
	Select *,
	ROW_NUMBER() over (partition by customer_id order by order_count desc) as ranks
	from
	channel)
	Select customer_id, channel as preferedchannel
	from
	Rankedchannel
	where ranks=1



Insert Into Customer_360(
	customer_id,
	gender,
	city,
	region,

	ordercount,
	totalspent,
	Weekend,
	averagespent,
	firstorderdate,
	lastorderdate,
	customerstatus,


	preferedquater,
	preferedcateagory,
	preferedchannel,
	preferedpaymentmode,
	activetime,
	averagerating
	);
With QuarterCount as (
	Select Customer_id,datepart(quarter,FixDateTime) as Quarters, count(*) as orderscount
	from
	Order_Fix
	group by Customer_id, datepart(quarter,fixdatetime)
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
							when datepart(hour,FixDateTime)>22 or datepart(hour,FixDateTime)<06 then 'NightHawk'
							else 'DawnSparrow'
						end as ActiveType, count(*) as order_count
	from
	Order_Fix
	group by Customer_id,case 
							when datepart(hour,FixDateTime)>22 or datepart(hour,FixDateTime)<06 then 'NightHawk'
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
	ranks=1)
	


	

	
Select 	
			c.custid,
			c.Gender,
			c.customer_city,
			st.Region,

			count(Distinct o.order_id) as ordercount,
			Sum(op.payment_value) as Totalspent,
			sum(case
					when datepart(weekday,o.fixdatetime) = 1 or datepart(weekday,o.fixdatetime)=7 then op.payment_value
					else 0
				end) as WeekSpent,
					
			sum(op.payment_value)*1.0/count(distinct o.order_id)  as averagespent,
			min(convert(Date,o.fixdatetime,101)) as firstorderdate,
			max(convert(Date,o.fixdatetime,101)) as lastorderdate,
			case 
				when max(convert(Date,o.fixdatetime,101))>Dateadd(month,-6,(Select max(fixdatetime) from Order_Fix)) then 'Active'
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
			avg(orr.customer_satisfaction_score) as averagerating


from
	Customer_Fix as c
	join
	Order_Fix as o
	on 
	c.Custid=o.Customer_id
	join
	Orders_Payment_Fix as Op
	on
	op.order_id=o.order_id
	join
	Orders_Review_Fix as orr
	on
	orr.order_id=o.order_id
	join
	Store_Fix as st
	on
	st.StoreID=o.Delivered_StoreID
	join 
	Product_Fix as p
	on
	p.product_id = o.product_id
	join
	FavQuarter as Fq
	on
	fq.customer_id=c.Custid
	join
	Preferecategory as pc
	on
	pc.Customer_id=c.Custid
	join
	preferechannel as pch
	on
	pch.Customer_id=c.Custid
	join
	preferedMode as pm
	on
	pm.Customer_id=c.Custid
	join
	preferedtype as pt
	on
	pt.customer_id=c.Custid

	
	group by c.Custid, c.Gender, c.customer_city,st.Region,fq.preferedquarter,pc.Category ,pch.preferedchannel,pm.preferedmode,pt.ActiveType
	order by ordercount desc



	-- Step 1: Count how many orders per quarter per customer
With QuarterCount as (
	Select Customer_id,datepart(quarter,FixDateTime) as Quarters, count(*) as orderscount
	from
	Order_Fix
	group by Customer_id, datepart(quarter,fixdatetime)
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
							when datepart(hour,FixDateTime)>22 or datepart(hour,FixDateTime)<06 then 'NightHawk'
							else 'DawnSparrow'
						end as ActiveType, count(*) as order_count
	from
	Order_Fix
	group by Customer_id,case 
							when datepart(hour,FixDateTime)>22 or datepart(hour,FixDateTime)<06 then 'NightHawk'
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
	ranks=1)

Insert Into Customer_360(
	customer_id,
	gender,
	city,
	region,

	ordercount,
	totalspent,
	Weekend,
	averagespent,
	firstorderdate,
	lastorderdate,
	customerstatus,


	preferedquater,
	preferedcateagory,
	preferedchannel,
	preferedpaymentmode,
	activetime,
	averagerating
	)

Select 	
			c.custid,
			c.Gender,
			c.customer_city,
			st.Region,

			count(Distinct o.order_id) as ordercount,
			Sum(op.payment_value) as Totalspent,
			sum(case
					when datepart(weekday,o.fixdatetime) = 1 or datepart(weekday,o.fixdatetime)=7 then op.payment_value
					else 0
				end) as WeekSpent,
					
			sum(op.payment_value)*1.0/count(distinct o.order_id)  as averagespent,
			min(convert(Date,o.fixdatetime,101)) as firstorderdate,
			max(convert(Date,o.fixdatetime,101)) as lastorderdate,
			case 
				when max(convert(Date,o.fixdatetime,101))>Dateadd(month,-6,(Select max(fixdatetime) from Order_Fix)) then 'Active'
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
			avg(orr.customer_satisfaction_score) as averagerating


from
	Customer_Fix as c
	join
	Order_Fix as o
	on 
	c.Custid=o.Customer_id
	join
	Orders_Payment_Fix as Op
	on
	op.order_id=o.order_id
	join
	Orders_Review_Fix as orr
	on
	orr.order_id=o.order_id
	join
	Store_Fix as st
	on
	st.StoreID=o.Delivered_StoreID
	join 
	Product_Fix as p
	on
	p.product_id = o.product_id
	join
	FavQuarter as Fq
	on
	fq.customer_id=c.Custid
	join
	Preferecategory as pc
	on
	pc.Customer_id=c.Custid
	join
	preferechannel as pch
	on
	pch.Customer_id=c.Custid
	join
	preferedMode as pm
	on
	pm.Customer_id=c.Custid
	join
	preferedtype as pt
	on
	pt.customer_id=c.Custid

	
	group by c.Custid, c.Gender, c.customer_city,st.Region,fq.preferedquarter,pc.Category ,pch.preferedchannel,pm.preferedmode,pt.ActiveType
	order by ordercount desc


	Select * into customer_360backup from 
	Customer_360

	Select *
	from
	Customer_360


--------------------------------------------------------Orders 360------------------------------------------------------------

Create table orders360(
						order_id varchar(50),
						
						customer_id varchar(50),
						gender varchar(5),
						prefered_channel varchar(50),

						Productcount int,
						Storecount int,
						categorycount int,

						customercity varchar(50),
						sellercity varchar(50),
						C_type varchar(50),
						
						customerstate varchar(50),
						sellerstate varchar(50),
						S_type varchar(50),

						customerregion varchar(50),
						sellerregion varchar(50),
						R_type varchar(50),

						totaldiscount float,
						totalamount float,
						preferedmode varchar(50),
						mode_percent_value float,

						week_day_end varchar(50),
						orderhour int,
						night_day varchar(50),
						quart int,
						
						satisfaction_score float
						)



Select * into orders360backup from orders360











With Payment_mode as (Select op.order_id,op.payment_type,count(*) as mode_count
					  from
					  Orders_Payment_Fix as Op
					  
					  group by op.order_id,op.payment_type
					  ),RankedMode as (
					  Select *,
					  ROW_NUMBER() over (partition by order_id order by mode_count desc) as Ranks
					  from
					  Payment_mode),preferedmode as(
					  Select order_id, payment_type as preferedmode
					  from
					  RankedMode
					  where ranks=1
					  ),total_amount_per_order as (
					  Select order_id , sum(total_amount) as total_amount
					  from
					  Order_Fix 
					  group by order_id
					  ), preferedmode_amount as(
					  Select op.order_id,sum(op.payment_value) as Mode_amount
					  from
					  preferedmode as pm
					  join
					  Orders_Payment_Fix as op
					  on
					  op.order_id=pm.order_id and op.payment_type=pm.preferedmode
					  group by op.order_id
					  ),Total_discount_per_order as (
					  Select order_id, sum(discount) as totaldiscount 
					  from
					  Order_Fix 
					  group by order_id
					  ), customer_region as (
					  Select c.Custid,c.customer_state,st.Region
					  from
					  Customer_Fix as c
					  join
					  Store_fix as st
					  on
					  c.customer_state=st.seller_state
					  group by c.custid,c.customer_state, St.Region
					  ),Channel as( 
						Select order_id,Channel,count(*) as order_count
						from
						Order_Fix 
						group by order_id,channel
						),Rankedchannel as (
						Select *,
						ROW_NUMBER() over (partition by order_id order by order_count desc) as Ranks
						from
						Channel), preferedchannel as (
						Select order_id, channel
						from
						Rankedchannel
						where ranks=1
						)


insert into orders360(
						order_id ,
						
						customer_id,
						gender ,
						prefered_channel ,

						Productcount ,
						Storecount ,
						categorycount ,

						customercity,
						sellercity ,
						C_type,
						
						customerstate,
						sellerstate ,
						S_type ,

						customerregion ,
						sellerregion ,
						R_type ,

						totaldiscount,
						totalamount ,
						preferedmode ,
						mode_percent_value ,

						week_day_end ,
						orderhour ,
						night_day ,
						quart ,
						
						satisfaction_score )


					
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

						cr.Region as customerregion,
						st.Region as storeregion,
						Case 
							when cr.Region=St.Region then 'IntraRegion'
							else 'InterRegion'
						end As Inter_Intra_Region,

						tdo.totaldiscount as Totaldiscount,
						tao.total_amount as TotalAmount,
						pm.preferedmode as preferedmode,
						(pmm.Mode_amount*100.0)/tao.total_amount  as preferedmodepercent,
						Case
							when Datepart(weekday,o.fixdatetime) not in (1,7) then 'Weekday'
							else 'Weekend'
						end as Week_day_end,
						Datepart(hour,o.FixDateTime) as Orderhour,
						case 
							when Datepart(hour,o.fixdatetime)>6 and Datepart(hour,o.fixdatetime)<22
							then 'Day'
							else 'Night'
						end as night_day,
						case
							when Datepart(quarter, o.FixDateTime)!=1 then Datepart(quarter,o.fixdatetime)-1
							else 4
						end as Quarters,
						orr.Customer_Satisfaction_Score as Satisfaction_score
						 


										

from
Order_Fix as o
join
Customer_Fix as c
on
o.Customer_id=c.Custid
join
total_amount_per_order as TAO
on
tao.order_id=o.order_id
join
Store_fix as st
on
st.StoreID = o.Delivered_StoreID
join 
Orders_Payment_Fix as op
on
op.order_id=o.order_id
join
Orders_Review_Fix as orr
on
orr.order_id=o.order_id
join
Product_Fix as p
on
p.product_id= o.product_id
join
preferedmode as pm
on
pm.order_id=o.order_id
join
preferedmode_amount as pmm
on
pmm.order_id=o.order_id
join
Total_discount_per_order as Tdo
on
o.order_id=tdo.order_id
join
customer_region as cr
on
cr.Custid=c.Custid
join
preferedchannel as pc
on
pc.order_id=o.order_id

group by o.order_id,c.custid,o.FixDateTime,orr.Customer_Satisfaction_Score,c.gender,c.customer_city,st.seller_city,c.customer_state, st.seller_state,st.region,pm.preferedmode,pmm.Mode_amount,tao.total_amount,tdo.totaldiscount,cr.Region, pc.Channel

order by preferedmodepercent


Select  *
from
Orders_Payment_Fix 
where order_id='636f0241ddc83a3b9e37a8088167bd45'



Select  *
from
Order_Fix 
where order_id='636f0241ddc83a3b9e37a8088167bd45'


Select Distinct order_id
from
orders360


Select distinct order_id
from
Orders_Payment_Fix

Select distinct order_id
from
Orders_Review_Fix



Select o.order_id
from
Order_Fix as o
join
Customer_Fix as c
on
o.Customer_id=c.Custid
join
Store_fix as st
on
st.StoreID = o.Delivered_StoreID
join 
Orders_Payment_Fix as op
on
op.order_id=o.order_id
join
Orders_Review_Fix as orr
on
orr.order_id=o.order_id
join
Product_Fix as p
on
p.product_id= o.product_id


Delete o 
from
Order_Fix as o
Right join
Customer_Fix as c
on
o.Customer_id=c.Custid
where c.Custid is null


Delete o 
from
Order_Fix as o
right join
Orders_Payment_Fix as op
on
o.order_id=op.order_id
where op.order_id is null

Delete o 
from
Order_Fix as o
right join
Orders_Review_Fix as orr
on
o.order_id=orr.order_id
where orr.order_id is null


Delete o 
from
Order_Fix as o
right join
Store_fix as st
on
st.StoreID=o.Delivered_StoreID
where st.StoreID is null


Delete o 
from
Order_Fix as o
right join
Product_Fix as p
on
p.product_id=o.product_id
where p.product_id is null

Select Distinct Category
from
Product_Fix

Select Distinct channel
from
Order_Fix


Select * from orders360 as o3 right join Order_Fix as o on o3.order_id=o.order_id where o3.order_id is null


Select * from
Customer_360


----------------------------------------------------------------store 360-----------------------------------------------------------------

create table store360(
				      storeid varchar(50),
					  storecity varchar(50),
					  storestate varchar(50),
					  storeregion varchar(50),

					  total_orders int,
					  total_customer_served int,
					  total_discount_given float,
					  total_revenue float,
					  avg_order_value float,
					  
					  most_sold_category varchar(50),
					  total_products_sold int,
					  peak_quarter varchar(50),

					  avg_customer_score float,
					  most_preferred_payment_method varchar(50),
					  most_active_hours int)




select * into store360backup from store360		




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
				  Select Delivered_StoreID, DATEPART(quarter, FixDateTime) as Quarters, count(*) as order_count
				  from 
				  Order_Fix as o
				  group by Delivered_StoreID, DATEPART(QUARTER,FixDateTime)
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
				  Select Delivered_StoreID, Datepart(hour,FixDateTime) as Hrs, count(*) as order_count
				  from
				  Order_Fix as o
				  group by Delivered_StoreID,Datepart(hour,FixDateTime)
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
				  

	
insert into store360(
					 storeid,
					 storecity,
					 storestate,
					 storeregion,

					 total_orders,
					 total_customer_served,
					 total_discount_given,
					 total_revenue,
					 avg_order_value,

					 most_sold_category,
					 total_products_sold,
					 peak_quarter,

					 avg_customer_score,
					 most_preferred_payment_method,
					 most_active_hours
)




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



Select * from Customer_360 as c360 right join Customer_Fix as C on c360.customer_id=c.Custid where c360.customer_id is null

Select * from store360  as st360 right join Store_fix as st on st.StoreID=st360.storeid where st360.storeid is null

Select * from orders360 as o360 right join Order_Fix as o on o360.order_id=o.order_id where o360.order_id is null

