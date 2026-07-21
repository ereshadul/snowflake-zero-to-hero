# Task 122 — Query tagging & cost attribution

**Category:** FinOps

## Goal
Using `QUERY_TAG` and object tags to attribute warehouse spend back to
a team, project, or workload — the chargeback/showback pattern real
platform teams use to answer "who's actually spending our credits."

## Steps
1. Run `123_query_tagging_cost_attribution.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `123_query_tagging_cost_attribution.sql` — three
questions on trusting session-set tags vs. admin-assigned object tags,
attributing cost when teams share a warehouse, and how tagging differs
in purpose from a resource monitor.
