# BMAD Method v16 - Quick Start Guide

## 🚀 Start Here - 5 Minutes to Success

### Prerequisites
- Frappe bench installed
- ERPNext installed (optional)
- Working directory: `/home/frappe/frappe-bench`

## Step 1: Create Your App (1 minute)

```bash
cd /home/frappe/frappe-bench
bench new-app my_app
```

## Step 2: Initialize BMAD Structure (30 seconds)

```bash
cd apps/my_app

# Run the magic script (replace my_app and my_module with your names)
/home/frappe/bmad-erpnext-development/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/utils/PROJECT-INIT-STRUCTURE.sh my_app my_module
```

This creates:
- ✅ All required folders
- ✅ `.bmad-erpnext-v16` symlink
- ✅ `PROJECT_CONTEXT.yaml` registry
- ✅ Standard structure compliance

## Step 3: Start Planning (2 minutes)

### Activate the Architect
```bash
/bmadErpNext:agent:erpnext-architect
```

### Generate Your PRD
```
*generate-prd
# Answer the questions about your app
```

### Create Architecture
```
*design-architecture
# Architecture is generated from PRD
```

## Step 4: Begin Development (1 minute)

### Activate Development Coordinator
```bash
/bmadErpNext:agent:development-coordinator
```

The coordinator will:
- Route tasks to appropriate specialists
- Enforce quality gates
- Track all handoffs
- Ensure Frappe-first compliance

## Step 5: Verify Everything Works (30 seconds)

```bash
# Check structure
ls -la .bmad-erpnext-v16  # Should show symlink

# Check context
cat PROJECT_CONTEXT.yaml  # Should show your app info

# Check folders
ls docs/  # Should be empty but ready
ls tests/  # Should have subdirectories
```

## 🎯 Common First Tasks

### Create Your First DocType
```bash
/bmadErpNext:agent:doctype-designer
*create-doctype Customer Order
```

### Create Your First API
```bash
/bmadErpNext:agent:api-developer
*create-api-endpoint get_customer_data
```

### Create Vue Components
```bash
/bmadErpNext:agent:vue-spa-architect
*create-vue-dashboard
```

## 📁 Where Everything Lives

```
my_app/
├── .bmad-erpnext-v16/     # → Symlink to expansion pack
├── docs/                   # Your planning documents
│   ├── prd.md             # Product Requirements
│   ├── architecture.md    # Technical Architecture
│   ├── epics/             # Feature epics
│   └── stories/           # User stories
├── my_app/                # Your actual code
│   ├── api/               # API endpoints
│   ├── my_module/         # Module with DocTypes
│   └── public/js/         # Vue components
├── tests/                 # Test files
└── PROJECT_CONTEXT.yaml   # Master registry
```

## 🔥 Power User Commands

### See All Available Agents
```bash
ls .bmad-erpnext-v16/agents/
```

### Run Quality Gates
```bash
# Activate compliance validator
/bmadErpNext:agent:frappe-compliance-validator
*validate-app
```

### Generate Documentation
```bash
/bmadErpNext:agent:documentation-specialist
*generate-docs
```

## ⚠️ Critical Rules

1. **ALWAYS** run PROJECT-INIT-STRUCTURE.sh first
2. **NEVER** create files outside standard structure
3. **ALWAYS** use Frappe built-in features (no external libraries)
4. **NEVER** skip quality gates

## 🆘 Quick Troubleshooting

### "File not found"
```bash
# Re-run initialization
./PROJECT-INIT-STRUCTURE.sh my_app my_module
```

### "Quality gate failed"
```bash
# Check what failed
cat .bmad-project/quality-reports/latest.yaml
```

### "Agent doesn't know where files are"
```bash
# Verify PROJECT_CONTEXT.yaml exists
cat PROJECT_CONTEXT.yaml
```

## 📚 Next Steps

1. Read **UNIVERSAL-FOLDER-STRUCTURE.md** - Understand the structure
2. Review **FILE-REFERENCE-SYSTEM.md** - Learn file discovery
3. Explore **agents/** directory - See all available agents
4. Check **workflows/** - Understand automated processes

## 🎉 Success Checklist

- [ ] App created with `bench new-app`
- [ ] PROJECT-INIT-STRUCTURE.sh executed
- [ ] `.bmad-erpnext-v16` symlink exists
- [ ] PROJECT_CONTEXT.yaml created
- [ ] Architect agent activated
- [ ] PRD generated
- [ ] Architecture designed
- [ ] Development started

---

**Pro Tip**: Keep this guide open in another terminal for quick reference!

**Remember**: The system enforces quality - embrace it, don't fight it!