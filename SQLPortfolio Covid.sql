SELECT *
FROM [Portfolio Project]..[Covid Deaths]
WHERe continent is NOT NULL
order by 3,4

--SELECT *
--FROM [Portfolio Project]..[Covid Vaccinations]
--order by 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..[Covid Deaths]
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood dying f you contract Covid in Spain

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..[Covid Deaths]
Where location like '%spain%'
order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of populatiopn got covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..[Covid Deaths]
Where location like '%spain%'
order by 1, 2

-- Looking at countries with highest infection rate comparet to population 

SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercetPopulationInfected
FROM [Portfolio Project]..[Covid Deaths]
GROUP BY Location, Population
order by PercetPopulationInfected desc

-- Showing the countries with Highest Death Count per Population

SELECT Location,MAX (cast (total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..[Covid Deaths]
WHERe continent is NOT NULL
GROUP BY Location, Population
order by TotalDeathCount desc


-- Showing the continent with the highest death count

SELECT continent ,MAX (cast (total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..[Covid Deaths]
WHERe continent is not NULL
GROUP BY continent
order by TotalDeathCount desc

-- Global numbers

SELECT date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..[Covid Deaths]
Where continent is NOT NULL
GROUP BY date
order by 1, 2

SELECT  SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..[Covid Deaths]
Where continent is NOT NULL
--GROUP BY date
order by 1, 2

-- Looking at total vaccination vs population

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
FROM [Covid Deaths] dea
JOIN [Covid Vaccinations] vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3

--USE CTE

With PopvsVac (Continent, Location, date, population, New_Vaccinations, TotalPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
FROM [Covid Deaths] dea
JOIN [Covid Vaccinations] vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)

Select *, (TotalPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
FROM [Covid Deaths] dea
JOIN [Covid Vaccinations] vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Select *, (TotalPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualization 

CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalPeopleVaccinated
FROM [Covid Deaths] dea
JOIN [Covid Vaccinations] vac
	ON dea.Location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

Create View HighestDeathCOunt as
SELECT continent ,MAX (cast (total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..[Covid Deaths]
WHERe continent is not NULL
GROUP BY continent
