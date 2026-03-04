import { auth } from "@/lib/firebase";
import { isValidEmail } from "@/utils/validate";
import { useRouter } from "expo-router";
import {
  sendPasswordResetEmail,
  signInWithEmailAndPassword,
} from "firebase/auth";
import { useState } from "react";
import {
  ActivityIndicator,
  Alert,
  Pressable,
  Text,
  TextInput,
  View,
} from "react-native";

export default function LoginScreen() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  /**
   * The `onLogin` function handles user login by validating input, signing in with email and password,
   * and displaying appropriate alerts for success or error.
   * @returns The `onLogin` function is returning an Alert message if the email or password is missing,
   * and it is also catching any errors that occur during the sign-in process and displaying an error
   * message. Finally, it sets the loading state to false after the sign-in process is completed.
   */
  //Part 1.
  const onLogin = async () => {
    const e = email.trim().toLowerCase();
    if (!isValidEmail(e))
      return Alert.alert("Email no valido", "Ingresa un email valido");
    if (password.length < 6)
      return Alert.alert(
        "Insecure password",
        "Password must be at least 6 characters long",
      );
    try {
      setLoading(true);
      await signInWithEmailAndPassword(auth, e, password);
      router.replace("/users");
    } catch (e: any) {
      const code = e?.code ?? "";
      if (code === "auth/user-not-found") {
        Alert.alert(
          "Usuario no encontrado",
          "No existe una cuenta con ese email, intenta registrarte",
        );
      } else if (code === "auth/wrong-password") {
        Alert.alert(
          "Contraseña incorrecta",
          "La contraseña que ingresaste es incorrecta, intenta de nuevo",
        );
      } else {
        Alert.alert("Error al entrar", e?.message ?? "Ocurrio un error");
      }
    } finally {
      setLoading(false);
    }
  };
  //Part 2.
  // Crear un panel de registro en otra pantalla o mostrar un modal para ingresar email y contraseña y registrar desde ahí
  /* `const router = useRouter();` is creating a router instance using the `useRouter` hook provided by
  the "expo-router" library. This hook allows you to access the router object and perform navigation
  actions within your React components. In this specific case, it is used to navigate to different
  screens or routes within the application, such as redirecting to the registration screen when the
  corresponding button is pressed. */
  const router = useRouter();
  // Send to another screen to reset password, or show a modal to enter email and send the email from there
  //Part 3
  const onResetPassword = async () => {
    if (!email.trim())
      return Alert.alert(
        "Falta email",
        "Ingresa tu email para restablecer tu contraseña",
      );
    try {
      setLoading(true);
      await sendPasswordResetEmail(auth, email.trim());
      Alert.alert(
        "Correo enviado",
        "Revisa tu correo para restablecer tu contraseña",
      );
    } catch (e: any) {
      Alert.alert("Error al enviar correo", e?.message ?? "Ocurrio un error");
    } finally {
      setLoading(false);
    }
  };
  return (
    <View style={{ padding: 16, gap: 12, flex: 1, justifyContent: "center" }}>
      <Text style={{ fontSize: 30, fontWeight: "800" }}>Bolitos</Text>
      <Text style={{ opacity: 0.6 }}>Inicia sesión o regístrate</Text>

      <TextInput
        placeholder="Email"
        autoCapitalize="none"
        keyboardType="email-address"
        value={email}
        onChangeText={setEmail}
        style={{ borderWidth: 1, padding: 12, borderRadius: 12 }}
      />
      <TextInput
        placeholder="Contraseña"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
        style={{ borderWidth: 1, padding: 12, borderRadius: 12 }}
      />
      <Pressable
        onPress={onLogin}
        disabled={loading}
        style={{
          padding: 14,
          borderWidth: 1,
          borderRadius: 12,
          alignItems: "center",
          opacity: loading ? 0.6 : 1,
        }}>
        {loading ? <ActivityIndicator /> : <Text>Entrar</Text>}
      </Pressable>
      <Pressable
        onPress={() => router.push("/auth/register")}
        disabled={loading}
        style={{
          padding: 14,
          borderWidth: 1,
          borderRadius: 12,
          alignItems: "center",
          opacity: loading ? 0.6 : 1,
        }}>
        <Text>Crear cuenta</Text>
      </Pressable>
      <Pressable
        onPress={onResetPassword}
        disabled={loading}
        style={{ padding: 10, alignItems: "center" }}>
        <Text style={{ textDecorationLine: "underline" }}>
          Olvide mi contraseña
        </Text>
      </Pressable>
    </View>
  );
}
