-- =====================================================================
-- Migracion: crear_indices
-- Descripcion: Indices para consultas frecuentes y llaves foraneas
-- =====================================================================

-- Historial de pedidos del cliente
create index idx_pedido_perfil_id
    on public.pedido (perfil_id);

-- Lista de pedidos del admin por estado y fecha de entrega
create index idx_pedido_estado_fecha_entrega
    on public.pedido (estado, fecha_de_entrega);

-- FK hacia sabor (estadisticas por sabor y validacion del ON DELETE RESTRICT)
create index idx_articulo_pedido_sabor_id
    on public.articulo_pedido (sabor_id);

-- FK hacia perfil en auditoria
create index idx_registro_auditoria_perfil_id
    on public.registro_auditoria (perfil_id);

-- Consultar el historial de un registro especifico
create index idx_registro_auditoria_tabla_registro
    on public.registro_auditoria (nombre_tabla, registro_id);