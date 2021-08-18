Select *
From PortfolioProject_1..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we use
-- ����� �����͵� Ȯ��

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject_1..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- ġ���� ��ǥ

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject_1..CovidDeaths
Where location like '%korea%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- ������ ��ǥ

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject_1..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
-- �α���� ���� ���� �������� ���� ������ ���(�� ����� 1���� ������) + date�� �Բ� ǥ���Ϸ��� ���� �ߺ��Ǿ� ǥ���Ǵ� ������ ����

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject_1..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
-- �� ���� ���� ����� ��

Select Location, MAX(cast(Total_deaths as float)) as TotalDeathCount
From PortfolioProject_1..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
-- �� ����� ����� ����


Select continent, MAX(cast(Total_deaths as float)) as TotalDeathCount
From PortfolioProject_1..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
-- �� ������, �� ����ڸ� ���� ���� ġ����

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject_1..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- �ڷγ� ����� �� ���� ���� ������ ������ �ľ��ϰ� �� ������ ���� �ľ�(����� ���°��� �ܼ� �հ��ϴ� ���̹Ƿ� ���� �����Ϳ� ������ ������ �� ����)
-- OVER �Լ��� ���� ���ذ� �ʿ���.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortfolioProject_1..CovidDeaths dea
Join PortfolioProject_1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
and vac.new_vaccinations is not null
order by 2,3



-- Using Temp Table to perform Calculation on Partition By in previous query
-- numeric �Ҽ��� ����

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
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by  dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject_1..CovidDeaths dea
Join PortfolioProject_1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

