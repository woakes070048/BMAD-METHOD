#!/bin/bash

# PROJECT-INIT-STRUCTURE.sh - Initialize BMAD folder structure for ERPNext apps
# This script MUST be run for every new ERPNext app to ensure structure compliance
# Usage: ./PROJECT-INIT-STRUCTURE.sh {app_name} {module_name}

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ "$#" -ne 2 ]; then
    echo -e "${RED}Error: Incorrect number of arguments${NC}"
    echo "Usage: $0 {app_name} {module_name}"
    echo "Example: $0 customer_portal customer_management"
    exit 1
fi

APP_NAME=$1
MODULE_NAME=$2
CURRENT_DIR=$(pwd)
BENCH_DIR="/home/frappe/frappe-bench"
APP_DIR="${BENCH_DIR}/apps/${APP_NAME}"
EXPANSION_PACK_DIR="/home/frappe/bmad-erpnext-development/BMAD-METHOD/expansion-packs/bmad-erpnext-v16"

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}BMAD Method - Project Structure Initialization${NC}"
echo -e "${BLUE}==================================================${NC}"
echo -e "App Name: ${GREEN}${APP_NAME}${NC}"
echo -e "Module Name: ${GREEN}${MODULE_NAME}${NC}"
echo -e "App Directory: ${GREEN}${APP_DIR}${NC}"

# Verify we're in the right location
if [ ! -d "${APP_DIR}" ]; then
    echo -e "${RED}Error: App directory does not exist: ${APP_DIR}${NC}"
    echo "Please create the app first using: bench new-app ${APP_NAME}"
    exit 1
fi

cd "${APP_DIR}"

# Check if already initialized
if [ -f ".bmad-init" ]; then
    echo -e "${YELLOW}Warning: BMAD structure already initialized for this app${NC}"
    read -p "Do you want to reinitialize? This will preserve existing files (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Initialization cancelled"
        exit 0
    fi
fi

echo -e "\n${BLUE}Step 1: Creating BMAD folder structure...${NC}"

# Create BMAD planning folders
mkdir -p docs/epics
mkdir -p docs/stories
mkdir -p docs/planning

# Create test folders
mkdir -p tests/unit
mkdir -p tests/integration
mkdir -p tests/plans
mkdir -p tests/results
mkdir -p tests/coverage
mkdir -p tests/compliance

# Create .bmad-erpnext-v16 folders (for project-specific BMAD files)
mkdir -p .bmad-project/handoffs
mkdir -p .bmad-project/session-logs
mkdir -p .bmad-project/quality-reports

echo -e "${GREEN}✓ Folder structure created${NC}"

# Step 2: Create symlink to expansion pack
echo -e "\n${BLUE}Step 2: Creating expansion pack symlink...${NC}"

if [ -L ".bmad-erpnext-v16" ]; then
    echo -e "${YELLOW}Symlink already exists, verifying...${NC}"
    if [ "$(readlink .bmad-erpnext-v16)" != "${EXPANSION_PACK_DIR}" ]; then
        echo -e "${YELLOW}Updating symlink to correct location${NC}"
        rm .bmad-erpnext-v16
        ln -s "${EXPANSION_PACK_DIR}" .bmad-erpnext-v16
    fi
elif [ -e ".bmad-erpnext-v16" ]; then
    echo -e "${RED}Error: .bmad-erpnext-v16 exists but is not a symlink${NC}"
    echo "Please remove it manually and run this script again"
    exit 1
else
    ln -s "${EXPANSION_PACK_DIR}" .bmad-erpnext-v16
fi

echo -e "${GREEN}✓ Expansion pack symlink created${NC}"

# Step 3: Create PROJECT_CONTEXT.yaml
echo -e "\n${BLUE}Step 3: Creating PROJECT_CONTEXT.yaml...${NC}"

cat > PROJECT_CONTEXT.yaml << EOF
# PROJECT_CONTEXT.yaml - BMAD Method Project Registry
# Auto-generated on $(date -Iseconds)
# DO NOT EDIT MANUALLY - Updated by agents during development

project_context:
  # Basic project information
  app_name: "${APP_NAME}"
  module_name: "${MODULE_NAME}"
  created_date: "$(date -Iseconds)"
  bmad_version: "v16"
  initialized_by: "PROJECT-INIT-STRUCTURE.sh"
  
  # Path configuration
  paths:
    app_root: "${APP_DIR}/"
    expansion_pack: ".bmad-erpnext-v16/"  # Symlink to expansion pack
    bench_dir: "${BENCH_DIR}/"
    
  # Document registry (updated as documents are created)
  documents:
    planning:
      prd:
        exists: false
        path: "docs/prd.md"
        created_by: null
        created_date: null
        version: null
      architecture:
        exists: false
        path: "docs/architecture.md"
        created_by: null
        created_date: null
        version: null
      project_structure:
        exists: false
        path: "docs/PROJECT_STRUCTURE.md"
        created_by: null
        created_date: null
        
    development:
      epics: []  # List of epic files in docs/epics/
      stories: []  # List of story files in docs/stories/
      tasks: []  # Active development tasks
      
    testing:
      test_plans: []  # Test plan documents
      latest_results: null  # Path to latest test results
      coverage_report: null  # Path to latest coverage report
      compliance_report: null  # Path to latest compliance audit
      
  # Component registry (updated as components are created)
  components:
    doctypes: []  # List of created DocTypes with paths
    apis: []  # List of API endpoints with file paths
    pages: []  # List of Frappe pages
    reports: []  # List of reports
    print_formats: []  # List of print formats
    workflows: []  # List of workflows
    vue_components: []  # List of Vue components with bundle paths
    
  # Quality metrics (updated by quality gates)
  quality:
    last_quality_gate: null
    compliance_status: "not_checked"
    test_coverage: 0
    lint_status: "not_checked"
    security_scan: "not_performed"
    
  # Handoff tracking
  handoffs:
    active: []  # Current active handoffs
    completed: []  # Completed handoffs archive
    
  # Session tracking
  sessions:
    last_agent: null
    last_activity: null
    total_sessions: 0
    
  # Validation status
  validation:
    structure_compliant: true
    last_validated: "$(date -Iseconds)"
    validation_errors: []
EOF

echo -e "${GREEN}✓ PROJECT_CONTEXT.yaml created${NC}"

# Step 4: Create marker files
echo -e "\n${BLUE}Step 4: Creating marker files...${NC}"

# Create .bmad-init marker
cat > .bmad-init << EOF
# BMAD Method Initialized
Date: $(date -Iseconds)
App: ${APP_NAME}
Module: ${MODULE_NAME}
Version: v16
EOF

# Create .bmad-project/project-config.yaml
cat > .bmad-project/project-config.yaml << EOF
# Project-specific BMAD configuration
project_config:
  app_name: "${APP_NAME}"
  module_name: "${MODULE_NAME}"
  
  # Agent settings for this project
  agents:
    default_context: "development"
    quality_gates_enabled: true
    auto_documentation: true
    
  # Workflow settings
  workflows:
    enforce_quality_gates: true
    require_handoffs: true
    track_sessions: true
    
  # File naming conventions (DO NOT CHANGE)
  naming:
    doctypes: "PascalCase"
    python_files: "snake_case"
    vue_components: "PascalCase"
    api_methods: "snake_case"
    
  # Validation rules
  validation:
    enforce_frappe_first: true
    block_external_libs: true
    require_whitelisting: true
    require_permission_checks: true
EOF

echo -e "${GREEN}✓ Marker files created${NC}"

# Step 5: Create initial documentation templates
echo -e "\n${BLUE}Step 5: Creating documentation templates...${NC}"

# Create README.md if it doesn't exist
if [ ! -f "README.md" ]; then
    cat > README.md << EOF
# ${APP_NAME}

## Overview
ERPNext application created with BMAD Method v16.

## Structure
This app follows the UNIVERSAL-FOLDER-STRUCTURE defined in:
\`.bmad-erpnext-v16/UNIVERSAL-FOLDER-STRUCTURE.md\`

## Module
- **Module Name**: ${MODULE_NAME}

## Documentation
- **PRD**: docs/prd.md (to be created)
- **Architecture**: docs/architecture.md (to be created)
- **Stories**: docs/stories/
- **Epics**: docs/epics/

## Testing
- **Test Plans**: tests/plans/
- **Results**: tests/results/
- **Coverage**: tests/coverage/

## BMAD Method
This app uses BMAD Method v16 for development coordination.
Access agents via: \`.bmad-erpnext-v16/agents/\`

## Initialization
Initialized on: $(date -Iseconds)
EOF
    echo -e "${GREEN}✓ README.md created${NC}"
else
    echo -e "${YELLOW}⚠ README.md already exists, skipping${NC}"
fi

# Step 6: Validate structure
echo -e "\n${BLUE}Step 6: Validating folder structure...${NC}"

ERRORS=0

# Check required folders
REQUIRED_FOLDERS=(
    "docs"
    "docs/epics"
    "docs/stories"
    "tests"
    "tests/plans"
    "tests/results"
    ".bmad-project"
    ".bmad-project/handoffs"
)

for folder in "${REQUIRED_FOLDERS[@]}"; do
    if [ ! -d "$folder" ]; then
        echo -e "${RED}✗ Missing folder: $folder${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓ $folder${NC}"
    fi
done

# Check required files
REQUIRED_FILES=(
    "PROJECT_CONTEXT.yaml"
    ".bmad-init"
    ".bmad-project/project-config.yaml"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ Missing file: $file${NC}"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓ $file${NC}"
    fi
done

# Check symlink
if [ ! -L ".bmad-erpnext-v16" ]; then
    echo -e "${RED}✗ Expansion pack symlink not created${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ .bmad-erpnext-v16 symlink${NC}"
fi

# Final report
echo -e "\n${BLUE}==================================================${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ BMAD Structure Initialization Complete!${NC}"
    echo -e "${GREEN}✓ All validations passed${NC}"
    echo ""
    echo -e "Next steps:"
    echo -e "1. ${BLUE}Activate ERPNext Architect:${NC} /bmadErpNext:agent:erpnext-architect"
    echo -e "2. ${BLUE}Create PRD:${NC} Use architect to generate Product Requirements Document"
    echo -e "3. ${BLUE}Create Architecture:${NC} Design technical architecture"
    echo -e "4. ${BLUE}Begin Development:${NC} Follow BMAD Method workflows"
    echo ""
    echo -e "Access expansion pack resources via: ${GREEN}.bmad-erpnext-v16/${NC}"
    echo -e "Track project status in: ${GREEN}PROJECT_CONTEXT.yaml${NC}"
else
    echo -e "${RED}✗ Initialization completed with $ERRORS errors${NC}"
    echo -e "${YELLOW}Please fix the errors and run validation again${NC}"
fi
echo -e "${BLUE}==================================================${NC}"

cd "${CURRENT_DIR}"