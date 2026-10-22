-- Read-only. Lists reference numbers used by more than one booking.
select ref_number, count(*) as uses,
       string_agg(client_name || ' (' || to_char(date, 'YYYY-MM-DD') || ')', ', ') as bookings
from public.bookings
where ref_number is not null
group by ref_number
having count(*) > 1
order by ref_number;
