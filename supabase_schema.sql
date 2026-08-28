-- ==============================================================================
-- PLACED: Placement & Assessment Intelligence — Supabase PostgreSQL Schema
-- Run this script in your Supabase Dashboard SQL Editor (https://supabase.com/dashboard/project/_/sql)
-- ==============================================================================

-- 1. Enable UUID extension
create extension if not exists "uuid-ossp";

-- 2. Institutions Table
create table if not exists public.institutions (
  id text primary key default concat('inst_', substr(md5(random()::text), 1, 8)),
  name text not null,
  short text not null unique,
  city text default 'Campus',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. Students Table
create table if not exists public.students (
  id text primary key default concat('S', floor(random() * 9000 + 1000)::text),
  name text not null,
  email text,
  institution text not null, -- Short code e.g. CIE
  department text not null,
  year text default 'Final Yr',
  aptitude integer default 0 check (aptitude between 0 and 100),
  coding integer default 0 check (coding between 0 and 100),
  communication integer default 0 check (communication between 0 and 100),
  resume integer default 0 check (resume between 0 and 100),
  interview text default 'Pending' check (interview in ('Completed', 'Scheduled', 'Pending')),
  readiness integer default 0 check (readiness between 0 and 100),
  risk text default 'High' check (risk in ('Low', 'Medium', 'High')),
  last_active text default 'Just now',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 4. Assessments Table
create table if not exists public.assessments (
  id text primary key default concat('a_', substr(md5(random()::text), 1, 8)),
  name text not null,
  type text default 'Aptitude Test' check (type in ('Aptitude Test', 'Coding Challenge', 'Mock Test', 'Communication')),
  date text default to_char(now(), 'DD Mon YYYY'),
  duration integer default 60,
  completion integer default 0 check (completion between 0 and 100),
  avg numeric default 0 check (avg between 0 and 100),
  institutions text[] default '{}',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. Placement Drives Table
create table if not exists public.placement_drives (
  id text primary key default concat('d_', substr(md5(random()::text), 1, 8)),
  company text not null,
  role text default 'Role Pending',
  pkg text default '—',
  applied integer default 0,
  appeared integer default 0,
  selected integer default 0,
  status text default 'Upcoming' check (status in ('Upcoming', 'Ongoing', 'Closed')),
  date text default to_char(now() + interval '7 days', 'DD Mon YYYY'),
  min_score integer default 60,
  institutions text[] default '{}',
  departments text[] default '{}',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 6. Notifications Table
create table if not exists public.notifications (
  id text primary key default concat('n_', substr(md5(random()::text), 1, 8)),
  t text not null, -- Notification text
  kind text default 'brand' check (kind in ('bad', 'good', 'warn', 'brand', 'neutral')),
  read boolean default false,
  time text default 'Just now',
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 7. Automated Readiness & Risk Calculation Trigger
create or replace function public.calculate_student_readiness()
returns trigger as $$
begin
  -- Formula: Readiness = 25% Aptitude + 35% Coding + 20% Comm + 15% Resume (+ 5 bonus if interview completed)
  new.readiness := least(100, round(
    (coalesce(new.aptitude, 0) * 0.25) +
    (coalesce(new.coding, 0) * 0.35) +
    (coalesce(new.communication, 0) * 0.20) +
    (coalesce(new.resume, 0) * 0.15) +
    (case when new.interview = 'Completed' then 5 else 0 end)
  ));

  -- Assign Risk Category
  if new.readiness >= 75 then
    new.risk := 'Low';
  elsif new.readiness >= 55 then
    new.risk := 'Medium';
  else
    new.risk := 'High';
  end if;

  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_student_readiness on public.students;
create trigger trg_student_readiness
before insert or update on public.students
for each row execute function public.calculate_student_readiness();

-- 8. Enable Row Level Security (RLS) & Public Admin Policies
alter table public.institutions enable row level security;
alter table public.students enable row level security;
alter table public.assessments enable row level security;
alter table public.placement_drives enable row level security;
alter table public.notifications enable row level security;

-- Admin read/write policies (Public access for anon key dashboard)
create policy "Allow all on institutions" on public.institutions for all using (true) with check (true);
create policy "Allow all on students" on public.students for all using (true) with check (true);
create policy "Allow all on assessments" on public.assessments for all using (true) with check (true);
create policy "Allow all on placement_drives" on public.placement_drives for all using (true) with check (true);
create policy "Allow all on notifications" on public.notifications for all using (true) with check (true);

-- 9. Enable Realtime Publications for all tables
alter publication supabase_realtime add table public.institutions;
alter publication supabase_realtime add table public.students;
alter publication supabase_realtime add table public.assessments;
alter publication supabase_realtime add table public.placement_drives;
alter publication supabase_realtime add table public.notifications;

-- 10. Performance Indexes
create index if not exists idx_students_institution on public.students(institution);
create index if not exists idx_students_department on public.students(department);
create index if not exists idx_students_risk on public.students(risk);
create index if not exists idx_drives_status on public.placement_drives(status);
create index if not exists idx_notifs_read on public.notifications(read);
