-- =====================================================================
-- Migracion: crear_reglas_articulo_pedido
-- Descripcion: Reglas de negocio de la tabla articulo_pedido
--   - Solo editable si el pedido esta pendiente y dentro de la ventana
--   - Precio congelado desde sabor
--   - Validacion de sabor activo y stock suficiente
--   - Reserva y devolucion de stock
--   - Recalculo automatico del total del pedido
-- =====================================================================

-- ---------------------------------------------------------------------
-- Valida que un pedido todavia se pueda modificar
-- ---------------------------------------------------------------------
create or replace function public.validar_pedido_editable(p_pedido_id uuid)
returns void
language plpgsql
stable
set search_path = ''
as $$
declare
    v_estado public.tipo_estado_pedido;
    v_fecha_de_entrega date;
begin
    select estado, fecha_de_entrega
    into v_estado, v_fecha_de_entrega
    from public.pedido
    where id = p_pedido_id;

    if v_estado <> 'pendiente' then
        raise exception 'El pedido ya no se puede modificar (estado: %)', v_estado
        using errcode = 'BL005';
    end if;

    if public.fecha_de_entrega_vigente() is distinct from v_fecha_de_entrega then
        raise exception 'La ventana de pedidos ya cerro; el pedido no se puede modificar'
        using errcode = 'BL005';
    end if;
end;
$$;

-- Uso interno de los triggers: no se expone a la API
revoke execute on function public.validar_pedido_editable(uuid) from public, anon, authenticated;

-- ---------------------------------------------------------------------
-- BEFORE INSERT / UPDATE / DELETE: validar, congelar precio y mover stock
-- security definer: el cliente reserva stock sin permiso directo sobre sabor
-- ---------------------------------------------------------------------
create or replace function public.fn_articulo_pedido_antes()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_sabor public.sabor%rowtype;
    v_cantidad_extra integer;
begin
    -- DELETE ------------------------------------------------------------
    if tg_op = 'DELETE' then
        -- Borrado en cascada de un pedido: no se valida ni se mueve stock.
        -- Los pedidos no se eliminan; se cancelan.
        if not exists (select 1 from public.pedido where id = old.pedido_id) then
            return old;
        end if;

        perform public.validar_pedido_editable(old.pedido_id);

        update public.sabor
            set stock = stock + old.cantidad
        where id = old.sabor_id;

        return old;
    end if;

    -- INSERT / UPDATE -----------------------------------------------------
    perform public.validar_pedido_editable(new.pedido_id);

    if tg_op = 'UPDATE' then
        if new.pedido_id <> old.pedido_id or new.sabor_id <> old.sabor_id then
            raise exception 'No se puede cambiar el sabor de un articulo; eliminelo y agregue uno nuevo'
            using errcode = 'BL008';
        end if;

        new.precio_unitario := old.precio_unitario;
        v_cantidad_extra := new.cantidad - old.cantidad;
    else
        v_cantidad_extra := new.cantidad;
    end if;

    -- Bloquea la fila del sabor: dos pedidos simultaneos no pueden
    -- reservar el mismo ultimo bolo
    select * into v_sabor
    from public.sabor
    where id = new.sabor_id
    for update;

    if not found then
        raise exception 'El sabor no existe'
        using errcode = 'BL006';
    end if;

    if tg_op = 'INSERT' then
        new.precio_unitario := v_sabor.precio;
    end if;

    if v_cantidad_extra > 0 then
        if not v_sabor.es_activo then
            raise exception 'El sabor "%" no esta disponible', v_sabor.nombre
            using errcode = 'BL006';
        end if;

        if v_sabor.stock < v_cantidad_extra then
            raise exception 'Stock insuficiente de "%": quedan %', v_sabor.nombre, v_sabor.stock
            using errcode = 'BL007';
        end if;
    end if;

    if v_cantidad_extra <> 0 then 
        update public.sabor
            set stock = stock - v_cantidad_extra
        where id = new.sabor_id;
    end if;

    return new;
end;
$$;

create trigger trg_articulo_pedido_antes
    before insert or update or delete on public.articulo_pedido
    for each row execute function public.fn_articulo_pedido_antes();

-- ---------------------------------------------------------------------
-- AFTER INSERT / UPDATE / DELETE: recalcular el total del pedido
-- ---------------------------------------------------------------------
create or replace function public.fn_articulo_pedido_recalcular_total()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_pedido_id uuid;
begin
    if tg_op = 'DELETE' then
        v_pedido_id := old.pedido_id;
    else
        v_pedido_id := new.pedido_id;
    end if;

    update public.pedido p
        set total = coalesce(
            (select sum(ap.subtotal)
            from public.articulo_pedido ap
            where ap.pedido_id = v_pedido_id), 0)
        where p.id = v_pedido_id;
    
    return null;
end;
$$;

create trigger trg_articulo_pedido_recalcular_total
    after insert or update or delete on public.articulo_pedido
    for each row execute function public.fn_articulo_pedido_recalcular_total();