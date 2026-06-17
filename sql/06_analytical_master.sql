-- ============================================================
-- File: 06_analytical_master.sql
-- Project: Outbound Funnel Intelligence
-- Stage: Analytical Master Creation
-- Purpose: Build the final analytical dataset by
--          combining validated source tables,
--          summary layers, and overlap indicators
--          into a single reporting-ready table.
-- Dependencies:
--     01_environment_setup.sql
--     02_schema_standardization.sql
--     03_relationship_validation.sql
--     04_summary_layers.sql
--     05_sender_overlap_modeling.sql
-- ============================================================

-- ============================================================
-- Stage 6 — Analytical Master Creation
-- ============================================================

-- Create Analytical Master Table
CREATE TABLE analytical_master AS
SELECT 
ea.event_id,
ea.contact_id,
ea.campaign_id,
ea.sender_id,
ea.send_date,
ea.sequence_no,
ea.actual_gap_days,
ea.sequence_status,

s.sender_group,

rc.email,
rc.company,
rc.role,
rc.seniority_score,
rc.region,
rc.company_size,
rc.duplicate_email_flag,
rc.email_duplicate_count,

ca.outreach_style,
ca.execution_style,
ca.campaign_start_date,
ca.planned_sequence_count,
ca.planned_gap_days,

ts.total_touchpoints,
ts.first_touch_date,
ts.last_touch_date,
ts.outreach_duration_days,
ts.avg_gap_days,
ts.max_sequence_reached,

sof.unique_sender_count,
sof.has_sender_overlap,

es.has_replied,
es.has_negative_response,
es.is_qualified,
es.is_converted,
es.first_response_date,
es.response_stage

FROM email_activity_clean ea

LEFT JOIN raw_contact rc
    ON ea.contact_id = rc.contact_id

LEFT JOIN senders_clean s
    ON ea.sender_id = s.sender_id

LEFT JOIN campaign_clean ca
    ON ea.campaign_id = ca.campaign_id

LEFT JOIN touchpoint_summary ts
    ON ea.contact_id = ts.contact_id
   AND ea.campaign_id = ts.campaign_id

LEFT JOIN sender_overlap_flags sof
    ON rc.email = sof.email

LEFT JOIN engagement_summary es
    ON ea.contact_id = es.contact_id
   AND ea.campaign_id = es.campaign_id;
   
 
--  Validate Analytical Master Row Preservation
SELECT 
    COUNT(*) AS master_rows,
    (SELECT COUNT(*) FROM email_activity_clean) AS source_rows,
    COUNT(*) - (SELECT COUNT(*) FROM email_activity_clean) AS inflation
FROM analytical_master;

-- Validate Analytical Master Data Coverage ( Null check)
SELECT
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS missing_contact_details,
    SUM(CASE WHEN sender_group IS NULL THEN 1 ELSE 0 END) AS missing_sender_details,
    SUM(CASE WHEN outreach_style IS NULL THEN 1 ELSE 0 END) AS missing_campaign_details,
    SUM(CASE WHEN total_touchpoints IS NULL THEN 1 ELSE 0 END) AS missing_touchpoint_summary,
    SUM(CASE WHEN has_sender_overlap IS NULL THEN 1 ELSE 0 END) AS missing_overlap_flags,
    SUM(CASE WHEN has_replied IS NULL THEN 1 ELSE 0 END) AS no_engagement_record
FROM analytical_master;

-- Validate Event Grain Preservation
SELECT 
    COUNT(DISTINCT event_id) AS unique_event_ids,
    COUNT(*) AS row_count
FROM analytical_master;

-- Validate Sender Overlap Population
SELECT 
    has_sender_overlap,
    COUNT(DISTINCT contact_id) AS contacts,
    COUNT(DISTINCT CONCAT(contact_id, '-', campaign_id)) AS journeys
FROM analytical_master
GROUP BY has_sender_overlap;
