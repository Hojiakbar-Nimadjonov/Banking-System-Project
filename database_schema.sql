-- Banking System Database Schema
-- Core Banking Tables

-- 1. Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    DOB DATE NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber NVARCHAR(20),
    Address NVARCHAR(200),
    City NVARCHAR(50),
    State NVARCHAR(50),
    Country NVARCHAR(50),
    NationalID NVARCHAR(50),
    TaxID NVARCHAR(50),
    EmploymentStatus NVARCHAR(50),
    AnnualIncome DECIMAL(15,2),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);

-- 2. Branches
CREATE TABLE Branches (
    BranchID INT PRIMARY KEY IDENTITY(1,1),
    BranchName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(200),
    City NVARCHAR(50),
    State NVARCHAR(50),
    Country NVARCHAR(50),
    ContactNumber NVARCHAR(20),
    ManagerID INT,
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- 3. Employees
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    BranchID INT FOREIGN KEY REFERENCES Branches(BranchID),
    FullName NVARCHAR(100) NOT NULL,
    Position NVARCHAR(50),
    Department NVARCHAR(50),
    Salary DECIMAL(10,2),
    HireDate DATE,
    Status NVARCHAR(20) DEFAULT 'Active',
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- 4. Accounts
CREATE TABLE Accounts (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    AccountType NVARCHAR(20) NOT NULL,
    Balance DECIMAL(15,2) DEFAULT 0.00,
    Currency NVARCHAR(3) DEFAULT 'USD',
    Status NVARCHAR(20) DEFAULT 'Active',
    BranchID INT FOREIGN KEY REFERENCES Branches(BranchID),
    CreatedDate DATETIME2 DEFAULT GETDATE(),
    LastTransactionDate DATETIME2
);

-- 5. Transactions
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    AccountID INT FOREIGN KEY REFERENCES Accounts(AccountID),
    TransactionType NVARCHAR(20) NOT NULL,
    Amount DECIMAL(15,2) NOT NULL,
    Currency NVARCHAR(3) DEFAULT 'USD',
    TransactionDate DATETIME2 DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Completed',
    ReferenceNo NVARCHAR(50),
    Description NVARCHAR(200),
    Location NVARCHAR(100),
    IPAddress NVARCHAR(45),
    DeviceType NVARCHAR(50)
);

-- 6. CreditCards
CREATE TABLE CreditCards (
    CardID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    CardNumber NVARCHAR(16) NOT NULL,
    CardType NVARCHAR(20),
    CVV NVARCHAR(4),
    ExpiryDate DATE,
    CreditLimit DECIMAL(15,2),
    CurrentBalance DECIMAL(15,2) DEFAULT 0.00,
    Status NVARCHAR(20) DEFAULT 'Active',
    IssueDate DATE DEFAULT GETDATE()
);

-- 7. CreditCardTransactions
CREATE TABLE CreditCardTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    CardID INT FOREIGN KEY REFERENCES CreditCards(CardID),
    Merchant NVARCHAR(100),
    Amount DECIMAL(15,2) NOT NULL,
    Currency NVARCHAR(3) DEFAULT 'USD',
    TransactionDate DATETIME2 DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Completed',
    Location NVARCHAR(100),
    MerchantCategory NVARCHAR(50)
);

-- 8. OnlineBankingUsers
CREATE TABLE OnlineBankingUsers (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    Username NVARCHAR(50) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    LastLogin DATETIME2,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- 9. BillPayments
CREATE TABLE BillPayments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    BillerName NVARCHAR(100),
    Amount DECIMAL(15,2) NOT NULL,
    PaymentDate DATETIME2 DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Completed',
    BillType NVARCHAR(50),
    DueDate DATE
);

-- 10. MobileBankingTransactions
CREATE TABLE MobileBankingTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    DeviceID NVARCHAR(100),
    AppVersion NVARCHAR(20),
    TransactionType NVARCHAR(50),
    Amount DECIMAL(15,2),
    TransactionDate DATETIME2 DEFAULT GETDATE(),
    Location NVARCHAR(100),
    DeviceType NVARCHAR(50)
);

-- 11. Loans
CREATE TABLE Loans (
    LoanID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    LoanType NVARCHAR(20) NOT NULL,
    Amount DECIMAL(15,2) NOT NULL,
    InterestRate DECIMAL(5,2),
    StartDate DATE,
    EndDate DATE,
    Status NVARCHAR(20) DEFAULT 'Active',
    BranchID INT FOREIGN KEY REFERENCES Branches(BranchID),
    ApprovedBy INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- 12. LoanPayments
CREATE TABLE LoanPayments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    LoanID INT FOREIGN KEY REFERENCES Loans(LoanID),
    AmountPaid DECIMAL(15,2) NOT NULL,
    PaymentDate DATETIME2 DEFAULT GETDATE(),
    RemainingBalance DECIMAL(15,2),
    PaymentMethod NVARCHAR(50)
);

-- 13. CreditScores
CREATE TABLE CreditScores (
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    CreditScore INT,
    ScoreDate DATE DEFAULT GETDATE(),
    CreditBureau NVARCHAR(50),
    UpdatedAt DATETIME2 DEFAULT GETDATE(),
    PRIMARY KEY (CustomerID, ScoreDate)
);

-- 14. DebtCollection
CREATE TABLE DebtCollection (
    DebtID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    AmountDue DECIMAL(15,2) NOT NULL,
    DueDate DATE,
    CollectorAssigned INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    Status NVARCHAR(20) DEFAULT 'Active',
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- 15. KYC
CREATE TABLE KYC (
    KYCID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    DocumentType NVARCHAR(50),
    DocumentNumber NVARCHAR(100),
    VerifiedBy INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    VerificationDate DATETIME2 DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Pending',
    ExpiryDate DATE
);

-- 16. FraudDetection
CREATE TABLE FraudDetection (
    FraudID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    TransactionID INT,
    RiskLevel NVARCHAR(20),
    ReportedDate DATETIME2 DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Under Investigation',
    Description NVARCHAR(500),
    InvestigatorID INT FOREIGN KEY REFERENCES Employees(EmployeeID)
);

-- 17. AMLCases
CREATE TABLE AMLCases (
    CaseID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    CaseType NVARCHAR(50),
    Status NVARCHAR(20) DEFAULT 'Open',
    InvestigatorID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    ClosedAt DATETIME2,
    Description NVARCHAR(500)
);

-- 18. RegulatoryReports
CREATE TABLE RegulatoryReports (
    ReportID INT PRIMARY KEY IDENTITY(1,1),
    ReportType NVARCHAR(50),
    SubmissionDate DATETIME2 DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Submitted',
    Regulator NVARCHAR(100),
    ReportPeriod NVARCHAR(20)
);

-- 19. Departments
CREATE TABLE Departments (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName NVARCHAR(100) NOT NULL,
    ManagerID INT,
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- 20. Salaries
CREATE TABLE Salaries (
    SalaryID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    BaseSalary DECIMAL(10,2),
    Bonus DECIMAL(10,2) DEFAULT 0.00,
    Deductions DECIMAL(10,2) DEFAULT 0.00,
    PaymentDate DATE,
    PayPeriod NVARCHAR(20)
);

-- 21. EmployeeAttendance
CREATE TABLE EmployeeAttendance (
    AttendanceID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeID INT FOREIGN KEY REFERENCES Employees(EmployeeID),
    CheckInTime DATETIME2,
    CheckOutTime DATETIME2,
    TotalHours DECIMAL(5,2),
    AttendanceDate DATE DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Present'
);

-- 22. Investments
CREATE TABLE Investments (
    InvestmentID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    InvestmentType NVARCHAR(50),
    Amount DECIMAL(15,2),
    ROI DECIMAL(5,2),
    MaturityDate DATE,
    Status NVARCHAR(20) DEFAULT 'Active',
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- 23. StockTradingAccounts
CREATE TABLE StockTradingAccounts (
    AccountID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    BrokerageFirm NVARCHAR(100),
    TotalInvested DECIMAL(15,2),
    CurrentValue DECIMAL(15,2),
    Status NVARCHAR(20) DEFAULT 'Active',
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- 24. ForeignExchange
CREATE TABLE ForeignExchange (
    FXID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    CurrencyPair NVARCHAR(10),
    ExchangeRate DECIMAL(10,4),
    AmountExchanged DECIMAL(15,2),
    TransactionDate DATETIME2 DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Completed'
);

-- 25. InsurancePolicies
CREATE TABLE InsurancePolicies (
    PolicyID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    InsuranceType NVARCHAR(50),
    PremiumAmount DECIMAL(10,2),
    CoverageAmount DECIMAL(15,2),
    StartDate DATE,
    EndDate DATE,
    Status NVARCHAR(20) DEFAULT 'Active'
);

-- 26. Claims
CREATE TABLE Claims (
    ClaimID INT PRIMARY KEY IDENTITY(1,1),
    PolicyID INT FOREIGN KEY REFERENCES InsurancePolicies(PolicyID),
    ClaimAmount DECIMAL(15,2),
    Status NVARCHAR(20) DEFAULT 'Pending',
    FiledDate DATETIME2 DEFAULT GETDATE(),
    Description NVARCHAR(500),
    ApprovedBy INT FOREIGN KEY REFERENCES Employees(EmployeeID)
);

-- 27. UserAccessLogs
CREATE TABLE UserAccessLogs (
    LogID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT,
    ActionType NVARCHAR(50),
    Timestamp DATETIME2 DEFAULT GETDATE(),
    IPAddress NVARCHAR(45),
    UserAgent NVARCHAR(500),
    Success BIT DEFAULT 1
);

-- 28. CyberSecurityIncidents
CREATE TABLE CyberSecurityIncidents (
    IncidentID INT PRIMARY KEY IDENTITY(1,1),
    AffectedSystem NVARCHAR(100),
    ReportedDate DATETIME2 DEFAULT GETDATE(),
    ResolutionStatus NVARCHAR(20) DEFAULT 'Open',
    Severity NVARCHAR(20),
    Description NVARCHAR(500),
    AssignedTo INT FOREIGN KEY REFERENCES Employees(EmployeeID)
);

-- 29. Merchants
CREATE TABLE Merchants (
    MerchantID INT PRIMARY KEY IDENTITY(1,1),
    MerchantName NVARCHAR(100),
    Industry NVARCHAR(50),
    Location NVARCHAR(200),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID),
    Status NVARCHAR(20) DEFAULT 'Active',
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

-- 30. MerchantTransactions
CREATE TABLE MerchantTransactions (
    TransactionID INT PRIMARY KEY IDENTITY(1,1),
    MerchantID INT FOREIGN KEY REFERENCES Merchants(MerchantID),
    Amount DECIMAL(15,2),
    PaymentMethod NVARCHAR(50),
    TransactionDate DATETIME2 DEFAULT GETDATE(),
    Status NVARCHAR(20) DEFAULT 'Completed',
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
);

-- Add foreign key constraints for ManagerID references
ALTER TABLE Branches ADD CONSTRAINT FK_Branches_ManagerID 
    FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID);

ALTER TABLE Departments ADD CONSTRAINT FK_Departments_ManagerID 
    FOREIGN KEY (ManagerID) REFERENCES Employees(EmployeeID);

-- Create indexes for better performance
CREATE INDEX IX_Customers_Email ON Customers(Email);
CREATE INDEX IX_Accounts_CustomerID ON Accounts(CustomerID);
CREATE INDEX IX_Transactions_AccountID ON Transactions(AccountID);
CREATE INDEX IX_Transactions_Date ON Transactions(TransactionDate);
CREATE INDEX IX_Loans_CustomerID ON Loans(CustomerID);
CREATE INDEX IX_CreditCards_CustomerID ON CreditCards(CustomerID);
CREATE INDEX IX_Employees_BranchID ON Employees(BranchID);
