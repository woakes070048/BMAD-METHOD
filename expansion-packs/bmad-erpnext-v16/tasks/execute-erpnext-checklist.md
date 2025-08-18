# execute-erpnext-checklist

Execute ERPNext-specific checklists to ensure quality, compliance, and completeness of ERPNext development work.

## Purpose

Provide a systematic approach to execute various ERPNext checklists, ensuring consistent quality standards and Frappe Framework compliance across all ERPNext development activities.

## Usage

This task can be used with any ERPNext checklist:
- `erpnext-story-dod-checklist.md` - Definition of Done validation
- `erpnext-po-master-checklist.md` - Product Owner process validation
- `erpnext-integration-checklist.md` - Multi-app integration validation
- `frappe-ui-compliance.md` - Frontend compliance validation
- `security-checklist.md` - Security compliance validation
- And any other ERPNext-specific checklists

## Execution Process

### 1. Checklist Initialization

**1.1 Checklist Selection and Loading:**
- Load specified checklist from `/checklists/` directory
- Validate checklist is current and appropriate for task
- Initialize checklist execution context
- Set up tracking for completion status

**1.2 Context Setup:**
```yaml
execution_context:
  checklist_name: [name of checklist being executed]
  execution_date: [current date/time]
  executor: [agent or person executing]
  target_artifact: [story, epic, code, etc. being checked]
  erpnext_context: [relevant ERPNext environment details]
```

### 2. ERPNext Environment Validation

**2.1 Environment Check:**
- Verify ERPNext bench environment is accessible
- Confirm site is available and responsive
- Validate existing app versions and compatibility
- Check development environment setup

**2.2 Integration Context:**
- Assess docflow integration status
- Verify n8n_integration connectivity
- Check existing custom app functionality
- Validate multi-tenancy setup if applicable

### 3. Systematic Checklist Execution

**3.1 Item-by-Item Execution:**

For each checklist item:

```yaml
checklist_item_execution:
  item_description: [specific checklist requirement]
  validation_method: [how to verify compliance]
  erpnext_specifics: [ERPNext-specific validation criteria]
  tools_required: [bench commands, tests, etc.]
  acceptance_criteria: [what constitutes pass/fail]
```

**3.2 ERPNext-Specific Validations:**

**DocType Checklist Items:**
- Field types are appropriate and follow Frappe conventions
- Relationships (Link, Table) are correctly implemented
- Naming conventions follow Frappe standards
- Permissions are properly configured for roles
- Workflow integration works with docflow if applicable

**Controller Checklist Items:**
- Business logic follows ERPNext patterns
- Hooks are implemented correctly (before_save, validate, etc.)
- Error handling follows Frappe conventions
- Performance is acceptable for expected data volumes
- Security measures are properly implemented

**API Checklist Items:**
- All endpoints are properly whitelisted
- Authentication and authorization work correctly
- Input validation prevents security issues
- Response formats follow Frappe conventions
- Rate limiting is considered where appropriate

**Frontend Checklist Items:**
- Vue.js components use Frappe UI patterns
- Mobile-first design is properly implemented
- PWA features work if required
- Accessibility standards are met
- Loading states and error handling are proper

### 4. Frappe Framework Compliance Validation

**4.1 Frappe-First Principle Check:**
- No external libraries where Frappe has built-in solutions
- Proper use of Frappe utilities and helpers
- Correct implementation of Frappe design patterns
- Adherence to Frappe security best practices

**4.2 Anti-Pattern Detection:**
- Check for common ERPNext anti-patterns
- Validate against known problematic approaches
- Ensure clean separation of concerns
- Verify proper error handling patterns

### 5. Multi-App Integration Validation

**5.1 docflow Integration Checks:**
- Workflow states are properly defined
- Transitions follow business rules correctly
- Approval processes function as expected
- Document lifecycle is managed properly

**5.2 n8n_integration Checks:**
- Webhook endpoints are secure and functional
- Event triggers work correctly
- External system integration is stable
- Error handling for automation failures is adequate

**5.3 Existing App Compatibility:**
- No conflicts with existing ERPNext functionality
- Data relationships maintain integrity
- API endpoints don't create conflicts
- Performance impact is acceptable

### 6. Quality and Performance Validation

**6.1 Code Quality Checks:**
- Code follows ERPNext coding standards
- Documentation is adequate and current
- Test coverage meets requirements
- Code is maintainable and readable

**6.2 Performance Validation:**
- Database queries are optimized
- Page load times are acceptable
- API response times meet standards
- Memory usage is reasonable

**6.3 Security Validation:**
- Input validation prevents common attacks
- Authentication and authorization are secure
- Sensitive data is properly protected
- API security follows ERPNext standards

### 7. Testing and Validation

**7.1 Automated Testing:**
- Unit tests pass for all components
- Integration tests validate multi-component functionality
- API tests verify endpoint behavior
- Frontend tests validate user interface behavior

**7.2 Manual Testing:**
- User workflows function as expected
- Error scenarios are handled gracefully
- Mobile responsiveness works across devices
- PWA functionality operates correctly if implemented

### 8. Documentation and Compliance

**8.1 Documentation Review:**
- Technical documentation is complete and accurate
- User documentation is clear and helpful
- API documentation follows standards
- Code comments are adequate and meaningful

**8.2 Compliance Verification:**
- Regulatory requirements are met
- Business rules are properly implemented
- Data privacy requirements are satisfied
- Audit trail requirements are fulfilled

### 9. Results Documentation

**9.1 Checklist Results Recording:**
```yaml
checklist_results:
  total_items: [number of checklist items]
  items_passed: [number of items that passed]
  items_failed: [number of items that failed]
  items_not_applicable: [items that don't apply to current context]
  overall_status: [PASS/FAIL/CONDITIONAL_PASS]
```

**9.2 Detailed Findings:**
- Document specific failures with remediation guidance
- Note any conditional passes with requirements
- Highlight exceptional quality achievements
- Provide recommendations for improvement

**9.3 Action Items:**
- List required fixes for failed items
- Set priorities for remediation work
- Assign responsibility for corrections
- Establish timeline for resolution

### 10. Follow-up and Closure

**10.1 Remediation Tracking:**
- Monitor progress on required fixes
- Re-execute checklist items after corrections
- Validate that fixes don't introduce new issues
- Confirm overall checklist completion

**10.2 Process Improvement:**
- Identify recurring checklist failures
- Suggest improvements to development processes
- Recommend additional checklist items if needed
- Share lessons learned with team

## Completion Criteria

Checklist execution is complete when:

- All applicable checklist items have been evaluated
- Results are documented with specific findings
- Failed items have clear remediation guidance
- Overall pass/fail status is determined
- Action items are assigned and tracked
- Process improvements are identified and documented

## Integration Points

- Coordinates with all ERPNext specialists for item validation
- Reports results to erpnext-product-owner for business validation
- Works with erpnext-qa-lead for quality assurance
- Provides feedback to main-dev-coordinator for process improvement
- Supports erpnext-scrum-master with process refinement