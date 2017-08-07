/*
The calculated improvement_measure column provides the estimated improvement 
value of each index recommendation, based on the average total reduction 
in query cost that would result, the number of seek and scan operations 
that could be satisfied by the index, and the percentage benefit the index 
would provide to the queries being executed. 

This column makes it easier to focus on those indexers that offer the biggest cost benefit.
Focus on the indexes with an impact value higher than 50,000
*/

SELECT migs.avg_total_user_cost * ( migs.avg_user_impact / 100.0 ) * ( migs.user_seeks + migs.user_scans ) AS improvement_measure,
    mid.statement AS TableName,
    'CREATE INDEX [missing_index_' 
        + CONVERT (VARCHAR, mig.index_group_handle) + '_' 
        + CONVERT (VARCHAR, mid.index_handle) + '_' 
        + LEFT(PARSENAME(mid.statement, 1), 32) + ']' 
        + ' ON ' 
        + mid.statement  
        + ' (' 
        + ISNULL(mid.equality_columns, '') 
        + CASE 
            WHEN mid.equality_columns IS NOT NULL 
                AND mid.inequality_columns IS NOT NULL 
                THEN ',' 
                ELSE '' 
            END 
        + ISNULL(mid.inequality_columns, '') + ')' 
        + ISNULL(' INCLUDE (' 
        + mid.included_columns 
        + ')', '') AS create_index_statement, 
        migs.*,
        mid.database_id,
        mid.[object_id] 
FROM sys.dm_db_missing_index_groups mig 
    INNER JOIN sys.dm_db_missing_index_group_stats migs 
        ON migs.group_handle = mig.index_group_handle 
    INNER JOIN sys.dm_db_missing_index_details mid 
        ON mig.index_handle = mid.index_handle 
WHERE migs.avg_total_user_cost * ( migs.avg_user_impact / 100.0 ) * ( migs.user_seeks + migs.user_scans ) > 10
	AND (migs.avg_total_user_cost * ( migs.avg_user_impact / 100.0 ) * ( migs.user_seeks + migs.user_scans )) > 50000 
ORDER BY migs.avg_total_user_cost * migs.avg_user_impact * ( migs.user_seeks + migs.user_scans ) DESC