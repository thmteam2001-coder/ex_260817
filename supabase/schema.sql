-- Supabase SQL 편집기(SQL Editor)에서 한 번 실행하세요.
-- 먹음/폐기 버튼 클릭, 레시피 탭 클릭, 개별 레시피 열람 이벤트를 기록하는 테이블입니다.

create table if not exists public.app_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,       -- 'consume' | 'discard' | 'recipe_tab_click' | 'recipe_open'
  item_name text,                 -- consume/discard 이벤트일 때 재료 이름
  recipe_id text,                 -- recipe_open 이벤트일 때 레시피 id
  recipe_name text,               -- recipe_open 이벤트일 때 레시피 이름
  created_at timestamptz not null default now()
);

alter table public.app_events enable row level security;

-- anon key로 접속하는 클라이언트는 새 이벤트를 기록(insert)만 할 수 있고,
-- 조회(select)/수정/삭제는 할 수 없습니다. 데이터 확인은 Supabase 대시보드에서 하세요.
create policy "Allow anonymous inserts"
  on public.app_events
  for insert
  to anon
  with check (true);

-- 집계 예시 쿼리 (Supabase 대시보드 SQL Editor에서 실행):
--
-- 먹음/폐기 버튼 클릭 횟수:
--   select event_type, count(*) from public.app_events
--   where event_type in ('consume', 'discard') group by event_type;
--
-- 레시피 탭 버튼 클릭 횟수:
--   select count(*) from public.app_events where event_type = 'recipe_tab_click';
--
-- 레시피별 열람 횟수:
--   select recipe_name, count(*) from public.app_events
--   where event_type = 'recipe_open' group by recipe_name order by count(*) desc;
