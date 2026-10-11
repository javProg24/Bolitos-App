-- ACT-15 (Fase 3): crear_pedido como unica puerta para crear pedidos.
-- Guarda el pedido y sus articulos en una sola transaccion (todo o nada).
-- El stock, el precio, el total y la ventana los siguen aplicando los
-- triggers de la Fase 1.

-- 1. Una sola puerta: sin escritura directa del cliente ------------------
-- Un pedido confirmado no se modifica; el cliente solo puede cancelarlo
-- (politica pedido_update, que no cambia).
drop policy if exists pedido_insert_propio          on public.pedido;
drop policy if exists articulo_pedido_insert_propio on public.articulo_pedido;
drop policy if exists articulo_pedido_update_propio on public.articulo_pedido;
drop policy if exists articulo_pedido_delete_propio on public.articulo_pedido;

revoke insert                 on public.pedido          from anon, authenticated;
revoke insert, update, delete on public.articulo_pedido from anon, authenticated;

-- Tambien se retiran permisos a nivel de columna, si los hubiera:
-- un revoke de tabla no los elimina.
do $$
declare
    c record;
begin
    for c in
        select table_name, column_name
          from information_schema.columns
         where table_schema = 'public'
           and table_name in ('pedido', 'articulo_pedido')
    loop
        execute format('revoke insert (%I) on public.%I from anon, authenticated',
                       c.column_name, c.table_name);
        if c.table_name = 'articulo_pedido' then
            execute format('revoke update (%I) on public.%I from anon, authenticated',
                           c.column_name, c.table_name);
        end if;
    end loop;
end;
$$;

-- 2. crear_pedido ---------------------------------------------------------
create or replace function public.crear_pedido(
    p_direccion_de_entrega  text,
    p_articulos             jsonb,
    p_referencia_de_entrega text default null,
    p_notas                 text default null
)
returns public.pedido
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_perfil_id uuid := auth.uid();
    v_pedido    public.pedido;
begin
    -- Quien llama: siempre el usuario del JWT, nunca un dato de la peticion
    if v_perfil_id is null then
        raise exception 'Se requiere iniciar sesion para crear un pedido'
        using errcode = '42501';
    end if;

    if coalesce(trim(p_direccion_de_entrega), '') = '' then
        raise exception 'La direccion de entrega es obligatoria'
        using errcode = 'BL014';
    end if;

    if p_articulos is null
       or jsonb_typeof(p_articulos) <> 'array'
       or jsonb_array_length(p_articulos) = 0 then
        raise exception 'El pedido debe tener al menos un articulo'
        using errcode = 'BL013';
    end if;

    -- Cada articulo: {"sabor_id": uuid, "cantidad": entero >= 1}.
    -- El CASE evalua en orden, para no convertir un valor que no es numero.
    if exists (
        select 1
          from jsonb_array_elements(p_articulos) e
         where case
                 when jsonb_typeof(e) <> 'object' then true
                 when jsonb_typeof(e -> 'sabor_id') is distinct from 'string' then true
                 when (e ->> 'sabor_id') !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' then true
                 when jsonb_typeof(e -> 'cantidad') is distinct from 'number' then true
                 when (e ->> 'cantidad')::numeric < 1 then true
                 when (e ->> 'cantidad')::numeric > 2147483647 then true
                 when (e ->> 'cantidad')::numeric <> trunc((e ->> 'cantidad')::numeric) then true
                 else false
               end
    ) then
        raise exception 'Cada articulo necesita un sabor valido y una cantidad entera mayor o igual a 1'
        using errcode = 'BL014';
    end if;

    -- Cabecera: el trigger asigna fecha de entrega, estado y total (o lanza BL001)
    insert into public.pedido (perfil_id, direccion_de_entrega, referencia_de_entrega, notas)
    values (v_perfil_id,
            trim(p_direccion_de_entrega),
            nullif(trim(p_referencia_de_entrega), ''),
            nullif(trim(p_notas), ''))
    returning * into v_pedido;

    -- Articulos: los sabores repetidos se suman. Se insertan ordenados por
    -- sabor para que dos pedidos simultaneos bloqueen los sabores en el mismo
    -- orden y no se produzca un interbloqueo (deadlock).
    insert into public.articulo_pedido (pedido_id, sabor_id, cantidad)
    select v_pedido.id, a.sabor_id, sum(a.cantidad)::integer
      from jsonb_to_recordset(p_articulos) as a(sabor_id uuid, cantidad integer)
     group by a.sabor_id
     order by a.sabor_id;

    -- Se relee para devolver el total ya calculado por los triggers
    select * into v_pedido from public.pedido where id = v_pedido.id;
    return v_pedido;
end;
$$;

comment on function public.crear_pedido(text, jsonb, text, text) is
    'Unica forma de crear un pedido: cabecera y articulos en una transaccion. BL013 sin articulos, BL014 datos invalidos; BL001, BL006 y BL007 vienen de los triggers.';

revoke execute on function public.crear_pedido(text, jsonb, text, text) from public, anon;
grant  execute on function public.crear_pedido(text, jsonb, text, text) to authenticated, service_role;