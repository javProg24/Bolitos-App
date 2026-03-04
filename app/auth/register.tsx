import { auth, db } from "@/lib/firebase";
import { isValidEmail } from "@/utils/validate";

import { router } from "expo-router";
import { createUserWithEmailAndPassword } from "firebase/auth";
import { doc, serverTimestamp, setDoc } from "firebase/firestore";
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
export default function RegisterScreen() {
  const [name, setName] = useState("");
  const [lastname, setLastname] = useState("");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
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
            <Text style={{ textDecorationLine: "underline" }}>
              Ya tengo cuenta
            </Text>
          </Pressable>
        </View>
      </ScrollView>
    </KeyboardAvoidingView>
  );
}
