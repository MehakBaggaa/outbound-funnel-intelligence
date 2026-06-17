-- ============================================================
-- File: 07_journey_validation.sql
-- Project: Outbound Funnel Intelligence
-- Stage: Journey Grain Validation
-- Purpose: Define and validate the journey-level
--          reporting grain used for KPI calculations.
--          Ensures one unique journey per
--          email + campaign combination.
-- Dependencies:
--     01_environment_setup.sql
--     02_schema_standardization.sql
--     03_relationship_validation.sql
--     04_summary_layers.sql
--     05_sender_overlap_modeling.sql
--     06_analytical_master.sql
-- ============================================================

-- ============================================================
-- Stage 7: Journey Grain Validation
-- ============================================================

-- -- Define Journey-Level Reporting Grain
WITH dedup_journeys AS (
    SELECT
        email,
        campaign_id,
        MAX(has_sender_overlap) AS has_sender_overlap,
        MAX(total_touchpoints) AS total_touchpoints,
        MAX(COALESCE(has_replied, 0)) AS has_replied,
        MAX(COALESCE(has_negative_response, 0)) AS negative,
        MAX(COALESCE(is_qualified, 0)) AS qualified,
        MAX(COALESCE(is_converted, 0)) AS converted,
        MAX(outreach_duration_days) AS duration_days,
        MAX(avg_gap_days) AS avg_gap,
        MAX(response_stage) AS response_stage,
        MAX(outreach_style) AS outreach_style,
        MAX(region) AS region,
        MAX(company_size) AS company_size,
        MAX(role) AS role
    FROM analytical_master
    GROUP BY email, campaign_id
)
SELECT *
FROM dedup_journeys;


-- Validate Journey Grain Uniqueness
WITH dedup_journeys AS (
    SELECT
        email,
        campaign_id,
        MAX(has_sender_overlap) AS has_sender_overlap,
        MAX(total_touchpoints) AS total_touchpoints,
        MAX(COALESCE(has_replied, 0)) AS has_replied,
        MAX(COALESCE(has_negative_response, 0)) AS negative,
        MAX(COALESCE(is_qualified, 0)) AS qualified,
        MAX(COALESCE(is_converted, 0)) AS converted,
        MAX(outreach_duration_days) AS duration_days,
        MAX(avg_gap_days) AS avg_gap,
        MAX(response_stage) AS response_stage,
        MAX(outreach_style) AS outreach_style,
        MAX(region) AS region,
        MAX(company_size) AS company_size,
        MAX(role) AS role
    FROM analytical_master
    GROUP BY email, campaign_id
)

SELECT
    email,
    campaign_id,
    COUNT(*) AS journey_count
FROM dedup_journeys
GROUP BY email, campaign_id
HAVING COUNT(*) > 1;
