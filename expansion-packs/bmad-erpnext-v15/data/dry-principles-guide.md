# DRY Principles Guide - Leveraging Existing Frappe Functionality

## Don't Repeat Yourself - The Frappe Way

This guide provides practical patterns for leveraging existing Frappe functionality instead of recreating it. Follow these principles to build efficient, maintainable ERPNext applications.

## Core DRY Principles

### 1. Extend, Don't Duplicate
**Principle**: Always check if Frappe already provides the functionality before building from scratch.

### 2. Compose, Don't Recreate  
**Principle**: Combine existing Frappe features to create new functionality.

### 3. Hook, Don't Replace
**Principle**: Use Frappe's hook system to add custom behavior without modifying core functionality.

### 4. Configure, Don't Code
**Principle**: Use Frappe's configuration options before writing custom code.

## Practical DRY Patterns

### Pattern 1: DocType Extension

#### ❌ WRONG - Creating Duplicate DocType
```python
# DON'T create a new DocType that duplicates existing functionality
class CustomCustomer(Document):
    def __init__(self):
        self.customer_name = ""
        self.email = ""
        self.phone = ""
        self.address = ""
        # ... recreating Customer fields
```

#### ✅ RIGHT - Extend Existing DocType
```python
# Extend existing Customer DocType
class Customer(Document):
    def validate(self):
        super().validate()  # Keep existing validation
        self.custom_validation()  # Add your logic
    
    def custom_validation(self):
        """Add custom business rules without breaking existing ones"""
        if self.custom_field and not self.validated_custom_field:
            self.validate_custom_business_rule()
    
    def on_update(self):
        super().on_update()  # Keep existing behavior
        self.sync_to_custom_system()  # Add your integration
```

#### Adding Custom Fields
```python
# Use Custom Field DocType instead of modifying core
custom_field = frappe.get_doc({
    "doctype": "Custom Field",
    "dt": "Customer",
    "fieldname": "custom_loyalty_points",
    "label": "Loyalty Points",
    "fieldtype": "Int",
    "default": "0"
})
custom_field.insert()
```

### Pattern 2: API Composition

#### ❌ WRONG - Recreating API Logic
```python
@frappe.whitelist()
def create_customer_with_address(customer_data, address_data):
    # DON'T recreate customer creation logic
    customer = frappe.new_doc("Customer")
    customer.customer_name = customer_data["name"]
    customer.email = customer_data["email"]
    # ... manual field assignment
    customer.insert()
    
    # DON'T recreate address creation logic
    address = frappe.new_doc("Address")
    address.address_line1 = address_data["line1"]
    # ... manual field assignment
    address.insert()
```

#### ✅ RIGHT - Compose Existing APIs
```python
@frappe.whitelist()
def create_customer_with_address(customer_data, address_data):
    """Compose existing functionality"""
    
    # Use existing customer creation
    customer = frappe.get_doc({
        "doctype": "Customer",
        **customer_data
    })
    customer.insert()
    
    # Use existing address creation and link it
    address = frappe.get_doc({
        "doctype": "Address",
        "address_line1": address_data.get("line1"),
        "address_line2": address_data.get("line2"),
        "city": address_data.get("city"),
        "state": address_data.get("state"),
        "pincode": address_data.get("pincode"),
        "country": address_data.get("country"),
        "email_id": customer_data.get("email"),
        "phone": customer_data.get("phone")
    })
    address.insert()
    
    # Use existing linking mechanism
    address.append("links", {
        "link_doctype": "Customer",
        "link_name": customer.name
    })
    address.save()
    
    return {
        "customer": customer.name,
        "address": address.name
    }
```

### Pattern 3: Notification System Integration

#### ❌ WRONG - Custom Notification System
```python
def send_custom_notification(user, message):
    # DON'T create custom notification system
    import smtplib
    server = smtplib.SMTP('localhost')
    server.sendmail('system@company.com', user.email, message)
```

#### ✅ RIGHT - Use Frappe Notification Framework
```python
def send_business_notification(user, message_type, context):
    """Leverage existing notification system"""
    
    # Use Frappe's notification system
    frappe.publish_realtime(
        event='custom_business_event',
        message={
            'type': message_type,
            'message': context['message'],
            'title': context['title']
        },
        user=user
    )
    
    # Use existing email queue
    if context.get('send_email'):
        frappe.sendmail(
            recipients=[user],
            subject=context['title'],
            message=context['message'],
            reference_doctype=context.get('doctype'),
            reference_name=context.get('docname')
        )
```

### Pattern 4: Report Generation

#### ❌ WRONG - Custom Report Engine
```python
class CustomReportGenerator:
    def __init__(self):
        self.data = []
        self.columns = []
    
    def generate_pdf(self):
        # DON'T recreate PDF generation
        pass
    
    def generate_excel(self):
        # DON'T recreate Excel generation
        pass
```

#### ✅ RIGHT - Use Frappe Report Framework
```python
# Create a proper Frappe report
def execute(filters=None):
    """Use Frappe's report framework"""
    columns = get_columns()
    data = get_data(filters)
    chart = get_chart_data(data)  # Optional
    
    return columns, data, None, chart

def get_columns():
    """Define columns using Frappe patterns"""
    return [
        {
            "fieldname": "customer",
            "label": _("Customer"),
            "fieldtype": "Link",
            "options": "Customer",
            "width": 150
        },
        {
            "fieldname": "total_amount",
            "label": _("Total Amount"),
            "fieldtype": "Currency",
            "width": 120
        }
    ]

def get_data(filters):
    """Use Frappe's database methods"""
    return frappe.db.sql("""
        SELECT 
            c.name as customer,
            SUM(si.grand_total) as total_amount
        FROM `tabCustomer` c
        LEFT JOIN `tabSales Invoice` si ON si.customer = c.name
        WHERE si.posting_date BETWEEN %(from_date)s AND %(to_date)s
        GROUP BY c.name
        ORDER BY total_amount DESC
    """, filters, as_dict=1)
```

### Pattern 5: Workflow Integration

#### ❌ WRONG - Custom Approval System
```python
class CustomApprovalSystem:
    def __init__(self):
        self.approval_levels = []
        self.current_level = 0
    
    def send_for_approval(self, document):
        # DON'T create custom workflow system
        pass
```

#### ✅ RIGHT - Use Frappe Workflow
```python
# Define workflow in Workflow DocType, then use it
def trigger_approval_workflow(doc, method):
    """Hook into existing workflow system"""
    
    if doc.docstatus == 0 and doc.total_amount > 10000:
        # Use existing workflow system
        doc.workflow_state = "Pending Approval"
        
        # Use existing notification system for approvers
        approvers = frappe.get_all("User", 
            filters={"role_profile_name": "Purchase Approver"},
            fields=["name"]
        )
        
        for approver in approvers:
            frappe.publish_realtime(
                event='approval_required',
                message={
                    'doctype': doc.doctype,
                    'docname': doc.name,
                    'title': f'Approval Required: {doc.name}'
                },
                user=approver.name
            )

# Register in hooks.py
doc_events = {
    "Purchase Order": {
        "before_save": "myapp.workflows.trigger_approval_workflow"
    }
}
```

### Pattern 6: Permission System Extension

#### ❌ WRONG - Custom Permission Logic
```python
def check_custom_permission(user, document, action):
    # DON'T recreate permission system
    user_roles = get_user_roles(user)
    if "Manager" in user_roles and action == "write":
        return True
    return False
```

#### ✅ RIGHT - Extend Frappe Permission System
```python
def has_custom_business_permission(doc, user=None):
    """Extend existing permission system"""
    
    if not user:
        user = frappe.session.user
    
    # First check standard Frappe permissions
    if not frappe.has_permission(doc.doctype, "read", doc=doc.name, user=user):
        return False
    
    # Add custom business logic
    if doc.doctype == "Sales Order":
        # Custom rule: sales person can only see their own orders
        if frappe.get_value("User", user, "role_profile_name") == "Sales Person":
            return doc.owner == user or doc.sales_person == user
    
    return True

# Use in your business logic
if has_custom_business_permission(sales_order):
    # Proceed with operation
    pass
```

### Pattern 7: Data Import/Export

#### ❌ WRONG - Custom Import System
```python
class CustomDataImporter:
    def import_csv(self, file_path):
        # DON'T recreate import system
        pass
    
    def export_excel(self, data):
        # DON'T recreate export system
        pass
```

#### ✅ RIGHT - Use Frappe Data Import
```python
def bulk_import_customers(file_content, file_type="CSV"):
    """Use Frappe's data import framework"""
    
    # Use existing data import
    data_import = frappe.get_doc({
        "doctype": "Data Import",
        "import_type": "Insert New Records",
        "reference_doctype": "Customer",
        "import_file": file_content
    })
    
    # Leverage existing validation and processing
    data_import.insert()
    data_import.start_import()
    
    return data_import.name

def export_customer_data(filters=None):
    """Use Frappe's export capabilities"""
    
    # Get data using Frappe methods
    customers = frappe.get_all("Customer",
        filters=filters or {},
        fields=["name", "customer_name", "email_id", "mobile_no", "territory"]
    )
    
    # Use existing export functionality
    from frappe.utils.xlsxutils import make_xlsx
    xlsx_file = make_xlsx(customers, "Customer Export")
    
    return xlsx_file
```

### Pattern 8: Background Jobs

#### ❌ WRONG - Custom Job System
```python
import threading
def custom_background_task(data):
    # DON'T create custom threading/job system
    thread = threading.Thread(target=process_data, args=(data,))
    thread.start()
```

#### ✅ RIGHT - Use Frappe Background Jobs
```python
def schedule_data_processing(data):
    """Use Frappe's background job system"""
    
    # Enqueue job using existing system
    frappe.enqueue(
        method="myapp.tasks.process_large_dataset",
        queue="long",  # Use appropriate queue
        job_name=f"process_data_{frappe.utils.now()}",
        data=data,
        timeout=300
    )

def process_large_dataset(data):
    """Background job that processes data"""
    try:
        # Your processing logic here
        for item in data:
            # Process each item
            process_single_item(item)
            
        # Use existing notification system to report completion
        frappe.publish_realtime(
            event="job_completed",
            message={"status": "success", "processed": len(data)}
        )
        
    except Exception as e:
        # Use existing error logging
        frappe.log_error(frappe.get_traceback(), "Data Processing Job Failed")
        
        # Use existing notification system for errors
        frappe.publish_realtime(
            event="job_failed",
            message={"status": "error", "error": str(e)}
        )

# Schedule in hooks.py
scheduler_events = {
    "daily": [
        "myapp.tasks.daily_data_sync"
    ]
}
```

## DRY Configuration Patterns

### Use Frappe Settings Instead of Custom Config

#### ❌ WRONG - Custom Configuration System
```python
# DON'T create custom config files
CUSTOM_CONFIG = {
    "api_key": "secret_key",
    "batch_size": 100,
    "enable_feature": True
}
```

#### ✅ RIGHT - Use Frappe Single DocType
```python
# Create Settings DocType
class MyAppSettings(Document):
    pass  # Fields defined in JSON

# Use settings throughout app
def get_app_settings():
    return frappe.get_single("MyApp Settings")

def process_with_settings():
    settings = get_app_settings()
    batch_size = settings.batch_size or 100
    
    if settings.enable_advanced_feature:
        # Advanced processing
        pass
```

### Use Custom Fields Instead of New DocTypes

#### ❌ WRONG - Creating Similar DocType
```python
# DON'T create new DocType for simple extensions
class CustomCustomerExtension(Document):
    def __init__(self):
        self.customer = ""
        self.loyalty_points = 0
        self.preferred_payment_method = ""
```

#### ✅ RIGHT - Use Custom Fields
```python
# Add fields to existing Customer DocType
def add_custom_customer_fields():
    custom_fields = [
        {
            "doctype": "Custom Field",
            "dt": "Customer",
            "fieldname": "loyalty_points",
            "label": "Loyalty Points",
            "fieldtype": "Int",
            "default": "0"
        },
        {
            "doctype": "Custom Field", 
            "dt": "Customer",
            "fieldname": "preferred_payment_method",
            "label": "Preferred Payment Method",
            "fieldtype": "Select",
            "options": "\nCash\nCredit Card\nBank Transfer"
        }
    ]
    
    for field in custom_fields:
        if not frappe.db.exists("Custom Field", {"dt": field["dt"], "fieldname": field["fieldname"]}):
            frappe.get_doc(field).insert()
```

## DRY Testing Patterns

### Leverage Frappe Test Framework

#### ✅ RIGHT - Extend Frappe Test Classes
```python
import frappe
import unittest
from frappe.tests.utils import FrappeTestCase

class TestCustomerExtensions(FrappeTestCase):
    def setUp(self):
        # Use Frappe's test data creation
        self.customer = frappe.get_test_customer()
    
    def test_loyalty_points_calculation(self):
        """Test custom functionality using Frappe patterns"""
        
        # Use existing customer
        customer = frappe.get_doc("Customer", self.customer)
        
        # Test custom functionality
        customer.loyalty_points = 100
        customer.save()
        
        # Verify using Frappe methods
        updated_customer = frappe.get_doc("Customer", customer.name)
        self.assertEqual(updated_customer.loyalty_points, 100)
    
    def tearDown(self):
        # Cleanup using Frappe methods
        frappe.db.rollback()
```

## Performance DRY Patterns

### Use Frappe Caching

#### ❌ WRONG - Custom Caching
```python
cache = {}
def get_customer_data(customer_name):
    if customer_name in cache:
        return cache[customer_name]
    
    data = frappe.get_doc("Customer", customer_name)
    cache[customer_name] = data
    return data
```

#### ✅ RIGHT - Use Frappe Cache
```python
@frappe.cache_manager.cache()
def get_customer_analysis(customer_name):
    """Use Frappe's caching system"""
    return frappe.db.sql("""
        SELECT 
            customer_name,
            COUNT(*) as total_orders,
            SUM(grand_total) as total_value
        FROM `tabSales Invoice`
        WHERE customer = %s
    """, customer_name, as_dict=True)

# Cache will be automatically managed by Frappe
```

## Quick DRY Checklist

Before writing any code, ask:

- [ ] Does Frappe already provide this functionality?
- [ ] Can I extend an existing DocType instead of creating a new one?
- [ ] Can I use Custom Fields instead of creating a new DocType?
- [ ] Can I use hooks to add my logic to existing processes?
- [ ] Can I compose existing APIs instead of writing new ones?
- [ ] Am I following Frappe's naming and coding conventions?
- [ ] Am I using Frappe's built-in features (caching, jobs, notifications)?

## DRY Benefits

Following these patterns provides:
- ✅ **Reduced Code**: Less code to maintain
- ✅ **Better Integration**: Works seamlessly with Frappe updates
- ✅ **Consistent UX**: Users see familiar Frappe interfaces
- ✅ **Automatic Features**: Get Frappe features like permissions, audit trails, etc.
- ✅ **Better Testing**: Leverage Frappe's testing framework
- ✅ **Community Support**: Use patterns familiar to Frappe community

## Remember: Extend, Don't Recreate!

The goal is to build on Frappe's solid foundation, not replace it. Your custom functionality should feel like a natural extension of ERPNext, not a separate system bolted on top.