# 10K Workout Tracker V6

V6 removes the admin concept entirely.

## Editing behavior
- Any signed-in user can edit the shared workout plan.
- A workout is editable for you until you personally mark it complete.
- Once you complete a workout, the editor locks that workout for your account.
- Your completed workout snapshot remains preserved in your history.
- Other users who have not completed that workout can still edit the shared plan.

## Calendar
Workout-type colors remain consistent across workout cards and the calendar:
- Run: blue
- Strength: red
- Bike: green
- Recovery: purple
- Race: amber

## Upgrade
1. Run `SUPABASE_SETUP_V6.sql` in Supabase SQL Editor.
2. Replace the GitHub Pages files with the V6 files.
3. Commit to `main`.
4. Reload the app.

After that, workout edits happen inside the app without GitHub redeploys.
