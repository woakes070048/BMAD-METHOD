# create-workflow

## Task Description
Create Frappe Framework workflows for ERPNext DocTypes to manage document approval processes and state transitions.

## Parameters
- `doctype`: Target DocType for workflow
- `workflow_name`: Name of the workflow
- `states`: List of workflow states (Draft, Pending, Approved, etc.)
- `transitions`: Allowed state transitions
- `roles`: Roles involved in the workflow
- `auto_transitions`: Automatic transitions based on conditions

## Prerequisites
- DocType exists and is configured
- Business process workflow defined
- User roles created
- Permission structure planned

## Steps

### 1. Workflow Design Analysis
```python
# Analyze DocType for workflow requirements
def analyze_workflow_requirements(doctype):
    """Analyze DocType structure for workflow compatibility"""
    
    # Check if DocType is submittable
    meta = frappe.get_meta(doctype)
    if not meta.is_submittable:
        frappe.msgprint(_("Warning: DocType is not submittable. Consider making it submittable for better workflow control."))
    
    # Check existing workflow
    existing_workflow = frappe.db.get_value("Workflow", {"document_type": doctype}, "name")
    if existing_workflow:
        frappe.throw(_("Workflow already exists: {0}").format(existing_workflow))
    
    return {
        "is_submittable": meta.is_submittable,
        "has_workflow_state_field": "workflow_state" in [f.fieldname for f in meta.fields],
        "current_permissions": get_doctype_permissions(doctype)
    }
```

### 2. Create Workflow Document
```python
def create_workflow_document(workflow_data):
    """Create the main workflow document"""
    
    workflow = frappe.get_doc({
        "doctype": "Workflow",
        "workflow_name": workflow_data["workflow_name"],
        "document_type": workflow_data["doctype"],
        "is_active": 1,
        "send_email_alert": workflow_data.get("send_email_alert", 1),
        "workflow_state_field": "workflow_state",
        "states": [],
        "transitions": []
    })
    
    # Add states
    for state in workflow_data["states"]:
        workflow.append("states", {
            "state": state["name"],
            "doc_status": state.get("doc_status", 0),
            "allow_edit": state.get("allow_edit", "All"),
            "message": state.get("message", ""),
            "next_action_email_template": state.get("email_template", "")
        })
    
    # Add transitions
    for transition in workflow_data["transitions"]:
        workflow.append("transitions", {
            "state": transition["from_state"],
            "action": transition["action"],
            "next_state": transition["to_state"],
            "allowed": transition["allowed_roles"],
            "condition": transition.get("condition", ""),
            "allow_self_approval": transition.get("allow_self_approval", 0)
        })
    
    workflow.insert()
    return workflow.name
```

### 3. Configure Workflow States
```python
# Standard workflow states for different processes
STANDARD_WORKFLOWS = {
    "approval_workflow": {
        "states": [
            {
                "name": "Draft",
                "doc_status": 0,
                "allow_edit": "All",
                "message": "Document is in draft state"
            },
            {
                "name": "Pending Approval",
                "doc_status": 0,
                "allow_edit": "System Manager",
                "message": "Document is pending approval"
            },
            {
                "name": "Approved",
                "doc_status": 1,
                "allow_edit": "System Manager",
                "message": "Document has been approved"
            },
            {
                "name": "Rejected",
                "doc_status": 0,
                "allow_edit": "All",
                "message": "Document has been rejected"
            }
        ],
        "transitions": [
            {
                "from_state": "Draft",
                "action": "Submit for Approval",
                "to_state": "Pending Approval",
                "allowed_roles": "Employee, Manager"
            },
            {
                "from_state": "Pending Approval", 
                "action": "Approve",
                "to_state": "Approved",
                "allowed_roles": "Manager, System Manager"
            },
            {
                "from_state": "Pending Approval",
                "action": "Reject",
                "to_state": "Rejected", 
                "allowed_roles": "Manager, System Manager"
            },
            {
                "from_state": "Rejected",
                "action": "Resubmit",
                "to_state": "Draft",
                "allowed_roles": "Employee, Manager"
            }
        ]
    },
    
    "purchase_approval": {
        "states": [
            {
                "name": "Draft",
                "doc_status": 0,
                "allow_edit": "All"
            },
            {
                "name": "Pending Manager Approval",
                "doc_status": 0,
                "allow_edit": "Purchase Manager"
            },
            {
                "name": "Pending Finance Approval", 
                "doc_status": 0,
                "allow_edit": "Accounts Manager"
            },
            {
                "name": "Approved",
                "doc_status": 1,
                "allow_edit": "System Manager"
            },
            {
                "name": "Rejected",
                "doc_status": 0,
                "allow_edit": "All"
            }
        ],
        "transitions": [
            {
                "from_state": "Draft",
                "action": "Submit",
                "to_state": "Pending Manager Approval",
                "allowed_roles": "Purchase User",
                "condition": "doc.grand_total <= 10000"
            },
            {
                "from_state": "Draft", 
                "action": "Submit",
                "to_state": "Pending Finance Approval",
                "allowed_roles": "Purchase User",
                "condition": "doc.grand_total > 10000"
            },
            {
                "from_state": "Pending Manager Approval",
                "action": "Approve",
                "to_state": "Approved",
                "allowed_roles": "Purchase Manager"
            },
            {
                "from_state": "Pending Finance Approval",
                "action": "Approve", 
                "to_state": "Approved",
                "allowed_roles": "Accounts Manager"
            }
        ]
    }
}
```

### 4. Add Workflow State Field to DocType
```python
def add_workflow_state_field(doctype):
    """Add workflow_state field to DocType if not exists"""
    
    meta = frappe.get_meta(doctype)
    existing_field = None
    
    for field in meta.fields:
        if field.fieldname == "workflow_state":
            existing_field = field
            break
    
    if not existing_field:
        # Add workflow_state field
        workflow_field = {
            "fieldname": "workflow_state",
            "fieldtype": "Link",
            "label": "Workflow State",
            "options": "Workflow State",
            "hidden": 1,
            "read_only": 1,
            "no_copy": 1
        }
        
        # Get DocType document
        doctype_doc = frappe.get_doc("DocType", doctype)
        doctype_doc.append("fields", workflow_field)
        doctype_doc.save()
        
        frappe.msgprint(_("Added workflow_state field to {0}").format(doctype))
```

### 5. Configure Workflow Actions
```python
def setup_workflow_actions(workflow_name, doctype):
    """Setup custom actions for workflow transitions"""
    
    # Create custom buttons for workflow actions
    workflow_actions_js = f'''
frappe.ui.form.on("{doctype}", {{
    refresh: function(frm) {{
        if (frm.doc.workflow_state) {{
            // Add custom workflow buttons based on current state
            add_workflow_buttons(frm);
        }}
    }}
}});

function add_workflow_buttons(frm) {{
    let workflow_state = frm.doc.workflow_state;
    
    // Get available transitions for current state
    frappe.call({{
        method: "frappe.client.get",
        args: {{
            doctype: "Workflow",
            name: "{workflow_name}"
        }},
        callback: function(r) {{
            if (r.message) {{
                let transitions = r.message.transitions || [];
                transitions.forEach(function(transition) {{
                    if (transition.state === workflow_state) {{
                        frm.add_custom_button(transition.action, function() {{
                            execute_workflow_transition(frm, transition);
                        }}, __("Actions"));
                    }}
                }});
            }}
        }}
    }});
}}

function execute_workflow_transition(frm, transition) {{
    frappe.call({{
        method: "frappe.model.workflow.apply_workflow",
        args: {{
            doc: frm.doc,
            action: transition.action
        }},
        callback: function(r) {{
            if (!r.exc) {{
                frm.reload_doc();
                frappe.show_alert(__("Workflow action completed successfully"));
            }}
        }}
    }});
}}
'''
    
    # Save the JS file
    js_file_path = f"public/js/{doctype.lower()}_workflow.js"
    with open(js_file_path, 'w') as f:
        f.write(workflow_actions_js)
```

### 6. Email Notifications Setup
```python
def setup_workflow_notifications(workflow_name, doctype):
    """Setup email notifications for workflow transitions"""
    
    # Create email templates for each state
    notification_templates = [
        {
            "name": f"{workflow_name} Approval Required",
            "subject": "Approval Required: {{{{ doc.name }}}}",
            "message": """
            <p>Dear {{{{ frappe.db.get_value("User", doc.owner, "full_name") or doc.owner }}}},</p>
            <p>A {{{{ doc.doctype }}}} ({{{{ doc.name }}}}) requires your approval.</p>
            <p><strong>Details:</strong></p>
            <ul>
                <li>Document: {{{{ doc.name }}}}</li>
                <li>Current State: {{{{ doc.workflow_state }}}}</li>
                <li>Submitted by: {{{{ frappe.db.get_value("User", doc.owner, "full_name") or doc.owner }}}}</li>
            </ul>
            <p>Please review and take appropriate action.</p>
            """,
            "document_type": doctype,
            "event": "Workflow State Changed",
            "enabled": 1
        },
        {
            "name": f"{workflow_name} Status Update",
            "subject": "Status Update: {{{{ doc.name }}}}",
            "message": """
            <p>Dear {{{{ frappe.db.get_value("User", doc.owner, "full_name") or doc.owner }}}},</p>
            <p>The status of your {{{{ doc.doctype }}}} ({{{{ doc.name }}}}) has been updated.</p>
            <p><strong>New Status:</strong> {{{{ doc.workflow_state }}}}</p>
            <p>Thank you.</p>
            """,
            "document_type": doctype,
            "event": "Workflow State Changed",
            "enabled": 1
        }
    ]
    
    # Create notification documents
    for template in notification_templates:
        if not frappe.db.exists("Notification", template["name"]):
            notification = frappe.get_doc({
                "doctype": "Notification",
                **template
            })
            notification.insert()
```

### 7. Workflow Conditions and Validations
```python
def add_workflow_validations(doctype, validations):
    """Add custom validations for workflow transitions"""
    
    validation_code = f'''
# Workflow validations for {doctype}
def validate_workflow_transition(doc, method):
    """Custom validation for workflow transitions"""
    
    if not doc.workflow_state:
        return
    
    current_state = doc.workflow_state
    
    # State-specific validations
    validations = {{
        "Pending Approval": [
            validate_required_fields,
            validate_amounts,
            validate_attachments
        ],
        "Approved": [
            validate_approval_authority,
            log_approval_action
        ]
    }}
    
    if current_state in validations:
        for validation_func in validations[current_state]:
            validation_func(doc)

def validate_required_fields(doc):
    """Validate required fields before approval"""
    required_fields = {validations.get("required_fields", [])}
    
    for field in required_fields:
        if not doc.get(field):
            frappe.throw(_("{0} is required for approval").format(field))

def validate_amounts(doc):
    """Validate amounts and calculations"""
    if hasattr(doc, 'grand_total'):
        if doc.grand_total <= 0:
            frappe.throw(_("Grand Total must be greater than 0"))

def validate_attachments(doc):
    """Validate required attachments"""
    attachments = frappe.get_all("File", filters={{"attached_to_doctype": doc.doctype, "attached_to_name": doc.name}})
    
    if not attachments:
        frappe.throw(_("At least one attachment is required before approval"))

def validate_approval_authority(doc):
    """Validate if user has authority to approve"""
    if hasattr(doc, 'grand_total'):
        user_approval_limit = get_user_approval_limit(frappe.session.user)
        
        if doc.grand_total > user_approval_limit:
            frappe.throw(_("You don't have authority to approve amounts above {0}").format(user_approval_limit))

def log_approval_action(doc):
    """Log approval action for audit trail"""
    frappe.get_doc({{
        "doctype": "Comment",
        "comment_type": "Workflow",
        "reference_doctype": doc.doctype,
        "reference_name": doc.name,
        "content": f"Document approved by {{frappe.session.user}} at {{frappe.utils.now()}}",
        "comment_email": frappe.session.user
    }}).insert(ignore_permissions=True)
'''
    
    # Add to hooks.py
    return validation_code
```

### 8. Complete Workflow Setup Function
```python
@frappe.whitelist()
def setup_complete_workflow(doctype, workflow_config):
    """Complete workflow setup including all components"""
    
    try:
        # 1. Analyze requirements
        analysis = analyze_workflow_requirements(doctype)
        
        # 2. Add workflow state field if needed
        if not analysis["has_workflow_state_field"]:
            add_workflow_state_field(doctype)
        
        # 3. Create workflow document
        workflow_name = create_workflow_document(workflow_config)
        
        # 4. Setup workflow actions
        setup_workflow_actions(workflow_name, doctype)
        
        # 5. Setup notifications
        setup_workflow_notifications(workflow_name, doctype)
        
        # 6. Configure permissions
        configure_workflow_permissions(doctype, workflow_config)
        
        return {
            "success": True,
            "workflow_name": workflow_name,
            "message": _("Workflow setup completed successfully")
        }
        
    except Exception as e:
        frappe.log_error(message=str(e), title="Workflow Setup Error")
        frappe.throw(_("Error setting up workflow: {0}").format(str(e)))

def configure_workflow_permissions(doctype, workflow_config):
    """Configure role permissions for workflow"""
    
    # Clear existing permissions
    frappe.db.delete("Custom DocPerm", {"parent": doctype})
    
    # Add workflow-based permissions
    for state in workflow_config["states"]:
        for role in state.get("allowed_roles", []):
            perm = frappe.get_doc({
                "doctype": "Custom DocPerm",
                "parent": doctype,
                "parenttype": "DocType",
                "parentfield": "permissions",
                "role": role,
                "permlevel": 0,
                "read": 1,
                "write": 1 if state.get("allow_edit") == "All" or role in state.get("allow_edit", []) else 0,
                "submit": 1 if state.get("doc_status") == 1 else 0,
                "cancel": 1 if role == "System Manager" else 0,
                "delete": 1 if role == "System Manager" else 0
            })
            perm.insert()
```

## Usage Examples

### Simple Approval Workflow
```python
# Setup a simple approval workflow
workflow_config = {
    "workflow_name": "Purchase Request Approval",
    "doctype": "Purchase Request",
    "send_email_alert": 1,
    "states": STANDARD_WORKFLOWS["approval_workflow"]["states"],
    "transitions": STANDARD_WORKFLOWS["approval_workflow"]["transitions"]
}

setup_complete_workflow("Purchase Request", workflow_config)
```

### Complex Multi-Level Approval
```python
# Multi-level approval based on amount
complex_workflow = {
    "workflow_name": "Purchase Order Approval",
    "doctype": "Purchase Order", 
    "states": STANDARD_WORKFLOWS["purchase_approval"]["states"],
    "transitions": STANDARD_WORKFLOWS["purchase_approval"]["transitions"]
}

setup_complete_workflow("Purchase Order", complex_workflow)
```

## Best Practices
1. **Keep workflows simple** - Avoid overly complex state machines
2. **Use meaningful state names** - Clear, business-relevant terminology
3. **Plan role permissions** carefully before implementation
4. **Test thoroughly** with different user roles
5. **Document workflow logic** for future maintenance
6. **Include audit trails** for compliance requirements
7. **Setup proper notifications** to keep stakeholders informed
8. **Consider rollback scenarios** for rejected documents

## Integration Points
- **Workflow Specialist**: Primary agent using this task
- **DocType Designer**: DocType compatibility validation
- **Business Analyst**: Workflow requirements gathering
- **Testing Specialist**: Workflow testing and validation