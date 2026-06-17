-- ============================================================
-- File: 02_schema_standardization.sql
-- Project: Outbound Funnel Intelligence
-- Stage: Data Quality Validation & Schema Standardization
-- Purpose: Validate source data quality, standardize schemas,
--          enforce data types, create primary keys, and
--          establish duplicate identity tracking.
-- Dependencies: 01_environment_setup.sql
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
