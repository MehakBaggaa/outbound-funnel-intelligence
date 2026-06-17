-- ============================================================
-- File: 05_sender_overlap_modeling.sql
-- Project: Outbound Funnel Intelligence
-- Stage: Sender Overlap Modeling
-- Purpose: Measure multi-sender exposure at the
--          human identity level and create overlap
--          indicators for downstream analysis.
-- Dependencies:
--     01_environment_setup.sql
--     02_schema_standardization.sql
--     03_relationship_validation.sql
--     04_summary_layers.sql
-- ============================================================

-- ============================================================
-- STAGE 5: SENDER OVERLAP MODELING
-- ============================================================

-- Create Sender Overlap Flags Table
CREATE TABLE sender_overlap_flags AS
SELECT
    rc.email,
    COUNT(DISTINCT ea.sender_id) AS unique_sender_count,
    CASE
        WHEN COUNT(DISTINCT ea.sender_id) > 1 THEN 1
        ELSE 0
    END AS has_sender_overlap
FROM email_activity_clean ea
JOIN raw_contact rc
    ON ea.contact_id = rc.contact_id
GROUP BY rc.email;

-- Create Primary Key
ALTER TABLE sender_overlap_flags
ADD CONSTRAINT pk_sender_overlap_flags
PRIMARY KEY (email);

-- Validate Sender Overlap Table Grain
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT email) AS unique_emails
FROM sender_overlap_flags;
