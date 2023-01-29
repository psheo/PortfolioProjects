select *
from [Portfolio Project]..CovidDeaths
order by 3,4

select *
from [Portfolio Project]..CovidVaccinations
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population 
from [Portfolio Project]..CovidDeaths
order by 1,2

--Looking at the Death Percentage in Germany

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
from [Portfolio Project]..CovidDeaths
where location like '%Germany%'
and continent is not null
order by 1,2

--Looking at the Case Percentage in Germany

 select location, date, total_cases, population, (total_cases/population)*100 AS CasePercentage
from [Portfolio Project]..CovidDeaths
where location like '%Germany%'
and continent is not null
order by 1,2

--looking at the Higest infection rate compared with population

select location, population, MAX(total_cases) AS HIC, MAX((total_cases/population))*100 AS infection_rate
from [Portfolio Project]..CovidDeaths
--where location like '%Germany%'
Group by location,population
order by infection_rate desc

-- Looking at the total deaths in countries

select location, MAX(cast(total_deaths as int)) as Total_deaths
from [Portfolio Project]..CovidDeaths
--where location like '%Germany%'
where continent is not null
Group by location
order by Total_deaths desc

-- Global numbers

select Sum(cast(new_deaths as int)) as total_deaths, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int))/Sum(new_cases)*100 AS DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location like '%Germany%'
where continent is not null
Group by date
--order by 1,2

-- Joining both tables

select *
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date

-- Looking at Total Population Vs Vaccination

select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE

With PopulationVsVaccination (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
from PopulationVsVaccination

-- Temp Table

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated

(

Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric

)

Insert into #PercentPopulationVaccinated

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
order by 2,3

select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating View to store data for later visualizations

create view PercentPopulationVaccinated as

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION by dea.Location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

create view TotalPopVsVaccination as

select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

create view GlobalNumbers as 

select  Sum(cast(new_deaths as int)) as total_deaths, Sum(new_cases) as total_cases, Sum(cast(new_deaths as int))/Sum(new_cases)*100 AS DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location like '%Germany%'
where continent is not null
--Group by date
order by 1,2

create view TotalDeaths as 

select location, MAX(cast(total_deaths as int)) as Total_deaths
from [Portfolio Project]..CovidDeaths
--where location like '%Germany%'
where continent is not null
Group by location
--order by Total_deaths desc