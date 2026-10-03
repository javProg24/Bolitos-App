-- =========================================================================================
-- Migracion: crear_politicas_rls
-- Descripcion: Politicas RLS por tabla y por rol (cliente/admin)
-- Convencion: una politica por operacion, siempre "to authenticated" y con "using" y "with check" para que se cumpla la condicion
-- (select auth.uid()) y (select public.es_admin()) se evaluan una sola
-- vez por consulta y no una vez por fila.
-- =========================================================================================
-- -----------------------------------------------------------------------------------------
-- Segunda barrera: anon no tiene ningun permiso sobre las tablas.
-- El catalogo solo se ve con sesion iniciada.
-- -----------------------------------------------------------------------------------------
revoke all on public.perfil from anon;
revoke all on public.sabor from anon;
revoke all on public.pedido from anon;
revoke all on public.articulo_pedido from anon;
revoke all on public.registro_auditoria from anon;

--TRUNCATE no respeta RLS: se retira a authenticated en todas las tablas
revoke truncate, references, trigger on public.perfil from authenticated;
revoke truncate, references, trigger on public.sabor from authenticated;
revoke truncate, references, trigger on public.pedido from authenticated;
revoke truncate, references, trigger on public.articulo_pedido from authenticated;
revoke truncate, references, trigger on public.registro_auditoria from authenticated;

-- =========================================================================================
-- perfil
-- =========================================================================================
revoke insert, delete on public.perfil from authenticated;

-- RLS controla filas, no columnas. El update de toda la tabla se quita y se concede solo en
-- las columnas editables: rol, id y fechas quedan fuera.
revoke update on public.perfil from authenticated;
grant update (
    nombres_completos,
    telefono,
    direccion,
    direccion_referencia,
    token_notificacion,
    avatar_url
) on public.perfil to authenticated;

create policy perfil_select
on public.perfil
for select
to authenticated
using (
    id = (select auth.uid())
    or (select public.es_admin())
);

create policy perfil_update_propio
on public.perfil
for update
to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()));

-- =========================================================================================
-- sabor
-- =========================================================================================
-- delete: los sabores se deshabilitan (es_activo = false)
revoke delete on public.sabor from authenticated;

-- Cliente: solo activos (los agotados siguen visibles). Admin: todos.
create policy sabor_select
on public.sabor
for select
to authenticated
using (
    es_activo
    or (select public.es_admin())
);

create policy sabor_insert_admin
on public.sabor
for insert
to authenticated
with check ((select public.es_admin()));

create policy sabor_update_admin
on public.sabor
for update
to authenticated
using ((select public.es_admin()))
with check ((select public.es_admin()));

-- =========================================================================================
-- pedido
-- =========================================================================================
-- delete: los pedidos se cancelan, no se borran
revoke delete on public.pedido from authenticated;

create policy pedido_select
on public.pedido
for select
to authenticated
using(
    perfil_id = (select auth.uid())
    or (select public.es_admin())
);

-- Solo el cliente crea pedidos, y siempre a su nombre
create policy pedido_insert_propio
on public.pedido
for insert
to authenticated
with check (perfil_id = (select auth.uid()));

-- Cliente: solo puede dejar su pedido en "cancelado".
-- (Que columnas cambia lo limita el trigger de proteger_columnas_pedido; desde que estados
-- puede cancelar lo limitan las transiciones de la Fase 1.)
-- Admin: cualquier cambio que permiten los triggers.
create policy pedido_update
on public.pedido
for update
to authenticated
using (
    perfil_id = (select auth.uid())
    or (select public.es_admin())
)
with check (
    (perfil_id = (select auth.uid()) and estado = 'cancelado')
    or (select public.es_admin())
);

-- =========================================================================================
-- articulo_pedido
-- =========================================================================================
-- El cliente opera solo sobre articulos de sus pedidos. Los triggers de la Fase 1 ya
-- limitan los cambios a pedidos pendientes y en ventana.
create policy articulo_pedido_select
on public.articulo_pedido
for select
to authenticated
using (
    exists (
        select 1 
        from public.pedido p
        where p.id = articulo_pedido.pedido_id
        and p.perfil_id = (select auth.uid())
    )
    or (select public.es_admin())
);

create policy articulo_pedido_insert_propio
on public.articulo_pedido
for insert
to authenticated
with check (
    exists (
        select 1
        from public.pedido p
        where p.id = articulo_pedido.pedido_id
        and p.perfil_id = (select auth.uid())
    )
);

create policy articulo_pedido_update_propio
on public.articulo_pedido
for update
to authenticated
using (
    exists (
        select 1
        from public.pedido p
        where p.id = articulo_pedido.pedido_id
        and p.perfil_id = (select auth.uid())
    )
)
with check (
    exists (
        select 1
        from public.pedido p
        where p.id = articulo_pedido.pedido_id
        and p.perfil_id = (select auth.uid())
    )
);

create policy articulo_pedido_delete_propio
on public.articulo_pedido
for delete
to authenticated
using (
    exists (
        select 1
        from public.pedido p
        where p.id = articulo_pedido.pedido_id
        and p.perfil_id = (select auth.uid())
    )
);

-- =========================================================================================
-- registro_auditoria
-- =========================================================================================
-- Solo escriben los triggers (security definer). Desde la API: solo lectura admin.
revoke insert, update, delete on public.registro_auditoria from authenticated;
create policy registro_auditoria_select_admin
on public.registro_auditoria
for select
to authenticated
using ((select public.es_admin()));