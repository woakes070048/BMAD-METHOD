# Agent-Driven Structure Validation Checklist
## Preventing DocFlow/Server Manager Issues Through BMAD Expansion Pack Agents

**Primary Agent**: Eva Thorne (App Structure Validator)  
**Supporting Agents**: Claudia Donovan, Allison Blake, Nathan Stark  
**Purpose**: 100% prevention of structural anti-patterns through AI-driven validation  
**Reference**: Based on DocFlow retrospective and Server Manager analysis  

---

## 🚨 MANDATORY PRE-DEVELOPMENT PHASE

### 1. Eva Thorne Structure Planning (REQUIRED)
- [ ] **Activate Eva Thorne**: `/bmadErpNext:agent:app-structure-validator`
- [ ] **Request Structure Analysis**: "Eva, analyze Frappe CRM structure for [app_name] requirements"
- [ ] **Generate Template**: "Eva, create compliant structure template with proper import patterns"
- [ ] **Validate Template**: "Eva, score this template for compliance ≥95%"
- [ ] **Team Review**: Structure template approved by lead developer

**Agent Prompt for Planning**:
```
Eva, I'm planning a new Frappe app called '[app_name]' with these features:
- [Feature 1]
- [Feature 2] 
- [Feature N]

Please:
1. Analyze the Frappe CRM structure at /home/frappe/crm/crm
2. Create a compliant directory structure template
3. Define correct import patterns to avoid DocFlow violations
4. Ensure business logic stays at module root level
5. Provide compliance score (target: ≥95%)
6. Identify potential anti-patterns to avoid
```

### 2. Reference Standard Validation
- [ ] **CRM Structure Study**: Eva analyzes `/home/frappe/crm/crm` as gold standard
- [ ] **Import Pattern Analysis**: Eva documents correct import paths
- [ ] **Anti-Pattern Identification**: Eva identifies forbidden structures
- [ ] **Template Generation**: Eva creates app-specific structure template
- [ ] **Compliance Scoring**: Template achieves ≥95% compliance score

### 3. Multi-Agent Coordination Review
- [ ] **Claudia Donovan Review**: `/bmadErpNext:agent:main-dev-coordinator` validates team coordination
- [ ] **Allison Blake Compliance**: `/bmadErpNext:agent:frappe-compliance-validator` validates Frappe standards
- [ ] **Structure Approval**: All agents confirm template is production-ready
- [ ] **Documentation**: Template documented for team reference

---

## 🔄 DEVELOPMENT-TIME VALIDATION

### Daily Structure Monitoring (2 minutes/day)

#### Eva Thorne Daily Check
- [ ] **Activate Eva**: `/bmadErpNext:agent:app-structure-validator`
- [ ] **Daily Audit Request**: "Eva, perform daily structure audit on [app_name]"
- [ ] **Violation Review**: Address any new violations immediately
- [ ] **Compliance Tracking**: Monitor compliance score trends
- [ ] **Team Communication**: Report status to development team

**Daily Agent Prompt**:
```
Eva, perform daily structure audit on [app_name] at [path]:
1. Check for new directory structure violations
2. Validate any new import statements
3. Ensure no business logic added to business modules
4. Compare against approved template
5. Report compliance score changes
6. Flag any drift toward DocFlow anti-patterns
```

#### Import Pattern Validation (After each import change)
- [ ] **New Import Review**: Eva validates each new import statement
- [ ] **Pattern Compliance**: Imports follow approved patterns
- [ ] **Business Module Check**: No api/, services/, utils/ in business modules
- [ ] **Path Validation**: Import paths reference correct locations
- [ ] **Circular Dependency**: Eva checks for import circular dependencies

**Import Validation Prompt**:
```
Eva, validate these new imports in [app_name]:
[paste import changes]

Check for:
1. DocFlow-style violations (business logic in business modules)
2. Correct import path patterns
3. Compliance with Frappe standards
4. Circular dependency risks
5. Module root vs business module placement
```

### Git Integration Workflow
- [ ] **Pre-Commit Hook**: Eva validates structure before each commit
- [ ] **Violation Blocking**: Commits blocked if compliance drops <85%
- [ ] **Automated Alerts**: Real-time notifications for structure violations
- [ ] **Branch Protection**: Main branch requires structure validation
- [ ] **Team Notifications**: Automated alerts to team on violations

---

## 🎯 REAL-TIME VIOLATION PREVENTION

### DocFlow Anti-Pattern Detection
- [ ] **Business Logic Scanning**: Eva monitors for api/, services/, utils/ in business modules
- [ ] **Import Statement Analysis**: Eva validates import patterns continuously
- [ ] **Directory Structure Monitoring**: Eva watches for forbidden directory creation
- [ ] **Compliance Score Tracking**: Eva maintains real-time compliance scoring
- [ ] **Immediate Alerts**: Instant notifications when violations detected

### Agent-Driven Early Warning System
```yaml
warning_levels:
  green: "≥95% compliance - All good"
  yellow: "85-94% compliance - Minor issues detected"
  orange: "70-84% compliance - Intervention needed"
  red: "<70% compliance - STOP development"

alert_triggers:
  business_logic_in_module: "IMMEDIATE - Critical DocFlow violation"
  import_violation: "URGENT - Incorrect import pattern"
  structure_drift: "WARNING - Deviation from template"
  compliance_drop: "ALERT - Score decrease detected"
```

### Multi-Agent Response Protocol
- [ ] **Eva Thorne**: Primary structure validation
- [ ] **Claudia Donovan**: Team coordination and workflow management
- [ ] **Allison Blake**: Frappe compliance and quality assurance
- [ ] **Nathan Stark**: Integration impact assessment
- [ ] **Steve Jinks**: Testing validation requirements

---

## 🏆 PRE-DEPLOYMENT CERTIFICATION

### Comprehensive Eva Thorne Audit (15 minutes)
- [ ] **Activate for Final Audit**: `/bmadErpNext:agent:app-structure-validator`
- [ ] **Comprehensive Analysis**: "Eva, perform final deployment audit"
- [ ] **Compliance Certification**: Achieve ≥95% compliance score
- [ ] **Production Readiness**: Eva certifies app is deployment-ready
- [ ] **Documentation**: Generate compliance report for stakeholders

**Final Audit Prompt**:
```
Eva, perform comprehensive final audit of [app_name] before production deployment:

1. Complete structure compliance analysis
2. Validate all import patterns against standards
3. Verify no DocFlow-style anti-patterns exist
4. Check hooks.py configuration compliance
5. Validate module organization against Frappe CRM standard
6. Generate compliance score (require ≥95%)
7. Provide production deployment certification or rejection
8. Document any remaining risks or considerations
```

### Multi-Agent Final Validation Pipeline
- [ ] **Stage 1 - Eva Thorne**: Structure and compliance validation
- [ ] **Stage 2 - Allison Blake**: Frappe framework compliance
- [ ] **Stage 3 - Nathan Stark**: Integration compatibility validation
- [ ] **Stage 4 - Steve Jinks**: Quality assurance and testing validation
- [ ] **Stage 5 - Claudia Donovan**: Final coordination and deployment approval

### Import Resolution Testing
- [ ] **Console Testing**: All imports resolve correctly in Frappe console
- [ ] **Functional Testing**: App features work with clean structure
- [ ] **Performance Testing**: No performance impact from structure
- [ ] **Integration Testing**: Multi-app compatibility verified
- [ ] **Migration Testing**: Deployment process tested

---

## 🚨 EMERGENCY RESPONSE PROTOCOLS

### Critical Violations (Compliance <50%) - EMERGENCY PROTOCOL

#### Immediate Actions (Within 1 hour)
- [ ] **STOP Development**: Halt all coding immediately
- [ ] **Emergency Backup**: Create emergency backup branch
- [ ] **Activate Eva**: `/bmadErpNext:agent:app-structure-validator` for emergency analysis
- [ ] **Team Alert**: Notify all team members of critical violation
- [ ] **Assessment**: Eva provides emergency assessment and migration plan

**Emergency Agent Prompt**:
```
EMERGENCY: Critical structure violations detected in [app_name].
Current compliance: [score]%

Eva, provide immediate emergency response:
1. Analyze current structure violations
2. Compare to DocFlow failure patterns
3. Create step-by-step migration plan
4. Identify immediate risks
5. Provide timeline for remediation
6. Coordinate with other agents for emergency response
```

#### Emergency Response Team Activation
- [ ] **Lead**: Eva Thorne (structure analysis and remediation)
- [ ] **Coordinator**: Claudia Donovan (team coordination)
- [ ] **Quality**: Allison Blake (compliance oversight)
- [ ] **Integration**: Nathan Stark (impact assessment)
- [ ] **Stakeholder Communication**: Project manager notification

### Moderate Violations (50-84% Compliance) - INTERVENTION PROTOCOL

#### Structured Remediation (Within 24 hours)
- [ ] **Create Fix Branch**: Structure-remediation branch
- [ ] **Eva Analysis**: Detailed violation analysis and fix plan
- [ ] **Team Coordination**: Coordinate fixes with Claudia Donovan
- [ ] **Fix Implementation**: Step-by-step structure corrections
- [ ] **Validation**: Re-test compliance after each fix

**Intervention Agent Prompt**:
```
Moderate structure violations detected in [app_name].
Current compliance: [score]%

Eva, provide structured remediation plan:
1. List specific violations with locations
2. Prioritize fixes by impact and effort
3. Provide step-by-step remediation steps
4. Estimate time required for each fix
5. Identify dependencies between fixes
6. Create testing plan for validation
```

---

## 📊 AGENT-DRIVEN METRICS & MONITORING

### Real-Time Compliance Dashboard
```yaml
dashboard_metrics:
  current_compliance_score: "Real-time percentage"
  violation_count: "Active violations by type"
  compliance_trend: "Score changes over time"
  agent_activity: "Eva Thorne validation frequency"
  team_adoption: "Developer usage of validation"

alert_thresholds:
  compliance_drop_5_percent: "Yellow alert"
  compliance_drop_10_percent: "Orange alert"
  compliance_below_85_percent: "Red alert"
  docflow_pattern_detected: "Critical alert"
```

### Agent Coordination Tracking
- [ ] **Eva Thorne Activity**: Daily structure validations performed
- [ ] **Multi-Agent Handoffs**: Successful coordination between agents
- [ ] **Response Times**: Average time from violation to resolution
- [ ] **Prevention Success**: Issues caught before implementation
- [ ] **Team Engagement**: Developer interaction with agents

### Continuous Improvement Loop
- [ ] **Violation Pattern Analysis**: Eva learns from detected issues
- [ ] **Template Optimization**: Improve structure templates based on success
- [ ] **Agent Training**: Enhance validation patterns based on experience
- [ ] **Workflow Refinement**: Optimize agent interaction workflows
- [ ] **Knowledge Base Updates**: Document lessons learned for team

---

## ✅ SUCCESS CRITERIA & QUALITY GATES

### Primary Success Metrics
- [ ] **Zero DocFlow-style violations** in any new app
- [ ] **100% pre-development validation** using Eva Thorne
- [ ] **≥95% compliance score** for all apps at deployment
- [ ] **Real-time violation detection** with <5 minute response time
- [ ] **Zero structural remediation projects** needed post-deployment

### Quality Gate Requirements
```yaml
pre_development:
  template_approval: "Eva Thorne ≥95% compliance score"
  team_review: "Lead developer approval"
  documentation: "Structure plan documented"

development_time:
  daily_monitoring: "Eva Thorne daily checks performed"
  violation_prevention: "No new violations introduced"
  compliance_maintenance: "Score maintained ≥85%"

pre_deployment:
  final_audit: "Eva Thorne comprehensive certification"
  multi_agent_validation: "All supporting agents approve"
  production_readiness: "≥95% compliance + zero critical issues"
```

### Team Adoption Requirements
- [ ] **100% developer training** on agent-driven validation
- [ ] **Standard workflow adoption** for all new apps
- [ ] **Emergency protocol familiarity** for all team members
- [ ] **Agent interaction proficiency** for all developers
- [ ] **Continuous feedback loop** for process improvement

---

## 🎓 AGENT TRAINING & TEAM ENABLEMENT

### Developer Training on Agent Usage

#### Eva Thorne Interaction Training
- [ ] **Basic Agent Activation**: How to properly activate Eva Thorne
- [ ] **Effective Prompting**: Writing clear requests for structure validation
- [ ] **Interpretation Skills**: Understanding Eva's compliance reports
- [ ] **Response Actions**: How to act on Eva's recommendations
- [ ] **Escalation Procedures**: When to involve other agents

#### Practical Workshop Exercises
- [ ] **Template Generation**: Practice creating structure templates with Eva
- [ ] **Violation Detection**: Learn to identify structural anti-patterns
- [ ] **Import Validation**: Understand correct import patterns
- [ ] **Emergency Response**: Practice emergency protocol procedures
- [ ] **Multi-Agent Coordination**: Work with supporting agents effectively

### Knowledge Base Maintenance
- [ ] **Agent Interaction Examples**: Document successful Eva Thorne interactions
- [ ] **Common Violations**: Catalog structural issues and solutions
- [ ] **Best Practices**: Document proven successful patterns
- [ ] **Troubleshooting Guide**: Common agent interaction issues
- [ ] **Continuous Updates**: Regular knowledge base improvements

---

This checklist ensures that Eva Thorne and the BMAD expansion pack agents become an integral part of the development workflow, preventing structural issues before they occur rather than fixing them after the fact. The focus is on seamless integration that feels natural and beneficial to developers while maintaining rigorous standards.