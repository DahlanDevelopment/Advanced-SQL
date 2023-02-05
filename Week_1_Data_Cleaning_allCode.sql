-- **************************************************************
-- INCONSISTENT DATA
-- **************************************************************

-- "AUSTIN" vs. "Austin"
select *
from vk_data.examples.city_format_one as c1
join vk_data.examples.city_format_two as c2 on upper(c1.city_name) = upper(c2.city_name);

-- "AUSTIN" vs. "AUSTIN, TX"
select *
from vk_data.examples.city_format_one as c1
join vk_data.examples.city_format_three as c3 
    on upper(c1.city_name) = substring(upper(c3.city_state_name), 1, charindex(',', c3.city_state_name) - 1);

-- **************************************************************
-- DATA IN THE WAREHOUSE DOES NOT MATCH THE SOURCE
-- **************************************************************

-- view the duplicate data in the event table
select * from vk_data.examples.event;

-- count distinct events by customer by using distinct
select
    customer_id,
    event_type,
    count(distinct event_date) as total_events
from vk_data.examples.event
group by
    customer_id,
    event_type;
  
-- count distinct events by customer by using group by  
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

-- **************************************************************
-- MISSING DATA
-- **************************************************************

-- order totals by customer, accounting for customers without orders
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