/*
Covid 19 Data

Skills Used:
Joins, Temp Tables, CTE, Windows Functions, Converting Data Types, Create views

*/

SELECT *
FROM Profile..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


--Select the Relevant Data

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Profile..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at Total Cases VS Total Deaths
--Shows the percentage probability of dying if your contract covid in Canada.


SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM Profile..CovidDeaths
WHERE location like 'Canada' and continent is not null
ORDER BY 1,2

-- Looking at the Total_Cases vs the Population
-- Shows what percentage of the population had Covid

SELECT location,date,Population,total_cases,(total_cases/Population)*100 as PercentPopulationInfected
FROM Profile..CovidDeaths
--WHERE location like 'Canada' and continent is not null
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as 
PercentagePopulationInfected
FROM Profile..CovidDeaths
--Where continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc


-- Countries with the highest deaths counts per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Profile..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathsCount desc

-- Break Down by Continent
-- Max death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Profile..CovidDeaths
WHERE continent is not null
GROUP BY continent 
ORDER BY TotalDeathsCount desc


-- Global Numbers

SELECT SUM(new_cases) as Total_Cases, SUM(CAST(NEW_DEATHS as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/ SUM(NEW_CASES)*100 
 as DeathPercentage
FROM Profile..CovidDeaths
WHERE continent is not null
--Group by date 
ORDER BY 1,2


-- Total Population vs Total Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   ,SUM(Convert(bigint, vac.new_vaccinations)) 
   OVER (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

FROM Profile..CovidDeaths dea
JOIN Profile..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
   WHERE dea.continent is not null
   -- order by 2,3
 
 --Use CTE for  calculations

   WITH PopvsVac (Continent, Location, Date,Population, new_vaccinations, RollingpeopleVaccinated) 
   as
   (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   ,SUM(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
FROM Profile..CovidDeaths dea
JOIN Profile..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
   WHERE dea.continent is not null
   -- order by 2,3
   )
SELECT*, (RollingpeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE for calculations


DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 
   ,SUM(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

FROM Profile..CovidDeaths dea
JOIN Profile..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
   --Where dea.continent is not null
   -- order by 2,3
   
SELECT*, (RollingpeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Visualizations

CREATE VIEW 
PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 
   ,SUM(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated

FROM Profile..CovidDeaths dea
JOIN Profile..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
   WHERE dea.continent is not null

   
   
