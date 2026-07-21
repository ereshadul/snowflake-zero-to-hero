# Task 92 — Network policies (conceptual)

**Category:** Security

## Goal
IP allow/block lists at the account or user level (conceptual, since this lab has no VPC).

**⚠️ Safety note:** this task never actually attaches a network policy
to your account or user. A misconfigured IP allow-list can lock you
out of your own trial with no way back in from outside it — everything
here only creates and inspects the policy object.

**Real-world scenario:** A company wants to restrict Snowflake access
to only their office network and VPN ranges — network policies are
how, but getting the IP list wrong the first time is a real,
account-locking mistake, which is exactly why this stays conceptual.

## Steps
1. Run `93_network_policies.sql`.
2. Work through it section by section against your own Snowflake trial
   — don't just read it.
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `93_network_policies.sql` — three questions closing
out the Security category, on the lockout risk, finding your own IP
safely, and why you'd test on one user before going account-wide.
