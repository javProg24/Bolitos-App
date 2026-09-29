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