-- =====================================================================
-- Migracion: erd_v1_1
-- Descripcion: Cambio controlado ERD v1.0 -> v1.1
--   1. Nuevo estado 'en_camino' en tipo_estado_pedido
--   2. Nueva columna motivo_de_cancelacion en pedido
-- =====================================================================

alter type public.tipo_estado_pedido add value 'en_camino' after 'aceptado';

alter table public.pedido
    add column motivo_de_cancelacion text;

comment on column public.pedido.motivo_de_cancelacion is 
    'Obligatorio al cancelar un pedido que ya estaba aceptado (ERD v1.1)';