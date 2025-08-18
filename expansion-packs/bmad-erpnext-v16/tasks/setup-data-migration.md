# Task: Setup Data Migration

## Description
Plan and execute comprehensive data migration between systems, ensuring data integrity, relationship preservation, and minimal downtime during the transition to ERPNext.

## Required Agents
- data-integration-expert
- doctype-designer
- testing-specialist

## Input Requirements
1. **Source System Details**:
   - Database type and version
   - Data volume estimates
   - Schema documentation
   - Access credentials

2. **Migration Requirements**:
   - Target ERPNext modules
   - Data transformation rules
   - Timeline constraints
   - Rollback requirements

## Process Steps

### 1. Data Assessment
```yaml
assessment:
  source_analysis:
    - Identify all data entities
    - Document data types and formats
    - Map relationships and dependencies
    - Calculate data volumes
    - Identify data quality issues
    
  target_mapping:
    - Map to ERPNext DocTypes
    - Define field transformations
    - Plan custom field creation
    - Design relationship structure
```

### 2. Migration Strategy
```yaml
strategy:
  approach: "phased_migration"
  
  phases:
    - phase: "Master Data"
      entities: ["Customers", "Suppliers", "Items"]
      method: "bulk_import"
      
    - phase: "Transactional Data"
      entities: ["Orders", "Invoices", "Payments"]
      method: "incremental_sync"
      
    - phase: "Historical Data"
      entities: ["Archived Records", "Logs"]
      method: "batch_processing"
      
  timing:
    preparation: "2 weeks"
    execution: "48 hours"
    validation: "1 week"
    cutover: "4 hours"
```

### 3. ETL Pipeline Implementation
```python
# etl_pipeline.py
import frappe
from frappe.utils import nowdate, flt
import pandas as pd

class DataMigrationPipeline:
    def __init__(self, source_config, target_config):
        self.source = source_config
        self.target = target_config
        self.error_log = []
        
    def extract(self, entity):
        """Extract data from source system"""
        if self.source['type'] == 'sql':
            return self.extract_from_sql(entity)
        elif self.source['type'] == 'api':
            return self.extract_from_api(entity)
        elif self.source['type'] == 'csv':
            return self.extract_from_csv(entity)
            
    def transform(self, data, mapping):
        """Transform data according to mapping rules"""
        transformed = []
        
        for record in data:
            new_record = {}
            
            for target_field, source_config in mapping.items():
                if isinstance(source_config, dict):
                    # Complex transformation
                    value = self.apply_transformation(
                        record.get(source_config['field']),
                        source_config.get('transform')
                    )
                else:
                    # Simple field mapping
                    value = record.get(source_config)
                    
                new_record[target_field] = value
                
            # Apply validations
            if self.validate_record(new_record, self.target['doctype']):
                transformed.append(new_record)
            else:
                self.error_log.append({
                    'record': record,
                    'error': 'Validation failed'
                })
                
        return transformed
        
    def load(self, data, doctype):
        """Load data into ERPNext"""
        success_count = 0
        
        for record in data:
            try:
                doc = frappe.get_doc({
                    'doctype': doctype,
                    **record
                })
                doc.insert(ignore_permissions=True)
                success_count += 1
                
                if success_count % 100 == 0:
                    frappe.db.commit()
                    print(f"Loaded {success_count} records...")
                    
            except Exception as e:
                self.error_log.append({
                    'record': record,
                    'error': str(e)
                })
                
        frappe.db.commit()
        return success_count
```

### 4. Data Validation Framework
```python
# validation.py
def validate_migration(source_stats, target_stats):
    """Validate migration completeness and accuracy"""
    
    validations = {
        'record_count': True,
        'sum_totals': True,
        'relationships': True,
        'data_integrity': True
    }
    
    # Check record counts
    if source_stats['count'] != target_stats['count']:
        validations['record_count'] = False
        
    # Check financial totals
    if abs(source_stats['total'] - target_stats['total']) > 0.01:
        validations['sum_totals'] = False
        
    # Check relationships preserved
    orphaned = check_orphaned_records()
    if orphaned:
        validations['relationships'] = False
        
    # Check data integrity
    if not validate_constraints():
        validations['data_integrity'] = False
        
    return validations
```

### 5. Incremental Sync Setup
```yaml
incremental_sync:
  method: "timestamp_based"
  
  configuration:
    sync_field: "modified"
    batch_size: 1000
    frequency: "hourly"
    
  implementation: |
    def sync_incremental(last_sync_time):
        # Get records modified since last sync
        new_records = source.query(
            "SELECT * FROM table WHERE modified > %s",
            last_sync_time
        )
        
        # Transform and load
        transformed = transform(new_records)
        load(transformed)
        
        # Update sync timestamp
        update_last_sync(nowdate())
```

### 6. Rollback Strategy
```yaml
rollback:
  backup_strategy:
    - Full database backup before migration
    - Snapshot at each phase completion
    - Transaction logs for point-in-time recovery
    
  rollback_procedure:
    1. Stop all write operations
    2. Identify rollback point
    3. Restore from backup
    4. Replay transactions if needed
    5. Validate system state
    
  testing:
    - Test rollback in staging
    - Document recovery time
    - Verify data consistency
```

## Output Format

### Migration Report
```yaml
migration_summary:
  start_time: "2024-01-15 00:00:00"
  end_time: "2024-01-15 04:23:15"
  
  statistics:
    total_records: 150000
    successful: 149850
    failed: 150
    
  by_entity:
    customers:
      source_count: 5000
      migrated: 5000
      errors: 0
      
    sales_orders:
      source_count: 50000
      migrated: 49950
      errors: 50
      
  validation_results:
    record_counts: "PASS"
    data_integrity: "PASS"
    relationships: "PASS"
    
  error_summary:
    - type: "duplicate_key"
      count: 100
      resolution: "skip_duplicates"
      
    - type: "invalid_reference"
      count: 50
      resolution: "create_placeholder"
```

## Success Criteria
- All data migrated with < 0.1% error rate
- No data loss or corruption
- Relationships preserved
- Performance targets met
- Rollback tested and documented
- User acceptance obtained

## Common Patterns

### Migration Best Practices
```yaml
best_practices:
  preparation:
    - Clean source data first
    - Create mapping documentation
    - Test with subset of data
    - Plan for downtime
    
  execution:
    - Use batch processing
    - Implement checkpoints
    - Monitor progress
    - Log all operations
    
  validation:
    - Reconcile counts
    - Verify calculations
    - Test workflows
    - User acceptance testing
```

## Error Handling

### Common Issues
1. **Data Type Mismatches**: Transform to compatible types
2. **Missing References**: Create placeholders or skip
3. **Duplicate Keys**: Implement deduplication logic
4. **Performance Issues**: Adjust batch sizes
5. **Memory Constraints**: Use streaming/chunking

## Dependencies
- Source system access
- Network bandwidth
- Storage for backups
- ERPNext target environment
- Testing environment

## Next Steps
After migration setup:
1. Execute pilot migration
2. Validate results
3. Optimize performance
4. Train users
5. Schedule production migration