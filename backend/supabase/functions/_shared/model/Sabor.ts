export class Sabor{
    constructor(
        public readonly id: string,
        public nombre: string,
        public esActivo: boolean,
        public stock: number,
        public readonly fechaCreacion: string,
        public  fechaActualizacion: string
    ){}
}