CREATE TABLE dummytags(id int not null unique, tag text);

alter table dummytags alter column unique_num set not null;

alter table dummytags add  unique(unique_num);

update dummytags d  set unique_num=v.num from (values (1,101),(2,102),(3,103),(5,105),(6,106),(7,107),(8,108),(10,110)) as v(id,num) where d.id=v.id;


create table dummytags_reference(id int not null unique, description text,tagId integer references dummytags(id) on delete cascade);

insert into dummytags_reference values(1,'a',1);

select * from dummytags_reference;

drop table dummytags;

select * from dummytags;

insert into dummytags values(1,'a'),(2,'b'),(3,'c'),(5,'e'),(6,'f'),(7,'g'),(8,'h');

--The target column names can be listed in any order. If no list of column names is given at all, the default is all the columns 
--of the table in their declared order; or the first N column names, if there are only N columns supplied by the VALUES clause or query. 
--The values supplied by the VALUES clause or query are associated with the explicit or implicit column list left-to-right.
insert into dummytags values(9);

drop table dummytags;

-- 1.) Postgres maintains order of update(TX1 and TX2)
--TX1
begin;
update dummytags set tag='dog' where id=3;
commit;

--TX2
begin;
update dummytags set tag='dog' where id=3;
--blocks(After TX1 commits then this block will open)
commit;

select * from dummytags_reference;
select * from dummytags;

begin;
insert into dummytags_reference values(4,'reference',8);
commit;

--LOCKS
--1.) For update locks
--	blocks insert  in referencing table due to foreign key
-- does not allow any update/delete in the locked table
-- exclusive lock
	begin;
	select * from dummytags for update;
	commit;

--2.) For no key update locks
	--	does not block insert in referencing table
	-- does not allow any update/delete in the locked table
	-- exclusive lock
	begin;
	select * from dummytags for no key update;
	commit;

--3.) For share locks
	--	does not block insert in referencing table
	-- does not allow any update/delete in the locked table but locks can be shared
	begin;
	select * from dummytags for share;
	commit;

	begin;
		update dummytags set metatags='hello' where id=5;
	end;
	
--4.) for key share
	--	does not block insert in referencing table
	-- allow non-key columns update in the locked rows and is a shared lock,but disallow row deletion even when non of the columns are unique in the locked rows
	-- does not allow deletion of locked row
	-- does not allow update of unique/primary column in the locked table
	begin;
select * from dummytags for key share;
	end;

--Testing for key share with non-keyed colum
	CREATE TABLE dummytags_non_unique(id int not null, tag text,metatags text);
insert into dummytags_non_unique values(1,'a'),(2,'b'),(3,'c'),(5,'e'),(6,'f'),(7,'g'),(8,'h');
	
	begin;
select * from dummytags_non_unique for key share;
	end;
	
--Allows updating non-unique column in key share row lock but disallaow deletion of the row in the locked rows even when non of the column are unique
		begin;
	delete from dummytags_non_unique where id=10;
	commit;


--transaction levels Reference 

--#REPEATABLE READ#
--1.) Normal corcurrent update
begin transaction isolation level repeatable read;
begin;
	select * from dummytags;
--in this mean time if some transaction update the same below row then repatable read throws "SQL Error [40001]: ERROR: could not serialize access due to concurrent 
--update", if reading or inserting a new row in this mean time, then repeatable read does not throw error
	update dummytags set tag='rhino' where id=1;
commit;


--2.) using row level locks
begin transaction isolation level repeatable read;
begin;
	select * from dummytags;
--in this mean time, if some transaction update id=3 then below queries will eventually throw 40001 error after pausing for some time, when that "some" transaction 
--commit then the pause aborts and below queries throw error
select * from dummytags where id=3 for update;
select * from dummytags where id=3 for no key update;

--in this mean time, if some transaction update id=3 then below queries will immediately throw 40001 error
update dummytags set tag='rhino' where id=1;
update dummytags set tag='moa moa' where id=6;

--test
select * from dummytags where id=1 and metatags='sahara';
commit;


#SERIALIZABLE#

--1.)Any update-update in unrelated row of same table when transaction is ongoing will cause a serialization error, read will not cause serialization error, 
--update  needs to happen. Error in insert-insert(error when read is performed in both sides) or update-insert(error when read is performed in 
--either one side) in same table.

--2.) Two table can have serialization error when update-update is done with read of both tables, when no read is done to either table, then update-update of 
--	cross table is possible without serialization error

--	ERROR:  could not serialize access due to read/write dependencies among transactions
--DETAIL:  Reason code: Canceled on identification as a pivot, during conflict out checking.
--HINT:  The transaction might succeed if retried.

	

	





