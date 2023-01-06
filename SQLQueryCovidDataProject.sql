SELECT *
FROM Profile..CovidDeaths
Where continent is not null
order by 3,4

--SELECT *
--FROM Profile..CovidVaccines
--order by 3,4

--SELELECT THE DATA I GOING TO BE USING

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Profile..CovidDeaths
Where continent is not null
ORDER BY 1,2

--Looking at Total Cases VS Total Deaths
--Shows the percentage of dying probability if your contract covid in Canada.
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM Profile..CovidDeaths
WHERE location like 'Canada' and continent is not null
ORDER BY 1,2

-- Looking at the Total_Cases vs the Population
-- Shows what percentage of the population got Covid

SELECT location,date,Population,total_cases,(total_cases/Population)*100 as PercentPopulationInfected
FROM Profile..CovidDeaths
WHERE location like 'Canada' and continent is not null
ORDER BY 1,2

--Looking at countries with highest infection rate compared to population

SELECT location,Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as 
PercentagePopulationInfected
FROM Profile..CovidDeaths
Where continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc


-- Countries with the highest deaths counts per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Profile..CovidDeaths
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathsCount desc
-- Break Down by Continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Profile..CovidDeaths
Where continent is not null
GROUP BY continent 
ORDER BY TotalDeathsCount desc

-- Continent with the Highest  Death Counts pero Population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
FROM Profile..CovidDeaths
Where continent is not null
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
 
 --USE CTE

   WITH PopvsVac (Continent, Location, Date,Population, new_vaccinations, RollingpeopleVaccinated) 
   as
   (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   ,SUM(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
FROM Profile..CovidDeaths dea
Join Profile..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
   Where dea.continent is not null
   -- order by 2,3
   )
SELECT*, (RollingpeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   ,SUM(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
FROM Profile..CovidDeaths dea
Join Profile..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
   --Where dea.continent is not null
   -- order by 2,3
SELECT*, (RollingpeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Visualizations
Create View PercentPopulationVaccinated as
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
   ,SUM(Convert(bigint, vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
FROM Profile..CovidDeaths dea
Join Profile..CovidVaccinations vac
   ON dea.location = vac.location
   and dea.date = vac.date
   Where dea.continent is not null

   SELECT*
   FROM PercentPopulationVaccinated
   
