-- Create database and schema
-- Run in SSMS (Connections -> New Query) after connecting to server.
CREATE DATABASE LibraryDB;
GO
USE LibraryDB;
GO
-- Create a dedicated schema for library objects
CREATE SCHEMA lib AUTHORIZATION dbo;
GO
-- OPTIONAL: Set default schema for a specific user (replace YOUR_DB_USER)
-- ALTER USER [YOUR_DB_USER] WITH DEFAULT_SCHEMA = lib;
-- GO

-- Set context to the library schema for the session where needed:
-- In SQL Server you cannot set a schema 'for session' directly; use schema-qualified names (lib.TableName) or ALTER USER as above.
