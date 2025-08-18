# create-multi-doctype-view

**Task:** Design and implement user interfaces that span multiple related DocTypes

**Agent:** ui-layout-designer  
**Category:** UI/UX Design  
**Elicit:** true  
**Prerequisites:** Multiple related DocTypes, business workflow understanding  

## Overview

This task guides the creation of complex user interfaces that integrate multiple DocTypes into cohesive views, such as dashboards, master-detail layouts, and multi-step wizards.

## Input Requirements

**Required:**
- List of DocTypes to integrate
- Relationships between DocTypes (parent-child, linked, etc.)
- User workflow and interaction patterns
- Business objectives for the unified view

**Optional:**
- Existing UI patterns or style guide
- Performance requirements
- Mobile-specific requirements
- Accessibility standards

## Process Steps

### Step 1: DocType Relationship Analysis
1. **Map DocType relationships:**
   ```yaml
   relationships:
     customer:
       primary_doctype: "Customer"
       related_doctypes:
         - name: "Sales Order"
           relationship: "one-to-many"
           key_field: "customer"
         - name: "Address"
           relationship: "many-to-many"
           link_doctype: "Dynamic Link"
         - name: "Contact"
           relationship: "many-to-many"
           link_doctype: "Dynamic Link"
   ```

2. **Identify data flow patterns:**
   - Which DocType is the entry point?
   - How do users navigate between DocTypes?
   - What data needs to be visible at each level?
   - Which operations span multiple DocTypes?

3. **Analyze user workflows:**
   - Common user journeys across DocTypes
   - Frequency of access patterns
   - Task completion requirements
   - Decision points and branching logic

### Step 2: Layout Pattern Selection
1. **Choose appropriate pattern based on relationships:**

   **Master-Detail Pattern:**
   - Use when: One primary DocType with related records
   - Example: Customer view with orders, invoices, payments
   ```vue
   <template>
     <div class="master-detail-layout">
       <div class="master-section">
         <CustomerDetails :customer="selectedCustomer" />
       </div>
       <div class="detail-section">
         <Tabs>
           <Tab name="orders">
             <OrdersList :customer-id="selectedCustomer.name" />
           </Tab>
           <Tab name="invoices">
             <InvoicesList :customer-id="selectedCustomer.name" />
           </Tab>
         </Tabs>
       </div>
     </div>
   </template>
   ```

   **Dashboard Pattern:**
   - Use when: Summarizing data from multiple DocTypes
   - Example: Sales dashboard with metrics from orders, customers, products
   ```vue
   <template>
     <div class="dashboard-layout">
       <div class="metrics-row">
         <MetricCard title="Total Customers" :value="customerCount" />
         <MetricCard title="Open Orders" :value="orderCount" />
         <MetricCard title="Revenue" :value="totalRevenue" />
       </div>
       <div class="charts-row">
         <SalesChart :data="salesData" />
         <CustomerGrowthChart :data="customerData" />
       </div>
     </div>
   </template>
   ```

   **Wizard Pattern:**
   - Use when: Sequential data entry across DocTypes
   - Example: Order creation spanning customer, items, shipping, payment
   ```vue
   <template>
     <div class="wizard-layout">
       <StepIndicator :steps="wizardSteps" :current="currentStep" />
       <div class="wizard-content">
         <component :is="currentStepComponent" 
                    @next="nextStep" 
                    @previous="previousStep" />
       </div>
     </div>
   </template>
   ```

   **Split-View Pattern:**
   - Use when: Comparing or working with two DocTypes simultaneously
   - Example: Comparing quotes side-by-side
   ```vue
   <template>
     <div class="split-view-layout">
       <div class="left-panel">
         <QuoteDetails :quote="leftQuote" />
       </div>
       <div class="divider" />
       <div class="right-panel">
         <QuoteDetails :quote="rightQuote" />
       </div>
     </div>
   </template>
   ```

### Step 3: Component Architecture Design
1. **Design component hierarchy:**
   ```yaml
   component_structure:
     page_container:
       - layout_header:
           - breadcrumbs
           - page_actions
           - search_bar
       - layout_sidebar:
           - navigation_menu
           - filters_panel
       - main_content:
           - doctype_selector
           - data_view_container:
               - list_view
               - detail_view
               - related_data_tabs
       - layout_footer:
           - pagination
           - bulk_actions
   ```

2. **Define data flow between components:**
   - Shared state management (Pinia stores)
   - Event propagation patterns
   - API call coordination
   - Cache management strategy

3. **Plan component reusability:**
   - Generic components for common patterns
   - DocType-specific components
   - Composable functions for shared logic

### Step 4: API Integration Planning
1. **Design data fetching strategy:**
   ```javascript
   // Parallel fetching for independent data
   const fetchDashboardData = async () => {
     const [customers, orders, invoices] = await Promise.all([
       fetchCustomers(),
       fetchOrders(),
       fetchInvoices()
     ])
     return { customers, orders, invoices }
   }
   
   // Sequential fetching for dependent data
   const fetchCustomerDetails = async (customerId) => {
     const customer = await fetchCustomer(customerId)
     const orders = await fetchCustomerOrders(customer.name)
     const invoices = await fetchCustomerInvoices(customer.name)
     return { customer, orders, invoices }
   }
   ```

2. **Optimize API calls:**
   - Batch requests where possible
   - Implement pagination for large datasets
   - Use field filtering to reduce payload
   - Cache frequently accessed data

3. **Handle loading and error states:**
   - Progressive loading for better UX
   - Graceful error handling
   - Retry mechanisms for failed requests

### Step 5: Responsive Design Implementation
1. **Mobile adaptations:**
   ```css
   /* Mobile-first approach */
   .multi-doctype-view {
     display: flex;
     flex-direction: column;
   }
   
   /* Tablet and up */
   @media (min-width: 768px) {
     .multi-doctype-view {
       flex-direction: row;
       gap: 1rem;
     }
   }
   
   /* Desktop */
   @media (min-width: 1024px) {
     .multi-doctype-view {
       grid-template-columns: 300px 1fr 350px;
     }
   }
   ```

2. **Touch-friendly interactions:**
   - Swipe gestures for navigation
   - Touch-optimized buttons and controls
   - Collapsible sections for mobile

3. **Performance optimization:**
   - Lazy loading for off-screen content
   - Virtual scrolling for long lists
   - Image optimization and lazy loading

### Step 6: State Management
1. **Implement Pinia stores for shared state:**
   ```javascript
   // stores/multiDocTypeStore.js
   export const useMultiDocTypeStore = defineStore('multiDocType', {
     state: () => ({
       primaryDocType: null,
       relatedData: {},
       filters: {},
       selectedItems: []
     }),
     
     actions: {
       async loadPrimaryDocType(doctype, name) {
         this.primaryDocType = await fetchDocType(doctype, name)
         await this.loadRelatedData()
       },
       
       async loadRelatedData() {
         // Load all related DocType data
         for (const relation of this.primaryDocType.relations) {
           this.relatedData[relation.doctype] = await fetchRelated(relation)
         }
       }
     }
   })
   ```

2. **Synchronize state across components:**
   - Real-time updates via websockets
   - Optimistic UI updates
   - Conflict resolution strategies

## Deliverables

### 1. UI Specification Document
```yaml
multi_doctype_view:
  name: "Customer Management Portal"
  primary_doctype: "Customer"
  related_doctypes:
    - "Sales Order"
    - "Invoice"
    - "Payment"
    - "Address"
    - "Contact"
  
  layout_pattern: "master-detail"
  
  components:
    master_view:
      - customer_header
      - customer_summary
      - quick_actions
    
    detail_views:
      - orders_list
      - invoices_list
      - payment_history
      - addresses_grid
      - contacts_list
  
  navigation_flow:
    entry_point: "customer_list"
    primary_navigation: "tabs"
    secondary_navigation: "breadcrumbs"
```

### 2. Component Implementation
- Vue components for each view section
- Shared components for reusable elements
- Composables for business logic
- Pinia stores for state management

### 3. API Integration Layer
- API service modules
- Data transformation utilities
- Error handling middleware
- Caching strategies

### 4. Responsive Layouts
- Mobile-specific templates
- Tablet optimizations
- Desktop enhancements
- Print-friendly views

## Quality Checks

- [ ] All DocTypes properly integrated
- [ ] Data relationships correctly implemented
- [ ] Navigation flow is intuitive
- [ ] Performance targets met (load time < 2s)
- [ ] Mobile experience optimized
- [ ] Accessibility standards met (WCAG 2.1)
- [ ] Error handling comprehensive
- [ ] State management efficient
- [ ] API calls optimized
- [ ] Security considerations addressed

## Success Criteria

1. **Functional Completeness**
   - All required DocTypes accessible
   - CRUD operations work across DocTypes
   - Data synchronization maintained
   - Business workflows supported

2. **User Experience**
   - Intuitive navigation between DocTypes
   - Consistent interaction patterns
   - Fast response times
   - Clear visual hierarchy

3. **Technical Quality**
   - Clean component architecture
   - Efficient state management
   - Optimized API usage
   - Maintainable code structure

4. **Performance Metrics**
   - Initial load < 2 seconds
   - Subsequent navigation < 500ms
   - Smooth scrolling and animations
   - Memory usage within limits

## Common Patterns

### Customer 360 View
```vue
<template>
  <CustomerLayout>
    <template #header>
      <CustomerHeader :customer="customer" />
    </template>
    <template #sidebar>
      <CustomerMetrics :metrics="customerMetrics" />
      <QuickActions :actions="quickActions" />
    </template>
    <template #content>
      <TabView>
        <OrdersTab :orders="orders" />
        <InvoicesTab :invoices="invoices" />
        <CommunicationTab :communications="communications" />
      </TabView>
    </template>
  </CustomerLayout>
</template>
```

### Multi-Step Order Creation
```vue
<template>
  <WizardLayout :steps="orderSteps" v-model:current="currentStep">
    <CustomerSelection v-if="currentStep === 1" />
    <ItemSelection v-if="currentStep === 2" />
    <ShippingDetails v-if="currentStep === 3" />
    <PaymentMethod v-if="currentStep === 4" />
    <OrderReview v-if="currentStep === 5" />
  </WizardLayout>
</template>
```

## Next Steps

After creating the multi-DocType view:
1. Conduct user testing with real workflows
2. Optimize performance based on metrics
3. Implement advanced features (filters, search, export)
4. Add keyboard shortcuts for power users
5. Create documentation and training materials
6. Plan for future enhancements and scalability