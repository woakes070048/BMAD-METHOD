# Extract Customer Pain Points Task

## Task Description
Systematically extract and analyze customer pain points from collected research data using structured methodology to identify problems, assess priority, and preserve authentic customer language.

## Input Parameters
- **research_data**: Raw research data from online sources (required)
- **problem_focus**: Specific problem area to investigate (optional)
- **analysis_depth**: Level of analysis (basic extraction, full analysis, priority scoring)
- **output_format**: Desired output format (quotes only, analysis, scored matrix)

## Execution Instructions

### Step 1: Data Preparation and Organization
1. Review all collected research data systematically
2. Organize data by source platform and content type
3. Prepare for systematic quote extraction and categorization
4. Establish quality criteria for relevant quotes

### Step 2: Problem-Focused Quote Extraction
Use this professional market research prompt structure for extraction:

```
### Problem we're investigating

[SPECIFIC PROBLEM AREA GOES HERE]

## My goal
Extract all relevant mentions of the problem, to understand its various manifestations and impact on users.

## Your role
You are a market research expert specialized in extracting relevant customer quotes and pain points.

## Your mission
Extract all relevant quotes from the provided raw data that relate to our specific problem. Group them by sub-themes or aspects of the main problem.

## Instructions and formatting
- Extract exact customer wording
- Group by sub-themes within the main problem
- Use only direct quotes from the raw data
- Keep the original language and emotions
- Focus on impactful, relatable statements

## Format
{
## [Sub-theme of the problem]

- "[Exact quote from raw data]"
- "[Exact quote from raw data]"
- [Continue with all relevant quotes]

## [Next sub-theme]

- "[Exact quote from raw data]"
- "[Exact quote from raw data]"
- [Continue with all relevant quotes]
}

## EXTREMELY IMPORTANT
- Only include quotes directly related to our specific problem
- Maintain exact customer language
- No analysis or interpretation
- No summaries or additional text
- No context or explanations needed
```

### Step 3: Comprehensive Pain Point Analysis
Apply the COUNT/URGENCY/IMPACT framework from the methodology:

For each identified problem, analyze using this structure:

```
## PROBLEM
#[number] - [Problem Title]

## COUNT:
[number of mentions across all data sources]

## URGENCY:
[High/Medium/Low - how time-sensitive is this problem]

## IMPACT:
[High/Medium/Low - severity of consequences if unresolved]

## SEARCH QUERY:
"[likely search term customers would use]"

## CONTEXT:
[2-3 line description of the problem and its manifestation]

## KEY QUOTES:
- "[Quote 1 with source reference]"
- "[Quote 2 with source reference]"
- "[Quote 3 with source reference]"
- "[Quote 4 with source reference]"
- "[Quote 5 with source reference]"

---
```

### Step 4: Problem Prioritization Matrix
Create prioritization using the scoring methodology:

| Problem | Count | Urgency | Impact | Priority Score | Strategic Value |
|---------|-------|---------|--------|----------------|-----------------|
| Problem 1 | [#] | [H/M/L] | [H/M/L] | [Calculated] | [High/Med/Low] |
| Problem 2 | [#] | [H/M/L] | [H/M/L] | [Calculated] | [High/Med/Low] |

**Priority Scoring Formula**:
- Count: Raw number of mentions
- Urgency: High=3, Medium=2, Low=1
- Impact: High=3, Medium=2, Low=1
- Priority Score = Count × (Urgency + Impact)

### Step 5: Customer Language Analysis
Extract authentic customer language patterns:

**Pain Point Keywords Found**:
- Direct problem statements
- Emotional expressions
- Frustration indicators
- Desired outcome language
- Current workaround descriptions

**Customer Voice Patterns**:
- How customers describe the problem
- Emotional intensity indicators
- Frequency of mention patterns
- Context and trigger situations

## Pain Point Categories

### Functional Pain Points
- Process inefficiencies
- Tool limitations
- Capability gaps
- Performance issues

### Emotional Pain Points
- Stress and anxiety
- Frustration with current solutions
- Fear of consequences
- Confidence issues

### Financial Pain Points
- Cost concerns
- Budget constraints
- ROI challenges
- Value perception issues

### Social Pain Points
- Professional reputation
- Team dynamics
- Customer satisfaction
- Industry standing

## Output Requirements

### Standard Deliverable
- Complete pain point extraction organized by themes
- COUNT/URGENCY/IMPACT analysis for all problems
- Prioritization matrix with strategic recommendations
- Preserved customer quotes with source attribution

### Quality Criteria
- **Authenticity**: Exact customer language preserved
- **Completeness**: All relevant pain points identified and categorized
- **Prioritization**: Clear ranking based on objective criteria
- **Actionability**: Insights suitable for solution development
- **Source Attribution**: All quotes properly referenced

## Advanced Analysis Techniques

### Sentiment Analysis
- Emotional intensity scoring
- Frustration level assessment
- Urgency indicators in language
- Hope/desperation markers

### Frequency Analysis
- Most commonly mentioned problems
- Platform-specific pain point patterns
- Seasonal or timing variations
- Demographic differences (if identifiable)

### Gap Analysis
- Unmet needs identification
- Current solution inadequacies
- Workaround behaviors
- Ideal state descriptions

## Integration Points

This pain point analysis directly feeds into:
- **Solution Generation**: Problem-to-solution mapping
- **Buyer Persona Development**: Pain point clustering by customer type
- **Value Proposition Design**: Addressing specific customer pains
- **Marketing Message Development**: Using authentic customer language
- **Product Roadmap Planning**: Feature prioritization based on pain severity

## Success Metrics
- Number of distinct pain points identified
- Quality and authenticity of customer quotes collected
- Accuracy of prioritization based on customer data
- Usefulness for solution development and messaging
- Coverage across different customer segments and platforms

## Common Pain Point Indicators

### High-Priority Indicators
- Multiple mentions across different platforms
- Emotional language and strong frustration
- Mentions of failed previous solutions
- Time-sensitive or urgent language
- Financial impact descriptions

### Problem Validation Signals
- Specific, detailed problem descriptions
- Workaround behaviors described
- Willingness to pay mentions
- Competitor complaint patterns
- Industry-wide acknowledgment

## Output Templates
Use the provided templates:
- `pain-point-analysis-tmpl.yaml` for structured analysis
- `customer-quotes-tmpl.yaml` for quote organization
- `problem-prioritization-tmpl.yaml` for scoring matrix