


WITH events AS (

    SELECT
        event_id,
        session_id,
        event_timestamp,
        TRIM(PARSE_JSON(event_details):"recipe_id", '"') AS recipe_id,
        TRIM(PARSE_JSON(event_details):"event", '"') AS event_type
    FROM VK_DATA.EVENTS.WEBSITE_ACTIVITY
    GROUP BY 1, 2, 3, 4, 5

),

grouped_sessions AS (

    SELECT
        session_id,
        MIN(event_timestamp) AS min_event_timestamp,
        MAX(event_timestamp) AS max_event_timestamp,
        IFF(COUNT_IF(event_type = 'view_recipe') = 0, NULL,
            ROUND(COUNT_IF(event_type = 'search') / COUNT_IF(event_type = 'view_recipe'))) AS searches_per_recipe_view
    FROM events
    GROUP BY session_id

),

fav_recipe AS (

    SELECT
        DATE(event_timestamp) AS event_day,
        recipe_id,
        COUNT(*) AS total_views
    FROM events
    WHERE recipe_id IS NOT NULL
    GROUP BY 1, 2
    QUALIFY ROW_NUMBER() over(partition BY event_day ORDER BY total_views DESC) = 1

),

result AS (

    SELECT
        DATE(min_event_timestamp) AS event_day,
        COUNT(session_id) AS total_sessions,
        ROUND(AVG(DATEDIFF('sec', min_event_timestamp, max_event_timestamp))) AS avg_session_length_sec,
        MAX(searches_per_recipe_view) AS avg_searches_per_recipe_view,
        MAX(recipe_id) AS favorite_recipe
    FROM grouped_sessions
    INNER JOIN fav_recipe ON DATE(grouped_sessions.min_event_timestamp) = fav_recipe.event_day
    INNER JOIN VK_DATA.CHEFS.RECIPE USING (recipe_id)
    GROUP BY 1
)
SELECT *
FROM result;

// Most expensive nodes to run is TableScan on VK_DATA_CHEFS.RECIPE
