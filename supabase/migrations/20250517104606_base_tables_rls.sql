-- Base tables and RLS for CodeSphere
SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
-- Set row security to off to allow for manual RLS policies/Will be enabled later in file.
SET row_security = off;


CREATE EXTENSION IF NOT EXISTS "pgsodium";

COMMENT ON SCHEMA "public" IS 'standard public schema';

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";


-- Function to insert profile for new user
CREATE OR REPLACE FUNCTION "public"."insert_profile_for_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
declare
  base_username text;
  new_username text;
  counter integer := 0;
begin
  -- Get base username from metadata or generate one
  base_username := coalesce(new.raw_user_meta_data->>'name', 'user_' || substr(gen_random_uuid()::text, 1, 8));
  
  -- Ensure username is unique
  new_username := base_username;
  while exists (select 1 from public.profiles p where p.username = new_username) loop
    counter := counter + 1;
    new_username := base_username || '_' || counter::text;
  end loop;

  insert into public.profiles (id, username, avatar_url)
  values (
    new.id,
    new_username,
    coalesce(new.raw_user_meta_data->>'avatar_url', '')
  );
  return new;
end;
$$;

-- Alter function to set owner to postgres
ALTER FUNCTION "public"."insert_profile_for_new_user"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

-- Create likes table with id, created_at, user_id, and post_id
CREATE TABLE IF NOT EXISTS "public"."likes" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "post_id" "uuid" NOT NULL
);

-- Alter table to set owner to postgres
ALTER TABLE "public"."likes" OWNER TO "postgres";

-- Alter table to add generated id sequence for likes table
ALTER TABLE "public"."likes" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."likes_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);

-- Create profiles table with id, username, headline, bio, avatar_url, location, links, created_at
CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
    "username" TEXT NOT NULL UNIQUE,
    "headline" TEXT,
    "bio" TEXT,
    "avatar_url" TEXT,
    "location" TEXT,
    "links" TEXT[],
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT now ()
);

-- Create skills table with id, name
CREATE TABLE IF NOT EXISTS "public"."skills" (
    "id" SERIAL PRIMARY KEY,
    "name" TEXT NOT NULL UNIQUE
);

-- Create profile_skills table with profile_id, skill_id, and level
CREATE TABLE IF NOT EXISTS "public"."profile_skills" (
    "profile_id" UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
    "skill_id" INTEGER NOT NULL REFERENCES public.skills (id) ON DELETE CASCADE,
    "level" INTEGER NOT NULL CHECK (level BETWEEN 1 AND 5),
    PRIMARY KEY ("profile_id", "skill_id")
);

-- Create follows table with follower_id, followee_id, and created_at
CREATE TABLE IF NOT EXISTS "public"."follows" (
    "follower_id" UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
    "followee_id" UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT now (),
    PRIMARY KEY ("follower_id", "followee_id")
);

-- Create projects table with id, owner_id, name, description, visibility, repo_url, created_at, updated_at
CREATE TABLE IF NOT EXISTS "public"."projects" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    "owner_id" UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "visibility" TEXT NOT NULL CHECK (
        "visibility" IN ('public', 'connections', 'private')
    ) DEFAULT 'public',
    "repo_url" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT now (),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now ()
);

-- Create posts table with id, user_id, content, visibility, created_at, updated_at
CREATE TABLE IF NOT EXISTS "public"."posts" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
    "content" TEXT NOT NULL,
    "visibility" TEXT NOT NULL CHECK (
        "visibility" IN ('public', 'connections', 'private')
    ) DEFAULT 'public',
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT now(),
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create comments table with id, post_id, user_id, content, created_at
CREATE TABLE IF NOT EXISTS "public"."comments" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    "post_id" UUID NOT NULL REFERENCES public.posts (id) ON DELETE CASCADE,
    "user_id" UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT now ()
);

-- Create endorsements table with id, skill_id, user_id, endorsed_to, created_at
CREATE TABLE IF NOT EXISTS "public"."endorsements" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid (),
    "skill_id" INTEGER NOT NULL REFERENCES public.skills (id) ON DELETE CASCADE,
    "user_id" UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
    "endorsed_to" UUID NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT now ()
);

-- Alter table to set owner to postgres
ALTER TABLE "public"."posts" OWNER TO "postgres";

-- Alter table to set owner to postgres
ALTER TABLE "public"."profiles" OWNER TO "postgres";

-- Alter table to add foreign key for likes table
ALTER TABLE ONLY "public"."likes"
    ADD CONSTRAINT "likes_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "public"."posts"("id") ON UPDATE CASCADE ON DELETE CASCADE;

-- RLS Policies
-- profiles
CREATE POLICY "Allow insert for authenticated users" ON "public"."profiles" FOR INSERT TO "authenticated" WITH CHECK (true);
CREATE POLICY "anyone can select likes" ON "public"."likes" FOR SELECT USING (true);
CREATE POLICY "authenticated user can like post" ON "public"."likes" FOR INSERT TO "authenticated" WITH CHECK (("user_id" = "auth"."uid"()));
CREATE POLICY "authenticated users can delete their likes" ON "public"."likes" FOR DELETE TO "authenticated" USING (("user_id" = "auth"."uid"()));
CREATE POLICY "enable read access for profiles" ON "public"."profiles" FOR SELECT USING (true);
CREATE POLICY "Anyone can read profiles" ON "public"."profiles" FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can update their own profile" ON "public"."profiles" FOR UPDATE TO authenticated USING (auth.uid () = id);

-- skills
CREATE POLICY "Anyone can read skills" ON "public"."skills" FOR SELECT TO authenticated USING (true);

-- profile_skills
CREATE POLICY "Users can add skills to their profile" ON "public"."profile_skills" FOR INSERT TO authenticated WITH CHECK (auth.uid () = profile_id);
CREATE POLICY "Users can remove their profile skills" ON "public"."profile_skills" FOR DELETE TO authenticated USING (auth.uid () = profile_id);

-- follows
CREATE POLICY "Users can view their follows" ON "public"."follows" FOR SELECT TO authenticated USING (auth.uid () = follower_id);
CREATE POLICY "Users can follow others" ON "public"."follows" FOR INSERT TO authenticated WITH CHECK (auth.uid () = follower_id);
CREATE POLICY "Users can unfollow" ON "public"."follows" FOR DELETE TO authenticated USING (auth.uid () = follower_id);

-- projects
CREATE POLICY "Anyone can read public projects" ON "public"."projects" FOR SELECT TO authenticated USING (visibility = 'public');
CREATE POLICY "Users can create projects" ON "public"."projects" FOR INSERT TO authenticated WITH CHECK (auth.uid () = owner_id);
CREATE POLICY "Users can update their own projects" ON "public"."projects" FOR UPDATE TO authenticated USING (auth.uid () = owner_id);
CREATE POLICY "Users can delete their own projects" ON "public"."projects" FOR DELETE TO authenticated USING (auth.uid () = owner_id);

-- posts
CREATE POLICY "Anyone can read posts" ON "public"."posts" FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can create posts" ON "public"."posts" FOR INSERT TO authenticated WITH CHECK (auth.uid () = user_id);
CREATE POLICY "Users can update their own posts" ON "public"."posts" FOR UPDATE TO authenticated USING (auth.uid () = user_id);
CREATE POLICY "Users can delete their own posts" ON "public"."posts" FOR DELETE TO authenticated USING (auth.uid () = user_id);

-- comments
CREATE POLICY "Anyone can read comments" ON "public"."comments" FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can comment" ON "public"."comments" FOR INSERT TO authenticated WITH CHECK (auth.uid () = user_id);
CREATE POLICY "Users can edit their own comments" ON "public"."comments" FOR UPDATE TO authenticated USING (auth.uid () = user_id);
CREATE POLICY "Users can delete their own comments" ON "public"."comments" FOR DELETE TO authenticated USING (auth.uid () = user_id);

-- endorsements
CREATE POLICY "Anyone can read endorsements" ON "public"."endorsements" FOR SELECT TO authenticated USING (true);
CREATE POLICY "Users can endorse others" ON "public"."endorsements" FOR INSERT TO authenticated WITH CHECK (auth.uid () = user_id);
CREATE POLICY "Users can delete their endorsements" ON "public"."endorsements" FOR DELETE TO authenticated USING (auth.uid () = user_id);

-- likes
CREATE POLICY "Users can read their own likes" ON "public"."likes" FOR SELECT TO authenticated USING (auth.uid () = user_id);
CREATE POLICY "Users can like posts" ON "public"."likes" FOR INSERT TO authenticated WITH CHECK (auth.uid () = user_id);
CREATE POLICY "Users can delete their own likes" ON "public"."likes" FOR DELETE TO authenticated USING (auth.uid () = user_id);

-- users
CREATE POLICY "Anyone can view auth users" ON "auth"."users" FOR SELECT TO authenticated USING (true);

-- Enable row level security for all tables
ALTER TABLE "public"."likes" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."posts" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."skills" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."profile_skills" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."follows" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."projects" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."comments" ENABLE ROW LEVEL SECURITY;

ALTER TABLE "public"."endorsements" ENABLE ROW LEVEL SECURITY;

-- Alter publication to set owner to postgres
ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";

RESET ALL;