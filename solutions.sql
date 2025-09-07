-- Netflix Project
Drop table if exists netflix;
create table netflix(
	show_id	 varchar(6),
	type varchar(10),
	title varchar(150),
	director varchar(210),
	casts varchar(1000),
	country	varchar(150),
	date_added	varchar(50),
	release_year INT,
	rating	varchar(10),
	duration varchar(15),
	listed_in varchar(100),
	description varchar(250)
); 

select * from netflix;

select count(*) as total_content from netflix;

select Distinct type from netflix;

select Distinct duration from netflix;


-- 15 Problems

-- 1. Count the numbers of movies vs TV shows

select 
	type, count(*) as total_content from netflix
group by type;

-- 2. Find the most comman rating for movies and TV shows

SELECT  type, rating 
FROM(
	SELECT
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
	FROM netflix
	GROUP BY 1,2
) as t1 WHERE ranking=1;

-- 3. List all movies released in a specific year(e.g 2020)

select * from netflix
where type='Movie' AND release_year=2020;


-- 4. Find the top 5 countries with the most content on netflix

SELECT
 	UNNEST(STRING_TO_ARRAY(country,',')) as new_country, 
	COUNT(show_id) as total_content 
FROM netflix
group by 1
order by 2 desc
LIMIT 5


-- 5. Identify the longest movie?

select * from netflix
where 
	type='Movie'
	AND
	duration = (select max(duration) from netflix);

-- 6. Find content added in the last 5 years

SELECT * FROM netflix
where TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. find all the movies/TV shows by director 'Rajiv Chilaka'?

select * from netflix
where director LIKE '%Rajiv Chilaka%';

-- 8. List All Tv shows with more than 5 seasons

SELECT * from netflix
where
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ', 1)::numeric > 5;

-- 9. Count the number of content items in each genre?

select UNNEST(STRING_TO_ARRAY(listed_in, ',')) as genre, count(show_id) as total_count from netflix
group by 1;

-- 10. Find each year and the average numbers of content release in India on netflix.
-- return top 5 year with highest avg content release! 

select 
	EXTRACT(year from TO_DATE(date_added, 'Month DD, YYYY')) as date,
	count(*),
	ROUND(count(*)::numeric/(select count(*) from netflix where country= 'India')::numeric * 100, 2) 
from netflix
where country = 'India'
group by 1
order by 3 desc
limit 5;

-- 11. List all movies that are documentories

select * from netflix
where listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director

select * from netflix
where director is null;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years?

select * from netflix
where 
	casts ILIKE '%Salman Khan%'
	AND
	release_year > extract(year from current_date)-10;

-- 14. Find the top 10 actors who have appeared in highest number of movies produced in india.
	
select 
	unnest(STRING_TO_ARRAY(casts, ',')) as actors,
	COUNT(*) as total_content
from netflix
where country LIKE '%India%'
group by 1
order by 2 DESC
limit 10;

-- 15. Categorize the content based on the presence of the keywords 'Kill' and 'violence' in the description field.
-- Label content containing these keywords as 'Bad' abd all other content as 'Good'.
-- count how many items fall into each category.

with new_table AS(
	select *,
		case
		when 
			description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad_Content'
			else 'Good_content'
		end category
	from netflix
)
select category,count(*) as total_content 
from new_table
group by 1;


