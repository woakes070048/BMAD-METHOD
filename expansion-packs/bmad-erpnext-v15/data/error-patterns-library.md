# error-patterns-library

**Resource:** Common ERPNext/Frappe error patterns and their solutions

**Category:** Debugging Reference  
**For:** diagnostic-specialist agent and troubleshooting teams  

## Overview

This library contains common error patterns encountered in ERPNext/Frappe development along with their root causes and proven solutions.

## Import and Module Errors

### ImportError: No module named 'app_name'

**Pattern:**
```
ImportError: No module named 'custom_app'
Traceback (most recent call last):
  File "/home/frappe/frappe-bench/apps/frappe/frappe/__init__.py", line 7, in <module>
    import custom_app
```

**Root Causes:**
1. App not installed with `bench get-app`
2. App not installed on specific site
3. App directory name mismatch
4. Python path issues

**Solutions:**
```bash
# Install app if not present
bench get-app custom_app [repository_url]

# Install app on site
bench --site [site-name] install-app custom_app

# Check if app is installed
bench list-apps
bench --site [site-name] list-apps

# Verify app directory structure
ls -la apps/custom_app/custom_app/__init__.py
```

### ImportError: cannot import name 'function_name'

**Pattern:**
```
ImportError: cannot import name 'validate_customer' from 'custom_app.utils'
```

**Root Causes:**
1. Function doesn't exist in target module
2. Circular import dependencies
3. Function name typo or case mismatch

**Solutions:**
```python
# Check if function exists
grep -r "def validate_customer" apps/custom_app/

# Check for circular imports
python -c "import custom_app.utils"

# Verify exact function name and case
cat apps/custom_app/custom_app/utils.py | grep "def "
```

## Database Errors

### OperationalError: (2006, 'MySQL server has gone away')

**Pattern:**
```
pymysql.err.OperationalError: (2006, "MySQL server has gone away")
```

**Root Causes:**
1. Database connection timeout
2. Query too large for max_allowed_packet
3. Database server restart
4. Connection pool exhaustion

**Solutions:**
```bash
# Check database configuration
bench --site [site-name] console
>>> frappe.db.sql("SHOW VARIABLES LIKE 'wait_timeout'")
>>> frappe.db.sql("SHOW VARIABLES LIKE 'max_allowed_packet'")

# Restart database service
sudo systemctl restart mariadb

# Check database connectivity
bench --site [site-name] mariadb
```

### ProgrammingError: Table doesn't exist

**Pattern:**
```
pymysql.err.ProgrammingError: (1146, "Table 'site_db.tabCustom DocType' doesn't exist")
```

**Root Causes:**
1. DocType not migrated to database
2. Migration failure
3. DocType name mismatch

**Solutions:**
```bash
# Check pending migrations
bench --site [site-name] show-pending-migrations

# Run migrations
bench --site [site-name] migrate

# Check DocType exists in meta
bench --site [site-name] console
>>> frappe.get_meta("Custom DocType")

# Check table exists
bench --site [site-name] mariadb
> SHOW TABLES LIKE 'tabCustom DocType';
```

## Permission Errors

### PermissionError: Insufficient permission for User

**Pattern:**
```
frappe.exceptions.PermissionError: Insufficient permission for User john@company.com for Sales Order
```

**Root Causes:**
1. User lacks required role
2. Role permissions not configured
3. Document-level permissions restrict access
4. User permissions limit access

**Solutions:**
```bash
# Check user roles
bench --site [site-name] console
>>> user = frappe.get_doc("User", "john@company.com")
>>> user.get_roles()

# Check role permissions for DocType
>>> frappe.db.get_all("Custom Role Permission", {"parent": "Sales Order"})

# Grant role to user
>>> user.add_roles("Sales User")

# Check specific permission
>>> frappe.has_permission("Sales Order", "read", user="john@company.com")
```

### ValidationError: Please select a Company

**Pattern:**
```
frappe.exceptions.ValidationError: Please select a Company
```

**Root Causes:**
1. Company field is mandatory but not set
2. User doesn't have access to any company
3. Default company not configured

**Solutions:**
```python
# Set default company for user
frappe.db.set_value("User", "john@company.com", "company", "My Company")

# Check user permissions for company
frappe.get_all("User Permission", 
    filters={"user": "john@company.com", "allow": "Company"})

# Set in user defaults
user_defaults = frappe.get_user().defaults
user_defaults.company = "My Company"
```

## API and Frontend Errors

### 403 Forbidden on API calls

**Pattern:**
```
HTTP 403 Forbidden
{
  "message": "Insufficient Permission for User",
  "exception": "frappe.exceptions.PermissionError"
}
```

**Root Causes:**
1. API method missing `@frappe.whitelist()` decorator
2. User lacks permissions for underlying DocType
3. Guest access not allowed

**Solutions:**
```python
# Add whitelist decorator
@frappe.whitelist()
def custom_api_method():
    return {"status": "success"}

# Allow guest access if needed
@frappe.whitelist(allow_guest=True)
def public_api_method():
    return {"data": "public"}

# Check method permissions
@frappe.whitelist(methods=['POST'])
def create_record():
    # Only allow POST requests
    pass
```

### JavaScript Console Errors

**Pattern:**
```
Uncaught ReferenceError: frappe is not defined
TypeError: Cannot read property 'call' of undefined
```

**Root Causes:**
1. Scripts loading before frappe framework
2. Missing script includes
3. Wrong execution context

**Solutions:**
```javascript
// Ensure frappe is loaded first
frappe.ready(() => {
    // Your code here
});

// Check if frappe exists
if (typeof frappe !== 'undefined') {
    frappe.call({
        method: 'custom_app.api.method'
    });
}

// Use proper async loading
$(document).ready(function() {
    // DOM manipulation code
});
```

## Performance Issues

### Slow Database Queries

**Pattern:**
```
Query took 2.5 seconds:
SELECT * FROM `tabSales Order` WHERE customer = 'CUST001'
```

**Root Causes:**
1. Missing database indexes
2. N+1 query problems
3. Full table scans
4. Unnecessary data fetching

**Solutions:**
```python
# Add database index
frappe.db.add_index("Sales Order", ["customer"])

# Use optimized queries
# Instead of:
orders = frappe.get_all("Sales Order", {"customer": customer})
for order in orders:
    items = frappe.get_all("Sales Order Item", {"parent": order.name})

# Use:
orders = frappe.get_all("Sales Order",
    filters={"customer": customer},
    fields=["name", "total", "status"])

# Or use single query with joins
orders_with_items = frappe.db.sql("""
    SELECT so.name, so.total, soi.item_code, soi.qty
    FROM `tabSales Order` so
    LEFT JOIN `tabSales Order Item` soi ON so.name = soi.parent
    WHERE so.customer = %s
""", customer, as_dict=True)
```

### High Memory Usage

**Pattern:**
```
MemoryError: Unable to allocate memory
Process killed due to memory limit
```

**Root Causes:**
1. Large dataset processing without pagination
2. Memory leaks in loops
3. Inefficient data structures

**Solutions:**
```python
# Use pagination for large datasets
def process_large_dataset():
    start = 0
    page_size = 1000
    
    while True:
        records = frappe.get_all("Large DocType",
            fields=["name"],
            start=start,
            page_length=page_size)
        
        if not records:
            break
            
        for record in records:
            process_record(record)
        
        start += page_size

# Use generators for memory efficiency
def get_records_generator():
    for record in frappe.db.sql_list("SELECT name FROM `tabLarge DocType`"):
        yield frappe.get_doc("Large DocType", record)
```

## Configuration Issues

### Site Creation Failures

**Pattern:**
```
ERROR: Could not create site site1.local
MariaDB access denied for user 'root'@'localhost'
```

**Root Causes:**
1. Database user permissions
2. MariaDB configuration
3. Site already exists

**Solutions:**
```bash
# Check database access
mysql -u root -p -e "SELECT User, Host FROM mysql.user;"

# Reset MariaDB root password if needed
sudo mysql_secure_installation

# Drop existing site if corrupted
bench drop-site site1.local --force

# Create with specific database user
bench new-site site1.local --db-name site1_db --db-user frappe_user
```

### App Installation Failures

**Pattern:**
```
ERROR: Could not install app custom_app
No module named 'custom_app.hooks'
```

**Root Causes:**
1. Missing hooks.py file
2. Incorrect app structure
3. Setup.py configuration errors

**Solutions:**
```python
# Create proper hooks.py
# File: apps/custom_app/custom_app/hooks.py
app_name = "custom_app"
app_title = "Custom App"
app_publisher = "Your Company"
app_description = "Description"
app_version = "0.0.1"

# Verify setup.py
# File: apps/custom_app/setup.py
from setuptools import setup, find_packages

setup(
    name='custom_app',
    version='0.0.1',
    packages=find_packages(),
    zip_safe=False,
    include_package_data=True,
    install_requires=["frappe"]
)

# Reinstall app
bench get-app custom_app --branch main
bench --site [site-name] install-app custom_app
```

## Environment Setup Issues

### Bench Installation Problems

**Pattern:**
```
Permission denied: '/home/frappe/.local/bin/bench'
Command 'bench' not found
```

**Root Causes:**
1. Bench not in PATH
2. Incorrect installation
3. User permissions

**Solutions:**
```bash
# Add bench to PATH
echo 'export PATH=$PATH:~/.local/bin' >> ~/.bashrc
source ~/.bashrc

# Verify bench installation
which bench
bench --version

# Reinstall bench if needed
pip3 install frappe-bench --user
```

### Node.js and Asset Building Issues

**Pattern:**
```
Error: Cannot find module 'rollup'
npm ERR! peer dep missing: rollup@^2.0.0
```

**Root Causes:**
1. Missing Node.js dependencies
2. Version compatibility issues
3. Build process failures

**Solutions:**
```bash
# Update Node.js to LTS version
nvm install --lts
nvm use --lts

# Clear and reinstall node modules
rm -rf node_modules package-lock.json
npm install

# Build assets
bench build
```

## Recovery Procedures

### Database Corruption Recovery

**Steps:**
1. Stop all bench processes
2. Create database backup
3. Check database integrity
4. Repair corrupted tables
5. Restore from backup if needed

```bash
# Stop bench
bench use [site-name]
bench stop

# Backup database
bench backup --with-files

# Check table integrity
bench --site [site-name] mariadb
> CHECK TABLE `tabSales Order`;
> REPAIR TABLE `tabSales Order`;
```

### Site Restoration

**Steps:**
1. Create new site
2. Restore database backup
3. Restore files backup
4. Migrate to current version
5. Rebuild assets

```bash
# Create new site
bench new-site restored-site.local

# Restore from backup
bench --site restored-site.local restore database_backup.sql.gz
bench --site restored-site.local restore --with-private-files files_backup.tar

# Migrate and build
bench --site restored-site.local migrate
bench build
```

## Prevention Strategies

### Code Quality Prevention
- Use linting tools (flake8, pylint)
- Implement pre-commit hooks
- Write comprehensive tests
- Regular code reviews

### Performance Prevention
- Monitor query performance
- Use database indexes appropriately
- Implement caching strategies
- Regular performance testing

### Environment Prevention
- Document environment setup steps
- Use configuration management
- Regular backup procedures
- Environment monitoring

### Error Monitoring
- Implement logging throughout application
- Use error tracking services
- Set up alerts for critical errors
- Regular log analysis

## Diagnostic Commands Quick Reference

```bash
# Site and app status
bench status
bench list-apps
bench --site [site-name] list-apps

# Database connectivity  
bench --site [site-name] console
>>> frappe.db.sql("SELECT 1")

# Permission debugging
>>> frappe.has_permission("DocType", "read")
>>> frappe.get_roles()

# Migration status
bench --site [site-name] show-pending-migrations

# Log monitoring
tail -f logs/bench.log
tail -f logs/[site-name].log

# System resources
top
df -h
free -h

# Database queries
bench --site [site-name] mariadb
> SHOW PROCESSLIST;
> EXPLAIN SELECT...
```

This error patterns library provides a comprehensive reference for common issues and their solutions in ERPNext/Frappe development.