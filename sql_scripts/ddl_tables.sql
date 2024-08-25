/****** Object:  Table [staging].[retailer_checkers]    Script Date: 6/20/2024 12:52:01 AM ******/

--create table retailers (
--retailer_sk INT IDENTITY(1,1),
--retailer_name varchar(30),
--full_name varchar(50),
--isactive bit
--);
--go

--insert into retailers
--values
--('Checkers', 'Checkers ZA', 1),
--('PNP', 'Pick n Pay', 1),
--('Spar', 'Spar', 1),
--('Woolworths', 'Woolworths Limited', 1);
--go

CREATE TABLE [dbo].[fact_sales](
    year_month INT NOT NULL,
    [retailer_sk] INT NULL,
    product_id VARBINARY(20),
    store_id VARBINARY(20),
    sales DECIMAL(19,4),
    [quantity] INT
) ;
GO

-- Adding a clustered columnstore index for analytical queries
CREATE CLUSTERED COLUMNSTORE INDEX CCI_fact_sales ON [dbo].[fact_sales];
GO

-- Adding a non-clustered index for specific lookups
CREATE NONCLUSTERED INDEX idx_year_month_retailer_sk 
ON [dbo].[fact_sales] (year_month, retailer_sk);
GO


CREATE TABLE [dbo].[dim_products](
product_sk int identity(1,1)
,product_id VARBINARY(20)
      ,[EAN] [nvarchar](30)
	  ,barcode bigint
	  ,SKU [nvarchar](30)
      ,[product_code] int
	  ,[product_name] [nvarchar](60)
      ,[category] [nvarchar](60)
      ,[subCategory] [nvarchar](60)
      ,[segment] [nvarchar](60)
      ,[pack_type] [nvarchar](60)
	  ,[unit_of_measure][nvarchar](30) 
);
GO

-- Adding a clustered columnstore index for analytical queries
CREATE CLUSTERED COLUMNSTORE INDEX CCI_dim_products ON  [dbo].[dim_products];
GO


CREATE TABLE [dbo].[dim_stores](
store_sk int identity(1,1)
,store_id VARBINARY(20)
,store_code int
,store_name [nvarchar](60)
,[province] [nvarchar](60)
,[region] [nvarchar](60)
);
GO

-- Adding a clustered columnstore index for analytical queries
CREATE CLUSTERED COLUMNSTORE INDEX CCI_dim_stores ON  [dbo].[dim_stores];
GO


-- Create the table structure
CREATE TABLE [dbo].[dim_dates](
    date_sk INT,
    calendar_date DATE,
    date_short_name NVARCHAR(50),
    date_name NVARCHAR(50),
    date_short_label NVARCHAR(50),
    date_label NVARCHAR(50),
    is_weekend BIT,
    day_of_week_no INT,
    day_of_week_short_name NVARCHAR(10),
    day_of_week_in_month_no INT,
    day_of_month INT,
    day_of_year INT,
    week_of_year INT,
    year_month INT,
    month_no INT,
    month_short_name NVARCHAR(10),
    month_name NVARCHAR(50),
    month_short_label NVARCHAR(50),
    month_label NVARCHAR(50),
    quarter_id INT,
    quarter_no INT,
    quarter_short_name NVARCHAR(10),
    quarter_name NVARCHAR(50),
    quarter_label NVARCHAR(50),
    [year] INT
);
-- Adding a clustered columnstore index for analytical queries
CREATE CLUSTERED COLUMNSTORE INDEX CCI_dim_dates on [dbo].[dim_dates]


WITH dates AS (
    SELECT CAST('2020-01-01' AS DATE) AS calendar_date
    UNION ALL
    SELECT DATEADD(DAY, 1, calendar_date)
    FROM dates
    WHERE calendar_date < '2030-01-01'
)
SELECT
    CAST(FORMAT(calendar_date, 'yyyyMMdd') AS INT) AS date_sk,
    CAST(calendar_date AS DATE) AS calendar_date,
    FORMAT(calendar_date, 'dd MMM yyyy') AS date_short_name,
    FORMAT(calendar_date, 'dd MMMM yyyy') AS date_name,
    CONCAT(FORMAT(calendar_date, 'ddd'), ', ', FORMAT(calendar_date, 'dd MMM yyyy')) AS date_short_label,
    CONCAT(FORMAT(calendar_date, 'ddd'), ', ', FORMAT(calendar_date, 'dd MMMM yyyy')) AS date_label,
    CAST(CASE WHEN LEFT(FORMAT(calendar_date, 'ddd'), 1) = 'S' THEN 1 ELSE 0 END AS BIT) AS is_weekend,
    CASE WHEN DATEPART(WEEKDAY, calendar_date) = 1 THEN 7 ELSE DATEPART(WEEKDAY, calendar_date) - 1 END AS day_of_week_no,
    FORMAT(calendar_date, 'ddd') AS day_of_week_short_name,
    DATEPART(WEEKDAY, calendar_date) AS day_of_week_in_month_no,
    DATEPART(DAY, calendar_date) AS day_of_month,
    DATEPART(DAYOFYEAR, calendar_date) AS day_of_year,
    DATEPART(WEEK, calendar_date) AS week_of_year,
    CAST(FORMAT(calendar_date, 'yyyyMM') AS INT) AS year_month,
    DATEPART(MONTH, calendar_date) AS month_no,
    FORMAT(calendar_date, 'MMM') AS month_short_name,
    FORMAT(calendar_date, 'MMMM') AS month_name,
    FORMAT(calendar_date, 'MMM yyyy') AS month_short_label,
    FORMAT(calendar_date, 'MMMM yyyy') AS month_label,
    CAST(CAST(YEAR(calendar_date) AS VARCHAR) + CAST(DATEPART(QUARTER, calendar_date) AS VARCHAR) AS INT) AS quarter_id,
    DATEPART(QUARTER, calendar_date) AS quarter_no,
    FORMAT(calendar_date, 'Q') AS quarter_short_name,
    FORMAT(calendar_date, 'Q') + ' Quarter' AS quarter_name,
    FORMAT(calendar_date, 'Q') + ' Quarter ' + CAST(YEAR(calendar_date) AS VARCHAR) AS quarter_label,
    YEAR(calendar_date) AS [year]
	into #dates
FROM dates
WHERE calendar_date BETWEEN '2020-01-01' AND '2030-01-01'
OPTION (MAXRECURSION 0);  -- Allow recursion to generate all dates

-- Populate the table using the CTE and SELECT statement
INSERT INTO [dbo].[dim_dates] (
    date_sk,
    calendar_date,
    date_short_name,
    date_name,
    date_short_label,
    date_label,
    is_weekend,
    day_of_week_no,
    day_of_week_short_name,
    day_of_week_in_month_no,
    day_of_month,
    day_of_year,
    week_of_year,
    year_month,
    month_no,
    month_short_name,
    month_name,
    month_short_label,
    month_label,
    quarter_id,
    quarter_no,
    quarter_short_name,
    quarter_name,
    quarter_label,
    [year]
)
select * from #dates;