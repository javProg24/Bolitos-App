-- =====================================================================
-- Seed: catalogo oficial de sabores (solo entorno local)
-- Se ejecuta automaticamente con: pnpm supabase db reset
-- En produccion, los sabores se registran desde la app admin.
-- =====================================================================

insert into public.sabor(nombre,precio,stock)
values
    ('Chocolate',         0.25,0),
    ('Leche',             0.25,0),
    ('Frutilla',          0.25,0),
    ('Coco',              0.25,0),
    ('Ensalada de fruta', 0.25,0),
    ('Mora',              0.25,0)
on conflict (nombre) do nothing;

-- =====================================================================
-- Usuarios de desarrollo (SOLO entorno local)
-- El seed no se aplica en Supabase Cloud.
-- Contrasenas solo de desarrollo: NO son las de produccion.
-- El perfil lo crea el trigger de la ACT-12 a partir de raw_user_meta_data.
-- =====================================================================

-- Admin de desarrollo: Dev#Bolitos2026
-- Cliente de prueba:   Bolitos#2026

insert into auth.users (
    instance_id, id, aud, role, email, encrypted_password,
    email_confirmed_at, raw_app_meta_data, raw_user_meta_data,
    created_at, updated_at,
    confirmation_token, recovery_token, email_change_token_new,
    email_change, email_change_token_current, phone_change,
    phone_change_token, reauthentication_token
)
values 
(
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-4000-8000-000000000001',
    'authenticated', 'authenticated',
    'javiertomalag14@gmail.com',
    extensions.crypt('Dev#Bolitos2026', extensions.gen_salt('bf')),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"nombres_completos": "Felix Javier Tomala Gonzalez", "telefono": "0900000001"}',
    now(), now(),
    '', '', '', '', '', '', '', ''
),
(
    '00000000-0000-0000-0000-000000000000',
    '00000000-0000-4000-8000-000000000002',
    'authenticated', 'authenticated',
    'cliente1@example.com',
    extensions.crypt('Bolitos#2026', extensions.gen_salt('bf')),
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"nombres_completos": "Cliente Prueba", "telefono": "0991234567"}',
    now(), now(),
    '', '', '', '', '', '', '', ''
);

-- Identidades: sin esto, el login con correo y contrasena falla
insert into auth.identities (
    id, user_id, provider_id, provider, identity_data,
    last_sign_in_at, created_at, updated_at
)
select gen_random_uuid(), u.id, u.id::text, 'email',
        jsonb_build_object('sub', u.id::text, 'email', u.email, 'email_verified', true),
        now(), now(), now()
from auth.users u
where u.id in (
    '00000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000002'
);

-- Datos ficticios de direccion del admin de desarrollo
update public.perfil
    set direccion            = 'Direccion de prueba',
        direccion_referencia = 'Referencia de prueba'
    where id = '00000000-0000-4000-8000-000000000001';

-- Asignar el rol admin (queda auditado por trg_perfil_auditar_rol)
update public.perfil
    set rol = 'admin'
    where id = '00000000-0000-4000-8000-000000000001';