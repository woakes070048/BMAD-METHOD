# Task: Create API Module for ERPNext App

## Objective
Create a secure, well-structured API module following Frappe's whitelisting requirements and best practices.

## Prerequisites
- ERPNext app already created
- Python environment set up
- Understanding of Frappe permissions

## Step-by-Step Guide

### 1. Create API Directory Structure
```bash
cd apps/[app_name]/[app_name]
mkdir -p api
touch api/__init__.py
```

### 2. Create Base API Module
```bash
# Create main API modules
touch api/auth.py
touch api/doc.py
touch api/utils.py
touch api/views.py
```

### 3. Implement Authentication Module
```python
# api/auth.py
import frappe
from frappe import _
import json

@frappe.whitelist(allow_guest=True)
def login(usr, pwd):
    """
    Login endpoint with rate limiting
    """
    try:
        login_manager = frappe.auth.LoginManager()
        login_manager.authenticate(usr, pwd)
        login_manager.post_login()
        
        return {
            "success": True,
            "message": _("Login successful"),
            "user": frappe.session.user,
            "full_name": frappe.get_value("User", frappe.session.user, "full_name")
        }
    except frappe.AuthenticationError:
        frappe.clear_messages()
        return {
            "success": False,
            "message": _("Invalid login credentials")
        }

@frappe.whitelist()
def logout():
    """
    Logout current user
    """
    frappe.local.login_manager.logout()
    frappe.db.commit()
    return {"success": True, "message": _("Logged out successfully")}

@frappe.whitelist()
def get_logged_user():
    """
    Get current logged in user details
    """
    if frappe.session.user == "Guest":
        return {"success": False, "message": _("Not logged in")}
    
    user = frappe.get_doc("User", frappe.session.user)
    return {
        "success": True,
        "user": {
            "email": user.email,
            "full_name": user.full_name,
            "user_image": user.user_image,
            "roles": [r.role for r in user.roles]
        }
    }
```

### 4. Create Document API Module
```python
# api/doc.py
import frappe
from frappe import _
from frappe.utils import cint

@frappe.whitelist()
def get_list(doctype, fields=None, filters=None, order_by=None, limit=20, offset=0):
    """
    Generic list endpoint with pagination
    """
    # Check read permission
    if not frappe.has_permission(doctype, "read"):
        frappe.throw(_("No permission to read {0}").format(doctype))
    
    # Parse parameters
    if isinstance(fields, str):
        fields = frappe.parse_json(fields)
    if isinstance(filters, str):
        filters = frappe.parse_json(filters)
    
    # Default fields
    if not fields:
        fields = ["name", "modified", "owner"]
    
    # Get data with pagination
    data = frappe.get_all(
        doctype,
        fields=fields,
        filters=filters or {},
        order_by=order_by or "modified desc",
        limit=cint(limit),
        start=cint(offset)
    )
    
    # Get total count
    total = frappe.db.count(doctype, filters)
    
    return {
        "success": True,
        "data": data,
        "pagination": {
            "total": total,
            "limit": limit,
            "offset": offset,
            "has_next": (offset + limit) < total
        }
    }

@frappe.whitelist()
def get_document(doctype, name):
    """
    Get single document with permission check
    """
    if not frappe.has_permission(doctype, "read", doc=name):
        frappe.throw(_("No permission to read this document"))
    
    try:
        doc = frappe.get_doc(doctype, name)
        return {
            "success": True,
            "data": doc.as_dict()
        }
    except frappe.DoesNotExistError:
        return {
            "success": False,
            "message": _("{0} {1} not found").format(doctype, name)
        }

@frappe.whitelist()
def create_document(doctype, data):
    """
    Create new document
    """
    if not frappe.has_permission(doctype, "create"):
        frappe.throw(_("No permission to create {0}").format(doctype))
    
    try:
        doc_data = frappe.parse_json(data) if isinstance(data, str) else data
        doc = frappe.get_doc({
            "doctype": doctype,
            **doc_data
        })
        doc.insert()
        frappe.db.commit()
        
        return {
            "success": True,
            "data": doc.as_dict(),
            "message": _("{0} created successfully").format(doctype)
        }
    except Exception as e:
        frappe.db.rollback()
        return {
            "success": False,
            "message": str(e)
        }

@frappe.whitelist()
def update_document(doctype, name, data):
    """
    Update existing document
    """
    try:
        doc = frappe.get_doc(doctype, name)
        
        if not doc.has_permission("write"):
            frappe.throw(_("No permission to update this document"))
        
        update_data = frappe.parse_json(data) if isinstance(data, str) else data
        
        # Remove protected fields
        protected_fields = ["name", "creation", "modified", "modified_by", "owner"]
        for field in protected_fields:
            update_data.pop(field, None)
        
        doc.update(update_data)
        doc.save()
        frappe.db.commit()
        
        return {
            "success": True,
            "data": doc.as_dict(),
            "message": _("Document updated successfully")
        }
    except Exception as e:
        frappe.db.rollback()
        return {
            "success": False,
            "message": str(e)
        }

@frappe.whitelist()
def delete_document(doctype, name):
    """
    Delete document
    """
    if not frappe.has_permission(doctype, "delete", doc=name):
        frappe.throw(_("No permission to delete this document"))
    
    try:
        frappe.delete_doc(doctype, name)
        frappe.db.commit()
        
        return {
            "success": True,
            "message": _("Document deleted successfully")
        }
    except frappe.LinkExistsError:
        return {
            "success": False,
            "message": _("Cannot delete: document is linked with other documents")
        }
```

### 5. Create Utility Functions Module
```python
# api/utils.py
import frappe
from frappe import _
from frappe.utils import now_datetime, add_days
import hashlib

@frappe.whitelist()
def get_meta(doctype):
    """
    Get DocType metadata
    """
    if not frappe.has_permission(doctype, "read"):
        frappe.throw(_("No permission"))
    
    meta = frappe.get_meta(doctype)
    
    return {
        "success": True,
        "data": {
            "fields": [
                {
                    "fieldname": f.fieldname,
                    "fieldtype": f.fieldtype,
                    "label": f.label,
                    "reqd": f.reqd,
                    "hidden": f.hidden,
                    "options": f.options
                }
                for f in meta.fields
            ],
            "permissions": meta.permissions,
            "is_submittable": meta.is_submittable,
            "is_table": meta.istable
        }
    }

@frappe.whitelist()
def run_method(doctype, name, method, args=None):
    """
    Run document method
    """
    doc = frappe.get_doc(doctype, name)
    
    if not hasattr(doc, method):
        frappe.throw(_("Method {0} not found").format(method))
    
    # Check if method is whitelisted
    method_obj = getattr(doc, method)
    if not getattr(method_obj, "whitelisted", False):
        frappe.throw(_("Method not allowed"))
    
    if args:
        args = frappe.parse_json(args) if isinstance(args, str) else args
        result = method_obj(**args)
    else:
        result = method_obj()
    
    return {
        "success": True,
        "result": result
    }

@frappe.whitelist()
def get_list_settings(doctype):
    """
    Get list view settings
    """
    if not frappe.has_permission(doctype, "read"):
        frappe.throw(_("No permission"))
    
    meta = frappe.get_meta(doctype)
    
    return {
        "success": True,
        "data": {
            "default_sort": f"{meta.sort_field or 'modified'} {meta.sort_order or 'desc'}",
            "title_field": meta.title_field or "name",
            "image_field": meta.image_field,
            "fields": [f.fieldname for f in meta.fields if f.in_list_view]
        }
    }
```

### 6. Create Views Module
```python
# api/views.py
import frappe
from frappe import _

@frappe.whitelist()
def get_dashboard_data():
    """
    Get dashboard statistics
    """
    if frappe.session.user == "Guest":
        frappe.throw(_("Please login"))
    
    # Example dashboard data
    data = {
        "total_customers": frappe.db.count("Customer"),
        "total_items": frappe.db.count("Item"),
        "recent_documents": frappe.get_all(
            "ToDo",
            filters={"owner": frappe.session.user},
            fields=["name", "description", "status"],
            limit=5,
            order_by="modified desc"
        )
    }
    
    return {
        "success": True,
        "data": data
    }

@frappe.whitelist()
def get_sidebar_items():
    """
    Get sidebar menu items based on permissions
    """
    items = []
    
    # Check permissions and build menu
    doctypes = ["Customer", "Item", "Sales Order", "Purchase Order"]
    
    for dt in doctypes:
        if frappe.has_permission(dt, "read"):
            items.append({
                "label": _(dt),
                "doctype": dt,
                "route": f"/app/{dt.lower().replace(' ', '-')}"
            })
    
    return {
        "success": True,
        "items": items
    }
```

### 7. Update Main __init__.py
```python
# api/__init__.py
"""
API Module for [app_name]

All API methods must be whitelisted using @frappe.whitelist()
"""

from . import auth
from . import doc  
from . import utils
from . import views

__all__ = ["auth", "doc", "utils", "views"]
```

### 8. Add Rate Limiting (Optional)
```python
# api/decorators.py
import frappe
from frappe.rate_limiter import rate_limit
from functools import wraps

def api_response(func):
    """
    Decorator to standardize API responses
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            result = func(*args, **kwargs)
            if not isinstance(result, dict):
                result = {"data": result}
            if "success" not in result:
                result["success"] = True
            return result
        except frappe.PermissionError as e:
            return {
                "success": False,
                "error": "PermissionDenied",
                "message": str(e)
            }
        except Exception as e:
            frappe.log_error(frappe.get_traceback(), f"API Error: {func.__name__}")
            return {
                "success": False,
                "error": "ServerError",
                "message": _("An error occurred")
            }
    return wrapper

def require_auth(func):
    """
    Decorator to require authentication
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        if frappe.session.user == "Guest":
            return {
                "success": False,
                "error": "AuthRequired",
                "message": _("Authentication required")
            }
        return func(*args, **kwargs)
    return wrapper

# Usage example:
@frappe.whitelist()
@rate_limit(limit=100, seconds=60)
@api_response
@require_auth
def protected_endpoint():
    return {"data": "Protected data"}
```

### 9. Create Tests for API Module
```python
# tests/test_api.py
import frappe
import unittest
import json

class TestAPI(unittest.TestCase):
    
    def setUp(self):
        self.test_user = "test@example.com"
        frappe.set_user(self.test_user)
    
    def test_get_list(self):
        from app_name.api.doc import get_list
        result = get_list("ToDo", limit=10)
        
        self.assertTrue(result["success"])
        self.assertIn("data", result)
        self.assertIn("pagination", result)
    
    def test_permission_denied(self):
        frappe.set_user("Guest")
        from app_name.api.doc import get_list
        
        with self.assertRaises(frappe.PermissionError):
            get_list("User")
    
    def test_create_document(self):
        from app_name.api.doc import create_document
        
        data = {
            "description": "Test Todo"
        }
        
        result = create_document("ToDo", json.dumps(data))
        self.assertTrue(result["success"])
        
        # Cleanup
        if result["success"]:
            frappe.delete_doc("ToDo", result["data"]["name"])
    
    def tearDown(self):
        frappe.set_user("Administrator")
```

### 10. Configure API Routes in hooks.py
```python
# hooks.py additions
# Add API configuration
api_version = "v1"

# Whitelist methods for mobile apps
whitelist_methods = [
    "app_name.api.auth.login",
    "app_name.api.auth.logout",
    "app_name.api.auth.get_logged_user"
]

# Rate limiting configuration
rate_limit = {
    "api/*": [100, 60],  # 100 requests per 60 seconds
    "api/auth/login": [5, 60],  # 5 login attempts per minute
}
```

## Testing the API

### 1. Test with cURL
```bash
# Login
curl -X POST http://site.local:8000/api/method/app_name.api.auth.login \
  -H "Content-Type: application/json" \
  -d '{"usr": "user@example.com", "pwd": "password"}'

# Get list with session
curl -X POST http://site.local:8000/api/method/app_name.api.doc.get_list \
  -H "Content-Type: application/json" \
  -H "Cookie: sid=..." \
  -d '{"doctype": "Customer", "limit": 10}'
```

### 2. Test with JavaScript
```javascript
// Using frappe.call
frappe.call({
    method: 'app_name.api.doc.get_list',
    args: {
        doctype: 'Customer',
        fields: ['name', 'customer_name'],
        limit: 20
    },
    callback: function(response) {
        console.log(response.message);
    }
});
```

### 3. Test with Python
```python
# In bench console
frappe.get_doc({
    "doctype": "Test Script",
    "script": """
from app_name.api.doc import get_list
result = get_list("Customer", limit=5)
print(result)
"""
}).run()
```

## Security Best Practices

### 1. Always Use @frappe.whitelist()
```python
# CORRECT - Method is whitelisted
@frappe.whitelist()
def safe_method():
    return {"data": "safe"}

# WRONG - Method is not accessible via API
def unsafe_method():
    return {"data": "unsafe"}
```

### 2. Check Permissions
```python
@frappe.whitelist()
def secure_endpoint(doctype, name):
    # Always check permissions
    if not frappe.has_permission(doctype, "read", doc=name):
        frappe.throw(_("No permission"))
    
    # Proceed with operation
    return frappe.get_doc(doctype, name).as_dict()
```

### 3. Validate Input
```python
@frappe.whitelist()
def validate_input(email, age):
    # Validate email format
    if not frappe.utils.validate_email_address(email):
        frappe.throw(_("Invalid email"))
    
    # Validate data types
    age = cint(age)
    if age < 0 or age > 150:
        frappe.throw(_("Invalid age"))
    
    return {"success": True}
```

### 4. Sanitize Output
```python
@frappe.whitelist()
def get_safe_data(doctype, name):
    doc = frappe.get_doc(doctype, name)
    
    # Remove sensitive fields
    safe_dict = doc.as_dict()
    sensitive_fields = ["password", "api_key", "secret"]
    
    for field in sensitive_fields:
        safe_dict.pop(field, None)
    
    return {"data": safe_dict}
```

## Common Patterns

### 1. Pagination Pattern
```python
def paginated_response(doctype, page=1, page_size=20):
    offset = (page - 1) * page_size
    data = frappe.get_all(doctype, limit=page_size, start=offset)
    total = frappe.db.count(doctype)
    
    return {
        "data": data,
        "page": page,
        "page_size": page_size,
        "total_pages": (total + page_size - 1) // page_size,
        "total_items": total
    }
```

### 2. Search Pattern
```python
@frappe.whitelist()
def search(doctype, query, fields=None):
    if not frappe.has_permission(doctype, "read"):
        frappe.throw(_("No permission"))
    
    meta = frappe.get_meta(doctype)
    search_fields = meta.search_fields or "name"
    
    return frappe.get_all(
        doctype,
        filters={search_fields: ["like", f"%{query}%"]},
        fields=fields or ["name", search_fields]
    )
```

### 3. Bulk Operations Pattern
```python
@frappe.whitelist()
def bulk_update(doctype, names, updates):
    names = frappe.parse_json(names)
    updates = frappe.parse_json(updates)
    
    success = []
    failed = []
    
    for name in names:
        try:
            doc = frappe.get_doc(doctype, name)
            if doc.has_permission("write"):
                doc.update(updates)
                doc.save()
                success.append(name)
            else:
                failed.append({"name": name, "error": "No permission"})
        except Exception as e:
            failed.append({"name": name, "error": str(e)})
    
    frappe.db.commit()
    
    return {
        "success": success,
        "failed": failed
    }
```

## Troubleshooting

### Common Issues

1. **Method not whitelisted**
   - Ensure @frappe.whitelist() decorator is present
   - Check method is imported in __init__.py

2. **Permission denied**
   - Verify user has required permissions
   - Check Role Permission Manager settings

3. **CSRF token error**
   - Include X-Frappe-CSRF-Token header
   - Token available in window.csrf_token

4. **Rate limiting**
   - Implement exponential backoff
   - Cache frequently accessed data

5. **JSON parsing errors**
   - Use frappe.parse_json() for string inputs
   - Validate JSON structure before parsing

## Next Steps

1. Implement authentication flow
2. Add comprehensive error handling
3. Set up rate limiting
4. Create API documentation
5. Implement caching strategy
6. Add monitoring and logging
7. Write comprehensive tests
8. Set up CI/CD pipeline