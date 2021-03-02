select * from [dbo].[DIM_CUSTOMER] as a , [dbo].[DIM_DATE] as b, [dbo].[DIM_LOCATION] as c, [dbo].[DIM_MANUFACTURER] as d, [dbo].[DIM_MODEL] as e, [dbo].[FACT_TRANSACTIONS] as f 
where a.[IDCustomer] = f.[IDCustomer] and b.[DATE]= f.[Date] and c.[IDLocation] = f.[IDLocation] and d.[IDManufacturer] = e.[IDManufacturer] and e.[IDModel] = f.[IDModel] 


--1. list all the states in which we have customers who have bought cellphones from 2005 till today.
select distinct [State] from [dbo].[DIM_LOCATION] as t1, [dbo].[FACT_TRANSACTIONS] as t2, [dbo].[DIM_DATE] as t3 where t1.[IDLocation] = t2.[IDLocation] and t2.[Date] = t3.[DATE]
and t3.[YEAR]>= 2005





--2. What state in the us is buying more 'Samsung' cell phones? 
select top 1 t1.[State], t1.[Country], count(t4.[Quantity]) [phones_sold] from [dbo].[DIM_LOCATION] as t1, [dbo].[DIM_MANUFACTURER] as t2, [dbo].[DIM_MODEL] as t3, [dbo].[FACT_TRANSACTIONS]as t4 
where t1.[IDLocation] = t4.[IDLocation] and t2.[IDManufacturer] = t3.[IDManufacturer] and t3.[IDModel] = t4.[IDModel] and t1.[Country] = 'US' and t2.[Manufacturer_Name] = 'Samsung'
group by [State],  t1.[Country]
order by [phones_sold] desc


--3. show the number of transactions for each model per zip code per state.
select t1.[ZipCode], t1.[State], t2.[Model_Name], count(t3.[IDCustomer]) [ttl_ tran] from [dbo].[DIM_LOCATION] as t1, [dbo].[DIM_MODEL] as t2, [dbo].[FACT_TRANSACTIONS] as t3
where t1.[IDLocation] = t3.[IDLocation] and t2.[IDModel] = t3.[IDModel]
group by t1.[ZipCode],  t1.[State], t2.[Model_Name]



--4. show the cheapest cellphone.
select x.[Manufacturer_Name] from (
select t1.[Manufacturer_Name], t2.[Model_Name], min(t3.[TotalPrice]) as price 
from [dbo].[DIM_MANUFACTURER] as t1, [dbo].[DIM_MODEL] as t2, [dbo].[FACT_TRANSACTIONS] as t3 
where t1.[IDManufacturer] = t2.[IDManufacturer] and t2.[IDModel] = t3.[IDModel]
group by t1.[Manufacturer_Name], t2.[Model_Name], t3.TotalPrice having t3.TotalPrice = (select min([TotalPrice]) from [dbo].[FACT_TRANSACTIONS]) ) x



--5. find out the average price for each model in the top 5 manufactures in terms of sales quantity and order by average price.
select t2.[Model_Name], avg(t3.TotalPrice) as avg_price
from [dbo].[DIM_MANUFACTURER] as t1, [dbo].[DIM_MODEL] as t2, [dbo].[FACT_TRANSACTIONS] as t3 
where t1.[IDManufacturer] = t2.[IDManufacturer] and t2.[IDModel] = t3.[IDModel] 
and t1.[Manufacturer_Name] in (select x.[Manufacturer_Name] from 
(select top 5 t1.[Manufacturer_Name], count(t3.[Quantity]) as qty
from [dbo].[DIM_MANUFACTURER] as t1, [dbo].[DIM_MODEL] as t2, [dbo].[FACT_TRANSACTIONS] as t3 
where t1.[IDManufacturer] = t2.[IDManufacturer] and t2.[IDModel] = t3.[IDModel] 
group by t1.[Manufacturer_Name]
order by qty desc) x)
group by  t2.[Model_Name]
order by  avg_price


--6. list the names of the customers and the average amount spent in 2009, where the average is higher than 500
select t1.[Customer_Name], avg(t3.[TotalPrice])  from [dbo].[DIM_CUSTOMER] as t1, [dbo].[DIM_DATE] as t2, [dbo].[FACT_TRANSACTIONS] as t3 
where t1.[IDCustomer] = t3.[IDCustomer] and t2.[DATE] = t3.[Date] and year(t2.[DATE]) = 2009
group by t1.[Customer_Name], t3.[TotalPrice]
having avg(t3.[TotalPrice])> 500


-- 7. list if there is any model that was in the top 5 in terms of quantity, simulateneously in 2008,2009 and 2010.
select A.[Model_Name] from

(select top 5 [Model_Name], year(t2.[DATE]) year, sum( [Quantity]) qty from [dbo].[DIM_MODEL] t1
inner join [dbo].[FACT_TRANSACTIONS] t2 on t1.[IDModel]= t2.[IDModel]
where year(t2.[DATE]) = 2008
group by [Model_Name], year(t2.[DATE])
order by qty desc ) A

inner join

(select top 5 [Model_Name], year(t2.[DATE]) year, sum( [Quantity]) qty from [dbo].[DIM_MODEL] t1
inner join [dbo].[FACT_TRANSACTIONS] t2 on t1.[IDModel]= t2.[IDModel]
where year(t2.[DATE]) = 2009
group by [Model_Name], year(t2.[DATE])
order by qty desc) B on A.[Model_Name] = B.Model_Name

inner join

(select top 5 [Model_Name], year(t2.[DATE]) year, sum( [Quantity]) qty from [dbo].[DIM_MODEL] t1
inner join [dbo].[FACT_TRANSACTIONS] t2 on t1.[IDModel]= t2.[IDModel]
where year(t2.[DATE]) = 2010
group by [Model_Name], year(t2.[DATE])
order by qty desc ) C on B.Model_Name = c.Model_Name


-- 8. show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd sales in the year of 2010.

select top 2 t.[Manufacturer_Name] from
(
select top 2 [Manufacturer_Name], sum(t3.[TotalPrice]) as sales from [dbo].[DIM_MANUFACTURER] t1
inner join [dbo].[DIM_MODEL] t2 on t1.[IDManufacturer] = t2.[IDManufacturer]
inner join [dbo].[FACT_TRANSACTIONS] t3 on t3.[IDModel] = t3.[IDModel]
where year(t3.[Date]) =  2009
group by [Manufacturer_Name], year(t3.[Date])
order by sales desc


union all

select top 2 [Manufacturer_Name], sum(t3.[TotalPrice]) as sales from [dbo].[DIM_MANUFACTURER] t1
inner join [dbo].[DIM_MODEL] t2 on t1.[IDManufacturer] = t2.[IDManufacturer]
inner join [dbo].[FACT_TRANSACTIONS] t3 on t3.[IDModel] = t3.[IDModel]
where year(t3.[Date]) = 2010
group by [Manufacturer_Name], year(t3.[Date])
order by sales desc 
)t
group by t.Manufacturer_Name, t.sales
order by t.sales 



--9. show thw manufactures that sold cellphone in 2010 but didnt in 2009.
select distinct t1.[Manufacturer_Name] from [dbo].[DIM_MANUFACTURER] t1
inner join [dbo].[DIM_MODEL] t2 on t1.[IDManufacturer] = t2.[IDManufacturer]
inner join [dbo].[FACT_TRANSACTIONS] t3 on t2.[IDModel] = t3.[IDModel]
where year(t3.[Date]) = '2010' except
select distinct t1.[Manufacturer_Name] from [dbo].[DIM_MANUFACTURER] t1
inner join [dbo].[DIM_MODEL] t2 on t1.[IDManufacturer] = t2.[IDManufacturer]
inner join [dbo].[FACT_TRANSACTIONS] t3 on t2.[IDModel] = t3.[IDModel]
where year(t3.[Date]) = '2009' 


--10. find top 100 custemors and their average spend, average quantity by each year. also find the percentage of change of change in their spend. 
select top 100 [Customer_Name], [TotalPrice], avg_spnd as [Average_spend], avg_qty as [AVQuantity], dt as [year_of_spend], 
case when A.prev_spend = 0 then null else convert(numeric(25,0), (([TotalPrice]-prev_spend)/prev_spend )*100) end [% change in spending] from
(select [Customer_Name], [TotalPrice], avg([TotalPrice]) as avg_spnd, avg([Quantity]) as avg_qty, year([Date]) as dt, 
lag(avg([TotalPrice]), 1,0) over(PARTITION by [Customer_Name] order by (year([Date]))) as prev_spend from [dbo].[DIM_CUSTOMER] 
inner join [dbo].[FACT_TRANSACTIONS] on [dbo].[DIM_CUSTOMER].[IDCustomer] = [dbo].[FACT_TRANSACTIONS].[IDCustomer]
group by [Customer_Name], year([Date]), [TotalPrice])A
order by avg_spnd desc