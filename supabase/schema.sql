-- Enable necessary extensions
create extension if not exists "uuid-ossp";

-- Create profiles table
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  name text,
  email text unique,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create mood entries table
create table mood_entries (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) on delete cascade not null,
  mood_value integer check (mood_value >= 1 and mood_value <= 5) not null,
  note text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

create table screen_time_entries (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) on delete cascade not null,
  app_name text not null,
  -- Store duration in seconds (integer) to match the app model
  duration integer not null,
  date date not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create challenges table
create table challenges (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references profiles(id) on delete cascade not null,
  title text not null,
  description text,
  category text not null,
  start_date date not null,
  end_date date,
  is_done boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create user preferences table
create table user_preferences (
  user_id uuid references profiles(id) on delete cascade primary key,
  notifications_enabled boolean default true,
  -- Store daily screen time goal in seconds (integer) to match the app
  daily_screen_time_goal integer default 14400, -- 4 hours in seconds
  focus_areas text[] default array['Focus', 'Ontspanning', 'Sociale contacten'],
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Create RLS policies
alter table profiles enable row level security;
alter table mood_entries enable row level security;
alter table screen_time_entries enable row level security;
alter table challenges enable row level security;
alter table user_preferences enable row level security;

-- Profiles policies
create policy "Users can view their own profile"
  on profiles for select
  using (auth.uid() = id);

create policy "Users can update their own profile"
  on profiles for update
  using (auth.uid() = id);

-- Mood entries policies
create policy "Users can view their own mood entries"
  on mood_entries for select
  using (auth.uid() = user_id);

create policy "Users can insert their own mood entries"
  on mood_entries for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own mood entries"
  on mood_entries for update
  using (auth.uid() = user_id);

create policy "Users can delete their own mood entries"
  on mood_entries for delete
  using (auth.uid() = user_id);

-- Screen time entries policies
create policy "Users can view their own screen time entries"
  on screen_time_entries for select
  using (auth.uid() = user_id);

create policy "Users can insert their own screen time entries"
  on screen_time_entries for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own screen time entries"
  on screen_time_entries for update
  using (auth.uid() = user_id);

create policy "Users can delete their own screen time entries"
  on screen_time_entries for delete
  using (auth.uid() = user_id);

-- Challenges policies
create policy "Users can view their own challenges"
  on challenges for select
  using (auth.uid() = user_id);

create policy "Users can insert their own challenges"
  on challenges for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own challenges"
  on challenges for update
  using (auth.uid() = user_id);

create policy "Users can delete their own challenges"
  on challenges for delete
  using (auth.uid() = user_id);

-- User preferences policies
create policy "Users can view their own preferences"
  on user_preferences for select
  using (auth.uid() = user_id);

create policy "Users can update their own preferences"
  on user_preferences for update
  using (auth.uid() = user_id);

-- Create functions
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, name, email)
  values (new.id, new.raw_user_meta_data->>'name', new.email);
  
  insert into public.user_preferences (user_id)
  values (new.id);
  
  return new;
end;
$$ language plpgsql security definer;

-- Create trigger for new user
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- Create indexes
create index mood_entries_user_id_idx on mood_entries(user_id);
create index mood_entries_created_at_idx on mood_entries(created_at);
create index screen_time_entries_user_id_idx on screen_time_entries(user_id);
create index screen_time_entries_date_idx on screen_time_entries(date);
create index challenges_user_id_idx on challenges(user_id);
create index challenges_category_idx on challenges(category); 