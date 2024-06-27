SELECT *
FROM [Project Portfolio].dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

--SELECT *
--FROM [Project Portfolio].dbo.CovidVaccinations
--ORDER BY 3,4YIYNBVBKKL


--Select Data that we are going to be using

SELECT Location, date,total_cases, new_cases,total_deaths, population
FROM [Project Portfolio].dbo.CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country
SELECT Location, date,total_cases, total_deaths,  CONVERT(float, total_deaths) / CONVERT(float, total_cases) * 100 as DeathPercentage
FROM [Project Portfolio].dbo.CovidDeaths
WHERE continent is NOT NULL
AND location like '%States%'
ORDER BY 1,2


-- Looking at the Total Cases Vs Population
-- Shows what percentage of population got Covid

SELECT Location, date,total_cases, population,  CONVERT(float, total_cases) / CONVERT(float, population) * 100 as PercentPopulationInfected
FROM [Project Portfolio].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is NOT NULL
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate compared to Population
SELECT Location,population, MAX(total_cases) as HighestInfectionCount,  CONVERT(float, MAX(total_cases) / CONVERT(float, population)) * 100 as PercentPopulationInfected
FROM [Project Portfolio].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is NOT NULL
GROUP BY Location,population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount 
FROM [Project Portfolio].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- LET'S BREAK THINGS DOWN BY CONTINENTS


SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount 
FROM [Project Portfolio].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Showing the continents with Highest Death count per Population

SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount 
FROM [Project Portfolio].dbo.CovidDeaths
--WHERE location like '%States%'
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT  SUM(new_cases) as TotalNewcases, SUM(CAST(new_deaths as int)) as TotalNewDeaths,
 CASE      
	WHEN SUM(CAST(new_cases AS float)) > 0 
    THEN (SUM(CAST(new_deaths AS float)) / SUM(CAST(new_cases AS float))) * 100 
    ELSE 0 
    END AS DeathPercentage
FROM [Project Portfolio].dbo.CovidDeaths
WHERE continent is NOT NULL
--WHERE location like '%States%' 
--GROUP BY date
ORDER BY 1,2


--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location,dea.Date) as RollingPeopleVaccinated
FROM [Project Portfolio].dbo.CovidDeaths dea
--,  (RollingPeopleVaccinated / Population) * 100
JOIN [Project Portfolio].dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
order by 2,3 


--USE CTE
with PopsvsVac (Continent, Location, Date, Population, New_accinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location,dea.Date) as RollingPeopleVaccinated
FROM [Project Portfolio].dbo.CovidDeaths dea
--,  (RollingPeopleVaccinated / Population) * 100
JOIN [Project Portfolio].dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--order by 2,3 
)
select *, (RollingPeopleVaccinated / Population) * 100
from PopsvsVac


--Temp TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated BIGINT
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations 
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location,dea.Date) as RollingPeopleVaccinated
FROM [Project Portfolio].dbo.CovidDeaths dea
--,  (RollingPeopleVaccinated / Population) * 100
JOIN [Project Portfolio].dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--order by 2,3 

 select *, (RollingPeopleVaccinated / Population) * 100
from #PercentPopulationVaccinated


--Creating View to store data for later Visual

IF OBJECT_ID('PercentPopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW PercentPopulationVaccinated;
GO
CREATE view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations 
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location,dea.Date) as RollingPeopleVaccinated
FROM [Project Portfolio].dbo.CovidDeaths dea
--,  (RollingPeopleVaccinated / Population) * 100
JOIN [Project Portfolio].dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--order by 2,3 


select *
from PercentPopulationVaccinated