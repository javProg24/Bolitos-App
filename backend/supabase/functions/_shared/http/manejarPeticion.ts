import { ErrorAplicacion } from "../errors/ErrorAplicacion.ts";
import { crearLogger, type Logger } from "../logging/logger.ts";
import { CABECERAS_CORS, respuestaError } from "./respuestas.ts";

export interface ContextoPeticion {
  idSolicitud: string;
  logger: Logger;
}

type Metodo = "GET" | "POST" | "PATCH";

interface OpcionesFuncion {
    /** Nombre de la Edge Function, para los logs. */
    nombre: string;
    metodo: Metodo;
    manejador: (req: Request, contexto: ContextoPeticion) => Promise<Response>;
}

/**
 * Envoltorio comun de todas las Edge Functions: CORS, metodo HTTP,
 * idSolicitud, logging con duracion y manejo centralizado de errores.
 * Cada funcion solo escribe su logica en `manejador`.
 */
export function crearManejador(opciones: OpcionesFuncion): (req: Request) => Promise<Response> {
    const loggerBase = crearLogger({ funcion: opciones.nombre });

    return async (req: Request): Promise<Response> => {
        if (req.method === "OPTIONS") {
        return new Response("ok", { headers: CABECERAS_CORS });
        }

        const idSolicitud = req.headers.get("x-request-id") ?? crypto.randomUUID();
        const logger = loggerBase.hijo({ idSolicitud });
        const inicio = performance.now();
        const duracionMs = () => Math.round(performance.now() - inicio);

        try {
        if (req.method !== opciones.metodo) {
            throw new ErrorAplicacion(
            "METODO_NO_PERMITIDO",
            `Esta función solo acepta ${opciones.metodo}.`,
            405,
            );
        }

        const respuesta = await opciones.manejador(req, { idSolicitud, logger });
        logger.info("Solicitud completada", { estado: respuesta.status, duracionMs: duracionMs() });
        return respuesta;
        } catch (error) {
        const errorApp = error instanceof ErrorAplicacion ? error : new ErrorAplicacion(
            "ERROR_INTERNO",
            "Ocurrió un error inesperado. Intenta nuevamente.",
            500,
            { causa: error },
        );

        const datosLog = {
            estado: errorApp.estadoHttp,
            codigo: errorApp.codigo,
            codigoInterno: errorApp.codigoInterno,
            causa: describirCausa(errorApp.cause),
            duracionMs: duracionMs(),
        };

        if (errorApp.estadoHttp >= 500) logger.error("Solicitud fallida", datosLog);
        else logger.warn("Solicitud rechazada", datosLog);

        return respuestaError(errorApp, idSolicitud);
        }
    };
}

/** Lee el cuerpo como JSON; si no es JSON valido responde 400. */
export async function leerJson(req: Request): Promise<unknown> {
    try {
        return await req.json();
    } catch {
        throw new ErrorAplicacion("JSON_INVALIDO", "El cuerpo de la solicitud no es un JSON válido.", 400);
    }
}

function describirCausa(causa: unknown): unknown {
    if (causa === undefined || causa === null) return undefined;
    if (causa instanceof Error) return { nombre: causa.name, mensaje: causa.message };
    return causa;
}