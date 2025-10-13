
select album.title as album,
sum(milliseconds) * interval '1 ms' as duration
from album
join artist using(artist_id)
left join track using(album_id)
where artist.artist_id = 1
--group by and order by can use select alias
group by album
order by album;
--group by album.title
--having and where clause cannot use select alias
--having album.title <>'Let There Be Rock'
--order by album.title;

create or replace function get_all_albums
(
in artist_id bigint,
out album text,
out duration interval
)
returns setof record
language sql
as $$
select album.title as album,
sum(milliseconds) * interval '1 ms' as duration
from album
join artist using(artist_id)
left join track using(album_id)
--need to do either functionName.inVariable or postitional notation
where artist.artist_id = get_all_albums.artist_id
--where artist.artist_id = $1
--wrong here, postgres interprets artist_id as artist.artist_id from table artist
--where artist.artist_id = artist_id
group by album
order by album;
$$;

select * from get_all_albums(1);

explain(analyze) select *
from get_all_albums(
(select artist_id
from artist
where name = 'Red Hot Chili Peppers')
);

explain(analyze) select album, duration
from artist,
lateral get_all_albums(artist_id)
where artist.name = 'Red Hot Chili Peppers';

select * from album;
select * from artist;
select * from track;
