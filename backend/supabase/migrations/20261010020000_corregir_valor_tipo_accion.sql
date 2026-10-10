-- =====================================================================
-- Migracion: corregir_valor_tipo_accion
-- Descripcion: Corrige typo en enum tipo_accion ('INSERTy' -> 'INSERT')
--              introducido en 20260928160933_crear_tipos.sql
-- =====================================================================
alter type public.tipo_accion rename value 'INSERTy' to 'INSERT';