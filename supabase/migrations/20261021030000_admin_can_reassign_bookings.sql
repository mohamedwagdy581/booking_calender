-- created_by stays locked for employees, but an admin (or the SQL editor /
-- service role, where auth.uid() is null) may assign or correct it, e.g. for
-- older bookings saved without a creator.

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
  elsif auth.uid() is not null and not public.is_admin() then
    new.created_by := old.created_by;
  end if;
  return new;
end;
$$;

