
SELECT
    TRIM(LOWER(c.city_name)) as city_name,
    TRIM(LOWER(c.state_name)) as state_name,
    geo_location
FROM VK_DATA.RESOURCES.US_CITIES as c;

SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    c.email, 
    TRIM(LOWER(a.customer_city)) AS customer_city, 
    TRIM(LOWER(a.customer_state)) AS customer_state    
FROM VK_DATA.CUSTOMERS.CUSTOMER_DATA AS c
INNER JOIN VK_DATA.CUSTOMERS.CUSTOMER_ADDRESS AS a 
    ON c.customer_id = a.customer_id
ORDER BY c.last_name ASC;

SELECT
        supplier_id,
        supplier_name,
        LOWER(TRIM(supplier_city)) AS supplier_city,
        LOWER(TRIM(supplier_state)) AS supplier_state
    FROM VK_DATA.SUPPLIERS.SUPPLIER_INFO;

SELECT
        LOWER(TRIM(city_name)) AS city_name,
        LOWER(TRIM(state_name)) AS state_name,
        LOWER(TRIM(state_abbr)) as state_abbr,
        lat,
        long,
        geo_location
    FROM VK_DATA.RESOURCES.US_CITIES AS c 