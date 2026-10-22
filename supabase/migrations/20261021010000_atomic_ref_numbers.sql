-- Reference numbers ("1234 / MM / د م") are allocated by the database on insert.
-- A sequence never hands out the same value twice, so concurrent saves cannot
-- collide. Any ref_number sent by the client is ignored.

begin;

create sequence if not exists public.booking_ref_seq;

-- Continue after the highest number already used (minimum 1000, as the app did).
select setval(
  'public.booking_ref_seq',
  greatest(
    999,
    coalesce((
      select max((substring(ref_number from '^\s*(\d+)'))::bigint)
      from public.bookings
    ), 0)
  )
);

create or replace function public.bookings_assign_ref_number()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.ref_number := nextval('public.booking_ref_seq')::text
    || ' / ' || to_char(now() at time zone 'Asia/Riyadh', 'MM')
    || ' / د م';
  return new;
end;
$$;

drop trigger if exists bookings_assign_ref_number on public.bookings;
create trigger bookings_assign_ref_number
  before insert on public.bookings
  for each row execute function public.bookings_assign_ref_number();

-- Edits must not change an issued number.
create or replace function public.bookings_keep_ref_number()
returns trigger
language plpgsql
as $$
begin
  new.ref_number := old.ref_number;
  return new;
end;
$$;

drop trigger if exists bookings_keep_ref_number on public.bookings;
create trigger bookings_keep_ref_number
  before update on public.bookings
  for each row execute function public.bookings_keep_ref_number();

-- Enforce uniqueness when existing data allows it; report old duplicates otherwise.
do $$
begin
  if exists (
    select 1 from public.bookings
    where ref_number is not null
    group by ref_number having count(*) > 1
  ) then
    raise notice 'Duplicate ref_number values exist; unique index not created. '
      'Run supabase/checks/duplicate_ref_numbers.sql to list them.';
  else
    create unique index if not exists bookings_ref_number_key
      on public.bookings (ref_number);
  end if;
end $$;

commit;
