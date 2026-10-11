import { CATALOGO_ERRORES } from "./catalogoErrores.ts";
import { ErrorAplicacion } from "./ErrorAplicacion.ts";

/** Forma de los errores que devuelve supabase-js (PostgrestError). */
export interface ErrorDeBaseDeDatos{
    code?:string;
    message?:string;
}

/**
    * Convierte un error de PostgreSQL o PostgREST en un ErrorAplicacion.
    * Los errores de negocio (BLxxx) conservan el mensaje de la base como detalle,
    * porque dice exactamente que fallo (por ejemplo, que sabor no tiene stock).
    * Los errores inesperados nunca exponen el mensaje original a la app.
*/
export function traducirErroBaseDeDatos(error:ErrorDeBaseDeDatos):ErrorDeBaseDeDatos{
    const codigo=error.code??"";
    const definicion=CATALOGO_ERRORES[codigo];

    if(definicion){
        return new ErrorAplicacion(definicion.codigo,definicion.mensaje,definicion.estadoHttp,{
            detalles:error.message,
            codigoInterno:codigo,
            causa:error
        });
    }
    // Codigo de negocio que aun no esta en el catalogo
    if(/^BL\d{3}$/.test(codigo)){
        return new ErrorAplicacion(
            "REGLA_DE_NEGOCIO",
            error.message??"No se pudo completar la operacion.",
            409,
            {codigoInterno:codigo,causa:error}
        )
    }
    if(codigo==="42501"){
        return new ErrorAplicacion(
            "PERMISO_DENEGADO",
            "No tienes permiso para realizar esta operacion.",
            403,
            {codigoInterno:codigo,causa:error}
        )
    }
    if(codigo==="PGRST116"){
        return new ErrorAplicacion("NO_ENCONTRADO","El recurso solicitado no existe.", 404,{
            codigoInterno:codigo,
            causa:error
        })
    }
    // PGRST3xx: JWT ausente, invalido o expirado
    if(codigo.startsWith("PGRST3")){
        return new ErrorAplicacion(
            "SESION_INVALIDA",
            "Tu sesión no es válida o expiró. Inicia sesión nuevamente.",
            401,
        {codigoInterno:codigo,causa:error}
        )
    }
    return new ErrorAplicacion(
        "ERROR_INTERNO",
        "Ocurrió un error inesperado. Intenta nuevamente.",
        500,
        {codigoInterno:codigo||undefined,causa:error}
    )
}