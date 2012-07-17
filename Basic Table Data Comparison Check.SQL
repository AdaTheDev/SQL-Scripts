DECLARE @Table1 sysname = '' -- Name of the 1st table containing data to compare. This is used a source/original table to compare against.
DECLARE @Table2 sysname = '' -- Name of the 2nd table containing data to compare. It is assumed both tables have the same structure.
DECLARE @IgnoreColumns TABLE (ColumnName sysname) -- Populate with the names of any columns to NOT be included in the comparison

DECLARE @SQL NVARCHAR(MAX)
SELECT @SQL = ISNULL(@SQL + ' AND ', '') + ' (t1.' + QUOTENAME(c.NAME) + ' = t2.' + QUOTENAME(c.NAME) + ' OR (t1.' + QUOTENAME(c.NAME) + ' IS NULL AND t2.' + QUOTENAME(c.NAME) + ' IS NULL))' + CHAR(13) + CHAR(10)
FROM sys.columns c
WHERE c.object_id = OBJECT_ID(@Table1)
	AND NOT EXISTS(SELECT * FROM @IgnoreColumns i WHERE i.ColumnName = c.name)
ORDER BY c.column_id

SELECT @SQL = 
'SELECT (SELECT COUNT(*) FROM ' + QUOTENAME(@Table1) + ') AS ' + QUOTENAME(@Table1 + ' RowCount') + ',
	(SELECT COUNT(*) FROM ' + QUOTENAME(@Table2) + ') AS ' + QUOTENAME(@Table2 + ' RowCount') + ', 
	COUNT(*) AS [MatchedCount]
FROM ' + QUOTENAME(@Table1) + ' t1 
	INNER JOIN ' + QUOTENAME(@Table2) + ' t2 ON ' + @SQL
		
PRINT @SQL