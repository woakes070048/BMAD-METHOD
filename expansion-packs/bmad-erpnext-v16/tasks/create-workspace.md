# Task: Create ERPNext Workspace

## Purpose
Create a properly structured workspace for ERPNext with valid navigation, cards, shortcuts, and reports

## Prerequisites
- ERPNext app structure created
- Module defined in the app
- DocTypes, Reports, and Pages created for linking
- Understanding of workspace hierarchy

## Input Requirements
```yaml
app_name: String         # App name (e.g., 'erpnext', 'custom_app')
workspace_name: String   # Internal name (snake_case)
workspace_label: String  # Display label (Title Case)
workspace_icon: String   # Valid Frappe icon name
module_name: String      # Module this workspace belongs to
is_public: Boolean       # Public (true) or private workspace
roles: Array            # List of roles with access
```

## Step-by-Step Implementation

### 1. Create Workspace Directory Structure
```bash
# Navigate to your app
cd apps/{{app_name}}

# Create workspace directory
mkdir -p {{app_name}}/{{module_name}}/workspace/{{workspace_name}}
```

### 2. Identify Valid Icons
Use one of these valid Frappe/ERPNext icons:

#### Core Icons (Most Common)
- `dashboard` - Dashboard/Overview
- `organization` - Company/Organization
- `users` - User Management
- `setting` - Settings/Configuration
- `tool` - Tools/Utilities
- `integration` - Integrations
- `project` - Projects
- `website` - Website Management

#### Business Icons
- `sell` - Sales/Selling
- `buying` - Purchase/Buying
- `stock` - Inventory/Stock
- `accounting` - Accounts/Finance
- `crm` - CRM/Customer Relations
- `support` - Help/Support
- `quality` - Quality Management
- `assets` - Asset Management

#### Navigation Icons
- `home` - Home/Main
- `file` - Documents/Files
- `folder-open` - Folders
- `list` - Lists
- `calendar` - Calendar/Schedule
- `graph` - Analytics/Charts

#### Action Icons
- `add` - Add/Create
- `edit` - Edit/Modify
- `delete` - Delete/Remove
- `filter` - Filter/Search
- `upload` - Upload
- `download` - Download
- `refresh` - Refresh/Reload
- `print` - Print

### 3. Create Workspace JSON File

Create `{{workspace_name}}.json` with this structure:

```json
{
  "app": "{{app_name}}",
  "category": "Modules",
  "charts": [],
  "content": "[CONTENT_ARRAY]",
  "creation": "2024-01-01 00:00:00.000000",
  "custom_blocks": [],
  "docstatus": 0,
  "doctype": "Workspace",
  "for_user": "",
  "hide_custom": 0,
  "icon": "{{workspace_icon}}",
  "idx": 0,
  "is_hidden": 0,
  "label": "{{workspace_label}}",
  "links": [
    // Card definitions with links
  ],
  "modified": "2024-01-01 00:00:00.000000",
  "modified_by": "Administrator",
  "module": "{{module_name}}",
  "name": "{{workspace_label}}",
  "number_cards": [],
  "owner": "Administrator",
  "parent_page": "",
  "public": 1,
  "quick_lists": [],
  "roles": [],
  "sequence_id": 1.0,
  "shortcuts": [],
  "title": "{{workspace_label}}"
}
```

### 4. Define Content Layout

The `content` field is a stringified JSON array defining the workspace layout:

```javascript
[
  // Header
  {
    "id": "header_1",
    "type": "header",
    "data": {
      "text": "<span class=\"h4\"><b>Quick Access</b></span>",
      "col": 12
    }
  },
  // Shortcuts (4 columns each)
  {
    "id": "shortcut_1",
    "type": "shortcut",
    "data": {
      "shortcut_name": "New Item",
      "col": 3
    }
  },
  // Spacer
  {
    "id": "spacer_1",
    "type": "spacer",
    "data": {
      "col": 12
    }
  },
  // Cards (3-4 columns each)
  {
    "id": "card_1",
    "type": "card",
    "data": {
      "card_name": "Transactions",
      "col": 4
    }
  }
]
```

### 5. Define Links Array

Each card needs links defined in the `links` array:

```json
"links": [
  {
    "description": "Primary transactions",
    "hidden": 0,
    "is_query_report": 0,
    "label": "Transactions",
    "link_count": 0,
    "link_type": "DocType",
    "onboard": 1,
    "type": "Card Break"
  },
  {
    "dependencies": "",
    "hidden": 0,
    "is_query_report": 0,
    "label": "Sales Order",
    "link_count": 0,
    "link_to": "Sales Order",
    "link_type": "DocType",
    "onboard": 1,
    "type": "Link"
  }
]
```

### 6. Define Shortcuts

Quick access buttons at the top of workspace:

```json
"shortcuts": [
  {
    "color": "Blue",
    "doc_view": "New",
    "label": "New Order",
    "link_to": "Sales Order",
    "type": "DocType"
  },
  {
    "color": "Green",
    "doc_view": "",
    "label": "Analytics",
    "link_to": "Sales Analytics",
    "type": "Report"
  }
]
```

### 7. Set Permissions

Define role-based access:

```json
"roles": [
  {
    "role": "System Manager"
  },
  {
    "role": "Sales User"
  },
  {
    "role": "Sales Manager"
  }
]
```

### 8. Validate Link Types

Ensure all links are valid:

#### Valid DocType Links
- Must be parent DocTypes (not child tables)
- DocType must exist in the system
- User must have read permission

#### Valid Report Links
- Query Reports: Set `is_query_report: 1`
- Script Reports: Set `is_query_report: 0`
- Report must exist and be accessible

#### Valid Page Links
- Custom pages created in the app
- Standard ERPNext pages
- Page must be accessible to user's role

### 9. Install and Test

```bash
# Migrate to install workspace
bench --site [site-name] migrate

# Clear cache
bench --site [site-name] clear-cache

# Restart bench (if in production)
bench restart
```

### 10. Troubleshooting

#### Workspace Not Appearing
- Check if module is visible in Module Def
- Verify public flag is set correctly
- Ensure user has required roles

#### Invalid Links
- Verify DocType is not a child table
- Check if Report/Page exists
- Confirm permissions are set

#### Icons Not Showing
- Use only valid Frappe icon names
- Don't use FontAwesome icons
- Check icon name spelling

## Validation Checklist

- [ ] Workspace directory created correctly
- [ ] JSON file is valid and properly formatted
- [ ] Icon is from valid Frappe icon list
- [ ] All DocType links point to parent DocTypes
- [ ] Reports exist and are accessible
- [ ] Pages are created and load properly
- [ ] Shortcuts have appropriate colors
- [ ] Cards are logically organized
- [ ] Permissions are configured
- [ ] Workspace appears after migration

## Best Practices

### Organization
1. Group related items in cards
2. Limit shortcuts to 4-6 most used items
3. Use clear, descriptive labels
4. Order by frequency of use

### Performance
1. Don't add too many charts (impacts loading)
2. Keep cards to 3-4 per row
3. Minimize number of shortcuts

### User Experience
1. Provide quick access to common tasks
2. Include both transactional and reporting links
3. Add helpful descriptions to card breaks
4. Use consistent naming conventions

## Common Patterns

### Sales Workspace
- Shortcuts: New Customer, New Order, Sales Dashboard
- Cards: Transactions, Masters, Reports, Settings

### Inventory Workspace
- Shortcuts: Stock Entry, Stock Balance, Item
- Cards: Stock Transactions, Items, Reports, Configuration

### Accounting Workspace
- Shortcuts: Payment Entry, Journal Entry, Balance Sheet
- Cards: Accounting, Banking, Reports, Setup

## Output

After successful creation:
```
{{app_name}}/
└── {{module_name}}/
    └── workspace/
        └── {{workspace_name}}/
            └── {{workspace_name}}.json
```

The workspace will be accessible at:
`/app/{{workspace_name}}`

## Next Steps

1. Customize workspace layout via drag-and-drop
2. Add user-specific customizations
3. Create role-based variations
4. Add onboarding steps for new users
5. Configure domain-specific visibility