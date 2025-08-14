# Claude Coding Rules for ERPNext/Frappe Development

## Core Principles

### 1. Incremental Development
- Build one feature at a time
- Verify each step works before proceeding
- Commit working code frequently
- Never build everything then hope it works

### 2. Validation-First Approach
```bash
# After EVERY code generation:
1. Check file was created correctly
2. Verify syntax is valid
3. Test the specific functionality
4. Document what actually worked
```

### 3. Error Handling Priority
- Expect things to fail
- Always have a rollback plan
- Parse error messages carefully
- Fix based on actual errors, not assumptions

## ERPNext/Frappe Specific Rules

### DocType Development
```python
# ALWAYS follow this sequence:
1. Create minimal DocType first (just name field)
2. Run: bench --site {site} migrate
3. Verify table created in database
4. Add fields one by one, migrating after each
5. Add controller methods incrementally
```

### API Development
```python
# MANDATORY for all APIs:
@frappe.whitelist()  # Never forget this decorator
def api_method():
    # Always validate permissions first
    if not frappe.has_permission("DocType", "read"):
        frappe.throw("Insufficient permissions")
    
    # Always use try/except for database operations
    try:
        # Your logic here
        frappe.db.commit()  # Explicit commit when needed
    except Exception as e:
        frappe.log_error(f"API Error: {str(e)}")
        frappe.throw("An error occurred")
```

### Frontend Development (Vue + frappe-ui)
```javascript
// ALWAYS verify before using:
1. Check frappe-ui is installed: yarn list frappe-ui
2. Verify CSRF token handling in development
3. Test API calls work before building UI
4. Use createResource() for all API calls
5. Handle loading and error states explicitly
```

## Code Generation Rules

### 1. Never Generate Without Context
```yaml
BEFORE generating any code:
- Check what already exists
- Understand the environment
- Verify dependencies are available
- Know the exact file paths
```

### 2. Always Include Verification
```python
# After generating code, ALWAYS add:
def verify_functionality():
    """Test that this actually works"""
    try:
        # Actual test of the functionality
        result = the_function_you_created()
        assert result is not None
        return True
    except Exception as e:
        print(f"Verification failed: {e}")
        return False
```

### 3. Progressive Enhancement
```yaml
Start Simple:
  - Basic functionality first
  - No optimization initially
  - No complex features
  
Then Enhance:
  - Add validation
  - Add error handling
  - Add performance optimization
  - Add advanced features
```

## Common Pitfalls to Avoid

### 1. Import Errors
```python
# WRONG - Assuming module exists
from some_module import something

# RIGHT - Check first, handle gracefully
try:
    from some_module import something
except ImportError:
    frappe.log_error("Module 'some_module' not found")
    something = None  # Provide fallback
```

### 2. Database Operations
```python
# WRONG - No error handling
frappe.db.sql("INSERT INTO table...")

# RIGHT - Proper error handling
try:
    frappe.db.sql("INSERT INTO table...")
    frappe.db.commit()
except frappe.db.OperationalError as e:
    frappe.db.rollback()
    frappe.log_error(f"Database error: {e}")
```

### 3. Frontend API Calls
```javascript
// WRONG - No error handling
const data = await call('api.method')

// RIGHT - Complete error handling
try {
    const response = await call('api.method')
    if (response.error) {
        console.error('API error:', response.error)
        // Handle error in UI
    }
} catch (error) {
    console.error('Network error:', error)
    // Show user-friendly error message
}
```

## Testing Rules

### Always Test Incrementally
```bash
# After creating DocType:
bench --site {site} console
>>> frappe.get_meta('YourDocType')  # Should return metadata

# After creating API:
bench --site {site} execute your_app.api.module.method

# After frontend changes:
yarn dev  # Check for compilation errors first
# Then test in browser with console open
```

### Rollback Procedures
```bash
# If DocType creation fails:
1. Remove the directory: rm -rf apps/{app}/{module}/doctype/{doctype}
2. Clear cache: bench --site {site} clear-cache
3. Try again with simpler structure

# If API fails:
1. Check error logs: bench --site {site} show-logs
2. Verify permissions and user context
3. Test with simpler logic first

# If frontend fails:
1. Check browser console for errors
2. Verify API endpoints are accessible
3. Test with minimal component first
```

## Communication Rules

### When Reporting Status
```markdown
✅ COMPLETED: [Specific action taken]
⚠️ ISSUE: [Specific problem encountered]
🔧 FIXING: [How you're addressing it]
📝 TODO: [What needs to be done next]
```

### When Encountering Errors
```markdown
ERROR ENCOUNTERED:
- Error message: [Exact error]
- Context: [What was being attempted]
- Attempted fix: [What was tried]
- Next step: [Proposed solution]
```

## Production Readiness Checklist

Before claiming something is "ready":
- [ ] File exists at correct path
- [ ] Syntax is valid (no parse errors)
- [ ] Basic functionality tested
- [ ] Error handling implemented
- [ ] Rollback procedure documented
- [ ] Integration points verified
- [ ] Performance acceptable
- [ ] Security considered

## Remember

**You are a code generator, not an autonomous builder.** Work WITH the human to:
1. Generate code
2. Test it together
3. Fix issues based on real errors
4. Document what actually works
5. Build confidence through verification

Never claim something works without verification. Always be ready to debug and fix.