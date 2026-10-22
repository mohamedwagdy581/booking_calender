-- Locks bookings, profiles and device_tokens to signed-in employees.
-- An "employee" is any auth user that has a row in public.profiles.
-- Replaces every existing policy on these three tables.

begin;

-- ---------------------------------------------------------------------------
-- Role helpers (security definer so they can read profiles under RLS)
-- ---------------------------------------------------------------------------
create or replace function public.is_employee()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.profiles where id = auth.uid());
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and role = 'admin'
  );
$$;

revoke all on function public.is_employee() from public, anon;
revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_employee() to authenticated;
grant execute on function public.is_admin() to authenticated;

-- ---------------------------------------------------------------------------
-- Drop every existing policy on the hardened tables
-- ---------------------------------------------------------------------------
do $$
declare
  p record;
begin
  for p in
    select policyname, tablename
    from pg_policies
    where schemaname = 'public'
      and tablename in ('bookings', 'profiles', 'device_tokens')
  loop
    execute format('drop policy %I on public.%I', p.policyname, p.tablename);
  end loop;
end $$;

alter table public.bookings enable row level security;
alter table public.profiles enable row level security;
alter table public.device_tokens enable row level security;

-- Anonymous (logged-out) callers get nothing, even if a policy is added later.
revoke all on public.bookings from anon;
revoke all on public.profiles from anon;
revoke all on public.device_tokens from anon;

-- ---------------------------------------------------------------------------
-- bookings: employees share one calendar; no client-side deletes
-- ---------------------------------------------------------------------------
create policy bookings_select_employees on public.bookings
  for select to authenticated
  using (public.is_employee());

create policy bookings_insert_employees on public.bookings
  for insert to authenticated
  with check (public.is_employee());

create policy bookings_update_employees on public.bookings
  for update to authenticated
  using (public.is_employee())
  with check (public.is_employee());

-- created_by always reflects the real author and cannot be rewritten.
create or replace function public.bookings_set_created_by()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    if auth.uid() is not null then
      new.created_by := auth.uid();
    end if;
  else
    new.created_by := old.created_by;
  end if;
  return new;
end;
$$;

drop trigger if exists bookings_set_created_by on public.bookings;
create trigger bookings_set_created_by
  before insert or update on public.bookings
  for each row execute function public.bookings_set_created_by();

-- ---------------------------------------------------------------------------
-- profiles: read own row (admins read all); no client writes, so nobody can
-- change their own role from the app or the REST API
-- ---------------------------------------------------------------------------
create policy profiles_select_self_or_admin on public.profiles
  for select to authenticated
  using (id = auth.uid() or public.is_admin());

-- ---------------------------------------------------------------------------
-- device_tokens: owners only; writes go through the RPCs below
-- ---------------------------------------------------------------------------
create policy device_tokens_select_own on public.device_tokens
  for select to authenticated
  using (user_id = auth.uid());

create policy device_tokens_delete_own on public.device_tokens
  for delete to authenticated
  using (user_id = auth.uid());

-- Tokens without an owner can no longer receive pushes.
delete from public.device_tokens where user_id is null;

create or replace function public.register_device_token(
  p_token text,
  p_platform text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null or not public.is_employee() then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  if p_token is null or length(p_token) = 0 or length(p_token) > 4096 then
    raise exception 'invalid token' using errcode = '22023';
  end if;

  insert into public.device_tokens (token, user_id, platform, updated_at)
  values (p_token, auth.uid(), left(p_platform, 32), now())
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        updated_at = now();
end;
$$;

create or replace function public.unregister_device_token(p_token text)
returns void
language sql
security definer
set search_path = public
as $$
  delete from public.device_tokens
  where token = p_token and user_id = auth.uid();
$$;

revoke all on function public.register_device_token(text, text) from public, anon;
revoke all on function public.unregister_device_token(text) from public, anon;
grant execute on function public.register_device_token(text, text) to authenticated;
grant execute on function public.unregister_device_token(text) to authenticated;

commit;
