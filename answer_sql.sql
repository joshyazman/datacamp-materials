----------------
--Activity 1.2--
----------------
select * from jyazman.horserace limit 5;
select * from jyazman.demographics limit 5;
select * from jyazman.issues limit 5;

select distinct phone_type from jyazman.horserace;
select distinct gender from jyazman.demographics;
select distinct birthright_citizenship from jyazman.issues;

----------------
--Activity 1.3--
----------------
/*
For building out a base file of all polls, we want to do a left join because that 
will preserve all of our responses even if a poll didn't ask the specific issues
in the issues table
*/
create local temp table upshot_polling_base as(
        select 
                h.*
                , d.race_eth
                , d.gender
                , d.age
                , d.education
                , d.party
                , d.region
                , d.turnout
                , i.birthright_citizenship
                , i.check_or_support
        from jyazman.horserace h
        inner join jyazman.demographics d on h.respondent_id = d.respondent_id 
        left join jyazman.issues i on h.respondent_id = i.respondent_id
);

----------------
--Activity 2.1--
----------------
select avg(w_lv) from jyazman.horserace where district = 'azse';

/*select
        ntile(5) over(order by w_lv) weight_quintile
        , avg(w_lv) as avg_weight
from jyazman.horserace
group by w_lv;*/

----------------
--Activity 2.2--
----------------
select 
        response
        , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by 'all'),1) as percent_support
from upshot_polling_base
group by 1
having response in ('Und','Rep','Dem');

----------------
--Activity 2.3--
----------------
select 
        gender
        , response
        , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by gender),1) as percent_support
        , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by 'all'),1) as weighted_share_of_voters
from upshot_polling_base
group by 1, 2
having response in ('Und','Rep','Dem')
order by 1,2;

----------------
--Activity 2.4--
----------------
-- What is the margin for the Democratic candidate in the VA-10th congressional district? hint(`district = 'va10'`)
-- Answer: +6.4
select 
        response
        , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by 'all'),1) as percent_support
from upshot_polling_base
where district = 'va10'
group by 1
having response in ('Und','Rep','Dem')
order by 1,2;

-- How much did support for the Republican candidate in FL 26 move from the first poll to the second?
-- Answer: -3.3
select 
        poll_id
        , response
        , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by poll_id),1) as percent_support
from upshot_polling_base
where district = 'fl26'
group by 1, 2
having response in ('Und','Rep','Dem')
order by 1,2;

----------------
--Activity 3.1--
----------------
select *
from (
        select 
                response
                , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by 'all'),1) as male
        from upshot_polling_base
        where district = 'va10' and gender = 'Male'
        group by 1
        having response in ('Und','Rep','Dem')
        ) as male
inner join (
        select 
                response
                , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by 'all'),1) as female
        from upshot_polling_base
        where district = 'va10' and gender = 'Female'
        group by 1
        having response in ('Und','Rep','Dem')
        ) as female using(response)
;

----------------
--Activity 3.2--
----------------
select
        quintile
        , avg(w_lv)
from (
        select
                ntile(5) over(order by w_lv) as quintile
                , w_lv
        from upshot_polling_base
        group by w_lv
        )
group by 1
order by 1;

----------------
--Activity 3.3--
----------------
select 
        response
        , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by 'all'),1) as percent_support
from upshot_polling_base
where district in (select distinct district from upshot_polling_base group by district having count(*) > 900)
group by 1
having response in ('Und','Rep','Dem')
;
----------------
--Activity 3.4--
----------------
-- step 1
select distinct poll_id from upshot_polling_base where check_or_support != 'NA';
-- step 2
with vote_supp as (
        select
                district
                , check_or_support
                , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by district),1) as percent_support
        from upshot_polling_base
        where poll_id in (select distinct poll_id from upshot_polling_base where check_or_support != 'NA')
        group by 1,2
        )
select * from vote_supp where check_or_support = 'Support';

-- step 3
with vote_supp as (
        select
                district
                , check_or_support
                , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by district),1) as percent_support
        from upshot_polling_base
        where poll_id in (select distinct poll_id from upshot_polling_base where check_or_support != 'NA')
        group by 1,2
        )
select
        s.district
        , percent_support
        , percent_check
        , round(percent_support - percent_check, 1) as margin
from (select district, percent_support from vote_supp where check_or_support = 'Support') s
inner join (select district, percent_support as percent_check from vote_supp where check_or_support = 'Check') c on s.district = c.district
order by margin desc;

----------------
--Activity 4.1--
----------------
select 
        case
                when response = 'Dem' and genballot = 'Dems. take House' then 'Local Dem, National Dem'
                when response = 'Und' and genballot = 'Dems. take House' then 'Local Und, National Dem'
                when response = 'Rep' and genballot = 'Dems. take House' then 'Local Rep, National Dem'
                when response = 'Dem' and genballot = 'Reps. keep House' then 'Local Dem, National Rep'
                when response = 'Und' and genballot = 'Reps. keep House' then 'Local Und, National Rep'
                when response = 'Rep' and genballot = 'Reps. keep House' then 'Local Rep, National Rep'
                else 'Other'
        end as local_partisans
        , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by 'all'),1) as response
from upshot_polling_base
group by 1;

----------------
--Activity 4.2--
----------------
-- Original
select 
        response
        , round(sum(w_lv)*100/sum(sum(w_lv)::float) over(partition by 'all'),1) as percent_support
from upshot_polling_base
where district = 'va10'
group by 1
having response in ('Und','Rep','Dem')
order by 1,2;

-- New
select 
        'va10' as district
        , round(sum(case when response = 'Dem' then w_lv else 0 end)*100/sum(w_lv),1) as dem_support
        , round(sum(case when response = 'Rep' then w_lv else 0 end)*100/sum(w_lv),1) as rep_support
from upshot_polling_base
where response in ('Und','Rep','Dem') and district = 'va10';

----------------
--Activity 4.3--
----------------
select 
        'va10' as group_name
        , round(sum(case when response = 'Dem' then w_lv else 0 end)*100/sum(w_lv),1) as dem_support
        , round(sum(case when response = 'Rep' then w_lv else 0 end)*100/sum(w_lv),1) as rep_support
from upshot_polling_base
where response in ('Und','Rep','Dem') and district = 'va10'

union

select 
        gender as group_name
        , round(sum(case when response = 'Dem' then w_lv else 0 end)*100/sum(w_lv),1) as dem_support
        , round(sum(case when response = 'Rep' then w_lv else 0 end)*100/sum(w_lv),1) as rep_support
from upshot_polling_base
where response in ('Und','Rep','Dem') and district = 'va10'
group by 1;

----------------
--Activity 4.4--
----------------
select 
        1 as group_order
        , 'va10' as group_name
        , round(sum(case when response = 'Dem' then w_lv else 0 end)*100/sum(w_lv),1) as dem_support
        , round(sum(case when response = 'Rep' then w_lv else 0 end)*100/sum(w_lv),1) as rep_support
from upshot_polling_base
where response in ('Und','Rep','Dem') and district = 'va10'

union

select 
        2 as group_order
        ,gender as group_name
        , round(sum(case when response = 'Dem' then w_lv else 0 end)*100/sum(w_lv),1) as dem_support
        , round(sum(case when response = 'Rep' then w_lv else 0 end)*100/sum(w_lv),1) as rep_support
from upshot_polling_base
where response in ('Und','Rep','Dem') and district = 'va10'
group by 1, 2

union

select 
        3 as group_order
        , age as group_name
        , round(sum(case when response = 'Dem' then w_lv else 0 end)*100/sum(w_lv),1) as dem_support
        , round(sum(case when response = 'Rep' then w_lv else 0 end)*100/sum(w_lv),1) as rep_support
from upshot_polling_base
where response in ('Und','Rep','Dem') and district = 'va10'
group by 1, 2

union

select 
        4 as group_order
        , race_eth as group_name
        , round(sum(case when response = 'Dem' then w_lv else 0 end)*100/sum(w_lv),1) as dem_support
        , round(sum(case when response = 'Rep' then w_lv else 0 end)*100/sum(w_lv),1) as rep_support
from upshot_polling_base
where response in ('Und','Rep','Dem') and district = 'va10'
group by 1, 2
order by 1;
