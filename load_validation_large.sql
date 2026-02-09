USE LibraryDB;
GO

-- Validation queries for large sample CSVs
-- 1) Row counts
SELECT 'Students count' AS Item, COUNT(*) AS RowCount FROM lib.Students;
SELECT 'Books count' AS Item, COUNT(*) AS RowCount FROM lib.Books;
SELECT 'BorrowTransactions count' AS Item, COUNT(*) AS RowCount FROM lib.BorrowTransactions;

-- 2) Sample records
SELECT TOP 10 * FROM lib.Students ORDER BY StudentID;
SELECT TOP 10 * FROM lib.Books ORDER BY BookID;

-- 3) Quick checks
-- Check for duplicate emails
SELECT Email, COUNT(*) AS Cnt FROM lib.Students GROUP BY Email HAVING COUNT(*) > 1;
-- Check for negative or inconsistent copies
SELECT * FROM lib.Books WHERE TotalCopies < 0 OR AvailableCopies < 0;
-- Check for overdue transactions
SELECT * FROM lib.BorrowTransactions WHERE ReturnDate IS NULL AND DueDate < CAST(GETDATE() AS DATE);
GO
