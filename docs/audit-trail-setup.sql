create extension if not exists pgcrypto;

create table if not exists public.audit_events (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid not null,
  actor_email text,
  actor_role text,
  action text not null,
  entity_type text,
  entity_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

alter table public.audit_events enable row level security;

create policy "authenticated users can insert audit events"
  on public.audit_events
  for insert
  to authenticated
  with check (auth.uid() = actor_id);

create policy "admins can read audit events"
  on public.audit_events
  for select
  to authenticated
  using (
    exists (
      select 1
      from public.users u
      where u.user_id = auth.uid()::text
        and u.user_role = 'admin'
    )
  );

alter publication supabase_realtime add table public.audit_events;
