# Task: Analyze Business Requirements

## Description
Conduct comprehensive business requirements analysis for ERPNext implementation, including stakeholder interviews, process mapping, gap analysis, and requirements documentation to ensure the solution meets business needs.

## Required Agents
- business-analyst
- erpnext-architect
- erpnext-product-owner

## Input Requirements
1. **Business Context**:
   - Company overview and industry
   - Current processes and pain points
   - Business objectives and KPIs
   - Stakeholder list and roles

2. **Project Scope**:
   - Modules to be implemented
   - Timeline and budget constraints
   - Integration requirements
   - Compliance requirements

## Process Steps

### 1. Stakeholder Analysis
```yaml
stakeholder_mapping:
  identification:
    - Executive sponsors
    - Department heads
    - Process owners
    - End users
    - IT team
    - External partners
    
  analysis_matrix:
    - stakeholder: "CEO"
      interest: "High"
      influence: "High"
      requirements_focus: "Strategic alignment, ROI"
      
    - stakeholder: "Operations Manager"
      interest: "High"
      influence: "Medium"
      requirements_focus: "Process efficiency, automation"
      
    - stakeholder: "End Users"
      interest: "Medium"
      influence: "Low"
      requirements_focus: "Ease of use, training"
      
  engagement_plan:
    high_influence_high_interest: "Manage closely"
    high_influence_low_interest: "Keep satisfied"
    low_influence_high_interest: "Keep informed"
    low_influence_low_interest: "Monitor"
```

### 2. Business Process Discovery
```python
# business_process_analyzer.py
import frappe
from datetime import datetime

class BusinessProcessAnalyzer:
    def __init__(self, organization):
        self.organization = organization
        self.processes = {}
        self.requirements = []
        
    def discover_processes(self):
        """Discover and document business processes"""
        
        process_areas = [
            'Sales',
            'Purchasing',
            'Inventory',
            'Manufacturing',
            'Accounting',
            'HR',
            'Customer Service'
        ]
        
        for area in process_areas:
            self.processes[area] = self.analyze_process_area(area)
            
        return self.processes
    
    def analyze_process_area(self, area):
        """Analyze specific business process area"""
        
        return {
            'current_state': self.map_current_process(area),
            'pain_points': self.identify_pain_points(area),
            'requirements': self.extract_requirements(area),
            'future_state': self.design_future_process(area),
            'gap_analysis': self.perform_gap_analysis(area)
        }
    
    def map_current_process(self, area):
        """Map AS-IS process"""
        
        process_map = {
            'steps': [],
            'actors': [],
            'systems': [],
            'documents': [],
            'decision_points': [],
            'metrics': {}
        }
        
        # Example: Sales process mapping
        if area == 'Sales':
            process_map['steps'] = [
                {'id': 1, 'name': 'Lead Generation', 'duration': '1-2 days'},
                {'id': 2, 'name': 'Qualification', 'duration': '2-3 days'},
                {'id': 3, 'name': 'Quotation', 'duration': '1 day'},
                {'id': 4, 'name': 'Negotiation', 'duration': '3-5 days'},
                {'id': 5, 'name': 'Order Confirmation', 'duration': '1 day'},
                {'id': 6, 'name': 'Fulfillment', 'duration': '5-7 days'}
            ]
            
            process_map['metrics'] = {
                'cycle_time': '12-19 days',
                'conversion_rate': '25%',
                'average_deal_size': '$50,000',
                'customer_satisfaction': '3.5/5'
            }
        
        return process_map
    
    def identify_pain_points(self, area):
        """Identify current process pain points"""
        
        pain_points = []
        
        # Interview questions template
        questions = [
            "What takes the most time in this process?",
            "Where do errors commonly occur?",
            "What information is difficult to find?",
            "What approvals slow down the process?",
            "What manual tasks could be automated?"
        ]
        
        # Simulated pain points (would come from interviews)
        if area == 'Sales':
            pain_points = [
                {
                    'issue': 'Manual quote generation',
                    'impact': 'High',
                    'frequency': 'Daily',
                    'cost': '2 hours per quote'
                },
                {
                    'issue': 'No visibility into sales pipeline',
                    'impact': 'Medium',
                    'frequency': 'Weekly',
                    'cost': 'Lost opportunities'
                }
            ]
        
        return pain_points
```

### 3. Requirements Elicitation
```yaml
elicitation_techniques:
  interviews:
    structured:
      - Predefined questionnaire
      - Consistent across stakeholders
      - Quantitative data collection
      
    semi_structured:
      - Open-ended questions
      - Follow-up probes
      - Qualitative insights
      
  workshops:
    requirements_workshop:
      participants: ["Process owners", "End users", "IT"]
      duration: "4 hours"
      outputs:
        - Process flows
        - User stories
        - Acceptance criteria
        
    prioritization_workshop:
      method: "MoSCoW"
      categories:
        must_have: "Critical for go-live"
        should_have: "Important but not critical"
        could_have: "Nice to have"
        wont_have: "Future phase"
        
  observation:
    job_shadowing:
      - Observe actual work
      - Identify unstated requirements
      - Understand workarounds
      
  document_analysis:
    review:
      - Current procedures
      - Forms and reports
      - System documentation
      - Compliance requirements
```

### 4. Requirements Documentation
```python
def document_requirements(process_area, requirements):
    """Create comprehensive requirements documentation"""
    
    requirement_doc = {
        'metadata': {
            'project': 'ERPNext Implementation',
            'area': process_area,
            'date': datetime.now().isoformat(),
            'version': '1.0',
            'status': 'Draft'
        },
        'functional_requirements': [],
        'non_functional_requirements': [],
        'business_rules': [],
        'data_requirements': [],
        'integration_requirements': [],
        'reporting_requirements': []
    }
    
    # Functional Requirements
    for req in requirements:
        if req['type'] == 'functional':
            requirement_doc['functional_requirements'].append({
                'id': req['id'],
                'description': req['description'],
                'priority': req['priority'],
                'acceptance_criteria': req['acceptance_criteria'],
                'erpnext_mapping': map_to_erpnext_feature(req),
                'effort_estimate': estimate_effort(req)
            })
    
    # Business Rules
    requirement_doc['business_rules'] = [
        {
            'id': 'BR001',
            'rule': 'Credit limit check before order confirmation',
            'condition': 'order_total > customer.credit_limit',
            'action': 'Require approval from Finance Manager',
            'exception': 'VIP customers exempt'
        },
        {
            'id': 'BR002',
            'rule': 'Inventory reservation on order',
            'condition': 'order.status = "Confirmed"',
            'action': 'Reserve inventory for order items',
            'exception': 'Drop-ship items'
        }
    ]
    
    return requirement_doc

def map_to_erpnext_feature(requirement):
    """Map business requirement to ERPNext features"""
    
    erpnext_mapping = {
        'module': identify_module(requirement),
        'doctype': identify_doctype(requirement),
        'features': identify_features(requirement),
        'customization_needed': assess_customization(requirement),
        'configuration': identify_configuration(requirement)
    }
    
    return erpnext_mapping
```

### 5. Gap Analysis
```python
def perform_gap_analysis(current_state, future_state, erpnext_capabilities):
    """Analyze gaps between requirements and ERPNext capabilities"""
    
    gap_analysis = {
        'fully_supported': [],
        'configuration_required': [],
        'customization_required': [],
        'workaround_needed': [],
        'not_supported': []
    }
    
    for requirement in future_state['requirements']:
        capability_assessment = assess_erpnext_capability(
            requirement,
            erpnext_capabilities
        )
        
        if capability_assessment['support_level'] == 'full':
            gap_analysis['fully_supported'].append({
                'requirement': requirement,
                'erpnext_feature': capability_assessment['feature'],
                'implementation': 'Out-of-the-box'
            })
            
        elif capability_assessment['support_level'] == 'partial':
            gap_analysis['configuration_required'].append({
                'requirement': requirement,
                'configuration_needed': capability_assessment['config'],
                'effort': capability_assessment['effort']
            })
            
        elif capability_assessment['support_level'] == 'custom':
            gap_analysis['customization_required'].append({
                'requirement': requirement,
                'customization_type': capability_assessment['type'],
                'complexity': capability_assessment['complexity'],
                'effort': capability_assessment['effort']
            })
            
        else:
            gap_analysis['not_supported'].append({
                'requirement': requirement,
                'alternatives': suggest_alternatives(requirement),
                'impact': assess_impact(requirement)
            })
    
    return gap_analysis
```

### 6. Requirements Validation
```yaml
validation_criteria:
  completeness:
    - All stakeholder needs addressed
    - All process areas covered
    - All integration points identified
    
  consistency:
    - No conflicting requirements
    - Uniform terminology
    - Aligned with business rules
    
  feasibility:
    - Technical feasibility
    - Resource availability
    - Timeline constraints
    
  testability:
    - Clear acceptance criteria
    - Measurable outcomes
    - Verification methods defined
    
  traceability:
    - Link to business objectives
    - Map to system features
    - Track through implementation
```

## Output Format

### Requirements Document Structure
```yaml
business_requirements_document:
  executive_summary:
    project_overview: "ERPNext implementation for XYZ Corp"
    objectives:
      - "Automate order-to-cash process"
      - "Improve inventory visibility"
      - "Enhance reporting capabilities"
    scope: "Sales, Inventory, Accounting modules"
    
  stakeholder_analysis:
    total_stakeholders: 25
    key_stakeholders: 8
    engagement_level: "High"
    
  process_analysis:
    processes_mapped: 12
    pain_points_identified: 34
    improvement_opportunities: 28
    
  requirements_summary:
    total_requirements: 156
    must_have: 67
    should_have: 52
    could_have: 37
    
  gap_analysis:
    fully_supported: 102
    configuration_needed: 38
    customization_needed: 12
    not_supported: 4
    
  implementation_roadmap:
    phase_1: "Core modules - 3 months"
    phase_2: "Extensions - 2 months"
    phase_3: "Integrations - 1 month"
    
  success_metrics:
    - metric: "Order processing time"
      current: "3 days"
      target: "1 day"
      
    - metric: "Inventory accuracy"
      current: "85%"
      target: "99%"
```

## Success Criteria
- All stakeholders interviewed
- All business processes documented
- Requirements traceable to objectives
- Gap analysis complete
- Validation sign-off obtained
- Implementation roadmap approved

## Common Patterns

### Requirements Patterns
```yaml
common_requirements:
  process_automation:
    - Approval workflows
    - Email notifications
    - Document generation
    - Data validation
    
  reporting:
    - Dashboard views
    - Scheduled reports
    - Ad-hoc queries
    - Data exports
    
  integration:
    - Data synchronization
    - API endpoints
    - File imports/exports
    - Third-party services
    
  compliance:
    - Audit trails
    - Access controls
    - Data retention
    - Regulatory reports
```

## Error Handling

### Common Issues
1. **Incomplete Requirements**: Schedule follow-up sessions
2. **Conflicting Requirements**: Facilitate resolution workshops
3. **Scope Creep**: Document change requests
4. **Unrealistic Expectations**: Educate on capabilities
5. **Missing Stakeholders**: Identify and engage

## Dependencies
- Stakeholder availability
- Current documentation
- Process observation access
- ERPNext feature knowledge
- Industry best practices

## Next Steps
After requirements analysis:
1. Review with stakeholders
2. Prioritize requirements
3. Create implementation plan
4. Design solution architecture
5. Begin development phase