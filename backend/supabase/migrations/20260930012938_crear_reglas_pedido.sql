-- =====================================================================
-- Migracion: crear_reglas_pedido
-- Descripcion: Reglas de negocio de la tabla pedido
--   - Ventana de pedidos y fecha de entrega automatica
--   - Valores iniciales forzados al crear
--   - Campos inmutables y total controlado por la base
--   - Transiciones de estado validas
--   - Motivo obligatorio al cancelar un pedido aceptado
--   - Estado de pago valido
--   - Devolucion de stock al rechazar o cancelar
-- =====================================================================

-- ---------------------------------------------------------------------
-- BEFORE INSERT: validar ventana y fijar valores iniciales
-- ---------------------------------------------------------------------

create or replace function public.fn_pedido_antes_de_insertar()
returns trigger
LANGUAGE plpgsql
set search_path = ''
as $$
declare
    v_fecha_entrega DATE := public.fecha_de_entrega_vigente();
begin
    if v_fecha_entrega is null then
        raise exception 'Solo se aceptan pedidos desde el viernes 00:00 hasta el sabado 08:00'
        using errcode = 'BL001';
    end if;

    -- Valores que el cliente no puede decidir
    new.fecha_de_entrega      := v_fecha_entrega;
    new.estado                := 'pendiente';
    new.estado_pago        := 'pendiente';
    new.total                 := 0;
    new.total                 := 0;
    new.motivo_de_rechazo     := null;
    new.motivo_de_cancelacion := null;
    new.creado_el             := now();
    new.actualizado_el        := now();

    return new;
end;
$$;

create trigger trg_pedido_antes_de_insertar
    before insert on public.pedido
    for each row execute function public.fn_pedido_antes_de_insertar();

-- ---------------------------------------------------------------------
-- BEFORE UPDATE: inmutables, transiciones, motivos y pago
-- ---------------------------------------------------------------------
create or replace function public.fn_pedido_antes_de_actualizar()
returns trigger
LANGUAGE plpgsql
set search_path = ''
as $$
begin
    -- Campos que nunca cambian despues de crear el pedido
    new.perfil_id        := old.perfil_id;
    new.fecha_de_entrega := old.fecha_de_entrega;
    new.creado_el        := old.creado_el;

    -- El total solo lo modifica el trigger de articulo_pedido (profundidad > 1)
    if pg_trigger_depth() = 1 then
        new.total := old.total;
    end if;

    -- Transiciones de estado
    if new.estado is distinct from old.estado then
        if not(
            (old.estado = 'pendiente' and new.estado in ('aceptado','rechazado','cancelado'))
            or (old.estado = 'aceptado' and new.estado in ('en_camino','cancelado'))
            or (old.estado = 'en_camino' and new.estado = 'entregado')
        ) then
            raise exception 'No se puede cambiar un pedido de "%" a "%"', old.estado, new.estado
            using errcode = 'BL002';
        end if;

        if old.estado = 'aceptado'
            and new.estado = 'cancelado'
            and coalesce(trim(new.motivo_de_cancelacion),'') = '' then
            raise exception 'Debe indicar el motivo para cancelar un pedido aceptado'
            using errcode = 'BL003';
        end if;
    end if;

    -- Estado de pago
    if new.estado_pago is distinct from old.estado_pago
        and new.estado_pago = 'pagado'
        and new.estado not in ('aceptado','en_camino','entregado') then
        raise exception 'Solo se puede marcar como pagado un pedido aceptado, en camino o entregado'
        using errcode = 'BL004';
    end if;

    return new;
end;
$$;

create trigger trg_pedido_antes_de_actualizar
    before update on public.pedido
    for each row execute function public.fn_pedido_antes_de_actualizar();

-- ---------------------------------------------------------------------
-- AFTER UPDATE: devolver stock al rechazar o cancelar
-- security definer: en la Fase 2 el cliente no tendra permiso de
-- escritura sobre sabor, pero su cancelacion debe devolver el stock.
-- ---------------------------------------------------------------------
create or replace function public.fn_pedido_devolver_stock()
returns trigger
LANGUAGE plpgsql
set search_path = ''
as $$
begin
    if new.estado in ('rechazado','cancelado') then
        update public.sabor s
            set stock = s.stock + ap.cantidad
        from public.articulo_pedido ap
        where ap.pedido_id = new.id
            and s.id = ap.sabor_id;
    end if;

    return null;
end;
$$;

create trigger trg_pedido_devolver_stock
    after update of estado on public.pedido
    for each row
    when (old.estado is distinct from new.estado)
    execute function public.fn_pedido_devolver_stock();