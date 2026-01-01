-- Staging Validation Queries for SchemaGuard AI
-- Run these queries in Athena to validate staging data

-- 1. Row Count Check
SELECT 
    COUNT(*) as total_rows,
    COUNT(DISTINCT id) as unique_ids,
    COUNT(*) - COUNT(DISTINCT id) as duplicate_count
FROM staging_table;

-- 2. Required Fields Null Check
SELECT 
    COUNT(*) as total_rows,
    COUNT(id) as id_count,
    COUNT(timestamp) as timestamp_count,
    COUNT(event_type) as event_type_count,
    COUNT(*) - COUNT(id) as missing_id,
    COUNT(*) - COUNT(timestamp) as missing_timestamp,
    COUNT(*) - COUNT(event_type) as missing_event_type
FROM staging_table;

-- 3. Data Type Validation
SELECT 
    event_type,
    COUNT(*) as count,
    MIN(timestamp) as min_timestamp,
    MAX(timestamp) as max_timestamp
FROM staging_table
GROUP BY event_type;

-- 4. Schema Consistency Check
DESCRIBE staging_table;

-- 5. Data Quality - Timestamp Range
SELECT 
    MIN(timestamp) as earliest_event,
    MAX(timestamp) as latest_event,
    MAX(timestamp) - MIN(timestamp) as time_range_ms,
    (MAX(timestamp) - MIN(timestamp)) / 1000 / 60 / 60 as time_range_hours
FROM staging_table;

-- 6. Event Type Distribution
SELECT 
    event_type,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as percentage
FROM staging_table
GROUP BY event_type
ORDER BY count DESC;

-- 7. User Activity Check
SELECT 
    user_id,
    COUNT(*) as event_count,
    COUNT(DISTINCT event_type) as unique_event_types
FROM staging_table
WHERE user_id IS NOT NULL
GROUP BY user_id
ORDER BY event_count DESC
LIMIT 10;

-- 8. Data Completeness
SELECT 
    COUNT(*) as total_rows,
    COUNT(id) as has_id,
    COUNT(timestamp) as has_timestamp,
    COUNT(event_type) as has_event_type,
    COUNT(user_id) as has_user_id,
    COUNT(data) as has_data,
    ROUND(COUNT(id) * 100.0 / COUNT(*), 2) as id_completeness_pct,
    ROUND(COUNT(user_id) * 100.0 / COUNT(*), 2) as user_id_completeness_pct
FROM staging_table;

-- 9. Anomaly Detection - Duplicate IDs
SELECT 
    id,
    COUNT(*) as occurrence_count
FROM staging_table
GROUP BY id
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC
LIMIT 10;

-- 10. Recent Data Check
SELECT 
    DATE(FROM_UNIXTIME(timestamp / 1000)) as event_date,
    COUNT(*) as event_count
FROM staging_table
GROUP BY DATE(FROM_UNIXTIME(timestamp / 1000))
ORDER BY event_date DESC
LIMIT 7;
