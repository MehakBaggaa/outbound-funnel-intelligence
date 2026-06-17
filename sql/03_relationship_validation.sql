-- ============================================================
-- File: 03_relationship_validation.sql
-- Project: Outbound Funnel Intelligence
-- Stage: Relationship Validation
-- Purpose: Validate referential integrity and join
--          cardinality across all key relationships
--          before analytical modeling.
-- Dependencies:
--     01_environment_setup.sql
--     02_schema_standardization.sql
-- ============================================================

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
