USE LibraryDB;
GO

-- Generic DML audit trigger pattern. Create one per table.
-- Example: audit trigger for Students
CREATE TRIGGER trg_Students_Audit
ON lib.Students
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @User NVARCHAR(128) = SUSER_SNAME();

    -- INSERTS
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO lib.AuditLog (TableName, ActionType, UserName, OldData, NewData)
        SELECT 'lib.Students', 'INSERT', @User, NULL, (SELECT i.* FOR JSON PATH)
        FROM inserted i;
    END

    -- UPDATES
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO lib.AuditLog (TableName, ActionType, UserName, OldData, NewData)
        SELECT 'lib.Students', 'UPDATE', @User, (SELECT d.* FOR JSON PATH), (SELECT i.* FOR JSON PATH)
        FROM inserted i
        JOIN deleted d ON i.StudentID = d.StudentID;
    END

    -- DELETES
    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO lib.AuditLog (TableName, ActionType, UserName, OldData, NewData)
        SELECT 'lib.Students', 'DELETE', @User, (SELECT d.* FOR JSON PATH), NULL
        FROM deleted d;
    END
END;
GO

-- Repeat similar triggers for lib.Books and lib.BorrowTransactions
CREATE TRIGGER trg_Books_Audit
ON lib.Books
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @User NVARCHAR(128) = SUSER_SNAME();

    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO lib.AuditLog (TableName, ActionType, UserName, OldData, NewData)
        SELECT 'lib.Books', 'INSERT', @User, NULL, (SELECT i.* FOR JSON PATH)
        FROM inserted i;
    END

    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO lib.AuditLog (TableName, ActionType, UserName, OldData, NewData)
        SELECT 'lib.Books', 'UPDATE', @User, (SELECT d.* FOR JSON PATH), (SELECT i.* FOR JSON PATH)
        FROM inserted i
        JOIN deleted d ON i.BookID = d.BookID;
    END

    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO lib.AuditLog (TableName, ActionType, UserName, OldData, NewData)
        SELECT 'lib.Books', 'DELETE', @User, (SELECT d.* FOR JSON PATH), NULL
        FROM deleted d;
    END
END;
GO

CREATE TRIGGER trg_Borrow_Audit
ON lib.BorrowTransactions
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @User NVARCHAR(128) = SUSER_SNAME();

    IF EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO lib.AuditLog (TableName, ActionType, UserName, OldData, NewData)
        SELECT 'lib.BorrowTransactions', 'INSERT', @User, NULL, (SELECT i.* FOR JSON PATH)
        FROM inserted i;
    END

    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
    BEGIN
        INSERT INTO lib.AuditLog (TableName, ActionType, UserName, OldData, NewData)
        SELECT 'lib.BorrowTransactions', 'UPDATE', @User, (SELECT d.* FOR JSON PATH), (SELECT i.* FOR JSON PATH)
        FROM inserted i
        JOIN deleted d ON i.TransactionID = d.TransactionID;
    END

    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        INSERT INTO lib.AuditLog (TableName, ActionType, UserName, OldData, NewData)
        SELECT 'lib.BorrowTransactions', 'DELETE', @User, (SELECT d.* FOR JSON PATH), NULL
        FROM deleted d;
    END
END;
GO
