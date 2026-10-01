select
    parse_date('%Y%m%d', event_date) as event_date,
    timestamp_micros(event_timestamp) as event_ts,
    event_name,
    user_pseudo_id,
    (select value.int_value from unnest(event_params) where key = 'ga_session_id') as session_id,
    concat(user_pseudo_id, '-',
        cast((select value.int_value from unnest(event_params) where key = 'ga_session_id') as string)
    ) as session_key,
    (select value.string_value from unnest(event_params) where key = 'page_location') as page_location,
    device.category as device_category,
    geo.country as country,
    traffic_source.source as source,
    traffic_source.medium as medium,
    ecommerce.purchase_revenue_in_usd as purchase_revenue
from {{ source('ga4', 'events') }}
where _table_suffix between '{{ var("start_date") }}' and '{{ var("end_date") }}'


