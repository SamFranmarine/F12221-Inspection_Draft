-- F12221 Inspection ITP — access requests (added 2026-10-30)
-- Run once: Supabase dashboard → SQL Editor → New query → paste all of this → Run. Safe to re-run.
-- External users confirm their email (sign-in link + password), then ask for access from the landing page.
-- Franmarine staff see the requests in the Access tab of either tool and approve (adds them as a Viewer) or decline.

create table if not exists public.access_requests (
  email        text primary key check (email = lower(email)),
  name         text not null check (length(name) between 1 and 120),
  company      text check (company is null or length(company) <= 120),
  reason       text check (reason is null or length(reason) <= 500),
  status       text not null default 'pending' check (status in ('pending','declined')),
  requested_at timestamptz not null default now(),
  decided_by   text,
  decided_at   timestamptz
);

alter table public.access_requests enable row level security;

drop policy if exists "requests: read"      on public.access_requests;
drop policy if exists "requests: ask"       on public.access_requests;
drop policy if exists "requests: ask again" on public.access_requests;
drop policy if exists "requests: staff"     on public.access_requests;
-- a person sees only their own request; Franmarine staff see all
create policy "requests: read"      on public.access_requests for select to authenticated using (public.is_staff() or email = public.my_email());
-- a signed-in (email-confirmed) person can ask for access for their own address only
create policy "requests: ask"       on public.access_requests for insert to authenticated with check (email = public.my_email() and status = 'pending' and not public.is_staff());
create policy "requests: ask again" on public.access_requests for update to authenticated using (email = public.my_email()) with check (email = public.my_email() and status = 'pending');
-- Franmarine staff decide (decline, or delete once approved)
create policy "requests: staff"     on public.access_requests for all    to authenticated using (public.is_staff()) with check (public.is_staff());

revoke all on public.access_requests from anon;
grant select, insert, update, delete on public.access_requests to authenticated;
