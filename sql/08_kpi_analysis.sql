-- ============================================================
-- File: 08_kpi_analysis.sql
-- Project: Outbound Funnel Intelligence
-- Stage: KPI Development & Business Analysis
-- Purpose: Calculate journey-level KPIs, analyze
--          funnel performance, sender overlap,
--          outreach efficiency, CRM duplication,
--          and response quality metrics.
-- Dependencies:
--     01_environment_setup.sql
--     02_schema_standardization.sql
--     03_relationship_validation.sql
--     04_summary_layers.sql
--     05_sender_overlap_modeling.sql
--     06_analytical_master.sql
--     07_journey_validation.sql
-- ============================================================

-- ============================================================
-- Stage 8: KPI Development & Business Analysis
-- ============================================================


-- Funnel Performance Analysis
WITH dedup_journeys AS (
    SELECT
        email,
        campaign_id,
        MAX(COALESCE(has_replied, 0)) AS replied,
        MAX(COALESCE(has_negative_response, 0)) AS negative,
        MAX(COALESCE(is_qualified, 0)) AS qualified,
        MAX(COALESCE(is_converted, 0)) AS converted
    FROM analytical_master
    GROUP BY email, campaign_id
)

SELECT 
    COUNT(*) AS total_journeys,
    COUNT(DISTINCT email) AS unique_humans,
    SUM(replied) AS replied_count,
    SUM(negative) AS negative_response_count,
    SUM(qualified) AS qualified_count,
    SUM(converted) AS converted_count,
    ROUND(SUM(replied) / COUNT(*) * 100, 1) AS reply_rate_pct,
    ROUND(SUM(negative) / NULLIF(SUM(replied), 0) * 100, 1) AS negative_resp_rate_of_replied_journeys,
    ROUND(SUM(negative) / COUNT(*) * 100, 1) AS negative_resp_rate_of_total_journeys,    
    ROUND(SUM(qualified) / NULLIF(SUM(replied), 0) * 100, 1) AS reply_to_qualification_rate_pct,
    ROUND(SUM(converted) / NULLIF(SUM(qualified), 0) * 100, 1) AS qualified_to_conversion_rate_pct,
    ROUND(SUM(converted) / COUNT(*) * 100, 1) AS overall_conversion_rate_pct
FROM dedup_journeys;


-- Sender Overlap Impact Analysis
WITH dedup_journeys AS (
    SELECT
        email,
        campaign_id,
        MAX(has_sender_overlap) AS overlap,
        MAX(COALESCE(has_replied, 0)) AS replied,
        MAX(COALESCE(has_negative_response, 0)) AS negative,
        MAX(COALESCE(is_qualified, 0)) AS qualified,
        MAX(COALESCE(is_converted, 0)) AS converted,
        MAX(total_touchpoints) AS touchpoints
    FROM analytical_master
    GROUP BY email, campaign_id
)

SELECT
    overlap AS has_sender_overlap,
    COUNT(*) AS total_journeys,
    COUNT(DISTINCT email) AS unique_humans,
    ROUND(AVG(replied) * 100, 1) AS reply_rate_pct,
    ROUND(AVG(negative) * 100, 1) AS negative_resp_rate_of_total_journeys,
    ROUND(AVG(qualified) * 100, 1) AS qualification_rate_pct,
    ROUND(AVG(converted) * 100, 1) AS conversion_rate_pct,
    ROUND(AVG(touchpoints), 1) AS avg_touchpoints
FROM dedup_journeys
GROUP BY overlap;

-- Touchpoint Effectiveness Analysis
WITH dedup_journeys AS (
    SELECT
        email,
        campaign_id,
        MAX(total_touchpoints) AS touchpoints,
        MAX(COALESCE(is_converted, 0)) AS converted,
        MAX(COALESCE(has_negative_response, 0)) AS negative
    FROM analytical_master
    GROUP BY email, campaign_id
)

SELECT
    touchpoints,
    COUNT(*) AS total_journeys,
    ROUND(AVG(converted) * 100, 1) AS conversion_rate_pct,
    ROUND(AVG(negative) * 100, 1) AS negative_resp_rate_total_journeys
FROM dedup_journeys
GROUP BY touchpoints
ORDER BY touchpoints;


-- Outreach Efficiency Analysis
WITH dedup_journeys AS (
    SELECT
        email,
        campaign_id,
        MAX(total_touchpoints) AS touchpoints,
        MAX(outreach_duration_days) AS duration_days,
        MAX(avg_gap_days) AS avg_gap_days,
        MAX(COALESCE(is_converted, 0)) AS converted,
        MAX(COALESCE(has_negative_response, 0)) AS negative
    FROM analytical_master
    GROUP BY email, campaign_id
)

SELECT
    touchpoints,
    COUNT(*) AS total_journeys,
    ROUND(AVG(converted) * 100, 1) AS conversion_rate_pct,
    ROUND(AVG(negative) * 100, 1) AS negative_resp_rate_total_journeys,
    ROUND(AVG(duration_days), 1) AS avg_outreach_duration_days,
    ROUND(AVG(avg_gap_days), 1) AS avg_gap_between_touchpoints
FROM dedup_journeys
GROUP BY touchpoints
ORDER BY touchpoints;


-- CRM Duplication Analysis

--  Analyze Duplicate Identity Prevalence
SELECT 
    duplicate_email_flag,
    COUNT(DISTINCT contact_id) AS unique_contacts,
    ROUND(COUNT(DISTINCT contact_id) * 100.0 / 
          (SELECT COUNT(DISTINCT contact_id) FROM analytical_master), 2) AS pct
FROM analytical_master
GROUP BY duplicate_email_flag;


-- Measure CRM Duplication Rate
SELECT
    COUNT(DISTINCT contact_id) AS total_crm_records,
    COUNT(DISTINCT email) AS unique_human_identities,
    COUNT(DISTINCT contact_id) - COUNT(DISTINCT email) AS excess_crm_records,
    ROUND(
        (COUNT(DISTINCT contact_id) - COUNT(DISTINCT email))
        / COUNT(DISTINCT contact_id) * 100,
        1
    ) AS crm_duplication_rate_pct
FROM analytical_master;

-- Compare Conversion by Identity Type
WITH email_level AS (
    SELECT
        email,
        COUNT(DISTINCT contact_id) AS contact_count,
        MAX(COALESCE(is_converted, 0)) AS converted
    FROM analytical_master
    GROUP BY email
)

SELECT
    CASE 
        WHEN contact_count > 1 THEN 'duplicate_identity'
        ELSE 'single_identity'
    END AS crm_identity_type,
    COUNT(*) AS unique_humans,
    ROUND(AVG(converted) * 100, 1) AS conversion_rate_pct
FROM email_level
GROUP BY crm_identity_type;


-- Compare Exposure & Overlap by Identity Type
WITH email_level AS (
    SELECT
        email,
        COUNT(DISTINCT contact_id) AS contact_count,
        COUNT(DISTINCT campaign_id) AS campaign_exposure,
        MAX(total_touchpoints) AS max_touchpoints,
        MAX(has_sender_overlap) AS has_sender_overlap
    FROM analytical_master
    GROUP BY email
)

SELECT
    CASE 
        WHEN contact_count > 1 THEN 'duplicate_identity'
        ELSE 'single_identity'
    END AS crm_identity_type,
    COUNT(*) AS unique_humans,
    ROUND(AVG(campaign_exposure), 1) AS avg_campaign_exposure,
    ROUND(AVG(max_touchpoints), 1) AS avg_max_touchpoints,
    ROUND(AVG(has_sender_overlap) * 100, 1) AS sender_overlap_rate_pct
FROM email_level
GROUP BY crm_identity_type;


-- Sender Overlap Prevalence
SELECT
    COUNT(DISTINCT email) AS total_unique_humans,
    COUNT(DISTINCT CASE WHEN has_sender_overlap = 1 THEN email END) AS overlapped_humans,
    ROUND(
        COUNT(DISTINCT CASE WHEN has_sender_overlap = 1 THEN email END)
        / COUNT(DISTINCT email) * 100,
        1
    ) AS sender_overlap_rate_pct
FROM analytical_master;


-- Response Quality Analysis
WITH dedup_journeys AS (
    SELECT
        email,
        campaign_id,
        MAX(response_stage) AS response_stage,
        MAX(COALESCE(is_qualified, 0)) AS qualified,
        MAX(COALESCE(is_converted, 0)) AS converted
    FROM analytical_master
    WHERE response_stage IS NOT NULL
    GROUP BY email, campaign_id
)

SELECT
    response_stage,
    COUNT(*) AS total_journeys,
    ROUND(AVG(qualified) * 100, 1) AS qualification_rate_pct,
    ROUND(AVG(converted) * 100, 1) AS conversion_rate_pct
FROM dedup_journeys
GROUP BY response_stage
ORDER BY conversion_rate_pct DESC;
