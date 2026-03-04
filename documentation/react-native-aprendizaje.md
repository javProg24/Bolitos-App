# Aprendizaje de React Native en este proyecto

Este proyecto te sirve para entender React Native desde un caso real, no solo desde teoría. Aquí ya estás trabajando con pantallas, navegación, formularios, estado local y conexión a Firebase.

## 1. Qué estás usando realmente

Tu app está hecha con:

- React Native: para construir la interfaz móvil con componentes como `View`, `Text`, `TextInput` y `Pressable`.
- Expo: para facilitar la ejecución del proyecto sin montar toda la configuración nativa manualmente.
- Expo Router: para navegar entre pantallas usando carpetas y archivos dentro de `app`.
- Firebase: para autenticación y base de datos.

## 2. Cómo pensar React Native

React Native funciona por componentes. Cada pantalla es una función que devuelve interfaz.

Ejemplo mental:

- `View`: contenedor, parecido a un `div`
- `Text`: texto visible
- `TextInput`: campo de entrada
- `Pressable`: botón presionable

La pantalla cambia según el estado. Si el estado cambia, React vuelve a renderizar la interfaz.

## 3. Qué estás aprendiendo ya en tus pantallas

En tus archivos de autenticación, por ejemplo:

- [login.tsx](C:\Users\USER\Desktop\Proyectos\bolitos\app\auth\login.tsx)
- [register.tsx](C:\Users\USER\Desktop\Proyectos\bolitos\app\auth\register.tsx)

ya estás usando `useState`.

Eso significa que cada dato del formulario vive dentro del componente:

```ts
const [email, setEmail] = useState("");
const [password, setPassword] = useState("");
```

Esto te enseña una idea central de React Native:

- la UI depende del estado
- el usuario escribe
- cambias el estado con `setEmail`, `setPassword`
- la pantalla refleja ese cambio

## 4. Cómo funciona la navegación en tu proyecto

Tu proyecto usa `Expo Router`, así que la navegación depende de la estructura de carpetas dentro de `app`.

Ejemplos:

- `app/auth/login.tsx` representa la ruta `/auth/login`
- `app/auth/register.tsx` representa la ruta `/auth/register`
- `app/users/index.tsx` representa la ruta `/users`

El archivo [app/_layout.tsx](C:\Users\USER\Desktop\Proyectos\bolitos\app\_layout.tsx) define el `Stack` principal de navegación.

Eso te enseña que en React Native no necesitas armar toda la navegación manualmente si usas una herramienta como Expo Router.

## 5. Cómo decides a qué pantalla entrar

El archivo [app/index.tsx](C:\Users\USER\Desktop\Proyectos\bolitos\app\index.tsx) escucha si hay un usuario autenticado:

```ts
onAuthStateChanged(auth, (user) => {
  router.replace(user ? "/users" : "/auth/login");
});
```

Esto te enseña una idea muy importante:

- la app no solo muestra pantallas
- también toma decisiones según datos
- en este caso, según si el usuario ya inició sesión o no

## 6. Cómo se conecta Firebase

En [lib/firebase.ts](C:\Users\USER\Desktop\Proyectos\bolitos\lib\firebase.ts) inicializas Firebase con variables de entorno.

Ahí estás haciendo tres cosas importantes:

1. Leer la configuración del proyecto Firebase
2. Inicializar la app de Firebase
3. Exportar servicios listos para usar

```ts
export const auth = getAuth(app);
export const db = getFirestore(app);
```

Esto te enseña una buena práctica:

- separar configuración en un archivo reutilizable
- no repetir la conexión en cada pantalla

## 7. Qué hace el registro

En [register.tsx](C:\Users\USER\Desktop\Proyectos\bolitos\app\auth\register.tsx) haces dos procesos:

1. Crear el usuario en Firebase Authentication
2. Guardar datos extra del usuario en Firestore

Primero:

```ts
const cred = await createUserWithEmailAndPassword(auth, e, password);
```

Después:

```ts
await setDoc(doc(db, "users", cred.user.uid), {
  name,
  lastname,
  phone,
  email: e,
  createdAt: serverTimestamp(),
});
```

Aprendizaje clave:

- Authentication guarda la cuenta
- Firestore guarda el perfil o información adicional
- no son lo mismo

## 8. Qué hace el login

En [login.tsx](C:\Users\USER\Desktop\Proyectos\bolitos\app\auth\login.tsx) haces:

```ts
await signInWithEmailAndPassword(auth, e, password);
```

Eso valida correo y contraseña contra Firebase Auth.

Aprendizaje clave:

- login no busca usuarios manualmente en Firestore
- Firebase Auth se encarga de validar credenciales

## 9. Qué aprendiste del teclado y los formularios

Ya mejoraste la experiencia móvil usando:

- `KeyboardAvoidingView`
- `ScrollView`

Eso enseña una realidad importante de React Native:

- no basta con que algo se vea bien en escritorio
- en móvil el teclado cambia el espacio disponible
- tienes que diseñar pensando en interacción real

También añadiste mostrar y ocultar contraseña. Eso te enseña cómo usar estado para modificar comportamiento visual:

```ts
const [showPassword, setShowPassword] = useState(false);
```

## 10. Diferencia entre React web y React Native

En React web usarías cosas como:

- `div`
- `button`
- `input`

En React Native usas:

- `View`
- `Pressable`
- `TextInput`

La lógica de React es parecida, pero la interfaz usa componentes nativos.

## 11. Qué conceptos ya tocaste sin darte cuenta

En este proyecto ya practicaron estos temas:

- componentes funcionales
- estado con `useState`
- efectos con `useEffect`
- navegación
- validación de formularios
- renderizado condicional
- peticiones asíncronas con `async/await`
- manejo de errores con `try/catch`
- conexión a servicios externos

## 12. Cómo deberías explicarte tu app

Una forma clara de resumir tu proyecto es esta:

"Estoy haciendo una app móvil con React Native y Expo. Tengo pantallas de autenticación y navegación por rutas usando Expo Router. Uso `useState` para manejar formularios, Firebase Auth para registrar e iniciar sesión, y Firestore para guardar datos adicionales del usuario."

## 13. Siguiente aprendizaje recomendado

Después de esto, lo más útil sería aprender en este orden:

1. `props` y cómo pasar datos entre componentes
2. `useEffect` y cuándo usarlo bien
3. renderizado de listas con `FlatList`
4. manejo global de sesión o contexto
5. reglas de seguridad en Firestore
6. logout y protección de rutas

## 14. Idea final

Lo importante es que ya no estás aprendiendo React Native "desde cero" en abstracto. Ya estás viendo cómo una app real:

- muestra pantallas
- captura datos
- se conecta a un servicio externo
- navega según el estado del usuario

Ese es el aprendizaje correcto: entender cómo se conectan las piezas.
