-- ============================================================
-- Stage 1: Environment Setup and Standardization.
-- ============================================================

-- Renaming Tables
USE outbound_funnel_analysis;
SHOW TABLES;
RENAME TABLE `campaign cleaned table`
TO campaign_clean;
RENAME TABLE `contacts cleaned table`
TO contacts_clean;
RENAME TABLE `email_activity clean table`
TO email_activity_clean;
RENAME TABLE `engagement cleaned table`
TO engagement_clean;
RENAME TABLE `senders cleaned table`
TO senders_clean;

-- Validate source table record counts after import
SELECT 'email_activity_clean' AS table_name, COUNT(*) AS row_count FROM email_activity_clean
UNION ALL
SELECT 'engagement_clean', COUNT(*) FROM engagement_clean
UNION ALL
SELECT 'contacts_clean', COUNT(*) FROM contacts_clean
UNION ALL
SELECT 'campaign_clean', COUNT(*) FROM campaign_clean
UNION ALL
SELECT 'senders_clean', COUNT(*) FROM senders_clean;


-- ============================================================
-- STAGE 2: Data Quality Validation & Schema Standardization
-- ============================================================


-- 1) Email Activity Table
DESCRIBE email_activity_clean;

-- Validate Source Columns Names 
ALTER TABLE email_activity_clean
CHANGE COLUMN `ï»¿event_id` event_id INT;

-- Validating nulls and Primary Key Uniqueness
SELECT
    SUM(CASE WHEN event_id IS NULL THEN 1 ELSE 0 END) AS null_event_id,
    SUM(CASE WHEN contact_id IS NULL THEN 1 ELSE 0 END) AS null_contact_id,
    SUM(CASE WHEN sender_id IS NULL THEN 1 ELSE 0 END) AS null_sender_id,
    SUM(CASE WHEN campaign_id IS NULL THEN 1 ELSE 0 END) AS null_campaign_id,
    SUM(CASE WHEN send_date IS NULL THEN 1 ELSE 0 END) AS null_send_date,
    SUM(CASE WHEN sequence_no IS NULL THEN 1 ELSE 0 END) AS null_sequence_no, 
    SUM(CASE WHEN actual_gap_days IS NULL THEN 1 ELSE 0 END) AS null_actual_gap_days, 
    SUM(CASE WHEN sequence_status IS NULL THEN 1 ELSE 0 END) AS null_sequence_status
FROM email_activity_clean;

SELECT 
    COUNT(DISTINCT event_id) AS unique_event_ids,
    COUNT(*) AS row_count
FROM email_activity_clean;

-- Standardize date format
SELECT 
    send_date,
    STR_TO_DATE(send_date, '%d-%m-%Y') AS converted_send_date
FROM email_activity_clean
LIMIT 10;

SELECT
    SUM(CASE 
        WHEN STR_TO_DATE(send_date, '%d-%m-%Y') IS NULL THEN 1 
        ELSE 0 
    END) AS failed_date_conversions
FROM email_activity_clean;

SET SQL_SAFE_UPDATES = 0;

UPDATE email_activity_clean
SET send_date = STR_TO_DATE(send_date, '%d-%m-%Y');

SELECT send_date
FROM email_activity_clean
LIMIT 5;

ALTER TABLE email_activity_clean
CHANGE COLUMN send_date send_date DATE;

-- Primary Key Creation
ALTER TABLE email_activity_clean
ADD PRIMARY KEY (event_id);

-- Standardize relationship key data types
SELECT
    MAX(LENGTH(campaign_id)) AS max_len,
    MIN(LENGTH(campaign_id)) AS min_len
FROM email_activity_clean;

SELECT
    MAX(LENGTH(sender_id)) AS max_len,
    MIN(LENGTH(sender_id)) AS min_len
FROM email_activity_clean;

ALTER TABLE email_activity_clean
MODIFY COLUMN campaign_id CHAR(4),
MODIFY COLUMN sender_id CHAR(4);

-- 2) Sender Table
DESCRIBE senders_clean;

-- --Standardize data types
ALTER TABLE senders_clean
CHANGE COLUMN `ï»¿Sender_id` Sender_id CHAR(4),
MODIFY COLUMN Sender_group VARCHAR(50),
MODIFY COLUMN Performance_tier VARCHAR(50);

-- Primary Key Creation
ALTER TABLE senders_clean
ADD PRIMARY KEY (Sender_id);

-- 3) Campaign Table
DESCRIBE campaign_clean;

-- Standardize date format
SELECT
    campaign_start_date,
    STR_TO_DATE(campaign_start_date, '%d-%m-%Y') AS converted_date
FROM campaign_clean
LIMIT 10;

SELECT
    COUNT(*) AS failed_date_conversions
FROM campaign_clean
WHERE campaign_start_date IS NOT NULL
  AND STR_TO_DATE(campaign_start_date, '%d-%m-%Y') IS NULL;
  
UPDATE campaign_clean
SET campaign_start_date = STR_TO_DATE(campaign_start_date, '%d-%m-%Y');

-- Standardize schema and data types
ALTER TABLE campaign_clean
CHANGE COLUMN `ï»¿campaign_id` campaign_id CHAR(4),
MODIFY COLUMN sender_id CHAR(4),
MODIFY COLUMN outreach_style VARCHAR(50),
MODIFY COLUMN execution_style VARCHAR(50),
MODIFY COLUMN campaign_start_date DATE;


-- Validating Nulls and Primary Key Uniqueness
SELECT
    SUM(CASE WHEN campaign_id IS NULL THEN 1 ELSE 0 END) AS null_campaign_id,
    SUM(CASE WHEN sender_id IS NULL THEN 1 ELSE 0 END) AS null_sender_id,
    SUM(CASE WHEN outreach_style IS NULL THEN 1 ELSE 0 END) AS null_outreach_style,
    SUM(CASE WHEN execution_style IS NULL THEN 1 ELSE 0 END) AS null_execution_style,
    SUM(CASE WHEN campaign_start_date IS NULL THEN 1 ELSE 0 END) AS null_campaign_start_date,
    SUM(CASE WHEN planned_sequence_count IS NULL THEN 1 ELSE 0 END) AS null_planned_sequence_count,
    SUM(CASE WHEN planned_gap_days IS NULL THEN 1 ELSE 0 END) AS null_planned_gap_days,
    SUM(CASE WHEN batch_size IS NULL THEN 1 ELSE 0 END) AS null_batch_size
FROM campaign_clean;

SELECT
    COUNT(DISTINCT campaign_id) AS uni_id,
    COUNT(*) AS all_rows
FROM campaign_clean;

-- Primary Key Creation
ALTER TABLE campaign_clean
ADD PRIMARY KEY (campaign_id);

-- Validate campaign-to-sender relationship
SELECT
    campaign_id,
    COUNT(DISTINCT sender_id) AS sender_count
FROM campaign_clean
GROUP BY campaign_id
HAVING COUNT(DISTINCT sender_id) > 1;

-- 4) Engagement Table
DESCRIBE engagement_clean;

-- Standardize date format
SELECT
    response_date,
    STR_TO_DATE(response_date, '%d-%m-%Y') AS converted_datee
FROM engagement_clean
LIMIT 10;

SELECT
    COUNT(*) AS failed_date_conversions
FROM engagement_clean
WHERE response_date IS NOT NULL
  AND STR_TO_DATE( response_date, '%d-%m-%Y') IS NULL;
  
  UPDATE engagement_clean
SET response_date = STR_TO_DATE(response_date, '%d-%m-%Y');

-- Validating Primary Key Uniqueness
SELECT COUNT(*) AS all_rows,
COUNT(distinct response_id) as uniq_id
FROM engagement_clean;

-- Primary Key Creation and Standardize data types
ALTER TABLE engagement_clean
ADD PRIMARY KEY (response_id),
MODIFY COLUMN campaign_id CHAR(4),
MODIFY COLUMN sender_id CHAR(4),
MODIFY COLUMN response_type VARCHAR(50),
MODIFY COLUMN response_stage VARCHAR(50),
MODIFY COLUMN response_text TEXT,
MODIFY COLUMN response_date DATE,
MODIFY COLUMN is_success TINYINT,
MODIFY COLUMN final_outcome VARCHAR(50),
MODIFY COLUMN drop_reason VARCHAR(50),
MODIFY COLUMN clean_response_type VARCHAR(50),
MODIFY COLUMN qualified_flag VARCHAR(10);

-- Validate contact-campaign response grain
SELECT
    contact_id,
    campaign_id,
    COUNT(*) AS row_count
FROM engagement_clean
GROUP BY contact_id, campaign_id
HAVING COUNT(*) > 1;

-- 5) Contact Table

-- Validate schema and source column names
DESCRIBE raw_contact;

-- Standardize schema and data types
ALTER TABLE raw_contact
CHANGE COLUMN ï»¿contact_id contact_id INT,
MODIFY COLUMN email VARCHAR(200),
MODIFY COLUMN company VARCHAR(150),
MODIFY COLUMN role VARCHAR(100),
MODIFY COLUMN seniority_score INT,
MODIFY COLUMN region VARCHAR(50),
MODIFY COLUMN company_size VARCHAR(50);

-- Validate null values
SELECT
    SUM(CASE WHEN contact_id IS NULL THEN 1 ELSE 0 END) AS null_contact_id,
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS null_email,
    SUM(CASE WHEN company IS NULL THEN 1 ELSE 0 END) AS null_company,
    SUM(CASE WHEN role IS NULL THEN 1 ELSE 0 END) AS null_role,
    SUM(CASE WHEN seniority_score IS NULL THEN 1 ELSE 0 END) AS null_seniority_score,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS null_region,
    SUM(CASE WHEN company_size IS NULL THEN 1 ELSE 0 END) AS null_company_size
FROM raw_contact;

-- Analyze duplicate email identities
SELECT email, 
COUNT(*) AS duplicate_count
FROM raw_contact
GROUP BY email
HAVING COUNT(*) > 1;

SELECT 
    MAX(duplicate_count) AS max_dup
FROM (
    SELECT 
        email,
        COUNT(*) AS duplicate_count
    FROM raw_contact
    GROUP BY email
) dup;

SELECT 
    MIN(duplicate_count) AS min_dup
FROM (
    SELECT 
        email,
        COUNT(*) AS duplicate_count
    FROM raw_contact
    GROUP BY email
) dup;

-- Create duplicate tracking fields
ALTER TABLE raw_contact
ADD COLUMN duplicate_email_flag TINYINT(1) DEFAULT 0,
ADD COLUMN email_duplicate_count INT DEFAULT 1;

-- Populate duplicate indicators
UPDATE raw_contact rc
JOIN (
    SELECT email, COUNT(*) AS email_count
    FROM raw_contact
    GROUP BY email
    HAVING COUNT(*) > 1
) dup ON rc.email = dup.email
SET rc.duplicate_email_flag = 1;

-- Validate duplicate identity prevalence
SELECT COUNT(*) AS total_contacts, 
SUM(duplicate_email_flag) AS flagged_duplicates, 
ROUND(SUM(duplicate_email_flag) / COUNT(*) * 100, 2) AS duplicate_pct
FROM raw_contact;

-- Populate duplicate occurrence counts
UPDATE raw_contact rc
JOIN (
    SELECT email, COUNT(*) AS email_count
    FROM raw_contact
    GROUP BY email
) dup ON rc.email = dup.email
SET rc.email_duplicate_count = dup.email_count;


-- Validate duplicate occurrence distribution
SELECT 
    email_duplicate_count,
    COUNT(*) AS contact_rows
FROM raw_contact
GROUP BY email_duplicate_count
ORDER BY email_duplicate_count;


-- Primary Key Uniqueness Validation
SELECT
    COUNT(DISTINCT contact_id) AS unique_id,
    COUNT(*) AS all_rows
FROM raw_contact;

-- Create primary key
ALTER TABLE raw_contact
ADD PRIMARY KEY (contact_id);


-- ============================================================
-- STAGE 3: RELATIONSHIP VALIDATION
-- ============================================================

-- Validate Email Activity to Sender relationship
SELECT ea.sender_id
FROM email_activity_clean AS ea
LEFT JOIN senders_clean AS s
    ON ea.sender_id = s.sender_id
WHERE s.sender_id IS NULL;


-- Validate Email Activity to Sender join cardinality
WITH row_count_check AS (
    SELECT 
        COUNT(*) AS before_join_count
    FROM email_activity_clean
),
joined_count_check AS (
    SELECT 
        COUNT(*) AS after_join_count
    FROM email_activity_clean AS ea
    LEFT JOIN senders_clean AS s
        ON ea.sender_id = s.sender_id
)
SELECT 
    before_join_count,
    after_join_count,
    after_join_count - before_join_count AS row_difference
FROM row_count_check, joined_count_check;

-- Validate Email Activity to Campaign relationship
SELECT ea.campaign_id
FROM email_activity_clean AS ea
LEFT JOIN campaign_clean AS ca
    ON ea.campaign_id = ca.campaign_id
WHERE ca.campaign_id IS NULL;

-- Validate Email Activity to Campaign join cardinality
WITH row_count_check AS (
    SELECT 
        COUNT(*) AS before_count
    FROM email_activity_clean
),

joined_count_check AS (
    SELECT 
        COUNT(*) AS after_count
    FROM email_activity_clean AS ea
    LEFT JOIN campaign_clean AS ca
        ON ea.campaign_id = ca.campaign_id
)

SELECT 
    before_count,
    after_count,
    after_count - before_count AS row_diff
FROM row_count_check, joined_count_check;


-- Validate Email Activity to Contact relationship
SELECT ea.contact_id 
FROM email_activity_clean AS ea 
LEFT JOIN raw_contact AS rc 
ON ea.contact_id = rc.contact_id 
WHERE rc.contact_id IS NULL; 

-- Validate Email Activity to Contact join cardinality
WITH row_count_check AS 
( SELECT COUNT(*) AS before_join_count 
FROM email_activity_clean ), 

joined_count_check AS 
( SELECT COUNT(*) AS after_join_count 
FROM email_activity_clean AS ea 
LEFT JOIN raw_contact AS rc 
ON ea.contact_id = rc.contact_id ) 

SELECT before_join_count,
after_join_count, 
after_join_count - before_join_count AS row_difference 
FROM row_count_check, joined_count_check;


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


