
/*
Covid 19 Data Exploration
Data Source: https://ourworldindata.org/covid-deaths
Data collected: Jan 2020 to July 2021
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/


-- Quick view of data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2



-- Shows the mortality risk of Covid-cases by total cases and total deaths in:

-- Australia
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS fatality_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Australia'
AND continent is not null
ORDER BY 1, 2

-- Vietnam
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS fatality_percentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%Viet%'
AND continent is not null
ORDER BY 1, 2



-- Looking at Total Cases vs Population
-- Shows the percentage of the population got covid infected

-- Australia
SELECT location, date, total_cases, population, (total_cases/population)*100 AS infection_percentage
FROM PortfolioProject..CovidDeaths
WHERE location = 'Australia'
AND continent is not null
ORDER BY 1, 2



-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS total_cases, MAX((total_cases/population))*100 AS highest_infection_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by location, population
ORDER BY highest_infection_percentage desc



-- Showing Countries with Highest Death Count per Population

SELECT location, population, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by location, population
ORDER BY total_death_count desc



-- Categorise by Continents
-- Showing continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
GROUP by continent
ORDER BY total_death_count desc



-- Global Numbers

-- By Date
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths
, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2

-- Summary table

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths
, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2



-- Vaccination Progress through days

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3



-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingVaccinated/population)*100 AS VaccinationPercentage
FROM PopvsVac


-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingVaccinated/population)*100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualisation

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date) AS RollingVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated