# Task 77 — No-schedule/triggered tasks

**Category:** Tasks, deeper

## About this category — Tasks, deeper
Tasks 77-82 go past Task 3's basics into more advanced task mechanics
— DAGs, conditional logic, monitoring, compute choice, and load
strategy.

## Goal
Tasks that fire on a stream having data instead of a fixed schedule.

**Real-world scenario:** Waiting up to a full minute for new data to
process (Task 71's fixed schedule) is fine for some pipelines and too
slow for others. This task tests whether a schedule-free, purely
stream-triggered task reacts meaningfully faster.

## Steps
1. Requires Tasks 69-71 already done — reuses STREAM_DEMO_SOURCE,
   STREAM_DEMO_STREAM, and STREAM_DEMO_HISTORY.
2. Run `78_task_no_schedule_triggered.sql`. **Suspend the task at the
   end.**
3. Answer the understanding check below before moving to the next task.

## Understanding check
See the bottom of `78_task_no_schedule_triggered.sql` — three
questions on whether a schedule-free task is even supported on your
account, its actual reaction latency, and when a fixed schedule still
wins.
