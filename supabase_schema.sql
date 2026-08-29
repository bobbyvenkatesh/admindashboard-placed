-- ==============================================================================
-- PLACED Admin Intelligence — Clean Isolated `admin_*` Tables Schema
-- ==============================================================================

-- 1. admin_institutions Table
create table if not exists public.admin_institutions (
  id text primary key default ('inst_' || substr(md5(random()::text), 1, 8)),
  name text not null,
  short text not null unique,
  city text default 'Campus',
  created_at timestamptz default now() not null
);

-- 2. admin_students Table
create table if not exists public.admin_students (
  id text primary key default ('S' || floor(random() * 9000 + 1000)::text),
  name text not null,
  email text,
  institution text not null,
  department text not null,
  year text default 'Final Yr',
  aptitude integer default 0,
  coding integer default 0,
  communication integer default 0,
  resume integer default 0,
  interview text default 'Pending',
  readiness integer default 0,
  risk text default 'High',
  last_active text default 'Just now',
  created_at timestamptz default now() not null
);

-- 3. admin_assessments Table
create table if not exists public.admin_assessments (
  id text primary key default ('a_' || substr(md5(random()::text), 1, 8)),
  name text not null,
  type text default 'Aptitude Test',
  date text default to_char(now(), 'DD Mon YYYY'),
  duration integer default 60,
  completion integer default 0,
  avg numeric default 0,
  institutions text[] default '{}',
  created_at timestamptz default now() not null
);

-- 4. admin_placement_drives Table
create table if not exists public.admin_placement_drives (
  id text primary key default ('d_' || substr(md5(random()::text), 1, 8)),
  company text not null,
  role text default 'Role Pending',
  pkg text default '—',
  applied integer default 0,
  appeared integer default 0,
  selected integer default 0,
  status text default 'Upcoming',
  date text default to_char(now() + interval '7 days', 'DD Mon YYYY'),
  min_score integer default 60,
  institutions text[] default '{}',
  departments text[] default '{}',
  created_at timestamptz default now() not null
);

-- 5. admin_notifications Table
create table if not exists public.admin_notifications (
  id text primary key default ('n_' || substr(md5(random()::text), 1, 8)),
  t text not null,
  kind text default 'brand',
  read boolean default false,
  time text default 'Just now',
  created_at timestamptz default now() not null
);

-- 6. Direct Permissions for the 5 new admin tables
grant all on table public.admin_institutions to anon, authenticated, service_role;
grant all on table public.admin_students to anon, authenticated, service_role;
grant all on table public.admin_assessments to anon, authenticated, service_role;
grant all on table public.admin_placement_drives to anon, authenticated, service_role;
grant all on table public.admin_notifications to anon, authenticated, service_role;

-- 7. Reload API Cache
notify pgrst, 'reload schema';
