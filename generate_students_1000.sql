USE LibraryDB;
GO
SET NOCOUNT ON;

-- Generate 1,000 synthetic students into lib.Students
;WITH nums AS (
    SELECT TOP (1000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_columns a CROSS JOIN sys.all_columns b
)
INSERT INTO lib.Students (FirstName, LastName, Email, Phone, Status, CreatedAt)
SELECT
    'First' + CAST(n AS VARCHAR(10)) AS FirstName,
    'Last' + CAST(n AS VARCHAR(10)) AS LastName,
    LOWER('student' + RIGHT('0000' + CAST(n AS VARCHAR(10)), 4) + '@example.com') AS Email,
    '555-' + RIGHT('0000' + CAST(1000 + n AS VARCHAR(10)), 4) AS Phone,
    'ACTIVE' AS Status,
    SYSUTCDATETIME()
FROM nums;
GO

SELECT COUNT(*) AS StudentsInserted FROM lib.Students WHERE Email LIKE 'student%';
GO