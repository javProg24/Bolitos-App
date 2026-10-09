-- =====================================================================
-- Migracion: crear_perfil_al_registrarse
-- Descripcion: PC3 del DFD. Crea el perfil automaticamente cuando un
--              usuario se registra en Supabase Auth.
--   - nombres_completos y telefono salen de raw_user_meta_data
--   - rol NO se copia del registro: toma el default 'cliente'
--   - si faltan datos, se cancela el registro completo
-- =====================================================================

-- security definer: el registro lo hace Auth y perfil esta protegido por RLS
create or replace function public.fn_crear_perfil_al_registrarse()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_nombres text := trim(coalesce(new.raw_user_meta_data ->> 'nombres_completos', ''));
    v_telefono text := trim(coalesce(new.raw_user_meta_data ->> 'telefono', ''));
begin
    if v_nombres = '' then
        raise exception 'El nombre completo es obligatorio'
        using errcode = 'BL009';
    end if;

    if v_telefono = '' or length(v_telefono) > 20 then
        raise exception 'El telefono es obligatorio (maximo 20 caracteres)'
        using errcode = 'BL010';
    end if;

    -- Cualquier "rol" enviado en el registro se ignora a proposito:
    -- la columna toma su default 'cliente'. Los admin se asignan a mano.
    insert into public.perfil (id,nombres_completos,telefono)
    values (new.id,v_nombres,v_telefono);
    
    return new;
end;
$$;

comment on function public.fn_crear_perfil_al_registrarse() is
    'Crea el perfil con rol cliente al registrase (PC3). Solo se ejecuta como trigger';

-- Solo debe ejecutarse como trigger (evita el aviso del linter)
revoke execute on function public.fn_crear_perfil_al_registrarse() 
    from public, anon, authenticated;

create trigger tgr_crear_perfil_al_registrarse
    after insert on auth.users
    for each row execute function public.fn_crear_perfil_al_registrarse();