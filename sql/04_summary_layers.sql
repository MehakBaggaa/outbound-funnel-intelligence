-- ============================================================
-- File: 04_summary_layers.sql
-- Project: Outbound Funnel Intelligence
-- Stage: Summary Layer Creation
-- Purpose: Create engagement and touchpoint summary
--          tables to resolve grain differences and
--          prepare data for analytical modeling.
-- Dependencies:
--     01_environment_setup.sql
--     02_schema_standardization.sql
--     03_relationship_validation.sql
-- ============================================================

-- ============================================================
-- STAGE 4: SUMMARY LAYER CREATION
-- ============================================================

-- Analyze engagement table grain
SELECT 
    contact_id,
    campaign_id,
    COUNT(*) AS engagement_count
FROM engagement_clean
GROUP BY contact_id, campaign_id;

SELECT contact_id, campaign_id, COUNT(*) AS response_count
FROM engagement_clean
GROUP BY contact_id, campaign_id
ORDER BY response_count DESC
LIMIT 20;

SELECT 
    contact_id,
    campaign_id,
    COUNT(*) AS engagement_count
FROM engagement_clean
GROUP BY contact_id, campaign_id
HAVING COUNT(*) > 1;

-- Create engagement summary table
CREATE TABLE engagement_summary AS
SELECT
    contact_id,
    campaign_id,

    MAX(CASE 
        WHEN clean_response_type IN ('positive', 'neutral', 'negative') THEN 1 
        ELSE 0 
    END) AS has_replied,

    MAX(CASE 
        WHEN clean_response_type = 'negative' THEN 1 
        ELSE 0 
    END) AS has_negative_response,

    MAX(CASE 
        WHEN qualified_flag = 'yes' THEN 1 
        ELSE 0 
    END) AS is_qualified,

    MAX(CASE 
        WHEN final_outcome = 'converted' THEN 1 
        ELSE 0 
    END) AS is_converted,

    MIN(response_date) AS first_response_date,
    MIN(response_stage) AS response_stage
FROM engagement_clean
GROUP BY contact_id, campaign_id;

-- Enforce summary table grain
ALTER TABLE engagement_summary
ADD CONSTRAINT pk_engagement_summary
PRIMARY KEY (contact_id, campaign_id);

-- Validate summary table uniqueness
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT CONCAT(contact_id, '-', campaign_id)) AS unique_journeys
FROM engagement_summary;
-- Both numbers must be equal


-- Create touchpoint summary table
CREATE TABLE touchpoint_summary AS
SELECT
    contact_id,
    campaign_id,
    COUNT(event_id) AS total_touchpoints,
    MIN(send_date) AS first_touch_date,
    MAX(send_date) AS last_touch_date,
    DATEDIFF(MAX(send_date), MIN(send_date)) AS outreach_duration_days,
    AVG(actual_gap_days) AS avg_gap_days,
    MAX(sequence_no) AS max_sequence_reached
FROM email_activity_clean
GROUP BY contact_id, campaign_id;


-- Review summary table structure
SHOW WARNINGS;
DESCRIBE touchpoint_summary;

-- Validate summary table uniqueness
SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT CONCAT(contact_id, '-', campaign_id)) AS unique_journeys
FROM touchpoint_summary;
-- Both numbers must be equal


-- Enforce summary table grain
ALTER TABLE touchpoint_summary
ADD CONSTRAINT pk_touchpoint_summary
PRIMARY KEY (contact_id, campaign_id);
