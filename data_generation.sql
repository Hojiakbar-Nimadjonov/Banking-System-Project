-- Banking System Data Generation Script
-- This script will populate all tables with realistic banking data

-- Set up variables for data generation
DECLARE @i INT = 1;
DECLARE @CustomerCount INT = 10000;
DECLARE @BranchCount INT = 50;
DECLARE @EmployeeCount INT = 500;
DECLARE @TransactionCount INT = 50000;
DECLARE @LoanCount INT = 3000;
DECLARE @CreditCardCount INT = 8000;

-- Arrays for realistic data
DECLARE @FirstNames TABLE (Name NVARCHAR(50));
DECLARE @LastNames TABLE (Name NVARCHAR(50));
DECLARE @Cities TABLE (City NVARCHAR(50), State NVARCHAR(50), Country NVARCHAR(50));
DECLARE @Banks TABLE (BankName NVARCHAR(100));
DECLARE @Merchants TABLE (MerchantName NVARCHAR(100), Industry NVARCHAR(50));

-- Populate lookup tables
INSERT INTO @FirstNames VALUES 
('John'),('Mary'),('James'),('Patricia'),('Robert'),('Jennifer'),('Michael'),('Linda'),('William'),('Elizabeth'),
('David'),('Barbara'),('Richard'),('Susan'),('Joseph'),('Jessica'),('Thomas'),('Sarah'),('Christopher'),('Karen'),
('Charles'),('Nancy'),('Daniel'),('Lisa'),('Matthew'),('Betty'),('Anthony'),('Helen'),('Mark'),('Sandra'),
('Donald'),('Donna'),('Steven'),('Carol'),('Paul'),('Ruth'),('Andrew'),('Sharon'),('Joshua'),('Michelle'),
('Kenneth'),('Laura'),('Kevin'),('Emily'),('Brian'),('Kimberly'),('George'),('Deborah'),('Edward'),('Dorothy'),
('Ronald'),('Lisa'),('Timothy'),('Nancy'),('Jason'),('Karen'),('Jeffrey'),('Betty'),('Ryan'),('Helen'),
('Jacob'),('Sandra'),('Gary'),('Donna'),('Nicholas'),('Carol'),('Eric'),('Ruth'),('Jonathan'),('Sharon'),
('Stephen'),('Michelle'),('Larry'),('Laura'),('Justin'),('Emily'),('Scott'),('Kimberly'),('Brandon'),('Deborah'),
('Benjamin'),('Dorothy'),('Frank'),('Lisa'),('Gregory'),('Nancy'),('Raymond'),('Karen'),('Samuel'),('Betty'),
('Patrick'),('Helen'),('Alexander'),('Sandra'),('Jack'),('Donna'),('Dennis'),('Carol'),('Jerry'),('Ruth');

INSERT INTO @LastNames VALUES 
('Smith'),('Johnson'),('Williams'),('Brown'),('Jones'),('Garcia'),('Miller'),('Davis'),('Rodriguez'),('Martinez'),
('Hernandez'),('Lopez'),('Gonzalez'),('Wilson'),('Anderson'),('Thomas'),('Taylor'),('Moore'),('Jackson'),('Martin'),
('Lee'),('Perez'),('Thompson'),('White'),('Harris'),('Sanchez'),('Clark'),('Ramirez'),('Lewis'),('Robinson'),
('Walker'),('Young'),('Allen'),('King'),('Wright'),('Scott'),('Torres'),('Nguyen'),('Hill'),('Flores'),
('Green'),('Adams'),('Nelson'),('Baker'),('Hall'),('Rivera'),('Campbell'),('Mitchell'),('Carter'),('Roberts'),
('Gomez'),('Phillips'),('Evans'),('Turner'),('Diaz'),('Parker'),('Cruz'),('Edwards'),('Collins'),('Reyes'),
('Stewart'),('Morris'),('Morales'),('Murphy'),('Cook'),('Rogers'),('Gutierrez'),('Ortiz'),('Morgan'),('Cooper'),
('Peterson'),('Bailey'),('Reed'),('Kelly'),('Howard'),('Ramos'),('Kim'),('Cox'),('Ward'),('Richardson'),
('Watson'),('Brooks'),('Chavez'),('Wood'),('James'),('Bennett'),('Gray'),('Mendoza'),('Ruiz'),('Hughes'),
('Price'),('Alvarez'),('Castillo'),('Sanders'),('Patel'),('Myers'),('Long'),('Ross'),('Foster'),('Jimenez');

INSERT INTO @Cities VALUES 
('New York','NY','USA'),('Los Angeles','CA','USA'),('Chicago','IL','USA'),('Houston','TX','USA'),('Phoenix','AZ','USA'),
('Philadelphia','PA','USA'),('San Antonio','TX','USA'),('San Diego','CA','USA'),('Dallas','TX','USA'),('San Jose','CA','USA'),
('Austin','TX','USA'),('Jacksonville','FL','USA'),('Fort Worth','TX','USA'),('Columbus','OH','USA'),('Charlotte','NC','USA'),
('San Francisco','CA','USA'),('Indianapolis','IN','USA'),('Seattle','WA','USA'),('Denver','CO','USA'),('Washington','DC','USA'),
('Boston','MA','USA'),('El Paso','TX','USA'),('Nashville','TN','USA'),('Detroit','MI','USA'),('Oklahoma City','OK','USA'),
('Portland','OR','USA'),('Las Vegas','NV','USA'),('Memphis','TN','USA'),('Louisville','KY','USA'),('Baltimore','MD','USA'),
('Milwaukee','WI','USA'),('Albuquerque','NM','USA'),('Tucson','AZ','USA'),('Fresno','CA','USA'),('Sacramento','CA','USA'),
('Atlanta','GA','USA'),('Kansas City','MO','USA'),('Long Beach','CA','USA'),('Colorado Springs','CO','USA'),('Miami','FL','USA'),
('Raleigh','NC','USA'),('Omaha','NE','USA'),('Minneapolis','MN','USA'),('Tulsa','OK','USA'),('Cleveland','OH','USA'),
('Wichita','KS','USA'),('Arlington','TX','USA'),('New Orleans','LA','USA'),('Bakersfield','CA','USA'),('Tampa','FL','USA'),
('Honolulu','HI','USA'),('Aurora','CO','USA'),('Anaheim','CA','USA'),('Santa Ana','CA','USA'),('Corpus Christi','TX','USA');

INSERT INTO @Banks VALUES 
('Chase Bank'),('Bank of America'),('Wells Fargo'),('Citibank'),('US Bank'),
('PNC Bank'),('Capital One'),('TD Bank'),('Goldman Sachs'),('Morgan Stanley'),
('American Express'),('Discover Bank'),('Ally Bank'),('Charles Schwab'),('Fidelity Bank');

INSERT INTO @Merchants VALUES 
('Walmart','Retail'),('Amazon','E-commerce'),('Target','Retail'),('Home Depot','Home Improvement'),
('Costco','Wholesale'),('Best Buy','Electronics'),('Starbucks','Food & Beverage'),('McDonald''s','Fast Food'),
('Subway','Fast Food'),('KFC','Fast Food'),('Burger King','Fast Food'),('Pizza Hut','Fast Food'),
('Domino''s','Fast Food'),('Wendy''s','Fast Food'),('Taco Bell','Fast Food'),('Shell','Gas Station'),
('ExxonMobil','Gas Station'),('Chevron','Gas Station'),('BP','Gas Station'),('Marathon','Gas Station'),
('Netflix','Entertainment'),('Spotify','Entertainment'),('Hulu','Entertainment'),('Disney+','Entertainment'),
('Apple Store','Electronics'),('Microsoft Store','Electronics'),('Google Play','Digital Services'),
('Uber','Transportation'),('Lyft','Transportation'),('Airbnb','Travel'),('Booking.com','Travel'),
('Expedia','Travel'),('Delta Airlines','Airlines'),('American Airlines','Airlines'),('United Airlines','Airlines'),
('Southwest Airlines','Airlines'),('JetBlue','Airlines'),('Hilton','Hospitality'),('Marriott','Hospitality'),
('Hyatt','Hospitality'),('Holiday Inn','Hospitality'),('CVS','Pharmacy'),('Walgreens','Pharmacy'),
('Rite Aid','Pharmacy'),('Kroger','Grocery'),('Safeway','Grocery'),('Albertsons','Grocery'),
('Publix','Grocery'),('Whole Foods','Grocery'),('Trader Joe''s','Grocery'),('Aldi','Grocery');

-- 1. Generate Branches
PRINT 'Generating Branches...';
WHILE @i <= @BranchCount
BEGIN
    DECLARE @CityIndex INT = (@i % (SELECT COUNT(*) FROM @Cities)) + 1;
    DECLARE @BankIndex INT = (@i % (SELECT COUNT(*) FROM @Banks)) + 1;
    DECLARE @City NVARCHAR(50), @State NVARCHAR(50), @Country NVARCHAR(50), @BankName NVARCHAR(100);
    
    SELECT @City = City, @State = State, @Country = Country FROM @Cities ORDER BY (SELECT NULL) OFFSET (@CityIndex-1) ROWS FETCH NEXT 1 ROWS ONLY;
    SELECT @BankName = BankName FROM @Banks ORDER BY (SELECT NULL) OFFSET (@BankIndex-1) ROWS FETCH NEXT 1 ROWS ONLY;
    
    INSERT INTO Branches (BranchName, Address, City, State, Country, ContactNumber)
    VALUES (
        @BankName + ' - ' + @City + ' Branch',
        CAST(@i AS NVARCHAR(10)) + ' Main Street',
        @City,
        @State,
        @Country,
        '+1-' + CAST(555 + (@i % 900) AS NVARCHAR(10)) + '-' + CAST(1000 + (@i % 9000) AS NVARCHAR(10))
    );
    
    SET @i = @i + 1;
END;

-- 2. Generate Employees
PRINT 'Generating Employees...';
SET @i = 1;
WHILE @i <= @EmployeeCount
BEGIN
    DECLARE @FirstName NVARCHAR(50), @LastName NVARCHAR(50);
    DECLARE @BranchID INT = (@i % @BranchCount) + 1;
    DECLARE @Position NVARCHAR(50);
    DECLARE @Department NVARCHAR(50);
    DECLARE @Salary DECIMAL(10,2);
    
    SELECT @FirstName = Name FROM @FirstNames ORDER BY (SELECT NULL) OFFSET (@i % (SELECT COUNT(*) FROM @FirstNames)) ROWS FETCH NEXT 1 ROWS ONLY;
    SELECT @LastName = Name FROM @LastNames ORDER BY (SELECT NULL) OFFSET (@i % (SELECT COUNT(*) FROM @LastNames)) ROWS FETCH NEXT 1 ROWS ONLY;
    
    -- Assign positions and departments
    IF @i % 10 = 0
    BEGIN
        SET @Position = 'Branch Manager';
        SET @Department = 'Management';
        SET @Salary = 75000 + (@i % 50000);
    END
    ELSE IF @i % 5 = 0
    BEGIN
        SET @Position = 'Loan Officer';
        SET @Department = 'Lending';
        SET @Salary = 55000 + (@i % 30000);
    END
    ELSE IF @i % 3 = 0
    BEGIN
        SET @Position = 'Teller';
        SET @Department = 'Operations';
        SET @Salary = 35000 + (@i % 20000);
    END
    ELSE
    BEGIN
        SET @Position = 'Customer Service';
        SET @Department = 'Customer Relations';
        SET @Salary = 40000 + (@i % 25000);
    END
    
    INSERT INTO Employees (BranchID, FullName, Position, Department, Salary, HireDate, Email, PhoneNumber)
    VALUES (
        @BranchID,
        @FirstName + ' ' + @LastName,
        @Position,
        @Department,
        @Salary,
        DATEADD(DAY, -(@i * 30), GETDATE()),
        LOWER(@FirstName) + '.' + LOWER(@LastName) + '@bank.com',
        '+1-' + CAST(555 + (@i % 900) AS NVARCHAR(10)) + '-' + CAST(1000 + (@i % 9000) AS NVARCHAR(10))
    );
    
    SET @i = @i + 1;
END;

-- Update Branch Manager IDs
UPDATE b SET ManagerID = e.EmployeeID
FROM Branches b
INNER JOIN Employees e ON b.BranchID = e.BranchID
WHERE e.Position = 'Branch Manager';

-- 3. Generate Customers
PRINT 'Generating Customers...';
SET @i = 1;
WHILE @i <= @CustomerCount
BEGIN
    DECLARE @CustomerFirstName NVARCHAR(50), @CustomerLastName NVARCHAR(50);
    DECLARE @CustomerCity NVARCHAR(50), @CustomerState NVARCHAR(50), @CustomerCountry NVARCHAR(50);
    DECLARE @DOB DATE;
    DECLARE @EmploymentStatus NVARCHAR(50);
    DECLARE @AnnualIncome DECIMAL(15,2);
    
    SELECT @CustomerFirstName = Name FROM @FirstNames ORDER BY (SELECT NULL) OFFSET (@i % (SELECT COUNT(*) FROM @FirstNames)) ROWS FETCH NEXT 1 ROWS ONLY;
    SELECT @CustomerLastName = Name FROM @LastNames ORDER BY (SELECT NULL) OFFSET (@i % (SELECT COUNT(*) FROM @LastNames)) ROWS FETCH NEXT 1 ROWS ONLY;
    SELECT @CustomerCity = City, @CustomerState = State, @CustomerCountry = Country FROM @Cities ORDER BY (SELECT NULL) OFFSET (@i % (SELECT COUNT(*) FROM @Cities)) ROWS FETCH NEXT 1 ROWS ONLY;
    
    SET @DOB = DATEADD(YEAR, -(18 + (@i % 62)), GETDATE());
    
    -- Assign employment status and income
    IF @i % 10 = 0
    BEGIN
        SET @EmploymentStatus = 'Unemployed';
        SET @AnnualIncome = 0;
    END
    ELSE IF @i % 5 = 0
    BEGIN
        SET @EmploymentStatus = 'Self-Employed';
        SET @AnnualIncome = 50000 + (@i % 150000);
    END
    ELSE IF @i % 3 = 0
    BEGIN
        SET @EmploymentStatus = 'Part-Time';
        SET @AnnualIncome = 25000 + (@i % 50000);
    END
    ELSE
    BEGIN
        SET @EmploymentStatus = 'Full-Time';
        SET @AnnualIncome = 40000 + (@i % 200000);
    END
    
    INSERT INTO Customers (FullName, DOB, Email, PhoneNumber, Address, City, State, Country, NationalID, TaxID, EmploymentStatus, AnnualIncome)
    VALUES (
        @CustomerFirstName + ' ' + @CustomerLastName,
        @DOB,
        LOWER(@CustomerFirstName) + '.' + LOWER(@CustomerLastName) + '@email.com',
        '+1-' + CAST(555 + (@i % 900) AS NVARCHAR(10)) + '-' + CAST(1000 + (@i % 9000) AS NVARCHAR(10)),
        CAST(@i AS NVARCHAR(10)) + ' Customer Street',
        @CustomerCity,
        @CustomerState,
        @CustomerCountry,
        'NID' + CAST(@i AS NVARCHAR(10)),
        'TAX' + CAST(@i AS NVARCHAR(10)),
        @EmploymentStatus,
        @AnnualIncome
    );
    
    SET @i = @i + 1;
END;

-- 4. Generate Accounts (multiple accounts per customer)
PRINT 'Generating Accounts...';
SET @i = 1;
WHILE @i <= @CustomerCount * 2 -- Average 2 accounts per customer
BEGIN
    DECLARE @CustomerID INT = (@i % @CustomerCount) + 1;
    DECLARE @BranchID INT = (@i % @BranchCount) + 1;
    DECLARE @AccountType NVARCHAR(20);
    DECLARE @Balance DECIMAL(15,2);
    
    -- Assign account types
    IF @i % 4 = 0
        SET @AccountType = 'Savings';
    ELSE IF @i % 3 = 0
        SET @AccountType = 'Checking';
    ELSE IF @i % 2 = 0
        SET @AccountType = 'Business';
    ELSE
        SET @AccountType = 'Investment';
    
    -- Generate realistic balances
    IF @AccountType = 'Savings'
        SET @Balance = 1000 + (@i % 50000);
    ELSE IF @AccountType = 'Checking'
        SET @Balance = 500 + (@i % 10000);
    ELSE IF @AccountType = 'Business'
        SET @Balance = 5000 + (@i % 100000);
    ELSE
        SET @Balance = 10000 + (@i % 200000);
    
    INSERT INTO Accounts (CustomerID, AccountType, Balance, BranchID)
    VALUES (@CustomerID, @AccountType, @Balance, @BranchID);
    
    SET @i = @i + 1;
END;

-- 5. Generate Transactions
PRINT 'Generating Transactions...';
SET @i = 1;
WHILE @i <= @TransactionCount
BEGIN
    DECLARE @AccountID INT = (@i % (SELECT COUNT(*) FROM Accounts)) + 1;
    DECLARE @TransactionType NVARCHAR(20);
    DECLARE @Amount DECIMAL(15,2);
    DECLARE @TransactionDate DATETIME2;
    DECLARE @MerchantIndex INT = (@i % (SELECT COUNT(*) FROM @Merchants)) + 1;
    DECLARE @MerchantName NVARCHAR(100);
    
    SELECT @MerchantName = MerchantName FROM @Merchants ORDER BY (SELECT NULL) OFFSET (@MerchantIndex-1) ROWS FETCH NEXT 1 ROWS ONLY;
    
    -- Assign transaction types
    IF @i % 5 = 0
        SET @TransactionType = 'Deposit';
    ELSE IF @i % 4 = 0
        SET @TransactionType = 'Withdrawal';
    ELSE IF @i % 3 = 0
        SET @TransactionType = 'Transfer';
    ELSE
        SET @TransactionType = 'Payment';
    
    -- Generate realistic amounts
    IF @TransactionType = 'Deposit'
        SET @Amount = 100 + (@i % 5000);
    ELSE IF @TransactionType = 'Withdrawal'
        SET @Amount = 50 + (@i % 1000);
    ELSE IF @TransactionType = 'Transfer'
        SET @Amount = 200 + (@i % 3000);
    ELSE
        SET @Amount = 25 + (@i % 500);
    
    SET @TransactionDate = DATEADD(MINUTE, -(@i * 10), GETDATE());
    
    INSERT INTO Transactions (AccountID, TransactionType, Amount, TransactionDate, Description, Location, IPAddress, DeviceType)
    VALUES (
        @AccountID,
        @TransactionType,
        @Amount,
        @TransactionDate,
        @TransactionType + ' at ' + @MerchantName,
        'Location ' + CAST(@i % 100 AS NVARCHAR(10)),
        '192.168.' + CAST(@i % 255 AS NVARCHAR(10)) + '.' + CAST(@i % 255 AS NVARCHAR(10)),
        CASE WHEN @i % 3 = 0 THEN 'Mobile' WHEN @i % 2 = 0 THEN 'Desktop' ELSE 'Tablet' END
    );
    
    SET @i = @i + 1;
END;

-- 6. Generate Credit Cards
PRINT 'Generating Credit Cards...';
SET @i = 1;
WHILE @i <= @CreditCardCount
BEGIN
    DECLARE @CardCustomerID INT = (@i % @CustomerCount) + 1;
    DECLARE @CardType NVARCHAR(20);
    DECLARE @CreditLimit DECIMAL(15,2);
    DECLARE @CurrentBalance DECIMAL(15,2);
    
    -- Assign card types
    IF @i % 4 = 0
        SET @CardType = 'Visa';
    ELSE IF @i % 3 = 0
        SET @CardType = 'Mastercard';
    ELSE IF @i % 2 = 0
        SET @CardType = 'American Express';
    ELSE
        SET @CardType = 'Discover';
    
    SET @CreditLimit = 1000 + (@i % 20000);
    SET @CurrentBalance = (@i % @CreditLimit) * 0.3; -- 30% utilization on average
    
    INSERT INTO CreditCards (CustomerID, CardNumber, CardType, CVV, ExpiryDate, CreditLimit, CurrentBalance)
    VALUES (
        @CardCustomerID,
        CAST(4000 + (@i % 9999) AS NVARCHAR(16)),
        @CardType,
        CAST(100 + (@i % 900) AS NVARCHAR(4)),
        DATEADD(YEAR, 3, GETDATE()),
        @CreditLimit,
        @CurrentBalance
    );
    
    SET @i = @i + 1;
END;

-- 7. Generate Credit Card Transactions
PRINT 'Generating Credit Card Transactions...';
SET @i = 1;
WHILE @i <= @TransactionCount / 2
BEGIN
    DECLARE @CardID INT = (@i % @CreditCardCount) + 1;
    DECLARE @CCMerchantIndex INT = (@i % (SELECT COUNT(*) FROM @Merchants)) + 1;
    DECLARE @CCMerchantName NVARCHAR(100), @CCIndustry NVARCHAR(50);
    
    SELECT @CCMerchantName = MerchantName, @CCIndustry = Industry FROM @Merchants ORDER BY (SELECT NULL) OFFSET (@CCMerchantIndex-1) ROWS FETCH NEXT 1 ROWS ONLY;
    
    DECLARE @CCAmount DECIMAL(15,2) = 10 + (@i % 500);
    DECLARE @CCTransactionDate DATETIME2 = DATEADD(MINUTE, -(@i * 15), GETDATE());
    
    INSERT INTO CreditCardTransactions (CardID, Merchant, Amount, TransactionDate, Location, MerchantCategory)
    VALUES (
        @CardID,
        @CCMerchantName,
        @CCAmount,
        @CCTransactionDate,
        'Location ' + CAST(@i % 100 AS NVARCHAR(10)),
        @CCIndustry
    );
    
    SET @i = @i + 1;
END;

-- 8. Generate Loans
PRINT 'Generating Loans...';
SET @i = 1;
WHILE @i <= @LoanCount
BEGIN
    DECLARE @LoanCustomerID INT = (@i % @CustomerCount) + 1;
    DECLARE @LoanBranchID INT = (@i % @BranchCount) + 1;
    DECLARE @LoanType NVARCHAR(20);
    DECLARE @LoanAmount DECIMAL(15,2);
    DECLARE @InterestRate DECIMAL(5,2);
    DECLARE @LoanEmployeeID INT;
    
    SELECT @LoanEmployeeID = EmployeeID FROM Employees WHERE Position = 'Loan Officer' ORDER BY (SELECT NULL) OFFSET (@i % 100) ROWS FETCH NEXT 1 ROWS ONLY;
    
    -- Assign loan types
    IF @i % 4 = 0
    BEGIN
        SET @LoanType = 'Mortgage';
        SET @LoanAmount = 200000 + (@i % 500000);
        SET @InterestRate = 3.5 + (@i % 300) / 100.0;
    END
    ELSE IF @i % 3 = 0
    BEGIN
        SET @LoanType = 'Personal';
        SET @LoanAmount = 5000 + (@i % 25000);
        SET @InterestRate = 8.0 + (@i % 800) / 100.0;
    END
    ELSE IF @i % 2 = 0
    BEGIN
        SET @LoanType = 'Auto';
        SET @LoanAmount = 15000 + (@i % 35000);
        SET @InterestRate = 5.0 + (@i % 500) / 100.0;
    END
    ELSE
    BEGIN
        SET @LoanType = 'Business';
        SET @LoanAmount = 50000 + (@i % 200000);
        SET @InterestRate = 6.0 + (@i % 600) / 100.0;
    END
    
    INSERT INTO Loans (CustomerID, LoanType, Amount, InterestRate, StartDate, EndDate, BranchID, ApprovedBy)
    VALUES (
        @LoanCustomerID,
        @LoanType,
        @LoanAmount,
        @InterestRate,
        DATEADD(MONTH, -(@i % 60), GETDATE()),
        DATEADD(MONTH, (@i % 120) + 60, GETDATE()),
        @LoanBranchID,
        @LoanEmployeeID
    );
    
    SET @i = @i + 1;
END;

-- 9. Generate Online Banking Users
PRINT 'Generating Online Banking Users...';
SET @i = 1;
WHILE @i <= @CustomerCount * 0.7 -- 70% of customers use online banking
BEGIN
    DECLARE @OnlineCustomerID INT = (@i % @CustomerCount) + 1;
    DECLARE @Username NVARCHAR(50);
    
    SELECT @Username = LOWER(FullName) + CAST(@i AS NVARCHAR(10)) FROM Customers WHERE CustomerID = @OnlineCustomerID;
    
    INSERT INTO OnlineBankingUsers (CustomerID, Username, PasswordHash, LastLogin)
    VALUES (
        @OnlineCustomerID,
        @Username,
        'hashed_password_' + CAST(@i AS NVARCHAR(10)),
        DATEADD(HOUR, -(@i % 168), GETDATE()) -- Last 7 days
    );
    
    SET @i = @i + 1;
END;

-- 10. Generate Bill Payments
PRINT 'Generating Bill Payments...';
SET @i = 1;
WHILE @i <= @CustomerCount
BEGIN
    DECLARE @BillCustomerID INT = @i;
    DECLARE @BillAmount DECIMAL(15,2) = 50 + (@i % 300);
    DECLARE @BillType NVARCHAR(50);
    
    IF @i % 4 = 0
        SET @BillType = 'Electricity';
    ELSE IF @i % 3 = 0
        SET @BillType = 'Water';
    ELSE IF @i % 2 = 0
        SET @BillType = 'Internet';
    ELSE
        SET @BillType = 'Phone';
    
    INSERT INTO BillPayments (CustomerID, BillerName, Amount, BillType, DueDate)
    VALUES (
        @BillCustomerID,
        @BillType + ' Company',
        @BillAmount,
        @BillType,
        DATEADD(DAY, (@i % 30), GETDATE())
    );
    
    SET @i = @i + 1;
END;

-- 11. Generate Mobile Banking Transactions
PRINT 'Generating Mobile Banking Transactions...';
SET @i = 1;
WHILE @i <= @TransactionCount / 3
BEGIN
    DECLARE @MobileCustomerID INT = (@i % @CustomerCount) + 1;
    DECLARE @MobileAmount DECIMAL(15,2) = 10 + (@i % 200);
    DECLARE @MobileTransactionDate DATETIME2 = DATEADD(MINUTE, -(@i * 20), GETDATE());
    
    INSERT INTO MobileBankingTransactions (CustomerID, DeviceID, AppVersion, TransactionType, Amount, TransactionDate, Location, DeviceType)
    VALUES (
        @MobileCustomerID,
        'Device_' + CAST(@i AS NVARCHAR(10)),
        '2.' + CAST(@i % 10 AS NVARCHAR(10)) + '.' + CAST(@i % 100 AS NVARCHAR(10)),
        CASE WHEN @i % 3 = 0 THEN 'Transfer' WHEN @i % 2 = 0 THEN 'Payment' ELSE 'Check Balance' END,
        @MobileAmount,
        @MobileTransactionDate,
        'Location ' + CAST(@i % 100 AS NVARCHAR(10)),
        CASE WHEN @i % 3 = 0 THEN 'iPhone' WHEN @i % 2 = 0 THEN 'Android' ELSE 'iPad' END
    );
    
    SET @i = @i + 1;
END;

-- 12. Generate Credit Scores
PRINT 'Generating Credit Scores...';
SET @i = 1;
WHILE @i <= @CustomerCount
BEGIN
    DECLARE @CreditScore INT = 300 + (@i % 500); -- 300-800 range
    
    INSERT INTO CreditScores (CustomerID, CreditScore, CreditBureau)
    VALUES (
        @i,
        @CreditScore,
        CASE WHEN @i % 3 = 0 THEN 'Experian' WHEN @i % 2 = 0 THEN 'TransUnion' ELSE 'Equifax' END
    );
    
    SET @i = @i + 1;
END;

-- 13. Generate KYC Records
PRINT 'Generating KYC Records...';
SET @i = 1;
WHILE @i <= @CustomerCount
BEGIN
    DECLARE @KYCEmployeeID INT;
    SELECT @KYCEmployeeID = EmployeeID FROM Employees WHERE Position = 'Customer Service' ORDER BY (SELECT NULL) OFFSET (@i % 100) ROWS FETCH NEXT 1 ROWS ONLY;
    
    INSERT INTO KYC (CustomerID, DocumentType, DocumentNumber, VerifiedBy, Status, ExpiryDate)
    VALUES (
        @i,
        CASE WHEN @i % 3 = 0 THEN 'Passport' WHEN @i % 2 = 0 THEN 'Driver License' ELSE 'National ID' END,
        'DOC' + CAST(@i AS NVARCHAR(10)),
        @KYCEmployeeID,
        CASE WHEN @i % 10 = 0 THEN 'Pending' ELSE 'Verified' END,
        DATEADD(YEAR, 5, GETDATE())
    );
    
    SET @i = @i + 1;
END;

-- 14. Generate Fraud Detection Records
PRINT 'Generating Fraud Detection Records...';
SET @i = 1;
WHILE @i <= @CustomerCount * 0.05 -- 5% of customers have fraud flags
BEGIN
    DECLARE @FraudCustomerID INT = (@i * 20) % @CustomerCount + 1;
    DECLARE @FraudEmployeeID INT;
    SELECT @FraudEmployeeID = EmployeeID FROM Employees WHERE Position = 'Loan Officer' ORDER BY (SELECT NULL) OFFSET (@i % 50) ROWS FETCH NEXT 1 ROWS ONLY;
    
    INSERT INTO FraudDetection (CustomerID, TransactionID, RiskLevel, Status, Description, InvestigatorID)
    VALUES (
        @FraudCustomerID,
        (@i * 100) % @TransactionCount + 1,
        CASE WHEN @i % 3 = 0 THEN 'High' WHEN @i % 2 = 0 THEN 'Medium' ELSE 'Low' END,
        CASE WHEN @i % 5 = 0 THEN 'Resolved' ELSE 'Under Investigation' END,
        'Suspicious transaction pattern detected',
        @FraudEmployeeID
    );
    
    SET @i = @i + 1;
END;

-- 15. Generate Departments
PRINT 'Generating Departments...';
INSERT INTO Departments (DepartmentName) VALUES 
('Retail Banking'),('Commercial Banking'),('Investment Banking'),('Risk Management'),
('Compliance'),('IT'),('Human Resources'),('Marketing'),('Operations'),('Treasury');

-- 16. Generate Salaries
PRINT 'Generating Salaries...';
SET @i = 1;
WHILE @i <= @EmployeeCount
BEGIN
    DECLARE @SalaryEmployeeID INT = @i;
    DECLARE @BaseSalary DECIMAL(10,2);
    DECLARE @Bonus DECIMAL(10,2) = (@i % 5000);
    DECLARE @Deductions DECIMAL(10,2) = (@i % 2000);
    
    SELECT @BaseSalary = Salary FROM Employees WHERE EmployeeID = @SalaryEmployeeID;
    
    INSERT INTO Salaries (EmployeeID, BaseSalary, Bonus, Deductions, PaymentDate, PayPeriod)
    VALUES (
        @SalaryEmployeeID,
        @BaseSalary,
        @Bonus,
        @Deductions,
        DATEADD(MONTH, -(@i % 12), GETDATE()),
        'Monthly'
    );
    
    SET @i = @i + 1;
END;

-- 17. Generate Employee Attendance
PRINT 'Generating Employee Attendance...';
SET @i = 1;
WHILE @i <= @EmployeeCount * 30 -- 30 days of attendance per employee
BEGIN
    DECLARE @AttendanceEmployeeID INT = (@i % @EmployeeCount) + 1;
    DECLARE @AttendanceDate DATE = DATEADD(DAY, -(@i % 30), GETDATE());
    DECLARE @CheckInTime DATETIME2 = DATEADD(HOUR, 8, @AttendanceDate);
    DECLARE @CheckOutTime DATETIME2 = DATEADD(HOUR, 17, @AttendanceDate);
    
    INSERT INTO EmployeeAttendance (EmployeeID, CheckInTime, CheckOutTime, TotalHours, AttendanceDate)
    VALUES (
        @AttendanceEmployeeID,
        @CheckInTime,
        @CheckOutTime,
        8.0,
        @AttendanceDate
    );
    
    SET @i = @i + 1;
END;

-- 18. Generate Investments
PRINT 'Generating Investments...';
SET @i = 1;
WHILE @i <= @CustomerCount * 0.3 -- 30% of customers have investments
BEGIN
    DECLARE @InvestmentCustomerID INT = (@i * 3) % @CustomerCount + 1;
    DECLARE @InvestmentType NVARCHAR(50);
    DECLARE @InvestmentAmount DECIMAL(15,2);
    DECLARE @ROI DECIMAL(5,2);
    
    IF @i % 4 = 0
    BEGIN
        SET @InvestmentType = 'Stocks';
        SET @InvestmentAmount = 5000 + (@i % 50000);
        SET @ROI = 5.0 + (@i % 1500) / 100.0;
    END
    ELSE IF @i % 3 = 0
    BEGIN
        SET @InvestmentType = 'Bonds';
        SET @InvestmentAmount = 10000 + (@i % 100000);
        SET @ROI = 3.0 + (@i % 800) / 100.0;
    END
    ELSE IF @i % 2 = 0
    BEGIN
        SET @InvestmentType = 'Mutual Funds';
        SET @InvestmentAmount = 3000 + (@i % 30000);
        SET @ROI = 7.0 + (@i % 1200) / 100.0;
    END
    ELSE
    BEGIN
        SET @InvestmentType = 'Real Estate';
        SET @InvestmentAmount = 50000 + (@i % 200000);
        SET @ROI = 4.0 + (@i % 1000) / 100.0;
    END
    
    INSERT INTO Investments (CustomerID, InvestmentType, Amount, ROI, MaturityDate)
    VALUES (
        @InvestmentCustomerID,
        @InvestmentType,
        @InvestmentAmount,
        @ROI,
        DATEADD(YEAR, (@i % 10) + 1, GETDATE())
    );
    
    SET @i = @i + 1;
END;

-- 19. Generate Insurance Policies
PRINT 'Generating Insurance Policies...';
SET @i = 1;
WHILE @i <= @CustomerCount * 0.4 -- 40% of customers have insurance
BEGIN
    DECLARE @InsuranceCustomerID INT = (@i * 2) % @CustomerCount + 1;
    DECLARE @InsuranceType NVARCHAR(50);
    DECLARE @PremiumAmount DECIMAL(10,2);
    DECLARE @CoverageAmount DECIMAL(15,2);
    
    IF @i % 4 = 0
    BEGIN
        SET @InsuranceType = 'Life Insurance';
        SET @PremiumAmount = 100 + (@i % 500);
        SET @CoverageAmount = 100000 + (@i % 500000);
    END
    ELSE IF @i % 3 = 0
    BEGIN
        SET @InsuranceType = 'Auto Insurance';
        SET @PremiumAmount = 50 + (@i % 300);
        SET @CoverageAmount = 25000 + (@i % 100000);
    END
    ELSE IF @i % 2 = 0
    BEGIN
        SET @InsuranceType = 'Home Insurance';
        SET @PremiumAmount = 75 + (@i % 400);
        SET @CoverageAmount = 200000 + (@i % 300000);
    END
    ELSE
    BEGIN
        SET @InsuranceType = 'Health Insurance';
        SET @PremiumAmount = 200 + (@i % 800);
        SET @CoverageAmount = 50000 + (@i % 200000);
    END
    
    INSERT INTO InsurancePolicies (CustomerID, InsuranceType, PremiumAmount, CoverageAmount, StartDate, EndDate)
    VALUES (
        @InsuranceCustomerID,
        @InsuranceType,
        @PremiumAmount,
        @CoverageAmount,
        DATEADD(MONTH, -(@i % 24), GETDATE()),
        DATEADD(YEAR, 1, GETDATE())
    );
    
    SET @i = @i + 1;
END;

-- 20. Generate Merchants
PRINT 'Generating Merchants...';
SET @i = 1;
WHILE @i <= @CustomerCount * 0.1 -- 10% of customers are merchants
BEGIN
    DECLARE @MerchantCustomerID INT = (@i * 10) % @CustomerCount + 1;
    DECLARE @MerchantIndex INT = (@i % (SELECT COUNT(*) FROM @Merchants)) + 1;
    DECLARE @MerchantName NVARCHAR(100), @MerchantIndustry NVARCHAR(50);
    
    SELECT @MerchantName = MerchantName, @MerchantIndustry = Industry FROM @Merchants ORDER BY (SELECT NULL) OFFSET (@MerchantIndex-1) ROWS FETCH NEXT 1 ROWS ONLY;
    
    INSERT INTO Merchants (MerchantName, Industry, Location, CustomerID)
    VALUES (
        @MerchantName + ' - Branch ' + CAST(@i AS NVARCHAR(10)),
        @MerchantIndustry,
        'Location ' + CAST(@i % 100 AS NVARCHAR(10)),
        @MerchantCustomerID
    );
    
    SET @i = @i + 1;
END;

-- 21. Generate User Access Logs
PRINT 'Generating User Access Logs...';
SET @i = 1;
WHILE @i <= @CustomerCount * 2 -- Multiple access logs per user
BEGIN
    DECLARE @LogUserID INT = (@i % @CustomerCount) + 1;
    DECLARE @ActionType NVARCHAR(50);
    DECLARE @LogTimestamp DATETIME2 = DATEADD(MINUTE, -(@i * 5), GETDATE());
    
    IF @i % 5 = 0
        SET @ActionType = 'Login';
    ELSE IF @i % 4 = 0
        SET @ActionType = 'Logout';
    ELSE IF @i % 3 = 0
        SET @ActionType = 'View Balance';
    ELSE IF @i % 2 = 0
        SET @ActionType = 'Transfer';
    ELSE
        SET @ActionType = 'Payment';
    
    INSERT INTO UserAccessLogs (UserID, ActionType, Timestamp, IPAddress, UserAgent, Success)
    VALUES (
        @LogUserID,
        @ActionType,
        @LogTimestamp,
        '192.168.' + CAST(@i % 255 AS NVARCHAR(10)) + '.' + CAST(@i % 255 AS NVARCHAR(10)),
        'Browser ' + CAST(@i % 5 AS NVARCHAR(10)),
        CASE WHEN @i % 20 = 0 THEN 0 ELSE 1 END -- 5% failure rate
    );
    
    SET @i = @i + 1;
END;

-- 22. Generate Cyber Security Incidents
PRINT 'Generating Cyber Security Incidents...';
SET @i = 1;
WHILE @i <= 100 -- 100 security incidents
BEGIN
    DECLARE @IncidentEmployeeID INT;
    SELECT @IncidentEmployeeID = EmployeeID FROM Employees WHERE Position = 'Customer Service' ORDER BY (SELECT NULL) OFFSET (@i % 50) ROWS FETCH NEXT 1 ROWS ONLY;
    
    INSERT INTO CyberSecurityIncidents (AffectedSystem, ResolutionStatus, Severity, Description, AssignedTo)
    VALUES (
        CASE WHEN @i % 4 = 0 THEN 'Online Banking' WHEN @i % 3 = 0 THEN 'Mobile App' WHEN @i % 2 = 0 THEN 'ATM Network' ELSE 'Internal Systems' END,
        CASE WHEN @i % 5 = 0 THEN 'Resolved' WHEN @i % 3 = 0 THEN 'In Progress' ELSE 'Open' END,
        CASE WHEN @i % 3 = 0 THEN 'High' WHEN @i % 2 = 0 THEN 'Medium' ELSE 'Low' END,
        'Security incident ' + CAST(@i AS NVARCHAR(10)) + ' detected',
        @IncidentEmployeeID
    );
    
    SET @i = @i + 1;
END;

PRINT 'Data generation completed successfully!';
PRINT 'Generated:';
PRINT '- ' + CAST(@CustomerCount AS NVARCHAR(10)) + ' Customers';
PRINT '- ' + CAST(@BranchCount AS NVARCHAR(10)) + ' Branches';
PRINT '- ' + CAST(@EmployeeCount AS NVARCHAR(10)) + ' Employees';
PRINT '- ' + CAST(@TransactionCount AS NVARCHAR(10)) + ' Transactions';
PRINT '- ' + CAST(@CreditCardCount AS NVARCHAR(10)) + ' Credit Cards';
PRINT '- ' + CAST(@LoanCount AS NVARCHAR(10)) + ' Loans';
PRINT '- And many more records across all 30+ tables';
