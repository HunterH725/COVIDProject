SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data we are going to use
SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- Look at total cases vs total deaths, death %
SELECT Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- Look at total case vs population, case %
SELECT Location,date,total_cases,population,(total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths$
WHERE Location like '%states%' and continent is not null
ORDER BY 1,2

-- Look at countries with highest infection rate compared to population
SELECT Location,population,MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as CasePercentage
FROM PortfolioProject..CovidDeaths$
GROUP BY Location,population
ORDER BY CasePercentage desc

-- Showing countries with highest death count per population
SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

-- Break down by continent
SELECT continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global numbers
SELECT date,SUM(new_cases) as TotalCases,SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

-- Look at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageVaxxed
FROM PopvsVac

-- TEMP TABLE

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
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageVaxxed
FROM #PercentPopulationVaccinated

-- Create view to store data for visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM PercentPopulationVaccinated