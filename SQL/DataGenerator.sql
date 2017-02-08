DECLARE @loopIndex INT

SET @loopIndex = 1;

WHILE @loopIndex < 1000000
  BEGIN
      INSERT INTO [dbo].[datapump]
                  ([number])
      VALUES      (@loopIndex);

      SET @loopIndex = @loopIndex + 1
  END 