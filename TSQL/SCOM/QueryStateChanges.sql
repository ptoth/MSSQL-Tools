DECLARE @Err int
DECLARE @Ret int
DECLARE @DaysToKeep tinyint
DECLARE @GroomingThresholdLocal datetime
DECLARE @GroomingThresholdUTC datetime
DECLARE @TimeGroomingRan datetime
DECLARE @MaxTimeGroomed datetime
DECLARE @RowCount int
SET @TimeGroomingRan = getutcdate()

SELECT @GroomingThresholdLocal = dbo.fn_GroomingThreshold(DaysToKeep, getdate())
	FROM dbo.PartitionAndGroomingSettings
WHERE ObjectName = 'StateChangeEvent'

EXEC dbo.p_ConvertLocalTimeToUTC @GroomingThresholdLocal, @GroomingThresholdUTC OUT
SET @Err = @@ERROR

SELECT COUNT (*) SCE
FROM dbo.StateChangeEvent SCE
    JOIN dbo.State S WITH(NOLOCK)
        ON SCE.[StateId] = S.[StateId]
    WHERE TimeGenerated < @GroomingThresholdUTC
    AND S.[HealthState] in (0,1,2,3) 
