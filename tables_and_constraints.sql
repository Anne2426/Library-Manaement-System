USE LibraryDB;
GO

-- Students
CREATE TABLE lib.Students (
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(255) UNIQUE,
    Phone NVARCHAR(50),
    Status NVARCHAR(20) NOT NULL DEFAULT ('ACTIVE'),
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT CK_Students_Status CHECK (Status IN ('ACTIVE','INACTIVE')),
    CONSTRAINT CK_Students_EmailFormat CHECK (Email IS NULL OR CHARINDEX('@', Email) > 1)
);

-- Books
CREATE TABLE lib.Books (
    BookID INT IDENTITY(1,1) PRIMARY KEY,
    ISBN NVARCHAR(20) UNIQUE,
    Title NVARCHAR(500) NOT NULL,
    Author NVARCHAR(255),
    Publisher NVARCHAR(255),
    YearPublished INT,
    TotalCopies INT NOT NULL DEFAULT 1,
    AvailableCopies INT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT CK_Books_Copies CHECK (TotalCopies >= 0 AND AvailableCopies >= 0 AND AvailableCopies <= TotalCopies)
);

-- Borrow / Return transactions
CREATE TABLE lib.BorrowTransactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    StudentID INT NOT NULL,
    BookID INT NOT NULL,
    BorrowDate DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    DueDate DATE NOT NULL,
    ReturnDate DATE NULL,
    FineAmount DECIMAL(10,2) NOT NULL DEFAULT (0.00),
    Status NVARCHAR(20) NOT NULL DEFAULT ('BORROWED'),
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT CK_Borrow_Dates CHECK (DueDate >= BorrowDate AND (ReturnDate IS NULL OR ReturnDate >= BorrowDate)),
    CONSTRAINT FK_Borrow_Student FOREIGN KEY (StudentID) REFERENCES lib.Students(StudentID),
    CONSTRAINT FK_Borrow_Book FOREIGN KEY (BookID) REFERENCES lib.Books(BookID)
);

-- Audit log
CREATE TABLE lib.AuditLog (
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(128) NOT NULL,
    ActionType NVARCHAR(10) NOT NULL,
    UserName NVARCHAR(128) NOT NULL,
    ActionTime DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    OldData NVARCHAR(MAX) NULL,
    NewData NVARCHAR(MAX) NULL
);

-- Indexes for performance
CREATE INDEX IX_Students_Email ON lib.Students (Email);
CREATE INDEX IX_Books_ISBN ON lib.Books (ISBN);
CREATE INDEX IX_Books_Title ON lib.Books (Title);
CREATE INDEX IX_Borrow_DueDate ON lib.BorrowTransactions (DueDate);
CREATE INDEX IX_Borrow_Student ON lib.BorrowTransactions (StudentID);
CREATE INDEX IX_Borrow_Book ON lib.BorrowTransactions (BookID);
CREATE INDEX IX_Borrow_Status_DueDate ON lib.BorrowTransactions (Status, DueDate);
CREATE INDEX IX_Borrow_FineAmount ON lib.BorrowTransactions (FineAmount);
GO
