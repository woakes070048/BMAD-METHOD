# MANDATORY CHANGELOG REQUIREMENTS
## Every Change Must Be Tracked

**PURPOSE**: Create an audit trail of ALL modifications for debugging, rollback, and understanding what happened when things go wrong.

---

## 📝 THE CHANGELOG MANDATE

### Every Session Must Create/Update:
```bash
# Session changelog file
/home/frappe/frappe-bench/apps/[app_name]/SESSION-CHANGELOG-[date].md
```

### Every Change Must Record:
```markdown
## [Timestamp] - [Agent/Human] - [Change Type]

### Context
- **Problem**: What we're trying to fix
- **Root Cause**: Why it's broken
- **Working Before**: What was functional

### Change Details
- **File**: `path/to/file.py`
- **Lines**: 45-52
- **Before**: 
  ```python
  # Original code
  ```
- **After**:
  ```python
  # New code
  ```

### Justification
- **Why This Change**: Reasoning
- **Alternatives Considered**: Other options
- **Risk Assessment**: What could break

### Result
- **Outcome**: Success/Partial/Failed
- **Testing**: How verified
- **Side Effects**: What else changed

### Rollback
- **How to Undo**: Steps if needed
- **Dependencies**: Related changes

---
```

---

## 🔄 CHANGELOG WORKFLOW

### 1. Session Start
```bash
# Create session changelog
touch SESSION-CHANGELOG-$(date +%Y%m%d-%H%M%S).md

# Add header
echo "# Development Session Changelog
Date: $(date)
Developer: [Agent/Human]
App: [app_name]
Purpose: [session goal]

## Pre-Session State
- Working Features: [list]
- Known Issues: [list]
- Last Commit: $(git log --oneline -1)

---" > SESSION-CHANGELOG-*.md
```

### 2. Before EACH Change
```bash
# Record intent
echo "## $(date +%H:%M:%S) - Starting Change
Intent: [what we're about to do]
Hypothesis: [why we think it will work]" >> SESSION-CHANGELOG-*.md
```

### 3. After EACH Change
```bash
# Record result
echo "Result: [success/failure]
Impact: [what changed]
Next Step: [what to do next]
---" >> SESSION-CHANGELOG-*.md
```

### 4. Session End
```bash
# Summarize session
echo "## Session Summary
Total Changes: [number]
Successful: [number]
Failed: [number]
Rolled Back: [number]

Final State:
- Fixed: [list]
- Still Broken: [list]
- New Issues: [list]

Next Session Should:
- [recommendations]
" >> SESSION-CHANGELOG-*.md
```

---

## 📊 CHANGELOG FORMATS

### Quick Change Log (Minimum Required)
```markdown
## 14:30:15 - API Fix
- **File**: api/customer.py
- **Change**: Added permission check
- **Result**: Fixed 500 error
```

### Detailed Change Log (For Complex Changes)
```markdown
## 14:30:15 - Complex Refactoring

### Investigation
- Spent 10 mins tracing error
- Found circular import in modules
- Checked 5 related files

### Changes Made
1. `api/customer.py` - Moved import inside function
2. `utils/helper.py` - Removed circular dependency
3. `hooks.py` - Updated import path

### Testing Performed
- Ran unit tests: PASS
- Manual test with user: PASS
- Checked related features: PASS

### Lessons Learned
- Always check for circular imports
- Test related features after import changes
```

---

## 🚨 CRITICAL CHANGELOG RULES

### MUST Log These Events:
1. **Every file modification** (no matter how small)
2. **Every command that changes state** (migrate, build, etc.)
3. **Every error encountered**
4. **Every rollback performed**
5. **Every "let me try" moment** (especially these!)

### MUST Include:
- **Timestamp** (always)
- **File path** (exact)
- **Reasoning** (why this change)
- **Result** (what happened)

### NEVER:
- Skip logging "small" changes (they add up)
- Batch multiple changes in one entry
- Use vague descriptions ("fixed stuff")
- Forget to log failures

---

## 🎯 AUTOMATIC CHANGELOG GENERATION

### Git Hook for Automatic Logging
```bash
#!/bin/bash
# .git/hooks/pre-commit

# Add to changelog
echo "## $(date +%H:%M:%S) - Git Commit
Files Changed:
$(git diff --cached --name-only)
Commit Message: $(cat .git/COMMIT_EDITMSG)
---" >> SESSION-CHANGELOG-*.md
```

### Python Decorator for Function Changes
```python
import functools
import datetime

def log_change(description):
    """Decorator to log function modifications"""
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            # Log the change
            with open(f"SESSION-CHANGELOG-{datetime.date.today()}.md", "a") as f:
                f.write(f"""
## {datetime.datetime.now().strftime('%H:%M:%S')} - Function Modified
Function: {func.__name__}
Change: {description}
---
""")
            return func(*args, **kwargs)
        return wrapper
    return decorator

# Usage
@log_change("Added permission check")
@frappe.whitelist()
def get_customer(name):
    # ... function code
```

---

## 📁 CHANGELOG MANAGEMENT

### Directory Structure
```
app_name/
├── CHANGELOG.md           # Official version changelog
├── SESSION-CHANGELOGS/    # Development session logs
│   ├── 2024-01-18-143000.md
│   ├── 2024-01-18-160000.md
│   └── 2024-01-19-090000.md
└── ROLLBACK-PLANS/        # How to undo changes
    └── 2024-01-18.md
```

### Consolidation Process
```bash
# Daily: Consolidate session logs
cat SESSION-CHANGELOGS/$(date +%Y%m%d)*.md > DAILY-CHANGELOG-$(date +%Y%m%d).md

# Weekly: Summarize for CHANGELOG.md
echo "## Week $(date +%V) Summary
Major Changes:
- [Extract from daily logs]
Fixes:
- [List of bugs fixed]
Known Issues:
- [Still outstanding]
" >> CHANGELOG.md
```

---

## 🔍 CHANGELOG SEARCH PATTERNS

### Finding What Broke
```bash
# Find all changes to specific file
grep -A5 "File.*customer.py" SESSION-CHANGELOG-*.md

# Find all failed attempts
grep -A10 "Result.*Failed" SESSION-CHANGELOG-*.md

# Find panic mode moments
grep -i "try\|maybe\|hopefully" SESSION-CHANGELOG-*.md

# Find rollbacks
grep -A5 "Rollback" SESSION-CHANGELOG-*.md
```

---

## 📈 CHANGELOG ANALYTICS

### Track Your Patterns
```python
# Analyze changelog for patterns
import re
from collections import Counter

def analyze_changelog(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Count change types
    changes = re.findall(r'Result: (\w+)', content)
    change_counts = Counter(changes)
    
    # Find problem files
    files = re.findall(r'File: (.*\.py)', content)
    problem_files = Counter(files)
    
    # Calculate success rate
    success_rate = change_counts['Success'] / sum(change_counts.values())
    
    print(f"Success Rate: {success_rate:.1%}")
    print(f"Most Modified Files: {problem_files.most_common(5)}")
    print(f"Failed Attempts: {change_counts['Failed']}")
```

---

## ✅ GOOD CHANGELOG EXAMPLE

```markdown
## 14:30:15 - API Permission Fix

### Context
- **Problem**: API returning 500 for non-admin users
- **Root Cause**: Missing permission check before get_doc
- **Working Before**: Admin access functioned normally

### Change Details
- **File**: `api/customer.py`
- **Lines**: 45-47
- **Before**: 
  ```python
  customer = frappe.get_doc("Customer", name)
  ```
- **After**:
  ```python
  if not frappe.has_permission("Customer", "read"):
      frappe.throw(_("Insufficient permissions"))
  customer = frappe.get_doc("Customer", name)
  ```

### Justification
- **Why**: get_doc throws when user lacks permission
- **Alternative**: Could use get_doc_if_permitted but need error control

### Result
- **Outcome**: Success - API now returns proper 403
- **Testing**: Verified with test user
- **Side Effects**: None observed

---
```

## ❌ BAD CHANGELOG EXAMPLE

```markdown
## some time - fixed stuff
changed api thing
it works now hopefully
```

---

## 🎖️ THE CHANGELOG OATH

**"I solemnly swear to log every change,
document every failure,
explain every decision,
and leave a trail that others can follow."**

---

## 🚀 IMPLEMENTATION

### For Agents
Add to customization:
```yaml
customization: |
  I MUST maintain a SESSION-CHANGELOG-[timestamp].md file
  logging EVERY change with: timestamp, file, reasoning, and result.
  No change is too small to log.
```

### For Humans
Create alias:
```bash
alias logchange='echo "## $(date +%H:%M:%S) - Manual Change" >> SESSION-CHANGELOG-$(date +%Y%m%d).md'
```

---

*This changelog requirement is MANDATORY for all development work.*
*A session without a changelog is a session that didn't happen.*