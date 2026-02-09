USE LibraryDB;
GO
SET NOCOUNT ON;

-- Test flow: register student, add book, borrow with due date in the past (overdue), return, validate fine and audit
BEGIN TRAN;

-- Register student
DECLARE @StudentID INT;
EXEC @StudentID = lib.sp_RegisterStudent @FirstName='Test', @LastName='User', @Email='test.user@example.com', @Phone='555-0000';
PRINT 'Registered StudentID: ' + CAST(@StudentID AS VARCHAR(10));

-- Create a single test book
INSERT INTO lib.Books (ISBN, Title, Author, Publisher, YearPublished, TotalCopies, AvailableCopies, CreatedAt)
VALUES ('9789999999000', 'Test Book For Flow', 'Test Author', 'Test Pub', 2020, 1, 1, SYSUTCDATETIME());
DECLARE @BookID INT = SCOPE_IDENTITY();
PRINT 'Inserted BookID: ' + CAST(@BookID AS VARCHAR(10));

COMMIT;

-- Borrow with Days = -5 to make it overdue by 5 days
EXEC lib.sp_BorrowBook @StudentID = @StudentID, @BookID = @BookID, @Days = -5;

-- Get transaction
DECLARE @TransactionID INT;
SELECT TOP 1 @TransactionID = TransactionID FROM lib.BorrowTransactions WHERE StudentID = @StudentID AND BookID = @BookID AND ReturnDate IS NULL ORDER BY TransactionID DESC;
PRINT 'Borrow TransactionID: ' + CAST(@TransactionID AS VARCHAR(10));

-- Confirm available copies decreased
SELECT BookID, AvailableCopies FROM lib.Books WHERE BookID = @BookID;

-- Return the book (this will calculate fine at ₹10/day)
EXEC lib.sp_ReturnBook @TransactionID = @TransactionID;

-- Check transaction details
SELECT TransactionID, StudentID, BookID, BorrowDate, DueDate, ReturnDate, FineAmount, Status FROM lib.BorrowTransactions WHERE TransactionID = @TransactionID;

-- Check audit log entries for borrower and book
SELECT TOP 10 * FROM lib.AuditLog WHERE TableName IN ('lib.BorrowTransactions','lib.Books','lib.Students') ORDER BY ActionTime DESC;

-- Clean up test data (optional)
-- DELETE FROM lib.BorrowTransactions WHERE TransactionID = @TransactionID;
-- DELETE FROM lib.Books WHERE BookID = @BookID;
-- DELETE FROM lib.Students WHERE StudentID = @StudentID;
GO