# App Validation Principles for ERPNext Development

## Core Principle
The AI should inherently understand and validate ERPNext apps based on Frappe framework principles, not through external scripts.

## What Makes a Valid ERPNext App

### 1. Structural Integrity
An ERPNext app MUST have:
- **hooks.py** - Defines app metadata and integration points
- **modules.txt** - Lists all modules in the app
- **Module directories** - Each with proper subdirectories (doctype/, report/, page/, workspace/)
- **DocType structure** - JSON definition + Python controller
- **NO utils/ or scripts/** - Business logic belongs in DocTypes, APIs, or controllers

### 2. DocType Principles

#### Parent DocTypes
- Standalone documents
- Can be linked in workspaces
- Have their own permissions
- Examples: Customer, Sales Order, Item

#### Child DocTypes (Tables)
- **NEVER** appear in workspaces
- **NEVER** have direct routes
- Only exist within parent DocTypes
- Identified by `"istable": 1` in JSON
- Examples: Sales Order Item, Payment Entry Reference

### 3. Workspace Principles

#### Valid Links
- Only link to parent DocTypes
- Only link to existing Reports
- Only link to created Pages
- Use Frappe's built-in icons

#### Invalid Practices
- ❌ Linking child tables
- ❌ Using FontAwesome icons (fa-, icon-)
- ❌ Linking non-existent components
- ❌ Creating workspaces without proper module structure

### 4. Report Principles

#### Query Reports
- SQL-based
- Defined in JSON
- Fast execution
- Simple filters

#### Script Reports
- Python or JavaScript logic
- Complex calculations
- Dynamic columns
- Advanced filtering

### 5. Page Principles

#### Standard Pages
- Simple JavaScript
- Frappe page system
- Basic routing

#### Vue Pages (Native)
- Bundle.js entry point
- SetVueGlobals integration
- NO /frontend/ directory
- Components in public/js/

### 6. API Principles

#### Security Requirements
- `@frappe.whitelist()` decorator
- `frappe.has_permission()` checks
- Input validation
- Error handling with `frappe.throw()`

#### Structure
- APIs in `[app]/api/` directory
- Or in DocType controllers
- Follow REST patterns where applicable

## How AI Should Validate

### When Creating Components
The AI should automatically:
1. Ensure DocTypes follow parent/child patterns correctly
2. Never suggest child tables for workspace links
3. Only use valid Frappe icons
4. Create proper file structures
5. Include security decorators

### When Reviewing Apps
The AI should check:
1. **Read hooks.py** - Understand app configuration
2. **Read modules.txt** - Know all modules
3. **Check each module** - Verify standard structure
4. **Read DocType JSONs** - Identify child tables
5. **Read workspace JSONs** - Validate all links and icons
6. **Verify relationships** - Ensure proper parent/child usage

### Red Flags to Always Catch

#### Critical Issues
- Child table in workspace link → **ALWAYS WRONG**
- FontAwesome icon in workspace → **ALWAYS WRONG**
- Missing @frappe.whitelist() → **SECURITY RISK**
- No permission checks → **SECURITY RISK**
- /frontend/ directory → **OUTDATED PATTERN**

#### Structural Issues
- DocType without controller (.py)
- Script Report without script file
- Page without JavaScript
- Workspace without valid module
- API without error handling

## Validation Questions AI Should Ask

When reviewing an app, consider:

1. **Does every DocType have a purpose?**
   - Masters: Reference data
   - Transactions: Business processes
   - Settings: Configuration
   - Child Tables: Line items

2. **Are components properly connected?**
   - Workspace → DocTypes/Reports/Pages
   - Reports → Source DocTypes
   - Pages → API endpoints
   - Child Tables → Parent DocTypes

3. **Is security implemented?**
   - APIs whitelisted
   - Permissions configured
   - Input validated
   - Errors handled

4. **Does it follow Frappe patterns?**
   - Naming conventions
   - File structure
   - Hook configuration
   - Module organization

## The Right Way to Build

### Start with Business Logic
1. Define DocTypes based on business needs
2. Identify parent/child relationships
3. Create workflows and validations
4. Build reports for insights
5. Design workspace for navigation

### Follow Framework Patterns
- Use Frappe's built-in utilities
- Follow established naming conventions
- Leverage framework features (permissions, workflows, etc.)
- Don't reinvent what Frappe provides

### Maintain Consistency
- Similar patterns across modules
- Consistent naming schemes
- Standard file organization
- Predictable component locations

## What Success Looks Like

A well-structured ERPNext app has:
- ✅ Clear module organization
- ✅ Proper parent/child DocType relationships  
- ✅ Workspace with valid navigation
- ✅ Reports that provide business value
- ✅ Secure API endpoints
- ✅ Native Vue integration (if needed)
- ✅ NO child tables in workspaces
- ✅ NO invalid icons
- ✅ NO /frontend/ directory
- ✅ NO external scripts or utils

## Remember

The AI should treat these validation principles as inherent knowledge, not external checks. When building or reviewing ERPNext apps, these principles should guide every decision and recommendation.

The expansion pack provides templates, agents, and tasks that embody these principles. Use them as the foundation for creating valid, well-structured ERPNext applications.