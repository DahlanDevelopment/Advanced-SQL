DESCRIBE TABLE VK_DATA.RESOURCES.US_CITIES;

select 
    * 
from vk_data.examples.type_conversion 
order by customer_age;

select 
    * 
from vk_data.examples.type_conversion 
order by customer_age::int;

select *
from vk_data.examples.city_format_one as c1
join vk_data.examples.city_format_two as c2 on upper(c1.city_name) = upper(c2.city_name);

select *
from vk_data.examples.city_format_one as c1
join vk_data.examples.city_format_three as c3 
    on upper(c1.city_name) = substring(upper(c3.city_state_name), 1, charindex(',', c3.city_state_name) - 1);

select * from vk_data.examples.event;

// Taking care of duplicate records by using count distinct
select
    customer_id,
    event_type,
    count(distinct event_date) as total_events
from vk_data.examples.event
group by
    customer_id,
    event_type;

select
    customer_id,
    event_type,
    count(*) as total_events
from 
    (select 
        customer_id,
        event_type,
        event_date
     from vk_data.examples.event
     group by 1, 2, 3) as unique_events
group by
    customer_id,
    event_type;
select
    recipe_name,
    tag_list,
    typeof(tag_list)
from vk_data.chefs.recipe
limit 10


// Here's the Project for Week 1
WITH cities AS (
    SELECT
        UPPER(TRIM(city_name)) AS city_name,
        UPPER(TRIM(STATE_ABBR)) AS state_name,
        lat,
        long
    FROM VK_DATA.RESOURCES.US_CITIES
    QUALIFY ROW_NUMBER() over (partition by UPPER(city_name), UPPER(state_abbr) ORDER BY 1) = 1
    
),