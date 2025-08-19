# Code Change Justification Protocol
## Mandatory Framework for Deliberate, Thoughtful Code Changes

**PURPOSE**: Stop the cascade of panic fixes that introduce more bugs than they solve.

---

## 🛑 MANDATORY: Before ANY Code Change

### The 5-Second Rule
**STOP. BREATHE. THINK.**
Before touching ANY code, you MUST spend at least 5 seconds asking:
- "Do I understand what this code currently does?"
- "Do I know why it's broken?"
- "Will my fix break something else?"

If ANY answer is "no" - STOP and gather context first.

---

## 📋 Required Context Checklist

### MUST HAVE Before Starting
- [ ] **Current State**: What IS working right now?
- [ ] **Problem Statement**: What specifically is broken?
- [ ] **Root Cause**: WHY is it broken (not just the symptom)?
- [ ] **Dependencies**: What other code relies on this?
- [ ] **History**: What's been tried already that failed?
- [ ] **Business Logic**: What business rules apply here?
- [ ] **Test Data**: How will I verify the fix works?

### Red Flags - STOP if you see these:
- 🚨 "Let me try something..."
- 🚨 "Maybe this will work..."
- 🚨 "I'll just quickly change..."
- 🚨 Making changes without reading the full file
- 🚨 Fixing symptoms without understanding cause
- 🚨 No clear success criteria

---

## 📝 Change Justification Template

### EVERY Change Must Document:

```yaml
change_justification:
  # 1. WHAT - Be specific
  what_changing:
    file: "exact/file/path.py"
    lines: "125-130"
    description: "Changing X to Y"
  
  # 2. WHY - Root cause, not symptom
  why_changing:
    problem: "The actual problem this solves"
    root_cause: "Why the problem exists"
    evidence: "Error message/behavior that proves this"
  
  # 3. IMPACT - Think through consequences
  impact_analysis:
    dependencies: ["List of files/functions that use this"]
    side_effects: ["What else might change"]
    risk_level: "low|medium|high"
  
  # 4. ALTERNATIVES - Show you thought about it
  alternatives_considered:
    option_1: "Why not chosen"
    option_2: "Why not chosen"
    selected: "Why this approach is best"
  
  # 5. SAFETY - How to recover
  safety_measures:
    backup: "Created backup at: path"
    rollback: "Steps to undo if needed"
    testing: "How to verify it worked"
  
  # 6. VERIFICATION - Define success
  success_criteria:
    - "Specific thing that should work"
    - "Error that should stop appearing"
    - "Functionality that must remain intact"
```

---

## 🔍 Context Gathering Commands

### Before Making Changes, Run These:

```bash
# 1. Understand current structure
find . -name "*.py" -path "*[module_name]*" | head -20

# 2. Check what imports this
grep -r "from.*[module_name]" --include="*.py"

# 3. See recent changes
git diff HEAD~5 [file_name]

# 4. Check for similar patterns
grep -r "[pattern]" --include="*.py" | head -10

# 5. Verify current working state
bench --site [site] console
# Test current functionality
```

---

## ⚠️ High-Risk Change Indicators

### REQUIRE EXTRA CAUTION:
1. **Import Statement Changes**
   - Can cascade break entire app
   - Always check all files that import

2. **DocType Field Changes**
   - Affects database schema
   - Check for dependent fields/logic

3. **API Endpoint Modifications**
   - Breaks external integrations
   - Verify all consumers

4. **Hooks.py Changes**
   - Affects entire app loading
   - Can make app uninstallable

5. **JavaScript/Frontend Changes**
   - Often cached aggressively
   - Hard to test all interactions

---

## 🎯 The Right Way: Deliberate Change Process

### Phase 1: Understand (Don't Skip!)
```python
# BEFORE changing anything:
# 1. Read the ENTIRE file
# 2. Understand the business logic
# 3. Trace the data flow
# 4. Check for patterns used elsewhere
```

### Phase 2: Plan
```python
# Document your plan:
"""
Current Issue: [specific problem]
Root Cause: [why it's happening]
Proposed Fix: [what you'll change]
Impact: [what else might be affected]
Test Plan: [how you'll verify]
"""
```

### Phase 3: Implement
```python
# Make the MINIMAL change needed
# Add clear comments explaining WHY
# Keep old code commented for reference
```

### Phase 4: Verify
```python
# Test the specific fix
# Test related functionality
# Check for new errors
# Verify performance
```

---

## 🚫 Anti-Patterns to AVOID

### The "Shotgun Debug"
```python
# BAD: Changing multiple things hoping one works
# Change 1: Maybe this?
# Change 2: Or perhaps this?
# Change 3: Let's try this too!
```

### The "Hail Mary"
```python
# BAD: Major refactor when a small fix would work
# "Let me just rewrite this whole module..."
```

### The "Assumption Fix"
```python
# BAD: Fixing based on assumption not investigation
# "This looks wrong, let me change it..."
# (without checking if it actually IS wrong)
```

### The "Context-Free Fix"
```python
# BAD: Making changes without understanding surroundings
# Changes line 50 without reading lines 1-49 and 51-100
```

---

## ✅ Good Change Example

```python
"""
CHANGE JUSTIFICATION:
- Problem: API endpoint returning 500 error
- Root Cause: Missing permission check for new DocType
- Investigation: Traced error to frappe.get_doc() call without permission
- Fix: Add frappe.has_permission() check before get_doc()
- Impact: Only affects this endpoint, no other dependencies
- Testing: Verified with test user having/not having permission
- Rollback: Remove permission check if issues arise
"""

@frappe.whitelist()
def get_customer_data(customer_name):
    # FIX: Added permission check to prevent 500 error
    # Previously failed when user lacked Customer read permission
    if not frappe.has_permission("Customer", "read"):
        frappe.throw(_("Insufficient permissions"), frappe.PermissionError)
    
    # Original code continues...
    return frappe.get_doc("Customer", customer_name)
```

---

## 🔄 When Things Go Wrong

### The Rollback Protocol
1. **STOP making more changes**
2. **Document what you changed**
3. **Revert to last working state**
4. **Analyze why the fix failed**
5. **Gather more context**
6. **Try again with better understanding**

### Recovery Commands
```bash
# View recent changes
git diff

# Revert specific file
git checkout -- path/to/file.py

# Create recovery point
git stash save "before attempting fix for X"

# Check what was working
git log --oneline -10
```

---

## 📊 Success Metrics

### Good Code Change Indicators:
- ✅ One problem, one fix
- ✅ Clear justification documented
- ✅ Related functionality still works
- ✅ No new errors introduced
- ✅ Can explain change to someone else
- ✅ Have rollback plan ready

### Bad Code Change Indicators:
- ❌ Multiple unrelated changes
- ❌ "Not sure why but it works now"
- ❌ Fixed one thing, broke two others
- ❌ Can't explain what was wrong originally
- ❌ No way to undo changes
- ❌ "Let me try one more thing..."

---

## 🎓 The Mental Model

**Think like a surgeon, not a mechanic:**
- Surgeons understand anatomy before cutting
- They know what connects to what
- They plan the procedure
- They minimize invasiveness
- They monitor vital signs throughout
- They have contingency plans

**Your code is a living system** - treat it with the same care.

---

## 🔑 The Golden Rules

1. **No change without understanding**
2. **No fix without root cause**
3. **No modification without impact analysis**
4. **No commit without verification**
5. **No assumption without investigation**

---

## 📢 The Battle Cry

**"STOP THE PANIC FIXES!"**

Better to spend 10 minutes understanding than 2 hours undoing cascade failures.

---

*This protocol is MANDATORY for all agents performing code changes.*
*Violations result in immediate rollback and context gathering requirement.*