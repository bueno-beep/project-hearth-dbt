-- Funnel counts and step-to-step conversion for all sessions, by device and by channel group.
with segmented as (
    select
        'overall' as dimension,
        'all' as segment,
        viewed_item, added_to_cart, began_checkout, purchased
    from {{ ref('fct_session_funnel') }}

    union all

    select
        'device' as dimension,
        device_category as segment,
        viewed_item, added_to_cart, began_checkout, purchased
    from {{ ref('fct_session_funnel') }}

    union all

    select
        'channel' as dimension,
        channel_group as segment,
        viewed_item, added_to_cart, began_checkout, purchased
    from {{ ref('fct_session_funnel') }}
)

select
    dimension,
    segment,
    count(*) as sessions,
    countif(viewed_item) as view_item_sessions,
    countif(added_to_cart) as add_to_cart_sessions,
    countif(began_checkout) as begin_checkout_sessions,
    countif(purchased) as purchase_sessions,
    safe_divide(countif(viewed_item), count(*)) as session_to_view_rate,
    safe_divide(countif(added_to_cart), countif(viewed_item)) as view_to_cart_rate,
    safe_divide(countif(began_checkout), countif(added_to_cart)) as cart_to_checkout_rate,
    safe_divide(countif(purchased), countif(began_checkout)) as checkout_to_purchase_rate,
    safe_divide(countif(purchased), countif(viewed_item)) as view_to_purchase_rate
from segmented
group by dimension, segment
