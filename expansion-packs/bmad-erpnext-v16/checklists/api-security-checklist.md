# API Security Checklist for Frappe/ERPNext

## 🔴 CRITICAL - Must Pass All

### Whitelisting & Exposure
- [ ] **All API methods have @frappe.whitelist() decorator - NO EXCEPTIONS!**
- [ ] **No Python methods exposed without whitelisting**
- [ ] **Guest access (`allow_guest=True`) used only when absolutely necessary**
- [ ] **No sensitive operations available to guest users**
- [ ] **Internal methods are NOT whitelisted**
- [ ] **NEVER use 'import requests' - Use frappe.make_get_request() instead**

### Authentication & Authorization
- [ ] **Permission checks MUST be FIRST operation after try block**
- [ ] **Permission checks implemented for ALL operations**
  ```python
  # 🚨 CRITICAL: Permission check MUST be FIRST!
  if not frappe.has_permission(doctype, "read"):
      frappe.throw(_("Insufficient permissions"))  # Use frappe.throw()
  ```
- [ ] **ALWAYS use frappe.throw() for errors - NEVER raise Exception**
- [ ] **Document-level permissions verified**
- [ ] **Field-level permissions respected**
- [ ] **Role-based access control enforced**
- [ ] **Session validation for sensitive operations**

### Input Validation
- [ ] **All parameters validated before use**
- [ ] **Type checking with frappe.utils (cint, cstr, flt)**
- [ ] **JSON parameters parsed with frappe.parse_json()**
- [ ] **Required parameters checked for existence**
- [ ] **Parameter ranges and limits enforced**

### SQL Injection Prevention
- [ ] **NO string concatenation in SQL queries**
- [ ] **Parameterized queries used exclusively**
- [ ] **User input never directly inserted into SQL**
- [ ] **ORM methods preferred over raw SQL**
  ```python
  # ❌ BAD
  frappe.db.sql(f"SELECT * FROM tabItem WHERE name = '{item_name}'")
  
  # ✅ GOOD
  frappe.db.sql("SELECT * FROM tabItem WHERE name = %s", item_name)
  ```

### XSS Prevention
- [ ] **User input sanitized before display**
- [ ] **HTML content escaped properly**
- [ ] **frappe.utils.strip_html() used for untrusted content**
- [ ] **Content-Type headers set correctly**

## 🟡 IMPORTANT - Should Implement

### Rate Limiting
- [ ] **Rate limiting implemented for expensive operations**
- [ ] **Bulk operations have limits**
- [ ] **File upload size limits enforced**
- [ ] **API call frequency limited per user**
  ```python
  from frappe.rate_limiter import rate_limit
  
  @frappe.whitelist()
  @rate_limit(limit=10, seconds=60)
  def api_method():
      pass
  ```

### Error Handling
- [ ] **Sensitive information not exposed in errors**
- [ ] **Generic error messages for production**
- [ ] **Detailed errors logged server-side**
- [ ] **Try-catch blocks for all operations**
- [ ] **Graceful degradation on failures**

### Data Security
- [ ] **Sensitive fields excluded from responses**
- [ ] **Personal data properly protected**
- [ ] **Passwords never returned in API responses**
- [ ] **Encryption used for sensitive data**
- [ ] **PII handling complies with regulations**

### CORS & Headers
- [ ] **CORS configured appropriately**
- [ ] **Security headers implemented**
- [ ] **X-Frame-Options set**
- [ ] **Content-Security-Policy configured**
- [ ] **X-Content-Type-Options: nosniff**

## 🟢 BEST PRACTICES - Recommended

### API Design
- [ ] **RESTful principles followed**
- [ ] **Consistent response format**
- [ ] **Proper HTTP status codes used**
- [ ] **Versioning strategy implemented**
- [ ] **Pagination for list endpoints**

### Documentation
- [ ] **All endpoints documented**
- [ ] **Parameter types specified**
- [ ] **Response format documented**
- [ ] **Error codes listed**
- [ ] **Example requests provided**

### Testing
- [ ] **Unit tests for all endpoints**
- [ ] **Permission tests included**
- [ ] **Input validation tests**
- [ ] **Error handling tests**
- [ ] **Security tests (injection, XSS)**

### Performance
- [ ] **Database queries optimized**
- [ ] **N+1 queries avoided**
- [ ] **Caching implemented where appropriate**
- [ ] **Bulk operations optimized**
- [ ] **Response size limited**

## 📝 Code Review Checklist

### Before Approval, Verify:

```python
# ✅ GOOD Example
@frappe.whitelist()
def get_customer_orders(customer_id, limit=20, offset=0):
    """Get customer orders with proper security"""
    
    # 1. Check permissions
    if not frappe.has_permission("Sales Order", "read"):
        frappe.throw(_("No permission to read Sales Orders"))
    
    # 2. Validate input
    customer_id = frappe.utils.cstr(customer_id)
    limit = frappe.utils.cint(limit)
    offset = frappe.utils.cint(offset)
    
    if not customer_id:
        frappe.throw(_("Customer ID required"))
    
    if limit > 100:
        frappe.throw(_("Limit cannot exceed 100"))
    
    # 3. Check customer access
    if not frappe.db.exists("Customer", customer_id):
        frappe.throw(_("Customer not found"))
    
    # 4. Use parameterized query
    orders = frappe.db.sql("""
        SELECT name, transaction_date, grand_total, status
        FROM `tabSales Order`
        WHERE customer = %(customer)s
        AND docstatus = 1
        ORDER BY transaction_date DESC
        LIMIT %(limit)s OFFSET %(offset)s
    """, {
        "customer": customer_id,
        "limit": limit,
        "offset": offset
    }, as_dict=True)
    
    # 5. Return structured response
    return {
        "success": True,
        "data": orders,
        "total": frappe.db.count("Sales Order", {"customer": customer_id}),
        "limit": limit,
        "offset": offset
    }

# ❌ BAD Example - Multiple Security Issues
def get_customer_orders(customer_id):  # Missing @frappe.whitelist()
    # No permission check
    # No input validation
    # SQL injection vulnerability
    orders = frappe.db.sql(f"""
        SELECT * FROM `tabSales Order`
        WHERE customer = '{customer_id}'
    """)
    return orders  # Returns all fields including sensitive data
```

## 🚨 Security Testing Commands

### Test for SQL Injection
```bash
curl -X POST http://site.local/api/method/app.api.method \
  -d "param='; DROP TABLE tabCustomer; --"
```

### Test for XSS
```bash
curl -X POST http://site.local/api/method/app.api.method \
  -d 'param=<script>alert("XSS")</script>'
```

### Test Rate Limiting
```bash
for i in {1..20}; do
  curl -X POST http://site.local/api/method/app.api.method
done
```

## 🔍 Audit Tools

### Static Analysis
```python
# Check for whitelisting
grep -r "def.*(" --include="*.py" | grep -v "@frappe.whitelist"

# Find SQL concatenation
grep -r "frappe.db.sql.*f\"" --include="*.py"
grep -r "frappe.db.sql.*%" --include="*.py" | grep -v "%s"

# Find direct request usage
grep -r "import requests" --include="*.py"
```

### Runtime Testing
```python
# Test permission bypass attempts
frappe.set_user("Guest")
try:
    frappe.call("app.api.sensitive_method")
except frappe.PermissionError:
    print("✅ Permission check working")
```

## 📊 Security Score

Calculate your API security score:

- **Critical items (10 points each)**: ___ / 50
- **Important items (5 points each)**: ___ / 45
- **Best practices (1 point each)**: ___ / 15

**Total Score**: ___ / 110

### Minimum Requirements:
- **Production**: 95+ points with ALL critical items
- **Staging**: 85+ points
- **Development**: 75+ points

## 🛡️ Security Response Plan

If a vulnerability is discovered:

1. **Immediate Actions**
   - [ ] Disable affected endpoints
   - [ ] Review access logs
   - [ ] Notify security team

2. **Fix Implementation**
   - [ ] Develop patch
   - [ ] Test thoroughly
   - [ ] Deploy to staging first

3. **Post-Fix**
   - [ ] Audit similar endpoints
   - [ ] Update documentation
   - [ ] Add regression tests

## 📚 References

- [Frappe Security Documentation](https://frappeframework.com/docs/user/en/security)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [Frappe Whitelisting Guide](https://frappeframework.com/docs/user/en/api/rest#whitelisting-methods)