# Comprehensive Root Cause Analysis Task

## Task Description
Conduct a comprehensive root cause analysis using multiple methodologies to identify true root causes, contributing factors, and systemic issues behind incidents or problems.

## Input Parameters
- **incident**: Description of the incident or problem to analyze (required)
- **context**: Business context and background information (required)
- **data**: Available data, metrics, and evidence (required)
- **methodology**: Preferred RCA methodology or "all" for comprehensive analysis
- **perspective**: Analysis perspective (operational, financial, strategic, customer)

## Execution Instructions

### Step 1: Incident Documentation and Timeline
1. Document the incident precisely with facts, not assumptions
2. Create detailed timeline of events leading to incident
3. Identify all stakeholders affected and their impacts
4. Quantify impacts (financial, operational, reputational, customer)
5. Gather all available data and evidence

### Step 2: Multi-Methodology Root Cause Analysis

#### 5 Whys Analysis
Apply the Five Whys methodology systematically:

```
INCIDENT: [Description of what happened]

Why 1: Why did this incident occur?
Answer: [Evidence-based answer]
Supporting Data: [Specific data/observations]
Confidence: [High/Medium/Low]

Why 2: Why did [Answer 1] happen?
Answer: [Deeper cause]
Supporting Data: [Evidence]
Confidence: [Level]

Why 3: Why did [Answer 2] happen?
Answer: [Even deeper cause]
Supporting Data: [Evidence]
Confidence: [Level]

Why 4: Why did [Answer 3] happen?
Answer: [Systemic cause]
Supporting Data: [Evidence]
Confidence: [Level]

Why 5: Why did [Answer 4] happen?
Answer: [Root cause]
Supporting Data: [Evidence]
Confidence: [Level]

ROOT CAUSE IDENTIFIED: [Final root cause that is actionable and preventable]
```

#### Fishbone (Ishikawa) Analysis
Create comprehensive cause-and-effect diagram:

```
PROBLEM: [Central problem statement]

CATEGORIES OF CAUSES:

1. PEOPLE (Human Factors)
   - Skills/Training: [Specific causes]
   - Communication: [Specific causes]
   - Motivation/Culture: [Specific causes]
   - Decision-making: [Specific causes]

2. PROCESS (Method)
   - Procedures: [Specific causes]
   - Controls: [Specific causes]
   - Workflows: [Specific causes]
   - Standards: [Specific causes]

3. TECHNOLOGY (Machine)
   - Systems: [Specific causes]
   - Tools: [Specific causes]
   - Automation: [Specific causes]
   - Infrastructure: [Specific causes]

4. MATERIALS (Inputs)
   - Data Quality: [Specific causes]
   - Resource Quality: [Specific causes]
   - Supplier Issues: [Specific causes]
   - Specifications: [Specific causes]

5. MEASUREMENT
   - Metrics: [Specific causes]
   - Monitoring: [Specific causes]
   - Feedback: [Specific causes]
   - Calibration: [Specific causes]

6. ENVIRONMENT
   - External Factors: [Specific causes]
   - Market Conditions: [Specific causes]
   - Regulations: [Specific causes]
   - Culture/Climate: [Specific causes]

PRIMARY CAUSES IDENTIFIED: [Top 3-5 causes with highest impact]
```

#### Fault Tree Analysis
Build logical tree of failure paths:

```
TOP EVENT: [Incident/Failure]

IMMEDIATE CAUSES (OR gates):
├── Cause A (Probability: X%)
│   ├── Sub-cause A1 (AND gate)
│   │   ├── Basic Event A1a
│   │   └── Basic Event A1b
│   └── Sub-cause A2
│       └── Basic Event A2a
├── Cause B (Probability: Y%)
│   └── Sub-cause B1
│       ├── Basic Event B1a
│       └── Basic Event B1b
└── Cause C (Probability: Z%)
    └── Basic Event C1

CRITICAL PATH: [Path with highest probability or impact]
FAILURE PROBABILITY: [Calculated probability]
```

#### Pareto Analysis (80/20 Rule)
Identify vital few causes:

```
CONTRIBUTING FACTORS RANKED BY IMPACT:

| Rank | Factor | Frequency | Impact Score | Cumulative % | Category |
|------|--------|-----------|--------------|--------------|----------|
| 1 | [Factor] | [Count] | [Score] | [%] | Vital Few |
| 2 | [Factor] | [Count] | [Score] | [%] | Vital Few |
| 3 | [Factor] | [Count] | [Score] | [%] | Vital Few |
| 4 | [Factor] | [Count] | [Score] | [%] | Useful Many |
| ... | ... | ... | ... | ... | ... |

VITAL FEW (Top 20% causing 80% impact):
1. [Critical Factor 1] - [Impact description]
2. [Critical Factor 2] - [Impact description]
3. [Critical Factor 3] - [Impact description]

RECOMMENDATION: Focus on these vital few for maximum improvement
```

### Step 3: Pattern and Systemic Analysis

#### Historical Pattern Analysis
```
SIMILAR INCIDENTS IN PAST 12 MONTHS:
- [Date]: [Incident] - [Common factors]
- [Date]: [Incident] - [Common factors]
- [Date]: [Incident] - [Common factors]

RECURRING PATTERNS IDENTIFIED:
1. [Pattern]: Frequency [X times], Common trigger [Y]
2. [Pattern]: Frequency [X times], Common trigger [Y]

SYSTEMIC ISSUES:
- [Systemic issue that enables multiple incidents]
- [Organizational factor that contributes to pattern]
```

#### Cross-Functional Impact Analysis
```
DEPARTMENTS/FUNCTIONS AFFECTED:
- Operations: [Impact and cascade effects]
- Finance: [Cost and financial implications]
- Customer Service: [Customer impact and satisfaction]
- Sales: [Revenue and market implications]
- IT: [System and technology impacts]
- HR: [People and culture implications]

INTERDEPENDENCIES REVEALED:
- [How failure in one area cascaded to others]
- [Weak points in cross-functional processes]
```

### Step 4: Root Cause Synthesis and Validation

#### Root Cause Identification
```
PRIMARY ROOT CAUSES (Validated across methodologies):
1. ROOT CAUSE: [Description]
   - Evidence: [Supporting data from multiple analyses]
   - Confidence Score: [0-100%]
   - Category: [Human/Process/Technology/External]
   - Preventability: [High/Medium/Low]

2. ROOT CAUSE: [Description]
   - Evidence: [Supporting data]
   - Confidence Score: [%]
   - Category: [Type]
   - Preventability: [Level]

CONTRIBUTING FACTORS (Not root causes but amplifiers):
- [Factor 1]: [How it contributed]
- [Factor 2]: [How it contributed]

SYMPTOMS (Often mistaken for causes):
- [Symptom 1]: Actually caused by [root cause]
- [Symptom 2]: Actually caused by [root cause]
```

### Step 5: Solution Development and Prevention

#### Immediate Actions (Quick Wins)
```
1. ACTION: [Specific action to prevent recurrence]
   - Timeline: [Within X days]
   - Owner: [Responsible party]
   - Expected Impact: [Reduction in incident probability]
   - Cost: [Estimated cost]
   - ROI: [Expected return]

2. ACTION: [Second immediate action]
   - [Details as above]
```

#### Systematic Improvements (3-6 months)
```
1. IMPROVEMENT: [Process or system improvement]
   - Root Cause Addressed: [Which root cause]
   - Implementation Plan: [High-level steps]
   - Success Metrics: [How to measure success]
   - Risk Mitigation: [Potential risks and mitigation]
```

#### Long-term Transformation (6-12 months)
```
1. TRANSFORMATION: [Fundamental change needed]
   - Systemic Issues Addressed: [Which patterns/issues]
   - Change Management Required: [People and process changes]
   - Investment Required: [Resources and budget]
   - Expected Benefits: [Quantified improvements]
```

## Output Requirements

### Comprehensive RCA Report
- Executive summary with key findings
- Detailed analysis from each methodology
- Synthesized root causes with confidence scores
- Pattern analysis and systemic issues
- Prioritized recommendations with ROI
- Implementation roadmap with timeline

### Visual Deliverables
- Fishbone diagram visualization
- Fault tree diagram
- Pareto chart
- Timeline visualization
- Impact heat map

### Action Plan
- Immediate actions checklist
- 30-60-90 day improvement plan
- Long-term transformation roadmap
- Success metrics and KPIs
- Risk mitigation strategies

## Quality Criteria
- **Evidence-Based**: All conclusions supported by data
- **Multi-Causal**: Recognition that complex problems have multiple causes
- **Actionable**: Clear, implementable recommendations
- **Preventive**: Focus on preventing recurrence
- **Systemic**: Address underlying organizational issues
- **Measurable**: Include success metrics and monitoring plan

## Integration Points
This RCA integrates with:
- **Pattern Detection**: Feed findings to pattern analysis
- **Risk Assessment**: Identify new risks from root causes
- **Solution Architecture**: Design solutions for root causes
- **Continuous Improvement**: Create improvement projects
- **Executive Reporting**: Brief leadership on findings

## Success Metrics
- Root cause identification accuracy
- Incident recurrence reduction (target: 80% reduction)
- Implementation success rate of recommendations
- Time to root cause identification
- Stakeholder satisfaction with analysis depth
- ROI of implemented improvements