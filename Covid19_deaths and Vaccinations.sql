Use [PortfolioProject ]

/*
Covid 19 Data Exploration
Skills used: Import Tables with the correct data types, Joins, CTE's, Temp Tables, Windows Functions, Aggregate functions, Creating Views, Converting Data Types

Database source - Link to Dataset: https://ourworldindata.org/covid-deaths
*/

-- Check data with Deaths table and Vaccination table. The result are then ordered by the third and fourth columns.

Select * 
from CovidDeaths 
order by 3,4;

Select * 
from CovidVaccinations 
order by 3,4;

-- GLOBAL NUMBERS
/* Table 1 -Total Cases vs Total Deaths */

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidDeaths
where continent is not null 
order by 1,2

--Selecting specific columns that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
Where continent is not null
order by 1,2

-- Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, CAST(total_deaths AS float)/CAST(total_cases as float)*100 as DeathPercentage
from CovidDeaths
Where continent IS NOT NULL 
and location like '%India%'
order by 1,2

-- Checking INDIA Death rate status
SELECT location, date, total_cases, total_deaths, MAX(CAST(total_deaths AS float)/CAST(total_cases as float))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL 
AND location LIKE '%India%'
GROUP BY location, date, total_cases, total_deaths
ORDER BY 1,2

/* Death rate rised rapidly in 2020 in India, reached the highest point (3.43%) in May and begin to fall back, and stabilize at around 1.45% at the end of 2020
*/

-- Total Cases vs Population
--Shows what percentage of population infected with Covid
Select location, date, population, total_cases, CAST(total_cases AS float)/CAST(population as float)*100 as PercentPopulationInfected
from CovidDeaths
Where location like '%India%'
order by 1,2

/* India population is around 1.417 billion, total cases is around 44.95 million
The percentage of the population currently infected totals about 3.17% in India 
*/

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

)
Select *, (RollingPeopleVaccinated/Population)*100 AS PeopleVaccinatedPercentage
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 AS PeopleVaccinatedPercentage
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


-- Check the View
SELECT * FROM PercentPopulationVaccinated

