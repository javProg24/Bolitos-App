export type UsuarioRole = "cliente" | "admin";
export interface Perfil {
  id: string;
  nombresCompletos: string;
  telefono: string;
  rol: UsuarioRole;
  fechaCreacion: string;
  fechaActualizacion: string;
}
