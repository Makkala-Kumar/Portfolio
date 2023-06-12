/* First Looking at Covid Deaths Table*/

Select * from ProjectPortfolio..CovidDeaths
where continent is not null

select location,date,total_cases,new_cases,total_deaths,population
from ProjectPortfolio..CovidDeaths
order by 1,2

--Looking at New Cases Vs New Deaths
--Likelihood of dying if you get Covid in India
set arithabort off
set ansi_warnings off
select location,date,total_deaths,total_cases,
(new_deaths/new_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where location like'%India%'
and continent is not null
order by 1,2

/* Total Deaths vs Total Population

select location,date,total_deaths,total_cases,
(convert(int,total_deaths)/convert(int,total_cases))*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where location like'%India%'
and continent is not null
order by 1,2
*/


--New cases vs Population
--set arithabort off
set ansi_warnings off
select location,date,new_cases,total_cases,total_deaths, population,
(new_cases/population)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where location like'%India%'
order by 1,2

--Looking at countries with highest infection rate
--Population Infected per new cases
Select location, population, MAX(cast(total_cases as int)) as HighestInfected,
MAX((total_cases/population))*100 as PercentagePopulationInfected
from ProjectPortfolio..CovidDeaths
where continent is null
group by location,population
order by PercentagePopulationInfected DESC

--Showing Countries with higesht death population

Select location, MAX(cast(total_deaths as int)) as Deaths
from ProjectPortfolio..CovidDeaths
where continent is null
group by location
order by Deaths DESC

--Selecting highest deaths per continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeaths
from ProjectPortfolio..CovidDeaths
where continent is not null
group by continent
order by TotalDeaths DESC

--Global Death Counts
select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
where continent is not null
--group by date
order by 1,2


/*Looking at Covid Vaccination Table*/

Select *
from ProjectPortfolio..CovidDeaths Dea
Join ProjectPortfolio..CovidVaccinations Vac
	On Dea.location = Vac.location
	and Dea.date = Vac.date


--Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER 
(partition by dea.location order by dea.location,dea.date) PeopleGotVaccinated
--sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location)

from ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and Dea.date = Vac.date
where dea.continent is not null
Order by 1,2,3


--Same one with CTE
--Checking how many people got vaccinated in percentage for every increase in the vaccinations

With PopuVsVacc(Continent, Location, Date, Population, new_vaccinations, PeopleGotVaccinated)
as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER 
(partition by dea.location order by dea.location,dea.date) PeopleGotVaccinated
--sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location)

from ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and Dea.date = Vac.date
where dea.continent is not null
--Order by 1,2,3
)
Select *, (PeopleGotVaccinated/Population)*100 as PercentageOfVaccinated
From PopuVsVacc


--Using Temp Table

Drop table if exists #PercentageOfVaccinated
Create Table #PercentageOfVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_Vaccinations int,
PeopleGotVaccinated int)

Insert into #PercentageOfVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER 
(partition by dea.location order by dea.location,dea.date) PeopleGotVaccinated
--sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location)

from ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and Dea.date = Vac.date
--where dea.continent is not null

Select *, (PeopleGotVaccinated/Population)
from #PercentageOfVaccinated



--Creating View to store data for later Visualizations

Create View PercentageOfVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) OVER 
(partition by dea.location order by dea.location,dea.date) PeopleGotVaccinated
--sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location)

from ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and Dea.date = Vac.date
where dea.continent is not null

Select *
from PercentageOfVaccinated
