##1 Top 10 Songs
#----------------------------------------------------------------------------------------
select name as Song_Name, artists as Artist, popularity as Song_Popularity
from spotify.songs
order by popularity desc
limit 10;
#----------------------------------------------------------------------------------------


##2 Longest and shortest Song in Minutes
#----------------------------------------------------------------------------------------
select name as Song_name,artists, duration_ms/(60*1000) as Duration_in_minutes
from spotify.songs
where duration_ms = (select max(duration_ms) from spotify.songs) 
or
duration_ms = (select min(duration_ms) from spotify.songs)
order by duration_ms desc;
#----------------------------------------------------------------------------------------


##3 Artist with more than 50 songs and popularity greater than 55
#----------------------------------------------------------------------------------------
select artists_a as Artist
from spotify.artist 
where count_a > 50 and popularity_a > 55
order by popularity_a desc 
limit 10;  
#----------------------------------------------------------------------------------------


##4 Top 3 artists with the most songs that are explicit and popular
#----------------------------------------------------------------------------------------
select count(*) as Explicit_songs, artists as Artists
from spotify.songs
where explicit = 1 and popularity > 20 
group by artists
order by explicit_songs desc
limit 3;
#----------------------------------------------------------------------------------------


##5 Top 10 Artist scored by the number of songs
#----------------------------------------------------------------------------------------
select artists as Artists, avg(popularity) as Popularity, count(*) as Total_Songs
from spotify.songs 
group by artists
having min(popularity) >70
order by Total_Songs desc
limit 10;
#----------------------------------------------------------------------------------------


##6 Artist with very popular songs that have never made an explicit song. 
#----------------------------------------------------------------------------------------
select artists_a as Artist
from spotify.artist 
where exists (select name
				from spotify.songs
                where artists = artists_a and popularity > 90)
	and not exists (select name
					from spotify.songs
                    where artists = artists_a and explicit = 1);
#----------------------------------------------------------------------------------------


##7 Most danceable songs compared to the average of the year
#----------------------------------------------------------------------------------------
select name as Song_Name, artists as Artists, year as Year, danceability as Danceability
from spotify.songs left join spotify.year on year = year_y
where danceability-danceability_y > .5;
#----------------------------------------------------------------------------------------                    
    
    
##8 Most popular song by Billie Eilish
#----------------------------------------------------------------------------------------
select name as Song_Nane, year as Year
from spotify.songs
where artists =  'Billie Eilish' and popularity = (select max(popularity) 
													   from spotify.songs
													   where artists = 'Billie Eilish') ;
#----------------------------------------------------------------------------------------
 
 
##9 Popularity of the Artist with the most popular song of the most popular year 
#----------------------------------------------------------------------------------------
select artists_a as Artist, popularity_a as Artist_Popularity
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
#----------------------------------------------------------------------------------------


##10 New Ranking Score
#----------------------------------------------------------------------------------------
select name,artists, popularity*(energy/(select max(energy) from spotify.songs) + 
						liveness/(select max(liveness) from spotify.songs) + 
                        tempo/(select max(tempo) from spotify.songs)+
                        speechiness/(select max(speechiness) from spotify.songs)) as score, energy, liveness, tempo,speechiness
from spotify.songs
order by score desc
limit 50;
#----------------------------------------------------------------------------------------
 
 
 ##11 Most Popular Artist within certain parameters
 #----------------------------------------------------------------------------------------
select distinct  a.artists_a, a.popularity_a
from spotify.artist a
where a.artists_a in (select artists as arts from spotify.songs
						where instrumentalness = 0 and loudness between -40 and 0 and
							energy > 0.6 and speechiness < 0.2 and tempo > 100)
order by popularity_a desc
limit 10;
#----------------------------------------------------------------------------------------
