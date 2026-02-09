USE LibraryDB;
GO

-- Student registration & management
CREATE PROCEDURE lib.sp_RegisterStudent
    @FirstName NVARCHAR(100),
    @LastName NVARCHAR(100),
    @Email NVARCHAR(255),
    @Phone NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO lib.Students (FirstName, LastName, Email, Phone, Status, CreatedAt)
    VALUES (@FirstName, @LastName, @Email, @Phone, 'ACTIVE', SYSUTCDATETIME());

    SELECT SCOPE_IDENTITY() AS StudentID;
END;
GO

CREATE PROCEDURE lib.sp_UpdateStudentStatus
    @StudentID INT,
    @Status NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE lib.Students SET Status = @Status, UpdatedAt = SYSUTCDATETIME() WHERE StudentID = @StudentID;
END;
GO

-- Mark inactive students (run monthly)
CREATE PROCEDURE lib.sp_MarkInactiveStudents
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE s
    SET s.Status = 'INACTIVE', s.UpdatedAt = SYSUTCDATETIME()
    FROM lib.Students s
    WHERE NOT EXISTS (
        SELECT 1 FROM lib.BorrowTransactions bt
        WHERE bt.StudentID = s.StudentID AND bt.BorrowDate >= DATEADD(month, -6, CAST(GETDATE() AS DATE))
    ) AND s.Status <> 'INACTIVE';
END;
GO

-- Reporting views
CREATE VIEW lib.vw_OverdueBooks AS
SELECT bt.TransactionID, bt.StudentID, s.FirstName, s.LastName, bt.BookID, b.Title, bt.BorrowDate, bt.DueDate
FROM lib.BorrowTransactions bt
JOIN lib.Students s ON bt.StudentID = s.StudentID
JOIN lib.Books b ON bt.BookID = b.BookID
WHERE bt.ReturnDate IS NULL AND bt.DueDate < CAST(GETDATE() AS DATE);
GO

CREATE VIEW lib.vw_StudentFines AS
SELECT s.StudentID, s.FirstName, s.LastName, SUM(bt.FineAmount) AS TotalFines
FROM lib.BorrowTransactions bt
JOIN lib.Students s ON bt.StudentID = s.StudentID
GROUP BY s.StudentID, s.FirstName, s.LastName;
GO

CREATE VIEW lib.vw_MostBorrowedBooks AS
SELECT TOP 100 PERCENT b.BookID, b.Title, COUNT(*) AS BorrowCount
FROM lib.BorrowTransactions bt
JOIN lib.Books b ON bt.BookID = b.BookID
GROUP BY b.BookID, b.Title
ORDER BY BorrowCount DESC;
GO

CREATE VIEW lib.vw_StudentActivity AS
SELECT Status, COUNT(*) AS CountStudents FROM lib.Students GROUP BY Status;
GO

CREATE VIEW lib.vw_MonthlyBorrowing AS
SELECT TOP 100 PERCENT YEAR(BorrowDate) AS Yr, MONTH(BorrowDate) AS Mo, COUNT(*) AS Borrows
FROM lib.BorrowTransactions
GROUP BY YEAR(BorrowDate), MONTH(BorrowDate)
ORDER BY Yr, Mo;
GO
