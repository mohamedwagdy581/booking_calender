-- Display names of employees, so bookings can show who added them.
-- profiles stays private (own row / admin only); this exposes only id + name,
-- and only to signed-in employees.

create or replace function public.employee_names()
returns table (id uuid, name text)
language sql
stable
security definer
set search_path = public
as $$
  select p.id,
         coalesce(nullif(trim(u.raw_user_meta_data ->> 'full_name'), ''),
                  split_part(p.email, '@', 1))
  from public.profiles p
  join auth.users u on u.id = p.id
  where public.is_employee();
$$;

revoke all on function public.employee_names() from public, anon;
grant execute on function public.employee_names() to authenticated;
