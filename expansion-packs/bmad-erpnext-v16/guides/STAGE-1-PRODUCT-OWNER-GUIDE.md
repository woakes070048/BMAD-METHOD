# STAGE 1: Product Owner Guide - Mrs. Frederic

## Overview

This guide covers Stage 1 of the BMAD ERPNext v16 development process, led by **Mrs. Frederic (erpnext-product-owner)**. This stage focuses on vision setting, requirement prioritization, and strategic planning for ERPNext implementations.

## Agent Activation

```bash
/bmadErpNext:agent:erpnext-product-owner
"Help me plan and prioritize ERPNext features for my business"
```

## Stage Objectives

### Primary Goals
1. **Vision Definition**: Establish clear business objectives for ERPNext implementation
2. **Requirement Prioritization**: Define and prioritize features based on business value
3. **Scope Management**: Determine MVP and future enhancement roadmap
4. **Stakeholder Alignment**: Ensure all stakeholders understand the vision and priorities

### Deliverables
- Product Requirements Document (PRD)
- Feature prioritization matrix
- MVP definition
- Development roadmap
- Acceptance criteria templates

## Key Activities

### 1. Vision and Strategy Definition

**Commands:**
```bash
/bmadErpNext:agent:erpnext-product-owner
"Define the business vision for our ERPNext implementation focusing on [your business domain]"
```

**Activities:**
- Conduct stakeholder interviews
- Define business objectives and success metrics
- Identify key business processes to be supported
- Establish ERPNext customization strategy

**Templates to Use:**
- `erpnext-prd-template.yaml`
- `business-requirements-template.yaml`
- `erpnext-project-brief-template.yaml`

### 2. Requirement Gathering and Analysis

**Commands:**
```bash
/bmadErpNext:agent:erpnext-product-owner
"Help me analyze and prioritize these business requirements: [list requirements]"
```

**Key Questions:**
- What are the critical business processes?
- Which ERPNext modules are needed?
- What custom functionality is required?
- What are the integration requirements?
- What are the reporting and analytics needs?

### 3. Feature Prioritization

**Priority Framework:**
- **P0 (Critical)**: Core business functionality, compliance requirements
- **P1 (High)**: Important efficiency improvements, key integrations
- **P2 (Medium)**: Nice-to-have features, advanced reporting
- **P3 (Low)**: Future enhancements, experimental features

**Commands:**
```bash
/bmadErpNext:agent:erpnext-product-owner
"Create a prioritized feature list for my ERPNext implementation with these requirements: [requirements]"
```

### 4. MVP Definition

**MVP Criteria:**
- Minimum viable functionality for business operations
- Core DocTypes and workflows
- Essential user roles and permissions
- Basic reporting capabilities

**Commands:**
```bash
/bmadErpNext:agent:erpnext-product-owner
"Define the MVP scope for my ERPNext project focusing on [business area]"
```

## ERPNext-Specific Considerations

### Standard Module Assessment
- **Accounts**: Financial management requirements
- **Sales**: CRM and sales process needs
- **Purchase**: Procurement and vendor management
- **Stock**: Inventory and warehouse management
- **Manufacturing**: Production planning requirements
- **Projects**: Project management needs
- **HR**: Human resource management
- **Assets**: Asset tracking and maintenance

### Custom Development Areas
- Custom DocTypes for business-specific entities
- Specialized workflows and approval processes
- Integration with external systems
- Custom reports and dashboards
- Mobile and offline requirements

## Stage 1 Checklist

### Vision and Strategy
- [ ] Business objectives clearly defined
- [ ] ERPNext fit assessment completed
- [ ] Stakeholder alignment achieved
- [ ] Success metrics established

### Requirements
- [ ] Functional requirements documented
- [ ] Non-functional requirements identified
- [ ] Integration requirements specified
- [ ] Reporting requirements defined

### Prioritization
- [ ] Feature prioritization matrix created
- [ ] MVP scope defined
- [ ] Development roadmap established
- [ ] Resource requirements estimated

### Documentation
- [ ] Product Requirements Document completed
- [ ] User personas and stories defined
- [ ] Acceptance criteria templates created
- [ ] Risk assessment conducted

## Handoff to Stage 2

### Deliverables for Business Analyst
- Completed PRD with prioritized requirements
- Business process documentation
- Stakeholder contact information
- Defined success metrics and KPIs

### Handoff Command
```bash
/bmadErpNext:agent:main-dev-coordinator
"Ready to hand off Stage 1 Product Owner deliverables to Business Analyst for Stage 2"
```

## Common Patterns

### New Business Implementation
```bash
/bmadErpNext:agent:erpnext-product-owner
"I'm implementing ERPNext for a [business type] company. Help me define the product vision and requirements."
```

### Existing ERP Migration
```bash
/bmadErpNext:agent:erpnext-product-owner
"We're migrating from [current system] to ERPNext. Help me plan the transition and define requirements."
```

### Module Enhancement
```bash
/bmadErpNext:agent:erpnext-product-owner
"We need to enhance our existing ERPNext [module] with [specific functionality]. Help me prioritize and plan this."
```

## Success Metrics

### Stage Completion Indicators
- Clear, documented product vision
- Prioritized requirement backlog
- Defined MVP scope
- Stakeholder sign-off on priorities
- Ready handoff to Stage 2

### Quality Gates
- All requirements have business justification
- MVP is achievable within timeline
- Technical feasibility confirmed
- Resource availability validated

## Tips for Success

1. **Think ERPNext-First**: Leverage standard ERPNext functionality before considering customization
2. **Start Small**: Focus on MVP that delivers immediate business value
3. **Involve Users**: Include end users in requirement definition and prioritization
4. **Consider Integration**: Plan for integration with existing systems early
5. **Document Decisions**: Keep clear records of why features were prioritized or deprioritized

## Next Stage

Once Stage 1 is complete, proceed to [STAGE-2-BUSINESS-ANALYST-GUIDE.md](STAGE-2-BUSINESS-ANALYST-GUIDE.md) for detailed business process analysis and solution design.

---

**Stage 1 Owner**: Mrs. Frederic (erpnext-product-owner)  
**Estimated Duration**: 1-2 weeks for most projects  
**Key Focus**: Vision, Requirements, Prioritization