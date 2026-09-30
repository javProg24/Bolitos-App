-- =====================================================================
-- Migracion: crear_trigger_actualizado_el
-- Descripcion: Actualiza actualizado_el automaticamente en cada UPDATE
-- =====================================================================

create or replace function public.fn_actualizar_actualizado_el()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
    new.actualizado_el := now();
    return new;
end;
$$;

create trigger trg_actualizar_actualizado_el
    before update on public.perfil
    for each row execute function public.fn_actualizar_actualizado_el();

create trigger trg_sabor_actualizado_el
    before update on public.sabor
    for each row execute function public.fn_actualizar_actualizado_el();

create trigger trg_pedido_actualizado_el
    before update on public.pedido
    for each row execute function public.fn_actualizar_actualizado_el();