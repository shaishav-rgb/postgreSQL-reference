CREATE TABLE dummytags(id int not null unique, tag text);

drop table dummytags;

select * from dummytags;

insert into dummytags values(1,'a'),(2,'b'),(3,'c'),(5,'e'),(6,'f'),(7,'g'),(8,'h');

--The target column names can be listed in any order. If no list of column names is given at all, the default is all the columns 
--of the table in their declared order; or the first N column names, if there are only N columns supplied by the VALUES clause or query. 
--The values supplied by the VALUES clause or query are associated with the explicit or implicit column list left-to-right.
insert into dummytags values(9);

drop table dummytags;

--Postgres maintains order of update
begin;
update dummytags set tag='dog' where id=3;
commit;

