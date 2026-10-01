# Project Hearth: GA4 e-commerce analytics with dbt and BigQuery

A dbt project that turns raw Google Analytics 4 event data into clean session, funnel and channel tables, ready for dashboards.

**Data:** Google's public GA4 sample e-commerce dataset (`bigquery-public-data.ga4_obfuscated_sample_ecommerce`), January 2021 (~118k sessions, ~1,100 purchases).
**Stack:** BigQuery, dbt Core (dbt-bigquery), SQL, Git.

## Lineage

![Lineage graph](docs/lineage.png)

| Model | Type | What it contains |
| --- | --- | --- |
| `stg_ga4__events` | view | One row per event, with the nested GA4 fields (session id, page, device, source) flattened once |
| `fct_sessions` | table | One row per session: duration, event count, purchase flag, revenue, source, medium and a custom `channel_group` |
| `fct_funnel` | table | Daily session counts and step-to-step conversion: view item, add to cart, begin checkout, purchase |
| `fct_channels` | table | Sessions, purchasing sessions, conversion rate and revenue by channel group, source and medium |

## Key decisions

- **Flatten once.** The UNNEST of `event_params` happens only in staging, so the marts stay simple.
- **Sessions, not events.** A session key is `user_pseudo_id` + `ga_session_id`. The funnel counts distinct sessions reaching each step, because one session can fire `view_item` many times.
- **Tests.** `unique` and `not_null` on `fct_sessions.session_key` and `fct_funnel.event_date`.
- **Custom channel grouping.** `channel_group` is a simple rule on medium and source (Paid Search, Organic Search, Referral, Direct, Unknown). It is not Google's official channel definition.

## What the data shows (January 2021)

- Overall session conversion is about 0.9%.
- Organic Search is the largest channel group by revenue (about 17k), followed by Referral (about 14k) and Direct (about 12k).
- Paid Search (cpc) brings 5k sessions but only about 1.8k revenue, with a conversion rate of about 0.7%.
- [Add 1-2 funnel findings from `fct_funnel`, for example the biggest drop-off step.]

## Data limitations

- **Obfuscated values.** Google obfuscated this public sample, so about a third of sessions have a source or medium of `(data deleted)` or `<Other>`. About 20% of sessions land in "Unknown" in `channel_group`.
- **Acquisition channel, not session channel.** In this export, `traffic_source` is the channel that first acquired the user, not the source of each individual session. `fct_channels` is therefore revenue by acquisition channel.
- **One month only.** The date range is set by the `start_date` and `end_date` variables in `dbt_project.yml`. The sample runs Nov 2020 to Jan 2021.

## How to run

```
pip install dbt-bigquery
gcloud auth application-default login
dbt build
```

Set your own project and dataset in `~/.dbt/profiles.yml` (profile name `hearth`, method `oauth`, location `US`).
