with steps as (
    select
        event_date,
        count(distinct if(event_name = 'view_item', session_key, null)) as view_item_sessions,
        count(distinct if(event_name = 'add_to_cart', session_key, null)) as add_to_cart_sessions,
        count(distinct if(event_name = 'begin_checkout', session_key, null)) as begin_checkout_sessions,
        count(distinct if(event_name = 'purchase', session_key, null)) as purchase_sessions
    from {{ ref('stg_ga4__events') }}
    where session_id is not null
    group by event_date
)
select
    *,
    safe_divide(add_to_cart_sessions, view_item_sessions) as view_to_cart_rate,
    safe_divide(begin_checkout_sessions, add_to_cart_sessions) as cart_to_checkout_rate,
    safe_divide(purchase_sessions, begin_checkout_sessions) as checkout_to_purchase_rate
from steps