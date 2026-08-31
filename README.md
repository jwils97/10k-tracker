# 10K Workout Tracker V4

V4 removes all Supabase setup fields from the app and removes teams entirely.

## User experience
- Open app
- Create account or sign in
- Enter your name and plan start date once
- Track workouts

Each account has its own:
- plan start date
- workout completion
- duration logs
- weight logs
- notes
- workout photos
- history

The Supabase Project URL and publishable browser key are embedded in the app.

## Upgrade steps
1. Run `SUPABASE_SETUP_V4.sql` in your existing Supabase project's SQL Editor.
2. Replace the files in your GitHub Pages repository with the V4 files.
3. Commit changes to `main`.
4. Reload the GitHub Pages site / PWA.
5. Create an account.

## Data durability
Supabase is the primary cloud store. The app also keeps a local offline cache and queues offline workout changes. Use Export Full Backup periodically for a JSON copy of your settings, logs, and training plan.

Photos are stored privately in Supabase Storage and the JSON backup contains their storage paths rather than duplicate image files.
