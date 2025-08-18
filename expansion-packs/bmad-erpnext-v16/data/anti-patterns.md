# Frappe Anti-Patterns Guide
## What NOT to Do - With Clear Examples

**Last Updated**: 2025-08-11  
**Framework Version**: Frappe Framework 15 | ERPNext 16  
**Purpose**: Explicitly show what NOT to do and provide correct alternatives

---

## 🚨 STOP! Common Mistakes That MUST Be Avoided

### 1. HTTP Requests - NEVER Use External Libraries

#### ❌ DON'T DO THIS
```python
# WRONG - Using requests library
import requests

def get_external_data():
    response = requests.get('https://api.example.com/data')
    return response.json()

def post_to_webhook():
    headers = {'Content-Type': 'application/json'}
    data = {'key': 'value'}
    response = requests.post('https://webhook.site/xyz', json=data, headers=headers)
    return response.status_code
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using frappe.request
import frappe

def get_external_data():
    response = frappe.request.get('https://api.example.com/data')
    return response.json()

def post_to_webhook():
    headers = {'Content-Type': 'application/json'}
    data = {'key': 'value'}
    response = frappe.request.post('https://webhook.site/xyz', json=data, headers=headers)
    return response.status_code
```

---

### 2. Database Queries - NEVER Write Direct SQL

#### ❌ DON'T DO THIS
```python
# WRONG - Direct SQL queries
import frappe

def get_customers():
    # NEVER write SQL directly
    customers = frappe.db.sql("""
        SELECT name, customer_name, territory 
        FROM tabCustomer 
        WHERE status = 'Active'
    """, as_dict=True)
    return customers

def update_customer_status(customer_name):
    # NEVER use SQL for updates
    frappe.db.sql("""
        UPDATE tabCustomer 
        SET status = 'Inactive' 
        WHERE name = %s
    """, customer_name)
    
def delete_old_records():
    # NEVER use SQL for deletes
    frappe.db.sql("""
        DELETE FROM tabCustomer 
        WHERE creation < DATE_SUB(NOW(), INTERVAL 1 YEAR)
    """)
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using Frappe ORM
import frappe

def get_customers():
    # Use frappe.get_all or frappe.get_list
    customers = frappe.get_all('Customer', 
        filters={'status': 'Active'},
        fields=['name', 'customer_name', 'territory']
    )
    return customers

def update_customer_status(customer_name):
    # Use frappe.db.set_value for single field updates
    frappe.db.set_value('Customer', customer_name, 'status', 'Inactive')
    
    # Or use document API for complex updates
    doc = frappe.get_doc('Customer', customer_name)
    doc.status = 'Inactive'
    doc.save()

def delete_old_records():
    # Use frappe ORM with filters
    from frappe.utils import add_years, today
    
    old_customers = frappe.get_all('Customer',
        filters={'creation': ['<', add_years(today(), -1)]},
        pluck='name'
    )
    
    for customer in old_customers:
        frappe.delete_doc('Customer', customer)
```

---

### 3. Authentication - NEVER Implement Custom Auth

#### ❌ DON'T DO THIS
```python
# WRONG - Custom JWT implementation
import jwt
import hashlib
from datetime import datetime, timedelta

def generate_token(user_id):
    # NEVER implement custom JWT
    payload = {
        'user_id': user_id,
        'exp': datetime.utcnow() + timedelta(hours=24)
    }
    token = jwt.encode(payload, 'secret_key', algorithm='HS256')
    return token

def verify_token(token):
    # NEVER implement custom token verification
    try:
        payload = jwt.decode(token, 'secret_key', algorithms=['HS256'])
        return payload['user_id']
    except jwt.ExpiredSignatureError:
        return None

def hash_password(password):
    # NEVER implement custom password hashing
    return hashlib.sha256(password.encode()).hexdigest()

def custom_login(username, password):
    # NEVER implement custom login
    hashed = hash_password(password)
    user = frappe.db.sql("""
        SELECT * FROM tabUser 
        WHERE username = %s AND password = %s
    """, (username, hashed))
    if user:
        return generate_token(user[0]['name'])
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using Frappe's authentication
import frappe

def api_authentication():
    # Use Frappe's token-based auth for APIs
    # Generate API key and secret in User settings
    # Client sends: Authorization: token api_key:api_secret
    pass

def session_authentication():
    # Use Frappe's session-based auth for web
    frappe.auth.login(username, password)
    # Session cookie is automatically managed

def check_user_permission():
    # Use Frappe's permission system
    if not frappe.has_permission('Customer', 'read'):
        frappe.throw('Insufficient permissions')

@frappe.whitelist()
def secure_api_endpoint():
    # Decorator automatically handles authentication
    # Only authenticated users can access
    return {'status': 'success'}
```

---

### 4. Background Jobs - NEVER Use External Job Queues

#### ❌ DON'T DO THIS
```python
# WRONG - Using Celery
from celery import Celery
import redis

app = Celery('tasks', broker='redis://localhost:6379')

@app.task
def process_large_import(file_path):
    # NEVER use Celery for background jobs
    process_file(file_path)
    return 'Done'

# WRONG - Using Python threading
import threading

def background_task():
    thread = threading.Thread(target=long_running_function)
    thread.start()

# WRONG - Using RQ
from rq import Queue
from redis import Redis

redis_conn = Redis()
q = Queue(connection=redis_conn)
job = q.enqueue(process_data, data)
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using frappe.enqueue
import frappe

def trigger_background_job():
    # Use frappe.enqueue for background jobs
    frappe.enqueue(
        method='app.module.process_large_import',
        queue='long',  # short, default, long
        timeout=600,
        file_path='/path/to/file'
    )

def enqueue_document_method():
    # Enqueue document methods
    frappe.enqueue_doc(
        doctype='Sales Order',
        name='SO-001',
        method='submit'
    )

# In hooks.py for scheduled jobs
scheduler_events = {
    "hourly": [
        "app.tasks.hourly_sync"
    ],
    "daily": [
        "app.tasks.daily_cleanup"
    ],
    "cron": {
        "*/5 * * * *": [
            "app.tasks.sync_every_5_minutes"
        ]
    }
}
```

---

### 5. Caching - NEVER Use Redis Directly

#### ❌ DON'T DO THIS
```python
# WRONG - Direct Redis usage
import redis
import json

r = redis.Redis(host='localhost', port=6379, db=0)

def cache_data(key, value):
    # NEVER use Redis directly
    r.set(key, json.dumps(value), ex=3600)

def get_cached_data(key):
    # NEVER access Redis directly
    data = r.get(key)
    return json.loads(data) if data else None

def clear_cache_pattern(pattern):
    # NEVER manipulate Redis directly
    for key in r.scan_iter(match=pattern):
        r.delete(key)
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using frappe.cache
import frappe

def cache_data(key, value):
    # Use frappe.cache for caching
    frappe.cache().set(key, value, expires_in_sec=3600)

def get_cached_data(key):
    # Use frappe.cache to get data
    return frappe.cache().get(key)

def clear_cache_pattern(pattern):
    # Use frappe.cache for pattern deletion
    frappe.cache().delete_keys(pattern)

def use_document_cache():
    # Use built-in document caching
    doc = frappe.get_cached_doc('Customer', 'CUST-001')
    
    # Clear document cache
    frappe.clear_cache(doctype='Customer')
```

---

### 6. Email - NEVER Use SMTP Libraries Directly

#### ❌ DON'T DO THIS
```python
# WRONG - Using smtplib
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def send_email_wrong():
    # NEVER use smtplib directly
    smtp = smtplib.SMTP('smtp.gmail.com', 587)
    smtp.starttls()
    smtp.login('user@gmail.com', 'password')
    
    msg = MIMEMultipart()
    msg['From'] = 'user@gmail.com'
    msg['To'] = 'recipient@example.com'
    msg['Subject'] = 'Test Email'
    
    body = 'This is the email body'
    msg.attach(MIMEText(body, 'plain'))
    
    smtp.send_message(msg)
    smtp.quit()

# WRONG - Using third-party email services directly
import boto3

def send_via_ses():
    # NEVER integrate email services directly
    client = boto3.client('ses')
    client.send_email(
        Source='sender@example.com',
        Destination={'ToAddresses': ['recipient@example.com']},
        Message={'Subject': {'Data': 'Test'}, 'Body': {'Text': {'Data': 'Body'}}}
    )
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using frappe.sendmail
import frappe

def send_email_correct():
    # Use frappe.sendmail for all emails
    frappe.sendmail(
        recipients=['recipient@example.com'],
        subject='Test Email',
        message='This is the email body',
        delayed=False,  # Send immediately
        reference_doctype='Customer',
        reference_name='CUST-001',
        attachments=[{
            'fname': 'document.pdf',
            'fcontent': file_content
        }]
    )

def send_templated_email():
    # Use templates for complex emails
    frappe.sendmail(
        recipients=['recipient@example.com'],
        subject='Welcome',
        template='welcome_email',
        args={
            'customer_name': 'John Doe',
            'company': 'ACME Corp'
        }
    )

def queue_bulk_emails():
    # Use email queue for bulk sending
    for recipient in recipients:
        frappe.sendmail(
            recipients=[recipient],
            subject='Newsletter',
            message=content,
            delayed=True  # Queue for later
        )
```

---

### 7. API Development - NEVER Use External Frameworks

#### ❌ DON'T DO THIS
```python
# WRONG - Using Flask
from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/api/customers', methods=['GET'])
def get_customers():
    # NEVER create separate Flask apps
    customers = fetch_customers()
    return jsonify(customers)

# WRONG - Using FastAPI
from fastapi import FastAPI

app = FastAPI()

@app.get("/api/customers")
def read_customers():
    # NEVER use FastAPI
    return {"customers": fetch_customers()}

# WRONG - Using GraphQL
import graphene

class CustomerType(graphene.ObjectType):
    # NEVER implement GraphQL
    name = graphene.String()
    email = graphene.String()

class Query(graphene.ObjectType):
    customers = graphene.List(CustomerType)
    
    def resolve_customers(self, info):
        return get_all_customers()

schema = graphene.Schema(query=Query)
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using Frappe's REST API
import frappe

@frappe.whitelist()
def get_customers():
    # Automatically available at: /api/method/app.module.get_customers
    return frappe.get_all('Customer', 
        fields=['name', 'customer_name', 'email']
    )

@frappe.whitelist(methods=['POST'])
def create_customer():
    # POST endpoint with validation
    data = frappe.local.request.json
    
    customer = frappe.get_doc({
        'doctype': 'Customer',
        'customer_name': data.get('customer_name'),
        'email': data.get('email')
    })
    customer.insert()
    
    return customer.as_dict()

# Built-in REST endpoints (no code needed):
# GET    /api/resource/Customer
# GET    /api/resource/Customer/CUST-001
# POST   /api/resource/Customer
# PUT    /api/resource/Customer/CUST-001
# DELETE /api/resource/Customer/CUST-001
```

---

### 8. File Handling - NEVER Handle Uploads Manually

#### ❌ DON'T DO THIS
```python
# WRONG - Manual file handling
import os
from werkzeug.utils import secure_filename

UPLOAD_FOLDER = '/uploads'

def save_uploaded_file(file):
    # NEVER handle file uploads manually
    filename = secure_filename(file.filename)
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    file.save(filepath)
    return filepath

def delete_file(filepath):
    # NEVER manipulate files directly
    if os.path.exists(filepath):
        os.remove(filepath)

# WRONG - Using boto3 for S3 directly
import boto3

def upload_to_s3(file):
    # NEVER integrate storage directly
    s3 = boto3.client('s3')
    s3.upload_fileobj(file, 'bucket-name', file.filename)
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using Frappe's file handling
import frappe

def handle_file_upload():
    # Use Frappe's file management
    file_doc = frappe.get_doc({
        'doctype': 'File',
        'file_name': frappe.local.uploaded_filename,
        'content': frappe.local.uploaded_file,
        'is_private': 0,
        'attached_to_doctype': 'Customer',
        'attached_to_name': 'CUST-001'
    })
    file_doc.insert()
    return file_doc.file_url

def attach_file_to_document(doctype, docname, file_url):
    # Attach existing file to document
    frappe.attach_print(
        doctype=doctype,
        name=docname,
        file_name='attachment.pdf',
        print_format='Standard'
    )

# File upload via REST API (automatic):
# POST /api/method/upload_file
# with multipart/form-data
```

---

### 9. Logging - NEVER Use print() or logging Module

#### ❌ DON'T DO THIS
```python
# WRONG - Using print statements
def process_data():
    print("Starting data processing")  # NEVER use print
    data = get_data()
    print(f"Processing {len(data)} records")  # NEVER use print
    print("Done")  # NEVER use print

# WRONG - Using logging module directly
import logging

logger = logging.getLogger(__name__)

def custom_function():
    logger.info("Function started")  # NEVER use logging directly
    try:
        process()
    except Exception as e:
        logger.error(f"Error: {e}")  # NEVER use logging directly
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using Frappe's logging
import frappe

def process_data():
    # Use frappe.logger for debug logging
    frappe.logger().info("Starting data processing")
    data = get_data()
    frappe.logger().debug(f"Processing {len(data)} records")
    
    # Use msgprint for user messages
    frappe.msgprint(f"Processing {len(data)} records")

def handle_errors():
    try:
        process()
    except Exception as e:
        # Use frappe.log_error for error logging
        frappe.log_error(
            message=frappe.get_traceback(),
            title="Processing Failed"
        )
        
        # Show error to user
        frappe.throw(f"Processing failed: {str(e)}")
```

---

### 10. Permissions - NEVER Implement Custom Authorization

#### ❌ DON'T DO THIS
```python
# WRONG - Custom permission checks
def check_permission(user, resource, action):
    # NEVER implement custom permissions
    user_roles = get_user_roles(user)
    resource_permissions = get_resource_permissions(resource)
    
    for role in user_roles:
        if action in resource_permissions.get(role, []):
            return True
    return False

def custom_role_check():
    # NEVER create custom role systems
    if current_user.role != 'admin':
        raise PermissionError("Admin access required")

# WRONG - Manual permission enforcement
def get_sensitive_data():
    # NEVER bypass Frappe's permission system
    if not is_user_authorized():
        return None
    return frappe.db.sql("SELECT * FROM tabSensitiveData")
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using Frappe's permission system
import frappe

def check_document_permission():
    # Use Frappe's permission checks
    if not frappe.has_permission('Customer', 'write'):
        frappe.throw('You do not have permission to edit customers')
    
    # Document-level permission check
    doc = frappe.get_doc('Customer', 'CUST-001')
    doc.check_permission('write')  # Throws if no permission

def get_filtered_data():
    # get_list automatically applies user permissions
    customers = frappe.get_list('Customer',
        fields=['name', 'customer_name'],
        filters={'status': 'Active'}
    )
    return customers

@frappe.whitelist()
def sensitive_operation():
    # Whitelist decorator enforces authentication
    # Add role checks as needed
    frappe.only_for('System Manager', 'Sales Manager')
    
    return process_sensitive_data()
```

---

### 11. Validation - NEVER Use External Validation Libraries

#### ❌ DON'T DO THIS
```python
# WRONG - Using external validation libraries
from cerberus import Validator
import jsonschema

def validate_with_cerberus(data):
    # NEVER use external validation libraries
    schema = {
        'name': {'type': 'string', 'required': True},
        'age': {'type': 'integer', 'min': 0}
    }
    v = Validator(schema)
    return v.validate(data)

def validate_with_jsonschema(data):
    # NEVER use jsonschema
    schema = {
        "type": "object",
        "properties": {
            "name": {"type": "string"},
            "age": {"type": "number"}
        }
    }
    jsonschema.validate(data, schema)
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using Frappe's validation
import frappe
from frappe.model.document import Document

class Customer(Document):
    def validate(self):
        # Built-in validation in document class
        if not self.customer_name:
            frappe.throw("Customer Name is required")
        
        if self.credit_limit < 0:
            frappe.throw("Credit limit cannot be negative")
        
        # Use Frappe's validation utilities
        from frappe.utils import validate_email_address
        if self.email:
            validate_email_address(self.email)

# For API validation
@frappe.whitelist()
def create_contact(email, phone=None):
    # Use Frappe's validation utilities
    from frappe.utils import validate_email_address, validate_phone_number
    
    if not validate_email_address(email):
        frappe.throw("Invalid email address")
    
    if phone and not validate_phone_number(phone):
        frappe.throw("Invalid phone number")
```

---

### 12. Templates - NEVER Use External Template Engines

#### ❌ DON'T DO THIS
```python
# WRONG - Using Jinja2 directly
from jinja2 import Template, Environment, FileSystemLoader

def render_template_wrong():
    # NEVER use Jinja2 directly
    env = Environment(loader=FileSystemLoader('templates'))
    template = env.get_template('email.html')
    return template.render(name='John', company='ACME')

# WRONG - Using other template engines
from mako.template import Template

def render_mako():
    # NEVER use alternative template engines
    tmpl = Template(filename='template.html')
    return tmpl.render(data=data)
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using Frappe's template rendering
import frappe

def render_template_correct():
    # Use frappe.render_template
    html = frappe.render_template(
        'templates/email.html',
        context={'name': 'John', 'company': 'ACME'}
    )
    return html

def render_string_template():
    # Render template strings
    template = "Hello {{ name }}, welcome to {{ company }}!"
    rendered = frappe.render_template(
        template,
        {'name': 'John', 'company': 'ACME'}
    )
    return rendered
```

---

### 13. Real-time Updates - NEVER Implement Custom WebSockets

#### ❌ DON'T DO THIS
```python
# WRONG - Custom WebSocket implementation
import websocket
import asyncio
import socketio

# NEVER create custom WebSocket servers
sio = socketio.Server()

@sio.event
def connect(sid, environ):
    print('Client connected')

# NEVER use external real-time libraries
from pusher import Pusher

def send_realtime_update():
    pusher = Pusher(app_id='xxx', key='xxx', secret='xxx')
    pusher.trigger('channel', 'event', {'message': 'data'})
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using Frappe's real-time features
import frappe

def send_realtime_update():
    # Use frappe.publish_realtime
    frappe.publish_realtime(
        event='doc_update',
        message={
            'doctype': 'Customer',
            'name': 'CUST-001',
            'status': 'Active'
        },
        user='user@example.com'  # Optional: specific user
    )

def broadcast_to_all():
    # Broadcast to all users
    frappe.publish_realtime(
        event='announcement',
        message={'text': 'System maintenance at 10 PM'}
    )

# Client-side subscription (JavaScript)
# frappe.realtime.on('doc_update', function(data) {
#     console.log('Document updated:', data);
# });
```

---

### 14. PDF Generation - NEVER Use External PDF Libraries

#### ❌ DON'T DO THIS
```python
# WRONG - Using reportlab
from reportlab.pdfgen import canvas

def generate_pdf_wrong():
    # NEVER use reportlab directly
    c = canvas.Canvas("document.pdf")
    c.drawString(100, 750, "Hello World")
    c.save()

# WRONG - Using other PDF libraries
import pdfkit
from weasyprint import HTML

def create_pdf_wrong():
    # NEVER use external PDF libraries
    pdfkit.from_string('Hello World', 'out.pdf')
    HTML(string='<h1>Title</h1>').write_pdf('document.pdf')
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using Frappe's PDF generation
import frappe

def generate_pdf_correct():
    # Use frappe.utils.get_pdf
    html = "<h1>Invoice</h1><p>Details here...</p>"
    pdf = frappe.utils.get_pdf(html)
    
    return pdf

def get_document_pdf():
    # Get PDF of a document with print format
    html = frappe.get_print(
        doctype='Sales Invoice',
        name='SINV-001',
        format='Standard Invoice'
    )
    pdf = frappe.utils.get_pdf(html)
    
    return pdf
```

---

### 15. Scheduling - NEVER Use External Schedulers

#### ❌ DON'T DO THIS
```python
# WRONG - Using schedule library
import schedule
import time

def job():
    print("Running scheduled job")

# NEVER use external schedulers
schedule.every(10).minutes.do(job)
schedule.every().hour.do(job)

while True:
    schedule.run_pending()
    time.sleep(1)

# WRONG - Using APScheduler
from apscheduler.schedulers.blocking import BlockingScheduler

scheduler = BlockingScheduler()
scheduler.add_job(job, 'interval', hours=1)
scheduler.start()
```

#### ✅ DO THIS INSTEAD
```python
# CORRECT - Using Frappe's scheduler
# In hooks.py file:

scheduler_events = {
    "all": [
        "app.tasks.run_every_event"
    ],
    "hourly": [
        "app.tasks.hourly_backup"
    ],
    "daily": [
        "app.tasks.daily_cleanup"
    ],
    "weekly": [
        "app.tasks.weekly_report"
    ],
    "monthly": [
        "app.tasks.monthly_billing"
    ],
    "cron": {
        "*/5 * * * *": [
            "app.tasks.sync_every_5_minutes"
        ],
        "0 2 * * *": [
            "app.tasks.nightly_batch_job"
        ]
    }
}

# The actual task functions
def hourly_backup():
    # This runs every hour
    backup_database()

def sync_every_5_minutes():
    # This runs every 5 minutes via cron
    sync_with_external_system()
```

---

## 📊 Quick Reference Table

| Task | ❌ NEVER Use | ✅ ALWAYS Use |
|------|--------------|---------------|
| HTTP Requests | `import requests` | `frappe.request` |
| Database Queries | Raw SQL | `frappe.get_all()`, `frappe.db` |
| Authentication | JWT, custom auth | Frappe session/token auth |
| Background Jobs | Celery, RQ | `frappe.enqueue` |
| Caching | Redis directly | `frappe.cache()` |
| Email | smtplib | `frappe.sendmail` |
| API Framework | Flask, FastAPI, GraphQL | Frappe REST API |
| File Uploads | Manual handling | Frappe File DocType |
| Logging | print(), logging | `frappe.log_error`, `frappe.logger()` |
| Permissions | Custom checks | `frappe.has_permission` |
| Validation | External libraries | Frappe validation |
| Templates | Jinja2 directly | `frappe.render_template` |
| Real-time | WebSocket, Pusher | `frappe.publish_realtime` |
| PDF Generation | reportlab, pdfkit | `frappe.utils.get_pdf` |
| Scheduling | schedule, APScheduler | Frappe scheduler |

---

## 🎯 Remember

**Every time you think about importing an external library, STOP and check if Frappe has a built-in solution. In 99% of cases, it does!**

This guide is not optional - following these patterns is MANDATORY for:
- Security
- Performance
- Maintainability
- Consistency
- Upgrade compatibility

**When in doubt, use Frappe's built-in solution!**