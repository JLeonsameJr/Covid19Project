--SELECT *
--FROM Covid19Project..CovidDeaths
--ORDER BY 3,4;

--SELECT *
--FROM Covid19Project..CovidVaccinations
--ORDER BY 3,4;

--Total Cases vs Total Deaths - UK
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Covid19Project..CovidDeaths
WHERE location = 'United Kingdom'
AND continent IS NOT NULL
ORDER BY location, date

--Total Cases vs Total Population - Infection rate - UK
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS infection_rate
FROM Covid19Project..CovidDeaths
WHERE location = 'United Kingdom'
AND continent IS NOT NULL
ORDER BY location, date

--Countries with highest infection rate vs. population
SELECT location, population, MAX(total_cases) AS highest_infection_count, ROUND(MAX((total_cases/population))*100,2) AS infection_rate
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC;

--Countries with highest mortality count per population
SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Mortality count by continent
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--GLOBAL STATS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM Covid19Project..CovidDeaths
WHERE continent IS NOT NULL

--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_pop_vaccinated
FROM Covid19Project..CovidDeaths AS dea
JOIN Covid19Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date

--Using a Common Table Expression - total persons vaccinated as a percentage of population - cumulative daily

WITH pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_pop_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_pop_vaccinated
FROM Covid19Project..CovidDeaths AS dea
JOIN Covid19Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_pop_vaccinated/population)*100
FROM pop_vs_vac

--TEMP Table

DROP TABLE IF EXISTS #percentPopulationVaccinated
CREATE TABLE #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_pop_vaccinated numeric
)

INSERT INTO #percentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_pop_vaccinated
FROM Covid19Project..CovidDeaths AS dea
JOIN Covid19Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_pop_vaccinated/population)*100
FROM #percentPopulationVaccinated

--Creating a view to store data for later visualisation

CREATE VIEW percentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_pop_vaccinated
FROM Covid19Project..CovidDeaths AS dea
JOIN Covid19Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

Select *
FROM percentPopulationVaccinated;