SELECT * 
FROM PortfolioProject..CovDea
WHERE continent is not null
ORDER BY 3,4;

--SELECT * 
--FROM PortfolioProject..CovVac
--ORDER BY 3,4;

--- Data Selection ---

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovDea
WHERE continent is not null
ORDER BY 1, 2;


--- Total Cases vs Total Deaths ---
-- Death perc shows the probability of dying if COVID is contracted. 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_perc
FROM PortfolioProject..CovDea
ORDER BY 1, 2;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_perc
FROM PortfolioProject..CovDea
WHERE location like '%kingdom%'
AND continent is not null
ORDER BY 1, 2;

--- Total Cases vs Population ---
-- percentage of population positive to COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Infect_perc
FROM PortfolioProject..CovDea
WHERE continent is not null
ORDER BY 1, 2;

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Infect_perc
FROM PortfolioProject..CovDea
WHERE location like '%kingdom%'
AND continent is not null
ORDER BY 1, 2;


--- Countries with Highest Infection Rate compared to Population ---
SELECT location, population, MAX(total_cases) AS HIR, MAX((total_cases/population))*100 AS Infect_perc
FROM PortfolioProject..CovDea
--WHERE location like '%kingdom%'
WHERE continent is not null
GROUP BY location, population
ORDER BY Infect_perc DESC;

--- Countries with Highest Death Rate compared to Population ---
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovDea
WHERE continent is not null
--WHERE location like '%kingdom%'
GROUP BY location
ORDER BY TotalDeathCount DESC;


--- Continents with Highest Death Rate compared to Population ---
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovDea
WHERE continent is not null
--WHERE location like '%kingdom%'
GROUP BY continent
ORDER BY TotalDeathCount DESC;


--- Global numbers ---
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, 
SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS death_perc
FROM PortfolioProject..CovDea
--WHERE location like '%kingdom%'
WHERE continent is not null
ORDER BY 1, 2;

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS int)) AS total_deaths, 
SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS death_perc
FROM PortfolioProject..CovDea
--WHERE location like '%kingdom%'
WHERE continent is not null
GROUP BY date
ORDER BY 1, 2;



--- Total Population vs Vaccinations ---

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingVaccinated
--, (RollingVaccinated/population)*100
FROM PortfolioProject..CovDea dea
JOIN PortfolioProject..CovVac vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3;


-- CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingVaccinated
--, (RollingVaccinated/population)*100
FROM PortfolioProject..CovDea dea
JOIN PortfolioProject..CovVac vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2, 3
)
SELECT *, (RollingVaccinated/population)*100
FROM PopvsVac
ORDER BY 2, 3



--- TEMP TABLE ---
DROP Table if exists #PercentPopulationVaccinated 
CREATE Table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingVaccinated
--, (RollingVaccinated/population)*100
From PortfolioProject..CovDea dea
Join PortfolioProject..CovVac vac
   on dea.location = vac.location
   and dea.date = vac.date
--WHERE dea.continent is not null
-- ORDER BY 2, 3

SELECT *, (RollingVaccinated/population)*100
FROM #PercentPopulationVaccinated



--- Creating views for subsequent data visualisations---

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, 
dea.date) as RollingVaccinated
--, (RollingVaccinated/population)*100
From PortfolioProject..CovDea dea
Join PortfolioProject..CovVac vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3