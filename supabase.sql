-- Таблица общего рейтинга. Выполните в Supabase: SQL Editor → New query → Run.
create table if not exists public.scores (
  id uuid primary key default auth.uid() references auth.users on delete cascade,
  nick text check (char_length(nick) <= 20),
  xp integer not null default 0,
  best_where integer not null default 0,
  best_price integer not null default 0,
  best_agent integer not null default 0,
  best_travel integer not null default 0,
  best_timeline integer not null default 0,
  daily_day integer,
  daily_score integer,
  updated_at timestamptz not null default now()
);
alter table public.scores enable row level security;
create policy "Anyone can read the leaderboard" on public.scores for select using (true);
create policy "Players insert their own row" on public.scores for insert with check (auth.uid() = id);
create policy "Players update their own row" on public.scores for update using (auth.uid() = id);
-- Защита от явно невозможных результатов
alter table public.scores add constraint sane_scores check (
  best_where <= 75000 and best_price <= 10000 and best_agent <= 25000 and best_travel <= 2000 and best_timeline <= 3600 and coalesce(daily_score,0) <= 75000
);

-- Отзывы и обезличенные события для метрик беты (запись есть у всех, чтение только в панели Supabase)
create table if not exists public.feedback (
  id bigserial primary key,
  uid uuid default auth.uid(),
  text text not null check (char_length(text) between 1 and 2000),
  screen text check (char_length(screen) <= 40),
  lang text check (char_length(lang) <= 5),
  ua text check (char_length(ua) <= 200),
  created_at timestamptz not null default now()
);
alter table public.feedback enable row level security;
create policy "Players send feedback" on public.feedback for insert to authenticated with check (uid = auth.uid());
grant insert on public.feedback to authenticated;
grant usage on sequence public.feedback_id_seq to authenticated;

create table if not exists public.events (
  id bigserial primary key,
  uid uuid default auth.uid(),
  name text not null check (name in ('start','finish','share')),
  game text check (char_length(game) <= 20),
  value integer,
  day integer,
  lang text check (char_length(lang) <= 5),
  created_at timestamptz not null default now()
);
alter table public.events enable row level security;
create policy "Players log their own events" on public.events for insert to authenticated with check (uid = auth.uid());
grant insert on public.events to authenticated;
grant usage on sequence public.events_id_seq to authenticated;
