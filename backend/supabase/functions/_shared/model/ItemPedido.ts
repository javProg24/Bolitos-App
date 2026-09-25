export class ItemPedido{
    constructor(
        public readonly id:string,
        public readonly pedidoId:string,
        public readonly saborId:string,
        public cantidad:number,
    ){}
}