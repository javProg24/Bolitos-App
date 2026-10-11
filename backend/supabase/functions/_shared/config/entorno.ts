/**
 * Variables de entorno de las Edge Functions.
 * Supabase inyecta SUPABASE_URL y SUPABASE_ANON_KEY en cada funcion,
 * tanto en local como en Supabase Cloud. Nunca se escriben en el codigo.
 */
function leerVariable(nombre: string): string {
    const valor = Deno.env.get(nombre);
    if (!valor) {
        throw new Error(`Falta la variable de entorno ${nombre}`);
    }
    return valor;
}

export const entorno = {
    get supabaseUrl(): string {
        return leerVariable("SUPABASE_URL");
    },
    get supabaseAnonKey(): string {
        return leerVariable("SUPABASE_ANON_KEY");
    },
};