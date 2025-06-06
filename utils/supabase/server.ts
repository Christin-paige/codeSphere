import { createServerClient } from "@supabase/ssr";
import { cookies } from "next/headers";
import { Database } from "../../supabase/supabase.types";

import { SupabaseClient } from "@supabase/supabase-js";

export async function createClient() {
  // change to supabase server to reduce confusion?
  const cookieStore = await cookies();

  const supabase: SupabaseClient<Database> = await createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll();
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options),
            );
          } catch {
            // The `setAll` method was called from a Server Component.
            // This can be ignored if you have middleware refreshing
            // user sessions.
          }
        },
      },
    },
  );

  return supabase;
}
