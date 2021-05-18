Select *
From PortfolioProject..CovidDeaths 
where continent is not null
order by 3,4


Select *
From PortfolioProject..CovidVaccinations 
where continent is not null
order by 3,4

--select data that we are going to be using

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at Total Cases vs Total Deaths 

 
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at Total Cases vs Total Deaths in United States

 
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--Considering Total Cases vs Population
--Displaying what percentage of population got Covid

Select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2


--considering Countries with highest infection rate compared to population

Select location,population,Max(total_cases) as HighestInfectioncount,Max((total_cases/population)) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by PercentPopulationInfected Desc


-- Displaying Countries with Highest Death Count per Population

Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount Desc 


-- Let's break things down by continent


--Displaying continents with the highest death count per population

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount Desc


-- more correct version 
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount Desc


--Global Numbers


Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast
(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
group by date
order by 1,2

--- Grand total cases, deaths and death percentage

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Considering Total Population vs Vaccination

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))Over (Partition by dea.location Order by dea.location, dea.date) RollingPeopleVaccinated,
(RollingPeopleVaccinated/population) *100

from PortfolioProject ..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


---USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))Over (Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population) *100

from PortfolioProject ..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
---order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac



---Temp Table

Drop Table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))Over (Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population) *100

from PortfolioProject ..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
---where dea.continent is not null
---order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Creating view to store data for visualizations


Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int))Over (Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
---,(RollingPeopleVaccinated/population) *100

from PortfolioProject ..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from PercentPopulationVaccinated


Create View  GobalNumbers as 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM (new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--order by 1,2

select * 
from GobalNumbers