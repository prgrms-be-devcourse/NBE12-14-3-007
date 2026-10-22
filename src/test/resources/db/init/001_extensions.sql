-- 테스트별 임시 스키마에서 동일한 검색 연산자를 사용할 수 있게 public에 설치한다.
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;
