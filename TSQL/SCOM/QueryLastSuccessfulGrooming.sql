-- Last successful grooming and running time
SELECT TOP 10
	InternalJobHistoryId,
	TimeStarted,
	TimeFinished,
	DATEDIFF(MINUTE, TimeStarted, TimeFinished) AS RunningTimeInMinutes,
	StatusCode,
	Command,
	Comment
FROM dbo.InternalJobHistory
WHERE StatusCode = 1 /* 1 = Success | 0 = Failure */
	AND Command LIKE 'Exec dbo.p_GroomPartitionedObjects and dbo.p_Grooming'
ORDER BY InternalJobHistoryId DESC
