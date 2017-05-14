## Borough Stats (2012- 2017)
#################################################
 %sql
select case when length(borough) > 0 then borough else 'UNKNOWN_CITY' end as Borough,sum(no_of_persons_injured) as persons_injured,sum(no_of_persons_killed) as persons_killed,sum(no_of_pedestrians_injured) as pedestrians_injured ,sum(no_of_pedestrians_killed) as pedestrians_killed,sum(no_of_cyclists_injured) as cyclists_injured,sum(no_of_cyclists_killed) as cyclists_killed,sum(no_of_motorists_injured) as motorists_injured,sum(no_of_motorists_killed) as motorists_killed from kbohra_db.nypd_mvc where borough<>'0' group by borough sort by borough


## Top Ten Accident prone zipcodes in (2012-2017)
##################################################
%sql
select case when length(zipcode) > 0 then zipcode else 'unknown_zipcode' end as zipcode, sum(no_of_persons_killed+no_of_pedestrians_killed+no_of_cyclists_killed+no_of_motorists_killed) as total_killed,sum(no_of_persons_injured+no_of_pedestrians_injured+no_of_cyclists_injured+no_of_motorists_injured) as total_injured from kbohra_db.nypd_mvc where zipcode <> '0' group by zipcode order by total_killed desc limit 10 


## Accident based on day of week (2012-2017)
###################################################
%sql
select occurence_date,date_format(from_unixtime(unix_timestamp(occurence_date,'MM/dd/yyyy'), 'yyyy-MM-dd'),'EEEE') as day_of_week,sum(no_of_persons_killed+no_of_pedestrians_killed+no_of_cyclists_killed+no_of_motorists_killed) as total_killed,sum(no_of_persons_injured+no_of_pedestrians_injured+no_of_cyclists_injured+no_of_motorists_injured) as total_injured from (select occurence_date,nvl(no_of_persons_killed,0) as no_of_persons_killed,nvl(no_of_pedestrians_killed,0) as no_of_pedestrians_killed,nvl(no_of_cyclists_killed,0) as no_of_cyclists_killed,nvl(no_of_motorists_killed,0) as no_of_motorists_killed,nvl(no_of_persons_injured,0) as no_of_persons_injured,nvl(no_of_pedestrians_injured,0) as no_of_pedestrians_injured,nvl(no_of_cyclists_injured,0) as no_of_cyclists_injured,nvl(no_of_motorists_injured,0) as no_of_motorists_injured from kbohra_db.nypd_mvc where zipcode <> '0') t group by occurence_date sort by day_of_week desc


## Top 10 dates with highest kills (2012-2017)
####################################################
%sql
select occurence_date,sum(no_of_persons_killed+no_of_pedestrians_killed+no_of_cyclists_killed+no_of_motorists_killed) as total_killed,sum(no_of_persons_injured+no_of_pedestrians_injured+no_of_cyclists_injured+no_of_motorists_injured) as total_injured from (select occurence_date,nvl(no_of_persons_killed,0) as no_of_persons_killed,nvl(no_of_pedestrians_killed,0) as no_of_pedestrians_killed,nvl(no_of_cyclists_killed,0) as no_of_cyclists_killed,nvl(no_of_motorists_killed,0) as no_of_motorists_killed,nvl(no_of_persons_injured,0) as no_of_persons_injured,nvl(no_of_pedestrians_injured,0) as no_of_pedestrians_injured,nvl(no_of_cyclists_injured,0) as no_of_cyclists_injured,nvl(no_of_motorists_injured,0) as no_of_motorists_injured from kbohra_db.nypd_mvc where zipcode <> '0') t group by occurence_date sort by total_killed desc limit 10


## Killed v/s Injured yearly stats (2012-2017)
####################################################
.%sql
select year,sum(no_of_persons_killed+no_of_pedestrians_killed+no_of_cyclists_killed+no_of_motorists_killed) as total_killed,sum(no_of_persons_injured+no_of_pedestrians_injured+no_of_cyclists_injured+no_of_motorists_injured) as total_injured from (select date_format(from_unixtime(unix_timestamp(occurence_date,'MM/dd/yyyy'), 'yyyy-MM-dd'),'y') as year,nvl(no_of_persons_killed,0) as no_of_persons_killed,nvl(no_of_pedestrians_killed,0) as no_of_pedestrians_killed,nvl(no_of_cyclists_killed,0) as no_of_cyclists_killed,nvl(no_of_motorists_killed,0) as no_of_motorists_killed,nvl(no_of_persons_injured,0) as no_of_persons_injured,nvl(no_of_pedestrians_injured,0) as no_of_pedestrians_injured,nvl(no_of_cyclists_injured,0) as no_of_cyclists_injured,nvl(no_of_motorists_injured,0) as no_of_motorists_injured from kbohra_db.nypd_mvc where zipcode <> '0') t group by year sort by year desc


## Top 5 reasons each year for accidents (2012-2017)
#####################################################
%sql
select year,cnt_fact_vehicle1,cnt_fact_vehicle2,cnt_fact_vehicle3,total_killed,total_injured,rank from
(select year,cnt_fact_vehicle1,cnt_fact_vehicle2,cnt_fact_vehicle3,total_killed,total_injured,rank() over (partition by year order by a.total_killed desc,a.total_injured desc) as rank from (
select year,cnt_fact_vehicle1,cnt_fact_vehicle2,cnt_fact_vehicle3,sum(no_of_persons_killed+no_of_pedestrians_killed+no_of_cyclists_killed+no_of_motorists_killed) as total_killed,sum(no_of_persons_injured+no_of_pedestrians_injured+no_of_cyclists_injured+no_of_motorists_injured) as total_injured from (select date_format(from_unixtime(unix_timestamp(occurence_date,'MM/dd/yyyy'), 'yyyy-MM-dd'),'y') as year,case when length(cnt_fact_vehicle1)=0 or cnt_fact_vehicle1='0' then 'No Fault' else cnt_fact_vehicle1 end as cnt_fact_vehicle1  ,case when  length(cnt_fact_vehicle2)=0 then 'No Fault' else cnt_fact_vehicle2 end as cnt_fact_vehicle2,case when length(cnt_fact_vehicle3)='0' then 'No Fault' else cnt_fact_vehicle3 end as cnt_fact_vehicle3,nvl(no_of_persons_killed,0) as no_of_persons_killed,nvl(no_of_pedestrians_killed,0) as no_of_pedestrians_killed,nvl(no_of_cyclists_killed,0) as no_of_cyclists_killed,nvl(no_of_motorists_killed,0) as no_of_motorists_killed,nvl(no_of_persons_injured,0) as no_of_persons_injured,nvl(no_of_pedestrians_injured,0) as no_of_pedestrians_injured,nvl(no_of_cyclists_injured,0) as no_of_cyclists_injured,nvl(no_of_motorists_injured,0) as no_of_motorists_injured from kbohra_db.nypd_mvc where zipcode <> '0') t where !((cnt_fact_vehicle1== 'No Fault' or cnt_fact_vehicle1=='Unspecified') and (cnt_fact_vehicle2== 'No Fault' or cnt_fact_vehicle2=='Unspecified') and (cnt_fact_vehicle3== 'No Fault' or cnt_fact_vehicle3=='Unspecified')) group by year,cnt_fact_vehicle1,cnt_fact_vehicle2,cnt_fact_vehicle3 sort by total_killed desc,total_injured desc) a ORDER BY total_killed desc,total_injured desc) t where rank < 4




