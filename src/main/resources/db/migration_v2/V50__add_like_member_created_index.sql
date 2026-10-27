-- 마이페이지 "내가 좋아요한 행사·후기" 조회용 인덱스.
-- 기존 인덱스는 (src_id, member_id), (festival_id, member_id)라 회원 ID만으로는 쓸 수 없어서
-- 요청마다 좋아요 테이블 전체를 읽었다. (좋아요 200만 건에서 목록 31ms → 0.2ms)
-- 좋아요를 누른 최신순(created_at DESC, id DESC) 그대로 읽도록 정렬 컬럼까지 포함한다.
CREATE INDEX idx_like_member_created_at
    ON "like" (member_id, created_at DESC, id DESC);
