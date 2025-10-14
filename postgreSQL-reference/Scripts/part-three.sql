
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

select genre.name, count(*) as count
from
 genre
left join track using(genre_id)
group by genre.name
order by count desc;

--Example of lateral join
-- name: genre-top-n
-- Get the N top tracks by genre
select genre.name as genre,
case when length(ss.name) > 15
then substring(ss.name from 1 for 15) || '⋯'
else ss.name
end as track,
artist.name as artist
from genre left join lateral
/*
* the lateral left join implements a nested loop over
* the genres and allows to fetch our Top-N tracks per
* genre, applying the order by desc limit n clause.
*
* here we choose to weight the tracks by how many
* times they appear in a playlist, so we join against
* the playlisttrack table and count appearances.
*/
(
select track.name, track.album_id, count(playlist_id)
from
 track
left join playlist_track using (track_id)
where track.genre_id = genre.genre_id
group by track.track_id
order by count desc
limit 3
)
/*
* the join happens in the subquery's where clause, so
* we don't need to add another one at the outer join
* level, hence the "on true" spelling.
*/
ss(name, album_id, count) on true
join album using(album_id)
join artist using(artist_id)
order by genre.name, ss.count desc;



select * from album;
select * from artist;
select * from track;
select * from genre;
select * from playlist_track;
