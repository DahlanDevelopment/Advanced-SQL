// US Cities
-- SELECT 
--     INITCAP(TRIM(city_name)) AS city_name,
--     UPPER(TRIM(state_abbr)) AS state_abbr,
--     geo_location
-- FROM VK_DATA.RESOURCES.US_CITIES
-- LIMIT 10;

// Customers with Address
-- SELECT 
--     cust_data.customer_id AS customer_id,
--     cust_data.first_name AS customer_firstname,
--     cust_data.last_name AS customer_lastname,
--     cust_data.email AS customer_email,
--     TRIM(UPPER(cust_add.customer_city)) AS customer_city,
--     cust_add.customer_state
-- FROM VK_DATA.CUSTOMERS.CUSTOMER_DATA AS cust_data
-- JOIN VK_DATA.CUSTOMERS.CUSTOMER_ADDRESS AS cust_add
--     ON cust_data.customer_id = cust_add.customer_id
-- LIMIT 10;

-- impacted us cities
-- SELECT 
--     INITCAP(TRIM(city_name)) AS city_name,
--     UPPER(TRIM(state_abbr)) AS state_abbr,
--     lat,
--     long,
--     geo_location
-- FROM VK_DATA.RESOURCES.US_CITIES
-- WHERE 
--     (city_name = 'CHICAGO' AND state_abbr = 'IL') OR
--     (city_name = 'GARY' AND state_abbr = 'IN') OR
--     ((city_name = 'CONCORD' OR city_name = 'ASHLAND') AND state_abbr = 'KY') OR
--     (city_name = 'PLEASANT HILL' AND state_abbr = 'CA') OR
--     ((city_name = 'BROWNSVILLE' OR city_name = 'ARLINGTON') AND state_abbr = 'TX')
-- LIMIT 10;

-- SELECT CITY_NAME
-- FROM VK_DATA.RESOURCES.US_CITIES
-- WHERE STATE_ABBR = 'KY'
-- ORDER BY CITY_NAME;

// Customer preferences
-- select 
--     customer_id,
--     count(*) as food_pref_count
-- from vk_data.customers.customer_survey
-- where is_active = true
-- group by customer_id

-- select 
--     geo_location
-- from VK_DATA.RESOURCES.US_CITIES 
-- where 
--     city_name = 'CHICAGO' 
--     and state_abbr = 'IL'

SELECT 
                INITCAP(TRIM(city_name)) AS city_name,
                UPPER(TRIM(state_abbr)) AS state_abbr,
                lat,
                long,
                geo_location
            FROM VK_DATA.RESOURCES.US_CITIES
            WHERE 
                (city_name = 'CHICAGO' AND state_abbr = 'IL') OR
                (city_name = 'GARY' AND state_abbr = 'IN') OR
                ((city_name = 'CONCORD' OR city_name = 'ASHLAND') AND state_abbr = 'KY') OR
                ((city_name = 'PLEASANT HILL' OR city_name = 'OAKLAND') AND state_abbr = 'CA') OR
                (city_name = 'ARLINGTON' AND state_abbr = 'TX') OR
                city_name = 'BROWNSVILLE'