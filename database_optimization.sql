-- Database Optimization Recommendations for Advisor Desk
-- This file contains SQL statements to optimize the database schema
-- Apply these optimizations to improve query performance

-- ================================================
-- INDEXES FOR PERFORMANCE OPTIMIZATION
-- ================================================

-- Index on daily_entries table for date-based queries
-- This will significantly speed up queries that filter by date
CREATE INDEX IF NOT EXISTS idx_daily_entries_date 
ON daily_entries(date);

-- Index on csat_entries table for date-based queries
CREATE INDEX IF NOT EXISTS idx_csat_entries_date 
ON csat_entries(date);

-- Index on cq_entries table for audit_date queries
CREATE INDEX IF NOT EXISTS idx_cq_entries_audit_date 
ON cq_entries(audit_date);

-- Index on leave_entries table (date is already PRIMARY KEY, so no index needed)

-- Composite index on monthly_data for month and year queries
CREATE INDEX IF NOT EXISTS idx_monthly_data_month_year 
ON monthly_data(month, year);

-- Index on chat_history for timestamp-based queries
CREATE INDEX IF NOT EXISTS idx_chat_history_timestamp 
ON chat_history(timestamp);

-- Index on chat_history for is_user flag (useful for filtering user vs AI messages)
CREATE INDEX IF NOT EXISTS idx_chat_history_is_user 
ON chat_history(is_user);

-- ================================================
-- QUERY OPTIMIZATION NOTES
-- ================================================

-- 1. Use LIMIT and OFFSET for pagination:
-- SELECT * FROM daily_entries ORDER BY date DESC LIMIT 20 OFFSET 0;

-- 2. Use specific columns instead of SELECT *:
-- SELECT id, date, call_count FROM daily_entries WHERE date >= ?;

-- 3. Use prepared statements to prevent SQL injection and improve performance

-- 4. Add WHERE clauses to limit the result set:
-- SELECT * FROM daily_entries WHERE date BETWEEN ? AND ?;

-- 5. Use COUNT(*) efficiently:
-- SELECT COUNT(*) FROM daily_entries WHERE date >= ?;

-- ================================================
-- VACUUM AND ANALYZE RECOMMENDATIONS
-- ================================================

-- Run VACUUM to reclaim storage and optimize database file
-- Should be run periodically (e.g., monthly)
-- VACUUM;

-- Run ANALYZE to update query planner statistics
-- Should be run after significant data changes
-- ANALYZE;

-- ================================================
-- ADDITIONAL OPTIMIZATION STRATEGIES
-- ================================================

-- 1. Batch INSERT operations instead of individual inserts
-- 2. Use transactions for multiple related operations
-- 3. Implement connection pooling if applicable
-- 4. Cache frequently accessed data in memory
-- 5. Use EXPLAIN QUERY PLAN to analyze slow queries
-- 6. Consider archiving old data (older than 1-2 years)
-- 7. Implement lazy loading for large datasets in UI

-- ================================================
-- MAINTENANCE QUERIES
-- ================================================

-- Check database size
-- SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size();

-- Check table sizes
-- SELECT name, (SELECT COUNT(*) FROM daily_entries) as row_count FROM sqlite_master WHERE type='table';

-- Find duplicate entries (example for daily_entries)
-- SELECT date, COUNT(*) as count FROM daily_entries GROUP BY date HAVING count > 1;

-- ================================================
-- IMPLEMENTATION NOTES
-- ================================================

-- These indexes should be created during database initialization
-- in the LocalDataSource.init() method or via a migration script.
-- 
-- Example in Dart:
-- await db.execute('CREATE INDEX IF NOT EXISTS idx_daily_entries_date ON daily_entries(date)');
--
-- Monitor the impact of indexes:
-- - Indexes speed up SELECT queries but slow down INSERT/UPDATE/DELETE
-- - For this app with more reads than writes, indexes are beneficial
-- - The daily_entries, csat_entries, and cq_entries tables are frequently queried by date
--
-- Performance expectations:
-- - Without index: O(n) linear scan
-- - With index: O(log n) binary search
-- - For 1000 entries: ~1000x faster with index for date queries
