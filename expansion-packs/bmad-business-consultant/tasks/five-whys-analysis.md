# Five Whys Root Cause Analysis Task

## Task Description
Conduct a systematic Five Whys analysis to drill down from symptoms to root causes through iterative questioning.

## Input Parameters
- **problem**: The problem or incident to analyze (required)
- **context**: Business context and background (required)
- **data**: Supporting data and evidence (required)
- **depth**: Number of why levels to explore (default: 5, max: 7)

## Execution Instructions

### Step 1: Problem Definition
Define the problem clearly and specifically:
```
PROBLEM STATEMENT: [Specific, measurable problem description]
WHEN: [Time period or specific incident]
WHERE: [Location, system, or process]
IMPACT: [Quantified business impact]
```

### Step 2: Iterative Why Analysis

#### First Why
```
WHY 1: Why did [PROBLEM] occur?

ANSWER: [Direct cause based on evidence]

EVIDENCE:
- Data point 1: [Specific data]
- Data point 2: [Specific data]
- Observation: [What was observed]

CONFIDENCE LEVEL: [High/Medium/Low]
VALIDATION METHOD: [How this was verified]
```

#### Second Why
```
WHY 2: Why did [ANSWER 1] happen?

ANSWER: [Deeper cause]

EVIDENCE:
- Data point 1: [Specific data]
- Data point 2: [Specific data]
- Analysis: [What analysis shows]

CONFIDENCE LEVEL: [High/Medium/Low]
VALIDATION METHOD: [How this was verified]
```

#### Third Why
```
WHY 3: Why did [ANSWER 2] happen?

ANSWER: [Even deeper cause]

EVIDENCE:
- Process review: [Findings]
- System analysis: [Findings]
- Interview insights: [Key points]

CONFIDENCE LEVEL: [High/Medium/Low]
VALIDATION METHOD: [How this was verified]
```

#### Fourth Why
```
WHY 4: Why did [ANSWER 3] happen?

ANSWER: [Systemic cause]

EVIDENCE:
- Organizational factor: [Description]
- Policy/procedure gap: [Description]
- Resource constraint: [Description]

CONFIDENCE LEVEL: [High/Medium/Low]
VALIDATION METHOD: [How this was verified]
```

#### Fifth Why
```
WHY 5: Why did [ANSWER 4] happen?

ANSWER: [Root cause]

EVIDENCE:
- Strategic gap: [Description]
- Cultural factor: [Description]
- Fundamental issue: [Description]

CONFIDENCE LEVEL: [High/Medium/Low]
VALIDATION METHOD: [How this was verified]
```

### Step 3: Root Cause Validation

#### Validation Tests
1. **Reversibility Test**: If we fix [ROOT CAUSE], will it prevent [PROBLEM]?
   - Answer: [Yes/No/Partially]
   - Reasoning: [Explanation]

2. **Sufficiency Test**: Is [ROOT CAUSE] sufficient to cause [PROBLEM]?
   - Answer: [Yes/No/Partially]
   - Reasoning: [Explanation]

3. **Necessity Test**: Is [ROOT CAUSE] necessary for [PROBLEM] to occur?
   - Answer: [Yes/No/Partially]
   - Reasoning: [Explanation]

### Step 4: Alternative Paths Analysis
Explore alternative why chains:

#### Alternative Path A
```
From WHY 2, alternative answer: [Different cause]
WHY 3A: Why did [Alternative] happen?
WHY 4A: [Continue chain]
WHY 5A: [Alternative root cause]
```

#### Alternative Path B
```
From WHY 3, alternative answer: [Different cause]
WHY 4B: Why did [Alternative] happen?
WHY 5B: [Alternative root cause]
```

### Step 5: Root Cause Synthesis

#### Primary Root Cause
- **Root Cause**: [Final actionable root cause]
- **Category**: [Human/Process/Technology/Environmental]
- **Preventability**: [High/Medium/Low]
- **Actionability**: [High/Medium/Low]

#### Contributing Factors
1. Factor: [Description] - Impact: [High/Medium/Low]
2. Factor: [Description] - Impact: [High/Medium/Low]
3. Factor: [Description] - Impact: [High/Medium/Low]

### Step 6: Solution Development

#### Immediate Actions
1. **Action**: [Specific action]
   - Timeline: [Days/Weeks]
   - Owner: [Role/Department]
   - Expected Impact: [Description]

2. **Action**: [Specific action]
   - Timeline: [Days/Weeks]
   - Owner: [Role/Department]
   - Expected Impact: [Description]

#### Long-term Solutions
1. **Solution**: [Comprehensive solution]
   - Root Cause Addressed: [Which root cause]
   - Implementation Complexity: [High/Medium/Low]
   - Investment Required: [Estimate]
   - ROI Timeline: [Months]

## Output Format

### Five Whys Analysis Report
```
FIVE WHYS ROOT CAUSE ANALYSIS
==============================

Problem: [Problem statement]
Date: [Analysis date]
Analyst: [Name/Team]

WHY CHAIN ANALYSIS
------------------
Why 1: [Question] → [Answer] (Confidence: X%)
Why 2: [Question] → [Answer] (Confidence: X%)
Why 3: [Question] → [Answer] (Confidence: X%)
Why 4: [Question] → [Answer] (Confidence: X%)
Why 5: [Question] → [Answer] (Confidence: X%)

ROOT CAUSE IDENTIFIED
--------------------
Primary Root Cause: [Description]
Category: [Type]
Confidence Score: [%]
Evidence Strength: [Strong/Moderate/Weak]

ALTERNATIVE CAUSES
-----------------
1. [Alternative root cause] - Probability: [%]
2. [Alternative root cause] - Probability: [%]

RECOMMENDATIONS
--------------
Immediate:
1. [Action] - [Timeline]
2. [Action] - [Timeline]

Long-term:
1. [Solution] - [ROI]
2. [Solution] - [ROI]

VALIDATION
----------
✓ Reversibility Test: [Pass/Fail]
✓ Sufficiency Test: [Pass/Fail]
✓ Necessity Test: [Pass/Fail]
```

## Quality Criteria
- Each why must be answered with evidence
- Confidence levels must be assessed
- Alternative paths must be explored
- Root cause must be actionable
- Solutions must address the root cause
- Validation tests must be completed

## Common Pitfalls to Avoid
1. **Stopping at symptoms**: Ensure you reach true root causes
2. **Jumping to conclusions**: Base each answer on evidence
3. **Single path thinking**: Explore alternatives
4. **Blaming individuals**: Focus on systemic issues
5. **Non-actionable causes**: Ensure root cause can be addressed

## Integration Points
- Feeds into: Comprehensive RCA Report
- Combines with: Fishbone Analysis, Fault Tree Analysis
- Informs: Solution Architecture, Risk Assessment
- Validates: Pattern Detection findings