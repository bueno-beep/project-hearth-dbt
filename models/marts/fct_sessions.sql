with sessions as (
    select
        session_key,
        user_pseudo_id,
        session_id,
        min(event_ts) as session_start,
        max(event_ts) as session_end,
        timestamp_diff(max(event_ts), min(event_ts), second) as session_duration_sec,
        count(*) as event_count,
        countif(event_name = 'purchase') > 0 as has_purchase,
        sum(if(event_name = 'purchase', purchase_revenue, 0)) as revenue,
        any_value(device_category) as device_category,
        any_value(country) as country,
        any_value(source) as source,
        any_value(medium) as medium
    from {{ ref('stg_ga4__events') }}
    where session_id is not null
    group by session_key, user_pseudo_id, session_id
)

select
    *,
    case
        when medium = 'cpc' then 'Paid Search'
        when medium = 'organic' then 'Organic Search'
        when medium = 'referral' then 'Referral'
        when source = '(direct)' and medium = '(none)' then 'Direct'
        else 'Unknown (obfuscated)'
    end as channel_group
from sessions