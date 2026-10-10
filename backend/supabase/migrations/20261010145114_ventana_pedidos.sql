-- ACT-14 (Fase 3): ventana de pedidos como definicion unica del horario.
-- ventana_pedidos() es la unica funcion que conoce el horario.
-- fecha_de_entrega_vigente() pasa a depender de ella con la misma firma,
-- por lo que los triggers de pedido y articulo_pedido no cambian.
 -- 1. Definicion unica del horario --------------------------------------

create or replace function public.ventana_pedidos(out abierta boolean, out fecha_de_entrega date, out abre_el timestamptz, out cierra_el timestamptz, out entrega_el timestamptz, out ahora timestamptz) language plpgsql stable
set search_path = '' as $$
declare
    v_ahora timestamp := public.ahora_guayaquil();
    v_sabado date;
begin
    -- Sabado de entrega: hoy si es sabado; si no, el proximo (isodow 6)
    v_sabado := v_ahora::date + ((6 - extract(isodow from v_ahora)::integer + 7) % 7);

    -- Desde el sabado 08:00 la ventana de ese sabado ya cerro: pasa al siguiente
    if v_ahora >= v_sabado + time '08:00' then
        v_sabado := v_sabado + 7;
    end if;

    -- La ventana va del viernes 00:00 al sabado 08:00 (hora de Guayaquil)
    fecha_de_entrega := v_sabado;
    abierta := v_ahora >= (v_sabado - 1)::timestamp
            and v_ahora <  v_sabado + time '08:00';

    -- Horas locales de Guayaquil convertidas a timestamptz
    abre_el    := (v_sabado - 1)::timestamp at time zone 'America/Guayaquil';
    cierra_el  := (v_sabado + time '08:00') at time zone 'America/Guayaquil';
    entrega_el := (v_sabado + time '11:00') at time zone 'America/Guayaquil';
    ahora      := v_ahora                   at time zone 'America/Guayaquil';
end;
$$;

comment on function public.ventana_pedidos() is 'Ventana de pedidos vigente o proxima: viernes 00:00 a sabado 08:00, entrega sabado 11:00 (Guayaquil). Unica definicion del horario.';

revoke execute on function public.ventana_pedidos()
from public, anon;

grant execute on function public.ventana_pedidos() to authenticated, service_role;

-- 2. fecha_de_entrega_vigente() pasa a depender de ventana_pedidos() ----

create or replace function public.fecha_de_entrega_vigente() returns date language sql stable
set search_path = '' as $$
    select case when v.abierta then v.fecha_de_entrega end
    from public.ventana_pedidos() v;
$$;

-- 3. Limpieza: se elimina la linea duplicada new.total := 0 -------------

create or replace function public.fn_pedido_antes_de_insertar() returns trigger language plpgsql
set search_path = '' as $$
declare
    v_fecha_entrega date := public.fecha_de_entrega_vigente();
begin
    if v_fecha_entrega is null then
        raise exception 'Solo se aceptan pedidos desde el viernes 00:00 hasta el sabado 08:00'
        using errcode = 'BL001';
    end if;

    -- Valores que el cliente no puede decidir
    new.fecha_de_entrega      := v_fecha_entrega;
    new.estado                := 'pendiente';
    new.estado_pago           := 'pendiente';
    new.total                 := 0;
    new.motivo_de_rechazo     := null;
    new.motivo_de_cancelacion := null;
    new.creado_el             := now();
    new.actualizado_el        := now();

    return new;
end;
$$;