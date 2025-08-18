# Fishbone (Ishikawa) Cause-and-Effect Analysis Task

## Task Description
Conduct a comprehensive Fishbone diagram analysis to systematically identify all potential causes contributing to a problem across multiple categories.

## Input Parameters
- **problem**: The effect or problem to analyze (required)
- **categories**: Analysis categories to use (default: 6M - Man, Machine, Method, Material, Measurement, Mother Nature)
- **context**: Business context and environment (required)
- **data**: Available data and evidence (required)

## Execution Instructions

### Step 1: Problem Definition (Fish Head)
```
PROBLEM STATEMENT (Effect)
=========================
Problem: [Clear, specific problem description]
Metric: [How it's measured]
Current State: [Current performance]
Target State: [Desired performance]
Gap: [Quantified gap]
Impact: [Business impact]
```

### Step 2: Category Analysis (Fish Bones)

#### Category 1: PEOPLE (Man/Human Factors)
```
PRIMARY BONE: PEOPLE
--------------------
Skills & Training:
├── Cause: [Lack of specific skill]
│   Evidence: [Training records, performance data]
│   Impact: [High/Medium/Low]
├── Cause: [Insufficient training]
│   Evidence: [Training completion rates]
│   Impact: [High/Medium/Low]
└── Cause: [Knowledge gaps]
    Evidence: [Assessment results]
    Impact: [High/Medium/Low]

Communication:
├── Cause: [Information flow issues]
│   Evidence: [Communication audit]
│   Impact: [High/Medium/Low]
├── Cause: [Language/terminology barriers]
│   Evidence: [Incident reports]
│   Impact: [High/Medium/Low]
└── Cause: [Feedback loops missing]
    Evidence: [Process review]
    Impact: [High/Medium/Low]

Motivation & Culture:
├── Cause: [Low engagement]
│   Evidence: [Survey results]
│   Impact: [High/Medium/Low]
├── Cause: [Cultural misalignment]
│   Evidence: [Behavioral observations]
│   Impact: [High/Medium/Low]
└── Cause: [Incentive misalignment]
    Evidence: [Performance metrics]
    Impact: [High/Medium/Low]

Decision Making:
├── Cause: [Authority gaps]
│   Evidence: [RACI analysis]
│   Impact: [High/Medium/Low]
└── Cause: [Decision delays]
    Evidence: [Process timing]
    Impact: [High/Medium/Low]
```

#### Category 2: PROCESS (Method)
```
PRIMARY BONE: PROCESS
---------------------
Procedures:
├── Cause: [Missing procedures]
│   Evidence: [Documentation review]
│   Impact: [High/Medium/Low]
├── Cause: [Outdated procedures]
│   Evidence: [Last update dates]
│   Impact: [High/Medium/Low]
└── Cause: [Complex procedures]
    Evidence: [Error rates]
    Impact: [High/Medium/Low]

Workflows:
├── Cause: [Bottlenecks]
│   Evidence: [Flow analysis]
│   Impact: [High/Medium/Low]
├── Cause: [Redundant steps]
│   Evidence: [Process mapping]
│   Impact: [High/Medium/Low]
└── Cause: [Missing handoffs]
    Evidence: [Gap analysis]
    Impact: [High/Medium/Low]

Controls:
├── Cause: [Inadequate controls]
│   Evidence: [Control testing]
│   Impact: [High/Medium/Low]
├── Cause: [Manual processes]
│   Evidence: [Automation assessment]
│   Impact: [High/Medium/Low]
└── Cause: [Inconsistent execution]
    Evidence: [Variation analysis]
    Impact: [High/Medium/Low]

Standards:
├── Cause: [No standards defined]
│   Evidence: [Standards review]
│   Impact: [High/Medium/Low]
└── Cause: [Standards not followed]
    Evidence: [Compliance audit]
    Impact: [High/Medium/Low]
```

#### Category 3: TECHNOLOGY (Machine)
```
PRIMARY BONE: TECHNOLOGY
------------------------
Systems:
├── Cause: [System limitations]
│   Evidence: [Capability assessment]
│   Impact: [High/Medium/Low]
├── Cause: [Integration issues]
│   Evidence: [Interface analysis]
│   Impact: [High/Medium/Low]
└── Cause: [Performance problems]
    Evidence: [Performance metrics]
    Impact: [High/Medium/Low]

Tools:
├── Cause: [Inadequate tools]
│   Evidence: [Tool assessment]
│   Impact: [High/Medium/Low]
├── Cause: [Tool reliability]
│   Evidence: [Failure rates]
│   Impact: [High/Medium/Low]
└── Cause: [Version control issues]
    Evidence: [Version audit]
    Impact: [High/Medium/Low]

Infrastructure:
├── Cause: [Capacity constraints]
│   Evidence: [Utilization data]
│   Impact: [High/Medium/Low]
├── Cause: [Maintenance gaps]
│   Evidence: [Maintenance logs]
│   Impact: [High/Medium/Low]
└── Cause: [Obsolete technology]
    Evidence: [Technology audit]
    Impact: [High/Medium/Low]

Automation:
├── Cause: [Automation gaps]
│   Evidence: [Manual task analysis]
│   Impact: [High/Medium/Low]
└── Cause: [Automation errors]
    Evidence: [Error logs]
    Impact: [High/Medium/Low]
```

#### Category 4: MATERIALS (Inputs)
```
PRIMARY BONE: MATERIALS
-----------------------
Input Quality:
├── Cause: [Poor data quality]
│   Evidence: [Data quality metrics]
│   Impact: [High/Medium/Low]
├── Cause: [Inconsistent inputs]
│   Evidence: [Variation analysis]
│   Impact: [High/Medium/Low]
└── Cause: [Missing information]
    Evidence: [Completeness check]
    Impact: [High/Medium/Low]

Suppliers:
├── Cause: [Supplier performance]
│   Evidence: [Supplier scorecards]
│   Impact: [High/Medium/Low]
├── Cause: [Supply chain delays]
│   Evidence: [Lead time data]
│   Impact: [High/Medium/Low]
└── Cause: [Quality variations]
    Evidence: [Quality reports]
    Impact: [High/Medium/Low]

Specifications:
├── Cause: [Unclear specifications]
│   Evidence: [Spec review]
│   Impact: [High/Medium/Low]
└── Cause: [Changing requirements]
    Evidence: [Change logs]
    Impact: [High/Medium/Low]

Resources:
├── Cause: [Resource availability]
│   Evidence: [Resource utilization]
│   Impact: [High/Medium/Low]
└── Cause: [Resource allocation]
    Evidence: [Allocation analysis]
    Impact: [High/Medium/Low]
```

#### Category 5: MEASUREMENT
```
PRIMARY BONE: MEASUREMENT
-------------------------
Metrics:
├── Cause: [Wrong metrics]
│   Evidence: [Metric relevance analysis]
│   Impact: [High/Medium/Low]
├── Cause: [Missing metrics]
│   Evidence: [KPI gaps]
│   Impact: [High/Medium/Low]
└── Cause: [Metric conflicts]
    Evidence: [Metric alignment]
    Impact: [High/Medium/Low]

Monitoring:
├── Cause: [Inadequate monitoring]
│   Evidence: [Monitoring coverage]
│   Impact: [High/Medium/Low]
├── Cause: [Delayed reporting]
│   Evidence: [Reporting timelines]
│   Impact: [High/Medium/Low]
└── Cause: [Alert failures]
    Evidence: [Alert effectiveness]
    Impact: [High/Medium/Low]

Calibration:
├── Cause: [Measurement errors]
│   Evidence: [Calibration records]
│   Impact: [High/Medium/Low]
└── Cause: [Inconsistent measurement]
    Evidence: [Measurement variance]
    Impact: [High/Medium/Low]

Feedback:
├── Cause: [No feedback loops]
│   Evidence: [Process design]
│   Impact: [High/Medium/Low]
└── Cause: [Feedback not acted upon]
    Evidence: [Action tracking]
    Impact: [High/Medium/Low]
```

#### Category 6: ENVIRONMENT (Mother Nature)
```
PRIMARY BONE: ENVIRONMENT
-------------------------
External Factors:
├── Cause: [Market conditions]
│   Evidence: [Market analysis]
│   Impact: [High/Medium/Low]
├── Cause: [Regulatory changes]
│   Evidence: [Compliance review]
│   Impact: [High/Medium/Low]
└── Cause: [Economic factors]
    Evidence: [Economic indicators]
    Impact: [High/Medium/Low]

Internal Environment:
├── Cause: [Organizational changes]
│   Evidence: [Change impact]
│   Impact: [High/Medium/Low]
├── Cause: [Resource constraints]
│   Evidence: [Budget analysis]
│   Impact: [High/Medium/Low]
└── Cause: [Political factors]
    Evidence: [Stakeholder analysis]
    Impact: [High/Medium/Low]

Physical Environment:
├── Cause: [Workspace issues]
│   Evidence: [Environment audit]
│   Impact: [High/Medium/Low]
├── Cause: [Location factors]
│   Evidence: [Location analysis]
│   Impact: [High/Medium/Low]
└── Cause: [Climate/weather impact]
    Evidence: [Historical data]
    Impact: [High/Medium/Low]

Cultural Environment:
├── Cause: [Cultural barriers]
│   Evidence: [Culture assessment]
│   Impact: [High/Medium/Low]
└── Cause: [Change resistance]
    Evidence: [Change readiness]
    Impact: [High/Medium/Low]
```

### Step 3: Cause Prioritization

#### Impact-Probability Matrix
```
HIGH IMPACT, HIGH PROBABILITY (Critical)
1. [Cause]: Impact Score [X], Probability [Y%]
2. [Cause]: Impact Score [X], Probability [Y%]
3. [Cause]: Impact Score [X], Probability [Y%]

HIGH IMPACT, LOW PROBABILITY (Monitor)
1. [Cause]: Impact Score [X], Probability [Y%]
2. [Cause]: Impact Score [X], Probability [Y%]

LOW IMPACT, HIGH PROBABILITY (Efficiency)
1. [Cause]: Impact Score [X], Probability [Y%]
2. [Cause]: Impact Score [X], Probability [Y%]

LOW IMPACT, LOW PROBABILITY (Accept)
1. [Cause]: Impact Score [X], Probability [Y%]
```

### Step 4: Root Cause Identification

#### Primary Root Causes (Top 20%)
1. **[Category] - [Specific Cause]**
   - Evidence Strength: [Strong/Moderate/Weak]
   - Contribution: [X%] of problem
   - Actionability: [High/Medium/Low]

2. **[Category] - [Specific Cause]**
   - Evidence Strength: [Strong/Moderate/Weak]
   - Contribution: [X%] of problem
   - Actionability: [High/Medium/Low]

3. **[Category] - [Specific Cause]**
   - Evidence Strength: [Strong/Moderate/Weak]
   - Contribution: [X%] of problem
   - Actionability: [High/Medium/Low]

### Step 5: Solution Mapping

#### Solutions by Category
```
PEOPLE SOLUTIONS
- Training program for [skill gap]
- Communication protocol for [information flow]
- Incentive alignment for [motivation]

PROCESS SOLUTIONS
- Process redesign for [workflow bottleneck]
- Automation for [manual process]
- Control implementation for [gap]

TECHNOLOGY SOLUTIONS
- System upgrade for [limitation]
- Integration solution for [interface issue]
- Tool replacement for [inadequate tool]

MATERIAL SOLUTIONS
- Supplier improvement for [quality issue]
- Data quality program for [data problems]
- Specification clarification for [unclear specs]

MEASUREMENT SOLUTIONS
- KPI redesign for [metric issues]
- Monitoring enhancement for [gaps]
- Feedback loop creation for [missing feedback]

ENVIRONMENT SOLUTIONS
- Change management for [resistance]
- Risk mitigation for [external factor]
- Culture program for [cultural barrier]
```

## Output Format

### Fishbone Analysis Report
```
FISHBONE CAUSE-AND-EFFECT ANALYSIS
===================================

Problem Effect: [Problem statement]
Analysis Date: [Date]
Categories Analyzed: [List of categories]

CAUSE DISTRIBUTION
-----------------
People: [X] causes ([Y%] of total)
Process: [X] causes ([Y%] of total)
Technology: [X] causes ([Y%] of total)
Materials: [X] causes ([Y%] of total)
Measurement: [X] causes ([Y%] of total)
Environment: [X] causes ([Y%] of total)

TOP ROOT CAUSES (Pareto Principle)
----------------------------------
1. [Cause] - [Category] - [Impact%]
2. [Cause] - [Category] - [Impact%]
3. [Cause] - [Category] - [Impact%]
4. [Cause] - [Category] - [Impact%]
5. [Cause] - [Category] - [Impact%]

VISUAL DIAGRAM
-------------
[ASCII or description of fishbone diagram]

RECOMMENDATIONS BY PRIORITY
--------------------------
Critical (Immediate Action):
1. [Solution] addresses [Cause]
2. [Solution] addresses [Cause]

High (30 days):
1. [Solution] addresses [Cause]
2. [Solution] addresses [Cause]

Medium (90 days):
1. [Solution] addresses [Cause]
2. [Solution] addresses [Cause]

IMPLEMENTATION COMPLEXITY
------------------------
Quick Wins: [List]
Major Projects: [List]
Transformational: [List]
```

## Quality Criteria
- All six categories must be thoroughly analyzed
- Each cause must have supporting evidence
- Impact assessment for every cause
- Prioritization based on data
- Solutions mapped to specific causes
- Visual diagram representation

## Tips for Effective Analysis
1. **Brainstorm broadly**: Don't filter ideas initially
2. **Seek diverse perspectives**: Include all stakeholders
3. **Use data**: Support causes with evidence
4. **Go deep**: Don't stop at surface causes
5. **Cross-category thinking**: Causes may span categories
6. **Validate causes**: Test cause-effect relationships

## Integration Points
- Complements: Five Whys Analysis
- Feeds into: Comprehensive RCA Report
- Informs: Solution Architecture
- Validates: Pattern Detection
- Supports: Risk Assessment