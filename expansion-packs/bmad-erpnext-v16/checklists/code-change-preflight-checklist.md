# Code Change Pre-Flight Checklist
## The Mandatory Checklist Before ANY Code Modification

**USE THIS**: Before making ANY code change, no matter how small.
**PURPOSE**: Prevent cascade failures and panic-fix spirals.

---

## ✈️ PRE-FLIGHT CHECKLIST

### Phase 1: STOP AND THINK (30 seconds)
```
□ STOPPED - I've paused before acting
□ BREATHING - I'm not in panic-fix mode  
□ THINKING - I understand what I'm about to do
```

### Phase 2: CONTEXT CHECK (2 minutes)
```
□ I know EXACTLY what error I'm fixing
□ I can reproduce the problem consistently
□ I know what IS working (and shouldn't break)
□ I've checked what was recently changed
□ I understand the business purpose of this code
```

### Phase 3: INVESTIGATION (5 minutes)
```
□ I've read the ENTIRE file I'm about to change
□ I've checked what other files import this
□ I've looked for similar patterns elsewhere
□ I've identified the ROOT CAUSE (not just symptom)
□ I've checked if this has been tried before
```

### Phase 4: PLANNING (2 minutes)
```
□ I have a SPECIFIC fix in mind (not "try stuff")
□ I've considered at least 2 alternatives
□ I know what COULD break from this change
□ I have a way to TEST if it worked
□ I have a ROLLBACK plan if it fails
```

### Phase 5: SAFETY MEASURES (1 minute)
```
□ I've created a backup/git stash
□ I've documented what I'm changing
□ I've added comments explaining WHY
□ I'm making the MINIMAL change needed
□ I'm not changing unrelated things
```

---

## 🚨 ABORT TRIGGERS

### STOP IMMEDIATELY if:
- ☠️ You're on attempt #4+ without understanding why 1-3 failed
- ☠️ You're changing code you don't understand
- ☠️ You can't explain the root cause
- ☠️ You're making changes "just to see"
- ☠️ Each fix creates new errors
- ☠️ You've lost track of what you've changed

### When you hit an ABORT TRIGGER:
1. **STOP all changes**
2. **REVERT to last known good state**
3. **DOCUMENT what you learned**
4. **GATHER more context**
5. **ASK for help or different approach**

---

## 📝 THE CHANGE RECORD

### For EVERY change, document:

```yaml
Change_Record:
  timestamp: "2024-01-18 14:30"
  
  problem:
    error: "Exact error message"
    location: "Where it happens"
    frequency: "Always/Sometimes/Random"
  
  diagnosis:
    root_cause: "Why this is happening"
    evidence: "How I know this is the cause"
    
  change:
    file: "path/to/file.py"
    lines: "45-47"
    before: "old code"
    after: "new code"
    reason: "Why this specific change"
    
  testing:
    verification: "How I tested"
    result: "What happened"
    side_effects: "What else changed"
    
  status:
    outcome: "Fixed/Partial/Failed"
    next_steps: "What to do next"
```

---

## 🎯 THE 5-MINUTE RULE

If you've been trying to fix something for 5 minutes without progress:

1. **STOP**
2. **Run this diagnostic**:
   ```bash
   echo "=== DIAGNOSTIC ==="
   echo "1. What am I trying to fix?"
   echo "2. What have I tried?"
   echo "3. Why didn't it work?"
   echo "4. What don't I understand?"
   echo "5. What context am I missing?"
   ```
3. **Get the missing context**
4. **Start fresh with understanding**

---

## ✅ GOOD CHANGE PATTERN

```python
# ✅ GOOD: Clear, justified, minimal change
"""
FIX: Add permission check to prevent 500 error
CAUSE: frappe.get_doc() called without checking permissions
TEST: Verified with users with/without Customer access
"""
if not frappe.has_permission("Customer", "read"):  # Added check
    frappe.throw(_("Insufficient permissions"))
# ... rest of original code unchanged
```

---

## ❌ BAD CHANGE PATTERN

```python
# ❌ BAD: Multiple random changes hoping something works
# Maybe this?
try:
    # Changed this
    customer = get_customer(name)  
except:
    # And added this
    customer = None
    # Also trying this
    pass
# Not sure but changed this too
return customer or {}  # Was just 'return customer'
```

---

## 🚀 THE QUICK REFERENCE

### Before EVERY Change:
1. **KNOW** what's broken
2. **KNOW** why it's broken  
3. **KNOW** what your fix does
4. **KNOW** what it might break
5. **KNOW** how to undo it

### The Three Laws:
1. **First Law**: Do no harm (don't break working code)
2. **Second Law**: Understand before acting
3. **Third Law**: Document everything

### The Prime Directive:
**"Better to understand for 10 minutes than fix for 2 hours"**

---

## 📊 SUCCESS METRICS

### You're doing it RIGHT if:
- ✅ One problem = One fix
- ✅ You can explain the change to someone else
- ✅ No new errors after your change
- ✅ Related features still work
- ✅ You have confidence in your change

### You're doing it WRONG if:
- ❌ Multiple attempts without understanding
- ❌ "Shotgun" debugging (trying everything)
- ❌ Can't explain why it works now
- ❌ Fixed one thing, broke another
- ❌ "It works but I don't know why"

---

## 🛑 THE FINAL GATE

### Before committing/saving:
```
□ The original problem is fixed
□ No new problems introduced
□ Code is cleaner than before
□ Comments explain any tricky parts
□ I can defend this change in code review
```

---

**REMEMBER**: This checklist is your protection against the cascade of failures that comes from thoughtless changes. Use it EVERY time.

*Print this. Pin it up. Tattoo it on your forehead if needed.*

**NO EXCEPTIONS.**