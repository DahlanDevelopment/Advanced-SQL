WITH
    impacted_cities AS (
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
    ),
    chicago_location AS (
        SELECT 
            geo_location
        FROM impacted_cities 
        WHERE 
            city_name = 'Chicago' 
            and state_abbr = 'IL'
    ),
    gary_location AS (
        SELECT 
            geo_location
        FROM impacted_cities 
        WHERE 
            city_name = 'Gary' 
            and state_abbr = 'IN'
    ),
    customer_with_address AS (
        SELECT 
            cust_data.customer_id AS customer_id,
            cust_data.first_name AS customer_firstname,
            cust_data.last_name AS customer_lastname,
            cust_data.email AS customer_email,
            TRIM(UPPER(cust_add.customer_city)) AS customer_city,
            cust_add.customer_state AS customer_state
        FROM VK_DATA.CUSTOMERS.CUSTOMER_DATA AS cust_data
        JOIN VK_DATA.CUSTOMERS.CUSTOMER_ADDRESS AS cust_add
            ON cust_data.customer_id = cust_add.customer_id
    ),
    customer_with_address_geo AS (
        SELECT
            cwa.customer_id AS customer_id,
            cwa.customer_firstname AS customer_firstname,
            cwa.customer_lastname AS customer_lastname,
            cwa.customer_city AS customer_city,
            cwa.customer_state AS customer_state,
            uc.lat AS customer_lat,
            uc.long AS customer_long,
            uc.geo_location AS customer_geo
        FROM customer_with_address AS cwa
        JOIN VK_DATA.RESOURCES.US_CITIES AS uc
            ON LOWER(cwa.customer_city) = LOWER(uc.city_name)
            AND UPPER(cwa.customer_state) = UPPER(uc.state_abbr)
    ),
    affected_customers AS (
        SELECT
            cwag.customer_id,
            cwag.customer_firstname || ' ' || cwag.customer_lastname AS customer_name,
            cwag.customer_lat,
            cwag.customer_long,
            cwag.customer_geo,
            ic.city_name AS customer_city,
            ic.state_abbr AS customer_state
        FROM customer_with_address_geo AS cwag
        JOIN impacted_cities AS ic
            ON UPPER(cwag.customer_city) = UPPER(ic.city_name)
                AND UPPER((cwag.customer_state)) = UPPER(ic.state_abbr)
    ),
    active_customer_survey_preferences AS (
        SELECT 
            customer_id,
            count(*) as food_pref_count
        FROM vk_data.customers.customer_survey
        WHERE is_active = true
        GROUP BY customer_id
    )
    SELECT 
        affected_customers.customer_name as customer_name,
        affected_customers.customer_city AS customer_city,
        affected_customers.customer_state AS customer_state,
        active_customer_survey_preferences.food_pref_count AS count_food_preference,
        (st_distance(affected_customers.customer_geo, chicago_location.geo_location) / 1609)::int AS miles_from_chicago_site,
        (st_distance(affected_customers.customer_geo, gary_location.geo_location) / 1609)::int as miles_from_gary_site
    FROM affected_customers
    INNER JOIN active_customer_survey_preferences
        ON affected_customers.customer_id = active_customer_survey_preferences.customer_id
    CROSS JOIN chicago_location
    CROSS JOIN gary_location
    ;
