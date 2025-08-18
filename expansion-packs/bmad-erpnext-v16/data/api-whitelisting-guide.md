# Frappe API Whitelisting & Security Guide

## Critical Security Rule
**NEVER expose a Python method to the web without @frappe.whitelist() decorator**

## What is Whitelisting?

Whitelisting in Frappe is a security mechanism that explicitly marks Python methods as safe to be called from the client-side (browser/API). Without whitelisting, methods cannot be accessed via REST API or RPC calls.

## Basic Whitelisting

### Simple Method
```python
import frappe
from frappe import _

@frappe.whitelist()
def get_user_info():
    """Get current user information"""
    return {
        "user": frappe.session.user,
        "roles": frappe.get_roles(),
        "full_name": frappe.get_user().full_name
    }
```

### With Parameters
```python
@frappe.whitelist()
def get_customer_details(customer_id):
    """Get customer details by ID"""
    # Always validate permissions
    if not frappe.has_permission("Customer", "read"):
        frappe.throw(_("Insufficient permissions"))
    
    # Validate input
    if not customer_id:
        frappe.throw(_("Customer ID is required"))
    
    return frappe.get_doc("Customer", customer_id).as_dict()
```

## Security Levels

### 1. Authenticated Users Only (Default)
```python
@frappe.whitelist()
def authenticated_method():
    # Only logged-in users can access
    return {"status": "success"}
```

### 2. Allow Guest Access
```python
@frappe.whitelist(allow_guest=True)
def public_method():
    # Anyone can access (use sparingly!)
    return {"message": "Public information"}
```

### 3. Specific Roles
```python
@frappe.whitelist()
def admin_only_method():
    # Check role manually
    if "System Manager" not in frappe.get_roles():
        frappe.throw(_("Only System Managers can access this"))
    return {"admin_data": "sensitive"}
```

### 4. Methods with Validation
```python
@frappe.whitelist()
def update_record(doctype, name, updates):
    """Update a record with validation"""
    # Check permissions
    if not frappe.has_permission(doctype, "write", name):
        frappe.throw(_("No write permission"))
    
    # Parse JSON if string
    if isinstance(updates, str):
        updates = frappe.parse_json(updates)
    
    # Get and update document
    doc = frappe.get_doc(doctype, name)
    doc.update(updates)
    doc.save()
    
    return doc.as_dict()
```

## Input Validation Patterns

### Type Validation
```python
@frappe.whitelist()
def process_order(order_id, quantity, price):
    """Process order with type validation"""
    from frappe.utils import cint, flt, cstr
    
    # Convert and validate types
    order_id = cstr(order_id)
    quantity = cint(quantity)
    price = flt(price)
    
    if quantity <= 0:
        frappe.throw(_("Quantity must be positive"))
    
    if price < 0:
        frappe.throw(_("Price cannot be negative"))
    
    # Process order...
    return {"status": "processed"}
```

### JSON Parameter Handling
```python
@frappe.whitelist()
def bulk_update(items):
    """Handle JSON parameters"""
    # Parse JSON if string
    if isinstance(items, str):
        items = frappe.parse_json(items)
    
    # Validate it's a list
    if not isinstance(items, list):
        frappe.throw(_("Items must be a list"))
    
    results = []
    for item in items:
        # Process each item
        results.append(process_item(item))
    
    return results
```

### SQL Injection Prevention
```python
@frappe.whitelist()
def search_customers(search_term, limit=20):
    """Safe SQL query example"""
    # NEVER do string concatenation for SQL
    # BAD: f"SELECT * FROM tabCustomer WHERE name LIKE '%{search_term}%'"
    
    # GOOD: Use parameterized queries
    customers = frappe.db.sql("""
        SELECT name, customer_name, territory
        FROM `tabCustomer`
        WHERE customer_name LIKE %(search)s
        LIMIT %(limit)s
    """, {
        "search": f"%{search_term}%",
        "limit": frappe.utils.cint(limit)
    }, as_dict=True)
    
    return customers
```

## Permission Checking

### Document-Level Permissions
```python
@frappe.whitelist()
def get_document(doctype, name):
    """Get document with permission check"""
    # Method 1: Using has_permission
    if not frappe.has_permission(doctype, "read", name):
        frappe.throw(_("No read permission"))
    
    # Method 2: Using get_doc with check
    doc = frappe.get_doc(doctype, name)
    doc.check_permission("read")
    
    return doc.as_dict()
```

### Field-Level Permissions
```python
@frappe.whitelist()
def get_filtered_data(doctype, name):
    """Return data based on field permissions"""
    doc = frappe.get_doc(doctype, name)
    doc.check_permission("read")
    
    # Get meta to check field permissions
    meta = frappe.get_meta(doctype)
    data = {}
    
    for field in meta.fields:
        if not field.permlevel or frappe.has_permission(doctype, "read", permLevel=field.permlevel):
            data[field.fieldname] = doc.get(field.fieldname)
    
    return data
```

## Rate Limiting

### Basic Rate Limiting
```python
from frappe.rate_limiter import rate_limit

@frappe.whitelist()
@rate_limit(limit=10, seconds=60)  # 10 requests per minute
def rate_limited_api():
    """API with rate limiting"""
    return {"data": "rate limited response"}
```

### Custom Rate Limiting
```python
@frappe.whitelist()
def custom_rate_limited():
    """Custom rate limiting logic"""
    from frappe.utils import now_datetime
    from datetime import timedelta
    
    # Check last request time
    user = frappe.session.user
    cache_key = f"api_last_request_{user}"
    last_request = frappe.cache().get(cache_key)
    
    if last_request:
        time_diff = now_datetime() - last_request
        if time_diff < timedelta(seconds=5):
            frappe.throw(_("Please wait 5 seconds between requests"))
    
    # Update last request time
    frappe.cache().set(cache_key, now_datetime(), expires_in_sec=60)
    
    return {"status": "success"}
```

## Error Handling

### Proper Error Responses
```python
@frappe.whitelist()
def safe_operation(doc_name):
    """Operation with proper error handling"""
    try:
        # Validate input
        if not doc_name:
            frappe.throw(_("Document name is required"), frappe.ValidationError)
        
        # Check existence
        if not frappe.db.exists("Customer", doc_name):
            frappe.throw(_("Customer not found"), frappe.DoesNotExistError)
        
        # Process
        doc = frappe.get_doc("Customer", doc_name)
        result = process_customer(doc)
        
        return {
            "success": True,
            "data": result
        }
        
    except frappe.PermissionError as e:
        frappe.throw(_("Permission denied: {0}").format(str(e)))
    except frappe.ValidationError as e:
        frappe.throw(_("Validation failed: {0}").format(str(e)))
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "API Error")
        frappe.throw(_("An error occurred. Please try again."))
```

## File Upload Handling

### Secure File Upload
```python
@frappe.whitelist()
def upload_file():
    """Secure file upload"""
    from frappe.utils.file_manager import save_file
    
    # Get uploaded file
    file = frappe.local.uploaded_file
    filename = frappe.local.uploaded_filename
    
    if not file:
        frappe.throw(_("No file uploaded"))
    
    # Validate file type
    allowed_types = ['.pdf', '.doc', '.docx', '.jpg', '.png']
    import os
    ext = os.path.splitext(filename)[1].lower()
    
    if ext not in allowed_types:
        frappe.throw(_("File type not allowed"))
    
    # Validate file size (5MB max)
    if len(file) > 5 * 1024 * 1024:
        frappe.throw(_("File size exceeds 5MB limit"))
    
    # Save file
    file_doc = save_file(
        filename,
        file,
        "Customer",
        "CUST-001",
        is_private=1
    )
    
    return {
        "file_url": file_doc.file_url,
        "file_name": file_doc.file_name
    }
```

## CORS Configuration

### For API Endpoints
```python
@frappe.whitelist()
def cors_enabled_api():
    """API with CORS headers"""
    # Set CORS headers
    frappe.response.headers["Access-Control-Allow-Origin"] = "*"
    frappe.response.headers["Access-Control-Allow-Methods"] = "GET, POST"
    frappe.response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    
    return {"data": "CORS enabled response"}
```

## Best Practices Checklist

### ✅ Always Do:
1. Use `@frappe.whitelist()` for any client-accessible method
2. Check permissions with `frappe.has_permission()`
3. Validate all input parameters
4. Use parameterized queries for SQL
5. Parse JSON parameters with `frappe.parse_json()`
6. Handle errors gracefully
7. Log errors for debugging
8. Use rate limiting for expensive operations
9. Return consistent response formats
10. Document your APIs

### ❌ Never Do:
1. Expose methods without `@frappe.whitelist()`
2. Trust client input without validation
3. Use string concatenation for SQL queries
4. Return sensitive data without permission checks
5. Use `allow_guest=True` unless absolutely necessary
6. Ignore error handling
7. Return internal error messages to client
8. Allow unlimited file uploads
9. Skip permission checks for convenience
10. Use eval() or exec() with user input

## API Response Standards

### Success Response
```python
@frappe.whitelist()
def standard_api():
    """Standard API response format"""
    try:
        # Operation
        data = perform_operation()
        
        return {
            "success": True,
            "data": data,
            "message": _("Operation completed successfully")
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "message": _("Operation failed")
        }
```

### List Response with Pagination
```python
@frappe.whitelist()
def get_paginated_list(doctype, page=1, page_size=20):
    """Paginated list response"""
    page = frappe.utils.cint(page)
    page_size = frappe.utils.cint(page_size)
    
    start = (page - 1) * page_size
    
    data = frappe.get_all(
        doctype,
        fields=["*"],
        limit=page_size,
        start=start
    )
    
    total = frappe.db.count(doctype)
    
    return {
        "data": data,
        "pagination": {
            "total": total,
            "page": page,
            "page_size": page_size,
            "total_pages": (total + page_size - 1) // page_size
        }
    }
```

## Testing Whitelisted Methods

### Using Postman/cURL
```bash
# Login first
curl -X POST http://site.local:8000/api/method/login \
  -H "Content-Type: application/json" \
  -d '{"usr":"admin@example.com","pwd":"admin"}'

# Call whitelisted method
curl -X POST http://site.local:8000/api/method/app.module.method_name \
  -H "Content-Type: application/json" \
  -H "X-Frappe-CSRF-Token: <token>" \
  -d '{"param1":"value1","param2":"value2"}'
```

### Using frappe.call in JavaScript
```javascript
frappe.call({
    method: 'app.module.method_name',
    args: {
        param1: 'value1',
        param2: 'value2'
    },
    callback: function(response) {
        console.log(response.message);
    }
});
```

## Security Audit Checklist

- [ ] All client-accessible methods have `@frappe.whitelist()`
- [ ] Permission checks are in place
- [ ] Input validation is comprehensive
- [ ] SQL injection is prevented
- [ ] XSS vulnerabilities are addressed
- [ ] Rate limiting is implemented where needed
- [ ] Error messages don't expose sensitive info
- [ ] File uploads are validated
- [ ] CORS is properly configured
- [ ] API responses follow standard format