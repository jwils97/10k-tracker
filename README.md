# 10K Workout Tracker V5

V5 separates app code from workout content.

## What changes
- The 70-workout plan now lives in Supabase (`plan_workouts`) instead of `index.html`.
- Updating a workout no longer requires a GitHub Pages deployment.
- Users do not need to log out or back in after plan edits.
- Realtime subscription refreshes plan changes automatically.
- Calendar tab shows future workouts by date.
- Each workout type has a persistent color:
  - Run: blue
  - Strength: red
  - Bike: green
  - Recovery: purple
  - Race: amber
- The same color appears as a ribbon on workout cards and as a bar/dot in the calendar.
- Tap a calendar date to preview the workout, then tap the workout card to open/log it.
- Admin accounts get an in-app Edit Plan tab.
- Completed workouts save a snapshot of the workout definition so later plan edits do not rewrite historical workout details.

## One-time upgrade
1. Run `SUPABASE_SETUP_V5.sql` in the existing Supabase project's SQL Editor.
2. Replace the GitHub Pages repository files with the V5 files and commit to `main`.
3. Sign in normally.
4. After your account exists, make your account an admin once with this SQL:
   update public.user_settings
   set is_admin = true
   where user_id = (select id from auth.users where email = 'YOUR_EMAIL_HERE');
5. Reload the app once. You will now see the Edit Plan tab.

After this one V5 deployment, workout changes can be made from Edit Plan without redeploying GitHub Pages.

## Data model
- `workout_types`: type name + color
- `plan_workouts`: shared current plan content
- `user_settings`: each user's name/start date/admin flag
- `workout_logs`: personal completion/results/history
- `workout_snapshot`: immutable copy of a workout saved when it is first marked complete
