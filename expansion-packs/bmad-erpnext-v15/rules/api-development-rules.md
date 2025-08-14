# API Development Rules for ERPNext/Frappe

## Core API Principles

### 1. Always Use @frappe.whitelist()
```python
# MANDATORY - Without this, your API won't be accessible
@frappe.whitelist()
def your_api_method():
    pass

# For class methods
@frappe.whitelist()
def get_data(doctype, name):
    doc = frappe.get_doc(doctype, name)
    return doc.as_dict()
```

### 2. Permission Checking
```python
@frappe.whitelist()
def create_customer(customer_name, email):
    # ALWAYS check permissions first
    if not frappe.has_permission("Customer", "create"):
        frappe.throw(_("Insufficient permissions to create Customer"))
    
    # For document-specific permissions
    if not frappe.has_permission("Customer", "write", doc="CUST-0001"):
        frappe.throw(_("Cannot modify this customer"))
```

### 3. Input Validation
```python
@frappe.whitelist()
def process_data(data, doctype=None, filters=None):
    # Parse JSON inputs
    if isinstance(data, str):
        data = frappe.parse_json(data)
    
    if isinstance(filters, str):
        filters = frappe.parse_json(filters)
    
    # Validate required parameters
    if not data:
        frappe.throw(_("Data is required"))
    
    # Sanitize inputs
    doctype = frappe.scrub(doctype)  # Converts to snake_case
    
    # Validate against allowed values
    allowed_doctypes = ["Customer", "Supplier", "Item"]
    if doctype not in allowed_doctypes:
        frappe.throw(_("Invalid DocType"))
```

## API Response Patterns

### 1. Standard Success Response
```python
@frappe.whitelist()
def get_dashboard_data():
    try:
        data = {
            "total_customers": get_customer_count(),
            "total_orders": get_order_count(),
            "revenue": get_total_revenue()
        }
        
        # Return data directly - frappe handles JSON serialization
        return data
        
    except Exception as e:
        frappe.log_error(f"Dashboard API Error: {str(e)}")
        frappe.throw(_("Failed to load dashboard data"))
```

### 2. List/Search APIs
```python
@frappe.whitelist()
def search_items(query, filters=None, page_length=20, start=0):
    # Parse filters
    if filters:
        filters = frappe.parse_json(filters)
    else:
        filters = {}
    
    # Add search condition
    if query:
        filters["item_name"] = ["like", f"%{query}%"]
    
    # Get data with pagination
    items = frappe.get_all(
        "Item",
        filters=filters,
        fields=["name", "item_name", "item_group", "stock_uom"],
        order_by="modified desc",
        limit_start=start,
        limit_page_length=page_length
    )
    
    # Get total count for pagination
    total_count = frappe.db.count("Item", filters=filters)
    
    return {
        "items": items,
        "total_count": total_count,
        "has_more": (start + page_length) < total_count
    }
```

### 3. CRUD Operations
```python
# CREATE
@frappe.whitelist()
def create_record(doctype, data):
    if not frappe.has_permission(doctype, "create"):
        frappe.throw(_("Insufficient permissions"))
    
    data = frappe.parse_json(data)
    doc = frappe.get_doc({
        "doctype": doctype,
        **data
    })
    doc.insert(ignore_permissions=False)
    frappe.db.commit()
    
    return doc.as_dict()

# READ
@frappe.whitelist()
def get_record(doctype, name):
    if not frappe.has_permission(doctype, "read", doc=name):
        frappe.throw(_("Insufficient permissions"))
    
    doc = frappe.get_doc(doctype, name)
    return doc.as_dict()

# UPDATE
@frappe.whitelist()
def update_record(doctype, name, data):
    if not frappe.has_permission(doctype, "write", doc=name):
        frappe.throw(_("Insufficient permissions"))
    
    data = frappe.parse_json(data)
    doc = frappe.get_doc(doctype, name)
    doc.update(data)
    doc.save(ignore_permissions=False)
    frappe.db.commit()
    
    return doc.as_dict()

# DELETE
@frappe.whitelist()
def delete_record(doctype, name):
    if not frappe.has_permission(doctype, "delete", doc=name):
        frappe.throw(_("Insufficient permissions"))
    
    frappe.delete_doc(doctype, name, ignore_permissions=False)
    frappe.db.commit()
    
    return {"message": "Deleted successfully"}
```

## Error Handling

### 1. Comprehensive Error Handling
```python
@frappe.whitelist()
def complex_operation(params):
    try:
        params = frappe.parse_json(params)
        
        # Validate input
        if not params.get("required_field"):
            frappe.throw(_("Required field is missing"))
        
        # Database transaction
        frappe.db.begin()
        try:
            # Multiple operations
            result1 = operation_1(params)
            result2 = operation_2(result1)
            
            # Commit if all successful
            frappe.db.commit()
            
            return {
                "success": True,
                "data": result2
            }
            
        except Exception as e:
            # Rollback on any error
            frappe.db.rollback()
            raise
            
    except frappe.ValidationError as e:
        # User-friendly validation errors
        frappe.log_error(f"Validation Error: {str(e)}")
        frappe.throw(str(e))
        
    except Exception as e:
        # Log unexpected errors
        frappe.log_error(f"Unexpected Error in complex_operation: {str(e)}")
        frappe.throw(_("An unexpected error occurred. Please try again."))
```

### 2. Logging Best Practices
```python
@frappe.whitelist()
def process_webhook(payload):
    # Log incoming webhook for debugging
    frappe.log_error(
        title="Webhook Received",
        message=f"Payload: {payload}"
    )
    
    try:
        # Process webhook
        result = process_payload(payload)
        
        # Log success
        frappe.log_error(
            title="Webhook Processed",
            message=f"Result: {result}",
            reference_doctype="Webhook Log",
            reference_name=result.get("id")
        )
        
        return result
        
    except Exception as e:
        # Log failure with full traceback
        frappe.log_error(
            title="Webhook Processing Failed",
            message=frappe.get_traceback()
        )
        frappe.throw(_("Webhook processing failed"))
```

## Database Operations

### 1. Safe Database Queries
```python
@frappe.whitelist()
def get_customer_orders(customer_id, status=None):
    # Use parameterized queries to prevent SQL injection
    filters = {"customer": customer_id}
    if status:
        filters["status"] = status
    
    # Using frappe.get_all (recommended)
    orders = frappe.get_all(
        "Sales Order",
        filters=filters,
        fields=["name", "transaction_date", "grand_total", "status"],
        order_by="transaction_date desc"
    )
    
    # Using frappe.db.sql (when needed for complex queries)
    # ALWAYS use %s placeholders, never string formatting
    query = """
        SELECT 
            so.name, 
            so.transaction_date, 
            so.grand_total,
            COUNT(soi.name) as item_count
        FROM `tabSales Order` so
        LEFT JOIN `tabSales Order Item` soi ON soi.parent = so.name
        WHERE so.customer = %s
        AND so.docstatus = 1
        GROUP BY so.name
        ORDER BY so.transaction_date DESC
    """
    
    complex_orders = frappe.db.sql(query, customer_id, as_dict=True)
    
    return orders
```

### 2. Batch Operations
```python
@frappe.whitelist()
def bulk_update_items(items):
    items = frappe.parse_json(items)
    
    # Use single transaction for batch operations
    frappe.db.begin()
    try:
        updated_items = []
        
        for item_data in items:
            # Validate each item
            if not frappe.db.exists("Item", item_data.get("name")):
                frappe.throw(_("Item {0} does not exist").format(item_data.get("name")))
            
            # Update item
            doc = frappe.get_doc("Item", item_data.get("name"))
            doc.update(item_data)
            doc.save(ignore_permissions=False)
            updated_items.append(doc.name)
        
        # Commit all changes together
        frappe.db.commit()
        
        return {
            "updated": updated_items,
            "count": len(updated_items)
        }
        
    except Exception as e:
        frappe.db.rollback()
        frappe.log_error(f"Bulk update failed: {str(e)}")
        frappe.throw(_("Bulk update failed. No items were updated."))
```

## Authentication & Security

### 1. API Key Authentication
```python
@frappe.whitelist(allow_guest=True)
def api_with_key_auth():
    # Get API key from headers
    api_key = frappe.get_request_header("X-API-Key")
    api_secret = frappe.get_request_header("X-API-Secret")
    
    if not api_key or not api_secret:
        frappe.throw(_("API credentials required"), frappe.AuthenticationError)
    
    # Validate API key
    user = validate_api_credentials(api_key, api_secret)
    if not user:
        frappe.throw(_("Invalid API credentials"), frappe.AuthenticationError)
    
    # Set user context
    frappe.set_user(user)
    
    # Now proceed with normal permission checks
    return get_protected_data()
```

### 2. Rate Limiting
```python
@frappe.whitelist()
def rate_limited_api():
    # Simple rate limiting
    key = f"rate_limit_{frappe.session.user}_{frappe.request.path}"
    
    # Check rate limit (e.g., 100 requests per hour)
    count = frappe.cache().get(key) or 0
    if count >= 100:
        frappe.throw(_("Rate limit exceeded. Please try again later."), frappe.RateLimitExceededError)
    
    # Increment counter
    frappe.cache().set(key, count + 1, expires_in_sec=3600)
    
    # Process request
    return process_request()
```

## File Handling

### 1. File Upload API
```python
@frappe.whitelist()
def upload_file():
    # Get uploaded file
    files = frappe.request.files
    if not files:
        frappe.throw(_("No file uploaded"))
    
    file = files.get("file")
    
    # Validate file type
    allowed_types = [".jpg", ".jpeg", ".png", ".pdf"]
    file_ext = os.path.splitext(file.filename)[1].lower()
    if file_ext not in allowed_types:
        frappe.throw(_("File type not allowed"))
    
    # Validate file size (e.g., max 5MB)
    file.seek(0, os.SEEK_END)
    file_size = file.tell()
    file.seek(0)
    
    if file_size > 5 * 1024 * 1024:
        frappe.throw(_("File size exceeds 5MB limit"))
    
    # Save file
    file_doc = frappe.get_doc({
        "doctype": "File",
        "file_name": file.filename,
        "attached_to_doctype": "Customer",
        "attached_to_name": frappe.form_dict.customer,
        "content": file.read(),
        "is_private": 1
    })
    file_doc.save(ignore_permissions=False)
    
    return {
        "file_url": file_doc.file_url,
        "file_name": file_doc.file_name
    }
```

## Performance Optimization

### 1. Caching
```python
@frappe.whitelist()
def get_expensive_data(param):
    # Use caching for expensive operations
    cache_key = f"expensive_data_{param}"
    
    # Try to get from cache
    cached_data = frappe.cache().get(cache_key)
    if cached_data:
        return cached_data
    
    # Compute expensive data
    data = compute_expensive_operation(param)
    
    # Cache for 1 hour
    frappe.cache().set(cache_key, data, expires_in_sec=3600)
    
    return data
```

### 2. Pagination
```python
@frappe.whitelist()
def get_large_dataset(page=1, page_size=20):
    page = int(page)
    page_size = int(page_size)
    
    # Limit page size to prevent abuse
    page_size = min(page_size, 100)
    
    start = (page - 1) * page_size
    
    # Get paginated data
    data = frappe.get_all(
        "Large DocType",
        fields=["name", "title", "status"],
        order_by="creation desc",
        limit_start=start,
        limit_page_length=page_size
    )
    
    # Get total for pagination info
    total = frappe.db.count("Large DocType")
    
    return {
        "data": data,
        "pagination": {
            "page": page,
            "page_size": page_size,
            "total": total,
            "total_pages": math.ceil(total / page_size),
            "has_next": (page * page_size) < total,
            "has_previous": page > 1
        }
    }
```

## Testing Your APIs

### 1. Unit Testing
```python
# In test_api.py
import frappe
import unittest

class TestAPI(unittest.TestCase):
    def setUp(self):
        # Login as test user
        frappe.set_user("test@example.com")
    
    def test_create_customer_api(self):
        # Test successful creation
        response = create_customer(
            customer_name="Test Customer",
            email="test@customer.com"
        )
        
        self.assertTrue(response.get("name"))
        self.assertEqual(response.get("customer_name"), "Test Customer")
        
        # Cleanup
        frappe.delete_doc("Customer", response.get("name"))
    
    def test_permission_denied(self):
        # Test with user without permissions
        frappe.set_user("limited@example.com")
        
        with self.assertRaises(frappe.PermissionError):
            create_customer(
                customer_name="Test Customer",
                email="test@customer.com"
            )
```

### 2. Manual Testing
```bash
# Test with curl
curl -X POST http://site.local:8000/api/method/app.api.create_customer \
  -H "Content-Type: application/json" \
  -H "X-Frappe-CSRF-Token: ${CSRF_TOKEN}" \
  -d '{"customer_name": "Test", "email": "test@example.com"}'

# Test with bench console
bench --site site.local console
>>> from app.api import create_customer
>>> result = create_customer("Test Customer", "test@example.com")
>>> print(result)
```

## Common Pitfalls

### 1. Forgetting @frappe.whitelist()
```python
# WRONG - API won't be accessible
def my_api():
    return data

# RIGHT
@frappe.whitelist()
def my_api():
    return data
```

### 2. Not Handling JSON Inputs
```python
# WRONG - Will fail if frontend sends JSON string
@frappe.whitelist()
def process(data):
    for item in data:  # TypeError if data is string
        process_item(item)

# RIGHT
@frappe.whitelist()
def process(data):
    if isinstance(data, str):
        data = frappe.parse_json(data)
    for item in data:
        process_item(item)
```

### 3. Missing Permission Checks
```python
# WRONG - Security vulnerability
@frappe.whitelist()
def get_sensitive_data(doctype, name):
    doc = frappe.get_doc(doctype, name)
    return doc.as_dict()

# RIGHT
@frappe.whitelist()
def get_sensitive_data(doctype, name):
    if not frappe.has_permission(doctype, "read", doc=name):
        frappe.throw(_("Insufficient permissions"))
    doc = frappe.get_doc(doctype, name)
    return doc.as_dict()
```

## Remember

1. **Always whitelist**: No @frappe.whitelist() = No API access
2. **Check permissions**: Never trust the client
3. **Validate inputs**: Parse JSON, check types, sanitize data
4. **Handle errors**: Graceful error messages, proper logging
5. **Use transactions**: Commit/rollback for data integrity
6. **Test thoroughly**: Both success and failure cases