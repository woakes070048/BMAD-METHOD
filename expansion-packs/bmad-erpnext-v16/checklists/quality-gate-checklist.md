# Quality Gate Checklist
## Step-by-Step Verification for All Agents

This checklist MUST be completed before any code handoff, submission, or deployment. Each agent must verify ALL applicable items based on their work context.

---

## 🚦 PRE-DEVELOPMENT GATES

### ✅ Context Detection Gate
- [ ] **Context type identified** (TROUBLESHOOTING/NEW_DEVELOPMENT/ENHANCEMENT/MIGRATION)
- [ ] **Requirements documented** in appropriate format
- [ ] **Success criteria defined** and measurable
- [ ] **SESSION-CHANGELOG.md created** with context logged
- [ ] **Universal workflow completed** (universal-context-detection-workflow.yaml)

### ✅ Structure Requirements Gate
- [ ] **3-layer architecture reviewed** (ERPNEXT-APP-STRUCTURE-PATTERNS.md)
- [ ] **Directory structure planned** according to patterns
- [ ] **Import patterns understood** (no triple nesting)
- [ ] **DocType naming conventions** clear (PascalCase, _ct suffix for children)
- [ ] **No /frontend/ directory** will be created

### ✅ Dependency Analysis Gate
- [ ] **analyze-app-dependencies task executed**
- [ ] **DocType relationships mapped** and understood
- [ ] **Import dependencies analyzed** for impacts
- [ ] **Business logic patterns identified**
- [ ] **Workflow dependencies documented**

### ✅ Test Strategy Gate
- [ ] **Test scope defined** based on changes
- [ ] **Test cases planned** for all scenarios
- [ ] **Acceptance criteria established** and measurable
- [ ] **Test data strategy defined**
- [ ] **Test environment prepared**

---

## 🔧 DURING-DEVELOPMENT GATES

### ✅ Import Validation Gate
Check that NO forbidden patterns exist:
- [ ] **No** `from app_name.app_name.api` imports
- [ ] **No** `from app_name.app_name.doctype.*.* import` patterns
- [ ] **No** `import requests` - using `frappe.make_get_request()`
- [ ] **No** `import unittest` - using `FrappeTestCase`
- [ ] **No** `import celery` - using `frappe.enqueue()`
- [ ] **No** `import redis` - using `frappe.cache()`
- [ ] **No** `import jwt` - using `frappe.session`
- [ ] **No** `import jinja2` - using `frappe.render_template()`

### ✅ Frappe Compliance Gate
Verify Frappe-first principles:
- [ ] **All APIs have** `@frappe.whitelist()` decorator
- [ ] **Permission checks** with `frappe.has_permission()`
- [ ] **Database operations** use `frappe.db` methods
- [ ] **No raw SQL** queries (unless absolutely necessary with proper escaping)
- [ ] **Error handling** with `frappe.throw()`
- [ ] **Async operations** use `frappe.enqueue()`
- [ ] **Caching** uses `frappe.cache()`
- [ ] **Email** uses `frappe.sendmail()`

### ✅ Incremental Testing Gate
- [ ] **Unit tests written** for new code
- [ ] **Tests passing** locally
- [ ] **No regressions** introduced
- [ ] **Edge cases tested**
- [ ] **Error scenarios covered**

### ✅ Structure Adherence Gate
Verify files are in correct locations:
- [ ] **Python files** NOT at root level
- [ ] **hooks.py** at package layer (`app-name/app-name/`)
- [ ] **DocTypes** in module layer (`app-name/app-name/doctype/`)
- [ ] **APIs** in `app-name/api/` directory
- [ ] **Vue components** in `app-name/public/js/`
- [ ] **Child tables** have `_ct` suffix
- [ ] **No /frontend/** directory exists

---

## ✔️ POST-DEVELOPMENT GATES

### ✅ Full Test Suite Gate
Execute and verify all tests:
- [ ] **Run:** `bench --site [site] run-tests --app [app]`
- [ ] **All unit tests** passing
- [ ] **Integration tests** passing
- [ ] **API tests** complete
- [ ] **Frontend tests** if applicable
- [ ] **Test coverage** >= 80%
- [ ] **Critical paths** 100% covered

### ✅ Structure Validation Gate
Final structure check:
- [ ] **Run structure validation** (Eva Thorne compliance check)
- [ ] **No structure violations** found
- [ ] **Import patterns** validated
- [ ] **Workspace configuration** correct (no child tables)
- [ ] **File naming** follows conventions

### ✅ Documentation Completeness Gate
Verify all documentation:
- [ ] **Code documentation** (docstrings, comments for complex logic)
- [ ] **API documentation** complete with examples
- [ ] **User documentation** updated if user-facing changes
- [ ] **Technical documentation** for architecture changes
- [ ] **README updated** if setup changes
- [ ] **CHANGELOG updated** with changes

### ✅ Cross-Verification Gate
Independent verification:
- [ ] **Testing specialist** verified test results
- [ ] **Code review** completed by senior developer
- [ ] **No critical issues** identified
- [ ] **Recommendations addressed** or documented

---

## 🎯 FINAL GATES

### ✅ Eva Thorne Compliance Gate
Framework compliance validation:
- [ ] **Frappe framework compliance** verified
- [ ] **ERPNext standards** met
- [ ] **No anti-patterns** detected
- [ ] **Best practices** followed
- [ ] **Performance patterns** appropriate

### ✅ Integration Testing Gate
Multi-app and system integration:
- [ ] **Multi-app compatibility** tested
- [ ] **API integrations** verified
- [ ] **Workflow integrations** tested
- [ ] **Data flow** validated
- [ ] **No breaking changes** for existing functionality

### ✅ Performance Validation Gate
Performance metrics verification:
- [ ] **API response time** < 2 seconds
- [ ] **Page load time** < 3 seconds
- [ ] **Database queries** optimized (no N+1)
- [ ] **Memory usage** acceptable
- [ ] **No performance regression** from baseline

### ✅ Security Review Gate
Security validation complete:
- [ ] **Input validation** present for all inputs
- [ ] **Authentication** properly implemented
- [ ] **Authorization** correctly enforced
- [ ] **No hardcoded** credentials or secrets
- [ ] **SQL injection** prevention verified
- [ ] **XSS protection** implemented

---

## 🤝 HANDOFF PREPARATION

### ✅ Handoff Requirements
Before passing work to another agent:
- [ ] **All applicable gates** passed
- [ ] **Test results** documented
- [ ] **Known issues** listed with workarounds
- [ ] **Dependencies** documented
- [ ] **Next steps** clearly defined
- [ ] **Handoff report** generated

### ✅ Handoff Documentation
Create handoff package containing:
- [ ] **Work completed** summary
- [ ] **Test results** and coverage metrics
- [ ] **Documentation links** and references
- [ ] **Environment setup** requirements
- [ ] **Configuration changes** needed
- [ ] **Remaining tasks** if any

---

## ⚠️ BLOCKING CONDITIONS

**STOP if any of these exist:**
- ❌ **Structure violations** detected
- ❌ **Failing tests** not resolved
- ❌ **Missing documentation** for public APIs
- ❌ **Frappe compliance** issues
- ❌ **Security vulnerabilities** identified
- ❌ **Performance regression** detected
- ❌ **Import pattern** violations

---

## 📊 QUALITY METRICS

Record these metrics:
- **Total tests:** ___________
- **Tests passed:** ___________
- **Code coverage:** ___________% 
- **Gates passed first attempt:** ___________
- **Gates requiring correction:** ___________
- **Time to complete gates:** ___________

---

## 🔄 RETRY PROTOCOL

If gates fail:
1. **First attempt:** Fix issues and retry
2. **Second attempt:** Get peer review before retry
3. **Third attempt:** Escalate to development coordinator
4. **After third failure:** STOP - requires team review

---

## ✍️ SIGN-OFF

By completing this checklist, I certify that:
- All applicable quality gates have been passed
- The code meets ERPNext development standards
- Testing is comprehensive and passing
- Documentation is complete
- The code is ready for handoff/submission

**Agent:** _______________________
**Date:** _______________________
**Context Type:** _______________________
**Gates Passed:** _______________________
**Notes:** _______________________

---

## 🚀 QUICK COMMANDS

```bash
# Run all tests
bench --site [site] run-tests --app [app]

# Check structure
find . -path "*/frontend/*" -type f  # Should return nothing
find . -name "*.py" -maxdepth 1      # Should be minimal

# Validate imports
grep -r "from app_name.app_name.api" .  # Should return nothing
grep -r "@frappe.whitelist" app-name/api/  # Should find decorators

# Check child table naming
find . -path "*/doctype/*" -type d -name "*_ct"  # Should find child tables

# Clear cache and test
bench --site [site] clear-cache
bench --site [site] migrate
bench build --app [app]
```

---

**Remember:** Quality gates ensure code reliability, maintainability, and consistency. Never skip gates to save time - they prevent larger issues later!