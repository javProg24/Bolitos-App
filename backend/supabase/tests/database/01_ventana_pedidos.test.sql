-- Pruebas de la ventana de pedidos (ACT-14)
-- La hora simulada es hora local de Guayaquil, sin zona horaria.
begin;


create extension if not exists pgtap with schema extensions;


select plan(8);

-- 1. La simulacion de hora funciona

select set_config('app.ahora_simulada', '2026-10-09 10:30:00', true);


select is (public.ahora_guayaquil(),
        '2026-10-09 10:30:00'::timestamp,
        'ahora_guayaquil() devuelve la hora simulada');

-- 2. Sin simulacion se usa la hora real de Guayaquil

select set_config('app.ahora_simulada', '', true);


select is(public.ahora_guayaquil(), now() at time zone 'America/Guayaquil', 'ahora_guayaquil() sin simulacion usa la hora real');

-- 3. Jueves 23:59:59: cerrada

select set_config('app.ahora_simulada', '2026-10-08 23:59:59', true);


select is(public.fecha_de_entrega_vigente(), null::date, 'Jueves 23:59:59: ventana cerrada');

-- 4. Viernes 00:00:00: abre, entrega el sabado

select set_config('app.ahora_simulada', '2026-10-09 00:00:00', true);


select is(public.fecha_de_entrega_vigente(), '2026-10-10'::date, 'Viernes 00:00:00: entrega el sabado 10');

-- 5. Viernes 23:59:59: abierta

select set_config('app.ahora_simulada', '2026-10-09 23:59:59', true);


select is(public.fecha_de_entrega_vigente(), '2026-10-10'::date, 'Viernes 23:59:59: entrega el sabado 10');

-- 6. Sabado 07:59:59: ultimo segundo abierto

select set_config('app.ahora_simulada', '2026-10-10 07:59:59', true);


select is(public.fecha_de_entrega_vigente(), '2026-10-10'::date, 'Sabado 07:59:59: entrega el mismo sabado');

-- 7. Sabado 08:00:00: cerrada

select set_config('app.ahora_simulada', '2026-10-10 08:00:00', true);


select is(public.fecha_de_entrega_vigente(), null::date, 'Sabado 08:00:00: ventana cerrada');

-- 8. Domingo: cerrada

select set_config('app.ahora_simulada', '2026-10-11 12:00:00', true);


select is(public.fecha_de_entrega_vigente(), null::date, 'Domingo: ventana cerrada');


select *
from finish();


rollback;