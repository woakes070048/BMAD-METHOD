# Create ERPNext Story Task

## Purpose

To identify the next logical ERPNext story based on project progress and epic definitions, and then to prepare a comprehensive, self-contained, and actionable ERPNext story file using the `ERPNext Story Template`. This task ensures the story is enriched with all necessary ERPNext technical context, DocType requirements, Frappe patterns, and acceptance criteria, making it ready for efficient implementation by an ERPNext Developer Agent with minimal need for additional research.

## ERPNext-Specific Context

This task is adapted for ERPNext development and includes:
- DocType design and relationship considerations
- Frappe Framework pattern validation
- Multi-app integration awareness (docflow, n8n_integration)
- Vue.js frontend with Frappe UI requirements
- Mobile-first and PWA considerations
- API security and whitelisting requirements
- Frappe-first principle enforcement

## SEQUENTIAL Task Execution (Do not proceed until current Task is complete)

### 0. Load ERPNext Configuration and Check Workflow

- Load `.bmad-erpnext-v16/config.yaml` from the ERPNext expansion pack
- If the file does not exist, HALT and inform the user: "config.yaml not found. This file is required for ERPNext story creation."
- Extract key configurations: `environment.development_directory`, `environment.bench_path`, `existing_apps`, integration requirements
- Validate ERPNext bench environment and site availability

### 1. Identify Next ERPNext Story for Preparation

#### 1.1 Locate Epic Files and Review Existing ERPNext Stories

- Based on story location configuration, locate ERPNext epic files
- If story directory has ERPNext story files, load the highest `{epicNum}.{storyNum}.erpnext-story.md` file
- **If highest story exists:**
  - Verify status is 'Done'. If not, alert user: "ALERT: Found incomplete ERPNext story! File: {lastEpicNum}.{lastStoryNum}.erpnext-story.md Status: [current status] You should fix this ERPNext story first, but would you like to accept risk & override to create the next story in draft?"
  - If proceeding, select next sequential story in the current epic
  - If epic is complete, prompt user: "ERPNext Epic {epicNum} Complete: All stories in Epic {epicNum} have been completed. Would you like to: 1) Begin Epic {epicNum + 1} with story 1 2) Select a specific ERPNext story to work on 3) Cancel story creation"
  - **CRITICAL**: NEVER automatically skip to another epic. User MUST explicitly instruct which ERPNext story to create.
- **If no story files exist:** The next story is ALWAYS 1.1 (first story of first epic)
- Announce the identified story to the user: "Identified next ERPNext story for preparation: {epicNum}.{storyNum} - {Story Title}"

### 2. Gather ERPNext Story Requirements and Previous Story Context

- Extract ERPNext story requirements from the identified epic file
- If previous story exists, review Dev Agent Record sections for:
  - ERPNext-specific completion notes and debug log references
  - DocType implementation decisions and technical choices
  - Frappe Framework challenges encountered and lessons learned
  - Integration issues with docflow or n8n_integration
  - Vue.js frontend implementation notes
- Extract relevant ERPNext insights that inform the current story's preparation

### 3. Gather ERPNext Architecture Context

#### 3.1 Read ERPNext Architecture Documents Based on Story Type

**For ALL ERPNext Stories:** 
- `erpnext-patterns.yaml`
- `frappe-field-types.yaml`
- `frappe-first-principles.md`
- `vue-frontend-architecture.md`
- `api-patterns.yaml`
- `testing-patterns.yaml`

**For DocType Stories, additionally:** 
- `doctype-template.yaml`
- `frappe-ui-patterns.md`
- `data-fetching-patterns.md`

**For API/Backend Stories, additionally:** 
- `api-endpoint-template.yaml`
- `api-whitelisting-guide.md`
- `workflow-patterns.yaml`

**For Frontend Stories, additionally:** 
- `vue-spa-patterns.md`
- `frappe-ui-components.md`
- `mobile-desktop-patterns.md`
- `pwa-implementation.md`

**For Integration Stories, additionally:**
- `n8n-node-mappings.yaml`
- `erpnext-vue-integration.md`

### 4. Analyze Multi-App Integration Requirements

- Review existing apps: docflow, n8n_integration
- Identify integration points and dependencies
- Consider workflow automation possibilities
- Validate multi-app compatibility requirements
- Check for potential conflicts or overlaps

### 5. Apply ERPNext Story Template and Populate

#### 5.1 Initialize ERPNext Story Structure

- Load `.bmad-erpnext-v16/templates/erpnext-story-template.yaml`
- Create new story file: `{epicNum}.{storyNum}.erpnext-story.md`
- Populate basic story metadata with ERPNext context

#### 5.2 Populate ERPNext-Specific Sections

**Story Section:**
- Include ERPNext module context
- Specify DocType requirements if applicable
- Define Frappe Framework constraints
- Include mobile-first considerations

**Acceptance Criteria:**
- Add Frappe-first validation requirements
- Include DocType relationship validation
- Specify API security requirements
- Add multi-app integration validation
- Include Vue.js frontend requirements
- Add mobile responsiveness criteria

**Tasks/Subtasks:**
- Break down by ERPNext component type (DocType, Controller, Client Script, etc.)
- Include Frappe UI component requirements
- Add API whitelisting tasks
- Include testing at multiple levels (unit, integration, UI)
- Add compliance validation tasks

**Technical Context:**
- DocType design specifications
- Field type selections and validations
- Relationship modeling requirements
- Permission matrix design
- Workflow integration considerations
- API endpoint specifications
- Vue.js component requirements
- Frappe UI pattern usage

### 6. ERPNext Validation and Quality Checks

#### 6.1 Frappe-First Compliance Review
- Ensure no external libraries when Frappe has built-in solutions
- Validate adherence to Frappe naming conventions
- Check for proper use of Frappe field types
- Verify API security patterns

#### 6.2 Multi-App Integration Review
- Validate compatibility with existing apps
- Check for integration opportunities with docflow
- Consider n8n_integration automation possibilities
- Ensure proper data flow between apps

#### 6.3 Technical Feasibility Review
- Validate DocType design against ERPNext constraints
- Check Vue.js frontend requirements against Frappe UI capabilities
- Verify mobile-first design requirements
- Validate PWA implementation requirements

### 7. Final ERPNext Story Preparation

#### 7.1 Complete Story Documentation
- Ensure all ERPNext-specific sections are populated
- Add environment-specific configurations
- Include bench command requirements
- Add site-specific considerations

#### 7.2 Set Story Status and Handoff
- Set status to 'Ready for Development'
- Add story to development backlog
- Notify main-dev-coordinator for task routing
- Create handoff documentation for assigned developer

## Completion Criteria

- ERPNext story file created with complete technical context
- All Frappe Framework requirements specified
- Multi-app integration considerations documented
- Vue.js frontend requirements clearly defined
- Mobile-first and PWA requirements included
- API security and whitelisting requirements specified
- Story marked as 'Ready for Development'
- Handoff documentation prepared for development team

## Integration Points

- Coordinates with erpnext-product-owner for requirement validation
- Hands off to main-dev-coordinator for specialist assignment
- Integrates with existing ERPNext apps (docflow, n8n_integration)
- Follows Frappe Framework development patterns