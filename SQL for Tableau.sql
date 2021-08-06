
/*
Covid 19 Queries for Tableau viz
Data Source: https://ourworldindata.org/covid-deaths
Data collected: Jan 2020 to July 2021
*/



-- 1.
-- Summary table

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths
, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2


-- 2
SELECT location, SUM(CAST(new_deaths AS int)) AS dead_toll
FROM PortfolioProject..CovidDeaths
WHERE continent is null
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY dead_toll desc


-- 3
-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS total_cases, MAX((total_cases/population))*100 AS infection_percentage
FROM PortfolioProject..CovidDeaths
GROUP by location, population
ORDER BY infection_percentage desc



-- 4
-- Looking at Countries with Highest Infection Rate compared to Population
-- By date
SELECT location, population, date, MAX(total_cases) AS total_cases, MAX((total_cases/population))*100 AS infection_percentage
FROM PortfolioProject..CovidDeaths
GROUP by location, population, date
ORDER BY infection_percentage desc



