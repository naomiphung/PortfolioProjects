-- European Soccer Data Exploration
-- Data Source: Kaggle: European Soccer Database by Hugo Mathien


.fullschema

select *
From Country


SELECT *
From League


SELECT *
From Match


SELECT *
From Team



-- Use CTE

WITH CTE_home_team_score (league_id, home_team_api_id, season, W, L, D, score)
as 
-- Calculate home team total win, total loss, total draw and its score by season
-- Score = Win +3, Draw +1, Loss 0
(
SELECT league_id, home_team_api_id, season,
sum(CASE WHEN home_team_goal > away_team_goal THEN 1 ELSE 0 END) W,
sum(CASE WHEN home_team_goal < away_team_goal THEN 1 ELSE 0 END) L,
sum(CASE WHEN home_team_goal = away_team_goal THEN 1 ELSE 0 END) D,
sum(CASE
        WHEN home_team_goal > away_team_goal THEN 3
        WHEN home_team_goal = away_team_goal THEN 1
        WHEN home_team_goal < away_team_goal THEN 0
    END) AS score
FROM Match
Group by home_team_api_id, season, league_id
)

-- Rank home team performance by season
SELECT season, league_id, home_team_api_id, score,
RANK() over (partition by season, league_id ORDER BY score DESC) as rank
FROM CTE_home_team_score



----------------------
-- Use join and window functions to filter out "England Premier League" performance in 2015/2016

SELECT season,
        l.name as league_name,
        t.team_long_name as home_team_long_name,
        sum(home_team_goal - away_team_goal) as Dif,
        sum(CASE WHEN home_team_goal > away_team_goal THEN 1 ELSE 0 END) W,
        sum(CASE WHEN home_team_goal < away_team_goal THEN 1 ELSE 0 END) L,
        sum(CASE WHEN home_team_goal = away_team_goal THEN 1 ELSE 0 END) D,
        RANK() over (partition by season, league_id
                        ORDER BY sum(CASE
                                        WHEN home_team_goal > away_team_goal THEN 3
                                        WHEN home_team_goal = away_team_goal THEN 1
                                        WHEN home_team_goal < away_team_goal THEN 0
                    END) desc) AS ranking
FROM Match m
LEFT JOIN League l
ON m.league_id = l.id
LEFT JOIN team t
ON t.team_api_id = m.home_team_api_id
where season = "2015/2016" and l.name = "England Premier League"
Group by    season,
            league_id,
            home_team_api_id




-- Rank the performance of all Team in England Premier League 2015/2016
-- Use CTE and then Join the result tables

WITH 
-- Home team table
home_table AS (
SELECT season,
        l.name as league_name,
        t.team_long_name as home_team_long_name,
        home_team_api_id as team_id,
        home_team_goal - away_team_goal as Dif_home,
        sum(CASE
                WHEN home_team_goal > away_team_goal THEN 3
                WHEN home_team_goal = away_team_goal THEN 1
                WHEN home_team_goal < away_team_goal THEN 0
                END) AS score
FROM Match m
LEFT JOIN League l
ON m.league_id = l.id
LEFT JOIN team t
ON t.team_api_id = m.home_team_api_id
where season = "2015/2016" and l.name = "England Premier League"
Group by    season,
            l.name,
            home_team_api_id
), 

-- Away team table

away_table AS (
SELECT season,
        l.name as league_name,
        t.team_long_name as away_team_long_name,
        away_team_api_id as team_id,
        sum(away_team_goal - home_team_goal) as Dif_away,
        sum(CASE
                WHEN away_team_goal > home_team_goal THEN 3
                WHEN home_team_goal = away_team_goal THEN 1
                WHEN away_team_goal < home_team_goal THEN 0
            END) AS score
FROM Match m
LEFT JOIN League l
ON m.league_id = l.id
LEFT JOIN team t
ON t.team_api_id = m.away_team_api_id
where season = "2015/2016" and l.name = "England Premier League"
Group by    season,
            l.name,
            away_team_api_id
)

-- join home team and away team table
SELECT
   ht.season,
   ht.league_name,
   t.team_long_name,
   ht.Dif_home + at.Dif_away AS Dif,
   ht.score + at.score AS Total_Score,
   RANK() OVER (ORDER BY ht.score + at.score DESC) AS Ranking

FROM home_table ht
JOIN away_table at
ON ht.team_id = at.team_id
LEFT JOIN team t on ht.team_id = t.team_api_id
ORDER BY Total_Score DESC, Dif DESC



