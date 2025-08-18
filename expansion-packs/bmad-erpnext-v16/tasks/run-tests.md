# Run Tests

## Overview
This task guides you through running comprehensive test suites for your ERPNext application, including unit tests, integration tests, performance tests, and automated testing workflows.

## Prerequisites

### Required Knowledge
- [ ] Understanding of different test types (unit, integration, performance)
- [ ] Knowledge of Python unittest framework
- [ ] Familiarity with Frappe testing utilities
- [ ] Basic understanding of CI/CD concepts

### Testing Environment
- [ ] Test database is configured and isolated
- [ ] All app dependencies are installed
- [ ] Test data fixtures are available
- [ ] Development mode is enabled
- [ ] Testing frameworks are installed (pytest, coverage)

## Step-by-Step Process

### Step 1: Prepare Test Environment

#### Set Up Test Database
```bash
# Create separate test site
bench new-site test.localhost --force --db-root-password frappe

# Install apps on test site
bench --site test.localhost install-app erpnext
bench --site test.localhost install-app your_app

# Enable developer mode for testing
bench --site test.localhost set-config developer_mode 1

# Set test database configuration
bench --site test.localhost set-config allow_tests true
```

#### Configure Test Settings
```python
# Create test configuration
# File: sites/test.localhost/site_config.json
{
    "db_name": "test_yourapp",
    "db_password": "test_password",
    "allow_tests": true,
    "developer_mode": 1,
    "disable_website_cache": true,
    "logging": 2
}
```

#### Install Test Dependencies
```bash
# Install Python testing dependencies
pip install pytest pytest-cov pytest-xdist coverage

# For native Vue components, testing tools are included with Frappe
# No separate frontend testing setup needed
# Vue components are tested through Frappe's testing framework
```

### Step 2: Run Unit Tests

#### Execute Basic Unit Tests
```bash
# Run all unit tests for your app
bench --site test.localhost run-tests --app your_app

# Run specific test module
bench --site test.localhost run-tests --module your_app.tests.test_customer

# Run tests with verbose output
bench --site test.localhost run-tests --app your_app --verbose

# Run tests in parallel for faster execution
bench --site test.localhost run-tests --app your_app --parallel
```

#### Run Specific Test Classes
```bash
# Run specific test class
bench --site test.localhost run-tests --module your_app.tests.test_customer.TestCustomer

# Run specific test method
bench --site test.localhost run-tests --module your_app.tests.test_customer.TestCustomer.test_customer_creation

# Run tests matching pattern
bench --site test.localhost run-tests --app your_app --profile --grep "customer"
```

#### Monitor Test Results
```python
# Create test monitoring script
# File: run_monitored_tests.py

import subprocess
import time
import json
from datetime import datetime

def run_monitored_tests(app_name):
    """Run tests with monitoring and reporting"""
    
    start_time = time.time()
    print(f"Starting test run for {app_name} at {datetime.now()}")
    
    # Run tests and capture output
    cmd = [
        "bench", "--site", "test.localhost", "run-tests",
        "--app", app_name,
        "--verbose",
        "--coverage"
    ]
    
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=1800  # 30 minute timeout
        )
        
        end_time = time.time()
        duration = end_time - start_time
        
        # Parse test results
        test_results = parse_test_output(result.stdout)
        
        # Generate report
        report = {
            "app": app_name,
            "start_time": datetime.fromtimestamp(start_time).isoformat(),
            "duration": duration,
            "return_code": result.returncode,
            "tests_run": test_results.get("tests_run", 0),
            "tests_passed": test_results.get("tests_passed", 0),
            "tests_failed": test_results.get("tests_failed", 0),
            "coverage": test_results.get("coverage", 0),
            "stdout": result.stdout,
            "stderr": result.stderr
        }
        
        # Save report
        report_filename = f"test_report_{app_name}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_filename, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"Test run completed in {duration:.2f} seconds")
        print(f"Report saved to: {report_filename}")
        
        return report
        
    except subprocess.TimeoutExpired:
        print("Test run timed out after 30 minutes")
        return None
    except Exception as e:
        print(f"Error running tests: {e}")
        return None

def parse_test_output(output):
    """Parse test output to extract key metrics"""
    
    metrics = {
        "tests_run": 0,
        "tests_passed": 0,
        "tests_failed": 0,
        "coverage": 0
    }
    
    lines = output.split('\n')
    
    for line in lines:
        if "tests run" in line.lower():
            # Extract test counts from output
            import re
            match = re.search(r'(\d+) tests run', line.lower())
            if match:
                metrics["tests_run"] = int(match.group(1))
        
        if "failed" in line.lower() and "passed" in line.lower():
            # Extract pass/fail counts
            pass_match = re.search(r'(\d+) passed', line.lower())
            fail_match = re.search(r'(\d+) failed', line.lower())
            
            if pass_match:
                metrics["tests_passed"] = int(pass_match.group(1))
            if fail_match:
                metrics["tests_failed"] = int(fail_match.group(1))
        
        if "coverage" in line.lower() and "%" in line:
            # Extract coverage percentage
            coverage_match = re.search(r'(\d+)%', line)
            if coverage_match:
                metrics["coverage"] = int(coverage_match.group(1))
    
    return metrics

# Run the monitored test
if __name__ == "__main__":
    report = run_monitored_tests("your_app")
    if report and report["return_code"] == 0:
        print("✅ All tests passed!")
    else:
        print("❌ Some tests failed or encountered errors")
```

### Step 3: Run Integration Tests

#### Execute Integration Test Suite
```bash
# Run integration tests specifically
bench --site test.localhost run-tests --module your_app.tests.integration

# Run with database transactions for isolation
bench --site test.localhost run-tests --app your_app --profile
```

#### Create Integration Test Monitoring
```python
# File: integration_test_runner.py

import frappe
from frappe.tests.utils import FrappeTestCase

class IntegrationTestRunner:
    """Run and monitor integration tests"""
    
    def __init__(self, site_name="test.localhost"):
        self.site_name = site_name
        self.results = []
    
    def run_workflow_tests(self):
        """Run workflow integration tests"""
        
        print("Running workflow integration tests...")
        
        test_cases = [
            "test_sales_order_workflow",
            "test_purchase_order_workflow", 
            "test_customer_approval_workflow"
        ]
        
        for test_case in test_cases:
            try:
                result = self.run_single_test(
                    f"your_app.tests.integration.test_workflows.{test_case}"
                )
                self.results.append({
                    "test": test_case,
                    "status": "passed" if result else "failed"
                })
                print(f"✅ {test_case}: PASSED")
                
            except Exception as e:
                self.results.append({
                    "test": test_case,
                    "status": "error",
                    "error": str(e)
                })
                print(f"❌ {test_case}: FAILED - {str(e)}")
    
    def run_api_tests(self):
        """Run API integration tests"""
        
        print("Running API integration tests...")
        
        api_endpoints = [
            "test_customer_api_create",
            "test_customer_api_update",
            "test_customer_api_delete",
            "test_order_api_workflow"
        ]
        
        for endpoint_test in api_endpoints:
            try:
                result = self.run_single_test(
                    f"your_app.tests.integration.test_api.{endpoint_test}"
                )
                self.results.append({
                    "test": endpoint_test,
                    "status": "passed" if result else "failed"
                })
                print(f"✅ {endpoint_test}: PASSED")
                
            except Exception as e:
                self.results.append({
                    "test": endpoint_test,
                    "status": "error",
                    "error": str(e)
                })
                print(f"❌ {endpoint_test}: FAILED - {str(e)}")
    
    def run_single_test(self, test_path):
        """Run a single test and return result"""
        
        import subprocess
        
        cmd = [
            "bench", "--site", self.site_name, "run-tests",
            "--module", test_path
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0
    
    def generate_report(self):
        """Generate integration test report"""
        
        total_tests = len(self.results)
        passed_tests = len([r for r in self.results if r["status"] == "passed"])
        failed_tests = len([r for r in self.results if r["status"] == "failed"])
        error_tests = len([r for r in self.results if r["status"] == "error"])
        
        print(f"\n{'='*50}")
        print("INTEGRATION TEST REPORT")
        print(f"{'='*50}")
        print(f"Total Tests: {total_tests}")
        print(f"Passed: {passed_tests}")
        print(f"Failed: {failed_tests}")
        print(f"Errors: {error_tests}")
        print(f"Success Rate: {(passed_tests/total_tests*100):.1f}%")
        
        if failed_tests > 0 or error_tests > 0:
            print("\nFailed/Error Tests:")
            for result in self.results:
                if result["status"] in ["failed", "error"]:
                    print(f"  ❌ {result['test']}: {result.get('error', 'Failed')}")

# Run integration tests
if __name__ == "__main__":
    runner = IntegrationTestRunner()
    runner.run_workflow_tests()
    runner.run_api_tests()
    runner.generate_report()
```

### Step 4: Run Performance Tests

#### Execute Performance Test Suite
```python
# File: performance_test_runner.py

import time
import statistics
import frappe
from concurrent.futures import ThreadPoolExecutor
import matplotlib.pyplot as plt
import json

class PerformanceTestRunner:
    """Run performance tests and generate reports"""
    
    def __init__(self):
        self.results = {}
        
    def test_database_performance(self):
        """Test database query performance"""
        
        print("Running database performance tests...")
        
        test_queries = [
            {
                "name": "customer_list",
                "query": "SELECT name, customer_name FROM `tabCustomer` LIMIT 100",
                "description": "Basic customer list query"
            },
            {
                "name": "customer_with_orders",
                "query": """
                    SELECT c.name, c.customer_name, COUNT(so.name) as order_count
                    FROM `tabCustomer` c
                    LEFT JOIN `tabSales Order` so ON c.name = so.customer
                    GROUP BY c.name
                    LIMIT 100
                """,
                "description": "Customer with order count"
            },
            {
                "name": "complex_reporting_query",
                "query": """
                    SELECT 
                        c.territory,
                        COUNT(c.name) as customer_count,
                        COALESCE(SUM(so.grand_total), 0) as total_sales
                    FROM `tabCustomer` c
                    LEFT JOIN `tabSales Order` so ON c.name = so.customer
                    WHERE c.disabled = 0
                    GROUP BY c.territory
                    ORDER BY total_sales DESC
                """,
                "description": "Territory-wise sales report"
            }
        ]
        
        db_results = {}
        
        for test_query in test_queries:
            print(f"Testing: {test_query['description']}")
            
            # Run query multiple times to get average
            execution_times = []
            
            for i in range(10):
                start_time = time.time()
                
                try:
                    frappe.db.sql(test_query["query"])
                    execution_time = time.time() - start_time
                    execution_times.append(execution_time)
                except Exception as e:
                    print(f"Query failed: {e}")
                    execution_times.append(None)
            
            # Filter out failed queries
            valid_times = [t for t in execution_times if t is not None]
            
            if valid_times:
                db_results[test_query["name"]] = {
                    "description": test_query["description"],
                    "avg_time": statistics.mean(valid_times),
                    "min_time": min(valid_times),
                    "max_time": max(valid_times),
                    "successful_runs": len(valid_times),
                    "total_runs": len(execution_times)
                }
                
                print(f"  Average: {db_results[test_query['name']]['avg_time']:.3f}s")
            else:
                print(f"  All queries failed!")
        
        self.results["database"] = db_results
    
    def test_api_performance(self):
        """Test API endpoint performance"""
        
        print("Running API performance tests...")
        
        api_endpoints = [
            {
                "method": "your_app.api.get_customer_list",
                "args": {"limit": 20},
                "description": "Customer list API"
            },
            {
                "method": "your_app.api.create_customer",
                "args": {
                    "customer_name": "Performance Test Customer",
                    "email_id": "perftest@example.com"
                },
                "description": "Customer creation API"
            }
        ]
        
        api_results = {}
        
        for endpoint in api_endpoints:
            print(f"Testing: {endpoint['description']}")
            
            execution_times = []
            
            for i in range(5):  # Fewer runs for API tests
                start_time = time.time()
                
                try:
                    # Modify args to avoid duplicates
                    args = endpoint["args"].copy()
                    if "email_id" in args:
                        args["email_id"] = f"perftest{i}@example.com"
                    
                    frappe.call(endpoint["method"], **args)
                    execution_time = time.time() - start_time
                    execution_times.append(execution_time)
                    
                except Exception as e:
                    print(f"API call failed: {e}")
                    execution_times.append(None)
            
            valid_times = [t for t in execution_times if t is not None]
            
            if valid_times:
                api_results[endpoint["method"]] = {
                    "description": endpoint["description"],
                    "avg_time": statistics.mean(valid_times),
                    "min_time": min(valid_times),
                    "max_time": max(valid_times),
                    "successful_calls": len(valid_times),
                    "total_calls": len(execution_times)
                }
                
                print(f"  Average: {api_results[endpoint['method']]['avg_time']:.3f}s")
        
        self.results["api"] = api_results
    
    def test_concurrent_load(self):
        """Test concurrent user load"""
        
        print("Running concurrent load tests...")
        
        def simulate_user_session():
            """Simulate a user session with multiple operations"""
            
            session_start = time.time()
            operations = []
            
            try:
                # Operation 1: Get customer list
                op1_start = time.time()
                frappe.call("your_app.api.get_customer_list", limit=10)
                operations.append(time.time() - op1_start)
                
                # Operation 2: Get specific customer (if any exist)
                customers = frappe.get_all("Customer", limit=1)
                if customers:
                    op2_start = time.time()
                    frappe.call("your_app.api.get_customer", customer_id=customers[0].name)
                    operations.append(time.time() - op2_start)
                
                session_time = time.time() - session_start
                return {
                    "success": True,
                    "session_time": session_time,
                    "operations": operations
                }
                
            except Exception as e:
                return {
                    "success": False,
                    "error": str(e),
                    "session_time": time.time() - session_start
                }
        
        # Test with different concurrency levels
        concurrency_levels = [1, 5, 10, 20]
        load_results = {}
        
        for concurrent_users in concurrency_levels:
            print(f"Testing with {concurrent_users} concurrent users...")
            
            with ThreadPoolExecutor(max_workers=concurrent_users) as executor:
                futures = [
                    executor.submit(simulate_user_session)
                    for _ in range(concurrent_users * 2)  # Each user does 2 sessions
                ]
                
                results = [future.result() for future in futures]
            
            # Analyze results
            successful_sessions = [r for r in results if r["success"]]
            failed_sessions = [r for r in results if not r["success"]]
            
            if successful_sessions:
                session_times = [r["session_time"] for r in successful_sessions]
                load_results[f"{concurrent_users}_users"] = {
                    "concurrent_users": concurrent_users,
                    "total_sessions": len(results),
                    "successful_sessions": len(successful_sessions),
                    "failed_sessions": len(failed_sessions),
                    "avg_session_time": statistics.mean(session_times),
                    "max_session_time": max(session_times),
                    "min_session_time": min(session_times)
                }
                
                print(f"  Success rate: {len(successful_sessions)/len(results)*100:.1f}%")
                print(f"  Avg session time: {statistics.mean(session_times):.3f}s")
        
        self.results["load"] = load_results
    
    def generate_performance_report(self):
        """Generate comprehensive performance report"""
        
        print("\n" + "="*60)
        print("PERFORMANCE TEST REPORT")
        print("="*60)
        
        # Database Performance
        if "database" in self.results:
            print("\n📊 DATABASE PERFORMANCE:")
            for query_name, metrics in self.results["database"].items():
                print(f"  {metrics['description']}")
                print(f"    Average: {metrics['avg_time']:.3f}s")
                print(f"    Range: {metrics['min_time']:.3f}s - {metrics['max_time']:.3f}s")
                
                if metrics['avg_time'] > 1.0:
                    print(f"    ⚠️  Slow query (>1s)")
                elif metrics['avg_time'] > 0.5:
                    print(f"    ⚡ Moderate performance")
                else:
                    print(f"    ✅ Good performance")
        
        # API Performance
        if "api" in self.results:
            print("\n🌐 API PERFORMANCE:")
            for endpoint, metrics in self.results["api"].items():
                print(f"  {metrics['description']}")
                print(f"    Average: {metrics['avg_time']:.3f}s")
                
                if metrics['avg_time'] > 2.0:
                    print(f"    ⚠️  Slow API (>2s)")
                elif metrics['avg_time'] > 1.0:
                    print(f"    ⚡ Moderate performance")
                else:
                    print(f"    ✅ Good performance")
        
        # Load Test Results
        if "load" in self.results:
            print("\n🚀 LOAD TEST RESULTS:")
            for test_name, metrics in self.results["load"].items():
                print(f"  {metrics['concurrent_users']} concurrent users:")
                print(f"    Success rate: {metrics['successful_sessions']/metrics['total_sessions']*100:.1f}%")
                print(f"    Avg response: {metrics['avg_session_time']:.3f}s")
                
                if metrics['successful_sessions']/metrics['total_sessions'] < 0.95:
                    print(f"    ⚠️  Low success rate")
                else:
                    print(f"    ✅ Good reliability")
        
        # Save detailed results
        report_filename = f"performance_report_{time.strftime('%Y%m%d_%H%M%S')}.json"
        with open(report_filename, 'w') as f:
            json.dump(self.results, f, indent=2, default=str)
        
        print(f"\n📋 Detailed report saved to: {report_filename}")

# Run performance tests
if __name__ == "__main__":
    runner = PerformanceTestRunner()
    runner.test_database_performance()
    runner.test_api_performance()
    runner.test_concurrent_load()
    runner.generate_performance_report()
```

### Step 5: Run Coverage Analysis

#### Generate Code Coverage Report
```bash
# Run tests with coverage
bench --site test.localhost run-tests --app your_app --coverage

# Generate detailed HTML coverage report
coverage html --directory=coverage_html

# View coverage report
open coverage_html/index.html  # On macOS
# Or on Linux: xdg-open coverage_html/index.html
```

#### Create Coverage Analysis Script
```python
# File: coverage_analyzer.py

import coverage
import subprocess
import os
import json

def run_coverage_analysis(app_name):
    """Run comprehensive coverage analysis"""
    
    print(f"Running coverage analysis for {app_name}...")
    
    # Initialize coverage
    cov = coverage.Coverage()
    cov.start()
    
    try:
        # Run tests with coverage
        cmd = [
            "bench", "--site", "test.localhost", "run-tests",
            "--app", app_name
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        # Stop coverage collection
        cov.stop()
        cov.save()
        
        # Generate reports
        print("Generating coverage reports...")
        
        # Console report
        print("\nCoverage Summary:")
        cov.report()
        
        # HTML report
        cov.html_report(directory='coverage_html')
        
        # JSON report for programmatic analysis
        cov.json_report(outfile='coverage.json')
        
        # Analyze coverage data
        analyze_coverage_data('coverage.json', app_name)
        
        return result.returncode == 0
        
    except Exception as e:
        print(f"Coverage analysis failed: {e}")
        return False

def analyze_coverage_data(json_file, app_name):
    """Analyze coverage data and provide insights"""
    
    try:
        with open(json_file, 'r') as f:
            coverage_data = json.load(f)
        
        print("\n" + "="*50)
        print("COVERAGE ANALYSIS")
        print("="*50)
        
        # Overall statistics
        totals = coverage_data.get('totals', {})
        
        total_statements = totals.get('num_statements', 0)
        covered_statements = totals.get('covered_lines', 0)
        missing_statements = totals.get('missing_lines', 0)
        coverage_percent = totals.get('percent_covered', 0)
        
        print(f"Total Statements: {total_statements}")
        print(f"Covered Statements: {covered_statements}")
        print(f"Missing Statements: {missing_statements}")
        print(f"Coverage Percentage: {coverage_percent:.1f}%")
        
        # File-by-file analysis
        files = coverage_data.get('files', {})
        
        print(f"\nFILE COVERAGE BREAKDOWN:")
        low_coverage_files = []
        
        for file_path, file_data in files.items():
            if app_name in file_path:  # Focus on our app files
                file_coverage = file_data.get('summary', {}).get('percent_covered', 0)
                print(f"  {os.path.basename(file_path)}: {file_coverage:.1f}%")
                
                if file_coverage < 70:  # Flag files with low coverage
                    low_coverage_files.append({
                        'file': file_path,
                        'coverage': file_coverage
                    })
        
        # Recommendations
        print(f"\nRECOMMENDations:")
        
        if coverage_percent >= 90:
            print("✅ Excellent test coverage!")
        elif coverage_percent >= 80:
            print("✅ Good test coverage")
        elif coverage_percent >= 70:
            print("⚡ Acceptable coverage, room for improvement")
        else:
            print("⚠️  Low test coverage, needs significant improvement")
        
        if low_coverage_files:
            print(f"\nFiles needing more tests:")
            for file_info in sorted(low_coverage_files, key=lambda x: x['coverage']):
                print(f"  {os.path.basename(file_info['file'])}: {file_info['coverage']:.1f}%")
        
    except Exception as e:
        print(f"Error analyzing coverage data: {e}")

# Run coverage analysis
if __name__ == "__main__":
    success = run_coverage_analysis("your_app")
    if success:
        print("✅ Coverage analysis completed successfully")
    else:
        print("❌ Coverage analysis encountered errors")
```

### Step 6: Set Up Automated Testing

#### Create CI/CD Pipeline Configuration
```yaml
# File: .github/workflows/tests.yml

name: Run Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: frappe
          MYSQL_DATABASE: test_yourapp
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3
        ports:
          - 3306:3306
      
      redis:
        image: redis:alpine
        options: >-
          --health-cmd="redis-cli ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3
        ports:
          - 6379:6379

    steps:
    - name: Checkout code
      uses: actions/checkout@v3

    - name: Setup Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.10'

    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'

    - name: Cache Python packages
      uses: actions/cache@v3
      with:
        path: ~/.cache/pip
        key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}

    - name: Install system dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y wkhtmltopdf xvfb

    - name: Install Frappe Bench
      run: |
        pip install frappe-bench

    - name: Initialize bench
      run: |
        bench init test-bench --skip-redis-config-generation --python python3
        cd test-bench

    - name: Create test site
      run: |
        cd test-bench
        bench new-site test.localhost --force --db-root-password frappe --db-host 127.0.0.1 --db-port 3306

    - name: Install ERPNext
      run: |
        cd test-bench
        bench get-app erpnext --branch version-16
        bench --site test.localhost install-app erpnext

    - name: Install your app
      run: |
        cd test-bench
        bench get-app your_app $GITHUB_WORKSPACE
        bench --site test.localhost install-app your_app

    - name: Run tests with coverage
      run: |
        cd test-bench
        bench --site test.localhost run-tests --app your_app --coverage --verbose

    - name: Generate coverage report
      run: |
        cd test-bench
        coverage xml

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./test-bench/coverage.xml
        flags: unittests
        name: codecov-umbrella

    - name: Run performance tests
      run: |
        cd test-bench
        python $GITHUB_WORKSPACE/performance_test_runner.py

    - name: Archive test reports
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-reports
        path: |
          test-bench/coverage_html/
          test-bench/*.json
          test-bench/logs/
```

#### Create Local Test Runner Script
```bash
#!/bin/bash
# File: run_local_tests.sh

set -e

echo "🧪 Starting local test suite..."

# Configuration
SITE_NAME="test.localhost"
APP_NAME="your_app"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command -v bench &> /dev/null; then
    print_error "Frappe bench is not installed"
    exit 1
fi

if [ ! -d "sites/$SITE_NAME" ]; then
    print_error "Test site '$SITE_NAME' does not exist"
    exit 1
fi

# Step 1: Unit Tests
print_status "Running unit tests..."
if bench --site $SITE_NAME run-tests --app $APP_NAME; then
    print_status "✅ Unit tests passed"
else
    print_error "❌ Unit tests failed"
    exit 1
fi

# Step 2: Integration Tests
print_status "Running integration tests..."
if bench --site $SITE_NAME run-tests --module $APP_NAME.tests.integration; then
    print_status "✅ Integration tests passed"
else
    print_warning "⚠️ Integration tests had issues (continuing...)"
fi

# Step 3: Code Coverage
print_status "Running coverage analysis..."
if bench --site $SITE_NAME run-tests --app $APP_NAME --coverage; then
    print_status "✅ Coverage analysis completed"
    
    # Generate HTML report
    coverage html
    print_status "Coverage report generated in coverage_html/"
else
    print_warning "⚠️ Coverage analysis had issues"
fi

# Step 4: Performance Tests (optional)
read -p "Run performance tests? This may take several minutes [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Running performance tests..."
    if python performance_test_runner.py; then
        print_status "✅ Performance tests completed"
    else
        print_warning "⚠️ Performance tests had issues"
    fi
fi

# Step 5: Code Quality Checks
print_status "Running code quality checks..."

# Check for Python code quality (if flake8 is available)
if command -v flake8 &> /dev/null; then
    if flake8 apps/$APP_NAME --max-line-length=100 --exclude=migrations; then
        print_status "✅ Code quality checks passed"
    else
        print_warning "⚠️ Code quality issues found"
    fi
fi

# Final summary
print_status "🎉 Local test suite completed!"
print_status "Check the generated reports for detailed results."

echo ""
echo "📊 Generated Reports:"
echo "   - Coverage: coverage_html/index.html"
echo "   - Performance: performance_report_*.json"
echo "   - Logs: logs/"
```

### Step 7: Test Reporting and Analysis

#### Create Test Dashboard
```python
# File: test_dashboard.py

import json
import os
from datetime import datetime
import matplotlib.pyplot as plt
import seaborn as sns

class TestDashboard:
    """Generate visual test reporting dashboard"""
    
    def __init__(self):
        self.test_results = {}
        self.coverage_data = {}
        self.performance_data = {}
    
    def load_test_data(self):
        """Load all test data from various sources"""
        
        # Load latest test results
        test_files = [f for f in os.listdir('.') if f.startswith('test_report_')]
        if test_files:
            latest_test = sorted(test_files)[-1]
            with open(latest_test, 'r') as f:
                self.test_results = json.load(f)
        
        # Load coverage data
        if os.path.exists('coverage.json'):
            with open('coverage.json', 'r') as f:
                self.coverage_data = json.load(f)
        
        # Load performance data
        perf_files = [f for f in os.listdir('.') if f.startswith('performance_report_')]
        if perf_files:
            latest_perf = sorted(perf_files)[-1]
            with open(latest_perf, 'r') as f:
                self.performance_data = json.load(f)
    
    def generate_test_summary_chart(self):
        """Generate test summary visualization"""
        
        if not self.test_results:
            return
        
        # Test results pie chart
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 6))
        
        # Test pass/fail distribution
        if 'tests_passed' in self.test_results and 'tests_failed' in self.test_results:
            passed = self.test_results['tests_passed']
            failed = self.test_results['tests_failed']
            
            labels = ['Passed', 'Failed']
            sizes = [passed, failed]
            colors = ['#28a745', '#dc3545']
            
            ax1.pie(sizes, labels=labels, colors=colors, autopct='%1.1f%%', startangle=90)
            ax1.set_title('Test Results Distribution')
        
        # Coverage visualization
        if 'coverage' in self.test_results:
            coverage_pct = self.test_results['coverage']
            
            # Coverage gauge chart
            ax2.pie([coverage_pct, 100-coverage_pct], 
                   colors=['#28a745', '#e9ecef'],
                   startangle=90,
                   counterclock=False)
            
            # Add coverage percentage in center
            ax2.text(0, 0, f'{coverage_pct}%', 
                    horizontalalignment='center',
                    verticalalignment='center',
                    fontsize=20, fontweight='bold')
            ax2.set_title('Code Coverage')
        
        plt.tight_layout()
        plt.savefig('test_summary_dashboard.png', dpi=300, bbox_inches='tight')
        plt.close()
        
        print("📊 Test summary chart saved as: test_summary_dashboard.png")
    
    def generate_performance_trends(self):
        """Generate performance trend visualizations"""
        
        if not self.performance_data:
            return
        
        fig, axes = plt.subplots(2, 2, figsize=(15, 10))
        fig.suptitle('Performance Test Results', fontsize=16)
        
        # Database performance
        if 'database' in self.performance_data:
            db_data = self.performance_data['database']
            
            query_names = list(db_data.keys())
            avg_times = [data['avg_time'] for data in db_data.values()]
            
            axes[0,0].bar(query_names, avg_times, color='skyblue')
            axes[0,0].set_title('Database Query Performance')
            axes[0,0].set_ylabel('Average Time (seconds)')
            axes[0,0].tick_params(axis='x', rotation=45)
        
        # API performance
        if 'api' in self.performance_data:
            api_data = self.performance_data['api']
            
            api_names = [name.split('.')[-1] for name in api_data.keys()]
            api_times = [data['avg_time'] for data in api_data.values()]
            
            axes[0,1].bar(api_names, api_times, color='lightcoral')
            axes[0,1].set_title('API Performance')
            axes[0,1].set_ylabel('Average Time (seconds)')
            axes[0,1].tick_params(axis='x', rotation=45)
        
        # Load test results
        if 'load' in self.performance_data:
            load_data = self.performance_data['load']
            
            users = []
            success_rates = []
            avg_times = []
            
            for test_name, metrics in load_data.items():
                users.append(metrics['concurrent_users'])
                success_rate = metrics['successful_sessions'] / metrics['total_sessions']
                success_rates.append(success_rate * 100)
                avg_times.append(metrics['avg_session_time'])
            
            # Success rate vs concurrent users
            axes[1,0].plot(users, success_rates, marker='o', color='green')
            axes[1,0].set_title('Success Rate vs Concurrent Users')
            axes[1,0].set_xlabel('Concurrent Users')
            axes[1,0].set_ylabel('Success Rate (%)')
            axes[1,0].grid(True, alpha=0.3)
            
            # Response time vs concurrent users
            axes[1,1].plot(users, avg_times, marker='s', color='orange')
            axes[1,1].set_title('Response Time vs Concurrent Users')
            axes[1,1].set_xlabel('Concurrent Users')
            axes[1,1].set_ylabel('Average Response Time (s)')
            axes[1,1].grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig('performance_trends_dashboard.png', dpi=300, bbox_inches='tight')
        plt.close()
        
        print("📈 Performance trends chart saved as: performance_trends_dashboard.png")
    
    def generate_html_report(self):
        """Generate comprehensive HTML test report"""
        
        html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Test Report Dashboard</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        .header {{ background-color: #f8f9fa; padding: 20px; border-radius: 5px; }}
        .section {{ margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }}
        .metric {{ display: inline-block; margin: 10px; padding: 10px; background-color: #e9ecef; border-radius: 3px; }}
        .success {{ color: #28a745; }}
        .warning {{ color: #ffc107; }}
        .error {{ color: #dc3545; }}
        img {{ max-width: 100%; height: auto; }}
    </style>
</head>
<body>
    <div class="header">
        <h1>Test Report Dashboard</h1>
        <p>Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    </div>
    
    <div class="section">
        <h2>Test Summary</h2>
"""
        
        if self.test_results:
            html_content += f"""
        <div class="metric">
            <strong>Tests Run:</strong> {self.test_results.get('tests_run', 0)}
        </div>
        <div class="metric">
            <strong>Passed:</strong> <span class="success">{self.test_results.get('tests_passed', 0)}</span>
        </div>
        <div class="metric">
            <strong>Failed:</strong> <span class="error">{self.test_results.get('tests_failed', 0)}</span>
        </div>
        <div class="metric">
            <strong>Coverage:</strong> {self.test_results.get('coverage', 0)}%
        </div>
        <div class="metric">
            <strong>Duration:</strong> {self.test_results.get('duration', 0):.2f}s
        </div>
"""
        
        html_content += """
    </div>
    
    <div class="section">
        <h2>Visualizations</h2>
        <img src="test_summary_dashboard.png" alt="Test Summary Dashboard">
        <img src="performance_trends_dashboard.png" alt="Performance Trends Dashboard">
    </div>
    
</body>
</html>
"""
        
        with open('test_report.html', 'w') as f:
            f.write(html_content)
        
        print("📋 HTML report generated: test_report.html")
    
    def run(self):
        """Run the complete dashboard generation"""
        
        print("📊 Generating test dashboard...")
        
        self.load_test_data()
        self.generate_test_summary_chart()
        self.generate_performance_trends()
        self.generate_html_report()
        
        print("✅ Test dashboard generation completed!")
        print("📋 Open test_report.html to view the complete dashboard")

# Generate dashboard
if __name__ == "__main__":
    dashboard = TestDashboard()
    dashboard.run()
```

### Step 8: Cleanup and Maintenance

#### Clean Up Test Artifacts
```bash
# Clean up test files and reports
find . -name "*.pyc" -delete
find . -name "__pycache__" -type d -exec rm -rf {} +
rm -rf coverage_html/
rm -f coverage.xml coverage.json
rm -f test_report_*.json
rm -f performance_report_*.json
```

## Best Practices

### Test Organization
- Group tests by functionality and test type
- Use descriptive test names that explain what's being tested
- Keep tests independent and isolated
- Use proper setup and teardown methods
- Maintain test data separately from production data

### Test Execution Strategy
- Run fast unit tests frequently during development
- Run integration tests before commits
- Run performance tests periodically
- Use parallel execution for faster test runs
- Implement test result caching where appropriate

### Continuous Testing
- Set up automated testing in CI/CD pipelines
- Run tests on multiple Python versions if needed
- Test against different database configurations
- Monitor test performance over time
- Set up alerting for test failures

### Test Maintenance
- Regularly review and update test cases
- Remove obsolete tests when functionality changes
- Keep test dependencies up to date
- Monitor and improve test coverage
- Document complex test scenarios

---

*Your comprehensive test suite is now ready and properly configured. Regular testing ensures code quality and catches issues early in the development process.*