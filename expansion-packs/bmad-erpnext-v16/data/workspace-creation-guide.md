# ERPNext Workspace Creation Guide
## Complete Reference for Modern Workspace Development

This guide incorporates lessons learned from workspace troubleshooting and provides the definitive reference for creating ERPNext workspaces.

---

## 🚨 CRITICAL: Modern vs Legacy Format

### ✅ Modern Format (Current ERPNext)
Uses a single `content` field with JSON-encoded layout string:
```json
{
  "app": "my_app",
  "type": "Workspace",
  "content": "[{\"id\":\"abc123\",\"type\":\"card\",\"data\":{...}}]",
  "roles": [],
  // ... other fields
}
```

### ❌ Legacy Format (Outdated)
Uses separate arrays for links, shortcuts, cards:
```json
{
  "links": [...],
  "shortcuts": [...],
  "number_cards": [...],
  // This format may cause issues in current versions
}
```

**ALWAYS USE MODERN FORMAT FOR NEW WORKSPACES**

---

## 📋 Required Fields Checklist

### Mandatory Fields (Modern Format)
- [ ] `app` - The app this workspace belongs to
- [ ] `type` - Must be "Workspace"
- [ ] `content` - JSON string containing layout
- [ ] `name` - Workspace identifier
- [ ] `label` - Display name
- [ ] `module` - Module assignment

### Important Fields
- [ ] `roles` - Empty array `[]` for public workspaces
- [ ] `icon` - Valid Frappe icon (NOT FontAwesome)
- [ ] `is_hidden` - 0 for visible workspaces
- [ ] `public` - 1 for public access

---

## 🏗️ Complete Workspace Structure

### Working Example Template
```json
{
  "app": "my_app",
  "type": "Workspace",
  "name": "My Workspace",
  "label": "My Workspace",
  "module": "My Module",
  "icon": "crm",
  "is_hidden": 0,
  "public": 1,
  "roles": [],
  "content": "[{\"id\":\"xyz\",\"type\":\"header\",\"data\":{\"text\":\"Reports\",\"level\":4}},{\"id\":\"abc\",\"type\":\"card\",\"data\":{\"card_name\":\"Masters\",\"col\":4}}]",
  "number_cards": [
    {
      "name": "Active Items",
      "label": "Active Items",
      "function": "Count",
      "doctype": "Item",
      "filter_json": "{\"disabled\":0}",
      "color": "#4B88F7"
    }
  ],
  "shortcuts": [
    {
      "label": "New Item",
      "type": "DocType",
      "name": "Item",
      "link_to": "Item",
      "color": "#4B88F7"
    }
  ]
}
```

---

## 📊 Content Field Structure

The `content` field is a JSON-encoded string containing an array of layout elements:

### Layout Element Types

#### 1. Header
```json
{
  "id": "unique_id_1",
  "type": "header",
  "data": {
    "text": "Section Title",
    "level": 4
  }
}
```

#### 2. Card
```json
{
  "id": "unique_id_2",
  "type": "card",
  "data": {
    "card_name": "Card Title",
    "col": 4
  }
}
```

#### 3. Shortcut
```json
{
  "id": "unique_id_3",
  "type": "shortcut",
  "data": {
    "label": "Shortcut Name",
    "type": "DocType",
    "name": "Customer"
  }
}
```

#### 4. Chart
```json
{
  "id": "unique_id_4",
  "type": "chart",
  "data": {
    "chart_name": "Sales Analytics",
    "col": 8
  }
}
```

### Encoding the Content Field
```javascript
// JavaScript example
const layoutArray = [
  { id: "h1", type: "header", data: { text: "Masters", level: 4 }},
  { id: "c1", type: "card", data: { card_name: "Items", col: 4 }}
];
const contentString = JSON.stringify(layoutArray);
```

---

## 🔢 Number Cards Configuration

### Structure
```json
"number_cards": [
  {
    "name": "Card Internal Name",
    "label": "Display Label",
    "function": "Count|Sum|Average",
    "doctype": "Target DocType",
    "field": "field_name (for Sum/Average)",
    "filter_json": "{\"status\":\"Active\"}",
    "color": "#HEX_COLOR"
  }
]
```

### Common Functions
- **Count**: Total number of documents
- **Sum**: Sum of a numeric field
- **Average**: Average of a numeric field

### Example Number Cards
```json
[
  {
    "name": "total_customers",
    "label": "Total Customers",
    "function": "Count",
    "doctype": "Customer",
    "color": "#4B88F7"
  },
  {
    "name": "total_sales",
    "label": "Total Sales",
    "function": "Sum",
    "doctype": "Sales Order",
    "field": "total",
    "filter_json": "{\"docstatus\":1}",
    "color": "#28A745"
  }
]
```

---

## 🎨 Valid Frappe Icons

### NEVER Use FontAwesome Icons!
Always use Frappe's built-in icon set:

#### Business Icons
- `crm` - Customer Relations
- `sell` - Sales
- `buying` - Purchase
- `stock` - Inventory
- `accounting` - Finance
- `hr` - Human Resources
- `project` - Projects
- `support` - Support/Help Desk
- `quality` - Quality Management
- `assets` - Asset Management

#### System Icons
- `dashboard` - Dashboards
- `setting` - Settings
- `tool` - Tools/Utilities
- `integration` - Integrations
- `website` - Web
- `education` - Training/Education
- `healthcare` - Medical
- `agriculture` - Farming
- `non-profit` - NGO/Charity

#### Navigation Icons
- `home` - Home
- `list` - Lists
- `calendar` - Calendar
- `graph` - Analytics
- `file` - Documents
- `folder-open` - Folders
- `filter` - Filters
- `search` - Search

---

## 🔧 Troubleshooting Guide

### Problem: Workspace Not Appearing
**Check:**
1. `is_hidden` is set to 0
2. User has required roles (or `roles` is empty array)
3. Module is enabled
4. Cache has been cleared

**Fix:**
```bash
bench --site site_name clear-cache
bench --site site_name migrate
```

### Problem: Number Cards Not Working
**Check:**
1. Content field is properly JSON encoded
2. DocType exists and user has permission
3. Filter JSON is valid
4. Function and field match (Sum/Average need field)

**Fix:**
```python
# Validate filter JSON
import json
filter_str = '{"status":"Active"}'
json.loads(filter_str)  # Should not raise error
```

### Problem: Icons Not Displaying
**Check:**
1. Using Frappe icon (not FontAwesome)
2. Icon name is exact match
3. Icon exists in valid set

**Fix:**
Replace with valid Frappe icon from list above

### Problem: Links/Shortcuts Broken
**Check:**
1. DocType/Report/Page exists
2. User has permission
3. Link type matches destination
4. Not linking to child tables

**Fix:**
Verify each link destination exists and is accessible

---

## 🚀 Step-by-Step Creation Process

### 1. Find Working Reference
```bash
# Find a similar working workspace
cd /home/frappe/frappe-bench/apps
find . -name "*.json" -path "*/workspace/*" | head -5
# Open and study the structure
```

### 2. Create Workspace File
```bash
# Create in correct location
cd /home/frappe/frappe-bench/apps/my_app/my_app/my_module/workspace/
mkdir -p my_workspace
cd my_workspace
```

### 3. Build JSON Structure
```python
# Python helper to create workspace
import json

workspace = {
    "app": "my_app",
    "type": "Workspace",
    "name": "My Workspace",
    "label": "My Workspace",
    "module": "My Module",
    "icon": "crm",
    "is_hidden": 0,
    "public": 1,
    "roles": [],
    "content": json.dumps([
        {"id": "h1", "type": "header", "data": {"text": "Quick Access", "level": 4}},
        {"id": "c1", "type": "card", "data": {"card_name": "Masters", "col": 4}}
    ])
}

with open('my_workspace.json', 'w') as f:
    json.dump(workspace, f, indent=2)
```

### 4. Add to Module
```python
# In my_module/__init__.py or hooks.py
# Ensure workspace is registered
```

### 5. Deploy
```bash
# Install/update workspace
bench --site site_name migrate
bench --site site_name clear-cache
bench restart  # If in production
```

### 6. Validate
- Check workspace appears in sidebar
- Verify all cards and links work
- Test number cards display correctly
- Confirm shortcuts function

---

## 📝 Quick Reference Card

### DO's ✅
- ALWAYS check working examples first
- Use modern format with content field
- Validate against known-good workspaces
- Use empty roles array for public access
- Clear cache after changes
- Use simple migration commands

### DON'Ts ❌
- Never use FontAwesome icons
- Don't link to child tables
- Avoid complex database operations
- Don't use legacy format
- Never skip validation steps
- Don't assume backward compatibility

---

## 🆘 Emergency Recovery

If workspace is completely broken:

1. **Backup current state**
```bash
cp my_workspace.json my_workspace.json.backup
```

2. **Copy working workspace structure**
```bash
# Find working workspace
cat ../other_workspace/other_workspace.json > template.json
```

3. **Modify for your needs**
- Change app, name, label, module
- Update content field
- Adjust cards and shortcuts

4. **Deploy safely**
```bash
bench --site site_name migrate
bench --site site_name clear-cache
```

5. **Test thoroughly**
- Verify in UI
- Check all functionality
- Confirm permissions

---

## 📚 Additional Resources

- [Frappe Workspace Documentation](https://frappeframework.com/docs/user/en/desk/workspace)
- [ERPNext Module Development](https://docs.erpnext.com/docs/user/manual/en/module-development)
- Working Examples in `/home/frappe/frappe-bench/apps/erpnext/erpnext/*/workspace/`

---

*Last Updated: Based on ERPNext Workspace Troubleshooting Experience*
*Format: Modern ERPNext Workspace Structure*