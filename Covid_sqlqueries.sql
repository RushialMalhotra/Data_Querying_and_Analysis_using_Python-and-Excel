--The following is the set of SQL queries used for the analysis of Covid data across the World. 
--Data Source : https://ourworldindata.org/covid-deaths. 
--db.name : Portfolio_Project. Tables used : covid_deaths & covid_vaccination
--The following queries were executed on Sql-Server to develop insights on covid deaths, covid cases and it's affect on a global level.
--Future prospect : These SQL queries can be used to create data visualizations for a better end-user understanding.


--1. Viewing both tables before querying

Select *
From Portfolio_Project..covid_deaths
order by 1,2

Select *
From Portfolio_Project..covid_vaccination
order by 1,2

--2. Select data which we are going to use

Select location, date, total_cases,new_cases, total_deaths, population
From Portfolio_Project..covid_deaths
where continent is not null
order by 1,2


-- 3. Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project..covid_deaths
where location = 'india'
order by 1,2


-- 4. Looking at Total Cases vs Population

Select location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
From Portfolio_Project..covid_deaths
where location = 'india'
order by 1,2


--5. Looking at Countries with Highest Infection rate compared to the Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPerPopulation
From Portfolio_Project..covid_deaths
Group by location, population
Order by PercentPerPopulation desc


--6. Looking at Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..covid_deaths
where continent is not null
Group by location
Order by TotalDeathCount desc


--7. Looking at Death Count per Continent

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio_Project..covid_deaths
where continent is not null
Group by continent
Order by TotalDeathCount desc


--8. Global Numbers on basis of time(Date of contraction)

Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project..covid_deaths
where continent is not null
Group by date
Order by 1,2


--9. Total infection and deaths on the global level

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100 as DeathPercentage
From Portfolio_Project..covid_deaths
where continent is not null
Order by 1,2


--10. Looking at TotalPopulation vs Vaccinations

Select dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations, 
SUM(Convert(int,vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_deaths as dea
Join Portfolio_Project..covid_vaccination as vacc
on dea.date = vacc.date
and dea.location = vacc.location
where dea.continent is not null
Order by 2,3


--11. Using CTE

With PopvsVacc (Continent, Location, Date, population, New_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations, 
SUM(Convert(int,vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_deaths as dea
Join Portfolio_Project..covid_vaccination as vacc
on dea.location = vacc.location
where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVacc


--12. Using Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations, 
SUM(Convert(int,vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_deaths as dea
Join Portfolio_Project..covid_vaccination as vacc
on dea.location = vacc.location
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--13. Creating view to store data for future visualizations

Create View PercentagePopulationVaccinated As
(
Select dea.continent, dea.location,dea.date, dea.population, vacc.new_vaccinations, 
SUM(Convert(int,vacc.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio_Project..covid_deaths as dea
Join Portfolio_Project..covid_vaccination as vacc
on dea.location = vacc.location 
and dea.date = vacc.date
where dea.continent is not null
)

Select *
From PercentagePopulationVaccinated

