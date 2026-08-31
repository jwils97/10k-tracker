-- 10K Tracker V5
-- Cloud-managed training plan + calendar + admin editor.
-- Run this entire file once in Supabase SQL Editor.

create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Runner',
  start_date date not null default current_date,
  updated_at timestamptz not null default now()
);


create table if not exists public.workout_types (
  name text primary key,
  color_hex text not null,
  sort_order integer not null default 99,
  updated_at timestamptz not null default now()
);

create table if not exists public.plan_workouts (
  workout_key text primary key,
  week integer not null check (week between 1 and 52),
  day integer not null check (day between 1 and 7),
  title text not null,
  category text not null references public.workout_types(name),
  location text not null,
  scheme text not null,
  distance text not null default '—',
  effort text not null,
  estimate text not null,
  cardio boolean not null default true,
  active boolean not null default true,
  revision integer not null default 1,
  updated_at timestamptz not null default now()
);

create table if not exists public.workout_logs (
  user_id uuid not null references auth.users(id) on delete cascade,
  workout_key text not null,
  completed boolean not null default false,
  duration text,
  weight_log text,
  notes text,
  photo_path text,
  workout_snapshot jsonb,
  updated_at timestamptz not null default now(),
  primary key(user_id, workout_key)
);

alter table public.workout_logs add column if not exists workout_snapshot jsonb;

insert into public.workout_types(name,color_hex,sort_order)
values
('Run', '#3B82F6', 1),
('Strength', '#EF4444', 2),
('Bike', '#22C55E', 3),
('Recovery', '#A855F7', 4),
('Race', '#F59E0B', 5)
on conflict(name) do update set
  color_hex=excluded.color_hex,
  sort_order=excluded.sort_order,
  updated_at=now();

insert into public.plan_workouts(
  workout_key,week,day,title,category,location,scheme,distance,effort,estimate,cardio,active,revision
)
values
('w1d1', 1, 1, 'Easy Run + Strides', 'Run', 'Treadmill or flat outdoor route', '25 min easy + 4 x 20 sec relaxed strides / 60 sec walk', '~2.2–2.5 mi', 'RPE 4/10; easy pace 11:15–12:30/mi', '35 min', true, true, 1),
('w1d2', 1, 2, 'Strength A', 'Strength', 'Princeton Club weights + turf', 'Goblet squat 3x10; DB bench 3x10; Romanian deadlift 3x10; cable row 3x12; walking lunge 2x10/leg; plank 3x40 sec', '—', 'RPE 6–7/10; leave 2–3 reps in reserve', '50 min', false, true, 1),
('w1d3', 1, 3, '400m Intervals', 'Run', 'Treadmill or track', '10 min warm-up; 6 x 400m @ 2:24–2:28 with 200m walk/jog; 10 min cool-down', '~3.2 mi', 'RPE 7/10 on reps; controlled, not sprinting', '45 min', true, true, 1),
('w1d4', 1, 4, 'Recovery Cycle + Mobility', 'Bike', 'Princeton Club indoor cycle + turf', '25 min easy spin at 80–95 rpm + 10 min hip/ankle mobility + 5 min easy core', '—', 'RPE 3/10; pure recovery', '40 min', true, true, 1),
('w1d5', 1, 5, 'Tempo Blocks', 'Run', 'Treadmill', '10 min easy; 3 x 5 min @ 9:55–10:05/mi with 2 min easy; 8 min cool-down', '~3.5 mi', 'RPE 6–7/10', '40 min', true, true, 1),
('w1d6', 1, 6, 'Bike Endurance', 'Bike', 'Outdoor bike or indoor cycle', '10 min easy; 40 min steady; 5 x 30 sec high-cadence / 90 sec easy; 5 min cool-down', '~12–16 mi outdoor', 'RPE 4–5/10', '60 min', true, true, 1),
('w1d7', 1, 7, 'Long Easy Run', 'Run', 'Flat outdoor route or treadmill', 'Continuous easy run; walk 60 sec every 10 min if needed', '4.0 mi', 'RPE 4/10; conversational', '48–52 min', true, true, 1),
('w2d1', 2, 1, 'Easy Run', 'Run', 'Treadmill or outdoor', '30 min easy + 4 x 20 sec strides', '~2.7–3.0 mi', 'RPE 4/10', '38 min', true, true, 1),
('w2d2', 2, 2, 'Strength B', 'Strength', 'Princeton Club weights + turf', 'Trap-bar or DB deadlift 3x8; incline DB press 3x10; lat pulldown 3x10; split squat 3x8/leg; calf raise 3x15; Pallof press 3x10/side', '—', 'RPE 6–7/10', '50 min', false, true, 1),
('w2d3', 2, 3, '400m Intervals', 'Run', 'Treadmill or track', '10 min warm-up; 8 x 400m @ 2:22–2:26 with 200m walk/jog; 10 min cool-down', '~3.7 mi', 'RPE 7/10', '50 min', true, true, 1),
('w2d4', 2, 4, 'Recovery Cycle', 'Bike', 'Indoor cycle', '35 min easy spin, cadence 80–95 rpm', '—', 'RPE 3/10', '35 min', true, true, 1),
('w2d5', 2, 5, 'Tempo Blocks', 'Run', 'Treadmill', '10 min easy; 4 x 5 min @ 9:50–10:00/mi with 90 sec easy; 8 min cool-down', '~4.0 mi', 'RPE 6–7/10', '45 min', true, true, 1),
('w2d6', 2, 6, 'Strength A Lite + Mobility', 'Strength', 'Princeton Club', 'Goblet squat 2x10; DB bench 2x10; row 2x12; RDL 2x10; 10 min mobility', '—', 'RPE 5–6/10', '35 min', false, true, 1),
('w2d7', 2, 7, 'Long Easy Run', 'Run', 'Outdoor or treadmill', 'Easy continuous run', '4.5 mi', 'RPE 4/10', '52–58 min', true, true, 1),
('w3d1', 3, 1, 'Easy Run + Strides', 'Run', 'Outdoor or treadmill', '30 min easy + 6 x 20 sec strides', '~3.0 mi', 'RPE 4/10', '40 min', true, true, 1),
('w3d2', 3, 2, 'Strength A', 'Strength', 'Princeton Club', 'Goblet squat 3x10; DB bench 3x10; RDL 3x10; seated row 3x12; reverse lunge 3x8/leg; plank 3x45 sec', '—', 'RPE 6–7/10', '50 min', false, true, 1),
('w3d3', 3, 3, '400m Intervals', 'Run', 'Track or treadmill', '12 min warm-up; 10 x 400m @ 2:20–2:24 with 200m jog; 10 min cool-down', '~4.5 mi', 'RPE 7–8/10', '58 min', true, true, 1),
('w3d4', 3, 4, 'Recovery Cycle', 'Bike', 'Princeton Club indoor cycle', '35 min easy spin; smooth cadence, light resistance', '—', 'RPE 3/10', '35 min', true, true, 1),
('w3d5', 3, 5, 'Cruise Intervals', 'Run', 'Treadmill', '10 min easy; 3 x 8 min @ 9:45–9:55/mi with 2 min easy; 8 min cool-down', '~4.2 mi', 'RPE 6–7/10', '48 min', true, true, 1),
('w3d6', 3, 6, 'Bike Endurance', 'Bike', 'Outdoor or indoor cycle', '60 min steady with 6 x 1 min strong / 2 min easy', '—', 'RPE 4–5/10', '60 min', true, true, 1),
('w3d7', 3, 7, 'Long Easy Run', 'Run', 'Outdoor', 'Easy run; keep it relaxed', '5.0 mi', 'RPE 4/10', '58–64 min', true, true, 1),
('w4d1', 4, 1, 'Recovery Run', 'Run', 'Treadmill or outdoor', '25 min very easy', '~2.2 mi', 'RPE 3–4/10', '30 min', true, true, 1),
('w4d2', 4, 2, 'Strength B', 'Strength', 'Princeton Club', 'Deadlift 3x8; incline DB press 3x10; pulldown 3x10; split squat 3x8/leg; calf raise 3x15; Pallof 3x10/side', '—', 'RPE 6/10', '45 min', false, true, 1),
('w4d3', 4, 3, 'Fast 400s', 'Run', 'Track or treadmill', '12 min warm-up; 8 x 400m @ 2:17–2:22 with 200m jog; 10 min cool-down', '~4.0 mi', 'RPE 8/10', '52 min', true, true, 1),
('w4d4', 4, 4, 'Recovery Walk + Mobility', 'Recovery', 'Treadmill + turf', '25 min brisk incline walk (1–4% grade) + 10 min mobility', '~1.5–2.0 mi', 'RPE 3/10', '35 min', true, true, 1),
('w4d5', 4, 5, 'Goal-Pace Repeats', 'Run', 'Treadmill', '10 min easy; 5 x 800m @ 4:46–4:50 with 400m easy jog; 8 min cool-down', '~4.8 mi', 'RPE 7/10', '55 min', true, true, 1),
('w4d6', 4, 6, 'Mobility + Easy Cycle', 'Bike', 'Indoor cycle + turf', '25 min easy spin + 15 min mobility/core', '—', 'RPE 3/10', '40 min', true, true, 1),
('w4d7', 4, 7, 'Long Easy Run', 'Run', 'Outdoor', 'Easy continuous run', '4.5 mi', 'RPE 4/10', '52–58 min', true, true, 1),
('w5d1', 5, 1, 'Easy Run + Strides', 'Run', 'Outdoor or treadmill', '35 min easy + 4 x 20 sec strides', '~3.2 mi', 'RPE 4/10', '43 min', true, true, 1),
('w5d2', 5, 2, 'Strength A', 'Strength', 'Princeton Club', 'Squat 3x8; DB bench 3x8; RDL 3x8; row 3x10; walking lunge 2x12/leg; plank 3x50 sec', '—', 'RPE 7/10', '50 min', false, true, 1),
('w5d3', 5, 3, '400m Intervals', 'Run', 'Track or treadmill', '12 min warm-up; 12 x 400m @ 2:18–2:22 with 200m jog; 10 min cool-down', '~5.1 mi', 'RPE 7–8/10', '62 min', true, true, 1),
('w5d4', 5, 4, 'Easy Cycle + Core', 'Bike', 'Princeton Club indoor cycle + turf', '30 min easy spin + dead bug 3x10/side + side plank 2x30 sec/side', '—', 'RPE 3–4/10', '42 min', true, true, 1),
('w5d5', 5, 5, 'Threshold Blocks', 'Run', 'Treadmill', '10 min easy; 2 x 12 min @ 9:45–9:55/mi with 3 min easy; 8 min cool-down', '~4.4 mi', 'RPE 7/10', '48 min', true, true, 1),
('w5d6', 5, 6, 'Bike Endurance', 'Bike', 'Outdoor or indoor', '65 min steady; last 15 min moderately strong', '—', 'RPE 4–6/10', '65 min', true, true, 1),
('w5d7', 5, 7, 'Long Easy Run', 'Run', 'Outdoor', 'Easy run', '5.5 mi', 'RPE 4/10', '64–70 min', true, true, 1),
('w6d1', 6, 1, 'Recovery Run', 'Run', 'Treadmill or outdoor', '30 min easy', '~2.6 mi', 'RPE 3–4/10', '35 min', true, true, 1),
('w6d2', 6, 2, 'Strength B', 'Strength', 'Princeton Club', 'Deadlift 3x6; incline DB press 3x8; pulldown 3x8; split squat 3x8/leg; calf raise 3x15; side plank 3x35 sec/side', '—', 'RPE 7/10', '50 min', false, true, 1),
('w6d3', 6, 3, 'Speed Mix', 'Run', 'Track or treadmill', '12 min warm-up; 6 x 400m @ 2:15–2:20, then 4 x 200m brisk with 200m easy between all reps; cool-down', '~3.8 mi', 'RPE 8/10', '50 min', true, true, 1),
('w6d4', 6, 4, 'Recovery Cycle', 'Bike', 'Indoor cycle', '40 min easy spin', '—', 'RPE 3/10', '40 min', true, true, 1),
('w6d5', 6, 5, 'Goal-Pace 1Ks', 'Run', 'Treadmill or track', '10 min easy; 4 x 1 km @ 5:55–6:00 with 400m easy jog; 10 min cool-down', '~4.7 mi', 'RPE 7/10', '55 min', true, true, 1),
('w6d6', 6, 6, 'Mobility + Core', 'Strength', 'Turf / home', 'Dead bug 3x10/side; bird dog 3x10/side; side plank 3x40 sec; hip mobility 15 min', '—', 'RPE 3–4/10', '35 min', false, true, 1),
('w6d7', 6, 7, 'Long Easy Run', 'Run', 'Outdoor', 'Easy continuous run', '6.0 mi', 'RPE 4/10', '70–76 min', true, true, 1),
('w7d1', 7, 1, 'Easy Run + Strides', 'Run', 'Outdoor or treadmill', '30 min easy + 6 x 20 sec strides', '~3.0 mi', 'RPE 4/10', '40 min', true, true, 1),
('w7d2', 7, 2, 'Strength A Reduced', 'Strength', 'Princeton Club', 'Squat 3x8; DB bench 3x8; RDL 2x8; row 3x10; lunges 2x8/leg; plank 2x45 sec', '—', 'RPE 6/10', '45 min', false, true, 1),
('w7d3', 7, 3, '400m Intervals', 'Run', 'Track or treadmill', '12 min warm-up; 10 x 400m @ 2:16–2:20 with 200m jog; cool-down', '~4.5 mi', 'RPE 8/10', '58 min', true, true, 1),
('w7d4', 7, 4, 'Recovery Cycle', 'Bike', 'Princeton Club indoor cycle', '30 min very easy spin; cadence 85–95 rpm, low resistance', '—', 'RPE 2–3/10', '30 min', true, true, 1),
('w7d5', 7, 5, 'Goal-Pace Ladder', 'Run', 'Treadmill or track', '10 min easy; 400m / 800m / 1200m / 800m / 400m at 9:35–9:40/mi equivalent; 400m easy jog between; cool-down', '~4.6 mi', 'RPE 7/10', '55 min', true, true, 1),
('w7d6', 7, 6, 'Bike Endurance', 'Bike', 'Outdoor or indoor', '60 min steady, mostly easy', '—', 'RPE 4/10', '60 min', true, true, 1),
('w7d7', 7, 7, 'Long Easy Run', 'Run', 'Outdoor', 'Easy run, last 10 min moderately steady if feeling good', '5.5 mi', 'RPE 4–5/10', '64–70 min', true, true, 1),
('w8d1', 8, 1, 'Recovery Run', 'Run', 'Treadmill or outdoor', '25 min very easy', '~2.2 mi', 'RPE 3/10', '30 min', true, true, 1),
('w8d2', 8, 2, 'Strength B Reduced', 'Strength', 'Princeton Club', 'Deadlift 2x6; incline DB press 2x8; pulldown 2x8; split squat 2x8/leg; calf raise 2x15; Pallof 2x10/side', '—', 'RPE 5–6/10', '40 min', false, true, 1),
('w8d3', 8, 3, 'Race-Pace 400s', 'Run', 'Track or treadmill', '12 min warm-up; 12 x 400m @ 2:20–2:24 with 200m jog; cool-down', '~5.1 mi', 'RPE 7/10; smooth rhythm', '62 min', true, true, 1),
('w8d4', 8, 4, 'Recovery Walk + Mobility', 'Recovery', 'Treadmill + turf', '25 min easy walk + 10 min lower-body mobility', '~1.3–1.8 mi', 'RPE 2–3/10', '35 min', true, true, 1),
('w8d5', 8, 5, '10K Simulation Blocks', 'Run', 'Treadmill', '10 min easy; 3 x 1 mile @ 9:35–9:40/mi with 3 min easy jog; cool-down', '~4.8 mi', 'RPE 7–8/10', '55 min', true, true, 1),
('w8d6', 8, 6, 'Easy Cycle + Mobility', 'Bike', 'Indoor cycle + turf', '30 min easy spin + 10 min mobility', '—', 'RPE 3/10', '40 min', true, true, 1),
('w8d7', 8, 7, 'Long Easy Run', 'Run', 'Outdoor', 'Easy continuous run', '6.0 mi', 'RPE 4/10', '69–75 min', true, true, 1),
('w9d1', 9, 1, 'Easy Run + Strides', 'Run', 'Outdoor or treadmill', '30 min easy + 4 x 20 sec strides', '~2.8 mi', 'RPE 4/10', '38 min', true, true, 1),
('w9d2', 9, 2, 'Strength Maintenance', 'Strength', 'Princeton Club', 'Goblet squat 2x8; DB bench 2x8; RDL 2x8; row 2x10; reverse lunge 2x8/leg; plank 2x40 sec', '—', 'RPE 5–6/10', '35 min', false, true, 1),
('w9d3', 9, 3, 'Sharp 400s', 'Run', 'Track or treadmill', '12 min warm-up; 8 x 400m @ 2:15–2:20 with 200m jog; cool-down', '~4.0 mi', 'RPE 8/10', '50 min', true, true, 1),
('w9d4', 9, 4, 'Easy Cycle', 'Bike', 'Princeton Club indoor cycle', '30 min easy spin, light resistance', '—', 'RPE 3/10', '30 min', true, true, 1),
('w9d5', 9, 5, 'Goal-Pace Rehearsal', 'Run', 'Treadmill or outdoor', '10 min easy; 2 mi @ 9:38–9:42/mi; 4 min easy; 1 mi @ goal pace; cool-down', '~4.5 mi', 'RPE 7/10', '48 min', true, true, 1),
('w9d6', 9, 6, 'Easy Cycle', 'Bike', 'Indoor cycle', '35 min easy spin', '—', 'RPE 3/10', '35 min', true, true, 1),
('w9d7', 9, 7, 'Long Easy Run', 'Run', 'Outdoor', 'Easy run', '5.0 mi', 'RPE 4/10', '58–64 min', true, true, 1),
('w10d1', 10, 1, 'Easy Run', 'Run', 'Outdoor or treadmill', '25 min easy + 4 x 15 sec strides', '~2.2 mi', 'RPE 3–4/10', '32 min', true, true, 1),
('w10d2', 10, 2, 'Light Strength + Mobility', 'Strength', 'Princeton Club', 'Goblet squat 2x6; DB bench 2x6; cable row 2x8; calf raise 2x12; 15 min mobility', '—', 'RPE 4–5/10; no soreness', '35 min', false, true, 1),
('w10d3', 10, 3, 'Race-Pace 400s', 'Run', 'Track or treadmill', '10 min warm-up; 6 x 400m @ 2:22–2:24 with 200m easy; 8 min cool-down', '~3.2 mi', 'RPE 6–7/10', '42 min', true, true, 1),
('w10d4', 10, 4, 'Recovery Walk + Mobility', 'Recovery', 'Treadmill + turf', '20 min easy walk + 10 min mobility; finish fresher than you started', '~1.0–1.5 mi', 'RPE 2/10', '30 min', true, true, 1),
('w10d5', 10, 5, 'Tune-Up', 'Run', 'Treadmill or outdoor', '10 min easy; 3 x 3 min @ goal pace with 2 min easy; 8 min cool-down', '~2.7 mi', 'RPE 6/10', '35 min', true, true, 1),
('w10d6', 10, 6, 'Pre-Race Shakeout', 'Run', 'Outdoor or treadmill', '15–20 min very easy + 4 x 15 sec strides', '~1.5–1.8 mi', 'RPE 2–3/10', '25 min', true, true, 1),
('w10d7', 10, 7, '10K Race', 'Race', 'Race course', 'Warm up 8–10 min easy + mobility; race 10K. Aim first 2 mi around 9:45/mi, settle near 9:35–9:40, race final 2K by feel.', '6.2 mi race', 'Goal: <60:00. Do not exceed RPE 7 early; build to 9–10 late.', '70–80 min incl. warm-up', true, true, 1)
on conflict(workout_key) do nothing;

alter table public.user_settings enable row level security;
alter table public.workout_types enable row level security;
alter table public.plan_workouts enable row level security;
alter table public.workout_logs enable row level security;

revoke all on table public.user_settings, public.workout_types, public.plan_workouts, public.workout_logs from anon, authenticated;

grant select,insert,update,delete on public.user_settings to authenticated;
grant select on public.workout_types to authenticated;
grant select on public.plan_workouts to authenticated;
grant select,insert,update,delete on public.workout_logs to authenticated;

drop policy if exists user_settings_self on public.user_settings;
create policy user_settings_self on public.user_settings
for all to authenticated
using(user_id=auth.uid())
with check(user_id=auth.uid());

drop policy if exists workout_types_read on public.workout_types;
create policy workout_types_read on public.workout_types
for select to authenticated using(true);

drop policy if exists plan_workouts_read on public.plan_workouts;
create policy plan_workouts_read on public.plan_workouts
for select to authenticated using(true);

drop policy if exists workout_logs_self on public.workout_logs;
create policy workout_logs_self on public.workout_logs
for all to authenticated
using(user_id=auth.uid())
with check(user_id=auth.uid());

-- Any authenticated user can edit the shared training plan.
drop policy if exists plan_workouts_admin_insert on public.plan_workouts;
drop policy if exists plan_workouts_admin_update on public.plan_workouts;
drop policy if exists plan_workouts_admin_delete on public.plan_workouts;
drop policy if exists plan_workouts_auth_insert on public.plan_workouts;
drop policy if exists plan_workouts_auth_update on public.plan_workouts;
drop policy if exists plan_workouts_auth_delete on public.plan_workouts;

create policy plan_workouts_auth_insert on public.plan_workouts
for insert to authenticated with check(true);

create policy plan_workouts_auth_update on public.plan_workouts
for update to authenticated using(true) with check(true);

create policy plan_workouts_auth_delete on public.plan_workouts
for delete to authenticated using(true);

grant insert,update,delete on public.plan_workouts to authenticated;

insert into storage.buckets(id,name,public)
values('workout-photos','workout-photos',false)
on conflict(id) do update set public=false;

drop policy if exists v5_photo_read_self on storage.objects;
create policy v5_photo_read_self on storage.objects
for select to authenticated
using(bucket_id='workout-photos' and (storage.foldername(name))[1]=auth.uid()::text);

drop policy if exists v5_photo_insert_self on storage.objects;
create policy v5_photo_insert_self on storage.objects
for insert to authenticated
with check(bucket_id='workout-photos' and (storage.foldername(name))[1]=auth.uid()::text);

drop policy if exists v5_photo_update_self on storage.objects;
create policy v5_photo_update_self on storage.objects
for update to authenticated
using(bucket_id='workout-photos' and (storage.foldername(name))[1]=auth.uid()::text)
with check(bucket_id='workout-photos' and (storage.foldername(name))[1]=auth.uid()::text);

do $$ begin
  alter publication supabase_realtime add table public.plan_workouts;
exception when duplicate_object then null; end $$;

do $$ begin
  alter publication supabase_realtime add table public.workout_types;
exception when duplicate_object then null; end $$;

do $$ begin
  alter publication supabase_realtime add table public.workout_logs;
exception when duplicate_object then null; end $$;
