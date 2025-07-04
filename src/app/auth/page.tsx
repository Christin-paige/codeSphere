"use client";

import React from "react";
import { Globe } from "lucide-react";
import { Button } from "../../../@/components/ui/button";
import { FcGoogle } from "react-icons/fc";
import { FaGithub } from "react-icons/fa6";
import supabaseClient from "../../../utils/supabase/client";
import DevSignIn from "./dev-signin";

export default function Page() {
  const handleLoginWithOAuth = (provider: "github" | "google") => {
    const supabase = supabaseClient;
    supabase.auth.signInWithOAuth({
      provider,
      options: {
        redirectTo: location.origin + "/",
      },
    });
  };

  return (
    <div className="flex items-center justify-center w-full h-screen">
      <div className="w-96 text-center rounded-md border p-5 space-y-5 relative bg-slate-950">
        <div className="flex items-center gap-2 justify-center mr-4">
          <Globe />

          <h1 className="text-2xl font-bold">BuiltInPublic</h1>
        </div>
        <p className="text-md text-gray-300">Register or Sign In</p>
        <Button
          variant="outline"
          size="medium"
          className="w-full flex items-center gap-2 p-2 cursor-pointer"
          onClick={() => handleLoginWithOAuth("google")}
        >
          <FcGoogle /> Google
        </Button>
        <Button
          variant="outline"
          size="medium"
          className="w-full flex items-center gap-2 p-2 cursor-pointer"
          onClick={() => handleLoginWithOAuth("github")}
        >
          <FaGithub />
          Github
        </Button>
        <DevSignIn />
      </div>
    </div>
  );
}
