/*SELECT * 
FROM Portfolio..CovidDeaths
order by 3, 4*/

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
order by 1, 2

-- Total cases vs total deaths

SELECT Location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 as DeathPercentage
FROM Portfolio..CovidDeaths
where location like '%states%'
order by 1, 2

SELECT Location, date, total_cases, total_deaths
FROM Portfolio..CovidDeaths
where location like '%states%'
order by 1, 2

-- looking at total cases vs population to show what % of population got Covid19

SELECT Location, date, population, (total_cases/population)*100 as DeathPercentage
FROM Portfolio..CovidDeaths
where location like '%states%'
order by 1, 2


SELECT Location, date,total_cases, total_deaths, population, (total_cases/population)*100 as DeathPercentage
FROM Portfolio..CovidDeaths
where location like '%Estonia%'
order by 1, 2

-- I want to look at country with highest invection rate

SELECT Location, population, MAX(total_cases) as HighestInfectioncount, Max(total_cases/population)*100 
as PercetagePopulationInfected
FROM Portfolio..CovidDeaths
--where location like '%Estonia%'
Group by location, population
order by PercetagePopulationInfected desc

-- I want to show countries with highest death count per poplulation

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
--where location like '%Estonia%'
Group by location
order by TotalDeathCount desc


--To eliminate generalised continent
SELECT * 
FROM Portfolio..CovidDeaths
where continent is not NULL
order by 3, 4

-- I want to run this again 
-- I want to show countries with highest death count per poplulation

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--I want to break it down by continent

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
--where location like '%Estonia%'
where continent is null
Group by location
order by TotalDeathCount desc

-- There were many unwanted rows in the location by continent that needed to be removed

DELETE FROM Portfolio..CovidDeaths WHERE location = 'Low income'
DELETE FROM Portfolio..CovidDeaths WHERE location = 'High income'
DELETE FROM Portfolio..CovidDeaths WHERE location = 'Upper middle income'
DELETE FROM Portfolio..CovidDeaths WHERE location = 'Lower middle income'

-- here I want to show continents with the highest  death count per popuation

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM Portfolio..CovidDeaths
--where location like '%Estonia%'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

SELECT SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, 
SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentages
FROM Portfolio..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1, 2


-- I want to look at total popuplation vs Vaccinations


SELECT * FROM Portfolio.dbo.CovidVaccinations$

SELECT * FROM Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinationated
--, (RollingPeopleVaccinationated/population)*100
FROM Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--Using CTE

WITH PopvsVac (Continent, location, date, population, new_vaccinations, RollinPeopleVaccinated) 
as 
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinationated
--, (RollingPeopleVaccinationated/population)*100
FROM Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
select *, (RollinPeopleVaccinated/population) from PopvsVac

--Temp Table

Drop Table if exists #PercentPopulationVaccinated --very important to include this
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinationated
--, (RollingPeopleVaccinationated/population)*100
FROM Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccinated


-- I want to create view to store data for later visualizations

Create View PercentagePpopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinationated
--, (RollingPeopleVaccinationated/population)*100
FROM Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

select * from PercentagePpopulationVaccinated