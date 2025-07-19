

-----------------------------------------------Customer fixing--------------------------------------------------

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
)

Insert Into Customer_360(
	customer_id,
	gender,
	city,
	customer_state,
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

Select 	
			c.custid,
			c.Gender,
			c.customer_city,
			c.customer_state,
			fr.Region,

			count(
			Case 
				when c.Custid=o.Customer_id then o.order_id
			
			end) as ordercount,

			Sum(
			Case
				when o.order_id=op.order_id then op.payment_value
			end) as Totalspent,

			sum(case
					when datepart(weekday,o.fixdatetime) = 1 or datepart(weekday,o.fixdatetime)=7 then op.payment_value
					else 0
				end) as WeekSpent,
					
			avg(
			case
				when o.order_id=op.order_id then payment_value
			end)  as averagespent,

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
			avg(
			case
				when o.order_id=orr.order_id then orr.Customer_Satisfaction_Score
			end) as averagerating


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
	join
	FinalRegion as fr
	on
	fr.Customer_id=c.Custid
	
	group by c.Custid, c.Gender, c.customer_city,c.customer_state,st.Region,St.seller_state,fq.preferedquarter,pc.Category ,pch.preferedchannel,pm.preferedmode,pt.ActiveType,fr.Region
	order by ordercount desc



	Select * from customer_fix as c left join Store_fix as st on c.customer_state=st.seller_state where c.customer_state is null



drop table customer_360



Create Table Customer_360 (
	customer_id varchar(50),
	gender varchar(50),
	city varchar(50),
	customer_state varchar(50),
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
    MAX(CASE WHEN DATEPART(weekday, o.fixdatetime) IN (1, 7) THEN 1 ELSE 0 END) AS is_weekend
  FROM Orders_Payment_Fix op
  JOIN Order_Fix o ON o.order_id = op.order_id
  GROUP BY o.order_id
)



Insert Into customer_360(
	customer_id,
	gender,
	city,
	customer_state,
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
			avg(
			case
				when o.order_id=orr.order_id then orr.Customer_Satisfaction_Score
			end) as averagerating



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
	
	


	Select * from customer_fix as c left join Store_fix as st on c.customer_state=st.seller_state where c.customer_state is null




---------------------------------------------------------orders fixing----------------------------------------------
Select * from Order_Fix as o left join orders360 as o360 on o.order_id=o360.order_id where o360.order_id is null
	
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

insert into orders360backup(
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

group by o.order_id,c.custid,o.FixDateTime,orr.Customer_Satisfaction_Score,c.gender,c.customer_city,st.seller_city,c.customer_state, st.seller_state,fr.Region,st.region,pm.preferedmode,pmm.Mode_amount,tao.total_amount,tdo.totaldiscount, pc.Channel

order by preferedmodepercent





select distinct * from orders360backup 


Select * from orders360backup where order_id is null or 
									customer_id is null or
									gender is null or
									prefered_channel is null or
									Productcount is null or
									Storecount is null or
									categorycount is null or
									customercity is null or
									sellercity is null or
									customerstate is null or
									sellerstate is null or
									customerregion is null or
									sellerregion is null or
									totaldiscount is null or
									totalamount is null or 
									preferedmode is null or
									mode_percent_value is null or 
									week_day_end is null or
									orderhour is null or
									night_day is null or
									quart is null or
									satisfaction_score is null
Select * from Customer_360 where customer_id is null or
								 gender is null or
								 city is null or
								 region is null or
								 ordercount is null or
								 totalspent is null or
								 Weekend is null or
								 averagespent is null or
								 firstorderdate is null or
								 lastorderdate is null or
								 customerstatus is null or
								 preferedquater is null or
								 preferedcateagory is null or
								 preferedchannel is null or
								 preferedpaymentmode is null or
								 activetime is null or
								 averagerating is null
Select * from store_360 where storeid is null or
							 storecity is null or
							 storestate is null or
							 storeregion is null or
							 total_orders is null or
							 total_customer_served is null or
							 total_discount_given is null or
							 total_revenue is null or
							 avg_order_value is null or
							 most_sold_category is null or
							 total_products_sold is null or
							 peak_quarter is null or
							 avg_customer_score is null or
							 most_preferred_payment_method is null or
							 most_active_hours is null

update Customer_360
set averagerating=0 where averagerating is null

Delete from orders360backup 
where customer_id is null

update orders360backup
set satisfaction_score=0 where satisfaction_score is null

Delete from orders360backup 
where order_id ='005d9a5423d47281ac463a968b3936fb'


Delete from Customer_360
where customer_id='4636293460'

drop table orders360

Select distinct * into order_360 from orders360backup
Select * into store_360 from store360

Select * from Customer_360
Select * from Order_360
Select * from Store_360
