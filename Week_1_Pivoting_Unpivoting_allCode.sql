-- **************************************************************
-- PIVOT DATA
-- **************************************************************

-- summarize data to show what it looks like before we pivot
select 
    video_name,
    date_part(month, view_date) as view_month,
    count(*) as total_views
from vk_data.examples.video_views
group by 
    video_name,
    view_month

-- apply a pivot around the existing query
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
    as pivot_values (video_name, january_views, february_views, march_views)

-- **************************************************************
-- UNPIVOT DATA
-- **************************************************************

-- review data from the Facebook report that we imported into the warehouse
select
    *
from vk_data.examples.facebook_marketing

-- unpivot data so we can add it to a table that has data for all marketing platforms
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
 ) unpivoted_data