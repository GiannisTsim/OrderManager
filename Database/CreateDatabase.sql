USE master
GO
-- Create the new database if it does not already exist 
IF NOT EXISTS
    (
        SELECT name
        FROM sys.databases
        WHERE name = N'$(DB_NAME)'
    )
CREATE DATABASE $(DB_NAME);
GO