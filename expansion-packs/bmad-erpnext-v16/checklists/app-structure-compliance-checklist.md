# Frappe App Structure Compliance Checklist

**Purpose**: Prevent structural issues like those encountered with DocFlow and Server Manager apps  
**Based on**: DocFlow Structure Retrospective Analysis  
**Reference Standard**: Frappe CRM structure at `/home/frappe/crm/crm`  
**Agent**: Eva Thorne (App Structure Validator)  

---

## 🚨 CRITICAL PRE-DEVELOPMENT CHECKLIST

### 1. Reference Analysis (MANDATORY)
- [ ] **Analyze Frappe CRM Structure**: Study `/home/frappe/crm/crm` structure
- [ ] **Review ERPNext Patterns**: Examine ERPNext module organization
- [ ] **Document Reference Pattern**: Create structure template based on reference apps
- [ ] **Validate Template**: Ensure template follows all Frappe conventions

### 2. Structure Planning (BEFORE CODING)
- [ ] **Plan Directory Layout**: Design complete app structure
- [ ] **Validate Business Module**: Ensure business module contains ONLY doctype/ and workspace/
- [ ] **Check Import Patterns**: Plan import paths to follow Frappe standards
- [ ] **Review with Eva Thorne**: Use `/bmadErpNext:agent:app-structure-validator`

---

## 📁 DIRECTORY STRUCTURE COMPLIANCE

### Module Root Level (✅ REQUIRED LOCATIONS)
```
[app_name]/[app_name]/              # Module Root
├── hooks.py                        # ✅ REQUIRED
├── modules.txt                     # ✅ REQUIRED  
├── __init__.py                     # ✅ REQUIRED
├── api/                            # ✅ Module root level
├── config/                         # ✅ Module root level
├── public/                         # ✅ Module root level
├── patches/                        # ✅ Module root level
├── utils/                          # ✅ Module root level (if needed)
├── services/                       # ✅ Module root level (if needed)
├── integrations/                   # ✅ Module root level (if needed)
├── overrides/                      # ✅ Module root level (if needed)
├── templates/                      # ✅ Module root level (if needed)
├── www/                            # ✅ Module root level (if needed)
└── [business_module]/              # Business Module (MINIMAL)
```

#### Validation Checklist:
- [ ] **hooks.py exists** at module root
- [ ] **modules.txt exists** at module root
- [ ] **__init__.py exists** at module root
- [ ] **All API code** is in `/api/` at module root
- [ ] **All utilities** are in `/utils/` at module root
- [ ] **All services** are in `/services/` at module root
- [ ] **Public assets** are in `/public/` at module root only
- [ ] **Configuration** is in `/config/` at module root only

### Business Module Level (⚠️ RESTRICTED CONTENT)
```
[business_module]/                  # Minimal Business Module
├── doctype/                        # ✅ ONLY DocTypes allowed
└── workspace/                      # ✅ ONLY Workspace configs allowed
```

#### Validation Checklist:
- [ ] **ONLY doctype/ directory** for DocType definitions
- [ ] **ONLY workspace/ directory** for workspace configurations
- [ ] **NO api/ directory** in business module
- [ ] **NO services/ directory** in business module
- [ ] **NO utils/ directory** in business module
- [ ] **NO public/ directory** in business module
- [ ] **NO config/ directory** in business module
- [ ] **NO duplicate directories** from module root

### ❌ FORBIDDEN PATTERNS (Auto-Fail)
- [ ] **NO business logic in business module** (api/, services/, utils/, etc.)
- [ ] **NO duplicate public/ directories**
- [ ] **NO duplicate config/ directories**
- [ ] **NO duplicate fixtures/ directories**
- [ ] **NO nested [app_name]/[app_name]/[app_name]/ structure**

---

## 📦 IMPORT PATTERN COMPLIANCE

### ✅ CORRECT Import Patterns
```python
# Module root imports (CORRECT)
from [app_name].api.workflow_api import get_execution_status
from [app_name].services.execution_service import ExecutionService  
from [app_name].utils.workflow_engine import WorkflowEngine

# DocType imports (CORRECT)
from [app_name].[business_module].doctype.[doctype_name].[doctype_name] import DocTypeName
```

### ❌ INCORRECT Import Patterns (DocFlow Anti-Pattern)
```python
# Business module imports (WRONG - caused DocFlow issues)
from [app_name].[business_module].api.workflow_api import get_execution_status      # ❌
from [app_name].[business_module].services.execution_service import ExecutionService # ❌
from [app_name].[business_module].utils.workflow_engine import WorkflowEngine        # ❌
```

---

## 🎯 COMPLIANCE SCORING

### Scoring Criteria
- **Structure Organization** (40 points)
- **Import Patterns** (30 points)  
- **Hooks Configuration** (20 points)
- **Framework Standards** (10 points)

### Compliance Levels
- **95-100%**: ✅ **EXCELLENT** - Full compliance, ready for production
- **85-94%**: ⚠️ **GOOD** - Minor issues, address before deployment
- **70-84%**: 🔄 **NEEDS WORK** - Moderate violations, restructure required
- **Below 70%**: ❌ **CRITICAL** - Major violations, comprehensive restructure needed

---

**Remember**: Structure compliance is not optional. Every violation increases technical debt and makes the app harder to maintain.

**Success Metric**: Zero apps deployed with compliance score below 85%.
