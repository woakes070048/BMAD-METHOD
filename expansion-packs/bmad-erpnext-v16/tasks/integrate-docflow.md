# Integrate DocFlow

## Overview
This task guides you through integrating document flow management in your ERPNext application, enabling sophisticated document lifecycle management, approval workflows, and inter-document relationships.

## Prerequisites

### Required Knowledge
- [ ] Understanding of ERPNext document lifecycle
- [ ] Knowledge of workflow systems and approval processes
- [ ] Familiarity with Frappe's document event system
- [ ] Understanding of role-based permissions
- [ ] Basic knowledge of state machines and business process modeling

### System Requirements
- [ ] ERPNext development environment is set up
- [ ] Custom app is created and installed
- [ ] Basic DocTypes are already created
- [ ] User roles and permissions are configured

## Step-by-Step Process

### Step 1: Design Document Flow Architecture

#### Analyze Document Relationships
```python
# Document flow analysis and planning
# File: your_app/docflow_analysis.py

import frappe

def analyze_document_flow():
    """Analyze and document the flow between different document types"""
    
    document_flow_map = {
        "Lead": {
            "next_documents": ["Opportunity", "Customer"],
            "triggers": ["qualification", "conversion"],
            "approval_required": False
        },
        "Opportunity": {
            "next_documents": ["Quotation", "Sales Order"],
            "previous_documents": ["Lead"],
            "triggers": ["won", "quotation_request"],
            "approval_required": True,
            "approval_threshold": {"amount": 10000}
        },
        "Quotation": {
            "next_documents": ["Sales Order"],
            "previous_documents": ["Opportunity"],
            "triggers": ["customer_acceptance"],
            "approval_required": True,
            "approval_roles": ["Sales Manager"]
        },
        "Sales Order": {
            "next_documents": ["Delivery Note", "Sales Invoice"],
            "previous_documents": ["Quotation", "Opportunity"],
            "triggers": ["confirmation", "delivery_request"],
            "approval_required": True,
            "parallel_flows": ["inventory_reservation", "production_planning"]
        },
        "Purchase Order": {
            "next_documents": ["Purchase Receipt", "Purchase Invoice"],
            "triggers": ["supplier_confirmation"],
            "approval_required": True,
            "approval_levels": [
                {"role": "Purchase User", "limit": 5000},
                {"role": "Purchase Manager", "limit": 50000},
                {"role": "CFO", "limit": None}
            ]
        }
    }
    
    return document_flow_map

def create_flow_configuration():
    """Create DocFlow configuration document"""
    
    flow_map = analyze_document_flow()
    
    # Create or update DocFlow Settings
    if not frappe.db.exists("DocFlow Settings", "DocFlow Settings"):
        flow_settings = frappe.get_doc({
            "doctype": "DocFlow Settings",
            "name": "DocFlow Settings",
            "enable_docflow": 1,
            "auto_create_linked_docs": 0,
            "require_approval_comments": 1,
            "send_flow_notifications": 1
        })
        
        # Add flow rules
        for doctype, flow_config in flow_map.items():
            flow_settings.append("flow_rules", {
                "source_doctype": doctype,
                "next_doctypes": ",".join(flow_config.get("next_documents", [])),
                "triggers": ",".join(flow_config.get("triggers", [])),
                "approval_required": flow_config.get("approval_required", False),
                "approval_roles": ",".join(flow_config.get("approval_roles", []))
            })
        
        flow_settings.insert()
        print("DocFlow configuration created")

# Execute the analysis
if __name__ == "__main__":
    create_flow_configuration()
```

### Step 2: Create DocFlow Management System

#### Create DocFlow DocType
```json
// DocType definition for Document Flow
{
    "doctype": "DocType",
    "name": "Document Flow",
    "module": "Your App",
    "is_submittable": 1,
    "track_changes": 1,
    "fields": [
        {
            "fieldname": "flow_name",
            "fieldtype": "Data",
            "label": "Flow Name",
            "required": 1,
            "unique": 1
        },
        {
            "fieldname": "source_doctype",
            "fieldtype": "Link",
            "options": "DocType",
            "label": "Source Document Type",
            "required": 1
        },
        {
            "fieldname": "source_document",
            "fieldtype": "Dynamic Link",
            "options": "source_doctype",
            "label": "Source Document"
        },
        {
            "fieldname": "current_stage",
            "fieldtype": "Select",
            "options": "Draft\nIn Progress\nPending Approval\nApproved\nCompleted\nRejected\nCancelled",
            "default": "Draft",
            "label": "Current Stage"
        },
        {
            "fieldname": "flow_status",
            "fieldtype": "Select",
            "options": "Active\nPaused\nCompleted\nAborted",
            "default": "Active",
            "label": "Flow Status"
        },
        {
            "fieldname": "priority",
            "fieldtype": "Select",
            "options": "Low\nMedium\nHigh\nUrgent",
            "default": "Medium",
            "label": "Priority"
        },
        {
            "fieldname": "assigned_to",
            "fieldtype": "Link",
            "options": "User",
            "label": "Assigned To"
        },
        {
            "fieldname": "due_date",
            "fieldtype": "Datetime",
            "label": "Due Date"
        },
        {
            "fieldname": "flow_data",
            "fieldtype": "JSON",
            "label": "Flow Data"
        },
        {
            "fieldname": "flow_stages",
            "fieldtype": "Table",
            "label": "Flow Stages",
            "options": "Document Flow Stage"
        },
        {
            "fieldname": "linked_documents",
            "fieldtype": "Table",
            "label": "Linked Documents",
            "options": "Document Flow Link"
        }
    ]
}
```

#### Create Child Tables
```json
// Document Flow Stage
{
    "doctype": "DocType",
    "name": "Document Flow Stage",
    "istable": 1,
    "fields": [
        {
            "fieldname": "stage_name",
            "fieldtype": "Data",
            "label": "Stage Name",
            "required": 1
        },
        {
            "fieldname": "stage_type",
            "fieldtype": "Select",
            "options": "Manual\nAutomatic\nApproval\nNotification",
            "default": "Manual",
            "label": "Stage Type"
        },
        {
            "fieldname": "sequence",
            "fieldtype": "Int",
            "label": "Sequence",
            "required": 1
        },
        {
            "fieldname": "status",
            "fieldtype": "Select",
            "options": "Pending\nIn Progress\nCompleted\nSkipped\nFailed",
            "default": "Pending",
            "label": "Status"
        },
        {
            "fieldname": "assigned_role",
            "fieldtype": "Link",
            "options": "Role",
            "label": "Assigned Role"
        },
        {
            "fieldname": "assigned_user",
            "fieldtype": "Link", 
            "options": "User",
            "label": "Assigned User"
        },
        {
            "fieldname": "due_date",
            "fieldtype": "Datetime",
            "label": "Due Date"
        },
        {
            "fieldname": "completed_on",
            "fieldtype": "Datetime",
            "label": "Completed On",
            "read_only": 1
        },
        {
            "fieldname": "comments",
            "fieldtype": "Text",
            "label": "Comments"
        },
        {
            "fieldname": "stage_conditions",
            "fieldtype": "JSON",
            "label": "Stage Conditions"
        }
    ]
}
```

### Step 3: Implement DocFlow Controller Logic

#### Create DocFlow Controller
```python
# your_app/your_app/doctype/document_flow/document_flow.py

import frappe
from frappe.model.document import Document
from frappe.utils import now_datetime, add_days, get_datetime
import json

class DocumentFlow(Document):
    def validate(self):
        """Validate document flow before saving"""
        self.validate_flow_stages()
        self.validate_linked_documents()
        self.set_current_stage()
    
    def on_submit(self):
        """Actions when document flow is submitted"""
        self.start_flow()
        self.send_flow_notification("started")
    
    def on_cancel(self):
        """Actions when document flow is cancelled"""
        self.abort_flow()
        self.send_flow_notification("cancelled")
    
    def validate_flow_stages(self):
        """Validate flow stages configuration"""
        if not self.flow_stages:
            frappe.throw("At least one flow stage is required")
        
        # Check sequence numbers
        sequences = [stage.sequence for stage in self.flow_stages]
        if len(sequences) != len(set(sequences)):
            frappe.throw("Duplicate sequence numbers in flow stages")
        
        # Sort stages by sequence
        self.flow_stages = sorted(self.flow_stages, key=lambda x: x.sequence)
    
    def validate_linked_documents(self):
        """Validate linked documents"""
        for link in self.linked_documents:
            if not frappe.db.exists(link.linked_doctype, link.linked_document):
                frappe.throw(f"Linked document {link.linked_doctype} {link.linked_document} does not exist")
    
    def set_current_stage(self):
        """Set current stage based on flow progress"""
        if not self.current_stage:
            # Set to first stage
            first_stage = min(self.flow_stages, key=lambda x: x.sequence)
            self.current_stage = first_stage.stage_name
    
    def start_flow(self):
        """Start the document flow process"""
        # Set flow status to active
        self.db_set("flow_status", "Active")
        
        # Initialize first stage
        first_stage = self.get_current_stage_doc()
        if first_stage:
            first_stage.status = "In Progress"
            first_stage.assigned_user = self.assigned_to
            
            # Set due date if not already set
            if not first_stage.due_date and self.due_date:
                first_stage.due_date = self.due_date
        
        self.save()
        
        # Auto-execute if it's an automatic stage
        if first_stage and first_stage.stage_type == "Automatic":
            self.execute_automatic_stage(first_stage)
    
    def get_current_stage_doc(self):
        """Get the current stage document"""
        for stage in self.flow_stages:
            if stage.stage_name == self.current_stage:
                return stage
        return None
    
    def advance_stage(self, comments=None):
        """Advance to the next stage in the flow"""
        current_stage = self.get_current_stage_doc()
        if not current_stage:
            frappe.throw("Current stage not found")
        
        # Mark current stage as completed
        current_stage.status = "Completed"
        current_stage.completed_on = now_datetime()
        if comments:
            current_stage.comments = comments
        
        # Find next stage
        next_stage = self.get_next_stage(current_stage.sequence)
        
        if next_stage:
            # Move to next stage
            self.current_stage = next_stage.stage_name
            next_stage.status = "In Progress"
            
            # Auto-assign if role is specified
            if next_stage.assigned_role and not next_stage.assigned_user:
                next_stage.assigned_user = self.get_user_with_role(next_stage.assigned_role)
            
            # Set due date
            if not next_stage.due_date:
                next_stage.due_date = add_days(now_datetime(), 2)  # Default 2 days
            
            self.save()
            
            # Send notification
            self.send_stage_notification(next_stage)
            
            # Auto-execute if automatic
            if next_stage.stage_type == "Automatic":
                self.execute_automatic_stage(next_stage)
                
        else:
            # Flow completed
            self.flow_status = "Completed"
            self.current_stage = "Completed"
            self.save()
            self.send_flow_notification("completed")
    
    def get_next_stage(self, current_sequence):
        """Get the next stage in sequence"""
        next_stages = [s for s in self.flow_stages if s.sequence > current_sequence]
        if next_stages:
            return min(next_stages, key=lambda x: x.sequence)
        return None
    
    def get_user_with_role(self, role):
        """Get a user with the specified role using intelligent assignment logic"""
        users = frappe.get_all("Has Role", 
            filters={"role": role, "parenttype": "User"},
            fields=["parent"]
        )
        
        if not users:
            return None
        
        if len(users) == 1:
            return users[0].parent
        
        # Implement smart assignment logic
        return self._assign_user_intelligently(users, role)
    
    def _assign_user_intelligently(self, users, role):
        """Intelligent user assignment using multiple strategies"""
        user_list = [user.parent for user in users]
        
        # Strategy 1: Check current workload (active flows assigned)
        workload_scores = {}
        for user in user_list:
            active_flows = frappe.db.count("Document Flow", {
                "flow_status": "Active",
                "assigned_to": user
            })
            
            # Also count active stage assignments
            active_stages = frappe.db.sql("""
                SELECT COUNT(*) 
                FROM `tabDocument Flow Stage` dfs
                INNER JOIN `tabDocument Flow` df ON dfs.parent = df.name
                WHERE dfs.assigned_user = %s 
                AND dfs.status = 'In Progress'
                AND df.flow_status = 'Active'
            """, [user])[0][0]
            
            workload_scores[user] = active_flows + (active_stages * 0.5)
        
        # Strategy 2: Check user availability (last login, enabled status)
        available_users = []
        for user in user_list:
            user_doc = frappe.get_cached_doc("User", user)
            if (not user_doc.enabled or 
                user_doc.user_type != "System User"):
                continue
            
            # Check if user has been active recently (last 7 days)
            last_login = frappe.db.get_value("User", user, "last_login")
            if last_login:
                from frappe.utils import getdate, add_days
                if getdate(last_login) < add_days(getdate(), -7):
                    workload_scores[user] += 10  # Penalty for inactive users
            
            available_users.append(user)
        
        if not available_users:
            # Fall back to first available user if none are recently active
            return user_list[0]
        
        # Strategy 3: Round-robin with workload balancing
        # Get the user with the lowest workload score
        best_user = min(available_users, key=lambda u: workload_scores.get(u, 0))
        
        # Strategy 4: Consider role-specific preferences (if configured)
        role_preferences = self._get_role_assignment_preferences(role)
        if role_preferences:
            preferred_users = [u for u in available_users if u in role_preferences]
            if preferred_users:
                # Among preferred users, pick the one with lowest workload
                best_user = min(preferred_users, key=lambda u: workload_scores.get(u, 0))
        
        frappe.log_error(
            f"DocFlow assignment: Role {role} assigned to {best_user} "
            f"(workload: {workload_scores.get(best_user, 0)})",
            "DocFlow User Assignment"
        )
        
        return best_user
    
    def _get_role_assignment_preferences(self, role):
        """Get preferred users for a role from DocFlow Settings"""
        try:
            flow_settings = frappe.get_single("DocFlow Settings")
            if hasattr(flow_settings, 'role_assignments'):
                for assignment in flow_settings.role_assignments:
                    if assignment.role == role and assignment.preferred_users:
                        return [u.strip() for u in assignment.preferred_users.split(',')]
        except Exception:
            pass
        return []
    
    def execute_automatic_stage(self, stage):
        """Execute automatic stage logic"""
        try:
            stage_conditions = json.loads(stage.stage_conditions or "{}")
            
            # Execute based on stage type and conditions
            if stage_conditions.get("action") == "create_document":
                self.create_linked_document(stage_conditions)
            elif stage_conditions.get("action") == "send_email":
                self.send_email_notification(stage_conditions)
            elif stage_conditions.get("action") == "update_source":
                self.update_source_document(stage_conditions)
            
            # Auto-advance to next stage
            self.advance_stage("Automatic stage completed")
            
        except Exception as e:
            stage.status = "Failed"
            stage.comments = f"Automatic execution failed: {str(e)}"
            self.save()
            frappe.log_error(f"DocFlow automatic stage failed: {str(e)}", "DocFlow Error")
    
    def create_linked_document(self, conditions):
        """Create a linked document as part of the flow"""
        doctype = conditions.get("doctype")
        template_data = conditions.get("template", {})
        
        if not doctype:
            return
        
        # Get source document data
        source_doc = frappe.get_doc(self.source_doctype, self.source_document)
        
        # Merge template with source data
        new_doc_data = {"doctype": doctype}
        new_doc_data.update(template_data)
        
        # Map fields from source document
        field_mapping = conditions.get("field_mapping", {})
        for source_field, target_field in field_mapping.items():
            if hasattr(source_doc, source_field):
                new_doc_data[target_field] = getattr(source_doc, source_field)
        
        # Create and save the document
        new_doc = frappe.get_doc(new_doc_data)
        new_doc.insert()
        
        # Add to linked documents
        self.append("linked_documents", {
            "linked_doctype": doctype,
            "linked_document": new_doc.name,
            "relationship": "Created by Flow"
        })
    
    def send_stage_notification(self, stage):
        """Send notification for stage assignment"""
        if not stage.assigned_user:
            return
        
        user_email = frappe.db.get_value("User", stage.assigned_user, "email")
        if not user_email:
            return
        
        # Send email notification
        frappe.sendmail(
            recipients=[user_email],
            subject=f"Document Flow Assignment: {self.flow_name}",
            template="docflow_stage_assignment",
            args={
                "flow": self,
                "stage": stage,
                "source_doc": frappe.get_doc(self.source_doctype, self.source_document)
            },
            reference_doctype=self.doctype,
            reference_name=self.name
        )
    
    def send_flow_notification(self, event):
        """Send flow-level notifications"""
        if not self.assigned_to:
            return
        
        user_email = frappe.db.get_value("User", self.assigned_to, "email")
        if not user_email:
            return
        
        event_subjects = {
            "started": f"Document Flow Started: {self.flow_name}",
            "completed": f"Document Flow Completed: {self.flow_name}",
            "cancelled": f"Document Flow Cancelled: {self.flow_name}"
        }
        
        frappe.sendmail(
            recipients=[user_email],
            subject=event_subjects.get(event, f"Document Flow Update: {self.flow_name}"),
            template="docflow_notification",
            args={
                "flow": self,
                "event": event,
                "source_doc": frappe.get_doc(self.source_doctype, self.source_document)
            },
            reference_doctype=self.doctype,
            reference_name=self.name
        )
```

### Step 4: Create Flow Templates and Builders

#### DocFlow Template System
```python
# your_app/docflow/templates.py

import frappe
import json

class DocFlowTemplate:
    """Template system for creating common document flows"""
    
    def __init__(self):
        self.templates = {
            "sales_process": self.get_sales_process_template(),
            "purchase_process": self.get_purchase_process_template(),
            "approval_process": self.get_approval_process_template(),
            "quality_assurance": self.get_qa_process_template()
        }
    
    def get_sales_process_template(self):
        """Sales process flow template"""
        return {
            "flow_name": "Sales Process Flow",
            "description": "Standard sales process from lead to invoice",
            "stages": [
                {
                    "stage_name": "Lead Qualification",
                    "stage_type": "Manual",
                    "sequence": 1,
                    "assigned_role": "Sales User",
                    "stage_conditions": {
                        "required_fields": ["email_id", "mobile_no"],
                        "validation_rules": ["valid_email", "valid_phone"]
                    }
                },
                {
                    "stage_name": "Opportunity Creation",
                    "stage_type": "Automatic",
                    "sequence": 2,
                    "stage_conditions": {
                        "action": "create_document",
                        "doctype": "Opportunity",
                        "field_mapping": {
                            "lead_name": "party_name",
                            "email_id": "contact_email",
                            "mobile_no": "contact_mobile"
                        }
                    }
                },
                {
                    "stage_name": "Quotation Preparation",
                    "stage_type": "Manual", 
                    "sequence": 3,
                    "assigned_role": "Sales User"
                },
                {
                    "stage_name": "Quotation Approval",
                    "stage_type": "Approval",
                    "sequence": 4,
                    "assigned_role": "Sales Manager",
                    "stage_conditions": {
                        "approval_threshold": 10000,
                        "escalation_days": 2
                    }
                },
                {
                    "stage_name": "Order Processing",
                    "stage_type": "Automatic",
                    "sequence": 5,
                    "stage_conditions": {
                        "action": "create_document",
                        "doctype": "Sales Order",
                        "field_mapping": {
                            "customer": "customer",
                            "items": "items"
                        }
                    }
                }
            ]
        }
    
    def get_purchase_process_template(self):
        """Purchase process flow template"""
        return {
            "flow_name": "Purchase Process Flow",
            "description": "Standard purchase process from request to receipt",
            "stages": [
                {
                    "stage_name": "Purchase Request",
                    "stage_type": "Manual",
                    "sequence": 1,
                    "assigned_role": "Purchase User"
                },
                {
                    "stage_name": "Vendor Selection",
                    "stage_type": "Manual",
                    "sequence": 2,
                    "assigned_role": "Purchase User",
                    "stage_conditions": {
                        "minimum_quotes": 3,
                        "comparison_required": True
                    }
                },
                {
                    "stage_name": "Purchase Approval",
                    "stage_type": "Approval",
                    "sequence": 3,
                    "stage_conditions": {
                        "approval_levels": [
                            {"role": "Purchase Manager", "limit": 50000},
                            {"role": "CFO", "limit": 200000},
                            {"role": "CEO", "limit": None}
                        ]
                    }
                },
                {
                    "stage_name": "Order Placement",
                    "stage_type": "Automatic",
                    "sequence": 4,
                    "stage_conditions": {
                        "action": "create_document",
                        "doctype": "Purchase Order"
                    }
                }
            ]
        }
    
    def get_approval_process_template(self):
        """Generic approval process template"""
        return {
            "flow_name": "Approval Process",
            "description": "Generic multi-level approval process",
            "stages": [
                {
                    "stage_name": "Initial Review",
                    "stage_type": "Manual",
                    "sequence": 1,
                    "assigned_role": "System Manager"
                },
                {
                    "stage_name": "Level 1 Approval",
                    "stage_type": "Approval",
                    "sequence": 2,
                    "assigned_role": "Approver Level 1"
                },
                {
                    "stage_name": "Level 2 Approval", 
                    "stage_type": "Approval",
                    "sequence": 3,
                    "assigned_role": "Approver Level 2"
                },
                {
                    "stage_name": "Final Approval",
                    "stage_type": "Approval",
                    "sequence": 4,
                    "assigned_role": "Final Approver"
                }
            ]
        }
    
    def get_qa_process_template(self):
        """Quality assurance process template"""
        return {
            "flow_name": "Quality Assurance Process",
            "description": "Quality assurance and testing process",
            "stages": [
                {
                    "stage_name": "QA Assignment",
                    "stage_type": "Manual",
                    "sequence": 1,
                    "assigned_role": "QA Manager"
                },
                {
                    "stage_name": "Initial Testing",
                    "stage_type": "Manual",
                    "sequence": 2,
                    "assigned_role": "QA Tester",
                    "stage_conditions": {
                        "test_cases_required": True,
                        "documentation_required": True
                    }
                },
                {
                    "stage_name": "Defect Review",
                    "stage_type": "Manual",
                    "sequence": 3,
                    "assigned_role": "QA Manager",
                    "stage_conditions": {
                        "defect_threshold": 0,
                        "severity_check": True
                    }
                },
                {
                    "stage_name": "Final Approval",
                    "stage_type": "Approval",
                    "sequence": 4,
                    "assigned_role": "QA Manager"
                }
            ]
        }
    
    def create_flow_from_template(self, template_name, source_doctype, source_document, **kwargs):
        """Create a document flow from template"""
        
        if template_name not in self.templates:
            frappe.throw(f"Template '{template_name}' not found")
        
        template = self.templates[template_name].copy()
        
        # Override template values with kwargs
        template.update(kwargs)
        
        # Create Document Flow
        flow_doc = frappe.get_doc({
            "doctype": "Document Flow",
            "flow_name": template["flow_name"],
            "source_doctype": source_doctype,
            "source_document": source_document,
            "priority": kwargs.get("priority", "Medium"),
            "assigned_to": kwargs.get("assigned_to")
        })
        
        # Add stages
        for stage_data in template["stages"]:
            flow_doc.append("flow_stages", {
                "stage_name": stage_data["stage_name"],
                "stage_type": stage_data["stage_type"],
                "sequence": stage_data["sequence"],
                "assigned_role": stage_data.get("assigned_role"),
                "assigned_user": stage_data.get("assigned_user"),
                "stage_conditions": json.dumps(stage_data.get("stage_conditions", {}))
            })
        
        flow_doc.insert()
        return flow_doc

# Usage functions
def create_sales_flow(source_doctype, source_document, **kwargs):
    """Create sales process flow"""
    template = DocFlowTemplate()
    return template.create_flow_from_template("sales_process", source_doctype, source_document, **kwargs)

def create_purchase_flow(source_doctype, source_document, **kwargs):
    """Create purchase process flow"""
    template = DocFlowTemplate()
    return template.create_flow_from_template("purchase_process", source_doctype, source_document, **kwargs)
```

### Step 5: Integrate with Existing DocTypes

#### Document Event Hooks
```python
# your_app/docflow/hooks.py

import frappe
from your_app.docflow.templates import create_sales_flow, create_purchase_flow

def on_lead_conversion(doc, method):
    """Create sales flow when lead is converted"""
    if method == "on_update" and doc.status == "Converted":
        create_sales_flow("Lead", doc.name, assigned_to=doc.owner)

def on_purchase_request_submit(doc, method):
    """Create purchase flow when purchase request is submitted"""
    if doc.doctype == "Material Request" and doc.material_request_type == "Purchase":
        create_purchase_flow("Material Request", doc.name, assigned_to=doc.owner)

def on_quotation_submit(doc, method):
    """Handle quotation submission in sales flow"""
    # Find related document flow
    flows = frappe.get_all("Document Flow",
        filters={
            "source_doctype": "Lead",
            "flow_status": "Active"
        }
    )
    
    for flow_name in [f.name for f in flows]:
        flow_doc = frappe.get_doc("Document Flow", flow_name)
        
        # Check if this quotation is linked to the flow
        if any(link.linked_document == doc.name for link in flow_doc.linked_documents):
            # Advance the flow
            flow_doc.advance_stage(f"Quotation {doc.name} submitted")
            break

def on_document_approval(doc, method):
    """Handle document approval in flows"""
    # Find related flows
    flows = frappe.get_all("Document Flow",
        filters={
            "flow_status": "Active",
            "current_stage": ["like", "%Approval%"]
        }
    )
    
    for flow_name in [f.name for f in flows]:
        flow_doc = frappe.get_doc("Document Flow", flow_name)
        
        # Check if this document is part of the flow
        if (flow_doc.source_doctype == doc.doctype and 
            flow_doc.source_document == doc.name):
            
            if doc.docstatus == 1:  # Submitted/Approved
                flow_doc.advance_stage(f"Document {doc.name} approved")
            elif doc.workflow_state in ["Rejected", "Cancelled"]:
                # Handle rejection
                current_stage = flow_doc.get_current_stage_doc()
                if current_stage:
                    current_stage.status = "Failed"
                    current_stage.comments = f"Document {doc.name} was rejected"
                    flow_doc.save()
```

### Step 6: Create DocFlow Dashboard and Interface

#### DocFlow Dashboard
```python
# your_app/docflow/dashboard.py

import frappe
from frappe.utils import get_datetime, now_datetime
import json

def get_docflow_dashboard_data():
    """Get dashboard data for document flows"""
    
    # Active flows
    active_flows = frappe.db.count("Document Flow", {"flow_status": "Active"})
    
    # Completed flows
    completed_flows = frappe.db.count("Document Flow", {"flow_status": "Completed"})
    
    # Overdue flows
    overdue_flows = frappe.db.sql("""
        SELECT COUNT(*) 
        FROM `tabDocument Flow` df
        INNER JOIN `tabDocument Flow Stage` dfs ON df.name = dfs.parent
        WHERE df.flow_status = 'Active'
        AND dfs.status = 'In Progress'
        AND dfs.due_date < %s
    """, [now_datetime()])[0][0]
    
    # My pending tasks
    my_pending = frappe.db.sql("""
        SELECT COUNT(*)
        FROM `tabDocument Flow` df
        INNER JOIN `tabDocument Flow Stage` dfs ON df.name = dfs.parent
        WHERE df.flow_status = 'Active'
        AND dfs.status = 'In Progress'
        AND (dfs.assigned_user = %s OR df.assigned_to = %s)
    """, [frappe.session.user, frappe.session.user])[0][0]
    
    # Flow performance metrics
    avg_completion_time = frappe.db.sql("""
        SELECT AVG(TIMESTAMPDIFF(HOUR, creation, modified))
        FROM `tabDocument Flow`
        WHERE flow_status = 'Completed'
        AND creation >= DATE_SUB(NOW(), INTERVAL 30 DAY)
    """)[0][0] or 0
    
    return {
        "active_flows": active_flows,
        "completed_flows": completed_flows,
        "overdue_flows": overdue_flows,
        "my_pending": my_pending,
        "avg_completion_hours": round(avg_completion_time, 1),
        "flow_types": get_flow_type_distribution(),
        "recent_completions": get_recent_completions()
    }

def get_flow_type_distribution():
    """Get distribution of flow types"""
    return frappe.db.sql("""
        SELECT flow_name, COUNT(*) as count
        FROM `tabDocument Flow`
        WHERE creation >= DATE_SUB(NOW(), INTERVAL 30 DAY)
        GROUP BY flow_name
        ORDER BY count DESC
        LIMIT 5
    """, as_dict=True)

def get_recent_completions():
    """Get recently completed flows"""
    return frappe.db.sql("""
        SELECT name, flow_name, source_doctype, source_document, modified
        FROM `tabDocument Flow`
        WHERE flow_status = 'Completed'
        ORDER BY modified DESC
        LIMIT 10
    """, as_dict=True)

@frappe.whitelist()
def get_my_pending_flows():
    """Get flows pending for current user"""
    return frappe.db.sql("""
        SELECT DISTINCT df.name, df.flow_name, df.source_doctype, 
               df.source_document, df.current_stage, df.priority,
               dfs.due_date, dfs.comments
        FROM `tabDocument Flow` df
        INNER JOIN `tabDocument Flow Stage` dfs ON df.name = dfs.parent
        WHERE df.flow_status = 'Active'
        AND dfs.status = 'In Progress'
        AND (dfs.assigned_user = %s OR df.assigned_to = %s)
        ORDER BY dfs.due_date ASC
    """, [frappe.session.user, frappe.session.user], as_dict=True)

@frappe.whitelist()
def advance_flow_stage(flow_name, comments=None):
    """Advance a flow stage (API method)"""
    flow_doc = frappe.get_doc("Document Flow", flow_name)
    
    # Check permissions
    current_stage = flow_doc.get_current_stage_doc()
    if current_stage:
        if (current_stage.assigned_user != frappe.session.user and
            flow_doc.assigned_to != frappe.session.user):
            frappe.throw("You are not assigned to this flow stage")
    
    flow_doc.advance_stage(comments)
    return {"success": True, "message": "Flow stage advanced successfully"}
```

#### DocFlow Web Interface
```vue
<!-- DocFlow Dashboard Component -->
<template>
  <div class="docflow-dashboard">
    <!-- Dashboard Header -->
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Document Flow Dashboard</h1>
      <p class="text-gray-600 mt-1">Monitor and manage document workflows</p>
    </div>

    <!-- Metrics Cards -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
      <MetricCard
        title="Active Flows"
        :value="dashboardData.active_flows"
        color="blue"
        icon="PlayCircle"
      />
      <MetricCard
        title="My Pending"
        :value="dashboardData.my_pending"
        color="orange"
        icon="Clock"
      />
      <MetricCard
        title="Overdue"
        :value="dashboardData.overdue_flows"
        color="red"
        icon="AlertTriangle"
      />
      <MetricCard
        title="Completed"
        :value="dashboardData.completed_flows"
        color="green"
        icon="CheckCircle"
      />
    </div>

    <!-- My Pending Tasks -->
    <div class="bg-white rounded-lg border p-6 mb-8">
      <h2 class="text-lg font-semibold mb-4">My Pending Tasks</h2>
      
      <div v-if="pendingFlows.length === 0" class="text-gray-500 py-8 text-center">
        No pending tasks
      </div>
      
      <div v-else class="space-y-4">
        <div 
          v-for="flow in pendingFlows"
          :key="flow.name"
          class="flex items-center justify-between p-4 border rounded-lg hover:bg-gray-50"
        >
          <div class="flex-1">
            <h3 class="font-medium">{{ flow.flow_name }}</h3>
            <p class="text-sm text-gray-600">
              {{ flow.source_doctype }} - {{ flow.source_document }}
            </p>
            <p class="text-sm text-gray-500">
              Current Stage: {{ flow.current_stage }}
            </p>
          </div>
          
          <div class="flex items-center space-x-3">
            <Badge
              :color="getPriorityColor(flow.priority)"
              :label="flow.priority"
            />
            
            <div class="text-sm text-gray-500">
              Due: {{ formatDate(flow.due_date) }}
            </div>
            
            <Button
              size="sm"
              @click="openAdvanceDialog(flow)"
            >
              Advance
            </Button>
          </div>
        </div>
      </div>
    </div>

    <!-- Flow Statistics -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
      <!-- Flow Types Chart -->
      <div class="bg-white rounded-lg border p-6">
        <h2 class="text-lg font-semibold mb-4">Flow Types (Last 30 Days)</h2>
        <FlowTypeChart :data="dashboardData.flow_types" />
      </div>
      
      <!-- Recent Completions -->
      <div class="bg-white rounded-lg border p-6">
        <h2 class="text-lg font-semibold mb-4">Recent Completions</h2>
        <div class="space-y-3">
          <div 
            v-for="completion in dashboardData.recent_completions"
            :key="completion.name"
            class="flex items-center justify-between py-2 border-b border-gray-100 last:border-b-0"
          >
            <div>
              <p class="font-medium text-sm">{{ completion.flow_name }}</p>
              <p class="text-xs text-gray-600">
                {{ completion.source_doctype }} - {{ completion.source_document }}
              </p>
            </div>
            <div class="text-xs text-gray-500">
              {{ formatDate(completion.modified) }}
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Advance Flow Dialog -->
    <Dialog v-model="showAdvanceDialog" :options="{ title: 'Advance Flow Stage', size: 'md' }">
      <template #body>
        <div class="space-y-4">
          <div v-if="selectedFlow">
            <p class="text-sm text-gray-600 mb-2">
              Flow: <strong>{{ selectedFlow.flow_name }}</strong>
            </p>
            <p class="text-sm text-gray-600 mb-4">
              Current Stage: <strong>{{ selectedFlow.current_stage }}</strong>
            </p>
          </div>
          
          <FormControl
            v-model="advanceComments"
            label="Comments (Optional)"
            type="textarea"
            placeholder="Add any comments about this stage completion..."
          />
        </div>
      </template>
      <template #actions>
        <div class="flex justify-end space-x-2">
          <Button
            variant="outline"
            @click="showAdvanceDialog = false"
          >
            Cancel
          </Button>
          <Button
            variant="solid"
            :loading="advancing"
            @click="advanceFlowStage"
          >
            Advance Stage
          </Button>
        </div>
      </template>
    </Dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
// REMOVED: frappe-ui import - use native components
// REMOVED: frappe-ui import - use native components
import { PlayCircle, Clock, AlertTriangle, CheckCircle } from 'lucide-vue-next'
import MetricCard from '@/components/MetricCard.vue'
import FlowTypeChart from '@/components/charts/FlowTypeChart.vue'
import { toast } from '@/utils'
import { formatDate } from '@/utils/date'

// Reactive state
const dashboardData = ref({})
const pendingFlows = ref([])
const showAdvanceDialog = ref(false)
const selectedFlow = ref(null)
const advanceComments = ref('')
const advancing = ref(false)

// Resources
const dashboardResource = // REMOVED: createResource - use frappe.call()({
  url: 'your_app.docflow.dashboard.get_docflow_dashboard_data',
  auto: true,
  onSuccess(data) {
    dashboardData.value = data
  }
})

const pendingFlowsResource = // REMOVED: createResource - use frappe.call()({
  url: 'your_app.docflow.dashboard.get_my_pending_flows',
  auto: true,
  onSuccess(data) {
    pendingFlows.value = data
  }
})

const advanceStageResource = // REMOVED: createResource - use frappe.call()({
  url: 'your_app.docflow.dashboard.advance_flow_stage',
  auto: false,
  onSuccess() {
    toast({
      title: 'Success',
      text: 'Flow stage advanced successfully',
      icon: 'check',
      iconClasses: 'text-green-600'
    })
    
    showAdvanceDialog.value = false
    advanceComments.value = ''
    selectedFlow.value = null
    
    // Refresh data
    dashboardResource.fetch()
    pendingFlowsResource.fetch()
  }
})

// Methods
const getPriorityColor = (priority) => {
  const colors = {
    'Low': 'gray',
    'Medium': 'blue',
    'High': 'orange',
    'Urgent': 'red'
  }
  return colors[priority] || 'gray'
}

const openAdvanceDialog = (flow) => {
  selectedFlow.value = flow
  showAdvanceDialog.value = true
  advanceComments.value = ''
}

const advanceFlowStage = async () => {
  if (!selectedFlow.value) return
  
  advancing.value = true
  
  try {
    await advanceStageResource.fetch({
      flow_name: selectedFlow.value.name,
      comments: advanceComments.value || null
    })
  } finally {
    advancing.value = false
  }
}

// Lifecycle
onMounted(() => {
  dashboardResource.fetch()
  pendingFlowsResource.fetch()
})
</script>
```

### Step 7: Integration Testing and Validation

#### DocFlow Testing Suite
```python
# your_app/tests/test_docflow.py

import frappe
from frappe.tests.utils import FrappeTestCase
from your_app.docflow.templates import DocFlowTemplate

class TestDocFlow(FrappeTestCase):
    
    def setUp(self):
        """Set up test data"""
        # Create test lead
        if not frappe.db.exists("Lead", "test-lead-docflow"):
            self.test_lead = frappe.get_doc({
                "doctype": "Lead",
                "lead_name": "Test Lead DocFlow",
                "email_id": "testlead@docflow.com",
                "status": "Open"
            })
            self.test_lead.insert()
        else:
            self.test_lead = frappe.get_doc("Lead", "test-lead-docflow")
    
    def test_sales_flow_creation(self):
        """Test creation of sales process flow"""
        template = DocFlowTemplate()
        
        flow_doc = template.create_flow_from_template(
            "sales_process",
            "Lead", 
            self.test_lead.name,
            assigned_to=frappe.session.user
        )
        
        self.assertIsNotNone(flow_doc)
        self.assertEqual(flow_doc.source_doctype, "Lead")
        self.assertEqual(flow_doc.source_document, self.test_lead.name)
        self.assertTrue(len(flow_doc.flow_stages) > 0)
        
        # Test flow submission
        flow_doc.submit()
        self.assertEqual(flow_doc.flow_status, "Active")
    
    def test_stage_advancement(self):
        """Test advancing flow stages"""
        template = DocFlowTemplate()
        
        flow_doc = template.create_flow_from_template(
            "approval_process",
            "Lead",
            self.test_lead.name
        )
        flow_doc.submit()
        
        initial_stage = flow_doc.current_stage
        
        # Advance stage
        flow_doc.advance_stage("Test stage advancement")
        
        self.assertNotEqual(flow_doc.current_stage, initial_stage)
        
        # Check stage status
        completed_stages = [s for s in flow_doc.flow_stages if s.status == "Completed"]
        self.assertTrue(len(completed_stages) > 0)
    
    def test_automatic_stage_execution(self):
        """Test automatic stage execution"""
        # Create flow with automatic stage
        flow_doc = frappe.get_doc({
            "doctype": "Document Flow",
            "flow_name": "Test Automatic Flow",
            "source_doctype": "Lead",
            "source_document": self.test_lead.name
        })
        
        # Add manual stage followed by automatic stage
        flow_doc.append("flow_stages", {
            "stage_name": "Manual Review",
            "stage_type": "Manual",
            "sequence": 1,
            "assigned_user": frappe.session.user
        })
        
        flow_doc.append("flow_stages", {
            "stage_name": "Auto Email",
            "stage_type": "Automatic", 
            "sequence": 2,
            "stage_conditions": '{"action": "send_email", "template": "welcome"}'
        })
        
        flow_doc.insert()
        flow_doc.submit()
        
        # Advance past manual stage
        flow_doc.advance_stage("Manual review completed")
        
        # Check that automatic stage executed and advanced
        self.assertNotEqual(flow_doc.current_stage, "Auto Email")
    
    def test_flow_completion(self):
        """Test flow completion"""
        template = DocFlowTemplate()
        
        flow_doc = template.create_flow_from_template(
            "approval_process",
            "Lead",
            self.test_lead.name
        )
        flow_doc.submit()
        
        # Advance through all stages
        while flow_doc.current_stage != "Completed":
            flow_doc.advance_stage("Test progression")
            flow_doc.reload()
        
        self.assertEqual(flow_doc.flow_status, "Completed")
        self.assertEqual(flow_doc.current_stage, "Completed")
    
    def tearDown(self):
        """Clean up test data"""
        # Delete test flows
        flows = frappe.get_all("Document Flow", 
            filters={"source_document": self.test_lead.name})
        for flow in flows:
            frappe.delete_doc("Document Flow", flow.name, force=True)
```

## Best Practices

### DocFlow Design
- Keep flows simple and intuitive
- Design for common business processes
- Allow for flexibility and customization
- Consider parallel processing where appropriate
- Plan for exception handling and recovery

### Performance Optimization
- Index flow-related fields properly
- Use background jobs for heavy processing
- Implement caching for frequently accessed data
- Monitor flow execution times
- Clean up completed flows periodically

### Security and Permissions
- Implement proper role-based access control
- Validate user permissions at each stage
- Audit flow actions and decisions
- Secure sensitive data in flow stages
- Implement approval limits and escalation

### Monitoring and Maintenance
- Track flow performance metrics
- Monitor for stuck or overdue flows
- Implement alerting for critical issues
- Regularly review and optimize flows
- Maintain documentation for complex flows

---

*Your document flow integration is now complete, providing sophisticated workflow management capabilities that enhance business process automation and control in your ERPNext application.*