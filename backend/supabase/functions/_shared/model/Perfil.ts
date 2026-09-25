export type UsuarioRol='cliente'|'admin'
export class Perfil{
    constructor(
        public id:number,
        public nombresCompletos:string,
        public telefono:string,
        public rol: UsuarioRol,
        public fechaCreacion: string,
        public fechaActualizacion: string
    ){}
}