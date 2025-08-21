# 🚨 SERVER & CLIENT SCRIPTS - AUTOMATION PATTERNS

## CRITICAL: Proper Automation = Efficient Business Processes

This document contains MANDATORY patterns for Server Scripts, Client Scripts, and automation in Frappe/ERPNext.

---

## 🔴 UNDERSTANDING FRAPPE'S SCRIPT SYSTEM

### Three Types of Scripts:

1. **Server Scripts** - Python code running on server (backend automation)
2. **Client Scripts** - JavaScript running in browser (UI automation)
3. **Form Scripts** - JavaScript in DocType .js files (form behavior)

### When to Use Each:

| Script Type | Use For | Language | Access To |
|------------|---------|----------|-----------|
| **Server Script** | Business logic, calculations, API calls | Python | Database, server resources |
| **Client Script** | UI updates, field interactions | JavaScript | Form fields, UI elements |
| **Form Script** | DocType-specific behavior | JavaScript | Current form, frappe.ui |

---

## 🔴 SERVER SCRIPTS (BACKEND AUTOMATION)

### Creating a Server Script:

1. Go to: **Customization → Server Script**
2. Set Script Type: `DocType Event`, `Scheduler Event`, or `API`
3. Write Python code

### DocType Event Server Script:

```python
# Script Type: DocType Event
# Reference Document Type: Sales Order
# DocType Event: Before Save

# PATTERN: Auto-calculate discounts based on customer tier
def calculate_tier_discount(doc):
    """Apply automatic discount based on customer tier"""
    
    # Get customer tier
    customer = frappe.get_doc("Customer", doc.customer)
    
    if customer.customer_tier == "Gold":
        discount_percent = 10
    elif customer.customer_tier == "Silver":
        discount_percent = 5
    else:
        discount_percent = 0
    
    # Apply discount to all items
    for item in doc.items:
        if not item.discount_percentage:  # Don't override manual discounts
            item.discount_percentage = discount_percent
            item.discount_amount = (item.rate * item.qty * discount_percent) / 100
    
    # Recalculate totals
    doc.calculate_taxes_and_totals()
    
    # Add comment
    if discount_percent > 0:
        frappe.msgprint(f"Applied {discount_percent}% tier discount")

# Execute the function
calculate_tier_discount(doc)
```

### API Server Script:

```python
# Script Type: API
# API Method: get_customer_summary

# PATTERN: Custom API endpoint via Server Script
def get_customer_summary():
    """Get customer order summary"""
    
    # Get parameters
    customer = frappe.form_dict.get("customer")
    from_date = frappe.form_dict.get("from_date")
    to_date = frappe.form_dict.get("to_date")
    
    # Validate
    if not customer:
        frappe.throw("Customer is required")
    
    # Check permissions
    if not frappe.has_permission("Customer", "read", customer):
        frappe.throw("Insufficient permissions")
    
    # Get data
    orders = frappe.db.sql("""
        SELECT 
            COUNT(*) as total_orders,
            SUM(grand_total) as total_amount,
            AVG(grand_total) as avg_order_value
        FROM `tabSales Order`
        WHERE customer = %s
        AND transaction_date BETWEEN %s AND %s
        AND docstatus = 1
    """, (customer, from_date, to_date), as_dict=1)
    
    # Return response
    frappe.response["message"] = {
        "success": True,
        "data": orders[0] if orders else {}
    }

# Execute
get_customer_summary()
```

### Scheduler Event Server Script:

```python
# Script Type: Scheduler Event
# Cron Format: 0 9 * * * (Daily at 9 AM)

# PATTERN: Daily automated tasks
def send_pending_order_alerts():
    """Send alerts for pending orders"""
    
    # Get pending orders older than 3 days
    pending_orders = frappe.get_all("Sales Order",
        filters={
            "status": "Draft",
            "creation": ["<", frappe.utils.add_days(frappe.utils.today(), -3)]
        },
        fields=["name", "customer", "grand_total", "owner"]
    )
    
    if pending_orders:
        # Create notification
        for order in pending_orders:
            frappe.get_doc({
                "doctype": "Notification Log",
                "subject": f"Pending Order: {order.name}",
                "for_user": order.owner,
                "document_type": "Sales Order",
                "document_name": order.name,
                "type": "Alert"
            }).insert(ignore_permissions=True)
        
        # Log summary
        frappe.log_error(
            f"Sent {len(pending_orders)} pending order alerts",
            "Daily Order Alerts"
        )

# Execute
send_pending_order_alerts()
```

---

## 🔴 CLIENT SCRIPTS (FRONTEND AUTOMATION)

### Creating a Client Script:

1. Go to: **Customization → Client Script**
2. Select DocType to customize
3. Choose trigger event
4. Write JavaScript code

### Field Interaction Pattern:

```javascript
// DocType: Sales Order
// Field: customer
// Trigger: On Change

frappe.ui.form.on('Sales Order', {
    customer: function(frm) {
        // PATTERN: Auto-fill fields based on customer
        if (frm.doc.customer) {
            // Get customer details
            frappe.call({
                method: 'frappe.client.get',
                args: {
                    doctype: 'Customer',
                    name: frm.doc.customer
                },
                callback: function(r) {
                    if (r.message) {
                        // Set fields
                        frm.set_value('customer_group', r.message.customer_group);
                        frm.set_value('territory', r.message.territory);
                        
                        // Set custom fields
                        if (r.message.default_price_list) {
                            frm.set_value('selling_price_list', r.message.default_price_list);
                        }
                        
                        // Show message
                        frappe.show_alert({
                            message: __('Customer details loaded'),
                            indicator: 'green'
                        }, 3);
                    }
                }
            });
        }
    }
});
```

### Form Validation Pattern:

```javascript
// DocType: Customer
// Trigger: validate

frappe.ui.form.on('Customer', {
    validate: function(frm) {
        // PATTERN: Custom validation rules
        
        // 1. Email format validation
        if (frm.doc.email_id && !validate_email(frm.doc.email_id)) {
            frappe.msgprint(__('Please enter a valid email address'));
            frappe.validated = false;
            return;
        }
        
        // 2. Phone number validation
        if (frm.doc.mobile_no && !validate_phone(frm.doc.mobile_no)) {
            frappe.msgprint(__('Please enter a valid phone number'));
            frappe.validated = false;
            return;
        }
        
        // 3. Business logic validation
        if (frm.doc.credit_limit && frm.doc.credit_limit < 0) {
            frappe.msgprint(__('Credit limit cannot be negative'));
            frappe.validated = false;
            return;
        }
    }
});

function validate_email(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

function validate_phone(phone) {
    const re = /^[\d\s\-\+\(\)]+$/;
    return re.test(phone) && phone.length >= 10;
}
```

### Dynamic Form Behavior:

```javascript
// DocType: Quotation
// Trigger: refresh, onload

frappe.ui.form.on('Quotation', {
    refresh: function(frm) {
        // PATTERN: Dynamic button and field visibility
        
        // 1. Add custom button
        if (frm.doc.docstatus === 1 && frm.doc.status !== 'Ordered') {
            frm.add_custom_button(__('Create Sales Order'), function() {
                create_sales_order(frm);
            }, __('Create'));
        }
        
        // 2. Show/hide fields based on condition
        frm.toggle_display('discount_section', frm.doc.total > 1000);
        
        // 3. Make fields read-only conditionally
        frm.set_df_property('customer', 'read_only', frm.doc.docstatus === 1);
        
        // 4. Set field descriptions dynamically
        if (frm.doc.customer) {
            frappe.call({
                method: 'frappe.client.get_value',
                args: {
                    doctype: 'Customer',
                    filters: {name: frm.doc.customer},
                    fieldname: ['credit_limit', 'outstanding_amount']
                },
                callback: function(r) {
                    if (r.message) {
                        const available = r.message.credit_limit - r.message.outstanding_amount;
                        frm.set_df_property('customer', 'description', 
                            __('Available Credit: {0}', [format_currency(available)]));
                    }
                }
            });
        }
    },
    
    onload: function(frm) {
        // PATTERN: Set defaults on new document
        if (frm.is_new()) {
            frm.set_value('transaction_date', frappe.datetime.nowdate());
            frm.set_value('valid_till', frappe.datetime.add_days(frappe.datetime.nowdate(), 30));
        }
    }
});

function create_sales_order(frm) {
    frappe.model.open_mapped_doc({
        method: 'erpnext.selling.doctype.quotation.quotation.make_sales_order',
        frm: frm
    });
}
```

---

## 🔴 CHILD TABLE MANIPULATION

### Adding Rows to Child Table:

```javascript
// PATTERN: Add items to child table programmatically
frappe.ui.form.on('Sales Order', {
    add_standard_items: function(frm) {
        // Clear existing items
        frm.clear_table('items');
        
        // Add standard items
        const standard_items = [
            {item_code: 'ITEM-001', qty: 1, rate: 100},
            {item_code: 'ITEM-002', qty: 2, rate: 200},
            {item_code: 'ITEM-003', qty: 1, rate: 150}
        ];
        
        standard_items.forEach(function(item) {
            let row = frm.add_child('items');
            row.item_code = item.item_code;
            row.qty = item.qty;
            row.rate = item.rate;
        });
        
        frm.refresh_field('items');
        frm.trigger('calculate_total');
    }
});

// Child table events
frappe.ui.form.on('Sales Order Item', {
    qty: function(frm, cdt, cdn) {
        calculate_item_amount(frm, cdt, cdn);
    },
    
    rate: function(frm, cdt, cdn) {
        calculate_item_amount(frm, cdt, cdn);
    },
    
    items_remove: function(frm) {
        calculate_order_total(frm);
    }
});

function calculate_item_amount(frm, cdt, cdn) {
    let row = locals[cdt][cdn];
    row.amount = row.qty * row.rate;
    frm.refresh_field('items');
    calculate_order_total(frm);
}
```

---

## 🔴 FORM SCRIPTS (DOCTYPE-SPECIFIC)

### Form Script File Structure:

```javascript
// [app_name]/[module]/doctype/[doctype]/[doctype].js

frappe.ui.form.on('Customer', {
    setup: function(frm) {
        // PATTERN: Setup queries and filters
        frm.set_query('lead_name', function() {
            return {
                filters: {
                    'status': 'Open',
                    'company': frm.doc.company
                }
            };
        });
    },
    
    onload: function(frm) {
        // PATTERN: Initialize form
        if (!frm.doc.credit_limit) {
            frm.set_value('credit_limit', 5000);
        }
    },
    
    refresh: function(frm) {
        // PATTERN: Add dashboard, buttons, indicators
        
        // 1. Add dashboard
        frm.dashboard.add_indicator(__('Total Orders: {0}', [frm.doc.total_orders]), 'blue');
        
        // 2. Add buttons
        if (!frm.is_new()) {
            frm.add_custom_button(__('View Ledger'), function() {
                frappe.set_route('query-report', 'General Ledger', {
                    party_type: 'Customer',
                    party: frm.doc.name
                });
            });
        }
        
        // 3. Show/hide sections
        frm.toggle_display('credit_limit_section', frm.doc.customer_type === 'Company');
    },
    
    validate: function(frm) {
        // PATTERN: Form validation
        if (frm.doc.credit_limit < frm.doc.outstanding_amount) {
            frappe.throw(__('Credit limit cannot be less than outstanding amount'));
        }
    },
    
    before_save: function(frm) {
        // PATTERN: Pre-save operations
        frm.doc.modified_by_user = frappe.session.user;
    },
    
    after_save: function(frm) {
        // PATTERN: Post-save operations
        frappe.show_alert({
            message: __('Customer {0} saved successfully', [frm.doc.name]),
            indicator: 'green'
        });
    }
});
```

---

## 🔴 COMMON AUTOMATION PATTERNS

### Auto-numbering Pattern:

```python
# Server Script - Before Insert
if not doc.custom_id:
    # Get last number
    last_id = frappe.db.sql("""
        SELECT MAX(CAST(SUBSTRING(custom_id, 5) AS UNSIGNED))
        FROM `tabYour DocType`
        WHERE custom_id LIKE 'CUST-%'
    """)[0][0] or 0
    
    # Set new ID
    doc.custom_id = f"CUST-{int(last_id) + 1:05d}"
```

### Status Update Pattern:

```javascript
// Client Script - After Save
frappe.ui.form.on('Project', {
    after_save: function(frm) {
        // Update status based on completion
        let completed_tasks = frm.doc.tasks.filter(t => t.status === 'Completed').length;
        let total_tasks = frm.doc.tasks.length;
        
        if (total_tasks > 0) {
            let completion = (completed_tasks / total_tasks) * 100;
            
            let status;
            if (completion === 0) status = 'Not Started';
            else if (completion < 100) status = 'In Progress';
            else status = 'Completed';
            
            if (frm.doc.status !== status) {
                frm.set_value('status', status);
                frm.set_value('percent_complete', completion);
                frm.save();
            }
        }
    }
});
```

### Notification Pattern:

```python
# Server Script - After Submit
if doc.priority == "High":
    # Send email notification
    recipients = frappe.db.get_value("User", doc.assigned_to, "email")
    
    frappe.sendmail(
        recipients=[recipients],
        subject=f"High Priority Task: {doc.name}",
        message=f"""
        <p>A high priority task has been assigned to you:</p>
        <p><b>Task:</b> {doc.subject}</p>
        <p><b>Due Date:</b> {doc.due_date}</p>
        <p><b>Description:</b> {doc.description}</p>
        """,
        delayed=False
    )
    
    # Create notification
    notification = frappe.new_doc("Notification Log")
    notification.subject = f"High Priority: {doc.subject}"
    notification.for_user = doc.assigned_to
    notification.document_type = doc.doctype
    notification.document_name = doc.name
    notification.insert(ignore_permissions=True)
```

---

## 🔴 BEST PRACTICES & ANTI-PATTERNS

### ✅ DO THIS:
```javascript
// Use proper error handling
try {
    // Your code
    updateCustomer(frm);
} catch(e) {
    frappe.msgprint(__('Error: {0}', [e.message]));
}

// Debounce expensive operations
frappe.ui.form.on('Item', {
    item_name: frappe.utils.debounce(function(frm) {
        // This runs 300ms after user stops typing
        searchRelatedItems(frm);
    }, 300)
});

// Show loading state
frm.disable_save();
frappe.show_alert('Processing...');
// ... async operation
frm.enable_save();
```

### ❌ DON'T DO THIS:
```javascript
// Don't use synchronous AJAX
$.ajax({
    async: false,  // BAD - blocks UI
    url: '/api/method'
});

// Don't modify DOM directly
document.getElementById('field').value = 'test';  // BAD

// Don't use infinite loops
while(true) {  // BAD - will freeze browser
    checkCondition();
}

// Don't hardcode values
frm.set_value('company', 'Acme Corp');  // BAD - use settings
```

---

## 📋 SCRIPT CHECKLIST

Before deploying scripts:

- [ ] Test in development environment
- [ ] Handle all error cases
- [ ] Check permissions properly
- [ ] Use translations for messages
- [ ] Avoid hardcoded values
- [ ] Document complex logic
- [ ] Test with different user roles
- [ ] Verify performance impact
- [ ] Clean up debug code
- [ ] Review security implications

---

## 🚨 SECURITY CONSIDERATIONS

### Server Scripts:
- Always validate input
- Check permissions before operations
- Don't expose sensitive data
- Use parameterized queries
- Log security events

### Client Scripts:
- Never trust client-side validation alone
- Don't store sensitive data in browser
- Validate on server side too
- Sanitize user inputs
- Use CSRF tokens

---

**REMEMBER**: Scripts are powerful but can break things - always test thoroughly!