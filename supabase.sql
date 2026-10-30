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
