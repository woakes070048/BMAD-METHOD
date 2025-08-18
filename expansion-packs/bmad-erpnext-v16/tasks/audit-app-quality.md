# audit-app-quality

A comprehensive task for auditing ERPNext application quality, identifying AI-generated anti-patterns, and assessing code compliance with Frappe Framework standards.

## Metadata
```yaml
task_id: audit-app-quality
title: "ERPNext App Quality Audit"
category: code-quality
complexity: high
estimated_time: "45-90 minutes"
prerequisites: ["ERPNext app exists", "Frappe bench access"]
outputs: ["Quality audit report", "Anti-pattern list", "Compliance score", "Remediation plan"]
elicit: true
agent_compatibility: ["erpnext-app-cleaner", "app-auditor"]
```

## Task Description

Perform a comprehensive quality audit of an ERPNext application to identify common problems created by AI coding tools, anti-patterns, security vulnerabilities, and compliance violations. This task systematically examines code structure, dependencies, and implementation patterns to provide actionable cleanup recommendations.

## Prerequisites

1. **Environment Setup**
   - Active Frappe bench installation
   - ERPNext application installed and accessible
   - Read/write permissions to app directory
   - Database access for schema validation

2. **Required Information**
   - App name and location
   - Site name for testing
   - Backup strategy preference
   - Critical functionality to preserve

## Input Requirements

### ELICIT REQUIRED INFORMATION

**App Details:**
- App name: _______________
- App path: _______________
- Site name for testing: _______________
- Primary modules/features: _______________

**Audit Scope:**
- [ ] Full app audit (recommended)
- [ ] Specific modules only: _______________
- [ ] Focus areas: [ ] Security [ ] Performance [ ] Structure [ ] Compliance

**Backup Strategy:**
- [ ] Create full backup before audit
- [ ] Backup only modified files
- [ ] No backup (not recommended)

## Audit Methodology

### Phase 1: Initial Discovery
```bash
# Navigate to app directory
cd /home/frappe/frappe-bench/apps/{{app_name}}

# Create audit workspace
mkdir -p /tmp/audit-{{app_name}}-$(date +%Y%m%d-%H%M%S)
export AUDIT_DIR="/tmp/audit-{{app_name}}-$(date +%Y%m%d-%H%M%S)"

# Document app structure
find . -type f -name "*.py" > $AUDIT_DIR/python_files.txt
find . -type f -name "*.js" > $AUDIT_DIR/javascript_files.txt
find . -type f -name "*.json" > $AUDIT_DIR/json_files.txt
find . -type f -name "*.vue" > $AUDIT_DIR/vue_files.txt

echo "Files discovered:"
echo "Python files: $(wc -l < $AUDIT_DIR/python_files.txt)"
echo "JavaScript files: $(wc -l < $AUDIT_DIR/javascript_files.txt)"
echo "JSON files: $(wc -l < $AUDIT_DIR/json_files.txt)"
echo "Vue files: $(wc -l < $AUDIT_DIR/vue_files.txt)"
```

### Phase 2: Anti-Pattern Detection

#### 2.1 External Library Usage Audit
```bash
# Check for common external libraries that should be replaced with Frappe built-ins
echo "=== EXTERNAL LIBRARY AUDIT ===" > $AUDIT_DIR/external_libraries.txt

echo "Checking for requests library usage:" >> $AUDIT_DIR/external_libraries.txt
grep -r "import requests" . --include="*.py" >> $AUDIT_DIR/external_libraries.txt 2>/dev/null || echo "No requests imports found" >> $AUDIT_DIR/external_libraries.txt

echo -e "\nChecking for pandas usage:" >> $AUDIT_DIR/external_libraries.txt
grep -r "import pandas" . --include="*.py" >> $AUDIT_DIR/external_libraries.txt 2>/dev/null || echo "No pandas imports found" >> $AUDIT_DIR/external_libraries.txt

echo -e "\nChecking for SQLAlchemy usage:" >> $AUDIT_DIR/external_libraries.txt
grep -r "import sqlalchemy\|from sqlalchemy" . --include="*.py" >> $AUDIT_DIR/external_libraries.txt 2>/dev/null || echo "No SQLAlchemy imports found" >> $AUDIT_DIR/external_libraries.txt

echo -e "\nChecking for Celery usage:" >> $AUDIT_DIR/external_libraries.txt
grep -r "import celery\|from celery" . --include="*.py" >> $AUDIT_DIR/external_libraries.txt 2>/dev/null || echo "No Celery imports found" >> $AUDIT_DIR/external_libraries.txt

echo -e "\nChecking for Redis direct usage:" >> $AUDIT_DIR/external_libraries.txt
grep -r "import redis" . --include="*.py" >> $AUDIT_DIR/external_libraries.txt 2>/dev/null || echo "No direct Redis imports found" >> $AUDIT_DIR/external_libraries.txt

echo -e "\nChecking for JWT library usage:" >> $AUDIT_DIR/external_libraries.txt
grep -r "import jwt\|import pyjwt" . --include="*.py" >> $AUDIT_DIR/external_libraries.txt 2>/dev/null || echo "No JWT library imports found" >> $AUDIT_DIR/external_libraries.txt
```

#### 2.2 Custom Authentication Detection
```bash
echo "=== CUSTOM AUTHENTICATION AUDIT ===" > $AUDIT_DIR/custom_auth.txt

echo "Checking for custom authentication functions:" >> $AUDIT_DIR/custom_auth.txt
grep -r "def authenticate\|def login\|def check_.*auth\|def verify_.*user" . --include="*.py" >> $AUDIT_DIR/custom_auth.txt 2>/dev/null || echo "No custom auth functions found" >> $AUDIT_DIR/custom_auth.txt

echo -e "\nChecking for custom permission systems:" >> $AUDIT_DIR/custom_auth.txt
grep -r "def check_permission\|def has_permission\|def can_.*access" . --include="*.py" >> $AUDIT_DIR/custom_auth.txt 2>/dev/null || echo "No custom permission functions found" >> $AUDIT_DIR/custom_auth.txt

echo -e "\nChecking for session management code:" >> $AUDIT_DIR/custom_auth.txt
grep -r "session\[.*\]\|session\.get\|session\.set" . --include="*.py" >> $AUDIT_DIR/custom_auth.txt 2>/dev/null || echo "No custom session management found" >> $AUDIT_DIR/custom_auth.txt

echo -e "\nChecking for password hashing:" >> $AUDIT_DIR/custom_auth.txt
grep -r "hashlib\|bcrypt\|scrypt\|pbkdf2" . --include="*.py" >> $AUDIT_DIR/custom_auth.txt 2>/dev/null || echo "No custom password hashing found" >> $AUDIT_DIR/custom_auth.txt
```

#### 2.3 Direct SQL Usage Detection
```bash
echo "=== DIRECT SQL AUDIT ===" > $AUDIT_DIR/direct_sql.txt

echo "Checking for direct SQL queries:" >> $AUDIT_DIR/direct_sql.txt
grep -r "frappe\.db\.sql.*SELECT\|frappe\.db\.sql.*INSERT\|frappe\.db\.sql.*UPDATE\|frappe\.db\.sql.*DELETE" . --include="*.py" >> $AUDIT_DIR/direct_sql.txt 2>/dev/null || echo "No direct SQL found" >> $AUDIT_DIR/direct_sql.txt

echo -e "\nChecking for cursor usage:" >> $AUDIT_DIR/direct_sql.txt
grep -r "cursor\.execute\|connection\.execute" . --include="*.py" >> $AUDIT_DIR/direct_sql.txt 2>/dev/null || echo "No cursor usage found" >> $AUDIT_DIR/direct_sql.txt

echo -e "\nChecking for raw SQL strings:" >> $AUDIT_DIR/direct_sql.txt
grep -r "SELECT.*FROM.*tab\|INSERT.*INTO.*tab\|UPDATE.*tab.*SET\|DELETE.*FROM.*tab" . --include="*.py" >> $AUDIT_DIR/direct_sql.txt 2>/dev/null || echo "No raw SQL strings found" >> $AUDIT_DIR/direct_sql.txt
```

#### 2.4 Code Duplication Detection
```bash
echo "=== CODE DUPLICATION AUDIT ===" > $AUDIT_DIR/duplicates.txt

echo "Checking for duplicate function names:" >> $AUDIT_DIR/duplicates.txt
grep -r "^def " . --include="*.py" | cut -d: -f2 | sort | uniq -d >> $AUDIT_DIR/duplicates.txt

echo -e "\nChecking for similar function patterns:" >> $AUDIT_DIR/duplicates.txt
grep -r "def.*get.*data\|def.*fetch.*data\|def.*retrieve.*data" . --include="*.py" >> $AUDIT_DIR/duplicates.txt 2>/dev/null || echo "No similar function patterns found" >> $AUDIT_DIR/duplicates.txt

echo -e "\nChecking for backup/temporary files:" >> $AUDIT_DIR/duplicates.txt
find . -name "*.bak" -o -name "*.old" -o -name "*.tmp" -o -name "*_backup*" -o -name "*_copy*" >> $AUDIT_DIR/duplicates.txt 2>/dev/null || echo "No backup files found" >> $AUDIT_DIR/duplicates.txt
```

### Phase 3: Structure Analysis

#### 3.1 App Structure Validation
```bash
echo "=== APP STRUCTURE AUDIT ===" > $AUDIT_DIR/structure.txt

echo "Checking required files:" >> $AUDIT_DIR/structure.txt
required_files=("setup.py" "hooks.py" "modules.txt" "__init__.py")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists" >> $AUDIT_DIR/structure.txt
    else
        echo "✗ $file MISSING" >> $AUDIT_DIR/structure.txt
    fi
done

echo -e "\nChecking directory structure:" >> $AUDIT_DIR/structure.txt
expected_dirs=("public" "templates" "patches")
for dir in "${expected_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "✓ $dir directory exists" >> $AUDIT_DIR/structure.txt
    else
        echo "? $dir directory missing (may be optional)" >> $AUDIT_DIR/structure.txt
    fi
done
```

#### 3.2 Frontend Structure Audit
```bash
echo "=== FRONTEND STRUCTURE AUDIT ===" > $AUDIT_DIR/frontend.txt

echo "Checking for incorrect frontend patterns:" >> $AUDIT_DIR/frontend.txt
if [ -d "frontend" ]; then
    echo "⚠️ /frontend/ directory found - should use public/js/ instead" >> $AUDIT_DIR/frontend.txt
    ls -la frontend/ >> $AUDIT_DIR/frontend.txt
else
    echo "✓ No /frontend/ directory (correct)" >> $AUDIT_DIR/frontend.txt
fi

echo -e "\nChecking for Vue build files:" >> $AUDIT_DIR/frontend.txt
build_files=("vite.config.js" "webpack.config.js" "package.json")
for file in "${build_files[@]}"; do
    if [ -f "$file" ]; then
        echo "⚠️ $file found - may indicate non-native Vue setup" >> $AUDIT_DIR/frontend.txt
    fi
done

echo -e "\nChecking for proper Vue structure:" >> $AUDIT_DIR/frontend.txt
if [ -d "public/js" ]; then
    echo "✓ public/js directory exists (correct for native Vue)" >> $AUDIT_DIR/frontend.txt
    find public/js -name "*.bundle.js" >> $AUDIT_DIR/frontend.txt
else
    echo "? No public/js directory found" >> $AUDIT_DIR/frontend.txt
fi
```

### Phase 4: Security Analysis

#### 4.1 API Security Audit
```bash
echo "=== API SECURITY AUDIT ===" > $AUDIT_DIR/api_security.txt

echo "Checking for unwhitelisted API functions:" >> $AUDIT_DIR/api_security.txt
grep -r "def " . --include="*.py" | grep -v "@frappe.whitelist\|@frappe\.whitelist" | grep -E "def.*(api|get|post|put|delete).*" >> $AUDIT_DIR/api_security.txt 2>/dev/null || echo "No unwhitelisted API functions detected" >> $AUDIT_DIR/api_security.txt

echo -e "\nChecking for proper input validation:" >> $AUDIT_DIR/api_security.txt
grep -r "@frappe\.whitelist" . --include="*.py" -A 10 | grep -E "def.*\(" | head -20 >> $AUDIT_DIR/api_security.txt

echo -e "\nChecking for SQL injection risks:" >> $AUDIT_DIR/api_security.txt
grep -r "frappe\.db\.sql.*%.*%" . --include="*.py" >> $AUDIT_DIR/api_security.txt 2>/dev/null || echo "No SQL injection patterns detected" >> $AUDIT_DIR/api_security.txt
```

#### 4.2 Permission System Audit
```bash
echo "=== PERMISSION SYSTEM AUDIT ===" > $AUDIT_DIR/permissions.txt

echo "Checking for Frappe permission usage:" >> $AUDIT_DIR/permissions.txt
grep -r "frappe\.has_permission\|frappe\.only_for" . --include="*.py" >> $AUDIT_DIR/permissions.txt 2>/dev/null || echo "No Frappe permission checks found" >> $AUDIT_DIR/permissions.txt

echo -e "\nChecking for custom permission systems:" >> $AUDIT_DIR/permissions.txt
grep -r "def.*check.*perm\|def.*validate.*access\|if.*role.*==" . --include="*.py" >> $AUDIT_DIR/permissions.txt 2>/dev/null || echo "No custom permission systems detected" >> $AUDIT_DIR/permissions.txt
```

### Phase 5: Performance Analysis

#### 5.1 Database Performance Audit
```bash
echo "=== DATABASE PERFORMANCE AUDIT ===" > $AUDIT_DIR/performance.txt

echo "Checking for N+1 query patterns:" >> $AUDIT_DIR/performance.txt
grep -r "for.*in.*frappe\.get" . --include="*.py" >> $AUDIT_DIR/performance.txt 2>/dev/null || echo "No obvious N+1 patterns found" >> $AUDIT_DIR/performance.txt

echo -e "\nChecking for missing filters in queries:" >> $AUDIT_DIR/performance.txt
grep -r "frappe\.get_all.*)" . --include="*.py" | grep -v "filters\|limit" >> $AUDIT_DIR/performance.txt 2>/dev/null || echo "All queries appear to have filters" >> $AUDIT_DIR/performance.txt

echo -e "\nChecking for large data operations:" >> $AUDIT_DIR/performance.txt
grep -r "get_all\|get_list" . --include="*.py" | grep -v "limit\|page_length" >> $AUDIT_DIR/performance.txt 2>/dev/null || echo "All queries appear to be limited" >> $AUDIT_DIR/performance.txt
```

## Analysis and Scoring

### Calculate Compliance Score
```python
import json
import os

def calculate_compliance_score(audit_dir):
    """Calculate overall compliance score based on audit results"""
    
    scores = {
        'external_libraries': 100,  # Start with perfect score
        'custom_auth': 100,
        'direct_sql': 100,
        'structure': 100,
        'frontend': 100,
        'api_security': 100,
        'permissions': 100,
        'performance': 100
    }
    
    weights = {
        'external_libraries': 20,
        'custom_auth': 15,
        'direct_sql': 15,
        'structure': 10,
        'frontend': 10,
        'api_security': 15,
        'permissions': 10,
        'performance': 5
    }
    
    # Analyze each audit file and deduct points for violations
    issues = []
    
    # External libraries check
    with open(f"{audit_dir}/external_libraries.txt", 'r') as f:
        content = f.read()
        if "import requests" in content:
            scores['external_libraries'] -= 30
            issues.append("Using requests library instead of frappe.request")
        if "import pandas" in content:
            scores['external_libraries'] -= 20
            issues.append("Using pandas instead of built-in Python/Frappe operations")
        if "sqlalchemy" in content:
            scores['external_libraries'] -= 25
            issues.append("Using SQLAlchemy instead of Frappe ORM")
    
    # Continue for other categories...
    
    # Calculate weighted average
    total_score = sum(scores[category] * weights[category] for category in scores) / 100
    
    return {
        'overall_score': round(total_score, 1),
        'category_scores': scores,
        'issues': issues,
        'recommendations': generate_recommendations(scores, issues)
    }

def generate_recommendations(scores, issues):
    """Generate specific recommendations based on scores and issues"""
    recommendations = []
    
    if scores['external_libraries'] < 80:
        recommendations.append("Replace external libraries with Frappe built-in equivalents")
    
    if scores['custom_auth'] < 80:
        recommendations.append("Migrate custom authentication to ERPNext Role Permission Manager")
    
    if scores['direct_sql'] < 80:
        recommendations.append("Replace direct SQL queries with frappe.get_all() and frappe.get_doc()")
    
    if scores['structure'] < 80:
        recommendations.append("Reorganize app structure to follow ERPNext conventions")
    
    return recommendations
```

## Report Generation

### Generate Comprehensive Audit Report
Create a detailed audit report using the template:

```markdown
# {{app_name}} Quality Audit Report

**Date:** {{current_date}}  
**Auditor:** ERPNext App Cleaner Agent  
**App Version:** {{app_version}}  
**Audit Duration:** {{audit_duration}}

## Executive Summary

- **Overall Compliance Score:** {{overall_score}}%
- **Critical Issues Found:** {{critical_count}}
- **Security Vulnerabilities:** {{security_count}}  
- **Performance Issues:** {{performance_count}}
- **Recommended Actions:** {{recommendation_count}}

## Detailed Findings

### 🚨 Critical Issues
{{critical_issues_list}}

### ⚠️ Security Concerns  
{{security_issues_list}}

### 📈 Performance Issues
{{performance_issues_list}}

### 🔧 Code Quality Issues
{{quality_issues_list}}

## Category Scores

| Category | Score | Issues | Priority |
|----------|-------|--------|----------|
| External Libraries | {{ext_lib_score}}% | {{ext_lib_issues}} | {{ext_lib_priority}} |
| Custom Authentication | {{auth_score}}% | {{auth_issues}} | {{auth_priority}} |
| Direct SQL Usage | {{sql_score}}% | {{sql_issues}} | {{sql_priority}} |
| App Structure | {{structure_score}}% | {{structure_issues}} | {{structure_priority}} |
| Frontend Patterns | {{frontend_score}}% | {{frontend_issues}} | {{frontend_priority}} |
| API Security | {{api_score}}% | {{api_issues}} | {{api_priority}} |
| Permission System | {{perm_score}}% | {{perm_issues}} | {{perm_priority}} |
| Performance | {{perf_score}}% | {{perf_issues}} | {{perf_priority}} |

## Remediation Plan

### High Priority (Fix Immediately)
{{high_priority_actions}}

### Medium Priority (Fix This Sprint)  
{{medium_priority_actions}}

### Low Priority (Technical Debt)
{{low_priority_actions}}

## Before/After Comparison

### Code Metrics
- **Total Files:** Before: {{files_before}} | After: {{files_after}}
- **Lines of Code:** Before: {{loc_before}} | After: {{loc_after}}  
- **External Dependencies:** Before: {{deps_before}} | After: {{deps_after}}
- **Security Issues:** Before: {{security_before}} | After: {{security_after}}

## Next Steps

1. **Immediate Actions**
   - Create app backup
   - Fix critical security issues
   - Replace external libraries

2. **Short-term Actions**  
   - Standardize app structure
   - Consolidate duplicate code
   - Improve performance

3. **Long-term Actions**
   - Implement monitoring
   - Set up quality gates
   - Team training on Frappe best practices

## Quality Gate Recommendations

- **Minimum Compliance Score:** 85%
- **Security Issues:** 0 critical, max 2 medium
- **External Dependencies:** Only Frappe-approved libraries
- **Code Coverage:** Minimum 70%
- **Performance:** Page load < 2 seconds

---
*This report was generated by the ERPNext App Cleaner Agent. For questions or assistance with remediation, consult the Frappe Framework documentation and ERPNext best practices guide.*
```

## Validation Steps

1. **Verify Audit Completeness**
   - All file types scanned
   - All modules examined  
   - Security checks completed
   - Performance analysis done

2. **Validate Findings**
   - Cross-check critical issues
   - Verify security vulnerabilities
   - Confirm anti-pattern detection
   - Test performance claims

3. **Review Recommendations**
   - Ensure actionability
   - Prioritize correctly
   - Consider app functionality
   - Account for business requirements

## Success Criteria

- ✅ Complete audit report generated
- ✅ All anti-patterns identified
- ✅ Security vulnerabilities documented
- ✅ Compliance score calculated
- ✅ Actionable remediation plan created
- ✅ Quality gates defined
- ✅ Before/after metrics established

## Common Issues and Solutions

**Issue:** App has many external library dependencies  
**Solution:** Create migration plan with Frappe equivalents

**Issue:** Custom authentication system detected  
**Solution:** Plan migration to ERPNext Role Permission Manager

**Issue:** Direct SQL queries throughout codebase  
**Solution:** Systematic replacement with Frappe ORM methods

**Issue:** Poor app structure organization  
**Solution:** Restructuring plan following ERPNext conventions

**Issue:** Security vulnerabilities in API endpoints  
**Solution:** Implement proper whitelisting and validation

Remember: This audit is the foundation for systematic app cleanup and quality improvement!