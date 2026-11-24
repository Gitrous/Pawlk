-- Pawlk · configuración de Supabase
-- Pégalo entero en Supabase → SQL Editor → New query → Run (una sola vez).
-- Al final cambia TU_CORREO por el correo con el que vas a entrar como administrador.

-- 1) Tabla de documentos (misma estructura de rutas que usa la app)
create table if not exists public.docs (
  path       text primary key check (length(path) <= 200),
  data       jsonb not null default '{}'::jsonb check (length(data::text) <= 1000000),
  updated_at timestamptz not null default now()
);
create table if not exists public.admins (email text primary key);

alter table public.docs   enable row level security;
alter table public.admins enable row level security;

grant select, insert, update, delete on public.docs to authenticated;
grant select on public.admins to authenticated;

-- 2) ¿Soy administrador?
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins
                 where lower(email) = lower(coalesce(auth.jwt() ->> 'email', '')))
$$;

-- 3) Quién puede leer cada ruta
create or replace function public.docs_read_ok(p text) returns boolean
language sql stable as $$
  select auth.uid() is not null and case
    when split_part(p,'/',1) = 'data'
      then split_part(p,'/',2) = 'users' and split_part(p,'/',3) = auth.uid()::text   -- espacio privado
    when split_part(p,'/',1) in ('flags','consents')
      then split_part(p,'/',2) = auth.uid()::text or public.is_admin()                -- denuncias y consentimientos: solo el autor y el admin
    when split_part(p,'/',1) in ('profiles','pubkeys','dogs','offers','answers','chats','reviews','verified','mod')
      then true
    else false end
$$;

-- 4) Quién puede escribir cada ruta (cada persona solo en lo suyo)
create or replace function public.docs_write_ok(p text) returns boolean
language sql stable as $$
  select auth.uid() is not null and case
    when split_part(p,'/',1) = 'data'
      then split_part(p,'/',2) = 'users' and split_part(p,'/',3) = auth.uid()::text
    when split_part(p,'/',1) in ('verified','mod')
      then public.is_admin()
    when split_part(p,'/',1) in ('profiles','pubkeys','dogs','offers','answers','chats','reviews','flags','consents')
      then split_part(p,'/',2) = auth.uid()::text
    else false end
$$;

drop policy if exists docs_select on public.docs;
drop policy if exists docs_insert on public.docs;
drop policy if exists docs_update on public.docs;
drop policy if exists docs_delete on public.docs;
create policy docs_select on public.docs for select to authenticated using (public.docs_read_ok(path));
create policy docs_insert on public.docs for insert to authenticated with check (public.docs_write_ok(path));
create policy docs_update on public.docs for update to authenticated using (public.docs_write_ok(path)) with check (public.docs_write_ok(path));
create policy docs_delete on public.docs for delete to authenticated using (public.docs_write_ok(path));

drop policy if exists admins_self on public.admins;
create policy admins_self on public.admins for select to authenticated
  using (lower(email) = lower(coalesce(auth.jwt() ->> 'email', '')));

-- 5) Tiempo real
do $$ begin
  alter publication supabase_realtime add table public.docs;
exception when duplicate_object then null;
end $$;

-- 6) Fotos y vídeos (bucket público de lectura; cada persona sube solo a su carpeta)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('pawlk','pawlk', true, 20971520,
        array['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/webm','video/quicktime'])
on conflict (id) do nothing;
drop policy if exists pawlk_upload on storage.objects;
drop policy if exists pawlk_delete on storage.objects;
create policy pawlk_upload on storage.objects for insert to authenticated
  with check (bucket_id = 'pawlk' and (storage.foldername(name))[1] = auth.uid()::text);
create policy pawlk_delete on storage.objects for delete to authenticated
  using (bucket_id = 'pawlk' and (storage.foldername(name))[1] = auth.uid()::text);

-- 7) Borrar mi cuenta (derecho de supresión): elimina mis datos y mi usuario
create or replace function public.delete_my_account() returns void
language plpgsql security definer set search_path = public, auth as $$
declare u text := auth.uid()::text;
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  delete from public.docs where
       (split_part(path,'/',1) in ('profiles','pubkeys','dogs','offers','answers','chats','reviews','flags','consents')
         and split_part(path,'/',2) = u)
    or (split_part(path,'/',1) = 'data' and split_part(path,'/',2) = 'users' and split_part(path,'/',3) = u)
    or path = 'verified/' || u;
  delete from auth.users where id = auth.uid();
end $$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- 8) Tu cuenta de administrador (verificar perfiles y moderar)
insert into public.admins (email) values ('TU_CORREO') on conflict do nothing;
