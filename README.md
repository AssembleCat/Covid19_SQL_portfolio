-RESOURCES AND TOOLS 
다음의 자료와 개발도구를 사용했음을 밝힙니다.
- https://ourworldindata.org/covid-death
- Microsoft SQL Server management studio



Select *
From PortfolioProject_1..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we use
-- 사용할 데이터들 확인

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject_1..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths
-- 치사율 지표

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject_1..CovidDeaths
Where location like '%korea%'
and continent is not null 
order by 1,2


-- Total Cases vs Population
-- 감염율 지표

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject_1..CovidDeaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population
-- 인구대비 가장 높은 감염율을 보인 비율을 골라냄(각 나라당 1개의 데이터) + date도 함께 표현하려면 나라가 중복되어 표현되는 문제가 있음

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject_1..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population
-- 각 나라별 누적 사망자 수

Select Location, MAX(cast(Total_deaths as float)) as TotalDeathCount
From PortfolioProject_1..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
-- 각 대륙별 사망자 숫자


Select continent, MAX(cast(Total_deaths as float)) as TotalDeathCount
From PortfolioProject_1..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
-- 총 감염자, 총 사망자를 통한 종합 치사율

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject_1..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- 코로나 백신이 각 나라에 들어온 시점과 수량을 파악하고 총 접종자 수를 파악(백신이 들어온것을 단순 합계하는 것이므로 실제 데이터와 오차가 존재할 수 있음)
-- OVER 함수에 대한 이해가 필요함.

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
-- numeric 소수점 설정

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

-- Select *, (RollingPeopleVaccinated/Population)*100
-- From #PercentPopulationVaccinated




