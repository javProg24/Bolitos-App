-- =====================================================================
-- Migracion: revocar_ejecucion_funciones_trigger
-- Descripcion: Las funciones de trigger security definer de la Fase 1
--              quedaron ejecutables por PUBLIC (permiso por defecto de
--              PostgreSQL). Se retira: solo deben ejecutarse como trigger.
--              No afecta el funcionamiento de los triggers.
-- =====================================================================

revoke execute on function public.fn_articulo_pedido_antes()
    from public, anon, authenticated;

revoke execute on function public.fn_articulo_pedido_recalcular_total()
    from public, anon, authenticated;

revoke execute on function public.fn_pedido_devolver_stock()
    from public, anon, authenticated;