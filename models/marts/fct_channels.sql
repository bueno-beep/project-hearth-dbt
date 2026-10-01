select
    channel_group,
    source,
    medium,
    count(*) as sessions,
    countif(has_purchase) as purchasing_sessions,
    safe_divide(countif(has_purchase), count(*)) as conversion_rate,
    sum(revenue) as revenue
from {{ ref('fct_sessions') }}
group by channel_group, source, medium