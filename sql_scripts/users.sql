-- Step 1: Create the login with a strong password
CREATE LOGIN profosama WITH PASSWORD = 'StrongP@ss123!';
GO

-- Step 2: Create the user for the login in the database
USE [consulting_db];--  database name
GO
CREATE USER Bos FOR LOGIN Bos;
GO

-- Step 3: Grant read and write privileges to the user
-- Option 1: Assign database roles
ALTER ROLE db_datareader ADD MEMBER profosama; -- Grant read access
ALTER ROLE db_datawriter ADD MEMBER profosama; -- Grant write access
GO

-- Option 2: Directly grant read and write permissions (optional, if specific table permissions are needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.YourTableName TO Bos; -- Replace with actual table name
