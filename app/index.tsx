import { onAuthStateChanged } from "firebase/auth";
import { router } from "expo-router";
import React, { useEffect } from "react";
import { ActivityIndicator, View } from "react-native";
import { auth } from "../lib/firebase";

export default function Index() {
  useEffect(() => {
    const unsub = onAuthStateChanged(auth, (user) => {
      router.replace(user ? "/users" : "/auth/login");
    });

    return unsub;
  }, []);

  return (
    <View
      style={{
        flex: 1,
        alignItems: "center",
        justifyContent: "center",
      }}
    >
      <ActivityIndicator />
    </View>
  );
}
