# analyze-app-dependencies

A critical task for understanding ERPNext app functionality, DocType relationships, and code dependencies before performing any cleanup operations. This ensures no functionality is broken during code cleanup.

## Metadata
```yaml
task_id: analyze-app-dependencies
title: "Deep App Dependency Analysis & Functionality Mapping"
category: analysis
complexity: high
estimated_time: "60-120 minutes"
prerequisites: ["ERPNext app exists", "Database access", "Read permissions"]
outputs: ["Dependency map", "Functionality matrix", "Risk assessment", "Safe cleanup plan"]
elicit: true
agent_compatibility: ["erpnext-app-cleaner", "app-auditor"]
critical: true
```

## Task Description

Perform deep analysis of ERPNext application to understand all functionality, DocType relationships, code dependencies, and business logic before any cleanup operations. This prevents breaking critical app functionality when removing or consolidating code.

## Critical Understanding Requirements

### ELICIT REQUIRED INFORMATION

**App Analysis Details:**
- App name: _______________
- Business purpose/domain: _______________
- Critical workflows: _______________
- Key users/stakeholders: _______________

**Functionality Scope:**
- [ ] All DocTypes and their purposes
- [ ] Custom fields and their business logic
- [ ] Workflows and automation
- [ ] Reports and dashboards
- [ ] API integrations
- [ ] Custom pages and forms

**Risk Tolerance:**
- [ ] Conservative (preserve all functionality, minimal changes)
- [ ] Moderate (optimize while preserving core features)
- [ ] Aggressive (major cleanup, accept some risk)

## Phase 1: DocType Functional Analysis

### 1.1 DocType Discovery and Mapping
```bash
# Create analysis workspace
export ANALYSIS_DIR="/tmp/analysis-{{app_name}}-$(date +%Y%m%d-%H%M%S)"
mkdir -p $ANALYSIS_DIR
cd /home/frappe/frappe-bench/apps/{{app_name}}

echo "=== DOCTYPE ANALYSIS ===" > $ANALYSIS_DIR/doctypes_analysis.txt

# Find all DocTypes
find . -path "*/doctype/*" -name "*.json" | while read doctype_file; do
    doctype_name=$(basename $(dirname $doctype_file))
    echo "Analyzing DocType: $doctype_name" >> $ANALYSIS_DIR/doctypes_analysis.txt
    
    # Extract key information from JSON
    python3 -c "
import json
import sys

try:
    with open('$doctype_file', 'r') as f:
        data = json.load(f)
    
    print(f'DocType: {data.get(\"name\", \"Unknown\")}')
    print(f'Type: {data.get(\"doctype\", \"Standard\")}')
    print(f'Is Submittable: {data.get(\"is_submittable\", 0)}')
    print(f'Is Tree: {data.get(\"is_tree\", 0)}')
    print(f'Is Single: {data.get(\"issingle\", 0)}')
    print(f'Module: {data.get(\"module\", \"Unknown\")}')
    
    # Analyze fields
    fields = data.get('fields', [])
    print(f'Total Fields: {len(fields)}')
    
    # Find special fields
    special_fields = []
    for field in fields:
        if field.get('fieldtype') == 'Check':
            special_fields.append(f'Checkbox: {field.get(\"fieldname\")} - {field.get(\"label\")}')
        elif field.get('fieldtype') == 'Link':
            special_fields.append(f'Link to: {field.get(\"options\")} - {field.get(\"fieldname\")}')
        elif field.get('fieldtype') == 'Table':
            special_fields.append(f'Child Table: {field.get(\"options\")} - {field.get(\"fieldname\")}')
        elif field.get('fieldtype') == 'Select':
            special_fields.append(f'Select: {field.get(\"fieldname\")} - {field.get(\"options\")}')
    
    if special_fields:
        print('Special Fields:')
        for field in special_fields:
            print(f'  - {field}')
    
    print('-' * 50)
    
except Exception as e:
    print(f'Error analyzing {sys.argv[1]}: {e}')
" >> $ANALYSIS_DIR/doctypes_analysis.txt
done
```

### 1.2 DocType Relationship Mapping
```python
# Create relationship analysis script
cat > $ANALYSIS_DIR/analyze_relationships.py << 'EOF'
import json
import os
import sys
from collections import defaultdict

def analyze_doctype_relationships(app_path):
    """Analyze relationships between DocTypes"""
    
    relationships = defaultdict(list)
    doctypes = {}
    
    # Find all DocType JSON files
    for root, dirs, files in os.walk(app_path):
        for file in files:
            if file.endswith('.json') and '/doctype/' in root:
                doctype_path = os.path.join(root, file)
                try:
                    with open(doctype_path, 'r') as f:
                        data = json.load(f)
                        doctype_name = data.get('name')
                        if doctype_name:
                            doctypes[doctype_name] = data
                except Exception as e:
                    print(f"Error reading {doctype_path}: {e}")
    
    # Analyze relationships
    for doctype_name, doctype_data in doctypes.items():
        fields = doctype_data.get('fields', [])
        
        for field in fields:
            fieldtype = field.get('fieldtype')
            
            if fieldtype == 'Link':
                target = field.get('options')
                if target:
                    relationships[doctype_name].append({
                        'type': 'Link',
                        'field': field.get('fieldname'),
                        'target': target,
                        'label': field.get('label')
                    })
            
            elif fieldtype == 'Table':
                target = field.get('options')
                if target:
                    relationships[doctype_name].append({
                        'type': 'Child Table',
                        'field': field.get('fieldname'),
                        'target': target,
                        'label': field.get('label')
                    })
    
    return relationships, doctypes

def find_business_logic_dependencies(app_path):
    """Find Python files that contain business logic for DocTypes"""
    
    business_logic = defaultdict(list)
    
    # Find all Python controller files
    for root, dirs, files in os.walk(app_path):
        for file in files:
            if file.endswith('.py') and '/doctype/' in root:
                py_path = os.path.join(root, file)
                try:
                    with open(py_path, 'r') as f:
                        content = f.read()
                        
                        # Look for validation logic
                        if 'def validate(' in content:
                            business_logic[py_path].append('Has validation logic')
                        
                        # Look for before_save logic
                        if 'def before_save(' in content:
                            business_logic[py_path].append('Has before_save logic')
                        
                        # Look for after_insert logic
                        if 'def after_insert(' in content:
                            business_logic[py_path].append('Has after_insert logic')
                        
                        # Look for on_submit logic
                        if 'def on_submit(' in content:
                            business_logic[py_path].append('Has on_submit logic')
                        
                        # Look for conditional logic (if/else based on fields)
                        if 'if self.' in content and ('==' in content or '!=' in content):
                            business_logic[py_path].append('Has conditional field logic')
                        
                        # Look for checkbox-based logic
                        if any(term in content for term in ['if self.', 'self.get(', 'frappe.db.get_value']):
                            business_logic[py_path].append('Has field-based business logic')
                
                except Exception as e:
                    print(f"Error reading {py_path}: {e}")
    
    return business_logic

if __name__ == "__main__":
    app_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    print("=== DOCTYPE RELATIONSHIPS ===")
    relationships, doctypes = analyze_doctype_relationships(app_path)
    
    for doctype, relations in relationships.items():
        if relations:
            print(f"\n{doctype}:")
            for rel in relations:
                print(f"  {rel['type']}: {rel['field']} -> {rel['target']} ({rel['label']})")
    
    print("\n=== BUSINESS LOGIC ANALYSIS ===")
    business_logic = find_business_logic_dependencies(app_path)
    
    for file_path, logic_types in business_logic.items():
        if logic_types:
            print(f"\n{file_path}:")
            for logic in logic_types:
                print(f"  - {logic}")

EOF

# Run the analysis
cd /home/frappe/frappe-bench/apps/{{app_name}}
python3 $ANALYSIS_DIR/analyze_relationships.py . > $ANALYSIS_DIR/relationships_and_logic.txt
```

## Phase 2: Code Dependency Analysis

### 2.1 Import Dependency Mapping
```bash
echo "=== IMPORT DEPENDENCY ANALYSIS ===" > $ANALYSIS_DIR/import_dependencies.txt

# Find all Python imports across the app
find . -name "*.py" -exec grep -l "^from\|^import" {} \; | while read file; do
    echo "File: $file" >> $ANALYSIS_DIR/import_dependencies.txt
    grep "^from\|^import" "$file" | head -20 >> $ANALYSIS_DIR/import_dependencies.txt
    echo "---" >> $ANALYSIS_DIR/import_dependencies.txt
done

# Create import graph analysis
cat > $ANALYSIS_DIR/analyze_imports.py << 'EOF'
import os
import ast
import sys
from collections import defaultdict, deque

class ImportAnalyzer(ast.NodeVisitor):
    def __init__(self):
        self.imports = []
        self.from_imports = []
    
    def visit_Import(self, node):
        for alias in node.names:
            self.imports.append(alias.name)
    
    def visit_ImportFrom(self, node):
        module = node.module or ''
        for alias in node.names:
            self.from_imports.append(f"{module}.{alias.name}")

def analyze_file_imports(file_path):
    """Analyze imports in a Python file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        tree = ast.parse(content)
        analyzer = ImportAnalyzer()
        analyzer.visit(tree)
        
        return {
            'imports': analyzer.imports,
            'from_imports': analyzer.from_imports
        }
    except Exception as e:
        return {'error': str(e)}

def build_dependency_graph(app_path):
    """Build dependency graph for the app"""
    
    dependencies = defaultdict(set)
    all_files = []
    
    # Find all Python files
    for root, dirs, files in os.walk(app_path):
        for file in files:
            if file.endswith('.py'):
                file_path = os.path.join(root, file)
                all_files.append(file_path)
    
    # Analyze imports for each file
    for file_path in all_files:
        imports_data = analyze_file_imports(file_path)
        
        if 'error' not in imports_data:
            # Look for internal dependencies
            for imp in imports_data['imports'] + imports_data['from_imports']:
                for other_file in all_files:
                    if other_file != file_path:
                        # Check if this import refers to another file in the app
                        other_module = os.path.splitext(os.path.basename(other_file))[0]
                        if other_module in imp or imp.replace('.', '/') in other_file:
                            dependencies[file_path].add(other_file)
    
    return dependencies

def find_critical_dependencies(dependencies):
    """Find files that are heavily depended upon"""
    
    dependents = defaultdict(int)
    
    for file_path, deps in dependencies.items():
        for dep in deps:
            dependents[dep] += 1
    
    # Sort by dependency count
    critical_files = sorted(dependents.items(), key=lambda x: x[1], reverse=True)
    
    return critical_files

if __name__ == "__main__":
    app_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    print("=== DEPENDENCY GRAPH ANALYSIS ===")
    dependencies = build_dependency_graph(app_path)
    
    print(f"Found {len(dependencies)} files with dependencies")
    
    # Show dependencies for each file
    for file_path, deps in dependencies.items():
        if deps:
            print(f"\n{file_path} depends on:")
            for dep in sorted(deps):
                print(f"  - {dep}")
    
    print("\n=== CRITICAL DEPENDENCIES ===")
    critical_files = find_critical_dependencies(dependencies)
    
    print("Files that other files depend on (high risk to modify):")
    for file_path, count in critical_files[:10]:  # Top 10
        if count > 0:
            print(f"  {file_path}: {count} dependent files")

EOF

cd /home/frappe/frappe-bench/apps/{{app_name}}
python3 $ANALYSIS_DIR/analyze_imports.py . >> $ANALYSIS_DIR/import_dependencies.txt
```

### 2.2 Function Usage Analysis
```bash
echo "=== FUNCTION USAGE ANALYSIS ===" > $ANALYSIS_DIR/function_usage.txt

# Find all function definitions
grep -r "^def " . --include="*.py" | while read line; do
    file=$(echo "$line" | cut -d: -f1)
    func_def=$(echo "$line" | cut -d: -f2-)
    func_name=$(echo "$func_def" | sed 's/def \([^(]*\).*/\1/')
    
    echo "Function: $func_name in $file" >> $ANALYSIS_DIR/function_usage.txt
    
    # Count usages of this function
    usage_count=$(grep -r "$func_name" . --include="*.py" --exclude="$file" | wc -l)
    echo "  Used $usage_count times in other files" >> $ANALYSIS_DIR/function_usage.txt
    
    if [ $usage_count -gt 0 ]; then
        echo "  Used in:" >> $ANALYSIS_DIR/function_usage.txt
        grep -r "$func_name" . --include="*.py" --exclude="$file" | head -5 | while read usage; do
            echo "    - $(echo "$usage" | cut -d: -f1)" >> $ANALYSIS_DIR/function_usage.txt
        done
    fi
    echo "---" >> $ANALYSIS_DIR/function_usage.txt
done
```

## Phase 3: Business Logic Impact Analysis

### 3.1 Checkbox and Conditional Logic Analysis
```python
cat > $ANALYSIS_DIR/analyze_business_logic.py << 'EOF'
import os
import ast
import json
import sys
from collections import defaultdict

class BusinessLogicAnalyzer(ast.NodeVisitor):
    def __init__(self, doctype_fields):
        self.doctype_fields = doctype_fields
        self.conditional_logic = []
        self.field_references = defaultdict(list)
        self.current_function = None
    
    def visit_FunctionDef(self, node):
        self.current_function = node.name
        self.generic_visit(node)
        self.current_function = None
    
    def visit_If(self, node):
        # Analyze if conditions that reference DocType fields
        condition_code = ast.unparse(node.test) if hasattr(ast, 'unparse') else str(node.test)
        
        # Check if condition references known fields
        for field_name in self.doctype_fields:
            if field_name in condition_code:
                self.conditional_logic.append({
                    'function': self.current_function,
                    'condition': condition_code,
                    'field': field_name,
                    'line': node.lineno
                })
        
        self.generic_visit(node)
    
    def visit_Attribute(self, node):
        # Track field access patterns like self.field_name
        if isinstance(node.value, ast.Name) and node.value.id == 'self':
            field_name = node.attr
            if field_name in self.doctype_fields:
                self.field_references[field_name].append({
                    'function': self.current_function,
                    'line': getattr(node, 'lineno', 0)
                })
        
        self.generic_visit(node)

def get_doctype_fields(doctype_json_path):
    """Extract all field names from DocType JSON"""
    try:
        with open(doctype_json_path, 'r') as f:
            data = json.load(f)
        
        fields = []
        for field in data.get('fields', []):
            field_name = field.get('fieldname')
            if field_name:
                fields.append(field_name)
        
        return fields
    except Exception as e:
        print(f"Error reading DocType JSON: {e}")
        return []

def analyze_business_logic_in_file(file_path, doctype_fields):
    """Analyze business logic in a Python file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        tree = ast.parse(content)
        analyzer = BusinessLogicAnalyzer(doctype_fields)
        analyzer.visit(tree)
        
        return {
            'conditional_logic': analyzer.conditional_logic,
            'field_references': dict(analyzer.field_references)
        }
    except Exception as e:
        return {'error': str(e)}

def analyze_app_business_logic(app_path):
    """Analyze business logic across the entire app"""
    
    business_logic_map = {}
    
    # Find all DocTypes and their controllers
    for root, dirs, files in os.walk(app_path):
        if '/doctype/' in root:
            doctype_json = None
            controller_py = None
            
            for file in files:
                if file.endswith('.json'):
                    doctype_json = os.path.join(root, file)
                elif file.endswith('.py') and not file.startswith('test_'):
                    controller_py = os.path.join(root, file)
            
            if doctype_json and controller_py:
                doctype_name = os.path.basename(root)
                doctype_fields = get_doctype_fields(doctype_json)
                
                if doctype_fields:
                    logic_analysis = analyze_business_logic_in_file(controller_py, doctype_fields)
                    
                    if 'error' not in logic_analysis:
                        business_logic_map[doctype_name] = {
                            'controller_file': controller_py,
                            'fields': doctype_fields,
                            'logic_analysis': logic_analysis
                        }
    
    return business_logic_map

if __name__ == "__main__":
    app_path = sys.argv[1] if len(sys.argv) > 1 else "."
    
    print("=== BUSINESS LOGIC IMPACT ANALYSIS ===")
    business_logic = analyze_app_business_logic(app_path)
    
    for doctype_name, data in business_logic.items():
        print(f"\nDocType: {doctype_name}")
        print(f"Controller: {data['controller_file']}")
        print(f"Fields: {len(data['fields'])}")
        
        logic = data['logic_analysis']
        
        if logic.get('conditional_logic'):
            print("  Conditional Logic:")
            for condition in logic['conditional_logic']:
                print(f"    - Function: {condition['function']}")
                print(f"      Condition: {condition['condition']}")
                print(f"      Field: {condition['field']}")
                print(f"      Line: {condition['line']}")
        
        if logic.get('field_references'):
            print("  Field References:")
            for field, refs in logic['field_references'].items():
                print(f"    - {field}: {len(refs)} references")

EOF

cd /home/frappe/frappe-bench/apps/{{app_name}}
python3 $ANALYSIS_DIR/analyze_business_logic.py . > $ANALYSIS_DIR/business_logic_analysis.txt
```

## Phase 4: Safe Cleanup Planning

### 4.1 Risk Assessment Matrix
```python
cat > $ANALYSIS_DIR/create_risk_matrix.py << 'EOF'
import json
import os
import sys

def create_risk_assessment(analysis_dir):
    """Create risk assessment for potential cleanup operations"""
    
    risk_matrix = {
        'high_risk': [],
        'medium_risk': [],
        'low_risk': [],
        'safe_to_modify': []
    }
    
    # Read analysis files
    try:
        # Analyze import dependencies
        with open(f"{analysis_dir}/import_dependencies.txt", 'r') as f:
            import_content = f.read()
        
        # Analyze business logic
        with open(f"{analysis_dir}/business_logic_analysis.txt", 'r') as f:
            logic_content = f.read()
        
        # Analyze function usage
        with open(f"{analysis_dir}/function_usage.txt", 'r') as f:
            function_content = f.read()
        
    except Exception as e:
        print(f"Error reading analysis files: {e}")
        return risk_matrix
    
    # Create risk assessment based on analysis
    
    # High risk: Files with heavy dependencies or critical business logic
    if "dependent files" in import_content:
        lines = import_content.split('\n')
        for line in lines:
            if ": " in line and "dependent files" in line:
                parts = line.split(': ')
                if len(parts) > 1:
                    count = int(parts[1].split()[0])
                    if count > 3:  # Heavily depended upon
                        risk_matrix['high_risk'].append({
                            'file': parts[0].strip(),
                            'reason': f"Heavily depended upon ({count} dependencies)",
                            'type': 'import_dependency'
                        })
    
    # Medium risk: Files with business logic
    if "Conditional Logic:" in logic_content:
        risk_matrix['medium_risk'].append({
            'type': 'business_logic',
            'reason': 'Contains conditional logic based on DocType fields',
            'details': 'Review carefully before modifying'
        })
    
    # Low risk: Functions with minimal usage
    lines = function_content.split('\n')
    current_function = None
    for line in lines:
        if line.startswith('Function: '):
            current_function = line
        elif 'Used 0 times' in line and current_function:
            risk_matrix['low_risk'].append({
                'function': current_function,
                'reason': 'Unused function - safe to remove',
                'type': 'unused_code'
            })
    
    return risk_matrix

def generate_safe_cleanup_plan(risk_matrix):
    """Generate a safe cleanup plan based on risk assessment"""
    
    cleanup_plan = {
        'phase_1_safe': [],
        'phase_2_careful': [],
        'phase_3_risky': [],
        'preserve': []
    }
    
    # Phase 1: Safe operations (low risk)
    for item in risk_matrix['low_risk']:
        if item['type'] == 'unused_code':
            cleanup_plan['phase_1_safe'].append({
                'action': 'Remove unused function',
                'target': item['function'],
                'reason': item['reason']
            })
    
    # Phase 2: Careful operations (medium risk)
    for item in risk_matrix['medium_risk']:
        cleanup_plan['phase_2_careful'].append({
            'action': 'Review and potentially refactor',
            'target': item.get('type', 'Unknown'),
            'reason': item['reason'],
            'requirements': ['Backup', 'Testing', 'Code Review']
        })
    
    # Phase 3: Risky operations (high risk)
    for item in risk_matrix['high_risk']:
        cleanup_plan['phase_3_risky'].append({
            'action': 'Preserve or very careful modification',
            'target': item['file'],
            'reason': item['reason'],
            'requirements': ['Full backup', 'Comprehensive testing', 'Rollback plan']
        })
    
    return cleanup_plan

if __name__ == "__main__":
    analysis_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    
    print("=== RISK ASSESSMENT MATRIX ===")
    risk_matrix = create_risk_assessment(analysis_dir)
    
    for risk_level, items in risk_matrix.items():
        if items:
            print(f"\n{risk_level.upper().replace('_', ' ')}:")
            for item in items:
                print(f"  - {item}")
    
    print("\n=== SAFE CLEANUP PLAN ===")
    cleanup_plan = generate_safe_cleanup_plan(risk_matrix)
    
    for phase, actions in cleanup_plan.items():
        if actions:
            print(f"\n{phase.upper().replace('_', ' ')}:")
            for action in actions:
                print(f"  - Action: {action['action']}")
                print(f"    Target: {action['target']}")
                print(f"    Reason: {action['reason']}")
                if 'requirements' in action:
                    print(f"    Requirements: {', '.join(action['requirements'])}")

EOF

python3 $ANALYSIS_DIR/create_risk_matrix.py $ANALYSIS_DIR > $ANALYSIS_DIR/risk_assessment.txt
```

## Phase 5: Validation and Testing Plan

### 5.1 Pre-Cleanup Testing Protocol
```bash
echo "=== PRE-CLEANUP TESTING PROTOCOL ===" > $ANALYSIS_DIR/testing_plan.txt

# Create comprehensive test plan
cat >> $ANALYSIS_DIR/testing_plan.txt << 'EOF'

## Functional Testing Requirements

### 1. DocType Testing
For each DocType identified:
- [ ] Create new document
- [ ] Save document
- [ ] Submit document (if submittable)
- [ ] Test all checkbox/select field combinations
- [ ] Verify conditional logic works
- [ ] Test validation rules
- [ ] Check child table operations

### 2. Workflow Testing
For each identified workflow:
- [ ] Test normal flow path
- [ ] Test exception paths
- [ ] Verify state transitions
- [ ] Check approval processes
- [ ] Test rejection scenarios

### 3. API Testing
For each API endpoint:
- [ ] Test with valid inputs
- [ ] Test with invalid inputs
- [ ] Verify authentication
- [ ] Check permission controls
- [ ] Test error handling

### 4. Report Testing
For each report:
- [ ] Run with default filters
- [ ] Test custom filters
- [ ] Verify data accuracy
- [ ] Check export functionality
- [ ] Test performance with large datasets

## Test Automation Script
EOF

# Create automated testing script
cat > $ANALYSIS_DIR/test_app_functionality.py << 'EOF'
import frappe
import json
import sys
from frappe.test_runner import make_test_records

def test_doctype_basic_operations(doctype_name):
    """Test basic CRUD operations for a DocType"""
    
    test_results = []
    
    try:
        # Test document creation
        doc = frappe.new_doc(doctype_name)
        test_results.append(f"✓ Can create new {doctype_name}")
        
        # Try to get DocType meta
        meta = frappe.get_meta(doctype_name)
        test_results.append(f"✓ DocType meta accessible for {doctype_name}")
        
        # Check if any required fields
        required_fields = [f.fieldname for f in meta.fields if f.reqd]
        if required_fields:
            test_results.append(f"⚠️ {doctype_name} has required fields: {required_fields}")
        
        # Test field access
        for field in meta.fields:
            if hasattr(doc, field.fieldname):
                test_results.append(f"✓ Field {field.fieldname} accessible")
            else:
                test_results.append(f"✗ Field {field.fieldname} NOT accessible")
        
    except Exception as e:
        test_results.append(f"✗ Error testing {doctype_name}: {str(e)}")
    
    return test_results

def test_all_doctypes(app_name):
    """Test all DocTypes in the app"""
    
    all_results = {}
    
    # Get all DocTypes for the app
    doctypes = frappe.get_all("DocType", filters={"module": ["like", f"%{app_name}%"]})
    
    for dt in doctypes:
        doctype_name = dt.name
        results = test_doctype_basic_operations(doctype_name)
        all_results[doctype_name] = results
    
    return all_results

if __name__ == "__main__":
    app_name = sys.argv[1] if len(sys.argv) > 1 else None
    
    if not app_name:
        print("Please provide app name")
        sys.exit(1)
    
    print(f"=== TESTING APP: {app_name} ===")
    
    results = test_all_doctypes(app_name)
    
    for doctype, tests in results.items():
        print(f"\nDocType: {doctype}")
        for test in tests:
            print(f"  {test}")

EOF
```

## Success Criteria & Safety Checklist

### Critical Safety Requirements
- ✅ **Complete dependency map created** - No file can be modified without understanding its dependencies
- ✅ **Business logic documented** - All conditional logic and field-based operations identified  
- ✅ **Risk assessment completed** - Every potential change classified by risk level
- ✅ **Testing protocol established** - Comprehensive pre/post cleanup testing plan
- ✅ **Backup strategy confirmed** - Full rollback capability ensured
- ✅ **Import impact analysis** - All file moves/deletions account for import updates

### Pre-Cleanup Validation
```bash
# Final validation checklist
echo "=== FINAL VALIDATION CHECKLIST ===" > $ANALYSIS_DIR/final_validation.txt

echo "1. Dependency Analysis Complete: $([ -f $ANALYSIS_DIR/import_dependencies.txt ] && echo "✓" || echo "✗")" >> $ANALYSIS_DIR/final_validation.txt
echo "2. Business Logic Mapped: $([ -f $ANALYSIS_DIR/business_logic_analysis.txt ] && echo "✓" || echo "✗")" >> $ANALYSIS_DIR/final_validation.txt  
echo "3. Risk Assessment Done: $([ -f $ANALYSIS_DIR/risk_assessment.txt ] && echo "✓" || echo "✗")" >> $ANALYSIS_DIR/final_validation.txt
echo "4. Testing Plan Created: $([ -f $ANALYSIS_DIR/testing_plan.txt ] && echo "✓" || echo "✗")" >> $ANALYSIS_DIR/final_validation.txt

# Count critical dependencies
high_risk_count=$(grep -c "high_risk" $ANALYSIS_DIR/risk_assessment.txt 2>/dev/null || echo "0")
echo "5. High Risk Items Identified: $high_risk_count" >> $ANALYSIS_DIR/final_validation.txt

# Verify no critical files will be modified without approval
echo "6. Critical Files Protected: Manual review required for high-risk modifications" >> $ANALYSIS_DIR/final_validation.txt

echo -e "\n=== SAFETY RECOMMENDATIONS ===" >> $ANALYSIS_DIR/final_validation.txt
echo "- Create full app backup before any changes" >> $ANALYSIS_DIR/final_validation.txt
echo "- Test all DocType operations after cleanup" >> $ANALYSIS_DIR/final_validation.txt
echo "- Verify all import statements still work" >> $ANALYSIS_DIR/final_validation.txt
echo "- Run comprehensive functional tests" >> $ANALYSIS_DIR/final_validation.txt
echo "- Keep rollback plan ready" >> $ANALYSIS_DIR/final_validation.txt
```

This analysis ensures that **no functionality is broken** during cleanup operations by providing complete understanding of:

1. **DocType functionality** - Every field, workflow, and business rule
2. **Code dependencies** - Which files depend on which other files  
3. **Business logic impact** - How checkbox fields and conditional logic work
4. **Import relationships** - What happens if files are moved or deleted
5. **Risk levels** - Which changes are safe vs. dangerous
6. **Testing protocols** - How to verify nothing is broken

Remember: **NEVER** proceed with cleanup until this analysis is complete and reviewed!