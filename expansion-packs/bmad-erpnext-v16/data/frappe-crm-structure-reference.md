# Frappe CRM Structure Reference
## Gold Standard for Frappe App Organization

This document serves as the reference standard for proper Frappe app structure, based on the official Frappe CRM application. Eva Thorne (app-structure-validator) uses this as the compliance baseline.

## ✅ CORRECT Structure Pattern

```
app_name/
├── app_name/                       # Main app module (MUST match app name)
│   ├── __init__.py                # Required for Python module
│   ├── hooks.py                   # App configuration and hooks
│   ├── modules.txt                # List of modules in the app
│   ├── patches.txt                # Migration patches list
│   │
│   ├── api/                       # API endpoints (MODULE ROOT LEVEL ONLY)
│   │   ├── __init__.py
│   │   └── *.py                   # API endpoint files
│   │
│   ├── config/                    # Configuration files (SINGLE LOCATION)
│   │   ├── __init__.py
│   │   └── *.py                   # Config modules
│   │
│   ├── utils/                     # Utility functions (MODULE ROOT LEVEL ONLY)
│   │   ├── __init__.py
│   │   └── *.py                   # Utility modules
│   │
│   ├── integrations/              # External service integrations
│   │   ├── __init__.py
│   │   └── service_name/          # Service-specific code
│   │
│   ├── overrides/                 # Framework overrides
│   │   ├── __init__.py
│   │   └── *.py                   # Override modules
│   │
│   ├── patches/                   # Database migration patches
│   │   └── version/               # Version-specific patches
│   │
│   ├── public/                    # Static assets (SINGLE LOCATION)
│   │   ├── js/                    # JavaScript files
│   │   ├── css/                   # Stylesheets
│   │   └── images/                # Image assets
│   │
│   ├── templates/                 # HTML/Email templates
│   │   ├── emails/                # Email templates
│   │   └── pages/                 # Page templates
│   │
│   ├── www/                       # Public web pages
│   │   └── *.py                   # Web page controllers
│   │
│   └── [business_module]/         # Business module (e.g., fcrm, sales, hr)
│       ├── __init__.py
│       ├── doctype/               # DocTypes (ONLY in business modules)
│       │   └── doctype_name/
│       │       ├── doctype_name.json
│       │       ├── doctype_name.py
│       │       ├── test_doctype_name.py
│       │       └── doctype_name.js
│       └── workspace/             # Workspace definitions
│           └── workspace_name/
│               └── workspace_name.json
│
├── frontend/                      # Optional: Separate frontend app
│   ├── src/                       # Frontend source code
│   ├── public/                    # Frontend static assets
│   └── package.json               # Frontend dependencies
│
├── LICENSE                        # License file
├── README.md                      # Documentation
├── requirements.txt               # Python dependencies
├── pyproject.toml                # Python project configuration
└── package.json                   # Node.js dependencies (if needed)
```

## 🚫 ANTI-PATTERNS (Never Do This)

### ❌ Business Logic in Business Modules
```
# WRONG - Creates import violations
app_name/
└── sales_module/
    ├── api/           # ❌ NEVER put api/ in business module
    ├── services/      # ❌ NEVER put services/ in business module
    ├── utils/         # ❌ NEVER put utils/ in business module
    └── doctype/       # ✅ This belongs here
```

### ❌ Duplicate Directories
```
# WRONG - Creates confusion and import issues
app_name/
├── public/            # ✅ Correct location
└── sales_module/
    └── public/        # ❌ NEVER duplicate public/ in modules
```

### ❌ Incorrect Import Patterns
```python
# WRONG - Import from business module subdirectory
from app_name.sales_module.api.customer import get_customer  # ❌

# CORRECT - Import from module root
from app_name.api.customer import get_customer  # ✅
```

## 📋 Validation Checklist

### Module Root Level Requirements
- [ ] `hooks.py` exists and is properly configured
- [ ] `modules.txt` lists all business modules
- [ ] `__init__.py` present for Python module
- [ ] `api/` directory at module root (if APIs exist)
- [ ] `utils/` directory at module root (if utilities exist)
- [ ] `public/` directory at module root (single location)
- [ ] `config/` directory at module root (single location)

### Business Module Structure
- [ ] Contains ONLY `doctype/` and `workspace/` directories
- [ ] NO `api/`, `services/`, `utils/` directories
- [ ] NO duplicate `public/` or `config/` directories
- [ ] Each DocType has proper file structure

### Import Pattern Validation
- [ ] All API imports from `app_name.api.*`
- [ ] All utility imports from `app_name.utils.*`
- [ ] DocType imports from `app_name.module.doctype.*`
- [ ] No cross-module business logic imports

## 📊 Compliance Scoring

### Weight Distribution
- **40%** - Directory Structure Organization
  - Module root has required directories
  - Business modules follow constraints
  - No duplicate directories

- **30%** - Import Pattern Correctness
  - Imports follow standard patterns
  - No business module subdirectory imports
  - Proper relative imports

- **20%** - Hooks Configuration
  - hooks.py properly configured
  - All app_include paths correct
  - DocType includes registered

- **10%** - General Framework Standards
  - Naming conventions followed
  - File permissions correct
  - Documentation present

### Compliance Levels
- **95-100%**: Production Ready ✅
- **85-94%**: Minor fixes needed ⚠️
- **70-84%**: Restructure required 🔧
- **<70%**: Critical - Stop development 🚨

## 🔍 Common Issues & Fixes

### Issue 1: API in Business Module
**Problem**: `app_name/sales/api/customer.py`
**Fix**: Move to `app_name/api/customer.py`
**Import Update**: 
```python
# Before
from app_name.sales.api.customer import get_customer

# After  
from app_name.api.customer import get_customer
```

### Issue 2: Multiple Public Directories
**Problem**: Public assets scattered across modules
**Fix**: Consolidate all to `app_name/public/`
**Path Update**: Update all asset references in hooks.py

### Issue 3: Utils in Wrong Location
**Problem**: `app_name/hr/utils/helper.py`
**Fix**: Move to `app_name/utils/hr_helper.py`
**Import Update**:
```python
# Before
from app_name.hr.utils.helper import process_data

# After
from app_name.utils.hr_helper import process_data
```

## 🛠️ Validation Tools

### Manual Validation
```bash
# Check structure
tree app_name -L 3 -d

# Find misplaced api directories
find app_name -type d -name "api" | grep -v "app_name/api"

# Find misplaced utils directories  
find app_name -type d -name "utils" | grep -v "app_name/utils"

# Check for duplicate public directories
find app_name -type d -name "public" | wc -l  # Should be 1
```

### Import Pattern Check
```bash
# Find incorrect import patterns
grep -r "from app_name\.[^.]*\.api\." --include="*.py"
grep -r "from app_name\.[^.]*\.utils\." --include="*.py"
```

## 📚 Reference Implementation

The Frappe CRM app serves as the reference implementation:
- **Repository**: https://github.com/frappe/crm
- **Local Path**: `/home/frappe/crm`
- **Key Features**:
  - Clean separation of concerns
  - Proper module organization
  - Correct import patterns
  - No structural anti-patterns

## 🎯 Migration Strategy

When fixing structural issues:

1. **Create backup branch**
2. **Move directories to correct locations**
3. **Update all import statements**
4. **Update hooks.py paths**
5. **Clear cache and rebuild**
6. **Run tests to verify**
7. **Update documentation**

## 📖 Additional Resources

- [Frappe App Development Guide](https://frappeframework.com/docs/user/en/tutorial)
- [Frappe Best Practices](https://frappeframework.com/docs/user/en/guides)
- [Module Structure Documentation](https://frappeframework.com/docs/user/en/basics/architecture)

---

This reference document is used by Eva Thorne (app-structure-validator) to ensure all Frappe apps maintain proper structure and avoid common anti-patterns that lead to import violations and maintenance issues.