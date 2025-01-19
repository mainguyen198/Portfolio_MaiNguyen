SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;


--Looking at total_cases vs total_deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Ireland%'
ORDER BY 1,2;

-- Looking at the total cases vs the population
-- Show the percentage of population got covid
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%Ireland%'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Ireland%'
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC;





-- Showing countries with highest death count per population
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Ireland%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with highest death count per population
SELECT Continent, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%Ireland%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS
SELECT  SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
--GROUP BY date
ORDER BY 1,2;

-- Looking at total population vs vaccinations
-- USE CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccincated) AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac -- JOIN WITH VACCINATIONS TABLE
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT * , (RollingPeopleVaccincated/Population)*100
FROM PopvsVac
ORDER BY Location,Date;





-- TEMP TABLE


DROP TABLE IF EXISTS  #PercentPopulationVaccinated 
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinatations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac -- JOIN WITH VACCINATIONS TABLE
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated;


-- Creating view to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac -- JOIN WITH VACCINATIONS TABLE
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;

SELECT *
FROM PercentPopulationVaccinated
ORDER BY Location, Date;

