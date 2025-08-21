# BMAD Integration Tools Expansion Pack

## Overview
This expansion pack contains specialized agents and workflows for integrating external systems with ERPNext, including Airtable migration and N8N workflow conversion capabilities.

## Contents

### Agents (4)
- **airtable-analyzer** - Analyzes Airtable bases for migration to ERPNext
- **n8n-workflow-analyst** - Analyzes N8N workflows for conversion
- **trigger-mapper** - Maps external triggers to ERPNext events
- **workflow-converter** - Converts external workflows to ERPNext automation

### Workflows (3)
- **airtable-to-erpnext-migration** - Complete Airtable migration workflow
- **n8n-workflow-conversion** - N8N to ERPNext conversion workflow
- **combined-airtable-n8n-conversion** - Combined migration for both systems

### Templates (2)
- **airtable-migration-template** - Template for Airtable migrations
- **n8n-to-erpnext-template** - Template for N8N conversions

### Tasks (4)
- **analyze-airtable-base** - Task for analyzing Airtable structures
- **convert-n8n-workflow** - Task for converting N8N workflows
- **convert-external-workflows** - Generic external workflow conversion
- **setup-n8n-triggers** - Configure N8N trigger mappings

### Teams (2)
- **airtable-migration-team** - Team configuration for Airtable migrations
- **n8n-conversion-team** - Team configuration for N8N conversions

### Data (1)
- **n8n-node-mappings** - Mappings between N8N nodes and ERPNext functionality

## Usage

To use this expansion pack:

```bash
# Load the expansion pack
*expansion-pack bmad-integration-tools*

# Activate an agent
/bmadIntegration:agent:airtable-analyzer
/bmadIntegration:agent:n8n-workflow-analyst
```

## Dependencies
This pack works alongside the main `bmad-erpnext-v16` expansion pack and requires:
- ERPNext v16+
- Frappe Framework v16+

## Migration Capabilities

### Airtable Migration
- Analyze base structure
- Map fields to ERPNext DocTypes
- Convert formulas and relationships
- Generate migration scripts
- Validate data integrity

### N8N Workflow Conversion
- Parse workflow JSON
- Map nodes to ERPNext functions
- Convert triggers to webhooks
- Generate Python automation code
- Setup scheduled jobs

## Integration Points
- Works with ERPNext's webhook system
- Utilizes Frappe's background job framework
- Integrates with ERPNext's workflow engine
- Compatible with ERPNext API structure

## Notes
This expansion pack was separated from the main `bmad-erpnext-v16` pack to keep the core ERPNext development tools focused and clean. Use this pack when you specifically need to migrate from or integrate with external systems.