# gate

## Metadata
- **Task ID**: gate
- **Type**: qa-decision
- **Agent**: erpnext-test-architect
- **Outputs**: docs/qa/gates/{epic}.{story}-{slug}.yml

## Description
Update or create quality gate decision for a story. Used after addressing review feedback or when gate status needs updating.

## Execution Steps

### 1. Context Gathering
- Review current gate status (if exists)
- Check recent changes/fixes
- Review test execution results
- Assess risk mitigation

### 2. Gate Status Determination

#### PASS Criteria
All must be true:
- All critical requirements tested
- No unmitigated critical risks (score ≥9)
- Core functionality working
- Security vulnerabilities addressed
- Data integrity maintained
- Tests passing

#### CONCERNS Criteria
Any of:
- Non-critical test gaps
- Medium risks (score 6-8) acknowledged
- Performance not fully optimized
- Documentation incomplete
- Minor code quality issues
- Non-blocking improvements needed

#### FAIL Criteria
Any of:
- Critical functionality untested
- Unmitigated critical risks (score ≥9)
- Security vulnerabilities present
- Data loss/corruption possible
- Core tests failing
- Blocking defects unresolved

#### WAIVED Criteria
Requires:
- Explicit acknowledgment of issues
- Business justification
- Approver identification
- Expiration date
- Risk acceptance documented

### 3. Gate Documentation

## Output Format

```yaml
gate_id: "{epic}.{story}-{YYYYMMDD}"
story: "{epic}.{story}"
date: "{YYYY-MM-DD}"
reviewer: "Test Architect"
status: "PASS" | "CONCERNS" | "FAIL" | "WAIVED"
update_reason: "Initial review" | "Post-fix verification" | "Reassessment"

summary:
  requirements_coverage: {0-100}
  test_quality_score: {A-F}
  code_quality_score: {A-F}
  security_score: {A-F}
  performance_score: {A-F}
  overall_confidence: {High|Medium|Low}

risk_assessment:
  critical_risks: {count}
  high_risks: {count}
  medium_risks: {count}
  mitigated_risks: {count}
  accepted_risks: {count}

test_metrics:
  total_tests: {number}
  passing_tests: {number}
  failing_tests: {number}
  skipped_tests: {number}
  coverage_percentage: {0-100}
  
findings:
  critical:
    - id: "CRIT-001"
      description: "{Finding description}"
      severity: "critical"
      status: "open" | "fixed" | "mitigated" | "accepted"
      mitigation: "{How addressed}"
  
  high:
    - id: "HIGH-001"
      description: "{Finding description}"
      severity: "high"
      status: "open" | "fixed" | "mitigated" | "accepted"
      mitigation: "{How addressed}"
  
  medium:
    - id: "MED-001"
      description: "{Finding description}"
      severity: "medium"
      status: "open" | "fixed" | "mitigated" | "accepted"
      
  low:
    - id: "LOW-001"
      description: "{Finding description}"
      severity: "low"
      status: "acknowledged"

frappe_compliance:
  frappe_first: true | false
  blocked_libraries: []
  pattern_violations: []
  security_compliance: true | false

improvements_tracking:
  requested:
    - "{Improvement 1}"
    - "{Improvement 2}"
  completed:
    - "{Completed improvement 1}"
    - "{Completed improvement 2}"
  pending:
    - "{Pending improvement 1}"

conditions:  # For CONCERNS status
  must_fix:
    - "{Critical condition 1}"
  should_fix:
    - "{Recommended condition 1}"
  nice_to_have:
    - "{Optional improvement 1}"

waiver:  # Only if WAIVED
  reason: "{Business justification}"
  risks_acknowledged:
    - "{Risk 1}"
    - "{Risk 2}"
  approved_by: "{Name and role}"
  approval_date: "{YYYY-MM-DD}"
  expires: "{YYYY-MM-DD}"
  review_required: "{YYYY-MM-DD}"

next_steps:
  immediate:
    - "{Action 1}"
  short_term:
    - "{Action 1}"
  long_term:
    - "{Action 1}"

notes: |
  {Additional context or explanations}
  {Special considerations}
  {Dependencies or blockers}
```

## Gate Status Transitions

### Valid Transitions
- FAIL → CONCERNS (after critical fixes)
- FAIL → PASS (after all fixes)
- CONCERNS → PASS (after addressing conditions)
- CONCERNS → FAIL (if new critical issues found)
- Any → WAIVED (with approval)

### Invalid Transitions
- PASS → FAIL (without new findings)
- WAIVED → FAIL (waiver must be revoked first)

## ERPNext-Specific Gate Checks

### Mandatory Validations
1. All DocTypes have permission checks
2. All APIs use @frappe.whitelist()
3. No raw SQL without parameters
4. No external libraries when Frappe provides
5. Tests use FrappeTestCase
6. Frontend uses native patterns

### Quality Thresholds
- Minimum test coverage: 70%
- Critical path coverage: 100%
- Security features coverage: 100%
- Permission tests: Required
- API validation tests: Required

## Waiver Process

### When Waivers Are Appropriate
- Time constraints with documented tech debt
- Acceptable risk for business benefit
- Temporary workaround with fix planned
- Third-party limitation acknowledged

### Waiver Requirements
1. Document all risks clearly
2. Get explicit approval from authorized person
3. Set expiration date (max 90 days)
4. Schedule review date
5. Create follow-up story for fixes

### Waiver Template
```markdown
## Waiver Request
**Story**: {epic}.{story}
**Requested By**: {Name}
**Date**: {YYYY-MM-DD}

### Issues Being Waived
1. {Issue 1 description and impact}
2. {Issue 2 description and impact}

### Business Justification
{Why waiver is needed}

### Risk Mitigation
{How risks will be managed}

### Commitment
- Fix planned for: {Date/Sprint}
- Review scheduled: {Date}
- Responsible party: {Name}

### Approval
- Approved By: {Name, Role}
- Date: {YYYY-MM-DD}
- Valid Until: {YYYY-MM-DD}
```