# validate-frappe-compliance

## Task Description
Validate ERPNext applications and code against Frappe Framework standards and best practices to ensure compliance and quality.

## Parameters
- `app_name`: Application to validate
- `validation_scope`: code, database, ui, security, or all (default: all)
- `strictness`: strict, standard, or relaxed (default: standard)
- `auto_fix`: Automatically fix issues where possible (default: false)
- `report_format`: json, html, or markdown (default: json)

## Prerequisites
- Application code available
- Frappe framework installed
- Testing environment configured
- Validation rules defined

## Steps

### 1. Code Compliance Validation
```python
def validate_code_compliance(app_name, strictness="standard"):
    """Validate Python code against Frappe standards"""
    
    validation_results = {
        "app": app_name,
        "validation_type": "code_compliance",
        "issues": [],
        "warnings": [],
        "info": [],
        "score": 100
    }
    
    # Get all Python files in app
    python_files = get_app_python_files(app_name)
    
    for file_path in python_files:
        file_results = validate_python_file(file_path, strictness)
        validation_results["issues"].extend(file_results["issues"])
        validation_results["warnings"].extend(file_results["warnings"])
        validation_results["info"].extend(file_results["info"])
    
    # Calculate compliance score
    validation_results["score"] = calculate_compliance_score(validation_results)
    
    return validation_results

def validate_python_file(file_path, strictness):
    """Validate individual Python file"""
    
    with open(file_path, 'r') as f:
        content = f.read()
    
    issues = []
    warnings = []
    info = []
    
    # Check imports
    import_issues = validate_imports(content, file_path)
    issues.extend(import_issues)
    
    # Check frappe.whitelist usage
    whitelist_issues = validate_whitelist_usage(content, file_path)
    issues.extend(whitelist_issues)
    
    # Check database operations
    db_issues = validate_database_operations(content, file_path)
    issues.extend(db_issues)
    
    # Check error handling
    error_issues = validate_error_handling(content, file_path)
    warnings.extend(error_issues)
    
    # Check naming conventions
    naming_issues = validate_naming_conventions(content, file_path)
    warnings.extend(naming_issues)
    
    # Check documentation
    doc_issues = validate_documentation(content, file_path)
    info.extend(doc_issues)
    
    return {
        "file": file_path,
        "issues": issues,
        "warnings": warnings,
        "info": info
    }
```

### 2. Import Validation
```python
def validate_imports(content, file_path):
    """Validate import statements against Frappe standards"""
    
    issues = []
    
    # Prohibited imports
    prohibited_imports = [
        'subprocess',  # Use frappe.utils.execute_in_shell
        'os.system',   # Security risk
        'eval',        # Security risk
        'exec',        # Security risk
        '__import__',  # Security risk
        'pickle',      # Security risk
        'shelve',      # Use frappe.cache instead
    ]
    
    for prohibited in prohibited_imports:
        if prohibited in content:
            issues.append({
                "type": "prohibited_import",
                "file": file_path,
                "issue": f"Prohibited import/function '{prohibited}' found",
                "severity": "error",
                "line": find_line_number(content, prohibited),
                "recommendation": get_import_recommendation(prohibited)
            })
    
    # Check for direct SQL imports
    if 'import MySQLdb' in content or 'import pymysql' in content:
        issues.append({
            "type": "direct_sql_import",
            "file": file_path,
            "issue": "Direct SQL library import found",
            "severity": "error",
            "recommendation": "Use frappe.db for database operations"
        })
    
    # Check for missing frappe imports
    if '@frappe.whitelist' in content and 'import frappe' not in content:
        issues.append({
            "type": "missing_import",
            "file": file_path,
            "issue": "Missing 'import frappe' statement",
            "severity": "error"
        })
    
    return issues

def get_import_recommendation(prohibited_import):
    """Get recommendation for prohibited import"""
    
    recommendations = {
        'subprocess': "Use frappe.utils.execute_in_shell() instead",
        'os.system': "Use frappe.utils.execute_in_shell() instead",
        'eval': "Avoid eval(), use json.loads() or ast.literal_eval()",
        'exec': "Avoid exec(), refactor code to avoid dynamic execution",
        'pickle': "Use frappe.cache() or json for serialization",
        'shelve': "Use frappe.cache() for caching"
    }
    
    return recommendations.get(prohibited_import, "Find a safer alternative")
```

### 3. API Compliance Validation
```python
def validate_api_compliance(app_name):
    """Validate API endpoints for Frappe compliance"""
    
    api_issues = []
    
    # Find all whitelisted methods
    whitelisted_methods = find_whitelisted_methods(app_name)
    
    for method in whitelisted_methods:
        # Check whitelist decorator usage
        if not has_whitelist_decorator(method):
            api_issues.append({
                "type": "missing_whitelist",
                "method": method["name"],
                "file": method["file"],
                "severity": "error",
                "issue": "API method missing @frappe.whitelist() decorator"
            })
        
        # Check permission validation
        if not has_permission_check(method):
            api_issues.append({
                "type": "missing_permission_check",
                "method": method["name"],
                "file": method["file"],
                "severity": "warning",
                "issue": "API method missing permission validation"
            })
        
        # Check input validation
        if not has_input_validation(method):
            api_issues.append({
                "type": "missing_input_validation",
                "method": method["name"],
                "file": method["file"],
                "severity": "warning",
                "issue": "API method missing input validation"
            })
        
        # Check SQL injection prevention
        sql_issues = check_sql_injection_prevention(method)
        api_issues.extend(sql_issues)
    
    return api_issues

def check_sql_injection_prevention(method):
    """Check for SQL injection vulnerabilities"""
    
    issues = []
    content = method["content"]
    
    # Check for string concatenation in SQL
    dangerous_patterns = [
        r'frappe\.db\.sql\([^)]*\+[^)]*\)',  # String concatenation in SQL
        r'frappe\.db\.sql\([^)]*%[^)]*%[^)]*\)',  # Old-style formatting
        r'frappe\.db\.sql\([^)]*\.format\([^)]*\)',  # .format() in SQL
        r'frappe\.db\.sql\([^)]*f["\'][^)]*\)',  # f-strings in SQL
    ]
    
    import re
    for pattern in dangerous_patterns:
        if re.search(pattern, content):
            issues.append({
                "type": "sql_injection_risk",
                "method": method["name"],
                "file": method["file"],
                "severity": "error",
                "issue": "Potential SQL injection vulnerability",
                "recommendation": "Use parameterized queries with %(param)s placeholders"
            })
    
    return issues
```

### 4. Database Schema Compliance
```python
def validate_database_compliance(app_name):
    """Validate database schema and operations"""
    
    db_issues = []
    
    # Get all DocTypes in app
    doctypes = get_app_doctypes(app_name)
    
    for doctype in doctypes:
        # Validate field types
        field_issues = validate_field_types(doctype)
        db_issues.extend(field_issues)
        
        # Validate naming patterns
        naming_issues = validate_doctype_naming(doctype)
        db_issues.extend(naming_issues)
        
        # Validate indexes
        index_issues = validate_indexes(doctype)
        db_issues.extend(index_issues)
        
        # Validate relationships
        relationship_issues = validate_relationships(doctype)
        db_issues.extend(relationship_issues)
    
    # Check for direct SQL usage
    sql_usage_issues = check_direct_sql_usage(app_name)
    db_issues.extend(sql_usage_issues)
    
    return db_issues

def validate_field_types(doctype):
    """Validate field type usage"""
    
    issues = []
    meta = frappe.get_meta(doctype)
    
    for field in meta.fields:
        # Check for deprecated field types
        if field.fieldtype in ['Small Text', 'Medium Text', 'Long Text']:
            issues.append({
                "type": "deprecated_field_type",
                "doctype": doctype,
                "field": field.fieldname,
                "severity": "warning",
                "issue": f"Deprecated field type '{field.fieldtype}'",
                "recommendation": "Use 'Text' or 'Text Editor' instead"
            })
        
        # Check Link field options
        if field.fieldtype == 'Link' and not field.options:
            issues.append({
                "type": "missing_link_options",
                "doctype": doctype,
                "field": field.fieldname,
                "severity": "error",
                "issue": "Link field missing options (target DocType)"
            })
        
        # Check Select field options
        if field.fieldtype == 'Select' and not field.options:
            issues.append({
                "type": "missing_select_options",
                "doctype": doctype,
                "field": field.fieldname,
                "severity": "error",
                "issue": "Select field missing options"
            })
    
    return issues
```

### 5. UI/UX Compliance
```python
def validate_ui_compliance(app_name):
    """Validate UI components and patterns"""
    
    ui_issues = []
    
    # Check for custom CSS/JS files
    custom_files = find_custom_ui_files(app_name)
    
    for file in custom_files:
        if file["type"] == "css":
            css_issues = validate_css_compliance(file)
            ui_issues.extend(css_issues)
        elif file["type"] == "js":
            js_issues = validate_javascript_compliance(file)
            ui_issues.extend(js_issues)
    
    # Check form customizations
    form_issues = validate_form_customizations(app_name)
    ui_issues.extend(form_issues)
    
    # Check print formats
    print_issues = validate_print_formats(app_name)
    ui_issues.extend(print_issues)
    
    return ui_issues

def validate_javascript_compliance(js_file):
    """Validate JavaScript against Frappe standards"""
    
    issues = []
    content = js_file["content"]
    
    # Check for jQuery usage (deprecated)
    if '$(' in content or 'jQuery(' in content:
        issues.append({
            "type": "jquery_usage",
            "file": js_file["path"],
            "severity": "warning",
            "issue": "jQuery usage detected",
            "recommendation": "Use vanilla JavaScript or Frappe UI utilities"
        })
    
    # Check for direct DOM manipulation
    if 'document.getElementById' in content or 'document.querySelector' in content:
        issues.append({
            "type": "direct_dom_manipulation",
            "file": js_file["path"],
            "severity": "info",
            "issue": "Direct DOM manipulation detected",
            "recommendation": "Consider using Frappe form events and APIs"
        })
    
    # Check for frappe.call usage
    if 'frappe.call' in content:
        # Ensure proper error handling
        if 'callback' not in content or 'error' not in content:
            issues.append({
                "type": "incomplete_api_call",
                "file": js_file["path"],
                "severity": "warning",
                "issue": "frappe.call without proper error handling",
                "recommendation": "Add error callback to handle failures"
            })
    
    return issues
```

### 6. Security Compliance
```python
def validate_security_compliance(app_name):
    """Validate security best practices"""
    
    security_issues = []
    
    # Check authentication
    auth_issues = validate_authentication_patterns(app_name)
    security_issues.extend(auth_issues)
    
    # Check authorization
    authz_issues = validate_authorization_patterns(app_name)
    security_issues.extend(authz_issues)
    
    # Check data exposure
    exposure_issues = validate_data_exposure(app_name)
    security_issues.extend(exposure_issues)
    
    # Check encryption
    encryption_issues = validate_encryption_usage(app_name)
    security_issues.extend(encryption_issues)
    
    return security_issues

def validate_authentication_patterns(app_name):
    """Validate authentication implementation"""
    
    issues = []
    
    # Find all authentication points
    auth_points = find_authentication_points(app_name)
    
    for auth_point in auth_points:
        # Check for hardcoded credentials
        if has_hardcoded_credentials(auth_point):
            issues.append({
                "type": "hardcoded_credentials",
                "file": auth_point["file"],
                "severity": "critical",
                "issue": "Hardcoded credentials detected",
                "recommendation": "Use environment variables or secure storage"
            })
        
        # Check for weak authentication
        if has_weak_authentication(auth_point):
            issues.append({
                "type": "weak_authentication",
                "file": auth_point["file"],
                "severity": "error",
                "issue": "Weak authentication mechanism",
                "recommendation": "Implement proper authentication with frappe.auth"
            })
    
    return issues

def validate_data_exposure(app_name):
    """Check for data exposure issues"""
    
    issues = []
    
    # Check for sensitive data in responses
    api_methods = find_api_methods(app_name)
    
    for method in api_methods:
        # Check if sensitive fields are exposed
        exposed_fields = find_exposed_sensitive_fields(method)
        
        for field in exposed_fields:
            issues.append({
                "type": "sensitive_data_exposure",
                "method": method["name"],
                "field": field,
                "severity": "error",
                "issue": f"Sensitive field '{field}' exposed in API response",
                "recommendation": "Remove or mask sensitive fields before returning"
            })
    
    return issues
```

### 7. Performance Compliance
```python
def validate_performance_compliance(app_name):
    """Validate performance best practices"""
    
    perf_issues = []
    
    # Check for N+1 queries
    n_plus_one_issues = find_n_plus_one_queries(app_name)
    perf_issues.extend(n_plus_one_issues)
    
    # Check for missing indexes
    index_issues = find_missing_indexes(app_name)
    perf_issues.extend(index_issues)
    
    # Check for heavy operations in loops
    loop_issues = find_heavy_operations_in_loops(app_name)
    perf_issues.extend(loop_issues)
    
    # Check for synchronous operations that should be async
    async_issues = find_sync_operations_needing_async(app_name)
    perf_issues.extend(async_issues)
    
    return perf_issues

def find_n_plus_one_queries(app_name):
    """Find N+1 query patterns"""
    
    issues = []
    
    # Pattern: Loop with frappe.get_doc or frappe.db.get_value
    pattern = r'for .* in .*:\s*frappe\.(get_doc|db\.get_value)'
    
    python_files = get_app_python_files(app_name)
    
    for file_path in python_files:
        with open(file_path, 'r') as f:
            content = f.read()
        
        import re
        if re.search(pattern, content, re.MULTILINE):
            issues.append({
                "type": "n_plus_one_query",
                "file": file_path,
                "severity": "warning",
                "issue": "Potential N+1 query pattern detected",
                "recommendation": "Use frappe.get_all() with filters to fetch all records at once"
            })
    
    return issues
```

### 8. Testing Compliance
```python
def validate_testing_compliance(app_name):
    """Validate testing coverage and patterns"""
    
    testing_issues = []
    
    # Check test coverage
    coverage = calculate_test_coverage(app_name)
    
    if coverage < 60:
        testing_issues.append({
            "type": "low_test_coverage",
            "app": app_name,
            "severity": "warning",
            "issue": f"Test coverage {coverage}% is below recommended 60%",
            "recommendation": "Add more unit and integration tests"
        })
    
    # Check for test files
    test_files = find_test_files(app_name)
    
    if not test_files:
        testing_issues.append({
            "type": "missing_tests",
            "app": app_name,
            "severity": "error",
            "issue": "No test files found",
            "recommendation": "Create test files following Frappe testing patterns"
        })
    
    # Validate test patterns
    for test_file in test_files:
        test_pattern_issues = validate_test_patterns(test_file)
        testing_issues.extend(test_pattern_issues)
    
    return testing_issues

def validate_test_patterns(test_file):
    """Validate test file patterns"""
    
    issues = []
    content = test_file["content"]
    
    # Check for setUp and tearDown methods
    if 'def setUp' not in content:
        issues.append({
            "type": "missing_setup",
            "file": test_file["path"],
            "severity": "info",
            "issue": "Missing setUp method in test",
            "recommendation": "Add setUp method for test initialization"
        })
    
    # Check for proper test naming
    import re
    test_methods = re.findall(r'def (test_\w+)', content)
    
    for method in test_methods:
        if not method.startswith('test_'):
            issues.append({
                "type": "invalid_test_name",
                "file": test_file["path"],
                "method": method,
                "severity": "error",
                "issue": f"Test method '{method}' doesn't start with 'test_'",
                "recommendation": "Rename method to start with 'test_'"
            })
    
    return issues
```

### 9. Documentation Compliance
```python
def validate_documentation_compliance(app_name):
    """Validate documentation standards"""
    
    doc_issues = []
    
    # Check README
    if not has_readme(app_name):
        doc_issues.append({
            "type": "missing_readme",
            "app": app_name,
            "severity": "error",
            "issue": "Missing README.md file",
            "recommendation": "Create README.md with setup and usage instructions"
        })
    
    # Check docstrings
    python_files = get_app_python_files(app_name)
    
    for file_path in python_files:
        docstring_issues = validate_docstrings(file_path)
        doc_issues.extend(docstring_issues)
    
    # Check API documentation
    api_methods = find_api_methods(app_name)
    
    for method in api_methods:
        if not has_api_documentation(method):
            doc_issues.append({
                "type": "missing_api_docs",
                "method": method["name"],
                "file": method["file"],
                "severity": "warning",
                "issue": "API method missing documentation",
                "recommendation": "Add docstring with parameters and return value documentation"
            })
    
    return doc_issues

def validate_docstrings(file_path):
    """Validate Python docstrings"""
    
    issues = []
    
    import ast
    with open(file_path, 'r') as f:
        try:
            tree = ast.parse(f.read())
        except:
            return issues
    
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.ClassDef)):
            if not ast.get_docstring(node):
                issues.append({
                    "type": "missing_docstring",
                    "file": file_path,
                    "name": node.name,
                    "severity": "info",
                    "issue": f"Missing docstring for {node.__class__.__name__} '{node.name}'",
                    "recommendation": "Add descriptive docstring"
                })
    
    return issues
```

### 10. Auto-Fix Capabilities
```python
def auto_fix_compliance_issues(app_name, issues, fix_types=None):
    """Automatically fix certain compliance issues"""
    
    fix_types = fix_types or ['imports', 'naming', 'docstrings', 'whitelist']
    fixed_issues = []
    
    for issue in issues:
        if issue["type"] in fix_types:
            fix_result = auto_fix_issue(issue)
            if fix_result["success"]:
                fixed_issues.append(issue)
    
    return {
        "fixed": fixed_issues,
        "remaining": [i for i in issues if i not in fixed_issues]
    }

def auto_fix_issue(issue):
    """Fix individual compliance issue"""
    
    fix_functions = {
        'missing_import': fix_missing_import,
        'missing_whitelist': fix_missing_whitelist,
        'missing_docstring': fix_missing_docstring,
        'invalid_naming': fix_invalid_naming
    }
    
    fix_func = fix_functions.get(issue["type"])
    
    if fix_func:
        return fix_func(issue)
    
    return {"success": False, "reason": "No auto-fix available"}

def fix_missing_import(issue):
    """Add missing import statement"""
    
    file_path = issue["file"]
    
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    # Add import at the beginning
    import_line = "import frappe\n"
    
    # Find the right place to add import
    insert_index = 0
    for i, line in enumerate(lines):
        if not line.startswith('#') and not line.startswith('"""'):
            insert_index = i
            break
    
    lines.insert(insert_index, import_line)
    
    with open(file_path, 'w') as f:
        f.writelines(lines)
    
    return {"success": True}

def fix_missing_whitelist(issue):
    """Add missing @frappe.whitelist decorator"""
    
    file_path = issue["file"]
    method_name = issue["method"]
    
    with open(file_path, 'r') as f:
        lines = f.readlines()
    
    # Find method definition
    for i, line in enumerate(lines):
        if f"def {method_name}" in line:
            # Add decorator before method
            lines.insert(i, "@frappe.whitelist()\n")
            break
    
    with open(file_path, 'w') as f:
        f.writelines(lines)
    
    return {"success": True}
```

### 11. Compliance Report Generation
```python
def generate_compliance_report(validation_results, format="json"):
    """Generate comprehensive compliance report"""
    
    # Calculate overall compliance score
    total_issues = len(validation_results.get("issues", []))
    total_warnings = len(validation_results.get("warnings", []))
    total_info = len(validation_results.get("info", []))
    
    # Weight the score
    score = 100
    score -= total_issues * 10  # Critical issues
    score -= total_warnings * 3  # Warnings
    score -= total_info * 1      # Info items
    score = max(0, score)
    
    report = {
        "app": validation_results["app"],
        "validation_date": frappe.utils.now(),
        "compliance_score": score,
        "summary": {
            "total_issues": total_issues,
            "total_warnings": total_warnings,
            "total_info": total_info,
            "critical_issues": len([i for i in validation_results.get("issues", []) if i.get("severity") == "critical"]),
            "errors": len([i for i in validation_results.get("issues", []) if i.get("severity") == "error"])
        },
        "details": validation_results,
        "recommendations": generate_recommendations(validation_results),
        "compliance_status": get_compliance_status(score)
    }
    
    if format == "json":
        return report
    elif format == "html":
        return generate_html_report(report)
    elif format == "markdown":
        return generate_markdown_report(report)
    
    return report

def get_compliance_status(score):
    """Get compliance status based on score"""
    
    if score >= 90:
        return {"status": "Excellent", "color": "green", "passed": True}
    elif score >= 75:
        return {"status": "Good", "color": "yellow", "passed": True}
    elif score >= 60:
        return {"status": "Acceptable", "color": "orange", "passed": True}
    else:
        return {"status": "Poor", "color": "red", "passed": False}

def generate_recommendations(validation_results):
    """Generate actionable recommendations"""
    
    recommendations = []
    
    # Critical issues first
    critical_issues = [i for i in validation_results.get("issues", []) if i.get("severity") == "critical"]
    if critical_issues:
        recommendations.append({
            "priority": "Critical",
            "action": "Fix critical security and compliance issues immediately",
            "issues": critical_issues
        })
    
    # Performance issues
    perf_issues = [i for i in validation_results.get("issues", []) if "performance" in i.get("type", "")]
    if perf_issues:
        recommendations.append({
            "priority": "High",
            "action": "Optimize performance issues to improve system efficiency",
            "issues": perf_issues
        })
    
    # Documentation
    doc_issues = [i for i in validation_results.get("warnings", []) if "doc" in i.get("type", "")]
    if doc_issues:
        recommendations.append({
            "priority": "Medium",
            "action": "Improve documentation for better maintainability",
            "issues": doc_issues
        })
    
    return recommendations
```

## Validation Rules Summary

### Critical Compliance Rules
1. **No direct SQL imports** - Use frappe.db
2. **All APIs must have @frappe.whitelist()** 
3. **No hardcoded credentials**
4. **No dangerous functions** (eval, exec, etc.)
5. **Parameterized SQL queries only**

### Important Standards
1. **Permission checks in all APIs**
2. **Input validation for all user inputs**
3. **Error handling with frappe.throw()**
4. **Proper naming conventions**
5. **DocType field validation**

### Best Practices
1. **Docstrings for all functions/classes**
2. **Test coverage > 60%**
3. **No N+1 queries**
4. **Proper index usage**
5. **Security headers in responses**

## Integration Points
- **Frappe Compliance Validator**: Primary agent using this task
- **Testing Specialist**: Compliance testing
- **Security Auditor**: Security compliance validation
- **Code Reviewer**: Automated code review
- **CI/CD Pipeline**: Automated compliance checks