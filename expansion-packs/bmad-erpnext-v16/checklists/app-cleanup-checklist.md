# App Cleanup Checklist

A comprehensive checklist to ensure safe and thorough ERPNext app cleanup operations while preserving all functionality.

## Metadata
```yaml
checklist_id: app-cleanup-checklist
title: "ERPNext App Cleanup Safety Checklist"
category: quality-assurance
version: "1.0.0"
critical: true
agent_compatibility: ["erpnext-app-cleaner", "app-auditor"]
```

## Pre-Cleanup Safety Checklist

### 🛡️ CRITICAL SAFETY REQUIREMENTS (MUST BE COMPLETED)

#### Prerequisites Validation
- [ ] **App Backup Created**
  - [ ] Full app directory backed up with timestamp
  - [ ] Backup integrity verified (can restore successfully)
  - [ ] Backup location documented and accessible
  - [ ] Database backup created if needed

- [ ] **Dependency Analysis Completed**
  - [ ] All DocTypes and their relationships mapped
  - [ ] Business logic dependencies identified
  - [ ] Import dependencies analyzed
  - [ ] Function usage patterns documented
  - [ ] Risk assessment matrix created

- [ ] **Environment Preparation**
  - [ ] Development/staging environment being used (NOT production)
  - [ ] Frappe bench access confirmed
  - [ ] Site name and app name verified
  - [ ] Required permissions available

### 📊 Understanding and Analysis

#### App Functionality Documentation
- [ ] **DocType Analysis Complete**
  - [ ] All DocTypes identified and cataloged
  - [ ] Custom fields and their purposes documented
  - [ ] Checkbox/conditional logic mapped
  - [ ] Validation rules understood
  - [ ] Workflow processes documented

- [ ] **Code Structure Analysis**
  - [ ] File dependency graph created
  - [ ] Import relationships mapped
  - [ ] Function call patterns analyzed
  - [ ] Dead code identification completed
  - [ ] Duplicate code detection finished

- [ ] **Business Logic Mapping**
  - [ ] Critical workflows identified
  - [ ] Conditional logic based on fields documented
  - [ ] Integration points mapped
  - [ ] API dependencies understood
  - [ ] Custom permission systems identified

### 🔍 Risk Assessment

#### High-Risk Components Identified
- [ ] **Files with Many Dependencies**
  - [ ] Core utility modules identified
  - [ ] Heavily imported files flagged
  - [ ] Central configuration files marked
  - [ ] Shared libraries cataloged

- [ ] **Business-Critical Logic**
  - [ ] DocType controllers with validation logic
  - [ ] Workflow transition functions
  - [ ] Custom API endpoints
  - [ ] Integration connectors
  - [ ] Financial calculation functions

- [ ] **Security-Sensitive Code**
  - [ ] Authentication mechanisms
  - [ ] Permission validation code
  - [ ] Data access controls
  - [ ] Encryption/decryption functions

## During Cleanup Checklist

### 🔄 Safe Operation Procedures

#### File Operations
- [ ] **Before Removing Any File**
  - [ ] Confirm file is not imported anywhere
  - [ ] Verify no critical functionality depends on it
  - [ ] Create individual backup with timestamp
  - [ ] Document reason for removal

- [ ] **Before Modifying Any File**
  - [ ] Create backup with clear naming convention
  - [ ] Document specific changes being made
  - [ ] Verify change doesn't break dependencies
  - [ ] Test change in isolation if possible

#### Function Consolidation
- [ ] **Before Consolidating Functions**
  - [ ] Verify functions are truly identical
  - [ ] Check all call sites for compatibility
  - [ ] Ensure parameters match exactly
  - [ ] Test consolidated function works
  - [ ] Update all import statements

#### Import Updates
- [ ] **When Fixing Import Dependencies**
  - [ ] Map old import paths to new ones
  - [ ] Update all references systematically
  - [ ] Verify no circular dependencies created
  - [ ] Test import resolution works
  - [ ] Document all import changes

### 📝 Documentation During Operations

#### Change Logging
- [ ] **Every Operation Logged**
  - [ ] Timestamp for each change
  - [ ] Specific files/functions affected
  - [ ] Reason for the change
  - [ ] Expected impact documented
  - [ ] Rollback procedure noted

- [ ] **Progress Tracking**
  - [ ] Completion percentage tracked
  - [ ] Issues encountered documented
  - [ ] Decisions made recorded
  - [ ] Deferred items noted

## Post-Cleanup Validation Checklist

### ✅ Functionality Verification

#### Core App Operations
- [ ] **App Import Test**
  - [ ] `import app_name` works without errors
  - [ ] All modules accessible
  - [ ] No import warnings or errors
  - [ ] Python compilation successful

- [ ] **DocType Operations**
  - [ ] Can create new documents for each DocType
  - [ ] Save operations work correctly
  - [ ] Submit/cancel operations function (if applicable)
  - [ ] Validation rules still apply
  - [ ] Field defaults work properly

#### Business Logic Validation
- [ ] **Conditional Logic Testing**
  - [ ] Checkbox-based logic still functions
  - [ ] Field validation rules work
  - [ ] Workflow transitions operate correctly
  - [ ] Custom calculations accurate
  - [ ] Integration points functional

- [ ] **Data Integrity Checks**
  - [ ] Existing data accessible
  - [ ] No data corruption detected
  - [ ] Reports generate correctly
  - [ ] Exports/imports work
  - [ ] Search functionality intact

### 🛠️ Technical Validation

#### Code Quality Checks
- [ ] **No Broken Dependencies**
  - [ ] All imports resolve correctly
  - [ ] Function calls work as expected
  - [ ] Module references valid
  - [ ] Asset loading functional

- [ ] **Performance Validation**
  - [ ] Page load times acceptable
  - [ ] Query performance maintained
  - [ ] Memory usage normal
  - [ ] No new performance bottlenecks

#### Security Validation
- [ ] **Permission Systems Intact**
  - [ ] Role-based access working
  - [ ] API endpoints properly secured
  - [ ] Data access controls functional
  - [ ] Authentication mechanisms working

### 📋 Quality Assurance

#### Comprehensive Testing
- [ ] **User Workflow Testing**
  - [ ] Primary user workflows tested
  - [ ] Edge cases verified
  - [ ] Error handling works
  - [ ] User interface responsive
  - [ ] Mobile compatibility maintained

- [ ] **Integration Testing**
  - [ ] External API calls work
  - [ ] Database operations function
  - [ ] File uploads/downloads work
  - [ ] Email notifications send
  - [ ] Scheduled jobs execute

## Post-Cleanup Reporting Checklist

### 📊 Report Generation

#### Cleanup Summary
- [ ] **Metrics Documented**
  - [ ] Files removed count
  - [ ] Files modified count
  - [ ] Functions consolidated count
  - [ ] Import issues fixed count
  - [ ] Code quality improvement percentage

- [ ] **Changes Cataloged**
  - [ ] Complete list of removed files
  - [ ] All modified files documented
  - [ ] Function consolidation details
  - [ ] Import dependency changes
  - [ ] Performance impact measured

#### Safety Documentation
- [ ] **Rollback Procedures**
  - [ ] Complete rollback instructions written
  - [ ] Backup locations documented
  - [ ] Recovery time estimates provided
  - [ ] Emergency contact information included
  - [ ] Rollback testing performed

### 🔄 Handoff and Communication

#### Team Communication
- [ ] **Stakeholder Notification**
  - [ ] Development team informed
  - [ ] QA team briefed
  - [ ] Business stakeholders updated
  - [ ] Documentation team notified
  - [ ] Support team informed

- [ ] **Knowledge Transfer**
  - [ ] Changes explained to team
  - [ ] New structure documented
  - [ ] Testing procedures shared
  - [ ] Monitoring requirements communicated
  - [ ] Maintenance guidelines provided

## Emergency Procedures Checklist

### 🚨 If Issues Are Detected

#### Immediate Response
- [ ] **Stop Further Changes**
  - [ ] Halt any ongoing cleanup operations
  - [ ] Document current state
  - [ ] Assess scope of issues
  - [ ] Determine rollback necessity

- [ ] **Issue Assessment**
  - [ ] Identify affected functionality
  - [ ] Determine user impact
  - [ ] Evaluate data integrity
  - [ ] Check system stability
  - [ ] Estimate recovery time

#### Recovery Actions
- [ ] **Rollback Procedures**
  - [ ] Execute appropriate rollback level
  - [ ] Verify system functionality
  - [ ] Test critical workflows
  - [ ] Confirm data integrity
  - [ ] Document lessons learned

## Quality Gates Checklist

### 🎯 Success Criteria

#### Mandatory Requirements
- [ ] **Zero Functionality Loss**
  - [ ] All original features work
  - [ ] No data corruption occurred
  - [ ] Performance maintained or improved
  - [ ] Security not compromised
  - [ ] User experience preserved

- [ ] **Code Quality Improvement**
  - [ ] Redundant code eliminated
  - [ ] External dependencies reduced
  - [ ] Frappe compliance improved
  - [ ] Structure standardized
  - [ ] Documentation updated

#### Quality Metrics
- [ ] **Measurable Improvements**
  - [ ] Code quality score increased by minimum 15%
  - [ ] File count reduced (unnecessary files removed)
  - [ ] Function duplication eliminated
  - [ ] Import complexity reduced
  - [ ] Security compliance improved

### 📈 Continuous Improvement

#### Future Prevention
- [ ] **Quality Gates Established**
  - [ ] Code review standards defined
  - [ ] Automated quality checks implemented
  - [ ] Development guidelines updated
  - [ ] Training plans created
  - [ ] Monitoring procedures established

- [ ] **Maintenance Planning**
  - [ ] Regular cleanup schedule defined
  - [ ] Quality assessment intervals set
  - [ ] Technical debt tracking implemented
  - [ ] Team responsibilities assigned
  - [ ] Review processes established

## Checklist Validation

### ✅ Completion Verification

#### Self-Assessment
- [ ] **All Critical Items Completed**
  - [ ] No safety requirements skipped
  - [ ] All testing performed
  - [ ] Documentation complete
  - [ ] Rollback procedures tested
  - [ ] Team communication finished

- [ ] **Quality Review**
  - [ ] Peer review of changes
  - [ ] Technical lead approval
  - [ ] QA team sign-off
  - [ ] Business stakeholder approval
  - [ ] Final documentation review

#### Sign-off
- [ ] **Formal Approval**
  - [ ] Cleanup completed successfully: ✅ / ❌
  - [ ] All functionality verified: ✅ / ❌
  - [ ] Documentation complete: ✅ / ❌
  - [ ] Team notified: ✅ / ❌
  - [ ] Ready for production: ✅ / ❌

**Cleanup Lead:** ___________________ **Date:** ___________

**QA Lead:** ___________________ **Date:** ___________

**Technical Lead:** ___________________ **Date:** ___________

---

## Important Notes

### Critical Reminders
1. **NEVER** proceed with cleanup until all safety requirements are met
2. **ALWAYS** create backups before making any changes
3. **VERIFY** functionality at each step of the process
4. **DOCUMENT** every change made during cleanup
5. **TEST** thoroughly before considering cleanup complete

### Emergency Contacts
- **Primary Support:** [Development Team Lead]
- **Technical Escalation:** [Technical Director]
- **Business Escalation:** [Product Owner]
- **Emergency:** [System Administrator]

Remember: **The goal is to improve code quality while preserving 100% of functionality!**