SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent is not null
 ORDER BY 3,4

 --SELECT * FROM PortfolioProject..CovidVaccinations
 --ORDER BY 3,4

 --Select Data that we are going to be using

 SELECT Location, date, total_cases, new_cases, total_deaths, population
 FROM PortfolioProject..CovidDeaths
 WHERE continent is not null
 ORDER BY 1,2

 -- Looking at Total Cases vs Total Deaths
 -- Shows likeihood of dying if you contract covid in your country 
 SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths
 WHERE location like 'Canada%' 
 ORDER BY 1,2

 -- Looking at Total Cases vs Population
 -- Shows what percentage of population got COVID
 SELECT location, date, population, total_cases, (total_cases/population)*100 as CasePercentage
 FROM PortfolioProject..CovidDeaths
 WHERE location like 'Canada%' AND ((total_cases/population)*100 > 1)
 ORDER BY 1,2
 
 -- Looking at Countires with Highest Infection Rate compared to Population
 SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
 FROM PortfolioProject..CovidDeaths
 WHERE location like 'Canada%'
 GROUP BY location, population
 ORDER BY PercentPopulationInfected DESC

 -- Showing countries total death per Population
 SELECT location, population, MAX(total_deaths) as HighestDeathCount, MAX((total_deaths/population))*100 as PercentPopulationDeaths
 FROM PortfolioProject..CovidDeaths
 WHERE location like 'Canada%'
 GROUP BY location, population
 ORDER BY PercentPopulationDeaths DESC

 -- Showing Countries with Highest Death Count per Population
  SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 --WHERE location like 'Canada%'
 WHERE continent is not null
 GROUP BY location
 ORDER BY TotalDeathCount DESC

 --Let's break things down by continent
 -- Correct data using this query
  SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 --WHERE location like 'Canada%'
 WHERE continent is null -- This line indicates that location column contains the continent names and all the statistics for each record and where the continent column is null
 GROUP BY location
 ORDER BY TotalDeathCount DESC

 -- Showing continents with the highest death count per population

 SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM PortfolioProject..CovidDeaths
 --WHERE location like 'Canada%'
 WHERE continent is not null 
 GROUP BY continent
 ORDER BY TotalDeathCount desc

 -- Global Numbers
 SELECT SUM(new_cases) as total_cases , SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 FROM PortfolioProject..CovidDeaths
 --WHERE location like 'Canada%' 
 WHERE continent is not null
 --GROUP BY date
 ORDER BY 1,2
 
 -- Looking at Total Population vs Vaccinations 

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null and dea.location LIKE 'Canada%'
Order by 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null and dea.location LIKE 'Canada%'
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( 
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null
-- ORDER by 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visulizations

Create VIEW  PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER by dea.location, dea.date) as RollingPeopleVaccinated
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date 
WHERE dea.continent is not null 
-- ORDER by 2,3

SELECT * FROM PercentPopulationVaccinated