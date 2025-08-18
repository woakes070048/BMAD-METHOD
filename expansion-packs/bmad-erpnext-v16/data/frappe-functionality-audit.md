# Frappe Functionality Audit - Avoid Recreating Existing Features

## Purpose
This comprehensive audit prevents developers from recreating functionality that already exists in the Frappe Framework and ERPNext. Always check this list before building new features.

## 🛑 STOP - Check This First!

Before creating any new functionality, ask:
1. **Does Frappe already provide this?**
2. **Does ERPNext already have this feature?**
3. **Can I extend existing functionality instead of recreating?**
4. **Is there a standard Frappe pattern I should follow?**

## Core Frappe Framework Features

### 📊 Document Management (DON'T RECREATE)
- ✅ **Use Existing**: DocType system for data models
- ✅ **Use Existing**: Document versioning and history
- ✅ **Use Existing**: Document states (Draft, Submitted, Cancelled)
- ✅ **Use Existing**: Document permissions and sharing
- ✅ **Use Existing**: Document workflows and approval processes
- ✅ **Use Existing**: Auto-naming and naming series
- ✅ **Use Existing**: Document relationships (Link, Table, Tree)

❌ **DON'T CREATE**: Custom document management systems
❌ **DON'T CREATE**: Custom audit trails (use frappe.db.add_version)
❌ **DON'T CREATE**: Custom permission systems

### 👥 User Management & Authentication (DON'T RECREATE)
- ✅ **Use Existing**: User DocType and authentication
- ✅ **Use Existing**: Role-based permissions
- ✅ **Use Existing**: Session management
- ✅ **Use Existing**: Two-factor authentication
- ✅ **Use Existing**: Password policies and reset
- ✅ **Use Existing**: User profile and settings
- ✅ **Use Existing**: Social login integration

❌ **DON'T CREATE**: Custom login systems
❌ **DON'T CREATE**: Custom session handling
❌ **DON'T CREATE**: Custom password management

```python
# ✅ CORRECT - Use Frappe auth
import frappe
from frappe.auth import LoginManager

# ❌ WRONG - Don't create custom auth
# def my_custom_login_function():
#     # This recreates existing functionality!
```

### 📧 Communication & Notifications (DON'T RECREATE)
- ✅ **Use Existing**: Email Queue and sending
- ✅ **Use Existing**: SMS integration
- ✅ **Use Existing**: Notification framework
- ✅ **Use Existing**: Communication DocType
- ✅ **Use Existing**: Comment system
- ✅ **Use Existing**: Activity feed
- ✅ **Use Existing**: Email templates

❌ **DON'T CREATE**: Custom email sending systems
❌ **DON'T CREATE**: Custom notification systems

```python
# ✅ CORRECT - Use Frappe notifications
frappe.publish_realtime(event='custom_event', message=data)

# ❌ WRONG - Custom notification system
# def my_custom_notify():
#     # This recreates existing functionality!
```

### 📁 File Management (DON'T RECREATE)
- ✅ **Use Existing**: File and Folder DocTypes
- ✅ **Use Existing**: File upload and storage
- ✅ **Use Existing**: Image processing and thumbnails
- ✅ **Use Existing**: File permissions and sharing
- ✅ **Use Existing**: Cloud storage integration (S3, etc.)
- ✅ **Use Existing**: File compression and optimization

❌ **DON'T CREATE**: Custom file upload systems
❌ **DON'T CREATE**: Custom image processing

```python
# ✅ CORRECT - Use Frappe file handling
file_doc = frappe.get_doc({
    "doctype": "File",
    "file_name": filename,
    "content": file_content
})

# ❌ WRONG - Custom file handling
# def my_file_upload():
#     # This recreates existing functionality!
```

### 🎨 UI Components (DON'T RECREATE)
- ✅ **Use Existing**: Frappe's form rendering system
- ✅ **Use Existing**: List views and filters
- ✅ **Use Existing**: Dialog and modal systems
- ✅ **Use Existing**: Progress bars and indicators
- ✅ **Use Existing**: Charts and dashboards
- ✅ **Use Existing**: Calendar and date pickers
- ✅ **Use Existing**: Tree views and hierarchies
- ✅ **Use Existing**: frappe-ui components (for Vue apps)

❌ **DON'T CREATE**: Custom form builders
❌ **DON'T CREATE**: Custom modal systems
❌ **DON'T CREATE**: Custom date pickers

```javascript
// ✅ CORRECT - Use frappe UI
new frappe.ui.Dialog({
    title: 'My Dialog',
    fields: [...]
});

// ❌ WRONG - Custom dialog
// function myCustomDialog() {
//     // This recreates existing functionality!
// }
```

### 📊 Reporting & Analytics (DON'T RECREATE)
- ✅ **Use Existing**: Report framework (Query and Script reports)
- ✅ **Use Existing**: Dashboard system
- ✅ **Use Existing**: Chart framework
- ✅ **Use Existing**: Data export (Excel, PDF, CSV)
- ✅ **Use Existing**: Report permissions and scheduling
- ✅ **Use Existing**: Number cards and KPIs

❌ **DON'T CREATE**: Custom reporting engines
❌ **DON'T CREATE**: Custom chart libraries
❌ **DON'T CREATE**: Custom export functionality

```python
# ✅ CORRECT - Use Frappe reports
def execute(filters=None):
    columns = get_columns()
    data = get_data(filters)
    return columns, data

# ❌ WRONG - Custom report system
# class MyCustomReportEngine:
#     # This recreates existing functionality!
```

### 🔗 Integration & API (DON'T RECREATE)
- ✅ **Use Existing**: REST API framework
- ✅ **Use Existing**: Webhook system
- ✅ **Use Existing**: OAuth integration
- ✅ **Use Existing**: Rate limiting
- ✅ **Use Existing**: API key management
- ✅ **Use Existing**: Data import/export tools
- ✅ **Use Existing**: Background job queue

❌ **DON'T CREATE**: Custom API frameworks
❌ **DON'T CREATE**: Custom webhook systems
❌ **DON'T CREATE**: Custom job queues

```python
# ✅ CORRECT - Use Frappe API
@frappe.whitelist()
def my_api_method():
    return {"success": True}

# ❌ WRONG - Custom API system
# class MyCustomAPI:
#     # This recreates existing functionality!
```

## ERPNext Business Features (DON'T RECREATE)

### 💰 Financial Management
- ✅ **Use Existing**: Chart of Accounts
- ✅ **Use Existing**: Journal Entry system
- ✅ **Use Existing**: Payment system
- ✅ **Use Existing**: Tax calculation engine
- ✅ **Use Existing**: Currency and exchange rates
- ✅ **Use Existing**: Cost center and budget management
- ✅ **Use Existing**: Financial reporting

### 📦 Inventory Management
- ✅ **Use Existing**: Item and Item Group system
- ✅ **Use Existing**: Stock tracking and valuation
- ✅ **Use Existing**: Warehouse management
- ✅ **Use Existing**: Serial and batch numbers
- ✅ **Use Existing**: Stock reconciliation
- ✅ **Use Existing**: Quality inspection

### 👤 Customer Relationship Management
- ✅ **Use Existing**: Customer and Lead management
- ✅ **Use Existing**: Opportunity tracking
- ✅ **Use Existing**: Communication timeline
- ✅ **Use Existing**: Campaign management
- ✅ **Use Existing**: Sales analytics

### 🏭 Manufacturing
- ✅ **Use Existing**: BOM (Bill of Materials)
- ✅ **Use Existing**: Work Order system
- ✅ **Use Existing**: Production planning
- ✅ **Use Existing**: Job card management
- ✅ **Use Existing**: Quality management

## Common Anti-Patterns to Avoid

### ❌ Custom User Management
```python
# DON'T DO THIS
class CustomUser:
    def __init__(self, email, password):
        self.email = email
        self.password = self.hash_password(password)
    
    def authenticate(self):
        # Custom authentication logic
        pass

# ✅ DO THIS INSTEAD
import frappe

@frappe.whitelist(allow_guest=True)
def custom_login(usr, pwd):
    login_manager = frappe.auth.LoginManager()
    login_manager.authenticate(usr, pwd)
    login_manager.post_login()
```

### ❌ Custom File Upload
```python
# DON'T DO THIS
def upload_file_custom(file_data, filename):
    # Custom file handling logic
    path = f"/custom/uploads/{filename}"
    with open(path, 'wb') as f:
        f.write(file_data)
    return path

# ✅ DO THIS INSTEAD
def upload_file_frappe(file_data, filename):
    file_doc = frappe.get_doc({
        "doctype": "File",
        "file_name": filename,
        "content": file_data,
        "is_private": 1
    })
    file_doc.insert()
    return file_doc.file_url
```

### ❌ Custom Email System
```python
# DON'T DO THIS
import smtplib
def send_custom_email(to, subject, message):
    # Custom SMTP logic
    server = smtplib.SMTP('localhost')
    server.sendmail(from_addr, to, message)

# ✅ DO THIS INSTEAD
frappe.sendmail(
    recipients=['user@example.com'],
    subject='Subject',
    message='Message content'
)
```

### ❌ Custom Permission System
```python
# DON'T DO THIS
class CustomPermissions:
    def has_access(self, user, document, action):
        # Custom permission logic
        return self.check_custom_rules(user, document, action)

# ✅ DO THIS INSTEAD
if frappe.has_permission(doctype, "read", doc=doc_name):
    # Proceed with operation
    pass
```

## Extend Instead of Recreate

### ✅ Extend DocTypes
```python
# Extend existing DocTypes instead of creating new ones
from frappe.model.document import Document

class CustomCustomer(Document):
    def validate(self):
        super().validate()
        # Add custom validation
        self.custom_validation()
    
    def custom_validation(self):
        # Your custom logic here
        pass
```

### ✅ Hook into Existing Events
```python
# hooks.py - Hook into existing events
doc_events = {
    "Sales Invoice": {
        "before_save": "myapp.custom.sales_invoice_before_save"
    }
}
```

### ✅ Use Existing APIs with Custom Logic
```python
@frappe.whitelist()
def enhanced_customer_creation(customer_data):
    # Use standard Customer creation
    customer = frappe.get_doc({
        "doctype": "Customer",
        **customer_data
    })
    customer.insert()
    
    # Add your custom post-creation logic
    create_custom_records(customer.name)
    
    return customer
```

## Standard Frappe Patterns

### Data Validation
```python
# ✅ Use Frappe validation patterns
def validate(self):
    self.validate_mandatory_fields()
    self.validate_custom_business_rules()

def validate_mandatory_fields(self):
    if not self.custom_field:
        frappe.throw(_("Custom Field is mandatory"))
```

### Error Handling
```python
# ✅ Use Frappe error handling
try:
    # Your logic here
    pass
except frappe.ValidationError:
    frappe.throw(_("Validation Error Message"))
except Exception as e:
    frappe.log_error(frappe.get_traceback(), "Custom Function Error")
    frappe.throw(_("An error occurred"))
```

### Database Operations
```python
# ✅ Use Frappe database methods
# Don't write raw SQL unless absolutely necessary
data = frappe.get_all("DocType", 
    filters={"status": "Active"},
    fields=["name", "title"],
    order_by="modified desc"
)
```

## Integration Points

### Use Frappe's Integration Framework
- ✅ **Webhooks**: Use Frappe's webhook system
- ✅ **REST API**: Extend Frappe's API, don't create new endpoints unnecessarily
- ✅ **OAuth**: Use Frappe's OAuth implementation
- ✅ **SSO**: Integrate with Frappe's SSO system

### Payment Gateways
- ✅ **Use Existing**: ERPNext payment gateway framework
- ✅ **Extend**: Create new payment gateway integrations using the framework
- ❌ **DON'T CREATE**: Custom payment processing from scratch

### Accounting Integration
- ✅ **Use Existing**: ERPNext's accounting engine
- ✅ **Extend**: Add custom accounting logic using hooks
- ❌ **DON'T CREATE**: Custom double-entry bookkeeping systems

## Decision Matrix

When building a feature, ask:

| Question | If Yes | If No |
|----------|--------|-------|
| Does Frappe already have this exact functionality? | **Use existing** - extend if needed | Continue evaluation |
| Can I achieve this by extending existing DocTypes? | **Extend existing** DocType | Continue evaluation |
| Can I achieve this using hooks and events? | **Use hooks** to add custom logic | Continue evaluation |
| Does this integrate with existing Frappe features? | **Follow Frappe patterns** | Consider if this belongs in Frappe ecosystem |

## Quick Reference Checklist

Before coding, verify:
- [ ] ✅ Searched Frappe documentation for existing functionality
- [ ] ✅ Searched ERPNext documentation for existing features  
- [ ] ✅ Checked existing DocTypes for similar functionality
- [ ] ✅ Reviewed existing APIs and integrations
- [ ] ✅ Considered extending instead of creating
- [ ] ✅ Verified this follows Frappe patterns and conventions
- [ ] ✅ Confirmed this adds unique value, not duplicate functionality

## Common ERPNext DocTypes to Leverage

### Master Data
- Customer, Supplier, Employee, User
- Item, Item Group, UOM, Brand
- Company, Cost Center, Account
- Address, Contact, Communication

### Transactions
- Sales Order, Purchase Order, Quotation
- Sales Invoice, Purchase Invoice, Payment Entry
- Stock Entry, Delivery Note, Purchase Receipt
- Journal Entry, Asset, Project, Task

### System
- Custom Field, Custom DocPerm, Property Setter
- Print Format, Email Template, Notification
- Workflow, Workflow State, Workflow Action
- Report, Dashboard, Number Card

## Resources for Verification

1. **Frappe Documentation**: https://frappeframework.com/docs/
2. **ERPNext User Manual**: https://docs.erpnext.com/
3. **Frappe Framework Source**: https://github.com/frappe/frappe
4. **ERPNext Source**: https://github.com/frappe/erpnext
5. **Frappe Community Forum**: https://discuss.frappe.io/

## Final Warning

🚨 **Creating duplicate functionality**:
- Increases maintenance burden
- Creates confusion for users
- Violates DRY (Don't Repeat Yourself) principles
- May conflict with future Frappe updates
- Wastes development time

**Always extend, never duplicate!**