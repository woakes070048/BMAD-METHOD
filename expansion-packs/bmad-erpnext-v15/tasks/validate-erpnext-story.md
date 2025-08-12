# validate-erpnext-story

Validate an ERPNext story for completeness, technical feasibility, and adherence to Frappe Framework principles before it enters development.

## Purpose

Ensure ERPNext stories are technically sound, complete, and ready for development by specialized ERPNext agents. This validation prevents development blockers and ensures efficient implementation.

## Prerequisites

- ERPNext story exists in draft or ready state
- Story follows erpnext-story-template structure
- Basic requirements have been gathered
- ERPNext technical context is available

## Validation Process

### 1. Story Structure Validation

**1.1 Template Compliance:**
- Story follows `erpnext-story-template.yaml` structure
- All required sections are present and populated
- ERPNext-specific fields are completed
- Story numbering follows epic sequence

**1.2 Metadata Validation:**
- Epic and story numbers are correct
- Priority and effort estimates are realistic
- ERPNext module assignment is appropriate
- Dependencies are clearly identified

### 2. ERPNext Technical Validation

**2.1 DocType Requirements:**
```yaml
doctype_validation:
  - field_types: [validate against frappe-field-types.yaml]
  - relationships: [verify Link and Table field logic]
  - naming_conventions: [ensure Frappe naming standards]
  - permissions: [validate role-based access requirements]
  - workflow_integration: [check docflow compatibility]
```

**2.2 Frappe Framework Compliance:**
- No external libraries when Frappe has built-in solutions
- Proper use of Frappe field types and validations
- Correct implementation of Frappe design patterns
- API endpoints follow Frappe whitelisting requirements
- Security measures align with Frappe best practices

**2.3 Vue.js Frontend Requirements:**
- Components use Frappe UI patterns
- Mobile-first design requirements are specified
- PWA features are clearly defined if needed
- Data fetching follows Frappe patterns
- State management aligns with Frappe architecture

### 3. Multi-App Integration Validation

**3.1 docflow Integration:**
- Workflow states and transitions are defined
- Approval processes are specified
- Document lifecycle requirements are clear
- Integration points are technically feasible

**3.2 n8n_integration Compatibility:**
- Webhook requirements are specified
- Automation trigger points are identified
- External system integration is feasible
- Event handling requirements are clear

**3.3 Existing App Compatibility:**
- No conflicts with existing ERPNext modules
- Data relationships maintain integrity
- API endpoints don't conflict
- Frontend components are compatible

### 4. Acceptance Criteria Validation

**4.1 Completeness Check:**
- All user scenarios are covered
- Edge cases are considered
- Error handling scenarios are defined
- Performance requirements are specified

**4.2 Testability Assessment:**
- Acceptance criteria are measurable
- Test scenarios can be automated
- Integration testing is feasible
- Performance testing requirements are clear

**4.3 ERPNext-Specific Criteria:**
- DocType behavior is clearly defined
- API functionality is precisely specified
- Frontend behavior is unambiguous
- Multi-app integration points are testable

### 5. Technical Feasibility Assessment

**5.1 Implementation Complexity:**
- Effort estimates are realistic for ERPNext development
- Required skills match available specialists
- Technical dependencies are manageable
- Risk factors are identified and mitigated

**5.2 Performance Considerations:**
- Database query impact is assessed
- Large dataset handling is considered
- Mobile performance requirements are feasible
- Caching strategies are planned if needed

**5.3 Security Assessment:**
- Security requirements are comprehensive
- Permission requirements are clearly defined
- Data validation requirements are specified
- API security measures are planned

### 6. Development Readiness Check

**6.1 Context Completeness:**
- All necessary technical context is provided
- Development environment requirements are clear
- Integration requirements are documented
- Testing requirements are comprehensive

**6.2 Dependency Analysis:**
- All technical dependencies are identified
- External dependencies are documented
- Internal ERPNext dependencies are mapped
- Blocking dependencies are resolved

**6.3 Resource Requirements:**
- Required ERPNext specialist skills are identified
- Development time estimates are reasonable
- Testing resource requirements are clear
- Deployment requirements are documented

### 7. Quality Standards Validation

**7.1 ERPNext Standards:**
- Follows ERPNext development best practices
- Aligns with Frappe Framework conventions
- Meets ERPNext security standards
- Satisfies ERPNext performance requirements

**7.2 Code Quality Requirements:**
- Maintainability requirements are clear
- Documentation requirements are specified
- Testing coverage requirements are defined
- Code review criteria are established

### 8. Validation Results and Actions

**8.1 Validation Scoring:**
```yaml
validation_results:
  structure_compliance: [pass/fail]
  technical_feasibility: [pass/fail]
  frappe_compliance: [pass/fail]
  integration_readiness: [pass/fail]
  development_readiness: [pass/fail]
  overall_score: [ready/needs_work/major_issues]
```

**8.2 Action Determination:**

**If READY:**
- Mark story as "Ready for Development"
- Route to main-dev-coordinator for specialist assignment
- Add to development backlog
- Notify team of story availability

**If NEEDS_WORK:**
- Mark story as "Needs Refinement"
- Document specific issues and requirements
- Return to erpnext-scrum-master for revision
- Schedule refinement session

**If MAJOR_ISSUES:**
- Mark story as "Blocked"
- Escalate to erpnext-product-owner
- Document blocking issues
- Schedule architecture review if needed

### 9. Documentation and Handoff

**9.1 Validation Report:**
- Document all validation findings
- Provide specific improvement recommendations
- Include technical guidance for revision
- Set clear expectations for resolution

**9.2 Team Communication:**
- Notify relevant team members of validation results
- Update project tracking systems
- Communicate any blocking issues
- Schedule follow-up actions as needed

## Validation Criteria

A story passes validation when:

- All technical requirements are clearly defined
- Frappe Framework compliance is ensured
- Multi-app integration is properly planned
- Implementation is technically feasible
- Testing strategy is comprehensive
- Development context is complete
- Resource requirements are reasonable
- Quality standards are achievable

## Integration Points

- Receives stories from erpnext-scrum-master
- Reports validation results to erpnext-product-owner
- Routes approved stories to main-dev-coordinator
- Escalates issues to appropriate team members
- Provides feedback for story improvement process