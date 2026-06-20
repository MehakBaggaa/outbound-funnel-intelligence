# Data Dictionary

This document describes the source tables, analytical summary tables, and final reporting tables used in the Outbound Funnel Intelligence project.

---

## Senders Table

**Purpose:**
Stores information about outreach senders and their segmentation used across outbound campaigns.

| Column Name      | Description                                                   |
| ---------------- | ------------------------------------------------------------- |
| sender_id        | Unique identifier for each sender. Serves as the primary key. |
| sender_group     | Categorizes senders into outreach strategy groups.            |
| performance_tier | Performance classification of the sender (High, Medium, Low). |

---

## Campaign Table

**Purpose:**
Stores campaign-level information including ownership, outreach strategy, execution approach, and campaign planning details.

| Column Name            | Description                                                     |
| ---------------------- | --------------------------------------------------------------- |
| campaign_id            | Unique identifier for each campaign. Serves as the primary key. |
| sender_id              | Identifies the sender who owns the campaign.                    |
| outreach_style         | Outreach strategy used in the campaign.                         |
| execution_style        | Indicates whether execution is manual or automated.             |
| campaign_start_date    | Campaign launch date.                                           |
| planned_sequence_count | Planned number of outreach touchpoints.                         |
| planned_gap_days       | Planned days between touchpoints.                               |
| batch_size             | Number of prospects included in the campaign.                   |

---

## Contacts Table

**Purpose:**
Stores prospect-level and company-level information used for audience segmentation and outreach analysis.

| Column Name     | Description                                                    |
| --------------- | -------------------------------------------------------------- |
| contact_id      | Unique identifier for each contact. Serves as the primary key. |
| email           | Prospect email address.                                        |
| company         | Company associated with the prospect.                          |
| role            | Job title or role of the prospect.                             |
| seniority_score | Score representing decision-making seniority.                  |
| region          | Geographic classification of the prospect.                     |
| company_size    | Company size category based on employee count range.           |
| duplicate_email_flag | Indicates whether the email appears multiple times in CRM records. |
| email_duplicate_count | Number of CRM records associated with the same email. |

---

## Email Activity Table

**Purpose:**
Stores outreach activity at the event level and tracks every touchpoint sent to a prospect during a campaign.

| Column Name     | Description                                                           |
| --------------- | --------------------------------------------------------------------- |
| event_id        | Unique identifier for each outreach event. Serves as the primary key. |
| contact_id      | Identifies the prospect who received the outreach.                    |
| campaign_id     | Identifies the campaign associated with the outreach activity.        |
| sender_id       | Identifies the sender who performed the outreach.                     |
| send_date       | Date on which the outreach touchpoint was sent.                       |
| sequence_no     | Sequence number of the outreach touchpoint.                           |
| actual_gap_days | Actual number of days between outreach touchpoints.                   |
| sequence_status | Status of the outreach touchpoint.                                    |

---

## Engagement Table

**Purpose:**
Stores prospect responses, engagement outcomes, qualification status, and conversion results generated from outreach activities.

| Column Name         | Description                                                            |
| ------------------- | ---------------------------------------------------------------------- |
| response_id         | Unique identifier for each response record. Serves as the primary key. |
| contact_id          | Identifies the prospect who submitted the response.                    |
| campaign_id         | Identifies the campaign associated with the response.                  |
| sender_id           | Identifies the sender responsible for the outreach.                    |
| response_type       | Original response classification.                                      |
| response_stage      | Detailed response category.                                            |
| response_text       | Text content of the response.                                          |
| response_date       | Date on which the response was received.                               |
| is_success          | Indicates whether the engagement resulted in a successful outcome.     |
| final_outcome       | Final status of the engagement.                                        |
| drop_reason         | Reason for opportunity loss when dropped.                              |
| clean_response_type | Standardized response classification used for analysis.                |
| qualified_flag      | Qualification indicator used for KPI reporting.                        |

---

## Engagement Summary Table

**Purpose:**
Stores journey-level engagement outcomes for each Contact + Campaign combination.

| Column Name           | Description                                         |
| --------------------- | --------------------------------------------------- |
| contact_id            | Prospect identifier.                                |
| campaign_id           | Campaign identifier.                                |
| has_replied           | Indicates whether a response was received.          |
| has_negative_response | Indicates whether a negative response was received. |
| is_qualified          | Indicates whether the journey became qualified.     |
| is_converted          | Indicates whether the journey converted.            |
| first_response_date   | First recorded response date.                       |
| response_stage        | Earliest recorded response stage.                   |

---

## Touchpoint Summary Table

**Purpose:**
Stores journey-level outreach activity metrics.

| Column Name            | Description                      |
| ---------------------- | -------------------------------- |
| contact_id             | Prospect identifier.             |
| campaign_id            | Campaign identifier.             |
| total_touchpoints      | Total outreach touchpoints sent. |
| first_touch_date       | First outreach date.             |
| last_touch_date        | Last outreach date.              |
| outreach_duration_days | Total outreach duration.         |
| avg_gap_days           | Average gap between touchpoints. |
| max_sequence_reached   | Highest sequence step reached.   |

---

## Sender Overlap Flags Table

**Purpose:**
Identifies whether a prospect was contacted by multiple senders.

| Column Name         | Description                                                     |
| ------------------- | --------------------------------------------------------------- |
| email               | Prospect email used as the identity key.                        |
| unique_sender_count | Number of distinct senders contacting the prospect.             |
| has_sender_overlap  | Indicates whether multiple senders contacted the same prospect. |

---

## Analytical Master Table

**Purpose:**
Central reporting table created by combining outreach activity, campaign information, contact details, engagement outcomes, touchpoint metrics, and sender overlap indicators. This table serves as the primary source for KPI calculation and Power BI dashboard development.

### Outreach Activity Fields

| Column Name     | Description                                                    |
| --------------- | -------------------------------------------------------------- |
| event_id        | Unique identifier for each outreach event.                     |
| contact_id      | Identifies the prospect associated with the outreach activity. |
| campaign_id     | Identifies the campaign associated with the outreach activity. |
| sender_id       | Identifies the sender who performed the outreach.              |
| send_date       | Date on which the outreach touchpoint was sent.                |
| sequence_no     | Sequence number of the outreach touchpoint.                    |
| actual_gap_days | Actual number of days between outreach touchpoints.            |
| sequence_status | Status of the outreach touchpoint.                             |

### Contact & Company Fields

| Column Name           | Description                                                        |
| --------------------- | ------------------------------------------------------------------ |
| email                 | Prospect email address used as the human identity key.             |
| company               | Company associated with the prospect.                              |
| role                  | Job title or functional role of the prospect.                      |
| seniority_score       | Score representing decision-making seniority.                      |
| region                | Geographic classification of the prospect.                         |
| company_size          | Company size category based on employee count range.               |
| duplicate_email_flag  | Indicates whether the email appears multiple times in CRM records. |
| email_duplicate_count | Number of CRM records associated with the same email.              |

### Campaign Fields

| Column Name            | Description                                         |
| ---------------------- | --------------------------------------------------- |
| sender_group           | Outreach strategy group assigned to the sender.     |
| outreach_style         | Outreach strategy used within the campaign.         |
| execution_style        | Indicates whether outreach was manual or automated. |
| campaign_start_date    | Date on which the campaign was launched.            |
| planned_sequence_count | Planned number of outreach touchpoints.             |
| planned_gap_days       | Planned number of days between touchpoints.         |

### Journey Metrics

| Column Name            | Description                                          |
| ---------------------- | ---------------------------------------------------- |
| total_touchpoints      | Total number of touchpoints sent during the journey. |
| first_touch_date       | Date of the first outreach touchpoint.               |
| last_touch_date        | Date of the last outreach touchpoint.                |
| outreach_duration_days | Total duration of the outreach journey.              |
| avg_gap_days           | Average number of days between touchpoints.          |
| max_sequence_reached   | Highest outreach sequence reached.                   |

### Sender Overlap Metrics

| Column Name         | Description                                                     |
| ------------------- | --------------------------------------------------------------- |
| unique_sender_count | Number of distinct senders contacting the prospect.             |
| has_sender_overlap  | Indicates whether multiple senders contacted the same prospect. |

### Engagement Metrics

| Column Name           | Description                                                        |
| --------------------- | ------------------------------------------------------------------ |
| has_replied           | Indicates whether the prospect responded.                          |
| has_negative_response | Indicates whether a negative response was received.                |
| is_qualified          | Indicates whether the journey resulted in a qualified opportunity. |
| is_converted          | Indicates whether the journey resulted in a conversion.            |
| first_response_date   | Date of the first recorded response.                               |
| response_stage        | Earliest recorded response stage for the journey.                  |

