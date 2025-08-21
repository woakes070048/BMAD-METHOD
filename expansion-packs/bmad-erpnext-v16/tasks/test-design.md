# test-design

## Metadata
- **Task ID**: test-design
- **Type**: qa-strategy
- **Agent**: erpnext-test-architect
- **Outputs**: docs/qa/assessments/{epic}.{story}-test-design-{YYYYMMDD}.md

## Description
Create comprehensive test strategy for an ERPNext story, defining what tests to write, at what levels, and with what priority based on risk assessment.

## Execution Steps

### 1. Requirements Analysis
- Extract all acceptance criteria from story
- Identify functional requirements
- Note non-functional requirements
- Map DocType operations to test

### 2. Test Level Planning

#### Unit Tests (FrappeTestCase)
- DocType field validations
- Controller method logic
- Utility function behavior
- Permission checks
- Business rule enforcement

#### Integration Tests
- DocType relationships
- API endpoint functionality
- Workflow transitions
- Event handlers
- Background job processing

#### End-to-End Tests
- Complete user journeys
- Multi-step workflows
- Cross-module interactions
- Report generation
- Data import/export flows

### 3. Test Scenario Definition
For each acceptance criterion:
- Define Given-When-Then scenarios
- Specify test data requirements
- Identify mock/stub needs
- Note edge cases
- Document negative tests

### 4. Risk-Based Prioritization
- **P0 (Critical)**: Must pass for story acceptance
- **P1 (High)**: Should pass for quality
- **P2 (Medium)**: Nice to have for coverage

### 5. Test Data Strategy
- Define test fixtures
- Specify data setup/teardown
- Document test user roles
- Plan for multi-tenant testing

## Output Format

```markdown
# Test Design: {Epic}.{Story}
Date: {YYYY-MM-DD}
Designer: Test Architect

## Test Summary
- Total Test Scenarios: X
- Unit Tests: X
- Integration Tests: X
- E2E Tests: X

## Priority Distribution
- P0 (Critical): X tests
- P1 (High): X tests
- P2 (Medium): X tests

## Test Scenarios

### Acceptance Criterion 1: {Description}

#### TEST-001: {Test Name} [P0]
**Level**: Unit
**Given**: {Initial state}
**When**: {Action taken}
**Then**: {Expected outcome}
**Test Data**: 
- {Data requirement 1}
- {Data requirement 2}
**Implementation Notes**:
```python
class Test{DocType}(FrappeTestCase):
    def test_{scenario}(self):
        # Test implementation guidance
```

### DocType Tests

#### Field Validations
- Required fields enforcement
- Field type validations
- Unique constraints
- Link field integrity

#### Permission Tests
- Role-based access
- Document-level permissions
- Field-level permissions
- Workflow state permissions

### API Tests

#### Whitelisted Methods
- Permission checks
- Input validation
- Response format
- Error handling

### Frontend Tests (if applicable)

#### Vue Component Tests
- Component rendering
- User interactions
- State management
- API integration

## Test Execution Strategy

### Setup Requirements
- Test database configuration
- Test site creation
- Fixture loading
- User role setup

### Execution Order
1. Unit tests first
2. Integration tests
3. E2E tests last

### CI/CD Integration
- bench run-tests configuration
- Test parallelization
- Coverage requirements
- Failure notifications

## Coverage Goals
- Line Coverage: ≥80%
- Branch Coverage: ≥70%
- Critical Path Coverage: 100%

## Risk Mitigation Through Testing
[Map to risks from risk-profile]
- RISK-001: Mitigated by TEST-003, TEST-007
- RISK-002: Mitigated by TEST-005, TEST-009
```

## ERPNext-Specific Test Patterns

### DocType Testing
```python
from frappe.tests.utils import FrappeTestCase
import frappe

class TestMyDocType(FrappeTestCase):
    def setUp(self):
        # Create test records
        self.test_doc = frappe.get_doc({
            "doctype": "MyDocType",
            "field": "value"
        }).insert()
    
    def tearDown(self):
        # Cleanup
        frappe.db.rollback()
```

### API Testing
```python
def test_whitelisted_method(self):
    # Test with proper user
    frappe.set_user("test@example.com")
    response = frappe.call("app.api.method", param="value")
    self.assertEqual(response["status"], "success")
    
    # Test permission denial
    frappe.set_user("Guest")
    self.assertRaises(frappe.PermissionError, 
                     frappe.call, "app.api.method")
```