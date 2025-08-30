import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import numpy as np
from datetime import datetime, timedelta
import pyodbc
import warnings
warnings.filterwarnings('ignore')

# Page configuration
st.set_page_config(
    page_title="Banking System BI Dashboard",
    page_icon="🏦",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        font-size: 3rem;
        color: #1f77b4;
        text-align: center;
        margin-bottom: 2rem;
    }
    .metric-card {
        background-color: #f0f2f6;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #1f77b4;
    }
    .alert-card {
        background-color: #fff3cd;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #ffc107;
    }
    .fraud-card {
        background-color: #f8d7da;
        padding: 1rem;
        border-radius: 0.5rem;
        border-left: 4px solid #dc3545;
    }
</style>
""", unsafe_allow_html=True)

# Database connection function (simulated for demo)
@st.cache_data
def load_sample_data():
    """Load sample data for demonstration purposes"""
    
    # Generate sample data for demonstration
    np.random.seed(42)
    
    # Sample customers data
    customers_data = {
        'CustomerID': range(1, 1001),
        'FullName': [f'Customer {i}' for i in range(1, 1001)],
        'AnnualIncome': np.random.normal(75000, 25000, 1000),
        'City': np.random.choice(['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'], 1000),
        'EmploymentStatus': np.random.choice(['Full-Time', 'Part-Time', 'Self-Employed', 'Unemployed'], 1000, p=[0.6, 0.2, 0.15, 0.05])
    }
    
    # Sample accounts data
    accounts_data = {
        'AccountID': range(1, 2001),
        'CustomerID': np.random.choice(range(1, 1001), 2000),
        'AccountType': np.random.choice(['Savings', 'Checking', 'Business', 'Investment'], 2000, p=[0.4, 0.3, 0.2, 0.1]),
        'Balance': np.random.exponential(10000, 2000),
        'Status': np.random.choice(['Active', 'Inactive'], 2000, p=[0.95, 0.05])
    }
    
    # Sample transactions data
    transactions_data = {
        'TransactionID': range(1, 5001),
        'AccountID': np.random.choice(range(1, 2001), 5000),
        'TransactionType': np.random.choice(['Deposit', 'Withdrawal', 'Transfer', 'Payment'], 5000),
        'Amount': np.random.exponential(500, 5000),
        'TransactionDate': pd.date_range(start='2023-01-01', periods=5000, freq='H'),
        'Status': np.random.choice(['Completed', 'Pending', 'Failed'], 5000, p=[0.95, 0.03, 0.02])
    }
    
    # Sample loans data
    loans_data = {
        'LoanID': range(1, 301),
        'CustomerID': np.random.choice(range(1, 1001), 300),
        'LoanType': np.random.choice(['Mortgage', 'Personal', 'Auto', 'Business'], 300),
        'Amount': np.random.exponential(100000, 300),
        'InterestRate': np.random.normal(5.5, 2, 300),
        'Status': np.random.choice(['Active', 'Paid', 'Default'], 300, p=[0.7, 0.25, 0.05])
    }
    
    # Sample fraud detection data
    fraud_data = {
        'FraudID': range(1, 51),
        'CustomerID': np.random.choice(range(1, 1001), 50),
        'RiskLevel': np.random.choice(['High', 'Medium', 'Low'], 50, p=[0.2, 0.3, 0.5]),
        'Status': np.random.choice(['Under Investigation', 'Resolved', 'False Positive'], 50),
        'ReportedDate': pd.date_range(start='2023-01-01', periods=50, freq='D')
    }
    
    return {
        'customers': pd.DataFrame(customers_data),
        'accounts': pd.DataFrame(accounts_data),
        'transactions': pd.DataFrame(transactions_data),
        'loans': pd.DataFrame(loans_data),
        'fraud': pd.DataFrame(fraud_data)
    }

# Load data
data = load_sample_data()

# Main dashboard
def main():
    st.markdown('<h1 class="main-header">🏦 Banking System BI Dashboard</h1>', unsafe_allow_html=True)
    
    # Sidebar navigation
    st.sidebar.title("Navigation")
    page = st.sidebar.selectbox(
        "Choose a page:",
        ["Executive Summary", "Fraud Detection", "Customer Analytics", "Operational Metrics", "Risk Management", "Compliance"]
    )
    
    if page == "Executive Summary":
        show_executive_summary()
    elif page == "Fraud Detection":
        show_fraud_detection()
    elif page == "Customer Analytics":
        show_customer_analytics()
    elif page == "Operational Metrics":
        show_operational_metrics()
    elif page == "Risk Management":
        show_risk_management()
    elif page == "Compliance":
        show_compliance()

def show_executive_summary():
    st.header("📊 Executive Summary")
    
    # Key metrics
    col1, col2, col3, col4 = st.columns(4)
    
    with col1:
        total_customers = len(data['customers'])
        st.metric("Total Customers", f"{total_customers:,}")
    
    with col2:
        total_assets = data['accounts'][data['accounts']['Status'] == 'Active']['Balance'].sum()
        st.metric("Total Assets", f"${total_assets:,.0f}")
    
    with col3:
        total_loans = data['loans'][data['loans']['Status'] == 'Active']['Amount'].sum()
        st.metric("Total Loans", f"${total_loans:,.0f}")
    
    with col4:
        active_fraud_cases = len(data['fraud'][data['fraud']['Status'] == 'Under Investigation'])
        st.metric("Active Fraud Cases", active_fraud_cases)
    
    # Charts
    col1, col2 = st.columns(2)
    
    with col1:
        # Account distribution by type
        account_dist = data['accounts']['AccountType'].value_counts()
        fig = px.pie(values=account_dist.values, names=account_dist.index, title="Account Distribution by Type")
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Transaction volume over time
        daily_transactions = data['transactions'].groupby(data['transactions']['TransactionDate'].dt.date).size()
        fig = px.line(x=daily_transactions.index, y=daily_transactions.values, 
                     title="Daily Transaction Volume", labels={'x': 'Date', 'y': 'Transactions'})
        st.plotly_chart(fig, use_container_width=True)
    
    # Top customers by balance
    st.subheader("🏆 Top 3 Customers by Total Balance")
    customer_balances = data['accounts'].groupby('CustomerID')['Balance'].sum().sort_values(ascending=False).head(3)
    top_customers = data['customers'][data['customers']['CustomerID'].isin(customer_balances.index)]
    
    for i, (customer_id, balance) in enumerate(customer_balances.items()):
        customer = top_customers[top_customers['CustomerID'] == customer_id].iloc[0]
        st.markdown(f"""
        <div class="metric-card">
            <h4>#{i+1}: {customer['FullName']}</h4>
            <p>Customer ID: {customer_id}</p>
            <p>Total Balance: ${balance:,.2f}</p>
            <p>Annual Income: ${customer['AnnualIncome']:,.2f}</p>
        </div>
        """, unsafe_allow_html=True)

def show_fraud_detection():
    st.header("🚨 Fraud Detection & Security")
    
    # Fraud alerts
    st.subheader("🔴 Active Fraud Alerts")
    
    # Simulate real-time fraud detection
    high_risk_transactions = data['transactions'][data['transactions']['Amount'] > 10000]
    suspicious_patterns = high_risk_transactions.sample(min(5, len(high_risk_transactions)))
    
    for _, transaction in suspicious_patterns.iterrows():
        st.markdown(f"""
        <div class="fraud-card">
            <h4>🚨 High Amount Transaction Alert</h4>
            <p>Transaction ID: {transaction['TransactionID']}</p>
            <p>Amount: ${transaction['Amount']:,.2f}</p>
            <p>Type: {transaction['TransactionType']}</p>
            <p>Date: {transaction['TransactionDate']}</p>
        </div>
        """, unsafe_allow_html=True)
    
    # Fraud statistics
    col1, col2 = st.columns(2)
    
    with col1:
        fraud_by_risk = data['fraud']['RiskLevel'].value_counts()
        fig = px.bar(x=fraud_by_risk.index, y=fraud_by_risk.values, 
                    title="Fraud Cases by Risk Level", color=fraud_by_risk.index)
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        fraud_by_status = data['fraud']['Status'].value_counts()
        fig = px.pie(values=fraud_by_status.values, names=fraud_by_status.index, 
                    title="Fraud Cases by Status")
        st.plotly_chart(fig, use_container_width=True)
    
    # Suspicious patterns
    st.subheader("🔍 Suspicious Transaction Patterns")
    
    # Large transactions within short time
    st.markdown("**Customers with Multiple Large Transactions (>$10,000) within 1 Hour:**")
    large_transactions = data['transactions'][data['transactions']['Amount'] > 10000]
    if len(large_transactions) > 0:
        st.dataframe(large_transactions.head(10))
    else:
        st.info("No suspicious patterns detected in the current data.")
    
    # Geographic anomalies
    st.markdown("**Geographic Transaction Anomalies:**")
    st.info("Monitoring for transactions from different countries within short timeframes...")

def show_customer_analytics():
    st.header("👥 Customer Analytics")
    
    # Customer segmentation
    st.subheader("📈 Customer Segmentation")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Income distribution
        fig = px.histogram(data['customers'], x='AnnualIncome', nbins=20, 
                          title="Customer Income Distribution")
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Employment status
        emp_status = data['customers']['EmploymentStatus'].value_counts()
        fig = px.pie(values=emp_status.values, names=emp_status.index, 
                    title="Employment Status Distribution")
        st.plotly_chart(fig, use_container_width=True)
    
    # Customer engagement
    st.subheader("💳 Customer Engagement Metrics")
    
    # Multiple loans analysis
    customer_loans = data['loans'].groupby('CustomerID').size()
    customers_with_multiple_loans = customer_loans[customer_loans > 1]
    
    if len(customers_with_multiple_loans) > 0:
        st.markdown("**Customers with Multiple Active Loans:**")
        st.metric("Count", len(customers_with_multiple_loans))
        
        # Show details
        multiple_loan_customers = data['customers'][data['customers']['CustomerID'].isin(customers_with_multiple_loans.index)]
        st.dataframe(multiple_loan_customers.head(10))
    else:
        st.info("No customers with multiple loans found.")
    
    # Geographic distribution
    st.subheader("🌍 Geographic Distribution")
    city_dist = data['customers']['City'].value_counts()
    fig = px.bar(x=city_dist.index, y=city_dist.values, 
                title="Customers by City", color=city_dist.values)
    st.plotly_chart(fig, use_container_width=True)

def show_operational_metrics():
    st.header("⚙️ Operational Metrics")
    
    # Branch performance (simulated)
    st.subheader("🏢 Branch Performance")
    
    # Simulate branch data
    branches = ['New York Main', 'Los Angeles Downtown', 'Chicago Central', 'Houston West', 'Phoenix North']
    branch_metrics = pd.DataFrame({
        'Branch': branches,
        'TotalLoans': np.random.randint(50, 200, len(branches)),
        'TotalLoanAmount': np.random.randint(5000000, 20000000, len(branches)),
        'EmployeeCount': np.random.randint(20, 50, len(branches))
    })
    
    col1, col2 = st.columns(2)
    
    with col1:
        fig = px.bar(branch_metrics, x='Branch', y='TotalLoanAmount', 
                    title="Total Loan Amount by Branch")
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        fig = px.scatter(branch_metrics, x='EmployeeCount', y='TotalLoans', 
                        size='TotalLoanAmount', hover_data=['Branch'],
                        title="Branch Efficiency: Loans vs Employees")
        st.plotly_chart(fig, use_container_width=True)
    
    # Transaction analysis
    st.subheader("💸 Transaction Analysis")
    
    col1, col2 = st.columns(2)
    
    with col1:
        # Transaction types
        trans_types = data['transactions']['TransactionType'].value_counts()
        fig = px.pie(values=trans_types.values, names=trans_types.index, 
                    title="Transaction Types Distribution")
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        # Transaction amounts over time
        daily_amounts = data['transactions'].groupby(data['transactions']['TransactionDate'].dt.date)['Amount'].sum()
        fig = px.line(x=daily_amounts.index, y=daily_amounts.values, 
                     title="Daily Transaction Volume ($)", labels={'x': 'Date', 'y': 'Amount'})
        st.plotly_chart(fig, use_container_width=True)

def show_risk_management():
    st.header("⚠️ Risk Management")
    
    # Credit risk assessment
    st.subheader("💳 Credit Risk Assessment")
    
    # Simulate credit scores
    credit_scores = np.random.normal(650, 100, len(data['customers']))
    credit_scores = np.clip(credit_scores, 300, 850)
    
    risk_categories = []
    for score in credit_scores:
        if score < 500:
            risk_categories.append('Very High Risk')
        elif score < 600:
            risk_categories.append('High Risk')
        elif score < 700:
            risk_categories.append('Medium Risk')
        elif score < 800:
            risk_categories.append('Low Risk')
        else:
            risk_categories.append('Very Low Risk')
    
    risk_df = pd.DataFrame({
        'CreditScore': credit_scores,
        'RiskCategory': risk_categories
    })
    
    col1, col2 = st.columns(2)
    
    with col1:
        fig = px.histogram(risk_df, x='CreditScore', nbins=20, 
                          title="Credit Score Distribution")
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        risk_dist = risk_df['RiskCategory'].value_counts()
        fig = px.pie(values=risk_dist.values, names=risk_dist.index, 
                    title="Risk Category Distribution")
        st.plotly_chart(fig, use_container_width=True)
    
    # Loan performance
    st.subheader("📊 Loan Performance Analysis")
    
    loan_performance = data['loans']['Status'].value_counts()
    fig = px.bar(x=loan_performance.index, y=loan_performance.values, 
                title="Loan Status Distribution", color=loan_performance.values)
    st.plotly_chart(fig, use_container_width=True)
    
    # High-risk customers
    st.subheader("🚨 High-Risk Customers")
    high_risk_customers = risk_df[risk_df['RiskCategory'].isin(['Very High Risk', 'High Risk'])]
    st.metric("High-Risk Customers", len(high_risk_customers))
    
    if len(high_risk_customers) > 0:
        st.dataframe(high_risk_customers.head(10))

def show_compliance():
    st.header("📋 Compliance & Regulatory")
    
    # KYC compliance
    st.subheader("🆔 KYC Compliance Status")
    
    # Simulate KYC data
    kyc_status = np.random.choice(['Verified', 'Pending', 'Expired'], len(data['customers']), p=[0.8, 0.15, 0.05])
    kyc_df = pd.DataFrame({
        'CustomerID': data['customers']['CustomerID'],
        'KYCStatus': kyc_status
    })
    
    col1, col2 = st.columns(2)
    
    with col1:
        kyc_dist = kyc_df['KYCStatus'].value_counts()
        fig = px.pie(values=kyc_dist.values, names=kyc_dist.index, 
                    title="KYC Status Distribution")
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        non_compliant = kyc_df[kyc_df['KYCStatus'].isin(['Pending', 'Expired'])]
        st.metric("Non-Compliant Customers", len(non_compliant))
        
        if len(non_compliant) > 0:
            st.markdown("**Non-Compliant Customers:**")
            st.dataframe(non_compliant.head(10))
    
    # AML monitoring
    st.subheader("🔍 AML Monitoring")
    
    # Simulate AML cases
    aml_cases = pd.DataFrame({
        'CaseID': range(1, 21),
        'CaseType': np.random.choice(['Suspicious Activity', 'Large Transaction', 'Unusual Pattern'], 20),
        'Status': np.random.choice(['Open', 'Under Investigation', 'Resolved'], 20),
        'Severity': np.random.choice(['High', 'Medium', 'Low'], 20)
    })
    
    col1, col2 = st.columns(2)
    
    with col1:
        aml_by_status = aml_cases['Status'].value_counts()
        fig = px.bar(x=aml_by_status.index, y=aml_by_status.values, 
                    title="AML Cases by Status", color=aml_by_status.values)
        st.plotly_chart(fig, use_container_width=True)
    
    with col2:
        aml_by_severity = aml_cases['Severity'].value_counts()
        fig = px.pie(values=aml_by_severity.values, names=aml_by_severity.index, 
                    title="AML Cases by Severity")
        st.plotly_chart(fig, use_container_width=True)
    
    # Regulatory reporting
    st.subheader("📊 Regulatory Reporting")
    
    # Simulate regulatory metrics
    reg_metrics = {
        'Metric': ['Total Assets', 'Total Deposits', 'Total Loans', 'Capital Ratio', 'Liquidity Ratio'],
        'Value': [total_assets := data['accounts']['Balance'].sum(), 
                 total_assets * 0.8, 
                 data['loans']['Amount'].sum(),
                 12.5,  # Capital ratio
                 105.2] # Liquidity ratio
    }
    
    reg_df = pd.DataFrame(reg_metrics)
    st.dataframe(reg_df, use_container_width=True)

if __name__ == "__main__":
    main()
