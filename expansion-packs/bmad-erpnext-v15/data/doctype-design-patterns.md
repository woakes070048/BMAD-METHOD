# ERPNext DocType Design Patterns

## Overview
This document provides comprehensive guidance on ERPNext DocType design patterns, best practices, and architectural approaches for creating robust, scalable, and maintainable custom DocTypes within the Frappe Framework.

## Core DocType Design Principles

### 1. Single Responsibility Principle
Each DocType should have a single, well-defined responsibility within the business domain.

```python
# Good: Focused DocType
class CustomerComplaint(Document):
    """Handles customer complaint lifecycle"""
    pass

# Avoid: Multi-purpose DocType
class CustomerEverything(Document):
    """Handles complaints, feedback, orders, payments..."""
    pass
```

### 2. Domain-Driven Design
Align DocTypes with business entities and processes rather than technical convenience.

```json
{
    "doctype": "Sales Territory Management",
    "fields": [
        {
            "fieldname": "territory_name",
            "fieldtype": "Data",
            "label": "Territory Name",
            "reqd": 1
        },
        {
            "fieldname": "territory_manager",
            "fieldtype": "Link",
            "options": "Employee",
            "label": "Territory Manager"
        }
    ]
}
```

### 3. Extensibility and Customization
Design DocTypes to be easily extended without breaking existing functionality.

```python
class BaseDocument(Document):
    """Base class for common functionality"""
    
    def validate_common_fields(self):
        """Common validation logic"""
        pass
    
    def set_audit_fields(self):
        """Set created/modified by fields"""
        pass

class CustomInventoryItem(BaseDocument):
    """Extends base with inventory-specific functionality"""
    
    def validate(self):
        super().validate_common_fields()
        self.validate_inventory_specific()
```

## Common DocType Patterns

### 1. Master-Transaction Pattern

#### Master DocType Pattern
Used for reference data that is relatively stable.

```json
{
    "doctype": "Product Category",
    "naming_rule": "By \"Naming Series\" field",
    "fields": [
        {
            "fieldname": "naming_series",
            "fieldtype": "Select",
            "options": "CAT-.YYYY.-",
            "default": "CAT-.YYYY.-",
            "label": "Naming Series"
        },
        {
            "fieldname": "category_name",
            "fieldtype": "Data",
            "label": "Category Name",
            "reqd": 1,
            "unique": 1
        },
        {
            "fieldname": "parent_category",
            "fieldtype": "Link",
            "options": "Product Category",
            "label": "Parent Category"
        },
        {
            "fieldname": "is_active",
            "fieldtype": "Check",
            "label": "Is Active",
            "default": 1
        }
    ]
}
```

#### Transaction DocType Pattern
Used for business transactions with workflow states.

```json
{
    "doctype": "Service Request",
    "naming_rule": "By \"Naming Series\" field",
    "is_submittable": 1,
    "fields": [
        {
            "fieldname": "naming_series",
            "fieldtype": "Select",
            "options": "SR-.YYYY.-.MM.-.#####",
            "label": "Naming Series"
        },
        {
            "fieldname": "customer",
            "fieldtype": "Link",
            "options": "Customer",
            "label": "Customer",
            "reqd": 1
        },
        {
            "fieldname": "request_date",
            "fieldtype": "Date",
            "label": "Request Date",
            "default": "Today",
            "reqd": 1
        },
        {
            "fieldname": "status",
            "fieldtype": "Select",
            "options": "Open\\nIn Progress\\nResolved\\nClosed",
            "default": "Open",
            "label": "Status"
        }
    ]
}
```

### 2. Hierarchical Pattern
For DocTypes that need parent-child relationships.

```python
class OrganizationUnit(Document):
    def validate(self):
        self.validate_hierarchy()
        self.set_hierarchy_level()
    
    def validate_hierarchy(self):
        """Prevent circular references"""
        if self.parent_unit:
            ancestors = self.get_ancestors()
            if self.name in ancestors:
                frappe.throw("Cannot set circular hierarchy")
    
    def get_ancestors(self):
        """Get all parent units"""
        ancestors = []
        parent = self.parent_unit
        while parent:
            ancestors.append(parent)
            parent_doc = frappe.get_doc("Organization Unit", parent)
            parent = parent_doc.parent_unit
        return ancestors
```

### 3. Composite Pattern
For DocTypes with child tables representing composition.

```json
{
    "doctype": "Project Template",
    "fields": [
        {
            "fieldname": "template_name",
            "fieldtype": "Data",
            "label": "Template Name",
            "reqd": 1
        },
        {
            "fieldname": "tasks",
            "fieldtype": "Table",
            "options": "Project Template Task",
            "label": "Tasks"
        },
        {
            "fieldname": "resources",
            "fieldtype": "Table",
            "options": "Project Template Resource",
            "label": "Resources"
        }
    ]
}
```

Child Table DocType:
```json
{
    "doctype": "Project Template Task",
    "istable": 1,
    "fields": [
        {
            "fieldname": "task_name",
            "fieldtype": "Data",
            "label": "Task Name",
            "reqd": 1,
            "in_list_view": 1
        },
        {
            "fieldname": "duration_days",
            "fieldtype": "Int",
            "label": "Duration (Days)",
            "in_list_view": 1
        },
        {
            "fieldname": "depends_on",
            "fieldtype": "Data",
            "label": "Depends On Task"
        }
    ]
}
```

### 4. State Machine Pattern
For DocTypes with complex workflow states.

```python
class ServiceRequest(Document):
    def validate(self):
        self.validate_state_transition()
    
    def validate_state_transition(self):
        """Validate allowed state transitions"""
        if self.is_new():
            return
        
        old_status = frappe.db.get_value("Service Request", self.name, "status")
        new_status = self.status
        
        allowed_transitions = {
            "Open": ["In Progress", "Cancelled"],
            "In Progress": ["Resolved", "On Hold", "Cancelled"],
            "On Hold": ["In Progress", "Cancelled"],
            "Resolved": ["Closed", "Reopened"],
            "Reopened": ["In Progress"],
            "Closed": [],
            "Cancelled": []
        }
        
        if new_status not in allowed_transitions.get(old_status, []):
            frappe.throw(f"Cannot change status from {old_status} to {new_status}")
```

### 5. Audit Trail Pattern
For maintaining comprehensive audit history.

```python
class AuditableDocument(Document):
    def validate(self):
        self.set_audit_fields()
        self.create_audit_log()
    
    def set_audit_fields(self):
        """Set audit timestamp and user fields"""
        if self.is_new():
            self.created_by = frappe.session.user
            self.created_on = frappe.utils.now()
        else:
            self.modified_by = frappe.session.user
            self.modified_on = frappe.utils.now()
    
    def create_audit_log(self):
        """Create detailed audit log entry"""
        if not self.is_new():
            changes = self.get_doc_changes()
            if changes:
                audit_log = frappe.get_doc({
                    "doctype": "Audit Log",
                    "document_type": self.doctype,
                    "document_name": self.name,
                    "action": "Update",
                    "changes": frappe.as_json(changes),
                    "user": frappe.session.user,
                    "timestamp": frappe.utils.now()
                })
                audit_log.insert(ignore_permissions=True)
```

## Field Design Patterns

### 1. Computed Field Pattern
For fields that derive values from other fields or external sources.

```python
class SalesInvoice(Document):
    def validate(self):
        self.calculate_totals()
        self.set_customer_details()
    
    def calculate_totals(self):
        """Calculate computed fields"""
        self.net_total = sum(item.amount for item in self.items)
        self.tax_amount = self.net_total * (self.tax_rate / 100)
        self.grand_total = self.net_total + self.tax_amount
    
    def set_customer_details(self):
        """Auto-populate customer details"""
        if self.customer:
            customer_doc = frappe.get_doc("Customer", self.customer)
            self.customer_name = customer_doc.customer_name
            self.billing_address = customer_doc.default_address
```

### 2. Validation Pattern
For field-level and cross-field validations.

```python
class Employee(Document):
    def validate(self):
        self.validate_email()
        self.validate_dates()
        self.validate_salary_structure()
    
    def validate_email(self):
        """Validate email format and uniqueness"""
        if self.email:
            if not frappe.utils.validate_email_address(self.email):
                frappe.throw("Invalid email format")
            
            existing = frappe.db.exists("Employee", {"email": self.email, "name": ("!=", self.name)})
            if existing:
                frappe.throw("Email already exists for another employee")
    
    def validate_dates(self):
        """Validate date relationships"""
        if self.date_of_joining and self.date_of_birth:
            if self.date_of_joining <= self.date_of_birth:
                frappe.throw("Date of joining must be after date of birth")
```

### 3. Reference Field Pattern
For linking to other DocTypes with validation.

```python
class ProjectTask(Document):
    def validate(self):
        self.validate_project_reference()
        self.validate_assignee_permissions()
    
    def validate_project_reference(self):
        """Validate project exists and is active"""
        if self.project:
            project_doc = frappe.get_doc("Project", self.project)
            if project_doc.status == "Cancelled":
                frappe.throw("Cannot assign task to cancelled project")
    
    def validate_assignee_permissions(self):
        """Validate assignee has project access"""
        if self.assigned_to and self.project:
            if not frappe.has_permission("Project", "read", self.project, user=self.assigned_to):
                frappe.throw(f"{self.assigned_to} does not have access to project {self.project}")
```

## Advanced Design Patterns

### 1. Plugin Architecture Pattern
For extensible DocTypes that support plugins.

```python
class ExtensibleDocument(Document):
    def validate(self):
        self.run_plugins("before_validate")
        self.core_validation()
        self.run_plugins("after_validate")
    
    def run_plugins(self, hook_name):
        """Execute registered plugins"""
        plugins = self.get_plugins()
        for plugin in plugins:
            if hasattr(plugin, hook_name):
                getattr(plugin, hook_name)(self)
    
    def get_plugins(self):
        """Get registered plugins for this DocType"""
        plugin_names = frappe.get_hooks(f"{self.doctype}_plugins") or []
        plugins = []
        for plugin_name in plugin_names:
            plugin_class = frappe.get_attr(plugin_name)
            plugins.append(plugin_class())
        return plugins
```

### 2. Factory Pattern
For creating different document types based on configuration.

```python
class DocumentFactory:
    @staticmethod
    def create_document(doc_type, data):
        """Create document based on type"""
        if doc_type == "sales_invoice":
            return SalesInvoiceCreator.create(data)
        elif doc_type == "purchase_invoice":
            return PurchaseInvoiceCreator.create(data)
        else:
            raise ValueError(f"Unknown document type: {doc_type}")

class SalesInvoiceCreator:
    @staticmethod
    def create(data):
        """Create sales invoice with business rules"""
        doc = frappe.new_doc("Sales Invoice")
        doc.update(data)
        doc.calculate_taxes()
        doc.set_customer_defaults()
        return doc
```

### 3. Observer Pattern
For DocTypes that need to notify other systems of changes.

```python
class Observable(Document):
    def after_insert(self):
        self.notify_observers("created")
    
    def after_save(self):
        self.notify_observers("updated")
    
    def on_cancel(self):
        self.notify_observers("cancelled")
    
    def notify_observers(self, event):
        """Notify registered observers"""
        observers = self.get_observers()
        for observer in observers:
            observer.handle_event(self, event)
    
    def get_observers(self):
        """Get registered observers"""
        observer_classes = frappe.get_hooks(f"{self.doctype}_observers") or []
        observers = []
        for observer_class in observer_classes:
            observers.append(frappe.get_attr(observer_class)())
        return observers
```

## Performance Design Patterns

### 1. Lazy Loading Pattern
For DocTypes with expensive operations.

```python
class ExpensiveDocument(Document):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._calculated_field = None
    
    @property
    def expensive_calculation(self):
        """Lazy load expensive calculation"""
        if self._calculated_field is None:
            self._calculated_field = self._perform_expensive_calculation()
        return self._calculated_field
    
    def _perform_expensive_calculation(self):
        """Expensive operation performed only when needed"""
        # Complex calculation here
        return calculated_value
```

### 2. Caching Pattern
For frequently accessed but rarely changed data.

```python
class CacheableDocument(Document):
    @frappe.whitelist()
    def get_cached_summary(self):
        """Get cached summary data"""
        cache_key = f"doc_summary_{self.doctype}_{self.name}"
        cached_data = frappe.cache().get_value(cache_key)
        
        if cached_data:
            return cached_data
        
        # Calculate summary
        summary = self._calculate_summary()
        
        # Cache for 1 hour
        frappe.cache().set_value(cache_key, summary, expires_in_sec=3600)
        return summary
    
    def on_update(self):
        """Clear cache when document is updated"""
        cache_key = f"doc_summary_{self.doctype}_{self.name}"
        frappe.cache().delete_value(cache_key)
```

### 3. Batch Processing Pattern
For DocTypes that handle bulk operations efficiently.

```python
class BatchProcessor(Document):
    @staticmethod
    def process_batch(doc_names, operation):
        """Process multiple documents in batch"""
        batch_size = 100
        total_processed = 0
        
        for i in range(0, len(doc_names), batch_size):
            batch = doc_names[i:i + batch_size]
            
            # Use database transactions for consistency
            with frappe.db.transaction():
                for doc_name in batch:
                    try:
                        doc = frappe.get_doc("Target DocType", doc_name)
                        operation(doc)
                        total_processed += 1
                    except Exception as e:
                        frappe.log_error(f"Error processing {doc_name}: {str(e)}")
            
            # Commit batch
            frappe.db.commit()
        
        return total_processed
```

## Security Design Patterns

### 1. Permission Layer Pattern
For fine-grained access control.

```python
class SecureDocument(Document):
    def has_permission(self, ptype, user=None):
        """Custom permission logic"""
        if not user:
            user = frappe.session.user
        
        # Admin always has permission
        if user == "Administrator":
            return True
        
        # Check role-based permissions
        if self.check_role_permissions(ptype, user):
            return True
        
        # Check ownership-based permissions
        if self.check_ownership_permissions(ptype, user):
            return True
        
        # Check custom business rules
        return self.check_business_rule_permissions(ptype, user)
    
    def check_ownership_permissions(self, ptype, user):
        """Check if user owns the document"""
        return self.owner == user or self.assigned_to == user
```

### 2. Data Masking Pattern
For protecting sensitive information.

```python
class SensitiveDocument(Document):
    def get_sensitive_fields(self):
        """Define sensitive fields that need masking"""
        return ["social_security_number", "bank_account", "salary"]
    
    def mask_sensitive_data(self, user=None):
        """Mask sensitive data based on user permissions"""
        if not user:
            user = frappe.session.user
        
        if not frappe.has_permission(self.doctype, "read_sensitive", user=user):
            sensitive_fields = self.get_sensitive_fields()
            for field in sensitive_fields:
                if hasattr(self, field) and getattr(self, field):
                    masked_value = self._mask_field_value(getattr(self, field))
                    setattr(self, field, masked_value)
    
    def _mask_field_value(self, value):
        """Mask field value"""
        if len(str(value)) > 4:
            return f"****{str(value)[-4:]}"
        return "****"
```

## Integration Design Patterns

### 1. Event-Driven Pattern
For DocTypes that need to integrate with external systems.

```python
class IntegratedDocument(Document):
    def after_insert(self):
        self.publish_event("document_created", {
            "doctype": self.doctype,
            "name": self.name,
            "data": self.as_dict()
        })
    
    def publish_event(self, event_type, data):
        """Publish event to external systems"""
        event_doc = frappe.get_doc({
            "doctype": "Integration Event",
            "event_type": event_type,
            "reference_doctype": self.doctype,
            "reference_name": self.name,
            "event_data": frappe.as_json(data),
            "status": "Pending"
        })
        event_doc.insert(ignore_permissions=True)
        
        # Queue for processing
        frappe.enqueue("process_integration_event", event_id=event_doc.name)
```

### 2. API Gateway Pattern
For DocTypes that expose standardized APIs.

```python
class APIEnabledDocument(Document):
    @frappe.whitelist()
    def api_create(self, data):
        """Standardized API for creating documents"""
        try:
            # Validate API data
            validated_data = self.validate_api_data(data)
            
            # Create document
            doc = frappe.get_doc(validated_data)
            doc.insert()
            
            # Return standardized response
            return {
                "success": True,
                "data": {
                    "id": doc.name,
                    "name": doc.name,
                    "creation": doc.creation
                },
                "message": "Document created successfully"
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "message": "Failed to create document"
            }
    
    def validate_api_data(self, data):
        """Validate incoming API data"""
        required_fields = self.get_required_api_fields()
        for field in required_fields:
            if field not in data:
                raise ValueError(f"Required field missing: {field}")
        
        return data
```

## Visual Layout Patterns

### 1. Standard Business Form Layout
Used for most business documents (Sales Order, Purchase Invoice, etc.)

```json
{
  "fields": [
    {
      "fieldname": "basic_section",
      "fieldtype": "Section Break",
      "label": "Basic Information"
    },
    {
      "fieldname": "naming_series",
      "fieldtype": "Select",
      "label": "Series"
    },
    {
      "fieldname": "customer",
      "fieldtype": "Link",
      "label": "Customer"
    },
    {
      "fieldname": "date",
      "fieldtype": "Date",
      "label": "Date"
    },
    {
      "fieldname": "column_break_4",
      "fieldtype": "Column Break"
    },
    {
      "fieldname": "status",
      "fieldtype": "Select",
      "label": "Status"
    },
    {
      "fieldname": "priority",
      "fieldtype": "Select",
      "label": "Priority"
    },
    {
      "fieldname": "items_section",
      "fieldtype": "Section Break",
      "label": "Items"
    },
    {
      "fieldname": "items",
      "fieldtype": "Table",
      "label": "Items",
      "options": "Item Child Table"
    },
    {
      "fieldname": "totals_section",
      "fieldtype": "Section Break",
      "label": "Totals"
    },
    {
      "fieldname": "total_qty",
      "fieldtype": "Float",
      "label": "Total Quantity",
      "read_only": 1
    },
    {
      "fieldname": "column_break_12",
      "fieldtype": "Column Break"
    },
    {
      "fieldname": "total_amount",
      "fieldtype": "Currency",
      "label": "Total Amount",
      "read_only": 1
    }
  ]
}
```

### 2. Tabbed Interface Pattern
For complex DocTypes with many fields

```json
{
  "fields": [
    {
      "fieldname": "tab_break_overview",
      "fieldtype": "Tab Break",
      "label": "Overview"
    },
    {
      "fieldname": "key_field_1",
      "fieldtype": "Data",
      "label": "Key Field 1"
    },
    {
      "fieldname": "tab_break_details",
      "fieldtype": "Tab Break",
      "label": "Details"
    },
    {
      "fieldname": "detail_section",
      "fieldtype": "Section Break"
    },
    {
      "fieldname": "detail_field_1",
      "fieldtype": "Text",
      "label": "Details"
    },
    {
      "fieldname": "tab_break_configuration",
      "fieldtype": "Tab Break",
      "label": "Configuration"
    },
    {
      "fieldname": "config_field_1",
      "fieldtype": "Check",
      "label": "Enable Feature"
    },
    {
      "fieldname": "tab_break_history",
      "fieldtype": "Tab Break",
      "label": "History"
    },
    {
      "fieldname": "history_html",
      "fieldtype": "HTML",
      "label": "Activity Log"
    }
  ]
}
```

### 3. Master Data Layout Pattern
For reference data like Customer, Supplier, Item

```json
{
  "fields": [
    {
      "fieldname": "identification_section",
      "fieldtype": "Section Break",
      "label": "Identification"
    },
    {
      "fieldname": "entity_name",
      "fieldtype": "Data",
      "label": "Name",
      "reqd": 1,
      "bold": 1
    },
    {
      "fieldname": "entity_code",
      "fieldtype": "Data",
      "label": "Code",
      "unique": 1
    },
    {
      "fieldname": "column_break_3",
      "fieldtype": "Column Break"
    },
    {
      "fieldname": "entity_type",
      "fieldtype": "Select",
      "label": "Type"
    },
    {
      "fieldname": "is_active",
      "fieldtype": "Check",
      "label": "Is Active",
      "default": 1
    },
    {
      "fieldname": "details_section",
      "fieldtype": "Section Break",
      "label": "Details",
      "collapsible": 1
    },
    {
      "fieldname": "description",
      "fieldtype": "Text Editor",
      "label": "Description"
    },
    {
      "fieldname": "classification_section",
      "fieldtype": "Section Break",
      "label": "Classification",
      "collapsible": 1,
      "collapsible_depends_on": "eval:doc.entity_type"
    },
    {
      "fieldname": "category",
      "fieldtype": "Link",
      "label": "Category"
    },
    {
      "fieldname": "tags",
      "fieldtype": "Table MultiSelect",
      "label": "Tags"
    }
  ]
}
```

### 4. Settings DocType Layout (Single)
For application settings and configuration

```json
{
  "issingle": 1,
  "fields": [
    {
      "fieldname": "general_section",
      "fieldtype": "Section Break",
      "label": "General Settings"
    },
    {
      "fieldname": "app_name",
      "fieldtype": "Data",
      "label": "Application Name"
    },
    {
      "fieldname": "enable_feature_x",
      "fieldtype": "Check",
      "label": "Enable Feature X"
    },
    {
      "fieldname": "column_break_3",
      "fieldtype": "Column Break"
    },
    {
      "fieldname": "default_value",
      "fieldtype": "Data",
      "label": "Default Value"
    },
    {
      "fieldname": "max_limit",
      "fieldtype": "Int",
      "label": "Maximum Limit"
    },
    {
      "fieldname": "advanced_section",
      "fieldtype": "Section Break",
      "label": "Advanced Settings",
      "collapsible": 1
    },
    {
      "fieldname": "advanced_config",
      "fieldtype": "Code",
      "label": "Configuration JSON",
      "options": "JSON"
    }
  ]
}
```

### 5. Wizard/Step Pattern
For guided data entry

```python
# Use depends_on to show fields progressively
{
  "fields": [
    {
      "fieldname": "step_1_section",
      "fieldtype": "Section Break",
      "label": "Step 1: Basic Information"
    },
    {
      "fieldname": "field_step_1",
      "fieldtype": "Data",
      "label": "Required Field",
      "reqd": 1
    },
    {
      "fieldname": "step_2_section",
      "fieldtype": "Section Break",
      "label": "Step 2: Details",
      "depends_on": "eval:doc.field_step_1"
    },
    {
      "fieldname": "field_step_2",
      "fieldtype": "Select",
      "label": "Choose Option",
      "depends_on": "eval:doc.field_step_1"
    },
    {
      "fieldname": "step_3_section",
      "fieldtype": "Section Break",
      "label": "Step 3: Confirmation",
      "depends_on": "eval:doc.field_step_1 && doc.field_step_2"
    }
  ]
}
```

### 6. Dashboard Layout Pattern
For DocTypes that show metrics and summaries

```json
{
  "fields": [
    {
      "fieldname": "metrics_section",
      "fieldtype": "Section Break",
      "label": "Key Metrics"
    },
    {
      "fieldname": "metric_1",
      "fieldtype": "Float",
      "label": "Metric 1",
      "read_only": 1,
      "bold": 1
    },
    {
      "fieldname": "metric_2",
      "fieldtype": "Float",
      "label": "Metric 2",
      "read_only": 1,
      "bold": 1
    },
    {
      "fieldname": "column_break_3",
      "fieldtype": "Column Break"
    },
    {
      "fieldname": "metric_3",
      "fieldtype": "Percent",
      "label": "Metric 3",
      "read_only": 1,
      "bold": 1
    },
    {
      "fieldname": "metric_4",
      "fieldtype": "Currency",
      "label": "Metric 4",
      "read_only": 1,
      "bold": 1
    },
    {
      "fieldname": "chart_section",
      "fieldtype": "Section Break",
      "label": "Visualizations"
    },
    {
      "fieldname": "chart_html",
      "fieldtype": "HTML",
      "label": "Chart",
      "options": "<div id='chart-container'></div>"
    }
  ]
}
```

## Testing Patterns

### 1. Test Data Builder Pattern
For creating test documents with realistic data.

```python
class DocumentBuilder:
    def __init__(self, doctype):
        self.doctype = doctype
        self.data = {}
    
    def with_field(self, fieldname, value):
        """Set field value"""
        self.data[fieldname] = value
        return self
    
    def with_defaults(self):
        """Set default values for required fields"""
        meta = frappe.get_meta(self.doctype)
        for field in meta.get("fields"):
            if field.reqd and not self.data.get(field.fieldname):
                self.data[field.fieldname] = self._get_default_value(field)
        return self
    
    def build(self):
        """Build the document"""
        doc = frappe.get_doc(self.doctype)
        doc.update(self.data)
        return doc
    
    def create(self):
        """Build and insert the document"""
        doc = self.build()
        doc.insert()
        return doc

# Usage
test_customer = (DocumentBuilder("Customer")
                .with_field("customer_name", "Test Customer")
                .with_field("customer_group", "Individual")
                .with_defaults()
                .create())
```

## Best Practices Summary

### 1. Naming Conventions
- Use clear, business-oriented DocType names
- Follow consistent field naming patterns
- Use meaningful naming series

### 2. Data Integrity
- Implement comprehensive validation
- Use database constraints where appropriate
- Maintain referential integrity

### 3. Performance
- Design for scalability from the start
- Use appropriate indexing strategies
- Implement caching for frequently accessed data

### 4. Security
- Apply principle of least privilege
- Implement proper access controls
- Protect sensitive data

### 5. Maintainability
- Follow SOLID principles
- Use consistent coding patterns
- Document complex business logic
- Implement comprehensive testing

### 6. Integration
- Design for loose coupling
- Use event-driven architectures
- Implement proper error handling
- Provide standardized APIs

---

This comprehensive guide provides the foundation for designing robust, scalable, and maintainable ERPNext DocTypes that follow industry best practices while leveraging the full power of the Frappe Framework.