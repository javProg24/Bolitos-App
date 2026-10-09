-- =====================================================================
-- Migracion: proteger_ultimo_admin
-- Descripcion: Impide quedarse sin administradores:
--   BL011: quitar el rol admin al unico admin
--   BL012: eliminar al unico admin (incluye el borrado en cascada
--          desde auth.users)
--   Para reemplazar al admin: crear primero el nuevo y luego quitar
--   el rol al anterior.
-- =====================================================================

create or replace function public.fn_perfil_proteger_ultimo_admin()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
    if old.rol = 'admin' 
        and (tg_op = 'DELETE' or new.rol <> 'admin') 
        and not exists (
            select 1
            from public.perfil
            where rol = 'admin'
            and id <> old.id
        ) then

        if tg_op = 'DELETE' then
            raise exception 'No se puede eliminar al unico administrador'
            using errcode = 'BL012';
        end if;

        raise exception 'No se puede quitar el rol al unico administrador'
        using errcode = 'BL011';
    end if;

    if tg_op = 'DELETE' then
        return old;
    end if;

    return new;
end;
$$;

create trigger tgr_perfil_proteger_ultimo_admin
    before update of rol or delete on public.perfil
    for each row execute function public.fn_perfil_proteger_ultimo_admin();