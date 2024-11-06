Create database Order_analysis;

use Order_analysis;

select * from order_Status;

select * from date_wise_report;

set autocommit = off;

start transaction;

-- We need to calculate the Stock count & work order count based on order_id
create Table Stock_work_Order
select order_id, 
sum(case 
		when order_type = "stock" then 1 else 0 end ) as Stock_count ,	 
sum(case 
		when order_type = "Work_order" then 1 else 0 end) as Work_order_count 
from Order_status group by order_id;

select * from Stock_work_Order;

-- next you calculate Work_order_pending Status

 Create table Work_Order_pending
select order_id, 
sum(case 
		when order_type = "stock" then 1 else 0 end ) as Stock_count ,	 
sum(case 
		when order_type = "Work_order" then 1 else 0 end) as Work_order_count , 
(sum(case 
		when order_type = "stock" then 1 else 0 end) - 
sum(case 
		when order_type = "Work_order" then 1 else 0 end )) as Work_order_pending
from Order_Status group by Order_id;

select * from work_order_pending;

/* finally you close the work_order
Conditions
	Work_order_pending status < 0
	Then update order_closed other wise Order_pending */
    
Create Table Order_Pending_Status
select order_id, 
sum(case 
		when order_type = "stock" then 1 else 0 end ) as Stock_count ,	 
sum(case 
		when order_type = "Work_order" then 1 else 0 end) as Work_order_count , 
(sum(case 
		when order_type = "stock" then 1 else 0 end) - 
sum(case 
		when order_type = "Work_order" then 1 else 0 end )) as Work_order_pending,
case
	when sum(case when order_type = "Work_order" then 1 else 0 end )
	then "Order_closed"
    else "Order_pending"
end as Work_Order_Close_or_Pending_Status
from order_status group by order_id;
    
select * from order_pending_status;

-- Joining Order Status & Date wise Report
create table order_Supplier_Report
select o.Trans, o.Negative, o.Order_Type, o.Assembly_Supplier, 
	   o.Ref, o.Order_id, o.Sale_id, o.Description,d.sale_Date, d.Qty,
	   d.Item_Type, d.Job_Status, d.Planner, d.Buyer_Name, d.Preferred_Supplier, 
	   d.Safety, d.Pre_PLT, d.Post_PLT, d.LT, d.Run_Total, d.Late, d.Safety_RT, 
	   d.PO_Note, d.Net_Neg, d.Last_Neg, d.Item_Category, d.Created_On_Date
from order_status o inner join Date_wise_report d on o.sale_id = d.sale_id;
  
select * from order_Supplier_Report;

-- Date wise Quantity & Order_id Count

create Table Date_Wise_Qty_Order_count
select sale_date,sum(Qty) as Date_wise_qty,count(Order_id) as OrderId_Count
from Order_supplier_report group by sale_date;

select * from Date_Wise_Qty_Order_count;

-- Split Supplier Name Using Substring_Index
create Table Split_supplier_name
select Buyer_name , substring_index(Buyer_name,',',-1) as First_name,
 substring_index(Buyer_name,',',1) as Last_name from order_supplier_report;
 
 select * from Split_supplier_name;
 
 -- Finally you stored the all reports and tables while using stored procedure
 
 Delimiter //
Create procedure Stock_Order_Analysis()
begin
select * from Stock_work_Order;
select * from work_order_pending;
select * from order_pending_status;
select * from order_Supplier_Report;
select * from Date_Wise_Qty_Order_count;
select * from Split_supplier_name;
end //
Delimiter ;

-- Call procedure

Call Stock_order_analysis();









