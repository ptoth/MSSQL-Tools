USE [tempdb]

--DBCC DROPCLEANBUFFERS
/*
Clears the clean buffers.
This will flush cached indexes and data pages. 
You may want to run a CHECKPOINT command first, 
in order to flush everything to disk.
*/

CHECKPOINT;
GO
DBCC DROPCLEANBUFFERS;
GO

--DBCC FREEPROCCACHE
/* Clears the procedure cache, which may free up some space in tempdb, 
although at the expense of your cached execution plans, 
which will need to be rebuilt the next time. 
This means that ad-hoc queries and stored procedures will have 
to recompile the next time you run them. 

Although this happens automatically, you may notice a significant 
performance decrease the first few times you run your procedures.
*/

DBCC FREEPROCCACHE;
GO

--DBCC FREESYSTEMCACHE
/* 
This operation is similar to FREEPROCCACHE, 
except it affects other types of caches.
*/

DBCC FREESYSTEMCACHE ('ALL');
GO

--DBCC FREESESSIONCACHE
/* Flushes the distributed query connection cache. 
This has to do with distributed queries (queries between servers), 
but I’m really not sure how much space they actually take up in tempdb.
*/

DBCC FREESESSIONCACHE;
GO

--DBCC SHRINKFILE
/*
DBCC SHRINKFILE is the same tool used to shrink any database file, 
in tempdb or other databases. 
This is the step that actually frees the unallocated space from 
the database file.

Warning: Make sure you don’t have any open transactions when running 
DBCC SHRINKFILE. 
Open transactions may cause the DBCC operation to fail, 
and possibly corrupt your tempdb!
*/

DBCC SHRINKFILE (TEMPDEV, 4096);   --- New file size in MB
GO