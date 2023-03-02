WITH CTE AS (
	SELECT *, ROW_NUMBER() OVER(PARTITION BY Col1 ORDER BY Col1) AS DuplicateCount
	FROM [dbo].[MyTable]
	)

--SELECT * FROM CTE

DELETE FROM CTE
WHERE DuplicateCount > 1;