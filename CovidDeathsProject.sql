Select*
FROM CovidDeaths
order by 3,4

--Select*
--FROM CovidVaccinations
--order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
order by 1,2

--looking at total deaths vs total cases
--kemungkinan lo ketam kl kena covid
Select location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
order by 1,2

--looking at total cases vs population
--presentase yg kena covid
Select location, date, total_cases, population, ROUND((total_cases/population)*100,2) as DeatPercentage
FROM CovidDeaths
--WHERE location like '%states%'
order by 1,2

SELECT Location, population, MAX(total_cases)
From CovidDeaths
Group by location,population
order by population desc

--highest death count per population by country
SELECT Location, MAX(cast(total_deaths as int)) as mmk
From CovidDeaths
where continent is not null
Group by location
order by mmk desc

--highest death count per population by continent
SELECT continent, MAX(cast(total_deaths as int)) as mmk
From CovidDeaths
where continent is not null
Group by continent
order by mmk desc

SELECT location, MAX(cast(total_deaths as int)) as mmk
From CovidDeaths
where continent is  null
Group by location
order by mmk desc

--globally
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases)) as deathpercentage
FROM CovidDeaths
WHERE continent is not null
group by date
order by 1,2

--joinan
--brp orang yg dah divaksin totalvac vs totalpop with CTE
WITH PopVsVac (Continent, Location, Date, Population, New_vaccinations, rollingpeoplevaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as rollingpeoplevaccinated
From PortofolioProject..CovidDeaths Dea
Join PortofolioProject..CovidVaccinations Vac
     On Dea.location = Vac.location
And  Dea.date = Vac.date
WHERE Dea.continent is not null
)
Select * , (rollingpeoplevaccinated/Population)*100
FROM PopVsVac

--brp orang yg dah divaksin totalvac vs totalpop with temptables
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations, SUM(CAST(Vac.new_vaccinations as int)) over (partition by Dea.location order by Dea.location, Dea.date) as rollingpeoplevaccinated
From PortofolioProject..CovidDeaths Dea
Join PortofolioProject..CovidVaccinations Vac
     On Dea.location = Vac.location
And  Dea.date = Vac.date

Select * , (rollingpeoplevaccinated/Population)*100
FROM #PercentPopulationVaccinated