# API Security Patterns

## Overview
This document outlines security patterns and best practices for implementing secure APIs in Frappe/ERPNext applications.

## Authentication Patterns

### Token-Based Authentication
```python
import frappe
from frappe import _
import jwt
from datetime import datetime, timedelta

class TokenAuthentication:
    """Secure token-based authentication implementation"""
    
    @staticmethod
    def generate_access_token(user, expires_in=3600):
        """Generate JWT access token"""
        payload = {
            'user': user,
            'exp': datetime.utcnow() + timedelta(seconds=expires_in),
            'iat': datetime.utcnow(),
            'type': 'access'
        }
        
        secret = frappe.get_conf().get('jwt_secret_key')
        return jwt.encode(payload, secret, algorithm='HS256')
    
    @staticmethod
    def validate_token(token):
        """Validate JWT token"""
        try:
            secret = frappe.get_conf().get('jwt_secret_key')
            payload = jwt.decode(token, secret, algorithms=['HS256'])
            
            if payload['type'] != 'access':
                raise frappe.AuthenticationError("Invalid token type")
            
            # Check if user is still active
            user = frappe.get_doc("User", payload['user'])
            if not user.enabled:
                raise frappe.AuthenticationError("User account disabled")
            
            frappe.set_user(payload['user'])
            return True
            
        except jwt.ExpiredSignatureError:
            raise frappe.AuthenticationError("Token has expired")
        except jwt.InvalidTokenError:
            raise frappe.AuthenticationError("Invalid token")
```

### API Key Authentication
```python
class APIKeyAuthentication:
    """Secure API key authentication with rate limiting"""
    
    @staticmethod
    def validate_api_key(api_key):
        """Validate API key and check permissions"""
        
        # Check API key format
        if not api_key or len(api_key) != 32:
            raise frappe.AuthenticationError("Invalid API key format")
        
        # Find user with this API key
        user = frappe.db.get_value("User", {
            "api_key": api_key,
            "enabled": 1
        }, ["name", "api_secret", "last_active"])
        
        if not user:
            # Log failed authentication attempt
            frappe.log_error(
                message=f"Failed API key authentication: {api_key[:8]}...",
                title="API Security Alert"
            )
            raise frappe.AuthenticationError("Invalid API key")
        
        # Check if account is locked
        if frappe.cache().get(f"api_locked_{user.name}"):
            raise frappe.AuthenticationError("API access temporarily locked")
        
        frappe.set_user(user.name)
        return True
    
    @staticmethod
    def lock_api_access(user, duration=300):
        """Lock API access for a user after multiple failed attempts"""
        frappe.cache().set(f"api_locked_{user}", True, ttl=duration)
```

## Authorization Patterns

### Role-Based Access Control (RBAC)
```python
class RoleBasedAccess:
    """Implement role-based access control for APIs"""
    
    @staticmethod
    def check_role_permission(required_roles):
        """Check if user has required roles"""
        user_roles = frappe.get_roles()
        
        if not any(role in user_roles for role in required_roles):
            frappe.throw(
                _("You need one of these roles: {0}").format(", ".join(required_roles)),
                frappe.PermissionError
            )
    
    @staticmethod
    def check_document_permission(doctype, docname, permission_type="read"):
        """Check document-level permissions"""
        if not frappe.has_permission(doctype, permission_type, docname):
            frappe.throw(
                _("You don't have {0} permission for {1}").format(permission_type, docname),
                frappe.PermissionError
            )
    
    @staticmethod
    def check_field_permission(doctype, field_name, permission_type="read"):
        """Check field-level permissions"""
        meta = frappe.get_meta(doctype)
        field = meta.get_field(field_name)
        
        if field and field.permlevel > 0:
            if not frappe.has_permission(doctype, permission_type, ptype='read', user=frappe.session.user):
                frappe.throw(
                    _("You don't have permission to access field {0}").format(field_name),
                    frappe.PermissionError
                )
```

### Attribute-Based Access Control (ABAC)
```python
class AttributeBasedAccess:
    """Advanced attribute-based access control"""
    
    @staticmethod
    def evaluate_policy(resource, action, context=None):
        """Evaluate access policy based on attributes"""
        
        policies = {
            'time_based': lambda: datetime.now().hour >= 9 and datetime.now().hour <= 17,
            'ip_based': lambda: frappe.local.request_ip in get_allowed_ips(),
            'location_based': lambda: check_user_location(),
            'department_based': lambda: check_department_access(resource, action)
        }
        
        for policy_name, policy_func in policies.items():
            if not policy_func():
                frappe.throw(
                    _("Access denied by {0} policy").format(policy_name),
                    frappe.PermissionError
                )
```

## Input Validation Patterns

### SQL Injection Prevention
```python
class SQLInjectionPrevention:
    """Prevent SQL injection attacks"""
    
    DANGEROUS_SQL_PATTERNS = [
        r'\b(DROP|DELETE|UPDATE|INSERT|ALTER|CREATE|EXEC|UNION)\b',
        r'[\'";]',
        r'--',
        r'/\*',
        r'\*/',
        r'xp_',
        r'@@'
    ]
    
    @staticmethod
    def sanitize_sql_input(value):
        """Sanitize input to prevent SQL injection"""
        if not isinstance(value, str):
            return value
        
        import re
        for pattern in SQLInjectionPrevention.DANGEROUS_SQL_PATTERNS:
            if re.search(pattern, value, re.IGNORECASE):
                frappe.throw(_("Invalid input detected"), frappe.ValidationError)
        
        return value
    
    @staticmethod
    def validate_filter_params(filters):
        """Validate filter parameters for database queries"""
        if isinstance(filters, dict):
            for key, value in filters.items():
                SQLInjectionPrevention.sanitize_sql_input(str(key))
                SQLInjectionPrevention.sanitize_sql_input(str(value))
```

### XSS Prevention
```python
class XSSPrevention:
    """Prevent Cross-Site Scripting attacks"""
    
    @staticmethod
    def sanitize_html_input(value):
        """Sanitize HTML input to prevent XSS"""
        import html
        import re
        
        if not isinstance(value, str):
            return value
        
        # Remove script tags
        value = re.sub(r'<script[^>]*>.*?</script>', '', value, flags=re.IGNORECASE | re.DOTALL)
        
        # Remove javascript: URLs
        value = re.sub(r'javascript:', '', value, flags=re.IGNORECASE)
        
        # Remove on* event handlers
        value = re.sub(r'\son\w+\s*=', '', value, flags=re.IGNORECASE)
        
        # Escape HTML entities
        value = html.escape(value)
        
        return value
    
    @staticmethod
    def validate_json_input(json_data):
        """Validate JSON input for XSS"""
        import json
        
        if isinstance(json_data, str):
            try:
                data = json.loads(json_data)
            except json.JSONDecodeError:
                frappe.throw(_("Invalid JSON format"), frappe.ValidationError)
        else:
            data = json_data
        
        return XSSPrevention._sanitize_json_object(data)
    
    @staticmethod
    def _sanitize_json_object(obj):
        """Recursively sanitize JSON object"""
        if isinstance(obj, dict):
            return {k: XSSPrevention._sanitize_json_object(v) for k, v in obj.items()}
        elif isinstance(obj, list):
            return [XSSPrevention._sanitize_json_object(item) for item in obj]
        elif isinstance(obj, str):
            return XSSPrevention.sanitize_html_input(obj)
        else:
            return obj
```

## Rate Limiting Patterns

### Sliding Window Rate Limiter
```python
import time
import redis

class SlidingWindowRateLimiter:
    """Implement sliding window rate limiting"""
    
    def __init__(self, redis_client=None):
        self.redis = redis_client or self._get_redis_client()
    
    def is_allowed(self, identifier, limit, window_seconds):
        """Check if request is within rate limit"""
        key = f"rate_limit:{identifier}"
        current_time = time.time()
        
        # Remove expired entries
        self.redis.zremrangebyscore(key, 0, current_time - window_seconds)
        
        # Check current count
        current_count = self.redis.zcard(key)
        
        if current_count >= limit:
            return False, 0, current_time + window_seconds
        
        # Add current request
        self.redis.zadd(key, {str(current_time): current_time})
        self.redis.expire(key, window_seconds)
        
        remaining = limit - current_count - 1
        reset_time = current_time + window_seconds
        
        return True, remaining, reset_time
```

### Adaptive Rate Limiting
```python
class AdaptiveRateLimiter:
    """Implement adaptive rate limiting based on system load"""
    
    @staticmethod
    def get_dynamic_limit(base_limit, user_tier="standard"):
        """Calculate dynamic rate limit based on system conditions"""
        
        # Check system load
        import psutil
        cpu_usage = psutil.cpu_percent(interval=1)
        memory_usage = psutil.virtual_memory().percent
        
        # Adjust limits based on system load
        load_factor = 1.0
        
        if cpu_usage > 80 or memory_usage > 80:
            load_factor = 0.5  # Reduce by 50%
        elif cpu_usage > 60 or memory_usage > 60:
            load_factor = 0.75  # Reduce by 25%
        
        # Apply user tier multiplier
        tier_multipliers = {
            "premium": 2.0,
            "standard": 1.0,
            "basic": 0.5
        }
        
        tier_factor = tier_multipliers.get(user_tier, 1.0)
        
        return int(base_limit * load_factor * tier_factor)
```

## Data Protection Patterns

### Data Encryption
```python
class DataEncryption:
    """Handle sensitive data encryption"""
    
    @staticmethod
    def encrypt_sensitive_field(value, field_name):
        """Encrypt sensitive field values"""
        from cryptography.fernet import Fernet
        
        # Get encryption key from configuration
        key = frappe.get_conf().get('encryption_key')
        if not key:
            frappe.throw(_("Encryption key not configured"), frappe.ValidationError)
        
        cipher_suite = Fernet(key.encode())
        encrypted_value = cipher_suite.encrypt(str(value).encode())
        
        # Log encryption activity (without sensitive data)
        frappe.log_error(
            message=f"Field {field_name} encrypted for user {frappe.session.user}",
            title="Data Encryption Activity"
        )
        
        return encrypted_value.decode()
    
    @staticmethod
    def decrypt_sensitive_field(encrypted_value, field_name):
        """Decrypt sensitive field values"""
        from cryptography.fernet import Fernet
        
        key = frappe.get_conf().get('encryption_key')
        cipher_suite = Fernet(key.encode())
        
        try:
            decrypted_value = cipher_suite.decrypt(encrypted_value.encode())
            return decrypted_value.decode()
        except Exception as e:
            frappe.log_error(
                message=f"Decryption failed for field {field_name}: {str(e)}",
                title="Decryption Error"
            )
            frappe.throw(_("Failed to decrypt sensitive data"), frappe.ValidationError)
```

### Data Masking
```python
class DataMasking:
    """Mask sensitive data in API responses"""
    
    SENSITIVE_FIELDS = [
        'social_security_number',
        'credit_card_number',
        'bank_account_number',
        'tax_id',
        'phone_number',
        'email'
    ]
    
    @staticmethod
    def mask_sensitive_data(data, user_role=None):
        """Mask sensitive fields based on user permissions"""
        
        if isinstance(data, dict):
            return DataMasking._mask_dict(data, user_role)
        elif isinstance(data, list):
            return [DataMasking.mask_sensitive_data(item, user_role) for item in data]
        else:
            return data
    
    @staticmethod
    def _mask_dict(data_dict, user_role):
        """Mask sensitive fields in dictionary"""
        masked_dict = data_dict.copy()
        
        for field_name, value in data_dict.items():
            if field_name.lower() in DataMasking.SENSITIVE_FIELDS:
                if not DataMasking._has_unmask_permission(field_name, user_role):
                    masked_dict[field_name] = DataMasking._mask_value(value, field_name)
        
        return masked_dict
    
    @staticmethod
    def _mask_value(value, field_type):
        """Apply appropriate masking based on field type"""
        if not value:
            return value
        
        value_str = str(value)
        
        if 'email' in field_type:
            # Mask email: j***@example.com
            parts = value_str.split('@')
            if len(parts) == 2:
                return f"{parts[0][0]}***@{parts[1]}"
        
        elif 'phone' in field_type:
            # Mask phone: ***-***-1234
            if len(value_str) >= 4:
                return '***-***-' + value_str[-4:]
        
        elif 'card' in field_type or 'account' in field_type:
            # Mask card/account: ****-****-****-1234
            if len(value_str) >= 4:
                return '****-****-****-' + value_str[-4:]
        
        else:
            # Generic masking
            if len(value_str) > 4:
                return value_str[:2] + '*' * (len(value_str) - 4) + value_str[-2:]
        
        return value
```

## API Response Security

### Secure Response Headers
```python
class SecureResponseHeaders:
    """Add security headers to API responses"""
    
    SECURITY_HEADERS = {
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'X-XSS-Protection': '1; mode=block',
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
        'Content-Security-Policy': "default-src 'self'",
        'Referrer-Policy': 'strict-origin-when-cross-origin',
        'Permissions-Policy': 'camera=(), microphone=(), location=()'
    }
    
    @staticmethod
    def add_security_headers():
        """Add security headers to response"""
        for header, value in SecureResponseHeaders.SECURITY_HEADERS.items():
            frappe.local.response.headers[header] = value
    
    @staticmethod
    def add_cors_headers(allowed_origins=None):
        """Add CORS headers with proper validation"""
        origin = frappe.get_request_header('Origin')
        
        # Validate origin against whitelist
        allowed_origins = allowed_origins or frappe.get_conf().get('allowed_origins', [])
        
        if origin in allowed_origins:
            frappe.local.response.headers['Access-Control-Allow-Origin'] = origin
        else:
            frappe.local.response.headers['Access-Control-Allow-Origin'] = 'null'
        
        frappe.local.response.headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
        frappe.local.response.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
        frappe.local.response.headers['Access-Control-Max-Age'] = '86400'
```

## Security Monitoring

### Audit Logging
```python
class SecurityAuditLogger:
    """Log security-related events for monitoring"""
    
    @staticmethod
    def log_authentication_event(event_type, user=None, success=True, details=None):
        """Log authentication events"""
        
        log_entry = {
            'timestamp': frappe.utils.now(),
            'event_type': f'auth_{event_type}',
            'user': user or frappe.session.user,
            'ip_address': frappe.local.request_ip,
            'user_agent': frappe.get_request_header('User-Agent'),
            'success': success,
            'details': details or {}
        }
        
        # Log to audit table
        SecurityAuditLogger._save_audit_log(log_entry)
        
        # Alert on suspicious activity
        if not success:
            SecurityAuditLogger._check_for_brute_force(user or 'unknown')
    
    @staticmethod
    def log_api_access(endpoint, method, response_code, user=None):
        """Log API access for monitoring"""
        
        log_entry = {
            'timestamp': frappe.utils.now(),
            'event_type': 'api_access',
            'endpoint': endpoint,
            'method': method,
            'response_code': response_code,
            'user': user or frappe.session.user,
            'ip_address': frappe.local.request_ip
        }
        
        SecurityAuditLogger._save_audit_log(log_entry)
    
    @staticmethod
    def _check_for_brute_force(user, threshold=5, window_minutes=15):
        """Check for brute force attacks"""
        
        # Count failed attempts in time window
        from_time = frappe.utils.add_to_date(frappe.utils.now(), minutes=-window_minutes)
        
        failed_attempts = frappe.db.count('Security Audit Log', {
            'user': user,
            'success': 0,
            'event_type': ['like', 'auth_%'],
            'timestamp': ['>=', from_time]
        })
        
        if failed_attempts >= threshold:
            # Lock account and alert administrators
            SecurityAuditLogger._handle_brute_force_attack(user)
```

## Best Practices Summary

1. **Authentication**: Use strong authentication methods (JWT, API keys) with proper expiration
2. **Authorization**: Implement role-based and attribute-based access controls
3. **Input Validation**: Validate and sanitize all inputs to prevent injection attacks
4. **Rate Limiting**: Implement adaptive rate limiting to prevent abuse
5. **Data Protection**: Encrypt sensitive data and mask it in responses
6. **Response Security**: Add security headers and validate CORS origins
7. **Monitoring**: Log all security events and monitor for suspicious activity
8. **Error Handling**: Don't expose sensitive information in error messages
9. **HTTPS**: Always use HTTPS for API communications
10. **Regular Updates**: Keep security measures updated with latest threats