# 🚨 CONTROLLER METHODS - MANDATORY DocType LIFECYCLE

## CRITICAL: Understanding Document States & Controller Methods

This document contains MANDATORY patterns for DocType controller methods. These methods control your document's behavior throughout its lifecycle.

---

## 🔴 UNDERSTANDING DOCUMENT TYPES

### Two Types of Documents:

#### 1. **Regular Documents** (Most Common - 80% of DocTypes)
- **Examples**: Customer, Item, Employee, User
- **Behavior**: Can be saved and edited multiple times
- **docstatus**: Always 0 (Draft/Saved)
- **Key Methods**: `validate()`, `before_save()`, `after_insert()`, `on_update()`
- **NO**: `on_submit()` or `on_cancel()` - these won't be called!

#### 2. **Submittable Documents** (Transactional - 20% of DocTypes)
- **Examples**: Sales Order, Purchase Order, Invoice, Journal Entry
- **Behavior**: Draft → Submit → Cannot edit (only cancel)
- **docstatus**: 0 (Draft) → 1 (Submitted) → 2 (Cancelled)
- **Additional Methods**: `on_submit()`, `on_cancel()`, `before_submit()`, `before_cancel()`
- **Set in DocType**: `"is_submittable": 1` in JSON

---

## 🔴 CONTROLLER METHOD LIFECYCLE

### For REGULAR Documents (Customer, Item, etc.):

```python
# [app_name]/[module_name]/doctype/[doctype_name]/[doctype_name].py

import frappe
from frappe.model.document import Document
from frappe import _

class Customer(Document):
    """Regular document - NOT submittable"""
    
    def validate(self):
        """
        ALWAYS RUNS before save (insert or update)
        Use for: Validation, setting computed fields
        """
        # Validate required custom logic
        if not self.customer_group:
            frappe.throw(_("Customer Group is mandatory"))
        
        # Set computed fields
        self.full_name = f"{self.first_name} {self.last_name}".strip()
        
        # Clean data
        self.email_id = (self.email_id or "").lower().strip()
    
    def before_save(self):
        """
        Runs AFTER validate, BEFORE database write
        Use for: Last-minute changes, external API calls
        """
        # Set defaults if not provided
        if not self.territory:
            self.territory = "All Territories"
        
        # Update modified timestamp
        self.last_updated = frappe.utils.now()
    
    def after_insert(self):
        """
        Runs ONLY on first save (new document)
        Use for: Creating related documents, sending welcome emails
        """
        # Create default contact
        frappe.get_doc({
            "doctype": "Contact",
            "first_name": self.first_name,
            "last_name": self.last_name,
            "email_id": self.email_id,
            "links": [{
                "link_doctype": "Customer",
                "link_name": self.name
            }]
        }).insert(ignore_permissions=True)
        
        # Send welcome email
        if self.email_id:
            frappe.sendmail(
                recipients=[self.email_id],
                subject=_("Welcome to {0}").format(frappe.get_site_config().site_name),
                message=_("Your account has been created successfully.")
            )
    
    def on_update(self):
        """
        Runs AFTER every save (insert or update)
        Use for: Logging, cache clearing, notifications
        """
        # Clear cache
        frappe.cache().delete_value(f"customer_{self.name}")
        
        # Log activity
        frappe.get_doc({
            "doctype": "Activity Log",
            "subject": f"Customer {self.name} updated",
            "user": frappe.session.user
        }).insert(ignore_permissions=True)
    
    def on_trash(self):
        """
        Runs BEFORE deletion
        Use for: Cleanup, checking dependencies
        """
        # Check for linked documents
        if frappe.db.count("Sales Order", {"customer": self.name}):
            frappe.throw(_("Cannot delete Customer with existing Sales Orders"))
        
        # Delete related data
        frappe.db.delete("Contact", {"customer": self.name})
```

### For SUBMITTABLE Documents (Sales Order, Invoice, etc.):

```python
class SalesOrder(Document):
    """Submittable document - has additional lifecycle methods"""
    
    def validate(self):
        """
        Runs on EVERY save (draft or submit)
        Use for: Validation that applies to all states
        """
        if not self.items:
            frappe.throw(_("Sales Order must have at least one item"))
        
        # Calculate totals
        self.calculate_totals()
        
        # Validate dates
        if self.delivery_date < self.transaction_date:
            frappe.throw(_("Delivery Date cannot be before Order Date"))
    
    def before_save(self):
        """Runs before saving to database"""
        self.status = self.get_status()
    
    def after_insert(self):
        """First time save only"""
        # Send notification of new order
        self.notify_sales_team()
    
    def before_submit(self):
        """
        ONLY for submittable docs - runs before submission
        Use for: Final validation before locking
        """
        # Check credit limit
        self.check_credit_limit()
        
        # Validate stock availability
        for item in self.items:
            if not self.check_stock_availability(item):
                frappe.throw(_("Insufficient stock for {0}").format(item.item_code))
    
    def on_submit(self):
        """
        ONLY for submittable docs - runs after submission
        Use for: Creating follow-up documents, updating balances
        """
        # Update customer's order count
        frappe.db.set_value("Customer", self.customer, 
            "total_orders", frappe.db.count("Sales Order", 
                {"customer": self.customer, "docstatus": 1}
            )
        )
        
        # Reserve stock
        for item in self.items:
            self.reserve_stock(item)
        
        # Create tasks
        self.create_fulfillment_tasks()
        
        # Send confirmation email
        self.send_order_confirmation()
    
    def before_cancel(self):
        """
        ONLY for submittable docs - runs before cancellation
        Use for: Checking if cancellation is allowed
        """
        # Check if delivery has been made
        if frappe.db.exists("Delivery Note", 
            {"sales_order": self.name, "docstatus": 1}):
            frappe.throw(_("Cannot cancel - Delivery Note already created"))
    
    def on_cancel(self):
        """
        ONLY for submittable docs - runs after cancellation
        Use for: Reversing the effects of submission
        """
        # Release reserved stock
        for item in self.items:
            self.release_stock(item)
        
        # Update customer order count
        frappe.db.set_value("Customer", self.customer,
            "total_orders", frappe.db.count("Sales Order",
                {"customer": self.customer, "docstatus": 1}
            )
        )
        
        # Cancel related tasks
        self.cancel_fulfillment_tasks()
    
    def on_update_after_submit(self):
        """
        ONLY for submittable docs - when updating after submission
        Use for: Handling allowed changes after submit
        """
        # Only certain fields can be updated after submit
        self.validate_update_after_submit()
        
        # Log the change
        self.add_comment("Edit", f"Document updated after submit by {frappe.session.user}")
```

---

## 🔴 METHOD EXECUTION ORDER

### For NEW Regular Document:
1. `validate()`
2. `before_save()`
3. `before_insert()` (if defined)
4. → Database INSERT
5. `after_insert()`
6. `on_update()`

### For EXISTING Regular Document:
1. `validate()`
2. `before_save()`
3. → Database UPDATE
4. `on_update()`

### For SUBMITTABLE Document (Submit action):
1. `validate()`
2. `before_submit()`
3. → Set docstatus = 1
4. → Database UPDATE
5. `on_submit()`
6. `on_update()`

### For SUBMITTABLE Document (Cancel action):
1. `before_cancel()`
2. → Set docstatus = 2
3. → Database UPDATE
4. `on_cancel()`
5. `on_update()`

---

## 🔴 COMMON PATTERNS BY METHOD

### `validate()` - Data Integrity
```python
def validate(self):
    """ALWAYS runs - your main validation point"""
    # 1. Check required fields
    self.validate_required_fields()
    
    # 2. Validate data formats
    self.validate_email()
    self.validate_phone()
    
    # 3. Business rule validation
    self.validate_credit_limit()
    self.validate_duplicate()
    
    # 4. Calculate computed fields
    self.calculate_totals()
    self.set_status()
    
    # 5. Clean/format data
    self.clean_whitespace()
    self.format_currency_fields()
```

### `before_save()` - Pre-processing
```python
def before_save(self):
    """Last chance before database write"""
    # 1. Set defaults
    if not self.priority:
        self.priority = "Medium"
    
    # 2. Auto-generate codes
    if not self.code:
        self.code = self.generate_code()
    
    # 3. Update timestamps
    self.last_modified_by = frappe.session.user
    self.last_modified_on = frappe.utils.now()
```

### `after_insert()` - Post-creation
```python
def after_insert(self):
    """Only runs once when document is created"""
    # 1. Create related documents
    self.create_default_address()
    self.create_default_contact()
    
    # 2. Send notifications
    self.send_welcome_email()
    self.notify_team()
    
    # 3. Initialize tracking
    self.create_audit_log("created")
    
    # 4. Set up defaults
    self.setup_default_permissions()
```

### `on_submit()` - Finalization (ONLY for submittable)
```python
def on_submit(self):
    """Document is now locked for editing"""
    # 1. Update related documents
    self.update_party_balance()
    self.update_stock_levels()
    
    # 2. Create follow-up documents
    self.create_gl_entries()
    self.create_stock_ledger_entries()
    
    # 3. Send confirmations
    self.send_confirmation_email()
    
    # 4. Trigger workflows
    self.trigger_approval_workflow()
```

### `on_cancel()` - Reversal (ONLY for submittable)
```python
def on_cancel(self):
    """Reverse all effects of submission"""
    # 1. Reverse financial impact
    self.reverse_gl_entries()
    self.reverse_stock_entries()
    
    # 2. Update balances
    self.update_party_balance(reverse=True)
    
    # 3. Cancel related documents
    self.cancel_linked_documents()
    
    # 4. Notify stakeholders
    self.send_cancellation_notice()
```

---

## 🔴 HELPER METHOD PATTERNS

### Always Define These Helpers:

```python
class YourDocType(Document):
    
    def validate_required_fields(self):
        """Check all required fields have values"""
        required_fields = ["customer", "date", "total"]
        for field in required_fields:
            if not self.get(field):
                frappe.throw(_(f"{field.replace('_', ' ').title()} is required"))
    
    def calculate_totals(self):
        """Calculate all total fields"""
        self.total = 0
        for item in self.items:
            item.amount = flt(item.qty) * flt(item.rate)
            self.total += item.amount
        
        self.tax_amount = flt(self.total) * flt(self.tax_rate) / 100
        self.grand_total = flt(self.total) + flt(self.tax_amount)
    
    def set_status(self):
        """Set document status based on conditions"""
        if self.docstatus == 0:
            self.status = "Draft"
        elif self.docstatus == 1:
            if self.payment_status == "Paid":
                self.status = "Completed"
            else:
                self.status = "Unpaid"
        elif self.docstatus == 2:
            self.status = "Cancelled"
    
    def get_formatted_name(self):
        """Return a formatted display name"""
        return f"{self.series}-{self.number:05d}"
    
    def can_edit(self):
        """Check if document can be edited"""
        if self.docstatus != 0:
            return False
        if self.locked:
            return False
        return True
```

---

## 🔴 ACCESSING CHILD TABLES

```python
def validate(self):
    """Working with child tables (items, details, etc.)"""
    
    # 1. Iterate through child table
    for idx, item in enumerate(self.items, 1):
        # Set line number
        item.idx = idx
        
        # Validate each row
        if not item.item_code:
            frappe.throw(_("Row {0}: Item Code is required").format(idx))
        
        # Calculate row totals
        item.amount = flt(item.qty) * flt(item.rate)
    
    # 2. Add items to child table
    self.append("items", {
        "item_code": "ITEM-001",
        "qty": 1,
        "rate": 100
    })
    
    # 3. Remove items from child table
    self.items = [item for item in self.items if item.qty > 0]
    
    # 4. Clear child table
    self.items = []
```

---

## 🔴 COMMON MISTAKES TO AVOID

### ❌ WRONG: Trying to submit non-submittable doc
```python
class Customer(Document):
    def on_submit(self):  # ❌ Will NEVER run!
        # Customer is not submittable
        pass
```

### ❌ WRONG: Database operations in validate()
```python
def validate(self):
    # ❌ Don't save other docs in validate
    other_doc = frappe.get_doc("Customer", "CUST-001")
    other_doc.save()  # Can cause recursion!
```

### ❌ WRONG: Not calling parent method
```python
def validate(self):
    # ❌ Missing super().validate()
    self.my_validation()
```

### ✅ CORRECT: Proper method structure
```python
def validate(self):
    super().validate()  # Call parent if extending
    self.validate_required_fields()
    self.calculate_totals()
    # Don't save other docs here!

def after_insert(self):
    # Safe to create/save other docs here
    self.create_related_documents()
```

---

## 🔴 DEBUGGING CONTROLLER METHODS

```python
def validate(self):
    """Add debug prints to trace execution"""
    frappe.logger().debug(f"Validating {self.doctype} {self.name}")
    
    # Check what triggered the save
    frappe.logger().debug(f"Triggered by: {frappe.flags.in_insert}")
    frappe.logger().debug(f"Via import: {frappe.flags.in_import}")
    
    # Log values
    frappe.msgprint(f"Total calculated: {self.total}")
    
    # Conditional debugging
    if frappe.conf.developer_mode:
        print(f"Debug: {self.as_dict()}")
```

---

## 📋 CONTROLLER METHOD CHECKLIST

### For Regular DocTypes:
- [ ] Define `validate()` for all validation
- [ ] Use `before_save()` for defaults
- [ ] Use `after_insert()` for one-time setup
- [ ] Use `on_update()` for logging/cache
- [ ] Use `on_trash()` for cleanup
- [ ] DON'T define submit/cancel methods

### For Submittable DocTypes:
- [ ] All of the above PLUS:
- [ ] Define `before_submit()` for final checks
- [ ] Define `on_submit()` for finalization
- [ ] Define `before_cancel()` for cancel validation
- [ ] Define `on_cancel()` for reversal
- [ ] Set `"is_submittable": 1` in DocType JSON

---

## 🚀 QUICK REFERENCE

| Method | Regular Docs | Submittable Docs | When It Runs |
|--------|-------------|------------------|--------------|
| `validate()` | ✅ | ✅ | Every save |
| `before_save()` | ✅ | ✅ | Before DB write |
| `after_insert()` | ✅ | ✅ | First save only |
| `on_update()` | ✅ | ✅ | After DB write |
| `on_trash()` | ✅ | ✅ | Before delete |
| `before_submit()` | ❌ | ✅ | Before submit |
| `on_submit()` | ❌ | ✅ | After submit |
| `before_cancel()` | ❌ | ✅ | Before cancel |
| `on_cancel()` | ❌ | ✅ | After cancel |

---

**REMEMBER**: 
- Most DocTypes are NOT submittable (Customer, Item, Employee)
- Only transactional documents are submittable (Orders, Invoices, Payments)
- Choose the right methods for your document type!