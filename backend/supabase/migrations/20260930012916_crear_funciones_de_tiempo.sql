-- =====================================================================
-- Migracion: crear_funciones_de_tiempo
-- Descripcion: Hora oficial del negocio (Guayaquil) y ventana de pedidos
--   Ventana: viernes 00:00 hasta sabado 07:59 -> entrega ese sabado 11:00
-- =====================================================================

-- ---------------------------------------------------------------------
-- Hora actual en Guayaquil (la base trabaja en UTC).
-- Solo para pruebas locales: si la sesion define app.ahora_simulada,
-- se usa esa fecha. Los clientes de la API no pueden definirla.
-- ---------------------------------------------------------------------

create or replace function public.ahora_guayaquil()
returns timestamp
language plpgsql
stable
set search_path = ''
as $$
declare
    v_simulada text := nullif(current_setting('app.ahora_simulada',true),'');
begin
    if v_simulada is not null then
        return v_simulada::timestamp;
    end if;
    return now() at time zone 'America/Guayaquil';
end;
$$;

comment on function public.ahora_guayaquil() is
    'Hora actual en America/Guayaquil. Acepta app.ahora_simulada para pruebas locales';

-- ---------------------------------------------------------------------
-- Fecha de entrega que corresponde si se pide ahora.
-- Devuelve null si estamos fuera de la ventana de pedidos.
-- ---------------------------------------------------------------------

create or replace function public.fecha_de_entrega_vigente()
returns date
language plpgsql
stable
set search_path = ''
as $$
declare
    v_ahora timestamp := public.ahora_guayaquil();
    v_dia integer := extract(isodow from v_ahora); -- 5 = viernes, 6 = sabado
begin
    if v_dia = 5 then
        return v_ahora::date + 1;
    elseif v_dia = 6 and v_ahora::time < time '08:00' then
        return v_ahora::date;
    end if;
    return null;
end;
$$;

comment on function public.fecha_de_entrega_vigente() is
    'Sabado de entrega si se pide ahora; null fuera de la ventana (viernes 00:00 - sabado 07:59)';