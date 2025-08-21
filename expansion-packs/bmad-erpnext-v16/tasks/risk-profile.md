# risk-profile

## Metadata
- **Task ID**: risk-profile
- **Type**: qa-assessment
- **Agent**: erpnext-test-architect
- **Outputs**: docs/qa/assessments/{epic}.{story}-risk-{YYYYMMDD}.md

## Description
Assess implementation risks for an ERPNext story before development begins. Identify potential issues early to guide development and testing strategies.

## Execution Steps

### 1. Context Gathering
- Read the story draft thoroughly
- Review related PRD sections
- Check architecture specifications
- Identify dependencies and integrations

### 2. Risk Categories Assessment

#### Technical Risks
- Complex DocType relationships
- Permission model complexity
- Database migration impacts
- Performance bottlenecks
- Integration points

#### Security Risks
- API exposure without proper whitelisting
- Permission bypass possibilities
- Data exposure risks
- Input validation gaps
- Cross-site scripting vulnerabilities

#### Data Risks
- Data migration requirements
- Data integrity concerns
- Backup/recovery impacts
- Multi-tenant data isolation

#### Business Risks
- Process disruption potential
- User adoption challenges
- Training requirements
- Rollback complexity

#### Performance Risks
- Large dataset handling
- Query optimization needs
- Caching requirements
- Real-time update impacts

#### Operational Risks
- Deployment complexity
- Monitoring requirements
- Support burden increase
- Documentation gaps

### 3. Risk Scoring
For each identified risk:
- **Probability**: 1-3 (Low/Medium/High)
- **Impact**: 1-3 (Low/Medium/High)
- **Risk Score**: Probability × Impact (1-9)

### 4. Risk Mitigation Strategies
For each risk ≥ 4:
- Define specific mitigation actions
- Identify preventive measures
- Specify testing requirements
- Document rollback procedures

### 5. Gate Impact Assessment
- Risks with score ≥ 9: Triggers FAIL gate
- Risks with score ≥ 6: Triggers CONCERNS gate
- Document waiver requirements if needed

## Output Format

```markdown
# Risk Profile: {Epic}.{Story}
Date: {YYYY-MM-DD}
Assessor: Test Architect

## Summary
- Total Risks Identified: X
- Critical Risks (≥9): X
- High Risks (6-8): X
- Medium Risks (4-5): X
- Low Risks (1-3): X

## Risk Assessment

### Critical Risks
[For each critical risk]
**Risk ID**: RISK-001
**Category**: {Technical|Security|Data|Business|Performance|Operational}
**Description**: {Detailed risk description}
**Probability**: 3 (High)
**Impact**: 3 (High)
**Score**: 9 (Critical)
**Mitigation Strategy**:
- {Specific action 1}
- {Specific action 2}
**Testing Requirements**:
- {Test scenario 1}
- {Test scenario 2}

### High Priority Risks
[Similar format for risks 6-8]

### Medium Priority Risks
[Similar format for risks 4-5]

## Recommendations
1. {Key recommendation 1}
2. {Key recommendation 2}

## Gate Impact
- Recommended Gate Status: {PASS|CONCERNS|FAIL}
- Waiver Required: {Yes|No}
- Waiver Justification: {If applicable}
```

## ERPNext-Specific Considerations
- DocType permission model complexity
- Multi-app integration impacts
- Frappe Framework limitations
- Bench deployment requirements
- Site-specific configurations