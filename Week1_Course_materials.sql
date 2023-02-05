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
    c.customer_id,
    c.customer_name,
    count(o.order_id) as order_count,
    sum(coalesce(o.order_amount, 0)) as total_orders
from vk_data.examples.customers as c
left join vk_data.examples.orders as o on c.customer_id = o.customer_id
group by 
    c.customer_id,
    c.customer_name;
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
    
);

// Pivoting
select 
    video_name,
    date_part(month, view_date) as view_month,
    count(*) as total_views
from vk_data.examples.video_views
group by 
    video_name,
    view_month;

select
    *
from
    (select 
        video_name,
        date_part(month, view_date) as view_month,
        count(*) as total_views
    from vk_data.examples.video_views
    group by 
        video_name,
        view_month) views_by_month
pivot( sum(total_views) 
    for view_month in (1, 2, 3)) 
    as pivot_values (video_name, january_views, february_views, march_views);

select
    *
from vk_data.examples.facebook_marketing;

select
    'facebook' as marketing_channel,
    activity_date,
    total_type,
    total_value
from vk_data.examples.facebook_marketing
unpivot 
    (total_value for total_type in (
        total_spend, total_impressions, total_clicks, total_sales
    )
 ) unpivoted_data;

 select
    activity_date,
    sum(activity_total) as total_spend
from vk_data.examples.facebook_marketing
where activity_type = 'total_spend'
group by activity_date
order by activity_date;

select 
    customer_id,
    flat_cell_phone.*
from vk_data.examples.customer_details
, table(flatten(cell_phone)) as flat_cell_phone;

select 
    customer_id,
    first_name,
    last_name,
    employment_history
from vk_data.examples.customer_employment;

select 
    customer_id,
    flat_history.value,
    flat_history.value:employer as employer,
    flat_history.value:title as job_title
from vk_data.examples.customer_employment
, table(flatten(employment_history:jobs)) as flat_history;

select 
    customer_id,
    flat_data.value
from vk_data.examples.customer_variant
, table(flatten(customer_variant)) as flat_data;


select 
    customer_id,
    flat_history.value,
    flat_history.value:employer as employer,
    flat_history.value:title as job_title
from vk_data.examples.customer_variant
, table(flatten(customer_variant:jobs)) as flat_history;