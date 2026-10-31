-- Метрики беты. Выполнять в Supabase: SQL Editor → New query → Run.

-- 1. Сколько начинают и доигрывают каждую игру (за последние 14 дней)
select game,
       count(*) filter (where name='start')  as starts,
       count(*) filter (where name='finish') as finishes,
       round(100.0*count(*) filter (where name='finish')/nullif(count(*) filter (where name='start'),0)) as completion_pct
from events where created_at > now() - interval '14 days'
group by game order by starts desc;

-- 2. Возврат на следующий день: доля игроков, которые сыграли в день N и вернулись в день N+1
with d as (select distinct uid, day from events)
select a.day, count(*) as players, count(b.uid) as returned_next_day,
       round(100.0*count(b.uid)/count(*)) as d1_pct
from d a left join d b on b.uid=a.uid and b.day=a.day+1
group by a.day order by a.day desc limit 14;

-- 3. Сколько игроков нажимают «Поделиться»
select count(distinct uid) filter (where name='share') as sharers,
       count(distinct uid) as players,
       round(100.0*count(distinct uid) filter (where name='share')/nullif(count(distinct uid),0)) as share_pct
from events where created_at > now() - interval '14 days';

-- 4. Игр за визит (в среднем на игрока в день)
select round(avg(n),2) as games_per_player_day from (select uid, day, count(*) n from events where name='start' group by uid, day) t;

-- 5. Свежие отзывы
select created_at, screen, lang, text from feedback order by created_at desc limit 50;
