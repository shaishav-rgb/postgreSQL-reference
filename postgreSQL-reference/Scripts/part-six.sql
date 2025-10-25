create schema if not exists sandbox;

create table sandbox.category
(
id
 serial primary key,
name text not null
);

insert into sandbox.category(name)
values ('sport'),('news'),('box office'),('music');

create table sandbox.article
(
id
 bigserial primary key,
category
 integer references sandbox.category(id),
title
 text not null,
content
 text
);

create table sandbox.comment
(
id
 bigserial primary key,
article
 integer references sandbox.article(id),
content
 text
);

insert into sandbox.article(category, title, content)
select random(1, 4) as category,
initcap(sandbox.lorem(5)) as title,
sandbox.lorem(100) as content
from generate_series(1, 1000) as t(x);

insert into sandbox.comment(article, content)
select random(1, 1000) as article,
sandbox.lorem(150) as content
from generate_series(1, 50000) as t(x);

select article.id, category.name, title
from
 sandbox.article
 join sandbox.category
on category.id = article.category
limit 3;

select count(*),
avg(length(title))::int as avg_title_length,
avg(length(content))::int as avg_content_length
from sandbox.article;
select article.id, article.title, count(*)
from
 sandbox.article
join sandbox.comment
on article.id = comment.article
group by article.id
order by count desc
limit 5;

select category.name,
count(distinct article.id) as articles,
count(*) as comments
from
 sandbox.category
left join sandbox.article on article.category = category.id
left join sandbox.comment on comment.article = article.id
group by category.name
order by category.name;

select * from sandbox.category;


--get recent 3 posts from a category with 3 latest comments
select category.name as category,
article.pubdate,
title,
jsonb_pretty(comments) as comments
from sandbox.category
/*
* Classic implementation of a Top-N query
* to fetch 3 most articles per category
*/
left join lateral
(
select id,
title,
article.pubdate,
jsonb_agg(comment) as comments
from sandbox.article
/*
* Classic implementation of a Top-N query
* to fetch 3 most recent comments per article
*/
left join lateral
(
select comment.pubdate,
substring(comment.content from 1 for 25) || '⋯'
as content
from sandbox.comment
where comment.article = article.id
order by comment.pubdate desc
limit 3
)
as comment
on true
 -- required with a lateral join
where category = category.id
group by article.id
order by article.pubdate desc
limit 3
)
as article
on true -- required with a lateral join
order by category.name, article.pubdate desc;










