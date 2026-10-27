CREATE TABLE uploaded_image (
    object_key VARCHAR(1024) PRIMARY KEY,
    owner_id UUID NOT NULL,
    uploaded_at TIMESTAMPTZ NOT NULL,
    state VARCHAR(20) NOT NULL CHECK (state IN ('PENDING', 'ACTIVE', 'DELETING', 'DELETED')),
    delete_attempts INTEGER NOT NULL DEFAULT 0,
    last_delete_attempt_at TIMESTAMPTZ
);
CREATE INDEX idx_uploaded_image_cleanup ON uploaded_image (state, uploaded_at);
-- 기존 R2 파일은 등록하지 않는다. 신규 업로드의 미사용 파일만 정리한다.
