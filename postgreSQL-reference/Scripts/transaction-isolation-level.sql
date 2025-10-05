--REPEATABLE READ(Case 1)
CREATE TABLE dummytags(id int, tag text);
--INSERT INTO tags
	--SESSION 1
BEGIN;
set transaction isolation level repeatable read;
select * from dummytags where tag='DA'; -- got data
	update dummytags set tag='da' where id=4;
COMMIT; -- first commit
	--SESSION 2
begin;
set transaction isolation level repeatable read;
select * from dummytags where tag='DA'; -- got data
update  dummytags set tag=lower(tag) || 'g' where tag='DA';
--ERROR:  could not serialize access due to concurrent update

--REPEATABLE READ(Case 1), this is the same behavior even in serializable isolation level because data is
--readonly IS SESSION 2, incase of data in another record is changed(say id 3) then serializable mode fails
--AND REPEATABLE READ passes. Seralizable mode fails even when doing 'select * from dummytags' after 
--SESSION 1 has commited
	insert into dummytags(id,tag) values(7,'jpt');
	--session 1
	set transaction isolation level repeatable read;
	delete from dummytags where id=7;
COMMIT;
	--session 2
	set transaction isolation level repeatable read;
count(*) from dummytags; --(NO info OF id 7 being deleted)
COMMIT;
--after commit we get that the id 7 is deleted in another concurrent transaction;

--serializable(In serializable transaction isolation level, it fails even when the data being updated 
--are different but it passes IN REPEATABLE READ level)
--	SESSION 1
begin transaction isolation level serializable;
update dummytags set tag='apple' where id=1;
COMMIT;

	--session 2
begin transaction isolation level serializable;
	update dummytags set tag='banana' where id=2;
commit;
--ERROR:  could not serialize access due to read/write dependencies among transactions
--DETAIL:  Reason code: Canceled on identification as a pivot, during commit attempt.
--HINT:  The transaction might succeed if retried.







