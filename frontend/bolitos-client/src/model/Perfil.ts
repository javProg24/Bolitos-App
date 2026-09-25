export type UsuarioRol = "cliente" | "admin";
export interface Perfil {
  id: string;
  nombresCompletos: string;
  telefono: string;
  rol: UsuarioRol;
  fechaCreacion: string;
  fechaActualizacion: string;
}
