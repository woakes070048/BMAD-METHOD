# DocType to UI Translation Rules

## Core Principle: DocTypes Drive UI Design

The UI should reflect the data model, not the other way around. Multiple related DocTypes often need to appear together in cohesive views.

## Understanding DocType Relationships

### 1. Identify Relationships
```yaml
# Example: Sales Order System
Primary DocType: Sales Order
  Child Tables: 
    - Sales Order Item (items)
    - Sales Taxes and Charges (taxes)
  Linked DocTypes:
    - Customer (customer field)
    - Address (customer_address field)
    - Contact (contact_person field)
  Related DocTypes:
    - Quotation (can be converted to SO)
    - Delivery Note (created from SO)
    - Sales Invoice (created from SO)
```

### 2. Determine UI Groupings
```yaml
# Based on relationships, create UI views:
Customer View:
  - Customer details (primary)
  - Addresses (linked, multiple)
  - Contacts (linked, multiple)
  - Orders (related transactions)
  - Invoices (related transactions)

Order Management View:
  - Sales Orders (list/kanban)
  - Order Details (form with child tables)
  - Related Documents (quotations, deliveries, invoices)
```

## Field Type to Component Mapping

### 1. Basic Field Types
```javascript
// DocType Field → UI Component
{
  // Text fields
  "Data": "Input",
  "Long Text": "Textarea", 
  "Text Editor": "RichTextEditor",
  "Code": "CodeEditor",
  
  // Numeric fields
  "Int": "Input[type=number]",
  "Float": "Input[type=number]",
  "Currency": "Input with currency prefix",
  "Percent": "Input with % suffix",
  
  // Date/Time fields
  "Date": "DatePicker",
  "Datetime": "DateTimePicker",
  "Time": "TimePicker",
  
  // Selection fields
  "Select": "Select/Dropdown",
  "Link": "Autocomplete with search",
  "Dynamic Link": "Two dropdowns (doctype + document)",
  "Check": "Checkbox",
  
  // Special fields
  "Table": "Nested table component",
  "Attach": "FileUpload",
  "Attach Image": "ImageUpload",
  "Signature": "SignaturePad",
  "Color": "ColorPicker",
  "Rating": "StarRating"
}
```

### 2. Field Properties to UI Behavior
```javascript
// DocType Properties → UI Behavior
{
  "reqd": true,           // Required indicator (*)
  "read_only": true,      // Disabled input
  "hidden": true,         // Don't render
  "unique": true,         // Validation on blur
  "default": "value",     // Pre-filled value
  "options": "...",       // Data source for dropdowns
  "depends_on": "eval:...", // Conditional rendering
  "mandatory_depends_on": "eval:...", // Conditional required
}
```

## Layout Patterns for Multiple DocTypes

### 1. Master-Detail Pattern
```vue
<!-- Customer (master) with Orders (detail) -->
<template>
  <div class="master-detail-layout">
    <!-- Master section -->
    <div class="master-panel">
      <CustomerForm :customer="customer" />
    </div>
    
    <!-- Detail section -->
    <div class="detail-panel">
      <Tabs>
        <TabPanel label="Orders">
          <OrderList :customer="customer.name" />
        </TabPanel>
        <TabPanel label="Invoices">
          <InvoiceList :customer="customer.name" />
        </TabPanel>
        <TabPanel label="Addresses">
          <AddressList :customer="customer.name" />
        </TabPanel>
      </Tabs>
    </div>
  </div>
</template>
```

### 2. Dashboard Pattern
```vue
<!-- Multiple DocTypes in summary view -->
<template>
  <div class="dashboard-layout">
    <div class="stats-row">
      <StatCard doctype="Customer" :count="customerCount" />
      <StatCard doctype="Sales Order" :count="orderCount" />
      <StatCard doctype="Invoice" :value="totalRevenue" />
    </div>
    
    <div class="content-grid">
      <RecentOrders />
      <PendingInvoices />
      <TopCustomers />
    </div>
  </div>
</template>
```

### 3. Wizard Pattern
```vue
<!-- Multiple DocTypes in sequential flow -->
<template>
  <div class="wizard-layout">
    <StepIndicator :steps="steps" :current="currentStep" />
    
    <div class="wizard-content">
      <!-- Step 1: Create/Select Customer -->
      <CustomerStep v-if="currentStep === 1" />
      
      <!-- Step 2: Add Items (uses Item DocType) -->
      <ItemSelectionStep v-if="currentStep === 2" />
      
      <!-- Step 3: Create Sales Order -->
      <OrderCreationStep v-if="currentStep === 3" />
      
      <!-- Step 4: Generate Invoice -->
      <InvoiceStep v-if="currentStep === 4" />
    </div>
  </div>
</template>
```

## Form Generation from DocType

### 1. Section-based Layout
```javascript
// DocType sections to UI layout
function generateFormLayout(doctype) {
  const sections = [];
  let currentSection = { fields: [] };
  
  doctype.fields.forEach(field => {
    if (field.fieldtype === 'Section Break') {
      if (currentSection.fields.length > 0) {
        sections.push(currentSection);
      }
      currentSection = {
        label: field.label,
        fields: [],
        collapsible: field.collapsible
      };
    } else if (field.fieldtype === 'Column Break') {
      currentSection.newColumn = true;
    } else {
      currentSection.fields.push(field);
    }
  });
  
  if (currentSection.fields.length > 0) {
    sections.push(currentSection);
  }
  
  return sections;
}
```

### 2. Responsive Grid Layout
```vue
<!-- Auto-generate form grid from DocType -->
<template>
  <form class="doctype-form">
    <div v-for="section in sections" :key="section.label" 
         class="form-section">
      <h3 v-if="section.label">{{ section.label }}</h3>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
        <FormControl 
          v-for="field in section.fields"
          :key="field.fieldname"
          :field="field"
          v-model="doc[field.fieldname]"
          :class="{
            'md:col-span-2': field.fieldtype === 'Table' || field.fieldtype === 'Text Editor',
            'md:col-span-1': true
          }"
        />
      </div>
    </div>
  </form>
</template>
```

## List View Generation

### 1. Column Selection from DocType
```javascript
// Auto-select columns for list view
function getListColumns(doctype) {
  const columns = [];
  
  // Always include name/ID
  columns.push({
    label: 'ID',
    fieldname: 'name',
    width: '120px'
  });
  
  // Add in_list_view fields
  doctype.fields
    .filter(f => f.in_list_view)
    .forEach(field => {
      columns.push({
        label: field.label,
        fieldname: field.fieldname,
        fieldtype: field.fieldtype,
        width: getColumnWidth(field.fieldtype)
      });
    });
  
  // Add standard fields
  columns.push(
    { label: 'Modified', fieldname: 'modified', width: '120px' },
    { label: 'Status', fieldname: 'status', width: '100px' }
  );
  
  return columns;
}

function getColumnWidth(fieldtype) {
  const widths = {
    'Data': '200px',
    'Link': '150px',
    'Date': '120px',
    'Currency': '120px',
    'Int': '80px',
    'Check': '60px'
  };
  return widths[fieldtype] || '150px';
}
```

### 2. Filter Generation
```javascript
// Generate filters from DocType fields
function getListFilters(doctype) {
  return doctype.fields
    .filter(f => f.in_standard_filter)
    .map(field => ({
      label: field.label,
      fieldname: field.fieldname,
      fieldtype: field.fieldtype,
      options: field.options,
      default: field.default
    }));
}
```

## Navigation Structure from DocTypes

### 1. Module-based Navigation
```javascript
// Group DocTypes by module
function generateNavigation(doctypes) {
  const modules = {};
  
  doctypes.forEach(dt => {
    const module = dt.module || 'General';
    if (!modules[module]) {
      modules[module] = {
        label: module,
        icon: getModuleIcon(module),
        items: []
      };
    }
    
    modules[module].items.push({
      label: dt.name,
      route: `/app/${dt.name.toLowerCase().replace(/ /g, '-')}`,
      icon: dt.icon || 'file',
      badge: dt.is_submittable ? 'Workflow' : null
    });
  });
  
  return Object.values(modules);
}
```

### 2. Relationship-based Navigation
```javascript
// Create navigation based on DocType relationships
function generateRelatedNavigation(primaryDoctype) {
  const nav = {
    primary: {
      label: primaryDoctype.name,
      route: `/app/${primaryDoctype.name}`
    },
    related: []
  };
  
  // Add linked DocTypes
  primaryDoctype.fields
    .filter(f => f.fieldtype === 'Link')
    .forEach(field => {
      nav.related.push({
        label: field.options,
        route: `/app/${field.options}`,
        relationship: 'linked'
      });
    });
  
  // Add child tables
  primaryDoctype.fields
    .filter(f => f.fieldtype === 'Table')
    .forEach(field => {
      nav.related.push({
        label: field.options,
        route: `#${field.fieldname}`,
        relationship: 'child'
      });
    });
  
  return nav;
}
```

## Mobile Responsive Patterns

### 1. Mobile Form Layout
```vue
<!-- Adapt form for mobile -->
<template>
  <div class="mobile-form">
    <!-- Stack all fields vertically on mobile -->
    <div v-for="field in visibleFields" :key="field.fieldname"
         class="mb-4">
      <FormControl 
        :field="field"
        v-model="doc[field.fieldname]"
        :mobile="true"
      />
    </div>
    
    <!-- Fixed bottom action bar -->
    <div class="fixed bottom-0 left-0 right-0 p-4 bg-white border-t">
      <div class="flex gap-2">
        <Button class="flex-1" @click="save">Save</Button>
        <Button class="flex-1" variant="outline" @click="cancel">
          Cancel
        </Button>
      </div>
    </div>
  </div>
</template>
```

### 2. Mobile List to Card Transform
```vue
<!-- List on desktop, cards on mobile -->
<template>
  <!-- Desktop: Table view -->
  <div class="hidden sm:block">
    <ListView :columns="columns" :rows="items" />
  </div>
  
  <!-- Mobile: Card view -->
  <div class="block sm:hidden">
    <div v-for="item in items" :key="item.name" 
         class="bg-white rounded-lg p-4 mb-2 shadow-sm">
      <h3 class="font-semibold">{{ item.title }}</h3>
      <p class="text-sm text-gray-600">{{ item.description }}</p>
      <div class="flex justify-between mt-2">
        <span class="text-xs text-gray-500">{{ item.date }}</span>
        <Badge :label="item.status" />
      </div>
    </div>
  </div>
</template>
```

## Workflow State to UI

### 1. Status-based UI Changes
```javascript
// Adapt UI based on DocType workflow state
function getUIStateFromWorkflow(doc, doctype) {
  const state = {
    editable: !doc.docstatus || doc.docstatus === 0,
    actions: [],
    statusColor: 'gray',
    nextStates: []
  };
  
  if (doctype.is_submittable) {
    switch(doc.docstatus) {
      case 0: // Draft
        state.actions = ['Save', 'Submit'];
        state.statusColor = 'yellow';
        break;
      case 1: // Submitted
        state.editable = false;
        state.actions = ['Cancel', 'Amend'];
        state.statusColor = 'green';
        break;
      case 2: // Cancelled
        state.editable = false;
        state.actions = ['Duplicate'];
        state.statusColor = 'red';
        break;
    }
  }
  
  return state;
}
```

### 2. Permission-based UI
```javascript
// Show/hide UI elements based on permissions
function getPermissionBasedUI(doctype, user_permissions) {
  return {
    showCreateButton: user_permissions.create,
    showEditButton: user_permissions.write,
    showDeleteButton: user_permissions.delete,
    showPrintButton: user_permissions.print,
    showEmailButton: user_permissions.email,
    showExportButton: user_permissions.export,
    readOnlyFields: !user_permissions.write
  };
}
```

## Performance Considerations

### 1. Lazy Loading Related DocTypes
```javascript
// Don't load all related data at once
const CustomerView = {
  data() {
    return {
      customer: null,
      orders: null,
      invoices: null,
      activeTab: 'details'
    };
  },
  
  methods: {
    async loadTabData(tab) {
      this.activeTab = tab;
      
      // Load data only when tab is activated
      switch(tab) {
        case 'orders':
          if (!this.orders) {
            this.orders = await this.fetchOrders();
          }
          break;
        case 'invoices':
          if (!this.invoices) {
            this.invoices = await this.fetchInvoices();
          }
          break;
      }
    }
  }
};
```

### 2. Virtual Scrolling for Large Tables
```vue
<!-- Use virtual scrolling for child tables with many rows -->
<template>
  <VirtualList 
    :items="childTableRows"
    :item-height="48"
    :visible-items="10"
  >
    <template #default="{ item }">
      <ChildTableRow :row="item" />
    </template>
  </VirtualList>
</template>
```

## Key Rules Summary

1. **DocTypes determine UI structure**, not vice versa
2. **Group related DocTypes** into cohesive views
3. **Map field types to appropriate components** consistently
4. **Respect DocType relationships** in navigation
5. **Generate forms dynamically** from DocType schema
6. **Consider mobile from the start** with responsive layouts
7. **Lazy load related data** for performance
8. **Reflect workflow states** in UI behavior
9. **Apply permissions** to show/hide UI elements
10. **Test with real data volumes** to ensure performance