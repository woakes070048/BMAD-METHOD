# Early Warning System Design and Implementation Task

## Task Description
Design and implement a comprehensive early warning system that detects potential issues before they become critical problems, enabling proactive intervention.

## Input Parameters
- **scope**: Business areas to monitor (required)
- **risk_appetite**: Organization's risk tolerance levels (required)  
- **historical_incidents**: Past incidents for pattern learning (required)
- **response_time_requirement**: How quickly warnings are needed (required)

## Execution Instructions

### Step 1: Warning System Architecture

#### System Overview
```
EARLY WARNING SYSTEM DESIGN
===========================
System Name: [Organization] Early Warning System
Coverage: [Business areas covered]
Monitoring Frequency: [Real-time/Hourly/Daily]
Alert Channels: [Email/SMS/Dashboard/API]
Escalation Levels: [Number of levels]
Response Teams: [List of teams]
```

#### Architecture Components
```
SYSTEM COMPONENTS
================
1. DATA COLLECTION LAYER
   - Data Sources: [List sources]
   - Collection Method: [APIs/Queries/Streams]
   - Frequency: [Real-time/Batch]
   - Data Volume: [Records/second]

2. PROCESSING LAYER
   - Analysis Engine: [Technology/Method]
   - Pattern Recognition: [Algorithms used]
   - Threshold Management: [Dynamic/Static]
   - Machine Learning: [Models deployed]

3. ALERT LAYER
   - Alert Generator: [Rule-based/ML-based]
   - Priority Engine: [Scoring method]
   - Distribution System: [Channels]
   - Acknowledgment Tracking: [System]

4. RESPONSE LAYER
   - Playbook Integration: [Automated/Manual]
   - Team Assignment: [Logic]
   - Tracking System: [Tool]
   - Feedback Loop: [Learning mechanism]
```

### Step 2: Key Risk Indicators (KRIs)

#### Primary Indicators
```
KEY RISK INDICATORS
==================

KRI-001: [Indicator Name]
Category: [Operational/Financial/Strategic/Compliance]
Description: [What it measures]
Current Value: [X]
Normal Range: [Min - Max]
Warning Threshold: [Value]
Critical Threshold: [Value]
Calculation: [Formula]
Data Source: [System]
Update Frequency: [How often]
Lead Time: [Advance warning period]
False Positive Rate: [%]

KRI-002: [Indicator Name]
Category: [Type]
Description: [What it measures]
Current Value: [Y]
Normal Range: [Min - Max]
Warning Threshold: [Value]
Critical Threshold: [Value]
Calculation: [Formula]
Data Source: [System]
Update Frequency: [How often]
Lead Time: [Advance warning period]
False Positive Rate: [%]
```

#### Composite Indicators
```
COMPOSITE RISK SCORES
====================
OVERALL RISK SCORE: [Current score]/100
Components:
- Operational Risk: [Score]/100 (Weight: 30%)
- Financial Risk: [Score]/100 (Weight: 25%)
- Strategic Risk: [Score]/100 (Weight: 25%)
- Compliance Risk: [Score]/100 (Weight: 20%)

Trend: [Improving/Stable/Deteriorating]
Rate of Change: [X% per period]
```

### Step 3: Threshold Configuration

#### Static Thresholds
```
THRESHOLD DEFINITIONS
====================
Indicator: [Name]
| Level    | Value | Action Required | Response Time | Escalation |
|----------|-------|-----------------|---------------|------------|
| Normal   | <[X]  | Monitor only    | N/A           | None       |
| Caution  | [X-Y] | Review needed   | 24 hours      | Team Lead  |
| Warning  | [Y-Z] | Investigation   | 4 hours       | Manager    |
| Critical | >[Z]  | Immediate action| 30 minutes    | Executive  |
```

#### Dynamic Thresholds
```
ADAPTIVE THRESHOLDS
==================
Indicator: [Name]
Base Threshold: [Value]
Adjustment Factors:
- Time of Day: ±[X%]
- Day of Week: ±[Y%]
- Season: ±[Z%]
- Business Cycle: ±[W%]

Current Adjusted Threshold: [Calculated value]
Learning Algorithm: [Method used]
Adaptation Rate: [How quickly it adjusts]
```

### Step 4: Pattern-Based Warnings

#### Warning Patterns
```
PATTERN-BASED ALERTS
===================

PATTERN 1: [Name]
Description: [What sequence indicates problem]
Sequence: [Event A] → [Event B] → [Event C]
Time Window: [X hours]
Confidence Required: [%]
Historical Accuracy: [%]
Last Triggered: [Date]
Action: [What to do when detected]

PATTERN 2: [Name]
Description: [Complex pattern description]
Conditions:
  AND: [Condition 1]
  AND: [Condition 2]
  OR:  [Condition 3]
Time Window: [Y hours]
Confidence Required: [%]
Historical Accuracy: [%]
```

#### Anomaly-Based Warnings
```
ANOMALY DETECTION
================
Method: [Statistical/ML Model]
Baseline Period: [Time range for normal]
Sensitivity: [High/Medium/Low]
Current Anomalies:

| Timestamp | Indicator | Expected | Actual | Deviation | Score | Status |
|-----------|-----------|----------|--------|-----------|-------|--------|
| [Time]    | [Name]    | [Value]  | [Value]| [%]       | [0-10]| [Alert]|
| [Time]    | [Name]    | [Value]  | [Value]| [%]       | [0-10]| [Alert]|
```

### Step 5: Alert Generation and Prioritization

#### Alert Scoring Matrix
```
ALERT PRIORITIZATION
===================
Score = (Impact × Likelihood × Velocity) / Response_Capability

| Factor | Weight | Score (1-10) | Weighted Score |
|--------|--------|--------------|----------------|
| Impact | 40%    | [X]          | [Calculate]    |
| Likelihood | 25% | [Y]          | [Calculate]    |
| Velocity | 20%  | [Z]          | [Calculate]    |
| Detectability | 15% | [W]      | [Calculate]    |

TOTAL PRIORITY SCORE: [Sum]
Priority Level: [Critical/High/Medium/Low]
```

#### Alert Templates
```
ALERT FORMAT
===========
[PRIORITY] Early Warning Alert

Alert ID: [Unique ID]
Timestamp: [Date/Time]
Category: [Type]
Severity: [Level]

ISSUE DETECTED:
[Clear description of what was detected]

INDICATORS:
- [Indicator 1]: [Value] (Normal: [Range])
- [Indicator 2]: [Value] (Normal: [Range])

POTENTIAL IMPACT:
- Business Impact: [Description]
- Financial Impact: $[Estimated]
- Customer Impact: [Description]

RECOMMENDED ACTION:
1. [Immediate action]
2. [Secondary action]
3. [Investigation needed]

ESCALATION REQUIRED: [Yes/No]
Response Deadline: [Time]
Assigned To: [Team/Person]
```

### Step 6: Response Protocols

#### Response Playbooks
```
RESPONSE PLAYBOOK
================
Alert Type: [Category]
Severity: [Level]

IMMEDIATE ACTIONS (0-30 minutes)
1. [Action]: [Who does what]
2. [Action]: [Who does what]
3. [Action]: [Who does what]

INVESTIGATION (30 min - 4 hours)
1. Check: [What to verify]
2. Analyze: [What to examine]
3. Document: [What to record]

RESOLUTION (4-24 hours)
1. Fix: [How to resolve]
2. Verify: [How to confirm]
3. Monitor: [What to watch]

ESCALATION TRIGGERS
- If [Condition], escalate to [Level]
- If not resolved in [Time], escalate to [Level]
```

#### Automated Responses
```
AUTOMATED ACTIONS
================
Trigger: [Alert condition]
Automated Response:
1. [System action taken]
2. [Notification sent]
3. [Process initiated]
4. [Data captured]

Human Approval Required: [Yes/No]
Rollback Capability: [Yes/No]
Success Rate: [%]
```

### Step 7: Dashboard and Visualization

#### Executive Dashboard
```
EARLY WARNING DASHBOARD
======================
╔════════════════════════════════════╗
║     SYSTEM STATUS: 🟡 WARNING      ║
╠════════════════════════════════════╣
║ Active Alerts:        5            ║
║ Critical:      🔴 1                ║
║ High:          🟠 2                ║
║ Medium:        🟡 2                ║
║ Low:           🟢 0                ║
╠════════════════════════════════════╣
║ TRENDING INDICATORS                ║
║ Revenue Risk:     ↗️ +15%          ║
║ Op Efficiency:    ↘️ -8%           ║
║ Customer Sat:     → Stable         ║
║ Compliance:       ↗️ +5%           ║
╠════════════════════════════════════╣
║ PREDICTIONS (Next 24hrs)           ║
║ Critical Events:  2 (85% conf)     ║
║ High Risk Areas:  Logistics, IT    ║
╚════════════════════════════════════╝
```

### Step 8: Continuous Improvement

#### Performance Metrics
```
SYSTEM PERFORMANCE
=================
Alert Accuracy:
- True Positives: [X%]
- False Positives: [Y%]
- False Negatives: [Z%]
- True Negatives: [W%]

Response Effectiveness:
- Avg Response Time: [Minutes]
- Resolution Rate: [%]
- Escalation Rate: [%]
- Prevented Incidents: [Count]

Value Delivered:
- Incidents Prevented: [Count]
- Cost Avoided: $[Amount]
- Downtime Prevented: [Hours]
- Customer Issues Avoided: [Count]
```

#### Feedback Loop
```
LEARNING MECHANISM
=================
Feedback Collection:
1. Post-Alert Survey: [Response rate]
2. False Positive Reporting: [Process]
3. Miss Event Analysis: [Process]

Model Updates:
- Frequency: [How often]
- Method: [Manual/Automated]
- Validation: [Process]
- Rollback Plan: [Process]

Improvements Made:
1. [Date]: [What was improved]
2. [Date]: [What was improved]
```

## Output Format

### Early Warning System Report
```
EARLY WARNING SYSTEM STATUS
===========================
System Health: [Status]
Coverage: [X%] of identified risks
Effectiveness: [Y%] accurate predictions

CURRENT WARNINGS
---------------
Critical: [List]
High: [List]
Medium: [List]

PREDICTED ISSUES (Next 7 Days)
-----------------------------
1. [Issue] - Probability: [%] - Impact: [High/Med/Low]
2. [Issue] - Probability: [%] - Impact: [High/Med/Low]

KEY METRICS
----------
- Mean Time to Detect: [Time]
- Mean Time to Alert: [Time]
- Mean Time to Respond: [Time]
- Prevention Success Rate: [%]

RECOMMENDATIONS
--------------
1. Adjust threshold for [Indicator]
2. Add monitoring for [New risk]
3. Improve response time for [Alert type]
```

## Quality Criteria
- Comprehensive risk coverage
- Low false positive rate (<10%)
- High true positive rate (>90%)
- Clear escalation paths
- Automated where possible
- Continuous learning capability
- Documented response procedures

## Technology Stack Options
- Streaming: Apache Kafka, AWS Kinesis
- Processing: Apache Spark, Storm
- ML Platforms: TensorFlow, PyTorch
- Visualization: Grafana, Tableau
- Alerting: PagerDuty, Opsgenie
- Orchestration: Apache Airflow

## Integration Points
- Connects to: All data sources
- Feeds: Incident Management
- Triggers: Response Playbooks
- Informs: Risk Management
- Updates: Executive Dashboards