SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
Order by 3,4


SELECT *
FROM PortfolioProject..CovidVaccinations
Order by 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2

--Total Cases vs Total Deaths
SELECT location,date,total_cases,total_deaths, (CONVERT(float,total_cases)/ NULLIF(CONVERT(float,population),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Mexico' and continent IS NOT NULL
ORDER by 1,2

--Looking at Total Cases vs Population
SELECT location,date,population,total_cases, (CONVERT(float,total_cases)/ NULLIF(CONVERT(float,population),0))*100 AS GotCovid
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'Mexico' and continent IS NOT NULL
order by 1,2

--Country highest infection rate compared to population
SELECT location,population, MAX (total_cases) as HighestInfectionCount,(CAST(MAX(total_cases) AS FLOAT)/ population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--BREAK DOWN BY CONTENT
SELECT continent , MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
Order by TotalDeathCount DESC


--Countries Highest dead count per population
SELECT location , MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
Order by TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/ SUM(new_cases) *100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as BIGINT))  OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE

WITH PopvsVac(Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as BIGINT))  OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *,(RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO  #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as BIGINT))  OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--CREATE VIEW TO STORE DATA FOR LATER VISUALIZATION
CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as BIGINT))  OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
FROM PercentPopulationVaccinated
