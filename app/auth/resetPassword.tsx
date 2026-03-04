import { auth } from "@/lib/firebase";
import { isValidEmail } from "@/utils/validate";
import { router } from "expo-router";
import { sendPasswordResetEmail } from "firebase/auth";
import { useState } from "react";
import { Alert, Pressable, Text, TextInput, View } from "react-native";

export default function ResetPasswordScreen() {
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const onResetPassword = async () => {
    const e = email.trim().toLowerCase();
    if (!isValidEmail(e))
      return Alert.alert("Invalid email", "Please enter a valid email");
    try {
      setLoading(true);
      await sendPasswordResetEmail(auth, e);
      router.replace("/auth/login");
    } catch (e: any) {
      Alert.alert(
        "Error resetting password",
        e?.message ?? "An error occurred",
      );
    } finally {
      setLoading(false);
    }
  };
  return (
    <View style={{ padding: 16, gap: 12, flex: 1, justifyContent: "center" }}>
      <TextInput
        placeholder="Email"
        autoCapitalize="none"
        keyboardType="email-address"
        value={email}
        onChangeText={setEmail}
        style={{ borderWidth: 1, padding: 12, borderRadius: 12 }}
      />
      <Pressable
        onPress={onResetPassword}
        disabled={loading}
        style={{
          padding: 14,
          borderWidth: 1,
          borderRadius: 12,
          alignItems: "center",
        }}>
        <Text>Reset Password</Text>
      </Pressable>
    </View>
  );
}
