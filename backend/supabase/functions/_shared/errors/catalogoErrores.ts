/**
    * Catalogo de errores de negocio que lanza PostgreSQL (BLxxx).
    * La base solo conoce el codigo; aqui se decide el nombre estable para la app,
    * el estado HTTP y el mensaje en espanol.
*/
export interface DefinicionError{
    codigo:string;
    estadoHttp:number;
    mensaje:string;
}

export const CATALOGO_ERRORES: Readonly<Record<string,DefinicionError>>={
    BL001: {
        codigo: "FUERA_DE_HORARIO",
        estadoHttp: 409,
        mensaje: "Los pedidos solo se reciben desde el viernes 00:00 hasta el sábado 08:00.",
    },
    BL002: {
        codigo: "TRANSICION_NO_PERMITIDA",
        estadoHttp: 409,
        mensaje: "El pedido no puede pasar a ese estado.",
    },
    BL003: {
        codigo: "MOTIVO_REQUERIDO",
        estadoHttp: 400,
        mensaje: "Debes indicar el motivo para cancelar un pedido aceptado.",
    },
    BL004: {
        codigo: "PAGO_NO_PERMITIDO",
        estadoHttp: 409,
        mensaje: "Solo se puede marcar como pagado un pedido aceptado, en camino o entregado.",
    },
    BL005: {
        codigo: "PEDIDO_NO_EDITABLE",
        estadoHttp: 409,
        mensaje: "El pedido ya no se puede modificar.",
    },
    BL006: {
        codigo: "SABOR_NO_DISPONIBLE",
        estadoHttp: 409,
        mensaje: "Uno de los sabores ya no está disponible.",
    },
    BL007: {
        codigo: "STOCK_INSUFICIENTE",
        estadoHttp: 409,
        mensaje: "No hay stock suficiente de uno de los sabores.",
    },
    BL008: {
        codigo: "CAMBIO_DE_SABOR",
        estadoHttp: 409,
        mensaje: "No se puede cambiar el sabor de un artículo.",
    },
    BL011: {
        codigo: "ULTIMO_ADMINISTRADOR",
        estadoHttp: 409,
        mensaje: "No se puede quitar el rol al único administrador.",
    },
    BL012: {
        codigo: "ULTIMO_ADMINISTRADOR",
        estadoHttp: 409,
        mensaje: "No se puede eliminar al único administrador.",
    },
    BL013: {
        codigo: "PEDIDO_VACIO",
        estadoHttp: 400,
        mensaje: "El pedido debe tener al menos un bolo.",
    },
    BL014: {
        codigo: "DATOS_DE_PEDIDO_INVALIDOS",
        estadoHttp: 400,
        mensaje: "Los datos del pedido no son válidos.",
    },
}