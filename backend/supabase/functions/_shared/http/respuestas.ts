import { ErrorAplicacion } from "../errors/ErrorAplicacion.ts";

export const CABECERAS_CORS:Readonly<Record<string,string>>={
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-request-id",
    "Access-Control-Allow-Methods": "GET, POST, PATCH, OPTIONS",
};
function respuestaJson(cuerpo:unknown,estado:number,idSolicitud:string):Response{
    return new Response(JSON.stringify(cuerpo),{
        status:estado,
        headers:{
            ...CABECERAS_CORS,
            "Content-Type": "application/json; charset=utf-8",
            "X-Request-Id": idSolicitud,
        }
    })
}
export function respuestaExito<T>(data:T,estado:number, idSolicitud:string):Response{
    return respuestaJson({data},estado,idSolicitud)
}
export function respuestaError(error:ErrorAplicacion, idSolicitud:string):Response{
    return respuestaJson(
        {
            error:{
                codigo:error.codigo,
                mensaje:error.message,
                detalles:error.detalles??null,
                idSolicitud
            }
        },
        error.estadoHttp,
        idSolicitud
    )
}