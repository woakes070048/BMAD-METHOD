# Pareto Analysis (80/20 Rule) Task

## Task Description
Conduct a Pareto Analysis to identify the vital few causes that contribute to the majority of problems, following the 80/20 principle for focused improvement efforts.

## Input Parameters
- **problem**: The problem or metric to analyze (required)
- **data_period**: Time period for data collection (required)
- **categories**: Categories or causes to analyze (required)
- **measurement**: How to measure impact (frequency, cost, time, etc.)

## Execution Instructions

### Step 1: Data Collection and Categorization

#### Problem Definition
```
PROBLEM STATEMENT
================
Problem: [Clear description]
Measurement Unit: [Frequency/Cost/Time/Defects/Complaints]
Data Period: [Start Date] to [End Date]
Total Impact: [Sum of all occurrences/costs]
Business Context: [Why this matters]
```

#### Data Collection Table
```
| Category/Cause | Frequency | Impact ($) | Time (hrs) | Other Metric | Data Source |
|----------------|-----------|------------|------------|--------------|-------------|
| [Cause A]      | [Count]   | [Amount]   | [Hours]    | [Value]      | [Source]    |
| [Cause B]      | [Count]   | [Amount]   | [Hours]    | [Value]      | [Source]    |
| [Cause C]      | [Count]   | [Amount]   | [Hours]    | [Value]      | [Source]    |
| [Cause D]      | [Count]   | [Amount]   | [Hours]    | [Value]      | [Source]    |
| [Cause E]      | [Count]   | [Amount]   | [Hours]    | [Value]      | [Source]    |
| ...            | ...       | ...        | ...        | ...          | ...         |
```

### Step 2: Pareto Calculation and Ranking

#### Sorted Impact Analysis
```
PARETO RANKING TABLE
===================
| Rank | Category | Frequency | % of Total | Cumulative % | Classification |
|------|----------|-----------|------------|--------------|----------------|
| 1    | [Cause]  | [Count]   | [X%]       | [X%]         | Vital Few      |
| 2    | [Cause]  | [Count]   | [Y%]       | [X+Y%]       | Vital Few      |
| 3    | [Cause]  | [Count]   | [Z%]       | [X+Y+Z%]     | Vital Few      |
| 4    | [Cause]  | [Count]   | [W%]       | [...%]       | Transition     |
| 5    | [Cause]  | [Count]   | [V%]       | [...%]       | Useful Many    |
| ...  | ...      | ...       | ...        | ...          | ...            |

80% THRESHOLD: Achieved at Rank [N]
```

### Step 3: Vital Few Identification

#### The Vital Few (Top 20% causing 80% impact)
```
VITAL FEW CAUSES
===============
Total Causes: [X]
Vital Few Count: [Y] ([Y/X]% of causes)
Impact Coverage: [Z]% of total impact

1. CAUSE: [Name]
   - Frequency: [Count] ([%] of total)
   - Impact: $[Amount] or [Metric]
   - Root Factors: [List key contributing factors]
   - Improvement Potential: [High/Medium/Low]

2. CAUSE: [Name]
   - Frequency: [Count] ([%] of total)
   - Impact: $[Amount] or [Metric]
   - Root Factors: [List key contributing factors]
   - Improvement Potential: [High/Medium/Low]

3. CAUSE: [Name]
   - Frequency: [Count] ([%] of total)
   - Impact: $[Amount] or [Metric]
   - Root Factors: [List key contributing factors]
   - Improvement Potential: [High/Medium/Low]
```

### Step 4: Multi-Dimensional Pareto Analysis

#### Cost-Based Pareto
```
FINANCIAL IMPACT RANKING
=======================
| Rank | Cause | Annual Cost | % of Total | Cumulative % | Action Priority |
|------|-------|-------------|------------|--------------|-----------------|
| 1    | [A]   | $[Amount]   | [X%]       | [X%]         | Immediate       |
| 2    | [B]   | $[Amount]   | [Y%]       | [X+Y%]       | Immediate       |
| 3    | [C]   | $[Amount]   | [Z%]       | [...%]       | High            |

Total Annual Cost: $[Sum]
80% Cost Drivers: [List]
```

#### Frequency-Based Pareto
```
OCCURRENCE FREQUENCY RANKING
===========================
| Rank | Cause | Occurrences | % of Total | Cumulative % | Pattern |
|------|-------|-------------|------------|--------------|---------|
| 1    | [A]   | [Count]     | [X%]       | [X%]         | Daily   |
| 2    | [B]   | [Count]     | [Y%]       | [X+Y%]       | Weekly  |
| 3    | [C]   | [Count]     | [Z%]       | [...%]       | Monthly |
```

#### Customer Impact Pareto
```
CUSTOMER IMPACT RANKING
======================
| Rank | Issue | Complaints | % of Total | Cumulative % | Severity |
|------|-------|------------|------------|--------------|----------|
| 1    | [A]   | [Count]    | [X%]       | [X%]         | Critical |
| 2    | [B]   | [Count]    | [Y%]       | [X+Y%]       | High     |
| 3    | [C]   | [Count]    | [Z%]       | [...%]       | Medium   |
```

### Step 5: Pareto Chart Visualization

#### ASCII Pareto Chart
```
PARETO CHART: [Problem Description]
====================================
100% |                                    ___________● Cumulative %
 90% |                              ___●
 80% |                        ___●━━━━━━━━━━━━━━━ 80% Line
 70% |                  ___●
 60% |            ___●
 50% |      ___●  ███
 40% |  ___●  ███ ███
 30% | ●  ███ ███ ███
 20% | ███ ███ ███ ███ ███
 10% | ███ ███ ███ ███ ███ ███ ███
  0% |_███_███_███_███_███_███_███________
      Cause Cause Cause Cause Cause Other
        A     B     C     D     E   Causes

Legend: ███ = Frequency/Impact
        ● = Cumulative Percentage
        ━━━ = 80% Threshold
```

### Step 6: Deeper Analysis of Vital Few

#### Sub-Pareto Analysis for Top Cause
```
SUB-PARETO: [Top Cause Name]
============================
Breaking down the #1 cause into sub-causes:

| Rank | Sub-Cause | Frequency | % of Parent | Cumulative % |
|------|-----------|-----------|-------------|--------------|
| 1    | [Sub A]   | [Count]   | [X%]        | [X%]         |
| 2    | [Sub B]   | [Count]   | [Y%]        | [X+Y%]       |
| 3    | [Sub C]   | [Count]   | [Z%]        | [...%]       |

Key Finding: [Sub-cause A] drives [X%] of [Top Cause]
```

### Step 7: Improvement Strategy

#### Focus Areas Based on Pareto
```
IMPROVEMENT PRIORITIES
=====================

IMMEDIATE ACTION (Vital Few - 80% Impact)
----------------------------------------
1. [Cause A] - [X%] of problem
   Action: [Specific improvement action]
   Owner: [Responsible party]
   Timeline: [Target date]
   Expected Impact: [% reduction]
   Investment: $[Amount]
   ROI: [Calculate]

2. [Cause B] - [Y%] of problem
   Action: [Specific improvement action]
   Owner: [Responsible party]
   Timeline: [Target date]
   Expected Impact: [% reduction]
   Investment: $[Amount]
   ROI: [Calculate]

SECONDARY FOCUS (Transition Zone)
---------------------------------
3. [Cause C] - [Z%] of problem
   Action: [Improvement action]
   Timeline: [Target date]

MONITOR ONLY (Useful Many)
--------------------------
- [List of remaining causes]
- Combined impact: [%]
- Strategy: Periodic review only
```

### Step 8: Before/After Projection

#### Expected Impact Analysis
```
PROJECTED IMPROVEMENT
====================
Current State:
- Total Problems: [Count]
- Total Cost: $[Amount]
- Vital Few Impact: [%]

After Addressing Vital Few:
- Expected Problem Reduction: [%]
- Expected Cost Savings: $[Amount]
- New Pareto Distribution: [Projection]

Success Metrics:
- KPI 1: [Metric] from [Current] to [Target]
- KPI 2: [Metric] from [Current] to [Target]
- KPI 3: [Metric] from [Current] to [Target]
```

## Output Format

### Pareto Analysis Report
```
PARETO ANALYSIS REPORT
=====================

Analysis: [Problem/Metric Analyzed]
Period: [Date Range]
Total Impact: [Sum of all impacts]

80/20 RULE RESULTS
-----------------
Vital Few: [X] causes ([Y%] of total causes)
Impact: [Z%] of total problem
Conclusion: [X] causes create [Z%] of impact

TOP 3 VITAL CAUSES
-----------------
1. [Cause] - [Impact%] - $[Cost/Value]
2. [Cause] - [Impact%] - $[Cost/Value]
3. [Cause] - [Impact%] - $[Cost/Value]

CUMULATIVE ANALYSIS
------------------
50% Impact: Top [X] causes
80% Impact: Top [Y] causes
90% Impact: Top [Z] causes

RECOMMENDATIONS
--------------
Focus Area 1: [Cause A]
- Current Impact: [Metrics]
- Improvement Action: [Action]
- Expected Reduction: [%]
- ROI: [Calculation]

Focus Area 2: [Cause B]
- Current Impact: [Metrics]
- Improvement Action: [Action]
- Expected Reduction: [%]
- ROI: [Calculation]

IMPLEMENTATION SEQUENCE
----------------------
Phase 1: Address [Cause A] - [Timeline]
Phase 2: Address [Cause B] - [Timeline]
Phase 3: Address [Cause C] - [Timeline]

MONITORING PLAN
--------------
- Weekly: Track [Vital Few metrics]
- Monthly: Update Pareto distribution
- Quarterly: Full re-analysis
```

## Quality Criteria
- Data completeness and accuracy
- Proper sorting by impact
- Correct cumulative calculations
- Clear 80/20 identification
- Actionable recommendations
- Visual representation included
- Sub-analysis for top causes

## Common Applications
1. **Quality Defects**: Which defects cause most rejections
2. **Customer Complaints**: Which issues generate most complaints
3. **Costs**: Which categories drive most costs
4. **Time**: Which activities consume most time
5. **Errors**: Which errors occur most frequently
6. **Downtime**: Which failures cause most downtime

## Tips for Effective Pareto Analysis
1. **Collect sufficient data**: Ensure sample size is representative
2. **Use consistent measurement**: Same units across all categories
3. **Time-bound analysis**: Define clear period for data
4. **Regular updates**: Pareto distribution changes over time
5. **Combine with other tools**: Use with RCA for deeper insight
6. **Act on findings**: Focus resources on vital few

## Integration Points
- Feeds into: Root Cause Analysis
- Complements: Fishbone Diagram
- Informs: Resource Allocation
- Supports: Continuous Improvement
- Validates: Improvement Priorities