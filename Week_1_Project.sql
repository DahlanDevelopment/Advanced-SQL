DESCRIBE TABLE VK_DATA.RESOURCES.US_CITIES;




WITH cities AS (
    SELECT
        UPPER(TRIM(city_name)) AS city_name,
        UPPER(TRIM(STATE_ABBR)) AS state_name,
        lat,
        long
    FROM VK_DATA.RESOURCES.US_CITIES
    QUALIFY ROW_NUMBER() over (partition by UPPER(city_name), UPPER(state_abbr) ORDER BY 1) = 1
    
),

customers AS (
    SELECT c.customer_id, c.first_name, c.last_name, c.email, a.customer_city, a.customer_state
    FROM VK_DATA.CUSTOMERS.CUSTOMER_DATA AS c
    INNER JOIN VK_DATA.CUSTOMERS.CUSTOMER_ADDRESS AS a 
    ON c.customer_id = a.customer_id
    ORDER BY c.last_name ASC
    LIMIT 10
)


SELECT c.customer_id, c.first_name, c.last_name, c.email, a.customer_city, a.customer_state
    FROM VK_DATA.CUSTOMERS.CUSTOMER_DATA AS c
    INNER JOIN VK_DATA.CUSTOMERS.CUSTOMER_ADDRESS AS a 
    ON c.customer_id = a.customer_id
    ORDER BY c.last_name ASC
    LIMIT 10

