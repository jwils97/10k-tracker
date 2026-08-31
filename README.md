# 10K Workout Tracker V3

V3 adds separate Jonathan/Nicole accounts, a shared training team, durable Supabase cloud storage, private photo storage, offline caching/queued writes, realtime synchronization, and a full JSON backup export.

Swimming has been completely removed from the 10-week plan. Those days were replaced with easy cycling, walking, mobility, and core work.

## Setup
1. Run SUPABASE_SETUP_V3.sql in the Supabase SQL Editor.
2. Replace your GitHub Pages repository files with the V3 files.
3. Open the PWA and enter the Project URL plus publishable/anon key.
4. Jonathan creates his own account and then creates the training team.
5. Copy the 8-character join code from Settings.
6. Nicole creates her own account and joins with that code.
7. Each person now records only their own completion/results, while both can see the team's records.

## Data durability
Supabase Postgres is the main source of truth. Each phone also has a local cache and queues workout changes made while offline. Use Export Full Backup periodically to download a JSON copy of team settings, members, all workout logs, and the complete plan.

Workout images remain in the private Supabase Storage bucket; the backup contains their storage paths, not duplicate image bytes.

## Security
The SQL enables Row Level Security. Team members can read shared team information. Each authenticated user can write only their own workout log rows. Photos are private and scoped by team ID and user ID. Never put a service-role key in the browser app.
