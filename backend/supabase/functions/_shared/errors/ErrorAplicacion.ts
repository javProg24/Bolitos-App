/** Detalle de un campo invalido, para que la app lo muestre junto al campo. */
export interface DetalleError{
    campo: string;
    mensaje: string;
}

export interface OpcionesError{
    /** Detalles para la app: lista de campos invalidos o un texto adicional. */
    detalles?: DetalleError[] | string;
    /** Codigo original de la base (BL007, 42501, PGRST116...). Solo para logs. */
    codigoInterno?:string;
    /** Error original. Solo para logs; nunca se envia a la app. */
    causa?: unknown;
}

/**
    * Error controlado de la aplicacion. Todo error que llega a la app pasa por
    * aqui: un codigo estable (STOCK_INSUFICIENTE), un mensaje en espanol y el
    * estado HTTP que le corresponde.
*/
export class ErrorAplicacion extends Error{
    readonly detalles?: DetalleError[] | string;
    readonly codigoInterno?: string;

    constructor(
        readonly codigo: string,
        mensaje: string,
        readonly estadoHttp: number,
        opciones: OpcionesError={}
    ){
        super(mensaje,{cause: opciones.causa});
        this.name='ErrorAplicacion';
        this.detalles=opciones.detalles;
        this.codigoInterno=opciones.codigoInterno;
    }
}