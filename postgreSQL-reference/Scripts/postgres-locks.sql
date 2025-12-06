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
--	blocks insert in foreign key remote table
-- does not allow any update/delete in the locked table
-- exclusive lock
	begin;
	select * from dummytags for update;
	commit;

--2.) For no key update locks
	--	does not block insert in foreign key remote table
	-- does not allow any update/delete in the locked table
	-- exclusive lock
	begin;
	select * from dummytags for no key update;
	commit;

--3.) For share locks
	--	does not block insert in foreign key remote table
	-- does not allow any update/delete in the locked table but locks can be shared
	begin;
	select * from dummytags for share;
	commit;

	begin;
		update dummytags set metatags='hello' where id=5;
	end;
	
--4.) for key share
	--	does not block insert in foreign key remote table
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
	
--Allows updating non-unique column in key share row lock but disallaow deletion of the row in the locked rows
		begin;
	delete from dummytags_non_unique where id=10;
	commit;

	





