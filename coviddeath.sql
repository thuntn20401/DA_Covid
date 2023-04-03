select * from dbo.CovidDeaths

select * from dbo.CovidVaccinations


-- select data that we are going using
select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeaths
order by 1,2


-- looking at total_cases vs total_deaths in Vietnam
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where location like '%Viet%'
order by 1,2

--looking at total_case vs Population
--show what	percentage of population in Vietnam got Covid
select location, date,population, total_cases, (total_cases/population)*100 as PercentagePopulation
from dbo.CovidDeaths
where location like '%Viet%'
order by 1,2

--looking at Countries with Highest Infection Rate compare to Poulation
select location,population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfection
from dbo.CovidDeaths
--where location like '%Viet%'
group by location,population
order by PercentagePopulationInfection desc


--break things down by continent
--showing Countries with Highest Death Count per Population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from dbo.CovidDeaths
--where location like '%Viet%'
where continent is not null
group by continent
order by TotalDeathCount desc

--global numbers
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from dbo.CovidDeaths
where continent is not null
order by 1,2


------------------------------VACCINE DATASET--------------------


with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
----looking at total population vs vaccination
(select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
--order by 2,3)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac




---temp table
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from  #PercentPopulationVaccinated



----creating view store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from dbo.CovidDeaths dea
join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null











