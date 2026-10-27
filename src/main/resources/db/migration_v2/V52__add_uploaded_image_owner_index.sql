-- 회원별 업로드 수(최근 24시간) 조회용. 업로드 한도 확인에 쓴다.
CREATE INDEX idx_uploaded_image_owner_time ON uploaded_image (owner_id, uploaded_at);
