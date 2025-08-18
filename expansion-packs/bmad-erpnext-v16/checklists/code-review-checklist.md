# Frappe Code Review Checklist
## Mandatory Compliance Checks Before Approval

**Last Updated**: 2025-08-11  
**Framework Version**: Frappe Framework 15 | ERPNext 16  
**Enforcement Level**: STRICT - All items must pass

---

## 🔴 CRITICAL - Immediate Rejection if Found

### HTTP Requests
- [ ] **NO `import requests`** - Must use `frappe.request`
- [ ] **NO `urllib` or `urllib3`** - Must use `frappe.request`
- [ ] **NO `httpx` or `aiohttp`** - Must use `frappe.request`
- [ ] **NO custom HTTP clients** - Must use Frappe's built-in methods

### Database Operations
- [ ] **NO raw SQL in business logic** - Must use Frappe ORM
- [ ] **NO `SELECT * FROM tab*`** - Must use `frappe.get_all()`
- [ ] **NO `INSERT INTO tab*`** - Must use `frappe.get_doc().insert()`
- [ ] **NO `UPDATE tab* SET`** - Must use `frappe.db.set_value()` or `doc.save()`
- [ ] **NO `DELETE FROM tab*`** - Must use `frappe.delete_doc()`
- [ ] **`frappe.db.sql()` only with documented justification**

### Authentication & Security
- [ ] **NO `import jwt` or `pyjwt`** - Must use Frappe auth
- [ ] **NO custom login implementations** - Must use Frappe sessions
- [ ] **NO custom password hashing** - Must use Frappe's auth
- [ ] **NO custom token generation** - Must use Frappe tokens
- [ ] **NO bypassing Frappe permissions** - Must use `frappe.has_permission()`

### API Development
- [ ] **NO `from flask import`** - Frappe is the framework
- [ ] **NO `from fastapi import`** - Use Frappe REST API
- [ ] **NO GraphQL implementations** - Use Frappe REST API
- [ ] **NO custom route handlers** - Use `@frappe.whitelist()`

---

## 🟡 MAJOR - Must Fix Before Merge

### Background Jobs
- [ ] **NO `import celery`** - Must use `frappe.enqueue`
- [ ] **NO `import rq`** - Must use `frappe.enqueue`
- [ ] **NO `threading` or `multiprocessing`** - Must use `frappe.enqueue`
- [ ] **NO custom job queues** - Must use Frappe's job system

### Caching
- [ ] **NO `import redis` direct usage** - Must use `frappe.cache()`
- [ ] **NO `memcached` usage** - Must use `frappe.cache()`
- [ ] **NO custom caching implementations** - Must use Frappe's cache

### Email
- [ ] **NO `import smtplib`** - Must use `frappe.sendmail`
- [ ] **NO `email.mime` modules** - Must use `frappe.sendmail`
- [ ] **NO direct email service SDKs** - Configure in Frappe settings

### File Handling
- [ ] **NO manual file upload handling** - Must use Frappe File DocType
- [ ] **NO direct `os.path` for uploads** - Must use Frappe's file methods
- [ ] **NO direct S3/cloud storage SDKs** - Configure in Frappe

---

## 🟢 BEST PRACTICES - Should Follow

### Logging & Debugging
- [ ] **NO `print()` statements** - Use `frappe.logger()` or `frappe.msgprint()`
- [ ] **NO `import logging` direct usage** - Use `frappe.logger()`
- [ ] **Errors logged with `frappe.log_error()`** - Not custom logging

### Utilities & Helpers
- [ ] **Date operations use `frappe.utils`** - Not Python datetime directly
- [ ] **String formatting uses `frappe.utils`** - Not custom implementations
- [ ] **Validation uses Frappe utilities** - Not external validation libraries

### Templates & Rendering
- [ ] **NO direct Jinja2 imports** - Use `frappe.render_template`
- [ ] **NO other template engines** - Use Frappe's templating

### Real-time & WebSockets
- [ ] **NO custom WebSocket implementations** - Use `frappe.publish_realtime`
- [ ] **NO external real-time services** - Use Frappe's real-time features

### PDF Generation
- [ ] **NO `reportlab` or `pdfkit`** - Use `frappe.utils.get_pdf`
- [ ] **NO external PDF libraries** - Use Frappe's PDF generation

### Scheduling
- [ ] **NO `schedule` library** - Use Frappe scheduler in hooks.py
- [ ] **NO `APScheduler`** - Use Frappe scheduler
- [ ] **NO custom cron implementations** - Use scheduler_events in hooks.py

---

## 📋 Code Pattern Checks

### Import Statements Review
```python
# ❌ REJECT if found:
import requests
import redis
import celery
import jwt
import flask
import pandas
import logging
import smtplib

# ✅ ACCEPT:
import frappe
from frappe import _
from frappe.utils import now, today
```

### Database Query Review
```python
# ❌ REJECT:
frappe.db.sql("SELECT * FROM tabCustomer")
cursor.execute("INSERT INTO...")

# ✅ ACCEPT:
frappe.get_all('Customer')
frappe.get_doc('Customer', name)
```

### API Endpoint Review
```python
# ❌ REJECT:
@app.route('/api/endpoint')
def custom_endpoint():
    pass

# ✅ ACCEPT:
@frappe.whitelist()
def api_method():
    pass
```

---

## 🔍 Quick Validation Commands

### Search for Prohibited Imports
```bash
# Run these grep commands to find violations:
grep -r "import requests" --include="*.py"
grep -r "import redis" --include="*.py"
grep -r "import celery" --include="*.py"
grep -r "import jwt" --include="*.py"
grep -r "from flask" --include="*.py"
grep -r "import pandas" --include="*.py"
```

### Search for SQL Queries
```bash
# Find potential raw SQL:
grep -r "SELECT.*FROM.*tab" --include="*.py"
grep -r "INSERT.*INTO.*tab" --include="*.py"
grep -r "UPDATE.*tab.*SET" --include="*.py"
grep -r "DELETE.*FROM.*tab" --include="*.py"
grep -r "frappe.db.sql" --include="*.py"
```

### Search for Print Statements
```bash
# Find debug prints that should be removed:
grep -r "print(" --include="*.py"
```

---

## ✅ Approval Criteria

### MUST PASS ALL:
1. [ ] Zero critical violations
2. [ ] All major issues resolved
3. [ ] No prohibited imports present
4. [ ] No raw SQL without justification
5. [ ] Uses Frappe authentication
6. [ ] Uses Frappe REST API patterns
7. [ ] Uses frappe.enqueue for background jobs
8. [ ] Uses frappe.cache for caching
9. [ ] Uses frappe.sendmail for emails
10. [ ] Follows Frappe permission model

### Documentation Requirements:
- [ ] Any `frappe.db.sql()` usage has comment explaining why ORM can't be used
- [ ] Any external library has justification in PR description
- [ ] Complex business logic has docstrings
- [ ] API endpoints have parameter documentation

---

## 📊 Scoring Guide

### Compliance Score Calculation:
- **Critical Violations**: -25 points each
- **Major Issues**: -10 points each
- **Best Practice Violations**: -2 points each
- **Starting Score**: 100 points

### Minimum Passing Score: **85/100**

### Rejection Thresholds:
- Any critical violation = **Automatic rejection**
- Score below 85 = **Needs revision**
- 3+ major issues = **Needs revision**

---

## 🚀 Pre-Submission Developer Checklist

Before submitting PR, developers should:

1. [ ] Run `bench --site {site} run-tests`
2. [ ] Check no prohibited imports with grep commands above
3. [ ] Verify all database operations use Frappe ORM
4. [ ] Confirm all API endpoints use `@frappe.whitelist()`
5. [ ] Ensure proper error handling with `frappe.throw()`
6. [ ] Remove all `print()` statements
7. [ ] Test with `bench --site {site} migrate`
8. [ ] Verify permissions with different user roles

---

## 🔒 Security Checklist

- [ ] No hardcoded credentials
- [ ] No bypassing of Frappe permissions
- [ ] All user inputs validated
- [ ] SQL injection prevented (using ORM)
- [ ] XSS prevented (using Frappe's escaping)
- [ ] CSRF protected (using Frappe's tokens)
- [ ] No sensitive data in logs

---

## 📝 Reviewer Sign-off

### Required Approvals:
- [ ] **Code Compliance**: Frappe-first principles followed
- [ ] **Security Review**: No security vulnerabilities
- [ ] **Performance Review**: No obvious performance issues
- [ ] **Documentation**: Code is properly documented

### Final Checklist:
- [ ] All automated tests pass
- [ ] Manual testing completed
- [ ] No console errors in browser
- [ ] Code follows team style guide
- [ ] PR description explains changes clearly

---

**Remember**: This checklist is MANDATORY. Code that doesn't comply with Frappe-first principles will be REJECTED without exception.