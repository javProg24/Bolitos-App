-- ===========================================================================================
-- Migracion: crear_funcion_es_admin
-- Descripcion Funcion central para saber si el usuario de la sesion
-- es administrador. La usan todas las politicas RLS
-- ===========================================================================================
-- security definer: lee perfil sin pasar por su RLS
-- Sin esto, la politica de perfil que llama a es_admin() volveria a
-- consultar perfil y PostgreSQL entraria en recursion infinita.
create or replace function public.es_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
    select exists (
        select 1
        from public.perfil
        where id  = (select auth.uid())
        and rol = 'admin'
    );
$$;

comment on function public.es_admin() is
    'true si el usuario autenticado tiene rol admin. Usada por las politicas RLS';

revoke execute on function public.es_admin() from public, anon;
grant  execute on function public.es_admin() to authenticated;