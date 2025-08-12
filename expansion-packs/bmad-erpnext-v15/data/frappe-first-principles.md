# Frappe-First Development Principles
## MANDATORY: Always Use Frappe Built-in Features Before External Libraries

**Last Updated**: 2025-08-11  
**Framework Version**: Frappe Framework 15 | ERPNext 15  
**Purpose**: Enforce using Frappe's built-in capabilities instead of external libraries or custom implementations

---

## ⚠️ CRITICAL RULES - READ FIRST

### The Golden Rule
**ALWAYS check if Frappe Framework provides a built-in solution before:**
- Importing any external Python library
- Writing custom authentication
- Implementing custom API frameworks
- Writing direct SQL queries
- Creating custom validation systems
- Building custom permission systems

### Violations That Will Be Rejected
1. Using `import requests` when `frappe.request` exists
2. Writing `SELECT * FROM` when `frappe.get_all()` exists
3. Implementing JWT auth when Frappe session management exists
4. Setting up GraphQL when Frappe REST API exists
5. Using SQLAlchemy when Frappe ORM exists
6. Using Celery when `frappe.enqueue` exists
7. Using Redis directly when `frappe.cache` exists

---

## 📚 Complete Frappe Built-in Capabilities Reference

### 1. Database Operations (NEVER USE DIRECT SQL)

#### Document CRUD Operations
```python
# ✅ CORRECT - Using Frappe ORM
doc = frappe.get_doc('Customer', 'CUST-001')
customers = frappe.get_all('Customer', filters={'status': 'Active'})
frappe.db.set_value('Customer', 'CUST-001', 'status', 'Inactive')

# ❌ WRONG - Direct SQL
cursor.execute("SELECT * FROM tabCustomer WHERE name = 'CUST-001'")
```

#### Complete Database API
```python
# Document Operations
frappe.get_doc(doctype, name)           # Get single document
frappe.get_all(doctype, filters)        # Get list without permissions
frappe.get_list(doctype, filters)       # Get list with permissions
frappe.new_doc(doctype)                 # Create new document
frappe.copy_doc(doc)                    # Copy existing document
frappe.rename_doc(doctype, old, new)    # Rename document
frappe.delete_doc(doctype, name)        # Delete document

# Database Methods
frappe.db.get_value(doctype, name, fieldname)    # Get field value
frappe.db.get_values(doctype, filters, fieldname) # Get multiple values
frappe.db.set_value(doctype, name, field, value) # Update field
frappe.db.exists(doctype, name)                   # Check existence
frappe.db.count(doctype, filters)                # Count records
frappe.db.get_single_value(doctype, fieldname)   # Get from singles
frappe.db.set_single_value(doctype, field, val)  # Set in singles

# Bulk Operations
frappe.db.bulk_insert(doctype, fields, values)   # Insert multiple
frappe.db.multisql(sql_dict)                     # Multi-DB queries

# Advanced Queries (Use Sparingly)
frappe.db.sql(query, values, as_dict=True)       # Last resort only
frappe.qb                                        # Query builder API

# Transactions
frappe.db.commit()                               # Commit transaction
frappe.db.rollback()                             # Rollback transaction
frappe.db.savepoint(name)                        # Create savepoint
```

### 2. HTTP Requests (NEVER USE requests LIBRARY)

#### Making HTTP Requests
```python
# ✅ CORRECT - Using Frappe's request methods
response = frappe.request.get('https://api.example.com/data')
response = frappe.request.post('https://api.example.com/submit', json=data)

# For frontend (JavaScript)
frappe.call({
    method: 'frappe.client.get_list',
    args: { doctype: 'Customer' },
    callback: function(r) { }
})

# ❌ WRONG - Using external libraries
import requests  # NEVER DO THIS
response = requests.get('https://api.example.com/data')
```

#### Complete Request API
```python
# Server-side HTTP requests
frappe.request.get(url, params, headers)
frappe.request.post(url, data, json, headers)
frappe.request.put(url, data, json, headers)
frappe.request.delete(url, headers)
frappe.request.head(url, headers)
frappe.request.patch(url, data, json, headers)

# Client-side (JavaScript)
frappe.call(method, args, callback)
frappe.xcall(method, args)  # Returns promise
frappe.db.get_doc(doctype, name)
frappe.db.get_list(doctype, args)
frappe.db.get_value(doctype, name, fieldname)
frappe.db.set_value(doctype, name, fieldname, value)
```

### 3. Authentication & Session Management (NEVER IMPLEMENT CUSTOM AUTH)

#### Authentication Methods
```python
# ✅ CORRECT - Using Frappe's authentication
# Token-based (for APIs)
headers = {'Authorization': f'token {api_key}:{api_secret}'}

# Session-based (for web)
frappe.auth.login(username, password)
frappe.auth.logout()

# OAuth (built-in support)
frappe.integrations.oauth2

# ❌ WRONG - Custom implementations
import jwt  # NEVER implement JWT auth
from flask_login import login_user  # NEVER use external auth
```

#### Complete Authentication API
```python
# Session Management
frappe.session.user                      # Current user
frappe.session.csrf_token                # CSRF token
frappe.session.data                      # Session data
frappe.session.sid                       # Session ID

# User Information
frappe.get_user()                        # Get user object
frappe.get_fullname(user)                # Get user's full name
frappe.get_roles(user)                   # Get user roles
frappe.has_permission(doctype, ptype)    # Check permission

# Authentication Methods
frappe.auth.login_as(user)              # Login as user
frappe.auth.logout()                     # Logout current user
frappe.auth.check_password(user, pwd)   # Verify password
```

### 4. REST API (NEVER USE GraphQL OR CUSTOM API FRAMEWORKS)

#### Built-in REST Endpoints
```
# ✅ CORRECT - Using Frappe REST API
GET    /api/resource/:doctype           # List documents
GET    /api/resource/:doctype/:name     # Get document
POST   /api/resource/:doctype           # Create document
PUT    /api/resource/:doctype/:name     # Update document
DELETE /api/resource/:doctype/:name     # Delete document
POST   /api/method/:method_path         # Call whitelisted method

# ❌ WRONG - Custom API frameworks
from flask import Flask  # NEVER create separate Flask app
import graphene  # NEVER implement GraphQL
```

#### Creating API Endpoints
```python
# ✅ CORRECT - Whitelisted methods
@frappe.whitelist()
def get_customer_data(customer):
    # Method is automatically available via REST API
    return frappe.get_doc('Customer', customer)

# ❌ WRONG - Custom route handlers
@app.route('/api/customer/<id>')  # NEVER do this
def get_customer(id):
    pass
```

### 5. Background Jobs & Scheduling (NEVER USE CELERY)

#### Background Job Processing
```python
# ✅ CORRECT - Using frappe.enqueue
frappe.enqueue(
    method='module.method_name',
    queue='default',  # short, default, long
    timeout=300,
    is_async=True,
    **kwargs
)

# Enqueue document method
frappe.enqueue_doc(
    doctype='Sales Order',
    name='SO-001',
    method='submit'
)

# ❌ WRONG - External job queues
from celery import Celery  # NEVER use Celery
import rq  # NEVER use RQ
```

#### Complete Background Jobs API
```python
# Job Enqueueing
frappe.enqueue(method, queue, timeout, **kwargs)
frappe.enqueue_doc(doctype, name, method)

# Scheduler Methods (hooks.py)
scheduler_events = {
    "all": ["method_1"],
    "hourly": ["method_2"],
    "daily": ["method_3"],
    "weekly": ["method_4"],
    "monthly": ["method_5"],
    "cron": {
        "*/5 * * * *": ["method_6"]  # Every 5 minutes
    }
}

# Job Management
frappe.get_jobs(queue)                  # Get jobs in queue
frappe.is_job_queued(job_id)           # Check if job queued
```

### 6. Caching (NEVER USE REDIS DIRECTLY)

#### Cache Operations
```python
# ✅ CORRECT - Using frappe.cache
cache = frappe.cache()
cache.set('key', 'value', expires_in_sec=3600)
value = cache.get('key')
cache.delete('key')
cache.exists('key')

# ❌ WRONG - Direct Redis usage
import redis  # NEVER import redis directly
r = redis.Redis()
```

#### Complete Cache API
```python
# Cache Operations
frappe.cache().get(key)
frappe.cache().set(key, value, expires_in_sec)
frappe.cache().delete(key)
frappe.cache().delete_keys(pattern)
frappe.cache().exists(key)
frappe.cache().incr(key)
frappe.cache().decr(key)
frappe.cache().lpush(key, value)
frappe.cache().rpush(key, value)
frappe.cache().lrange(key, start, stop)

# Document Cache
frappe.get_cached_doc(doctype, name)
frappe.clear_cache(doctype)
```

### 7. Email & Communication (NEVER USE EXTERNAL EMAIL LIBRARIES)

#### Sending Emails
```python
# ✅ CORRECT - Using frappe.sendmail
frappe.sendmail(
    recipients=['user@example.com'],
    subject='Subject',
    message='Message body',
    attachments=[{'fname': 'file.pdf', 'fcontent': content}]
)

# ❌ WRONG - External email libraries
import smtplib  # NEVER use smtplib directly
from email.mime.text import MIMEText  # NEVER use email package
```

#### Complete Email API
```python
# Email Sending
frappe.sendmail(
    recipients,
    sender=None,
    subject=None,
    message=None,
    as_markdown=False,
    delayed=False,
    reference_doctype=None,
    reference_name=None,
    attachments=None,
    template=None,
    args=None,
    send_after=None
)

# Email Queue
frappe.enqueue_email(email_dict)
frappe.clear_outbox()

# Communication
frappe.get_doc({
    'doctype': 'Communication',
    'subject': subject,
    'content': content,
    'communication_type': 'Comment'
}).insert()
```

### 8. File Handling (NEVER USE os OR shutil DIRECTLY FOR UPLOADS)

#### File Operations
```python
# ✅ CORRECT - Using Frappe file methods
# Upload file
file_doc = frappe.get_doc({
    'doctype': 'File',
    'file_name': 'document.pdf',
    'content': file_content,
    'attached_to_doctype': 'Customer',
    'attached_to_name': 'CUST-001'
}).insert()

# Get file
file_url = frappe.get_doc('File', file_name).file_url

# ❌ WRONG - Direct file operations
import os
os.path.join(upload_dir, filename)  # NEVER handle uploads directly
```

#### Complete File API
```python
# File Operations
frappe.get_file(file_url)
frappe.utils.get_files_path(filename)
frappe.local.uploaded_file  # Access uploaded file
frappe.local.uploaded_filename

# Attachments
frappe.attach_print(
    doctype,
    name,
    file_name=None,
    print_format=None
)

# File Utilities
frappe.utils.get_file_size(file_path)
frappe.utils.get_file_timestamp(file_path)
```

### 9. Permissions & Security (NEVER IMPLEMENT CUSTOM PERMISSIONS)

#### Permission Checking
```python
# ✅ CORRECT - Using Frappe permissions
if frappe.has_permission('Customer', 'write'):
    # User has write permission
    pass

doc.check_permission('write')  # Throws if no permission

# ❌ WRONG - Custom permission systems
def check_user_permission(user, resource):  # NEVER implement custom
    pass
```

#### Complete Permissions API
```python
# Permission Checks
frappe.has_permission(doctype, ptype, doc)
frappe.get_roles(user)
frappe.get_user_permissions(user)
doc.check_permission(permtype)
doc.has_permission(permtype)

# Permission Management
frappe.permissions.add_user_permission(
    doctype,
    name,
    user,
    apply_to_all_doctypes=0
)
frappe.permissions.remove_user_permission(
    doctype,
    name,
    user
)
frappe.permissions.clear_user_permissions_for_doctype(
    doctype,
    user
)
```

### 10. Utility Functions (NEVER REINVENT THE WHEEL)

#### Date & Time Utilities
```python
# ✅ CORRECT - Using frappe.utils
from frappe.utils import (
    now, today, nowdate, nowtime,
    add_days, add_months, add_years,
    date_diff, month_diff, 
    getdate, get_datetime,
    format_date, format_datetime,
    pretty_date  # "2 hours ago"
)

# ❌ WRONG - Using Python datetime directly
from datetime import datetime  # Use sparingly
datetime.now()  # Use frappe.utils.now() instead
```

#### Complete Utilities API
```python
# Date/Time Utilities
frappe.utils.now()                      # Current datetime string
frappe.utils.today()                    # Current date string
frappe.utils.nowdate()                  # Current date
frappe.utils.nowtime()                  # Current time
frappe.utils.getdate(date_str)          # Parse date string
frappe.utils.get_datetime(datetime_str) # Parse datetime string
frappe.utils.add_days(date, days)       # Add/subtract days
frappe.utils.add_months(date, months)   # Add/subtract months
frappe.utils.date_diff(date1, date2)    # Difference in days
frappe.utils.time_diff(time1, time2)    # Difference in seconds
frappe.utils.pretty_date(date)          # "2 hours ago"
frappe.utils.format_date(date)          # Format date
frappe.utils.format_datetime(datetime)   # Format datetime
frappe.utils.format_duration(seconds)    # "2h 30m"

# String Utilities
frappe.utils.cstr(val)                  # Convert to string
frappe.utils.cint(val)                  # Convert to int
frappe.utils.flt(val)                   # Convert to float
frappe.utils.comma_and(list)            # "a, b and c"
frappe.utils.money_in_words(amount)     # "One Thousand"
frappe.utils.get_abbr(text)             # Generate abbreviation
frappe.utils.random_string(length)      # Random string
frappe.utils.unique(sequence)           # Remove duplicates
frappe.utils.strip_html(html)           # Remove HTML tags

# Validation Utilities
frappe.utils.validate_email_address(email)
frappe.utils.validate_phone_number(phone)
frappe.utils.validate_url(url, throw=True)
frappe.utils.validate_json_string(json_str)

# Format Utilities
frappe.format_value(value, df)          # Format by field type
frappe.format(value, df)                # Alias for format_value

# PDF Generation (NEVER use external PDF libraries)
frappe.utils.get_pdf(html)              # Generate PDF from HTML
frappe.get_print(doctype, name, format) # Get print format HTML
```

### 11. Logging & Error Handling (NEVER USE print() OR logging DIRECTLY)

#### Logging and Errors
```python
# ✅ CORRECT - Using Frappe logging
frappe.log_error(message, title)        # Log to Error Log
frappe.logger().debug(message)          # Debug logging
frappe.msgprint(message)                 # Show message to user
frappe.throw(message)                    # Throw error with message

# ❌ WRONG - Direct logging
import logging  # Avoid direct usage
print("Debug message")  # NEVER use print()
```

#### Complete Logging API
```python
# Error Handling
frappe.throw(msg, exc=None, title=None)
frappe.log_error(message, title)
frappe.get_traceback()

# Logging Levels
frappe.logger().debug(message)
frappe.logger().info(message)
frappe.logger().warning(message)
frappe.logger().error(message)

# User Messages
frappe.msgprint(
    msg,
    title=None,
    raise_exception=False,
    indicator='blue',  # red, green, orange, blue
    alert=False
)
```

### 12. Translations (NEVER HARDCODE STRINGS)

#### Translation System
```python
# ✅ CORRECT - Using translations
from frappe import _

message = _('Document {0} submitted successfully').format(doc.name)
frappe.msgprint(_('Success'))

# ❌ WRONG - Hardcoded strings
message = f'Document {doc.name} submitted successfully'  # No translation
```

### 13. Templating (NEVER USE EXTERNAL TEMPLATE ENGINES)

#### Template Rendering
```python
# ✅ CORRECT - Using Frappe's Jinja
html = frappe.render_template('template.html', context)
rendered = frappe.render_template('{{ name }}', {'name': 'John'})

# ❌ WRONG - External template engines
from jinja2 import Template  # NEVER import directly
```

### 14. Real-time Updates (NEVER IMPLEMENT CUSTOM WEBSOCKETS)

#### Real-time Communication
```python
# ✅ CORRECT - Using Frappe real-time
frappe.publish_realtime(
    event='update',
    message={'data': 'value'},
    user='user@example.com'
)

# Frontend subscription
frappe.realtime.on('update', function(data) {
    // Handle update
})

# ❌ WRONG - Custom WebSocket implementation
import websocket  # NEVER implement custom WebSockets
```

### 15. Reports & Printing (NEVER USE EXTERNAL REPORTING LIBRARIES)

#### Report Generation
```python
# ✅ CORRECT - Using Frappe reports
# Script Report
def execute(filters=None):
    columns = get_columns()
    data = get_data(filters)
    return columns, data

# Query Report (in Report DocType)
SELECT * FROM `tabCustomer` WHERE status = %(status)s

# Print Formats
frappe.get_print(doctype, name, print_format)

# ❌ WRONG - External libraries
import pandas  # NEVER use for reports
import reportlab  # NEVER use for PDF generation
```

### 16. Workflows (USE FRAPPE'S WORKFLOW ENGINE)

#### Workflow Management
```python
# ✅ CORRECT - Using Frappe workflows
# Define in Workflow DocType
# Use workflow_state field in documents
# Transitions handled automatically

# Check workflow state
if doc.workflow_state == 'Approved':
    # Process approved document
    pass

# ❌ WRONG - Custom state machines
from transitions import Machine  # NEVER implement custom workflows
```

### 17. Integration Patterns (USE FRAPPE'S INTEGRATION FRAMEWORK)

#### Webhooks and Integrations
```python
# ✅ CORRECT - Using Frappe webhooks
# Configure in Webhook DocType
# Automatic triggers on document events

# Custom integration
@frappe.whitelist()
def sync_with_external_system():
    # Use frappe.request for external APIs
    response = frappe.request.post(url, json=data)

# ❌ WRONG - Custom webhook servers
from flask import Flask  # NEVER create separate servers
```

### 18. Testing (USE FRAPPE'S TEST FRAMEWORK)

#### Testing Patterns
```python
# ✅ CORRECT - Using Frappe test framework
import frappe
import unittest

class TestCustomer(unittest.TestCase):
    def test_customer_creation(self):
        customer = frappe.get_doc({
            'doctype': 'Customer',
            'customer_name': 'Test Customer'
        }).insert()
        self.assertTrue(customer.name)

# Run tests
bench run-tests --app your_app

# ❌ WRONG - External test frameworks
import pytest  # Use Frappe's test framework instead
```

---

## 🚫 Common Anti-Patterns to Avoid

### 1. External Libraries That Should NEVER Be Used

```python
# ❌ NEVER IMPORT THESE:
import requests          # Use frappe.request
import redis            # Use frappe.cache()
import celery           # Use frappe.enqueue
import jwt              # Use Frappe session auth
import sqlalchemy       # Use Frappe ORM
import pandas           # Use Frappe reports
import flask            # Frappe is the web framework
import django           # Frappe is the web framework
import graphene         # Use Frappe REST API
import logging          # Use frappe.logger()
import smtplib          # Use frappe.sendmail
import reportlab        # Use frappe.utils.get_pdf
import jinja2           # Use frappe.render_template
import schedule         # Use Frappe scheduler
import websocket        # Use frappe.publish_realtime
```

### 2. SQL Queries That Should NEVER Be Written

```sql
-- ❌ NEVER WRITE RAW SQL:
SELECT * FROM tabCustomer WHERE status = 'Active'
INSERT INTO tabCustomer VALUES (...)
UPDATE tabCustomer SET status = 'Inactive'
DELETE FROM tabCustomer WHERE name = 'CUST-001'

-- ✅ ALWAYS USE FRAPPE ORM:
frappe.get_all('Customer', filters={'status': 'Active'})
frappe.get_doc({'doctype': 'Customer', ...}).insert()
frappe.db.set_value('Customer', name, 'status', 'Inactive')
frappe.delete_doc('Customer', 'CUST-001')
```

### 3. Authentication That Should NEVER Be Implemented

```python
# ❌ NEVER IMPLEMENT:
- JWT tokens
- OAuth servers (use Frappe's OAuth)
- Custom session management
- API key generation (use Frappe's tokens)
- Password hashing (use Frappe's auth)
- Two-factor auth (use Frappe's 2FA)
```

---

## ✅ Quick Decision Tree

**Q: Do I need to make an HTTP request?**
→ Use `frappe.request`, NOT `requests` library

**Q: Do I need to query the database?**
→ Use `frappe.get_all()` or `frappe.db`, NOT raw SQL

**Q: Do I need background processing?**
→ Use `frappe.enqueue`, NOT Celery

**Q: Do I need caching?**
→ Use `frappe.cache()`, NOT Redis directly

**Q: Do I need to send email?**
→ Use `frappe.sendmail`, NOT smtplib

**Q: Do I need authentication?**
→ Use Frappe's session/token auth, NOT JWT

**Q: Do I need an API?**
→ Use Frappe REST API, NOT GraphQL or Flask

**Q: Do I need real-time updates?**
→ Use `frappe.publish_realtime`, NOT custom WebSockets

**Q: Do I need to generate PDFs?**
→ Use `frappe.utils.get_pdf`, NOT reportlab

**Q: Do I need logging?**
→ Use `frappe.log_error` or `frappe.logger()`, NOT print()

---

## 📋 Validation Checklist

Before writing ANY code, ask yourself:

- [ ] Have I checked if Frappe has a built-in solution?
- [ ] Am I using Frappe's ORM instead of raw SQL?
- [ ] Am I using Frappe's request methods instead of requests library?
- [ ] Am I using Frappe's authentication instead of custom auth?
- [ ] Am I using Frappe's REST API instead of GraphQL?
- [ ] Am I using frappe.enqueue instead of Celery?
- [ ] Am I using frappe.cache instead of Redis directly?
- [ ] Am I using frappe.sendmail instead of email libraries?
- [ ] Am I using Frappe's permission system?
- [ ] Am I using Frappe's utilities instead of reinventing?

**If any answer is NO, STOP and use Frappe's built-in solution!**

---

## 🎯 Summary

The Frappe Framework provides comprehensive built-in solutions for:
- Database operations (ORM)
- HTTP requests
- Authentication & sessions
- REST API
- Background jobs
- Caching
- Email
- File handling
- Permissions
- Utilities
- Logging
- Translations
- Templates
- Real-time updates
- Reports & printing
- Workflows
- Testing

**NEVER import external libraries for these functionalities. ALWAYS use Frappe's built-in solutions.**

This is not a suggestion - it's a requirement for maintaining consistency, security, and performance in Frappe/ERPNext applications.