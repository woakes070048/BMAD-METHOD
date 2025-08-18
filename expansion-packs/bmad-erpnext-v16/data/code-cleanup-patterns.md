# Code Cleanup Patterns for ERPNext Applications
## Common AI-Generated Code Issues and Their Solutions

**Last Updated**: 2025-08-17  
**Framework Version**: Frappe Framework 15+ | ERPNext 16  
**Purpose**: Comprehensive patterns for identifying and fixing common code issues created by AI coding tools

---

## 🚨 CRITICAL AI-GENERATED CODE PROBLEMS

### The Root Problems
AI coding tools often create these issues:
1. **Redundant Functions** - Adding new functions instead of fixing existing ones
2. **Unnecessary Files** - Creating new files instead of modifying existing ones
3. **External Dependencies** - Using external libraries instead of Frappe built-ins
4. **Custom Systems** - Building custom auth/permissions instead of using ERPNext
5. **Poor Structure** - Creating weird directory structures and naming patterns

---

## 🔄 REDUNDANT FUNCTION PATTERNS

### Pattern 1: Function Name Variations

#### ❌ PROBLEMATIC CODE (AI-GENERATED)
```python
# AI tools often create multiple similar functions
def get_customer_data(customer_id):
    return frappe.get_doc("Customer", customer_id)

def fetch_customer_data(customer_id):
    return frappe.get_doc("Customer", customer_id)

def retrieve_customer_info(customer_id):
    return frappe.get_doc("Customer", customer_id)

def load_customer_details(customer_id):
    return frappe.get_doc("Customer", customer_id)

# All functions do the same thing!
```

#### ✅ CLEANED CODE (CONSOLIDATED)
```python
def get_customer_data(customer_id):
    """Get customer document by ID"""
    return frappe.get_doc("Customer", customer_id)

# Remove all other functions and update their usage throughout the codebase
```

#### Detection Pattern
```python
# Regex to find similar function names
SIMILAR_FUNCTIONS = [
    r'def\s+(get|fetch|retrieve|load)_(\w+)_?(data|info|details|record)\(',
    r'def\s+(\w+)_(get|fetch|retrieve|load)_(\w+)\(',
    r'def\s+(\w+)_data(_get|_fetch)?\('
]
```

### Pattern 2: Copy-Paste with Minor Variations

#### ❌ PROBLEMATIC CODE (AI-GENERATED)
```python
def validate_customer_email(email):
    """Validate customer email"""
    if not email:
        frappe.throw("Email is required")
    if "@" not in email:
        frappe.throw("Invalid email format")
    if len(email) > 100:
        frappe.throw("Email too long")
    return True

def validate_supplier_email(email):
    """Validate supplier email"""
    if not email:
        frappe.throw("Email is required")
    if "@" not in email:
        frappe.throw("Invalid email format")
    if len(email) > 100:
        frappe.throw("Email too long")
    return True

def validate_user_email(email):
    """Validate user email"""
    if not email:
        frappe.throw("Email is required")
    if "@" not in email:
        frappe.throw("Invalid email format")
    if len(email) > 100:
        frappe.throw("Email too long")
    return True
```

#### ✅ CLEANED CODE (CONSOLIDATED)
```python
def validate_email(email, context=""):
    """Validate email address for any context"""
    if not email:
        frappe.throw(f"Email is required{' for ' + context if context else ''}")
    
    # Use Frappe's built-in email validation
    if not frappe.utils.validate_email_address(email):
        frappe.throw(f"Invalid email format{' for ' + context if context else ''}")
    
    if len(email) > 100:
        frappe.throw(f"Email too long{' for ' + context if context else ''}")
    
    return True

# Usage:
# validate_email(customer.email, "customer")
# validate_email(supplier.email, "supplier")
# validate_email(user.email, "user")
```

### Pattern 3: Incremental Function Creation

#### ❌ PROBLEMATIC CODE (AI-GENERATED)
```python
# AI creates new functions instead of updating existing ones
def calculate_total_v1(items):
    total = 0
    for item in items:
        total += item.get('amount', 0)
    return total

def calculate_total_v2(items):
    # Added tax calculation
    total = 0
    for item in items:
        total += item.get('amount', 0)
    tax = total * 0.18
    return total + tax

def calculate_total_v3(items):
    # Added discount
    total = 0
    for item in items:
        total += item.get('amount', 0)
    tax = total * 0.18
    discount = total * 0.1
    return total + tax - discount

def calculate_total_final(items):
    # Final version with proper calculation
    subtotal = sum(item.get('amount', 0) for item in items)
    tax = subtotal * 0.18
    discount = subtotal * 0.1
    return subtotal + tax - discount
```

#### ✅ CLEANED CODE (SINGLE FUNCTION)
```python
def calculate_total(items, tax_rate=0.18, discount_rate=0.10):
    """Calculate total with tax and discount
    
    Args:
        items: List of items with 'amount' field
        tax_rate: Tax rate (default 18%)
        discount_rate: Discount rate (default 10%)
    
    Returns:
        float: Final total after tax and discount
    """
    if not items:
        return 0.0
    
    subtotal = sum(item.get('amount', 0) for item in items)
    tax = subtotal * tax_rate
    discount = subtotal * discount_rate
    
    return subtotal + tax - discount
```

---

## 📁 UNNECESSARY FILE PATTERNS

### Pattern 1: Multiple API Files

#### ❌ PROBLEMATIC STRUCTURE (AI-GENERATED)
```
myapp/
├── api/
│   ├── customer_api.py
│   ├── customer_api_v2.py
│   ├── customer_endpoints.py
│   ├── customer_handlers.py
│   └── customer_utils.py
├── customer_api/
│   ├── __init__.py
│   ├── handlers.py
│   └── utils.py
└── utils/
    ├── customer_helpers.py
    └── customer_tools.py
```

#### ✅ CLEANED STRUCTURE (ORGANIZED)
```
myapp/
├── api/
│   └── customer.py  # Single consolidated file
└── utils/
    └── customer.py  # Single utility file if needed
```

#### Consolidation Script
```python
def consolidate_api_files(app_path):
    """Consolidate multiple API files into organized structure"""
    
    api_functions = {}
    files_to_remove = []
    
    # Find all API-related files
    for root, dirs, files in os.walk(app_path):
        for file in files:
            if ('api' in file.lower() or 'endpoint' in file.lower()) and file.endswith('.py'):
                file_path = os.path.join(root, file)
                
                # Extract functions from file
                functions = extract_functions_from_file(file_path)
                api_functions[file_path] = functions
                files_to_remove.append(file_path)
    
    # Create consolidated API file
    consolidated_content = generate_consolidated_api(api_functions)
    
    # Write to single API file
    api_file_path = os.path.join(app_path, 'api', 'consolidated.py')
    with open(api_file_path, 'w') as f:
        f.write(consolidated_content)
    
    return files_to_remove, api_file_path
```

### Pattern 2: Backup and Version Files

#### ❌ PROBLEMATIC FILES (AI-GENERATED)
```
myapp/
├── customer.py
├── customer_backup.py
├── customer_old.py
├── customer_v1.py
├── customer_v2.py
├── customer_final.py
├── customer_working.py
├── customer_copy.py
└── customer_new.py
```

#### ✅ CLEANED STRUCTURE
```
myapp/
└── customer.py  # Single file with best implementation
```

#### Cleanup Script
```python
def remove_backup_files(app_path):
    """Remove backup and version files created by AI tools"""
    
    backup_patterns = [
        r'.*_backup\.py$',
        r'.*_old\.py$',
        r'.*_v\d+\.py$',
        r'.*_copy\.py$',
        r'.*_new\.py$',
        r'.*_working\.py$',
        r'.*_final\.py$',
        r'.*_tmp\.py$',
        r'.*\.bak$'
    ]
    
    removed_files = []
    
    for root, dirs, files in os.walk(app_path):
        for file in files:
            for pattern in backup_patterns:
                if re.match(pattern, file):
                    file_path = os.path.join(root, file)
                    
                    # Check if it's actually redundant
                    if is_redundant_file(file_path):
                        os.rename(file_path, file_path + '.removed')
                        removed_files.append(file_path)
    
    return removed_files
```

---

## 🔗 EXTERNAL DEPENDENCY PATTERNS

### Pattern 1: HTTP Request Libraries

#### ❌ PROBLEMATIC CODE (AI-GENERATED)
```python
# AI often adds external HTTP libraries
import requests
import httpx
import urllib3
from aiohttp import ClientSession

class APIClient:
    def __init__(self, base_url):
        self.base_url = base_url
        self.session = requests.Session()
    
    def get_data(self, endpoint):
        url = f"{self.base_url}/{endpoint}"
        response = self.session.get(url)
        return response.json()
    
    def post_data(self, endpoint, data):
        url = f"{self.base_url}/{endpoint}"
        response = self.session.post(url, json=data)
        return response.json()

# Usage scattered throughout codebase
client = APIClient("https://api.example.com")
data = client.get_data("customers")
```

#### ✅ CLEANED CODE (FRAPPE BUILT-IN)
```python
# Use Frappe's built-in request capabilities
import frappe

class APIClient:
    def __init__(self, base_url):
        self.base_url = base_url
    
    def get_data(self, endpoint):
        url = f"{self.base_url}/{endpoint}"
        response = frappe.request.get(url)
        return response.json()
    
    def post_data(self, endpoint, data):
        url = f"{self.base_url}/{endpoint}"
        response = frappe.request.post(url, json=data)
        return response.json()

# Better: Use Frappe's integration patterns
@frappe.whitelist()
def fetch_external_data(endpoint):
    """Fetch data from external API"""
    base_url = frappe.db.get_single_value("API Settings", "base_url")
    url = f"{base_url}/{endpoint}"
    
    try:
        response = frappe.request.get(url, timeout=30)
        return response.json()
    except Exception as e:
        frappe.log_error(f"API request failed: {e}")
        frappe.throw("Failed to fetch external data")
```

### Pattern 2: Database Libraries

#### ❌ PROBLEMATIC CODE (AI-GENERATED)
```python
# AI adds database libraries instead of using Frappe ORM
import sqlalchemy
from sqlalchemy import create_engine, text
import pymysql
import psycopg2

class DatabaseManager:
    def __init__(self):
        self.engine = create_engine('mysql://user:pass@localhost/db')
    
    def get_customers(self):
        with self.engine.connect() as conn:
            result = conn.execute(text("SELECT * FROM tabCustomer"))
            return result.fetchall()
    
    def update_customer(self, customer_id, data):
        with self.engine.connect() as conn:
            conn.execute(text("""
                UPDATE tabCustomer 
                SET customer_name = :name, email = :email 
                WHERE name = :id
            """), {"name": data["name"], "email": data["email"], "id": customer_id})
            conn.commit()
```

#### ✅ CLEANED CODE (FRAPPE ORM)
```python
# Use Frappe's built-in ORM
import frappe

class CustomerManager:
    @staticmethod
    def get_customers(filters=None):
        """Get customers using Frappe ORM"""
        return frappe.get_all('Customer', 
            filters=filters or {},
            fields=['name', 'customer_name', 'email', 'territory']
        )
    
    @staticmethod
    def update_customer(customer_id, data):
        """Update customer using Frappe ORM"""
        customer = frappe.get_doc('Customer', customer_id)
        
        for field, value in data.items():
            setattr(customer, field, value)
        
        customer.save()
        return customer
    
    @staticmethod
    def create_customer(data):
        """Create customer using Frappe ORM"""
        customer = frappe.get_doc({
            'doctype': 'Customer',
            **data
        })
        customer.insert()
        return customer
```

---

## 🔒 CUSTOM AUTHENTICATION PATTERNS

### Pattern 1: JWT Implementation

#### ❌ PROBLEMATIC CODE (AI-GENERATED)
```python
# AI creates custom JWT authentication
import jwt
import datetime
from functools import wraps

class AuthManager:
    SECRET_KEY = "your-secret-key"
    
    @staticmethod
    def generate_token(user_id):
        payload = {
            'user_id': user_id,
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
        }
        return jwt.encode(payload, AuthManager.SECRET_KEY, algorithm='HS256')
    
    @staticmethod
    def verify_token(token):
        try:
            payload = jwt.decode(token, AuthManager.SECRET_KEY, algorithms=['HS256'])
            return payload['user_id']
        except jwt.ExpiredSignatureError:
            return None
        except jwt.InvalidTokenError:
            return None

def require_auth(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = request.headers.get('Authorization')
        if not token:
            return {'error': 'No token provided'}, 401
        
        user_id = AuthManager.verify_token(token)
        if not user_id:
            return {'error': 'Invalid token'}, 401
        
        return f(*args, **kwargs)
    return decorated_function

# Usage
@require_auth
@frappe.whitelist(allow_guest=True)  # Wrong!
def get_customer_data():
    return {"data": "sensitive"}
```

#### ✅ CLEANED CODE (FRAPPE AUTH)
```python
# Use Frappe's built-in authentication
import frappe

@frappe.whitelist()  # Proper Frappe authentication
def get_customer_data():
    """Get customer data - uses Frappe session authentication"""
    # Frappe automatically handles authentication
    # User must be logged in to access this endpoint
    
    # Check specific permissions if needed
    if not frappe.has_permission('Customer', 'read'):
        frappe.throw('Insufficient permissions')
    
    return {"data": "sensitive"}

@frappe.whitelist(allow_guest=False)  # Explicit: requires login
def get_secure_data():
    """Get secure data - requires authentication"""
    current_user = frappe.session.user
    
    # Additional role-based checks
    if 'System Manager' not in frappe.get_roles():
        frappe.throw('Access denied')
    
    return {"data": "very sensitive"}

# API key authentication for external integrations
@frappe.whitelist(allow_guest=True)
def api_endpoint():
    """API endpoint with API key authentication"""
    api_key = frappe.get_request_header('X-API-Key')
    
    if not api_key:
        frappe.throw('API key required')
    
    # Validate API key
    user = frappe.db.get_value('User', {'api_key': api_key}, 'name')
    if not user:
        frappe.throw('Invalid API key')
    
    # Set user context
    frappe.set_user(user)
    
    return {"status": "authenticated"}
```

### Pattern 2: Custom Permission System

#### ❌ PROBLEMATIC CODE (AI-GENERATED)
```python
# AI creates custom permission systems
class PermissionManager:
    PERMISSIONS = {
        'admin': ['create', 'read', 'write', 'delete'],
        'manager': ['create', 'read', 'write'],
        'user': ['read'],
        'guest': []
    }
    
    @staticmethod
    def has_permission(user_role, action):
        return action in PermissionManager.PERMISSIONS.get(user_role, [])
    
    @staticmethod
    def check_permission(user_role, action):
        if not PermissionManager.has_permission(user_role, action):
            raise PermissionError(f"User with role '{user_role}' cannot perform '{action}'")

def require_permission(action):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            user_role = get_user_role()  # Custom function
            PermissionManager.check_permission(user_role, action)
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@require_permission('write')
@frappe.whitelist()
def update_customer(customer_id, data):
    # Custom permission check conflicts with Frappe
    pass
```

#### ✅ CLEANED CODE (FRAPPE PERMISSIONS)
```python
# Use Frappe's Role Permission Manager
import frappe

@frappe.whitelist()
def update_customer(customer_id, data):
    """Update customer - uses Frappe's permission system"""
    
    # Frappe automatically checks DocType permissions
    # based on Role Permission Manager settings
    
    # Additional custom checks if needed
    if not frappe.has_permission('Customer', 'write', doc=customer_id):
        frappe.throw('You do not have permission to update this customer')
    
    # Check if user can access specific customer
    customer = frappe.get_doc('Customer', customer_id)
    
    # Custom business logic permission
    if customer.territory != frappe.db.get_value('User', frappe.session.user, 'territory'):
        if 'System Manager' not in frappe.get_roles():
            frappe.throw('You can only update customers in your territory')
    
    # Update customer
    for field, value in data.items():
        setattr(customer, field, value)
    
    customer.save()
    return customer

# Server Script for additional permission logic
def validate_customer_access(doc, method):
    """Additional validation via Server Script"""
    if method in ['before_save', 'before_submit']:
        # Custom business rules
        if doc.credit_limit > 100000:
            if 'Sales Manager' not in frappe.get_roles():
                frappe.throw('Only Sales Managers can set credit limit above 100,000')
```

---

## 🏗️ STRUCTURE PATTERNS

### Pattern 1: Weird Directory Organization

#### ❌ PROBLEMATIC STRUCTURE (AI-GENERATED)
```
myapp/
├── src/
│   ├── main/
│   │   ├── controllers/
│   │   ├── services/
│   │   └── utils/
│   └── test/
├── lib/
├── modules/
├── components/
├── helpers/
├── handlers/
├── managers/
└── processors/
```

#### ✅ CLEANED STRUCTURE (ERPNext STANDARD)
```
myapp/
├── myapp/
│   ├── __init__.py
│   ├── hooks.py
│   ├── modules.txt
│   ├── patches.txt
│   ├── config/
│   ├── public/
│   │   ├── css/
│   │   └── js/
│   ├── templates/
│   ├── www/
│   └── [module_name]/
│       ├── __init__.py
│       ├── doctype/
│       ├── page/
│       ├── report/
│       └── workspace/
├── requirements.txt
└── setup.py
```

### Pattern 2: Mixed Naming Conventions

#### ❌ PROBLEMATIC NAMING (AI-GENERATED)
```python
# Mixed conventions throughout codebase
class customerManager:  # camelCase class
    def GetCustomerData(self, customer_id):  # PascalCase method
        return self.fetchcustomerinfo(customer_id)  # lowercase method
    
    def fetchcustomerinfo(self, customerId):  # Mixed conventions
        customerData = frappe.get_doc("Customer", customerId)
        return customerData

def ProcessCustomerOrder(orderData):  # PascalCase function
    return process_order_data(orderData)

def process_order_data(order_data):  # snake_case function
    pass

# File names also inconsistent
# customerManager.py
# Customer_Utils.py
# customer-helpers.py
```

#### ✅ CLEANED NAMING (PYTHON/FRAPPE STANDARD)
```python
# Consistent Python/Frappe naming conventions
class CustomerManager:  # PascalCase for classes
    def get_customer_data(self, customer_id):  # snake_case for methods
        """Get customer data by ID"""
        return self._fetch_customer_info(customer_id)
    
    def _fetch_customer_info(self, customer_id):  # Private method with _
        """Fetch customer information from database"""
        customer_data = frappe.get_doc("Customer", customer_id)
        return customer_data

def process_customer_order(order_data):  # snake_case for functions
    """Process customer order data"""
    return _process_order_data(order_data)

def _process_order_data(order_data):  # Private function with _
    """Internal order processing logic"""
    pass

# File names: customer_manager.py, customer_utils.py, customer_helpers.py
```

---

## 🧹 CLEANUP AUTOMATION SCRIPTS

### Comprehensive Cleanup Tool

```python
import os
import re
import ast
import sys
from collections import defaultdict

class ERPNextCodeCleaner:
    def __init__(self, app_path):
        self.app_path = app_path
        self.issues_found = defaultdict(list)
        self.fixes_applied = defaultdict(list)
    
    def analyze_app(self):
        """Analyze app for common AI-generated issues"""
        
        for root, dirs, files in os.walk(self.app_path):
            for file in files:
                if file.endswith('.py'):
                    file_path = os.path.join(root, file)
                    self.analyze_file(file_path)
        
        return self.issues_found
    
    def analyze_file(self, file_path):
        """Analyze single file for issues"""
        
        try:
            with open(file_path, 'r') as f:
                content = f.read()
            
            # Check for external dependencies
            self.check_external_dependencies(file_path, content)
            
            # Check for duplicate functions
            self.check_duplicate_functions(file_path, content)
            
            # Check for custom auth patterns
            self.check_custom_auth(file_path, content)
            
            # Check for direct SQL usage
            self.check_direct_sql(file_path, content)
            
        except Exception as e:
            self.issues_found['file_errors'].append(f"{file_path}: {e}")
    
    def check_external_dependencies(self, file_path, content):
        """Check for external library usage"""
        
        external_imports = [
            'import requests',
            'import pandas',
            'import sqlalchemy',
            'import celery',
            'import redis',
            'import jwt',
            'import bcrypt'
        ]
        
        for imp in external_imports:
            if imp in content:
                self.issues_found['external_dependencies'].append({
                    'file': file_path,
                    'import': imp,
                    'line_numbers': [i+1 for i, line in enumerate(content.split('\n')) if imp in line]
                })
    
    def check_duplicate_functions(self, file_path, content):
        """Check for duplicate function patterns"""
        
        try:
            tree = ast.parse(content)
            functions = []
            
            for node in ast.walk(tree):
                if isinstance(node, ast.FunctionDef):
                    functions.append({
                        'name': node.name,
                        'line': node.lineno,
                        'args': [arg.arg for arg in node.args.args]
                    })
            
            # Find similar function names
            function_groups = defaultdict(list)
            for func in functions:
                # Group by similar names
                base_name = re.sub(r'(get|fetch|retrieve|load)_', '', func['name'])
                base_name = re.sub(r'_(data|info|details)$', '', base_name)
                function_groups[base_name].append(func)
            
            for base_name, group in function_groups.items():
                if len(group) > 1:
                    self.issues_found['duplicate_functions'].append({
                        'file': file_path,
                        'base_name': base_name,
                        'functions': group
                    })
                    
        except Exception as e:
            pass  # Skip files with syntax errors
    
    def check_custom_auth(self, file_path, content):
        """Check for custom authentication patterns"""
        
        auth_patterns = [
            r'def.*authenticate.*\(',
            r'def.*login.*\(',
            r'@.*require.*auth',
            r'jwt\.encode',
            r'jwt\.decode',
            r'bcrypt\.',
            r'class.*Auth.*Manager'
        ]
        
        for pattern in auth_patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            if matches:
                self.issues_found['custom_auth'].append({
                    'file': file_path,
                    'pattern': pattern,
                    'matches': matches
                })
    
    def check_direct_sql(self, file_path, content):
        """Check for direct SQL usage"""
        
        sql_patterns = [
            r'frappe\.db\.sql.*SELECT',
            r'frappe\.db\.sql.*INSERT',
            r'frappe\.db\.sql.*UPDATE',
            r'frappe\.db\.sql.*DELETE',
            r'cursor\.execute',
            r'connection\.execute'
        ]
        
        for pattern in sql_patterns:
            matches = re.findall(pattern, content, re.IGNORECASE)
            if matches:
                self.issues_found['direct_sql'].append({
                    'file': file_path,
                    'pattern': pattern,
                    'matches': matches
                })
    
    def apply_fixes(self):
        """Apply automated fixes where safe"""
        
        for file_path, issues in self.issues_found.items():
            if file_path in ['external_dependencies', 'custom_auth', 'direct_sql']:
                continue
                
            # Apply safe fixes
            self.fix_file_issues(file_path, issues)
    
    def generate_report(self):
        """Generate cleanup report"""
        
        report = ["# ERPNext App Cleanup Report\n"]
        
        for issue_type, issues in self.issues_found.items():
            if issues:
                report.append(f"## {issue_type.replace('_', ' ').title()}\n")
                
                for issue in issues:
                    if isinstance(issue, dict) and 'file' in issue:
                        report.append(f"- **File:** `{issue['file']}`")
                        if 'matches' in issue:
                            report.append(f"  - **Matches:** {len(issue['matches'])}")
                        report.append("")
                    else:
                        report.append(f"- {issue}")
                        report.append("")
        
        return '\n'.join(report)

if __name__ == "__main__":
    app_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    cleaner = ERPNextCodeCleaner(app_path)
    issues = cleaner.analyze_app()
    
    print("=== ERPNEXT CODE CLEANUP ANALYSIS ===")
    print(cleaner.generate_report())
    
    # Optionally apply fixes
    # cleaner.apply_fixes()
```

---

## 📊 PATTERN DETECTION METRICS

### Quality Indicators

#### Red Flags (High Priority Issues)
1. **Multiple functions with similar names** (90%+ similarity)
2. **External dependencies** that have Frappe equivalents
3. **Custom authentication systems** bypassing Frappe auth
4. **Direct SQL queries** instead of ORM usage
5. **Backup/version files** in production directories

#### Yellow Flags (Medium Priority Issues)
1. **Inconsistent naming conventions** across files
2. **Duplicated logic** with minor variations
3. **Unnecessary file structures** not following ERPNext patterns
4. **Missing error handling** in critical functions
5. **Hardcoded configuration** instead of using settings

#### Green Flags (Good Patterns)
1. **Single responsibility functions** with clear purposes
2. **Frappe-first development** using built-in capabilities
3. **Proper ERPNext structure** following conventions
4. **Comprehensive error handling** with proper logging
5. **Configuration via DocTypes** or site config

### Success Metrics
- **Code Reduction:** 20-40% reduction in redundant code
- **Dependency Cleanup:** 80%+ reduction in external dependencies
- **Structure Compliance:** 95%+ adherence to ERPNext patterns
- **Function Consolidation:** 60%+ reduction in duplicate functions
- **Performance Improvement:** 10-30% faster execution times

Remember: **Every cleanup operation should improve code quality while maintaining 100% functionality!**