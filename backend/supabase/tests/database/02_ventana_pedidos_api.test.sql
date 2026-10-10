-- Pruebas de ventana_pedidos(), BL001 y permisos (ACT-14)
begin;

create extension if not exists pgtap with schema extensions;

select plan(13);

-- Jueves 23:59:59: cerrada, la proxima entrega es el sabado 10
select set_config('app.ahora_simulada', '2026-10-08 23:59:59', true);
select is((select abierta from public.ventana_pedidos()), false,
    'Jueves: ventana cerrada');
select is((select fecha_de_entrega from public.ventana_pedidos()), '2026-10-10'::date,
    'Jueves: la proxima entrega es el sabado 10');

-- Viernes 00:00: abierta, con sus horas exactas
select set_config('app.ahora_simulada', '2026-10-09 00:00:00', true);
select is((select abierta from public.ventana_pedidos()), true,
    'Viernes 00:00: ventana abierta');
select is((select abre_el from public.ventana_pedidos()), '2026-10-09 00:00:00-05'::timestamptz,
    'Abre el viernes 00:00 de Guayaquil');
select is((select cierra_el from public.ventana_pedidos()), '2026-10-10 08:00:00-05'::timestamptz,
    'Cierra el sabado 08:00 de Guayaquil');
select is((select entrega_el from public.ventana_pedidos()), '2026-10-10 11:00:00-05'::timestamptz,
    'Entrega el sabado 11:00 de Guayaquil');

-- Pedido real dentro de la ventana: se crea con la fecha del sabado
select lives_ok(
    $$insert into public.pedido (perfil_id, direccion_de_entrega)
    values ('00000000-0000-4000-8000-000000000002', 'Prueba ACT-14')$$,
    'Viernes: se puede crear un pedido');
select is(
    (select fecha_de_entrega from public.pedido where direccion_de_entrega = 'Prueba ACT-14'),
    '2026-10-10'::date,
    'El pedido recibe la entrega del sabado 10');

-- Sabado 08:00: cerrada, la siguiente entrega es el sabado 17
select set_config('app.ahora_simulada', '2026-10-10 08:00:00', true);
select is((select abierta from public.ventana_pedidos()), false,
    'Sabado 08:00: ventana cerrada');
select is((select fecha_de_entrega from public.ventana_pedidos()), '2026-10-17'::date,
    'Sabado 08:00: la proxima entrega es el sabado 17');

-- Pedido fuera de la ventana: BL001
select throws_ok(
    $$insert into public.pedido (perfil_id, direccion_de_entrega)
    values ('00000000-0000-4000-8000-000000000002', 'Prueba ACT-14 fuera')$$,
    'BL001', null,
    'Sabado 08:00: crear un pedido falla con BL001');

-- Permisos
select ok(has_function_privilege('authenticated', 'public.ventana_pedidos()', 'execute'),
    'authenticated puede consultar la ventana');
select ok(not has_function_privilege('anon', 'public.ventana_pedidos()', 'execute'),
    'anon no puede consultar la ventana');

select * from finish();
rollback;