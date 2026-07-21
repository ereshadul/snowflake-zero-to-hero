# Task 76 — CHANGE_TRACKING & the CHANGES() clause

**Category:** Streams

## Goal
CHANGE_TRACKING = TRUE and the CHANGES() clause -- tracking a table's history without creating a Stream object, and when that's the better fit.

**Real-world scenario:** You need to check "what changed on this table
since yesterday" just once, for a one-off investigation — creating and
maintaining a whole Stream object for a single ad hoc check is
overkill. CHANGES() gives you the same change data at query time, no
object to manage.

## Steps
1. Run `77_change_tracking_on_table.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `77_change_tracking_on_table.sql` — three questions
closing out the Streams category, on statelessness, when a real Stream
still wins, and the bookkeeping CHANGES() puts on you instead.
