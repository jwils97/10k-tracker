-- 10K Tracker V3 schema
create extension if not exists pgcrypto;

create table if not exists public.training_teams (
  id uuid primary key default gen_random_uuid(),
  name text not null default '10K Team',
  join_code text not null unique,
  start_date date not null default current_date,
  created_by uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.training_members (
  team_id uuid not null references public.training_teams(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  display_name text not null,
  joined_at timestamptz not null default now(),
  primary key(team_id,user_id)
);

create table if not exists public.workout_logs (
  team_id uuid not null references public.training_teams(id) on delete cascade,
  workout_key text not null,
  user_id uuid not null references auth.users(id) on delete cascade,
  completed boolean not null default false,
  duration text,
  weight_log text,
  notes text,
  photo_path text,
  updated_at timestamptz not null default now(),
  primary key(team_id,workout_key,user_id)
);

create or replace function public.is_team_member(p_team_id uuid, p_user_id uuid default auth.uid())
returns boolean language sql stable security definer set search_path=public as $$
  select exists(select 1 from public.training_members where team_id=p_team_id and user_id=p_user_id);
$$;

revoke all on function public.is_team_member(uuid,uuid) from public;
grant execute on function public.is_team_member(uuid,uuid) to authenticated;

create or replace function public.create_training_team(p_name text,p_display_name text,p_start_date date default current_date)
returns table(team_id uuid,join_code text)
language plpgsql security definer set search_path=public as $$
declare v_team uuid; v_code text;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  v_code := upper(substr(encode(gen_random_bytes(6),'hex'),1,8));
  insert into public.training_teams(name,join_code,start_date,created_by)
  values(coalesce(nullif(trim(p_name),''),'10K Team'),v_code,p_start_date,auth.uid())
  returning id into v_team;
  insert into public.training_members(team_id,user_id,display_name)
  values(v_team,auth.uid(),coalesce(nullif(trim(p_display_name),''),'Runner'));
  return query select v_team,v_code;
end $$;

create or replace function public.join_training_team(p_join_code text,p_display_name text)
returns uuid language plpgsql security definer set search_path=public as $$
declare v_team uuid;
begin
  if auth.uid() is null then raise exception 'Authentication required'; end if;
  select id into v_team from public.training_teams where join_code=upper(trim(p_join_code));
  if v_team is null then raise exception 'Invalid join code'; end if;
  insert into public.training_members(team_id,user_id,display_name)
  values(v_team,auth.uid(),coalesce(nullif(trim(p_display_name),''),'Runner'))
  on conflict(team_id,user_id) do update set display_name=excluded.display_name;
  return v_team;
end $$;

revoke all on function public.create_training_team(text,text,date) from public;
revoke all on function public.join_training_team(text,text) from public;
grant execute on function public.create_training_team(text,text,date) to authenticated;
grant execute on function public.join_training_team(text,text) to authenticated;

alter table public.training_teams enable row level security;
alter table public.training_members enable row level security;
alter table public.workout_logs enable row level security;

revoke all on table public.training_teams,public.training_members,public.workout_logs from anon,authenticated;
grant select,update on public.training_teams to authenticated;
grant select on public.training_members to authenticated;
grant select,insert,update,delete on public.workout_logs to authenticated;

drop policy if exists teams_select_member on public.training_teams;
create policy teams_select_member on public.training_teams for select to authenticated using(public.is_team_member(id));
drop policy if exists teams_update_member on public.training_teams;
create policy teams_update_member on public.training_teams for update to authenticated using(public.is_team_member(id)) with check(public.is_team_member(id));
drop policy if exists members_select_team on public.training_members;
create policy members_select_team on public.training_members for select to authenticated using(public.is_team_member(team_id));
drop policy if exists logs_select_team on public.workout_logs;
create policy logs_select_team on public.workout_logs for select to authenticated using(public.is_team_member(team_id));
drop policy if exists logs_insert_self on public.workout_logs;
create policy logs_insert_self on public.workout_logs for insert to authenticated with check(public.is_team_member(team_id) and user_id=auth.uid());
drop policy if exists logs_update_self on public.workout_logs;
create policy logs_update_self on public.workout_logs for update to authenticated using(public.is_team_member(team_id) and user_id=auth.uid()) with check(public.is_team_member(team_id) and user_id=auth.uid());
drop policy if exists logs_delete_self on public.workout_logs;
create policy logs_delete_self on public.workout_logs for delete to authenticated using(public.is_team_member(team_id) and user_id=auth.uid());

insert into storage.buckets(id,name,public) values('workout-photos','workout-photos',false)
on conflict(id) do update set public=false;

drop policy if exists v3_photo_read_team on storage.objects;
create policy v3_photo_read_team on storage.objects for select to authenticated
using(bucket_id='workout-photos' and public.is_team_member(((storage.foldername(name))[1])::uuid));
drop policy if exists v3_photo_insert_self on storage.objects;
create policy v3_photo_insert_self on storage.objects for insert to authenticated
with check(bucket_id='workout-photos' and public.is_team_member(((storage.foldername(name))[1])::uuid) and (storage.foldername(name))[2]=auth.uid()::text);
drop policy if exists v3_photo_update_self on storage.objects;
create policy v3_photo_update_self on storage.objects for update to authenticated
using(bucket_id='workout-photos' and public.is_team_member(((storage.foldername(name))[1])::uuid) and (storage.foldername(name))[2]=auth.uid()::text)
with check(bucket_id='workout-photos' and public.is_team_member(((storage.foldername(name))[1])::uuid) and (storage.foldername(name))[2]=auth.uid()::text);

do $$ begin
  alter publication supabase_realtime add table public.workout_logs;
exception when duplicate_object then null; end $$;
do $$ begin
  alter publication supabase_realtime add table public.training_teams;
exception when duplicate_object then null; end $$;
