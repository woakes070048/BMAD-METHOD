# 🚨 TESTING ENFORCEMENT - MANDATORY FOR ALL ERPNEXT APPS

## CRITICAL: No Code Without Tests - PERIOD

This document contains MANDATORY testing patterns. Every feature MUST have tests or it doesn't ship.

---

## 🔴 MANDATORY TEST STRUCTURE

### Your App MUST Have This Structure:

```
your_app/
├── your_app/
│   ├── tests/                    # Main test directory
│   │   ├── __init__.py
│   │   ├── test_customer.py      # Unit tests
│   │   ├── test_sales_order.py   # Integration tests
│   │   └── test_api.py           # API tests
│   └── [module_name]/
│       └── doctype/
│           └── [doctype_name]/
│               └── test_[doctype_name].py  # DocType-specific tests
```

### 🚨 EVERY DocType MUST Have Tests:

```python
# your_app/sales/doctype/customer/test_customer.py
import frappe
from frappe.tests.utils import FrappeTestCase

class TestCustomer(FrappeTestCase):
    """MANDATORY: Every DocType needs a test class"""
    
    def setUp(self):
        """MANDATORY: Set up test data"""
        self.cleanup_test_data()
    
    def tearDown(self):
        """MANDATORY: Clean up after tests"""
        self.cleanup_test_data()
    
    def test_customer_creation(self):
        """MANDATORY: Test basic CRUD operations"""
        customer = frappe.get_doc({
            "doctype": "Customer",
            "customer_name": "Test Customer",
            "customer_group": "Individual",
            "territory": "All Territories"
        })
        customer.insert()
        
        self.assertTrue(frappe.db.exists("Customer", customer.name))
        
    def test_validation(self):
        """MANDATORY: Test validation rules"""
        customer = frappe.get_doc({
            "doctype": "Customer",
            "customer_name": "",  # Invalid - empty name
        })
        
        with self.assertRaises(frappe.ValidationError):
            customer.insert()
```

---

## 🔴 MANDATORY TEST PATTERNS

### 1. CRUD Tests (CREATE, READ, UPDATE, DELETE)

```python
def test_complete_crud_cycle(self):
    """EVERY DocType MUST have CRUD tests"""
    
    # CREATE
    doc = frappe.get_doc({
        "doctype": "YourDocType",
        "field1": "value1",
        "field2": "value2"
    })
    doc.insert()
    self.assertTrue(frappe.db.exists("YourDocType", doc.name))
    
    # READ
    retrieved = frappe.get_doc("YourDocType", doc.name)
    self.assertEqual(retrieved.field1, "value1")
    
    # UPDATE
    retrieved.field1 = "updated_value"
    retrieved.save()
    
    updated = frappe.get_doc("YourDocType", doc.name)
    self.assertEqual(updated.field1, "updated_value")
    
    # DELETE
    frappe.delete_doc("YourDocType", doc.name)
    self.assertFalse(frappe.db.exists("YourDocType", doc.name))
```

### 2. Validation Tests (MANDATORY for ALL validation rules)

```python
def test_required_fields(self):
    """Test EVERY required field"""
    doc = frappe.get_doc({
        "doctype": "YourDocType"
        # Missing required fields
    })
    
    with self.assertRaises(frappe.ValidationError) as context:
        doc.insert()
    
    self.assertIn("required", str(context.exception).lower())

def test_field_formats(self):
    """Test field format validation"""
    doc = frappe.get_doc({
        "doctype": "Customer",
        "email_id": "invalid-email"  # Bad format
    })
    
    with self.assertRaises(frappe.ValidationError):
        doc.insert()
```

### 3. Permission Tests (SECURITY CRITICAL)

```python
def test_permission_enforcement(self):
    """MANDATORY: Test all permission scenarios"""
    
    # Create test user
    test_user = "test_user@example.com"
    
    # Test with permission
    frappe.set_user(test_user)
    frappe.grant_role(test_user, "Sales User")
    
    doc = frappe.get_doc({
        "doctype": "Customer",
        "customer_name": "Test"
    })
    doc.insert()  # Should work
    
    # Test without permission
    frappe.revoke_role(test_user, "Sales User")
    
    with self.assertRaises(frappe.PermissionError):
        doc2 = frappe.get_doc({
            "doctype": "Customer",
            "customer_name": "Test2"
        })
        doc2.insert()  # Should fail
```

### 4. API Endpoint Tests (MANDATORY for ALL APIs)

```python
def test_api_endpoint(self):
    """EVERY API endpoint MUST have tests"""
    from your_app.api import your_api_method
    
    # Test successful call
    result = your_api_method(param1="value1", param2="value2")
    self.assertTrue(result.get("success"))
    self.assertIn("data", result)
    
    # Test validation
    with self.assertRaises(frappe.ValidationError):
        your_api_method(param1="")  # Invalid input
    
    # Test permissions
    frappe.set_user("Guest")
    with self.assertRaises(frappe.PermissionError):
        your_api_method(param1="value1")
```

### 5. Workflow Tests (For Submittable DocTypes)

```python
def test_document_workflow(self):
    """Test complete document lifecycle"""
    
    # Create in Draft
    doc = frappe.get_doc({
        "doctype": "Sales Order",
        "customer": create_test_customer().name,
        "transaction_date": frappe.utils.today(),
        "items": [{
            "item_code": "TEST-ITEM",
            "qty": 1,
            "rate": 100
        }]
    })
    doc.insert()
    self.assertEqual(doc.docstatus, 0)  # Draft
    
    # Submit
    doc.submit()
    self.assertEqual(doc.docstatus, 1)  # Submitted
    
    # Cancel
    doc.cancel()
    self.assertEqual(doc.docstatus, 2)  # Cancelled
```

---

## 🔴 TEST DATA FACTORY PATTERN (MANDATORY)

### Create a Test Data Factory:

```python
# your_app/tests/test_data_factory.py
import frappe
from frappe.utils import random_string

class TestDataFactory:
    """MANDATORY: Centralized test data creation"""
    
    @staticmethod
    def create_customer(**kwargs):
        """Create test customer with defaults"""
        defaults = {
            "customer_name": f"Test Customer {random_string(5)}",
            "customer_type": "Individual",
            "customer_group": "Individual",
            "territory": "All Territories"
        }
        defaults.update(kwargs)
        
        customer = frappe.get_doc({
            "doctype": "Customer",
            **defaults
        })
        customer.insert(ignore_permissions=True)
        return customer
    
    @staticmethod
    def create_item(**kwargs):
        """Create test item with defaults"""
        defaults = {
            "item_code": f"TEST-{random_string(8)}",
            "item_name": f"Test Item {random_string(5)}",
            "item_group": "All Item Groups",
            "stock_uom": "Nos"
        }
        defaults.update(kwargs)
        
        item = frappe.get_doc({
            "doctype": "Item",
            **defaults
        })
        item.insert(ignore_permissions=True)
        return item
    
    @staticmethod
    def cleanup_test_data():
        """Clean up all test data"""
        # Delete in reverse dependency order
        frappe.db.sql("DELETE FROM `tabSales Order` WHERE customer LIKE 'Test Customer%'")
        frappe.db.sql("DELETE FROM `tabCustomer` WHERE customer_name LIKE 'Test%'")
        frappe.db.sql("DELETE FROM `tabItem` WHERE item_code LIKE 'TEST-%'")
        frappe.db.commit()
```

---

## 🔴 PERFORMANCE TEST REQUIREMENTS

### MANDATORY Performance Benchmarks:

```python
def test_bulk_operation_performance(self):
    """Ensure operations complete within time limits"""
    import time
    
    start_time = time.time()
    
    # Create 100 records
    for i in range(100):
        TestDataFactory.create_customer(
            customer_name=f"Perf Test {i}"
        )
    
    duration = time.time() - start_time
    
    # MUST complete within 30 seconds
    self.assertLess(duration, 30, 
        f"Bulk creation too slow: {duration}s")
    
    # Cleanup
    TestDataFactory.cleanup_test_data()

def test_query_performance(self):
    """Ensure queries are optimized"""
    import time
    
    # Create test data
    for i in range(1000):
        TestDataFactory.create_customer()
    
    start_time = time.time()
    
    # Test query
    results = frappe.get_all("Customer",
        filters={"customer_name": ["like", "%Test%"]},
        limit=100
    )
    
    duration = time.time() - start_time
    
    # MUST complete within 2 seconds
    self.assertLess(duration, 2,
        f"Query too slow: {duration}s")
```

---

## 🔴 MOCKING PATTERNS (MANDATORY for External Services)

### Mock External APIs:

```python
import unittest.mock as mock

def test_external_api_integration(self):
    """MUST mock all external services"""
    
    with mock.patch('your_app.utils.call_external_api') as mock_api:
        # Configure mock
        mock_api.return_value = {
            "success": True,
            "data": {"id": "123"}
        }
        
        # Test your code
        result = your_function_that_uses_api()
        
        # Verify mock was called
        mock_api.assert_called_once()
        self.assertTrue(result["success"])

def test_email_sending(self):
    """MUST mock email sending"""
    
    with mock.patch('frappe.sendmail') as mock_mail:
        # Trigger email
        send_notification("test@example.com")
        
        # Verify email was "sent"
        mock_mail.assert_called_once()
        call_args = mock_mail.call_args
        self.assertIn("test@example.com", call_args[1]['recipients'])
```

---

## 🔴 TEST EXECUTION REQUIREMENTS

### Run Tests Before EVERY Commit:

```bash
# Run all tests for your app
bench --site test_site run-tests --app your_app

# Run specific test
bench --site test_site run-tests --app your_app --test test_customer

# Run with coverage
bench --site test_site run-tests --app your_app --coverage
```

### Minimum Test Coverage Requirements:
- **Overall**: 80% minimum
- **Critical paths**: 100% required
- **API endpoints**: 100% required
- **Validation rules**: 100% required
- **Permission checks**: 100% required

---

## 🔴 CI/CD INTEGRATION (MANDATORY)

### GitHub Actions Test Runner:

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_ROOT_PASSWORD: root
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
    
    - name: Install Frappe Bench
      run: |
        pip install frappe-bench
        bench init frappe-bench --skip-redis-config-generation
        cd frappe-bench
        bench get-app your_app $GITHUB_WORKSPACE
    
    - name: Run Tests
      run: |
        cd frappe-bench
        bench --site test_site run-tests --app your_app
    
    - name: Check Coverage
      run: |
        cd frappe-bench
        bench --site test_site run-tests --app your_app --coverage
        # Fail if coverage < 80%
        coverage report --fail-under=80
```

---

## 🔴 TEST CHECKLIST (MANDATORY BEFORE MERGE)

Before ANY code is merged:

- [ ] ALL DocTypes have test files
- [ ] CRUD operations tested for each DocType
- [ ] Validation rules have test cases
- [ ] Permission scenarios tested
- [ ] API endpoints have tests
- [ ] External services are mocked
- [ ] Performance benchmarks pass
- [ ] Test coverage >= 80%
- [ ] All tests pass in CI/CD
- [ ] No hardcoded test data in production code
- [ ] Test data is cleaned up properly
- [ ] Error scenarios are tested
- [ ] Edge cases are covered
- [ ] Integration tests for workflows
- [ ] No console.log or print statements

---

## 🚨 ENFORCEMENT RULES

1. **NO MERGE WITHOUT TESTS**: Pull requests without tests will be REJECTED
2. **BROKEN TESTS = BROKEN BUILD**: Fix immediately
3. **TEST FIRST**: Write test, watch it fail, then implement
4. **MOCK EVERYTHING EXTERNAL**: No real API calls in tests
5. **CLEAN UP**: Every test must clean its data
6. **FAST TESTS**: Individual tests < 5 seconds
7. **ISOLATED TESTS**: Tests must not depend on each other
8. **DESCRIPTIVE NAMES**: test_what_when_expected_result()

---

## 🎯 TESTING ANTI-PATTERNS TO AVOID

### ❌ NEVER DO THIS:
```python
# No test isolation
def test_1_create():
    self.customer = create_customer()  # Bad - affects other tests

# Hardcoded data
def test_with_specific_customer():
    customer = frappe.get_doc("Customer", "CUST-00001")  # Bad

# No cleanup
def test_without_cleanup():
    create_test_data()
    # Missing cleanup!

# Testing implementation not behavior
def test_internal_method():
    self.assertEqual(doc._calculate(), 42)  # Bad - test behavior
```

### ✅ ALWAYS DO THIS:
```python
# Isolated test
def test_create_customer(self):
    customer = TestDataFactory.create_customer()
    self.assertTrue(customer.name)
    frappe.delete_doc("Customer", customer.name)

# Dynamic data
def test_with_dynamic_customer(self):
    customer = TestDataFactory.create_customer()
    # Use the created customer

# Proper cleanup
def tearDown(self):
    TestDataFactory.cleanup_test_data()

# Test behavior
def test_total_calculation(self):
    doc = create_doc_with_items()
    self.assertEqual(doc.total, 100)  # Test result, not method
```

---

**REMEMBER**: Untested code is broken code. No exceptions!