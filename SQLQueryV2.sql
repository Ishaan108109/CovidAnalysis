Select*
From PorfolioProject..coviddeaths$	
where continent is not null
order by 3,4

--Select*
--From PorfolioProject..covidvaccinations$	
--order by 3,4

Select location, date,total_cases, new_cases, total_deaths, population
From PorfolioProject..coviddeaths$
where continent is not null
order by 1,2

--Looking at total cases vs total deaths
-- Shows the likelyhood of Dying if You live india and have covid
Select location, date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject..coviddeaths$ 
Where location like '%India%'
and continent is not null
order by 1,2

--Looking at total cases vs population
--Shows what population of the people got covid
Select location, date,population,total_cases, (total_cases/population)*100 as PercentOfPoputlationInfected
From PorfolioProject..coviddeaths$
Where location like '%India%'
and continent is not null
order by 1,2

--Looking at countries with highest infection rate compared to population
Select location,population,MAX(total_cases)as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentOfPoputlationInfected
From PorfolioProject..coviddeaths$
--Where location like '%India%'
where continent is not null
Group by location,population
order by PercentOfPoputlationInfected desc

--Showing the countries with the highest Death count per population

Select location,MAX(cast (total_deaths as int)) as TotalDeathcount
From PorfolioProject..coviddeaths$
where continent is not null
Group by location
order by TotalDeathcount desc

--BREAKING DOWN BY CONTINENT


--showing the continets with the highest death count
Select continent,MAX(cast (total_deaths as int))  as TotalDeathcount
From PorfolioProject..coviddeaths$
where continent is not null 
Group by continent
order by TotalDeathcount desc


--GLOBAL NUMBERS
Select SUM(new_cases) as totalCases,SUM (cast (new_deaths as int)) as totalDeaths,
SUM (cast (new_deaths as int))/SUM(new_cases)*100 as DeathPercentage --,total_cases, total_deaths,(total_cases/population)*100 as PercentOfPoputlationInfected
From PorfolioProject..coviddeaths$
Where continent is not null
--Group By date
order by 1,2


--Looking at total population vs population

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations))OVER(Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
 From PorfolioProject..coviddeaths$ dea
 Join PorfolioProject..covidvaccinations$ vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
order by 2,3

--Use CTE
With PopvsVac (continent, location, Date , population,new_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations))OVER(Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
 From PorfolioProject..coviddeaths$ dea
 Join PorfolioProject..covidvaccinations$ vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
--order by 2,3
)
Select*,(RollingPeopleVaccinated/population)*100
From PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercPopulationVaccinated
Create Table #PercPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercPopulationVaccinated
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations))OVER(Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
 From PorfolioProject..coviddeaths$ dea
 Join PorfolioProject..covidvaccinations$ vac
  On dea.location=vac.location
  and dea.date=vac.date
  --where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/population)*100
From #PercPopulationVaccinated


--Creating view to store dtat for later  visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,new_vaccinations))OVER(Partition by dea.location Order by dea.location,
dea.date) as RollingPeopleVaccinated
 From PorfolioProject..coviddeaths$ dea
 Join PorfolioProject..covidvaccinations$ vac
  On dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated