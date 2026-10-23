-- FestivalRegion 매핑 버그 수정(kotlin/festival-region) 반영 후, 이미 동기화된 과거 데이터를 바로잡는 1회성 백필.
--
-- 왜 필요한가:
--   FestivalService.syncPublicFestivals()는 seq(external_id)로 신규 여부만 판별하고,
--   이미 저장된 행사는 다시 동기화하지 않는다. 그래서 코드 수정만으로는 과거에 잘못
--   분류된 행이 저절로 바로잡히지 않는다. 이 스크립트를 환경별로 한 번씩 직접 실행해야 한다.
--
-- 실행 전 확인:
--   UPDATE 전에 아래 집계 쿼리로 영향받는 행 수를 먼저 확인해보는 걸 권장한다.
--
--   SELECT region, count(*) FROM festival
--   WHERE region IS NULL OR region = 'GWANGJU'
--   GROUP BY region;
--
-- 실행 후 확인:
--   SELECT count(*) FROM festival WHERE region IS NULL AND provider_type = 'PUBLIC';
--   (대상이 아니었던 행만 남아야 한다 — 주소가 비어있거나 패턴이 안 맞는 경우)

BEGIN;

-- 1) 줄임말 지역명(대구/충북/충남/경북/경남) 매칭 실패로 NULL이 된 행 복구
UPDATE festival SET region = 'DAEGU'
WHERE region IS NULL AND provider_type = 'PUBLIC'
  AND place_address LIKE '대구%';

UPDATE festival SET region = 'CHUNGBUK'
WHERE region IS NULL AND provider_type = 'PUBLIC'
  AND (place_address LIKE '충청북도%' OR place_address LIKE '충북%');

UPDATE festival SET region = 'CHUNGNAM'
WHERE region IS NULL AND provider_type = 'PUBLIC'
  AND (place_address LIKE '충청남도%' OR place_address LIKE '충남%');

UPDATE festival SET region = 'GYEONGBUK'
WHERE region IS NULL AND provider_type = 'PUBLIC'
  AND (place_address LIKE '경상북도%' OR place_address LIKE '경북%');

UPDATE festival SET region = 'GYEONGNAM'
WHERE region IS NULL AND provider_type = 'PUBLIC'
  AND (place_address LIKE '경상남도%' OR place_address LIKE '경남%');

-- 2) 전라남도·광주광역시 행정구역 통합(전남광주통합특별시)을 반영해
--    잘못 GWANGJU로 분류된 공공 동기화 데이터를 JEONNAM_GWANGJU로 재분류
--    (회원이 직접 GWANGJU/JEONNAM을 선택해 제보한 건은 그대로 둔다)
UPDATE festival SET region = 'JEONNAM_GWANGJU'
WHERE region = 'GWANGJU' AND provider_type = 'PUBLIC';

COMMIT;
