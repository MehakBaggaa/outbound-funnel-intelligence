# Outbound Funnel Intelligence

## Uncoordinated Multi-Touch Outreach Analysis

End-to-end sales analytics project built to measure funnel performance, sender overlap, outreach efficiency, and CRM data quality across outbound prospect journeys.

### Tools Used
- Excel
- Power Query
- MySQL
- SQL
- Power BI
- DAX
- GitHub

---

## Project Overview

Outbound sales teams often engage the same prospect through multiple campaigns, senders, and touchpoints. While this increases outreach coverage, it can also create duplicate engagement, ownership conflicts, CRM duplication challenges, and unreliable funnel reporting.

This project develops a journey-level analytical framework to measure funnel performance, quantify sender overlap, assess CRM data quality, and identify opportunities to improve outreach efficiency and reporting reliability.

---

## Business Problem

Outbound sales teams frequently contact the same prospect through multiple campaigns and senders without shared visibility into previous interactions. This creates ownership conflicts, fragmented attribution, duplicate outreach efforts, and reduced confidence in funnel reporting.

### Key Challenges

- Sender overlap across active prospect journeys
- CRM duplicate identities impacting reporting accuracy
- Limited visibility into prior outreach activity
- Funnel progression not consistently measurable
- Inefficient lead prioritization and follow-up decisions

  ---

## Project Objectives

This project was designed to answer the following business questions:

- Where does the largest funnel drop-off occur?
- What impact does sender overlap have on performance?
- How do duplicate identities affect reporting accuracy?
- When do additional touchpoints become less effective?
- Which response stages are most likely to convert?

### Objectives

- Measure outreach effectiveness consistently
- Identify sender overlap and ownership issues
- Improve reporting reliability
- Support better lead prioritization
- Enable accurate funnel performance analysis

---

## Dataset Overview

The project uses five operational datasets representing outreach activity, engagement behavior, campaign information, sender ownership, and contact-level CRM records.

| Dataset | Grain | Purpose |
|----------|----------|----------|
| Email Activity | 1 row = 1 outreach event | Outreach history and touchpoint activity |
| Engagement | 1 row = 1 engagement event | Responses, qualification outcomes, and conversions |
| Contacts | 1 row = 1 CRM contact record | Prospect identity and attributes |
| Campaigns | 1 row = 1 campaign | Campaign strategy and configuration |
| Senders | 1 row = 1 sender | Sender ownership and segmentation |

### Data Consideration

During validation, duplicate human identities were identified across multiple CRM contact records. Rather than removing these records, they were preserved because they represented a real operational challenge affecting outreach coordination, ownership visibility, and reporting reliability.

---

## Methodology

The project followed a structured analytics workflow from raw data preparation through dashboard development.

### Phase 1 — Excel & Power Query

- Imported five source datasets for validation and preparation
- Standardized data types and reviewed missing values
- Validated response-related fields and business classifications
- Investigated CRM duplicate identities
- Preserved original records to maintain analytical accuracy

### Phase 2 — SQL Data Validation & Modeling

- Loaded datasets into MySQL
- Standardized schemas and validated relationships
- Performed relationship validation across all source tables
- Built analytical summary layers for reporting
- Created sender overlap and CRM duplication indicators
- Developed a consolidated analytical dataset for KPI reporting

### Phase 3 — KPI Development

KPIs were standardized at the journey level using:

**Email + Campaign**

as the reporting grain to prevent metric inflation caused by multiple outreach events and duplicate CRM identities.

### Phase 4 — Power BI Dashboard Development

- Developed journey-level DAX measures
- Built executive-facing dashboard pages
- Designed funnel, overlap, efficiency, and CRM quality reporting
- Created stakeholder-focused visualizations and recommendations

---

## Analytical Modeling Decisions

### Key Decisions

1. CRM duplicate identities were preserved rather than removed.
2. Response classifications were standardized for consistent reporting.
3. Qualification logic was explicitly defined.
4. Email was selected as the human identity anchor.
5. Email Activity was used as the primary fact table.
6. Relationships were validated before KPI development.
7. Summary layers were created to resolve grain differences.
8. Sender overlap was measured at the human identity level.
9. The analytical model was maintained at the event level.
10. KPI reporting was standardized at the journey level.

---

## KPI Framework

All KPI calculations were standardized at the journey level using:

**Email + Campaign**

as the reporting grain.

| KPI Category | KPIs Measured |
|-------------|---------------|
| Funnel Performance | Total Journeys, Replied Journeys, Qualified Journeys, Converted Journeys, Reply Rate, Qualification Rate, Conversion Rate |
| Funnel Progression | Reply-to-Qualification Rate, Qualification-to-Conversion Rate |
| Sender Overlap Analysis | Sender Overlap Rate, Overlap Conversion Rate, No Overlap Conversion Rate, Conversion Delta |
| Outreach Efficiency | Average Touchpoints, Average Touchpoints (Converted), Average Touchpoints (Non-Converted), Average Outreach Duration |
| CRM Data Quality | CRM Duplication Rate, Duplicate Identity Conversion Rate, Single Identity Conversion Rate, Duplicate Identity Sender Overlap Rate |
| Response Quality | Direct Requirement Conversion Rate, Meeting Interest Conversion Rate, Negative Response Rate |

---

## Dashboard Overview

### Page 1 — Executive Funnel Summary
Overall funnel performance and stage-wise leakage.

### Page 2 — Sender Overlap Impact Analysis
Operational impact of multi-sender outreach.

### Page 3 — Outreach Efficiency
Touchpoint effectiveness and diminishing returns.

### Page 4 — Response Quality & CRM Data Quality
Response-stage conversion and CRM duplication analysis.

---

## Key Findings

### Funnel Performance

- Total Journeys: 18,014
- Replied Journeys: 5,484
- Qualified Journeys: 1,579
- Converted Journeys: 718

#### Key Insights

- Reply Rate: 30.44%
- Conversion Rate: 3.99%
- Largest funnel drop-off occurred between Reply and Qualification (71.2%).
- Qualified journeys converted at 45.5%.
- Qualification quality was the strongest predictor of downstream conversion.

---

### Sender Overlap Analysis

- Sender Overlap Rate: 72.5%
- Conversion Delta: 0.27 percentage points

#### Key Insights

- Sender overlap existed across most prospect journeys.
- Conversion performance differed by only 0.27 percentage points between overlapped and non-overlapped journeys.
- Sender overlap represents an operational coordination challenge more than a conversion performance issue.

---

### Outreach Efficiency

#### Key Insights

- Conversion performance was strongest at Touchpoint 1 (8.03%).
- Converted journeys averaged 2.93 touchpoints.
- Non-converted journeys averaged 3.99 touchpoints.
- Additional outreach attempts generated diminishing returns.

---

### CRM Data Quality

- CRM Duplication Rate: 47.37%

#### Key Insights

- Duplicate identities experienced 96.94% sender overlap.
- Single identities experienced 34.87% sender overlap.
- CRM duplication was identified as the primary driver of ownership fragmentation, sender overlap, and reporting reliability challenges.

---

### Response Quality

#### Key Insights

- Direct Requirement responses converted at 51.56%.
- Meeting Interest responses converted at 40.54%.
- High-intent responses were the strongest predictors of conversion.

---

## Business Recommendations

### 1. Implement Identity-Level CRM Deduplication Controls

Improve ownership visibility, reporting reliability, and outreach coordination by preventing duplicate prospect records.

**Expected Impact**
- Reduced sender overlap
- Improved reporting accuracy
- Stronger prospect ownership visibility

### 2. Prioritize High-Intent Response Signals

Focus qualification and follow-up efforts on Direct Requirement and Meeting Interest responses.

**Expected Impact**
- Improved conversion efficiency
- Better lead prioritization
- Faster qualification decisions

### 3. Establish Cross-Campaign Outreach Governance

Introduce ownership and coordination rules to reduce unnecessary multi-sender outreach while maintaining prospect coverage.

**Expected Impact**
- Improved attribution integrity
- Reduced duplicate outreach effort
- Better prospect experience

---

## Technical Stack

| Tool | Purpose |
|--------|---------|
| Excel | Initial data exploration and validation |
| Power Query | Data preparation and transformation |
| MySQL | Data validation and analytical modeling |
| SQL | KPI development and business analysis |
| Power BI | Dashboard development and visualization |
| DAX | Journey-level KPI calculations |
| GitHub | Documentation and portfolio management |

---

## Repository Structure

```text
outbound-funnel-intelligence/
│
├── README.md
├── LICENSE
│
├── data/
├── sql/
├── powerbi/
├── docs/
├── presentation/
└── assets/
```

## Conclusion

This project established a validated journey-level analytical framework for measuring outbound funnel performance, outreach efficiency, sender overlap, and CRM data quality.

The analysis demonstrated that operational visibility and identity management challenges had a greater impact on reporting reliability than on conversion performance, providing actionable opportunities for process improvement and outreach optimization.

### Key Outcomes

- 18,014 journeys analyzed
- 72.5% sender overlap identified
- 47.37% CRM duplication quantified
- Journey-level KPI framework established
- Executive Power BI dashboard delivered
- Business recommendations developed

---

## Author

**Mehak Bagga**

Business Analyst | Data Analyst | SalesOps Analyst | RevOps Analyst

GitHub Portfolio Project
