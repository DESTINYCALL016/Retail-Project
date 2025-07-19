create Database Internship_Data
use Internship_data

------------------------------------------------Customer-------------------------------------------------

-- Number of rows
Select count(custid) as Customer_Row_Count 
from 
Customer_Raw

-- Number of columns
Select Count(Column_name) as Customer_Column_count
from INFORMATION_SCHEMA.COLUMNS
Where TABLE_NAME='Customer_Raw'

-- Primary & Foreign keys
--		Primary Key must be distinct so we have to check for duplicates in customerid column.

Select custid, Count(Custid) as Duplicates
from 
Customer_Raw
group by Custid
having count(custid)>1
-- As there is no duplicates , Primary key - CustID and there is no foreign key


Select * 
from
Customer_Raw

-- Blank values

Select * 
from 
Customer_Raw
where customer_city is Null or
	  customer_state is Null or
	  Gender is Null 

-- no blank values

--  Datatypes?
Select COLUMN_NAME, DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Customer_raw'

-- customer Id as Big int is an issue as it can easily be tamperted

Alter Table customer_raw
alter column custid varchar(50)


Select COLUMN_NAME, DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Customer_raw'

--issue resolved by changing data type from Int to varchar

Select *
from Customer_Raw

Select customer_city, count(Distinct customer_state) as State_count
from Customer_Raw
group by customer_city
having count(Distinct customer_state)>=2
order by State_count desc



---------------------------------------orders-------------------------------------

-- NO. of rows

Select Count(*) as Orders_Row_Count
from
Orders_Raw

-- No. of columns

Select Count(column_name) as Orders_column_count
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Orders_Raw'

--DataType

Select COLUMN_NAME, DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Orders_Raw'

--customerid must also be in varchar
Alter table orders_raw
alter column customer_id varchar(50)

Select COLUMN_NAME, DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Orders_Raw'

--Done

--Bill_date_timestamp is nvarchar which should be split into two columns Date and Time with proper data type

Select*from Orders_Raw

Alter Table orders_raw
add Fix_Date Date

Alter Table orders_raw
add Fix_Time Time

Update orders_raw
set Fix_Date=convert(Date,bill_date_timestamp,101)

Update Orders_Raw
set Fix_Time=convert(time,bill_date_timestamp,101)

Alter table orders_raw
drop column bill_date_timestamp

-- numerical values which are in floats, i like to convert the data type into numeric with 2 places after decimal

Alter table orders_raw
alter column cost_per_unit numeric(30,2)

Alter table orders_raw
alter column MRP numeric(30,2)

Alter table orders_raw
alter column total_amount numeric(30,2)


Select COLUMN_NAME, DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='Orders_Raw'


-- Lets check for blank values

select *
from 
Orders_Raw
where Customer_id is null or
	  order_id is null or
	  product_id is null or
	  channel is null or 
	  Delivered_StoreID is null or
	  Fix_Date is null or
	  Fix_Time is null or 
	  Quantity is null or
	  Cost_Per_Unit is null or
	  MRP is null or
	  Discount is null or
	  Total_Amount is null
	 
-- So, there is no blanks in orders table	  

Select * from Orders_Raw

Select customer_id, count(customer_id) as Frequency 
from 
Orders_Raw
group by Customer_id
having count(customer_id)>1
order by Frequency desc

-- So, customer can be repeatative as one customer may have multiple orders

Select order_id, count(order_id) as orders_count
from
Orders_Raw
group by order_id
having count(order_id)>1
order by orders_count desc

-- So, one order_id may have multiple different products ordered at same time with one product having one record



Select * from Orders_Raw

-- Lets check why there is multiple order id's?
Delete Op
from 
Orders_Raw as O
right join 
Orders_Payment_Raw as Op
on O.order_id=op.order_id
where O.order_id is null

-- Deleted not relevent records from Orders_payment

Delete orat
from
Orders_Raw as O
right join
OrdersRating_Review_Raw as Orat
on
o.order_id=orat.order_id
where o.order_id is null

--Deleted not relevent Records from OrdersRating_Reviews





Select order_id, count(order_id) as Error
from
OrdersRating_Review_Raw
group by order_id
having count(order_id)>1
order by Error

With RankedReviews as
	(
	Select *,
	DENSE_RANK() over (partition by order_id order by customer_satisfaction_score desc) as Ranks
	from
	OrdersRating_Review_Raw
	) 
Delete orr
from OrdersRating_Review_Raw as Orr
join
rankedreviews as R
on
orr.order_id=R.order_id
where ranks=2


-- inconsistensy in orderrating reviews is fixed
 


 Select *
 from
 Orders_Payment_Raw

 Select count(order_id)
 from
 Orders_Payment_Raw
 

 Select count(distinct order_id)
 from
 Orders_Payment_Raw

 With
 orderRanks as
	(
	Select order_id,product_id, Fix_Date,Fix_Time,quantity,
	ROW_NUMBER() over (partition by order_id,product_id,fix_date,fix_time order by Quantity Desc) as Ranks
	from
	Orders_Raw
	)
Delete o
from
Orders_Raw as o
join
orderranks as orr
on
	o.order_id=orr.order_id
and o.product_id=orr.product_id
and o.fix_date=orr.fix_date
and o.fix_time=orr.fix_time
and o.quantity=orr.quantity
where ranks!=1


Select * 
from 
Store_info_Raw

Select count(storeid) Total_Rows
from 
Store_info_Raw

Select count(distinct storeid) as Distinct_Count
from 
Store_info_Raw

Select*
from
Store_info_Raw
group by StoreID,Region,seller_state, seller_city
having count(storeid)>1

Select* 
from
Store_info_Raw
where storeid='ST410'


Select* from Store_info_Raw

Select *
into Store_info_new_raw
from
	(Select *
	from
	Store_info_Raw
	group by StoreID, seller_city,seller_state,Region
	)as x





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
	group by order_id)

Select 
	PA.order_id, 
	Total_bill,Total_Paid, 
	(Total_bill-Total_Paid) as Difference,
	
	Case 
		when (Total_bill-Total_Paid)<-1 then 'OverPaid'
		when (Total_bill-Total_Paid)>1 then 'UnderPaid'
		else 'No Problem'
	end as Payment_status

from
	Amount_tobe_paid as Ap
	join
	Paid_amount as PA
	on
	Ap.order_id =PA.order_id

where Total_bill !=Total_Paid 
order by ABS(Total_bill-Total_Paid) desc







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





With Inactive as(
	Select count(c.custid) as Inactive_customer
	from
	Customer_Raw as C
	left join
	Orders_Raw as O
	on
	c.Custid=o.Customer_id
	where o.Customer_id is null
	), Active as
	(Select count(distinct Customer_id) as Active_customer
	from
	Orders_Raw
	),Total as
	( Select count(distinct Custid) as Total_customer
	from 
	Customer_Raw
	)
Select cast((inactive_customer/total_customer)*100.0 as numeric(10,10))as churn_rate
from
Inactive as i
cross join
total as t


Delete c
from 
Customer_Raw as c
left join
Orders_Raw as o
on
c.Custid=o.Customer_id
where o.Customer_id is null


Delete
from
Products_Info_Raw
where Category is null


Select*
from
Products_Info_Raw
Where product_id is null or
	  Category is null or
	  Trim(Category) ='#N/A' or
	  product_name_lenght is null or
	  product_description_lenght is null or
	  product_photos_qty is null or
	  product_weight_g is null or
	  product_weight_g <=0 or
	  product_length_cm is null or
	  product_length_cm<=0 or
	  product_height_cm is null or
	  product_height_cm<=0 or
	  product_width_cm is null or
	  product_width_cm <=0
	  
Delete 
from
Products_Info_Raw
where Category='#N/A' or
	  Category is null



Select*
from
Products_Info_Raw
Where product_id is null or
	  Category is null or
	  Trim(Category) ='#N/A' or
	  product_name_lenght is null or
	  product_description_lenght is null or
	  product_photos_qty is null or
	  product_weight_g is null or
	  product_weight_g <=0 or
	  product_length_cm is null or
	  product_length_cm<=0 or
	  product_height_cm is null or
	  product_height_cm<=0 or
	  product_width_cm is null or
	  product_width_cm <=0
	  

Select * 
from
Orders_Raw
where product_id ='09ff539a621711667c43eba6a3bd8466'

Select*
from
Orders_Raw as o
right join
Products_Info_Raw as p
on
o.product_id=p.product_id
where o.product_id is null

Select*
from
Orders_Raw as o
left join
Products_Info_Raw as p
on
o.product_id=p.product_id
where p.product_id is null

