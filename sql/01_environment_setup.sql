-- ============================================================
-- File: 01_environment_setup.sql
-- Project: Outbound Funnel Intelligence
-- Stage: Environment Setup
-- Purpose: Standardize table names and validate source
--          table imports before data modeling begins.
-- Dependencies: None
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
SELECT 'email_activity_clean' AS table_name, COUNT(*) AS row_count
FROM email_activity_clean
UNION ALL
SELECT 'engagement_clean', COUNT(*)
FROM engagement_clean
UNION ALL
SELECT 'contacts_clean', COUNT(*)
FROM contacts_clean
UNION ALL
SELECT 'campaign_clean', COUNT(*)
FROM campaign_clean
UNION ALL
SELECT 'senders_clean', COUNT(*)
FROM senders_clean;
