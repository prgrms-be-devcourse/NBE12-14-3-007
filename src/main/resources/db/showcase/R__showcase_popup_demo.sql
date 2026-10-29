-- 운영 화면용 예시 데이터: 회원 제보 팝업 18개와 후기·댓글·좋아요·커뮤니티 글.
-- 제보 행사는 2026-10-29 기준 실제로 열리는 팝업이며 기간·장소는 팝가·팝놀 안내와 공식 인스타그램으로 확인했다.
-- 후기·댓글·커뮤니티 글과 작성자는 지어낸 내용이다. 사진은 Unsplash 무료 사진과 팝가에 올라온 공식 포스터 주소를 그대로 쓴다.
-- 이 경로(classpath:db/showcase)는 기본 Flyway 경로에 없다. 운영에서는 SPRING_FLYWAY_LOCATIONS에 더해야 실행된다.
-- 반복 실행 마이그레이션이라 파일이 바뀌면 다시 실행된다. 이미 있는 행은 건드리지 않고 없는 행만 넣는다.
-- 예시 회원은 로그인할 수 없는 비밀번호를 쓰고, 자정 등급 집계가 바꾸지 않도록 등급을 고정한다.
-- 좋아요·정확도 투표는 예시 회원이 실제로 누른 기록으로 넣으므로 행사·후기당 최대 13개다.

INSERT INTO member (id, email, password, role, nickname, profile_img, phone, created_at, updated_at, deleted_at, role_locked)
SELECT seed.id, seed.email, '$2a$10$3J0CLAJcpClv0aXxx62Ir.isAsHcL4iA8CG2ahEZz9vVp9tM4pWge', seed.role, seed.nickname,
       NULL, NULL, '2026-09-01 09:00:00', '2026-09-01 09:00:00', NULL, TRUE
FROM (VALUES
    ('00000000-0000-7000-b100-000000000001'::UUID, 'showcase-member-01@example.com', 'ROLE_TRUSTED', '성수동 산책러'),
    ('00000000-0000-7000-b100-000000000002'::UUID, 'showcase-member-02@example.com', 'ROLE_TRUSTED', '팝업헌터 지니'),
    ('00000000-0000-7000-b100-000000000003'::UUID, 'showcase-member-03@example.com', 'ROLE_RECOGNIZED', '주말엔 전시'),
    ('00000000-0000-7000-b100-000000000004'::UUID, 'showcase-member-04@example.com', 'ROLE_RECOGNIZED', '오늘도 탈출'),
    ('00000000-0000-7000-b100-000000000005'::UUID, 'showcase-member-05@example.com', 'ROLE_UNVERIFIED', '빵순이 하루'),
    ('00000000-0000-7000-b100-000000000006'::UUID, 'showcase-member-06@example.com', 'ROLE_RECOGNIZED', '홍대 고양이'),
    ('00000000-0000-7000-b100-000000000007'::UUID, 'showcase-member-07@example.com', 'ROLE_RECOGNIZED', '부산 바다곰'),
    ('00000000-0000-7000-b100-000000000008'::UUID, 'showcase-member-08@example.com', 'ROLE_UNVERIFIED', '대구 토박이'),
    ('00000000-0000-7000-b100-000000000009'::UUID, 'showcase-member-09@example.com', 'ROLE_UNVERIFIED', '제주 귤밭'),
    ('00000000-0000-7000-b100-000000000010'::UUID, 'showcase-member-10@example.com', 'ROLE_TRUSTED', '굿즈 수집가'),
    ('00000000-0000-7000-b100-000000000011'::UUID, 'showcase-member-11@example.com', 'ROLE_UNVERIFIED', '아이랑 나들이'),
    ('00000000-0000-7000-b100-000000000012'::UUID, 'showcase-member-12@example.com', 'ROLE_UNVERIFIED', '일산 사는 곰'),
    ('00000000-0000-7000-b100-000000000013'::UUID, 'showcase-member-13@example.com', 'ROLE_UNVERIFIED', '센텀 출근러'),
    ('00000000-0000-7000-b100-000000000014'::UUID, 'showcase-member-14@example.com', 'ROLE_RECOGNIZED', '소울젬 지킴이')
) AS seed (id, email, role, nickname)
WHERE NOT EXISTS (
    SELECT 1 FROM member existing
    WHERE existing.id = seed.id OR (existing.email = seed.email AND existing.deleted_at IS NULL)
);

CREATE TEMPORARY TABLE showcase_festival_seed (
    seed_no INT, member_id UUID, title VARCHAR(255), category VARCHAR(255), content TEXT, url VARCHAR(2048), img_url VARCHAR(2048),
    begin_de TIMESTAMP, end_de TIMESTAMP, partcpt_expn_info TEXT, region VARCHAR(32), district VARCHAR(80), region_detail TEXT, reported_at TIMESTAMP
) ON COMMIT DROP;
INSERT INTO showcase_festival_seed VALUES
    (1, '00000000-0000-7000-b100-000000000003'::UUID, '짱구는 못말려 전시 - 놀자! 시공간 대모험', '전시', '운영 시간: 매일 11:00 — 20:00 (입장 마감 19:00)

떡잎마을 방범대가 시공간에 휩쓸렸다는 콘셉트의 짱구 몰입형 전시예요. 공간마다 인터랙티브 체험이 있어서 캐릭터들과 사진도 찍고 뛰어놀 수 있어요.

입장 마감이 저녁 7시라 늦게 가면 못 들어가요. 사전 예약을 못 했다면 현장 대기로도 입장할 수 있어요.

내년 1월 24일까지 길게 열지만 주말에는 붐비니 방문 전에 공식 인스타그램 공지를 확인해 주세요.', 'https://www.instagram.com/shinchan_spacetime_kr', 'https://images.unsplash.com/photo-1663850697008-29fd8ea8e941?auto=format&fit=crop&w=1200&q=80', '2026-10-17 11:00:00'::TIMESTAMP, '2027-01-24 20:00:00'::TIMESTAMP, '사전 예약 또는 현장 대기 (요금은 예약 페이지 확인)', 'SEOUL', '성동구', '연무장5길 9-29', '2026-10-17 22:40:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000011'::UUID, '탐정 스누피의 잃어버린 단서 in 유니세프 정원', '교육/체험', '운영 시간: 매일 12:00 — 19:00

서울숲 유니세프 정원에 탐정 스누피 콘셉트의 탐험 공간이 생겼어요. 정원을 산책하며 단서를 찾다 보면 유니세프의 활동과 메시지를 자연스럽게 알게 되는 구성이에요.

미션을 완료하고 인증하면 스누피 스티커팩을 받을 수 있어요. 야외 정원이라 아이와 서울숲 나들이 코스로 묶어 가기 좋아요.', 'https://popga.co.kr/popup/8882', 'https://images.unsplash.com/photo-1581524070124-957d29ec032f?auto=format&fit=crop&w=1200&q=80', '2026-09-10 12:00:00'::TIMESTAMP, '2026-11-16 19:00:00'::TIMESTAMP, NULL, 'SEOUL', '성동구', '뚝섬로 273 서울숲 유니세프 정원 (제이홉숲 근처)', '2026-09-12 10:15:00'::TIMESTAMP),
    (3, '00000000-0000-7000-b100-000000000005'::UUID, '메이드바이 X 맘마 햄스토어 팝업', '플리마켓/팝업', '운영 시간: 매일 12:00 — 20:00

햄스터 캐릭터 ''맘마''와 메이드바이가 함께 연 햄스토어 마트 콘셉트 팝업이에요. 선공개 신상과 콜라보 상품을 지하 1층부터 4층까지 둘러볼 수 있어요.

나만의 만두 만들기에 참여하고 완성한 만두 얼굴을 SNS에 인증하면 말랑 키링(10종 중 랜덤 1종)을 줘요. 층마다 있는 스탬프 5개를 모두 모으면 팝업 한정 랜덤 스티커도 받을 수 있어요.', 'https://www.instagram.com/madeby.official/', 'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?auto=format&fit=crop&w=1200&q=80', '2026-09-08 12:00:00'::TIMESTAMP, '2026-11-04 20:00:00'::TIMESTAMP, NULL, 'SEOUL', '성동구', '서울숲길 38 메이드바이 성수점', '2026-09-09 19:30:00'::TIMESTAMP),
    (4, '00000000-0000-7000-b100-000000000001'::UUID, '카카오페이 팝업 - 오래오래 함께가게', '플리마켓/팝업', '운영 시간: 매일 11:00 — 20:00

카카오페이가 소상공인 브랜드와 함께 만든 상생 팝업이에요. 진심·감각·일상·지속·지역 다섯 가지 테마로 꾸민 아틀리에 존에서 작은 브랜드들이 재료 하나로 제품을 만들어 가는 이야기를 볼 수 있어요.

10월 31일(토)까지라 이번 주말이 마지막이에요.', 'https://www.instagram.com/kakaopay.oraeorae/', 'https://images.unsplash.com/photo-1598305762558-328f599df683?auto=format&fit=crop&w=1200&q=80', '2026-09-01 11:00:00'::TIMESTAMP, '2026-10-31 20:00:00'::TIMESTAMP, '무료 관람', 'SEOUL', '성동구', '연무장3길 8-27', '2026-09-02 12:05:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000002'::UUID, '토이 스토리 팝업 - 하우스 오브 토이스토리', '플리마켓/팝업', '운영 시간: 매일 12:00 — 21:00

우디와 버즈를 실제 크기로 만날 수 있는 토이 스토리 팝업이에요. 1층부터 4층까지 건물 전체가 토이 스토리 상품과 포토존으로 채워져 있어요.

10월 31일(토)에 끝나니 아직 못 가셨다면 서두르세요!', 'https://www.instagram.com/smoremarket/', 'https://images.unsplash.com/photo-1718804715033-8e045415f6f3?auto=format&fit=crop&w=1200&q=80', '2026-09-04 12:00:00'::TIMESTAMP, '2026-10-31 21:00:00'::TIMESTAMP, NULL, 'SEOUL', '성동구', '연무장3길 8-9 +LECT HOUSE', '2026-09-04 21:20:00'::TIMESTAMP),
    (6, '00000000-0000-7000-b100-000000000004'::UUID, '리바이포유 10주년 팝업', '플리마켓/팝업', '운영 시간: 매일 11:00 — 19:00

스킨케어 브랜드 리바이포유가 10주년을 맞아 연 팝업이에요. 히알프렙 라인을 중심으로 인기 제품을 직접 발라 보고 고를 수 있어요.

방문하면 팝업 한정 가방과 거울 키링을 줘요. 사전 예약을 받고 있어서 예약하고 가면 더 편해요.', 'https://www.instagram.com/rbfy_official/', 'https://images.unsplash.com/photo-1787569499510-ef18cc7ba7a5?auto=format&fit=crop&w=1200&q=80', '2026-10-28 11:00:00'::TIMESTAMP, '2026-11-12 19:00:00'::TIMESTAMP, '네이버 사전 예약 가능', 'SEOUL', '성동구', '연무장길 65 LECT 성수', '2026-10-22 09:40:00'::TIMESTAMP),
    (7, '00000000-0000-7000-b100-000000000003'::UUID, '바이탈뷰티 팝업 - SUPER GLOW SAUNA', '플리마켓/팝업', '운영 시간: 10/28(수) 14:00 — 19:00, 그 외 10:00 — 19:00

바이탈뷰티 슈퍼레티놀 라인을 사우나 콘셉트로 풀어낸 팝업이에요. 새로 나온 슈퍼레티놀 라인업을 직접 써 보고 나에게 맞는 글로우 루틴을 찾아볼 수 있어요.

팝업 안 미션을 깨면 샘플 2종을, 슈퍼글로우 사우나 체험을 하면 팝업 한정 사우나 굿즈를 줘요. 11월 3일(화)까지 딱 일주일만 열어요.', 'https://www.instagram.com/vitalbeautie_official/', 'https://images.unsplash.com/photo-1759302353458-3c617bfd428b?auto=format&fit=crop&w=1200&q=80', '2026-10-28 14:00:00'::TIMESTAMP, '2026-11-03 19:00:00'::TIMESTAMP, NULL, 'SEOUL', '성동구', '연무장길 31-1 103호', '2026-10-26 18:10:00'::TIMESTAMP),
    (8, '00000000-0000-7000-b100-000000000010'::UUID, '뮤직 & 월즈26 팝업스토어 IN 트렌드팟 바이 올리브영 N성수', '플리마켓/팝업', '운영 시간: 매일 11:00 — 20:00

리그 오브 레전드 월즈와 롤 음악을 한자리에서 만나는 MUSIC & WORLDS26 팝업이 올리브영 N성수에 열려요. 이곳에서만 받을 수 있는 리워드도 준비돼 있대요.

사전 예약 없이 현장 대기로 입장하니 오픈 시간에 맞춰 가는 걸 추천해요.', 'https://www.instagram.com/leagueoflegendskorea/', 'https://images.unsplash.com/photo-1546443046-ed1ce6ffd1ab?auto=format&fit=crop&w=1200&q=80', '2026-10-29 11:00:00'::TIMESTAMP, '2026-11-08 20:00:00'::TIMESTAMP, '사전 예약 없이 현장 대기로 입장', 'SEOUL', '성동구', '연무장7길 13 트렌드팟 바이 올리브영 N성수', '2026-10-27 13:25:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000006'::UUID, '주술회전 콜라보 카페', '플리마켓/팝업', '운영 시간: 월–금 11:00 — 22:00, 토–일 10:30 — 22:00

애니메이션 「주술회전」 시부야사변을 테마로 한 콜라보 카페예요. 이타도리, 메구미, 노바라, 고죠, 나나미 등 캐릭터 콘셉트 음료와 시즌 한정 메뉴가 있어요.

전기(9/23–10/28)와 후기(10/29–12/1)로 나뉘어 메뉴 구매 특전이 달라져요. 메뉴를 사면 특전 코스터 랜덤 1종을, MD를 3만 원 이상 사면 오리지널 티켓 5종 중 랜덤 1종을 줘요.', 'https://www.instagram.com/box_cafe_ak/', 'https://images.unsplash.com/photo-1567880905822-56f8e06fe630?auto=format&fit=crop&w=1200&q=80', '2026-09-23 11:00:00'::TIMESTAMP, '2026-12-01 22:00:00'::TIMESTAMP, '음료·MD 구매 시 특전 증정', 'SEOUL', '마포구', '양화로 188 AK플라자 홍대 3층 BOX cafe&space', '2026-09-19 23:05:00'::TIMESTAMP),
    (10, '00000000-0000-7000-b100-000000000010'::UUID, '핫토이 팝업스토어', '플리마켓/팝업', '운영 시간: 월–금 11:00 — 22:00, 토–일 10:30 — 22:00

홍콩 컬렉터블 피규어 브랜드 핫토이 팝업이 AK플라자 홍대 2층에 열렸어요. 마블·DC 1:6 스케일 피규어부터 코스비·코스베이비, 플러쉬 굿즈까지 온라인에서만 보던 라인업을 직접 볼 수 있어요.

어벤져스: 둠스데이 스티브 로저스, 슈페리어 아이언맨 같은 한정판은 현장 선착순 판매와 프리오더로 진행돼 수량이 빨리 빠질 수 있어요.', 'https://www.instagram.com/hottoyskr/', 'https://images.unsplash.com/photo-1608278047522-58806a6ac85b?auto=format&fit=crop&w=1200&q=80', '2026-10-27 11:00:00'::TIMESTAMP, '2026-11-09 22:00:00'::TIMESTAMP, NULL, 'SEOUL', '마포구', '양화로 188 AK플라자 홍대 2층', '2026-10-24 20:45:00'::TIMESTAMP),
    (11, '00000000-0000-7000-b100-000000000006'::UUID, '아일릿 팝업 - BREAK EVEN @홍대', '플리마켓/팝업', '운영 시간: 매일 10:00 — 23:00

아일릿(ILLIT) 미니 5집 ''BREAK EVEN'' 발매 기념 팝업이 올리브영 홍대놀이터점에서 열려요.

대상 앨범을 사면 미공개 셀피 포토카드 4종 중 1종을 랜덤으로 줘요(구매 수량만큼). Weverse Albums ver.와 Photo Dump ver.는 특전 대상이 아니니 참고하세요.', 'https://www.instagram.com/oliveyoung_official/', 'https://images.unsplash.com/photo-1760931657888-87514a4e6c25?auto=format&fit=crop&w=1200&q=80', '2026-10-29 10:00:00'::TIMESTAMP, '2026-11-03 23:00:00'::TIMESTAMP, NULL, 'SEOUL', '마포구', '와우산로21길 29 올리브영 홍대놀이터점', '2026-10-27 23:30:00'::TIMESTAMP),
    (12, '00000000-0000-7000-b100-000000000002'::UUID, '2026 스텔라이브 팝업 - STELLA MODE:ON', '전시', '운영 시간: 매일 10:00 — 20:00

스텔라이브 공식 팝업스토어가 본다빈치뮤지엄 능동에서 열려요. 멤버들 개성대로 꾸민 전시 공간과, 스마트폰으로 주문하고 현장에서 받는 굿즈존으로 운영돼요.

만 14세 미만은 보호자 ID로 예약하고, 현장에서 예약 화면이나 출력물을 보여 줘야 입장할 수 있어요.', 'https://www.instagram.com/p/DdyPVt-CWeK/', 'https://images.unsplash.com/photo-1743119844808-fefd446de533?auto=format&fit=crop&w=1200&q=80', '2026-10-23 10:00:00'::TIMESTAMP, '2026-11-01 20:00:00'::TIMESTAMP, '네이버 사전 예약 (만 14세 미만은 보호자 ID로 예약)', 'SEOUL', '광진구', '광나루로 441 본다빈치뮤지엄 능동', '2026-10-13 10:20:00'::TIMESTAMP),
    (13, '00000000-0000-7000-b100-000000000007'::UUID, '힐리먼트 팝업스토어 (신세계 센텀시티)', '플리마켓/팝업', '운영 시간: 10:30 — 20:00 (연장 영업일 20:30)

낚시복의 기능을 일상복으로 풀어낸 ''피싱코어'' 아웃도어 브랜드 힐리먼트 팝업이에요. 26FW 신상품을 20% 할인하고, 일부 품목은 최대 40%까지 할인해요.

매주 금·토요일 오후 2시에 선착순 뽑기 행사가 있어요.', 'https://www.instagram.com/helement_official/', 'https://images.unsplash.com/photo-1567955465154-078c60ff5c9e?auto=format&fit=crop&w=1200&q=80', '2026-10-20 10:30:00'::TIMESTAMP, '2026-11-04 20:00:00'::TIMESTAMP, NULL, 'BUSAN', '해운대구', '센텀남대로 35 신세계 센텀시티 지하 2층 하이퍼스테이지', '2026-10-20 18:00:00'::TIMESTAMP),
    (14, '00000000-0000-7000-b100-000000000007'::UUID, '% 아라비카 ''응 커피'' 팝업 (신세계 센텀시티)', '플리마켓/팝업', '운영 시간: 10:30 — 20:00 (11/9 백화점 휴점일 휴무)

교토에서 시작한 스페셜티 커피 % 아라비카가 신세계 센텀시티 지하 1층에 약 8주 동안 팝업 매장을 열었어요. 로고가 ''응''처럼 보여서 ''응 커피''로 불리는 그곳이에요.

대표 메뉴 교토 라떼와 마차 라떼가 각 7,900원이고, 로고 머그컵 같은 굿즈도 팔아요. 11월 9일(월)은 백화점 휴점일이라 쉬어요.', 'https://www.instagram.com/arabica.kr/', 'https://images.unsplash.com/photo-1742549626436-bf3c11dab212?auto=format&fit=crop&w=1200&q=80', '2026-10-20 10:30:00'::TIMESTAMP, '2026-12-14 20:00:00'::TIMESTAMP, '음료 구매 (교토 라떼·마차 라떼 각 7,900원)', 'BUSAN', '해운대구', '센텀남대로 35 신세계 센텀시티 지하 1층', '2026-10-20 13:15:00'::TIMESTAMP),
    (15, '00000000-0000-7000-b100-000000000008'::UUID, '체로프 몽모 팝업스토어 (더현대 대구)', '플리마켓/팝업', '운영 시간: 월–목 10:30 — 20:00, 금–일 10:30 — 20:30

비숑 강아지 캐릭터 ''몽모''로 알려진 애착인형 브랜드 체로프 팝업이에요. 인형과 립밤 키링, 허그 키링에 더현대 대구 전용 굿즈까지 모여 있어요.

몽모 프레임 포토네컷이랑 몽모 그리기 체험도 있어서 아이랑 가기 좋아요. 5만 원 이상 사면 리유저블백, 10만 원 이상 사면 몽모 얼굴인형을 줘요.', 'https://www.instagram.com/thehyundai_daegu/', 'https://images.unsplash.com/photo-1602734846297-9299fc2d4703?auto=format&fit=crop&w=1200&q=80', '2026-10-21 10:30:00'::TIMESTAMP, '2026-11-11 20:00:00'::TIMESTAMP, NULL, 'DAEGU', '중구', '달구벌대로 2077 더현대 대구 9층 더 포럼 by 하이메 아욘', '2026-10-21 19:50:00'::TIMESTAMP),
    (16, '00000000-0000-7000-b100-000000000012'::UUID, '써모스 ''럭키 아일랜드'' 체험형 팝업 (스타필드 고양)', '교육/체험', '운영 시간: 매일 10:00 — 22:00

써모스가 스타필드 고양 1층 고메 아트리움에 행운의 섬을 꾸민 체험형 팝업이에요. 행운의 오솔길·연못·오두막을 지나며 행운 도감 미션을 채우는 방식이에요.

행운의 상점에서는 텀블러 30%, 키친웨어 최대 60% 현장 할인을 해요. 먼저 열렸던 스타필드 수원과는 장소가 다르니 헷갈리지 마세요.', 'https://www.instagram.com/thermoskorea/', 'https://images.unsplash.com/photo-1729192293999-ffbdc97cbac9?auto=format&fit=crop&w=1200&q=80', '2026-10-22 10:00:00'::TIMESTAMP, '2026-11-04 22:00:00'::TIMESTAMP, NULL, 'GYEONGGI', '고양시', '덕양구 고양대로 1955 스타필드 고양 1층 고메 아트리움', '2026-10-22 20:30:00'::TIMESTAMP),
    (17, '00000000-0000-7000-b100-000000000009'::UUID, '제주 로컬 브랜드 팝업스토어 ''주도적 장터''', '플리마켓/팝업', '운영 시간: 매일 11:00 — 17:00

제주시 원도심 로컬 거점공간 LPP에서 나흘 동안 열리는 제주 로컬 브랜드 팝업이에요. 제주에서 주도적으로 브랜드를 만드는 24개 팀이 상품을 전시하고 판매해요.

현장 할인쿠폰과 선물 꾸러미도 준비돼 있어요. 11월 1일(일)까지예요.', 'https://www.instagram.com/lpp_jeju/', 'https://images.unsplash.com/photo-1631692994621-d26f83cf4db8?auto=format&fit=crop&w=1200&q=80', '2026-10-29 11:00:00'::TIMESTAMP, '2026-11-01 17:00:00'::TIMESTAMP, NULL, 'JEJU', '제주시', '관덕로8길 15-3 LPP(Local Player Platform)', '2026-10-26 16:40:00'::TIMESTAMP),
    (18, '00000000-0000-7000-b100-000000000006'::UUID, '마법소녀 마도카☆마기카 <발푸르기스의 회천> 팝업스토어', '플리마켓/팝업', '운영 시간: 매일 12:00 — 20:00

11월 4일 국내 개봉하는 극장판 「마법소녀 마도카☆마기카 <발푸르기스의 회천>」을 기념한 팝업스토어가 홍대 JS스토어 2층에서 열려요. 2013년 「반역의 이야기」에 이어지는 정식 후속편이에요.

전시 연출과 한정 상품, 특별 구매 혜택이 준비돼 있어요. 상품 목록과 특전은 공식 인스타그램 공지를 확인해 주세요.', 'https://www.instagram.com/p/DeiU29Zsetp/', 'https://cdn.popga.co.kr/spot/14165/main/2f939217-182c-4f3b-b7eb-7f4e84f67b08_1792130626354_thumbnail_MAIN_W480.webp', '2026-10-30 12:00:00'::TIMESTAMP, '2026-11-11 20:00:00'::TIMESTAMP, NULL, 'SEOUL', '마포구', '와우산로29길 48-24 JS스토어 2층', '2026-10-23 21:40:00'::TIMESTAMP);

INSERT INTO festival (member_id, provider_type, title, category, content, url, img_url, begin_de, end_de, partcpt_expn_info, telno_info,
                      status, created_at, updated_at, deleted_at, region, district, region_detail, version)
SELECT seed.member_id, 'MEMBER', seed.title, seed.category, seed.content, seed.url, seed.img_url, seed.begin_de, seed.end_de,
       seed.partcpt_expn_info, NULL,
       CASE WHEN seed.end_de < CURRENT_TIMESTAMP THEN 'CLOSED' ELSE 'OPEN' END,
       seed.reported_at, seed.reported_at, NULL, seed.region, seed.district, seed.region_detail, 0
FROM showcase_festival_seed seed
JOIN member author ON author.id = seed.member_id AND author.deleted_at IS NULL
WHERE NOT EXISTS (
    SELECT 1 FROM festival existing
    WHERE existing.provider_type = 'MEMBER' AND existing.url = seed.url AND existing.title = seed.title
);

CREATE TEMPORARY TABLE showcase_festival ON COMMIT DROP AS
SELECT seed.seed_no, festival.id AS festival_id, seed.member_id
FROM showcase_festival_seed seed
JOIN festival ON festival.provider_type = 'MEMBER' AND festival.url = seed.url AND festival.title = seed.title
             AND festival.deleted_at IS NULL;

INSERT INTO festival_submission (id, festival_id, created_at, updated_at)
SELECT ('00000000-0000-7000-b200-' || LPAD(seed.seed_no::TEXT, 12, '0'))::UUID, seed.festival_id, festival.created_at, festival.created_at
FROM showcase_festival seed
JOIN festival ON festival.id = seed.festival_id
WHERE NOT EXISTS (
    SELECT 1 FROM festival_submission existing
    WHERE existing.id = ('00000000-0000-7000-b200-' || LPAD(seed.seed_no::TEXT, 12, '0'))::UUID
       OR existing.festival_id = seed.festival_id
);

INSERT INTO "like" (src_id, member_id, festival_id, created_at, updated_at)
SELECT NULL, seed.member_id, festival.festival_id, seed.liked_at, seed.liked_at
FROM (VALUES
    (1, '00000000-0000-7000-b100-000000000010'::UUID, '2026-10-18 00:10:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000013'::UUID, '2026-10-18 01:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000002'::UUID, '2026-10-18 03:10:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000007'::UUID, '2026-10-18 04:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000011'::UUID, '2026-10-18 06:10:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000009'::UUID, '2026-10-18 07:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000008'::UUID, '2026-10-18 09:10:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000006'::UUID, '2026-10-18 10:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000004'::UUID, '2026-10-18 12:10:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000001'::UUID, '2026-10-18 13:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000014'::UUID, '2026-10-18 15:10:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000012'::UUID, '2026-10-18 16:40:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000007'::UUID, '2026-09-12 11:45:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000002'::UUID, '2026-09-12 13:15:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000003'::UUID, '2026-09-12 14:45:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000006'::UUID, '2026-09-12 16:15:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000014'::UUID, '2026-09-12 17:45:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000008'::UUID, '2026-09-12 19:15:00'::TIMESTAMP),
    (3, '00000000-0000-7000-b100-000000000013'::UUID, '2026-09-09 21:00:00'::TIMESTAMP),
    (3, '00000000-0000-7000-b100-000000000012'::UUID, '2026-09-09 22:30:00'::TIMESTAMP),
    (3, '00000000-0000-7000-b100-000000000014'::UUID, '2026-09-10 00:00:00'::TIMESTAMP),
    (3, '00000000-0000-7000-b100-000000000004'::UUID, '2026-09-10 01:30:00'::TIMESTAMP),
    (3, '00000000-0000-7000-b100-000000000009'::UUID, '2026-09-10 03:00:00'::TIMESTAMP),
    (4, '00000000-0000-7000-b100-000000000013'::UUID, '2026-09-02 13:35:00'::TIMESTAMP),
    (4, '00000000-0000-7000-b100-000000000006'::UUID, '2026-09-02 15:05:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000009'::UUID, '2026-09-04 22:50:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000014'::UUID, '2026-09-05 00:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000005'::UUID, '2026-09-05 01:50:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000007'::UUID, '2026-09-05 03:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000013'::UUID, '2026-09-05 04:50:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000012'::UUID, '2026-09-05 06:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000008'::UUID, '2026-09-05 07:50:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000003'::UUID, '2026-09-05 09:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000001'::UUID, '2026-09-05 10:50:00'::TIMESTAMP),
    (6, '00000000-0000-7000-b100-000000000009'::UUID, '2026-10-22 11:10:00'::TIMESTAMP),
    (6, '00000000-0000-7000-b100-000000000012'::UUID, '2026-10-22 12:40:00'::TIMESTAMP),
    (7, '00000000-0000-7000-b100-000000000013'::UUID, '2026-10-26 19:40:00'::TIMESTAMP),
    (8, '00000000-0000-7000-b100-000000000006'::UUID, '2026-10-27 14:55:00'::TIMESTAMP),
    (8, '00000000-0000-7000-b100-000000000001'::UUID, '2026-10-27 16:25:00'::TIMESTAMP),
    (8, '00000000-0000-7000-b100-000000000013'::UUID, '2026-10-27 17:55:00'::TIMESTAMP),
    (8, '00000000-0000-7000-b100-000000000004'::UUID, '2026-10-27 19:25:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000004'::UUID, '2026-09-20 00:35:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000005'::UUID, '2026-09-20 02:05:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000012'::UUID, '2026-09-20 03:35:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000009'::UUID, '2026-09-20 05:05:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000001'::UUID, '2026-09-20 06:35:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000010'::UUID, '2026-09-20 08:05:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000014'::UUID, '2026-09-20 09:35:00'::TIMESTAMP),
    (10, '00000000-0000-7000-b100-000000000001'::UUID, '2026-10-24 22:15:00'::TIMESTAMP),
    (10, '00000000-0000-7000-b100-000000000009'::UUID, '2026-10-24 23:45:00'::TIMESTAMP),
    (10, '00000000-0000-7000-b100-000000000013'::UUID, '2026-10-25 01:15:00'::TIMESTAMP),
    (10, '00000000-0000-7000-b100-000000000011'::UUID, '2026-10-25 02:45:00'::TIMESTAMP),
    (11, '00000000-0000-7000-b100-000000000001'::UUID, '2026-10-28 01:00:00'::TIMESTAMP),
    (11, '00000000-0000-7000-b100-000000000003'::UUID, '2026-10-28 02:30:00'::TIMESTAMP),
    (11, '00000000-0000-7000-b100-000000000010'::UUID, '2026-10-28 04:00:00'::TIMESTAMP),
    (11, '00000000-0000-7000-b100-000000000002'::UUID, '2026-10-28 05:30:00'::TIMESTAMP),
    (11, '00000000-0000-7000-b100-000000000014'::UUID, '2026-10-28 07:00:00'::TIMESTAMP),
    (12, '00000000-0000-7000-b100-000000000011'::UUID, '2026-10-13 11:50:00'::TIMESTAMP),
    (12, '00000000-0000-7000-b100-000000000001'::UUID, '2026-10-13 13:20:00'::TIMESTAMP),
    (12, '00000000-0000-7000-b100-000000000003'::UUID, '2026-10-13 14:50:00'::TIMESTAMP),
    (13, '00000000-0000-7000-b100-000000000010'::UUID, '2026-10-20 19:30:00'::TIMESTAMP),
    (14, '00000000-0000-7000-b100-000000000006'::UUID, '2026-10-20 14:45:00'::TIMESTAMP),
    (14, '00000000-0000-7000-b100-000000000005'::UUID, '2026-10-20 16:15:00'::TIMESTAMP),
    (14, '00000000-0000-7000-b100-000000000012'::UUID, '2026-10-20 17:45:00'::TIMESTAMP),
    (14, '00000000-0000-7000-b100-000000000008'::UUID, '2026-10-20 19:15:00'::TIMESTAMP),
    (15, '00000000-0000-7000-b100-000000000014'::UUID, '2026-10-21 21:20:00'::TIMESTAMP),
    (15, '00000000-0000-7000-b100-000000000009'::UUID, '2026-10-21 22:50:00'::TIMESTAMP),
    (15, '00000000-0000-7000-b100-000000000001'::UUID, '2026-10-22 00:20:00'::TIMESTAMP),
    (16, '00000000-0000-7000-b100-000000000010'::UUID, '2026-10-22 22:00:00'::TIMESTAMP),
    (17, '00000000-0000-7000-b100-000000000008'::UUID, '2026-10-26 18:10:00'::TIMESTAMP),
    (18, '00000000-0000-7000-b100-000000000009'::UUID, '2026-10-23 23:10:00'::TIMESTAMP),
    (18, '00000000-0000-7000-b100-000000000004'::UUID, '2026-10-24 00:40:00'::TIMESTAMP),
    (18, '00000000-0000-7000-b100-000000000002'::UUID, '2026-10-24 02:10:00'::TIMESTAMP)
) AS seed (seed_no, member_id, liked_at)
JOIN showcase_festival festival ON festival.seed_no = seed.seed_no
JOIN member voter ON voter.id = seed.member_id AND voter.deleted_at IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO festival_accuracy_vote (festival_id, member_id, vote_type, created_at, updated_at)
SELECT festival.festival_id, seed.member_id, seed.vote_type, seed.voted_at, seed.voted_at
FROM (VALUES
    (1, '00000000-0000-7000-b100-000000000010'::UUID, 'ACCURATE', '2026-10-18 00:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000002'::UUID, 'ACCURATE', '2026-10-18 02:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000012'::UUID, 'ACCURATE', '2026-10-18 04:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000004'::UUID, 'ACCURATE', '2026-10-18 06:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000005'::UUID, 'ACCURATE', '2026-10-18 08:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000008'::UUID, 'ACCURATE', '2026-10-18 10:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000013'::UUID, 'ACCURATE', '2026-10-18 12:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000001'::UUID, 'ACCURATE', '2026-10-18 14:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000006'::UUID, 'ACCURATE', '2026-10-18 16:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000014'::UUID, 'ACCURATE', '2026-10-18 18:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000007'::UUID, 'ACCURATE', '2026-10-18 20:40:00'::TIMESTAMP),
    (1, '00000000-0000-7000-b100-000000000011'::UUID, 'ACCURATE', '2026-10-18 22:40:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000001'::UUID, 'INACCURATE', '2026-09-12 12:15:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000012'::UUID, 'ACCURATE', '2026-09-12 14:15:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000006'::UUID, 'ACCURATE', '2026-09-12 16:15:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000008'::UUID, 'ACCURATE', '2026-09-12 18:15:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000003'::UUID, 'ACCURATE', '2026-09-12 20:15:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000013'::UUID, 'ACCURATE', '2026-09-12 22:15:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000010'::UUID, 'ACCURATE', '2026-09-13 00:15:00'::TIMESTAMP),
    (2, '00000000-0000-7000-b100-000000000005'::UUID, 'ACCURATE', '2026-09-13 02:15:00'::TIMESTAMP),
    (3, '00000000-0000-7000-b100-000000000011'::UUID, 'ACCURATE', '2026-09-09 21:30:00'::TIMESTAMP),
    (3, '00000000-0000-7000-b100-000000000013'::UUID, 'ACCURATE', '2026-09-09 23:30:00'::TIMESTAMP),
    (3, '00000000-0000-7000-b100-000000000001'::UUID, 'ACCURATE', '2026-09-10 01:30:00'::TIMESTAMP),
    (3, '00000000-0000-7000-b100-000000000007'::UUID, 'ACCURATE', '2026-09-10 03:30:00'::TIMESTAMP),
    (3, '00000000-0000-7000-b100-000000000014'::UUID, 'ACCURATE', '2026-09-10 05:30:00'::TIMESTAMP),
    (4, '00000000-0000-7000-b100-000000000011'::UUID, 'ACCURATE', '2026-09-02 14:05:00'::TIMESTAMP),
    (4, '00000000-0000-7000-b100-000000000002'::UUID, 'ACCURATE', '2026-09-02 16:05:00'::TIMESTAMP),
    (4, '00000000-0000-7000-b100-000000000004'::UUID, 'ACCURATE', '2026-09-02 18:05:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000010'::UUID, 'INACCURATE', '2026-09-04 23:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000011'::UUID, 'ACCURATE', '2026-09-05 01:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000008'::UUID, 'ACCURATE', '2026-09-05 03:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000013'::UUID, 'ACCURATE', '2026-09-05 05:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000009'::UUID, 'ACCURATE', '2026-09-05 07:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000014'::UUID, 'ACCURATE', '2026-09-05 09:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000007'::UUID, 'ACCURATE', '2026-09-05 11:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000006'::UUID, 'ACCURATE', '2026-09-05 13:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000005'::UUID, 'ACCURATE', '2026-09-05 15:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000003'::UUID, 'ACCURATE', '2026-09-05 17:20:00'::TIMESTAMP),
    (5, '00000000-0000-7000-b100-000000000001'::UUID, 'ACCURATE', '2026-09-05 19:20:00'::TIMESTAMP),
    (6, '00000000-0000-7000-b100-000000000003'::UUID, 'ACCURATE', '2026-10-22 11:40:00'::TIMESTAMP),
    (6, '00000000-0000-7000-b100-000000000001'::UUID, 'ACCURATE', '2026-10-22 13:40:00'::TIMESTAMP),
    (7, '00000000-0000-7000-b100-000000000005'::UUID, 'ACCURATE', '2026-10-26 20:10:00'::TIMESTAMP),
    (7, '00000000-0000-7000-b100-000000000011'::UUID, 'ACCURATE', '2026-10-26 22:10:00'::TIMESTAMP),
    (8, '00000000-0000-7000-b100-000000000007'::UUID, 'ACCURATE', '2026-10-27 15:25:00'::TIMESTAMP),
    (8, '00000000-0000-7000-b100-000000000006'::UUID, 'ACCURATE', '2026-10-27 17:25:00'::TIMESTAMP),
    (8, '00000000-0000-7000-b100-000000000005'::UUID, 'ACCURATE', '2026-10-27 19:25:00'::TIMESTAMP),
    (8, '00000000-0000-7000-b100-000000000009'::UUID, 'ACCURATE', '2026-10-27 21:25:00'::TIMESTAMP),
    (8, '00000000-0000-7000-b100-000000000014'::UUID, 'ACCURATE', '2026-10-27 23:25:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000005'::UUID, 'ACCURATE', '2026-09-20 01:05:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000009'::UUID, 'ACCURATE', '2026-09-20 03:05:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000011'::UUID, 'ACCURATE', '2026-09-20 05:05:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000004'::UUID, 'ACCURATE', '2026-09-20 07:05:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000003'::UUID, 'ACCURATE', '2026-09-20 09:05:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000001'::UUID, 'ACCURATE', '2026-09-20 11:05:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000007'::UUID, 'ACCURATE', '2026-09-20 13:05:00'::TIMESTAMP),
    (9, '00000000-0000-7000-b100-000000000008'::UUID, 'ACCURATE', '2026-09-20 15:05:00'::TIMESTAMP),
    (10, '00000000-0000-7000-b100-000000000009'::UUID, 'INACCURATE', '2026-10-24 22:45:00'::TIMESTAMP),
    (10, '00000000-0000-7000-b100-000000000003'::UUID, 'ACCURATE', '2026-10-25 00:45:00'::TIMESTAMP),
    (10, '00000000-0000-7000-b100-000000000002'::UUID, 'ACCURATE', '2026-10-25 02:45:00'::TIMESTAMP),
    (10, '00000000-0000-7000-b100-000000000004'::UUID, 'ACCURATE', '2026-10-25 04:45:00'::TIMESTAMP),
    (10, '00000000-0000-7000-b100-000000000011'::UUID, 'ACCURATE', '2026-10-25 06:45:00'::TIMESTAMP),
    (11, '00000000-0000-7000-b100-000000000001'::UUID, 'ACCURATE', '2026-10-28 01:30:00'::TIMESTAMP),
    (11, '00000000-0000-7000-b100-000000000003'::UUID, 'ACCURATE', '2026-10-28 03:30:00'::TIMESTAMP),
    (11, '00000000-0000-7000-b100-000000000013'::UUID, 'ACCURATE', '2026-10-28 05:30:00'::TIMESTAMP),
    (11, '00000000-0000-7000-b100-000000000012'::UUID, 'ACCURATE', '2026-10-28 07:30:00'::TIMESTAMP),
    (11, '00000000-0000-7000-b100-000000000010'::UUID, 'ACCURATE', '2026-10-28 09:30:00'::TIMESTAMP),
    (12, '00000000-0000-7000-b100-000000000010'::UUID, 'ACCURATE', '2026-10-13 12:20:00'::TIMESTAMP),
    (12, '00000000-0000-7000-b100-000000000012'::UUID, 'ACCURATE', '2026-10-13 14:20:00'::TIMESTAMP),
    (12, '00000000-0000-7000-b100-000000000005'::UUID, 'ACCURATE', '2026-10-13 16:20:00'::TIMESTAMP),
    (13, '00000000-0000-7000-b100-000000000008'::UUID, 'ACCURATE', '2026-10-20 20:00:00'::TIMESTAMP),
    (14, '00000000-0000-7000-b100-000000000008'::UUID, 'ACCURATE', '2026-10-20 15:15:00'::TIMESTAMP),
    (14, '00000000-0000-7000-b100-000000000003'::UUID, 'ACCURATE', '2026-10-20 17:15:00'::TIMESTAMP),
    (14, '00000000-0000-7000-b100-000000000014'::UUID, 'ACCURATE', '2026-10-20 19:15:00'::TIMESTAMP),
    (14, '00000000-0000-7000-b100-000000000001'::UUID, 'ACCURATE', '2026-10-20 21:15:00'::TIMESTAMP),
    (14, '00000000-0000-7000-b100-000000000013'::UUID, 'ACCURATE', '2026-10-20 23:15:00'::TIMESTAMP),
    (14, '00000000-0000-7000-b100-000000000006'::UUID, 'ACCURATE', '2026-10-21 01:15:00'::TIMESTAMP),
    (15, '00000000-0000-7000-b100-000000000009'::UUID, 'ACCURATE', '2026-10-21 21:50:00'::TIMESTAMP),
    (15, '00000000-0000-7000-b100-000000000010'::UUID, 'ACCURATE', '2026-10-21 23:50:00'::TIMESTAMP),
    (15, '00000000-0000-7000-b100-000000000004'::UUID, 'ACCURATE', '2026-10-22 01:50:00'::TIMESTAMP),
    (16, '00000000-0000-7000-b100-000000000007'::UUID, 'ACCURATE', '2026-10-22 22:30:00'::TIMESTAMP),
    (16, '00000000-0000-7000-b100-000000000004'::UUID, 'ACCURATE', '2026-10-23 00:30:00'::TIMESTAMP),
    (17, '00000000-0000-7000-b100-000000000003'::UUID, 'ACCURATE', '2026-10-26 18:40:00'::TIMESTAMP),
    (18, '00000000-0000-7000-b100-000000000012'::UUID, 'ACCURATE', '2026-10-23 23:40:00'::TIMESTAMP),
    (18, '00000000-0000-7000-b100-000000000014'::UUID, 'ACCURATE', '2026-10-24 01:40:00'::TIMESTAMP)
) AS seed (seed_no, member_id, vote_type, voted_at)
JOIN showcase_festival festival ON festival.seed_no = seed.seed_no
JOIN member voter ON voter.id = seed.member_id AND voter.deleted_at IS NULL
ON CONFLICT DO NOTHING;

INSERT INTO post (id, member_id, pu_fev_id, title, content, thumbnail, created_at, updated_at, deleted_at, like_count)
SELECT seed.id, seed.member_id, festival.festival_id, seed.title, seed.content, seed.thumbnail, seed.written_at, seed.written_at, NULL, 0
FROM (VALUES
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, 1, '짱구 덕후라면 무조건, 시공간 대모험 다녀왔어요', '<p>오픈 이튿날 오후에 다녀왔어요. 사전 예약을 못 해서 현장 대기를 걸었는데 생각보다 금방 들어갔어요.</p><img src="https://images.unsplash.com/photo-1663850697008-29fd8ea8e941?auto=format&fit=crop&w=1200&q=80" alt="전시장 입구 포토존"><p>공간마다 콘셉트가 확 바뀌어서 지루할 틈이 없었어요. 화면이 몸짓에 반응하는 인터랙티브 존이 많아서 어른도 신나게 놀았네요.</p><img src="https://images.unsplash.com/photo-1744189578759-5103cc188897?auto=format&fit=crop&w=1200&q=80" alt="마지막 구역의 포토부스"><p>마지막 입장이 저녁 7시라 퇴근하고 가실 분들은 시간 꼭 확인하세요. 굿즈존은 나가는 길에 들르는 구조예요.</p>', 'https://images.unsplash.com/photo-1663850697008-29fd8ea8e941?auto=format&fit=crop&w=800&q=80', '2026-10-18 19:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000002'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, 1, '7살 아이랑 짱구 전시, 2시간 꽉 채워 놀았어요', '<p>짱구를 좋아하는 아이랑 일요일 오후에 갔어요. 체험 공간이 많아서 아이가 지칠 때까지 뛰어다녔어요.</p><p>주말 오후라 사람이 꽤 많았어요. 여유 있게 보시려면 오전 시간대를 추천해요.</p><img src="https://images.unsplash.com/photo-1764788127523-ac9fd80be5f3?auto=format&fit=crop&w=1200&q=80" alt="출구 쪽 굿즈존"><p>굿즈존에서 키링 하나씩 사 들고 나왔어요. 아이가 아직도 떡잎마을 방범대 노래를 불러요 😂</p>', 'https://images.unsplash.com/photo-1764788127523-ac9fd80be5f3?auto=format&fit=crop&w=800&q=80', '2026-10-25 16:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000003'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, 2, '서울숲 산책하다가 탐정 스누피 미션 완료!', '<p>주말에 서울숲 산책하다가 들렀어요. 유니세프 정원 안을 걸으면서 단서를 찾는 방식이라 아이가 보물찾기처럼 좋아했어요.</p><img src="https://images.unsplash.com/photo-1581524070124-957d29ec032f?auto=format&fit=crop&w=1200&q=80" alt="정원 안 산책로"><p>단서마다 유니세프 활동 이야기가 붙어 있어서 아이한테 설명해 주기도 좋았어요.</p><img src="https://images.unsplash.com/photo-1742744132094-26fa77a4163f?auto=format&fit=crop&w=1200&q=80" alt="서울숲 산책로"><p>미션을 다 하고 인증하면 스누피 스티커팩을 줘요. 정오에 열어서 점심 먹고 가기 딱 좋아요.</p>', 'https://images.unsplash.com/photo-1581524070124-957d29ec032f?auto=format&fit=crop&w=800&q=80', '2026-10-04 14:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000004'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, 2, '단풍 들기 시작한 서울숲, 스누피 단서 찾기 코스 추천', '<p>서울숲이 슬슬 물들기 시작해서 산책 겸 다녀왔어요. 평일 낮이라 정원이 한산했어요.</p><img src="https://images.unsplash.com/photo-1619441207978-3d326c46e2c9?auto=format&fit=crop&w=1200&q=80" alt="단풍 든 서울숲 연못"><p>단서 찾기는 천천히 걸어도 30분 정도면 충분해요. 끝나고 받은 스티커팩은 노트북에 붙였습니다.</p><img src="https://images.unsplash.com/photo-1778278553405-09b847a2af3e?auto=format&fit=crop&w=1200&q=80" alt="받은 스티커들"><p>11월 16일까지라 단풍 절정 때 한 번 더 가 볼 생각이에요.</p>', 'https://images.unsplash.com/photo-1619441207978-3d326c46e2c9?auto=format&fit=crop&w=800&q=80', '2026-10-19 12:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, 3, '햄스터 마트 콘셉트 너무 귀여워요, 맘마 햄스토어', '<p>햄스터들이 마트를 차렸다는 콘셉트인데 층마다 소품이 너무 귀여워서 사진만 백 장 찍었어요.</p><img src="https://images.unsplash.com/photo-1425082661705-1834bfd09dca?auto=format&fit=crop&w=1200&q=80" alt="맘마 생각나는 햄스터"><p>만두 만들기 코너에서 만두 얼굴을 꾸미고 SNS 인증하면 말랑 키링을 랜덤으로 줘요. 저는 두 번 만에 원하던 아이가 나왔어요!</p><img src="https://images.unsplash.com/photo-1764788127523-ac9fd80be5f3?auto=format&fit=crop&w=1200&q=80" alt="키링 진열대"><p>선공개 신상도 있어서 구경할 게 많아요. 서울숲이랑 가까워서 산책 코스로 묶기 좋아요.</p>', 'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?auto=format&fit=crop&w=800&q=80', '2026-09-13 17:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000006'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, 3, '지하 1층부터 4층까지 스탬프 다 모았어요', '<p>층마다 스탬프가 하나씩 숨어 있어서 다 모으려면 건물을 꼼꼼히 돌아야 해요. 5개 다 모아서 직원분께 보여 드리면 한정 스티커를 줘요.</p><img src="https://images.unsplash.com/photo-1598305762558-328f599df683?auto=format&fit=crop&w=1200&q=80" alt="층별 진열 상품"><img src="https://images.unsplash.com/photo-1625768376503-68d2495d78c5?auto=format&fit=crop&w=1200&q=80" alt="스티커 존"><p>콜라보 상품은 층마다 종류가 달라서 위층까지 다 보고 사는 걸 추천해요.</p>', 'https://images.unsplash.com/photo-1598305762558-328f599df683?auto=format&fit=crop&w=800&q=80', '2026-10-11 15:25:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000007'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, 4, '작은 브랜드 발견하는 재미, 오래오래 함께가게', '<p>카카오페이가 소상공인 브랜드랑 같이 만든 팝업이에요. 화려한 체험보다는 브랜드 이야기를 천천히 읽는 전시에 가까워요.</p><img src="https://images.unsplash.com/photo-1779684998897-ce5de594a5ac?auto=format&fit=crop&w=1200&q=80" alt="아틀리에 존 진열"><p>재료 하나가 제품이 되기까지의 과정을 보여 줘서, 평소 그냥 지나치던 동네 브랜드를 다시 보게 됐어요.</p><img src="https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=1200&q=80" alt="구매한 에코백"><p>붐비지 않아서 연무장길 돌다가 쉬어 가기에도 좋았어요.</p>', 'https://images.unsplash.com/photo-1779684998897-ce5de594a5ac?auto=format&fit=crop&w=800&q=80', '2026-09-20 13:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, 5, '실물 크기 우디랑 버즈… 어릴 적 꿈 이뤘어요', '<p>오픈 첫 주말에 다녀왔어요. 1층 들어서자마자 실물 크기 캐릭터가 반겨 줘서 소리 지를 뻔했어요.</p><img src="https://images.unsplash.com/photo-1718804715033-8e045415f6f3?auto=format&fit=crop&w=1200&q=80" alt="토이 스토리 캐릭터들"><p>4층 건물 전체가 팝업이라 층마다 분위기가 달라요. 계단 오르내리는 게 조금 힘들지만 볼거리가 정말 많아요.</p><img src="https://images.unsplash.com/photo-1697201193383-601d4f3b7339?auto=format&fit=crop&w=1200&q=80" alt="팝업이 열린 성수 건물"><p>포토존 줄은 층마다 따로 있어서 생각보다 오래 기다리지 않았어요.</p>', 'https://images.unsplash.com/photo-1718804715033-8e045415f6f3?auto=format&fit=crop&w=800&q=80', '2026-09-06 18:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000009'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, 5, '굿즈 위주로 정리한 하우스 오브 토이스토리 후기', '<p>굿즈 보러 간 사람 기준 후기예요. 피규어, 키링, 문구류까지 종류가 정말 많아요.</p><img src="https://images.unsplash.com/photo-1608278047522-58806a6ac85b?auto=format&fit=crop&w=1200&q=80" alt="피규어 진열장"><p>층마다 파는 상품이 달라서 마음에 드는 게 있으면 그 층에서 바로 사는 게 좋아요. 다시 내려오기 번거로워요.</p><img src="https://images.unsplash.com/photo-1764788127523-ac9fd80be5f3?auto=format&fit=crop&w=1200&q=80" alt="키링 코너"><p>31일에 끝나니 아직 안 가셨다면 이번 주가 마지막 기회예요.</p>', 'https://images.unsplash.com/photo-1608278047522-58806a6ac85b?auto=format&fit=crop&w=800&q=80', '2026-10-03 14:15:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000010'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, 6, '리바이포유 10주년 팝업 첫날 다녀왔어요', '<p>사전 예약하고 오픈 첫날 퇴근길에 들렀어요. 히알프렙 라인을 전부 테스트해 볼 수 있게 되어 있어요.</p><img src="https://images.unsplash.com/photo-1787569499510-ef18cc7ba7a5?auto=format&fit=crop&w=1200&q=80" alt="제품 진열대"><img src="https://images.unsplash.com/photo-1585945037805-5fd82c2e60b1?auto=format&fit=crop&w=1200&q=80" alt="크림 테스트"><p>방문 선물로 팝업 한정 가방이랑 거울 키링을 받았어요. 가방이 생각보다 튼튼해요.</p><img src="https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=1200&q=80" alt="팝업 한정 가방">', 'https://images.unsplash.com/photo-1787569499510-ef18cc7ba7a5?auto=format&fit=crop&w=800&q=80', '2026-10-28 18:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000011'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, 7, '사우나 콘셉트 진짜 잘 살렸어요, SUPER GLOW SAUNA', '<p>오픈 첫날 오후 2시에 문 열자마자 갔어요. 나무로 꾸민 사우나 공간이 생각보다 그럴듯해서 사진 찍기 좋아요.</p><img src="https://images.unsplash.com/photo-1759302353458-3c617bfd428b?auto=format&fit=crop&w=1200&q=80" alt="사우나 콘셉트 체험 공간"><p>슈퍼레티놀 신제품을 써 보고 미션을 깨면 샘플 2종을 줘요. 사우나 체험까지 하면 한정 굿즈도 받을 수 있어요.</p><img src="https://images.unsplash.com/photo-1608571423902-eed4a5ad8108?auto=format&fit=crop&w=1200&q=80" alt="체험한 앰플">', 'https://images.unsplash.com/photo-1759302353458-3c617bfd428b?auto=format&fit=crop&w=800&q=80', '2026-10-28 17:50:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000012'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, 9, '주술회전 콜라보 카페 전기 메뉴 먹어 봤어요', '<p>오픈 첫 주말에 다녀왔어요. 캐릭터마다 콘셉트 음료가 있어서 최애 음료부터 골랐어요.</p><img src="https://images.unsplash.com/photo-1785711571852-8edfd71e92ef?auto=format&fit=crop&w=1200&q=80" alt="캐릭터 콘셉트 음료"><p>메뉴를 사면 특전 코스터를 랜덤으로 하나 줘요. 최애가 안 나와서 한 잔 더 시킬 뻔했어요.</p><img src="https://images.unsplash.com/photo-1567880905822-56f8e06fe630?auto=format&fit=crop&w=1200&q=80" alt="카페 내부"><p>10월 29일부터는 후기 메뉴로 바뀌고 특전도 달라진대요. 후기 때 한 번 더 가려고요.</p>', 'https://images.unsplash.com/photo-1785711571852-8edfd71e92ef?auto=format&fit=crop&w=800&q=80', '2026-09-27 20:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000013'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, 9, 'MD 3만 원 특전 티켓 받았어요 + 후기 일정 정리', '<p>MD를 3만 원 이상 사면 오리지널 티켓 5종 중 하나를 랜덤으로 줘요. 저는 두 번째 방문에 원하던 티켓이 나왔어요.</p><img src="https://images.unsplash.com/photo-1792019626300-2911392d6c82?auto=format&fit=crop&w=1200&q=80" alt="MD 진열"><p>전기는 10월 28일까지, 후기는 10월 29일부터 12월 1일까지예요. 시즌마다 메뉴 특전이 달라서 두 번 가는 분들이 많더라고요.</p>', 'https://images.unsplash.com/photo-1792019626300-2911392d6c82?auto=format&fit=crop&w=800&q=80', '2026-10-12 13:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000014'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, 10, '핫토이 팝업 오픈 첫날 줄 서서 다녀왔어요', '<p>한정판 선착순 판매가 있어서 오픈 전에 도착했는데 이미 줄이 꽤 길었어요.</p><img src="https://images.unsplash.com/photo-1743324754696-c636e1aed0b6?auto=format&fit=crop&w=1200&q=80" alt="오픈 전 대기 줄"><p>1:6 스케일 피규어를 실물로 보니 디테일이 확실히 달라요. 사진으로만 보던 라인업을 한 번에 볼 수 있어서 좋았어요.</p><img src="https://images.unsplash.com/photo-1608278047522-58806a6ac85b?auto=format&fit=crop&w=1200&q=80" alt="피규어 전시"><p>한정판이 목표라면 무조건 일찍 가세요. 전시만 볼 거면 저녁 시간이 한산해요.</p>', 'https://images.unsplash.com/photo-1743324754696-c636e1aed0b6?auto=format&fit=crop&w=800&q=80', '2026-10-27 21:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000015'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, 12, '스텔라이브 팝업, 현장 픽업 방식이 편했어요', '<p>예약 시간에 맞춰 들어갔어요. 멤버별로 꾸민 공간이 다 달라서 한 바퀴 도는 데 꽤 걸렸어요.</p><img src="https://images.unsplash.com/photo-1743119844808-fefd446de533?auto=format&fit=crop&w=1200&q=80" alt="전시 공간"><p>굿즈는 스마트폰으로 주문해 두고 현장에서 받는 방식이라 계산 줄이 거의 없었어요. 이 방식 다른 팝업도 했으면 좋겠어요.</p><img src="https://images.unsplash.com/photo-1774514580599-c3dae376348e?auto=format&fit=crop&w=1200&q=80" alt="본다빈치뮤지엄 내부"><p>만 14세 미만은 보호자 ID로 예약해야 하니 가족 단위로 가실 분들은 꼭 확인하세요.</p>', 'https://images.unsplash.com/photo-1743119844808-fefd446de533?auto=format&fit=crop&w=800&q=80', '2026-10-24 16:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000016'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, 14, '센텀에서 만난 응 커피, 교토 라떼 맛있네요', '<p>부산에서도 응 커피를 마실 수 있다니! 오픈 이튿날 오전에 다녀왔어요.</p><img src="https://images.unsplash.com/photo-1742549626436-bf3c11dab212?auto=format&fit=crop&w=1200&q=80" alt="교토 라떼"><p>교토 라떼가 7,900원이라 저렴하진 않지만 고소하고 부드러워요. 로고 머그컵도 팔아요.</p><img src="https://images.unsplash.com/photo-1559001724-fbad036dbc9e?auto=format&fit=crop&w=1200&q=80" alt="라떼 한 잔"><p>백화점 지하 1층이라 쇼핑하다 들르기 좋아요. 12월 14일까지 연다니 자주 갈 것 같아요.</p>', 'https://images.unsplash.com/photo-1742549626436-bf3c11dab212?auto=format&fit=crop&w=800&q=80', '2026-10-21 11:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000017'::UUID, '00000000-0000-7000-b100-000000000013'::UUID, 14, '점심시간에 마차 라떼 한 잔, 웨이팅 팁', '<p>센텀 근처 직장인이라 점심시간에 들렀어요. 12시 반쯤이 제일 붐비고, 1시 넘으면 좀 나아요.</p><img src="https://images.unsplash.com/photo-1766426910014-63a302fa137e?auto=format&fit=crop&w=1200&q=80" alt="마차 라떼"><p>마차 라떼는 쌉싸름한 맛이 진해서 단 거 안 좋아하는 분들께 추천해요.</p>', 'https://images.unsplash.com/photo-1766426910014-63a302fa137e?auto=format&fit=crop&w=800&q=80', '2026-10-26 13:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000018'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, 15, '몽모 얼굴인형 받으려고 10만 원 채웠어요 ㅎㅎ', '<p>조카 선물 사러 갔다가 제가 더 신났어요. 애착인형이 정말 폭신해요.</p><img src="https://images.unsplash.com/photo-1602734846297-9299fc2d4703?auto=format&fit=crop&w=1200&q=80" alt="애착인형"><p>포토네컷 프레임이 몽모라서 조카랑 한 장 찍었어요. 몽모 그리기 체험도 있어서 아이들이 줄 서 있더라고요.</p><img src="https://images.unsplash.com/photo-1641085809270-71f722611ce1?auto=format&fit=crop&w=1200&q=80" alt="집에 온 인형"><p>10만 원 넘게 사면 몽모 얼굴인형을 줘서 결국 채웠습니다…</p>', 'https://images.unsplash.com/photo-1602734846297-9299fc2d4703?auto=format&fit=crop&w=800&q=80', '2026-10-24 15:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000019'::UUID, '00000000-0000-7000-b100-000000000012'::UUID, 16, '럭키 아일랜드 도감 미션 채우고 텀블러 득템', '<p>스타필드 고양 1층 고메 아트리움에 행운의 섬이 꾸며져 있어요. 오솔길, 연못, 오두막을 돌면서 도감 칸을 채우는 방식이에요.</p><img src="https://images.unsplash.com/photo-1761333485882-c60907725574?auto=format&fit=crop&w=1200&q=80" alt="스타필드 고양 아트리움"><p>행운의 상점에서 텀블러를 30% 할인해 줘서 하나 샀어요. 키친웨어는 최대 60%까지 할인하더라고요.</p><img src="https://images.unsplash.com/photo-1729192293999-ffbdc97cbac9?auto=format&fit=crop&w=1200&q=80" alt="새로 산 텀블러"><img src="https://images.unsplash.com/photo-1679310289576-8e1b68b808ba?auto=format&fit=crop&w=1200&q=80" alt="진열된 보틀">', 'https://images.unsplash.com/photo-1729192293999-ffbdc97cbac9?auto=format&fit=crop&w=800&q=80', '2026-10-25 14:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000020'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, 13, '금요일 2시 뽑기 도전! 힐리먼트 팝업 후기', '<p>매주 금·토요일 오후 2시에 선착순 뽑기를 해서 맞춰서 갔어요. 결과는 꽝이었지만 재밌었어요.</p><img src="https://images.unsplash.com/photo-1567955465154-078c60ff5c9e?auto=format&fit=crop&w=1200&q=80" alt="26FW 아우터"><p>26FW 신상이 20% 할인이라 바람막이를 하나 샀어요. 주머니가 많아서 진짜 낚시 갈 때도 입을 수 있겠어요.</p><img src="https://images.unsplash.com/photo-1649937408746-4d2f603f91c8?auto=format&fit=crop&w=1200&q=80" alt="매장에 걸린 재킷">', 'https://images.unsplash.com/photo-1567955465154-078c60ff5c9e?auto=format&fit=crop&w=800&q=80', '2026-10-23 19:45:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000021'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, 18, '13년 기다린 보람 있었어요, 발푸르기스의 회천 팝업 첫날 🌙', '<p>오픈 첫날 점심시간에 맞춰 홍대 JS스토어 2층에 다녀왔어요. 11월 4일 개봉을 앞두고 분위기를 먼저 느끼고 싶어서 반차까지 쓰고 달려갔답니다 🩷</p><img src="https://cdn.popga.co.kr/spot/14165/main/2f939217-182c-4f3b-b7eb-7f4e84f67b08_1792130626354_thumbnail_MAIN_W480.webp" alt="발푸르기스의 회천 팝업스토어 포스터"><h2>🎀 공간과 전시</h2><p>2층에 올라가면 극장판 키비주얼이 가장 먼저 반겨 줘요. 작품 세계관을 담은 전시 연출이 곳곳에 있어서, 굿즈만 사고 나오려다 한참을 둘러봤어요.</p><h2>🛍️ 굿즈와 혜택</h2><ul><li><p>극장판 개봉을 기념한 <strong>한정 상품</strong>이 준비돼 있어요</p></li><li><p><strong>특별 구매 혜택</strong>이 있으니 계산 전에 안내문을 꼭 확인하세요</p></li><li><p>상품 목록은 공식 인스타그램 공지에서 미리 볼 수 있어요</p></li></ul><h2>💡 방문 팁</h2><ul><li><p>운영 시간은 <strong>매일 12:00~20:00</strong>이에요</p></li><li><p>주말엔 붐빌 수 있으니 여유 있게 보려면 평일 방문을 추천해요</p></li><li><p><strong>11월 11일(수)</strong>까지만 열어요</p></li></ul><blockquote><p>개봉 전에 한 번, 영화 보고 나서 한 번 더 갈 생각이에요. 마도카 팬이라면 기간 안에 꼭 들러 보세요 ✨</p></blockquote><img src="https://images.unsplash.com/photo-1762541693135-fb989de961e1?auto=format&fit=crop&w=1200&h=675&q=80" alt="개봉일만 기다리는 중">', 'https://cdn.popga.co.kr/spot/14165/main/2f939217-182c-4f3b-b7eb-7f4e84f67b08_1792130626354_thumbnail_MAIN_W480.webp', '2026-10-30 16:10:00'::TIMESTAMP)
) AS seed (id, member_id, seed_no, title, content, thumbnail, written_at)
JOIN showcase_festival festival ON festival.seed_no = seed.seed_no
JOIN member author ON author.id = seed.member_id AND author.deleted_at IS NULL
ON CONFLICT (id) DO NOTHING;

INSERT INTO "like" (src_id, member_id, festival_id, created_at, updated_at)
SELECT seed.post_id, seed.member_id, NULL, seed.liked_at, seed.liked_at
FROM (VALUES
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000012'::UUID, '2026-10-18 20:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '2026-10-18 21:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '2026-10-18 22:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000009'::UUID, '2026-10-18 23:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '2026-10-19 00:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '2026-10-19 01:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000013'::UUID, '2026-10-19 02:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, '2026-10-19 03:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '2026-10-19 04:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '2026-10-19 05:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000002'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '2026-10-25 17:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000002'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '2026-10-25 18:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000002'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '2026-10-25 19:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000002'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '2026-10-25 20:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000002'::UUID, '00000000-0000-7000-b100-000000000012'::UUID, '2026-10-25 21:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000002'::UUID, '00000000-0000-7000-b100-000000000013'::UUID, '2026-10-25 22:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000003'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '2026-10-04 15:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000003'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '2026-10-04 16:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000003'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, '2026-10-04 17:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000003'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, '2026-10-04 18:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000003'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, '2026-10-04 19:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000004'::UUID, '00000000-0000-7000-b100-000000000013'::UUID, '2026-10-19 13:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000004'::UUID, '00000000-0000-7000-b100-000000000009'::UUID, '2026-10-19 14:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000004'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, '2026-10-19 15:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000004'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '2026-10-19 16:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '2026-09-13 18:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000012'::UUID, '2026-09-13 19:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000013'::UUID, '2026-09-13 20:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, '2026-09-13 21:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '2026-09-13 22:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, '2026-09-13 23:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '2026-09-14 00:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, '2026-09-14 01:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000006'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, '2026-10-11 16:25:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000006'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '2026-10-11 17:25:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000006'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, '2026-10-11 18:25:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000006'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, '2026-10-11 19:25:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000007'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '2026-09-20 14:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000007'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, '2026-09-20 15:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000007'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '2026-09-20 16:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000009'::UUID, '2026-09-06 19:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '2026-09-06 20:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '2026-09-06 21:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000013'::UUID, '2026-09-06 22:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, '2026-09-06 23:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, '2026-09-07 00:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '2026-09-07 01:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '2026-09-07 02:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '2026-09-07 03:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, '2026-09-07 04:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '2026-09-07 05:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000012'::UUID, '2026-09-07 06:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000009'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '2026-10-03 15:15:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000009'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, '2026-10-03 16:15:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000009'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '2026-10-03 17:15:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000009'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, '2026-10-03 18:15:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000009'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '2026-10-03 19:15:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000009'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '2026-10-03 20:15:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000010'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '2026-10-28 19:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000010'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '2026-10-28 20:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000011'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '2026-10-28 18:50:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000012'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, '2026-09-27 21:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000012'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '2026-09-27 22:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000012'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '2026-09-27 23:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000012'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '2026-09-28 00:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000012'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, '2026-09-28 01:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000012'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '2026-09-28 02:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000012'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '2026-09-28 03:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000013'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, '2026-10-12 14:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000013'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '2026-10-12 15:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000013'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '2026-10-12 16:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000013'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '2026-10-12 17:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000014'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '2026-10-27 22:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000014'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, '2026-10-27 23:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000014'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '2026-10-28 00:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000015'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '2026-10-24 17:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000015'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, '2026-10-24 18:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000015'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '2026-10-24 19:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000015'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, '2026-10-24 20:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000015'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '2026-10-24 21:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000016'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '2026-10-21 12:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000016'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, '2026-10-21 13:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000016'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, '2026-10-21 14:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000016'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '2026-10-21 15:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000016'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '2026-10-21 16:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000016'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '2026-10-21 17:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000016'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, '2026-10-21 18:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000017'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, '2026-10-26 14:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000017'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '2026-10-26 15:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000018'::UUID, '00000000-0000-7000-b100-000000000013'::UUID, '2026-10-24 16:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000018'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '2026-10-24 17:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000018'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, '2026-10-24 18:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000018'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '2026-10-24 19:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000019'::UUID, '00000000-0000-7000-b100-000000000009'::UUID, '2026-10-25 15:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000019'::UUID, '00000000-0000-7000-b100-000000000014'::UUID, '2026-10-25 16:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000019'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '2026-10-25 17:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000020'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '2026-10-23 20:45:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000020'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '2026-10-23 21:45:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000021'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '2026-10-30 16:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000021'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '2026-10-30 16:50:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000021'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '2026-10-30 17:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000021'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '2026-10-30 17:30:00'::TIMESTAMP)
) AS seed (post_id, member_id, liked_at)
JOIN post ON post.id = seed.post_id
JOIN member voter ON voter.id = seed.member_id AND voter.deleted_at IS NULL
ON CONFLICT DO NOTHING;

UPDATE post
SET like_count = (SELECT COUNT(*) FROM "like" WHERE "like".src_id = post.id)
WHERE post.id::TEXT LIKE '00000000-0000-7000-b300-%';

INSERT INTO "comment" (post_id, member_id, content, created_at, updated_at, deleted_at, parent_id)
SELECT seed.post_id, seed.member_id, seed.content, seed.written_at, seed.written_at, NULL, NULL
FROM (VALUES
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '현장 대기 몇 분 정도 걸리셨어요? 이번 주말에 가려고요!', '2026-10-18 21:02:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '포토부스 사진 너무 귀엽네요 ㅠㅠ', '2026-10-19 09:14:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000002'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '아이랑 가기 좋다니 저도 조카 데리고 가 봐야겠어요.', '2026-10-25 18:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000003'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, '서울숲 근처 살아서 산책 겸 가 봐야겠네요. 스티커팩 귀여워요?', '2026-10-04 19:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000004'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '단풍 사진 예쁘네요. 주말에도 사람 많지 않았나요?', '2026-10-19 18:22:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '햄스터 너무 귀여워서 저장했어요', '2026-09-13 20:41:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '말랑 키링 랜덤인 거 무섭네요… 원하는 거 나오셨다니 부러워요.', '2026-09-14 10:02:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000006'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '스탬프 다 모으면 스티커 주는 거 몰랐네요. 꿀팁 감사해요.', '2026-10-11 19:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000007'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '10월 말까지라니 성수 갈 때 꼭 들러야겠어요.', '2026-09-21 08:50:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '건물 전체가 토이 스토리라니 미쳤다…', '2026-09-06 21:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '아이가 버즈 광팬이라 꼭 가 보고 싶어요. 주말에 많이 붐비나요?', '2026-09-07 08:35:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000009'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '굿즈 정리 최고예요. 키링 가격대는 어땠어요?', '2026-10-03 17:28:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000010'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '한정 가방 실물 예쁜가요?', '2026-10-28 20:15:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000012'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '고죠 음료 비주얼 궁금했는데 후기 감사합니다', '2026-09-28 09:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000012'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '후기 메뉴도 기대되네요. 같이 정리해 주세요!', '2026-09-28 12:44:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000013'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '저도 같은 티켓 나왔어요 ㅋㅋ 반가워요', '2026-10-12 16:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000014'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '한정판 피규어 남아 있었나요?', '2026-10-27 22:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000015'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '사전 예약 꼭 해야 하나요?', '2026-10-24 19:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000016'::UUID, '00000000-0000-7000-b100-000000000013'::UUID, '저도 출근 전에 들렀어요. 머그컵 할인은 아직 하나요?', '2026-10-21 13:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000017'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '저는 교토 라떼만 마셔 봤는데 다음엔 마차 라떼 먹어 볼게요.', '2026-10-26 18:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000018'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '몽모 너무 귀여워요. 포토네컷 프레임 예쁘네요', '2026-10-24 20:45:00'::TIMESTAMP),
    ('00000000-0000-7000-b300-000000000019'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '수원에서 놓쳤는데 고양에서 하는군요! 감사합니다', '2026-10-25 19:12:00'::TIMESTAMP)
) AS seed (post_id, member_id, content, written_at)
JOIN post target ON target.id = seed.post_id
JOIN member author ON author.id = seed.member_id AND author.deleted_at IS NULL
WHERE NOT EXISTS (
    SELECT 1 FROM "comment" existing
    WHERE existing.post_id = seed.post_id AND existing.member_id = seed.member_id AND existing.content = seed.content
);

INSERT INTO "comment" (post_id, member_id, content, created_at, updated_at, deleted_at, parent_id)
SELECT seed.post_id, seed.member_id, seed.content, seed.written_at, seed.written_at, NULL, parent.id
FROM (VALUES
    ('00000000-0000-7000-b300-000000000001'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '저는 20분 안쪽이었어요. 오픈 직후가 제일 한산했어요.', '2026-10-18 21:30:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000002'::UUID, '현장 대기 몇 분 정도 걸리셨어요? 이번 주말에 가려고요!'),
    ('00000000-0000-7000-b300-000000000003'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '네! 아이가 받자마자 가방에 붙였어요 ㅎㅎ', '2026-10-04 20:12:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000001'::UUID, '서울숲 근처 살아서 산책 겸 가 봐야겠네요. 스티커팩 귀여워요?'),
    ('00000000-0000-7000-b300-000000000004'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, '주말엔 가족 단위가 많아요. 평일 낮이 여유로워요.', '2026-10-19 19:05:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000003'::UUID, '단풍 사진 예쁘네요. 주말에도 사람 많지 않았나요?'),
    ('00000000-0000-7000-b300-000000000005'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '운이 좋았어요! 꼭 원하는 아이 나오길 바라요 🍀', '2026-09-14 12:30:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000010'::UUID, '말랑 키링 랜덤인 거 무섭네요… 원하는 거 나오셨다니 부러워요.'),
    ('00000000-0000-7000-b300-000000000008'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '주말 오전에 가시면 그나마 한산해요!', '2026-09-07 09:12:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000011'::UUID, '아이가 버즈 광팬이라 꼭 가 보고 싶어요. 주말에 많이 붐비나요?'),
    ('00000000-0000-7000-b300-000000000009'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '종류마다 달라서 현장에서 보시는 게 정확해요!', '2026-10-03 18:02:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000002'::UUID, '굿즈 정리 최고예요. 키링 가격대는 어땠어요?'),
    ('00000000-0000-7000-b300-000000000010'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '생각보다 튼튼해서 장 볼 때 잘 쓸 것 같아요.', '2026-10-28 21:40:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000005'::UUID, '한정 가방 실물 예쁜가요?'),
    ('00000000-0000-7000-b300-000000000014'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '인기 있는 건 금방 빠지는 분위기라 일찍 가시는 게 좋아요.', '2026-10-27 22:31:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000002'::UUID, '한정판 피규어 남아 있었나요?'),
    ('00000000-0000-7000-b300-000000000015'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '네, 네이버 예약으로 받고 있어요. 14세 미만은 보호자 ID로 예약해야 해요.', '2026-10-24 19:26:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000003'::UUID, '사전 예약 꼭 해야 하나요?'),
    ('00000000-0000-7000-b300-000000000016'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '오픈 기념 수량이 200개라 이미 끝났을 수도 있어요 ㅠ', '2026-10-21 14:02:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000013'::UUID, '저도 출근 전에 들렀어요. 머그컵 할인은 아직 하나요?')
) AS seed (post_id, member_id, content, written_at, parent_member_id, parent_content)
JOIN "comment" parent ON parent.post_id = seed.post_id AND parent.member_id = seed.parent_member_id
                    AND parent.content = seed.parent_content AND parent.parent_id IS NULL
JOIN member author ON author.id = seed.member_id AND author.deleted_at IS NULL
WHERE NOT EXISTS (
    SELECT 1 FROM "comment" existing
    WHERE existing.post_id = seed.post_id AND existing.member_id = seed.member_id AND existing.content = seed.content
);

INSERT INTO community_post (id, member_id, category, title, content, view_count, created_at, updated_at, deleted_at)
SELECT seed.id, seed.member_id, seed.category, seed.title, seed.content, seed.view_count, seed.written_at, seed.written_at, NULL
FROM (VALUES
    ('00000000-0000-7000-b400-000000000001'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, 'EVENT', '이번 주에 끝나는 팝업 정리 (주말 동선용)', '이번 주말 전후로 끝나는 팝업들 정리해 봤어요. 날짜는 꼭 공식 계정에서 한 번 더 확인하세요!

- 카카오페이 오래오래 함께가게 (성수) ~10/31
- 하우스 오브 토이스토리 (성수) ~10/31
- 스텔라이브 STELLA MODE:ON (능동) ~11/1
- 주도적 장터 (제주 LPP) ~11/1
- 바이탈뷰티 SUPER GLOW SAUNA (성수) ~11/3
- 아일릿 BREAK EVEN (홍대) ~11/3

성수에서 능동까지 지하철로 금방이라 토요일에 묶어서 돌 생각이에요.', 412, '2026-10-28 22:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000002'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, 'FREE', '성수 팝업 하루 코스 (연무장길 기준)', '<p>연무장길 쪽에 팝업이 몰려 있어서 걸어서 돌기 좋아요.</p><p>1) 서울숲 탐정 스누피 (12시 오픈이라 점심 먹고 가도 돼요)<br>2) 메이드바이 햄스토어 (서울숲길)<br>3) 연무장길: 리바이포유 → 바이탈뷰티 → 올리브영 N성수 월즈 팝업<br>4) 마무리: 짱구 전시</p><img src="https://images.unsplash.com/photo-1652618959145-1d58531713d4?auto=format&fit=crop&w=1200&q=80" alt="연무장길 골목"><p>짱구 전시는 입장 마감이 저녁 7시라 마지막에 넣으면 아슬아슬해요. 시간 꼭 확인하세요!</p>', 538, '2026-10-26 20:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000003'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, 'FREE', 'AK플라자 홍대 2층·3층 같이 돌기 좋아요', '2층 핫토이 팝업, 3층 주술회전 콜라보 카페가 같은 건물이라 한 번에 돌았어요.
둘 다 평일 11시, 주말 10시 30분에 열어요. 카페는 메뉴 사면 코스터 특전이 있으니 참고하세요.', 203, '2026-10-27 22:45:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000004'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, 'EVENT', '[동행] 11/1(일) 오후 짱구 전시 같이 보실 분', '11월 1일 일요일 오후 3시쯤 짱구 전시 가려고 해요. 혼자 가기 아쉬워서 같이 보실 분 계시면 댓글 주세요!

공지대로 연락처는 남기지 않고, 전시장 입구에서 만나는 걸로 해요.', 97, '2026-10-28 12:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000005'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, 'EVENT', '월즈26 팝업 단독 리워드 뭐 주는지 아시는 분?', '올리브영 N성수에서만 주는 리워드가 있다던데 혹시 공지 보신 분 계세요?
현장 대기 입장이라 오픈런 해야 할지 고민이에요.', 156, '2026-10-28 19:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000006'::UUID, '00000000-0000-7000-b100-000000000012'::UUID, 'FREE', '써모스 럭키 아일랜드 행운 도감 다 채웠어요', '<p>스타필드 고양 고메 아트리움이에요. 오솔길·연못·오두막 돌면서 도감 칸 채우는 방식이라 아이들이 엄청 좋아하더라고요.</p><img src="https://images.unsplash.com/photo-1729192293999-ffbdc97cbac9?auto=format&fit=crop&w=1200&q=80" alt="할인받아 산 텀블러"><p>텀블러 30% 할인이라 하나 장만했습니다.</p>', 88, '2026-10-25 18:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000007'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, 'RESTAURANT', '성수 팝업 돌고 먹을 만한 곳 추천해 주세요', '이번 주말에 연무장길 팝업 돌 예정인데 웨이팅 짧은 밥집 아시는 분 계세요? 빵 말고 밥이요 ㅎㅎ', 264, '2026-10-24 11:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000008'::UUID, '00000000-0000-7000-b100-000000000013'::UUID, 'RESTAURANT', '센텀시티 근처 점심 어디 가세요?', '센텀 근처 직장인인데 아라비카 생기고 나서 커피는 해결됐어요 ㅋㅋ
점심은 백화점 식당가 말고 근처에 괜찮은 곳 있으면 공유해 주세요.', 71, '2026-10-23 12:50:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000009'::UUID, '00000000-0000-7000-b100-000000000009'::UUID, 'EVENT', '내일부터 제주 원도심에서 주도적 장터 열려요', '제주 로컬 브랜드 24개 팀이 나온대요. 11시부터 5시까지라 늦게 가면 못 볼 수도 있어요.
현장 할인쿠폰이랑 선물 꾸러미도 있다니 제주 계신 분들 가 보세요!', 45, '2026-10-28 17:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000010'::UUID, '00000000-0000-7000-b100-000000000008'::UUID, 'EVENT', '더현대 대구 9층 몽모 팝업 다녀오신 분', '체로프 몽모 팝업 이번 주말에 가 보려는데 포토네컷 줄 긴가요? 조카 데리고 가려고 해요.', 63, '2026-10-22 20:15:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000011'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, 'FREE', '팝업 사전예약 실패 덜 하는 법', '1. 예약 오픈 시간에 알림 맞춰 두기
2. 네이버 예약은 미리 로그인해 두기
3. 예약 못 했으면 현장 대기 운영하는지 공식 계정 공지 확인
4. 평일 오픈 직후가 제일 한산해요

다들 꿀팁 있으면 댓글로 공유해 주세요!', 389, '2026-10-20 21:00:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000012'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, 'FREE', '신세계 센텀 지하 2층 힐리먼트 할인 괜찮네요', '금요일 오후 2시 뽑기 도전했는데 꽝 ㅋㅋ
그래도 26FW 신상 20% 할인이라 바람막이 하나 샀어요. 11월 4일까지래요.', 58, '2026-10-23 20:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000013'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, 'RESTAURANT', '홍대 AK플라자 근처 디저트 카페 추천 받아요', '콜라보 카페 다녀오고 나서 디저트가 더 당기는데… 연남동 쪽으로 걸어갈 만한 곳 있을까요?', 112, '2026-10-26 15:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000014'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, 'FREE', '아이랑 가기 좋은 이번 주 팝업', '아이 데리고 다니기 편했던 곳 위주로 적어요.
- 서울숲 탐정 스누피 (야외 정원)
- 짱구 전시 (체험형)
- 써모스 럭키 아일랜드 (스타필드 고양)
- 체로프 몽모 (더현대 대구, 몽모 그리기 체험)

다른 추천 있으면 알려 주세요!', 147, '2026-10-27 09:30:00'::TIMESTAMP)
) AS seed (id, member_id, category, title, content, view_count, written_at)
JOIN member author ON author.id = seed.member_id AND author.deleted_at IS NULL
ON CONFLICT (id) DO NOTHING;

INSERT INTO community_comment (post_id, member_id, content, created_at, updated_at, deleted_at, parent_id)
SELECT seed.post_id, seed.member_id, seed.content, seed.written_at, seed.written_at, NULL, NULL
FROM (VALUES
    ('00000000-0000-7000-b400-000000000001'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '정리 감사합니다! 토이 스토리 아직 못 가서 토요일에 가려고요', '2026-10-28 22:31:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000001'::UUID, '00000000-0000-7000-b100-000000000006'::UUID, '아일릿 팝업은 밤 11시까지라 퇴근하고 가기 좋아요', '2026-10-28 22:50:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000002'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '동선 그대로 따라가 볼게요!', '2026-10-26 21:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000002'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '짱구 전시 입장 마감 시간 몰랐는데 감사합니다', '2026-10-26 21:44:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000002'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '아이랑 가면 스누피를 오전에 넣는 게 좋겠네요', '2026-10-27 08:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000003'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '핫토이 보고 카페에서 쉬면 딱이겠네요', '2026-10-27 23:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000004'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '저 그날 성수 가는데 시간 맞으면 갈게요!', '2026-10-28 13:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000005'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '자세한 건 아직 공식 계정에 안 올라온 것 같아요. 첫날 다녀오신 분 후기 기다려 봐요.', '2026-10-28 19:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000006'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '아이랑 가기 좋아 보이네요! 많이 붐볐나요?', '2026-10-25 19:02:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000007'::UUID, '00000000-0000-7000-b100-000000000001'::UUID, '큰길보다 골목 안쪽으로 조금 들어가면 칼국수·국밥집이 꽤 있어요. 웨이팅도 짧아요.', '2026-10-24 12:10:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000007'::UUID, '00000000-0000-7000-b100-000000000004'::UUID, '서울숲 쪽으로 가면 브런치 카페도 많아요!', '2026-10-24 13:02:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000008'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '영화의전당 쪽으로 조금 걸으면 밥집이 많아요.', '2026-10-23 13:20:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000009'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '부산에서 비행기 타고 가고 싶다…', '2026-10-28 18:12:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000010'::UUID, '00000000-0000-7000-b100-000000000011'::UUID, '서울이라 못 가지만 몽모 너무 귀여워요ㅠ', '2026-10-22 21:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000011'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '취소표가 전날 밤에 많이 풀려요!', '2026-10-20 21:30:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000011'::UUID, '00000000-0000-7000-b100-000000000010'::UUID, '굿즈가 목표면 첫날보다 둘째 날 오전이 덜 붐볐어요', '2026-10-20 22:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000011'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '1번 진짜 중요해요 ㅋㅋ', '2026-10-21 08:40:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000012'::UUID, '00000000-0000-7000-b100-000000000013'::UUID, '주말에 가 볼게요! 토요일도 뽑기 있죠?', '2026-10-23 21:15:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000013'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '경의선숲길 따라 연남동 쪽으로 걸으면 카페가 많아요!', '2026-10-26 16:05:00'::TIMESTAMP),
    ('00000000-0000-7000-b400-000000000014'::UUID, '00000000-0000-7000-b100-000000000012'::UUID, '써모스는 쇼핑몰 안이라 날씨 상관없어서 좋았어요', '2026-10-27 10:15:00'::TIMESTAMP)
) AS seed (post_id, member_id, content, written_at)
JOIN community_post target ON target.id = seed.post_id
JOIN member author ON author.id = seed.member_id AND author.deleted_at IS NULL
WHERE NOT EXISTS (
    SELECT 1 FROM community_comment existing
    WHERE existing.post_id = seed.post_id AND existing.member_id = seed.member_id AND existing.content = seed.content
);

INSERT INTO community_comment (post_id, member_id, content, created_at, updated_at, deleted_at, parent_id)
SELECT seed.post_id, seed.member_id, seed.content, seed.written_at, seed.written_at, NULL, parent.id
FROM (VALUES
    ('00000000-0000-7000-b400-000000000001'::UUID, '00000000-0000-7000-b100-000000000002'::UUID, '오 늦게까지 하는 거 몰랐어요. 감사해요!', '2026-10-28 23:02:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000006'::UUID, '아일릿 팝업은 밤 11시까지라 퇴근하고 가기 좋아요'),
    ('00000000-0000-7000-b400-000000000004'::UUID, '00000000-0000-7000-b100-000000000003'::UUID, '좋아요! 3시에 입구 앞에서 봬요 :)', '2026-10-28 13:40:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000004'::UUID, '저 그날 성수 가는데 시간 맞으면 갈게요!'),
    ('00000000-0000-7000-b400-000000000006'::UUID, '00000000-0000-7000-b100-000000000012'::UUID, '일요일 오후였는데 도감 미션 줄은 금방 빠졌어요.', '2026-10-25 19:30:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000011'::UUID, '아이랑 가기 좋아 보이네요! 많이 붐볐나요?'),
    ('00000000-0000-7000-b400-000000000007'::UUID, '00000000-0000-7000-b100-000000000005'::UUID, '골목 안쪽 공략해 볼게요 감사해요!', '2026-10-24 12:25:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000001'::UUID, '큰길보다 골목 안쪽으로 조금 들어가면 칼국수·국밥집이 꽤 있어요. 웨이팅도 짧아요.'),
    ('00000000-0000-7000-b400-000000000009'::UUID, '00000000-0000-7000-b100-000000000009'::UUID, '해피빈 펀딩으로도 같은 브랜드들 만날 수 있어요!', '2026-10-28 18:40:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000007'::UUID, '부산에서 비행기 타고 가고 싶다…'),
    ('00000000-0000-7000-b400-000000000012'::UUID, '00000000-0000-7000-b100-000000000007'::UUID, '네 금·토 오후 2시예요', '2026-10-23 21:40:00'::TIMESTAMP, '00000000-0000-7000-b100-000000000013'::UUID, '주말에 가 볼게요! 토요일도 뽑기 있죠?')
) AS seed (post_id, member_id, content, written_at, parent_member_id, parent_content)
JOIN community_comment parent ON parent.post_id = seed.post_id AND parent.member_id = seed.parent_member_id
                    AND parent.content = seed.parent_content AND parent.parent_id IS NULL
JOIN member author ON author.id = seed.member_id AND author.deleted_at IS NULL
WHERE NOT EXISTS (
    SELECT 1 FROM community_comment existing
    WHERE existing.post_id = seed.post_id AND existing.member_id = seed.member_id AND existing.content = seed.content
);
