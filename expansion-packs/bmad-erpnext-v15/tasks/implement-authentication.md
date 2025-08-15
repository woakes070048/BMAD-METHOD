# implement-authentication

## Task Description
Implement secure authentication mechanisms for Frappe/ERPNext API endpoints and applications.

## Parameters
- `auth_type`: token, oauth2, session, or custom
- `endpoints`: List of endpoints requiring authentication
- `roles`: Required roles for access
- `security_level`: basic, standard, or enhanced (default: standard)

## Prerequisites
- API endpoints identified
- Security requirements documented
- Role-based access control defined

## Steps

### 1. Choose Authentication Method

#### Token Authentication (API Key/Secret)
```python
# Generate API key and secret
import frappe
from frappe.utils import random_string

def generate_api_credentials(user):
    """Generate API key and secret for user"""
    api_key = random_string(15)
    api_secret = random_string(15)
    
    # Save to user document
    user_doc = frappe.get_doc("User", user)
    user_doc.api_key = api_key
    user_doc.api_secret = api_secret
    user_doc.save()
    
    return api_key, api_secret
```

#### OAuth 2.0 Implementation
```python
# OAuth 2.0 configuration
oauth_settings = {
    "client_id": "your_client_id",
    "client_secret": "your_client_secret",
    "redirect_uri": "https://your-domain.com/oauth/callback",
    "scope": "read write",
    "authorization_endpoint": "/api/oauth/authorize",
    "token_endpoint": "/api/oauth/token"
}
```

### 2. Implement Authentication Decorator
```python
import frappe
from frappe import _
from functools import wraps

def authenticate_api(auth_methods=['token', 'session']):
    """
    Decorator for API authentication
    
    Args:
        auth_methods: List of accepted authentication methods
    """
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            authenticated = False
            auth_method = None
            
            # Token authentication
            if 'token' in auth_methods:
                if authenticate_token():
                    authenticated = True
                    auth_method = 'token'
            
            # Session authentication
            if 'session' in auth_methods and not authenticated:
                if authenticate_session():
                    authenticated = True
                    auth_method = 'session'
            
            if not authenticated:
                frappe.throw(_("Authentication required"), 
                           frappe.AuthenticationError)
            
            # Add auth info to frappe local
            frappe.local.auth_method = auth_method
            
            return func(*args, **kwargs)
        return wrapper
    return decorator

def authenticate_token():
    """Validate API token"""
    api_key = frappe.get_request_header("Authorization")
    if not api_key or not api_key.startswith("token "):
        return False
    
    try:
        token = api_key.split(" ")[1]
        key_secret = token.split(":")
        
        if len(key_secret) != 2:
            return False
            
        api_key, api_secret = key_secret
        
        # Validate credentials
        user = frappe.db.get_value("User", {
            "api_key": api_key,
            "api_secret": api_secret,
            "enabled": 1
        }, "name")
        
        if user:
            frappe.set_user(user)
            return True
            
    except Exception:
        pass
    
    return False

def authenticate_session():
    """Validate session authentication"""
    if frappe.session.user != "Guest":
        return True
    return False
```

### 3. Rate Limiting Implementation
```python
import time
from collections import defaultdict

# In-memory rate limiting (use Redis in production)
rate_limits = defaultdict(list)

def rate_limit(calls_per_minute=60):
    """Rate limiting decorator"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            user = frappe.session.user
            current_time = time.time()
            minute_ago = current_time - 60
            
            # Clean old requests
            rate_limits[user] = [
                req_time for req_time in rate_limits[user] 
                if req_time > minute_ago
            ]
            
            # Check rate limit
            if len(rate_limits[user]) >= calls_per_minute:
                frappe.throw(_("Rate limit exceeded. Try again later."), 
                           frappe.RateLimitExceededError)
            
            # Add current request
            rate_limits[user].append(current_time)
            
            return func(*args, **kwargs)
        return wrapper
    return decorator
```

### 4. Secure API Endpoint Example
```python
@frappe.whitelist()
@authenticate_api(['token', 'session'])
@rate_limit(calls_per_minute=100)
def secure_endpoint(data):
    """Secure API endpoint with authentication and rate limiting"""
    
    # Validate permissions
    if not frappe.has_permission("Customer", "read"):
        frappe.throw(_("Insufficient permissions"), 
                   frappe.PermissionError)
    
    # Process request
    try:
        result = process_secure_data(data)
        
        # Log successful API call
        frappe.logger().info(f"API call successful: {frappe.session.user}")
        
        return {
            "success": True,
            "data": result,
            "auth_method": frappe.local.auth_method
        }
        
    except Exception as e:
        # Log error
        frappe.log_error(message=str(e), title="Secure API Error")
        frappe.throw(_("An error occurred processing your request"))
```

### 5. JWT Token Implementation (Advanced)
```python
import jwt
import datetime

JWT_SECRET = frappe.get_conf().get("jwt_secret") or "your-secret-key"

def generate_jwt_token(user, expires_in_hours=24):
    """Generate JWT token for user"""
    payload = {
        'user': user,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=expires_in_hours),
        'iat': datetime.datetime.utcnow()
    }
    
    token = jwt.encode(payload, JWT_SECRET, algorithm='HS256')
    return token

def validate_jwt_token(token):
    """Validate JWT token"""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=['HS256'])
        user = payload.get('user')
        
        # Verify user still exists and is enabled
        if frappe.db.get_value("User", user, "enabled"):
            frappe.set_user(user)
            return True
            
    except jwt.ExpiredSignatureError:
        frappe.throw(_("Token has expired"), frappe.AuthenticationError)
    except jwt.InvalidTokenError:
        frappe.throw(_("Invalid token"), frappe.AuthenticationError)
    
    return False

@frappe.whitelist(allow_guest=True)
def login_with_jwt(username, password):
    """Login endpoint that returns JWT token"""
    try:
        # Validate credentials
        frappe.auth.check_password(username, password)
        
        # Generate JWT token
        token = generate_jwt_token(username)
        
        return {
            "success": True,
            "token": token,
            "user": username,
            "message": _("Login successful")
        }
        
    except frappe.AuthenticationError:
        frappe.throw(_("Invalid credentials"), frappe.AuthenticationError)
```

### 6. CORS Configuration
```python
# In hooks.py
app_include_js = [
    "/assets/custom_app/js/cors-handler.js"
]

# CORS headers for API responses
def add_cors_headers():
    """Add CORS headers to API responses"""
    frappe.local.response['Access-Control-Allow-Origin'] = '*'
    frappe.local.response['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
    frappe.local.response['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
```

### 7. Security Middleware
```python
def security_middleware():
    """Security middleware for enhanced protection"""
    
    # HTTPS enforcement
    if not frappe.request.scheme == 'https' and not frappe.conf.developer_mode:
        frappe.throw(_("HTTPS required"), frappe.ValidationError)
    
    # Security headers
    frappe.local.response['X-Content-Type-Options'] = 'nosniff'
    frappe.local.response['X-Frame-Options'] = 'DENY'
    frappe.local.response['X-XSS-Protection'] = '1; mode=block'
    frappe.local.response['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    
    # API key validation for sensitive endpoints
    if frappe.request.path.startswith('/api/method/sensitive_'):
        validate_api_key_permissions()

def validate_api_key_permissions():
    """Validate API key has required permissions"""
    user = frappe.session.user
    if user == "Guest":
        frappe.throw(_("Authentication required"), frappe.AuthenticationError)
    
    # Check if user has API access
    if not frappe.db.get_value("User", user, "enabled"):
        frappe.throw(_("Account disabled"), frappe.PermissionError)
```

## Configuration

### Site Config (site_config.json)
```json
{
    "jwt_secret": "your-secret-key-here",
    "api_rate_limit": {
        "enabled": true,
        "calls_per_minute": 60,
        "burst_limit": 10
    },
    "cors": {
        "allow_origins": ["https://yourdomain.com"],
        "allow_methods": ["GET", "POST", "PUT", "DELETE"],
        "allow_headers": ["Content-Type", "Authorization"]
    }
}
```

### App Hooks Configuration
```python
# hooks.py
after_request = [
    "custom_app.auth.add_cors_headers",
    "custom_app.auth.security_middleware"
]

before_request = [
    "custom_app.auth.validate_api_access"
]
```

## Testing Authentication
```python
# Test API authentication
import requests

# Token authentication test
headers = {
    "Authorization": "token api_key:api_secret",
    "Content-Type": "application/json"
}

response = requests.get(
    "https://yoursite.com/api/method/your_app.api.secure_endpoint",
    headers=headers
)

# JWT authentication test
jwt_headers = {
    "Authorization": "Bearer your_jwt_token",
    "Content-Type": "application/json"
}

response = requests.get(
    "https://yoursite.com/api/method/your_app.api.jwt_endpoint",
    headers=jwt_headers
)
```

## Security Best Practices
1. **Always use HTTPS** in production
2. **Rotate API keys** regularly
3. **Implement rate limiting** to prevent abuse
4. **Log authentication attempts** for monitoring
5. **Use strong JWT secrets** with regular rotation
6. **Validate permissions** at the endpoint level
7. **Sanitize inputs** to prevent injection attacks
8. **Monitor failed authentication** attempts

## Integration Points
- **API Architect**: Primary agent using this task
- **API Developer**: Implementation of secure endpoints  
- **Testing Specialist**: Authentication testing
- **Security Middleware**: Enhanced security measures