# 10K Workout Tracker V7 — AI Coach

V7 builds on the working V6 Strava/data integration and adds adaptive AI coaching.

## What changes in V7
- New **Coach** tab with conversational coaching.
- Coach builds a persistent training profile by asking adaptive questions about event goals, baseline fitness, schedule, preferred training locations, equipment, preferences, and constraints. No GPS/location tracking is used.
- Coach can analyze completed workout logs plus synced Strava data.
- Coach can propose changes to future workouts or a new future plan.
- **AI changes never apply automatically.** They are stored as a pending proposal and shown on a **Confirm changes to training plan** screen with a high-level summary and workout-by-workout details.
- Manual edits in **Edit Plan** continue to save immediately without the coach approval workflow.
- V7 introduces a personal `user_plan_workouts` table so one athlete's adaptive plan does not change another athlete's plan. Existing V6 workouts are copied into each existing account during migration.
- Completed workouts cannot be altered by Coach proposals.

## Deployment order
### 1. Run the database migration
In Supabase → SQL Editor, run `SUPABASE_SETUP_V7.sql` once.

### 2. Add the OpenAI API secret
In Supabase → Edge Functions → Secrets add:
- `OPENAI_API_KEY` = your OpenAI API key
- Optional: `OPENAI_MODEL` = `gpt-5.6-terra`

Do not place the OpenAI key in `index.html` or GitHub. The AI call happens only inside the Supabase Edge Function.

### 3. Deploy two NEW Edge Functions
Using the Supabase dashboard editor, create/deploy:
- `coach-chat` using `supabase/functions/coach-chat/index.ts`
- `coach-apply` using `supabase/functions/coach-apply/index.ts`

Keep JWT verification ON for both Coach functions. Your existing working Strava functions do not need to be changed or redeployed for V7.

### 4. Deploy the V7 frontend
Replace the GitHub Pages root files with the V7 package and commit to `main`. At minimum replace `index.html` and `sw.js`; upload the complete package if you prefer.

### 5. Reopen the installed PWA
The service worker cache name is bumped to V7. If the old UI persists, close/reopen the app or refresh the GitHub Pages site in Safari.

## First Coach use
Open **Coach** → **Build my profile**. The coach will ask adaptive questions rather than requiring a fixed giant form. Once it has enough information, ask it to create or adapt a plan. If it proposes plan changes, the app opens the required confirmation screen.

## OpenAI API implementation
`coach-chat` uses the OpenAI Responses API with Structured Outputs so the conversational reply, profile update, and proposed plan changes arrive in a constrained JSON schema. The key stays server-side in Supabase.
