-- =====================================================================
-- Migracion: crear_tablas
-- Descripcion: Tablas del dominio Bolitos (ERD v1.0) con llaves,
--              restricciones de integridad y RLS activado.
-- =====================================================================

-- ---------------------------------------------------------------------
-- perfil: datos del usuario, 1:1 con auth.users
-- ---------------------------------------------------------------------

create table public.perfil (
    id                    uuid primary key references auth.users (id) on delete cascade,
    nombres_completos     varchar(120) not null,
    telefono              varchar(20),
    direccion             text,
    direccion_referencia  text,
    rol                   public.tipo_rol not null default 'cliente',
    token_notificacion    text,
    avatar_url            text,
    creado_el             timestamptz not null default now(),
    actualizado_el        timestamptz not null default now()
);
COMMENT ON TABLE public.perfil IS 'Perfil de usuario. id = auth.users.id';
COMMENT ON COLUMN public.perfil.rol is 'Admin se asigna manualmente. Sin UPDATE para clientes (Fase 2)';
COMMENT ON COLUMN public.perfil.token_notificacion is 'Token de Expo Push. Un dispositivo por cliente';

-- ---------------------------------------------------------------------
-- sabor: catalogo de productos con stock general
-- ---------------------------------------------------------------------

create table public.sabor (
    id              uuid primary key default gen_random_uuid(),
    nombre          varchar(60) not null,
    descripcion     text,
    precio          numeric(10,2) not null,
    stock           integer not null default 0,
    imagen_url      text,
    es_activo       boolean not null default true,
    creado_el       timestamptz not null default now(),
    actualizado_el  timestamptz not null default now(),

    constraint sabor_nombre_unico      unique (nombre),
    constraint sabor_precio_positivo   check (precio > 0),
    constraint sabor_stock_no_negativo check (stock >= 0)
);
comment on table public.sabor is 'Catalogo de sabores. Nunca se borra: se deshabilita con es_activo';

-- ---------------------------------------------------------------------
-- pedido: cabecera del pedido
-- ---------------------------------------------------------------------
create table public.pedido (
    id                     uuid primary key default gen_random_uuid(),
    perfil_id              uuid not null
                            references public.perfil (id) on delete restrict,
    estado                 public.tipo_estado_pedido not null default 'pendiente',
    estado_pago            public.tipo_estado_pago   not null default 'pendiente',
    motivo_de_rechazo      text,
    fecha_de_entrega       date not null,
    direccion_de_entrega   text not null,
    referencia_de_entrega  text,
    notas                  text,
    total                  numeric(10,2) not null default 0,
    creado_el              timestamptz not null default now(),
    actualizado_el         timestamptz not null default now(),

    constraint pedido_entrega_en_sabado
        check (extract(isodow from fecha_de_entrega) = 6),
    constraint pedido_motivo_si_rechazado
        check (estado <> 'rechazado'
            or (motivo_de_rechazo is not null and length(trim(motivo_de_rechazo)) > 0)),
    constraint pedido_total_no_negativo
        check (total >= 0)
);

-- ---------------------------------------------------------------------
-- articulo_pedido: detalle del pedido
-- ---------------------------------------------------------------------
create table public.articulo_pedido (
    id               uuid primary key default gen_random_uuid(),
    pedido_id        uuid not null references public.pedido (id) on delete cascade,
    sabor_id         uuid not null references public.sabor (id) on delete restrict,
    cantidad         integer not null,
    precio_unitario  numeric(10,2) not null,
    subtotal         numeric(10,2) generated always as (cantidad * precio_unitario) stored,

    constraint articulo_pedido_cantidad_positiva check (cantidad > 0),
    constraint articulo_pedido_sabor_unico       unique (pedido_id, sabor_id)
);
comment on column public.articulo_pedido.precio_unitario is 'Precio congelado al confirmar el pedido';

-- ---------------------------------------------------------------------
-- registro_auditoria: historial de operaciones criticas
-- ---------------------------------------------------------------------
create table public.registro_auditoria (
    id              bigint generated always as identity primary key,
    nombre_tabla    varchar(63) not null,
    registro_id     uuid not null,
    accion          public.tipo_accion not null,
    datos_antiguos  jsonb,
    datos_nuevos    jsonb,
    perfil_id       uuid references public.perfil (id) on delete set null,
    creado_el       timestamptz not null default now()
);
comment on column public.registro_auditoria.perfil_id is 'Quien hizo el cambio';

-- ---------------------------------------------------------------------
-- RLS activado en todas las tablas.
-- Sin politicas = sin acceso desde la API hasta la Fase 2.
-- ---------------------------------------------------------------------
alter table public.perfil             enable row level security;
alter table public.sabor              enable row level security;
alter table public.pedido             enable row level security;
alter table public.articulo_pedido    enable row level security;
alter table public.registro_auditoria enable row level security;