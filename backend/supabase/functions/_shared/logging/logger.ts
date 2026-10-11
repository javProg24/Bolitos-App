/**
    * Logging estructurado en JSON (una linea por evento), legible desde el
    * panel de logs de Supabase. Regla: nunca registrar datos personales
    * (direccion, telefono, correo, nombres); solo identificadores y metricas.
*/
type Nivel="debug" | "info" | "warn" | "error";
type Contexto=Record<string,unknown>;

export interface Logger{
    debug(mensaje:string,contexto?:Contexto):void;
    info(mensaje:string,contexto?:Contexto):void;
    warn(mensaje:string,contexto?:Contexto):void;
    error(mensaje:string,contexto?:Contexto):void;
    /** Logger que agrega contexto fijo (por ejemplo, el idSolicitud). */
    hijo(contexto:Contexto):Logger;
}
export function crearLogger(contextoBase:Contexto={}):Logger{
    const escribir=(nivel:Nivel, mensaje:string,contexto:Contexto={}):void=>{
        const linea=JSON.stringify({
            nivel,
            mensaje,
            ...contextoBase,
            ...contexto
        });
        if(nivel==="error")console.error(linea);
        else if(nivel==="warn")console.warn(linea);
        else console.log(linea);
    };
    return{
        debug:(mensaje,contexto)=>escribir("debug",mensaje,contexto),
        info:(mensaje,contexto)=>escribir("info",mensaje,contexto),
        warn:(mensaje,contexto)=>escribir("warn",mensaje,contexto),
        error:(mensaje,contexto)=>escribir("error",mensaje,contexto),
        hijo:(contexto)=>crearLogger({...contextoBase,...contexto})
    }
}