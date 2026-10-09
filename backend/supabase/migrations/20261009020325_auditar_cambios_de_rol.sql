-- =====================================================================
-- Migracion: auditar_cambios_de_rol
-- Descripcion: Todo cambio de rol en perfil queda en registro_auditoria,
--              sin importar el camino (SQL Editor, Edge Function, etc.)
-- =====================================================================

-- security definer: registro_auditoria no tiene permisos de escritura
-- para ningun rol de la API
create or replace function public.fn_perfil_auditar_rol()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.registro_auditoria (
        nombre_tabla, registro_id, accion, datos_antiguos, datos_nuevos, perfil_id
    )
    values (
        'perfil',
        new.id,
        'UPDATE',
        json_build_object('rol', old.rol),
        -- origen: rol de base de datos que hizo el cambio (postgres = SQL Editor)
        json_build_object('rol', new.rol, 'origen', session_user),
        -- quien hizo el cambio; null si fue desde el SQL Editor
        (select auth.uid())
    );

    return null;
end;
$$;

comment on function public.fn_perfil_auditar_rol() is 
    'Registra en registro_auditoria cada cambio de rol. Solo se ejecuta como trigger';

revoke execute on function public.fn_perfil_auditar_rol() 
    from public, anon, authenticated;

create trigger trg_perfil_auditar_rol
    after update of rol on public.perfil
    for each row
    when (old.rol is distinct from new.rol)
    execute function public.fn_perfil_auditar_rol();