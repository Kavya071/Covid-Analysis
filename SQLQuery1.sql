SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4


--SELECT THE DAATA THAT WE ARE GOING TO USE

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--LOOKING AT TOTAL_CASES V/S TOTAL_DEATHS
--SHOWS LIKELIHOOD OF CHANCES OF DYING IN A COUNTRY
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DEATH_PERCENTAGE
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%INDIA%'
AND continent IS NOT NULL
ORDER BY 1,2

--LOOKING AT TOTAL_CASES V/S POPULATION
--SHOWS PERCENTAGE OF PEOPLE WHO GOT COVID
SELECT location,date,population,total_cases,(total_cases/population)*100 AS PERCENTAGE_POPOULATION_INFECTED
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%INDIA%'AND continent IS NOT NULL
ORDER BY 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE AS COMPARED TO POPOULATION
SELECT location,population,MAX(total_cases) AS HIGHEST_INFECTION_COUNT,MAX((total_cases/population))*100 AS PERCENTAGE_POPOULATION_INFECTED
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%INDIA%'
GROUP BY location,population 
ORDER BY PERCENTAGE_POPOULATION_INFECTED DESC

--LOOKING AT COUNTRIES WITH HIGHEST DEATH COUNT

SELECT location,MAX(CAST(total_deaths AS int)) AS TOTAL_DEATH_COUNTS
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TOTAL_DEATH_COUNTS DESC

--BY CONTINENT

SELECT continent,MAX(CAST(total_deaths AS int)) AS TOTAL_DEATH_COUNTS
FROM PortfolioProject..CovidDeaths$
--WHERE location LIKE '%INDIA%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TOTAL_DEATH_COUNTS DESC

--GLOBAL NUMBERS

SELECT date,SUM(new_cases)AS TOTAL_CASES,SUM(CAST(new_deaths AS int)) AS TOTAL_DEATHS,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DEATH_PERCENTAGE
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases)AS TOTAL_CASES,SUM(CAST(new_deaths AS int)) AS TOTAL_DEATHS,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DEATH_PERCENTAGE
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
 
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3





DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc