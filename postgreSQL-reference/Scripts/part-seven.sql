begin;
create table twcache.daily_counters
(
day
 date not null primary key,
rts
 bigint,
de_rts bigint,
favs
 bigint,
de_favs bigint
);

create or replace function twcache.tg_update_daily_counters ()
returns trigger
language plpgsql
as $$
declare
begin
update twcache.daily_counters
set rts = case when NEW.action = 'rt'
then rts + 1
else rts
end,
de_rts = case when NEW.action = 'de-rt'
then de_rts + 1
else de_rts
end,
favs = case when NEW.action = 'fav'
then favs + 1
else favs
end,
de_favs = case when NEW.action = 'de-fav'
then de_favs + 1
else de_favs
end
where daily_counters.day = current_date;
if NOT FOUND
then
insert into twcache.daily_counters(day, rts, de_rts, favs, de_favs)
select current_date,
case when NEW.action = 'rt'
then 1 else 0
end,
case when NEW.action = 'de-rt'
then 1 else 0
end,
case when NEW.action = 'fav'
then 1 else 0
end,
case when NEW.action = 'de-fav'
then 1 else 0
end;
end if;
RETURNend;
$$;
NULL;
CREATE TRIGGER update_daily_counters
AFTER INSERT
ON tweet.activity
FOR EACH ROW
EXECUTE PROCEDURE twcache.tg_update_daily_counters();
insert into tweet.activity(messageid, action)
values (7, 'rt'),
(7, 'fav'),
(7, 'de-fav'),
(8, 'rt'),
(8, 'rt'),
(8, 'rt'),
(8, 'de-rt'),
(8, 'rt');

select day, rts, de_rts, favs, de_favs
from twcache.daily_counters;

begin;
create or replace function twcache.tg_notify_counters ()
returns trigger
language plpgsql
as $$
declare
channel text := TG_ARGV[0];
begin
PERFORM (
with payload(messageid, rts, favs) as
(
select NEW.messageid,
coalesce(
case NEW.action
when 'rt'
 then 1
when 'de-rt' then -1
end,
0
) as rts,
coalesce(
case NEW.action
when 'fav'
 then 1
when 'de-fav' then -1
end,
0
) as favs
)
select pg_notify(channel, row_to_json(payload)::text)
from payload
);
RETURN NULL;
end;
$$;
CREATE TRIGGER notify_counters
AFTER INSERT
ON tweet.activity
FOR EACH ROW
EXECUTE PROCEDURE twcache.tg_notify_counters('tweet.activity');
commit;


rollback;


--Row Constructor Comparison
SELECT (1,2,null) < (1,3,0);

select (1,2,0) >= (1,2,null);

select (1,3,0) >= (1,2,null);
select (1,2,0) >= (1,2,0);
select (1,null,0) >= (1,2,0);

select (1,3,null) = (1,2,0);
select (1,2,0) = (1,2,0);

select (1,null,0) <> (1,2,0);
select (1,2,null) <> (1,2,0);
select (1,3,null) <> (1,2,0);
select (1,2,0) <> (1,2,0);
select (null,2,0) <> (1,2,0);

