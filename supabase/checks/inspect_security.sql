-- Read-only. Paste into the Supabase SQL editor and run.
-- Returns one result set so the editor shows everything at once.

select 'rls' as section, relname::text as name,
       relrowsecurity::text as detail, null::text as extra
from pg_class
where relnamespace = 'public'::regnamespace and relkind = 'r'

union all
select 'policy', tablename || '.' || policyname,
       cmd || ' to ' || array_to_string(roles, ','),
       'using: ' || coalesce(qual, '-') || ' | check: ' || coalesce(with_check, '-')
from pg_policies
where schemaname = 'public'

union all
select 'grant', table_name || ' -> ' || grantee,
       string_agg(privilege_type, ', '), null
from information_schema.role_table_grants
where table_schema = 'public' and grantee in ('anon', 'authenticated')
group by table_name, grantee

union all
select 'role', coalesce(role::text, '<null>'), count(*)::text, null
from public.profiles
group by role

union all
select 'users_without_profile', count(*)::text, null, null
from auth.users u
where not exists (select 1 from public.profiles p where p.id = u.id)

union all
select 'bookings_column', column_name::text, data_type::text, column_default::text
from information_schema.columns
where table_schema = 'public' and table_name = 'bookings'
  and column_name in ('created_by', 'date', 'ref_number', 'total_revenue')

union all
select 'auth_users_trigger', tgname::text, null, null
from pg_trigger
where tgrelid = 'auth.users'::regclass and not tgisinternal

order by 1, 2;
