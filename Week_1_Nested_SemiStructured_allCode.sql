-- flatten the cell_phone array column to work with each value
select 
    customer_id,
    flat_cell_phone.*
from vk_data.examples.customer_details
, table(flatten(cell_phone)) as flat_cell_phone

-- view a table with an OBJECT column that stores JSON
select 
    customer_id,
    employment_history
from vk_data.examples.customer_employment

-- JSON query to display attributes
select 
    customer_id,
    flat_history.value,
    flat_history.value:employer as employer,
    flat_history.value:title as job_title
from vk_data.examples.customer_employment
, table(flatten(employment_history:jobs)) as flat_history

-- VARIANT query to flatten an array
select 
    customer_id,
    flat_data.value
from vk_data.examples.customer_variant
, table(flatten(customer_variant)) as flat_data

-- VARIANT query to flatten a group of objects within JSON
select 
    customer_id,
    flat_history.value,
    flat_history.value:employer as employer,
    flat_history.value:title as job_title
from vk_data.examples.customer_variant
, table(flatten(customer_variant:jobs)) as flat_history