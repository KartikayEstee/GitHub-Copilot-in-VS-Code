SET NOCOUNT ON;

SELECT x.Line
FROM (
    -- Table and view headings
    SELECT s.name AS Sch, o.name AS Obj, 0 AS Part, 0 AS Ord,
           CAST('## ' + IIF(o.type = 'U', 'Table', 'View') + ': ' + s.name + '.' + o.name AS nvarchar(max)) AS Line
    FROM sys.objects o
    JOIN sys.schemas s ON s.schema_id = o.schema_id
    WHERE o.type IN ('U', 'V') AND o.is_ms_shipped = 0

    UNION ALL
    -- Markdown table header
    SELECT s.name, o.name, 1, 1, CAST(N'| Column | Type | Nullable | Notes |' AS nvarchar(max))
    FROM sys.objects o
    JOIN sys.schemas s ON s.schema_id = o.schema_id
    WHERE o.type IN ('U', 'V') AND o.is_ms_shipped = 0

    UNION ALL
    SELECT s.name, o.name, 1, 2, CAST(N'|---|---|---|---|' AS nvarchar(max))
    FROM sys.objects o
    JOIN sys.schemas s ON s.schema_id = o.schema_id
    WHERE o.type IN ('U', 'V') AND o.is_ms_shipped = 0

    UNION ALL
    -- Column rows
    SELECT s.name, o.name, 1, c.column_id + 10,
           CAST(
             '| ' + c.name + ' | ' + TYPE_NAME(c.user_type_id) +
             CASE
               WHEN TYPE_NAME(c.user_type_id) IN ('nvarchar', 'nchar')
                 THEN '(' + IIF(c.max_length = -1, 'max', CAST(c.max_length / 2 AS varchar(10))) + ')'
               WHEN TYPE_NAME(c.user_type_id) IN ('varchar', 'char', 'varbinary', 'binary')
                 THEN '(' + IIF(c.max_length = -1, 'max', CAST(c.max_length AS varchar(10))) + ')'
               WHEN TYPE_NAME(c.user_type_id) IN ('decimal', 'numeric')
                 THEN '(' + CAST(c.precision AS varchar(10)) + ',' + CAST(c.scale AS varchar(10)) + ')'
               ELSE ''
             END +
             ' | ' + IIF(c.is_nullable = 1, 'YES', 'NO') +
             ' | ' + LTRIM(
                       IIF(EXISTS (SELECT 1
                                   FROM sys.indexes i
                                   JOIN sys.index_columns ic
                                     ON ic.object_id = i.object_id AND ic.index_id = i.index_id
                                   WHERE i.object_id = c.object_id AND i.is_primary_key = 1
                                     AND ic.column_id = c.column_id), 'PK ', '')
                       + IIF(c.is_identity = 1, 'Identity', '')) +
             ' |' AS nvarchar(max))
    FROM sys.columns c
    JOIN sys.objects o ON o.object_id = c.object_id
    JOIN sys.schemas s ON s.schema_id = o.schema_id
    WHERE o.type IN ('U', 'V') AND o.is_ms_shipped = 0

    UNION ALL
    -- Foreign keys (table only)
    SELECT s.name, o.name, 2, fkc.constraint_column_id,
           CAST('- FK ' + fk.name + ': ' + pc.name + ' -> '
                + rs.name + '.' + ro.name + '.' + rc.name AS nvarchar(max))
    FROM sys.foreign_keys fk
    JOIN sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
    JOIN sys.objects o ON o.object_id = fk.parent_object_id
    JOIN sys.schemas s ON s.schema_id = o.schema_id
    JOIN sys.columns pc ON pc.object_id = fk.parent_object_id AND pc.column_id = fkc.parent_column_id
    JOIN sys.objects ro ON ro.object_id = fk.referenced_object_id
    JOIN sys.schemas rs ON rs.schema_id = ro.schema_id
    JOIN sys.columns rc ON rc.object_id = fk.referenced_object_id AND rc.column_id = fkc.referenced_column_id

    UNION ALL
    -- Stored procedures, functions, and view definitions: heading
    SELECT s.name, o.name, 3, 0,
           CAST('## ' + CASE o.type
                          WHEN 'P' THEN 'Stored procedure'
                          WHEN 'V' THEN 'View definition'
                          ELSE 'Function' END + ': ' + s.name + '.' + o.name AS nvarchar(max))
    FROM sys.objects o
    JOIN sys.schemas s ON s.schema_id = o.schema_id
    WHERE o.type IN ('P', 'FN', 'IF', 'TF', 'V') AND o.is_ms_shipped = 0

    UNION ALL
    SELECT s.name, o.name, 3, 1, CAST(N'```sql' AS nvarchar(max))
    FROM sys.objects o
    JOIN sys.schemas s ON s.schema_id = o.schema_id
    WHERE o.type IN ('P', 'FN', 'IF', 'TF', 'V') AND o.is_ms_shipped = 0

    UNION ALL
    -- Object definition
    SELECT s.name, o.name, 3, 2, CAST(m.definition AS nvarchar(max))
    FROM sys.objects o
    JOIN sys.schemas s ON s.schema_id = o.schema_id
    JOIN sys.sql_modules m ON m.object_id = o.object_id
    WHERE o.type IN ('P', 'FN', 'IF', 'TF', 'V') AND o.is_ms_shipped = 0

    UNION ALL
    SELECT s.name, o.name, 3, 3, CAST(N'```' AS nvarchar(max))
    FROM sys.objects o
    JOIN sys.schemas s ON s.schema_id = o.schema_id
    WHERE o.type IN ('P', 'FN', 'IF', 'TF', 'V') AND o.is_ms_shipped = 0
) x
ORDER BY x.Sch, x.Obj, x.Part, x.Ord;