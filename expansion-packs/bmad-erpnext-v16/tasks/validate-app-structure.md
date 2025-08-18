# Task: Validate App Structure

**Objective**: Implement comprehensive app structure validation to prevent DocFlow/Server Manager structural issues  
**Agent**: Eva Thorne (App Structure Validator)  
**Priority**: Critical - Must be used for all new apps  
**Estimated Time**: 30-60 minutes per app  

---

## Quick Start Guide

### 1. Before Creating Any New App (5 minutes)
```bash
# Activate Eva Thorne for structure planning
/bmadErpNext:agent:app-structure-validator

# Use this prompt:
"I need to create a new Frappe app called '[app_name]' with these requirements: [describe features]. Please analyze the Frappe CRM structure and create a compliant structure template."
```

### 2. During Development (Daily Check - 2 minutes)
```bash
# Quick structure audit
/bmadErpNext:agent:app-structure-validator

# Use this prompt:
"Please audit the structure of my app at [app_path] and report any compliance violations."
```

### 3. Before Deployment (15 minutes)
```bash
# Comprehensive validation
/bmadErpNext:agent:app-structure-validator

# Use this prompt:
"Perform a comprehensive structure audit of [app_name] and provide a compliance score with detailed recommendations."
```

---

## Complete Validation Workflow

### Phase 1: Pre-Development Structure Planning

#### Step 1: Study Reference Structure (10 minutes)
```bash
# Study the Frappe CRM structure (GOLD STANDARD)
tree /home/frappe/crm/crm -I '__pycache__' -I '.git' -L 3

# Analyze import patterns
grep -r "from crm\." /home/frappe/crm/crm --include="*.py" | head -10
```

**Expected Output**: Clean structure with:
- `api/`, `config/`, `public/`, etc. at module root
- `fcrm/` business module with ONLY `doctype/` and `workspace/`

#### Step 2: Create Structure Template (10 minutes)
```bash
# Activate Eva Thorne
/bmadErpNext:agent:app-structure-validator

# Detailed planning prompt:
"I'm creating a Frappe app called '[app_name]' with these modules: [list modules]. Based on the Frappe CRM structure at /home/frappe/crm/crm, please:

1. Create a compliant directory structure template
2. Define correct import patterns
3. Plan hooks.py configuration  
4. Validate against Frappe standards
5. Provide compliance score"
```

#### Step 3: Validate Template (5 minutes)
```bash
# Template validation prompt:
"Please validate this structure template against Frappe standards and the reference CRM app: [paste template]"
```

**Success Criteria**: 
- Compliance score ≥ 95%
- No forbidden patterns identified
- Import paths follow standards

### Phase 2: Development Validation

#### Daily Structure Monitoring (2 minutes/day)
```bash
# Quick compliance check
/bmadErpNext:agent:app-structure-validator

"Quick audit: Check the structure of [app_name] at [path] for any new violations."
```

#### Import Pattern Validation (5 minutes/change)
```bash
# After adding new imports
grep -r "from [app_name]\." /path/to/app --include="*.py" | grep -E "(\.api\.|\.services\.|\.utils\.)"

# Check for violations - should NOT see:
# from [app_name].[business_module].api.*
# from [app_name].[business_module].services.*
# from [app_name].[business_module].utils.*
```

#### Hook Configuration Review (3 minutes/hook)
```bash
# Review hooks.py whenever modified
cat /path/to/app/hooks.py

# Verify all paths reference module root, not business module
```

### Phase 3: Pre-Deployment Validation

#### Comprehensive Structure Audit (15 minutes)
```bash
# Full Eva Thorne analysis
/bmadErpNext:agent:app-structure-validator

"Perform a comprehensive final audit of [app_name] before deployment. Provide:
1. Complete compliance score
2. Directory structure analysis  
3. Import pattern validation
4. Hooks configuration review
5. Final certification or rejection"
```

#### Import Resolution Testing (10 minutes)
```bash
# Test all imports resolve correctly
cd /home/frappe/frappe-bench
bench --site [site] console
```

```python
# Test critical imports - all should work without errors
from [app_name].api.[module] import [function]
from [app_name].services.[module] import [class]
from [app_name].utils.[module] import [utility]
from [app_name].[business_module].doctype.[doctype].[doctype] import [DocType]

print("All imports successful - structure is compliant!")
```

#### Functional Validation (10 minutes)
```bash
# Ensure app functions properly with clean structure
bench --site [site] migrate
bench restart

# Test key functionality
# - DocType CRUD operations
# - API endpoints
# - Scheduled tasks
# - Custom hooks
```

---

## Validation Rules Reference

### ✅ CORRECT Structure Pattern
```
[app_name]/
├── [app_name]/                 # Module Root
│   ├── hooks.py               # ✅ REQUIRED
│   ├── modules.txt            # ✅ REQUIRED
│   ├── __init__.py            # ✅ REQUIRED
│   ├── api/                   # ✅ Module root level
│   ├── services/              # ✅ Module root level  
│   ├── utils/                 # ✅ Module root level
│   ├── config/                # ✅ Module root level
│   ├── public/                # ✅ Module root level
│   └── [business_module]/     # Business Module (MINIMAL)
│       ├── doctype/           # ✅ ONLY DocTypes
│       └── workspace/         # ✅ ONLY Workspaces
```

### ❌ FORBIDDEN Anti-Patterns
```
[app_name]/
├── [app_name]/                 # Module Root
│   └── [business_module]/     # Business Module
│       ├── api/               # ❌ WRONG - Should be at module root
│       ├── services/          # ❌ WRONG - Should be at module root
│       ├── utils/             # ❌ WRONG - Should be at module root
│       ├── public/            # ❌ WRONG - Duplicate directory
│       ├── config/            # ❌ WRONG - Duplicate directory
│       ├── doctype/           # ✅ Correct location
│       └── workspace/         # ✅ Correct location
```

---

## Automation Scripts

### Quick Validation Script
```bash
#!/bin/bash
# save as: validate-structure.sh

APP_PATH=$1
if [ -z "$APP_PATH" ]; then
    echo "Usage: ./validate-structure.sh /path/to/app"
    exit 1
fi

echo "🔍 Checking app structure at: $APP_PATH"

# Check for forbidden patterns
echo "❌ Checking for forbidden business module directories..."
if [ -d "$APP_PATH/*/api" ] || [ -d "$APP_PATH/*/services" ] || [ -d "$APP_PATH/*/utils" ]; then
    echo "FAIL: Business logic found in business module!"
    exit 1
fi

# Check required files
echo "✅ Checking required files..."
if [ ! -f "$APP_PATH/hooks.py" ] || [ ! -f "$APP_PATH/modules.txt" ]; then
    echo "FAIL: Missing required files!"
    exit 1
fi

echo "✅ Basic structure validation passed!"
```

### Import Pattern Check
```bash
#!/bin/bash
# save as: check-imports.sh

APP_NAME=$1
APP_PATH=$2

echo "🔍 Checking import patterns for: $APP_NAME"

# Look for forbidden import patterns
VIOLATIONS=$(grep -r "from $APP_NAME\.[^.]*\.\(api\|services\|utils\)\." "$APP_PATH" --include="*.py" || true)

if [ ! -z "$VIOLATIONS" ]; then
    echo "❌ IMPORT VIOLATIONS FOUND:"
    echo "$VIOLATIONS"
    echo ""
    echo "FIX: Move api/, services/, utils/ to module root level"
    exit 1
else
    echo "✅ Import patterns are compliant!"
fi
```

---

## Emergency Response

### Critical Failure (Compliance < 50%)
```bash
# STOP development immediately
git add -A
git commit -m "EMERGENCY: Structure violations detected - stopping development"
git checkout -b structure-emergency-backup

# Activate Eva Thorne for emergency analysis
/bmadErpNext:agent:app-structure-validator

"EMERGENCY: My app has critical structure violations. Please analyze [app_path] and provide a step-by-step migration plan to fix the structure like the DocFlow retrospective example."
```

### Moderate Violations (50-84% compliance)
```bash
# Create backup and continue with fixes
git checkout -b structure-fixes

# Get specific recommendations
/bmadErpNext:agent:app-structure-validator

"My app has moderate structure violations. Please provide specific steps to improve compliance from [current_score]% to >85%."
```

---

## Success Metrics

### Compliance Scoring
- **95-100%**: ✅ Production ready
- **85-94%**: ⚠️ Minor fixes needed  
- **70-84%**: 🔄 Restructure required
- **<70%**: ❌ STOP development

### Validation Frequency
- **Pre-development**: Structure template validation
- **Daily**: Quick compliance checks during development
- **Pre-commit**: Import pattern validation
- **Pre-deployment**: Comprehensive audit

### Quality Gates
- [ ] Eva Thorne compliance score ≥ 85%
- [ ] All imports resolve correctly
- [ ] No forbidden directory patterns
- [ ] Hooks reference correct paths
- [ ] Functional testing passes

---

## Tools & Resources

### Primary Tools
- **Eva Thorne Agent**: `/bmadErpNext:agent:app-structure-validator`
- **Reference App**: `/home/frappe/crm/crm`
- **Compliance Checklist**: `../checklists/app-structure-compliance-checklist.md`

### Documentation
- **DocFlow Retrospective**: `/home/frappe/bmad-erpnext-development/docs/DOCFLOW_STRUCTURE_RETROSPECTIVE.md`
- **CLAUDE.md Guidelines**: Framework development patterns
- **Frappe Documentation**: Official framework standards

### Validation Commands
```bash
# Structure analysis
tree [app_path] -I '__pycache__' -I '.git'

# Import pattern check  
grep -r "from [app_name]\." [app_path] --include="*.py"

# Hook validation
cat [app_path]/hooks.py
```

---

**Remember**: Structure validation is not optional. Every skipped validation increases the risk of creating another DocFlow/Server Manager situation. Use Eva Thorne liberally - she exists to prevent these issues!

**Goal**: Zero apps deployed with compliance scores below 85%.
