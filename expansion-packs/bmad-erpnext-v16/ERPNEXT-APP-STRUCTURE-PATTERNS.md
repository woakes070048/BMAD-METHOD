# ERPNext App Structure Patterns

## Core Principle: 3-Layer Architecture

Every ERPNext app MUST follow this exact structure. No exceptions.

## The Three Layers

### Layer 1: App Root
```
app-name/                    # Root directory (kebab-case)
├── pyproject.toml          # Modern Python packaging
├── README.md               # Documentation
├── license.txt             # License file
├── requirements.txt        # Python dependencies (optional)
├── package.json           # Node dependencies (optional, for build tools only)
└── app-name/              # Package directory (same name as root)
```

**CRITICAL RULES:**
- NO Python files at root level
- NO business logic at root level
- Only configuration and documentation files

### Layer 2: Package Layer
```
app-name/app-name/          # Package directory
├── __init__.py            # Package initialization
├── hooks.py               # App configuration and event hooks
├── modules.txt            # Module definitions
├── patches.txt            # Database patches list
├── config/                # App configuration
│   ├── __init__.py
│   └── desktop.py        # Desktop/workspace configuration
├── fixtures/              # Data fixtures
│   ├── __init__.py
│   └── custom_fields.json # Custom field definitions
├── api/                   # API endpoints (ALL must use @frappe.whitelist)
│   ├── __init__.py
│   └── endpoints.py      # API functions
├── lib/                   # Business logic layer
│   ├── __init__.py
│   ├── services/         # Service layer
│   └── utils/            # Utility functions
├── utils/                 # Framework utilities
│   ├── __init__.py
│   └── helpers.py        # Helper functions
└── public/                # Static assets
    ├── js/               # JavaScript/Vue files
    ├── css/              # Stylesheets
    └── images/           # Static images
```

**CRITICAL RULES:**
- ALL Python code goes here or in module layer
- hooks.py MUST be at this level
- API endpoints MUST use @frappe.whitelist() decorator
- Public assets go in public/ directory

### Layer 3: Module Layer
```
app-name/app-name/app-name/  # Module directory (triple nesting)
├── __init__.py
├── doctype/                 # DocTypes (data models)
│   ├── __init__.py
│   ├── main_doctype/       # Parent DocType
│   │   ├── main_doctype.json
│   │   ├── main_doctype.py
│   │   ├── main_doctype.js
│   │   └── test_main_doctype.py
│   └── child_table_ct/     # Child table (MUST end with _ct)
│       ├── child_table_ct.json
│       └── child_table_ct.py
├── page/                    # Single Page Applications
│   ├── __init__.py
│   └── page_name/
│       ├── page_name.json
│       └── page_name.js
├── report/                  # Reports
│   ├── __init__.py
│   └── report_name/
│       ├── report_name.json
│       ├── report_name.py
│       └── report_name.js
├── workspace/              # Workspaces
│   └── workspace_name/
│       └── workspace_name.json
├── print_format/           # Print formats
├── web_form/              # Web forms
├── notification/          # Email notifications
└── dashboard_chart/       # Dashboard charts
```

**CRITICAL RULES:**
- Module name MUST match app name
- Child tables MUST use `_ct` suffix
- Each DocType needs .json and .py files minimum
- Test files follow pattern: test_[doctype_name].py

## Import Patterns

### CORRECT Import Patterns
```python
# From package layer
from app_name.api.endpoints import api_function
from app_name.lib.services import ServiceClass
from app_name.utils.helpers import helper_function

# DocType access (use frappe methods)
doc = frappe.get_doc("DocType Name", "doc_name")
# NOT: from app_name.app_name.doctype.doctype_name.doctype_name import DocTypeName
```

### WRONG Import Patterns
```python
# ❌ NEVER use triple nesting in imports
from app_name.app_name.api.endpoints import function  # WRONG!

# ❌ NEVER import DocType classes directly
from app_name.app_name.doctype.customer.customer import Customer  # WRONG!

# ❌ NEVER import from root
from app_name import something  # WRONG if something is at root!
```

## File Naming Conventions

### DocTypes
- **DocType Name**: PascalCase (e.g., `SalesOrder`, `CustomerGroup`)
- **Folder Name**: snake_case (e.g., `sales_order`, `customer_group`)
- **Child Tables**: snake_case_ct (e.g., `sales_order_item_ct`)

### Python Files
- **All Python files**: snake_case.py
- **Test files**: test_snake_case.py
- **API files**: descriptive_name_api.py

### JavaScript/Vue Files
- **Vue components**: PascalCase.vue
- **Bundle entry**: feature_name.bundle.js
- **Regular JS**: snake_case.js

### CSS Files
- **All CSS**: kebab-case.css

## Directory Placement Rules

### Where Things Go

| Component Type | Location | Example |
|---------------|----------|---------|
| API Endpoints | `app-name/api/` | `api/customer_api.py` |
| Business Logic | `app-name/lib/` | `lib/services/order_service.py` |
| Utilities | `app-name/utils/` | `utils/formatters.py` |
| DocTypes | `app-name/app-name/doctype/` | `doctype/sales_order/` |
| Vue Components | `app-name/public/js/` | `public/js/components/` |
| Pages | `app-name/app-name/page/` | `page/dashboard/` |
| Reports | `app-name/app-name/report/` | `report/sales_summary/` |
| Fixtures | `app-name/fixtures/` | `fixtures/custom_fields.json` |

### What NOT to Create

| DON'T Create | Use Instead |
|-------------|------------|
| `/frontend/` directory | `public/js/` with Frappe's build |
| `/src/` directory | Package layer directories |
| `/backend/` directory | Package layer (api/, lib/, utils/) |
| Root level Python files | Package layer files |
| Separate package.json for frontend | Use Frappe's build system |

## Workspace Rules

### ONLY Parent DocTypes in Workspace
```json
{
  "links": [
    {
      "type": "doctype",
      "name": "Sales Order",  // ✅ Parent DocType
      "link": "List/Sales Order"
    }
  ]
}
```

### NEVER Child Tables in Workspace
```json
{
  "links": [
    {
      "type": "doctype",
      "name": "Sales Order Item CT",  // ❌ WRONG! Child table
      "link": "List/Sales Order Item CT"
    }
  ]
}
```

## Configuration Files

### hooks.py Location
MUST be at: `app-name/app-name/hooks.py`

### Example hooks.py Structure
```python
app_name = "app_name"
app_title = "App Name"
app_publisher = "Your Company"
app_description = "App description"
app_email = "email@example.com"
app_license = "MIT"

# Hooks
doc_events = {
    "Sales Order": {
        "validate": "app_name.api.sales_api.validate_order"
    }
}

# Scheduled tasks
scheduler_events = {
    "hourly": ["app_name.tasks.hourly_task"]
}
```

## Validation Checklist

Before committing any app structure:

- [ ] Root directory has NO Python files
- [ ] hooks.py is at package layer (app-name/app-name/)
- [ ] All DocTypes are in module layer (app-name/app-name/app-name/)
- [ ] Child tables use _ct suffix
- [ ] API files have @frappe.whitelist() decorators
- [ ] Vue components are in public/js/
- [ ] No /frontend/ directory exists
- [ ] Imports follow correct patterns
- [ ] Workspace only links to parent DocTypes

## Common Mistakes to Avoid

1. **Creating /frontend/ directory** - Use public/js/ instead
2. **Putting Python files at root** - Use package layer
3. **Wrong import paths** - Follow the patterns above
4. **Child tables in workspace** - Only parent DocTypes
5. **Missing @frappe.whitelist()** - Required for all APIs
6. **Direct DocType imports** - Use frappe.get_doc() instead
7. **Creating /src/ or /backend/** - Use standard structure

## When to Create Subdirectories

### Create subdirectories when:
- You have 5+ files of same type
- Logical grouping improves clarity
- Different features need separation

### Examples:
```
api/
├── __init__.py
├── v1/                    # API versioning
│   ├── __init__.py
│   ├── customer_api.py
│   └── order_api.py
└── v2/
    ├── __init__.py
    └── customer_api.py

lib/
├── __init__.py
├── services/              # Service layer
│   ├── __init__.py
│   ├── order_service.py
│   └── payment_service.py
└── validators/           # Validation logic
    ├── __init__.py
    └── order_validator.py
```

## File Size Guidelines

### When to Split Files:
- Python files > 500 lines
- Vue components > 300 lines
- Too many responsibilities in one file

### How to Split:
1. **Services**: One service per business domain
2. **APIs**: Group by resource or version
3. **Utils**: Group by functionality type
4. **Components**: One component per file

## Testing Structure

### Test File Placement:
```
app-name/
├── app-name/
│   ├── tests/              # Unit tests
│   │   ├── __init__.py
│   │   └── test_services.py
│   └── app-name/
│       └── doctype/
│           └── sales_order/
│               └── test_sales_order.py  # DocType tests
```

### Test Naming:
- Test files: `test_*.py`
- Test methods: `test_*()` 
- Test classes: `Test*`

## Migration from Wrong Structure

If your app has wrong structure:

1. **Create correct directories** first
2. **Move files** to correct locations
3. **Update all imports** in moved files
4. **Update imports** in files that reference moved files
5. **Test thoroughly** before committing
6. **Update hooks.py** if needed
7. **Clear cache** and rebuild

## Compliance Validation

Use these commands to validate structure:

```bash
# Check for wrong patterns
find . -path "*/frontend/*" -type f  # Should return nothing
find . -name "*.py" -maxdepth 1      # Should only show setup.py if any

# Validate imports
grep -r "from app_name.app_name.api" .  # Should return nothing
grep -r "@frappe.whitelist" app-name/api/  # Should find decorators

# Check child table naming
find . -path "*/doctype/*" -type d -name "*_ct"  # Should find child tables
```

This structure MUST be followed for all ERPNext apps. No exceptions.