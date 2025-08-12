# Scaffold Complete ERPNext App with Vue Frontend

## Overview
This task orchestrates multiple specialist agents to generate a complete Vue.js frontend application for an ERPNext app, including all DocTypes with intelligent relationship mapping, CRUD operations, and modern UI patterns.

## Prerequisites

### Required Knowledge
- [ ] Basic understanding of ERPNext app structure
- [ ] Familiarity with Vue.js and modern frontend development
- [ ] Understanding of DocType relationships in ERPNext

### Development Environment
- [ ] ERPNext development environment is set up and running
- [ ] Node.js 18+ and npm/yarn installed
- [ ] App to be scaffolded already exists in ERPNext
- [ ] Access to app DocType definitions and data

## Input Requirements

```yaml
app_name: String # Name of the ERPNext app (snake_case)
app_title: String # Display title for the app
doctype_focus: Array # Optional: Specific DocTypes to prioritize
ui_complexity: String # "simple" | "intermediate" | "advanced"
include_relationships: Boolean # Whether to analyze and include related DocTypes
target_platform: String # "desktop" | "mobile" | "responsive"
performance_optimization: Boolean # Whether to apply performance optimizations
```

## Multi-Agent Orchestration Process

### Phase 1: Discovery & Analysis (Led by app-scaffold-coordinator)

#### Step 1.1: Initial App Assessment
The **app-scaffold-coordinator** initiates the discovery process:

1. **Gather Requirements**
   - Validate app exists and is accessible
   - Understand user priorities and constraints
   - Determine scope and complexity level

2. **Coordinate Agent Activation**
   ```
   Activating specialist agents for comprehensive analysis:
   🔍 erpnext-architect: Technical app structure analysis
   📊 business-analyst: Business workflow and relationship discovery
   🎨 vue-frontend-architect: UI complexity assessment
   ```

#### Step 1.2: DocType Discovery & Analysis
**erpnext-architect** performs comprehensive app analysis:

1. **DocType Enumeration**
   ```bash
   # Discover all DocTypes in the app
   frappe.get_meta({app_name})
   
   # Categorize by type and importance
   - Core Business DocTypes (full CRUD needed)
   - Supporting DocTypes (simplified CRUD)  
   - Configuration DocTypes (read-only/minimal)
   ```

2. **Relationship Mapping**
   ```
   Analyzing DocType relationships:
   - Link field dependencies (Customer → Territory)
   - Parent-child relationships (Sales Order → Sales Order Item)
   - Workflow dependencies (Draft → Submitted → Cancelled)
   - Permission inheritance patterns
   ```

3. **Performance Assessment**
   ```
   Identifying potential bottlenecks:
   - Large DocTypes (>10,000 records)
   - Complex queries and joins
   - Heavy data processing requirements
   ```

#### Step 1.3: Business Context Analysis
**business-analyst** provides business workflow understanding:

1. **User Workflow Discovery**
   ```
   Analyzing typical user journeys:
   - Primary business processes
   - Most frequently used DocTypes
   - User role and permission patterns
   - Critical business relationships
   ```

2. **Business Priority Assessment**
   ```
   Categorizing DocTypes by business importance:
   TIER 1 - Critical Operations:
   - Daily business transactions
   - Revenue-generating processes
   - Compliance-required documents
   
   TIER 2 - Supporting Operations:
   - Reference data and lookups
   - Periodic business processes
   - Reporting and analytics
   
   TIER 3 - Configuration:
   - System settings and preferences
   - User and permission management
   - Rarely-changed reference data
   ```

#### Step 1.4: UI Complexity Assessment
**vue-frontend-architect** evaluates frontend requirements:

1. **UI Pattern Analysis**
   ```
   Assessing appropriate UI patterns for each DocType:
   - Simple forms vs multi-step wizards
   - Standard lists vs advanced data tables
   - Master-detail views for relationships
   - Modal vs full-page editing
   ```

2. **Navigation Design**
   ```
   Planning app navigation structure:
   - Primary navigation for core DocTypes
   - Secondary navigation for supporting features
   - Contextual navigation for related records
   - Mobile-responsive navigation patterns
   ```

3. **Component Architecture Planning**
   ```
   Designing reusable component hierarchy:
   - Base CRUD components
   - Relationship-aware widgets
   - Form field components mapped to Frappe types
   - List and table components with filtering
   ```

### Phase 2: Coordinated Design (Multi-Agent Collaboration)

#### Step 2.1: Relationship Validation
**app-scaffold-coordinator** facilitates cross-agent validation:

```
Coordinating relationship validation:
🔍 erpnext-architect: "Sales Order links to Customer via Link field"
📊 business-analyst: "Users typically create orders after selecting customer"
🎨 vue-frontend-architect: "Recommend customer selector with order history widget"
✅ Consensus: Master-detail pattern with embedded relationship
```

#### Step 2.2: Component Design Strategy
**vue-frontend-architect** designs with **frappe-ui-developer** input:

1. **Component Patterns**
   ```vue
   // Example: Customer-Order Master-Detail Component
   <template>
     <div class="master-detail-view">
       <!-- Master: Customer Details -->
       <CustomerCard 
         :customer="selectedCustomer"
         @edit="showCustomerForm"
       />
       
       <!-- Detail: Related Orders -->
       <RelatedOrdersList 
         :customer-id="selectedCustomer.name"
         @create-order="showOrderForm"
       />
     </div>
   </template>
   ```

2. **Routing Strategy**
   ```javascript
   // Multi-DocType routing structure
   const routes = [
     {
       path: '/customers',
       component: CustomerList,
       children: [
         { path: ':id', component: CustomerDetail },
         { path: ':id/orders', component: CustomerOrders },
         { path: ':id/edit', component: CustomerForm }
       ]
     },
     {
       path: '/orders',
       component: OrderList,
       children: [
         { path: 'new', component: OrderForm },
         { path: ':id', component: OrderDetail }
       ]
     }
   ]
   ```

#### Step 2.3: Performance Optimization Planning
**erpnext-architect** coordinates performance strategy:

1. **Data Loading Strategy**
   ```
   Large DocType optimization:
   - Item DocType (50k+ records): Search-first UI pattern
   - Customer DocType (5k records): Standard pagination
   - Territory DocType (100 records): Full load with filtering
   ```

2. **Component Loading Strategy**
   ```
   Progressive loading approach:
   - Core components: Eager loading
   - Detail views: Lazy loading
   - Reports/Analytics: On-demand loading
   ```

### Phase 3: Coordinated Generation (Systematic Implementation)

#### Step 3.1: Foundation Setup
**vue-frontend-architect** and **frappe-ui-developer** coordinate:

1. **Vue SPA Foundation**
   ```bash
   # Set up Vue 3 SPA with doppio method
   cd apps/{app_name}
   npx degit NagariaHussain/doppio_frappeui_starter frontend
   cd frontend && yarn install
   ```

2. **Base Architecture Setup**
   ```
   Creating foundational structure:
   - Router configuration with DocType routes
   - State management with Pinia stores  
   - Base components and layouts
   - Authentication and permission integration
   ```

#### Step 3.2: Tiered Component Generation
**app-scaffold-coordinator** manages generation priorities:

**Tier 1 - Core Business Components (First Priority)**
```
Generating core business CRUD components:
🔧 frappe-ui-developer: Creating Customer CRUD components
   ✅ CustomerList.vue (with search, filters, pagination)
   ✅ CustomerForm.vue (create/edit with validation)
   ✅ CustomerCard.vue (display component)

🔧 frappe-ui-developer: Creating Sales Order CRUD components  
   ✅ SalesOrderList.vue (with customer filter integration)
   ✅ SalesOrderForm.vue (with customer selection and items table)
   ✅ SalesOrderDetail.vue (with customer and items display)
```

**Tier 2 - Supporting Components (Second Priority)**
```
Generating supporting CRUD components:
🔧 frappe-ui-developer: Creating Territory, Customer Group components
   ✅ Simplified CRUD with basic list and form views
   ✅ Integration as dropdown options in main forms
```

**Tier 3 - Configuration Components (Final Priority)**
```
Generating configuration interfaces:
🔧 frappe-ui-developer: Creating read-only/minimal edit interfaces
   ✅ Company settings display
   ✅ User preference forms
```

#### Step 3.3: Relationship Integration
**frappe-ui-developer** implements relationship-aware components:

1. **Master-Detail Views**
   ```vue
   <!-- Customer with related orders -->
   <template>
     <div class="customer-detail">
       <CustomerForm v-model="customer" />
       
       <div class="related-sections">
         <h3>Related Orders</h3>
         <SalesOrderList 
           :filters="{ customer: customer.name }"
           :embedded="true"
         />
         
         <Button @click="createOrder">
           New Order for {{ customer.customer_name }}
         </Button>
       </div>
     </div>
   </template>
   ```

2. **Smart Form Integration**
   ```vue
   <!-- Sales Order form with customer context -->
   <template>
     <form @submit="handleSubmit">
       <CustomerSelector 
         v-model="order.customer"
         @change="loadCustomerDefaults"
       />
       
       <!-- Auto-populated from customer -->
       <FormControl 
         v-model="order.territory"
         label="Territory"
         :readonly="true"
       />
       
       <ItemsTable 
         v-model="order.items"
         :customer-context="order.customer"
       />
     </form>
   </template>
   ```

### Phase 4: Integration & Optimization

#### Step 4.1: Backend API Integration
**api-architect** (coordinated by **app-scaffold-coordinator**) ensures proper backend support:

1. **Custom API Endpoints**
   ```python
   # Auto-generated API endpoints for complex operations
   @frappe.whitelist()
   def get_customer_with_orders(customer_id, limit=10):
       customer = frappe.get_doc("Customer", customer_id)
       orders = frappe.get_all("Sales Order", 
                               filters={"customer": customer_id},
                               limit=limit,
                               order_by="creation desc")
       return {
           "customer": customer.as_dict(),
           "recent_orders": orders
       }
   ```

2. **Search APIs**
   ```python
   # Optimized search for large DocTypes
   @frappe.whitelist()
   def search_items(query, customer=None, limit=20):
       filters = {}
       if customer:
           # Customer-specific item filtering
           filters["item_group"] = get_customer_item_groups(customer)
           
       return frappe.get_all("Item",
                             filters=filters,
                             or_filters={"item_name": ["like", f"%{query}%"]},
                             limit=limit)
   ```

#### Step 4.2: Performance Optimization
**vue-frontend-architect** implements optimizations:

1. **Lazy Loading Implementation**
   ```javascript
   // Route-based code splitting
   const routes = [
     {
       path: '/customers',
       component: () => import('@/pages/customers/CustomerList.vue')
     },
     {
       path: '/orders',
       component: () => import('@/pages/orders/OrderList.vue')
     }
   ]
   ```

2. **Caching Strategy**
   ```javascript
   // Smart caching for reference data
   const territoryStore = useTerritoryStore()
   const customerGroupStore = useCustomerGroupStore()
   
   // Cache small, rarely-changing data
   onMounted(async () => {
     await Promise.all([
       territoryStore.loadAll(), // Cache all territories
       customerGroupStore.loadAll() // Cache all customer groups
     ])
   })
   ```

#### Step 4.3: Testing & Validation
**app-scaffold-coordinator** orchestrates testing:

1. **Component Testing**
   ```bash
   # Test generated components
   npm run test:unit
   
   # Test component integration
   npm run test:integration
   ```

2. **End-to-End Workflow Testing**
   ```bash
   # Test complete user workflows
   npm run test:e2e
   ```

## Generated Output Structure

### Frontend Application Structure
```
{app_name}/frontend/
├── src/
│   ├── components/
│   │   ├── forms/           # Generated CRUD forms
│   │   │   ├── CustomerForm.vue
│   │   │   ├── SalesOrderForm.vue
│   │   │   └── ItemForm.vue
│   │   ├── lists/           # Generated list views  
│   │   │   ├── CustomerList.vue
│   │   │   ├── SalesOrderList.vue
│   │   │   └── ItemList.vue
│   │   ├── cards/           # Generated display components
│   │   │   ├── CustomerCard.vue
│   │   │   └── OrderCard.vue
│   │   ├── widgets/         # Relationship components
│   │   │   ├── RelatedOrdersWidget.vue
│   │   │   ├── CustomerSelectorWidget.vue
│   │   │   └── ItemSelectorWidget.vue
│   │   └── base/            # Reusable base components
│   │       ├── BaseForm.vue
│   │       ├── BaseList.vue
│   │       └── BaseCard.vue
│   ├── pages/               # Generated page components
│   │   ├── customers/
│   │   │   ├── CustomerList.vue
│   │   │   ├── CustomerDetail.vue
│   │   │   └── CustomerForm.vue
│   │   ├── orders/
│   │   │   ├── OrderList.vue  
│   │   │   ├── OrderDetail.vue
│   │   │   └── OrderForm.vue
│   │   └── dashboard/
│   │       └── Dashboard.vue
│   ├── stores/              # Generated Pinia stores
│   │   ├── customers.js
│   │   ├── orders.js
│   │   └── items.js
│   ├── composables/         # Generated composables
│   │   ├── useCustomers.js
│   │   ├── useOrders.js
│   │   └── usePermissions.js
│   ├── utils/               # Generated utilities
│   │   ├── api.js
│   │   ├── validation.js
│   │   └── formatting.js
│   └── router/              # Generated routing
│       └── index.js
├── package.json
├── vite.config.js
└── tailwind.config.js
```

### Backend Integration Files
```
{app_name}/
├── {app_name}/
│   ├── api/                 # Generated API endpoints
│   │   ├── customers.py
│   │   ├── orders.py
│   │   └── search.py
│   └── public/              # Generated frontend assets
│       └── {app_name}/      # Built frontend files
└── www/
    └── {app_name}.html      # Generated SPA entry point
```

## Agent Coordination Benefits

### ✅ **Intelligent Analysis**
- **erpnext-architect**: Discovers technical relationships and performance implications
- **business-analyst**: Provides business context and user workflow understanding  
- **vue-frontend-architect**: Designs appropriate UI patterns for each DocType

### ✅ **Coordinated Implementation**  
- **frappe-ui-developer**: Implements components following agreed patterns
- **app-scaffold-coordinator**: Ensures consistency across all generated components
- **Cross-agent validation**: Each decision is validated by multiple specialist perspectives

### ✅ **Optimized Output**
- **Performance-aware**: Large DocTypes get search-first UIs, small ones get full loading
- **Relationship-intelligent**: Master-detail views for parent-child relationships
- **Business-focused**: Core business DocTypes get full features, configuration gets minimal UI

## Success Metrics

### Generated App Quality
- **Functional Completeness**: All DocTypes have appropriate CRUD operations
- **Relationship Integrity**: All DocType relationships work correctly in the UI  
- **Performance Adequacy**: Large lists load quickly, forms save without delays
- **User Experience**: Navigation is intuitive, workflows are efficient

### Development Acceleration
- **Time to Working App**: Complete functional app in minutes vs days
- **Consistency**: All components follow the same patterns and standards
- **Maintainability**: Generated code is clean, documented, and extensible
- **Scalability**: App can handle growth in data volume and feature complexity

## Troubleshooting

### Common Issues & Agent Responses

#### Issue: "App has too many DocTypes (50+)"
```
app-scaffold-coordinator: "Large app detected. Coordinating selective generation..."
business-analyst: "Identifying core business processes to prioritize..."
vue-frontend-architect: "Designing modular navigation to prevent UI overwhelm..."
```

#### Issue: "DocType has circular relationships"
```
erpnext-architect: "Circular dependency detected between Customer and Contact..."
app-scaffold-coordinator: "Coordinating resolution strategy..."
Solution: Generate with optional relationship display to break cycles
```

#### Issue: "Performance concerns with large DocTypes"
```
erpnext-architect: "Item DocType has 100k+ records - standard list will be slow"
vue-frontend-architect: "Designing search-first UI pattern with lazy loading"
frappe-ui-developer: "Implementing autocomplete component with pagination"
```

### Validation Checklist
- [ ] All core DocTypes have functional CRUD operations
- [ ] DocType relationships display correctly in UI
- [ ] Large lists load within acceptable timeframes (< 3 seconds)
- [ ] Forms save and validate properly
- [ ] Navigation between related DocTypes works smoothly
- [ ] Mobile responsive design works on target devices
- [ ] User permissions are properly enforced
- [ ] Search and filtering operations work correctly

## Next Steps After Scaffolding

### Immediate Customization Options
1. **UI Refinement**: Customize specific form layouts and list views
2. **Business Logic**: Add custom validation and automation rules
3. **Advanced Features**: Implement specialized workflows and integrations
4. **Performance Tuning**: Optimize specific bottlenecks identified during testing

### Long-term Enhancement Planning
1. **User Feedback Integration**: Collect user feedback and iterate on UI patterns
2. **Feature Expansion**: Add advanced reporting, analytics, and automation
3. **Integration Development**: Connect with external systems and services
4. **Mobile App Development**: Extend to native mobile applications

---

*This multi-agent approach ensures your ERPNext app gets a comprehensive, well-architected Vue frontend that reflects both technical best practices and business process understanding.*