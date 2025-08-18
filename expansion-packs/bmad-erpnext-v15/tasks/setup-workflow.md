# Setup ERPNext Workflow

## Overview
This task guides you through creating comprehensive workflows in ERPNext, including states, transitions, permissions, and automation. Workflows help manage document approval processes and business logic.

## Prerequisites

### Required Knowledge
- [ ] Understanding of ERPNext DocTypes and permissions
- [ ] Basic knowledge of workflow concepts (states, transitions, approvals)
- [ ] Familiarity with Python and server scripts (for advanced workflows)
- [ ] Understanding of role-based access control

### Development Environment
- [ ] ERPNext development environment is set up
- [ ] Administrator access to the system
- [ ] Target DocType exists and is properly configured

## Step-by-Step Process

### Step 1: Plan Your Workflow

#### Define Workflow Requirements
```
Business Process: Purchase Order Approval
Document Type: Purchase Order
States: Draft → Pending Approval → Approved/Rejected
Approval Levels: Manager approval for orders > $5000
Notifications: Email notifications for approval requests
Auto-transitions: None (manual approval process)
```

#### Identify Key Components
- **States**: Different stages in the document lifecycle
- **Actions**: User-triggered transitions between states
- **Roles**: Who can perform which actions
- **Conditions**: When transitions are allowed
- **Notifications**: Who gets notified about state changes

### Step 2: Create Workflow States

#### Navigate to Workflow Setup
1. Go to **Settings > Workflow > Workflow State**
2. Create new workflow states for your process

#### Create Required States
```
State 1:
- State Name: Draft
- Icon: fa fa-edit
- Color: Blue (#007bff)
- Allow Edit: All

State 2:
- State Name: Pending Approval  
- Icon: fa fa-clock-o
- Color: Orange (#ffc107)
- Allow Edit: Purchase Manager

State 3:
- State Name: Approved
- Icon: fa fa-check
- Color: Green (#28a745)
- Allow Edit: None

State 4:
- State Name: Rejected
- Icon: fa fa-times
- Color: Red (#dc3545)
- Allow Edit: Purchase User
```

### Step 3: Create Workflow Actions

#### Navigate to Workflow Action
1. Go to **Settings > Workflow > Workflow Action**
2. Create actions for state transitions

#### Define Workflow Actions
```
Action 1:
- Action Name: Submit for Approval
- Allow Self Approval: No

Action 2:
- Action Name: Approve
- Allow Self Approval: No

Action 3:
- Action Name: Reject
- Allow Self Approval: No

Action 4:
- Action Name: Revise
- Allow Self Approval: Yes
```

### Step 4: Create the Main Workflow

#### Create New Workflow
1. Go to **Settings > Workflow > Workflow**
2. Click **New** to create a workflow

#### Configure Workflow Details
```yaml
Workflow Name: Purchase Order Approval Workflow
Document Type: Purchase Order
Is Active: Yes
Send Email Alert: Yes
Workflow State Field: workflow_state
```

#### Add States to Workflow
Add states in the **States** table:
```
State: Draft
Doc Status: 0 (Draft)
Allow Edit: Purchase User
Next Possible States: Pending Approval

State: Pending Approval
Doc Status: 0 (Draft) 
Allow Edit: Purchase Manager
Next Possible States: Approved, Rejected

State: Approved
Doc Status: 1 (Submitted)
Allow Edit: (empty)
Next Possible States: (empty)

State: Rejected
Doc Status: 2 (Cancelled)
Allow Edit: Purchase User
Next Possible States: Draft
```

#### Configure Transitions
Add transitions in the **Transitions** table:
```
State: Draft
Action: Submit for Approval
Next State: Pending Approval
Allowed: Purchase User
Condition: doc.grand_total > 0

State: Pending Approval
Action: Approve
Next State: Approved
Allowed: Purchase Manager
Condition: doc.workflow_state == "Pending Approval"

State: Pending Approval
Action: Reject
Next State: Rejected
Allowed: Purchase Manager
Condition: doc.workflow_state == "Pending Approval"

State: Rejected
Action: Revise
Next State: Draft
Allowed: Purchase User
Condition: doc.workflow_state == "Rejected"
```

### Step 5: Add Advanced Workflow Logic

#### Create Server Script for Workflow Events
Navigate to **Settings > Server Script** and create a new script:

```python
# Server Script for Purchase Order Workflow
# Event: Before Save

import frappe
from frappe import _

def purchase_order_workflow_handler(doc, method):
    """Handle Purchase Order workflow logic"""
    
    if doc.doctype != "Purchase Order":
        return
    
    # Get previous workflow state
    if doc.is_new():
        previous_state = None
    else:
        previous_state = frappe.db.get_value("Purchase Order", doc.name, "workflow_state")
    
    current_state = doc.workflow_state
    
    # Handle state-specific logic
    if current_state == "Pending Approval":
        handle_approval_request(doc, previous_state)
    elif current_state == "Approved":
        handle_approval_granted(doc, previous_state)
    elif current_state == "Rejected":
        handle_rejection(doc, previous_state)

def handle_approval_request(doc, previous_state):
    """Handle when PO is submitted for approval"""
    
    # Validate approval requirements
    if doc.grand_total > 10000:
        # High-value orders need additional validation
        if not doc.justification:
            frappe.throw(_("Justification is required for orders above $10,000"))
    
    # Set approval request date
    doc.approval_request_date = frappe.utils.now()
    
    # Notify approvers
    notify_approvers(doc)

def handle_approval_granted(doc, previous_state):
    """Handle when PO is approved"""
    
    # Set approval details
    doc.approved_by = frappe.session.user
    doc.approval_date = frappe.utils.now()
    
    # Auto-submit the document
    if doc.docstatus == 0:
        doc.docstatus = 1
    
    # Create purchase receipt if configured
    if doc.auto_create_receipt:
        create_purchase_receipt(doc)
    
    # Notify requester
    notify_approval_decision(doc, "approved")

def handle_rejection(doc, previous_state):
    """Handle when PO is rejected"""
    
    # Set rejection details  
    doc.rejected_by = frappe.session.user
    doc.rejection_date = frappe.utils.now()
    
    # Require rejection reason
    if not doc.rejection_reason:
        frappe.throw(_("Rejection reason is required"))
    
    # Cancel the document
    if doc.docstatus == 1:
        doc.docstatus = 2
    
    # Notify requester
    notify_approval_decision(doc, "rejected")

def notify_approvers(doc):
    """Send notification to approvers"""
    
    # Get users with Purchase Manager role
    approvers = frappe.get_all("Has Role",
        filters={"role": "Purchase Manager", "parenttype": "User"},
        fields=["parent"]
    )
    
    approver_emails = []
    for approver in approvers:
        email = frappe.db.get_value("User", approver.parent, "email")
        if email:
            approver_emails.append(email)
    
    if approver_emails:
        frappe.sendmail(
            recipients=approver_emails,
            subject=f"Purchase Order Approval Required: {doc.name}",
            template="purchase_order_approval_request",
            args={
                "doc": doc,
                "user": frappe.session.user
            },
            reference_doctype="Purchase Order",
            reference_name=doc.name
        )

def notify_approval_decision(doc, decision):
    """Notify requester about approval decision"""
    
    requester_email = frappe.db.get_value("User", doc.owner, "email")
    if requester_email:
        frappe.sendmail(
            recipients=[requester_email],
            subject=f"Purchase Order {decision.title()}: {doc.name}",
            template="purchase_order_approval_decision",
            args={
                "doc": doc,
                "decision": decision,
                "approver": frappe.session.user
            },
            reference_doctype="Purchase Order",
            reference_name=doc.name
        )

def create_purchase_receipt(doc):
    """Auto-create purchase receipt for approved orders"""
    
    try:
        # Create purchase receipt
        receipt = frappe.get_doc({
            "doctype": "Purchase Receipt",
            "supplier": doc.supplier,
            "purchase_order": doc.name,
            "posting_date": frappe.utils.today(),
            "items": []
        })
        
        # Copy items from purchase order
        for item in doc.items:
            receipt.append("items", {
                "item_code": item.item_code,
                "qty": item.qty,
                "rate": item.rate,
                "purchase_order": doc.name,
                "purchase_order_item": item.name
            })
        
        receipt.insert()
        receipt.submit()
        
        # Add comment to purchase order
        doc.add_comment("Info", f"Purchase Receipt {receipt.name} created automatically")
        
    except Exception as e:
        frappe.log_error(f"Failed to create purchase receipt: {str(e)}")

# Execute the handler
purchase_order_workflow_handler(doc, method)
```

### Step 6: Create Email Templates

#### Approval Request Template
Navigate to **Settings > Email Template** and create:

```html
<!-- Template Name: Purchase Order Approval Request -->
<div style="font-family: Arial, sans-serif; max-width: 600px;">
    <h2>Purchase Order Approval Required</h2>
    
    <div style="background: #f8f9fa; padding: 20px; margin: 20px 0; border-radius: 5px;">
        <h3>Order Details:</h3>
        <p><strong>Purchase Order:</strong> {{ doc.name }}</p>
        <p><strong>Supplier:</strong> {{ doc.supplier }}</p>
        <p><strong>Total Amount:</strong> {{ doc.currency }} {{ doc.grand_total }}</p>
        <p><strong>Required By:</strong> {{ doc.schedule_date }}</p>
        <p><strong>Requested By:</strong> {{ user }}</p>
    </div>
    
    {% if doc.justification %}
    <div style="margin: 20px 0;">
        <h4>Justification:</h4>
        <p>{{ doc.justification }}</p>
    </div>
    {% endif %}
    
    <div style="margin: 20px 0;">
        <h4>Items:</h4>
        <table style="width: 100%; border-collapse: collapse;">
            <thead>
                <tr style="background: #007bff; color: white;">
                    <th style="padding: 10px; border: 1px solid #ddd;">Item</th>
                    <th style="padding: 10px; border: 1px solid #ddd;">Qty</th>
                    <th style="padding: 10px; border: 1px solid #ddd;">Rate</th>
                    <th style="padding: 10px; border: 1px solid #ddd;">Amount</th>
                </tr>
            </thead>
            <tbody>
                {% for item in doc.items %}
                <tr>
                    <td style="padding: 10px; border: 1px solid #ddd;">{{ item.item_code }}</td>
                    <td style="padding: 10px; border: 1px solid #ddd;">{{ item.qty }}</td>
                    <td style="padding: 10px; border: 1px solid #ddd;">{{ item.rate }}</td>
                    <td style="padding: 10px; border: 1px solid #ddd;">{{ item.amount }}</td>
                </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
    
    <div style="margin: 20px 0;">
        <a href="{{ frappe.utils.get_url() }}/app/purchase-order/{{ doc.name }}" 
           style="background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
            Review Purchase Order
        </a>
    </div>
</div>
```

#### Approval Decision Template
```html
<!-- Template Name: Purchase Order Approval Decision -->
<div style="font-family: Arial, sans-serif; max-width: 600px;">
    <h2>Purchase Order {{ decision.title() }}</h2>
    
    <div style="background: {% if decision == 'approved' %}#d4edda{% else %}#f8d7da{% endif %}; 
                padding: 20px; margin: 20px 0; border-radius: 5px;">
        <p>Your Purchase Order <strong>{{ doc.name }}</strong> has been {{ decision }} by {{ approver }}.</p>
        
        {% if decision == "rejected" and doc.rejection_reason %}
        <p><strong>Rejection Reason:</strong> {{ doc.rejection_reason }}</p>
        {% endif %}
    </div>
    
    <div style="margin: 20px 0;">
        <a href="{{ frappe.utils.get_url() }}/app/purchase-order/{{ doc.name }}" 
           style="background: #007bff; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px;">
            View Purchase Order
        </a>
    </div>
</div>
```

### Step 7: Add Custom Fields for Workflow

#### Add Workflow-Related Fields
Navigate to **Customize Form** for Purchase Order and add:

```yaml
Field 1:
- Label: Justification
- Type: Text Editor
- Hidden: 0
- Read Only: 0

Field 2:
- Label: Rejection Reason  
- Type: Text
- Hidden: 0
- Read Only: 0

Field 3:
- Label: Approved By
- Type: Link (User)
- Hidden: 0
- Read Only: 1

Field 4:
- Label: Approval Date
- Type: Datetime
- Hidden: 0
- Read Only: 1
```

### Step 8: Create Client-Side Workflow Enhancements

#### Custom JavaScript for Purchase Order
Navigate to **Customize Form > Purchase Order > Client Script**:

```javascript
frappe.ui.form.on('Purchase Order', {
    refresh: function(frm) {
        // Add custom workflow buttons
        add_workflow_buttons(frm);
        
        // Set field properties based on workflow state
        set_workflow_field_properties(frm);
        
        // Show workflow status
        show_workflow_status(frm);
    },
    
    workflow_state: function(frm) {
        // Handle workflow state changes
        set_workflow_field_properties(frm);
        show_workflow_status(frm);
    }
});

function add_workflow_buttons(frm) {
    // Clear existing custom buttons
    frm.custom_buttons = {};
    
    if (!frm.doc.workflow_state || frm.is_new()) {
        return;
    }
    
    // Add workflow-specific buttons based on state and permissions
    if (frm.doc.workflow_state === "Draft" && 
        frappe.user_roles.includes("Purchase User")) {
        
        frm.add_custom_button(__('Submit for Approval'), function() {
            execute_workflow_action(frm, 'Submit for Approval');
        }, __("Workflow"));
    }
    
    if (frm.doc.workflow_state === "Pending Approval" && 
        frappe.user_roles.includes("Purchase Manager")) {
        
        frm.add_custom_button(__('Approve'), function() {
            execute_workflow_action(frm, 'Approve');
        }, __("Workflow"));
        
        frm.add_custom_button(__('Reject'), function() {
            show_rejection_dialog(frm);
        }, __("Workflow"));
    }
    
    // Add workflow history button
    frm.add_custom_button(__('Workflow History'), function() {
        show_workflow_history(frm);
    }, __("View"));
}

function set_workflow_field_properties(frm) {
    // Set field properties based on workflow state
    const state = frm.doc.workflow_state;
    
    if (state === "Pending Approval") {
        // Make justification mandatory for high-value orders
        if (frm.doc.grand_total > 10000) {
            frm.set_df_property('justification', 'reqd', 1);
        }
        
        // Make most fields read-only during approval
        frm.set_df_property('supplier', 'read_only', 1);
        frm.set_df_property('items', 'read_only', 1);
    } else if (state === "Approved") {
        // All fields read-only when approved
        frm.set_df_property('supplier', 'read_only', 1);
        frm.set_df_property('items', 'read_only', 1);
        frm.set_df_property('justification', 'read_only', 1);
    } else if (state === "Rejected") {
        // Show rejection reason
        frm.set_df_property('rejection_reason', 'hidden', 0);
        frm.set_df_property('rejection_reason', 'read_only', 1);
    }
}

function show_workflow_status(frm) {
    if (frm.doc.workflow_state) {
        const state_colors = {
            'Draft': '#17a2b8',
            'Pending Approval': '#ffc107', 
            'Approved': '#28a745',
            'Rejected': '#dc3545'
        };
        
        const color = state_colors[frm.doc.workflow_state] || '#6c757d';
        
        frm.dashboard.set_headline_alert(
            `<div style="color: ${color}; font-weight: bold;">
                Status: ${frm.doc.workflow_state}
            </div>`
        );
    }
}

function execute_workflow_action(frm, action) {
    frappe.confirm(
        __('Are you sure you want to {0}?', [action.toLowerCase()]),
        function() {
            frappe.call({
                method: 'frappe.model.workflow.apply_workflow',
                args: {
                    doc: frm.doc,
                    action: action
                },
                callback: function(r) {
                    if (!r.exc) {
                        frm.reload_doc();
                        frappe.show_alert({
                            message: __('Workflow action completed'),
                            indicator: 'green'
                        });
                    }
                }
            });
        }
    );
}

function show_rejection_dialog(frm) {
    const dialog = new frappe.ui.Dialog({
        title: __('Reject Purchase Order'),
        fields: [
            {
                fieldtype: 'Text',
                fieldname: 'rejection_reason',
                label: __('Rejection Reason'),
                reqd: 1
            }
        ],
        primary_action_label: __('Reject'),
        primary_action: function(values) {
            // Set rejection reason
            frm.set_value('rejection_reason', values.rejection_reason);
            
            // Execute workflow action
            frappe.call({
                method: 'frappe.model.workflow.apply_workflow',
                args: {
                    doc: frm.doc,
                    action: 'Reject'
                },
                callback: function(r) {
                    if (!r.exc) {
                        dialog.hide();
                        frm.reload_doc();
                        frappe.show_alert({
                            message: __('Purchase Order rejected'),
                            indicator: 'orange'
                        });
                    }
                }
            });
        }
    });
    
    dialog.show();
}

function show_workflow_history(frm) {
    // Show workflow history
    frappe.call({
        method: 'frappe.desk.form.load.get_communications',
        args: {
            doctype: frm.doc.doctype,
            name: frm.doc.name,
            limit: 20
        },
        callback: function(r) {
            if (r.message) {
                show_workflow_history_dialog(r.message);
            }
        }
    });
}

function show_workflow_history_dialog(communications) {
    const workflow_logs = communications.filter(c => 
        c.communication_type === 'Workflow' || c.reference_doctype === 'Workflow'
    );
    
    const dialog = new frappe.ui.Dialog({
        title: __('Workflow History'),
        size: 'large',
        fields: [
            {
                fieldtype: 'HTML',
                fieldname: 'workflow_history'
            }
        ]
    });
    
    let html = '<div class="workflow-history-list">';
    
    if (workflow_logs.length === 0) {
        html += '<p class="text-muted">No workflow history available.</p>';
    } else {
        workflow_logs.forEach(function(log) {
            const date = frappe.datetime.str_to_user(log.creation);
            html += `
                <div class="workflow-history-item" style="border-bottom: 1px solid #e9ecef; padding: 10px 0;">
                    <div class="workflow-action" style="font-weight: bold; color: #495057;">
                        ${log.subject || 'Workflow Action'}
                    </div>
                    <div class="workflow-details" style="color: #6c757d; font-size: 0.9em;">
                        By ${log.sender} on ${date}
                    </div>
                    ${log.content ? `<div class="workflow-content" style="margin-top: 5px;">${log.content}</div>` : ''}
                </div>
            `;
        });
    }
    
    html += '</div>';
    
    dialog.fields_dict.workflow_history.$wrapper.html(html);
    dialog.show();
}
```

### Step 9: Test the Workflow

#### Create Test Scenarios
1. **Test State Transitions**:
   - Create a new Purchase Order (should be in Draft state)
   - Submit for approval (should move to Pending Approval)
   - Approve the order (should move to Approved)

2. **Test Permission Enforcement**:
   - Login as Purchase User and try to approve (should be denied)
   - Login as Purchase Manager and approve (should work)

3. **Test Notifications**:
   - Submit order for approval and verify approvers get email
   - Approve/reject order and verify requester gets email

4. **Test Validation Logic**:
   - Try to submit high-value order without justification (should fail)
   - Try to reject without reason (should fail)

#### Testing Script
```python
# Create test Purchase Order
test_po = frappe.get_doc({
    "doctype": "Purchase Order",
    "supplier": "Test Supplier",
    "schedule_date": frappe.utils.today(),
    "items": [{
        "item_code": "Test Item",
        "qty": 10,
        "rate": 100
    }]
})
test_po.insert()

# Test workflow progression
test_po.workflow_state = "Pending Approval"
test_po.save()

# Verify state change
assert test_po.workflow_state == "Pending Approval"
print("Workflow test passed!")
```

### Step 10: Monitor and Maintain

#### Workflow Analytics
Create reports to monitor workflow performance:
```sql
-- Workflow transition times
SELECT 
    name,
    workflow_state,
    owner,
    creation,
    modified,
    DATEDIFF(modified, creation) as days_in_workflow
FROM `tabPurchase Order`
WHERE workflow_state IS NOT NULL
ORDER BY creation DESC;
```

#### Performance Optimization
- Monitor workflow execution times
- Optimize email sending for bulk operations
- Index workflow state fields for faster queries
- Clean up old workflow logs periodically

## Best Practices

### Workflow Design
- Keep workflows simple and intuitive
- Limit the number of states (5-7 maximum)
- Ensure clear transition paths
- Provide meaningful state names
- Document business rules clearly

### Permission Management
- Use role-based permissions consistently
- Test all permission combinations
- Avoid overly complex permission logic
- Document access requirements

### Notification Strategy
- Send notifications for important state changes only
- Include relevant context in notifications
- Provide direct links to documents
- Allow users to customize notification preferences

### Performance Considerations
- Use server scripts judiciously
- Avoid complex operations in workflow transitions
- Consider background jobs for heavy processing
- Monitor workflow execution performance

## Common Issues and Solutions

### Issue: Workflow Not Triggering
**Cause**: Workflow not active or field mapping incorrect
**Solution**: Check workflow is active and workflow_state field exists

### Issue: Permission Denied Errors
**Cause**: User role doesn't have required permissions
**Solution**: Verify role assignments and workflow action permissions

### Issue: Email Notifications Not Sending
**Cause**: Email template not found or SMTP not configured
**Solution**: Check email template exists and email settings are correct

### Issue: State Not Changing
**Cause**: Validation errors preventing state change
**Solution**: Check server script for validation errors and debug

---

*Your ERPNext workflow is now complete and ready for production use. Monitor its performance and gather user feedback for continuous improvement.*