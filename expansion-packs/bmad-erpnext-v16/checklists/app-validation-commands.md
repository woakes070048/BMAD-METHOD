# App Validation Commands for AI Assistant

## Purpose
Shell commands that the AI assistant can actually run to validate ERPNext apps

## Quick Validation Commands

### 1. Check App Structure
```bash
# Check if app exists and has proper structure
ls -la apps/[APP_NAME]/
ls -la apps/[APP_NAME]/[APP_NAME]/

# Check core files exist
test -f apps/[APP_NAME]/setup.py && echo "✓ setup.py exists" || echo "✗ setup.py missing"
test -f apps/[APP_NAME]/[APP_NAME]/hooks.py && echo "✓ hooks.py exists" || echo "✗ hooks.py missing"
test -f apps/[APP_NAME]/[APP_NAME]/modules.txt && echo "✓ modules.txt exists" || echo "✗ modules.txt missing"

# List all modules
cat apps/[APP_NAME]/[APP_NAME]/modules.txt
```

### 2. Find All DocTypes
```bash
# List all DocTypes in the app
find apps/[APP_NAME] -type d -name "doctype" -exec ls {} \; | sort -u

# Check if DocType has required files
DOCTYPE_NAME="[DOCTYPE_NAME]"
ls -la apps/[APP_NAME]/[APP_NAME]/*/doctype/$DOCTYPE_NAME/

# Check if it's a child table (look for istable in JSON)
grep -l '"istable": 1' apps/[APP_NAME]/[APP_NAME]/*/doctype/*/[DOCTYPE_NAME].json
```

### 3. Find All Reports
```bash
# List all reports
find apps/[APP_NAME] -type d -name "report" -exec ls {} \; | sort -u

# Check report structure
REPORT_NAME="[REPORT_NAME]"
ls -la apps/[APP_NAME]/[APP_NAME]/*/report/$REPORT_NAME/

# Check if report has query or script
find apps/[APP_NAME] -name "$REPORT_NAME.py" -o -name "$REPORT_NAME.js" -o -name "$REPORT_NAME.sql"
```

### 4. Find All Pages
```bash
# List all pages
find apps/[APP_NAME] -type d -name "page" -exec ls {} \; | sort -u

# Check page structure
PAGE_NAME="[PAGE_NAME]"
ls -la apps/[APP_NAME]/[APP_NAME]/*/page/$PAGE_NAME/

# Check for Vue bundles
ls -la apps/[APP_NAME]/[APP_NAME]/public/js/*.bundle.js 2>/dev/null

# Check if Vue page uses SetVueGlobals
grep -l "SetVueGlobals" apps/[APP_NAME]/[APP_NAME]/public/js/*.bundle.js
```

### 5. Validate Workspaces
```bash
# Find all workspaces
find apps/[APP_NAME] -path "*/workspace/*/*.json" -type f

# Check workspace for invalid icons (should NOT have fa- or icon-)
grep -h '"icon":' apps/[APP_NAME]/[APP_NAME]/*/workspace/*/*.json | grep -E '(fa-|icon-)' && echo "✗ Invalid FontAwesome icons found!" || echo "✓ Icons valid"

# Find child tables incorrectly linked in workspaces
# First, find all child tables
CHILD_TABLES=$(grep -l '"istable": 1' apps/[APP_NAME]/[APP_NAME]/*/doctype/*/*.json | xargs -I {} basename {} .json)

# Then check if any are in workspace
for TABLE in $CHILD_TABLES; do
  grep -l "\"$TABLE\"" apps/[APP_NAME]/[APP_NAME]/*/workspace/*/*.json && echo "✗ Child table $TABLE in workspace!"
done
```

### 6. Check APIs
```bash
# Find API files
find apps/[APP_NAME]/[APP_NAME]/api -name "*.py" 2>/dev/null

# Check for whitelisted functions
grep -r "@frappe.whitelist" apps/[APP_NAME]/[APP_NAME]/api/

# Check for permission checks in APIs
grep -r "frappe.has_permission" apps/[APP_NAME]/[APP_NAME]/api/

# Check for error handling
grep -r "frappe.throw" apps/[APP_NAME]/[APP_NAME]/api/
```

### 7. Quick Component Count
```bash
# Count all components
echo "=== Component Count ==="
echo "DocTypes: $(find apps/[APP_NAME] -type d -name "doctype" -exec ls {} \; | wc -l)"
echo "Reports: $(find apps/[APP_NAME] -type d -name "report" -exec ls {} \; | wc -l)"
echo "Pages: $(find apps/[APP_NAME] -type d -name "page" -exec ls {} \; | wc -l)"
echo "Workspaces: $(find apps/[APP_NAME] -path "*/workspace/*/*.json" | wc -l)"
echo "API Files: $(find apps/[APP_NAME]/[APP_NAME]/api -name "*.py" 2>/dev/null | wc -l)"
echo "Vue Bundles: $(ls apps/[APP_NAME]/[APP_NAME]/public/js/*.bundle.js 2>/dev/null | wc -l)"
```

## Complete Validation Script (Shell)
```bash
#!/bin/bash
# Run this complete check
APP_NAME="$1"

if [ -z "$APP_NAME" ]; then
    echo "Usage: $0 <app_name>"
    exit 1
fi

echo "========================================="
echo "Validating App: $APP_NAME"
echo "========================================="

# Check structure
echo -e "\n📁 STRUCTURE CHECK:"
test -f apps/$APP_NAME/setup.py && echo "✓ setup.py" || echo "✗ setup.py"
test -f apps/$APP_NAME/pyproject.toml && echo "✓ pyproject.toml" || echo "✗ pyproject.toml"
test -f apps/$APP_NAME/$APP_NAME/hooks.py && echo "✓ hooks.py" || echo "✗ hooks.py"
test -f apps/$APP_NAME/$APP_NAME/modules.txt && echo "✓ modules.txt" || echo "✗ modules.txt"
test -d apps/$APP_NAME/$APP_NAME/api && echo "✓ api/" || echo "✗ api/"
test -d apps/$APP_NAME/$APP_NAME/public && echo "✓ public/" || echo "✗ public/"

# Count components
echo -e "\n📊 COMPONENTS:"
echo "DocTypes: $(find apps/$APP_NAME -type d -name doctype -exec ls {} \; 2>/dev/null | wc -l)"
echo "Reports: $(find apps/$APP_NAME -type d -name report -exec ls {} \; 2>/dev/null | wc -l)"
echo "Pages: $(find apps/$APP_NAME -type d -name page -exec ls {} \; 2>/dev/null | wc -l)"
echo "Workspaces: $(find apps/$APP_NAME -path "*/workspace/*/*.json" 2>/dev/null | wc -l)"

# Check for common issues
echo -e "\n⚠️  CHECKING FOR ISSUES:"

# Invalid icons
if grep -h '"icon":' apps/$APP_NAME/$APP_NAME/*/workspace/*/*.json 2>/dev/null | grep -qE '(fa-|icon-)'; then
    echo "✗ Invalid FontAwesome icons in workspace!"
else
    echo "✓ Workspace icons valid"
fi

# Child tables in workspace
CHILD_COUNT=$(grep -l '"istable": 1' apps/$APP_NAME/$APP_NAME/*/doctype/*/*.json 2>/dev/null | wc -l)
if [ "$CHILD_COUNT" -gt 0 ]; then
    echo "⚠ Found $CHILD_COUNT child tables - checking workspace links..."
fi

# API security
API_COUNT=$(find apps/$APP_NAME/$APP_NAME/api -name "*.py" 2>/dev/null | wc -l)
if [ "$API_COUNT" -gt 0 ]; then
    WHITELIST_COUNT=$(grep -r "@frappe.whitelist" apps/$APP_NAME/$APP_NAME/api/ 2>/dev/null | wc -l)
    echo "✓ Found $WHITELIST_COUNT whitelisted API functions"
fi

echo -e "\n========================================="
echo "Validation Complete!"
echo "========================================="
```

## AI Assistant Usage Pattern

When validating an app, the AI should:

1. **Run the structure check first:**
```bash
ls -la apps/[APP_NAME]/
test -f apps/[APP_NAME]/setup.py && echo "exists" || echo "missing"
```

2. **Count components:**
```bash
find apps/[APP_NAME] -type d -name doctype -exec ls {} \; | wc -l
```

3. **Check for critical issues:**
```bash
# Check for child tables in workspaces
grep -l '"istable": 1' apps/[APP_NAME]/[APP_NAME]/*/doctype/*/*.json
```

4. **Validate workspace icons:**
```bash
grep '"icon":' apps/[APP_NAME]/[APP_NAME]/*/workspace/*/*.json
```

5. **Report findings** in a structured format

## Quick One-Liner Checks

```bash
# Is this app complete?
[ -f apps/[APP]/setup.py ] && [ -f apps/[APP]/[APP]/hooks.py ] && echo "✓ Basic structure OK" || echo "✗ Missing files"

# Any workspaces defined?
ls apps/[APP]/[APP]/*/workspace/*/*.json 2>/dev/null || echo "No workspaces found"

# Any DocTypes?
ls apps/[APP]/[APP]/*/doctype/ 2>/dev/null || echo "No DocTypes found"

# Frontend components?
ls apps/[APP]/[APP]/public/js/*.bundle.js 2>/dev/null || echo "No Vue bundles"
```