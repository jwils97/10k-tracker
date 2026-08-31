# 10K Workout Tracker V6

V6 adds:
- Strava connection from Settings
- Personal Strava analytics
- Calendar-based workout editing for admins
- Existing cloud plan + individual workout history

## One-time V6 database setup
Run `SUPABASE_SETUP_V6.sql` in Supabase SQL Editor after V5 is already installed.

## Create a Strava API application
Create an app at Strava's API settings page.

Set the Strava Authorization Callback Domain to:
`ewfsszhehargnzherokw.supabase.co`

You need:
- Client ID
- Client Secret

Never put the Client Secret in index.html.

## Edge Function secrets
Set these Supabase Edge Function secrets:
- STRAVA_CLIENT_ID = your Strava Client ID
- STRAVA_CLIENT_SECRET = your Strava Client Secret
- APP_URL = your GitHub Pages app URL, including trailing slash if that is your normal app URL

SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are available to deployed Supabase Edge Functions.

## Deploy Edge Functions
This package includes:
- `supabase/functions/strava-connect`
- `supabase/functions/strava-callback`
- `supabase/functions/strava-sync`

The callback must be deployed without JWT verification because Strava itself redirects the browser to it after authorization.
`supabase/config.toml` contains that setting.

Using Supabase CLI:
1. `supabase login`
2. `supabase link --project-ref ewfsszhehargnzherokw`
3. `supabase secrets set STRAVA_CLIENT_ID=... STRAVA_CLIENT_SECRET=... APP_URL=https://YOUR_GITHUB_PAGES_URL/`
4. `supabase functions deploy strava-connect`
5. `supabase functions deploy strava-callback --no-verify-jwt`
6. `supabase functions deploy strava-sync`

## GitHub Pages
Replace the existing GitHub Pages files with the V6 files once and commit to main.

## Using Strava
Each user:
1. Opens Settings
2. Taps Connect Strava
3. Authorizes Strava
4. Returns to the app
5. Taps Sync Activities
6. Opens Analytics

The sync imports up to the last 180 days of activities. Tokens are refreshed server-side.

## Analytics currently included
- Running miles over the last 6 months
- Average running pace
- Plan completion percentage
- Cycling miles
- Number of Strava runs
- Number of imported activities
- 8-week running mileage bars
- 10 most recent activities

## Admin editor
Edit Plan now opens a calendar instead of a Week/Day dropdown. Choose a date, edit that workout, and save.
