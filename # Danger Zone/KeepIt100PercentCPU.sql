CREATE OR ALTER PROCEDURE dbo._keep_it_100
AS
BEGIN

  WITH
    e1(n)
    AS
    ( SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
      UNION ALL
        SELECT NULL
    ),
    e2(n)
    AS
    (
      SELECT TOP 2147483647
        NEWID()
      FROM e1 a, e1 b, e1 c, e1 d, e1 e, e1 f, e1 g, e1 h, e1 i, e1 j
    )
  SELECT MAX(ca.n)
  FROM e2

CROSS APPLY
(
    SELECT TOP 2147483647 *
    FROM (
      SELECT TOP 2147483647 *
        FROM e2
      UNION ALL
        SELECT *
        FROM e2
      UNION ALL
        SELECT *
        FROM e2
      UNION ALL
        SELECT *
        FROM e2
      UNION ALL
        SELECT *
        FROM e2
      UNION ALL
        SELECT *
        FROM e2
      UNION ALL
        SELECT *
        FROM e2
      UNION ALL
        SELECT *
        FROM e2
      UNION ALL
        SELECT *
        FROM e2
      UNION ALL
        SELECT *
        FROM e2
      UNION ALL
        SELECT *
        FROM e2
      UNION ALL
        SELECT *
        FROM e2
         ) AS x
    WHERE x.n = e2.n
    ORDER BY x.n
) AS ca
  OPTION(MAXDOP 0, LOOP JOIN, QUERYTRACEON 8649);

END;