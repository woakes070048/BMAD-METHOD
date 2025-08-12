# ERPNext Technical Preferences and Standards

## Development Environment Standards

### Required Environment Setup
```yaml
development_environment:
  bench_path: "/home/frappe/frappe-bench"
  site: "prima-erpnext.pegashosting.com"
  user: "frappe"
  python_version: "3.8+"
  node_version: "14+"
  
framework_versions:
  frappe: ">=15.0.0,<16.0.0"
  erpnext: ">=15.0.0,<16.0.0"
  
required_tools:
  - bench
  - git
  - nodejs
  - yarn
  - redis
  - mariadb
```

### Development Workflow Tools
```yaml
code_quality:
  python_linter: "flake8"
  javascript_linter: "eslint"
  code_formatter: "black"
  import_sorter: "isort"
  
testing_framework:
  python_testing: "frappe.test_runner"
  javascript_testing: "jest"
  integration_testing: "cypress"
  
version_control:
  git_flow: "feature-branch"
  commit_convention: "conventional-commits"
  branch_naming: "feature/module-name-description"
```

## Frappe Framework Preferences

### Field Type Preferences
```yaml
preferred_field_types:
  text_short: "Data" # Up to 140 characters
  text_long: "Text" # Unlimited text
  rich_text: "Text Editor" # HTML rich text
  numbers: "Int" or "Float" # Based on precision needs
  currency: "Currency" # Always use for money values
  dates: "Date" or "Datetime" # Based on precision needs
  boolean: "Check" # For true/false values
  selections: "Select" # For predefined options
  
relationship_preferences:
  one_to_many: "Link" # Foreign key relationship
  many_to_many: "Table MultiSelect" # Junction table
  child_tables: "Table" # Embedded documents
  
validation_preferences:
  required_fields: "Set reqd=1 in DocType"
  custom_validation: "validate() method in controller"
  field_validation: "Frappe built-in validators"
  business_rules: "Controller methods with frappe.throw()"
```

### DocType Design Standards
```yaml
naming_conventions:
  doctype_names: "Title Case with Spaces"
  field_names: "snake_case"
  method_names: "snake_case"
  class_names: "PascalCase"
  
file_organization:
  controller: "[doctype_name].py"
  client_script: "[doctype_name].js"
  form_script: "[doctype_name]_list.js"
  templates: "[doctype_name].html"
  
performance_standards:
  max_fields_per_doctype: 50
  max_child_table_rows: 1000
  required_indexes: "For filtered/sorted fields"
  database_queries: "Use frappe.get_all() over raw SQL"
```

## API Development Standards

### API Endpoint Patterns
```python
# Preferred API Method Structure
@frappe.whitelist()
def get_filtered_data(doctype, filters=None, fields=None, limit=20):
    """
    Standard pattern for data retrieval APIs
    
    Args:
        doctype (str): The DocType to query
        filters (dict): Filter conditions
        fields (list): Fields to return
        limit (int): Maximum records to return
    
    Returns:
        list: Filtered and formatted data
    """
    # Permission validation
    if not frappe.has_permission(doctype, "read"):
        frappe.throw(_("Insufficient permissions"))
    
    # Input validation
    if filters:
        filters = frappe.parse_json(filters)
    if fields:
        fields = frappe.parse_json(fields)
    else:
        fields = ["name", "modified"]
    
    # Data retrieval
    data = frappe.get_all(
        doctype,
        filters=filters,
        fields=fields,
        limit=limit,
        order_by="modified desc"
    )
    
    return data

@frappe.whitelist()
def create_document_with_validation(doctype, doc_data):
    """
    Standard pattern for document creation APIs
    
    Args:
        doctype (str): The DocType to create
        doc_data (dict): Document data
    
    Returns:
        str: Created document name
    """
    # Permission validation
    if not frappe.has_permission(doctype, "create"):
        frappe.throw(_("Insufficient permissions"))
    
    # Input validation
    doc_data = frappe.parse_json(doc_data)
    doc_data["doctype"] = doctype
    
    # Document creation
    doc = frappe.get_doc(doc_data)
    doc.insert()
    
    return doc.name
```

### Security Standards
```yaml
api_security:
  authentication: "frappe.whitelist() for authenticated users"
  guest_access: "frappe.whitelist(allow_guest=True) only when necessary"
  permission_checking: "Always validate frappe.has_permission()"
  input_validation: "Use frappe.parse_json() for JSON inputs"
  rate_limiting: "Consider for high-frequency endpoints"
  
data_protection:
  sensitive_fields: "Use ignore_user_permissions=True sparingly"
  data_filtering: "Apply user-specific filters automatically"
  audit_logging: "Use frappe.log_error() for important operations"
  error_handling: "Don't expose internal errors to API consumers"
```

## Frontend Development Standards

### Vue.js with Frappe UI
```javascript
// Preferred Component Structure
<template>
  <div class="custom-component">
    <!-- Use Frappe UI components -->
    <FrappeCard>
      <template #header>
        <div class="flex justify-between items-center">
          <h3 class="text-lg font-semibold">{{ title }}</h3>
          <FrappeButton @click="handleAction">Action</FrappeButton>
        </div>
      </template>
      <template #body>
        <div class="space-y-4">
          <!-- Component content -->
        </div>
      </template>
    </FrappeCard>
  </div>
</template>

<script>
import { FrappeCard, FrappeButton } from 'frappe-ui'

export default {
  name: 'CustomComponent',
  components: {
    FrappeCard,
    FrappeButton
  },
  props: {
    title: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      // Component state
    }
  },
  computed: {
    // Computed properties
  },
  methods: {
    // Component methods
  },
  mounted() {
    // Component initialization
  }
}
</script>

<style scoped>
/* Component-specific styles using Tailwind CSS */
</style>
```

### Mobile-First Design Standards
```css
/* Responsive Design Patterns */
.responsive-container {
  @apply w-full max-w-7xl mx-auto px-4;
}

.responsive-grid {
  @apply grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4;
}

.mobile-friendly-button {
  @apply min-h-[44px] min-w-[44px] touch-manipulation;
}

/* Mobile breakpoints */
@media (max-width: 768px) {
  .hide-on-mobile {
    @apply hidden;
  }
  
  .mobile-full-width {
    @apply w-full;
  }
}
```

### Performance Standards
```yaml
frontend_performance:
  page_load_time: "<3 seconds on 3G"
  lighthouse_score: ">90 for Performance"
  bundle_size: "Keep chunks under 200KB"
  image_optimization: "Use WebP format when possible"
  caching_strategy: "Cache static assets, fresh data"
  
mobile_performance:
  touch_targets: "Minimum 44px x 44px"
  viewport_meta: "Properly configured"
  font_loading: "Preload critical fonts"
  offline_functionality: "Consider for core features"
```

## Testing Standards

### Test Coverage Requirements
```yaml
testing_coverage:
  unit_tests: ">80% code coverage"
  integration_tests: "All API endpoints"
  frontend_tests: "Critical user workflows"
  mobile_tests: "Core functionality on devices"
  
test_organization:
  unit_tests: "tests/test_[module].py"
  integration_tests: "tests/integration/test_[feature].py"
  frontend_tests: "cypress/integration/[feature].spec.js"
  fixtures: "tests/fixtures/[doctype].json"
```

### Testing Patterns
```python
# Unit Test Pattern
import unittest
import frappe
from frappe.test_runner import make_test_records

class TestCustomDocType(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        """Set up test data"""
        make_test_records("Custom DocType")
    
    def test_validation_logic(self):
        """Test document validation"""
        doc = frappe.get_doc({
            "doctype": "Custom DocType",
            "title": "Test Document"
        })
        doc.insert()
        self.assertEqual(doc.status, "Draft")
    
    def test_api_endpoint(self):
        """Test API functionality"""
        response = frappe.get_doc("Custom DocType").run_method(
            "custom_method", 
            {"param": "value"}
        )
        self.assertIsNotNone(response)
```

## Database Standards

### Query Optimization
```python
# Preferred Query Patterns
# Good: Specific field selection
data = frappe.get_all(
    "Sales Invoice",
    filters={"status": "Paid"},
    fields=["name", "customer", "grand_total", "posting_date"],
    limit=100
)

# Good: Using indexes effectively
data = frappe.get_all(
    "Sales Invoice",
    filters={
        "posting_date": ["between", ["2023-01-01", "2023-12-31"]],
        "status": "Paid"
    },
    order_by="posting_date desc"
)

# Bad: Selecting all fields
data = frappe.get_all("Sales Invoice")  # Avoid

# Bad: Complex operations in Python instead of database
# Process large datasets in database queries, not Python loops
```

### Index Strategy
```yaml
indexing_strategy:
  primary_key: "Automatic on 'name' field"
  foreign_keys: "Automatic on Link fields"
  filtered_fields: "Add index for frequently filtered fields"
  sorted_fields: "Add index for ORDER BY fields"
  composite_indexes: "For multi-field filter combinations"
  
database_performance:
  query_timeout: "30 seconds maximum"
  connection_pooling: "Use frappe.db connection"
  transaction_management: "Use frappe.db.begin() for multi-operations"
  bulk_operations: "Use frappe.db.bulk_insert() for large datasets"
```

## Integration Standards

### Multi-App Integration Patterns
```python
# docflow Integration Pattern
def setup_workflow_integration(self):
    """Standard workflow integration"""
    if frappe.db.exists("Workflow", f"{self.doctype} Workflow"):
        workflow_state = frappe.get_value(
            "Workflow State", 
            {"parent": f"{self.doctype} Workflow", "state": self.workflow_state}
        )
        return workflow_state
    return None

# n8n_integration Pattern
def trigger_automation(self, event_type):
    """Standard automation trigger"""
    if frappe.db.exists("DocType", "n8n Integration"):
        frappe.enqueue(
            "n8n_integration.api.trigger_webhook",
            queue="default",
            timeout=300,
            doctype=self.doctype,
            doc_name=self.name,
            event_type=event_type,
            doc_data=self.as_dict()
        )
```

### External API Integration
```python
# External API Call Pattern
import frappe
import requests
from frappe.utils import get_url

def call_external_api(endpoint, data, timeout=30):
    """Standard external API call pattern"""
    try:
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {get_api_token()}"
        }
        
        response = requests.post(
            endpoint,
            json=data,
            headers=headers,
            timeout=timeout
        )
        
        response.raise_for_status()
        return response.json()
        
    except requests.exceptions.RequestException as e:
        frappe.log_error(f"External API Error: {str(e)}", "External API")
        frappe.throw(_("External service temporarily unavailable"))
```

## Security Standards

### Authentication and Authorization
```yaml
security_requirements:
  authentication: "Use Frappe session management"
  authorization: "Role-based permissions with frappe.has_permission()"
  session_management: "Leverage Frappe's built-in session handling"
  password_policy: "Follow Frappe's password requirements"
  
data_protection:
  sensitive_data: "Use 'Hidden' field type for passwords"
  encryption: "Use frappe.utils.password for sensitive data"
  audit_trails: "Log important operations with frappe.log_error()"
  data_retention: "Follow ERPNext data retention policies"
  
api_security:
  input_validation: "Validate all inputs with frappe.parse_json()"
  output_sanitization: "Use frappe response methods"
  rate_limiting: "Implement for public APIs"
  cors_policy: "Configure appropriately for frontend"
```

## Deployment Standards

### Production Deployment
```yaml
deployment_requirements:
  environment_parity: "Development matches production setup"
  database_migrations: "Test migrations on staging first"
  asset_compilation: "Build and minify all assets"
  performance_testing: "Load test before deployment"
  
monitoring_setup:
  application_monitoring: "Monitor ERPNext performance"
  error_tracking: "Capture and alert on errors"
  log_aggregation: "Centralize logs from all services"
  uptime_monitoring: "Monitor site availability"
  
backup_strategy:
  database_backups: "Daily automated backups"
  file_backups: "Include uploaded files"
  code_backups: "Git repository with tags"
  recovery_testing: "Test restore procedures monthly"
```

### CI/CD Pipeline
```yaml
continuous_integration:
  code_quality_checks: "Lint, format, security scan"
  automated_testing: "Unit, integration, and E2E tests"
  build_validation: "Successful build for all environments"
  security_scanning: "Dependency and code security scans"
  
continuous_deployment:
  staging_deployment: "Automatic deployment to staging"
  production_deployment: "Manual approval required"
  rollback_capability: "Quick rollback on issues"
  health_checks: "Post-deployment validation"
```

## Documentation Standards

### Code Documentation
```python
# Function Documentation Standard
def process_sales_order(sales_order_name, action="submit"):
    """
    Process a Sales Order through its workflow states.
    
    This function handles the complete workflow processing of a Sales Order,
    including validation, state transitions, and integration triggers.
    
    Args:
        sales_order_name (str): The name of the Sales Order to process
        action (str, optional): The action to perform. Defaults to "submit".
                               Valid actions: "submit", "cancel", "approve"
    
    Returns:
        dict: Processing result with status and message
            {
                "status": "success" | "error",
                "message": "Description of the result",
                "data": {...}  # Additional result data
            }
    
    Raises:
        frappe.ValidationError: If the Sales Order is in an invalid state
        frappe.PermissionError: If user lacks required permissions
    
    Example:
        >>> result = process_sales_order("SO-2023-001", "submit")
        >>> print(result["status"])  # "success"
    
    Note:
        This function triggers automation workflows and updates related documents.
        Ensure all dependent documents are in valid states before calling.
    """
    # Implementation here
    pass
```

### API Documentation
```yaml
api_documentation:
  endpoint_description: "Clear purpose and usage"
  parameter_specification: "Type, required/optional, validation rules"
  response_format: "Structure and example responses"
  error_handling: "Possible errors and status codes"
  authentication: "Required permissions and roles"
  
user_documentation:
  feature_descriptions: "Business value and usage scenarios"
  step_by_step_guides: "Clear instructions with screenshots"
  troubleshooting: "Common issues and solutions"
  integration_guides: "How to integrate with other systems"
```