-- =====================================================================
-- Migracion: conceder_permisos_api
-- Descripcion: Correccion de la ACT-10. Las tablas nuevas de public no
--   tienen permisos para la API por defecto. RLS decide QUE FILAS; estos
--   GRANT deciden QUE OPERACIONES. Se concede solo lo que usan las
--   politicas RLS (minimo privilegio).
-- =====================================================================

grant usage on schema public to authenticated, service_role;

-- perfil: leer (el update por columnas ya se concedio en la ACT-10)
grant select on public.perfil to authenticated;

-- sabor: leer; crear y editar (las politicas lo limitan al admin)
grant select, insert, update on public.sabor to authenticated;

-- pedido: leer, crear y actualizar (cancelar / cambiar estado)
grant select, insert, update on public.pedido to authenticated;

-- articulo_pedido: gestion completa de los articulos de sus pedidos
grant select, insert, update, delete on public.articulo_pedido to authenticated;

-- registro_auditoria: solo lectura (la politica lo limita al admin)
grant select on public.registro_auditoria to authenticated;

-- service_role (Edge Functions, Fase 3): ignora RLS, pero necesita
-- permisos de tabla para operar
grant select, insert, update, delete
    on public.perfil, public.sabor, public.pedido,
        public.articulo_pedido, public.registro_auditoria
    to service_role;