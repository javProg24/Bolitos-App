# useState y otros conceptos importantes

## 1. Qué es `useState`

`useState` es un hook de React. Sirve para guardar datos que pueden cambiar dentro de un componente.

Ejemplo:

```ts
const [email, setEmail] = useState("");
```

Esto significa:

- `email`: es el valor actual
- `setEmail`: es la función para cambiar ese valor
- `useState("")`: el valor inicial es una cadena vacía

## 2. Para qué sirve `useState`

Sirve para manejar cosas que cambian en la pantalla, por ejemplo:

- texto de un input
- contador
- si un modal está abierto o cerrado
- si una contraseña se ve o se oculta
- si una carga está en progreso

Ejemplo con contador:

```ts
const [count, setCount] = useState(0);
```

Si haces:

```ts
setCount(count + 1);
```

el valor cambia y la pantalla se vuelve a renderizar.

## 3. Ejemplo real de formulario

```tsx
import { useState } from "react";
import { TextInput, View, Text } from "react-native";

export default function Example() {
  const [name, setName] = useState("");

  return (
    <View>
      <TextInput value={name} onChangeText={setName} placeholder="Nombre" />
      <Text>Hola {name}</Text>
    </View>
  );
}
```

Qué pasa aquí:

- escribes en el input
- `onChangeText` llama a `setName`
- `name` cambia
- el texto se actualiza en pantalla

## 4. `useState` no cambia el valor al instante en la misma línea

Ejemplo:

```ts
setCount(count + 1);
```

Debes pensar que React actualiza el estado y luego vuelve a renderizar.

Cuando dependes del valor anterior, es mejor usar esta forma:

```ts
setCount((prev) => prev + 1);
```

Esto evita errores cuando hay varias actualizaciones seguidas.

## 5. Ejemplo de mostrar y ocultar contraseña

```tsx
const [showPassword, setShowPassword] = useState(false);

<TextInput secureTextEntry={!showPassword} />

<Pressable onPress={() => setShowPassword((prev) => !prev)}>
  <Text>{showPassword ? "Ocultar" : "Ver"}</Text>
</Pressable>
```

Esto sirve para:

- guardar un valor booleano
- cambiar comportamiento visual
- responder a interacción del usuario

## 6. Qué es un hook

Un hook es una función especial de React que te deja usar características internas del framework.

Ejemplos comunes:

- `useState`
- `useEffect`

Los hooks normalmente se usan al inicio del componente.

## 7. Qué es `useEffect`

`useEffect` sirve para ejecutar lógica cuando el componente se monta o cuando cambia algún valor.

Ejemplo:

```ts
useEffect(() => {
  console.log("La pantalla se cargó");
}, []);
```

El arreglo vacío `[]` significa: ejecutar solo una vez al inicio.

Ejemplo con dependencia:

```ts
useEffect(() => {
  console.log("El email cambió", email);
}, [email]);
```

Eso se ejecuta cada vez que cambia `email`.

## 8. Diferencia entre `useState` y `useEffect`

`useState`:

- guarda datos que cambian

`useEffect`:

- reacciona a cambios o al ciclo de vida del componente

Ejemplo mental:

- `useState` guarda el dato
- `useEffect` observa y actúa

## 9. Qué es un componente

Un componente es una función que devuelve interfaz.

Ejemplo:

```tsx
export default function Welcome() {
  return <Text>Hola</Text>;
}
```

Ese componente puede representar una pantalla completa o una parte pequeña de la UI.

## 10. Qué son las `props`

Las `props` son datos que un componente recibe desde otro componente.

Ejemplo:

```tsx
function Greeting({ name }: { name: string }) {
  return <Text>Hola {name}</Text>;
}
```

Uso:

```tsx
<Greeting name="Luis" />
```

Aquí `name` llega como dato desde afuera.

## 11. Diferencia entre `props` y `state`

`props`:

- vienen desde otro componente
- normalmente no se modifican dentro del componente que las recibe

`state`:

- vive dentro del componente
- sí puede cambiar con `setState` o `useState`

## 12. Renderizar condicionalmente

Significa mostrar una cosa u otra según una condición.

Ejemplo:

```tsx
{loading ? <Text>Cargando...</Text> : <Text>Listo</Text>}
```

Esto es muy usado en React Native.

## 13. Manejo de eventos

Cuando el usuario toca un botón o escribe, ocurre un evento.

Ejemplo:

```tsx
<Pressable onPress={() => console.log("Presionado")}>
  <Text>Entrar</Text>
</Pressable>
```

Ejemplo con input:

```tsx
<TextInput value={email} onChangeText={setEmail} />
```

## 14. `async/await`

Sirve para trabajar con tareas asíncronas, por ejemplo login, registro o lectura de datos.

Ejemplo:

```ts
const onLogin = async () => {
  const user = await signInWithEmailAndPassword(auth, email, password);
};
```

Esto hace el código más claro que usar muchas promesas encadenadas.

## 15. `try/catch`

Sirve para capturar errores.

Ejemplo:

```ts
try {
  await signInWithEmailAndPassword(auth, email, password);
} catch (error) {
  console.log("Hubo un error");
}
```

Esto es importante cuando trabajas con Firebase o APIs.

## 16. Ejemplo completo pequeño

```tsx
import { useState } from "react";
import { Pressable, Text, TextInput, View } from "react-native";

export default function MiniExample() {
  const [name, setName] = useState("");
  const [showMessage, setShowMessage] = useState(false);

  return (
    <View style={{ padding: 16, gap: 12 }}>
      <TextInput
        placeholder="Escribe tu nombre"
        value={name}
        onChangeText={setName}
        style={{ borderWidth: 1, padding: 12 }}
      />

      <Pressable onPress={() => setShowMessage(true)}>
        <Text>Mostrar saludo</Text>
      </Pressable>

      {showMessage ? <Text>Hola {name}</Text> : null}
    </View>
  );
}
```

Aquí practicas:

- `useState`
- `TextInput`
- `Pressable`
- evento `onPress`
- renderizado condicional

## 17. Resumen rápido

`useState` te sirve para guardar datos cambiantes dentro del componente.

Ejemplos:

- email
- password
- loading
- mostrar u ocultar contraseña
- datos de un formulario

Otros conceptos que debes dominar junto con `useState`:

- componentes
- `props`
- `useEffect`
- eventos
- renderizado condicional
- `async/await`
- `try/catch`

## 18. Forma simple de recordarlo

Puedes recordarlo así:

- `useState`: guarda y actualiza datos
- `useEffect`: ejecuta lógica cuando algo cambia
- `props`: reciben datos desde afuera
- componente: bloque de interfaz reutilizable

Si dominas eso, ya tienes una base fuerte para seguir con React Native.
