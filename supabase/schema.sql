-- Mi Garage: estructura de la base. Pegar en Supabase → SQL Editor → Run.

-- Todo se guarda en una sola tabla: vehículos, registros (cargas, services, lavados, gastos,
-- contactos…) y fotos. El contenido de cada ítem va en "data" (JSON).
create table if not exists public.garage_items (
  kind        text not null check (kind in ('vehicle','record','photo')),
  id          text not null,
  data        jsonb not null,
  updated_at  timestamptz not null default now(),
  updated_by  text,
  primary key (kind, id)
);

-- Quiénes pueden ver y editar el garage (por mail).
create table if not exists public.garage_members (
  email text primary key
);

alter table public.garage_items   enable row level security;
alter table public.garage_members enable row level security;

create or replace function public.is_garage_member() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.garage_members m
                 where m.email = lower(coalesce(auth.jwt() ->> 'email', '')));
$$;

drop policy if exists "miembros leen"     on public.garage_items;
drop policy if exists "miembros crean"    on public.garage_items;
drop policy if exists "miembros editan"   on public.garage_items;
drop policy if exists "miembros borran"   on public.garage_items;
drop policy if exists "cada uno se ve"    on public.garage_members;

create policy "miembros leen"   on public.garage_items for select to authenticated using (public.is_garage_member());
create policy "miembros crean"  on public.garage_items for insert to authenticated with check (public.is_garage_member());
create policy "miembros editan" on public.garage_items for update to authenticated using (public.is_garage_member()) with check (public.is_garage_member());
create policy "miembros borran" on public.garage_items for delete to authenticated using (public.is_garage_member());
create policy "cada uno se ve"  on public.garage_members for select to authenticated using (email = lower(coalesce(auth.jwt() ->> 'email', '')));

-- Cambios en vivo entre los dos teléfonos.
do $$ begin
  alter publication supabase_realtime add table public.garage_items;
exception when duplicate_object then null; end $$;

-- ⚠️ Reemplazá por los mails reales (en minúsculas) con los que van a ingresar:
insert into public.garage_members (email) values
  ('tu-mail@ejemplo.com'),
  ('mail-de-tu-esposo@ejemplo.com')
on conflict do nothing;
