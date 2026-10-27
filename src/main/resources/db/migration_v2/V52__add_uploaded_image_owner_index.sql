-- 회원별 업로드 수(최근 24시간) 조회용. 업로드 한도 확인에 쓴다.
-- #100에서 V50으로 들어왔다가 #94의 V50과 번호가 겹쳐 V52로 옮겼다.
-- 머지 전 브랜치로 이미 V50을 적용한 로컬 DB에도 다시 돌 수 있게 IF NOT EXISTS로 만든다.
CREATE INDEX IF NOT EXISTS idx_uploaded_image_owner_time ON uploaded_image (owner_id, uploaded_at);
