create table if not exists public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  token text not null unique,
  user_id uuid null references auth.users(id) on delete set null,
  platform text null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_device_tokens_user_id on public.device_tokens(user_id);
create index if not exists idx_device_tokens_updated_at on public.device_tokens(updated_at desc);

alter table public.device_tokens enable row level security;

drop policy if exists "device_tokens_select_all" on public.device_tokens;
create policy "device_tokens_select_all"
on public.device_tokens
for select
to public
using (true);

drop policy if exists "device_tokens_insert_all" on public.device_tokens;
create policy "device_tokens_insert_all"
on public.device_tokens
for insert
to public
with check (true);

drop policy if exists "device_tokens_update_all" on public.device_tokens;
create policy "device_tokens_update_all"
on public.device_tokens
for update
to public
using (true)
with check (true);

drop policy if exists "device_tokens_delete_all" on public.device_tokens;
create policy "device_tokens_delete_all"
on public.device_tokens
for delete
to public
using (true);

