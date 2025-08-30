#!/usr/bin/env python3
"""
Banking System BI Dashboard Setup Script
This script helps users set up the complete banking system with database and dashboard.
"""

import os
import sys
import subprocess
import sqlite3
from pathlib import Path

def print_banner():
    """Print the project banner"""
    print("""
    ╔══════════════════════════════════════════════════════════════╗
    ║                    🏦 Banking System BI Dashboard            ║
    ║                                                              ║
    ║  A comprehensive banking system with Business Intelligence   ║
    ║  solutions to replace Excel-based systems                   ║
    ╚══════════════════════════════════════════════════════════════╝
    """)

def check_python_version():
    """Check if Python version is compatible"""
    if sys.version_info < (3, 8):
        print("❌ Error: Python 3.8 or higher is required")
        print(f"Current version: {sys.version}")
        sys.exit(1)
    print(f"✅ Python version: {sys.version.split()[0]}")

def install_dependencies():
    """Install required Python packages"""
    print("\n📦 Installing Python dependencies...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements.txt"])
        print("✅ Dependencies installed successfully")
    except subprocess.CalledProcessError:
        print("❌ Error installing dependencies")
        print("Please run: pip install -r requirements.txt")
        sys.exit(1)

def create_sqlite_database():
    """Create SQLite database for demo purposes"""
    print("\n🗄️ Creating SQLite database for demo...")
    
    # Read SQL schema
    try:
        with open('database_schema.sql', 'r') as f:
            schema_sql = f.read()
    except FileNotFoundError:
        print("❌ database_schema.sql not found")
        return False
    
    # Convert SQL Server syntax to SQLite
    schema_sql = schema_sql.replace('IDENTITY(1,1)', 'AUTOINCREMENT')
    schema_sql = schema_sql.replace('NVARCHAR', 'TEXT')
    schema_sql = schema_sql.replace('DECIMAL', 'REAL')
    schema_sql = schema_sql.replace('DATETIME2', 'DATETIME')
    schema_sql = schema_sql.replace('BIT', 'INTEGER')
    schema_sql = schema_sql.replace('GETDATE()', 'CURRENT_TIMESTAMP')
    schema_sql = schema_sql.replace('DEFAULT GETDATE()', 'DEFAULT CURRENT_TIMESTAMP')
    
    # Remove SQL Server specific syntax
    lines = schema_sql.split('\n')
    filtered_lines = []
    for line in lines:
        if not any(keyword in line.upper() for keyword in ['IDENTITY', 'NVARCHAR', 'DECIMAL', 'DATETIME2', 'BIT']):
            filtered_lines.append(line)
    
    schema_sql = '\n'.join(filtered_lines)
    
    # Create database
    try:
        conn = sqlite3.connect('banking_system.db')
        cursor = conn.cursor()
        
        # Execute schema
        cursor.executescript(schema_sql)
        conn.commit()
        conn.close()
        print("✅ SQLite database created successfully")
        return True
    except Exception as e:
        print(f"❌ Error creating database: {e}")
        return False

def generate_sample_data():
    """Generate sample data for the database"""
    print("\n📊 Generating sample data...")
    
    try:
        # Create a simple data generation script
        sample_data_script = """
import sqlite3
import random
from datetime import datetime, timedelta

def generate_sample_data():
    conn = sqlite3.connect('banking_system.db')
    cursor = conn.cursor()
    
    # Generate customers
    for i in range(1, 101):  # 100 customers for demo
        cursor.execute('''
            INSERT INTO Customers (FullName, DOB, Email, PhoneNumber, Address, City, State, Country, NationalID, TaxID, EmploymentStatus, AnnualIncome)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            f'Customer {i}',
            datetime.now() - timedelta(days=random.randint(6570, 25550)),  # 18-70 years old
            f'customer{i}@email.com',
            f'+1-555-{random.randint(100, 999)}-{random.randint(1000, 9999)}',
            f'{random.randint(100, 9999)} Main St',
            random.choice(['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix']),
            random.choice(['NY', 'CA', 'IL', 'TX', 'AZ']),
            'USA',
            f'NID{i:06d}',
            f'TAX{i:06d}',
            random.choice(['Full-Time', 'Part-Time', 'Self-Employed']),
            random.randint(30000, 150000)
        ))
    
    # Generate accounts
    for i in range(1, 201):  # 200 accounts
        cursor.execute('''
            INSERT INTO Accounts (CustomerID, AccountType, Balance, Currency, Status, BranchID)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            random.randint(1, 100),
            random.choice(['Savings', 'Checking', 'Business']),
            random.randint(1000, 100000),
            'USD',
            'Active',
            random.randint(1, 5)
        ))
    
    # Generate transactions
    for i in range(1, 1001):  # 1000 transactions
        cursor.execute('''
            INSERT INTO Transactions (AccountID, TransactionType, Amount, Currency, TransactionDate, Status, Description)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ''', (
            random.randint(1, 200),
            random.choice(['Deposit', 'Withdrawal', 'Transfer', 'Payment']),
            random.randint(100, 10000),
            'USD',
            datetime.now() - timedelta(hours=random.randint(1, 720)),
            'Completed',
            f'Transaction {i}'
        ))
    
    conn.commit()
    conn.close()
    print("Sample data generated successfully!")

if __name__ == "__main__":
    generate_sample_data()
"""
        
        with open('generate_sample_data.py', 'w') as f:
            f.write(sample_data_script)
        
        # Execute the script
        subprocess.check_call([sys.executable, 'generate_sample_data.py'])
        print("✅ Sample data generated successfully")
        
        # Clean up
        os.remove('generate_sample_data.py')
        return True
        
    except Exception as e:
        print(f"❌ Error generating sample data: {e}")
        return False

def test_dashboard():
    """Test if the dashboard can run"""
    print("\n🧪 Testing dashboard...")
    try:
        # Test import
        import streamlit
        import pandas
        import plotly
        print("✅ All required packages imported successfully")
        return True
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False

def print_next_steps():
    """Print next steps for the user"""
    print("""
    🎉 Setup completed successfully!
    
    📋 Next Steps:
    
    1. 🗄️ Database Setup (if using SQL Server):
       - Run database_schema.sql in your SQL Server
       - Execute data_generation.sql to populate data
       - Test with bi_queries.sql
    
    2. 🚀 Launch Dashboard:
       streamlit run bi_dashboard.py
    
    3. 🌐 Access Dashboard:
       Open http://localhost:8501 in your browser
    
    4. 📊 Explore Features:
       - Executive Summary
       - Fraud Detection
       - Customer Analytics
       - Operational Metrics
       - Risk Management
       - Compliance
    
    📚 Documentation:
    - README.md contains detailed information
    - bi_queries.sql has all KPI queries
    - Customize dashboard in bi_dashboard.py
    
    🔧 Customization:
    - Modify database_schema.sql for new tables
    - Add queries to bi_queries.sql
    - Update visualizations in bi_dashboard.py
    
    🆘 Support:
    - Check README.md for troubleshooting
    - Review error messages for specific issues
    """)

def main():
    """Main setup function"""
    print_banner()
    
    print("🔧 Starting setup process...")
    
    # Check Python version
    check_python_version()
    
    # Install dependencies
    install_dependencies()
    
    # Create SQLite database for demo
    if create_sqlite_database():
        generate_sample_data()
    
    # Test dashboard
    test_dashboard()
    
    # Print next steps
    print_next_steps()

if __name__ == "__main__":
    main()
