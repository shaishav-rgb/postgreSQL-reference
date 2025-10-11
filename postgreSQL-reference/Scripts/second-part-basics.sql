create table factbook
(
year
 int,
date
 date,
shares text,
trades text,
dollars text
);

select * from factbook order by year;

drop table if exists factbook;

truncate table factbook;

--nullif function
update factbook
set shares  = nullif(shares, ''),
    trades  = nullif(trades, ''),
    dollars = nullif(dollars, '')
where shares = '' or trades = '' or dollars = '';

--using case insteadof nullif function
update factbook
set shares  = case when shares  = '' then null else shares end,
    trades  = case when trades  = '' then null else trades end,
    dollars = case when dollars = '' then null else dollars end;


--changing type of a column from text to bigint
alter table factbook
alter trades
type bigint
using replace(trades, ',', '')::bigint,
alter dollars
type bigint
using substring(replace(dollars, ',', '') from 2)::numeric;

--type conversion using cast operator(::) and cast function
select date,
to_char(shares, '99G999G999G999') as shares,
to_char(trades, '99G999G999') as trades,
to_char(dollars, 'L99G999G999G999') as dollars
from factbook
where date >= '2017-02-01'::date
and date < cast('2017-02-01' as date) + interval '1 month'
order by date;

--type cast using type before the literal type
select date,
to_char(shares, '99G999G999G999') as shares,
to_char(trades, '99G999G999') as trades,
to_char(dollars, 'L99G999G999G999') as dollars
from factbook
where date >= date '2017-02-01'
and date < date '2017-02-01' + interval '1 month'
order by date;

--prepared statement
prepare foo1 as select date, shares, trades, dollars
from factbook
where date >= $1::date
and date < $1::date + interval '1 month'
order by date;

execute foo1('2010-02-01');

--using generate series function
select * from generate_series(date '2017-02-01',
date '2017-02-01' + interval '1 month'
- interval '1 day',
interval '1 day'
) as calendar(entry);

--with ordinality in function and table with column alias
select * from generate_series(date '2017-02-01',
date '2017-02-01' + interval '1 month'
- interval '1 day',
interval '1 day'
) with ordinality as calendar(entry,sn);

--using both cast function and cast operator(::)
--select cast(calendar.entry as date) as date,
select calendar.entry::date as date,
coalesce(shares, 0) as shares,
coalesce(trades, 0) as trades,
to_char(
coalesce(dollars, 0),
'L99G999G999G999'
) as dollars
from  /*
* Generate the target month's calendar then LEFT JOIN
* * each day against the factbook dataset, so as to have
* every day in the result set, whether or not we have a
* book entry for the day.
*/
generate_series(date '2017-02-01',
date '2017-02-01' + interval '1 month'
- interval '1 day',
interval '1 day'
)
as calendar(entry)
left join factbook
on factbook.date = calendar.entry
order by date;



--using CTE and window function
with computed_data as
(
select cast(date as date)
 as date,
to_char(date, 'Dy') as day,
coalesce(dollars, 0) as dollars,
lag(dollars, 1)
over(
partition by extract('isodow' from date)
order by date
)
as last_week_dollars
from /*
* Generate the month calendar, plus a week before
* so that we have values to compare dollars against
* even for the first week of the month.
*/
generate_series(date '2017-02-01' - interval '1 week',
date '2017-02-01' + interval '1 month'
- interval '1 day',
interval '1 day'
)
as calendar(date)
left join factbook using(date)
)
select date, day,
to_char(
coalesce(dollars, 0),
'L99G999G999G999'
) as dollars,
case when dollars is not null
and dollars <> 0
then round( 100.0 * (dollars - last_week_dollars)/ dollars, 2)
end
as "WoW %"
from computed_data
where date >= date '2017-02-01'
order by date;

--see the version of postgres
show server_version;


