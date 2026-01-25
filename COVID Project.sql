Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPersentage 
From PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population got covid 
Select location, date, total_cases, population, (total_cases/population)*100 as DeathPersentage 
From PortfolioProject..CovidDeaths$
where location like '%states%'
order by 1,2


-- Looking at Coumtries with Highest Infection Rate compared to population 

Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 
as PercentagePopulationInfected 
From PortfolioProject..CovidDeaths$
--where location like '%states%'
Group by location, population
order by PercentagePopulationInfected desc


-- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc



-- Break Down by Continents 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is null
Group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 
as DeathPercentage 
From PortfolioProject..CovidDeaths$
--where location like '%states%'
where continent is not null
Group By date 
order by 1,2


-- Total Population vs Vaccinations 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast (vac.new_vaccinations as int )) OVER (partition by dea.Location)
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null 
order by 2,3


-- Use CTE
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations,  RollingPeopleVaccinated)
as (

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated 

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null 
--order by 2,3
)
Select * , (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Temp Table

Create Table #PercentPopulationVaccinated 
(
Continent nvarchar (255),
Location nvarchar(255),
Data datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated 

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null 
--order by 2,3

Select * , (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- View to store data for Later use 

Create View PercentPopulationVaccinated as

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated 

From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location= vac.location
	and dea.date= vac.date
where dea.continent is not null 



Select *
From PercentPopulationVaccinated
