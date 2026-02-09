USE LibraryDB;
GO
SET NOCOUNT ON;

-- Generate 9,300 synthetic books into lib.Books
;WITH nums AS (
    SELECT TOP (9300) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_columns a CROSS JOIN sys.all_columns b
)
INSERT INTO lib.Books (ISBN, Title, Author, Publisher, YearPublished, TotalCopies, AvailableCopies, CreatedAt)
SELECT
    '978000' + RIGHT('000000000' + CAST(1000000 + n AS VARCHAR(9)), 9) AS ISBN,
    'Synthetic Book Title ' + CAST(n AS VARCHAR(10)) AS Title,
    CASE (n % 20)
        WHEN 0 THEN 'Paulo Coelho'
        WHEN 1 THEN 'Khaled Hosseini'
        WHEN 2 THEN 'Andy Weir'
        WHEN 3 THEN 'Delia Owens'
        WHEN 4 THEN 'J.K. Rowling'
        WHEN 5 THEN 'George Orwell'
        WHEN 6 THEN 'Jane Austen'
        WHEN 7 THEN 'Mark Twain'
        WHEN 8 THEN 'Ernest Hemingway'
        WHEN 9 THEN 'Harper Lee'
        WHEN 10 THEN 'Charles Dickens'
        WHEN 11 THEN 'F. Scott Fitzgerald'
        WHEN 12 THEN 'Stephen King'
        WHEN 13 THEN 'Neil Gaiman'
        WHEN 14 THEN 'John Steinbeck'
        WHEN 15 THEN 'Margaret Atwood'
        WHEN 16 THEN 'Salman Rushdie'
        WHEN 17 THEN 'Michael Crichton'
        WHEN 18 THEN 'Isabel Allende'
        ELSE 'Various'
    END AS Author,
    CASE (n % 10)
        WHEN 0 THEN 'HarperCollins'
        WHEN 1 THEN 'Penguin'
        WHEN 2 THEN 'Del Rey'
        WHEN 3 THEN 'Putnam'
        WHEN 4 THEN 'Bloomsbury'
        WHEN 5 THEN 'Random House'
        WHEN 6 THEN 'Simon & Schuster'
        WHEN 7 THEN 'Knopf'
        WHEN 8 THEN 'Macmillan'
        ELSE 'O''Reilly'
    END AS Publisher,
    1950 + (n % 75) AS YearPublished,
    1 + (n % 5) AS TotalCopies,
    1 + (n % 5) AS AvailableCopies,
    SYSUTCDATETIME()
FROM nums;
GO

-- Quick validation
SELECT COUNT(*) AS BooksInserted FROM lib.Books WHERE Title LIKE 'Synthetic Book Title %';
GO