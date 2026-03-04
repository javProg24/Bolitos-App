import { auth } from "@/lib/firebase";
import { isValidEmail } from "@/utils/validate";
import { useRouter } from "expo-router";
import {
  signInWithEmailAndPassword
} from "firebase/auth";
import { useState } from "react";
import {
  ActivityIndicator,
  Alert,
  KeyboardAvoidingView,
  Platform,
  Pressable,
  ScrollView,
  Text,
  TextInput,
  View,
} from "react-native";

export default function LoginScreen() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
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
  return (
    <KeyboardAvoidingView
      style={{ flex: 1 }}
      behavior={Platform.OS === "ios" ? "padding" : "height"}>
      <ScrollView
        keyboardShouldPersistTaps="handled"
        contentContainerStyle={{
          flexGrow: 1,
          justifyContent: "center",
          padding: 16,
        }}>
        <View style={{ gap: 12 }}>
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
          <View
            style={{
              borderWidth: 1,
              borderRadius: 12,
              flexDirection: "row",
              alignItems: "center",
              paddingLeft: 12,
            }}>
            <TextInput
              placeholder="Contraseña"
              secureTextEntry={!showPassword}
              value={password}
              onChangeText={setPassword}
              style={{ flex: 1, paddingVertical: 12 }}
            />
            <Pressable
              onPress={() => setShowPassword((value) => !value)}
              style={{ paddingHorizontal: 12, paddingVertical: 12 }}>
              <Text>{showPassword ? "Ocultar" : "Ver"}</Text>
            </Pressable>
          </View>
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
            onPress={() => router.push("/auth/resetPassword")}
            disabled={loading}
            style={{ padding: 10, alignItems: "center" }}>
            <Text style={{ textDecorationLine: "underline" }}>
              Olvide mi contraseña
            </Text>
          </Pressable>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
