#!/usr/bin/env python3
"""
Batch update script to add folder_knowledge section to all agents
This ensures all agents know exactly where files are located
"""

import os
import re
import yaml

# The folder_knowledge section to add to all agents
FOLDER_KNOWLEDGE = """
folder_knowledge:
  # CRITICAL: Standard paths all agents must know
  expansion_pack:
    agents: ".bmad-erpnext-v16/agents/"
    tasks: ".bmad-erpnext-v16/tasks/"
    templates: ".bmad-erpnext-v16/templates/"
    workflows: ".bmad-erpnext-v16/workflows/"
    checklists: ".bmad-erpnext-v16/checklists/"
    data: ".bmad-erpnext-v16/data/"
    
  erpnext_app:
    # Planning documents
    prd: "docs/prd.md"
    architecture: "docs/architecture.md"
    project_structure: "docs/PROJECT_STRUCTURE.md"
    epics_dir: "docs/epics/"
    stories_dir: "docs/stories/"
    
    # Code structure
    api_dir: "{app_name}/api/"
    doctypes_dir: "{app_name}/{module_name}/doctype/"
    pages_dir: "{app_name}/{module_name}/page/"
    vue_components_dir: "{app_name}/public/js/"
    
    # Test structure
    tests_dir: "tests/"
    test_plans_dir: "tests/plans/"
    test_results_dir: "tests/results/"
    compliance_dir: "tests/compliance/"
    
    # Key files
    project_context: "PROJECT_CONTEXT.yaml"
    hooks_file: "{app_name}/hooks.py"
    handoffs_dir: ".bmad-project/handoffs/"
"""

def has_folder_knowledge(content):
    """Check if agent already has folder_knowledge section"""
    return 'folder_knowledge:' in content

def find_insertion_point(content):
    """Find where to insert folder_knowledge section"""
    # Try to find common sections and insert after them
    patterns = [
        (r'^environment:.*?\n\n', 'after'),  # After environment block
        (r'^persona:.*?\n', 'before'),  # Before persona if no environment
        (r'^metadata:.*?\n\n', 'after'),  # After metadata block
        (r'^capabilities:', 'before'),  # Before capabilities
        (r'^dependencies:', 'before'),  # Before dependencies
        (r'^workflow_instructions:', 'before'),  # Before workflow_instructions
        (r'^commands:', 'before'),  # Before commands
    ]
    
    for pattern, position in patterns:
        match = re.search(pattern, content, re.MULTILINE | re.DOTALL)
        if match:
            if position == 'after':
                return match.end()
            else:
                return match.start()
    
    # If no suitable location found, try to find the end of the YAML block
    yaml_end = content.find('```')
    if yaml_end > 0:
        # Find the last line before the end of YAML
        last_newline = content.rfind('\n', 0, yaml_end)
        if last_newline > 0:
            return last_newline
    
    return -1

def update_agent_file(filepath):
    """Update a single agent file with folder_knowledge"""
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Check if already has folder_knowledge
    if has_folder_knowledge(content):
        print(f"✓ {os.path.basename(filepath)} - already has folder_knowledge")
        return False
    
    # Find where to insert
    insertion_point = find_insertion_point(content)
    if insertion_point == -1:
        print(f"✗ {os.path.basename(filepath)} - couldn't find insertion point")
        return False
    
    # Insert folder_knowledge
    updated_content = (
        content[:insertion_point] + 
        FOLDER_KNOWLEDGE + 
        content[insertion_point:]
    )
    
    # Write back
    with open(filepath, 'w') as f:
        f.write(updated_content)
    
    print(f"✓ {os.path.basename(filepath)} - updated with folder_knowledge")
    return True

def main():
    """Update all agents with folder_knowledge"""
    agents_dir = "/home/frappe/bmad-erpnext-development/BMAD-METHOD/expansion-packs/bmad-erpnext-v16/agents"
    
    # Get all agent files
    agent_files = [
        os.path.join(agents_dir, f) 
        for f in os.listdir(agents_dir) 
        if f.endswith('.md')
    ]
    
    print(f"Found {len(agent_files)} agent files")
    print("=" * 50)
    
    updated_count = 0
    already_has_count = 0
    failed_count = 0
    
    for agent_file in sorted(agent_files):
        result = update_agent_file(agent_file)
        if result:
            updated_count += 1
        elif has_folder_knowledge(open(agent_file).read()):
            already_has_count += 1
        else:
            failed_count += 1
    
    print("=" * 50)
    print(f"Summary:")
    print(f"  Updated: {updated_count}")
    print(f"  Already had folder_knowledge: {already_has_count}")
    print(f"  Failed to update: {failed_count}")
    print(f"  Total: {len(agent_files)}")

if __name__ == "__main__":
    main()