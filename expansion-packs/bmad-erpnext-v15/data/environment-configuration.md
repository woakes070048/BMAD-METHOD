# Environment Configuration Patterns for ERPNext Applications

## Overview
Proper environment configuration ensures your ERPNext application works seamlessly across development, staging, and production environments.

## Environment Variables Strategy

### 1. Backend Environment Configuration

#### Using site_config.json
```json
// sites/your-site.local/site_config.json
{
  "db_name": "_ad03fa1a5a1e2345",
  "db_password": "password",
  "db_type": "mariadb",
  "developer_mode": 1,
  "disable_website_cache": 1,
  
  // Custom app configuration
  "custom_app_settings": {
    "api_key": "your-api-key",
    "api_secret": "your-api-secret",
    "webhook_url": "https://your-webhook.com",
    "enable_debug": true,
    "max_retries": 3,
    "timeout": 30
  },
  
  // Feature flags
  "features": {
    "enable_new_ui": true,
    "enable_beta_features": false,
    "enable_analytics": true
  },
  
  // Third-party services
  "services": {
    "smtp_server": "smtp.gmail.com",
    "smtp_port": 587,
    "mail_login": "your-email@gmail.com",
    "s3_bucket": "your-bucket",
    "s3_region": "us-east-1"
  }
}
```

#### Accessing Configuration in Python
```python
# your_app/utils/config.py
import frappe
from frappe import _

def get_app_config(key, default=None):
    """Get app configuration from site config."""
    config = frappe.conf.get("custom_app_settings", {})
    return config.get(key, default)

def get_feature_flag(feature):
    """Check if a feature is enabled."""
    features = frappe.conf.get("features", {})
    return features.get(feature, False)

def get_service_config(service):
    """Get third-party service configuration."""
    services = frappe.conf.get("services", {})
    return services.get(service)

# Usage
api_key = get_app_config("api_key")
if get_feature_flag("enable_new_ui"):
    # Use new UI
    pass

smtp_config = get_service_config("smtp_server")
```

### 2. Frontend Environment Configuration

#### Using .env Files
```bash
# frontend/.env.development
VITE_APP_TITLE=ERPNext Dev
VITE_API_URL=http://localhost:8000
VITE_SOCKET_URL=http://localhost:9000
VITE_DEBUG=true
VITE_ENABLE_PWA=false
VITE_GOOGLE_ANALYTICS_ID=
VITE_SENTRY_DSN=

# frontend/.env.staging
VITE_APP_TITLE=ERPNext Staging
VITE_API_URL=https://staging.example.com
VITE_SOCKET_URL=wss://staging.example.com
VITE_DEBUG=false
VITE_ENABLE_PWA=true
VITE_GOOGLE_ANALYTICS_ID=UA-XXXXXXXXX-X
VITE_SENTRY_DSN=https://staging-key@sentry.io/project

# frontend/.env.production
VITE_APP_TITLE=ERPNext
VITE_API_URL=https://app.example.com
VITE_SOCKET_URL=wss://app.example.com
VITE_DEBUG=false
VITE_ENABLE_PWA=true
VITE_GOOGLE_ANALYTICS_ID=UA-YYYYYYYYY-Y
VITE_SENTRY_DSN=https://production-key@sentry.io/project
```

#### Environment Config Module
```javascript
// frontend/src/config/environment.js
const config = {
  development: {
    apiUrl: import.meta.env.VITE_API_URL || 'http://localhost:8000',
    socketUrl: import.meta.env.VITE_SOCKET_URL || 'http://localhost:9000',
    debug: import.meta.env.VITE_DEBUG === 'true',
    enablePWA: false,
    features: {
      analytics: false,
      errorTracking: false,
      offlineMode: false
    }
  },
  
  staging: {
    apiUrl: import.meta.env.VITE_API_URL,
    socketUrl: import.meta.env.VITE_SOCKET_URL,
    debug: false,
    enablePWA: true,
    features: {
      analytics: true,
      errorTracking: true,
      offlineMode: false
    }
  },
  
  production: {
    apiUrl: import.meta.env.VITE_API_URL,
    socketUrl: import.meta.env.VITE_SOCKET_URL,
    debug: false,
    enablePWA: true,
    features: {
      analytics: true,
      errorTracking: true,
      offlineMode: true
    }
  }
}

const environment = import.meta.env.MODE || 'development'

export default {
  ...config[environment],
  environment,
  version: import.meta.env.VITE_APP_VERSION || '1.0.0',
  
  // Helper methods
  isProduction: () => environment === 'production',
  isDevelopment: () => environment === 'development',
  isStaging: () => environment === 'staging',
  
  // Feature flags
  isFeatureEnabled: (feature) => {
    return config[environment].features[feature] || false
  }
}
```

#### Using Environment Config
```vue
<template>
  <div>
    <h1>{{ appTitle }}</h1>
    <DebugPanel v-if="showDebug" />
    <Analytics v-if="enableAnalytics" />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import config from '@/config/environment'
import DebugPanel from '@/components/DebugPanel.vue'
import Analytics from '@/components/Analytics.vue'

const appTitle = computed(() => import.meta.env.VITE_APP_TITLE)
const showDebug = computed(() => config.debug)
const enableAnalytics = computed(() => config.isFeatureEnabled('analytics'))

// API calls use environment config
const apiUrl = `${config.apiUrl}/api/method/app.module.method`
</script>
```

## Multi-Environment Setup

### 1. Docker-based Environments

#### docker-compose.yml for Different Environments
```yaml
# docker-compose.dev.yml
version: '3.8'

services:
  frappe:
    image: frappe/erpnext:v15
    environment:
      - FRAPPE_SITE_NAME=dev.localhost
      - DEVELOPER_MODE=1
      - ADMIN_PASSWORD=admin
      - DB_HOST=mariadb
      - REDIS_CACHE=redis:6379
    volumes:
      - ./apps:/home/frappe/frappe-bench/apps
      - ./sites:/home/frappe/frappe-bench/sites
    ports:
      - "8000:8000"
      - "9000:9000"
    depends_on:
      - mariadb
      - redis

  mariadb:
    image: mariadb:10.6
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=frappe
    volumes:
      - db-data:/var/lib/mysql

  redis:
    image: redis:alpine

  frontend:
    build: ./frontend
    environment:
      - NODE_ENV=development
      - VITE_API_URL=http://localhost:8000
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "5173:5173"
    command: yarn dev

volumes:
  db-data:
```

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  frappe:
    image: frappe/erpnext:v15
    environment:
      - FRAPPE_SITE_NAME=${SITE_NAME}
      - ADMIN_PASSWORD=${ADMIN_PASSWORD}
      - DB_HOST=${DB_HOST}
      - DB_PASSWORD=${DB_PASSWORD}
      - REDIS_CACHE=${REDIS_URL}
    volumes:
      - ./sites:/home/frappe/frappe-bench/sites
      - ./logs:/home/frappe/frappe-bench/logs
    restart: always
    networks:
      - erpnext-network

  nginx:
    image: nginx:alpine
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    ports:
      - "80:80"
      - "443:443"
    depends_on:
      - frappe
    restart: always
    networks:
      - erpnext-network

networks:
  erpnext-network:
    driver: bridge
```

### 2. Bench Configuration for Multiple Sites

#### Setup Multiple Sites
```bash
# Development site
bench new-site dev.local
bench --site dev.local install-app your_app
bench --site dev.local set-config developer_mode 1

# Staging site
bench new-site staging.local
bench --site staging.local install-app your_app
bench --site staging.local set-config developer_mode 0

# Production site
bench new-site prod.local
bench --site prod.local install-app your_app
bench --site prod.local set-config developer_mode 0
```

#### Site-specific Configuration
```python
# your_app/config/__init__.py
import frappe

class SiteConfig:
    """Site-specific configuration handler."""
    
    @staticmethod
    def get_config():
        site = frappe.local.site
        
        configs = {
            'dev.local': {
                'debug': True,
                'cache_enabled': False,
                'email_enabled': False,
                'background_jobs': False
            },
            'staging.local': {
                'debug': False,
                'cache_enabled': True,
                'email_enabled': True,
                'background_jobs': True
            },
            'prod.local': {
                'debug': False,
                'cache_enabled': True,
                'email_enabled': True,
                'background_jobs': True
            }
        }
        
        return configs.get(site, configs['dev.local'])
    
    @classmethod
    def is_debug(cls):
        return cls.get_config().get('debug', False)
    
    @classmethod
    def is_cache_enabled(cls):
        return cls.get_config().get('cache_enabled', True)
```

## Secret Management

### 1. Using Frappe Vault
```python
# Store secrets
frappe.utils.password.set_encrypted_password(
    "Integration Settings",
    "api_secret",
    "your-secret-key"
)

# Retrieve secrets
from frappe.utils.password import get_decrypted_password

api_secret = get_decrypted_password(
    "Integration Settings",
    "api_secret"
)
```

### 2. Environment Variables for Secrets
```bash
# .env file (never commit this!)
export FRAPPE_API_SECRET="your-secret-key"
export FRAPPE_JWT_SECRET="your-jwt-secret"
export FRAPPE_ENCRYPTION_KEY="your-encryption-key"

# Load in Python
import os

api_secret = os.environ.get('FRAPPE_API_SECRET')
jwt_secret = os.environ.get('FRAPPE_JWT_SECRET')
```

### 3. AWS Secrets Manager Integration
```python
# your_app/utils/secrets.py
import boto3
import json
from botocore.exceptions import ClientError

class SecretsManager:
    def __init__(self, region='us-east-1'):
        self.client = boto3.client('secretsmanager', region_name=region)
    
    def get_secret(self, secret_name):
        """Retrieve secret from AWS Secrets Manager."""
        try:
            response = self.client.get_secret_value(SecretId=secret_name)
            
            if 'SecretString' in response:
                return json.loads(response['SecretString'])
            else:
                # Binary secret
                return response['SecretBinary']
                
        except ClientError as e:
            frappe.log_error(f"Failed to retrieve secret: {e}", "Secrets Manager")
            return None
    
    def create_secret(self, secret_name, secret_value):
        """Create a new secret."""
        try:
            response = self.client.create_secret(
                Name=secret_name,
                SecretString=json.dumps(secret_value)
            )
            return response['ARN']
        except ClientError as e:
            frappe.log_error(f"Failed to create secret: {e}", "Secrets Manager")
            return None

# Usage
secrets = SecretsManager()
api_credentials = secrets.get_secret('erpnext/api/credentials')
```

## Feature Flags Implementation

### 1. Backend Feature Flags
```python
# your_app/utils/feature_flags.py
import frappe
from functools import wraps

class FeatureFlags:
    """Feature flag management system."""
    
    @staticmethod
    def is_enabled(feature_name, user=None):
        """Check if a feature is enabled."""
        user = user or frappe.session.user
        
        # Check global flags
        global_flags = frappe.conf.get('feature_flags', {})
        if feature_name in global_flags:
            return global_flags[feature_name]
        
        # Check user-specific flags
        user_flags = frappe.cache().get_value(f"feature_flags:{user}")
        if user_flags and feature_name in user_flags:
            return user_flags[feature_name]
        
        # Check role-based flags
        roles = frappe.get_roles(user)
        for role in roles:
            role_flags = frappe.cache().get_value(f"feature_flags:role:{role}")
            if role_flags and feature_name in role_flags:
                return role_flags[feature_name]
        
        return False
    
    @staticmethod
    def require(feature_name):
        """Decorator to require a feature flag."""
        def decorator(func):
            @wraps(func)
            def wrapper(*args, **kwargs):
                if not FeatureFlags.is_enabled(feature_name):
                    frappe.throw("This feature is not enabled")
                return func(*args, **kwargs)
            return wrapper
        return decorator

# Usage
@frappe.whitelist()
@FeatureFlags.require('new_reporting')
def get_advanced_report():
    """This API is only available when new_reporting feature is enabled."""
    return generate_report()
```

### 2. Frontend Feature Flags
```javascript
// src/utils/featureFlags.js
import { ref, computed } from 'vue'
import { createResource } from 'frappe-ui'

class FeatureFlagsManager {
  constructor() {
    this.flags = ref({})
    this.loaded = ref(false)
    
    // Load flags from backend
    this.resource = createResource({
      url: 'app.api.get_feature_flags',
      auto: true,
      onSuccess: (data) => {
        this.flags.value = data
        this.loaded.value = true
      }
    })
  }
  
  isEnabled(feature) {
    return computed(() => {
      return this.flags.value[feature] || false
    })
  }
  
  async waitForFlags() {
    if (this.loaded.value) return
    
    return new Promise((resolve) => {
      const unwatch = watch(this.loaded, (loaded) => {
        if (loaded) {
          unwatch()
          resolve()
        }
      })
    })
  }
  
  // A/B testing support
  getVariant(experiment) {
    return computed(() => {
      const experiments = this.flags.value.experiments || {}
      return experiments[experiment] || 'control'
    })
  }
}

export const featureFlags = new FeatureFlagsManager()

// Usage in components
export function useFeatureFlag(feature) {
  return featureFlags.isEnabled(feature)
}
```

```vue
<!-- Using feature flags in components -->
<template>
  <div>
    <NewFeature v-if="showNewFeature" />
    <LegacyFeature v-else />
    
    <ExperimentalButton v-if="variant === 'variant_a'" />
    <StandardButton v-else />
  </div>
</template>

<script setup>
import { useFeatureFlag } from '@/utils/featureFlags'

const showNewFeature = useFeatureFlag('new_feature')
const variant = featureFlags.getVariant('button_experiment')
</script>
```

## Database Configuration

### 1. Connection Pooling
```python
# site_config.json
{
  "db_connections": {
    "pool_size": 10,
    "max_overflow": 20,
    "pool_timeout": 30,
    "pool_recycle": 3600
  }
}
```

### 2. Read Replica Configuration
```python
# site_config.json
{
  "read_replica": {
    "host": "read-replica.example.com",
    "port": 3306,
    "user": "read_user",
    "password": "read_password"
  }
}

# Usage in code
def get_read_only_db():
    """Get connection to read replica."""
    config = frappe.conf.get('read_replica')
    if config:
        return frappe.database.get_db(
            host=config['host'],
            user=config['user'],
            password=config['password']
        )
    return frappe.db  # Fallback to main DB
```

## Cache Configuration

### 1. Redis Configuration
```python
# site_config.json
{
  "redis_cache": "redis://localhost:6379/0",
  "redis_queue": "redis://localhost:6379/1",
  "redis_socketio": "redis://localhost:6379/2",
  
  "cache_config": {
    "default_timeout": 3600,
    "max_entries": 10000,
    "cache_shared_resources": true
  }
}
```

### 2. Cache Strategy by Environment
```python
# your_app/utils/cache.py
import frappe
from functools import wraps

def environment_cache(timeout=None):
    """Cache decorator with environment-specific timeout."""
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            # Determine cache timeout based on environment
            if frappe.conf.developer_mode:
                # No caching in development
                return func(*args, **kwargs)
            
            # Use configured timeout or default
            cache_timeout = timeout or frappe.conf.get('cache_config', {}).get('default_timeout', 3600)
            
            # Generate cache key
            cache_key = f"{func.__name__}:{str(args)}:{str(kwargs)}"
            
            # Try to get from cache
            cached_value = frappe.cache().get_value(cache_key)
            if cached_value is not None:
                return cached_value
            
            # Execute function and cache result
            result = func(*args, **kwargs)
            frappe.cache().set_value(cache_key, result, expires_in_sec=cache_timeout)
            
            return result
        return wrapper
    return decorator

# Usage
@environment_cache(timeout=3600)
def expensive_calculation(param):
    """This will be cached in production but not in development."""
    return perform_calculation(param)
```

## Monitoring and Logging Configuration

### 1. Logging Configuration
```python
# site_config.json
{
  "logging": {
    "level": "INFO",  # DEBUG, INFO, WARNING, ERROR
    "file": "/var/log/frappe/app.log",
    "max_size": "10MB",
    "backup_count": 5,
    "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
  }
}

# your_app/utils/logger.py
import logging
import frappe

def get_logger(name):
    """Get configured logger for module."""
    config = frappe.conf.get('logging', {})
    
    logger = logging.getLogger(name)
    logger.setLevel(config.get('level', 'INFO'))
    
    # Add file handler if configured
    if config.get('file'):
        handler = logging.FileHandler(config['file'])
        formatter = logging.Formatter(config.get('format'))
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    
    return logger

# Usage
logger = get_logger(__name__)
logger.info("Application started")
logger.error("An error occurred", exc_info=True)
```

### 2. APM Integration (Application Performance Monitoring)
```python
# site_config.json
{
  "apm": {
    "enabled": true,
    "service_name": "erpnext-app",
    "environment": "production",
    "sample_rate": 0.1,
    "elastic_apm_server": "http://apm.example.com:8200"
  }
}

# your_app/__init__.py
import frappe

def setup_apm():
    """Setup APM based on configuration."""
    apm_config = frappe.conf.get('apm', {})
    
    if apm_config.get('enabled'):
        from elasticapm import Client
        
        client = Client({
            'SERVICE_NAME': apm_config.get('service_name'),
            'SERVER_URL': apm_config.get('elastic_apm_server'),
            'ENVIRONMENT': apm_config.get('environment'),
            'SAMPLE_RATE': apm_config.get('sample_rate', 0.1)
        })
        
        frappe.local.apm_client = client

# Call during app initialization
setup_apm()
```

## Best Practices

1. **Never commit secrets** - Use environment variables or secret management services
2. **Use different configs per environment** - Separate dev, staging, and production
3. **Implement feature flags** - For gradual rollouts and A/B testing
4. **Cache appropriately** - Different strategies for different environments
5. **Monitor everything** - Logging, APM, and error tracking
6. **Document configuration** - Keep a README for all config options
7. **Use config validation** - Validate configs on startup
8. **Implement config hot-reload** - For production updates without restart
9. **Secure sensitive configs** - Encrypt sensitive configuration data
10. **Version control configs** - Track config changes (except secrets)