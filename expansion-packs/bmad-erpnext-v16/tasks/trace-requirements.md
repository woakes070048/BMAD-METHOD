# trace-requirements

## Metadata
- **Task ID**: trace-requirements
- **Type**: qa-verification
- **Agent**: erpnext-test-architect  
- **Outputs**: docs/qa/assessments/{epic}.{story}-trace-{YYYYMMDD}.md

## Description
Verify that every acceptance criterion in the story has corresponding test coverage. Create a traceability matrix linking requirements to tests.

## Execution Steps

### 1. Requirements Extraction
- List all acceptance criteria from story
- Identify implicit requirements
- Note NFRs that need validation
- Extract business rules

### 2. Test Inventory
- Scan implemented test files
- Identify test methods
- Map tests to test levels
- Note test assertions

### 3. Traceability Mapping
For each acceptance criterion:
- Find corresponding test(s)
- Verify test completeness
- Check assertion adequacy
- Note coverage gaps

### 4. Gap Analysis
- Identify uncovered requirements
- Find redundant tests
- Spot missing edge cases
- Note inadequate assertions

### 5. Coverage Assessment
- Calculate requirement coverage %
- Assess test distribution
- Evaluate test quality
- Rate overall coverage

## Output Format

```markdown
# Requirements Traceability: {Epic}.{Story}
Date: {YYYY-MM-DD}
Analyst: Test Architect

## Coverage Summary
- Total Requirements: X
- Covered Requirements: X
- Coverage Percentage: X%
- Gap Severity: {None|Low|Medium|High|Critical}

## Traceability Matrix

### Acceptance Criterion 1: {Description}
**Status**: ✅ Fully Covered | ⚠️ Partially Covered | ❌ Not Covered
**Tests**:
- `test_file.py::TestClass::test_method` - Unit
  - Validates: {What it tests}
  - Assertions: {Key assertions}
- `test_integration.py::test_scenario` - Integration
  - Validates: {What it tests}
  - Coverage: {Complete|Partial}

### Acceptance Criterion 2: {Description}
**Status**: ⚠️ Partially Covered
**Tests**:
- `test_file.py::test_partial` - Unit
  - Validates: {What it tests}
  - **GAP**: Missing validation for {specific aspect}

### Business Rules
| Rule | Test Coverage | Status |
|------|--------------|--------|
| {Rule 1} | `test_method` | ✅ |
| {Rule 2} | None | ❌ |

### NFR Coverage
| Requirement | Test Coverage | Status |
|------------|--------------|--------|
| Performance | `test_large_dataset` | ✅ |
| Security | `test_permissions` | ✅ |
| Reliability | None | ❌ |

## Coverage Gaps

### Critical Gaps
1. **AC-3**: No test coverage for {scenario}
   - Impact: High
   - Recommended Test: Integration test for {flow}

### Medium Priority Gaps
1. **Business Rule X**: Edge case not tested
   - Current Coverage: Happy path only
   - Missing: Error scenarios

## Test Quality Assessment

### Well-Covered Areas
- DocType validations (100% coverage)
- API permission checks (100% coverage)
- Basic CRUD operations (95% coverage)

### Under-Covered Areas
- Error handling (40% coverage)
- Edge cases (30% coverage)
- Performance scenarios (20% coverage)

## Recommendations
1. Add integration test for {workflow}
2. Enhance error scenario testing
3. Add performance benchmarks
4. Improve assertion specificity

## Gate Impact
- Coverage Status: {Acceptable|Needs Improvement|Insufficient}
- Recommended Action: {Proceed|Add Tests|Block}
```

## ERPNext-Specific Traceability

### DocType Requirements
Map each DocType feature to tests:
- Field validations → Unit tests
- Permissions → Permission tests
- Workflows → Integration tests
- Controllers → Method tests

### API Requirements
Map each API endpoint to tests:
- @frappe.whitelist() → Security tests
- Input validation → Unit tests
- Business logic → Integration tests
- Response format → Contract tests

### Frontend Requirements
Map each UI feature to tests:
- Component rendering → Component tests
- User interactions → E2E tests
- State management → Unit tests
- API integration → Integration tests

## Coverage Standards
- Minimum acceptable: 70%
- Target coverage: 85%
- Critical path coverage: 100%
- Security features: 100%