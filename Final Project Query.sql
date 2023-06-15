--1. Create a table named 'matches' with appropriate data types for columns

CREATE TABLE matches (
   id INT PRIMARY KEY,
   city VARCHAR(40),
   date DATE,
   player_of_match VARCHAR(40),
   venue VARCHAR(80),
   neutral_venue INT,
   team1 VARCHAR(80),
   team2 VARCHAR(80),
   toss_winner VARCHAR(80),
   toss_decision VARCHAR(20),
   winner VARCHAR(80),
   result VARCHAR(40),
   result_margin INT,
   eliminator VARCHAR(10),
   method VARCHAR(10),
   umpire1 VARCHAR(40),
   umpire2 VARCHAR(40)
);


-- 2. Create a table named 'deliveries' with appropriate data types for columns

CREATE TABLE deliveries (
   id INT,
   inning INT,
   over INT,
   ball INT,
   batsman VARCHAR(40),
   non_striker VARCHAR(40),
   bowler VARCHAR(40),
   batsman_runs INT,
   extra_runs INT,
   total_runs INT,
   is_wicket INT,
   dismissal_kind VARCHAR(40),
   player_dismissed VARCHAR(40),
   fielder VARCHAR(80),
   extras_type VARCHAR(40),
   batting_team VARCHAR(40),
   bowling_team VARCHAR(40),
   FOREIGN KEY(id) REFERENCES matches(id)
);

select * from deliveries;

-- 3. Import data from csv file ’IPL_matches.csv’ attached in resources to the table ‘matches’ which was created in Q1
COPY matches FROM 'C:\Program Files\PostgreSQL\15\data\data_copy\IPL_matches.csv' DELIMITER ',' CSV HEADER; 
SELECT * FROM matches;


-- 4. Import data from csv file ’IPL_Ball.csv’ attached in resources to the table ‘deliveries’ which was created in Q2
COPY deliveries FROM 'C:\Program Files\PostgreSQL\15\data\data_copy\IPL_Ball.csv' DELIMITER ',' CSV HEADER;
SELECT * FROM deliveries;


-- 5. Select the top 20 rows of the deliveries table after ordering them by id, inning, over, ball in ascending order.
SELECT * FROM deliveries
ORDER BY id , inning, over, ball asc
LIMIT 20;


-- 6. Select the top 20 rows of the matches table.
SELECT * FROM matches
LIMIT 20;


-- 7. Fetch data of all the matches played on 2nd May 2013 from the matches table..
SELECT * FROM matches;
SELECT * FROM matches
WHERE date = '2013-05-02';


-- 8. Fetch data of all the matches where the result mode is ‘runs’ and margin of victory is more than 100 runs.
SELECT * FROM matches
WHERE result = 'runs'
AND
result_margin > 100;


-- 9. Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date.
SELECT * FROM matches
WHERE result = 'tie'
ORDER BY date DESC;


-- 10. Get the count of cities that have hosted an IPL match.
SELECT COUNT(DISTINCT city) 
FROM matches;


-- 11. Create table deliveries_v02 with all the columns of the table ‘deliveries’ and an additional column ball_result containing values boundary, dot or other depending on the total_run (boundary for >= 4, dot for 0 and other for any other number)
CREATE TABLE deliveries_v02 AS 
SELECT *,
      CASE 
	      WHEN total_runs = 4 THEN 'boundary'
		  WHEN total_runs = 0 THEN ' dot'
		  ELSE 'other'
	  END AS ball_result
FROM deliveries;


-- 12. Write a query to fetch the total number of boundaries and dot balls from the deliveries_v02 table.
SELECT 
    ball_result,
	COUNT(*) AS count 
FROM 
   deliveries_v02
WHERE 
   ball_result IN ('boundary', 'dot')
GROUP BY 
   ball_result;
   
   
-- 13. Write a query to fetch the total number of boundaries scored by each team from the deliveries_v02 table and order it in descending order of the number of boundaries scored.
SELECT batting_team,
	COUNT(*) AS boundary_count
FROM 
   deliveries_v02
WHERE 
   ball_result = 'boundary'
GROUP BY 
   batting_team
ORDER BY 
   boundary_count;
   
   
-- 14. Write a query to fetch the total number of dot balls bowled by each team and order it in descending order of the total number of dot balls bowled.
SELECT batting_team,
	COUNT(*) AS dot_count
FROM 
   deliveries_v02
WHERE 
   ball_result = 'dot'
GROUP BY 
   batting_team
ORDER BY 
   dot_count;


-- 15. Write a query to fetch the total number of dismissals by dismissal kinds where dismissal kind is not NA
-- from this question we get most common way of getting out in the ipl
SELECT
    dismissal_kind,
    COUNT(*) AS dismissal_count
FROM
    deliveries
WHERE
    dismissal_kind != 'NA'
GROUP BY
    dismissal_kind;


-- 16. Write a query to get the top 5 bowlers who conceded maximum extra runs from the deliveries table
SELECT 
    bowler,
	SUM (extra_runs) AS total_extra_runs
FROM
    deliveries
GROUP BY 
    bowler
ORDER BY
    total_extra_runs DESC
LIMIT 5;


-- 17. Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table and two additional column (named venue and match_date) of venue and date from table matches
SELECT * FROM matches;

CREATE TABLE deliveries_v03 AS
SELECT dv2.*, m.venue, m.date
FROM deliveries_v02 AS dv2
JOIN matches AS m ON dv2.id = m.id;

SELECT * FROM deliveries_v03;
/* In this query, we are using the CREATE TABLE statement to create a new table deliveries_v03. 
The AS keyword is used to specify that we are creating the new table as a result of the SELECT query.

The SELECT query is retrieving all the columns (*) from the deliveries_v02 table (dv2 alias) and also selecting the venue and match_date columns from the matches table (m alias).
The JOIN clause is used to join the two tables based on the match_id column.

By executing this query, a new table named deliveries_v03 will be created with all the columns from deliveries_v02 and two additional columns (venue and match_date) from the matches table. */



-- 18. Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored.

SELECT venue, SUM(total_runs) AS runs
FROM deliveries_v03
GROUP BY venue
ORDER BY runs DESC;
/* In this query, we are selecting the venue column and calculating the sum of runs (SUM(total_runs)) for each venue. 
The GROUP BY clause groups the data by venue. 
Then, we use the ORDER BY clause to sort the result set in descending order based on the total runs scored (total_runs).
By executing this query, you will get the total runs scored for each venue,
with the venues ordered in descending order based on the total runs scored.*/




-- 19. Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored.
SELECT * FROM deliveries_v03;

SELECT EXTRACT(YEAR FROM date) AS year, SUM(total_runs) AS runs
FROM deliveries_v03
WHERE venue = 'Eden Gardens'
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY runs DESC;
/* In this query, we use the EXTRACT() function to extract the year from the match_date column. 
The WHERE clause filters the data to only include matches played at Eden Gardens. 
The GROUP BY clause groups the data by year.
Finally, the ORDER BY clause sorts the result set in descending order based on the total runs scored.*/




/* 20. Get unique team1 names from the matches table, you will notice that there are two entries for Rising Pune Supergiant one with Rising Pune Supergiant and another one with Rising Pune Supergiants.  
Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr containing team names with replacing Rising Pune Supergiants with Rising Pune Supergiant. 
Now analyse these newly created columns. */


/* To create a table named matches_corrected with two additional columns team1_corr and team2_corr, where the team names "Rising Pune Supergiants" are replaced with "Rising Pune Supergiant,"
you can use the following SQL query: */
CREATE TABLE matches_corrected AS
SELECT *,
       CASE
           WHEN team1 = 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
           ELSE team1
       END AS team1_corr,
       CASE
           WHEN team2 = 'Rising Pune Supergiants' THEN 'Rising Pune Supergiant'
           ELSE team2
       END AS team2_corr
FROM matches;
/* In this query, we are using the CREATE TABLE statement to create a new table named matches_corrected as a result of the SELECT query.

The SELECT query retrieves all columns (*) from the matches table and uses the CASE statement to check if the team name is "Rising Pune Supergiants." If it matches, it replaces it with "Rising Pune Supergiant" in the team1_corr or team2_corr columns accordingly. If the team name doesn't match, it retains the original team name.

By executing this query, a new table named matches_corrected will be created with the original columns from the matches table and two additional columns (team1_corr and team2_corr) where the team names are corrected. */

-- After creating the matches_corrected table, you can analyze the newly created columns team1_corr and team2_corr using various SQL queries, such as:
-- 1. To get the count of matches for each team:
SELECT team1_corr AS team, COUNT(*) AS match_count
FROM matches_corrected
GROUP BY team1_corr
ORDER BY match_count DESC;
/* This query will give you the count of matches for each team in the team1_corr column, ordered in descending order based on the match count. */

-- 2. To get the total runs scored by each team:
SELECT team1_corr AS team, SUM(total_runs) AS runs
FROM matches_corrected, deliveries_v03
WHERE team1_corr IS NOT NULL
GROUP BY team1_corr
ORDER BY runs DESC;
/* This query will provide the total runs scored by each team in the team1_corr column, ordered in descending order based on the total runs scored. */




/* 21. Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning,
over and ball separated by ‘-’ (For ex. 335982-1-0-1 match_id-inning-over-ball)
and rest of the columns same as deliveries_v03) */

SELECT * FROM deliveries_v03;

CREATE TABLE deliveries_v04 AS
SELECT CONCAT(id, '-', inning, '-', over, '-', ball) AS ball_id, dv3.*
FROM deliveries_v03 AS dv3;

SELECT * FROM deliveries_v04;
/* In this query, we are using the CREATE TABLE statement to create a new table deliveries_v04 as a result of the SELECT query.

The SELECT query retrieves all columns (*) from the deliveries_v03 table (dv3 alias) and concatenates the match_id, inning, over, and ball columns using the CONCAT() function, separated by hyphens (-), and aliases it as ball_id. The rest of the columns from deliveries_v03 are included as well.

By executing this query, a new table named deliveries_v04 will be created with the ball_id column as the first column, containing the concatenated information of match_id, inning, over, and ball, followed by the rest of the columns from deliveries_v03 */





-- 22. Compare the total count of rows and total count of distinct ball_id in deliveries_v04;

-- To get the total count of rows in deliveries_v04:
SELECT COUNT(*) AS total_rows
FROM deliveries_v04;

-- To get the total count of distinct ball_id in deliveries_v04:
SELECT COUNT(DISTINCT ball_id) AS distinct_ball_ids
FROM deliveries_v04;



/* 23. SQL Row_Number() function is used to sort and assign row numbers to data rows in the presence of multiple groups. For example, to identify the top 10 rows which have the highest order amount in each region, we can use row_number to assign row numbers in each group (region) with any particular order (decreasing order of order amount) and then we can use this new column to apply filters. Using this knowledge, solve the following exercise. You can use hints to create an additional column of row number.
Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partition over ball_id. (HINT : Syntax to add along with other columns,  row_number() over (partition by ball_id) as r_num) */

CREATE TABLE deliveries_v05 AS
SELECT *, ROW_NUMBER() OVER (PARTITION BY ball_id ORDER BY ball_id) AS r_num
FROM deliveries_v04;

/* In this query, we are using the CREATE TABLE statement to create a new table deliveries_v05 as a result of the SELECT query.

The SELECT query retrieves all columns (*) from the deliveries_v04 table and uses the ROW_NUMBER() function along with the OVER clause to assign row numbers partitioned by ball_id. The ORDER BY clause specifies the order of the row numbers based on ball_id, but you can modify it as per your specific requirements.

By executing this query, a new table named deliveries_v05 will be created with all the columns from deliveries_v04 and an additional column r_num representing the row number within each partition of ball_id.  */
SELECT * FROM deliveries_v05;




/* 24. Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating. (HINT : select * from deliveries_v05 WHERE r_num=2;) */

SELECT *
FROM deliveries_v05
WHERE r_num > 1;

/* In this query, we are selecting all columns (*) from the deliveries_v05 table where the r_num column is greater than 1. This condition will include all rows where the ball_id is repeating.

By executing this query, you will retrieve all the rows from deliveries_v05 where the ball_id is repeating, as identified by the r_num column being greater than 1. */




/* 25. Use subqueries to fetch data of all the ball_id which are repeating. (HINT: SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE r_num=2);
 */

SELECT *
FROM deliveries_v05
WHERE ball_id IN (
    SELECT ball_id
    FROM deliveries_v05
    WHERE r_num > 1
);


/* In this query, the subquery (SELECT ball_id FROM deliveries_v05 WHERE r_num > 1) is used to retrieve all the ball_id values that have a r_num greater than 1, indicating that they are repeating. The outer query then selects all the rows from deliveries_v05 where the ball_id is present in the result of the subquery.

By executing this query, you will obtain the data of all the rows in deliveries_v05 where the ball_id values are repeating. */










