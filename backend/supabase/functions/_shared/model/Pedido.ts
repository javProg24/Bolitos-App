export type estadosPedido='pendiente'|'aceptado'|'rechazado'|'cancelado'|'entregado'
export type estadosPago='pendiente'|'pagado'

export class Pedido{
    constructor(
        public readonly id:string,
        public readonly perfilId:string,
        public estado: estadosPedido,
        public estadoPago: estadosPago,
        public readonly fechaPedido: Date,
        public fechaEntrega: Date,
        public readonly fechaCreacion: Date,
        public  fechaActualizacion: Date
    ){}
    cancelarPedido():boolean{
        return this.estado==='pendiente'
    }
}