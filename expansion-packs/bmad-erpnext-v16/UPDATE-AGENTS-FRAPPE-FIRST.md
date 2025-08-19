# Frappe-First Universal Enforcement Update
## Adding Frappe-First Validation to ALL Agents

This document outlines the Frappe-first requirements that must be added to ALL agent customization fields to ensure they ALWAYS use Frappe's built-in features.

---

## Universal Frappe-First Addition for ALL Agents

Add this section to EVERY agent's customization field, right after the LAYER 1 universal workflow section:

```yaml
customization: |
  MANDATORY ENFORCEMENT - UNIVERSAL WORKFLOW SYSTEM:
  
  LAYER 1 - UNIVERSAL WORKFLOW COMPLIANCE:
  Before ANY action, I MUST execute the universal-context-detection-workflow:
  - MANDATORY: Execute universal-context-detection-workflow FIRST
  - CANNOT SKIP: Context detection and safety initialization 
  - AUTOMATIC: Context type detection and appropriate information gathering
  - ENFORCED: Safety protocol activation based on detected context
  
  # ADD THIS NEW SECTION TO ALL AGENTS:
  FRAPPE-FIRST MANDATORY REQUIREMENTS:
  I MUST ALWAYS use Frappe's built-in features - NO EXCEPTIONS:
  
  DATABASE OPERATIONS:
  - ALWAYS USE: frappe.get_doc(), frappe.get_all(), frappe.db methods
  - NEVER USE: raw SQL, SQLAlchemy, direct database connections
  
  BACKGROUND JOBS:
  - ALWAYS USE: frappe.enqueue(), frappe.enqueue_doc()
  - NEVER USE: Celery, threading, multiprocessing, custom queues
  
  CACHING:
  - ALWAYS USE: frappe.cache().set_value(), frappe.cache().get_value()
  - NEVER USE: Redis directly, memcache, file-based caching
  
  HTTP REQUESTS:
  - ALWAYS USE: frappe.request, frappe.make_get_request(), frappe.make_post_request()
  - NEVER USE: import requests, urllib, httplib
  
  EMAIL/NOTIFICATIONS:
  - ALWAYS USE: frappe.sendmail(), frappe.publish_realtime()
  - NEVER USE: smtplib, email libraries, sendgrid
  
  AUTHENTICATION:
  - ALWAYS USE: frappe.session, frappe.has_permission(), @frappe.whitelist()
  - NEVER USE: JWT, OAuth libraries, custom auth
  
  SCHEDULING:
  - ALWAYS USE: hooks.py scheduler_events, frappe.enqueue with delay
  - NEVER USE: cron directly, APScheduler, schedule library
  
  LOGGING:
  - ALWAYS USE: frappe.log_error(), frappe.logger(), frappe.throw()
  - NEVER USE: import logging, print statements, custom logs
  
  DATE/TIME:
  - ALWAYS USE: frappe.utils.now(), frappe.utils.today(), frappe.utils.add_days()
  - NEVER USE: from datetime import, import time, pytz
  
  FILE OPERATIONS:
  - ALWAYS USE: frappe.get_site_path(), File DocType
  - NEVER USE: open() directly, os.path for uploads
  
  CRITICAL: Before generating ANY code, I MUST:
  1. Check if Frappe has a built-in feature for the requirement
  2. Use frappe-first-validation-workflow to validate approach
  3. BLOCK any external library when Frappe provides the feature
  4. Generate code using ONLY Frappe patterns
  
  [REST OF EXISTING CUSTOMIZATION CONTINUES...]
```

---

## Agents Requiring Update

### Project Management Team
1. **erpnext-product-owner** - Mrs. Frederic
2. **business-analyst** - Myka Bering  
3. **erpnext-scrum-master** - Pete Lattimer
4. **main-dev-coordinator** - Claudia Donovan

### Frontend Development Team
5. **vue-spa-architect** - Helena Wells
6. **vue-frontend-architect** - Holly Marten
7. **frappe-ui-developer** - Artie Nielsen
8. **ui-layout-designer** - Jack Carter
9. **pwa-specialist** - Lexi Doig
10. **mobile-ui-specialist** - Todd Manning

### Backend Development Team
11. **api-architect** - Allison Blake
12. **api-developer** - Douglas Fargo
13. **doctype-designer** - Paracelsus
14. **data-integration-expert** - Nathan Stark
15. **workflow-specialist** - Zane Donovan
16. **workspace-architect** - Beverly Barlowe

### Quality & Operations Team
17. **erpnext-qa-lead** - Allison Blake
18. **testing-specialist** - Steve Jinks
19. **bench-operator** - Larry Haberman
20. **frappe-compliance-validator** - Eva Thorne (Already has some, needs reinforcement)

### Additional Agents (11 more)
21. **workflow-converter**
22. **n8n-workflow-analyst**
23. **erpnext-app-cleaner**
24. **trigger-mapper**
25. **airtable-analyzer**
26. **jinja-template-specialist**
27. **template-generator**
28. **frontend-converter**
29. **data-migrator**
30. **security-auditor**
31. **performance-optimizer**

---

## Implementation Priority

### Phase 1: Critical Agents (Immediate)
- **erpnext-product-owner**: Sets requirements, must enforce Frappe-first
- **api-architect**: Designs APIs, must use @frappe.whitelist
- **api-developer**: Implements APIs, must use Frappe patterns
- **main-dev-coordinator**: Routes work, must enforce standards

### Phase 2: Development Agents (High Priority)
- All frontend architects (must use Frappe's asset pipeline)
- All backend developers (must use Frappe ORM)
- **doctype-designer** (must use Frappe field types)

### Phase 3: Quality Agents (Medium Priority)
- **erpnext-qa-lead**: Reviews code, must check Frappe compliance
- **testing-specialist**: Creates tests, must use Frappe test framework
- **frappe-compliance-validator**: Already focused on this

### Phase 4: Support Agents (Lower Priority)
- Workflow converters (ensure conversions use Frappe)
- Migration specialists (ensure migrations use Frappe patterns)

---

## Validation Checklist

For each agent update, verify:

- [ ] Frappe-first section added after Layer 1
- [ ] All major Frappe features listed (database, jobs, cache, etc.)
- [ ] ALWAYS USE / NEVER USE clearly specified
- [ ] Critical validation steps included
- [ ] Integration with frappe-first-validation-workflow mentioned

---

## Expected Outcome

After this update:
1. **ALL agents** will enforce Frappe-first development
2. **NO external libraries** when Frappe provides the feature
3. **Consistent patterns** across all generated code
4. **Better performance** using Frappe's optimized features
5. **Easier maintenance** with standard Frappe patterns

---

## Rollout Strategy

1. Update universal-context-detection-workflow ✅ (DONE)
2. Create frappe-first-validation-workflow ✅ (DONE)
3. Update each agent's customization field (TO DO)
4. Test with sample requests
5. Monitor for compliance

---

*This ensures that EVERY agent in the expansion pack will ALWAYS use Frappe's built-in features, creating maintainable, performant, and properly integrated ERPNext applications.*