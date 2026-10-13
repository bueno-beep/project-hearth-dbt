-- One row per session with a true/false flag for each funnel step.
-- Flags are independent: a session counts at a step if it fired that event.
with step_flags as (
    select
        session_key,
        countif(event_name = 'view_item') > 0 as viewed_item,
        countif(event_name = 'add_to_cart') > 0 as added_to_cart,
        countif(event_name = 'begin_checkout') > 0 as began_checkout,
        countif(event_name = 'purchase') > 0 as purchased
    from {{ ref('stg_ga4__events') }}
    where session_id is not null
    group by session_key
)

select
    s.session_key,
    date(s.session_start) as session_date,
    coalesce(s.device_category, 'unknown') as device_category,
    s.country,
    s.channel_group,
    f.viewed_item,
    f.added_to_cart,
    f.began_checkout,
    f.purchased
from step_flags as f
inner join {{ ref('fct_sessions') }} as s
    on f.session_key = s.session_key
