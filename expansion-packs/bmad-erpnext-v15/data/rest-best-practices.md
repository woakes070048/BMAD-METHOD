# REST API Best Practices for Frappe/ERPNext

## Overview
This guide outlines best practices for designing and implementing RESTful APIs in Frappe/ERPNext applications, ensuring consistency, scalability, and developer-friendly interfaces.

## URL Design Principles

### Resource-Based URLs
```python
# Good: Resource-based URLs
GET    /api/resource/Customer          # Get all customers
GET    /api/resource/Customer/CUST-001 # Get specific customer
POST   /api/resource/Customer          # Create new customer
PUT    /api/resource/Customer/CUST-001 # Update customer
DELETE /api/resource/Customer/CUST-001 # Delete customer

# Bad: Action-based URLs
POST   /api/createCustomer
GET    /api/getCustomer/CUST-001
POST   /api/updateCustomer/CUST-001
```

### Hierarchical Resource Relationships
```python
# Parent-child relationships
GET /api/resource/Customer/CUST-001/contacts           # Customer's contacts
GET /api/resource/Customer/CUST-001/addresses          # Customer's addresses
GET /api/resource/Sales Order/SO-001/items             # Sales order items

# Frappe implementation
@frappe.whitelist()
def get_customer_contacts(customer_name):
    """Get all contacts for a customer"""
    return frappe.get_all('Contact', 
        filters={'customer': customer_name},
        fields=['name', 'email_id', 'phone', 'mobile_no']
    )
```

### Query Parameters for Filtering and Pagination
```python
# Filtering
GET /api/resource/Customer?customer_group=Commercial&territory=India

# Pagination
GET /api/resource/Customer?limit=20&offset=40

# Sorting
GET /api/resource/Customer?order_by=customer_name asc

# Field selection
GET /api/resource/Customer?fields=["name","customer_name","territory"]

# Combined
GET /api/resource/Customer?filters={"disabled":0}&fields=["name","customer_name"]&limit=50&order_by=creation desc
```

## HTTP Methods and Status Codes

### Proper HTTP Method Usage
```python
class CustomerAPI:
    """RESTful Customer API implementation"""
    
    @frappe.whitelist(methods=['GET'])
    def get(self, name=None):
        """GET: Retrieve customer(s)"""
        if name:
            # Get specific customer
            if not frappe.has_permission("Customer", "read", name):
                frappe.throw(_("No permission"), frappe.PermissionError)
            
            customer = frappe.get_doc("Customer", name)
            return {
                "data": customer.as_dict(),
                "status": "success"
            }
        else:
            # Get list of customers with filters
            filters = frappe.parse_json(frappe.form_dict.get('filters', '{}'))
            fields = frappe.parse_json(frappe.form_dict.get('fields', '[]'))
            limit = int(frappe.form_dict.get('limit', 20))
            offset = int(frappe.form_dict.get('offset', 0))
            order_by = frappe.form_dict.get('order_by', 'name')
            
            customers = frappe.get_all('Customer',
                filters=filters,
                fields=fields or ['name', 'customer_name', 'customer_group'],
                limit=limit,
                start=offset,
                order_by=order_by
            )
            
            total_count = frappe.db.count('Customer', filters)
            
            return {
                "data": customers,
                "total": total_count,
                "limit": limit,
                "offset": offset,
                "status": "success"
            }
    
    @frappe.whitelist(methods=['POST'])
    def post(self):
        """POST: Create new customer"""
        data = frappe.parse_json(frappe.form_dict.get('data', '{}'))
        
        # Validate required fields
        if not data.get('customer_name'):
            frappe.throw(_("Customer name is required"), frappe.ValidationError)
        
        try:
            customer = frappe.get_doc({
                "doctype": "Customer",
                **data
            })
            customer.insert()
            frappe.db.commit()
            
            return {
                "data": customer.as_dict(),
                "message": _("Customer created successfully"),
                "status": "success"
            }
            
        except frappe.DuplicateEntryError:
            frappe.throw(_("Customer already exists"), frappe.DuplicateEntryError)
    
    @frappe.whitelist(methods=['PUT'])
    def put(self, name):
        """PUT: Update existing customer (full update)"""
        data = frappe.parse_json(frappe.form_dict.get('data', '{}'))
        
        customer = frappe.get_doc("Customer", name)
        
        if not customer.has_permission("write"):
            frappe.throw(_("No permission to update"), frappe.PermissionError)
        
        # Update all provided fields
        customer.update(data)
        customer.save()
        frappe.db.commit()
        
        return {
            "data": customer.as_dict(),
            "message": _("Customer updated successfully"),
            "status": "success"
        }
    
    @frappe.whitelist(methods=['PATCH'])
    def patch(self, name):
        """PATCH: Partial update of customer"""
        data = frappe.parse_json(frappe.form_dict.get('data', '{}'))
        
        customer = frappe.get_doc("Customer", name)
        
        if not customer.has_permission("write"):
            frappe.throw(_("No permission to update"), frappe.PermissionError)
        
        # Update only provided fields
        for field, value in data.items():
            if hasattr(customer, field):
                setattr(customer, field, value)
        
        customer.save()
        frappe.db.commit()
        
        return {
            "data": customer.as_dict(),
            "message": _("Customer updated successfully"),
            "status": "success"
        }
    
    @frappe.whitelist(methods=['DELETE'])
    def delete(self, name):
        """DELETE: Remove customer"""
        if not frappe.has_permission("Customer", "delete", name):
            frappe.throw(_("No permission to delete"), frappe.PermissionError)
        
        try:
            frappe.delete_doc("Customer", name)
            frappe.db.commit()
            
            return {
                "message": _("Customer deleted successfully"),
                "status": "success"
            }
            
        except frappe.LinkExistsError:
            frappe.throw(_("Cannot delete customer with linked documents"), 
                       frappe.LinkExistsError)
```

### HTTP Status Codes
```python
class APIResponse:
    """Standardized API response handling"""
    
    @staticmethod
    def success(data=None, message="Success", status_code=200):
        """200 OK - Successful GET, PUT, PATCH"""
        frappe.local.response.http_status_code = status_code
        return {
            "success": True,
            "data": data,
            "message": message,
            "timestamp": frappe.utils.now(),
            "status_code": status_code
        }
    
    @staticmethod
    def created(data=None, message="Created", location=None):
        """201 Created - Successful POST"""
        frappe.local.response.http_status_code = 201
        if location:
            frappe.local.response.headers['Location'] = location
        
        return {
            "success": True,
            "data": data,
            "message": message,
            "timestamp": frappe.utils.now(),
            "status_code": 201
        }
    
    @staticmethod
    def no_content(message="No Content"):
        """204 No Content - Successful DELETE"""
        frappe.local.response.http_status_code = 204
        return {
            "success": True,
            "message": message,
            "timestamp": frappe.utils.now(),
            "status_code": 204
        }
    
    @staticmethod
    def bad_request(message="Bad Request", errors=None):
        """400 Bad Request - Invalid request"""
        frappe.local.response.http_status_code = 400
        return {
            "success": False,
            "error": {
                "message": message,
                "errors": errors or [],
                "type": "ValidationError"
            },
            "timestamp": frappe.utils.now(),
            "status_code": 400
        }
    
    @staticmethod
    def unauthorized(message="Unauthorized"):
        """401 Unauthorized - Authentication required"""
        frappe.local.response.http_status_code = 401
        return {
            "success": False,
            "error": {
                "message": message,
                "type": "AuthenticationError"
            },
            "timestamp": frappe.utils.now(),
            "status_code": 401
        }
    
    @staticmethod
    def forbidden(message="Forbidden"):
        """403 Forbidden - Permission denied"""
        frappe.local.response.http_status_code = 403
        return {
            "success": False,
            "error": {
                "message": message,
                "type": "PermissionError"
            },
            "timestamp": frappe.utils.now(),
            "status_code": 403
        }
    
    @staticmethod
    def not_found(message="Resource not found"):
        """404 Not Found - Resource doesn't exist"""
        frappe.local.response.http_status_code = 404
        return {
            "success": False,
            "error": {
                "message": message,
                "type": "NotFoundError"
            },
            "timestamp": frappe.utils.now(),
            "status_code": 404
        }
    
    @staticmethod
    def conflict(message="Conflict"):
        """409 Conflict - Resource conflict"""
        frappe.local.response.http_status_code = 409
        return {
            "success": False,
            "error": {
                "message": message,
                "type": "ConflictError"
            },
            "timestamp": frappe.utils.now(),
            "status_code": 409
        }
    
    @staticmethod
    def rate_limited(message="Rate limit exceeded", retry_after=None):
        """429 Too Many Requests - Rate limit exceeded"""
        frappe.local.response.http_status_code = 429
        if retry_after:
            frappe.local.response.headers['Retry-After'] = str(retry_after)
        
        return {
            "success": False,
            "error": {
                "message": message,
                "type": "RateLimitError",
                "retry_after": retry_after
            },
            "timestamp": frappe.utils.now(),
            "status_code": 429
        }
    
    @staticmethod
    def server_error(message="Internal server error"):
        """500 Internal Server Error"""
        frappe.local.response.http_status_code = 500
        return {
            "success": False,
            "error": {
                "message": message,
                "type": "ServerError"
            },
            "timestamp": frappe.utils.now(),
            "status_code": 500
        }
```

## Request and Response Format

### Consistent Request Format
```python
# POST/PUT/PATCH request body format
{
    "data": {
        "customer_name": "Test Customer",
        "customer_group": "Commercial",
        "territory": "India"
    }
}

# Query parameters for GET requests
GET /api/resource/Customer?filters={"disabled":0}&fields=["name","customer_name"]&limit=20&offset=0&order_by="customer_name asc"
```

### Consistent Response Format
```python
class StandardAPIResponse:
    """Standard API response format"""
    
    @staticmethod
    def format_response(data=None, message="", success=True, meta=None):
        """Format consistent API response"""
        response = {
            "success": success,
            "timestamp": frappe.utils.now(),
            "request_id": frappe.local.request_id if hasattr(frappe.local, 'request_id') else None
        }
        
        if success:
            response["data"] = data
            if message:
                response["message"] = message
            if meta:
                response["meta"] = meta
        else:
            response["error"] = {
                "message": message,
                "type": type(data).__name__ if isinstance(data, Exception) else "Error"
            }
        
        return response

# Success response examples
{
    "success": true,
    "data": {
        "name": "CUST-001",
        "customer_name": "Test Customer",
        "customer_group": "Commercial"
    },
    "message": "Customer retrieved successfully",
    "timestamp": "2023-01-01 12:00:00.000000",
    "request_id": "req_12345"
}

# List response with pagination
{
    "success": true,
    "data": [
        {"name": "CUST-001", "customer_name": "Customer 1"},
        {"name": "CUST-002", "customer_name": "Customer 2"}
    ],
    "meta": {
        "total": 150,
        "limit": 20,
        "offset": 0,
        "has_more": true
    },
    "timestamp": "2023-01-01 12:00:00.000000"
}

# Error response
{
    "success": false,
    "error": {
        "message": "Customer name is required",
        "type": "ValidationError",
        "details": {
            "field": "customer_name",
            "code": "REQUIRED_FIELD"
        }
    },
    "timestamp": "2023-01-01 12:00:00.000000",
    "request_id": "req_12345"
}
```

## Pagination Best Practices

### Offset-Based Pagination
```python
@frappe.whitelist()
def get_paginated_data(doctype, page=1, page_size=20, filters=None, fields=None, order_by=None):
    """Standard pagination implementation"""
    
    # Validate parameters
    page = max(1, int(page))
    page_size = min(100, max(1, int(page_size)))  # Limit page size
    offset = (page - 1) * page_size
    
    # Parse filters and fields
    filters = frappe.parse_json(filters) if filters else {}
    fields = frappe.parse_json(fields) if fields else []
    
    # Get total count
    total = frappe.db.count(doctype, filters)
    
    # Get data
    data = frappe.get_all(doctype,
        filters=filters,
        fields=fields,
        limit=page_size,
        start=offset,
        order_by=order_by or 'creation desc'
    )
    
    # Calculate pagination metadata
    total_pages = (total + page_size - 1) // page_size  # Ceiling division
    has_next = page < total_pages
    has_prev = page > 1
    
    return {
        "data": data,
        "pagination": {
            "page": page,
            "page_size": page_size,
            "total": total,
            "total_pages": total_pages,
            "has_next": has_next,
            "has_prev": has_prev
        }
    }
```

### Cursor-Based Pagination
```python
@frappe.whitelist()
def get_cursor_paginated_data(doctype, cursor=None, limit=20, filters=None, order_by="creation"):
    """Cursor-based pagination for better performance on large datasets"""
    
    limit = min(100, max(1, int(limit)))
    filters = frappe.parse_json(filters) if filters else {}
    
    # Add cursor condition
    if cursor:
        if 'desc' in order_by.lower():
            filters[order_by.split()[0]] = ['<', cursor]
        else:
            filters[order_by.split()[0]] = ['>', cursor]
    
    # Get data with one extra record to determine if there's more
    data = frappe.get_all(doctype,
        filters=filters,
        limit=limit + 1,
        order_by=order_by
    )
    
    has_more = len(data) > limit
    if has_more:
        data = data[:-1]  # Remove the extra record
    
    # Get next cursor
    next_cursor = None
    if has_more and data:
        cursor_field = order_by.split()[0]
        next_cursor = data[-1].get(cursor_field)
    
    return {
        "data": data,
        "pagination": {
            "cursor": cursor,
            "next_cursor": next_cursor,
            "has_more": has_more,
            "limit": limit
        }
    }
```

## Error Handling

### Comprehensive Error Handling
```python
class APIErrorHandler:
    """Centralized API error handling"""
    
    @staticmethod
    def handle_api_error(func):
        """Decorator for consistent error handling"""
        from functools import wraps
        
        @wraps(func)
        def wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
                
            except frappe.ValidationError as e:
                return APIResponse.bad_request(str(e))
            
            except frappe.PermissionError as e:
                return APIResponse.forbidden(str(e))
            
            except frappe.AuthenticationError as e:
                return APIResponse.unauthorized(str(e))
            
            except frappe.DoesNotExistError as e:
                return APIResponse.not_found(str(e))
            
            except frappe.DuplicateEntryError as e:
                return APIResponse.conflict(str(e))
            
            except frappe.LinkExistsError as e:
                return APIResponse.bad_request(str(e))
            
            except Exception as e:
                # Log unexpected errors
                frappe.log_error(
                    message=f"API Error in {func.__name__}: {str(e)}",
                    title="API Error"
                )
                return APIResponse.server_error("An unexpected error occurred")
        
        return wrapper

# Usage example
@frappe.whitelist()
@APIErrorHandler.handle_api_error
def create_customer(data):
    """Create customer with proper error handling"""
    customer = frappe.get_doc({
        "doctype": "Customer",
        **frappe.parse_json(data)
    })
    customer.insert()
    return APIResponse.created(customer.as_dict())
```

## Versioning Strategies

### URL Versioning
```python
# Version in URL path
GET /api/v1/resource/Customer
GET /api/v2/resource/Customer

# Implementation
@frappe.whitelist()
def get_customer_v1(name):
    """Version 1 of customer API"""
    customer = frappe.get_doc("Customer", name)
    return {
        "name": customer.name,
        "customer_name": customer.customer_name,
        "customer_group": customer.customer_group
    }

@frappe.whitelist()
def get_customer_v2(name):
    """Version 2 with additional fields"""
    customer = frappe.get_doc("Customer", name)
    return {
        "id": customer.name,
        "name": customer.customer_name,
        "group": customer.customer_group,
        "territory": customer.territory,
        "created_at": customer.creation,
        "updated_at": customer.modified
    }
```

### Header Versioning
```python
@frappe.whitelist()
def get_customer(name):
    """Version-aware customer API"""
    version = frappe.get_request_header('API-Version') or 'v1'
    
    customer = frappe.get_doc("Customer", name)
    
    if version == 'v1':
        return {
            "name": customer.name,
            "customer_name": customer.customer_name
        }
    elif version == 'v2':
        return {
            "id": customer.name,
            "name": customer.customer_name,
            "group": customer.customer_group,
            "territory": customer.territory
        }
    else:
        frappe.throw(_("Unsupported API version"), frappe.ValidationError)
```

## Caching Strategies

### Response Caching
```python
import hashlib
import json

class APICache:
    """API response caching"""
    
    @staticmethod
    def cache_response(ttl=300):  # 5 minutes default
        """Decorator for caching API responses"""
        def decorator(func):
            @wraps(func)
            def wrapper(*args, **kwargs):
                # Generate cache key
                cache_key = APICache._generate_cache_key(func.__name__, args, kwargs)
                
                # Try to get from cache
                cached_response = frappe.cache().get(cache_key)
                if cached_response:
                    return cached_response
                
                # Execute function and cache result
                result = func(*args, **kwargs)
                frappe.cache().set(cache_key, result, ttl=ttl)
                
                # Add cache headers
                frappe.local.response.headers['Cache-Control'] = f'max-age={ttl}'
                frappe.local.response.headers['X-Cache'] = 'MISS'
                
                return result
            return wrapper
        return decorator
    
    @staticmethod
    def _generate_cache_key(func_name, args, kwargs):
        """Generate cache key from function parameters"""
        key_data = {
            'function': func_name,
            'args': args,
            'kwargs': kwargs,
            'user': frappe.session.user
        }
        
        key_string = json.dumps(key_data, sort_keys=True, default=str)
        return f"api_cache:{hashlib.md5(key_string.encode()).hexdigest()}"

# Usage
@frappe.whitelist()
@APICache.cache_response(ttl=600)  # Cache for 10 minutes
def get_customer_list(filters=None):
    """Cached customer list API"""
    return frappe.get_all('Customer', filters=frappe.parse_json(filters or '{}'))
```

## Documentation Standards

### OpenAPI/Swagger Documentation
```python
# API documentation using docstrings
@frappe.whitelist()
def create_customer():
    """
    Create a new customer
    
    ---
    tags:
      - Customer
    parameters:
      - in: body
        name: data
        required: true
        schema:
          type: object
          properties:
            customer_name:
              type: string
              description: Customer name
              example: "John Doe"
            customer_group:
              type: string
              description: Customer group
              example: "Commercial"
            territory:
              type: string
              description: Territory
              example: "India"
    responses:
      201:
        description: Customer created successfully
        schema:
          type: object
          properties:
            success:
              type: boolean
            data:
              $ref: '#/definitions/Customer'
            message:
              type: string
      400:
        description: Bad request
        schema:
          $ref: '#/definitions/Error'
    """
    pass
```

## Performance Optimization

### Database Query Optimization
```python
@frappe.whitelist()
def get_optimized_customer_data(filters=None, fields=None):
    """Optimized customer data retrieval"""
    
    # Use specific fields instead of getting all
    fields = fields or ['name', 'customer_name', 'customer_group', 'territory']
    
    # Use frappe.get_all instead of frappe.get_doc for lists
    customers = frappe.get_all('Customer',
        filters=filters or {},
        fields=fields,
        limit=100  # Always limit results
    )
    
    # Batch load related data instead of individual queries
    customer_names = [c['name'] for c in customers]
    
    # Get related data in batch
    contacts = frappe.get_all('Contact',
        filters={'customer': ['in', customer_names]},
        fields=['customer', 'email_id', 'phone']
    )
    
    # Group contacts by customer
    customer_contacts = {}
    for contact in contacts:
        if contact.customer not in customer_contacts:
            customer_contacts[contact.customer] = []
        customer_contacts[contact.customer].append(contact)
    
    # Attach contacts to customers
    for customer in customers:
        customer['contacts'] = customer_contacts.get(customer['name'], [])
    
    return customers
```

## Best Practices Summary

1. **Resource-Based URLs**: Use nouns for resources, not verbs for actions
2. **HTTP Methods**: Use appropriate HTTP methods (GET, POST, PUT, PATCH, DELETE)
3. **Status Codes**: Return meaningful HTTP status codes
4. **Consistent Format**: Maintain consistent request/response formats
5. **Error Handling**: Provide clear, consistent error messages
6. **Pagination**: Implement efficient pagination for large datasets
7. **Versioning**: Plan for API versioning from the start
8. **Caching**: Implement appropriate caching strategies
9. **Documentation**: Document APIs thoroughly with examples
10. **Performance**: Optimize database queries and response times
11. **Security**: Implement proper authentication and authorization
12. **Rate Limiting**: Protect APIs from abuse with rate limiting