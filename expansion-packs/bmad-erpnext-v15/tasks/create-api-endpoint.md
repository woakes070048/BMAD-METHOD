# Create API Endpoint

## Overview
This task guides you through creating secure, well-documented API endpoints in your ERPNext application using proper Frappe patterns and best practices.

## Prerequisites

### Required Knowledge
- [ ] Basic understanding of Python and Frappe framework
- [ ] Understanding of HTTP methods and REST API principles
- [ ] Knowledge of ERPNext permission system
- [ ] Familiarity with frappe.whitelist() decorator

### Development Environment
- [ ] Frappe development environment is set up
- [ ] Your custom app is created and installed
- [ ] Development mode is enabled (`bench --site [site-name] set-config developer_mode 1`)

## Step-by-Step Process

### Step 1: Plan Your API Endpoint

#### Define API Requirements
- **Purpose**: What business function will this API serve?
- **HTTP Method**: GET (read), POST (create), PUT/PATCH (update), DELETE (remove)
- **Authentication**: Does this endpoint require authentication?
- **Permissions**: What roles/permissions are needed?
- **Parameters**: What input parameters are required?
- **Response Format**: What data should be returned?

#### Example Planning
```
API Purpose: Create a new customer
HTTP Method: POST
Authentication: Required (logged-in users only)
Permissions: Customer creation permission
Parameters: customer_name, email_id, phone (optional)
Response: Success status and created customer ID
```

### Step 2: Create API Module Structure

#### Create API Directory
```bash
# Navigate to your app directory
cd /path/to/your/frappe-bench/apps/your_app

# Create API module directory
mkdir -p your_app/api
touch your_app/api/__init__.py
```

#### Create API Module File
```bash
# Create API module for specific functionality
touch your_app/api/customer_api.py
```

### Step 3: Implement API Endpoint

#### Basic API Endpoint Structure
```python
# your_app/api/customer_api.py

import frappe
from frappe import _
from frappe.utils import cstr, validate_email_address

@frappe.whitelist()
def create_customer(customer_name, email_id, phone=None):
    """
    Create a new customer record
    
    Args:
        customer_name (str): Name of the customer
        email_id (str): Email address of the customer
        phone (str, optional): Phone number of the customer
    
    Returns:
        dict: Response with success status and customer details
        
    Raises:
        frappe.ValidationError: When input validation fails
        frappe.PermissionError: When user lacks required permissions
    """
    try:
        # Input validation
        if not customer_name or not email_id:
            frappe.throw(_("Customer name and email are required"))
        
        # Validate email format
        validate_email_address(email_id)
        
        # Check permissions
        if not frappe.has_permission("Customer", "create"):
            frappe.throw(_("Not permitted to create customers"), frappe.PermissionError)
        
        # Check if customer already exists
        if frappe.db.exists("Customer", {"email_id": email_id}):
            frappe.throw(_("Customer with this email already exists"))
        
        # Create customer document
        customer = frappe.get_doc({
            "doctype": "Customer",
            "customer_name": customer_name,
            "email_id": email_id,
            "mobile_no": phone
        })
        
        # Insert the document
        customer.insert()
        
        # Return success response
        return {
            "success": True,
            "message": _("Customer created successfully"),
            "data": {
                "customer_id": customer.name,
                "customer_name": customer.customer_name,
                "email_id": customer.email_id
            }
        }
        
    except frappe.ValidationError:
        # Re-raise validation errors as-is
        raise
    except frappe.PermissionError:
        # Re-raise permission errors as-is
        raise
    except Exception as e:
        # Log unexpected errors
        frappe.log_error(frappe.get_traceback(), "Customer Creation API Error")
        frappe.throw(_("Failed to create customer: {0}").format(str(e)))
```

### Step 4: Add Advanced Features

#### Authentication and Permissions
```python
@frappe.whitelist()  # Requires authentication
def get_customer_details(customer_id):
    """Get customer details with permission check"""
    
    # Check if user has read permission for this specific customer
    if not frappe.has_permission("Customer", "read", customer_id):
        frappe.throw(_("Not permitted to access this customer"), frappe.PermissionError)
    
    customer = frappe.get_doc("Customer", customer_id)
    
    return {
        "success": True,
        "data": {
            "name": customer.name,
            "customer_name": customer.customer_name,
            "email_id": customer.email_id,
            "mobile_no": customer.mobile_no,
            "territory": customer.territory
        }
    }

@frappe.whitelist(allow_guest=True)  # No authentication required
def get_public_info():
    """Public API endpoint for guest access"""
    
    # Rate limiting for public endpoints
    if not check_rate_limit("public_info", 100):  # 100 requests per minute
        frappe.throw(_("Rate limit exceeded"))
    
    return {
        "success": True,
        "data": {
            "company_name": frappe.db.get_single_value("System Settings", "company"),
            "version": frappe.__version__
        }
    }
```

#### Input Validation and Sanitization
```python
@frappe.whitelist()
def update_customer(customer_id, **kwargs):
    """Update customer with comprehensive validation"""
    
    # Get the customer document
    customer = frappe.get_doc("Customer", customer_id)
    
    # Check write permission
    if not frappe.has_permission("Customer", "write", customer_id):
        frappe.throw(_("Not permitted to update this customer"), frappe.PermissionError)
    
    # Validate and sanitize inputs
    allowed_fields = ["customer_name", "email_id", "mobile_no", "territory"]
    updates = {}
    
    for field, value in kwargs.items():
        if field not in allowed_fields:
            continue
            
        # Sanitize string inputs
        if isinstance(value, str):
            value = cstr(value).strip()
        
        # Field-specific validation
        if field == "email_id" and value:
            validate_email_address(value)
            # Check for duplicates
            existing = frappe.db.get_value("Customer", 
                {"email_id": value, "name": ["!=", customer_id]}, "name")
            if existing:
                frappe.throw(_("Email already exists for another customer"))
        
        updates[field] = value
    
    # Update the document
    customer.update(updates)
    customer.save()
    
    return {
        "success": True,
        "message": _("Customer updated successfully"),
        "data": {
            "customer_id": customer.name,
            "updated_fields": list(updates.keys())
        }
    }
```

#### Error Handling and Logging
```python
@frappe.whitelist()
def bulk_create_customers(customers_data):
    """Bulk create customers with comprehensive error handling"""
    
    results = {
        "success": [],
        "errors": [],
        "total_processed": 0
    }
    
    try:
        customers_list = frappe.parse_json(customers_data)
        
        for i, customer_data in enumerate(customers_list):
            try:
                # Validate required fields
                required_fields = ["customer_name", "email_id"]
                for field in required_fields:
                    if not customer_data.get(field):
                        raise frappe.ValidationError(f"{field} is required")
                
                # Create customer
                customer = frappe.get_doc({
                    "doctype": "Customer",
                    **customer_data
                })
                customer.insert()
                
                results["success"].append({
                    "index": i,
                    "customer_id": customer.name,
                    "customer_name": customer.customer_name
                })
                
            except Exception as e:
                results["errors"].append({
                    "index": i,
                    "data": customer_data,
                    "error": str(e)
                })
                
                # Log individual errors
                frappe.log_error(
                    f"Bulk customer creation error at index {i}: {str(e)}", 
                    "Bulk Customer Creation"
                )
            
            results["total_processed"] += 1
        
        # Commit successful creations
        frappe.db.commit()
        
        return {
            "success": True,
            "message": _("Bulk operation completed"),
            "data": results
        }
        
    except Exception as e:
        frappe.db.rollback()
        frappe.log_error(frappe.get_traceback(), "Bulk Customer Creation Error")
        frappe.throw(_("Bulk operation failed: {0}").format(str(e)))
```

### Step 5: Add Response Formatting and Pagination

#### Standardized Response Format
```python
def format_api_response(success=True, data=None, message=None, error=None):
    """Standardize API response format"""
    response = {
        "success": success,
        "timestamp": frappe.utils.now(),
        "user": frappe.session.user
    }
    
    if data is not None:
        response["data"] = data
    
    if message:
        response["message"] = message
    
    if error:
        response["error"] = error
    
    return response

@frappe.whitelist()
def get_customers_list(limit=20, offset=0, filters=None):
    """Get paginated customer list"""
    
    try:
        # Parse and validate pagination parameters
        limit = min(int(limit), 100)  # Maximum 100 records per page
        offset = max(int(offset), 0)
        
        # Build filters
        where_conditions = []
        filter_values = {}
        
        if filters:
            parsed_filters = frappe.parse_json(filters)
            for field, value in parsed_filters.items():
                if field in ["customer_name", "email_id", "territory"]:
                    where_conditions.append(f"`tab{field}` LIKE %(filter_{field})s")
                    filter_values[f"filter_{field}"] = f"%{value}%"
        
        where_clause = f"WHERE {' AND '.join(where_conditions)}" if where_conditions else ""
        
        # Get total count
        count_query = f"""
            SELECT COUNT(*) as total 
            FROM `tabCustomer` 
            {where_clause}
        """
        total_count = frappe.db.sql(count_query, filter_values, as_dict=True)[0].total
        
        # Get paginated data
        data_query = f"""
            SELECT 
                name, customer_name, email_id, mobile_no, territory, creation
            FROM `tabCustomer` 
            {where_clause}
            ORDER BY creation DESC
            LIMIT %(limit)s OFFSET %(offset)s
        """
        
        filter_values.update({"limit": limit, "offset": offset})
        customers = frappe.db.sql(data_query, filter_values, as_dict=True)
        
        # Calculate pagination info
        total_pages = (total_count + limit - 1) // limit
        current_page = (offset // limit) + 1
        
        return format_api_response(
            success=True,
            data=customers,
            message=_("Customers retrieved successfully")
        ) | {
            "pagination": {
                "current_page": current_page,
                "total_pages": total_pages,
                "total_records": total_count,
                "limit": limit,
                "offset": offset,
                "has_next": current_page < total_pages,
                "has_prev": current_page > 1
            }
        }
        
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Customer List API Error")
        return format_api_response(
            success=False,
            error=str(e),
            message=_("Failed to retrieve customers")
        )
```

### Step 6: Add Rate Limiting and Security

#### Rate Limiting Implementation
```python
def check_rate_limit(endpoint_name, limit_per_minute):
    """Check if user has exceeded rate limit"""
    cache_key = f"rate_limit:{frappe.session.user}:{endpoint_name}"
    current_count = frappe.cache().get(cache_key) or 0
    
    if current_count >= limit_per_minute:
        return False
    
    # Increment counter with 60-second expiry
    frappe.cache().set(cache_key, current_count + 1, expires_in_sec=60)
    return True

@frappe.whitelist()
def secure_endpoint(data):
    """Endpoint with comprehensive security measures"""
    
    # Rate limiting
    if not check_rate_limit("secure_endpoint", 50):  # 50 requests per minute
        frappe.throw(_("Rate limit exceeded. Please try again later."))
    
    # Input sanitization
    if isinstance(data, str):
        data = frappe.parse_json(data)
    
    # Validate input structure
    if not isinstance(data, dict):
        frappe.throw(_("Invalid input format"))
    
    # SQL injection prevention (use parameterized queries)
    safe_query = """
        SELECT name, customer_name 
        FROM `tabCustomer` 
        WHERE territory = %(territory)s
    """
    
    # XSS prevention (escape HTML)
    from frappe.utils import escape_html
    safe_data = {k: escape_html(v) if isinstance(v, str) else v for k, v in data.items()}
    
    # Log security events
    frappe.log_error(
        f"Secure endpoint accessed by {frappe.session.user} with data: {data}",
        "Security Log"
    )
    
    return {
        "success": True,
        "message": _("Secure operation completed"),
        "data": safe_data
    }
```

### Step 7: Create Unit Tests

#### Test File Structure
```python
# your_app/tests/test_customer_api.py

import unittest
import frappe
from frappe.tests.utils import FrappeTestCase

class TestCustomerAPI(FrappeTestCase):
    def setUp(self):
        """Set up test environment"""
        # Create test user
        if not frappe.db.exists("User", "test_api_user@example.com"):
            user = frappe.get_doc({
                "doctype": "User",
                "email": "test_api_user@example.com",
                "first_name": "Test",
                "last_name": "User",
                "roles": [{"role": "Customer"}]
            })
            user.insert()
        
        # Set test user
        frappe.set_user("test_api_user@example.com")
    
    def test_create_customer_success(self):
        """Test successful customer creation"""
        response = frappe.call(
            "your_app.api.customer_api.create_customer",
            customer_name="Test Customer",
            email_id="test@example.com"
        )
        
        self.assertTrue(response["success"])
        self.assertIn("customer_id", response["data"])
        
        # Verify customer was created
        self.assertTrue(frappe.db.exists("Customer", response["data"]["customer_id"]))
    
    def test_create_customer_validation_error(self):
        """Test customer creation with invalid data"""
        with self.assertRaises(frappe.ValidationError):
            frappe.call(
                "your_app.api.customer_api.create_customer",
                customer_name="",
                email_id="invalid-email"
            )
    
    def test_api_permission_check(self):
        """Test API permission enforcement"""
        # Set user without customer creation permission
        frappe.set_user("Guest")
        
        with self.assertRaises(frappe.PermissionError):
            frappe.call(
                "your_app.api.customer_api.create_customer",
                customer_name="Test Customer",
                email_id="test@example.com"
            )
    
    def tearDown(self):
        """Clean up test data"""
        # Delete test customers
        test_customers = frappe.get_all("Customer", 
            filters={"email_id": ["like", "%@example.com"]})
        for customer in test_customers:
            frappe.delete_doc("Customer", customer.name)
        
        # Reset user
        frappe.set_user("Administrator")
```

### Step 8: Document Your API

#### API Documentation Template
Create a file `your_app/docs/api_documentation.md`:

```markdown
# Customer API Documentation

## Create Customer
**Endpoint**: `/api/method/your_app.api.customer_api.create_customer`
**Method**: POST
**Authentication**: Required

### Parameters
- `customer_name` (string, required): Name of the customer
- `email_id` (string, required): Valid email address
- `phone` (string, optional): Phone number

### Example Request
```json
{
    "customer_name": "John Doe",
    "email_id": "john@example.com",
    "phone": "+1234567890"
}
```

### Example Response
```json
{
    "success": true,
    "message": "Customer created successfully",
    "data": {
        "customer_id": "CUST-001",
        "customer_name": "John Doe",
        "email_id": "john@example.com"
    },
    "timestamp": "2023-01-01T12:00:00"
}
```

### Error Responses
- `400 Bad Request`: Invalid input data
- `403 Forbidden`: Insufficient permissions
- `409 Conflict`: Customer with email already exists
```

### Step 9: Test Your API

#### Using curl
```bash
# Test API endpoint using curl
curl -X POST \
  http://localhost:8000/api/method/your_app.api.customer_api.create_customer \
  -H 'Content-Type: application/json' \
  -H 'Authorization: token YOUR_API_KEY:YOUR_API_SECRET' \
  -d '{
    "customer_name": "Test Customer",
    "email_id": "test@example.com",
    "phone": "+1234567890"
  }'
```

#### Using Postman or API Client
1. Set request method to POST
2. Add endpoint URL
3. Set headers:
   - `Content-Type: application/json`
   - `Authorization: token YOUR_API_KEY:YOUR_API_SECRET`
4. Add request body with test data
5. Send request and verify response

### Step 10: Deploy and Monitor

#### Pre-deployment Validation Checklist
- [ ] **Frappe Compliance Validation**
  - [ ] Run frappe-compliance-validator on all API code
  - [ ] Verify no external libraries used when Frappe equivalents exist
  - [ ] Confirm all HTTP requests use frappe.request patterns
  - [ ] Validate proper use of @frappe.whitelist() decorator
- [ ] **Security Validation**
  - [ ] Run security vulnerability scan
  - [ ] Verify input sanitization and validation
  - [ ] Test authentication and authorization boundaries
  - [ ] Validate rate limiting effectiveness
  - [ ] Check for SQL injection vulnerabilities
  - [ ] Verify XSS protection measures
- [ ] **Testing Validation**
  - [ ] All unit tests pass
  - [ ] Integration tests with other apps pass
  - [ ] API contract tests verify response format
  - [ ] Performance tests meet response time requirements
  - [ ] Load tests verify scalability
  - [ ] Security penetration tests pass
- [ ] **Code Quality Validation**
  - [ ] Static code analysis passes
  - [ ] Code review completed and approved
  - [ ] Documentation is complete and accurate
  - [ ] Error handling covers all scenarios
  - [ ] Logging is implemented for debugging
- [ ] **Integration Validation**
  - [ ] Multi-app compatibility verified
  - [ ] docflow integration tested if applicable
  - [ ] n8n_integration webhook compatibility verified
  - [ ] Existing API endpoints not affected
- [ ] **Performance Validation**
  - [ ] Database query optimization verified
  - [ ] Memory usage within acceptable limits
  - [ ] Response time benchmarks met
  - [ ] Concurrent user load tested
- [ ] **Deployment Validation**
  - [ ] Migration scripts tested
  - [ ] Environment configuration validated
  - [ ] Rollback procedures tested
  - [ ] Production environment compatibility verified

#### Production Considerations
- Set up API monitoring and alerting
- Configure proper logging levels
- Implement request/response logging for auditing
- Set up rate limiting based on usage patterns
- Monitor API performance and response times
- Plan for API versioning if needed

## Best Practices

### Security
- Always validate and sanitize input data
- Use parameterized queries to prevent SQL injection
- Implement proper authentication and authorization
- Add rate limiting for public endpoints
- Log security events and failed attempts
- Use HTTPS in production

### Performance
- Implement pagination for large datasets
- Use database indexing for frequently queried fields
- Cache expensive operations when possible
- Use background jobs for long-running processes
- Monitor and optimize slow queries

### Error Handling
- Provide meaningful error messages
- Use appropriate HTTP status codes
- Log errors for debugging purposes
- Don't expose sensitive information in error responses
- Implement graceful degradation

### Documentation
- Document all endpoints with examples
- Include parameter descriptions and requirements
- Specify error conditions and responses
- Keep documentation updated with code changes
- Provide SDK or client libraries if needed

## Common Pitfalls to Avoid

1. **Missing Permission Checks**: Always verify user permissions before data operations
2. **SQL Injection**: Use parameterized queries, never string concatenation
3. **Exposing Sensitive Data**: Be careful about what data you return in API responses
4. **Missing Input Validation**: Always validate and sanitize user inputs
5. **Poor Error Handling**: Don't let unhandled exceptions crash your API
6. **Missing Rate Limiting**: Protect your API from abuse with appropriate rate limiting
7. **Inadequate Logging**: Log important events for debugging and auditing
8. **Ignoring Performance**: Monitor and optimize API performance regularly

## Troubleshooting

### Common Issues
- **Permission Denied**: Check user roles and document-level permissions
- **Validation Errors**: Verify input data format and required fields
- **Rate Limit Exceeded**: Implement proper rate limiting and inform users
- **Server Errors**: Check server logs for detailed error information

### Debug Tips
- Use `frappe.log_error()` for detailed error logging
- Enable developer mode for detailed error messages
- Use `frappe.db.commit()` and `frappe.db.rollback()` for transaction control
- Test with different user roles to verify permission enforcement

---

*This completes the API endpoint creation process. Your API should now be secure, well-documented, and ready for production use.*