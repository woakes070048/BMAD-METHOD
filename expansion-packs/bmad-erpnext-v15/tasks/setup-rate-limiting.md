# setup-rate-limiting

## Task Description
Implement rate limiting for API endpoints to prevent abuse and ensure system stability.

## Parameters
- `limit_type`: per_user, per_ip, or global
- `time_window`: Time window in seconds (default: 60)
- `max_requests`: Maximum requests allowed in time window
- `endpoints`: Specific endpoints to apply rate limiting
- `storage_backend`: memory, redis, or database (default: redis)

## Prerequisites
- API endpoints identified
- Rate limiting requirements defined
- Storage backend configured (Redis recommended)

## Steps

### 1. Redis-Based Rate Limiting (Recommended)
```python
import frappe
import redis
import time
import json
from frappe import _

# Redis configuration
def get_redis_connection():
    """Get Redis connection for rate limiting"""
    redis_config = frappe.get_conf().get("redis_cache", {})
    return redis.Redis(
        host=redis_config.get("host", "localhost"),
        port=redis_config.get("port", 6379),
        db=redis_config.get("db", 1),
        decode_responses=True
    )

class RateLimiter:
    def __init__(self, storage_backend="redis"):
        self.backend = storage_backend
        self.redis = get_redis_connection() if storage_backend == "redis" else None
    
    def is_allowed(self, identifier, limit, window_seconds):
        """
        Check if request is allowed based on rate limit
        
        Args:
            identifier: Unique identifier (user_id, ip, etc.)
            limit: Maximum requests allowed
            window_seconds: Time window in seconds
        
        Returns:
            tuple: (allowed: bool, remaining: int, reset_time: int)
        """
        if self.backend == "redis":
            return self._redis_rate_limit(identifier, limit, window_seconds)
        else:
            return self._memory_rate_limit(identifier, limit, window_seconds)
    
    def _redis_rate_limit(self, identifier, limit, window_seconds):
        """Redis-based sliding window rate limiting"""
        key = f"rate_limit:{identifier}"
        current_time = time.time()
        pipeline = self.redis.pipeline()
        
        # Remove expired entries
        pipeline.zremrangebyscore(key, 0, current_time - window_seconds)
        
        # Count current requests
        pipeline.zcard(key)
        
        # Add current request
        pipeline.zadd(key, {str(current_time): current_time})
        
        # Set expiry
        pipeline.expire(key, window_seconds)
        
        results = pipeline.execute()
        current_requests = results[1]
        
        if current_requests < limit:
            return True, limit - current_requests - 1, int(current_time + window_seconds)
        else:
            # Remove the request we just added since it's not allowed
            self.redis.zrem(key, str(current_time))
            return False, 0, int(current_time + window_seconds)
    
    def _memory_rate_limit(self, identifier, limit, window_seconds):
        """In-memory rate limiting (not recommended for production)"""
        if not hasattr(frappe.local, 'rate_limit_storage'):
            frappe.local.rate_limit_storage = {}
        
        storage = frappe.local.rate_limit_storage
        current_time = time.time()
        
        if identifier not in storage:
            storage[identifier] = []
        
        # Clean expired requests
        storage[identifier] = [
            req_time for req_time in storage[identifier]
            if req_time > current_time - window_seconds
        ]
        
        if len(storage[identifier]) < limit:
            storage[identifier].append(current_time)
            return True, limit - len(storage[identifier]), int(current_time + window_seconds)
        else:
            return False, 0, int(current_time + window_seconds)

# Global rate limiter instance
rate_limiter = RateLimiter()
```

### 2. Rate Limiting Decorator
```python
from functools import wraps
import inspect

def rate_limit(
    limit=60,
    window=60,
    per="user",
    key_func=None,
    error_message=None,
    skip_successful_requests=False
):
    """
    Rate limiting decorator for API endpoints
    
    Args:
        limit: Maximum requests allowed
        window: Time window in seconds
        per: Rate limit per 'user', 'ip', or custom function
        key_func: Custom function to generate rate limit key
        error_message: Custom error message
        skip_successful_requests: Only count failed requests
    """
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Generate rate limit identifier
            if key_func:
                identifier = key_func()
            elif per == "user":
                identifier = f"user:{frappe.session.user}"
            elif per == "ip":
                identifier = f"ip:{frappe.local.request_ip}"
            else:
                identifier = f"global:{func.__name__}"
            
            # Check rate limit
            allowed, remaining, reset_time = rate_limiter.is_allowed(
                identifier, limit, window
            )
            
            if not allowed:
                error_msg = error_message or _(
                    "Rate limit exceeded. Try again in {} seconds"
                ).format(reset_time - int(time.time()))
                
                # Add rate limit headers to response
                frappe.local.response.update({
                    "X-RateLimit-Limit": limit,
                    "X-RateLimit-Remaining": 0,
                    "X-RateLimit-Reset": reset_time
                })
                
                frappe.throw(error_msg, frappe.RateLimitExceededError)
            
            # Execute function
            try:
                result = func(*args, **kwargs)
                
                # Add rate limit headers to successful response
                if hasattr(frappe.local, 'response'):
                    frappe.local.response.update({
                        "X-RateLimit-Limit": limit,
                        "X-RateLimit-Remaining": remaining,
                        "X-RateLimit-Reset": reset_time
                    })
                
                return result
                
            except Exception as e:
                # If skip_successful_requests is True, only failed requests count
                if skip_successful_requests:
                    # Remove the request from rate limit counter
                    if rate_limiter.backend == "redis":
                        key = f"rate_limit:{identifier}"
                        # Remove the most recent entry
                        rate_limiter.redis.zpopmax(key, 1)
                
                raise e
        
        return wrapper
    return decorator
```

### 3. Advanced Rate Limiting Strategies

#### Tiered Rate Limiting
```python
def tiered_rate_limit():
    """Different limits based on user type"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            user = frappe.session.user
            
            # Get user role-based limits
            if "System Manager" in frappe.get_roles(user):
                limit, window = 1000, 60  # System managers get higher limits
            elif "API User" in frappe.get_roles(user):
                limit, window = 500, 60   # API users get medium limits
            else:
                limit, window = 100, 60   # Regular users get standard limits
            
            identifier = f"tiered:{user}"
            allowed, remaining, reset_time = rate_limiter.is_allowed(
                identifier, limit, window
            )
            
            if not allowed:
                frappe.throw(_("Rate limit exceeded"), frappe.RateLimitExceededError)
            
            return func(*args, **kwargs)
        return wrapper
    return decorator
```

#### Adaptive Rate Limiting
```python
def adaptive_rate_limit(base_limit=60, window=60):
    """Adaptive rate limiting based on system load"""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Get current system load (simplified example)
            cpu_usage = get_system_cpu_usage()  # Implement this function
            
            # Adjust limit based on system load
            if cpu_usage > 80:
                adjusted_limit = int(base_limit * 0.5)  # Reduce by 50%
            elif cpu_usage > 60:
                adjusted_limit = int(base_limit * 0.75)  # Reduce by 25%
            else:
                adjusted_limit = base_limit
            
            identifier = f"adaptive:{frappe.session.user}"
            allowed, remaining, reset_time = rate_limiter.is_allowed(
                identifier, adjusted_limit, window
            )
            
            if not allowed:
                frappe.throw(_("System is under high load. Please try again later."),
                           frappe.RateLimitExceededError)
            
            return func(*args, **kwargs)
        return wrapper
    return decorator
```

### 4. Endpoint-Specific Rate Limiting Examples

#### Heavy Computation Endpoints
```python
@frappe.whitelist()
@rate_limit(limit=5, window=60, per="user")  # 5 requests per minute
def generate_complex_report(filters):
    """Heavy computation endpoint with strict rate limiting"""
    return process_complex_report(filters)
```

#### Authentication Endpoints
```python
@frappe.whitelist(allow_guest=True)
@rate_limit(
    limit=5, 
    window=300,  # 5 attempts per 5 minutes
    per="ip",
    error_message="Too many login attempts. Please try again in 5 minutes."
)
def api_login(username, password):
    """Login endpoint with IP-based rate limiting"""
    return authenticate_user(username, password)
```

#### Bulk Operations
```python
@frappe.whitelist()
@rate_limit(limit=10, window=3600, per="user")  # 10 bulk operations per hour
def bulk_update_records(data):
    """Bulk operation with hourly rate limiting"""
    return process_bulk_update(data)
```

### 5. Rate Limiting Middleware
```python
def rate_limiting_middleware():
    """Global rate limiting middleware"""
    path = frappe.request.path
    
    # Apply different limits based on endpoint patterns
    if path.startswith('/api/method/'):
        method_name = path.split('/')[-1]
        
        # Heavy endpoints
        heavy_endpoints = ['generate_report', 'bulk_operation', 'export_data']
        if any(endpoint in method_name for endpoint in heavy_endpoints):
            apply_heavy_rate_limit()
        
        # Auth endpoints
        elif 'login' in method_name or 'password' in method_name:
            apply_auth_rate_limit()
        
        # Default API rate limit
        else:
            apply_default_api_rate_limit()

def apply_heavy_rate_limit():
    """Apply rate limit for heavy operations"""
    identifier = f"heavy:{frappe.session.user}"
    allowed, _, _ = rate_limiter.is_allowed(identifier, 5, 300)  # 5 per 5 minutes
    
    if not allowed:
        frappe.throw(_("Heavy operation rate limit exceeded"), 
                   frappe.RateLimitExceededError)

def apply_auth_rate_limit():
    """Apply rate limit for authentication"""
    identifier = f"auth:{frappe.local.request_ip}"
    allowed, _, _ = rate_limiter.is_allowed(identifier, 10, 600)  # 10 per 10 minutes
    
    if not allowed:
        frappe.throw(_("Authentication rate limit exceeded"), 
                   frappe.RateLimitExceededError)
```

### 6. Rate Limit Monitoring
```python
def get_rate_limit_stats():
    """Get rate limiting statistics"""
    stats = {}
    
    # Top rate-limited users
    if rate_limiter.backend == "redis":
        redis = rate_limiter.redis
        keys = redis.keys("rate_limit:user:*")
        
        for key in keys[:10]:  # Top 10
            user = key.split(":")[-1]
            count = redis.zcard(key)
            stats[user] = count
    
    return stats

@frappe.whitelist()
def rate_limit_dashboard():
    """Dashboard for rate limit monitoring"""
    if not frappe.has_permission("System Manager"):
        frappe.throw(_("Access denied"))
    
    return {
        "current_stats": get_rate_limit_stats(),
        "blocked_ips": get_blocked_ips(),
        "top_consumers": get_top_api_consumers()
    }
```

### 7. Configuration Management
```python
# Site config for rate limiting
rate_limiting_config = {
    "enabled": True,
    "storage": "redis",
    "default_limits": {
        "api": {"limit": 100, "window": 60},
        "heavy": {"limit": 5, "window": 300},
        "auth": {"limit": 5, "window": 300}
    },
    "user_tier_limits": {
        "System Manager": {"multiplier": 10},
        "API User": {"multiplier": 5},
        "Guest": {"multiplier": 0.1}
    }
}

# In site_config.json
{
    "rate_limiting": {
        "enabled": true,
        "storage": "redis",
        "redis_url": "redis://localhost:6379/1"
    }
}
```

## Testing Rate Limiting
```python
# Test rate limiting
import requests
import time

def test_rate_limit():
    """Test API rate limiting"""
    endpoint = "https://yoursite.com/api/method/test_endpoint"
    headers = {"Authorization": "token api_key:secret"}
    
    # Make requests up to the limit
    for i in range(65):  # Assuming 60 requests/minute limit
        response = requests.get(endpoint, headers=headers)
        print(f"Request {i+1}: {response.status_code}")
        
        if response.status_code == 429:  # Rate limited
            print("Rate limit hit!")
            print(f"Headers: {response.headers}")
            break
        
        time.sleep(0.5)  # Small delay between requests
```

## Integration with Hooks
```python
# hooks.py
before_request = [
    "custom_app.rate_limiting.rate_limiting_middleware"
]

# Custom rate limit error handling
on_session_creation = [
    "custom_app.rate_limiting.initialize_user_rate_limits"
]
```

## Best Practices
1. **Use Redis** for production rate limiting
2. **Set appropriate limits** based on endpoint complexity
3. **Monitor rate limit usage** regularly
4. **Implement tiered limits** for different user types
5. **Provide clear error messages** with retry information
6. **Log rate limit violations** for security monitoring
7. **Consider burst allowances** for legitimate traffic spikes
8. **Test thoroughly** before production deployment

## Integration Points
- **API Architect**: Primary agent using this task
- **API Developer**: Endpoint implementation with rate limits
- **Testing Specialist**: Rate limiting testing and validation
- **System Admin**: Rate limiting monitoring and configuration