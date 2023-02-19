//explain
select 
    * 
from vk_data.examples.customers as c
join vk_data.examples.orders as o
    on c.customer_id = o.customer_id;