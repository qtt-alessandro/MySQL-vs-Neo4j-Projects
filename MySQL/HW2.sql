#1.Most popular song by Billie Eilish
#----------------------------------------------------------------------------------------
select name, year
from spotify.songs
where artists =  'Billie Eilish' and popularity = (select max(popularity) 
													   from spotify.songs
													   where artists = 'Billie Eilish');
                                                       
                                                      
#IMPROVED VERSION: added new table based only on Billie Eilish

create table spotify.billie_songs 
as (select name, popularity, year from spotify.songs where artists = 'Billie Eilish' );

select name, year 
from spotify.billie_songs
where popularity =  (select max(popularity) from spotify.billie_songs);

Drop table spotify.billie_songs;
#----------------------------------------------------------------------------------------


#2.Popularity of the Artist with the most popular song of the most popular year 
#----------------------------------------------------------------------------------------
select artists_a, popularity_a
from spotify.artist
where artists_a = (select artists
					from spotify.songs
					where popularity = (select max(m.popularity)
										from spotify.songs m
										where m.year in (select y.year_y
														from spotify.year y
														where y.popularity_y = (select max(popularity_y) from spotify.year)))
							and year = (select y.year_y
										from spotify.year y
										where y.popularity_y = (select max(popularity_y) from spotify.year)));
                 
#IMPROVED VERSION: no nested queries, added indexes, with statement and joins

ALTER TABLE spotify.year ADD INDEX year_id_ (year_y);
ALTER TABLE spotify.artist ADD INDEX artist_id_ (index_a);
ALTER TABLE spotify.songs ADD INDEX songs_id_ (song_id);

WITH x AS( SELECT year_y AS max_pop_year
    FROM spotify.year
    WHERE popularity_y = (select max(popularity_y) from spotify.year))

SELECT artists, popularity_a
FROM   spotify.songs s
JOIN x ON s.year= x.max_pop_year
JOIN spotify.artist a ON s.artists = a.artists_a
WHERE popularity > 55
ORDER by popularity DESC
limit 1;

DROP INDEX year_id_ ON spotify.year;
DROP INDEX artist_id_ ON spotify.artist;
DROP INDEX songs_id_ ON spotify.songs;
#----------------------------------------------------------------------------------------
	
#3 New Ranking Score
#----------------------------------------------------------------------------------------
select name,artists, popularity*(energy/(select max(energy) from spotify.songs) + 
						liveness/(select max(liveness) from spotify.songs) + 
                        tempo/(select max(tempo) from spotify.songs)+
                        speechiness/(select max(speechiness) from spotify.songs)) as score, energy, liveness, tempo,speechiness
from spotify.songs
order by score desc
limit 10;

#IMPROVED VERSION: added indexes and with statement

ALTER TABLE spotify.songs ADD INDEX songs_id_ (song_id);

with max_values as (select max(energy) as e, max(liveness) as l, max(tempo) as t, max(speechiness) as s
					from spotify.songs)

select name, artists, popularity*(energy/max_values.e + liveness/max_values.l + tempo/max_values.t + speechiness/max_values.s) as score,
		energy, liveness, tempo, speechiness
from spotify.songs, max_values
order by score desc
limit 10;

DROP INDEX songs_id_ ON spotify.songs;
#----------------------------------------------------------------------------------------

#4.Most Popular Artist within certain parameters
#----------------------------------------------------------------------------------------
select distinct a.artists_a, a.popularity_a
from spotify.artist a
where a.artists_a in (select artists as arts from spotify.songs
						where instrumentalness = 0 and loudness between -40 and 0 and
							energy > 0.6 and speechiness < 0.2 and tempo > 100)
order by popularity_a desc
limit 10;

#IMPROVED VERSION: added new table, indexes and joins

alter table spotify.artist add index artist_id_ (index_a);

create table spotify.y (select artists as arts, song_id from spotify.songs
                    where instrumentalness = 0 and loudness > -40 and loudness < 0 and
							energy > 0.6 and speechiness < 0.2 and tempo > 100);
                            
alter table spotify.y add index y_id_ (song_id);

select distinct a.artists_a, a.popularity_a
from spotify.artist a
join spotify.y on y.arts = a.artists_a
where popularity_a > 70
order by popularity_a desc
limit 10;

drop index artist_id_ ON spotify.artist;
drop table spotify.y;
#----------------------------------------------------------------------------------------




