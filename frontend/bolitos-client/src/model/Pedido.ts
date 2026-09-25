import { ItemPedido } from "./ItemPedido";

export type estadosPedido =
  | "pendiente"
  | "aceptado"
  | "rechazado"
  | "cancelado"
  | "entregado";

export type estadoSPago = "pendiente" | "pagado";
export interface Pedido {
  id: string;
  perfilId: string;
  estado: estadosPedido;
  estadoPàgado: estadoSPago;
  diaPedido: string;
  diaEntrega: string;
  items: ItemPedido[];
}
