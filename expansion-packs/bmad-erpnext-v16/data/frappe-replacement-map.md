# Frappe Framework Replacement Map
## External Libraries → Frappe Built-in Equivalents

**Last Updated**: 2025-08-17  
**Framework Version**: Frappe Framework 15+ | ERPNext 16  
**Purpose**: Comprehensive mapping of external libraries to Frappe Framework built-in equivalents for code cleanup operations

---

## 🚨 CRITICAL REPLACEMENT RULES

### The Replacement Priority
1. **ALWAYS** check if Frappe provides the functionality
2. **PREFER** Frappe built-ins over external libraries
3. **NEVER** add external dependencies when Frappe alternatives exist
4. **REPLACE** existing external usage with Frappe equivalents during cleanup

---

## 📡 HTTP Requests & API Calls

### requests → frappe.request

#### ❌ EXTERNAL LIBRARY (REMOVE)
```python
import requests

# GET request
response = requests.get('https://api.example.com/data', headers={'Authorization': 'Bearer token'})
data = response.json()

# POST request
payload = {'key': 'value'}
response = requests.post('https://api.example.com/submit', json=payload, headers={'Content-Type': 'application/json'})

# Error handling
try:
    response = requests.get('https://api.example.com/data', timeout=30)
    response.raise_for_status()
except requests.exceptions.RequestException as e:
    print(f"Request failed: {e}")
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe

# GET request
response = frappe.request.get('https://api.example.com/data', headers={'Authorization': 'Bearer token'})
data = response.json()

# POST request
payload = {'key': 'value'}
response = frappe.request.post('https://api.example.com/submit', json=payload, headers={'Content-Type': 'application/json'})

# Error handling
try:
    response = frappe.request.get('https://api.example.com/data', timeout=30)
    response.raise_for_status()
    data = response.json()
except Exception as e:
    frappe.log_error(f"API request failed: {e}")
    frappe.throw("Failed to fetch external data")
```

#### Automated Replacement Pattern
```python
# Find and replace pattern
FIND: r'import requests\n.*?requests\.(get|post|put|delete|patch)'
REPLACE: r'import frappe\n# Use frappe.request instead\nfrappe.request.\1'
```

---

## 🗄️ Database Operations

### SQLAlchemy/Raw SQL → Frappe ORM

#### ❌ EXTERNAL LIBRARY (REMOVE)
```python
from sqlalchemy import create_engine, text
import pymysql

# Raw database connection
engine = create_engine('mysql://user:pass@localhost/db')
connection = engine.connect()

# Raw SQL queries
result = connection.execute(text("SELECT * FROM tabCustomer WHERE status = :status"), {"status": "Active"})
customers = result.fetchall()

# Insert/Update operations
connection.execute(text("UPDATE tabCustomer SET status = :status WHERE name = :name"), 
                  {"status": "Inactive", "name": "CUST-001"})
connection.commit()
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe

# Get records with filters
customers = frappe.get_all('Customer', 
    filters={'status': 'Active'},
    fields=['name', 'customer_name', 'territory']
)

# Get single document
customer = frappe.get_doc('Customer', 'CUST-001')

# Update operations
frappe.db.set_value('Customer', 'CUST-001', 'status', 'Inactive')
# OR
customer = frappe.get_doc('Customer', 'CUST-001')
customer.status = 'Inactive'
customer.save()

# Bulk operations
for customer in customers:
    frappe.db.set_value('Customer', customer.name, 'last_updated', frappe.utils.now())
frappe.db.commit()
```

#### Automated Replacement Pattern
```python
# Complex replacement - requires manual review
FIND: r'connection\.execute\(.*?\)'
REPLACE: '# REPLACE WITH: frappe.get_all() or frappe.db operations'
```

---

## 🐼 Data Processing

### pandas → Frappe Utils + Python Built-ins

#### ❌ EXTERNAL LIBRARY (REMOVE)
```python
import pandas as pd

# Read data
df = pd.read_csv('data.csv')
df = pd.DataFrame(data)

# Data manipulation
filtered_df = df[df['status'] == 'Active']
grouped = df.groupby('territory').sum()
df['new_column'] = df['old_column'] * 2

# Export
df.to_csv('output.csv', index=False)
df.to_excel('output.xlsx', index=False)
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe
from frappe.utils import csv

# Read data using Frappe
data = frappe.get_all('Customer', fields=['name', 'status', 'territory', 'outstanding_amount'])

# Data manipulation using Python built-ins
filtered_data = [row for row in data if row.status == 'Active']

# Grouping using collections
from collections import defaultdict
grouped = defaultdict(float)
for row in data:
    grouped[row.territory] += row.outstanding_amount

# Add calculated fields
for row in data:
    row['doubled_amount'] = row.outstanding_amount * 2

# Export using Frappe utils
frappe.utils.csvutils.build_csv_response(data, 'customer_data.csv')

# For Excel export, use Frappe's Excel builder
from frappe.utils.xlsxutils import make_xlsx
xlsx_file = make_xlsx(data, 'Customer Data')
```

#### Automated Replacement Pattern
```python
# Simple cases
FIND: r'import pandas as pd'
REPLACE: '# Use Python built-ins and frappe.utils instead of pandas'

FIND: r'pd\.DataFrame\((.*?)\)'
REPLACE: r'# Use list of dicts: \1'

FIND: r'\.to_csv\('
REPLACE: '# Use frappe.utils.csvutils.build_csv_response()'
```

---

## 📨 Email Operations

### smtplib/email → frappe.sendmail

#### ❌ EXTERNAL LIBRARY (REMOVE)
```python
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Email setup
smtp_server = smtplib.SMTP('smtp.gmail.com', 587)
smtp_server.starttls()
smtp_server.login('user@example.com', 'password')

# Create message
message = MIMEMultipart()
message['From'] = 'sender@example.com'
message['To'] = 'recipient@example.com'
message['Subject'] = 'Test Subject'

body = "Email body content"
message.attach(MIMEText(body, 'plain'))

# Send email
smtp_server.send_message(message)
smtp_server.quit()
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe

# Simple email
frappe.sendmail(
    recipients=['recipient@example.com'],
    subject='Test Subject',
    message='Email body content',
    sender='sender@example.com'
)

# Email with template
frappe.sendmail(
    recipients=['recipient@example.com'],
    subject='Welcome to Our Platform',
    template='welcome_email',
    args={
        'user_name': 'John Doe',
        'login_url': 'https://yoursite.com'
    }
)

# Email with attachments
frappe.sendmail(
    recipients=['recipient@example.com'],
    subject='Document Attached',
    message='Please find the attached document.',
    attachments=[{
        'fname': 'document.pdf',
        'fcontent': pdf_content
    }]
)
```

#### Automated Replacement Pattern
```python
FIND: r'import smtplib\n.*?smtp_server\.send_message\(.*?\)'
REPLACE: 'frappe.sendmail(recipients=[...], subject="...", message="...")'
```

---

## 📊 Caching Operations

### Redis/Memcached → frappe.cache

#### ❌ EXTERNAL LIBRARY (REMOVE)
```python
import redis
import memcache

# Redis setup
redis_client = redis.Redis(host='localhost', port=6379, db=0)

# Cache operations
redis_client.set('key', 'value', ex=3600)  # Expire in 1 hour
value = redis_client.get('key')
redis_client.delete('key')

# Memcached
mc = memcache.Client(['127.0.0.1:11211'])
mc.set('key', 'value', time=3600)
value = mc.get('key')
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe

# Cache operations
frappe.cache().set_value('key', 'value', expires_in_sec=3600)
value = frappe.cache().get_value('key')
frappe.cache().delete_value('key')

# Cache with user-specific key
user_cache_key = f"user_data_{frappe.session.user}"
frappe.cache().set_value(user_cache_key, user_data, expires_in_sec=1800)

# Cache with automatic key generation
@frappe.cache(ttl=3600)
def expensive_calculation(param1, param2):
    # This function result will be cached automatically
    return complex_calculation(param1, param2)

# Clear cache pattern
frappe.cache().delete_keys('pattern:*')
```

#### Automated Replacement Pattern
```python
FIND: r'import redis\n.*?redis\.Redis\('
REPLACE: '# Use frappe.cache() instead of direct Redis'

FIND: r'redis_client\.set\((.*?)\)'
REPLACE: r'frappe.cache().set_value(\1)'

FIND: r'redis_client\.get\((.*?)\)'
REPLACE: r'frappe.cache().get_value(\1)'
```

---

## 🔐 Authentication & Security

### JWT/bcrypt/passlib → frappe.auth

#### ❌ EXTERNAL LIBRARY (REMOVE)
```python
import jwt
import bcrypt
from passlib.hash import pbkdf2_sha256

# JWT operations
payload = {'user_id': 123, 'exp': datetime.utcnow() + timedelta(hours=24)}
token = jwt.encode(payload, 'secret', algorithm='HS256')
decoded = jwt.decode(token, 'secret', algorithms=['HS256'])

# Password hashing
password = 'user_password'
hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt())
is_valid = bcrypt.checkpw(password.encode('utf-8'), hashed)

# Alternative hashing
hashed = pbkdf2_sha256.encrypt(password)
is_valid = pbkdf2_sha256.verify(password, hashed)
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe
from frappe.utils.password import check_password, update_password

# Use Frappe's session management instead of JWT
# Login user
frappe.local.login_manager.authenticate(user_email, password)

# Check if user is logged in
if frappe.session.user != 'Guest':
    # User is authenticated
    pass

# Password operations
# Set password for user
update_password(user_email, new_password)

# Verify password
is_valid = check_password(user_email, provided_password)

# Generate secure tokens
token = frappe.generate_hash(length=32)

# API key authentication
api_key = frappe.generate_hash(length=32)
frappe.db.set_value('User', user_email, 'api_key', api_key)

# Permission checking
if frappe.has_permission('DocType', 'read', user=user_email):
    # User has permission
    pass
```

#### Automated Replacement Pattern
```python
FIND: r'import jwt\n.*?jwt\.encode\('
REPLACE: '# Use frappe.session management instead of JWT'

FIND: r'import bcrypt\n.*?bcrypt\.hashpw\('
REPLACE: '# Use frappe.utils.password.update_password()'
```

---

## 🔄 Background Jobs & Queues

### Celery/RQ → frappe.enqueue

#### ❌ EXTERNAL LIBRARY (REMOVE)
```python
from celery import Celery
import rq
from redis import Redis

# Celery setup
app = Celery('myapp', broker='redis://localhost:6379')

@app.task
def process_data(data):
    # Background processing
    return processed_data

# Queue job
result = process_data.delay(my_data)

# RQ setup
redis_conn = Redis()
q = rq.Queue(connection=redis_conn)

def background_task(data):
    # Process data
    return result

# Queue job
job = q.enqueue(background_task, my_data)
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe

def process_data_task(data):
    """Background task function"""
    # Process data
    frappe.db.commit()  # Commit changes
    return processed_data

# Queue background job
frappe.enqueue(
    process_data_task,
    queue='long',  # or 'short', 'default'
    timeout=600,
    data=my_data
)

# Queue with specific parameters
frappe.enqueue(
    'myapp.tasks.heavy_processing',
    queue='long',
    timeout=1800,
    is_async=True,
    **kwargs
)

# Queue method from DocType
doc = frappe.get_doc('My DocType', 'DOC-001')
frappe.enqueue_doc(
    doc.doctype,
    'process_document',
    name=doc.name,
    queue='default'
)

# Schedule recurring job
from frappe.utils.scheduler import add_to_scheduler
add_to_scheduler(
    'myapp.tasks.daily_cleanup',
    'cron',
    cron_format='0 2 * * *'  # Daily at 2 AM
)
```

#### Automated Replacement Pattern
```python
FIND: r'from celery import Celery\n.*?@app\.task'
REPLACE: '# Use frappe.enqueue() instead of Celery'

FIND: r'\.delay\((.*?)\)'
REPLACE: r'frappe.enqueue(function_name, \1)'
```

---

## 📊 Data Validation

### marshmallow/cerberus → Frappe DocType Validation

#### ❌ EXTERNAL LIBRARY (REMOVE)
```python
from marshmallow import Schema, fields, validate
from cerberus import Validator

# Marshmallow schema
class CustomerSchema(Schema):
    name = fields.Str(required=True, validate=validate.Length(min=1, max=100))
    email = fields.Email(required=True)
    phone = fields.Str(validate=validate.Regexp(r'^\d{10}$'))
    status = fields.Str(validate=validate.OneOf(['Active', 'Inactive']))

# Validation
schema = CustomerSchema()
errors = schema.validate(data)
if errors:
    raise ValidationError(errors)

# Cerberus
schema = {
    'name': {'type': 'string', 'required': True, 'maxlength': 100},
    'email': {'type': 'string', 'regex': r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'},
    'age': {'type': 'integer', 'min': 0, 'max': 150}
}

validator = Validator(schema)
if not validator.validate(data):
    raise ValidationError(validator.errors)
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe
from frappe import _

class Customer(Document):
    def validate(self):
        """DocType validation method"""
        self.validate_email()
        self.validate_phone()
        self.validate_status()
    
    def validate_email(self):
        """Validate email format"""
        if self.email:
            if not frappe.utils.validate_email_address(self.email):
                frappe.throw(_("Invalid email address"))
    
    def validate_phone(self):
        """Validate phone number"""
        if self.phone:
            import re
            if not re.match(r'^\d{10}$', self.phone):
                frappe.throw(_("Phone number must be 10 digits"))
    
    def validate_status(self):
        """Validate status field"""
        valid_statuses = ['Active', 'Inactive']
        if self.status not in valid_statuses:
            frappe.throw(_("Status must be one of: {0}").format(', '.join(valid_statuses)))

# Server script validation
def validate_customer_data(doc, method=None):
    """Custom validation via server script"""
    if doc.doctype == 'Customer':
        if not doc.customer_name:
            frappe.throw(_("Customer Name is required"))
        
        if len(doc.customer_name) > 100:
            frappe.throw(_("Customer Name cannot exceed 100 characters"))

# API endpoint validation
@frappe.whitelist()
def create_customer(customer_data):
    """API with validation"""
    # Validate required fields
    required_fields = ['customer_name', 'email']
    for field in required_fields:
        if not customer_data.get(field):
            frappe.throw(_("Field {0} is required").format(field))
    
    # Validate email
    if not frappe.utils.validate_email_address(customer_data.get('email')):
        frappe.throw(_("Invalid email address"))
    
    # Create document
    doc = frappe.get_doc({
        'doctype': 'Customer',
        **customer_data
    })
    doc.insert()
    return doc
```

#### Automated Replacement Pattern
```python
FIND: r'from marshmallow import.*?\n.*?Schema\('
REPLACE: '# Use Frappe DocType validation methods instead'

FIND: r'schema\.validate\((.*?)\)'
REPLACE: '# Implement in DocType.validate() method'
```

---

## 🧪 Testing

### pytest/unittest (external) → Frappe Test Framework

#### ❌ EXTERNAL TESTING (AVOID)
```python
import pytest
import unittest
from unittest.mock import patch, Mock

class TestCustomer(unittest.TestCase):
    def setUp(self):
        self.customer_data = {'name': 'Test Customer'}
    
    def test_customer_creation(self):
        # External testing
        pass
    
    @patch('requests.get')
    def test_api_call(self, mock_get):
        mock_get.return_value.json.return_value = {'status': 'success'}
        # Test code
        pass

# Pytest style
def test_customer_validation():
    # Test code
    assert customer.is_valid()

@pytest.fixture
def customer_data():
    return {'name': 'Test Customer'}
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe
import unittest
from frappe.tests.utils import FrappeTestCase

class TestCustomer(FrappeTestCase):
    def setUp(self):
        """Set up test data"""
        self.customer_data = {
            'doctype': 'Customer',
            'customer_name': 'Test Customer',
            'customer_type': 'Company'
        }
    
    def test_customer_creation(self):
        """Test customer creation"""
        customer = frappe.get_doc(self.customer_data)
        customer.insert()
        
        # Verify creation
        self.assertTrue(customer.name)
        self.assertEqual(customer.customer_name, 'Test Customer')
        
        # Cleanup
        customer.delete()
    
    def test_customer_validation(self):
        """Test validation rules"""
        customer = frappe.get_doc(self.customer_data)
        customer.customer_name = ''  # Invalid
        
        with self.assertRaises(frappe.ValidationError):
            customer.insert()
    
    def test_api_endpoint(self):
        """Test API endpoint"""
        from myapp.api import get_customer_data
        
        # Create test customer
        customer = frappe.get_doc(self.customer_data)
        customer.insert()
        
        # Test API
        result = get_customer_data(customer.name)
        self.assertIsNotNone(result)
        
        # Cleanup
        customer.delete()

# Run tests using Frappe's test runner
# bench --site [site-name] run-tests --app myapp --module "myapp.tests.test_customer"
```

#### Automated Replacement Pattern
```python
FIND: r'import pytest\n.*?def test_'
REPLACE: 'import frappe\nfrom frappe.tests.utils import FrappeTestCase\n\nclass Test...(FrappeTestCase):\n    def test_'

FIND: r'@pytest\.fixture'
REPLACE: 'def setUp(self):  # Use setUp method instead'
```

---

## 📁 File Operations

### os/pathlib (complex usage) → frappe.utils

#### ❌ MANUAL FILE OPERATIONS (AVOID)
```python
import os
import shutil
from pathlib import Path

# File operations
file_path = os.path.join('path', 'to', 'file.txt')
if os.path.exists(file_path):
    with open(file_path, 'r') as f:
        content = f.read()

# Directory operations
os.makedirs('path/to/directory', exist_ok=True)
shutil.copy2('source.txt', 'destination.txt')

# File uploads
def handle_file_upload(file):
    upload_path = os.path.join('uploads', file.filename)
    file.save(upload_path)
    return upload_path
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe
from frappe.utils.file_manager import save_file

# File operations using Frappe
file_doc = frappe.get_doc('File', {'file_url': '/files/document.pdf'})
content = file_doc.get_content()

# File uploads
def handle_file_upload(file_data, doctype, docname):
    """Handle file upload the Frappe way"""
    file_doc = save_file(
        fname=file_data.filename,
        content=file_data.read(),
        dt=doctype,
        dn=docname,
        is_private=1
    )
    return file_doc

# Attach file to document
doc = frappe.get_doc('Customer', 'CUST-001')
file_doc = save_file(
    fname='customer_document.pdf',
    content=pdf_content,
    dt='Customer',
    dn=doc.name,
    folder='Customer Documents'
)

# Access file attachments
attachments = frappe.get_all('File', 
    filters={
        'attached_to_doctype': 'Customer',
        'attached_to_name': 'CUST-001'
    }
)
```

#### Automated Replacement Pattern
```python
FIND: r'import os\n.*?os\.path\.join\('
REPLACE: '# Use frappe.utils.file_manager for file operations'

FIND: r'shutil\.copy\('
REPLACE: '# Use frappe File DocType for file management'
```

---

## 🔧 Configuration Management

### configparser/python-dotenv → frappe.conf

#### ❌ EXTERNAL CONFIG (REMOVE)
```python
import configparser
from dotenv import load_dotenv
import os

# ConfigParser
config = configparser.ConfigParser()
config.read('config.ini')
database_url = config['database']['url']
api_key = config['api']['key']

# Environment variables
load_dotenv()
debug_mode = os.getenv('DEBUG', 'False') == 'True'
secret_key = os.getenv('SECRET_KEY')
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe

# Site configuration
site_config = frappe.get_site_config()
database_url = site_config.get('database_url')

# App configuration via hooks
# In hooks.py
app_configuration = {
    'api_settings': {
        'timeout': 30,
        'retry_count': 3
    }
}

# Access in code
def get_api_settings():
    """Get API settings from app configuration"""
    from frappe import get_hooks
    config = get_hooks('app_configuration')[0]
    return config.get('api_settings', {})

# Single DocType for app settings
def get_app_setting(setting_name):
    """Get setting from App Settings DocType"""
    try:
        settings = frappe.get_single('App Settings')
        return getattr(settings, setting_name, None)
    except Exception:
        return None

# Environment-specific settings
if frappe.conf.developer_mode:
    # Development settings
    debug_mode = True
else:
    # Production settings
    debug_mode = False
```

#### Automated Replacement Pattern
```python
FIND: r'import configparser\n.*?config\.read\('
REPLACE: '# Use frappe.get_site_config() or Single DocType for settings'

FIND: r'os\.getenv\((.*?)\)'
REPLACE: r'frappe.conf.get(\1)'
```

---

## 📈 Data Export/Import

### openpyxl/xlrd → frappe.utils.xlsxutils

#### ❌ EXTERNAL EXCEL LIBRARIES (REMOVE)
```python
import openpyxl
from openpyxl import Workbook
import xlrd
import pandas as pd

# Reading Excel
workbook = openpyxl.load_workbook('data.xlsx')
sheet = workbook.active
data = []
for row in sheet.iter_rows(values_only=True):
    data.append(row)

# Writing Excel
wb = Workbook()
ws = wb.active
for row_data in data:
    ws.append(row_data)
wb.save('output.xlsx')

# Using pandas
df = pd.read_excel('input.xlsx')
df.to_excel('output.xlsx', index=False)
```

#### ✅ FRAPPE BUILT-IN (USE THIS)
```python
import frappe
from frappe.utils.xlsxutils import read_xlsx_file_from_attached_file, make_xlsx

# Reading Excel files
def process_excel_upload(file_url):
    """Process uploaded Excel file"""
    data = read_xlsx_file_from_attached_file(file_url)
    
    # Process each row
    for row in data:
        if row:  # Skip empty rows
            customer_data = {
                'doctype': 'Customer',
                'customer_name': row[0],
                'email': row[1],
                'phone': row[2]
            }
            
            customer = frappe.get_doc(customer_data)
            customer.insert()

# Writing Excel files
def export_customers_to_excel():
    """Export customers to Excel"""
    customers = frappe.get_all('Customer', 
        fields=['name', 'customer_name', 'email', 'phone', 'territory']
    )
    
    # Create Excel file
    xlsx_file = make_xlsx(customers, 'Customer Data')
    
    # Save as file
    file_doc = frappe.get_doc({
        'doctype': 'File',
        'file_name': 'customers_export.xlsx',
        'content': xlsx_file.getvalue(),
        'is_private': 1
    })
    file_doc.insert()
    
    return file_doc.file_url

# Data Import Tool integration
def bulk_import_customers(file_path):
    """Use Frappe's Data Import Tool"""
    from frappe.core.doctype.data_import.data_import import import_doc
    
    data_import = frappe.get_doc({
        'doctype': 'Data Import',
        'reference_doctype': 'Customer',
        'import_file': file_path
    })
    data_import.insert()
    data_import.start_import()
```

#### Automated Replacement Pattern
```python
FIND: r'import openpyxl\n.*?load_workbook\('
REPLACE: '# Use frappe.utils.xlsxutils.read_xlsx_file_from_attached_file()'

FIND: r'\.to_excel\((.*?)\)'
REPLACE: '# Use frappe.utils.xlsxutils.make_xlsx()'
```

---

## 🎯 AUTOMATED CLEANUP SCRIPT

### Mass Replacement Tool
```python
import os
import re
import sys

class FrappeReplacementTool:
    def __init__(self, app_path):
        self.app_path = app_path
        self.replacements = [
            # HTTP Requests
            (r'import requests\b', '# REPLACED: Use frappe.request instead of requests'),
            (r'requests\.(get|post|put|delete|patch)', r'frappe.request.\1'),
            
            # Database Operations
            (r'\.execute\(.*?SELECT.*?\)', '# REPLACED: Use frappe.get_all() instead'),
            (r'\.execute\(.*?INSERT.*?\)', '# REPLACED: Use frappe.get_doc().insert() instead'),
            (r'\.execute\(.*?UPDATE.*?\)', '# REPLACED: Use frappe.db.set_value() instead'),
            
            # Caching
            (r'import redis\b', '# REPLACED: Use frappe.cache() instead of redis'),
            (r'redis_client\.(get|set|delete)', r'frappe.cache().\1_value'),
            
            # Background Jobs
            (r'@app\.task', '# REPLACED: Use frappe.enqueue() instead of Celery'),
            (r'\.delay\(', '# REPLACED: Use frappe.enqueue(function, '),
            
            # Authentication
            (r'import jwt\b', '# REPLACED: Use frappe.session instead of JWT'),
            (r'jwt\.(encode|decode)', '# REPLACED: Use Frappe authentication'),
            
            # Email
            (r'import smtplib\b', '# REPLACED: Use frappe.sendmail() instead'),
            (r'smtp_server\.send_message', '# REPLACED: Use frappe.sendmail()'),
        ]
    
    def process_file(self, file_path):
        """Process a single Python file for replacements"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            changes_made = []
            
            for pattern, replacement in self.replacements:
                matches = re.findall(pattern, content)
                if matches:
                    content = re.sub(pattern, replacement, content)
                    changes_made.append(f"Replaced {len(matches)} occurrences of: {pattern}")
            
            if content != original_content:
                # Create backup
                backup_path = file_path + '.frappe_replacement_backup'
                with open(backup_path, 'w', encoding='utf-8') as f:
                    f.write(original_content)
                
                # Write updated content
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                return {
                    'file': file_path,
                    'backup': backup_path,
                    'changes': changes_made
                }
        
        except Exception as e:
            return {
                'file': file_path,
                'error': str(e)
            }
        
        return None
    
    def process_app(self):
        """Process entire app for Frappe replacements"""
        results = []
        
        for root, dirs, files in os.walk(self.app_path):
            for file in files:
                if file.endswith('.py'):
                    file_path = os.path.join(root, file)
                    result = self.process_file(file_path)
                    if result:
                        results.append(result)
        
        return results

if __name__ == "__main__":
    app_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    tool = FrappeReplacementTool(app_path)
    results = tool.process_app()
    
    print("=== FRAPPE REPLACEMENT RESULTS ===")
    for result in results:
        if 'error' in result:
            print(f"❌ Error in {result['file']}: {result['error']}")
        else:
            print(f"✅ Updated {result['file']}")
            for change in result['changes']:
                print(f"   - {change}")
```

---

## 🚫 NEVER REPLACE - KEEP EXTERNAL

### Legitimate External Dependencies
Some external libraries are acceptable and should NOT be replaced:

#### Scientific Computing (if needed)
- `numpy` - for complex mathematical operations
- `scipy` - for scientific computing
- `matplotlib` - for advanced plotting (if Frappe charts insufficient)

#### Specialized Libraries
- `Pillow` - for advanced image processing (Frappe has basic image handling)
- `cryptography` - for advanced encryption (beyond Frappe's built-in security)
- `lxml` - for complex XML processing (if simpler alternatives insufficient)

#### Integration Libraries
- Platform-specific SDKs (AWS boto3, Google Cloud libraries)
- Payment gateway SDKs (Stripe, PayPal official libraries)
- Specialized protocols (MQTT, WebSocket libraries if not covered by Frappe)

---

## 📋 REPLACEMENT VERIFICATION

### Post-Replacement Testing
After applying replacements, verify:

1. **Functionality Test**
   ```bash
   bench --site [site] console
   >>> import app_name
   >>> # Test key functions
   ```

2. **Import Test**
   ```bash
   python3 -m py_compile $(find . -name "*.py")
   ```

3. **Dependency Check**
   ```bash
   grep -r "import requests\|import redis\|import celery" . --include="*.py"
   # Should return only commented lines
   ```

4. **Performance Test**
   - Verify no performance degradation
   - Check memory usage
   - Validate response times

Remember: **Every replacement must preserve functionality while improving Frappe compliance!**