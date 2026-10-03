-- ===========================================================================================
-- Migracion: proteger_columnas_pedido
-- Descripcion: Cuando un cliente actualiza su pedido (solo para cancelar), unicamente
-- cambian estado y motivo_de_cancelacion. El resto de columnas vuelve a su valor anterior.
-- Admin y cliente comparten el rol "authenticated", por eso no se puede resolver con
-- permisos por columna.

create or replace function public.fn_pedido_proteger_columnas_cliente()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
    v_estado public.tipo_estado_pedido;
    v_motivo_de_cancelacion text;
    v_actualizado_el timestamptz;
begin
    -- Solo aplica a la peticion directa de un usuario de la app que no es admin.
    --   pg_trigger_depth() > 1: update interno (recalculo del total desde
    --     articulo_pedido); no se debe tocar.
    --   current_user <> 'authenticated': service_role, Edge Functions o SQL
    --     del administrador del sistema.
    if pg_trigger_depth() > 1
            or current_user <> 'authenticated'
            or public.es_admin() then
        return new;
    end if;

    v_estado := new.estado;
    v_motivo_de_cancelacion := new.motivo_de_cancelacion;
    v_actualizado_el := new.actualizado_el;

    new := old;

    new.estado := v_estado;
    new.motivo_de_cancelacion := v_motivo_de_cancelacion;
    -- Se conserva por si trigger de actualizado_el ya se ejecuto antes
    new.actualizado_el := v_actualizado_el;

    return new;
end;
$$;

comment on function public.fn_pedido_proteger_columnas_cliente() is
    'El cliente solo puede cambiar estado y motivo_de_cancelacion de su pedido';

create trigger trg_pedido_proteger_columnas_cliente
    before update on public.pedido
    for each row execute function public.fn_pedido_proteger_columnas_cliente();