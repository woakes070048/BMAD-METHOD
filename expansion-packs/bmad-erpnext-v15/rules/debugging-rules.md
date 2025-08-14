# Debugging Rules for ERPNext/Frappe Development

## Systematic Debugging Approach

### 1. Read the Error Message Carefully
```python
# Example error:
# AttributeError: 'NoneType' object has no attribute 'get'

# This tells you:
# - You're calling .get() on None
# - Something returned None when you expected an object
# - Look for the line number and trace backward

# Common patterns:
# ImportError → Module not installed or path incorrect
# OperationalError → Database issue, migration needed
# PermissionError → User lacks required permissions
# ValidationError → Data doesn't meet requirements
```

### 2. Identify Error Context
```bash
# Check which layer has the issue:

# Frontend (Browser)
- Open browser console (F12)
- Check Network tab for failed API calls
- Look for JavaScript errors

# API Layer
- Check bench logs
- Look for @frappe.whitelist() decorator
- Verify permissions

# Backend (Python)
- Use frappe.log_error() to capture stack traces
- Check DocType controllers
- Verify database state

# Database
- Check if tables exist
- Verify migrations ran
- Look for constraint violations
```

## Common Error Patterns and Fixes

### 1. Import Errors
```python
# ERROR: ImportError: No module named 'your_app'

# DIAGNOSIS STEPS:
1. Check if app is installed:
   bench --site site.local list-apps
   
2. Check Python path:
   bench --site site.local console
   >>> import sys
   >>> print(sys.path)
   
3. Check if file exists:
   ls apps/your_app/your_app/module.py

# FIXES:
# If app not installed:
bench --site site.local install-app your_app

# If file missing:
# Check spelling and path

# If import still fails:
bench --site site.local clear-cache
bench restart
```

### 2. Database Errors
```python
# ERROR: OperationalError: no such table: tabYourDocType

# DIAGNOSIS:
1. Check if DocType JSON exists:
   ls apps/*/doctype/your_doctype/

2. Check database tables:
   bench --site site.local mariadb
   > SHOW TABLES LIKE 'tabYour%';

# FIX:
bench --site site.local migrate

# If migrate fails:
1. Check JSON syntax in DocType file
2. Remove DocType directory and recreate
3. Clear cache and migrate again
```

### 3. Permission Errors
```python
# ERROR: frappe.PermissionError: No permission for Customer

# DIAGNOSIS:
bench --site site.local console
>>> frappe.set_user("your-user@example.com")
>>> frappe.get_roles()
>>> frappe.has_permission("Customer", "read")

# FIX:
# Add role to user:
bench --site site.local add-role your-user@example.com "Sales User"

# Or in code:
@frappe.whitelist()
def your_method():
    # Skip permission check if needed (use carefully)
    doc = frappe.get_doc("Customer", "CUST-0001")
    doc.flags.ignore_permissions = True
    doc.save()
```

### 4. Frontend API Errors
```javascript
// ERROR: 403 Forbidden on API call

// DIAGNOSIS:
// 1. Check browser console Network tab
// 2. Look at request headers - is CSRF token present?
// 3. Check response body for specific error

// FIX for development:
// Add to site_config.json:
{
    "ignore_csrf": 1
}

// FIX for production:
// Ensure CSRF token is set:
frappeRequest.configure({
    headers: {
        'X-Frappe-CSRF-Token': window.csrf_token
    }
})
```

## Debugging Tools and Techniques

### 1. Logging and Tracing
```python
# Add debug logging
import frappe

def problematic_function(data):
    # Log entry point
    frappe.log_error(f"Starting with data: {data}", "Debug")
    
    try:
        # Log each step
        frappe.log_error(f"Step 1: Processing", "Debug")
        result = process_data(data)
        
        frappe.log_error(f"Step 2: Result = {result}", "Debug")
        
        if not result:
            frappe.log_error("Result is None!", "Warning")
            
        return result
        
    except Exception as e:
        # Log full traceback
        frappe.log_error(frappe.get_traceback(), "Error in problematic_function")
        raise

# View logs:
# bench --site site.local show-logs
```

### 2. Interactive Debugging
```python
# Use bench console for interactive debugging
bench --site site.local console

>>> import frappe
>>> frappe.set_user("Administrator")
>>> 
>>> # Test your function
>>> from your_app.module import your_function
>>> result = your_function("test")
>>> 
>>> # Inspect objects
>>> doc = frappe.get_doc("Customer", "CUST-0001")
>>> print(doc.as_dict())
>>> 
>>> # Test database queries
>>> frappe.db.sql("SELECT * FROM tabCustomer LIMIT 1", as_dict=True)
```

### 3. Browser Debugging
```javascript
// Add breakpoints in browser
debugger; // Execution will pause here

// Console logging
console.log('Data:', data);
console.error('Error occurred:', error);
console.table(arrayData); // Display array as table

// Network inspection
// F12 → Network tab → Filter by XHR
// Check request payload and response

// Vue DevTools
// Install Vue DevTools extension
// Inspect component state and props
```

## Step-by-Step Debugging Process

### 1. Reproduce the Error
```markdown
1. Document exact steps to reproduce
2. Note any error messages verbatim
3. Check if error is consistent
4. Test in different environments (dev/prod)
```

### 2. Isolate the Problem
```python
# Start with minimal code
def test_minimal():
    # Remove everything except core issue
    try:
        # Just the problematic line
        result = frappe.get_doc("DocType", "name")
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False

# Gradually add complexity back
```

### 3. Binary Search Method
```python
# Comment out half the code
# If error persists, problem is in remaining half
# If error gone, problem is in commented half
# Repeat until you find the exact line

def complex_function():
    step1()  # Works
    step2()  # Works
    # step3()  # Comment out
    # step4()  # Comment out
    # step5()  # Comment out
    
    # If error persists, problem is in step1 or step2
    # If error gone, problem is in step3, step4, or step5
```

## Common Debugging Scenarios

### 1. DocType Not Working
```bash
# Checklist:
□ JSON file exists and is valid JSON
□ Python controller has correct class name
□ Module directory structure is correct
□ Migrations ran successfully
□ Permissions are set
□ No naming conflicts

# Debug commands:
bench --site site.local console
>>> frappe.get_meta("YourDocType")  # Should return metadata
>>> frappe.get_doc("YourDocType", "TEST-001")  # Try to fetch
>>> frappe.new_doc("YourDocType")  # Try to create
```

### 2. API Not Responding
```python
# Checklist:
□ @frappe.whitelist() decorator present
□ Method is in correct module path
□ No syntax errors in Python file
□ User has permissions

# Debug approach:
# 1. Test in console first
bench --site site.local console
>>> from your_app.api import your_method
>>> your_method()  # Should work here

# 2. Test with curl
curl -X POST http://site.local/api/method/your_app.api.your_method

# 3. Check logs for errors
tail -f logs/web.error.log
```

### 3. Frontend Not Loading
```javascript
// Checklist:
□ Build completed without errors
□ Assets are being served
□ No JavaScript errors in console
□ API endpoints are accessible
□ Correct routing configuration

// Debug steps:
// 1. Check build
yarn build
// Look for errors

// 2. Check browser console
// F12 → Console tab
// Look for red errors

// 3. Check network
// F12 → Network tab
// Look for 404s or 500s

// 4. Test API manually
fetch('/api/method/your_method')
  .then(r => r.json())
  .then(console.log)
  .catch(console.error)
```

## Performance Debugging

### 1. Slow Queries
```python
# Enable query logging
bench --site site.local console
>>> frappe.db.debug = True
>>> # Run your slow operation
>>> # Check queries being executed

# Analyze slow queries
bench --site site.local mariadb
> EXPLAIN SELECT * FROM tabYourTable WHERE condition;

# Add indexes if needed
> CREATE INDEX idx_field ON tabYourTable(field);
```

### 2. Memory Issues
```python
# Monitor memory usage
import tracemalloc
tracemalloc.start()

# Your code here
problematic_function()

# Get memory snapshot
snapshot = tracemalloc.take_snapshot()
top_stats = snapshot.statistics('lineno')

for stat in top_stats[:10]:
    print(stat)
```

## Error Recovery Strategies

### 1. Rollback Changes
```bash
# If DocType creation failed:
rm -rf apps/your_app/your_app/doctype/broken_doctype
bench --site site.local clear-cache
bench --site site.local migrate

# If database is corrupted:
bench --site site.local restore backup.sql

# If frontend broken:
git checkout -- frontend/
yarn install
yarn build
```

### 2. Clean State Reset
```bash
# Full reset (development only):
bench --site site.local reinstall
bench --site site.local install-app your_app

# Partial reset:
bench --site site.local clear-cache
bench --site site.local clear-website-cache
bench restart
```

## Debugging Checklist

### Before Starting:
- [ ] Can you reproduce the error?
- [ ] Do you have the exact error message?
- [ ] Have you checked the logs?
- [ ] Is this a new issue or regression?

### During Debugging:
- [ ] Read error message carefully
- [ ] Check stack trace for clues
- [ ] Isolate the problem area
- [ ] Test with minimal code
- [ ] Add logging/breakpoints
- [ ] Check documentation

### After Fixing:
- [ ] Test the fix thoroughly
- [ ] Check for side effects
- [ ] Document the solution
- [ ] Add error handling
- [ ] Consider adding tests
- [ ] Commit working code

## Pro Tips

1. **Use Version Control**: Commit before making changes so you can revert
2. **Keep Notes**: Document what you tried and what worked
3. **Take Breaks**: Fresh eyes often spot obvious issues
4. **Ask for Help**: Share complete error messages and context
5. **Learn from Errors**: Build a personal knowledge base of fixes

## Remember

- **Errors are information**: They tell you exactly what's wrong
- **Be systematic**: Random changes rarely fix issues
- **Trust the error**: The error message is usually right
- **Start simple**: Verify basics before assuming complex issues
- **Document findings**: Future you will thank present you