# AI App Validation Checklist

## Purpose
A practical checklist the AI assistant can use to validate ERPNext apps by reading files and checking the expansion pack structure.

## How AI Should Validate Apps

### 1. Read and Check Core Structure
The AI should read these files to validate:

```
When validating an app, I will:
1. Read hooks.py to understand app configuration
2. Read modules.txt to list all modules
3. Check each module directory for components
4. Read workspace JSON files to validate links
5. Check DocType JSON files for parent/child relationships
```

### 2. DocType Validation Process

**Step 1: Find all DocTypes**
- Navigate to each module's doctype directory
- List all DocType folders
- Read each [doctype_name].json file

**Step 2: Identify Child Tables**
- Look for `"istable": 1` in JSON
- Mark these as child tables
- These should NEVER appear in workspace links

**Step 3: Check DocType Components**
For each DocType, verify:
- `[doctype_name].json` exists
- `[doctype_name].py` exists (controller)
- `[doctype_name].js` exists (if has UI)
- `test_[doctype_name].py` exists (tests)

### 3. Workspace Validation Process

**Step 1: Read Workspace JSON**
```json
Check for:
- "icon": Must be from valid Frappe list (NOT "fa-*" or "icon-*")
- "links": Array of link objects
```

**Step 2: Validate Each Link**
For each link in workspace:
```json
{
  "link_type": "DocType",  // If DocType...
  "link_to": "Some DocType" // Must NOT be a child table!
}
```

**Step 3: Valid Frappe Icons**
```
VALID: dashboard, sell, buying, stock, accounting, crm, support, 
       quality, assets, project, tool, integration, users, setting
       
INVALID: fa-dashboard, icon-sales, fontawesome icons
```

### 4. Report Validation Process

**For each report directory:**
1. Read `[report_name].json`
2. Check `"report_type"` field:
   - If "Query Report" → SQL-based
   - If "Script Report" → Need .py or .js file
3. Verify required files exist based on type

### 5. Page Validation Process

**For each page:**
1. Read `[page_name].json`
2. Check for `[page_name].js`
3. If Vue-based, check for:
   - `public/js/[page_name].bundle.js`
   - Bundle should contain `SetVueGlobals`

### 6. API Validation Process

**Check api/ directory:**
1. Read each .py file
2. Look for `@frappe.whitelist()` decorators
3. Check for `frappe.has_permission()` calls
4. Verify `frappe.throw()` for error handling

## AI Validation Workflow

### Phase 1: Inventory
```
I will first create an inventory:
- List all DocTypes (marking child tables)
- List all Reports
- List all Pages  
- List all Workspaces
- List all API files
```

### Phase 2: Cross-Reference
```
I will then cross-reference:
- Every workspace link → Verify target exists
- Every child table → Ensure NOT in workspace
- Every report → Check required files
- Every page → Verify route and JS
```

### Phase 3: Report Issues
```
I will report:
CRITICAL ISSUES:
- Child tables in workspaces
- Missing core files
- Invalid icons
- Broken links

WARNINGS:
- Missing tests
- No API security
- Missing documentation
```

## Validation Report Template

```markdown
# App Validation Report

## ✅ Found Components
- DocTypes: [List parent DocTypes]
- Child Tables: [List child tables - should NOT be in workspaces]
- Reports: [List reports]
- Pages: [List pages]
- Workspaces: [List workspaces]

## ❌ Critical Issues
1. Child table "[Name]" linked in workspace [Workspace Name]
2. Invalid icon "[icon-name]" in workspace (use Frappe icons)
3. DocType "[Name]" missing controller (.py file)

## ⚠️ Warnings
1. No tests found for DocType "[Name]"
2. API file lacks permission checks
3. Page "[Name]" missing Vue bundle

## 📊 Completeness Score
- Structure: X/Y complete
- DocTypes: X/Y complete
- Reports: X/Y complete
- Pages: X/Y complete
- Overall: XX%

## 🔧 Required Actions
1. Remove child tables from workspace links
2. Replace FontAwesome icons with Frappe icons
3. Add missing controllers
4. Create test files
```

## Quick Reference for AI

### What Makes an App Complete?

**Minimum Requirements:**
- ✅ hooks.py with app configuration
- ✅ At least one module in modules.txt
- ✅ At least one parent DocType
- ✅ Workspace with valid icon and links
- ✅ No child tables in workspace

**Good to Have:**
- ✅ Reports for data analysis
- ✅ Custom pages for special features
- ✅ API endpoints (whitelisted)
- ✅ Tests for critical features
- ✅ Documentation

### Common Issues to Check

1. **Child Tables in Workspace**
   - Read DocType JSON for `"istable": 1`
   - Check if that DocType appears in any workspace link
   - This is ALWAYS wrong!

2. **Invalid Icons**
   - Workspace icons must be from Frappe's set
   - Never use "fa-" prefix
   - Never use "icon-" prefix

3. **Missing Files**
   - Every DocType needs .json and .py
   - Every Script Report needs .py or .js
   - Every Page needs .json and .js

4. **Broken Links**
   - Workspace links to non-existent DocTypes
   - Reports linking to missing DocTypes
   - Pages with no routes

## How to Use This Checklist

When asked to validate an app:

1. **Start by reading the app structure**
   - Read expansion pack files
   - Understand module organization

2. **Check each component type**
   - DocTypes: Read JSON, check istable
   - Workspaces: Read JSON, validate links and icons
   - Reports: Check type and required files
   - Pages: Verify routes and bundles

3. **Cross-validate relationships**
   - No child tables in workspaces
   - All links point to valid targets
   - Icons are from valid set

4. **Generate report**
   - List what's found
   - Highlight critical issues
   - Provide specific fixes

This approach works within the AI's capabilities - reading files, understanding JSON structure, and validating relationships without needing to execute scripts.