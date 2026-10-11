-- Pruebas de crear_pedido (ACT-15)
-- Se actua como cliente1 desde la app (rol authenticated con su JWT).
begin;

create extension if not exists pgtap with schema extensions;

select plan(21);

-- Preparacion (como postgres): viernes 10:00 y stock conocido -----------
select set_config('app.ahora_simulada', '2026-10-09 10:00:00', true);
update public.sabor set stock = 10, es_activo = true where nombre in ('Coco', 'Mora');

-- Desde aqui actuamos como cliente1 -------------------------------------
select set_config('request.jwt.claims',
    '{"sub": "00000000-0000-4000-8000-000000000002", "role": "authenticated"}', true);
set local role authenticated;

-- 1-7. Pedido valido: 2 Coco + 3 Mora -----------------------------------
select lives_ok(
    $$select public.crear_pedido(
        p_direccion_de_entrega => 'Prueba 03-A',
        p_articulos => jsonb_build_array(
            jsonb_build_object('sabor_id', (select id from public.sabor where nombre = 'Coco'), 'cantidad', 2),
            jsonb_build_object('sabor_id', (select id from public.sabor where nombre = 'Mora'), 'cantidad', 3)))$$,
    'Viernes: el cliente crea un pedido de 2 Coco y 3 Mora');

select is((select count(*) from public.pedido where direccion_de_entrega = 'Prueba 03-A'), 1::bigint,
    'Se crea un solo pedido');
select is((select perfil_id from public.pedido where direccion_de_entrega = 'Prueba 03-A'),
    '00000000-0000-4000-8000-000000000002'::uuid,
    'El pedido pertenece a quien lo crea (auth.uid())');
select is((select count(*) from public.articulo_pedido ap
                join public.pedido p on p.id = ap.pedido_id
            where p.direccion_de_entrega = 'Prueba 03-A'), 2::bigint,
    'El pedido tiene 2 articulos');
select is((select total from public.pedido where direccion_de_entrega = 'Prueba 03-A'),
    (select 2 * precio from public.sabor where nombre = 'Coco')
      + (select 3 * precio from public.sabor where nombre = 'Mora'),
    'El total se calcula con los precios del catalogo');
select is((select stock from public.sabor where nombre = 'Coco'), 8,
    'Se reservan 2 Coco (quedan 8)');
select is((select stock from public.sabor where nombre = 'Mora'), 7,
    'Se reservan 3 Mora (quedan 7)');

-- 8-9. Sabores repetidos se suman ---------------------------------------
select lives_ok(
    $$select public.crear_pedido(
        p_direccion_de_entrega => 'Prueba 03-B',
        p_articulos => jsonb_build_array(
            jsonb_build_object('sabor_id', (select id from public.sabor where nombre = 'Coco'), 'cantidad', 2),
            jsonb_build_object('sabor_id', (select id from public.sabor where nombre = 'Coco'), 'cantidad', 3)))$$,
    'Pedido con Coco repetido');
select is((select string_agg(ap.cantidad::text, ',') from public.articulo_pedido ap
                join public.pedido p on p.id = ap.pedido_id
            where p.direccion_de_entrega = 'Prueba 03-B'), '5',
    '2 Coco + 3 Coco quedan en una sola linea de 5');

-- 10-11. Validaciones de formato ----------------------------------------
select throws_ok(
    $$select public.crear_pedido(p_direccion_de_entrega => 'Prueba 03-vacio', p_articulos => '[]'::jsonb)$$,
    'BL013', null,
    'Un pedido sin articulos falla con BL013');
select throws_ok(
    $$select public.crear_pedido(
        p_direccion_de_entrega => '   ',
        p_articulos => jsonb_build_array(
            jsonb_build_object('sabor_id', (select id from public.sabor where nombre = 'Mora'), 'cantidad', 1)))$$,
    'BL014', null,
    'Una direccion vacia falla con BL014');

-- 12-14. Todo o nada: 1 Mora valida + 999 Coco sin stock -----------------
select throws_ok(
    $$select public.crear_pedido(
        p_direccion_de_entrega => 'Prueba 03-C',
        p_articulos => jsonb_build_array(
            jsonb_build_object('sabor_id', (select id from public.sabor where nombre = 'Mora'), 'cantidad', 1),
            jsonb_build_object('sabor_id', (select id from public.sabor where nombre = 'Coco'), 'cantidad', 999)))$$,
    'BL007', null,
    'Sin stock suficiente falla con BL007');
select is((select count(*) from public.pedido where direccion_de_entrega = 'Prueba 03-C'), 0::bigint,
    'Todo o nada: no queda el pedido');
select is((select stock from public.sabor where nombre = 'Mora'), 7,
    'Todo o nada: la Mora del pedido fallido no se descuenta');

-- 15-18. Una sola puerta: sin escritura directa ------------------------
select throws_ok(
    $$insert into public.pedido (perfil_id, direccion_de_entrega)
        values ('00000000-0000-4000-8000-000000000002', 'Prueba 03-directo')$$,
    '42501', null,
    'El cliente no puede insertar pedidos directamente');
select throws_ok(
    $$insert into public.articulo_pedido (pedido_id, sabor_id, cantidad)
        values ((select id from public.pedido where direccion_de_entrega = 'Prueba 03-A'),
                (select id from public.sabor where nombre = 'Mora'), 1)$$,
    '42501', null,
    'El cliente no puede agregar articulos a un pedido confirmado');
select throws_ok(
    $$update public.articulo_pedido set cantidad = 1
        where pedido_id = (select id from public.pedido where direccion_de_entrega = 'Prueba 03-A')$$,
    '42501', null,
    'El cliente no puede cambiar cantidades de un pedido confirmado');
select throws_ok(
    $$delete from public.articulo_pedido
        where pedido_id = (select id from public.pedido where direccion_de_entrega = 'Prueba 03-A')$$,
    '42501', null,
    'El cliente no puede quitar articulos de un pedido confirmado');

-- 19. Ventana cerrada ---------------------------------------------------
select set_config('app.ahora_simulada', '2026-10-10 08:00:00', true);
select throws_ok(
    $$select public.crear_pedido(
        p_direccion_de_entrega => 'Prueba 03-cerrada',
        p_articulos => jsonb_build_array(
            jsonb_build_object('sabor_id', (select id from public.sabor where nombre = 'Mora'), 'cantidad', 1)))$$,
    'BL001', null,
    'Sabado 08:00: falla con BL001');

-- 20. Sin sesion --------------------------------------------------------
select set_config('app.ahora_simulada', '2026-10-09 10:00:00', true);
select set_config('request.jwt.claims', '{}', true);
select throws_ok(
    $$select public.crear_pedido(
        p_direccion_de_entrega => 'Prueba 03-sin-sesion',
        p_articulos => jsonb_build_array(
            jsonb_build_object('sabor_id', (select id from public.sabor where nombre = 'Mora'), 'cantidad', 1)))$$,
    '42501', null,
    'Sin usuario (auth.uid() nulo) falla con 42501');

-- 21. Permisos ----------------------------------------------------------
select ok(not has_function_privilege('anon', 'public.crear_pedido(text, jsonb, text, text)', 'execute'),
    'anon no puede ejecutar crear_pedido');

select * from finish();
rollback;