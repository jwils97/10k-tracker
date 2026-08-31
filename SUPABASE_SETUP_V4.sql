-- 10K Tracker V4 schema
-- Individual accounts only. No teams or join codes.

create table if not exists public.user_settings (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'Runner',
  start_date date not null default current_date,
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
  updated_at timestamptz not null default now(),
  primary key(user_id, workout_key)
);

alter table public.user_settings enable row level security;
alter table public.workout_logs enable row level security;

revoke all on table public.user_settings, public.workout_logs from anon, authenticated;
grant select, insert, update, delete on public.user_settings to authenticated;
grant select, insert, update, delete on public.workout_logs to authenticated;

drop policy if exists user_settings_self on public.user_settings;
create policy user_settings_self on public.user_settings
for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

drop policy if exists workout_logs_self on public.workout_logs;
create policy workout_logs_self on public.workout_logs
for all to authenticated
using (user_id = auth.uid())
with check (user_id = auth.uid());

insert into storage.buckets(id,name,public)
values('workout-photos','workout-photos',false)
on conflict(id) do update set public=false;

drop policy if exists v4_photo_read_self on storage.objects;
create policy v4_photo_read_self on storage.objects
for select to authenticated
using (
  bucket_id='workout-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists v4_photo_insert_self on storage.objects;
create policy v4_photo_insert_self on storage.objects
for insert to authenticated
with check (
  bucket_id='workout-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

drop policy if exists v4_photo_update_self on storage.objects;
create policy v4_photo_update_self on storage.objects
for update to authenticated
using (
  bucket_id='workout-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
)
with check (
  bucket_id='workout-photos'
  and (storage.foldername(name))[1] = auth.uid()::text
);

do $$ begin
  alter publication supabase_realtime add table public.workout_logs;
exception when duplicate_object then null; end $$;

do $$ begin
  alter publication supabase_realtime add table public.user_settings;
exception when duplicate_object then null; end $$;
