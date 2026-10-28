-- F12221 CIP Structural Remediation — Inspection ITP database (Supabase / Postgres)
-- Run once: Supabase dashboard → SQL Editor → New query → paste all of this → Run.
-- Safe to re-run: it creates what's missing and replaces the functions and policies.

-- 1. Tables --------------------------------------------------------------------------------------
create table if not exists public.access_list (            -- non-Franmarine users allowed in
  email     text primary key check (email = lower(email)),
  role      text not null default 'viewer' check (role in ('viewer','editor')),
  note      text,
  added_by  text default lower(coalesce(auth.jwt()->>'email','')),
  added_at  timestamptz not null default now()
);

create table if not exists public.members (                 -- one row per structure member (readings, defects, points)
  structure  text not null check (structure in ('SSL','NSL')),
  member_key text not null,                                  -- tool member key, e.g. X3-S4, 1-35; '__common__' = inspection details
  data       jsonb not null,
  version    integer not null default 1,
  updated_by text,
  updated_at timestamptz not null default now(),
  primary key (structure, member_key)
);

create table if not exists public.member_history (          -- every saved version: who, when, what
  id         bigint generated always as identity primary key,
  structure  text not null,
  member_key text not null,
  version    integer,
  data       jsonb,
  changed_by text,
  changed_at timestamptz not null default now()
);
create index if not exists member_history_key on public.member_history (structure, member_key, changed_at desc);

-- 2. Who is signed in, and what may they do ---------------------------------------------------------
create or replace function public.my_email() returns text
  language sql stable as $$ select lower(coalesce(auth.jwt()->>'email', '')) $$;

create or replace function public.is_staff() returns boolean          -- Franmarine address
  language sql stable as $$ select public.my_email() like '%@franmarine.com.au' $$;

create or replace function public.my_role() returns text              -- 'editor', 'viewer' or null (no access)
  language sql stable security definer set search_path = public as $$
  select case when public.is_staff() then 'editor'
              else (select role from public.access_list where email = public.my_email()) end $$;

grant execute on function public.my_email(), public.is_staff(), public.my_role() to authenticated;

-- 3. Stamp every save with who / when / version, and keep the history ---------------------------------
create or replace function public.members_stamp() returns trigger
  language plpgsql security definer set search_path = public as $$
begin
  new.updated_by := public.my_email();
  new.updated_at := now();
  if tg_op = 'UPDATE' then new.version := old.version + 1; else new.version := 1; end if;
  insert into public.member_history (structure, member_key, version, data, changed_by)
  values (new.structure, new.member_key, new.version, new.data, new.updated_by);
  return new;
end $$;
drop trigger if exists members_stamp on public.members;
create trigger members_stamp before insert or update on public.members
  for each row execute function public.members_stamp();

-- 4. Row-level security -----------------------------------------------------------------------------
alter table public.members        enable row level security;
alter table public.access_list    enable row level security;
alter table public.member_history enable row level security;

drop policy if exists "members: read"   on public.members;
drop policy if exists "members: insert" on public.members;
drop policy if exists "members: update" on public.members;
create policy "members: read"   on public.members for select to authenticated using (public.my_role() is not null);
create policy "members: insert" on public.members for insert to authenticated with check (public.my_role() = 'editor');
create policy "members: update" on public.members for update to authenticated using (public.my_role() = 'editor') with check (public.my_role() = 'editor');
-- no delete policy: rows are never deleted from the app

drop policy if exists "access: read"   on public.access_list;
drop policy if exists "access: manage" on public.access_list;
create policy "access: read"   on public.access_list for select to authenticated using (public.is_staff() or email = public.my_email());
create policy "access: manage" on public.access_list for all    to authenticated using (public.is_staff()) with check (public.is_staff());

drop policy if exists "history: read" on public.member_history;
create policy "history: read" on public.member_history for select to authenticated using (public.my_role() is not null);

-- 4b. Table permissions for signed-in users (needed because "Automatically expose new tables" is off).
--     Row-level security above still decides which rows each person can see or change.
revoke all on public.members, public.access_list, public.member_history from anon;
grant select, insert, update          on public.members        to authenticated;
grant select, insert, update, delete  on public.access_list    to authenticated;
grant select                          on public.member_history to authenticated;

-- 5. Live updates -----------------------------------------------------------------------------------
do $$ begin
  alter publication supabase_realtime add table public.members;
exception when duplicate_object then null; end $$;
