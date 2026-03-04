import { auth, db } from "@/lib/firebase";
import { isValidEmail } from "@/utils/validate";
import { router } from "expo-router";
import { createUserWithEmailAndPassword } from "firebase/auth";
import { doc, serverTimestamp, setDoc } from "firebase/firestore";
import { useState } from "react";
import {
    ActivityIndicator,
    Alert,
    Pressable,
    Text,
    TextInput,
    View,
} from "react-native";
export default function RegisterScreen() {
  const [name, setName] = useState("");
  const [lastname, setLastname] = useState("");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const onRegister = async () => {
    const e = email.trim().toLowerCase();
    if (!name.trim())
      return Alert.alert("Invalid name", "Please enter your name");
    if (!lastname.trim())
      return Alert.alert("Invalid last name", "Please enter your last name");
    if (!phone.trim())
      return Alert.alert("Invalid phone", "Please enter your phone number");
    if (!isValidEmail(e))
      return Alert.alert("Invalid email", "Please enter a valid email");
    if (password.length < 6)
      return Alert.alert(
        "Insecure password",
        "Password must be at least 6 characters long",
      );
    try {
      setLoading(true);
      const cred = await createUserWithEmailAndPassword(auth, e, password);
      await setDoc(doc(db, "users", cred.user.uid), {
        name,
        lastname,
        phone,
        email: e,
        createdAt: serverTimestamp(),
      });
      router.replace("/users");
    } catch (e: any) {
      Alert.alert("Error registering", e?.message ?? "An error occurred");
    } finally {
      setLoading(false);
    }
  };
  return (
    <View style={{ padding: 16, gap: 12, flex: 1, justifyContent: "center" }}>
      <Text style={{ fontSize: 28, fontWeight: "800" }}>Crear cuenta</Text>

      <TextInput
        placeholder="Nombre"
        value={name}
        onChangeText={setName}
        style={{ borderWidth: 1, padding: 12, borderRadius: 12 }}
      />

      <TextInput
        placeholder="Apellido"
        value={lastname}
        onChangeText={setLastname}
        style={{ borderWidth: 1, padding: 12, borderRadius: 12 }}
      />

      <TextInput
        placeholder="Teléfono"
        keyboardType="phone-pad"
        value={phone}
        onChangeText={setPhone}
        style={{ borderWidth: 1, padding: 12, borderRadius: 12 }}
      />

      <TextInput
        placeholder="Correo"
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
        onPress={onRegister}
        disabled={loading}
        style={{
          padding: 14,
          borderWidth: 1,
          borderRadius: 12,
          alignItems: "center",
          opacity: loading ? 0.6 : 1,
        }}>
        {loading ? <ActivityIndicator /> : <Text>Registrarme</Text>}
      </Pressable>

      <Pressable
        onPress={() => router.replace("/auth/login")}
        style={{ padding: 10, alignItems: "center" }}>
        <Text style={{ textDecorationLine: "underline" }}>Ya tengo cuenta</Text>
      </Pressable>
    </View>
  );
}
