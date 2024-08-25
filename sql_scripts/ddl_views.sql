
create view staging.vw_dim_store_spar as
with src_store as (
select *,
row_number() over(partition by [Store] order by [Month_Yr] desc) as rn
from [staging].[retailer_spar]
)
select 
HASHBYTES('SHA1', [Store]) AS store_id,
[Store] as Store_name,
[Region],
[Cluster],
[Format] 
from src_store
where rn = 1 and [Store] is not null;
go

create view staging.vw_dim_product_spar as
with src_product as (
select 
*,
row_number() over(partition by [Product___Size],[Barcode] order by [Month_Yr] desc) as rn
from [staging].[retailer_spar]
)
select 
HASHBYTES('SHA1', [Product___Size] +'-'+ 'Spar') AS product_id
,[Barcode]
,[Brand]
,[Segment]
,[Product___Size] as product_name
from src_product
where rn = 1 and [Product___Size] is not null;
go



create or alter view staging.vw_fact_sales_spar as
select FORMAT([Month_Yr], 'yyyyMM') AS year_month,
r.[retailer_sk],
HASHBYTES('SHA1', [Product___Size] +'-'+ [Barcode]) AS product_id,
HASHBYTES('SHA1', [Store]+'-'+ 'Spar') AS store_id,
[Sales_(R)_2024] as sales,
[Units_2024] as quantity
from [staging].[retailer_spar] s
join [dbo].[retailers] r on r.[retailer_name] = 'Spar';
go



create or alter view staging.vw_dim_store_checkers as
with src_store as (
select *,
row_number() over(partition by [StoreName] order by [Period] desc) as rn
from [staging].[retailer_checkers]
)
select 
HASHBYTES('SHA1', [StoreName]+'-'+ 'Checkers') AS store_id
,[StoreName] as store_name
,[StoreCode] as store_code
,[alphalocationid]
,[Province] as region_division
,[PriceRegion]
from src_store
where rn = 1 and [StoreName] is not null

create view staging.vw_dim_product_checkers as
with src_product as (
select 
*,
row_number() over(partition by [ProductDesc],[EAN] order by [Period] desc) as rn
from [staging].[retailer_checkers]
)
select
HASHBYTES('SHA1', [ProductDesc] +'-'+ 'Checkers') AS product_id
      ,[EAN]
      ,[ProductCode]
      ,[SAP_ProductCode]
	  ,[ProductDesc]
	  ,[Department]
      ,[Category]
      ,[SubCategory]
      ,[Segment]
      ,[PackType]
	  ,[UnitOfMeasure]
from src_product
where rn = 1 and [ProductDesc] is not null;

create or alter view staging.vw_fact_sales_checkers as
select FORMAT([Period], 'yyyyMM') AS year_month,
r.[retailer_sk],
HASHBYTES('SHA1', [ProductDesc] +'-'+ 'Checkers') AS product_id,
HASHBYTES('SHA1', [StoreName]+'-'+ 'Checkers') AS store_id,
[TotalValue] as sales,
[TotalUnits] as quantity
from [staging].[retailer_checkers] c 
join [dbo].[retailers] r on r.[retailer_name] = 'Checkers'


--create view staging.vw_dim_dates as
--WITH dates AS
--(
--    -- Recursive CTE to generate a sequence of dates
--    SELECT CAST('2010-01-01' AS DATE) AS calendar_date
--    UNION ALL
--    SELECT DATEADD(DAY, 1, calendar_date)
--    FROM dates
--    WHERE calendar_date < '2030-01-01'
--)
--SELECT
--    CAST(FORMAT(calendar_date, 'yyyyMMdd') AS INT) AS date_sk,
--    CAST(calendar_date AS DATE) AS calendar_date,
--    FORMAT(calendar_date, 'dd MMM yyyy') AS date_short_name,
--    FORMAT(calendar_date, 'dd MMMM yyyy') AS date_name,
--    CONCAT(FORMAT(calendar_date, 'ddd'), ', ', FORMAT(calendar_date, 'dd MMM yyyy')) AS date_short_label,
--    CONCAT(FORMAT(calendar_date, 'ddd'), ', ', FORMAT(calendar_date, 'dd MMMM yyyy')) AS date_label,
--    CAST(CASE WHEN LEFT(FORMAT(calendar_date, 'ddd'), 1) = 'S' THEN 1 ELSE 0 END AS BIT) AS is_weekend,
--    CASE WHEN DATEPART(WEEKDAY, calendar_date) = 1 THEN 7 ELSE DATEPART(WEEKDAY, calendar_date) - 1 END AS day_of_week_no,
--    FORMAT(calendar_date, 'ddd') AS day_of_week_short_name,
--    DATEPART(WEEKDAY, calendar_date) AS day_of_week_in_month_no,
--    DATEPART(DAY, calendar_date) AS day_of_month,
--    DATEPART(DAYOFYEAR, calendar_date) AS day_of_year,
--    DATEPART(WEEK, calendar_date) AS week_of_year,
--    CAST(FORMAT(calendar_date, 'yyyyMM') AS INT) AS month_id,
--    DATEPART(MONTH, calendar_date) AS month_no,
--    FORMAT(calendar_date, 'MMM') AS month_short_name,
--    FORMAT(calendar_date, 'MMMM') AS month_name,
--    FORMAT(calendar_date, 'MMM yyyy') AS month_short_label,
--    FORMAT(calendar_date, 'MMMM yyyy') AS month_label,
--    CAST(CAST(YEAR(calendar_date) AS VARCHAR) + CAST(DATEPART(QUARTER, calendar_date) AS VARCHAR) AS INT) AS quarter_id,
--    DATEPART(QUARTER, calendar_date) AS quarter_no,
--    FORMAT(calendar_date, 'Q') AS quarter_short_name,
--    FORMAT(calendar_date, 'Q') + ' Quarter' AS quarter_name,
--    FORMAT(calendar_date, 'Q') + ' Quarter ' + CAST(YEAR(calendar_date) AS VARCHAR) AS quarter_label,
--    YEAR(calendar_date) AS year
--FROM dates
--WHERE
--    calendar_date BETWEEN '2020-01-01' AND '2030-01-01'
----OPTION (MAXRECURSION 0);  -- Allow recursion to generate all dates
----ORDER BY date_sk;
--GO



