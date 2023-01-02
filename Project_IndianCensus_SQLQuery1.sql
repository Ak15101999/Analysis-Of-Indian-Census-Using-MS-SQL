select*from Project.dbo.data1
select*from Project.dbo.data2

--no. rows into our dataset
select count(*)from Data1
select count(*)from Data2

-- dataset For Jharkhand And Bihar
select*from Project.dbo.data1 where state in ('Jharkhand','Bihar')

--population of india 
select sum(population) as population from Project.dbo.data2 

--avarage growth of india
Select avg(growth)*100 as avg_growth from Project.dbo.data1

--avg growth by state
select state,avg(growth)*100 as avg_growth From Project.dbo.data1 group by state

--avg sex_ratio
select state,round(avg(sex_ratio),0) as avg_sexratio From Project.dbo.data1 
group by state order by avg_sexratio desc

--avg litaracy ratio
select state, round(avg(Literacy),0) avg_litaracy_ratio from Project.dbo.data1
group by state 
having round (avg(literacy),0)>90 
order by avg_litaracy_ratio desc 

--top 3 state by highest avg growth ratio
select  top 3 state,avg(growth)*100 as avg_growth From Project.dbo.data1 
group by state order by avg_growth desc

--top 3 state by lowest lowest ratio
select top 6 state,round(avg(sex_ratio),0) as avg_sexratio From Project.dbo.data1 
group by state order by avg_sexratio asc

--top and bottom 3 sate in literacy rate

drop table if exists #topstate
create table #topstate
(State nvarchar(255),
topState float
)
Insert Into #topstate
select state, round(avg(Literacy),0) avg_litaracy_ratio from Project.dbo.data1
group by state order by avg_litaracy_ratio desc 

select top 3*from #topstate order by #topstate.topstate desc

drop table if exists #bottomstate
create table #bottomstate
(State nvarchar(255),
bottomstate float
)
Insert Into #bottomstate
select state, round(avg(Literacy),0) avg_litaracy_ratio from Project.dbo.data1
group by state order by avg_litaracy_ratio desc 
select top 6*from #bottomstate order by #bottomstate.bottomstate asc

--union operator 

select*from
(select top 6*from #topstate order by #topstate.topstate desc) a
union
select*from
(select top 6*from #bottomstate order by #bottomstate.bottomstate asc) b

--state starting with letter a
select distinct state from Project..Data1 where lower(state) like 'a%' 
or lower(state) like 'b%'
select distinct state from Project..Data1 where lower(state) like 'a%' 
or lower(state) like '%d'
select distinct state from Project..Data1 where lower(state) like 'a%' 
and lower(state) like '%m'

--joining both state
select d.state,sum(d.males) as total_males,sum(d.females) as Total_females from
(select c.district,c.state,round(c.population/(c.sex_ratio+1),0) as males,
round((c.population*c.sex_ratio)/(c.sex_ratio+1),0) as females from
(select a.district,a.state,a.sex_ratio/1000 sex_ratio,b.Population from Project.dbo.data1 as a
inner join Project.dbo.data2 as b on a.district=b.district ) as c) as d group by d.state

-- total literacy rate

select c.state, sum(LiteratePeople) as total_LP , sum(illitaratePeople) as total_Ilp from
(select d.district,d.state,round(d.literacy_ratio*d.population,0) as LiteratePeople,
round((1-d.literacy_ratio)*d.population,0) as illitaratePeople from
(select a.district,a.state,a.literacy/100 as literacy_ratio,b.Population from Project.dbo.data1 as a
inner join Project.dbo.data2 as b on a.district=b.district) as d) as c group by c.state

--populaton in previous sensus

select sum(m.previous_sensus_populaton) previous_sensus_populaton,
sum(current_sensus_populaton) current_sensus_populaton from
(select e.state,sum(e.previous_sensus_populaton) as previous_sensus_populaton,
sum(e.current_sensus_populaton) as current_sensus_populaton  from
(select d.district,d.state,round(population/(1+d.growth),0) as previous_sensus_populaton,
population current_sensus_populaton from
(select a.district,a.state,a.growth growth,b.Population from Project.dbo.data1 as a
inner join Project.dbo.data2 as b on a.district=b.district) as d) as e group by e.state) as m

--population vs area

select g.total_area/g.previous_sensus_populaton previous_sensus_populaton_vs_area,
g.total_area/g.current_sensus_populaton current_sensus_populaton_vs_area from
(select q.*,r.total_area from(

select '1' as keyy,n.* from
(select sum(m.previous_sensus_populaton) previous_sensus_populaton,
sum(current_sensus_populaton) current_sensus_populaton from
(select e.state,sum(e.previous_sensus_populaton) as previous_sensus_populaton,
sum(e.current_sensus_populaton) as current_sensus_populaton  from
(select d.district,d.state,round(population/(1+d.growth),0) as previous_sensus_populaton,
population current_sensus_populaton from
(select a.district,a.state,a.growth growth,b.Population from Project.dbo.data1 as a
inner join Project.dbo.data2 as b on a.district=b.district) as d) as e 
group by e.state) as m) n) q inner join(

select '1' as keyy,z.* from (
select sum(area_km2) total_area from Project.dbo.data2) as z) r on q.keyy=r.keyy) as g

--window function
select*from Project.dbo.data1
select*from Project.dbo.data2

output top 3 district from each state with highest literacy rate

select a.*from
(select district,state,literacy,
rank() over(partition by state  order by literacy desc) rnk from Project.dbo.data1) a
where a.rnk in (1,2,3) order by state


































