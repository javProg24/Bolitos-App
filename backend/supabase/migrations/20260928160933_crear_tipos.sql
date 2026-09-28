-- =====================================================================
-- Migracion: crear_tipos
-- Descripcion: Tipos enumerados del dominio Bolitos (ERD v1.0)
-- =====================================================================
create type public.tipo_rol as enum ('cliente', 'admin');

create type public.tipo_estado_pedido as enum (
    'pendiente',
    'aceptado',
    'rechazado',
    'entregado',
    'cancelado'
);

create type public.tipo_estado_pago as enum ('pendiente', 'pagado');

create type public.tipo_accion as enum ('INSERTy', 'UPDATE', 'DELETE');