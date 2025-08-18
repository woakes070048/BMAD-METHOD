# Create Unit Tests

## Overview
This task guides you through creating comprehensive unit tests for your ERPNext application, ensuring code quality, reliability, and maintainability through systematic testing practices.

## Prerequisites

### Required Knowledge
- [ ] Understanding of Python unittest framework
- [ ] Knowledge of Frappe testing utilities
- [ ] Familiarity with test-driven development (TDD)
- [ ] Understanding of mocking and test isolation

### Development Environment
- [ ] ERPNext development environment is set up
- [ ] pytest and testing dependencies are installed
- [ ] Test database is configured
- [ ] Development mode is enabled

## Step-by-Step Process

### Step 1: Plan Your Testing Strategy

#### Define Testing Scope
```
Module: Customer Management
Components to Test:
- Customer creation and validation
- Email validation logic
- Credit limit calculations
- Customer merge functionality
- Permission checks

Test Types:
- Unit tests for individual functions
- Integration tests for workflows
- API tests for endpoints
- Performance tests for critical paths
```

#### Identify Test Categories
- **Pure Functions**: Business logic without side effects
- **Database Operations**: CRUD operations and queries
- **API Endpoints**: REST API functionality
- **Workflow Logic**: Document lifecycle management
- **Validation Rules**: Input validation and constraints

### Step 2: Set Up Test Infrastructure

#### Create Test Directory Structure
```bash
# Navigate to your app
cd /path/to/frappe-bench/apps/your_app

# Create test structure
mkdir -p your_app/tests/{unit,integration,fixtures}
touch your_app/tests/__init__.py
touch your_app/tests/unit/__init__.py
touch your_app/tests/integration/__init__.py
```

#### Create Test Configuration
```python
# your_app/tests/test_config.py

import frappe
from frappe.tests.utils import FrappeTestCase

class BaseTestCase(FrappeTestCase):
    """Base test case with common setup"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test class"""
        super().setUpClass()
        cls.setup_test_data()
    
    @classmethod
    def setup_test_data(cls):
        """Create common test data"""
        # Create test company
        if not frappe.db.exists("Company", "Test Company"):
            company = frappe.get_doc({
                "doctype": "Company",
                "company_name": "Test Company",
                "abbr": "TC",
                "default_currency": "USD"
            })
            company.insert()
    
    def setUp(self):
        """Set up each test"""
        frappe.set_user("Administrator")
        frappe.db.commit()
    
    def tearDown(self):
        """Clean up after each test"""
        frappe.db.rollback()
        frappe.set_user("Administrator")
```

### Step 3: Create Unit Tests for DocType Logic

#### Test DocType Validation
```python
# your_app/tests/unit/test_customer.py

import unittest
import frappe
from frappe.tests.utils import FrappeTestCase
from your_app.tests.test_config import BaseTestCase

class TestCustomer(BaseTestCase):
    """Unit tests for Customer DocType"""
    
    def test_customer_creation_with_valid_data(self):
        """Test customer creation with valid data"""
        customer_data = {
            "doctype": "Customer",
            "customer_name": "Test Customer",
            "email_id": "test@example.com",
            "mobile_no": "+1234567890"
        }
        
        customer = frappe.get_doc(customer_data)
        customer.insert()
        
        # Assertions
        self.assertEqual(customer.customer_name, "Test Customer")
        self.assertEqual(customer.email_id, "test@example.com")
        self.assertIsNotNone(customer.name)
        self.assertTrue(frappe.db.exists("Customer", customer.name))
    
    def test_customer_email_validation(self):
        """Test email validation in customer"""
        customer_data = {
            "doctype": "Customer",
            "customer_name": "Invalid Email Customer",
            "email_id": "invalid-email-format"
        }
        
        customer = frappe.get_doc(customer_data)
        
        with self.assertRaises(frappe.ValidationError):
            customer.insert()
    
    def test_duplicate_email_prevention(self):
        """Test prevention of duplicate email addresses"""
        # Create first customer
        customer1 = frappe.get_doc({
            "doctype": "Customer",
            "customer_name": "Customer One",
            "email_id": "duplicate@example.com"
        })
        customer1.insert()
        
        # Try to create second customer with same email
        customer2 = frappe.get_doc({
            "doctype": "Customer", 
            "customer_name": "Customer Two",
            "email_id": "duplicate@example.com"
        })
        
        with self.assertRaises(frappe.ValidationError):
            customer2.insert()
    
    def test_customer_naming_series(self):
        """Test customer naming series functionality"""
        customer = frappe.get_doc({
            "doctype": "Customer",
            "customer_name": "Series Test Customer",
            "email_id": "series@example.com"
        })
        customer.insert()
        
        # Check naming pattern
        self.assertTrue(customer.name.startswith("CUST-"))
        self.assertTrue(len(customer.name) > 5)
    
    def test_credit_limit_validation(self):
        """Test credit limit validation logic"""
        from your_app.customer import validate_credit_limit
        
        # Test within credit limit
        result = validate_credit_limit("TEST-CUSTOMER", 5000, 10000)
        self.assertTrue(result)
        
        # Test exceeding credit limit
        with self.assertRaises(frappe.ValidationError):
            validate_credit_limit("TEST-CUSTOMER", 15000, 10000)
```

### Step 4: Create Tests for Business Logic Functions

#### Test Utility Functions
```python
# your_app/tests/unit/test_utils.py

import unittest
import frappe
from frappe.tests.utils import FrappeTestCase
from your_app.utils import (
    calculate_discount,
    format_currency,
    validate_phone_number,
    generate_reference_code
)

class TestUtils(FrappeTestCase):
    """Unit tests for utility functions"""
    
    def test_calculate_discount_percentage(self):
        """Test percentage discount calculation"""
        # Test 10% discount
        result = calculate_discount(100, 10, "percentage")
        self.assertEqual(result, 90)
        
        # Test 0% discount
        result = calculate_discount(100, 0, "percentage")
        self.assertEqual(result, 100)
        
        # Test 100% discount
        result = calculate_discount(100, 100, "percentage")
        self.assertEqual(result, 0)
    
    def test_calculate_discount_fixed_amount(self):
        """Test fixed amount discount calculation"""
        # Test fixed discount
        result = calculate_discount(100, 25, "fixed")
        self.assertEqual(result, 75)
        
        # Test discount larger than amount
        with self.assertRaises(frappe.ValidationError):
            calculate_discount(50, 75, "fixed")
    
    def test_format_currency_usd(self):
        """Test USD currency formatting"""
        result = format_currency(1234.56, "USD")
        self.assertEqual(result, "$1,234.56")
        
        result = format_currency(0, "USD")
        self.assertEqual(result, "$0.00")
    
    def test_validate_phone_number_formats(self):
        """Test phone number validation"""
        # Valid formats
        self.assertTrue(validate_phone_number("+1234567890"))
        self.assertTrue(validate_phone_number("(123) 456-7890"))
        self.assertTrue(validate_phone_number("123-456-7890"))
        
        # Invalid formats
        self.assertFalse(validate_phone_number("123"))
        self.assertFalse(validate_phone_number("invalid"))
        self.assertFalse(validate_phone_number(""))
    
    def test_generate_reference_code_uniqueness(self):
        """Test reference code generation uniqueness"""
        codes = set()
        
        # Generate 100 codes and check uniqueness
        for _ in range(100):
            code = generate_reference_code("TEST")
            self.assertNotIn(code, codes)
            codes.add(code)
            self.assertTrue(code.startswith("TEST-"))
            self.assertEqual(len(code), 13)  # TEST- + 8 characters
```

### Step 5: Create API Endpoint Tests

#### Test API Authentication and Responses
```python
# your_app/tests/unit/test_api.py

import json
import frappe
from frappe.tests.utils import FrappeTestCase
from unittest.mock import patch, Mock

class TestCustomerAPI(FrappeTestCase):
    """Unit tests for Customer API endpoints"""
    
    def setUp(self):
        """Set up API tests"""
        super().setUp()
        # Create test user with API access
        if not frappe.db.exists("User", "api_test@example.com"):
            user = frappe.get_doc({
                "doctype": "User",
                "email": "api_test@example.com",
                "first_name": "API",
                "last_name": "Test",
                "roles": [{"role": "Customer"}]
            })
            user.insert()
    
    def test_create_customer_api_success(self):
        """Test successful customer creation via API"""
        frappe.set_user("api_test@example.com")
        
        response = frappe.call(
            "your_app.api.create_customer",
            customer_name="API Test Customer",
            email_id="apitest@example.com"
        )
        
        self.assertTrue(response["success"])
        self.assertIn("customer_id", response["data"])
        
        # Verify customer was created
        customer_id = response["data"]["customer_id"]
        self.assertTrue(frappe.db.exists("Customer", customer_id))
    
    def test_create_customer_api_validation_error(self):
        """Test API validation error handling"""
        frappe.set_user("api_test@example.com")
        
        with self.assertRaises(frappe.ValidationError):
            frappe.call(
                "your_app.api.create_customer",
                customer_name="",  # Invalid empty name
                email_id="invalid-email"
            )
    
    def test_create_customer_api_permission_denied(self):
        """Test API permission checking"""
        frappe.set_user("Guest")
        
        with self.assertRaises(frappe.PermissionError):
            frappe.call(
                "your_app.api.create_customer",
                customer_name="Permission Test",
                email_id="permission@example.com"
            )
    
    @patch('your_app.api.send_welcome_email')
    def test_create_customer_with_email_notification(self, mock_send_email):
        """Test customer creation with email notification"""
        frappe.set_user("api_test@example.com")
        
        response = frappe.call(
            "your_app.api.create_customer",
            customer_name="Email Test Customer",
            email_id="emailtest@example.com",
            send_welcome_email=True
        )
        
        self.assertTrue(response["success"])
        mock_send_email.assert_called_once()
    
    def test_get_customer_list_pagination(self):
        """Test customer list API with pagination"""
        frappe.set_user("Administrator")
        
        # Create test customers
        for i in range(25):
            customer = frappe.get_doc({
                "doctype": "Customer",
                "customer_name": f"Test Customer {i}",
                "email_id": f"test{i}@example.com"
            })
            customer.insert()
        
        # Test first page
        response = frappe.call(
            "your_app.api.get_customer_list",
            limit=10,
            offset=0
        )
        
        self.assertEqual(len(response["data"]), 10)
        self.assertIn("pagination", response)
        self.assertEqual(response["pagination"]["current_page"], 1)
        
        # Test second page
        response = frappe.call(
            "your_app.api.get_customer_list", 
            limit=10,
            offset=10
        )
        
        self.assertEqual(len(response["data"]), 10)
        self.assertEqual(response["pagination"]["current_page"], 2)
```

### Step 6: Create Database Operation Tests

#### Test Database Queries and Transactions
```python
# your_app/tests/unit/test_database.py

import frappe
from frappe.tests.utils import FrappeTestCase

class TestDatabaseOperations(FrappeTestCase):
    """Test database operations and queries"""
    
    def test_bulk_insert_customers(self):
        """Test bulk customer insertion"""
        from your_app.database import bulk_insert_customers
        
        customer_data = [
            {"customer_name": "Bulk Customer 1", "email_id": "bulk1@example.com"},
            {"customer_name": "Bulk Customer 2", "email_id": "bulk2@example.com"},
            {"customer_name": "Bulk Customer 3", "email_id": "bulk3@example.com"}
        ]
        
        result = bulk_insert_customers(customer_data)
        
        self.assertEqual(result["success_count"], 3)
        self.assertEqual(result["error_count"], 0)
        
        # Verify customers were created
        for data in customer_data:
            self.assertTrue(
                frappe.db.exists("Customer", {"email_id": data["email_id"]})
            )
    
    def test_customer_search_query(self):
        """Test customer search functionality"""
        from your_app.database import search_customers
        
        # Create test customers
        customers = [
            {"customer_name": "John Smith", "email_id": "john@example.com"},
            {"customer_name": "Jane Doe", "email_id": "jane@example.com"},
            {"customer_name": "Bob Johnson", "email_id": "bob@example.com"}
        ]
        
        for customer_data in customers:
            customer = frappe.get_doc({"doctype": "Customer", **customer_data})
            customer.insert()
        
        # Test name search
        results = search_customers("John")
        self.assertEqual(len(results), 2)  # John Smith and Bob Johnson
        
        # Test email search
        results = search_customers("jane@example.com")
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["customer_name"], "Jane Doe")
    
    def test_transaction_rollback_on_error(self):
        """Test transaction rollback on error"""
        from your_app.database import create_customer_with_address
        
        # Test data that should cause an error
        customer_data = {
            "customer_name": "Transaction Test",
            "email_id": "transaction@example.com"
        }
        address_data = {
            "address_line1": "123 Test St",
            "city": "",  # Missing required field - should cause error
            "country": "United States"
        }
        
        with self.assertRaises(frappe.ValidationError):
            create_customer_with_address(customer_data, address_data)
        
        # Verify customer was not created (transaction rolled back)
        self.assertFalse(
            frappe.db.exists("Customer", {"email_id": "transaction@example.com"})
        )
    
    def test_database_performance_query(self):
        """Test database query performance"""
        import time
        from your_app.database import get_customer_summary
        
        # Create many test customers
        for i in range(1000):
            customer = frappe.get_doc({
                "doctype": "Customer",
                "customer_name": f"Performance Test Customer {i}",
                "email_id": f"perf{i}@example.com"
            })
            customer.insert()
        
        # Test query performance
        start_time = time.time()
        results = get_customer_summary()
        end_time = time.time()
        
        query_time = end_time - start_time
        
        # Assert query completed within reasonable time (2 seconds)
        self.assertLess(query_time, 2.0)
        self.assertIsInstance(results, list)
        self.assertGreaterEqual(len(results), 1000)
```

### Step 7: Create Mock and Integration Tests

#### Test External Service Integration
```python
# your_app/tests/unit/test_integrations.py

import unittest
from unittest.mock import patch, Mock
import frappe
from frappe.tests.utils import FrappeTestCase

class TestExternalIntegrations(FrappeTestCase):
    """Test external service integrations"""
    
    @patch('requests.post')
    def test_send_sms_notification(self, mock_post):
        """Test SMS notification sending"""
        from your_app.integrations.sms import send_sms
        
        # Mock successful SMS response
        mock_response = Mock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"success": True, "message_id": "12345"}
        mock_post.return_value = mock_response
        
        result = send_sms("+1234567890", "Test message")
        
        self.assertTrue(result["success"])
        self.assertEqual(result["message_id"], "12345")
        
        # Verify API was called with correct parameters
        mock_post.assert_called_once()
        call_args = mock_post.call_args
        self.assertIn("phone", call_args[1]["json"])
        self.assertIn("message", call_args[1]["json"])
    
    @patch('your_app.integrations.payment.stripe')
    def test_process_payment(self, mock_stripe):
        """Test payment processing integration"""
        from your_app.integrations.payment import process_payment
        
        # Mock successful payment
        mock_charge = Mock()
        mock_charge.id = "ch_12345"
        mock_charge.status = "succeeded"
        mock_stripe.Charge.create.return_value = mock_charge
        
        payment_data = {
            "amount": 10000,  # $100.00
            "currency": "usd",
            "source": "tok_visa",
            "description": "Test payment"
        }
        
        result = process_payment(payment_data)
        
        self.assertTrue(result["success"])
        self.assertEqual(result["charge_id"], "ch_12345")
        
        # Verify Stripe API was called
        mock_stripe.Charge.create.assert_called_once_with(
            amount=10000,
            currency="usd",
            source="tok_visa",
            description="Test payment"
        )
    
    @patch('frappe.sendmail')
    def test_email_notification_sending(self, mock_sendmail):
        """Test email notification system"""
        from your_app.notifications import send_customer_welcome_email
        
        customer = frappe.get_doc({
            "doctype": "Customer",
            "customer_name": "Email Test Customer",
            "email_id": "emailtest@example.com"
        })
        customer.insert()
        
        send_customer_welcome_email(customer.name)
        
        # Verify email was sent
        mock_sendmail.assert_called_once()
        call_args = mock_sendmail.call_args[1]
        
        self.assertEqual(call_args["recipients"], ["emailtest@example.com"])
        self.assertIn("Welcome", call_args["subject"])
        self.assertEqual(call_args["reference_doctype"], "Customer")
```

### Step 8: Create Performance Tests

#### Test System Performance
```python
# your_app/tests/unit/test_performance.py

import time
import statistics
import frappe
from frappe.tests.utils import FrappeTestCase
from concurrent.futures import ThreadPoolExecutor

class TestPerformance(FrappeTestCase):
    """Performance tests for critical functionality"""
    
    def test_customer_creation_performance(self):
        """Test customer creation performance"""
        from your_app.api import create_customer
        
        response_times = []
        
        # Create 100 customers and measure time
        for i in range(100):
            start_time = time.time()
            
            frappe.call(
                "your_app.api.create_customer",
                customer_name=f"Performance Test {i}",
                email_id=f"perf{i}@example.com"
            )
            
            end_time = time.time()
            response_times.append(end_time - start_time)
        
        # Analyze performance
        avg_time = statistics.mean(response_times)
        max_time = max(response_times)
        percentile_95 = statistics.quantiles(response_times, n=20)[18]
        
        # Assertions (adjust thresholds as needed)
        self.assertLess(avg_time, 0.5)  # Average under 500ms
        self.assertLess(max_time, 2.0)  # Maximum under 2 seconds
        self.assertLess(percentile_95, 1.0)  # 95th percentile under 1 second
        
        print(f"Customer creation performance:")
        print(f"  Average: {avg_time:.3f}s")
        print(f"  Maximum: {max_time:.3f}s") 
        print(f"  95th percentile: {percentile_95:.3f}s")
    
    def test_concurrent_api_requests(self):
        """Test concurrent API request handling"""
        
        def make_request(index):
            try:
                start_time = time.time()
                response = frappe.call(
                    "your_app.api.get_customer_list",
                    limit=10
                )
                end_time = time.time()
                return end_time - start_time, response.get("success", False)
            except Exception:
                return time.time() - start_time, False
        
        # Execute 50 concurrent requests
        with ThreadPoolExecutor(max_workers=10) as executor:
            futures = [executor.submit(make_request, i) for i in range(50)]
            results = [future.result() for future in futures]
        
        # Analyze results
        response_times = [r[0] for r in results]
        success_rate = sum(1 for r in results if r[1]) / len(results)
        
        # Assertions
        self.assertGreaterEqual(success_rate, 0.95)  # 95% success rate
        self.assertLess(statistics.mean(response_times), 2.0)  # Average under 2s
        
        print(f"Concurrent requests performance:")
        print(f"  Success rate: {success_rate:.1%}")
        print(f"  Average time: {statistics.mean(response_times):.3f}s")
```

### Step 9: Run and Validate Tests

#### Execute Test Suite
```bash
# Run all tests in your app
bench --site [site-name] run-tests --app your_app

# Run specific test module
bench --site [site-name] run-tests --module your_app.tests.unit.test_customer

# Run with coverage report
bench --site [site-name] run-tests --coverage --app your_app

# Run performance tests separately
bench --site [site-name] run-tests --module your_app.tests.unit.test_performance
```

#### Continuous Integration Setup
```yaml
# .github/workflows/tests.yml

name: Run Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: frappe
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.8
    
    - name: Install dependencies
      run: |
        pip install frappe-bench
        bench init test-bench --skip-redis-config-generation
        cd test-bench
        bench get-app your_app $GITHUB_WORKSPACE
        bench new-site test.localhost --force --db-root-password frappe
        bench --site test.localhost install-app your_app
    
    - name: Run tests
      run: |
        cd test-bench
        bench --site test.localhost run-tests --app your_app --coverage
```

### Step 10: Test Maintenance and Best Practices

#### Create Test Fixtures
```python
# your_app/tests/fixtures/test_data.py

import frappe

def create_test_company():
    """Create test company for all tests"""
    if not frappe.db.exists("Company", "Test Company"):
        company = frappe.get_doc({
            "doctype": "Company",
            "company_name": "Test Company", 
            "abbr": "TC",
            "default_currency": "USD",
            "country": "United States"
        })
        company.insert()
        return company
    return frappe.get_doc("Company", "Test Company")

def create_test_user(email, roles=None):
    """Create test user with specified roles"""
    if not frappe.db.exists("User", email):
        user = frappe.get_doc({
            "doctype": "User",
            "email": email,
            "first_name": "Test",
            "last_name": "User",
            "roles": [{"role": role} for role in (roles or ["Customer"])]
        })
        user.insert()
        return user
    return frappe.get_doc("User", email)

def cleanup_test_data(doctype, filters=None):
    """Clean up test data for a doctype"""
    test_docs = frappe.get_all(doctype, filters=filters or {})
    for doc in test_docs:
        frappe.delete_doc(doctype, doc.name, force=True)
```

## Best Practices

### Test Organization
- Group related tests in test classes
- Use descriptive test method names that explain what is being tested
- Keep tests independent and isolated from each other
- Use setUp and tearDown methods appropriately
- Create reusable test fixtures and utilities

### Test Data Management
- Use factories or fixtures for creating test data
- Clean up test data after tests complete
- Use realistic but safe test data that won't conflict with production
- Avoid dependencies on external data or services

### Assertion Strategies
- Use specific assertions (assertEqual, assertIn) rather than generic ones (assertTrue)
- Test both positive cases (expected behavior) and negative cases (error conditions)
- Verify error messages and exception types
- Test boundary conditions and edge cases

### Performance Testing
- Set realistic performance benchmarks based on requirements
- Test with production-like data volumes
- Monitor resource usage during tests
- Include tests for concurrent access scenarios

## Common Issues and Solutions

### Issue: Tests Fail Due to Data Dependencies
**Cause**: Tests depend on specific data that may not exist
**Solution**: Create test fixtures and use setUp/tearDown methods

### Issue: Tests Are Slow
**Cause**: Tests create too much data or perform expensive operations
**Solution**: Use mocking for external services and optimize test data creation

### Issue: Tests Pass Locally But Fail in CI
**Cause**: Environment differences or timing issues
**Solution**: Ensure consistent test environments and handle async operations properly

### Issue: Flaky Tests
**Cause**: Tests depend on timing, random data, or external factors
**Solution**: Use deterministic test data and proper synchronization

---

*Your comprehensive unit test suite is now ready. Run tests regularly during development and ensure all tests pass before deploying to production.*