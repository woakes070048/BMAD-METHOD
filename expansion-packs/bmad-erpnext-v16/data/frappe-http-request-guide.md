# Frappe HTTP Request Guide
## Complete Guide to Using Frappe's Built-in HTTP Methods Instead of `requests` Library

**CRITICAL**: NEVER use `import requests` - Frappe provides all HTTP functionality built-in!

---

## 🚫 What NOT to Do

```python
# NEVER DO THIS - Anti-patterns
import requests  # ❌ BLOCKED
import urllib    # ❌ BLOCKED
import urllib3   # ❌ BLOCKED
import httplib   # ❌ BLOCKED

# WRONG WAY
response = requests.get('https://api.example.com/data')
response = requests.post('https://api.example.com/create', json=data)
```

---

## ✅ The Frappe Way - Complete Examples

### 1. GET Requests

```python
import frappe
from frappe import _

def fetch_external_data():
    """Fetch data from external API using Frappe's built-in methods"""
    
    try:
        # Simple GET request
        response = frappe.make_get_request(
            url="https://api.example.com/data"
        )
        
        # GET request with headers
        response = frappe.make_get_request(
            url="https://api.example.com/users",
            headers={
                "Authorization": "Bearer your-api-token",
                "Accept": "application/json"
            }
        )
        
        # GET request with query parameters
        # Build URL with parameters
        from frappe.utils import get_url
        params = {"page": 1, "limit": 100, "sort": "name"}
        query_string = "&".join([f"{k}={v}" for k, v in params.items()])
        url = f"https://api.example.com/data?{query_string}"
        
        response = frappe.make_get_request(url)
        
        # Response is automatically parsed if JSON
        return response
        
    except Exception as e:
        frappe.log_error(f"Failed to fetch data: {str(e)}", "External API Error")
        frappe.throw(_("Unable to fetch external data"))
```

### 2. POST Requests

```python
import frappe
import json

@frappe.whitelist()
def create_external_record(data):
    """Create record in external system using Frappe's POST method"""
    
    try:
        # POST with JSON data
        response = frappe.make_post_request(
            url="https://api.example.com/create",
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {get_api_key()}"
            },
            data={
                "name": data.get("name"),
                "email": data.get("email"),
                "status": "active"
            }
        )
        
        # POST with form data
        response = frappe.make_post_request(
            url="https://api.example.com/form-submit",
            headers={
                "Content-Type": "application/x-www-form-urlencoded"
            },
            data="name=John&email=john@example.com"  # URL encoded string
        )
        
        return {
            "success": True,
            "external_id": response.get("id"),
            "message": "Record created successfully"
        }
        
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "External API POST Error")
        return {
            "success": False,
            "message": str(e)
        }
```

### 3. PUT Requests

```python
import frappe

@frappe.whitelist()
def update_external_record(record_id, updates):
    """Update record in external system"""
    
    try:
        response = frappe.make_put_request(
            url=f"https://api.example.com/records/{record_id}",
            headers={
                "Content-Type": "application/json",
                "Authorization": f"Bearer {get_api_key()}"
            },
            data=updates
        )
        
        # Log successful update
        frappe.log_error(f"Updated record {record_id}", "API Update Success")
        
        return response
        
    except Exception as e:
        frappe.log_error(f"Failed to update {record_id}: {str(e)}", "API Update Error")
        frappe.throw(_("Update failed"))
```

### 4. DELETE Requests

```python
import frappe

@frappe.whitelist()
def delete_external_record(record_id):
    """Delete record from external system"""
    
    if not frappe.has_permission("Custom DocType", "delete"):
        frappe.throw(_("Insufficient permissions"))
    
    try:
        response = frappe.make_delete_request(
            url=f"https://api.example.com/records/{record_id}",
            headers={
                "Authorization": f"Bearer {get_api_key()}"
            }
        )
        
        return {"success": True, "message": "Record deleted"}
        
    except Exception as e:
        frappe.log_error(str(e), "API Delete Error")
        return {"success": False, "error": str(e)}
```

---

## 📊 Advanced Patterns

### 1. API Integration Class

```python
import frappe
from frappe import _
import json

class ExternalAPIClient:
    """Frappe-based API client for external service integration"""
    
    def __init__(self):
        self.base_url = frappe.conf.get("external_api_url", "https://api.example.com")
        self.api_key = self.get_api_key()
        self.headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json"
        }
    
    def get_api_key(self):
        """Get API key from site config or settings"""
        # Option 1: From site config
        api_key = frappe.conf.get("external_api_key")
        
        # Option 2: From Singles DocType
        if not api_key:
            settings = frappe.get_single("Integration Settings")
            api_key = settings.get_password("api_key")
        
        if not api_key:
            frappe.throw(_("API key not configured"))
        
        return api_key
    
    def get(self, endpoint, params=None):
        """Make GET request to API"""
        url = f"{self.base_url}/{endpoint}"
        
        if params:
            query = "&".join([f"{k}={v}" for k, v in params.items()])
            url = f"{url}?{query}"
        
        try:
            return frappe.make_get_request(url, headers=self.headers)
        except Exception as e:
            self._handle_error(e, "GET", endpoint)
    
    def post(self, endpoint, data):
        """Make POST request to API"""
        url = f"{self.base_url}/{endpoint}"
        
        try:
            return frappe.make_post_request(
                url=url,
                headers=self.headers,
                data=data
            )
        except Exception as e:
            self._handle_error(e, "POST", endpoint)
    
    def put(self, endpoint, data):
        """Make PUT request to API"""
        url = f"{self.base_url}/{endpoint}"
        
        try:
            return frappe.make_put_request(
                url=url,
                headers=self.headers,
                data=data
            )
        except Exception as e:
            self._handle_error(e, "PUT", endpoint)
    
    def delete(self, endpoint):
        """Make DELETE request to API"""
        url = f"{self.base_url}/{endpoint}"
        
        try:
            return frappe.make_delete_request(
                url=url,
                headers=self.headers
            )
        except Exception as e:
            self._handle_error(e, "DELETE", endpoint)
    
    def _handle_error(self, error, method, endpoint):
        """Centralized error handling"""
        error_msg = f"{method} {endpoint} failed: {str(error)}"
        frappe.log_error(error_msg, "External API Error")
        frappe.throw(_("External service error: {0}").format(str(error)))

# Usage
def sync_with_external_system():
    client = ExternalAPIClient()
    
    # Fetch data
    users = client.get("users", {"active": True})
    
    # Create record
    new_user = client.post("users", {
        "name": "John Doe",
        "email": "john@example.com"
    })
    
    # Update record
    client.put(f"users/{new_user['id']}", {"status": "verified"})
    
    # Delete record
    client.delete(f"users/{new_user['id']}")
```

### 2. Webhook Handler

```python
import frappe
import json

@frappe.whitelist(allow_guest=True)
def webhook_handler():
    """Handle incoming webhooks using Frappe's request object"""
    
    # Access current request data
    data = frappe.request.data
    headers = frappe.request.headers
    method = frappe.request.method
    
    # Verify webhook signature
    signature = headers.get("X-Webhook-Signature")
    if not verify_webhook_signature(data, signature):
        frappe.throw(_("Invalid webhook signature"), frappe.AuthenticationError)
    
    # Parse request data
    if isinstance(data, bytes):
        data = data.decode('utf-8')
    
    if headers.get("Content-Type") == "application/json":
        payload = json.loads(data)
    else:
        payload = frappe.parse_json(data)
    
    # Process webhook
    try:
        if payload.get("event") == "user.created":
            create_local_user(payload.get("user"))
        elif payload.get("event") == "order.completed":
            process_order_completion(payload.get("order"))
        
        # Send response back to webhook sender
        frappe.response.status_code = 200
        frappe.response.data = json.dumps({"status": "success"})
        
    except Exception as e:
        frappe.log_error(frappe.get_traceback(), "Webhook Processing Error")
        frappe.response.status_code = 500
        frappe.response.data = json.dumps({"status": "error", "message": str(e)})
```

### 3. Batch API Requests with Rate Limiting

```python
import frappe
from frappe.utils import now_datetime, add_to_date
import time

class RateLimitedAPIClient:
    """API client with built-in rate limiting"""
    
    def __init__(self, requests_per_minute=60):
        self.requests_per_minute = requests_per_minute
        self.request_interval = 60.0 / requests_per_minute
        self.last_request_time = 0
    
    def _rate_limit(self):
        """Enforce rate limiting between requests"""
        current_time = time.time()
        time_since_last = current_time - self.last_request_time
        
        if time_since_last < self.request_interval:
            time.sleep(self.request_interval - time_since_last)
        
        self.last_request_time = time.time()
    
    def make_request(self, url, method="GET", **kwargs):
        """Make rate-limited request"""
        self._rate_limit()
        
        if method == "GET":
            return frappe.make_get_request(url, **kwargs)
        elif method == "POST":
            return frappe.make_post_request(url, **kwargs)
        elif method == "PUT":
            return frappe.make_put_request(url, **kwargs)
        elif method == "DELETE":
            return frappe.make_delete_request(url, **kwargs)
    
    def batch_fetch(self, urls):
        """Fetch multiple URLs with rate limiting"""
        results = []
        
        for url in urls:
            try:
                result = self.make_request(url)
                results.append({"url": url, "data": result, "success": True})
            except Exception as e:
                frappe.log_error(f"Failed to fetch {url}: {str(e)}", "Batch Fetch Error")
                results.append({"url": url, "error": str(e), "success": False})
        
        return results

# Usage
def sync_multiple_endpoints():
    client = RateLimitedAPIClient(requests_per_minute=30)
    
    urls = [
        "https://api.example.com/users",
        "https://api.example.com/orders",
        "https://api.example.com/products"
    ]
    
    results = client.batch_fetch(urls)
    
    for result in results:
        if result["success"]:
            process_data(result["data"])
        else:
            handle_error(result["error"])
```

### 4. Caching API Responses

```python
import frappe
import json
from frappe.utils import now_datetime, add_to_date

def get_cached_api_data(endpoint, cache_duration_minutes=30):
    """Fetch API data with caching using Frappe's cache"""
    
    cache_key = f"api_cache_{endpoint}"
    
    # Try to get from cache
    cached_data = frappe.cache().get_value(cache_key)
    
    if cached_data:
        return json.loads(cached_data)
    
    # Fetch fresh data
    try:
        response = frappe.make_get_request(
            url=f"https://api.example.com/{endpoint}",
            headers={"Authorization": f"Bearer {get_api_key()}"}
        )
        
        # Cache the response
        frappe.cache().set_value(
            cache_key,
            json.dumps(response),
            expires_in_sec=cache_duration_minutes * 60
        )
        
        return response
        
    except Exception as e:
        frappe.log_error(f"API fetch failed for {endpoint}", "API Cache Error")
        
        # Return stale cache if available
        stale_cache = frappe.cache().get_value(f"{cache_key}_backup")
        if stale_cache:
            return json.loads(stale_cache)
        
        frappe.throw(_("Unable to fetch data"))
```

---

## 🔒 Security Best Practices

### 1. API Key Management

```python
def get_api_key():
    """Securely retrieve API key"""
    # NEVER hardcode API keys
    # Use site config or password fields
    
    # Option 1: Site config (site_config.json)
    api_key = frappe.conf.get("external_api_key")
    
    # Option 2: Password field in Singles DocType
    if not api_key:
        settings = frappe.get_single("API Settings")
        api_key = settings.get_password("api_key")
    
    # Option 3: From key management DocType
    if not api_key:
        key_doc = frappe.get_doc("API Keys", {"service": "external_api"})
        api_key = key_doc.get_password("key")
    
    return api_key
```

### 2. Request Validation

```python
@frappe.whitelist()
def make_external_request(url, method="GET"):
    """Validate and make external request"""
    
    # Validate URL against whitelist
    allowed_domains = frappe.get_single("Integration Settings").allowed_domains
    from urllib.parse import urlparse
    
    parsed = urlparse(url)
    if parsed.netloc not in allowed_domains:
        frappe.throw(_("Domain not whitelisted"))
    
    # Validate method
    if method not in ["GET", "POST", "PUT", "DELETE"]:
        frappe.throw(_("Invalid HTTP method"))
    
    # Make request with timeout
    if method == "GET":
        return frappe.make_get_request(url, timeout=30)
```

---

## 📋 Quick Reference

| Need | Don't Use | Use Instead |
|------|-----------|-------------|
| GET request | `requests.get()` | `frappe.make_get_request()` |
| POST request | `requests.post()` | `frappe.make_post_request()` |
| PUT request | `requests.put()` | `frappe.make_put_request()` |
| DELETE request | `requests.delete()` | `frappe.make_delete_request()` |
| Current request | `flask.request` | `frappe.request` |
| Response object | `flask.Response` | `frappe.response` |
| JSON parsing | `json.loads()` | Auto-parsed in Frappe methods |
| Error handling | `try/except` | Use with `frappe.log_error()` |

---

## ⚠️ Common Mistakes to Avoid

```python
# ❌ WRONG - Using requests library
import requests
response = requests.get(url)

# ✅ CORRECT - Using Frappe
response = frappe.make_get_request(url)

# ❌ WRONG - Manual JSON parsing
import json
data = json.dumps({"key": "value"})
requests.post(url, data=data)

# ✅ CORRECT - Frappe handles JSON
frappe.make_post_request(url, data={"key": "value"})

# ❌ WRONG - No error handling
response = frappe.make_get_request(url)

# ✅ CORRECT - Proper error handling
try:
    response = frappe.make_get_request(url)
except Exception as e:
    frappe.log_error(str(e), "API Error")
    frappe.throw(_("API request failed"))
```

---

*Remember: Frappe provides everything you need for HTTP requests. There's NO reason to use external libraries like `requests`!*