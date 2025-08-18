# diagnose-runtime-error

**Task:** Systematic diagnosis of runtime errors and failures in ERPNext applications

**Agent:** diagnostic-specialist  
**Category:** Debugging & Diagnostics  
**Elicit:** true  
**Prerequisites:** Error message or symptoms description  

## Overview

This task provides a systematic approach to diagnosing runtime errors, performance issues, and unexpected behavior in ERPNext applications.

## Input Requirements

**Required:**
- Complete error message (if available)
- Description of when the error occurs
- Steps to reproduce the issue

**Optional:**
- Log files (error logs, browser console)
- Recent changes made to the system
- Environment details (development vs production)
- Screenshots or videos of the issue

## Process Steps

### Step 1: Error Information Gathering
1. **Capture complete error details:**
   ```
   Error message: [exact error text]
   Error type: [ImportError, AttributeError, etc.]
   File location: [file and line number]
   Stack trace: [complete traceback]
   Timestamp: [when error occurred]
   ```

2. **Document reproduction steps:**
   - What user action triggered the error?
   - Can the error be reproduced consistently?
   - Does it occur in all environments?
   - Are there any patterns or conditions?

3. **Check system context:**
   - Recent code changes or deployments
   - Environment configuration changes
   - New app installations or updates
   - Database migrations or schema changes

### Step 2: Initial Analysis
1. **Classify the error type:**
   - **Import/Module errors:** Missing dependencies or path issues
   - **Database errors:** Connection, query, or schema issues  
   - **Permission errors:** Access control or authentication issues
   - **Validation errors:** Data validation or business rule violations
   - **Frontend errors:** JavaScript, rendering, or API issues
   - **Configuration errors:** Site or app configuration problems

2. **Identify the failure point:**
   - Exact line and function where error occurs
   - Call stack leading to the error
   - Input data that triggers the failure
   - Expected vs actual behavior

### Step 3: Root Cause Investigation
1. **For Import/Module Errors:**
   ```bash
   # Check if module/app is installed
   bench list-apps
   
   # Verify app is enabled for site  
   bench --site [site-name] list-apps
   
   # Check Python path and imports
   bench --site [site-name] console
   >>> import [module-name]
   ```

2. **For Database Errors:**
   ```bash
   # Check database connectivity
   bench --site [site-name] console
   >>> frappe.db.sql("SELECT 1")
   
   # Check recent migrations
   bench --site [site-name] show-pending-migrations
   
   # Verify DocType exists
   bench --site [site-name] console
   >>> frappe.get_meta("DocType Name")
   ```

3. **For Permission Errors:**
   ```bash
   # Check user permissions
   bench --site [site-name] console
   >>> frappe.has_permission("DocType", "read", user="user@example.com")
   
   # Check role assignments
   >>> user = frappe.get_doc("User", "user@example.com")
   >>> user.get_roles()
   ```

4. **For Frontend Errors:**
   - Check browser console for JavaScript errors
   - Verify API endpoints are accessible
   - Test with network debugging tools
   - Check for CORS or authentication issues

### Step 4: Environment Verification
1. **Check system status:**
   ```bash
   # Verify bench status
   bench status
   
   # Check site status
   bench --site [site-name] console
   >>> frappe.init()
   
   # Verify dependencies
   pip list | grep [package-name]
   ```

2. **Validate configuration:**
   ```bash
   # Check site config
   cat sites/[site-name]/site_config.json
   
   # Verify hooks configuration
   grep -r "hooks" apps/[app-name]
   
   # Check app installation
   bench --site [site-name] list-apps --format table
   ```

### Step 5: Targeted Testing
1. **Create minimal reproduction:**
   - Strip down to simplest case that fails
   - Test with fresh data or clean environment
   - Isolate the specific component causing issues

2. **Test hypotheses:**
   - Apply suspected fixes in development
   - Test with different data sets
   - Verify fix doesn't break other functionality

## Diagnostic Tools and Commands

### Log Analysis
```bash
# Check frappe error logs
tail -f logs/bench.log

# Check specific site logs  
tail -f logs/[site-name].log

# Check nginx/web server logs
sudo tail -f /var/log/nginx/error.log
```

### Database Debugging
```bash
# Connect to database directly
bench --site [site-name] mariadb

# Check database schema
DESCRIBE `tab[DocType Name]`;

# Review recent database changes
SHOW PROCESSLIST;
```

### Frontend Debugging
- Browser Developer Tools (F12)
- Network tab for API call debugging
- Console tab for JavaScript errors
- Sources tab for breakpoint debugging

## Common Error Patterns

### ImportError: No module named 'app_name'
**Cause:** App not installed or not in Python path  
**Solution:** 
```bash
bench get-app [app-name] [repo-url]
bench --site [site-name] install-app [app-name]
```

### OperationalError: (2006, 'MySQL server has gone away')
**Cause:** Database connection timeout or configuration  
**Solution:** Check database configuration and connection pools

### PermissionError: Insufficient permission for User
**Cause:** User lacks required role or permissions  
**Solution:** Grant appropriate roles or adjust permission rules

### ValidationError: Invalid value for field
**Cause:** Data validation rules not met  
**Solution:** Check field validation rules and correct input data

## Deliverables

### 1. Error Analysis Report
```yaml
error_analysis:
  error_type: "ImportError"
  root_cause: "Custom app not installed on site"
  failure_point: "apps/custom_app/__init__.py line 1"
  reproduction: "Occurs when accessing custom DocType"
  impact: "All custom app functionality unavailable"
```

### 2. Recommended Solution
- Specific steps to fix the issue
- Commands to run or code to change
- Testing steps to verify the fix
- Prevention measures for future

### 3. Prevention Recommendations
- Code improvements to prevent recurrence
- Monitoring or alerting suggestions
- Documentation updates needed
- Process improvements

## Quality Checks

- [ ] Root cause identified (not just symptom)
- [ ] Solution tested in development environment
- [ ] Fix doesn't break existing functionality
- [ ] Prevention measures recommended
- [ ] Documentation updated if needed

## Success Criteria

1. **Accurate Diagnosis:** Root cause correctly identified
2. **Effective Solution:** Recommended fix resolves the issue
3. **Comprehensive:** All related issues addressed
4. **Preventive:** Measures in place to prevent recurrence
5. **Documented:** Solution and process documented for future reference

## Next Steps

After diagnosis:
1. Apply recommended fix
2. Test thoroughly in development
3. Document solution in knowledge base
4. Update error handling if needed
5. Monitor for similar issues