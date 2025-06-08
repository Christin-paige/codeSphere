"use server";

import { redirect } from "next/navigation";
import { createAnonClient } from "utils/supabase/server";

export async function signOutUser() {
  const supabase = await createAnonClient();

  try {
    const { error } = await supabase.auth.signOut();

    if (error) {
      throw new Error("Error signing out");
    }

    return redirect("/");
  } catch (e) {
    return {
      message: "Could not log out",
    };
  }
}
