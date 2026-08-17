-- Supabase SQL 편집기(SQL Editor)에서 한 번 실행하세요.
-- 먹음/폐기 버튼 클릭, 레시피 탭 클릭, 개별 레시피 열람 이벤트를 기록하는 테이블입니다.

create table if not exists public.app_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,       -- 'consume' | 'discard' | 'recipe_tab_click' | 'recipe_open'
  item_name text,                 -- consume/discard 이벤트일 때 재료 이름
  recipe_id text,                 -- recipe_open 이벤트일 때 레시피 id
  recipe_name text,               -- recipe_open 이벤트일 때 레시피 이름
  recipe_viewed boolean,          -- consume/discard 이벤트일 때, 이 재료의 레시피를 열람한 적 있는지
  created_at timestamptz not null default now()
);

-- 이미 app_events 테이블을 만들어서 쓰고 계셨다면, 위 create table은 그냥 넘어가고
-- 아래 줄만 SQL Editor에 붙여넣고 실행하면 recipe_viewed 컬럼이 추가됩니다.
alter table public.app_events add column if not exists recipe_viewed boolean;

alter table public.app_events enable row level security;

-- anon key로 접속하는 클라이언트는 새 이벤트를 기록(insert)만 할 수 있고,
-- 조회(select)/수정/삭제는 할 수 없습니다. 데이터 확인은 Supabase 대시보드에서 하세요.
-- (이미 이 정책을 만들어두셨다면 아래 구문은 "already exists" 에러가 나는데, 무시하고 넘어가면 됩니다.)
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
--
-- 레시피를 본 재료 vs 안 본 재료의 먹음/폐기 비율 비교 (핵심 KPI):
--   select recipe_viewed, event_type, count(*) from public.app_events
--   where event_type in ('consume', 'discard') group by recipe_viewed, event_type
--   order by recipe_viewed, event_type;
