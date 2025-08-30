-- Banking System BI Queries and Analytics
-- Addressing specific KPI requirements and banking system weaknesses

-- =====================================================
-- 1. TOP 3 CUSTOMERS WITH HIGHEST TOTAL BALANCE ACROSS ALL ACCOUNTS
-- =====================================================
SELECT TOP 3
    c.CustomerID,
    c.FullName,
    c.Email,
    c.AnnualIncome,
    SUM(a.Balance) as TotalBalance,
    COUNT(a.AccountID) as NumberOfAccounts
FROM Customers c
INNER JOIN Accounts a ON c.CustomerID = a.CustomerID
WHERE a.Status = 'Active'
GROUP BY c.CustomerID, c.FullName, c.Email, c.AnnualIncome
ORDER BY TotalBalance DESC;

-- =====================================================
-- 2. CUSTOMERS WHO HAVE MORE THAN ONE ACTIVE LOAN
-- =====================================================
SELECT 
    c.CustomerID,
    c.FullName,
    c.Email,
    c.AnnualIncome,
    COUNT(l.LoanID) as ActiveLoanCount,
    SUM(l.Amount) as TotalLoanAmount,
    AVG(l.InterestRate) as AverageInterestRate
FROM Customers c
INNER JOIN Loans l ON c.CustomerID = l.CustomerID
WHERE l.Status = 'Active'
GROUP BY c.CustomerID, c.FullName, c.Email, c.AnnualIncome
HAVING COUNT(l.LoanID) > 1
ORDER BY ActiveLoanCount DESC, TotalLoanAmount DESC;

-- =====================================================
-- 3. TRANSACTIONS THAT WERE FLAGGED AS FRAUDULENT
-- =====================================================
SELECT 
    fd.FraudID,
    c.CustomerID,
    c.FullName,
    fd.RiskLevel,
    fd.Status,
    fd.ReportedDate,
    fd.Description,
    t.TransactionID,
    t.Amount,
    t.TransactionType,
    t.TransactionDate,
    t.Location,
    t.IPAddress
FROM FraudDetection fd
INNER JOIN Customers c ON fd.CustomerID = c.CustomerID
LEFT JOIN Transactions t ON fd.TransactionID = t.TransactionID
ORDER BY fd.RiskLevel DESC, fd.ReportedDate DESC;

-- =====================================================
-- 4. TOTAL LOAN AMOUNT ISSUED PER BRANCH
-- =====================================================
SELECT 
    b.BranchID,
    b.BranchName,
    b.City,
    b.State,
    COUNT(l.LoanID) as TotalLoans,
    SUM(l.Amount) as TotalLoanAmount,
    AVG(l.InterestRate) as AverageInterestRate,
    COUNT(DISTINCT l.CustomerID) as UniqueCustomers
FROM Branches b
LEFT JOIN Loans l ON b.BranchID = l.BranchID
GROUP BY b.BranchID, b.BranchName, b.City, b.State
ORDER BY TotalLoanAmount DESC;

-- =====================================================
-- 5. CUSTOMERS WHO MADE MULTIPLE LARGE TRANSACTIONS (ABOVE $10,000) 
--    WITHIN SHORT TIME FRAME (LESS THAN 1 HOUR APART)
-- =====================================================
WITH LargeTransactions AS (
    SELECT 
        t.AccountID,
        t.TransactionDate,
        t.Amount,
        a.CustomerID,
        ROW_NUMBER() OVER (PARTITION BY a.CustomerID ORDER BY t.TransactionDate) as rn
    FROM Transactions t
    INNER JOIN Accounts a ON t.AccountID = a.AccountID
    WHERE t.Amount > 10000
),
SuspiciousCustomers AS (
    SELECT 
        lt1.CustomerID,
        lt1.TransactionDate as FirstTransaction,
        lt1.Amount as FirstAmount,
        lt2.TransactionDate as SecondTransaction,
        lt2.Amount as SecondAmount,
        DATEDIFF(MINUTE, lt1.TransactionDate, lt2.TransactionDate) as MinutesApart
    FROM LargeTransactions lt1
    INNER JOIN LargeTransactions lt2 ON lt1.CustomerID = lt2.CustomerID
    WHERE lt1.rn < lt2.rn
    AND DATEDIFF(MINUTE, lt1.TransactionDate, lt2.TransactionDate) < 60
)
SELECT 
    c.CustomerID,
    c.FullName,
    c.Email,
    sc.FirstTransaction,
    sc.FirstAmount,
    sc.SecondTransaction,
    sc.SecondAmount,
    sc.MinutesApart,
    (sc.FirstAmount + sc.SecondAmount) as TotalLargeTransactions
FROM SuspiciousCustomers sc
INNER JOIN Customers c ON sc.CustomerID = c.CustomerID
ORDER BY sc.MinutesApart ASC, TotalLargeTransactions DESC;

-- =====================================================
-- 6. CUSTOMERS WHO MADE TRANSACTIONS FROM DIFFERENT COUNTRIES 
--    WITHIN 10 MINUTES (COMMON RED FLAG FOR FRAUD)
-- =====================================================
WITH CountryTransactions AS (
    SELECT 
        t.AccountID,
        t.TransactionDate,
        t.Location,
        a.CustomerID,
        ROW_NUMBER() OVER (PARTITION BY a.CustomerID ORDER BY t.TransactionDate) as rn
    FROM Transactions t
    INNER JOIN Accounts a ON t.AccountID = a.AccountID
    WHERE t.Location IS NOT NULL
),
SuspiciousCountryTransactions AS (
    SELECT 
        ct1.CustomerID,
        ct1.TransactionDate as FirstTransaction,
        ct1.Location as FirstLocation,
        ct2.TransactionDate as SecondTransaction,
        ct2.Location as SecondLocation,
        DATEDIFF(MINUTE, ct1.TransactionDate, ct2.TransactionDate) as MinutesApart
    FROM CountryTransactions ct1
    INNER JOIN CountryTransactions ct2 ON ct1.CustomerID = ct2.CustomerID
    WHERE ct1.rn < ct2.rn
    AND ct1.Location != ct2.Location
    AND DATEDIFF(MINUTE, ct1.TransactionDate, ct2.TransactionDate) < 10
)
SELECT 
    c.CustomerID,
    c.FullName,
    c.Email,
    sct.FirstTransaction,
    sct.FirstLocation,
    sct.SecondTransaction,
    sct.SecondLocation,
    sct.MinutesApart
FROM SuspiciousCountryTransactions sct
INNER JOIN Customers c ON sct.CustomerID = c.CustomerID
ORDER BY sct.MinutesApart ASC;

-- =====================================================
-- CYBERSECURITY VULNERABILITIES ANALYSIS
-- =====================================================

-- 7. SUSPICIOUS LOGIN PATTERNS (MULTIPLE FAILED ATTEMPTS)
SELECT 
    ual.UserID,
    c.FullName,
    ual.IPAddress,
    COUNT(*) as FailedAttempts,
    MIN(ual.Timestamp) as FirstAttempt,
    MAX(ual.Timestamp) as LastAttempt,
    DATEDIFF(MINUTE, MIN(ual.Timestamp), MAX(ual.Timestamp)) as TimeSpan
FROM UserAccessLogs ual
INNER JOIN Customers c ON ual.UserID = c.CustomerID
WHERE ual.Success = 0
GROUP BY ual.UserID, c.FullName, ual.IPAddress
HAVING COUNT(*) > 3
ORDER BY FailedAttempts DESC;

-- 8. UNUSUAL TRANSACTION PATTERNS (LATE NIGHT TRANSACTIONS)
SELECT 
    c.CustomerID,
    c.FullName,
    t.TransactionID,
    t.Amount,
    t.TransactionType,
    t.TransactionDate,
    DATEPART(HOUR, t.TransactionDate) as HourOfDay,
    t.IPAddress,
    t.DeviceType
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
INNER JOIN Customers c ON a.CustomerID = c.CustomerID
WHERE DATEPART(HOUR, t.TransactionDate) BETWEEN 23 AND 5
AND t.Amount > 1000
ORDER BY t.TransactionDate DESC;

-- =====================================================
-- COMPLIANCE AND REGULATORY ANALYSIS
-- =====================================================

-- 9. KYC COMPLIANCE STATUS
SELECT 
    c.CustomerID,
    c.FullName,
    c.Email,
    k.Status as KYCStatus,
    k.VerificationDate,
    k.ExpiryDate,
    CASE 
        WHEN k.Status = 'Pending' THEN 'Non-Compliant'
        WHEN k.ExpiryDate < GETDATE() THEN 'Expired'
        ELSE 'Compliant'
    END as ComplianceStatus
FROM Customers c
LEFT JOIN KYC k ON c.CustomerID = k.CustomerID
WHERE k.Status = 'Pending' OR k.ExpiryDate < GETDATE()
ORDER BY ComplianceStatus;

-- 10. AML CASES BY SEVERITY
SELECT 
    aml.CaseID,
    c.CustomerID,
    c.FullName,
    aml.CaseType,
    aml.Status,
    aml.CreatedAt,
    aml.ClosedAt,
    DATEDIFF(DAY, aml.CreatedAt, ISNULL(aml.ClosedAt, GETDATE())) as DaysOpen
FROM AMLCases aml
INNER JOIN Customers c ON aml.CustomerID = c.CustomerID
ORDER BY aml.CreatedAt DESC;

-- =====================================================
-- OPERATIONAL EFFICIENCY ANALYSIS
-- =====================================================

-- 11. BRANCH PERFORMANCE METRICS
SELECT 
    b.BranchID,
    b.BranchName,
    b.City,
    COUNT(DISTINCT e.EmployeeID) as EmployeeCount,
    COUNT(DISTINCT a.AccountID) as AccountCount,
    COUNT(DISTINCT l.LoanID) as LoanCount,
    SUM(l.Amount) as TotalLoanAmount,
    AVG(e.Salary) as AverageEmployeeSalary
FROM Branches b
LEFT JOIN Employees e ON b.BranchID = e.BranchID
LEFT JOIN Accounts a ON b.BranchID = a.BranchID
LEFT JOIN Loans l ON b.BranchID = l.BranchID
GROUP BY b.BranchID, b.BranchName, b.City
ORDER BY TotalLoanAmount DESC;

-- 12. EMPLOYEE PRODUCTIVITY ANALYSIS
SELECT 
    e.EmployeeID,
    e.FullName,
    e.Position,
    e.Department,
    e.Salary,
    COUNT(DISTINCT l.LoanID) as LoansProcessed,
    COUNT(DISTINCT k.KYCID) as KYCVerifications,
    AVG(ea.TotalHours) as AverageHoursWorked
FROM Employees e
LEFT JOIN Loans l ON e.EmployeeID = l.ApprovedBy
LEFT JOIN KYC k ON e.EmployeeID = k.VerifiedBy
LEFT JOIN EmployeeAttendance ea ON e.EmployeeID = ea.EmployeeID
GROUP BY e.EmployeeID, e.FullName, e.Position, e.Department, e.Salary
ORDER BY LoansProcessed DESC;

-- =====================================================
-- CUSTOMER EXPERIENCE ANALYSIS
-- =====================================================

-- 13. CUSTOMER ENGAGEMENT METRICS
SELECT 
    c.CustomerID,
    c.FullName,
    c.AnnualIncome,
    COUNT(DISTINCT a.AccountID) as AccountCount,
    COUNT(DISTINCT cc.CardID) as CreditCardCount,
    COUNT(DISTINCT l.LoanID) as LoanCount,
    COUNT(DISTINCT obu.UserID) as OnlineBankingUser,
    COUNT(DISTINCT t.TransactionID) as TransactionCount,
    SUM(t.Amount) as TotalTransactionVolume
FROM Customers c
LEFT JOIN Accounts a ON c.CustomerID = a.CustomerID
LEFT JOIN CreditCards cc ON c.CustomerID = cc.CustomerID
LEFT JOIN Loans l ON c.CustomerID = l.CustomerID
LEFT JOIN OnlineBankingUsers obu ON c.CustomerID = obu.CustomerID
LEFT JOIN Transactions t ON a.AccountID = t.AccountID
GROUP BY c.CustomerID, c.FullName, c.AnnualIncome
ORDER BY TotalTransactionVolume DESC;

-- 14. DIGITAL BANKING ADOPTION
SELECT 
    COUNT(DISTINCT obu.CustomerID) as OnlineBankingUsers,
    COUNT(DISTINCT mbt.CustomerID) as MobileBankingUsers,
    COUNT(DISTINCT c.CustomerID) as TotalCustomers,
    CAST(COUNT(DISTINCT obu.CustomerID) * 100.0 / COUNT(DISTINCT c.CustomerID) AS DECIMAL(5,2)) as OnlineAdoptionRate,
    CAST(COUNT(DISTINCT mbt.CustomerID) * 100.0 / COUNT(DISTINCT c.CustomerID) AS DECIMAL(5,2)) as MobileAdoptionRate
FROM Customers c
LEFT JOIN OnlineBankingUsers obu ON c.CustomerID = obu.CustomerID
LEFT JOIN MobileBankingTransactions mbt ON c.CustomerID = mbt.CustomerID;

-- =====================================================
-- RISK MANAGEMENT ANALYSIS
-- =====================================================

-- 15. CREDIT RISK ASSESSMENT
SELECT 
    c.CustomerID,
    c.FullName,
    c.AnnualIncome,
    cs.CreditScore,
    COUNT(l.LoanID) as ActiveLoans,
    SUM(l.Amount) as TotalLoanAmount,
    SUM(cc.CreditLimit) as TotalCreditLimit,
    SUM(cc.CurrentBalance) as TotalCreditUsed,
    CASE 
        WHEN cs.CreditScore < 500 THEN 'Very High Risk'
        WHEN cs.CreditScore < 600 THEN 'High Risk'
        WHEN cs.CreditScore < 700 THEN 'Medium Risk'
        WHEN cs.CreditScore < 800 THEN 'Low Risk'
        ELSE 'Very Low Risk'
    END as RiskCategory
FROM Customers c
LEFT JOIN CreditScores cs ON c.CustomerID = cs.CustomerID
LEFT JOIN Loans l ON c.CustomerID = l.CustomerID AND l.Status = 'Active'
LEFT JOIN CreditCards cc ON c.CustomerID = cc.CustomerID AND cc.Status = 'Active'
GROUP BY c.CustomerID, c.FullName, c.AnnualIncome, cs.CreditScore
ORDER BY cs.CreditScore ASC;

-- 16. DEBT COLLECTION ANALYSIS
SELECT 
    dc.DebtID,
    c.CustomerID,
    c.FullName,
    dc.AmountDue,
    dc.DueDate,
    dc.Status,
    DATEDIFF(DAY, dc.DueDate, GETDATE()) as DaysOverdue,
    e.FullName as CollectorName
FROM DebtCollection dc
INNER JOIN Customers c ON dc.CustomerID = c.CustomerID
LEFT JOIN Employees e ON dc.CollectorAssigned = e.EmployeeID
WHERE dc.Status = 'Active'
ORDER BY DaysOverdue DESC;

-- =====================================================
-- FINANCIAL PERFORMANCE ANALYSIS
-- =====================================================

-- 17. REVENUE ANALYSIS BY PRODUCT TYPE
SELECT 
    'Loans' as ProductType,
    COUNT(l.LoanID) as ProductCount,
    SUM(l.Amount) as TotalAmount,
    AVG(l.InterestRate) as AverageInterestRate
FROM Loans l
WHERE l.Status = 'Active'
UNION ALL
SELECT 
    'Credit Cards' as ProductType,
    COUNT(cc.CardID) as ProductCount,
    SUM(cc.CreditLimit) as TotalAmount,
    NULL as AverageInterestRate
FROM CreditCards cc
WHERE cc.Status = 'Active'
UNION ALL
SELECT 
    'Investments' as ProductType,
    COUNT(i.InvestmentID) as ProductCount,
    SUM(i.Amount) as TotalAmount,
    AVG(i.ROI) as AverageInterestRate
FROM Investments i
WHERE i.Status = 'Active';

-- 18. TRANSACTION VOLUME BY TYPE AND TIME
SELECT 
    DATEPART(HOUR, t.TransactionDate) as HourOfDay,
    t.TransactionType,
    COUNT(*) as TransactionCount,
    SUM(t.Amount) as TotalAmount,
    AVG(t.Amount) as AverageAmount
FROM Transactions t
GROUP BY DATEPART(HOUR, t.TransactionDate), t.TransactionType
ORDER BY HourOfDay, TransactionCount DESC;

-- =====================================================
-- REAL-TIME FRAUD DETECTION QUERIES
-- =====================================================

-- 19. REAL-TIME SUSPICIOUS ACTIVITY DETECTION
-- (Run this query frequently to detect fraud patterns)
SELECT 
    t.AccountID,
    a.CustomerID,
    c.FullName,
    t.TransactionID,
    t.Amount,
    t.TransactionType,
    t.TransactionDate,
    t.Location,
    t.IPAddress,
    'High Amount Transaction' as AlertType
FROM Transactions t
INNER JOIN Accounts a ON t.AccountID = a.AccountID
INNER JOIN Customers c ON a.CustomerID = c.CustomerID
WHERE t.Amount > 50000
AND t.TransactionDate > DATEADD(HOUR, -1, GETDATE())
ORDER BY t.TransactionDate DESC;

-- 20. CREDIT CARD FRAUD PATTERNS
SELECT 
    cc.CardID,
    c.CustomerID,
    c.FullName,
    cc.CardType,
    cct.Merchant,
    cct.Amount,
    cct.TransactionDate,
    cct.Location,
    'Unusual Merchant' as AlertType
FROM CreditCardTransactions cct
INNER JOIN CreditCards cc ON cct.CardID = cc.CardID
INNER JOIN Customers c ON cc.CustomerID = c.CustomerID
WHERE cct.Amount > 1000
AND cct.TransactionDate > DATEADD(HOUR, -2, GETDATE())
AND cct.MerchantCategory IN ('Entertainment', 'Travel')
ORDER BY cct.TransactionDate DESC;

-- =====================================================
-- EXECUTIVE DASHBOARD SUMMARY
-- =====================================================

-- 21. EXECUTIVE SUMMARY METRICS
SELECT 
    'Total Customers' as Metric,
    COUNT(*) as Value
FROM Customers
UNION ALL
SELECT 
    'Total Assets Under Management',
    SUM(Balance)
FROM Accounts
WHERE Status = 'Active'
UNION ALL
SELECT 
    'Total Loans Outstanding',
    SUM(Amount)
FROM Loans
WHERE Status = 'Active'
UNION ALL
SELECT 
    'Total Credit Card Balances',
    SUM(CurrentBalance)
FROM CreditCards
WHERE Status = 'Active'
UNION ALL
SELECT 
    'Active Fraud Cases',
    COUNT(*)
FROM FraudDetection
WHERE Status = 'Under Investigation'
UNION ALL
SELECT 
    'Online Banking Adoption Rate (%)',
    CAST(COUNT(DISTINCT obu.CustomerID) * 100.0 / COUNT(DISTINCT c.CustomerID) AS DECIMAL(5,2))
FROM Customers c
LEFT JOIN OnlineBankingUsers obu ON c.CustomerID = obu.CustomerID;
