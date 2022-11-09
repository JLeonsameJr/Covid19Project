-- Queries used for data visualisation:

--1. Global statistics

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL

--2. Countries ranked by total mortality

SELECT location, SUM(CAST(new_deaths AS INT)) AS TotalDeathCount
FROM Covid19Project..CovidDeaths
WHERE continent IS NULL
AND location NOT IN ('World', 'European Union', 'International')
AND location NOT LIKE '%income'
GROUP BY location
ORDER BY TotalDeathCount DESC

--3. Countries by infection rate by population

SELECT location, population, MAX(total_cases) AS highest_infection_count, ROUND(MAX((total_cases/population))*100,2) AS infection_rate
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC;

 
 --3. Countries by infection rate by population

SELECT location, population, MAX(total_cases) AS highest_infection_count, ROUND(MAX((total_cases/population))*100,2) AS infection_rate
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC;

 --4. Countries by infection rate by population incl. dates

SELECT location, population, date, MAX(total_cases) AS highest_infection_count, ROUND(MAX((total_cases/population))*100,2) AS infection_rate
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY infection_rate DESC;