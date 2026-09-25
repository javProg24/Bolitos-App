export class AuditLog{
    constructor(
        public readonly id:string,
        public readonly perfilId:string,
        public accion:string,
        public metadata:Record<string,unknown>,
        public readonly fechaCreacion: Date
    ){}
}