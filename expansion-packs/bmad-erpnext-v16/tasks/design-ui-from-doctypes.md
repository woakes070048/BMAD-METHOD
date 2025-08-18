# design-ui-from-doctypes

**Task:** Create user interface layouts from DocType specifications

**Agent:** ui-layout-designer  
**Category:** UI/UX Design  
**Elicit:** true  
**Prerequisites:** DocType schemas and business requirements  

## Overview

This task guides the creation of user interface layouts based on DocType specifications, translating data structures into intuitive user experiences.

## Input Requirements

**Required:**
- DocType JSON schemas or specifications
- Business requirements and user workflows
- Target user personas and use cases

**Optional:**
- Existing UI components or design system
- Brand guidelines and styling preferences
- Performance requirements and constraints

## Process Steps

### Step 1: DocType Analysis
1. **Parse DocType schemas** to understand:
   - Field types and validation rules
   - Relationships between DocTypes
   - Required vs optional fields
   - Field groupings and sections

2. **Identify relationships:**
   - Parent-child relationships
   - Linked DocTypes and dependencies
   - Master-detail patterns
   - One-to-many and many-to-many relationships

3. **Map business workflows:**
   - How users will interact with the data
   - Sequential operations across DocTypes
   - Common user journeys and tasks

### Step 2: Information Architecture
1. **Group related information:**
   - Primary information vs supporting details
   - Frequently accessed vs occasional fields
   - Critical vs nice-to-have information

2. **Plan navigation structure:**
   - How users move between related DocTypes
   - Breadcrumb and navigation patterns
   - Search and filtering requirements

3. **Determine layout patterns:**
   - **Master-Detail:** Primary DocType with related records
   - **Dashboard:** Summary views of multiple DocTypes  
   - **Wizard:** Step-by-step flow across DocTypes
   - **Tabbed:** Multiple DocTypes in organized sections

### Step 3: UI Layout Design
1. **Create wireframes:**
   - Page layouts and component hierarchy
   - Information density and white space
   - Interactive elements and controls

2. **Design responsive behavior:**
   - Mobile-first approach
   - Tablet and desktop optimizations
   - Touch-friendly interactions

3. **Specify component requirements:**
   - Form components for different field types
   - List views with filtering and sorting
   - Detail views and modal dialogs
   - Navigation and breadcrumb components

### Step 4: Component Mapping
1. **Map to frappe-ui components:**
   - Form fields → appropriate input components
   - Lists → ListView or DataTable components
   - Actions → Button and menu components
   - Layout → LayoutHeader, LayoutSidebar, etc.

2. **Specify data flow:**
   - API endpoints needed for each view
   - State management requirements
   - Real-time update needs

3. **Document interactions:**
   - User actions and system responses
   - Validation and error handling
   - Loading and empty states

## Deliverables

### 1. UI Design Specification
```yaml
ui_design:
  pages:
    - name: "customer-overview"
      layout_type: "master-detail"
      components:
        header:
          component: "LayoutHeader"
          content: "Customer breadcrumbs and actions"
        sidebar:
          component: "LayoutSidebar"
          content: "Customer navigation menu"
        main:
          sections:
            - type: "detail-view"
              doctype: "Customer"
              fields: ["name", "customer_name", "email", "phone"]
            - type: "related-list"
              doctype: "Sales Order"
              title: "Recent Orders"
              limit: 10
```

### 2. Wireframe Documentation
- Visual layouts for each major view
- Component hierarchy and relationships
- Responsive behavior specifications
- User interaction flows

### 3. Component Requirements
- Detailed specifications for custom components
- frappe-ui component mappings
- Props and state requirements
- API integration needs

### 4. Implementation Guidelines
- Development priorities and phases
- Performance considerations
- Accessibility requirements
- Testing scenarios

## Quality Checks

- [ ] All DocType fields are represented in the UI
- [ ] Related DocTypes are accessible through navigation
- [ ] Mobile responsiveness is specified
- [ ] User workflows are supported by the design
- [ ] frappe-ui components are properly mapped
- [ ] Loading and error states are defined
- [ ] Accessibility requirements are met

## Success Criteria

1. **Completeness:** All DocType data is accessible through the UI
2. **Usability:** Common user tasks can be completed efficiently
3. **Responsive:** Design works across mobile, tablet, and desktop
4. **Implementable:** Developers can build from the specifications
5. **Consistent:** Follows established design patterns and conventions

## Next Steps

After completing this task:
1. Review design with stakeholders
2. Hand off to frappe-ui-developer for implementation
3. Coordinate with api-developer for backend integration
4. Plan testing scenarios with testing-specialist