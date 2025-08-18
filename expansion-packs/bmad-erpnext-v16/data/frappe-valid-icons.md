# Frappe Valid Icons Reference

## CRITICAL: Icon Usage Rules

### ✅ DO Use
- **Frappe's built-in icons** - These are SVG icons included in the framework
- **Icons from the validated list below** - Confirmed to work in workspaces
- **Exact icon names** - Case-sensitive, exact spelling required

### ❌ DON'T Use
- **FontAwesome icons** - Not supported in workspace definitions
- **Custom SVG files** - Unless properly registered in Frappe
- **Icon class names** - Use icon identifier strings only

## Validated Frappe Icons

### Core System Icons
- `dashboard` - Dashboard/overview screens
- `organization` - Company/organizational structure
- `users` - User management
- `setting` - Settings/configuration
- `tool` - Tools and utilities
- `integration` - Third-party integrations
- `project` - Project management
- `website` - Website/portal management
- `hammer` - Build/development tools
- `image-view` - Image/media viewing

### Business Process Icons
- `sell` - Sales and selling processes
- `buying` - Purchase and procurement
- `stock` - Inventory and stock management
- `accounting` - Finance and accounting
- `crm` - Customer relationship management
- `support` - Customer support/helpdesk
- `quality` - Quality management
- `assets` - Asset management
- `hr` - Human resources
- `education` - Education/training
- `healthcare` - Healthcare management
- `agriculture` - Agriculture/farming
- `non-profit` - Non-profit organizations

### Navigation Icons
- `home` - Home/main page
- `file` - Files and documents
- `folder-open` - Open folders/directories
- `list` - List views
- `calendar` - Calendar/scheduling
- `graph` - Charts and analytics
- `arrow-left` - Navigate back
- `arrow-right` - Navigate forward

### Action Icons
- `add` - Add/create new
- `edit` - Edit/modify
- `delete` - Delete/remove
- `filter` - Filter/search
- `upload` - Upload files
- `download` - Download files
- `refresh` - Refresh/reload
- `print` - Print documents
- `settings-gear` - Settings/preferences
- `search` - Search functionality

## Icon Usage in Workspaces

### In Workspace JSON
```json
{
  "icon": "dashboard",  // Use exact string from list above
  "doctype": "Workspace",
  ...
}
```

### In Shortcuts
```json
"shortcuts": [
  {
    "color": "Blue",
    "doc_view": "New",
    "label": "New Item",
    "link_to": "Item",
    "type": "DocType"
    // Note: Shortcuts inherit workspace icon
  }
]
```

## Icon Selection Guidelines

### By Module Type

#### Sales Modules
- Primary: `sell`
- Alternatives: `crm`, `graph`

#### Purchase Modules
- Primary: `buying`
- Alternatives: `organization`

#### Inventory Modules
- Primary: `stock`
- Alternatives: `assets`

#### Financial Modules
- Primary: `accounting`
- Alternatives: `graph`, `dashboard`

#### HR Modules
- Primary: `hr`
- Alternatives: `users`, `organization`

#### Project Modules
- Primary: `project`
- Alternatives: `tool`, `dashboard`

#### Settings/Configuration
- Primary: `setting`
- Alternatives: `tool`, `settings-gear`

#### Analytics/Reports
- Primary: `graph`
- Alternatives: `dashboard`

## Common Icon Mistakes

### ❌ Wrong
```json
"icon": "fa fa-dashboard"     // FontAwesome syntax
"icon": "icon-dashboard"       // Class name syntax
"icon": "Dashboard"           // Capitalized
"icon": "chart"              // Use 'graph' instead
"icon": "cog"                // Use 'setting' instead
```

### ✅ Correct
```json
"icon": "dashboard"
"icon": "graph"
"icon": "setting"
```

## Finding Additional Icons

To discover more valid icons:

1. Check existing ERPNext workspaces:
```bash
grep -r "\"icon\":" apps/erpnext --include="*.json" | grep workspace
```

2. Look in Frappe's public folder:
```bash
find apps/frappe/frappe/public -name "*.svg"
```

3. Check Otto or other Frappe apps for examples

## Icon Validation

Before using an icon, validate it:

1. **Check exact spelling** - Icons are case-sensitive
2. **Test in development** - Create a test workspace
3. **Verify rendering** - Ensure icon appears correctly
4. **Check console** - No 404 errors for icon resources

## Notes

- Icons are loaded from Frappe's built-in SVG sprite sheets
- Custom icons require proper registration in the app
- Workspace icons affect the sidebar appearance
- Some icons may be available but not commonly used
- Always prefer semantic icons that match the module purpose