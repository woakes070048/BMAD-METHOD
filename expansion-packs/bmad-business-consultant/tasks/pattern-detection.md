# Pattern Detection and Analysis Task

## Task Description
Identify recurring patterns, trends, anomalies, and predictive indicators in business data to enable proactive decision-making and early warning systems.

## Input Parameters
- **data_source**: Historical data to analyze (required)
- **timeframe**: Period for pattern analysis (required)
- **pattern_types**: Types of patterns to detect (trends, cycles, anomalies, correlations)
- **confidence_threshold**: Minimum confidence for pattern reporting (default: 75%)

## Execution Instructions

### Step 1: Data Preparation and Profiling

#### Data Overview
```
DATA PROFILE
===========
Source: [System/Database/Process]
Period: [Start Date] to [End Date]
Records: [Total count]
Dimensions: [List of key dimensions]
Metrics: [List of key metrics]
Granularity: [Hourly/Daily/Weekly/Monthly]
Quality Score: [0-100%]
```

#### Data Quality Assessment
```
| Quality Dimension | Score | Issues Found | Impact |
|------------------|-------|--------------|---------|
| Completeness     | [%]   | [Missing data] | [H/M/L] |
| Accuracy         | [%]   | [Errors found] | [H/M/L] |
| Consistency      | [%]   | [Inconsistencies] | [H/M/L] |
| Timeliness       | [%]   | [Delays] | [H/M/L] |
```

### Step 2: Temporal Pattern Analysis

#### Trend Detection
```
TREND ANALYSIS
=============
Metric: [Name]
Direction: [Upward/Downward/Stable]
Slope: [Rate of change]
R-squared: [Correlation strength]
Statistical Significance: [p-value]

TREND EQUATION: Y = [slope]X + [intercept]

Projection:
- Next Period: [Predicted value]
- Confidence Interval: [Lower - Upper]
- Trend Strength: [Strong/Moderate/Weak]

Key Inflection Points:
1. [Date]: [Event/Change description]
2. [Date]: [Event/Change description]
```

#### Seasonality Patterns
```
SEASONAL PATTERNS
================
Pattern Type: [Daily/Weekly/Monthly/Quarterly/Annual]
Cycle Length: [X periods]
Amplitude: [Variation magnitude]
Phase: [Timing within cycle]

Peak Periods:
- [Period]: [Value] ([% above average])
- [Period]: [Value] ([% above average])

Trough Periods:
- [Period]: [Value] ([% below average])
- [Period]: [Value] ([% below average])

Seasonal Factors:
| Period | Factor | Typical Range |
|--------|--------|---------------|
| Jan    | [1.2]  | [Range]       |
| Feb    | [0.9]  | [Range]       |
| ...    | ...    | ...           |
```

#### Cyclical Patterns
```
BUSINESS CYCLES DETECTED
=======================
Cycle 1: [Name/Description]
- Duration: [X periods]
- Last Peak: [Date]
- Last Trough: [Date]
- Current Phase: [Expansion/Peak/Contraction/Trough]
- Next Turn Prediction: [Date] ± [Confidence interval]

Cycle 2: [Name/Description]
- Duration: [Y periods]
- Pattern: [Description]
```

### Step 3: Anomaly Detection

#### Statistical Anomalies
```
ANOMALY DETECTION RESULTS
========================
Method: [Z-score/IQR/Isolation Forest/DBSCAN]
Threshold: [Statistical threshold used]
Anomalies Found: [Count]

| Date/Time | Metric | Expected | Actual | Deviation | Z-Score | Classification |
|-----------|--------|----------|--------|-----------|---------|----------------|
| [Date]    | [Name] | [Value]  | [Value]| [%]       | [Score] | [Type]         |
| [Date]    | [Name] | [Value]  | [Value]| [%]       | [Score] | [Type]         |

Anomaly Clusters:
- Cluster 1: [Dates] - Common Factor: [Description]
- Cluster 2: [Dates] - Common Factor: [Description]
```

#### Pattern Breaks
```
PATTERN DISRUPTIONS
==================
Pattern: [Normal pattern description]
Break Date: [When pattern broke]
Duration: [How long disruption lasted]
Impact: [Business impact]
Root Cause: [If identified]
Recovery: [When/if pattern resumed]
```

### Step 4: Correlation and Causation Analysis

#### Correlation Matrix
```
CORRELATION ANALYSIS
===================
Strong Positive Correlations (>0.7):
- [Metric A] ↔ [Metric B]: r = [0.85]
  Lag: [X periods]
  Causation Test: [Result]

Strong Negative Correlations (<-0.7):
- [Metric C] ↔ [Metric D]: r = [-0.78]
  Lag: [Y periods]
  Causation Test: [Result]

Leading Indicators:
1. [Indicator] leads [Outcome] by [X periods]
   Correlation: [r value]
   Predictive Power: [%]

2. [Indicator] leads [Outcome] by [Y periods]
   Correlation: [r value]
   Predictive Power: [%]
```

#### Causal Relationships
```
GRANGER CAUSALITY TEST
=====================
Hypothesis: [X] causes [Y]
F-Statistic: [Value]
P-Value: [Value]
Result: [Accept/Reject]
Interpretation: [Plain language explanation]
```

### Step 5: Pattern Classification

#### Pattern Inventory
```
IDENTIFIED PATTERNS
==================

RECURRING PATTERNS (High Confidence)
------------------------------------
Pattern ID: P001
Type: [Temporal/Behavioral/Structural]
Description: [What happens]
Frequency: [How often]
Trigger: [What causes it]
Impact: [Business impact]
Confidence: [%]
Next Expected: [Date/Condition]

Pattern ID: P002
Type: [Category]
Description: [What happens]
Frequency: [How often]
Trigger: [What causes it]
Impact: [Business impact]
Confidence: [%]
Next Expected: [Date/Condition]

EMERGING PATTERNS (Medium Confidence)
-------------------------------------
Pattern ID: E001
Type: [Category]
Description: [What's emerging]
First Detected: [Date]
Occurrence Count: [X times]
Trend: [Strengthening/Weakening]
Confidence: [%]
Monitor Until: [Date]
```

### Step 6: Predictive Indicators

#### Early Warning Signals
```
EARLY WARNING SYSTEM
===================

INDICATOR 1: [Name]
Current Value: [X]
Normal Range: [Min - Max]
Warning Threshold: [Value]
Critical Threshold: [Value]
Status: [Normal/Warning/Critical]
Predicted Event: [What it predicts]
Lead Time: [How much advance warning]
Accuracy: [Historical accuracy %]

INDICATOR 2: [Name]
Current Value: [Y]
Normal Range: [Min - Max]
Warning Threshold: [Value]
Critical Threshold: [Value]
Status: [Normal/Warning/Critical]
Predicted Event: [What it predicts]
Lead Time: [How much advance warning]
Accuracy: [Historical accuracy %]
```

#### Predictive Models
```
PREDICTION MODELS
================
Model 1: [Name/Type]
Target: [What it predicts]
Features: [Input variables]
Accuracy: [%]
Precision: [%]
Recall: [%]
Next Prediction: [Value] ± [Confidence interval]

Model 2: [Name/Type]
Target: [What it predicts]
Features: [Input variables]
Accuracy: [%]
Current Prediction: [Value/Category]
Confidence: [%]
```

### Step 7: Risk and Opportunity Patterns

#### Risk Patterns
```
RISK PATTERN ANALYSIS
====================
Risk Pattern 1: [Description]
Frequency: [How often it occurs]
Pre-conditions: [What happens before]
Warning Signs: [Early indicators]
Impact When Occurs: [Business impact]
Mitigation: [How to prevent/reduce]

Risk Pattern 2: [Description]
Frequency: [How often]
Pre-conditions: [List]
Current Risk Level: [High/Medium/Low]
```

#### Opportunity Patterns
```
OPPORTUNITY PATTERNS
===================
Opportunity 1: [Description]
Trigger Conditions: [When it appears]
Historical Success Rate: [%]
Value Potential: $[Amount]
Window Duration: [How long it lasts]
Next Expected: [Date/Condition]

Opportunity 2: [Description]
Pattern: [What to look for]
Frequency: [How often]
Success Factors: [What makes it work]
```

### Step 8: Pattern Visualization

#### Time Series Visualization
```
PATTERN TIMELINE
===============
        Critical Events
            ↓     ↓
    |---●---●---★---●---◆---●---|
    Jan Feb Mar Apr May Jun Jul
    
Legend:
● = Normal Pattern
★ = Anomaly Detected
◆ = Pattern Change
─ = Trend Line
```

#### Pattern Dashboard
```
PATTERN STATUS DASHBOARD
=======================
Active Patterns: [Count]
Emerging Patterns: [Count]
Broken Patterns: [Count]
Anomalies (Last 30 Days): [Count]

Top Patterns by Impact:
1. [Pattern] - Impact: $[Amount]
2. [Pattern] - Impact: $[Amount]
3. [Pattern] - Impact: $[Amount]

Alert Status:
🟢 Normal: [X] indicators
🟡 Warning: [Y] indicators
🔴 Critical: [Z] indicators
```

## Output Format

### Pattern Detection Report
```
PATTERN DETECTION REPORT
=======================
Analysis Period: [Date range]
Data Points Analyzed: [Count]
Patterns Identified: [Count]
Confidence Level: [Average %]

KEY FINDINGS
-----------
1. Strong Trends:
   - [Metric]: [Direction] at [Rate]
   
2. Recurring Patterns:
   - [Pattern]: Every [Frequency]
   
3. Anomalies:
   - [Count] anomalies detected
   - Clustering around [Factor]
   
4. Predictive Indicators:
   - [Indicator] predicts [Outcome]
   - Lead time: [Period]
   - Accuracy: [%]

ACTIONABLE INSIGHTS
------------------
Immediate Actions:
1. [Action based on pattern]
2. [Action based on anomaly]

Monitoring Requirements:
1. Watch [Indicator] for [Condition]
2. Track [Pattern] for changes

Opportunities:
1. [Opportunity] expected [When]
2. [Opportunity] triggered by [Condition]

Risks:
1. [Risk pattern] showing early signs
2. [Risk indicator] approaching threshold

RECOMMENDATIONS
--------------
1. Implement early warning for [Pattern]
2. Automate response to [Recurring pattern]
3. Investigate root cause of [Anomaly cluster]
4. Prepare for [Predicted event]
```

## Quality Criteria
- Statistical significance of patterns
- Sufficient data for confidence
- Multiple validation methods used
- Clear causation vs correlation
- Actionable insights provided
- Predictive accuracy tracked

## Machine Learning Methods
- Time series decomposition
- ARIMA/SARIMA modeling
- Anomaly detection algorithms
- Clustering analysis
- Regression analysis
- Neural network patterns
- Change point detection

## Integration Points
- Feeds: Early Warning Systems
- Informs: Risk Assessment
- Triggers: Automated Responses
- Supports: Predictive Analytics
- Enables: Proactive Decision Making