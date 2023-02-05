-- **************************************************************
-- EXPLICIT CONVERSION
-- **************************************************************

-- three ways to convert a string to a date
select cast('2023-01-30' as date);
select '2023-01-30'::date;
select to_date('2023-01-30');

-- three ways to convert a string to a decimal
select cast('123' as integer);
select '123'::integer;
select to_decimal('123');


-- **************************************************************
-- IMPLICIT CONVERSION (COERCION)
-- **************************************************************

-- query to show data types, all fields are in character format
describe table vk_data.examples.type_conversion

-- notice age can be used in a function that expects a numeric value
-- this is implicit conversion at work
select 
    avg(customer_age)
from vk_data.examples.type_conversion 

-- but the sort is not what we expect because age is stored as a varchar
select 
    * 
from vk_data.examples.type_conversion 
order by customer_age

-- we need to explicitly convert the value to sort it correctly
select 
    * 
from vk_data.examples.type_conversion 
order by customer_age::int

-- does not support implicit conversion
select date_part(month, '2023-01-30');
select date_part(month, '2023-01-30'::date);

-- supports implicit conversion
select '123' * 2;   -- string gets converted to integer
select 123 || 456;  -- two integers are converted to varchar in order to concatenate

-- **************************************************************
-- TYPEOF
-- **************************************************************

-- examples of the typeof() function to determine a value's data type
select typeof(cast('89' as integer));
select typeof('89'::integer);
select typeof(to_decimal('89'));

-- use typeof in a query in order to determine a column's data type
select
    recipe_name,
    tag_list,
    typeof(tag_list)
from vk_data.chefs.recipe
limit 10