insert into directors (director_name)
select distinct trim(director)
from raw_data
where director is not null and trim(director) <> '';

-- 2. фильмы
-- distinct on убирает дубликат «drishyam»
-- trim — пробелы, cast/regexp — типы, where — пустые ключи
insert into movies (
title, release_year, certificate, runtime_min, genre,
imdb_rating, overview, meta_score, director_id, votes, gross
)
select distinct on (trim(r.series_title))
trim(r.series_title) as title,
cast(trim(r.released_year) as int) as release_year,
nullif(trim(r.certificate), '') as certificate,
cast(regexp_replace(trim(r.runtime), '[^0-9]', '', 'g') as int) as runtime_min,
trim(r.genre) as genre,
cast(trim(r.imdb_rating) as numeric(3,1)) as imdb_rating,
trim(r.overview) as overview,
case when trim(r.meta_score) ~ '^[0-9]+$'
then cast(trim(r.meta_score) as int)
else null end as meta_score,
d.director_id,
cast(trim(r.no_of_votes) as int) as votes,
case when trim(replace(r.gross, ',', '')) ~ '^[0-9]+$'
then cast(trim(replace(r.gross, ',', '')) as numeric(15,0))
else null end as gross
from raw_data r
join directors d on d.director_name = trim(r.director)
where r.series_title is not null
and trim(r.series_title) <> ''
and r.released_year is not null
and trim(r.released_year) ~ '^[0-9]{4}$'
and r.imdb_rating is not null
and trim(r.imdb_rating) <> ''
order by trim(r.series_title), cast(trim(r.released_year) as int) desc;

-- 3. актёры (разворачиваем star1–star4)
insert into movie_cast (movie_id, star_name, star_order)
select m.movie_id, trim(r.star1), 1
from raw_data r
join movies m on m.title = trim(r.series_title)
where r.star1 is not null and trim(r.star1) <> ''
union all
select m.movie_id, trim(r.star2), 2
from raw_data r
join movies m on m.title = trim(r.series_title)
where r.star2 is not null and trim(r.star2) <> ''
union all
select m.movie_id, trim(r.star3), 3
from raw_data r
join movies m on m.title = trim(r.series_title)
where r.star3 is not null and trim(r.star3) <> ''
union all
select m.movie_id, trim(r.star4), 4
from raw_data r
join movies m on m.title = trim(r.series_title)
where r.star4 is not null and trim(r.star4) <> '';
