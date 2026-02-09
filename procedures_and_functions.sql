USE LibraryDB;
GO

-- Fine calculation function: ₹10 per day (adjustable)
CREATE FUNCTION lib.fn_CalculateFine(@DueDate DATE, @ReturnDate DATE)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @CalcReturn DATE = ISNULL(@ReturnDate, CAST(GETDATE() AS DATE));
    DECLARE @DaysLate INT = DATEDIFF(day, @DueDate, @CalcReturn);
    IF @DaysLate <= 0
        RETURN 0.00;
    DECLARE @Rate DECIMAL(10,2) = 10.00; -- ₹10 per day
    RETURN CAST(@DaysLate * @Rate AS DECIMAL(10,2));
END;
GO

-- Stored procedure to borrow a book
CREATE PROCEDURE lib.sp_BorrowBook
    @StudentID INT,
    @BookID INT,
    @Days INT = 14
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRAN;
    -- Check availability
    UPDATE lib.Books
    SET AvailableCopies = AvailableCopies - 1, UpdatedAt = SYSUTCDATETIME()
    WHERE BookID = @BookID AND AvailableCopies > 0;

    IF @@ROWCOUNT = 0
    BEGIN
        ROLLBACK TRAN;
        RAISERROR('Book not available.',16,1);
        RETURN;
    END

    DECLARE @DueDate DATE = DATEADD(day, @Days, CAST(GETDATE() AS DATE));
    INSERT INTO lib.BorrowTransactions (StudentID, BookID, BorrowDate, DueDate)
    VALUES (@StudentID, @BookID, CAST(GETDATE() AS DATE), @DueDate);

    COMMIT TRAN;
END;
GO

-- Stored procedure to return a book
CREATE PROCEDURE lib.sp_ReturnBook
    @TransactionID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRAN;

    DECLARE @BookID INT; DECLARE @DueDate DATE; DECLARE @ReturnDate DATE = CAST(GETDATE() AS DATE);

    SELECT @BookID = BookID, @DueDate = DueDate FROM lib.BorrowTransactions WHERE TransactionID = @TransactionID;

    IF @BookID IS NULL
    BEGIN
        ROLLBACK TRAN;
        RAISERROR('Transaction not found.',16,1);
        RETURN;
    END

    -- Calculate fine using lib.fn_CalculateFine
    DECLARE @Fine DECIMAL(10,2);
    SELECT @Fine = lib.fn_CalculateFine(@DueDate, @ReturnDate);

    UPDATE lib.BorrowTransactions
    SET ReturnDate = @ReturnDate, FineAmount = @Fine, Status = 'RETURNED', UpdatedAt = SYSUTCDATETIME()
    WHERE TransactionID = @TransactionID;

    -- Increase available copies (ensure no overflow)
    UPDATE lib.Books
    SET AvailableCopies = CASE WHEN AvailableCopies IS NULL THEN 1 ELSE AvailableCopies + 1 END,
        UpdatedAt = SYSUTCDATETIME()
    WHERE BookID = @BookID;

    COMMIT TRAN;
END;
GO

-- Procedure to update all overdue fines (useful for jobs)
CREATE PROCEDURE lib.sp_UpdateAllFines
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE bt
    SET bt.FineAmount = lib.fn_CalculateFine(bt.DueDate, NULL), bt.UpdatedAt = SYSUTCDATETIME()
    FROM lib.BorrowTransactions bt
    WHERE bt.ReturnDate IS NULL AND bt.DueDate < CAST(GETDATE() AS DATE);
END;
GO
