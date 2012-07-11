DECLARE @TableName SYSNAME = ''
DECLARE @IncludeDisabled bit = 0

SELECT t.NAME AS TableName, i.NAME AS IndexName, cols.IndexColumns, cols.IncludedColumns, i.filter_definition AS Filter, i.is_disabled AS IsDisabled
FROM sys.indexes i
	JOIN sys.tables t ON i.object_id = t.object_id
	CROSS APPLY 
	(
		SELECT CAST(
			(SELECT CASE ic.index_column_id WHEN 1 THEN '' ELSE ',' END +  c.NAME + ' ' + CASE ic.is_descending_key WHEN 1 THEN 'DESC' ELSE 'ASC' END
			FROM sys.index_columns ic
				JOIN sys.columns c ON  ic.column_id = c.column_id AND ic.object_id = c.object_id				
			WHERE ic.index_id = i.index_id AND ic.object_id = i.object_id
				AND ic.is_included_column = 0
			ORDER BY ic.index_column_id
			FOR XML PATH('')
			) AS VARCHAR(MAX)) AS IndexColumns,
			CAST(
				(
				SELECT c.NAME + ','
				FROM sys.index_columns ic
					JOIN sys.columns c ON  ic.column_id = c.column_id AND ic.object_id = c.object_id				
				WHERE ic.index_id = i.index_id AND ic.object_id = i.object_id
					AND ic.is_included_column = 1
				ORDER BY ic.index_column_id
				FOR XML PATH('')
				)
			AS VARCHAR(MAX)) AS IncludedColumns
	) cols 
WHERE (@TableName = '' OR i.object_id = OBJECT_ID(@TableName))
	AND (i.is_disabled = 0 OR @IncludeDisabled = 1)	
ORDER BY t.NAME, cols.IndexColumns