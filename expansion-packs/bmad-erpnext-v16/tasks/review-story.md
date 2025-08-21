# review-story

## Metadata
- **Task ID**: review-story  
- **Type**: qa-comprehensive
- **Agent**: erpnext-test-architect
- **Outputs**: Story QA Results section + Quality Gate

## Description
Comprehensive test architecture review combining requirements tracing, test analysis, code quality assessment, and active refactoring when safe. Results in quality gate decision.

## Execution Steps

### 1. Pre-Review Setup
- Load story from docs/stories/
- Identify all related code files
- Locate test files
- Review previous QA feedback

### 2. Requirements Traceability
- Map each acceptance criterion to tests
- Verify test completeness
- Check assertion adequacy
- Document coverage gaps

### 3. Test Architecture Analysis

#### Test Level Distribution
- Count unit tests (should be 60-70%)
- Count integration tests (should be 20-30%)
- Count E2E tests (should be 10-20%)
- Assess appropriateness

#### Test Quality Assessment
- Check for flaky tests
- Verify no hard waits
- Ensure tests are stateless
- Confirm parallel safety
- Check self-cleaning

#### Coverage Analysis
- Line coverage percentage
- Branch coverage percentage
- Critical path coverage
- Edge case coverage

### 4. Code Quality Review

#### Frappe-First Compliance
- Verify no external libraries when Frappe provides
- Check proper use of Frappe utilities
- Ensure correct patterns

#### Security Review
- API whitelisting verification
- Permission checks
- Input validation
- SQL injection prevention

#### Performance Review
- Query optimization
- Caching usage
- Background job usage
- Pagination implementation

### 5. Active Refactoring
When safe and improves quality:
- Fix obvious bugs
- Improve error handling
- Enhance validations
- Optimize queries
- Add missing tests
- Improve naming
- Extract complex logic

### 6. Quality Gate Decision

#### Gate Criteria
**PASS Requirements**:
- All P0 acceptance criteria have tests
- No critical security issues
- No data integrity risks
- Core functionality works
- Tests are passing

**CONCERNS Triggers**:
- Missing non-critical tests
- Performance not optimized
- Code quality issues
- Documentation gaps
- Minor security concerns

**FAIL Triggers**:
- Critical functionality untested
- Security vulnerabilities
- Data loss risks
- Failing tests
- Risk score ≥9 unmitigated

## Output Format

### Story File Update
Add to QA Results section:

```markdown
## QA Results

### Test Architecture Review
**Date**: {YYYY-MM-DD}
**Reviewer**: Test Architect

#### Coverage Analysis
- Requirements Coverage: X%
- Test Distribution: Unit(X%), Integration(X%), E2E(X%)
- Line Coverage: X%
- Critical Path Coverage: X%

#### Requirements Traceability
✅ AC1: Fully tested by `test_method1`, `test_method2`
⚠️ AC2: Partially tested, missing error scenarios
❌ AC3: No test coverage

#### Test Quality
**Strengths**:
- Good unit test coverage
- Proper use of FrappeTestCase
- Tests are self-cleaning

**Issues Found & Fixed**:
- Fixed flaky test in `test_async_operation`
- Added missing permission test
- Improved query performance in `get_items`

#### Code Improvements Made
1. Refactored `complex_method` for clarity
2. Added input validation to API endpoint
3. Fixed N+1 query in data fetching
4. Enhanced error messages

#### Remaining Concerns
- Performance with >10000 records untested
- Edge case for concurrent updates needs coverage
- Documentation could be more comprehensive

### Quality Gate Decision
**Status**: PASS | CONCERNS | FAIL
**Gate File**: docs/qa/gates/{epic}.{story}-{YYYYMMDD}.yml

**Justification**: {Detailed reason for decision}

**Conditions for PASS** (if CONCERNS):
1. Add performance tests for large datasets
2. Document edge cases
3. Add integration test for workflow
```

### Gate File Creation
Create `docs/qa/gates/{epic}.{story}-{YYYYMMDD}.yml`:

```yaml
gate_id: "{epic}.{story}-{YYYYMMDD}"
story: "{epic}.{story}"
date: "{YYYY-MM-DD}"
reviewer: "Test Architect"
status: "PASS" | "CONCERNS" | "FAIL" | "WAIVED"

summary:
  requirements_coverage: 85
  test_quality_score: B
  code_quality_score: A
  security_score: A
  performance_score: B

findings:
  critical: []
  high:
    - id: "FIND-001"
      description: "Performance degradation with large datasets"
      severity: "high"
      status: "acknowledged"
  
  medium:
    - id: "FIND-002"
      description: "Missing edge case tests"
      severity: "medium"
      status: "accepted"

improvements_made:
  - "Fixed SQL injection vulnerability"
  - "Added permission checks"
  - "Optimized database queries"
  - "Enhanced error handling"

conditions:
  - "Performance tests for >10000 records"
  - "Document complex business logic"

waiver:  # Only if WAIVED
  reason: "Time constraints for minor issues"
  approved_by: "Product Owner"
  expires: "2024-04-01"

next_steps:
  - "Continue to deployment"
  - "Schedule performance testing"
```

## ERPNext-Specific Review Points

### DocType Review
- Field validations appropriate
- Permissions properly configured
- Workflows correctly defined
- Link fields maintain integrity

### API Review
- All methods @frappe.whitelist()
- Permission checks implemented
- Uses frappe.db methods
- Proper error handling with frappe.throw()

### Frontend Review
- Native Vue patterns (no /frontend/)
- Bundle.js entry points correct
- SetVueGlobals() used
- Frappe UI components utilized

## Active Refactoring Guidelines

### Safe to Refactor
- Obvious typos and naming
- Missing error handling
- Unoptimized queries
- Missing validations
- Code formatting
- Extract repeated code

### Requires Caution
- Business logic changes
- Database schema changes
- API contract changes
- Permission modifications

### Never Change Without Approval
- Core business rules
- Integration points
- Data migrations
- Security mechanisms