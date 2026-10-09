-- =====================================================================
-- Migracion: telefono_obligatorio
-- Descripcion: Cambio controlado ERD v1.1 -> v1.2
--   perfil.telefono pasa a ser obligatorio y con formato de celular de
--   Ecuador (09XXXXXXXX). Necesario para coordinar la entrega y para la
--   futura integracion con WhatsApp.
-- =====================================================================

alter table public.perfil
    alter column telefono set not null;

alter table public.perfil
    add constraint perfil_nombres_completos_no_vacio
    check (length(trim(nombres_completos))>0);

alter table public.perfil
    add constraint perfil_telefono_no_vacio
    check (length(trim(telefono))>0);

comment on column public.perfil.telefono is
    'Obligatorio (ERD v1.2.). Formato libre; se normaliza a +593 al integrar WhatsApp.';