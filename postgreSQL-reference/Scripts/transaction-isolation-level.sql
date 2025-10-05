--REPEATABLE READ
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







