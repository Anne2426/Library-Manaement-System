USE LibraryDB;
GO

-- Job step T-SQL: Daily update of overdue fines (to be configured in SQL Server Agent via SSMS - GUI steps below)
-- This query finds overdue (not returned) transactions and updates fines using fn_CalculateFine
UPDATE bt
SET bt.FineAmount = lib.fn_CalculateFine(bt.DueDate, NULL), bt.UpdatedAt = SYSUTCDATETIME()
FROM lib.BorrowTransactions bt
WHERE bt.ReturnDate IS NULL AND bt.DueDate < CAST(GETDATE() AS DATE);
GO

-- Monthly job: mark students inactive if no borrow in last 6 months
UPDATE s
SET s.Status = 'INACTIVE', s.UpdatedAt = SYSUTCDATETIME()
FROM lib.Students s
WHERE NOT EXISTS (
    SELECT 1 FROM lib.BorrowTransactions bt
    WHERE bt.StudentID = s.StudentID AND bt.BorrowDate >= DATEADD(month, -6, CAST(GETDATE() AS DATE))
) AND s.Status <> 'INACTIVE';
GO

-- Note: Create these jobs in SQL Server Agent (SSMS):
-- 1) Daily job: run the fine-update T-SQL daily at 00:15
-- 2) Monthly job: run the inactive-students T-SQL on the 1st of every month
-- Use Notifications and Owner settings as desired.
