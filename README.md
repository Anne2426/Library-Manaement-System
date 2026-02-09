# 📚 Library Management System

**Author:** Anne  
**Database:** Microsoft SQL Server  
**Tool:** SQL Server Management Studio (SSMS)  
**Language:** T-SQL, Python

---

## 📌 Project Description

A complete Library Management System built using SQL Server that handles student registration, book cataloging (9,300+ books), borrowing/returning workflows, automatic fine calculation (₹10/day), audit logging, scheduled jobs, and reporting — all without using the command line.

---

## ✅ Features

✅ Student registration and management

✅ Book catalog with 9,300+ books

✅ Book borrowing and returning system

✅ Automatic fine calculation (₹10 per day late)

✅ Complete audit logging (INSERT / UPDATE / DELETE)

✅ 5 types of automated reports

✅ Daily and monthly automated checks (SQL Server Agent)

✅ Data integrity and validation (CHECK constraints, FKs, indexes)

✅ Python-based CSV data cleaning

---

## 🔄 Project Phases

| Phase | Description | Status |
|-------|-------------|--------|
| Phase 1 | Data Collection — CSVs, cleaning, validation | ✅ Done |
| Phase 2 | Database Setup — LibraryDB + lib schema | ✅ Done |
| Phase 3 | Table Design — Students, Books, Transactions, AuditLog | ✅ Done |
| Phase 4 | Keys & Performance — PK, FK, CHECK, Indexes | ✅ Done |
| Phase 5 | Load Data — Generate 1,000 students + 9,300 books | ✅ Done |
| Phase 6 | Transaction Flow — Borrow, Return, Copies update | ✅ Done |
| Phase 7 | Fine Automation — ₹10/day, stored in transaction | ✅ Done |
| Phase 8 | Scheduler — Daily fine update + Monthly inactivity check | ✅ Done |
| Phase 9 | Audit Tracking — Triggers on all 3 tables | ✅ Done |
| Phase 10 | Student Activity — Mark INACTIVE after 6 months | ✅ Done |
| Phase 11 | Reports — 5 report views | ✅ Done |
| Phase 12 | Final Validation — End-to-end test script | ✅ Done |

---

## 🗂️ Project Structure

```
library_system/
├── README.md
├── sql/
│   ├── create_database_and_schema.sql
│   ├── tables_and_constraints.sql
│   ├── triggers_and_audit.sql
│   ├── procedures_and_functions.sql
│   ├── registration_and_reports.sql
│   ├── generate_students_1000.sql
│   ├── generate_books_9300.sql
│   ├── create_agent_jobs.sql
│   ├── test_borrow_return_flow.sql
│   ├── load_validation_large.sql
│   └── jobs.sql
├── sample/
│   ├── students_sample.csv
│   ├── students_sample_cleaned.csv
│   ├── students_report.json
│   ├── students_1000.csv
│   ├── books_sample.csv
│   ├── books_sample_cleaned.csv
│   ├── books_report.json
│   └── books_500.csv
└── scripts/
    ├── clean_data.py
    └── requirements.txt
```

---

## 🛠️ Tech Stack

| Technology | Usage |
|------------|-------|
| SQL Server | Database engine |
| SSMS | GUI for running scripts |
| T-SQL | Stored procedures, functions, triggers, views |
| SQL Server Agent | Scheduled jobs (daily/monthly) |
| Python + pandas | CSV data cleaning |

---

## 📋 SQL Scripts (Run in Order)

| # | File | Purpose |
|---|------|---------|
| 1 | sql/create_database_and_schema.sql | Create LibraryDB database and lib schema |
| 2 | sql/tables_and_constraints.sql | Create tables, PKs, FKs, CHECK constraints, indexes |
| 3 | sql/triggers_and_audit.sql | Audit triggers for INSERT/UPDATE/DELETE |
| 4 | sql/procedures_and_functions.sql | Fine function, borrow/return/update procedures |
| 5 | sql/registration_and_reports.sql | Student registration procs and 5 report views |
| 6 | sql/generate_students_1000.sql | Generate 1,000 synthetic students |
| 7 | sql/generate_books_9300.sql | Generate 9,300 synthetic books |
| 8 | sql/create_agent_jobs.sql | Create daily fine + monthly inactivity jobs |
| 9 | sql/test_borrow_return_flow.sql | End-to-end test: borrow → return → fine → audit |
| 10 | sql/load_validation_large.sql | Row counts, duplicates, and data checks |

---

## 🚀 How to Use (SSMS GUI — No Command Line)

1. Open **SSMS** and connect to your SQL Server instance
2. Run scripts **1 through 5** in order (open each file → press **F5**)
3. Generate data: run scripts **6** and **7**
4. Create scheduled jobs: run script **8** (ensure SQL Server Agent is running)
5. Test the full flow: run script **9**
6. Validate data: run script **10**

---

## 🐍 Python Data Cleaning

1. Install Python and pandas (`pip install pandas`)
2. Edit `FILES_TO_CLEAN` in `scripts/clean_data.py` to point to your CSVs
3. Run the script — no arguments needed

---

## 🏗️ Database Objects

### Tables
| Table | Key Columns |
|-------|-------------|
| lib.Students | StudentID, FirstName, LastName, Email, Phone, Status |
| lib.Books | BookID, ISBN, Title, Author, Publisher, YearPublished, TotalCopies, AvailableCopies |
| lib.BorrowTransactions | TransactionID, StudentID, BookID, BorrowDate, DueDate, ReturnDate, FineAmount, Status |
| lib.AuditLog | AuditID, TableName, ActionType, UserName, ActionTime, OldData, NewData |

### Stored Procedures
| Procedure | Purpose |
|-----------|---------|
| lib.sp_RegisterStudent | Register a new student |
| lib.sp_UpdateStudentStatus | Change student status (ACTIVE/INACTIVE) |
| lib.sp_MarkInactiveStudents | Bulk mark students inactive (no borrow in 6 months) |
| lib.sp_BorrowBook | Borrow a book (decreases available copies) |
| lib.sp_ReturnBook | Return a book (calculates fine, increases copies) |
| lib.sp_UpdateAllFines | Batch update fines for all overdue books |

### Function
| Function | Purpose |
|----------|---------|
| lib.fn_CalculateFine | Calculate fine at ₹10 per day late |

### Report Views
| View | Shows |
|------|-------|
| lib.vw_OverdueBooks | Books not returned past due date |
| lib.vw_StudentFines | Students with highest total fines |
| lib.vw_MostBorrowedBooks | Most frequently borrowed books |
| lib.vw_StudentActivity | Active vs Inactive student count |
| lib.vw_MonthlyBorrowing | Monthly borrowing summary |

### Scheduled Jobs (SQL Server Agent)
| Job | Schedule |
|-----|----------|
| Daily_Update_Fines | Every day at 00:15 |
| Monthly_Mark_Inactive_Students | 1st of every month at 02:00 |

---

## 📎 Reference

- [Library Management Data Analysis Using SQL — GeeksforGeeks](https://www.geeksforgeeks.org/sql/library-management-data-analysis-using-sql/)

---

## 📄 License

This project is for educational purposes.
