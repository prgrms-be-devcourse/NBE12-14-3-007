-- CultureInfoDetailRow 디코딩 수정(fix/festival-html-entity-decode) 반영 후, 이미 동기화된 과거 데이터를 바로잡는 1회성 백필.
--
-- 왜 필요한가:
--   공공 API가 title/content/place에 &lt;, &amp;, &#39; 같은 HTML 엔티티를 이스케이프해서 보내는데,
--   지금까지는 그대로 저장해왔다. 코드 수정은 앞으로 동기화되는 신규 행사에만 적용되고,
--   이미 저장된 과거 행사는 syncPublicFestivals()가 다시 안 건드려서 저절로 안 바뀐다.
--   이 스크립트를 환경별로 한 번씩 직접 실행해야 한다.
--   Python 표준 라이브러리 html.unescape()로 생성했고, &amp;lsquo; 같은 이중 이스케이프도
--   더 이상 안 바뀔 때까지 반복 디코딩해서 처리했다 (총 2,753건).
--
-- 주의 (중요): festival.id는 환경마다 다를 수 있는 auto-increment 값이라 WHERE id = N 방식은
--   위험하다 (다른 환경에서 엉뚱한 행을 덮어쓸 수 있음). 그래서 이 스크립트는 환경에 관계없이
--   같은 행사를 가리키는 external_id(공공 API seq)로 매칭한다.
--
-- 실행 전 확인:
--   SELECT count(*) FROM festival
--   WHERE title ~ '&[a-zA-Z0-9#]+;' OR content ~ '&[a-zA-Z0-9#]+;' OR place ~ '&[a-zA-Z0-9#]+;';
--
-- 실행 후 확인 (0이어야 정상):
--   SELECT count(*) FROM festival
--   WHERE title ~ '&[a-zA-Z0-9#]+;' OR content ~ '&[a-zA-Z0-9#]+;' OR place ~ '&[a-zA-Z0-9#]+;';

BEGIN;

UPDATE festival SET title = '[대학로] 대표 코미디 연극 <오백에 삼십>', content = '', place = 'JTN아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393376';
UPDATE festival SET title = '2025년 박물관 미술관 주간 「뮤지엄×만나다」 - 큰이빨부리고래 전신 골격', content = '', place = '부산해양자연사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '341122';
UPDATE festival SET title = '[홍대] 미스터리 스릴러 연극 <흉터>', content = '', place = '홍대 씨어터 윤' WHERE provider_type = 'PUBLIC' AND external_id = '401660';
UPDATE festival SET title = '2025년 특별전시 <사상의 탄생>', content = '', place = '사상생활사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '332197';
UPDATE festival SET title = '2025 기획특별전 <어느 늦봄, 마음을 담다> ', content = '', place = '성북선잠박물관' WHERE provider_type = 'PUBLIC' AND external_id = '325793';
UPDATE festival SET title = '2025년 어린이실 테마전시 ''반구천의 암각화로 놀러 와!''', content = '', place = '울산암각화박물관' WHERE provider_type = 'PUBLIC' AND external_id = '335420';
UPDATE festival SET title = '박노해 사진전 <산빛>', content = '', place = '라 카페 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '335474';
UPDATE festival SET title = '2025 국립경찰박물관 특별전 <나의 영웅, 우리의 경찰>', content = '', place = '경찰박물관' WHERE provider_type = 'PUBLIC' AND external_id = '366899';
UPDATE festival SET title = '2025년 박두진문학관 광복 80주년 기념 특별기획전 <다시 찾은 빛, 청록집>', content = '', place = '박두진문학관' WHERE provider_type = 'PUBLIC' AND external_id = '340289';
UPDATE festival SET title = '2025년 하반기 소래역사관 기획전시 <좁은 선로, 넓은 이야기>', content = '', place = '소래역사관' WHERE provider_type = 'PUBLIC' AND external_id = '380747';
UPDATE festival SET title = '2025 대전시립박물관 특별전 ''꿈생원의 육아일기''', content = '', place = '대전시립박물관' WHERE provider_type = 'PUBLIC' AND external_id = '345840';
UPDATE festival SET title = '종로구립 박노수미술관 개관12주년 기념전시 「산수·격물」', content = '', place = '종로구립 박노수미술관' WHERE provider_type = 'PUBLIC' AND external_id = '366683';
UPDATE festival SET title = '미디어·아트 융합 전시 DREAM LIGHT', content = '', place = '수원시미디어센터' WHERE provider_type = 'PUBLIC' AND external_id = '345071';
UPDATE festival SET title = '[부산] 뮤지컬 <위키드> 내한공연', content = '', place = '드림씨어터 [부산]' WHERE provider_type = 'PUBLIC' AND external_id = '350230';
UPDATE festival SET title = '국립나주박물관 특별전 ''흙으로 만든 널, 고요한 위엄''', content = '', place = '국립나주박물관' WHERE provider_type = 'PUBLIC' AND external_id = '347141';
UPDATE festival SET title = '[용인] 뮤지컬 <꿀벌 마야의 모험>', content = '', place = '디아나아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '349644';
UPDATE festival SET title = '[대전] 공포스릴러연극 <시그널>', content = '', place = '아신극장 2관 (2층)' WHERE provider_type = 'PUBLIC' AND external_id = '380140';
UPDATE festival SET title = '김포국제조각공원 야외조각전시 <조각아회 彫刻雅會>', content = '', place = '김포문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '356905';
UPDATE festival SET title = '<울트라백화점 서울> 소비의 끝에서 만나는 가치', content = '', place = 'DDP 동대문디자인플라자' WHERE provider_type = 'PUBLIC' AND external_id = '344606';
UPDATE festival SET title = '2025 영종하늘도시 <밤하늘 빛담길 산책>', content = '', place = '영종하늘체육공원 입구 (만국기 거리)' WHERE provider_type = 'PUBLIC' AND external_id = '359654';
UPDATE festival SET title = '뮤지컬 <렌트>', content = '', place = '코엑스아티움(Coex Artium)' WHERE provider_type = 'PUBLIC' AND external_id = '349339';
UPDATE festival SET title = '뮤지컬 <테이크 오프>', content = '', place = '후암스테이지' WHERE provider_type = 'PUBLIC' AND external_id = '352405';
UPDATE festival SET title = '서울생활관박물관 기획전시 <아가 마중>', content = '', place = '서울생활사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '357309';
UPDATE festival SET title = '뮤지컬 <앤ANNE>', content = '', place = '대학로 자유극장 (자유문화발전소)' WHERE provider_type = 'PUBLIC' AND external_id = '351602';
UPDATE festival SET title = '제5회 한글실험프로젝트 <글(자)감(각): 쓰기와 도구>', content = '', place = '문화역 서울 284 RTO' WHERE provider_type = 'PUBLIC' AND external_id = '359399';
UPDATE festival SET title = '<푸룻푸룻프렌즈 : 빠씨를 찾아서> 어린이 체험전', content = '', place = '아난티 힐튼 호텔 [부산]' WHERE provider_type = 'PUBLIC' AND external_id = '355564';
UPDATE festival SET title = '2025 기획특별전 <바다의 꽃, 게 섰거라>', content = '', place = '인천광역시립박물관' WHERE provider_type = 'PUBLIC' AND external_id = '360045';
UPDATE festival SET title = '국립춘천박물관 브랜드2 ''강원의 불교미술, 깨달음을 찾는 길''', content = '', place = '국립춘천박물관' WHERE provider_type = 'PUBLIC' AND external_id = '359174';
UPDATE festival SET title = '2025 기획특별전 <空과 時, 그 안의 人> ', content = '', place = '성북선잠박물관' WHERE provider_type = 'PUBLIC' AND external_id = '359339';
UPDATE festival SET title = '2025 영종역사관 특별기획전 <영종진:永宗, 그 시작>', content = '', place = '영종역사관' WHERE provider_type = 'PUBLIC' AND external_id = '360049';
UPDATE festival SET title = '<물 위의 세계>', content = '', place = '김포아트빌리지 아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '360026';
UPDATE festival SET title = '뮤지컬 <로빈>', content = '', place = '티오엠씨어터(구. 문화공간필링) 1관' WHERE provider_type = 'PUBLIC' AND external_id = '354358';
UPDATE festival SET title = '배수영 개인전 <The Heart of Light>', content = '', place = '현대백화점 무역센터점' WHERE provider_type = 'PUBLIC' AND external_id = '359207';
UPDATE festival SET title = '[대학로] 로맨틱 뮤지컬 <투모로우 모닝>', content = '', place = '큐씨어터(구. 수상한흥신소전용관)' WHERE provider_type = 'PUBLIC' AND external_id = '358616';
UPDATE festival SET title = '[서울] 뮤지컬 <팬레터> 10주년 기념 공연', content = '', place = '예술의전당 [서울] CJ 토월극장' WHERE provider_type = 'PUBLIC' AND external_id = '354921';
UPDATE festival SET title = '연말 선물전 <To : You>', content = '', place = '헤드비갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '361854';
UPDATE festival SET title = '지역예술도약 <2025 ARKO LEAP> 통합 전시  ', content = '', place = '금호미술관' WHERE provider_type = 'PUBLIC' AND external_id = '362571';
UPDATE festival SET title = '기증유물특별전 <한글편지, 문안 아뢰옵고>', content = '', place = '서울역사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '362536';
UPDATE festival SET title = '2025 무계원 협력전시 <아주 보통의 하루>', content = '', place = '무계원' WHERE provider_type = 'PUBLIC' AND external_id = '366687';
UPDATE festival SET title = 'DDP 청년 창작자 그룹전시 <Next Hi Light> 展', content = '', place = '동대문디자인플라자(DDP) 살림터 2층 크레아' WHERE provider_type = 'PUBLIC' AND external_id = '362567';
UPDATE festival SET title = '[서울 강남] 장화 신은 고양이 비긴즈: 플레이 버전 ', content = '', place = 'KT&G 상상마당 대치아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '357993';
UPDATE festival SET title = '서대문형무소역사관 특별전 ''옥사에서 보는 일제강점기 독립운동''', content = '', place = '서대문형무소역사관' WHERE provider_type = 'PUBLIC' AND external_id = '363477';
UPDATE festival SET title = '2025 펄벅국제심포지엄 성과전 <펄 벅의 인연, 하나가 되다>展', content = '', place = '펄벅기념관' WHERE provider_type = 'PUBLIC' AND external_id = '362876';
UPDATE festival SET title = '2025 아뜰리에 광화 겨울 전시 <영원>', content = '', place = '세종문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '363991';
UPDATE festival SET title = '오이 나는 왜 하필 오이로 태어났을까? <스토리씽킹연구소>', content = '', place = '애니메이션박물관' WHERE provider_type = 'PUBLIC' AND external_id = '364000';
UPDATE festival SET title = '[대학로] 뮤지컬 <판>', content = '', place = '동덕여대공연예술센터 코튼홀' WHERE provider_type = 'PUBLIC' AND external_id = '358696';
UPDATE festival SET title = '가족뮤지컬 <넘버블록스> - 앵콜', content = '', place = '능동 어린이회관 티켓링크 1975 씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '362537';
UPDATE festival SET title = '[서울 송파] 영화 음악 오케스트라 콘서트 with 지브리 & 디즈니', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '362698';
UPDATE festival SET title = '한국영상자료원 영화상영 <내 말 좀 들어줘>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365370';
UPDATE festival SET title = '지브리&디즈니 영화음악 FESTA (26.01.03)', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '361080';
UPDATE festival SET title = '[평택] 어린이 뮤지컬 <렛잇고>', content = '', place = '평택남부문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '362327';
UPDATE festival SET title = '뮤지컬 <푸른 사자 와니니>', content = '', place = '노원문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '358105';
UPDATE festival SET title = '한국영상자료원 영화상영 <대통령의 케이크>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365360';
UPDATE festival SET title = '진채Society-우린 말이야', content = '<!-- wp:paragraph -->
<p>진채 전성기는 2026년 《진채 Society – 우린 말이야》에서 훨훨 날아간다. 매년 새해를 환대하며 열었던 기성화된 세화전의 전시 패턴을 뒤로 하고, 완전히 새로운 전시 형태를 구상했기 때문이다. 진채연구소는 10년 넘게 한국의 전통 진채를 현대화하기 위해 밑 작업을 충실히 해왔다. 그 일환으로 2016년부터 작년까지 10년 동안 매년 백여 명에 이르는 작가들이 세화전을 준비하기 위해 몇 개월의 공들임을 기꺼이 바쳤다. 하지만 ‘21세기 진채화’는 동물에 빗댄 기복적인 컨셉의 ‘진채-세화’를 넘어서야 한다는 창발적인 외침을 외면할 수 없었다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>   2026년 《진채 Society – 우린 말이야》는 진채연구소의 작가들이 자신의 작품 컨셉과 양식에 따라 자체적으로 10개의 소그룹과 개인 작가들로 구성되었다. 진채연구소의 벽면에 누군가 최초로 자신의 아이디어를 구체화하기 위해 벽보를 붙였을 것이고, 그에 동조하는 팀원들이 하나둘씩 응집하며 의기투합했다. 또한 독자적인 개성의 솔로 작업도 왕성하게 진척되었다. 미술사적으로 이것은 매우 의미가 깊다. 많은 사람들이 미켈란젤로가 그린 로마 바티칸의 시스티나 성당 천장화를 보았을 것이다. 그러나 실제로 르네상스 때까지도 작가는 자신의 창의성보다는 종교나 정치 같은 거창한 대의를 위해 움직였다. 모네가 인상주의의 대표주자로 각인된 것은 미켈란젤로의 대의가 아닌 자신의 창의적인 아이디어의 발현이었기 때문이다. 19세기 중반 이후, 서양의 작가들은 개개인의 컨셉에 맞는 작업세계를 구축하기 위해 급속도로 분파되어 나갔고 다채로운 미술사조를 양산했다. 이와 마찬가지로, 이번 《진채 Society – 우린 말이야》 전시는 급변하는 현대 진채화의 추세를 이끄는 징후로 파악된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>  이제 이번 전시의 분파 그룹을 가나다 순으로 소개해보겠다. 1. <벽사진채; 辟邪眞彩>는 9세기 신라 헌강왕 때 동해 용왕의 아들이 인간화되어 역신을 물리쳤다는 처용(處容)의 치유 능력과 풍류를 차용했다. 2. <사유의 여정>은 나를 찾아가는 내적 울림을 상징적으로 담아냈다. 3. <숲, 속으로: Forest, deep inside>는 진채입문 1년 차들이 모여 좋아하는 식물을 가까이 두는 방식을 탐험했다. 4. <실크로드: 비단 위의 일곱 여정>은 진채가 고급 비단 위에 그리기 때문에 ‘실크=비단’이라는 등식을 재밌게 실크로드로 풀어냈다. 5. <오방신수호도(五方神守護圖): 하늘·땅·물·불·마음>은 각각 북·서·동·남·중앙=현무·백호·청룡·주작:목어로 대응시켜 전통의 복을 다시 한번 불러냈다. 6. <책가도, 예술가의 브랜딩>은 9명의 작가들이 직사각형의 대형 책가도를 한 구획씩 맡아 자기만의 가상세계를 정열적으로 붉게 채색했다. 7. <판타지 실록>은 불가능의 판타지 공간을 유유자적하는 유니콘들과 용, 호랑이 도령, 꽃과 합체된 물고기들, 그리고 추상화로 채색된 말이 연대기로 등장했다. 8. <환상동화>는 2026년 말의 해를 기대하며 두려움 없이 환상세계를 여행하는 염원이 담긴 ‘작은 세화전’을 펼쳐주었다. 9. <Silk Blossom (실크 블라썸): 실크 위에 피어난 꽃>은 진채화의 진수로 피어난 화려한 꽃들을 섬세하게 표현했다. 10. <The Art of Luxury>는 진채화의 고급진 정성을 명품 탄생의 과정에 빗대어 명품 진채화를 표방했다. 이외에도 50여 명의 개별 작가들도 다양성을 뿜어냈다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>  《진채 Society – 우린 말이야》에 참여한 열 개의 진채 창작 분파 그룹과 50여 명의 개인 작가들은 작품의 주제도, 양식도, 디피도 자신들만의 이야기로 채우고 있다. 이번 전시가 21세기 진채화가 자유롭게 분파되는 태풍의 눈이자 뜨거운 감자로 감지되길 바란다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>미술비평가 反我 김정현</p>
<!-- /wp:paragraph -->', place = '갤러리 그림손' WHERE provider_type = 'PUBLIC' AND external_id = '364697';
UPDATE festival SET title = '[서울 중구] 가족발레 <댄싱뮤지엄> ', content = '', place = '한국콘텐츠진흥원 CKL스테이지' WHERE provider_type = 'PUBLIC' AND external_id = '361713';
UPDATE festival SET title = '이머시브씨어터 <럭키! 전당포>', content = '', place = '레온갤러리 구의 플레이스라운드' WHERE provider_type = 'PUBLIC' AND external_id = '362211';
UPDATE festival SET title = '2026 뮤지컬 <100층짜리 집>', content = '', place = '성균관대학교 새천년홀' WHERE provider_type = 'PUBLIC' AND external_id = '365956';
UPDATE festival SET title = '[원주] 국립청년극단 <미녀와 야수> ', content = '', place = '원주치악예술관' WHERE provider_type = 'PUBLIC' AND external_id = '362692';
UPDATE festival SET title = '시그니처 대전 연극 <검은 얼룩>', content = '', place = '대전예술의전당 앙상블홀' WHERE provider_type = 'PUBLIC' AND external_id = '362051';
UPDATE festival SET title = '[광주 광산] 오브제 음악극 <동물농장> ', content = '', place = '광산문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '364179';
UPDATE festival SET title = '1월, 월간연주자 한연숙 & 서범수 & 장종선 & 이선호', content = '', place = '갤러리 디 아르테 청담' WHERE provider_type = 'PUBLIC' AND external_id = '364680';
UPDATE festival SET title = '[서울] 춤추는 발레 FESTA: 백조의호수 & 호두까기인형 ', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '362285';
UPDATE festival SET title = '[부산] 낙동의 첫울림: 낙동강 팡파레 & 말러 교향곡 8번 ', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '363611';
UPDATE festival SET title = '뮤지컬 <밤이 되었습니다, 물고기는 고개를 들어주세요> ', content = '', place = '신촌문화발전소' WHERE provider_type = 'PUBLIC' AND external_id = '361334';
UPDATE festival SET title = '피아니스트 정용환 & 임재한 듀오 리사이틀', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '364106';
UPDATE festival SET title = '[원주] 창작연희극 <젊은 어멍 먹은 늙은 딸년> ', content = '', place = '원주치악예술관' WHERE provider_type = 'PUBLIC' AND external_id = '364806';
UPDATE festival SET title = '[화성] 정명훈 & KBS교향악단 연주회 (협연: 레오니다스 카바코스)', content = '', place = '화성예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '362917';
UPDATE festival SET title = '[인천] 가족 매직컬 <마술고양이>', content = '', place = '청라복합문화센터 블루노바홀 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '363080';
UPDATE festival SET title = '[고양] 춤추는 발레 FESTA: 백조의호수 & 호두까기인형 ', content = '', place = '고양아람누리 아람음악당' WHERE provider_type = 'PUBLIC' AND external_id = '363207';
UPDATE festival SET title = '콘사노 체임버오케스트라 신년음악회: Romantic d''amor', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '363060';
UPDATE festival SET title = '[부천] 어린이뮤지컬 <렛잇고>', content = '', place = '복사골문화센터 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '363179';
UPDATE festival SET title = '[원주 갤러리 원] 민정 개인전 ''빛이 머물렀던 자리''', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '366076';
UPDATE festival SET title = '2026 KNUANI 한국예술종합학교 영상원 애니메이션과 정기·졸업작품 전시·상영회', content = '', place = '한국예술종합학교' WHERE provider_type = 'PUBLIC' AND external_id = '365355';
UPDATE festival SET title = '더클랑 신년음악회, 파리의 선율 : 사라사테 & 비제 그리고 베토벤 황제', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '363250';
UPDATE festival SET title = '2026년 사당솔밭도서관 겨울 독서교실 <솔밭 어린이 의원단>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365875';
UPDATE festival SET title = '카운터테너 정민호: 고음악살롱 Renaissance & Baroque Music', content = '', place = '아트센터 림 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '365059';
UPDATE festival SET title = '<천년을 흘러온 시간> 연계 특별강연', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '364841';
UPDATE festival SET title = '울산도서관 영화상영 <인사이드 아웃>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365422';
UPDATE festival SET title = '김성복 <그리움의 그림자>', content = '', place = '노화랑' WHERE provider_type = 'PUBLIC' AND external_id = '365400';
UPDATE festival SET title = 'Message of History Heaven’s echo SEOUL', content = '', place = '킨텍스 제1전시장' WHERE provider_type = 'PUBLIC' AND external_id = '363809';
UPDATE festival SET title = '[인천] 최고다 호기심딱지 시즌3 <동화나라 구출 대작전>', content = '', place = '계양문화회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '363701';
UPDATE festival SET title = '[광주] 어린이 뮤지컬 <렛잇고>', content = '', place = '518기념문화센터 민주홀' WHERE provider_type = 'PUBLIC' AND external_id = '363727';
UPDATE festival SET title = '똥볶이 할멈: 정의의 맛', content = '', place = 'KT&G 상상마당 대치아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '363668';
UPDATE festival SET title = '제30회 MERRY 정기연주회, BEYOND: 클래식 & 영화음악 콘서트', content = '', place = 'KBS홀 [별관]' WHERE provider_type = 'PUBLIC' AND external_id = '363716';
UPDATE festival SET title = '연극 <초속 5cm>', content = '', place = '씨어터조이 (구. 마당세실극장)' WHERE provider_type = 'PUBLIC' AND external_id = '364544';
UPDATE festival SET title = '[화성] 임용훈 & Sambistas: 브라질 비트로 재탄생한 팝히트 ', content = '', place = '인스파이어 컬쳐홀' WHERE provider_type = 'PUBLIC' AND external_id = '364438';
UPDATE festival SET title = '피아니스트 김보라 & 노민영 듀오 연주회 앙상블의 미학Ⅰ', content = '', place = '일신홀' WHERE provider_type = 'PUBLIC' AND external_id = '361573';
UPDATE festival SET title = '북콘서트 <책, 몸으로 읽다 – 정경린 장편소설 「자기만의 집」>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365953';
UPDATE festival SET title = '2026 무계원 <아주 보통의 하루> 전시 연계 공예체험', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366682';
UPDATE festival SET title = '[성남] 지브리 & 디즈니 영화음악 FESTA ', content = '', place = '성남아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '363784';
UPDATE festival SET title = '제10회 모자이크 페스티벌: NO LIMIT, 독거 청년들! <빛(취)되자!>', content = '', place = '연희예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '364072';
UPDATE festival SET title = '[대학로극장 쿼드] 2026 기획공연 <땅 밑에>', content = '', place = '서울문화재단 대학로센터 대학로극장 쿼드' WHERE provider_type = 'PUBLIC' AND external_id = '361547';
UPDATE festival SET title = '[성남] Harmony: Violin & Piano Duo Recital ', content = '', place = '티엘아이(TLI) 아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '365806';
UPDATE festival SET title = '뮤지컬 <초록>', content = '', place = '대학로 드림아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '363952';
UPDATE festival SET title = '겨울방학 초등 교육프로그램 ''교실 밖 인천탐험''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '363399';
UPDATE festival SET title = '제8회 소설시장 페스티벌 : 2방인 - L’E-duo-ranger', content = '', place = '소극장 혜화당(구. 까망소극장)' WHERE provider_type = 'PUBLIC' AND external_id = '363962';
UPDATE festival SET title = '유선태 초대전  ''My Garden, My Artelier''', content = '<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17325,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/02/2026유선태-포스터3-1.jpg" alt="" class="wp-image-17325" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":17326,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/02/2026-유선태-개인전-포스터1.jpg" alt="" class="wp-image-17326" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>유선태 초대전 </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>''My Garden, My Artelier''</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-DDCCAECD-9B79-45A1-9144-1A1A6D4EB6E3">1월 28일(수)~3월 7일(토)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-75107697-DDD1-4F56-8BDE-211CCF641B9F">II 관 : 갤러리가이아 부산</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-3F2E2114-A9AF-4695-8D32-6A21B5F5181F">T. 051-627-3373</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-B7C48361-86DE-4A5E-ADC0-E1803B140DD8">(부산시 남구 대연동 16 2F)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-57E6877A-A6C3-437F-BA99-5DADEDC96B6D">관람시간 : 화~토 11am~4pm(공휴일 예약관람)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-B6218FB5-7C38-4D41-8791-C08E950774CA">​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-DE199001-D1F3-4EBB-AB9C-B5ED00287F7D">3월 17일(수)~5월 30일(토)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-C29CC3EA-8FEB-4FAD-A653-C04004E2BA24">I 관 : 갤러리가이아 서울</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-57CA2C60-87B6-43E2-94A7-EFF4D5131503">T. 02-733-3373</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-38EE2226-51FC-42D4-ACB0-26CA5E571284">(서울시 강남구 청담동 80-5 1F)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-B51E0E12-F575-48A0-AFAB-A9B1C1A876EB">관람시간 : 화~토 11am~6pm(공휴일 예약관람)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-0A5F8A21-8D51-4DC3-9F0E-8B5F8E86146D">​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-C30D9AB0-0314-4A20-9BC8-1B6AC530AAA8"><작가 소개 및 작품 설명></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-6F623B49-E212-4A7C-AAB5-CE3A5D746858">​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-E7AF25DE-0339-4519-A90D-F7B672D4B9A6">유선태 작가님은 홍익대학교와 동대학원, 파리국립미술대학교에서 수학한 후 파리8대학에서 박사 학위를 받은 후에 서울, 파리, 뉴욕, 벨기에, 스페인 등에서 다수의 개인전을 개최했습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-CB78BC69-2251-46F7-AB18-D5BD27828B57">아크릴이라는 서양화의 재료에 동양화의 준법을 활용한 서정적 초현실주의로 주목을 받고있습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-33450F1C-A2EA-4DCB-896F-3DFAFE699EA9">입체와 평면을 넘나들며 작업하는 작가는 자신의 작품을 ''오브제의 숲''이라고 표현할만큼 많은 일상의 친숙한 사물들로 안과 밖, 현실과 환상을 초월한 공간 안에서 신비로운 화면을 연출합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-AAC2792D-033E-4977-B475-A8D22AD18E39">​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-67809C1B-271B-45B4-90DD-1F9A83CF2B54">유선태 작가의 그림에는 사물들을 낯선 관계 속에 놓는 ''데페이스망(dépaysement)'' 즉, 일상의 오브제들을 그 쓰임과 다르게 그려내거나 배치함으로써 보는 이로 하여금 낯설게 느껴지도록 하는 기법이 활용되었습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-78BA7D63-DCEB-4D5C-A6B2-5634C9414574">작가는 초현실적인 3차원의 공간에 다양한 오브제들을 재구성함으로써 새로운 인식의 전환과 즐거운 상상을 가능하게 합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-33CDE961-3821-429D-8A8B-322CE08C83C6">각각의 사물을 정의하는 단어는 하나로 부족하다고 말하는 작가는 자신의 작업을 통해 다양한 의미를 부여하고 신비로운 가상세계를 그림을 통해 구현하고 있습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '갤러리 가이아' WHERE provider_type = 'PUBLIC' AND external_id = '368318';
UPDATE festival SET title = '울산도서관 영화상영 <라푼젤>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365402';
UPDATE festival SET title = '[부산 강서] 연극 <리어왕> ', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '364099';
UPDATE festival SET title = '제25회 하정웅청년작가초대전 《빛 2025》<작가와의 대화>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366074';
UPDATE festival SET title = '한국영상자료원 영화상영 <8일째 매미>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366591';
UPDATE festival SET title = '김효영 <김효영의 생황 <숨x굿>>- 2025 창작산실 올해의신작 전통예술', content = '생황의 숨결에서 시작된 이야기 소리와 몸, 빛이 공명하는 숨의 여정', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '362128';
UPDATE festival SET title = '연극 <만선>', content = '', place = '성수아트홀(성수문화복지회관)' WHERE provider_type = 'PUBLIC' AND external_id = '364445';
UPDATE festival SET title = '[인천] 지브리 & 디즈니 영화음악 FESTA ', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '364202';
UPDATE festival SET title = '[부산] 낭만주의 거장, 차이코프스키 & 라흐마니노프 & 신세계로부터 ', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '364944';
UPDATE festival SET title = '[인천] MelON 지브리 & 뮤지컬 갈라 오케스트라 콘서트', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '364241';
UPDATE festival SET title = '제3회 위드어스필하모닉오케스트라 정기연주회: 신년음악회: Polka & Waltz', content = '', place = '인천문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '364409';
UPDATE festival SET title = '2026 국립경찰박물관 겨울방학 문화행사 ''온 가족이 함께하는 드로잉 서커스쇼''', content = '', place = '경찰박물관 4층 폴리스홀' WHERE provider_type = 'PUBLIC' AND external_id = '364875';
UPDATE festival SET title = '나를 위한 <포옹> 1회차', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366075';
UPDATE festival SET title = '[과천] 어린이뮤지컬 <렛잇고>', content = '', place = '과천시민회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '364214';
UPDATE festival SET title = '[원주 갤러리 원] 손병순 초대개인전 ''민들레~봄을 만나러 가다''', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '367280';
UPDATE festival SET title = '코멜리 앙상블 콘서트, Brahms & Dvorak: 낭만의 대화', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '365786';
UPDATE festival SET title = '[서울 서초] 정명훈 & 드레스덴 슈타츠카펠레', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '365054';
UPDATE festival SET title = '2026 이여몽 <STORY>', content = '', place = '갤러리 제이원 서울' WHERE provider_type = 'PUBLIC' AND external_id = '389359';
UPDATE festival SET title = '[수원] 연극 <만선> ', content = '', place = '경기아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '365528';
UPDATE festival SET title = '바이올리니스트 조최현 & 피아니스트 공원경 듀오 리사이틀', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '364518';
UPDATE festival SET title = '한국영상자료원 영화상영 <거미집의 성>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366570';
UPDATE festival SET title = '대전광역시 서예진흥원 <2026 서예교육 전문인력 양성과정>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365703';
UPDATE festival SET title = '애프터 아워즈 - 선(善)넘는 자연', content = '우리는 오랫동안 자연을 ''선하다''고 믿어왔습니다.생명을 품고, 계절을 순환하며, 인간에게 쉼과 양식을 베푸는 존재. 그러나 이 믿음은 너무도 인간 중심적인 시선에 머물러 있었습니다. 현대 문명은 자연을 길들이고, 예측하고, 제어할 수 있다고 믿었습니다. 우리가 만든 댐은 강을 가두었고, 도시의 빛은 별의 질서를 잊게 했으며, 우리는 경작과 개발이라는 이름으로 땅을 파헤치고 나무를 베었습니다. 그 과정에서 자연은 침묵했습니다. 아니, 그렇게 믿었습니다. 그러나 지금 자연은 응답하고 있습니다. 뜨거운 지구, 사라지는 종, 들끓는 대기, 역습하는 바이러스. 우리는 그 응답 앞에서야 자연이 선도 악도 아닌, 그저 본래의 질서를 가진 존재임을 마주하게 됩니다. 인간이 만들어놓은 도덕과 이분법을 초월한, 예측 불가하고 자율적인 생명체로서의 자연. 이번 작업에서는 인간과 자연 사이의 뒤틀린 관계를 다시 바라보고자 했습니다. 우리가 무너뜨린 균형, 우리가 가려 했던 질서, 그리고 자연이 말없이 감내해 온 시간들. 작업 속에서 자연은 대상이 아니라, 존재 자체로서 등장합니다. 그리고 그 존재는, 때로는 조용히, 때로는 격렬하게, 인간에게 다시 묻습니다. “당신은 나를 보호하려 하나, 결국 누구로부터인가?” “당신이 말하는 ‘善’은 누구를 위한 것인가?” 이 전시는 자연을 다시 바라보는 시도입니다. 도덕적 기준 너머, 통제와 이용의 관점을 넘어, 자연을 하나의 주체로 마주하는 시선. 인간과 자연 사이의 감정, 충돌, 균열, 그리고 가능성에 대한 시각적 탐구입니다.  善넘는 자연 — 그것은 인간의 착각을 벗어던지고, 공존의 새로운 감각을 모색하는 예술적 실험입니다. 배정혜, Sapporo, 65.2x91.0cm, mixed media, 2025  안은진, Re:start, 117.0x91.0cm, acrylic on canvas, 2025 오계숙, 물결2, 72.7x72.7cm, acrylic on canvas, 2025  이경미, 가득찬 달, 53.0x40.9cm, acrylic on canvas, 2024  이은영, 보이지 않는 진실, 97.0x145.5cm, acrylic on canvas, 2026  정수경, 스며들다/떠오르다, 60.0x160.0cm x2, acrylic on canvas, 2025 ', place = '예술의전당(한가람미술관 제3전시실)' WHERE provider_type = 'PUBLIC' AND external_id = '367689';
UPDATE festival SET title = '왕과 판자새', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '366626';
UPDATE festival SET title = '제10회 모자이크 페스티벌: NO LIMIT, 이비상협동조합 <부패한 젤리 한 스푼>', content = '', place = '연희예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '364790';
UPDATE festival SET title = '[의정부] 남상일 & 박애리 국악라이브 스테이지: 잔치 ', content = '', place = '의정부예술의전당 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '364908';
UPDATE festival SET title = '[서울남산국악당] 엄마아빠 행복 프로젝트 <우리가족 국악캠프>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365374';
UPDATE festival SET title = 'RE’PLAY', content = '', place = '씨어터조이 (구. 마당세실극장)' WHERE provider_type = 'PUBLIC' AND external_id = '365781';
UPDATE festival SET title = '[서울] 뽀로로와 신비한 여행 ', content = '', place = 'KT&G 상상마당 대치아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '364941';
UPDATE festival SET title = '[부산] 어린이 뮤지컬 <렛잇고>', content = '', place = '부산시민회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '364904';
UPDATE festival SET title = '[부산] 소울드아웃콘서트 2nd. SOUL’D OUT CONCERT ', content = '', place = '부산시민회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '365083';
UPDATE festival SET title = '서동진 & 선한국 콘서트: 무도회', content = '', place = '광운대학교 동해문화예술관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '365098';
UPDATE festival SET title = '信 Young Artist X K''ARTS Audition 수상자 리사이틀: 테너 박준형', content = '', place = '신영체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '365787';
UPDATE festival SET title = '피아니스트 신정희 & 송문희 듀오 리사이틀', content = '', place = '영산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '365678';
UPDATE festival SET title = '한국영상자료원 영화상영 <핫코다 산>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366593';
UPDATE festival SET title = '한국영상자료원 영화상영 <언더그라운드>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366594';
UPDATE festival SET title = '한국영상자료원 영화상영 <란>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366579';
UPDATE festival SET title = '한국영상자료원 영화상영 <하얀 거탑>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366580';
UPDATE festival SET title = '김란 <Throw back>', content = '', place = '노화랑' WHERE provider_type = 'PUBLIC' AND external_id = '368260';
UPDATE festival SET title = '백연 발레프로젝트와이＜MELTING＞- 2025 창작산실 올해의신작 무용', content = '“아름다운 녹아내림 이면의 아우성 소리”', place = '대학로예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '362099';
UPDATE festival SET title = '김현정글로리아 & 진강우 피아노 듀오 리사이틀: Sweet Story', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '365583';
UPDATE festival SET title = '한국영상자료원 영화상영 <클라우드>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366581';
UPDATE festival SET title = '뮤지컬 <쉐도우> 213 My Birthday 콘서트', content = '', place = '무신사 개러지(구. 왓챠홀)' WHERE provider_type = 'PUBLIC' AND external_id = '365580';
UPDATE festival SET title = '국립무용단 <2026 축제>', content = '국립무용단이 2026년 병오년 새해의 문을 활짝연다.전통의 멋과 흥을 온몸으로 느낄 수 있는 특별한 무대를 만나는 시간!', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '362179';
UPDATE festival SET title = '[안산] 어린이 뮤지컬 <렛잇고>', content = '', place = '안산문화예술의전당 달맞이극장' WHERE provider_type = 'PUBLIC' AND external_id = '365568';
UPDATE festival SET title = '뮤지컬 <코코몽>', content = '', place = '상상나라극장' WHERE provider_type = 'PUBLIC' AND external_id = '367783';
UPDATE festival SET title = '문래재즈IN, 발렌타인데이 특집콘서트: 윤성희 트리오 & 현용선', content = '', place = '문래재즈IN' WHERE provider_type = 'PUBLIC' AND external_id = '366229';
UPDATE festival SET title = '[서울] 지브리 & 디즈니 영화음악 FESTA ', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '365584';
UPDATE festival SET title = '[세종] 하모니카 기타 듀오 김여레 & 앙투앙 보이여 Valetine Day Special Concert ', content = '', place = '재즈인연구소' WHERE provider_type = 'PUBLIC' AND external_id = '365598';
UPDATE festival SET title = '[고양] 제30회 MERRY 정기연주회, 심연: 파우스트 & 겨울왕국 콘서트', content = '', place = '고양아람누리 아람음악당' WHERE provider_type = 'PUBLIC' AND external_id = '365689';
UPDATE festival SET title = '잊음이 많은 머리를 비웃으며', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '368141';
UPDATE festival SET title = '[대학로극장 쿼드] 2026 기획공연 <함수 도미노>', content = '', place = '서울문화재단 대학로센터 대학로극장 쿼드' WHERE provider_type = 'PUBLIC' AND external_id = '361549';
UPDATE festival SET title = 'Eco d’Arte, 오페라 갈라콘서트', content = '', place = '구로아트밸리 예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '368604';
UPDATE festival SET title = 'In&Out', content = '<!-- wp:paragraph -->
<p>히든엠갤러리는 2026년의 첫 전시로 유수지, 이지선의 2인전 <In & Out>을 선보인다. 이번 전시는 집이라는 경험이 작품속에서 어떻게 안으로 스며들고, 다시 밖으로 향하는지를 두 작가의 서로 다른 시선을 통해 보여준다. 이 전시에서 집은 하나의 형태로 정의되지 않는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>집은 머무름과 이동이 겹쳐지는 공간이며, 외부와 내부의 감각이 맞닿는 자리이기도 하다. <In & Out>은 이러한 집의 성격에 주목한다. 두 작가에게 집은 특별한 사건의 무대라기보다, 감각이 가장 자연스럽게 풀어지고 작업이 시작되는 조건에 가깝다. 편안함 속에서 축적된 시간과 경험은 각자의 회화 안에서 서로 다른 방식으로 드러난다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>유수지작가의 작업에서 집은 외부 세계와 느슨하게 연결된 장소로 나타난다. 작가는 개인의 사적인 공간에서 출발하지만, 시선은 늘 바깥을 향해 열려 있다. 작가는 일상 속에서 스쳐 지나간 장면과 감정들을 일기처럼 기록하듯 화면에 옮기며, 흩어진 경험들을 하나의 리듬으로 엮어낸다. 이러한 구성은 서로를 잇고 잊어내는 과정을 반복하는 작가의 태도를 반영한다. 집은 이 과정의 중심에 놓인 배경이자, 세계와 다시 관계 맺기 위한 중간 지점으로 작동한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이지선작가의 작품 속 집은 보다 내밀한 방향으로 다가온다. 외부로 나아가기보다는, 오래 머물러온 감각과 기억의 층위를 천천히 더듬는다. 집은 작가에게 가장 편안한 장소로서, 말로 설명되지 않는 감정과 시간의 흔적이 고요하게 쌓여 있는 공간이다. 반복되는 붓질과 절제된 구성은 이러한 축적의 시간을 따라가며, 집이라는 장소가 지닌 정서적 깊이를 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시에서 특히 주목할 부분은 두 작가가 하나의 개념을 공유하며 작업을 전개했다는 점이다. 각자의 해석을 담아 독립된 작업으로 존재하면서도, 서로 기대어 서 있는 하나의 장면처럼 구성된다. 집의 형태를 연상시키는 방향성과 지붕을 닮은 윤곽을 떠올리게 하는 전시구성은, 머무는 곳과 나서는 곳, 안과 밖이 맞닿는 감각을 공간 안에서 자연스럽게 드러낸다. 작품들은 개별적인 감상에 머무르기보다, 전시의 동선과 흐름 속에서 서로 연결되며 ‘집’이라는 경험을 시각적으로 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 2인전은 집이라는 공통된 주제를 통해, 서로 다른 감각과 시선을 지닌 두 작가의 작업이 하나의 흐름 안에서 만나는 지점을 보여준다. 작품들은 개별적인 회화로 존재하면서도, 전시의 구성 속에서 서로 관계를 맺으며 읽힌다. 이번 전시를 통해 집을 하나의 고정된 이미지가 아닌, 머무름과 이동, 안과 밖의 감각이 겹쳐지는 경험으로 제안한다. 관객 또한 작품 사이를 오가며, 집이라는 경험이 지닌 다양한 결을 전시의 흐름 속에서 마주하게 된다.</p>
<!-- /wp:paragraph -->', place = '히든엠갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '369346';
UPDATE festival SET title = '지브리 & 디즈니 OST 콘서트', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '366240';
UPDATE festival SET title = '[원주 갤러리 원] 강화덕 초대개인전 ''시간을 잇다''', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '369664';
UPDATE festival SET title = '[여주] 가족뮤지컬 <겨울이야기> ', content = '', place = '세종국악당' WHERE provider_type = 'PUBLIC' AND external_id = '366155';
UPDATE festival SET title = '[양주] 동화뮤지컬 원데이클래스 <반쪽이전>', content = '', place = '링크처치' WHERE provider_type = 'PUBLIC' AND external_id = '367808';
UPDATE festival SET title = '[대전 서구] 어린이 체험학습 뮤지컬 <틀려도 괜찮아> ', content = '', place = '대전평송청소년문화센터' WHERE provider_type = 'PUBLIC' AND external_id = '366191';
UPDATE festival SET title = '쌀롱드무지끄, L''Echo del Settecento', content = '', place = '쌀롱드무지끄' WHERE provider_type = 'PUBLIC' AND external_id = '367882';
UPDATE festival SET title = '민트페스타 vol.80', content = '', place = 'KT&G 상상마당 라이브홀 [마포]' WHERE provider_type = 'PUBLIC' AND external_id = '366333';
UPDATE festival SET title = '[용인] 지브리 & 디즈니 영화음악 FESTA ', content = '', place = '용인포은아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '366377';
UPDATE festival SET title = '[부산] 11시 브런치 콘서트, 카프리치오 & 랩소디', content = '', place = '금정문화회관 소공연장(은빛샘홀)' WHERE provider_type = 'PUBLIC' AND external_id = '366322';
UPDATE festival SET title = '김응수 & 카메라타 솔, 겹의 미학 시리즈 2: B', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '366454';
UPDATE festival SET title = '권기범 개인전 ''모호한 형상의 구축''', content = '<!-- wp:paragraph -->
<p id="SE-bd1534a5-d42f-41c8-be6a-894ded52bb5b">[권기범 개인전]</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-f11a19f1-d396-429a-894b-d00309507c8b"><strong>''모호한 형상의 구축 (Constructing Ambiguoud Forms)''</strong></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17370,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/02/2025-권기범-개인전-포스터-시안-2026-권기범-개인전-인스타-포스터@2x-100.jpg" alt="" class="wp-image-17370" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p id="SE-fe3b85da-9655-4e10-b45b-4f79c03cf896">​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-96248790-1814-49db-9c7e-c589987fbb1f">2026년 2월 24일(화)~3월 8일(일)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-c38931b5-630e-43d4-9811-34855772dc5e">I 관 : 갤러리가이아 서울</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-f3ae3124-f30b-48a4-aa24-0ddd37f9d9ea">T. 02-733-3373</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-95ee33df-358d-4fac-a7a0-1b4efd8fdd5a">(서울시 강남구 청담동 80-5 1F)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-ae4e1e89-f787-4b03-8fe6-9e35cd76b58a">관람시간 : 월~토 11am~6pm (일요일, 공휴일 예약관람)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-d62f3fed-df8f-49c0-a3f0-2ba57da723bd">[작가 설명]</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-0ec11378-8bca-4af8-ae77-658fb1bddc93"><strong>권기범 KWON KIBEOM</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-e324dc62-ad3e-434c-ab93-c71b99424da8">권기범은 한국의 시각 예술가이다. 그의 작품은 현대 미술의 다양한 실험적 스펙트럼을 가지고 있다. 섬세하고 감각적인 연필 그림, 역사적 공간의 실험적인 사진 작업, 대형 벽화 드로잉 설치물 등 그의 모든 작업들은 동시대 미술의 비규정성과 실험성에 초점이 맞추어져 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-7a82a988-90a6-4f60-acf9-7c205659884a">특히 작가는 최근 복잡하고 정교한 연필 드로잉 작업을 통해 형상과 의미의 모호성에 관심을 가지고 있다. 조합된 형상의 드로잉들은 존재의 모호함과 불확실성에 대해 관객에게 질문을 던진다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-3d14ba33-fcf5-4657-9cea-fda72ecea9be">작가는 과거의 기억 속에 존재했던 사물, 식물, 풍경과 인물의 파편들을 여러 가지 상상의 조합을 통해 규정지어지지 않는 낯선 형상들로 그려내고 있다. 이런 형상들은 조형의 해체와 결합을 통해 모호한 이미지를 만들어낸다. 그의 작업 속에는 꽃, 정물, 인간과 상징체 등 다양한 이미지가 존재한다. 하지만 자세히 살펴보면 그 이미지는 많은 선과 면들의 주관적 해석, 개인의 경험을 통해 사물을 인지하는 형상의 재현이 중요하다는 것을 깨닫게 된다. 작가는 기억 속 편린들을 지속적으로 묘사하지만 이들의 조합과 관계 속에서 또 다른 의미와 상징으로 존재하는 비규정성의 메시지를 암시한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-958d8e78-0121-4763-bf72-09e4d05a67a0">​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-83f1c43d-b598-4885-8371-5a73008cd2c3">Kwon Kibeom is a Korean visual artist whose practice spans diverse experimental approaches in contemporary art, ranging from delicate pencil drawings to photography in historical spaces and large-scale mural installations. Across media, his work consistently explores indeterminacy and the open-ended nature of artistic expression.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-0bac8f7b-c437-400c-877e-5e90199808c8">In recent years, he has focused on intricate pencil drawings that examine the ambiguity of form and meaning. Using fragments of objects, plants, landscapes, and human figures preserved in memory, he recombines them into unfamiliar composite forms that resist fixed definition, inviting reflection on uncertainty and unstable perception.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-5003b03e-3141-4c17-a336-df18f9202a21">Through deconstruction and recombination, images such as flowers, still lifes, figures, and symbolic forms emerge, yet the works emphasize subjective interpretation. Reassembled through lines and planes, remembered fragments form new relationships, producing shifting meanings and new symbols shaped by indeterminacy.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-2be70b7f-f2fc-401d-baad-473109be5616">​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-4fa1c9d8-2154-4fa7-b324-3fb93c0e4a58">​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-2c86021d-52e1-42c3-a140-4248d88a2090">​</p>
<!-- /wp:paragraph -->', place = '갤러리 가이아' WHERE provider_type = 'PUBLIC' AND external_id = '369345';
UPDATE festival SET title = '뮤지컬 <여명의 눈동자> ', content = '', place = 'Converse Stage Arena 여명' WHERE provider_type = 'PUBLIC' AND external_id = '369151';
UPDATE festival SET title = '박진우 & 이지영 듀오 리사이틀', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '366021';
UPDATE festival SET title = 'Résone Ensemble: American Composer Series', content = '', place = '꿈의숲아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '369452';
UPDATE festival SET title = '제2회 S&G 어린이무용단 정기발표회: 춤의 비상', content = '', place = '꿈의숲아트센터 퍼포먼스홀' WHERE provider_type = 'PUBLIC' AND external_id = '369549';
UPDATE festival SET title = '[대학로] 알앤제이 (R&J) ', content = '', place = '업스테이지(UP Stage)' WHERE provider_type = 'PUBLIC' AND external_id = '368002';
UPDATE festival SET title = '플루티스트 최용재 & 로익 슈나이더 듀오콘서트', content = '', place = '거암아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '367568';
UPDATE festival SET title = '[대학로] 맨 끝줄 소년 ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '368124';
UPDATE festival SET title = '연극 <나리>', content = '', place = '공간아울' WHERE provider_type = 'PUBLIC' AND external_id = '366817';
UPDATE festival SET title = '윤성진: 2면 / 2시점 2 Faces / 2 Visions', content = '<!-- wp:paragraph -->
<p><em>“조각의 ‘평면적 기억’, 회화의 ‘확장된 공간 기억’이 결합될 때, 미술 표현의 또 다른 가능성이 열린다.”</em> ㅡ윤성진, 작가노트 2025</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>오늘날 조각은 소재나 표현 기법에 있어서 회화, 설치미술, 퍼포먼스, 영상 등과 혼성적 양식으로 나타나고 이러한 타 장르와의 결합을 통해 공간과 개념을 확장하고 있다. 갤러리JJ는 조각가 윤성진의 개인전 <윤성진: 2면 2시점>을 마련하였다. 윤성진은 회화와 조각을 넘어선 공간을 모색하고 동시대 조각의 새로운 경험을 탐색한다. 작가는 전통 조각의 물성과 양감을 최소화하여 회화적 평면을 지향하는 역설적인 접근방식으로, 회화적 평면의 양면을 가지는 추상적 오브제인 ‘2면 조각 (2-face sculpture)’을 제시한다. 그것은 조각 구조에 회화적 경험을 결합하는 것으로 나타난다. 이번 전시는 작가가 파리에서의 오랜 생활을 마치고 서울로 돌아온 이후 지난 4년간의 작업들을 모아 최초로 선보이는 자리로, <접힌 사각형> 등 신작을 비롯하여 그의 작업의 대표적인 ‘2면 조각’들을 소개한다. 전시는 20여점의 공간에 세우는 스탠딩 작업과 벽면을 이용하는 벽 작업으로 구성된다. 이번 전시는 그 동안 그가 사유하고 구축해온 특유의 조형 방식과 관람객의 시지각적 경험을 기반으로 하는 작품세계의 독자성을 조명한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>윤성진의 추상조각은 기하학적 조형요소 및 서예에서 비롯된 원리와 조형적 감각을 바탕으로, 회화의 평면성과 조각의 구조가 만나는 지점을 탐구하며 현대조각의 경계를 확장해왔다. 회화와 표현의 경계가 맞물리는 조형 구조를 가진 그의 작업은 조각이 점유해 온 물리적 공간을 넘어 평면 내부에서 발생하는 공간적 긴장과 감각의 층위를 섬세하게 드러냄으로써 평면과 입체에 대한 질문을 던진다. 작가가 ‘회화적 조각’ 혹은 ‘2면 조각’이라 명명하는 작업은 기하학적 추상 구조를 기반으로 하며, 회화와 조각, 설치라는 장르의 경계를 오간다. 하나의 얇은 판 위에 서로 다른 두 회화적 면을 병치하는 방식은 평면과 입체 사이의 긴장을 형성하며, 관람자의 이동과 시선의 변화 속에서 작품이 점진적으로 완성되도록 유도한다. 이로써 작업은 앞과 뒤, 내부와 외부라는 이분법적 구분을 넘어, 두 면 사이에서 분위기가 교차하는 또 다른 감각적 공간을 생성한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>돌이켜보면, 과거에도 예술 형식들은 서로 완전히 닫혀지지 않았다. 오랜 서양 조각의 역사에서 조각은 건축, 회화와 분리되지 않고 상호 작용했으며, 르네상스 이후 이들은 독립하여 자율적 형식을 갖추게 되었고 시간이 지남에 따라 형식 간의 경쟁이 스스로에게 집중하고 강력한 방식임을 입증하는 식으로 진전되었을 뿐이다. 현대미술에 이르러 새로운 소재로 질량을 최소화하고 내외부를 연결하여 전통적 조각의 틀에서 벗어나고자 했던 나움 가보(Naum Gabo), 사진이라는 매체를 조각으로 끌어들여 조각의 커다란 화두인 평면과 입체에 대한 질문을 던지는 권오상 등 조각의 정체성은 끊임없이 도전 받아왔다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>지난 1990년대 초 작가는 과학의 발달로 인한 가치관의 변화와 혼돈의 시대를 표현하고 자연파괴와 인간성의 피폐함을 고발하는 등 표현성이 짙은 작업으로 잘 알려져 있다. 은빛 알루미늄판을 자르고 조합하는 등 1970년대 한국미술의 물성 탐구의 계보를 잇는 작업을 하였고, 그의 작업들은 국립현대미술관을 비롯하여 시립미술관 등 국내외 주요기관에 소장되어 있다. 주관적인 감성과 물성을 중시하는 표현주의적 작업은 어느덧 변화하여 현재의 균형과 이성 중심의 기하학적 추상 형태에 이르게 되었고, 이에 대한 궁금증을 불러일으킨다. 그것은 20여년 가까운 파리 생활에서 몸에 배인 문화적 분위기와 십자가 형태의 조형작업과의 연관관계, 러시아 구성주의를 비롯한 20세기 초 미술사를 숙고하여 차용하게 된 점, 그리고 무엇보다 작가 자신의 깊숙한 내부로부터 대면한 서예의 조형성에 대한 기억에서 그 이유를 찾을 수 있을 것 같다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>—</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>선, 면, 공간</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시장에 벽과 바닥에 설치된 기하학적 추상 오브제들은 선과 면이라는 조형의 기본 요소들이 평면의 내부는 물론 조각의 구조적 형태로서 연속적으로 펼쳐진다. 절제된 단순한 색채 사용은 형태의 구조적 특징을 강화한다. 작품들은 내부에 뚫린 구멍으로 인해 작품의 내부와 외부의 구별 없이 공간이 연결된 형태이거나 혹은 대부분이 서로 유기적으로 연결된 사각형이나 원들이 반복하고 증식하며 공간 속으로 확장되는 듯하다. 작품은 개별요소보다 전체의 구조적 맥락 속에서 파악된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>윤성진의 조형 세계를 내부적으로 들여다보면, 동양 전통의 수묵과 서예에서 비롯된 획의 조형적 감각과 선(linear)적 행위를 공간으로 끌어내며, 구조주의적 사고와 함께 현대미술사의 차용과 변용으로 과거 역사를 참조한다. 작가는 조각에서 ‘매스를 축소하려’고 지속적으로 고민해왔으며, 서예에서의 필묵과 여백이 만들어내는 내외부공간의 긴장 관계에 주목하여 조각적 구조로 확장한다. 즉, 획의 역동성은 평면에 머무르지 않고 그것이 가로지르는 공간을 점유하며, 작가는 이러한 붓과 종이 사이에서 발생하는 긴장감과 궤적을 실제 공간으로 가져와 공간 자체를 하나의 조각적 현실로 만든다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그것은 서양예술론에서, 조형예술의 근간을 이루며 조각과 회화, 건축을 아우르는 선묘(dessin)의 방식으로 곧 작업은 아이디어와 조형요소들을 공간으로 끌어당기는 ‘공간 드로잉’으로서 공간에서 확장 가능성을 내재하는 ‘열림’의 미학을 보여준다. 좀더 논리를 이어가면, 르네상스 시기 뵐플린(Heinrich Wölfflin)의 구분에 의하면 조각은 곧 선(linear)적인 것이었고, 드로잉의 의미로서의 ‘디세뇨(disegno)’가 강조했던 형이상학적 사고는 20세기초 조형구조를 이성과 질서로 조직하려는 러시아 구성주의 작가들에 의해 기하학적 추상 체계로 확장되었으며 이들은 다시 조각과 디자인, 건축을 통합하려 했다. 실지로 바우하우스를 시작으로 디자인은 기하학적 추상언어를 기능성과 시각 체계로 발전시켰다. 윤성진의 추상조각은 이러한 원리 위에서 작동하는 것으로 보인다. 작업 가운데 <말레비치에 대한 오마주>가 보인다. 전통과 현대를 아우르는 그의 작업 여정은 조화로운 정신의 조형적 원형, 보편성을 향한 과거 유토피아적 꿈의 또 다른 지평을 여는 일은 아닐까?</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>—</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>조각의 회화적 경험  </strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시의 작품들은 마치 바닥에 우뚝 서있는 회화, 벽에 모서리를 대고 직각으로 붙은 회화처럼 보이기도 한다. <식물로부터>, <달>, <여인들>처럼 재현적이고 서정적인 제목이 있는가 하며 <접힌 사각형>, <상자들>과 같이 시각적 착시를 유도하기도 한다. 작품들은 그 구조가 마치 하드엣지의 변형된 캔버스나 혹은 회화 지지체의 지표적 기호처럼 그리드를 이루기도 한다. 생각해보면, 평면을 연장하면 입체가 되지 않는가. 재료로 사용한 ‘코어합판’은 변형이 없고 가벼워서 물체의 질량을 최소화하면서 입체의 골격이자 그 표면을 회화의 지지체로 내주고 있다. 작가는 잔상이나 그림자와 같은 비물질적 요소를 생각하며 조각의 물성을 최대한 무화시킬 수 있는 방법으로 이 소재를 선택했다고 말한다. 이렇게 그가 조각의 물질성에 저항하면서 회화를 끌어들이며 얻는 것은 무엇일까? 그것은 동어반복일 수도 있지만 여러 면에서 생각해 볼 수가 있다. 비가시적인 또 다른 리얼리티의 공간을 찾는 조형적 실험, 회화의 프레임 바깥 공간을 드러내어 이차원 이미지 너머로 회화를 확장하거나 동시에 조각의 정체성에 대한 질문, 조각의 회화적 경험의 도입 등···.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시 제목이자 작품 제목인 ‘2면 2시점’에서 알 수 있듯이, 그의 작업은 회화적 시점을 조각 내에 도입함으로써, 다면적 시점으로 분산되는 전통적 조각의 불확실한 경험에서 벗어나 회화가 지닌 정면성의 단일하고 지속적 시점의 명료함을 조각 구조 안에서 구현하려고 한다. 과거에 회화는 원근법을 통해 3차원의 자연을 평면에 재현하면서 자연에 대한 지성의 우월함을 주장했고 3차원 입체로서의 조각은 재료의 물질성과 공간 점유, 연극성의 경험을 기반으로 하여 서로 경쟁적 관계를 맺기도 했다. 윤성진은 이러한 두 매체의 긴장 관계를 조형적으로 결합하며, 회화의 평면성과 조각의 공간성이 만나는 접점을 탐구한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그 결과, 조각의 표면이자 회화 평면은 반복되는 프레임의 경계를 넘어 실제 공간에서의 조각적 형태까지 회화로 끌어들임으로써, 조각이 오브제성을 넘어 회화적 인식 속에서 새로운 감각적 깊이를 얻게 하였다. 틀에 의해 전적으로 회화의 내부에 한정되었던 관조적 영역은 물리적 공간 속에서 관람자의 신체 이동과 시간적 경험 속에 놓인다. 이처럼 윤성진의 작업은 회화적 시점을 도입하여 조각적 구조에 회화의 경험을 유도하면서, 회화의 평면성과 조각의 입체성이라는 형식주의의 이분법적 구분을 가뿐히 넘어선다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>글│강주연 Gallery JJ Director</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>[작가소개]</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>윤성진 (b.1952)</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>윤성진은 서울대학교 조소과와 동대학원을 졸업한 후 1985년 첫 개인전을 시작으로 수많은 개인전과 국내외 그룹전에 꾸준히 참여하면서 독자적인 조형언어를 구축해왔다. 그의 작업은 초기의 감성과 물성을 강조한 표현주의적 작업을 거쳐 20여년간의 파리 생활 이후 현재의 균형과 이성 중심의 기하학적 추상조각에 이르렀다. 작품은 국립현대미술관과 시립미술관을 비롯해 국내외 주요 기관에 소장되어 있다. 윤성진은 기하학적 조형언어를 바탕으로 회화와 조각을 넘어선 공간을 모색하고 동시대 조각의 새로운 경험을 탐색한다. 그의 추상 오브제인 ‘2면 조각’은 조각적 구조에 회화의 경험을 유도하면서 조각과 회화, 설치라는 장르의 경계를 오가고 입체와 평면에 대한 질문을 던진다.</p>
<!-- /wp:paragraph -->', place = '갤러리JJ' WHERE provider_type = 'PUBLIC' AND external_id = '367819';
UPDATE festival SET title = '헐리우드 블록버스터 & 디즈니 픽사 영화음악 FESTA', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '366997';
UPDATE festival SET title = '권민세 & 박선율 피아노 듀오 리사이틀', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '366943';
UPDATE festival SET title = '[춘천] 춘천시립교향악단 & 청소년교향악단 특별연주회: The Cinema and Classic', content = '', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '366828';
UPDATE festival SET title = '잠비나이 ＜적벽＞- 2025 창작산실 올해의신작 전통예술', content = '“전장(戰場)의 풍광(風光) 그 자체를 음악으로 만든다면”', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '362100';
UPDATE festival SET title = '[대전] 백조의호수 & 호두까기인형 발레 FESTA ', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '367049';
UPDATE festival SET title = '[성남] 지브리 & 디즈니 OST 콘서트 ', content = '', place = '성남아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '366867';
UPDATE festival SET title = '지브리 & 디즈니 오케스트라 콘서트', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '366825';
UPDATE festival SET title = '[서울남산국악당] 국무 이용녀 만신 새해대운맞이 <진접굿>', content = '', place = '남산골한옥마을 서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '365669';
UPDATE festival SET title = '[의정부] 코믹 마술쇼 & 윈터 버블쇼 ', content = '', place = '우리소극장 [의정부]' WHERE provider_type = 'PUBLIC' AND external_id = '368119';
UPDATE festival SET title = '[양주] 그림책뮤지컬 원데이클래스 <곤충호텔> ', content = '', place = '링크처치' WHERE provider_type = 'PUBLIC' AND external_id = '367787';
UPDATE festival SET title = '제107주년 삼일절 기념행사 ''1919 서대문, 그날의 함성 축제''', content = '', place = '서대문독립공원, 서대문형무소역사관, 감리교신학대학교 웨슬리채플관' WHERE provider_type = 'PUBLIC' AND external_id = '369566';
UPDATE festival SET title = '2026년 3·1절 계기 체험프로그램 - 독립국을 선언하다', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '369873';
UPDATE festival SET title = '춤추는 발레 FESTA: 백조의호수 & 호두까기인형 ', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '366954';
UPDATE festival SET title = '[광주] 신데렐라 & 초대형레이져쇼 ', content = '', place = '518기념문화센터 민주홀' WHERE provider_type = 'PUBLIC' AND external_id = '366992';
UPDATE festival SET title = '에드 무지카 제17회 정기연주회 ''String Echoes 시간을 넘어선 울림의 여정''', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '365166';
UPDATE festival SET title = '바이올린 양도원 & 비올라 방소연 듀오 연주회', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '369132';
UPDATE festival SET title = '첼리스트 홍진호 <첼로 스케이프>', content = '', place = '세종문화회관 세종M씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '362511';
UPDATE festival SET title = 'a의 일기', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '368992';
UPDATE festival SET title = '뮤지엄 콘서트 Dance & Waltz: 세계의 춤, 하나의 무대', content = '', place = '국립중앙박물관 극장 용' WHERE provider_type = 'PUBLIC' AND external_id = '368403';
UPDATE festival SET title = '시선이 남기는 것들(After the Gaze)', content = '<!-- wp:paragraph -->
<p>박주원 개인전</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>《시선이 남기는 것들(After the gaze)》에서 풍경은 자연의 재현이 아니라, 관계가 남긴 흔적이다. 박주원은 판넬의 단단한 평면 위에 색을 구획하고, 대상을 명암으로 모델링하기보다 색면으로 쪼개 단순화한다. 화면은 평평하고 정제되어 보이지만, 그 안에서 여러 단위로 구조화되어 세부적으로 묘사되어 있다. 이 이질적인 결합은 그림을 풍경으로 읽게 하면서도, 그 풍경을 단순히 ‘자연’으로 고정시키지 않는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>대표작 <이처럼 무수한 것들>(2025)에서 가로로 길게 펼쳐진 화면은 얇은 나무들로 가득 차 있다. 나무들은 규칙적으로 배열된 듯 보이지만, 간격은 미묘하게 변주된다. 동일해 보이는 거리 속에서 생겨나는 작은 차이들이 시선을 붙들고, 관객은 눈으로 장면을 훑기보다 화면의 폭을 따라 이동하게 된다. 긴 수평 화면은 관람자를 숲 안으로 끌어들이며, 보는 자를 장면의 외부가 아니라 내부에 위치시킨다. 이 숲은 계절을 말하지 않고, 꽃이나 초원의 풍요도 없다. 절제된 화면 속 나무들의 반복은 자연의 생태라기보다, 일상을 살아가며 맺어온 관계들의 밀도를 떠올리게 한다. 나무 하나하나는 한 사람처럼 서 있고, 그 사이의 간격은 관계의 거리처럼 유지된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><돌이켜보면>(2025)은 이 숲의 시간을 다른 각도에서 되짚는다. 화면 중앙에 몰려 선 나무들은 끝까지 밀려난 듯 밀집해 있고, 그 주변을 둘러싼 얼음인지 돌인지 분간되지 않는 경직된 덩어리들은 공간을 차갑게 감싼다. 일부 나무는 꺾여 쓰러져 있지만, 그럼에도 줄기들은 화면 끝까지 뻗어 나간다. 제목이 암시하듯 ‘돌이켜본다’는 행위는 단순한 회상이 아니라, 관계 속에서 자신의 자리를 다시 확인하는 시선이다. 몰리고 흔들리고 꺾이면서도 서로의 존재를 배경 삼아 다시 서 있는 상태에서, 이 숲은 더 이상 자연이 아니라 관계가 만들어낸 구조에 가깝다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>박주원의 화면은 정적인 듯 보이지만 내부에서는 끊임없이 운동이 발생한다. 얼음 혹은 돌처럼 보이는 배경의 경직된 면들은 화면을 고정시키지만, 나무의 잔가지들이 만들어내는 미세한 떨림, 파란 반원의 경계, 그리고 흰색과 노란색의 대각선이 그 경직을 깨뜨린다. 직선과 곡선, 밀집과 여백, 정지와 흐름이 교차하면서 화면은 고정되지 않는다. 통상적으로 자연의 유기성과는 어긋나 보일 수 있는 세로선의 반복이 이 회화에서는 어색하지 않다. 박주원의 숲은 자연의 숲이 아니라, 시선이 남긴 관계의 배열이기 때문이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가에게 ‘시선’은 단순히 대상을 바라보는 행위가 아니라, 관계를 남기는 행위다. 우리는 수많은 타인을 바라보고 지나치지만, 그 시선 이후에 남는 것은 장면이 아니라 감각이다. 작가는 거리, 긴장, 밀집, 그리고 서로를 지탱하는 보이지 않는 연결망 등을 풍경의 형식으로 드러낸다. 관객은 숲을 감상하는 대신, 그 안에서 자신의 관계를 떠올리며 서게 된다. 그리고 화면 앞에서 문득 묻게 된다. 이것은 풍경인가, 아니면 내가 지나온 관계의 흔적인가.</p>
<!-- /wp:paragraph -->', place = '두루아트스페이스' WHERE provider_type = 'PUBLIC' AND external_id = '370576';
UPDATE festival SET title = '뮤지컬 <너를 위한 글자> ', content = '', place = '대학로 드림아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '368008';
UPDATE festival SET title = '[서울 양천] 매직컬 <피터팬>', content = '', place = '한국방송회관 코바코홀 (구. 브로드홀)' WHERE provider_type = 'PUBLIC' AND external_id = '367203';
UPDATE festival SET title = '2026 서울문화재단 예술창작활동지원 선정 프로젝트 - 류무용단 <호남춤, 그 수작<秀作)의 시간>', content = '', place = '세종문화회관 세종M씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '368395';
UPDATE festival SET title = '[대학로] 뮤지컬 <ROGER> ', content = '', place = '서경대학교 공연예술센터' WHERE provider_type = 'PUBLIC' AND external_id = '367303';
UPDATE festival SET title = '이지연 플루트 독주회 : 여성 작곡가들의 플루트 음악 V - with Strings (세계 여성의 날을 기념하며) “Rotation & Revolution 자전과 공전”', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '366304';
UPDATE festival SET title = '서리풀청년예술단<서초M.스타즈>5기 예술가곡 시리즈 ''봄이오면''', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '369216';
UPDATE festival SET title = '《락다몬 & 체어맨 2인전》', content = '', place = '갤러리 지하' WHERE provider_type = 'PUBLIC' AND external_id = '370504';
UPDATE festival SET title = '박소형 개인전', content = 'PARK, SO HYOUNG2026 SOLO EXHIBITION Re: Curtain Call  Layers of Light, Fields of Color Phenomena in Layers  <Re: Curtain Call>은 빛과 지각에 대한 탐구를 색과 공간의 구조로 확장하는 작업이다. 이전 전시가 빛의 현상 자체에 주목했다면, 이번 전시는 빛과 색이 공간 속에서 어떻게 겹쳐지고 분절되며 나타나는지, 그 ‘층위 속의 현상’을 다룬다. 이는 단순한 반복이 아니라, 지각이 형성되는 방식을 다시 구성하려는 시도이다.전시장에 수직으로 드리워진 노방은 하나의 직물이 아니라 공간을 조직하는 장치로 작동한다. 반투명한 소재는 빛을 투과시키며 그레이, 블루, 그린, 옐로우, 레드의 색 구획을 만들어낸다. 각 색은 독립된 영역처럼 보이지만, 경계에서 서로 스며들고 겹치며 하나의 연속적인 스펙트럼을 이루어낸다.이 과정에서 현상은 하나의 표면 위에서 완결되지 않는다. 빛은 필터링되고, 색은 확산되며, 층위는 간극을 통해 새로운 관계를 생성한다. 지오메트리적 배열은 질서를 제안하지만, 관람자의 이동에 따라 색의 밀도와 공간의 깊이는 끊임없이 변화한다. 작품은 고정된 형상을 제시하기보다, 현상이 겹쳐지고 변형되는 과정을 경험하게 한다. ‘Re’는 단순한 반복이 아니라 다시 열림이자 재구성의 의미를 지닌다. 커튼콜이 공연의 끝에서 또 다른 시작을 알리듯, 은 빛과 색이 공간 속에서 다시 등장하며 새로운 관계를 만들어내는 감각의 장을 제안한다. 이번 전시는 물성과 색, 빛과 구조가 상호작용하는 공간을 통해 관람자가 스스로 장면의 일부가 되는 경험을 제시한다.Exhibition Sections-Grey Strata-Blue Transition- Green Interval-Luminous Field-Saturated PulseArtist Biography현재 중앙대학교 예술대학 디자인학부 공예전공 교수로 재직 중이다. 공예가이자 텍스타일 디자이너로서 소재의 물성과 색의 구조를 중심으로 공간적 감각을 탐구해 왔으며, 산업체 협업과 브랜드 프로젝트를 통해 조형 언어를 확장해 왔다. 국내외 개인전과 기획전을 통해 빛과 색, 층위와 공간의 관계를 실험하며 물성과 컬러가 지닌 조형적 가능성을 확장해 오고 있다.', place = '예술의전당(한가람디자인미술관)' WHERE provider_type = 'PUBLIC' AND external_id = '370907';
UPDATE festival SET title = '박신양의 전시쑈 <제 4의 벽>', content = '', place = '세종문화회관 미술관' WHERE provider_type = 'PUBLIC' AND external_id = '371602';
UPDATE festival SET title = '2026 국립극장 <완창판소리> 3월', content = '박애리 명창의 <심청가> 강산제.판소리 다섯 바탕, 그 긴 여정을 처음부터 끝까지 함께하는 국립극장 <완창판소리>', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '368169';
UPDATE festival SET title = '20th Anniversary World Tour ''FIVE O ONE'' ENCORE in SEOUL', content = '', place = 'KBS스포츠월드(아레나) KBS아레나' WHERE provider_type = 'PUBLIC' AND external_id = '367671';
UPDATE festival SET title = '뮤지컬 <하모니>', content = '', place = '열린극장' WHERE provider_type = 'PUBLIC' AND external_id = '370222';
UPDATE festival SET title = '[원주 갤러리 원] 최용근 개인전 "아리랑" 희망을 품다 ', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '370979';
UPDATE festival SET title = '연극 <고트 GOTT>', content = '', place = '트라이보울' WHERE provider_type = 'PUBLIC' AND external_id = '367369';
UPDATE festival SET title = '[서울] 지브리 & 디즈니 영화음악 FESTA', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '367638';
UPDATE festival SET title = 'DAY & NIGHT LIVE CONCERT', content = '', place = '온맘씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '369198';
UPDATE festival SET title = '김지윤 바이올린 독주회 ''SCHUMANN! SCHUMANN!''', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '366305';
UPDATE festival SET title = '인생백년 꿈 같네 Vol.1 ′五歌七聲(오가칠성)′', content = '', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '369458';
UPDATE festival SET title = '[수원] 신지아 & 디토오케스트라', content = '', place = '수원SK아트리움 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '367807';
UPDATE festival SET title = '대전광역시 서예진흥원 <2026 전통서예교육프로그램-한문>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366412';
UPDATE festival SET title = '[대전] 아침을 여는 클래식, 소프라노 신주형 & 바리톤 최병혁 (3월)', content = '', place = '대전예술의전당 앙상블홀' WHERE provider_type = 'PUBLIC' AND external_id = '367895';
UPDATE festival SET title = '2026 제5회 마포 사진 공모 <별별마포>', content = '', place = '온라인' WHERE provider_type = 'PUBLIC' AND external_id = '371758';
UPDATE festival SET title = '뮤지컬 <비스티>', content = '', place = '링크아트센터 벅스홀' WHERE provider_type = 'PUBLIC' AND external_id = '368203';
UPDATE festival SET title = '한국예술종합학교 3월 둘째 주 수요영화관 <헤어질 결심>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '370606';
UPDATE festival SET title = '아름다운 목요일 위대한 작곡가: 유다윤 & 정우찬 Violin Cello Duo', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '368106';
UPDATE festival SET title = '연극 <노민호와 주리애>', content = '', place = '성수아트홀(성수문화복지회관)' WHERE provider_type = 'PUBLIC' AND external_id = '367397';
UPDATE festival SET title = '국립극단 <삼매경>', content = '한국 창작극의 묵직한 결실, 무대 위에 펼쳐지는 인간 삶의 삼라만상!  관객과 평단의 찬사를 받은 <삼매경>이 더 깊어진 완성도로 돌아온다.', place = '국립극단 [명동] 명동예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '368155';
UPDATE festival SET title = '서리풀 전곡 연주 시리즈 <하이든 교향곡 31 ''Surprise''>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '371010';
UPDATE festival SET title = ' Quartet S 제9회 정기연주회 ‘유럽의 봄, 2개의 시선’', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '371067';
UPDATE festival SET title = '예풍 신작 낭독쇼케이스, 기억 Ⅰ: 인간선언 & 능소화', content = '', place = '성북마을극장' WHERE provider_type = 'PUBLIC' AND external_id = '369304';
UPDATE festival SET title = '극단Y ＜디사이딩 세트＞- 2025 창작산실 올해의신작 연극', content = '"이 세계에서 우리가 안전할지 잘 모르겠어." 스포츠가 언제나 공정한 것은 아니다. 엄격한 규칙과 심판 과정을 거치며 공정하다는 착각을 불러일으키지만, 공정이라는 이름에 가려져 다양한 몸들이 스포츠에서 ‘탈락’되어 왔다. 유영여고 배구부 선수들은 자신이 탈락 위기에 놓인 것 같다. 여성이 아닌 것 같아서, 키가 작아서, 몸이 무거워서. 앞으로 살아갈 세계 앞에서 자꾸만 멈칫거린다. 그럼에도, 선수들은 좋아하는 것을 포기하지 않는다. 서로의 고민을 끌어안으며, 코트 위에 함께 존재할 방법을 찾아 나간다.', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '368302';
UPDATE festival SET title = '[수원] 경기필 마스터피스 시리즈 I <림스키코르사코프 세헤라자데>', content = '경기필 2026 시즌 마스터피스 시리즈의 첫 번째 무대로, 지휘자 최수열과 피아니스트 박재홍이 함께하며 러시아 음악 특유의 정열과 화려한 관현악적 색채를 집중 조명', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '371017';
UPDATE festival SET title = '스타인웨이 위너콘서트 인 코리아 <이판 우 리사이틀>', content = '한 대의 피아노로 완성하는 세계적 무대!제65회 페루초 부소니 국제 피아노 콩쿠르 우승자, 피아니스트 이판 우 리사이틀', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '368363';
UPDATE festival SET title = '뮤지컬 <인화> ', content = '', place = '홍익대 대학로 아트센터 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '368211';
UPDATE festival SET title = '제249회 울산시립교향악단 정기연주회: 낭만, 열정, 그리고 비창 Romance, Passion, and Pathétique', content = '', place = '울산문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '368212';
UPDATE festival SET title = '[이천] 뮤지컬 <등등곡> ', content = '', place = '이천아트홀 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '368489';
UPDATE festival SET title = '[제주] 뮤지컬 <빈센트 반 고흐>', content = '', place = '서귀포예술의전당 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '370212';
UPDATE festival SET title = '[인천 남동] 리얼공룡쇼 <포켓다이노> ', content = '', place = '인천문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '368556';
UPDATE festival SET title = '<500 개인전 : 낙서에서 그림으로>', content = '', place = '비커밍갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '371540';
UPDATE festival SET title = 'KT&G 상상마당 춘천 뮤직아트센터 프로젝트 《우리는 같은 꿈을 꾼다》', content = '', place = 'KT&G 상상마당 [춘천]' WHERE provider_type = 'PUBLIC' AND external_id = '373926';
UPDATE festival SET title = '양평군립미술관×전국미술대학 대한민국 유망작가전 《무엇이 보이는가》', content = '', place = '양평군립미술관' WHERE provider_type = 'PUBLIC' AND external_id = '371394';
UPDATE festival SET title = '[대전] 창작발레 <갓 GAT>', content = '', place = '대전시립연정국악원 큰마당' WHERE provider_type = 'PUBLIC' AND external_id = '368504';
UPDATE festival SET title = '[부산] 양인모 & 잘츠부르크 모차르테움 오케스트라', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '368581';
UPDATE festival SET title = '[수원] 지브리 & 디즈니 영화음악 FESTA ', content = '', place = '경기아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '368627';
UPDATE festival SET title = '[익산] 사운드 포레스트 익산: 선우정아 & 카더가든 ', content = '', place = '익산예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '369460';
UPDATE festival SET title = '[서울] 경기필 마스터피스 시리즈 I <림스키코르사코프 세헤라자데>', content = '경기필 2026 시즌 마스터피스 시리즈의 첫 번째 무대로, 지휘자 최수열과 피아니스트 박재홍이 함께하며 러시아 음악 특유의 정열과 화려한 관현악적 색채를 집중 조명', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '371018';
UPDATE festival SET title = '[광명] 정태춘 & 박은옥 문학콘서트: 나의 시, 나의 노래 ', content = '', place = '광명시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '368778';
UPDATE festival SET title = '2026년 이천무형유산 전수교육관 상설공연 <거북아, 거북아 놀아라>', content = '', place = '이천문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '385577';
UPDATE festival SET title = '[대전] 겨울왕국&초대형레이져홀로그램', content = '', place = '대전평송청소년문화센터' WHERE provider_type = 'PUBLIC' AND external_id = '368760';
UPDATE festival SET title = '코리안챔버오케스트라 & 크론베르크 아카데미 시리즈 3', content = '', place = 'GS아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '368817';
UPDATE festival SET title = '[화성] Korean Soul & Seoul Chillun ', content = '', place = '인스파이어 컬쳐홀' WHERE provider_type = 'PUBLIC' AND external_id = '370146';
UPDATE festival SET title = '연극 <지킬 앤 하이드>', content = '', place = '링크더스페이스(LINK THE SPACE)' WHERE provider_type = 'PUBLIC' AND external_id = '369449';
UPDATE festival SET title = '이응노의 집 공방프로그램 <이응노와 자연: 코바늘 실로 엮는 이야기>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '369785';
UPDATE festival SET title = '[서울 서초구] 양인모 & 잘츠부르크 모차르테움 오케스트라 ', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '368895';
UPDATE festival SET title = '시니어와 함께하는 <미술관 한걸음>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '374619';
UPDATE festival SET title = '뮤지컬 <팬레터> 10주년 기념 앵콜 공연', content = '', place = '홍익대 대학로 아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '368888';
UPDATE festival SET title = '소프라노 박재은 독창회 ''괴테 : 묻다''', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '370402';
UPDATE festival SET title = '커피콘서트 1. 홍진호 & 고상지 & 최문석: 탱고 브리즈 (Tango Breeze)', content = '', place = '인천문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '368874';
UPDATE festival SET title = '[고양] 아람 클래식, 양인모 & 잘츠부르크 모차르테움 ', content = '', place = '고양아람누리 아람음악당' WHERE provider_type = 'PUBLIC' AND external_id = '368875';
UPDATE festival SET title = '서리풀 고음악 시리즈 <Bach in Blue>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '371012';
UPDATE festival SET title = '[고창] 더 보컬리스트: 알리 & 정인 ', content = '', place = '고창문화의전당 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '371521';
UPDATE festival SET title = '머더(3/20, 3/22)', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '371338';
UPDATE festival SET title = '정악단 기획공연 <이습회 1932>', content = '궁중음악의 공연화에 기여한 1932년 이왕직아악부의 첫 번째 이습회(肄習會)를 재현해 궁중음악의 전통을 이어가는 정악단의 정체성을 드러내는 무대를 선보입니다.종묘제례악 악곡과 궁중무용 반주곡, 가곡, 가사 등 1932년 당시 이왕직아악부의 첫 이습회 연주곡을 중심으로 실제 당시 연주와 평가가 함께 있었던 이습회 현장으로 안내합니다.', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '368378';
UPDATE festival SET title = '[부산] 국립발레단 <백조의 호수> ', content = '', place = '부산시민회관 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '368917';
UPDATE festival SET title = '[양양] 버라이어트 뮤지컬 <아는 노래> ', content = '', place = '양양문화복지회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '371708';
UPDATE festival SET title = '연극 <단편전> : 아루또 10주년 기념 공연 EDITION6 vol.2', content = '', place = '아루또소극장' WHERE provider_type = 'PUBLIC' AND external_id = '372219';
UPDATE festival SET title = '연극 <리어왕외전> ', content = '', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '370148';
UPDATE festival SET title = '[군포] 응답하라 군포 1980''s: 우리가 청춘이었던 그 봄 ', content = '', place = '군포문화예술회관 철쭉홀' WHERE provider_type = 'PUBLIC' AND external_id = '370389';
UPDATE festival SET title = '관현악시리즈Ⅲ <2025 상주작곡가: 손다혜·홍민웅>', content = '2016년, 국악계 최초 상주 작곡가 제도 도입. 2026년, 다시 한번 국악관현악 역사를 쓰다.', place = '국립극장 해오름' WHERE provider_type = 'PUBLIC' AND external_id = '368162';
UPDATE festival SET title = '서울모테트합창단 제131회 정기연주회 - W.A.Mozart ''Missa in C minor'' & ''Exsultate Jubilate''', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '369395';
UPDATE festival SET title = '[제천] 그랜드필하모닉오케스트라 & 백건우 ', content = '', place = '제천예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '369999';
UPDATE festival SET title = '박용휘 ＜봄을 안고 온 아이＞- 2025 창작산실 올해의신작 전통예술', content = '“첫눈이 오기 전에 돌아올게요!“ 사랑, 그리고 약속을 지키기 위해 나서는 한 아이의 용감한 여정', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '368307';
UPDATE festival SET title = '국립익산박물관 교육상자 연계교육 <학교에서 만나는 미륵사지>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '371259';
UPDATE festival SET title = '낭독극 <우리가 그린 15년>', content = '', place = '청년예술청 SAPY' WHERE provider_type = 'PUBLIC' AND external_id = '371232';
UPDATE festival SET title = '2026 브런치 콘서트 3월 <빛을 담다 : 램브란트부터 모네까지>', content = '도슨트의 명화해설과 함께하는클래식 음악 감상회', place = '용인시평생학습관 큰어울마당' WHERE provider_type = 'PUBLIC' AND external_id = '368437';
UPDATE festival SET title = '[서울 서대문] 지브리 & 디즈니 오케스트라 콘서트 ', content = '', place = '연세대학교 대강당' WHERE provider_type = 'PUBLIC' AND external_id = '369173';
UPDATE festival SET title = '[고양] 지브리 & 디즈니 영화음악 FESTA ', content = '', place = '고양아람누리 아람음악당' WHERE provider_type = 'PUBLIC' AND external_id = '369086';
UPDATE festival SET title = '[부산] 창작발레 <갓 GAT>', content = '', place = '금정문화회관 대공연장(금빛누리홀)' WHERE provider_type = 'PUBLIC' AND external_id = '368996';
UPDATE festival SET title = '2026년 경운박물관 특별기획전 <노라 노: First & Forever>', content = '', place = '경운박물관' WHERE provider_type = 'PUBLIC' AND external_id = '371442';
UPDATE festival SET title = '소장품섬_몸의 증언: 김순기·아나 멘디에타·크리스 버든', content = '', place = '부산현대미술관' WHERE provider_type = 'PUBLIC' AND external_id = '373044';
UPDATE festival SET title = '해동문화예술촌 3월 기획전시 ''틈새의 공생''展', content = '', place = '해동문화예술촌' WHERE provider_type = 'PUBLIC' AND external_id = '373042';
UPDATE festival SET title = '심포니 오프 뮤지컬 Ⅰ <김문정의 Cook the Music>', content = '김문정 음악감독의 섬세하고 위트있는 해설과 오케스트라가 빚어내는 압도적인 라이브 무대, 김문정이 요리한 음악 한 접시 <Cook the Music>', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '367382';
UPDATE festival SET title = '[목포] 가족뮤지컬 <겨울왕국> ', content = '', place = '목포시민문화체육센터 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '369074';
UPDATE festival SET title = ' [안산] K-히어로 뮤지컬 <똥볶이 할멈: 정의의 맛>', content = '', place = '안산문화예술의전당 달맞이극장' WHERE provider_type = 'PUBLIC' AND external_id = '369090';
UPDATE festival SET title = '프로하비 뮤지컬 <오! 캐롤>', content = '', place = '꿈의숲아트센터 퍼포먼스홀' WHERE provider_type = 'PUBLIC' AND external_id = '370444';
UPDATE festival SET title = 'Lover''s Concert (앵콜)', content = '', place = '연세대학교 백주년기념관' WHERE provider_type = 'PUBLIC' AND external_id = '371351';
UPDATE festival SET title = '[전주] 겨울왕국 & 초대형레이져쇼 ', content = '', place = '덕진예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '369294';
UPDATE festival SET title = '[부산] 사카리 오라모 & BBC 심포니 오케스트라 with 손열음 ', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '369496';
UPDATE festival SET title = '信 Young Artist X K''ARTS Audition 수상자 리사이틀: 클라리네티스트 신명', content = '', place = '신영체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '370557';
UPDATE festival SET title = '사카리 오라모 & BBC 심포니 오케스트라 with 손열음 (03.25)', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '369494';
UPDATE festival SET title = '안성맞춤아트홀 ''문화가 있는 날:아트-데이'' 가장 가까운 국립극장 창극 <춘향>', content = '', place = '안성맞춤아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '371890';
UPDATE festival SET title = '[부산] 재즈앙상블 시리즈 Ⅰ. 봄맞이 스윙재즈 콘서트: 성기문 재즈퀄텟 & 보컬 박재홍 ', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '370189';
UPDATE festival SET title = '윈튼 마살리스 & 재즈 앳 링컨센터 오케스트라', content = '', place = 'LG아트센터 서울 LG SIGNATURE 홀' WHERE provider_type = 'PUBLIC' AND external_id = '369498';
UPDATE festival SET title = '[남원] 차와 이야기가 있는 국악콘서트 <다담> ', content = '', place = '국립민속국악원 예음헌' WHERE provider_type = 'PUBLIC' AND external_id = '374423';
UPDATE festival SET title = '시 창작 워크숍 <봄비> [불화하는 시 쓰기]', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '373560';
UPDATE festival SET title = '서초문화재단 & 서초교향악단 공동기획, 모차르트 피아노 협주곡 전곡 시리즈 4', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '370508';
UPDATE festival SET title = '[부산] 부산시립국악관현악단 & 진주시립국악관현악단 합동교류연주회: 영남 풍류', content = '', place = '부산시민회관 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '369666';
UPDATE festival SET title = '사카리 오라모 & BBC 심포니 오케스트라 with 손열음 (03.26)', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '369542';
UPDATE festival SET title = '어린이박물관 개관 기념 국제교류전 <볼 빨간 돼지의 종이 모험>', content = '', place = '서울역사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '371410';
UPDATE festival SET title = '[제천] 뮤지컬 <난쟁이들> ', content = '', place = '제천예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '370727';
UPDATE festival SET title = '도록 출간회 『Layered Dialogues: We Are in Open Circuits』 & 『교차하는 서사: 근접한 세계』', content = '', place = '서울시립미술관 서소문본관 세마홀' WHERE provider_type = 'PUBLIC' AND external_id = '373322';
UPDATE festival SET title = '마약: 엇갈린 운명', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '369727';
UPDATE festival SET title = '연극 <운베난트>', content = '', place = '예스24 스테이지(구. DCF대명문화공장) 3관(구. 수현재씨어터)' WHERE provider_type = 'PUBLIC' AND external_id = '372422';
UPDATE festival SET title = '[서울] 강우성의 피아노 사색 ［思索］ #11 "사람의 사랑과 생애"', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '371440';
UPDATE festival SET title = '[대전] 손열음 & BBC 심포니 오케스트라 with 사카리 오라모 ', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '369740';
UPDATE festival SET title = '[평택] 윈튼 마살리스 & 재즈 앳 링컨센터 오케스트라 ', content = '', place = '평택아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '369743';
UPDATE festival SET title = '라율아트홀 살롱클래식, L’Aube Quartet (로브 콰르텟) Recital', content = '', place = '라율아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '370415';
UPDATE festival SET title = '[대구] 윤지현 & 최영성 피아노 듀오 리사이틀 ', content = '', place = '웃는얼굴아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '371985';
UPDATE festival SET title = '유니버설발레단 발레 <돈키호테>', content = '스페인의 정열이 살아 숨 쉬는 희극발레의 대표작 ‘돈키호테’. 선술집 딸 키트리와 이발사 바질의 좌충우돌 사랑과 우정, 판타지, 모험 이야기', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '367456';
UPDATE festival SET title = '한밤의 공연 산책 Ⅰ, U''s Again', content = '', place = '강동아트센터 소극장 드림' WHERE provider_type = 'PUBLIC' AND external_id = '370192';
UPDATE festival SET title = '샤마', content = '''샤마(שָׁמַע)''는 히브리어로 ''듣다''를 뜻합니다. 단순히 소리를 듣는 것이 아니라, 온 존재로 귀를 기울이고 그것을 받아들여 행동하는 것. 그 깊은 경청의 의미를 무대 위에 펼칩니다. 세상에는 하지 못한 말들이 넘쳐납니다. 두려움에, 낯설음에, 고통에, 외로움에 삼킨 말들이 어딘가에 켜켜이 쌓여 있습니다. 이 작품은 그 말들에 귀를 기울이는 것에서 시작합니다. ', place = '대학로예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '368350';
UPDATE festival SET title = '[서울 마포] M 초이스, 발레 <갓 GAT> ', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '369918';
UPDATE festival SET title = '2026 서리풀 악기거리 <토요 브런치 투어> 3월', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '370295';
UPDATE festival SET title = '2026 도민의 집 ''주말 예술 캠프'' 행사', content = '', place = '경남 도민의 집 앞뜰' WHERE provider_type = 'PUBLIC' AND external_id = '370989';
UPDATE festival SET title = '칸타빌레 클래식 기획연주회 29, 이미솔 & 목혜진 듀오리사이틀: Danza del Fuego', content = '', place = '칸타빌레 클래식 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '369898';
UPDATE festival SET title = 'IAN KIM 피아노 리사이틀 : 창밖의 비창 Pathétique beyond the Pane ', content = '', place = '헤르만아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '371769';
UPDATE festival SET title = '피아노&싱잉볼 살롱 음악회 공명 사이', content = '', place = '서울재질' WHERE provider_type = 'PUBLIC' AND external_id = '373021';
UPDATE festival SET title = '[진주] 이영희 & 박제민, Spring Dialogue 봄의 대화 ', content = '', place = '문기타, 문씨어터 [진주]' WHERE provider_type = 'PUBLIC' AND external_id = '372932';
UPDATE festival SET title = '월간연주자 듀오시리즈, 구혜진 & 류정인 (3월)', content = '', place = '갤러리 디 아르테 청담' WHERE provider_type = 'PUBLIC' AND external_id = '370032';
UPDATE festival SET title = '[서울] 피터 야블론스키 & 김정원 피아노 듀오 리사이틀', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '369932';
UPDATE festival SET title = '[부천] 아즈마 아키와 함께하는 영화음악 콘서트: 지브리 & 월드 무비 OST ', content = '', place = '부천시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '369948';
UPDATE festival SET title = '윤학준 음악극 <수호천사> 뮤직콘서트', content = '', place = '로데아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '371206';
UPDATE festival SET title = '[대전] MelON 지브리 & 뮤지컬 갈라 오케스트라 콘서트 ', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '370198';
UPDATE festival SET title = '[인천] 아즈마 아키와 함께하는 영화음악 콘서트: 지브리 & 월드 무비 OST ', content = '', place = '인천문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '370201';
UPDATE festival SET title = '악기를 빌리고, 문화를 나누는 <부천악기은행 개소식>', content = '', place = '복사골문화센터 4층 부천악기은행' WHERE provider_type = 'PUBLIC' AND external_id = '373563';
UPDATE festival SET title = '[대학로] 연극 <정희> ', content = '', place = '예스24아트원' WHERE provider_type = 'PUBLIC' AND external_id = '370092';
UPDATE festival SET title = '[서울 서초] 강우성의 피아노 사색 ［思索］ #11 "사람의 사랑과 생애"', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '371441';
UPDATE festival SET title = '[대학로] 연극 <아트> ', content = '', place = '예스24 스테이지(구. DCF대명문화공장) 1관' WHERE provider_type = 'PUBLIC' AND external_id = '370905';
UPDATE festival SET title = '피아니스트 강혜윤 & 정지혜 듀오 리사이틀', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '370090';
UPDATE festival SET title = '울산도서관 수요 인문학 아카데미 <영화 속 클래식>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '373206';
UPDATE festival SET title = '2026년 ''한지에 서예를 담다''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '373175';
UPDATE festival SET title = '한국예술종합학교 4월 첫주 수요영화관 <베일리와 버드>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '373562';
UPDATE festival SET title = 'FIGURE SCENES', content = '<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:columns -->
<div class="wp-block-columns"><!-- wp:column {"width":"100%"} -->
<div class="wp-block-column" style="flex-basis:100%"><!-- wp:columns -->
<div class="wp-block-columns"><!-- wp:column -->
<div class="wp-block-column"><!-- wp:paragraph -->
<p>최석운은 오랜 시간 인물을 화면의 중심에 두었다. 거창한 주제나 숭고한 가치보다, 주변에서 스쳐지나가는 순간들과 사람 사이에서 벌어지는 소소한 사건들 - 그것을 재미있게 포착해 사람들과 소통하는 것이 작업의 출발점이었다. 그러나 오랫동안 준비한 개인전이 팬데믹으로 조용히 막을 내렸고 작가는 전남 해안의 작은 섬 임하도로 향했다. 고립된 섬에서의 시간, 그리고 우연히 찾은 이탈리아의 의 시칠리아와 피렌체의 풍경 속에서 그는 전에는 보지 못했던 것들을 눈에 담기 시작했다. “당신은 왜 풍경을 그리지 않나요?” 몇 해 전 지인이 던진 그 말이 비로소 다르게 들린 시점이었다. 최석운의 시선은 인간을 바라보던 시선에서 풍경으로 천천히 이동하고 있었다. 그러나 작가에게 있어 풍경은 자연의 아름다움을 옮기는 대상이 아니었다. 풍경 속에 여전히 사람이 있었고, 사람이 곧 풍경이 되었다. 그리고 그 풍경 안에서 인물은 다시 새로운 얼굴로 돌아왔다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>최석운은 우리 주변의 평범한 인물과 일상의 풍경을 특유의 해학적 시선으로 포착해왔다. 이번 전시 «FIGURE SCENES»는 오랜 시간 견지해 온 유머와 풍자의 미학을 유지하면서도, 대상을 바라보는 관점의 변화를 보여준다. 작가의 시선은 최근 ‘인간’을 넘어 피규어(figure)로 확장되었다. 피규어는 사람, 동물 등 실재하는 대상의 외형을 본떠 만든 ‘가짜’이자 생명력이 없는 존재다. 대상을 대담하게 생략하거나 재해석하여 해학을 극대화한 작가는 이번 전시 작품에서 인물들을 더욱 뻣뻣하고 조형적인 이미지로 표현하여, 현대 사회 속 인간 본연의 모습을 객관적이면서도 냉소적으로 응시한다. 캔버스 위의 인물들은 살아 움직이는 듯하면서도 박제되어 있는 듯한 모습이다. 사실을 닮았으나 사실이 아닌, 그 어중간한 자리에 놓인 형태들, 조형적으로 재구성된 인물은 오히려 인간을 더 선명하게, 혹은 더 낯설게 응시하도록 이끈다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>일상에서 포착한 ‘대상’들의 배경이 되는 장면(scenes)들은 작가의 개인적인 경험과 세밀한 관찰에서 출발한다. 자전거를 타고 영산강과 섬진강을 여행하던 중 만난 리포터에게서 얻은 낯선 영감을 담은 <섬진강>(2024), 20년 동안 같은 길을 오가면서도 미처 눈에 담지 못했던 길가의 모란꽃을 그린 <모란꽃 밭에서>(2025)는 그 대표적인 예다. 오래 보아야 비로소 보이는 것들, 혹은 오랜 시간 보았기에 오히려 보이지 않았던 것들, 작가는 그 순간의 ‘발견’을 화면에 옮긴다. 평범한 일상이 ‘예술적 대상’으로 치환되는 것은 거창한 사건이 아니라 어느날 불현듯 달라진 평범한 시선 하나에서 비롯된다. 잠시 해남에 머물면서, 유기견을 구조하며 벌어진 에피소드를 시각화한 <Vacances> 연작도 같은 맥락에 있다. 강아지를 데려온 순간 모두가 반기면서도 정작 돌봄의 책임은 서로 미루는 모순적인 상황, 즐거운 휴가를 연상시키는 제목 이면에는 인간의 이기심과 무책임에 대한 풍자가 깔려 있다. 작가의 시선은 유기견도, 책임을 회피하는 인간을 탓하지 않는다. 다만 그 장면을 조용히 응시하게 만든다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가 내면의 고소공포증을 ‘발코니’라는 불안정한 공간으로 시각화한 작업은 현대인이 느끼는 보편적인 심리적 긴장감을 투영한다. 발코니의 인물들은 마치 피규어처럼 나열되어 정적인 느낌을 주면서도, 허공에 떠 있는 공간이 자아내는 위태로움을 통해 바라보는 이로 하여금 묘한 긴장감을 선사한다. 추락할 것 같지도, 그렇다고 안전한 것 같지도 않은 그 경계 - 그것은 비단 ‘발코니’ 그림만의 이야기는 아닌 듯 하다. 좁은 공간에 나란히 서서, 같은 곳을 바라보지 않는 사람들, 제각각의 시선. 우리는 언젠가부터 그런 풍경 속에 익숙하게 자리잡고 있었는지도 모른다. 최석운은 그러한 장면들은 판단하여 정답을 제시하지 않는다. 다만 가만히 들여다보게 만들 뿐이다. 그의 그림 앞에서 관람자는 어떤 메시지를 받는 대신, 스스로 삶의 어느 한 면과 마주하게 된다. 익숙한 듯 낯선, 유머러스하면서도 씁쓸한 - 그것이 오랫동안 작가가 그려온 세계이자, 이번 전시가 건네는 이야기이다._호리아트스페이스 디렉터 고은주</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column --></div>
<!-- /wp:columns --></div>
<!-- /wp:column --></div>
<!-- /wp:columns -->', place = '호리아트스페이스' WHERE provider_type = 'PUBLIC' AND external_id = '374370';
UPDATE festival SET title = '<산복도로 이야기 2 : 김명환 만화전>', content = '', place = '부산문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '386753';
UPDATE festival SET title = '2026 대관령음악제 기획공연 강원의 사계 <봄> 김준형 피아노 리사이틀', content = '', place = '강릉아트센터 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '371064';
UPDATE festival SET title = '마티네 콘서트: 김영하 작가의 <여행의 이유, 그리고 음악>Ⅰ', content = '수요일 오전, 클래식 음악과 함께 하는 마티네 콘서트.이번 시리즈는 작가 김영하가 함께 합니다. 매월 새로운 이야기와 작가가 직접 선별한 음악 큐레이션을 선보입니다.', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '368256';
UPDATE festival SET title = '뮤직드라마 <불편한 편의점2>', content = '', place = '후암씨어터(콘텐츠룸)' WHERE provider_type = 'PUBLIC' AND external_id = '370283';
UPDATE festival SET title = 'Heritage : Time Inherited (유산 : 이어받은 시간)', content = '<!-- wp:paragraph -->
<p><strong>갤러리 나우 개관 20주년 기념전</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>< </strong><strong>Heritage : Time Inherited</strong><strong> </strong><strong>(</strong><strong>유산 : 이어받은 시간)</strong><strong> </strong><strong>></strong><strong>展</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>시대를 관통하는 예술의 숨결</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>시간의 흐름 속에서 하나의 분야를 고수하며 지켜낸다는 것은 단순히 과거를 보존하는 행위를 넘어, 그 자체로 숭고한 가치를 지닙니다. 민족마다 고유한 색채와 DNA가 존재하듯, 우리가 발을 딛고 있는 이 땅의 정서와 정신적 맥락이 수천 년의 세월 동안 층층이 쌓여 비로소 한국 고유의 문화적 형상이 완성되었습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>오늘날 ''K-컬처''라는 이름의 한류가 전 세계의 심장을 두드리는 이 역동적인 시대에, 우리는 다시금 본질적인 질문을 마주하게 됩니다. "우리의 정신적 뿌리는 어디에 닿아 있으며, 그 정체성을 관통하는 한국적 DNA는 무엇인가”를 질문하게 됩니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>세대를 넘는 작가 정신</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 한국 미술의 근간을 이루는 예술 가문의 서사, 즉 2대, 혹은 3대에 걸쳐 세대의 장벽을 허물고 예술적 가치를 계승해온 부자(父子), 모녀(母女), 부녀(父女), 모자(母子), 손(孫)으로 이어온 작가들의 작업을 조명하고자 마련되었습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이들의 작업은 개인의 역사를 넘어 한국 현대미술의 견고한 줄기를 형성해 왔습니다. 부모가 일구어 놓은 예술적 토양 위에서 자녀는 새로운 잎을 틔우고, 그 잎은 다시 다음 세대의 밑거름이 될 것입니다. 1세대 작가가 지켜온 정서와 미학적 원형에, 변화하는 시대상에 맞춰 새롭게 변주된 2세대 작가들의 독창적이고 시대정신에 입각한 시선, 거기에 핏줄보다 진한 예술적 유대감으로 이어지는 숭고함을 들여다보는 전시입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리나우는 이번 전시를 통해 세대를 가로질러 묵묵히 제자리를 지키며, 한국인의 맥을 이어온 작가정신에 깊은 존경을 표하고자 합니다. 맥(脈)을 잇는다는 것은 앞선 세대의 치열했던 고뇌를 이해하고, 그 정신의 불꽃을 꺼뜨리지 않은 채 자신만의 언어로 재해석해내는 창조적 계승이자 앞으로의 발전입니다. 그들이 지켜낸 것은 단순한 ''작품''이 아니라, 우리 민족의 정신적 줄기이자 미래로 뻗어 나갈 문화적 생명력이기 때문입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>갤러리나우 20년의 여정, 그리고 ''잇는다는 것''의 무게</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리나우는 2006년 4월 5일 첫 문을 연 이래, 예술의 최전선에서 호흡하며 쉼 없이 달려왔습니다. 이번 전시는 20주년을 맞이하여 과거와 현재, 미래가 교차하는 징검다리로서의 역할을 다시금 되새기는 자리입니다. “예술은 강물처럼 흐르고, 갤러리는 그 물길이 막히지 않도록 낮은 곳에서 터를 닦는 존재” 여야 한다면 이번 전시는 세대를 넘어 귀하게 이어져 온 작가 정신의 결을 살피고, 끊기지 않고 도도히 흐르는 예술의 생명력을 잠시나마 한자리에서 목격하고 보필하는 기록의 장이 되기를 바라는 마음으로 기획된 전시입니다. 이 전시가 우리 안에 흐르는 한국미술의 DNA를 다시 확인하고, 예술이 지닌 영속적인 가치를 깊이 음미하는 소중한 시간이 되기를 바랍니다.</p>
<!-- /wp:paragraph -->', place = '갤러리나우' WHERE provider_type = 'PUBLIC' AND external_id = '374164';
UPDATE festival SET title = '수원시립공연단 제29회 정기공연 연극 <십번기>', content = '', place = '정조테마공연장' WHERE provider_type = 'PUBLIC' AND external_id = '371061';
UPDATE festival SET title = '[대학로] Noir _ L’historirde S', content = '', place = '연극실험실 혜화동1번지' WHERE provider_type = 'PUBLIC' AND external_id = '372081';
UPDATE festival SET title = '[부산] 봄을 알리는 콘서트, 이지훈 & 홍지민 ', content = '', place = '해운대문화회관 해운홀' WHERE provider_type = 'PUBLIC' AND external_id = '371237';
UPDATE festival SET title = '2026 부천문화재단 기획공연 뮤지컬 <더 픽션>', content = '', place = '복사골문화센터 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '370512';
UPDATE festival SET title = 'Missing(미씽)', content = '우리는 무엇을 잃어버렸는가. 그것을 잃어버렸다는 사실조차 얼마나 쉽게 잊고 사는가. 다음 세대에게 우리는 어떤 형태의 ‘종말’을 매일 선물하고 있는가.', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '368352';
UPDATE festival SET title = '강동문화재단 x 널 위한 문화예술 <그것의 미래: 동시대 먹그림展>', content = '', place = '강동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '373915';
UPDATE festival SET title = '제335회 부천필하모닉오케스트라 정기연주회: Romeo & Juliet', content = '', place = '부천아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '370523';
UPDATE festival SET title = '제44회 부산연극제, 개막 축하공연 <품>', content = '', place = '(재)영화의전당 하늘연극장' WHERE provider_type = 'PUBLIC' AND external_id = '372571';
UPDATE festival SET title = 'NT Live <햄릿>', content = '2025년 영국 국립극장 최신작, 한국 최초 상영! 권력과 혼란 속에서, ‘나는 누구인가’를 묻는 시대를 초월한 이야기', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '368163';
UPDATE festival SET title = '<러닝 조제 완료! 런약사 정보라의 달리기 처방전> 강연', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '373664';
UPDATE festival SET title = '산책도서관 <산책프렌즈> 4월 책읽기 & 책놀이 프로그램', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '373663';
UPDATE festival SET title = '박일광 전시연계 프로그램 <인사이드 애니멀>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '372891';
UPDATE festival SET title = '[서울] 나의 비밀친구 해치 ', content = '', place = 'KT&G 상상마당 대치아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '370772';
UPDATE festival SET title = '가족뮤지컬 <태권, 날아올라>', content = '한국체육고등학교 태권도 유망주들의 성장스토리!', place = '국립중앙박물관 극장 용' WHERE provider_type = 'PUBLIC' AND external_id = '368428';
UPDATE festival SET title = '후생가외, 박주연의 <금석맹약金石盟約-심청가>', content = '', place = '문화공간 아이원 운당' WHERE provider_type = 'PUBLIC' AND external_id = '372922';
UPDATE festival SET title = '[부산] MelON 지브리 & 뮤지컬 갈라 오케스트라 콘서트 ', content = '', place = '부산시민회관 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '370780';
UPDATE festival SET title = '제1회 디어에스엠 정기연주회: Love & Blossom', content = '', place = '영산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '372730';
UPDATE festival SET title = '연희 상설 공연 <연희판판>', content = '', place = '국립국악원 연희마당' WHERE provider_type = 'PUBLIC' AND external_id = '372609';
UPDATE festival SET title = 'NT Live <워렌 부인의 직업>', content = '2025년 영국 국립극장 최신작, 한국 최초 상영! 도덕과 생존 사이, 여성이 감당해야 했던 선택의 대가', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '368164';
UPDATE festival SET title = '2026 자유소극장 연극 <뼈의 기록>', content = '<천 개의 파랑> 천선란 작가 ‘로봇 3부작’ 마지막 이야기, 죽은 이의 마지막을 배웅하는 안드로이드 장의사 로비스의 시선으로 마주하는 인간 생의 기록', place = '예술의전당 자유소극장' WHERE provider_type = 'PUBLIC' AND external_id = '368440';
UPDATE festival SET title = '[인천] Wine & Music Night: Jazz & Tango', content = '', place = '엘림아트센터 챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '371234';
UPDATE festival SET title = '[화성] 김유빈 & 디토오케스트라: 디어 아마데우스 ', content = '', place = '유앤아이센터' WHERE provider_type = 'PUBLIC' AND external_id = '370946';
UPDATE festival SET title = '중구민을 위한 월요극장 11, 뮤지컬 <홍련>', content = '', place = '충무아트센터 중극장 블랙' WHERE provider_type = 'PUBLIC' AND external_id = '372544';
UPDATE festival SET title = '백조의 호수', content = '매회 전석 매진을 기록하는 국립발레단 <백조의 호수>는 발레 안무의 거장 유리 그리고로비치의 안무작으로 국립발레단만을 위해 특별히 고안한 행복한 결말이 특징이다.', place = '예술의전당 [서울] 오페라극장' WHERE provider_type = 'PUBLIC' AND external_id = '367454';
UPDATE festival SET title = '[원주 갤러리 원] 박노엘 개인전 "TRACEISM Fossilizing Flower"', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '375342';
UPDATE festival SET title = ' 강지영 피아노 독주회 "Romantic Ties"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '370309';
UPDATE festival SET title = '[부산] 파이프오르간 시리즈, 이사벨 드메르 & 션 위안: 포핸즈 ', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '371318';
UPDATE festival SET title = '한국예술종합학교 4월 둘째주 수요영화관 <서울의 봄>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '374310';
UPDATE festival SET title = '2026 도림 생활문화센터 사계절클래스 봄 <드로잉클래스>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '372789';
UPDATE festival SET title = '2026 안전 연극제: 면역력 <손가락 걸고>', content = '', place = '연극실험실 혜화동1번지' WHERE provider_type = 'PUBLIC' AND external_id = '372830';
UPDATE festival SET title = '제31회 전국신인정가악발표회 ′미래를 열어갈 젊은 신인들의 무대′', content = '', place = '국립국악원 예악당' WHERE provider_type = 'PUBLIC' AND external_id = '374417';
UPDATE festival SET title = '서리풀 전곡 연주 시리즈 <하이든 교향곡 32 ''Special Guest''>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '373903';
UPDATE festival SET title = '[대전] 키안 솔타니 & 박재홍 듀오 리사이틀', content = '', place = '대전예술의전당 앙상블홀' WHERE provider_type = 'PUBLIC' AND external_id = '371329';
UPDATE festival SET title = '[서울] 키안 솔타니 & 박재홍 듀오 리사이틀', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '371477';
UPDATE festival SET title = '2026 안전 연극제: 면역력 <각방프로젝트: n개의 균>', content = '', place = '연극실험실 혜화동1번지' WHERE provider_type = 'PUBLIC' AND external_id = '372853';
UPDATE festival SET title = '토요일 두시에 산책가자! <임금님 귀는 토끼 귀>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '374559';
UPDATE festival SET title = '2026 상반기 전북도립미술관 어린이 교육프로그램 <어린이 아뜰리에>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '373648';
UPDATE festival SET title = '[원주] 가족뮤지컬 <겨울이야기>', content = '', place = '원주치악예술관' WHERE provider_type = 'PUBLIC' AND external_id = '371660';
UPDATE festival SET title = '침묵의 낭송 Leçons du Silence', content = '', place = '서소문성지 역사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '372185';
UPDATE festival SET title = '2026 아뜰리에 광화 봄 전시 <피어나는 빛>', content = '', place = '세종문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '376230';
UPDATE festival SET title = '대학로 창작 연극 <달콤한 게 필요해!>', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '371715';
UPDATE festival SET title = '2026 국립극장 <완창판소리> 4월', content = '왕기석 명창의 <수궁가> 미산제.판소리 다섯 바탕, 그 긴 여정을 처음부터 끝까지 함께하는 국립극장 <완창판소리>', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '368170';
UPDATE festival SET title = '[광주] 아트콘서트 & 오감한스푼: 콰르옥텟 ', content = '', place = '빛고을시민문화관' WHERE provider_type = 'PUBLIC' AND external_id = '374941';
UPDATE festival SET title = '제952회 전남도립국악단 토요가무악희 <그린국악> 시즌 2 : 기억, 위로의 선율', content = '', place = '남도소리울림터' WHERE provider_type = 'PUBLIC' AND external_id = '374131';
UPDATE festival SET title = '루이 오자와 & 장지원 듀오 리사이틀', content = '', place = '로데아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '372289';
UPDATE festival SET title = '[평택] 얍 판 츠베덴 서울시립교향악단 Mozart & Tchaikovsky ', content = '', place = '평택아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '371576';
UPDATE festival SET title = 'M 초이스, 연극 <비기닝> ', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '371629';
UPDATE festival SET title = '[부천] 베토벤 & 라흐마니노프 ', content = '', place = '부천아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '371840';
UPDATE festival SET title = '정명훈 & 원 코리아 오케스트라', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '371850';
UPDATE festival SET title = '강희윤 첼로 독주회 "Hola! España"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '370609';
UPDATE festival SET title = '2026 안전 연극제: 면역력 <서비스직 근로자의 안전 관리 매뉴얼 만들기>', content = '', place = '연극실험실 혜화동1번지' WHERE provider_type = 'PUBLIC' AND external_id = '372839';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 침묵과 빛 사이 Between Silence & Light', content = '', place = '모란미술관' WHERE provider_type = 'PUBLIC' AND external_id = '376517';
UPDATE festival SET title = '[부산] 르네상스 in 동래: SUN & MOON ', content = '', place = '동래문화회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '372137';
UPDATE festival SET title = '[울산] 2026 렉처콘서트 ''조우'' - 제1장 라 트라비아타', content = '', place = '울산중구문화의전당 함월홀(2층)' WHERE provider_type = 'PUBLIC' AND external_id = '371941';
UPDATE festival SET title = '허준 개인전 - 꼬리가 몸통을 흔든다', content = '<!-- wp:paragraph -->
<p>토포하우스 제1,2전시실 </p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":18089,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/04/KakaoTalk_20260421_172103242.jpg" alt="" class="wp-image-18089" /><figcaption class="wp-element-caption"><em>토포하우스 제2전시실</em></figcaption></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong>기획 의도</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>허준 작가는 일상적인 존재나 사물들로부터 얻는 동질감을 작업의 모티브로 삼는다. 작가 자신을 의인화된 대상에 숨겨놓고 화면 밖 자신의 시선과 마주보는 ‘나무’ 시리즈가 대표적이다. 스케치 없는 작업은 곤충 표피와 같은 문양으로 나타나며 생동하는 꾸물꾸물한 패턴은 생명체로도 보인다. 나무는 동물 또는 벌레로 변신한 작가의 페르소나가 숨을 수 있는 공간과 장소이기도 하다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>허준은 인간 관계에 대해 많은 고민을 한다. 작업실 주변 경기도 양평군 일대를 운전하며 눈에 들어오는 교통표지판이 이러한 관계성을 대변해 주는 듯 보여 이번 전시에서는 표지판에서 유추한 도형을 출발점으로 삼은 작업을 내놓는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>작품 설명</strong></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":18090,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/04/관계의-방향1-34-x-226.5cm-한지에-혼합재료-2025-small-rotated.jpg" alt="" class="wp-image-18090" /><figcaption class="wp-element-caption"><em>관계의 방향1, 34 x 226.5cm, 한지에 혼합재료, 2025</em></figcaption></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>한 가운데 위치한 원안의 문양들은 낯설지만 익숙하다. 원안에는 관계의 기쁨, 슬픔, 배신, 어설픔, 괴로움, 여러 감정들을 내포하고 있다. 관계는 원안에서 시작하고 탄생한다. 단정한 이미지처럼 보이지만 내부에선 회오리가 있다. 결국 그 방향은 반대의 방향으로 흘러간다. 그건 상대의 잘못이건 내 잘못이건 결국 그렇게 흘러갈 운명이다. 전혀 다른 방향으로 흘러가는 운명이 누구에겐 상실감과 배신감일 것이며 반대의 입장에서 결론은 허무함이고 좌절감이자 미안함이다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":18091,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/04/KakaoTalk_20260421_171709923_02.jpg" alt="" class="wp-image-18091" /><figcaption class="wp-element-caption"><em>토포하우스 제1전시실</em></figcaption></figure>
<!-- /wp:image -->', place = '토포하우스' WHERE provider_type = 'PUBLIC' AND external_id = '376988';
UPDATE festival SET title = '서울시립미술관×중구문화재단 협력전시 ≪SeMA Collection: 청록미로≫', content = '', place = '충무아트센터 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '379323';
UPDATE festival SET title = '2026 인천아트플랫폼 <예술가 강사 양성 프로그램>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '370658';
UPDATE festival SET title = 'DAF2026 : ART & DESIGN 경계를 넘어', content = '', place = '예술의전당(한가람미술관)' WHERE provider_type = 'PUBLIC' AND external_id = '376670';
UPDATE festival SET title = 'ASAC 클래식. 구자범의 <사월, 다시 피다>', content = '구자범 지휘자의 복귀, ‘Queen’의 음악을 이 시대의 레퀴엠으로 재창조한 웅장하고 가슴 저린 교향곡', place = '안산문화예술의전당 해돋이극장' WHERE provider_type = 'PUBLIC' AND external_id = '368360';
UPDATE festival SET title = '구자범의 안산 사운드뮤직아카데미 <사월 다시피다>', content = '‘Queen’의 음악을 이 시대의 레퀴엠으로 재창조한 웅장하고 가슴 저린 교향곡', place = '안산문화예술의전당 해돋이극장' WHERE provider_type = 'PUBLIC' AND external_id = '368951';
UPDATE festival SET title = '믹스드 오케스트라 26', content = '명곡과 신작, 전통과 창작, 세대와 감각이 교차하며 국악관현악의 매력을 확장하는 ''믹스드 오케스트라''', place = '세종문화회관 세종대극장' WHERE provider_type = 'PUBLIC' AND external_id = '367374';
UPDATE festival SET title = '국립극단 <그의 어머니 Mother of Him>', content = '화제성과 작품성 둘 다 사로잡은 2026 관객의 Pick! 개막과 함께 매진을 알리며 관객들의 박수로 가득했던 작품의 발빠른 귀환!', place = '국립극단 명동예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '375066';
UPDATE festival SET title = '[PAC] 앰비규어스댄스컴퍼니 <더벨트>', content = '', place = '평택아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '376488';
UPDATE festival SET title = '[광주] ACC x QUAD 기언치, 봄 <헉_Hug>', content = '', place = '국립아시아문화전당 극장1' WHERE provider_type = 'PUBLIC' AND external_id = '373402';
UPDATE festival SET title = '나의 방을 나눔합니다 : From This Room to That Room', content = '<!-- wp:paragraph -->
<p>조연주는 지난 10년간 일곱 번의 이사를 경험하며 서로 다른 공간에 머물러 왔다. 이러한 경험을 바탕으로 그는 ‘집’을 고정된 장소가 아닌, 일정한 시간 동안 머무르는 상태 속에서 형성되는 감각적이고 정서적인 개념으로 바라본다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시 《나의 방을 나눔합니다 : From This Room to That Room》는 ‘집’이라는 익숙한 개념을 해체하고, 동시대의 이동적인 삶 속에서 우리가 거쳐가는 공간들이 어떻게 ‘집’으로 인식되는지를 질문한다. 작가는 물리적 구조로서의 공간보다, 기억과 감각, 그리고 타인의 흔적이 축적된 상태로서의 ‘집’에 주목한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>창을 통해 마주한 풍경을 담은 소형 회화, 분절된 화면의 결합과 해체를 반복하는 조립식 회화, 그리고 비단과 목판을 결합한 이중 레이어 회화는 각각 다른 방식으로 공간 경험과 기억의 구조를 드러낸다. 특히 작가는 특정 공간을 ‘집’으로 인식하게 만드는 요소로 개인적 사물, 즉 ‘센티멘털 오브제’에 주목하며, 이를 통해 공간에 축적된 시간과 감정의 층위를 시각화한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>조연주의 회화는 집을 하나의 고정된 실체로 제시하기보다, 시간과 기억, 시선이 중첩된 상태로 풀어낸다. 이 전시는 우리가 일시적으로 머무르는 수많은 공간들이 어떻게 개인의 경험 속에서 ‘집’이 되어가는지를 조용하게 되묻는다.</p>
<!-- /wp:paragraph -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity" />
<!-- /wp:separator -->

<!-- wp:paragraph -->
<p>Over the past decade, Cho Yeonjoo has moved seven times, inhabiting a series of different spaces. Through these experiences, she approaches “home” not as a fixed place, but as a sensory and emotional condition formed through the act of dwelling over time.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong><em>From This Room to That Room</em></strong> begins by deconstructing the familiar notion of home, translating the structures of contemporary, mobile life into painting. Rather than focusing on physical space, Cho attends to home as a state shaped by memory, perception, and the traces of others—raising a quiet yet incisive question about how we live today.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Small-scale paintings capturing fleeting views through windows, modular works that repeatedly assemble and disassemble fragmented surfaces, and double-layered paintings combining silk and wood panel each reveal different ways of structuring spatial experience and memory. Central to this body of work is the notion of “sentimental objects”—personal belongings that enable a space to be recognized as home, functioning as carriers of time, memory, and emotion.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Rather than defining home as a fixed entity, Cho proposes it as a layered condition shaped by time, memory, and perception. The exhibition ultimately reflects on how the many transient spaces we pass through come to be experienced as home.</p>
<!-- /wp:paragraph -->', place = '유엠 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '376675';
UPDATE festival SET title = '윤희주 & 최세린 피아노 듀오 리사이틀', content = '', place = '성남아트센터 앙상블씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '371393';
UPDATE festival SET title = 'Love & Music 갈라콘서트', content = '', place = 'DGT 아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '372744';
UPDATE festival SET title = '[부산] 2026 BCC CHOICE 오페라 <라 칼라스> ', content = '', place = '(재)영화의전당 하늘연극장' WHERE provider_type = 'PUBLIC' AND external_id = '372630';
UPDATE festival SET title = '2026 하남뮤직페스티벌 <뮤직 人 The 하남>', content = '', place = '하남종합운동장' WHERE provider_type = 'PUBLIC' AND external_id = '374379';
UPDATE festival SET title = '[부산] 비바아첼 기획공연, 듀오콘서트시리즈 1. 바이올리니스트 진혜빈 & 조혜란 ', content = '', place = '비바아첼 Chamber Hall & Academy' WHERE provider_type = 'PUBLIC' AND external_id = '375603';
UPDATE festival SET title = '김아름 & 김경란 듀오 리사이틀', content = '', place = '일신홀' WHERE provider_type = 'PUBLIC' AND external_id = '375706';
UPDATE festival SET title = '2026년 차이나타운 문화행사 <차이나는 문화 공연>', content = '', place = '인천 차이나타운 일대 (한중원, 황제계단, 동화마을 입구)' WHERE provider_type = 'PUBLIC' AND external_id = '376251';
UPDATE festival SET title = '[광주] 가족뮤지컬 <겨울이야기>  ', content = '', place = '광주디자인센터 이벤트홀' WHERE provider_type = 'PUBLIC' AND external_id = '372601';
UPDATE festival SET title = '뮤지컬 <만복이네 떡집> ', content = '', place = '다산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '372551';
UPDATE festival SET title = '[대전] K-히어로 뮤지컬 <똥볶이 할멈 : 정의의 맛>', content = '', place = '대전평송청소년문화센터' WHERE provider_type = 'PUBLIC' AND external_id = '372587';
UPDATE festival SET title = '맥화랑초대 강혜은개인전 Hyeeun Kang Solo Exhibition', content = '<!-- wp:paragraph {"align":"center"} -->
<p class="has-text-align-center">선의 축적, 회화의 확장 - 흩뿌려진 풍경 속 색선(色線)의 향연</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>지난 3월 홍콩의 주요 아트페어인 2026 ART CENTRAL HONG KONG(아트 센트럴 홍콩)에서 맥화랑을 통해 Duo Project 섹션에 참가하여 해외 컬렉터 및 미술 시장 관계자들의 큰 주목을 받았던 1956년 생 강혜은 작가의 개인전이 2026년 4월 18일(토)부터 5월 16일(토)까지 부산 해운대 맥화랑에서 개최됩니다. 오랜 시간에 걸쳐 구축된 작가의 독창적인 회화 언어를 조망하는 이번 전시는, 물질과 행위, 시간의 축적이 어떻게 하나의 회화적 장으로 응축되는지를 보여주는 자리입니다. 강혜은 작가는 10여 년에 이르는 치열한 시행착오 끝에, 유화 물감에서 실처럼 가는 선을 뽑아 올리는 고유의 기법을 완성하며 자신만의 조형적 세계를 확립했습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 물감 덩어리에 적절한 압력을 가해 굵고 가는 색선을 압출하듯 끌어내고, 이를 캔버스 위에 반복적으로 쌓아 올리며 화면을 구축합니다. 이러한 과정은 마치 누에가 실을 뽑아 고치를 만들 듯, 혹은 씨실과 날실이 교차하며 직물을 직조하듯 이어집니다. 작가는 작업 과정에서 단전에 힘을 두고 호흡을 조절하며 손끝에 온 신경을 집중하는데, 이러한 반복적이고 집중적인 행위는 마치 수행에 가까운 태도로 완성됩니다. 캔버스 위에서 교차하고 융합하는 색의 선들은 반복되는 행위를 통해 새로운 층을 형성하고, 화면은 점차 다층적인 구조와 깊이를 획득합니다. 가까이에서 보면 추상적인 선과 물감의 물질성이 두드러지지만, 멀리서 바라볼 때는 색과 흐름이 어우러지며 풍경을 연상시키는 장면으로 확장됩니다. 이처럼 축적된 선과 색, 물감의 물리적 두께는 환상적인 색감과 입체적인 질감을 만들어내며, 회화의 표면을 시간과 노동이 응축된 감각적 장으로 확장시킵니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 회화를 신체적 리듬과 시간의 밀도가 응집된 하나의 ‘과정의 흔적’으로 바라보게 합니다. 강혜은 작가의 화면은 수행적 반복과 물질적 축적이 빚어낸 결과이자, 감각과 사유가 교차하는 깊이 있는 공간으로 관객을 이끕니다. 봄의 정취가 짙어지는 해운대 달맞이언덕에서, 관람객은 작가의 축적된 시간과 호흡이 만들어낸 고요하면서도 밀도 높은 회화적 풍경을 마주하게 될 것입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"align":"center","id":18038,"width":840,"height":513,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image aligncenter size-full is-resized"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/04/Line-piece-2635-2026-Oil-on-panel-89.4x145.5cm_00.jpg" alt="" class="wp-image-18038" width="840" height="513" /><figcaption class="wp-element-caption">Line-piece 2635, 2026, Oil on panel, 89.4x145.5cm ⓒGALLERY MAC. 2026.</figcaption></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>A solo exhibition by artist Hyeeun Kang (b. 1956) will be held from April 18 to May 16, 2026, at GALLERY MAC in Haeundae, Busan. This exhibition offers an in-depth look into the artist’s distinctive painterly language, developed over many years, and explores how material, gesture, and the accumulation of time converge into a condensed pictorial field. After more than a decade of experimentation and refinement, Kang has established her own unique visual vocabulary by developing a technique that draws thread-like lines from oil paint, forming the foundation of her practice.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The artist applies controlled pressure to masses of paint, extruding lines of varying thickness, which are then repeatedly layered onto the canvas to construct the image. This process recalls the silkworm spinning its cocoon, or the interweaving of warp and weft in textile production. During her working process, Kang concentrates deeply, regulating her breath and channeling energy through her core to the tips of her fingers. This repetitive and highly focused act approaches a meditative, almost ascetic practice. The intersecting and merging lines of color form new layers through repetition, gradually building a multi-layered structure and depth within the canvas. Viewed up close, the abstract lines and materiality of the paint become prominent; from a distance, however, the flow of color coalesces into evocative, landscape-like imagery. In this way, the accumulated lines, colors, and physical thickness of paint generate a sensorial field in which luminous color and tactile depth expand the surface of painting into a space condensed with time and labor.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>This exhibition invites viewers to reconsider painting not merely as representation, but as a trace of process in which bodily rhythm and the density of time are embedded. Hyeeun Kang’s works are the result of performative repetition and material accumulation, guiding viewers into a contemplative space where sensation and thought intersect. Set against the springtime atmosphere of Dalmaji Hill in Haeundae, the exhibition offers an opportunity to encounter serene yet densely layered painterly landscapes shaped by the artist’s accumulated time and breath.</p>
<!-- /wp:paragraph -->', place = '맥화랑' WHERE provider_type = 'PUBLIC' AND external_id = '376672';
UPDATE festival SET title = '동화발레 <헨젤과 그레텔>', content = '고전동화 <헨젤과 그레텔>의 새로운 해석을 통해 현대사회에서 잊혀져 가는 가족 공동체에 대해 생각해 보는 국내 최초 <헨젤과 그레텔> 전막 K-발레공연', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '372177';
UPDATE festival SET title = '[서울남산국악당] 옴니버스 인형극 <음마갱깽 인형극장>', content = '', place = '남산골한옥마을 서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '372344';
UPDATE festival SET title = '수주 북클럽 <그늘> 4월 크러스너호르커이 라슬로『사탄 탱고』', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '374796';
UPDATE festival SET title = '[고양] MelON 지브리 & 뮤지컬 갈라 오케스트라 콘서트', content = '', place = '고양아람누리 아람음악당' WHERE provider_type = 'PUBLIC' AND external_id = '373096';
UPDATE festival SET title = '[인천] 베토벤 & 라흐마니노프 ', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '373101';
UPDATE festival SET title = '[서울 마포] 지브리 & 디즈니 오케스트라 콘서트 ', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '372760';
UPDATE festival SET title = '김다은 개인전 <다정함이 스미는>', content = '', place = '비커밍갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '374716';
UPDATE festival SET title = '서귀포예술의전당 & 제주특별자치도립 서귀포예술단 공동기획 공연 <아름다운 동행>', content = '', place = '서귀포예술의전당 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '369689';
UPDATE festival SET title = '2026 이원희 초대전 <진경 眞景 : 세상의 모든 풍경>', content = '', place = '갤러리 제이원 서울' WHERE provider_type = 'PUBLIC' AND external_id = '389039';
UPDATE festival SET title = '[꿈의숲아트센터] 꿈의숲 마티네 콘서트 <벨에포크 아트 & 뮤직> 시리즈 1', content = '', place = '꿈의숲아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '371546';
UPDATE festival SET title = '[서울 동작] 춤추는 지휘자 백윤학의 지브리 & 디즈니 OST 페스타 ', content = '', place = '소태산홀' WHERE provider_type = 'PUBLIC' AND external_id = '375873';
UPDATE festival SET title = '[서초문화원] 서초인문학 아카데미 <겪어보면 안다, 그냥 살자> 김홍신 소설가', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '375639';
UPDATE festival SET title = '한국예술종합학교 4월 넷째주 수요영화관 <파더 마더 시스터 브라더>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376495';
UPDATE festival SET title = '창작악단 기획공연 <수작 II>', content = '숫자에 담긴 철학적, 수리적, 상징적 의미를 음악적 아이디어로 구현해 빼어난 국악 실내악 작품을 발굴하는 무대입니다.지난 해에 이은 두 번째 시리즈로 국악이 품고 있는 수의 질서와 그 안에 담겨진 삶의 이야기가 신진 작곡가들의 참신한 창의력과 만나 창작악단의 연주를 통해 ''수작''으로 선보입니다.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '368380';
UPDATE festival SET title = ' 이미현 피아노 독주회 "멈추지 않았던 마음의 선율"', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '373005';
UPDATE festival SET title = '[연희예술극장 X 극단 문지방] 연극 <이해의 적자>', content = '', place = '연희예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '374318';
UPDATE festival SET title = '가족극 <Please Right Back>', content = '영국 극단 1927의 아시아 초연 가족극 〈Please Right Back〉,그래픽노블 비주얼과 노래·춤·코미디가 어우러진 환상적 무대', place = '경기아트센터 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '371016';
UPDATE festival SET title = '[울산] 이은결 <META> ', content = '', place = '울산문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '373302';
UPDATE festival SET title = '2026 청주 국가유산 야행 <압각수의 사계(四季·史計), 천년의 헤아림>', content = '', place = '청주중앙공원, 용두사지철당간, 충북도청, 성안길중앙공원, 용두사지철당간, 충북도청, 성안길' WHERE provider_type = 'PUBLIC' AND external_id = '373906';
UPDATE festival SET title = '2026 함평나비대축제 특별 교육프로그램 <날아라, 나비!>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '377853';
UPDATE festival SET title = '[남원] 국립민속국악원 대표창극 <춘향>', content = '', place = '국립민속국악원 예원당' WHERE provider_type = 'PUBLIC' AND external_id = '374959';
UPDATE festival SET title = '대한민국 제46회 장애인의 날 기념 제23회 사랑의 음악회 ''공감의 선율''', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '374597';
UPDATE festival SET title = '[광주] ACC x QUAD 기언치, 봄 <아따, 구보씨>', content = '', place = '국립아시아문화전당 극장1' WHERE provider_type = 'PUBLIC' AND external_id = '373403';
UPDATE festival SET title = '진주빛마루 유등 상설 체험프로그램 ‘빛나는 창작소’', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376895';
UPDATE festival SET title = '2026 도민의 집 ''주말 예술 캠프''', content = '', place = '경남 도민의 집 앞뜰' WHERE provider_type = 'PUBLIC' AND external_id = '377012';
UPDATE festival SET title = '《건축적 산수》연계 프로그램 <자연을 담은 집>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376069';
UPDATE festival SET title = '[부산] 초록마술사의 쿡 & 매직 ', content = '', place = '초록마술극장' WHERE provider_type = 'PUBLIC' AND external_id = '374966';
UPDATE festival SET title = '2026년 인천개항장 문화지구 ''테라스 콘서트 in 개항장''', content = '', place = '대불호텔 전시관' WHERE provider_type = 'PUBLIC' AND external_id = '376849';
UPDATE festival SET title = '[성남] 베토벤 & 라흐마니노프 ', content = '', place = '성남아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '373749';
UPDATE festival SET title = '[인천] 지브리 & 디즈니 콘서트 ', content = '', place = '아트센터 인천 다목적홀' WHERE provider_type = 'PUBLIC' AND external_id = '373758';
UPDATE festival SET title = 'NAC 시그니처 클래식 시리즈 Ⅱ, 멘델스존 5번 & 패리시 알바스 하프 협주곡', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '373468';
UPDATE festival SET title = '심리스릴러 연극 <베팅>', content = '', place = '극장 봄 (봄소극장) 극장 봄' WHERE provider_type = 'PUBLIC' AND external_id = '374288';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 뮤지엄 다이어리', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376706';
UPDATE festival SET title = '<Modern Magazine 조선의 힙스터 아카이브>', content = '', place = '국립중앙도서관' WHERE provider_type = 'PUBLIC' AND external_id = '379110';
UPDATE festival SET title = 'Net-Zero 1,5°C 의 경고', content = '', place = '국토발전전시관' WHERE provider_type = 'PUBLIC' AND external_id = '399975';
UPDATE festival SET title = 'GS아트센터 × 국립심포니오케스트라 <피터와 늑대 & 어미 거위> ', content = '', place = 'GS아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '376198';
UPDATE festival SET title = '더벨과 함께하는 Musical & Symphony', content = '', place = '세종문화회관 세종대극장' WHERE provider_type = 'PUBLIC' AND external_id = '373740';
UPDATE festival SET title = '[서울] 베토벤 & 라흐마니노프 ', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '373750';
UPDATE festival SET title = '성동구립도서관 박하재홍 작가와 함께하는 ''디스? NO! 피스!''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '377235';
UPDATE festival SET title = '연극 <미세스 마캠> 앵콜 공연', content = '', place = '굿씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '373048';
UPDATE festival SET title = '[평택] 어린이 참여형 인터랙티브 연극 <안녕, 잠!>', content = '', place = '평택서부문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '374156';
UPDATE festival SET title = '2026 <이응노 아카데미: 아시아 현대미술 다시보기> (4/30)', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '375637';
UPDATE festival SET title = '오윤주 피아노 독주회 "영원에서 영원으로"', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '370236';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 묻힌 그릇들은 아직 끝나지 않았다 - 쓰임, 폐기, 그리고 다시 불려진 것들', content = '', place = '한양대학교박물관' WHERE provider_type = 'PUBLIC' AND external_id = '376523';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 2026 세상을 잇는 ‘빛의 말’_종이의 질주', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376724';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 조문국 시공간 미션 어드벤처', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376716';
UPDATE festival SET title = '2026 새빛문화예술클럽 <시민의 메아리> ', content = '', place = '정조테마공연장 어울무대' WHERE provider_type = 'PUBLIC' AND external_id = '387195';
UPDATE festival SET title = '[의정부] 레빛투더문 버블 & 매직쇼 ', content = '', place = '우리소극장 [의정부]' WHERE provider_type = 'PUBLIC' AND external_id = '374742';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 《Still Breathing: 아직 숨 쉬고 있다》 - 상처 입은 동물을 위한 생명 존중의 연대', content = '', place = '사비나미술관' WHERE provider_type = 'PUBLIC' AND external_id = '376520';
UPDATE festival SET title = '2026 영등포아트스퀘어 X 카이스트 경험디자인연구실 특별 전시 <Living Geometry(생동 기하학)>', content = '', place = '타임스퀘어 영등포아트스퀘어' WHERE provider_type = 'PUBLIC' AND external_id = '375752';
UPDATE festival SET title = '[대전] 지브리 & 디즈니 영화음악 FESTA (앵콜)', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '374284';
UPDATE festival SET title = '토요 클래식의 밤, 해설이 있는 클래식: Poeme d''Amour', content = '', place = '콘서트홀 나누' WHERE provider_type = 'PUBLIC' AND external_id = '377339';
UPDATE festival SET title = '[꿈의숲아트센터] 꿈의숲 어린이 마술 콘서트 <쇼프라이즈 II>', content = '', place = '꿈의숲아트센터 퍼포먼스홀' WHERE provider_type = 'PUBLIC' AND external_id = '374562';
UPDATE festival SET title = '2026 동시대미감전 <김덕용:빛과 결, 自生之美> 전시연계_첫 번째, 명상', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376848';
UPDATE festival SET title = '어린이 연극학교 특별 워크숍 ‘엉뚱한 바람이 몹시 불던 날’', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '375643';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 뉴트로 흥부와 놀부: 애니메이션 x 인형극 퍼레이드', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376525';
UPDATE festival SET title = '나빌레라', content = '다음 웹툰 연재 당시 평점 1위를 기록하며 전 세대의 사랑을 받은 동명의 웹툰을 원작으로, 삶의 끝자락에서 발레라는 꿈을 선택한 일흔여섯 노인 ''덕출''과 불안한 청춘 속에서 방황하는 스물셋 청년 ''채록''의 교감과 성장을 그린 작품이다.  2019년 초연 당시 객석 점유율 96%를 기록하고, 2024년 일본 토호와의 라이선스 계약과 2026년 7월 대만 타이중 국립극장 공연을 통해 글로벌 시장에서도 그 작품성을 입증한 서울예술단의 대표 레퍼토리다.', place = '예술의전당 CJ 토월극장' WHERE provider_type = 'PUBLIC' AND external_id = '374217';
UPDATE festival SET title = '2026 토요명품', content = '한민족의 흥과 신명이 살아 숨 쉬는 노래와 음악, 춤을 비롯해세계가 인정한 유네스코 등재 무형문화유산까지 다채롭게 만날 수 있는 국립국악원의 대표 주말 공연 <토요명품>. 한국인과 외국인 모두 꼭 봐야할 한국의 전통 공연 예술이 매주 토요일, 우면당 무대를 가득 채웁니다. 대한민국 최고의 연주가들이 선사하는 <토요명품>을 통해 국악이 가진 아름다움을 느껴보세요.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '376216';
UPDATE festival SET title = '어린이날 기념, 민쿠스 발레 Suite: 돈키호테 & 라 바야데르', content = '', place = '소월아트홀(성동문화회관)' WHERE provider_type = 'PUBLIC' AND external_id = '375096';
UPDATE festival SET title = '[대학로] 연극 < 나의 별> ', content = '', place = '대학로 스카이씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '375606';
UPDATE festival SET title = '어린이날 맞이 디즈니 & 지브리 & 블록버스터 FESTA', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '374425';
UPDATE festival SET title = '들썩들썩인형극 <호랑이 소동>', content = '', place = '북극곰소극장' WHERE provider_type = 'PUBLIC' AND external_id = '375634';
UPDATE festival SET title = '소나기마을 어린이날 특별체험 <얼굴 속에 담긴 사랑>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '378425';
UPDATE festival SET title = '가족뮤지컬 <달샤베트>', content = '백희나 작가의 스테디셀러 「달샤베트」를 원작으로 더위에 지친 동네에 나타난 달샤베트를 통해 이웃 간 따뜻한 나눔과 소소한 행복을 그린 감성 가족뮤지컬', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375750';
UPDATE festival SET title = '[원주 갤러리 원] 이경화 개인전 "연기 -緣起”인연 일다 : partⅤ"', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '378545';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 유연한 공간 공동의 숨 Flexible Space : Breathing Together', content = '', place = '교동아트미술관' WHERE provider_type = 'PUBLIC' AND external_id = '376701';
UPDATE festival SET title = '[성남] 지브리 & 디즈니 OST 콘서트 with 첼로댁 ', content = '', place = '성남아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '374453';
UPDATE festival SET title = '[대전] 슈퍼히어로와 함께 하는 어린이날 영화음악 콘서트: 헐리우드 블록버스터 & 디즈니 & 지브리 영화음악', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '374455';
UPDATE festival SET title = '대학로 청소년연극 <사춘기메들리>', content = '', place = '마루아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '376621';
UPDATE festival SET title = '[PAC] 영국극단 1927 <Please Right Back>', content = '', place = '평택아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '376565';
UPDATE festival SET title = '극단 마음같이 맘 & 맘 페스티벌: 로봇손녀, 사랑입니까, 동행', content = '', place = '제이원씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '374958';
UPDATE festival SET title = '라하브 샤니 & 뮌헨 필하모닉 (05.05)', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '374487';
UPDATE festival SET title = '한국예술종합학교 3월 첫주 수요영화관 <천주정>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '378363';
UPDATE festival SET title = '2026 모두를 위한 예술 프로그램 〈몸으로 만나는 미술관〉 ''공통의 리듬’', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '377053';
UPDATE festival SET title = '대구문화예술회관 미술관 <뮤지엄 아카데미>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '375341';
UPDATE festival SET title = 'CULTUS, Wine & Piano House concert (쿨투스, 와인 & 피아노 하우스 콘서트)', content = '', place = '크레디아 클래식 클럽' WHERE provider_type = 'PUBLIC' AND external_id = '377910';
UPDATE festival SET title = ' <가자 모놀로그 낭독회>', content = '', place = '서울연극센터' WHERE provider_type = 'PUBLIC' AND external_id = '377816';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 모두의 성장소설: The coming of us', content = '', place = '소다 미술관' WHERE provider_type = 'PUBLIC' AND external_id = '376521';
UPDATE festival SET title = '마티네 콘서트: 김영하 작가의 <여행의 이유, 그리고 음악> Ⅱ', content = '수요일 오전, 클래식 음악과 함께 하는 마티네 콘서트.이번 시리즈는 작가 김영하가 함께 합니다. 매월 새로운 이야기와 작가가 직접 선별한 음악 큐레이션을 선보입니다.', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '375818';
UPDATE festival SET title = '<나의 고난은 50분 남았다> - 제47회 서울연극제 자유경연작', content = '', place = '씨어터조이 (구. 마당세실극장)' WHERE provider_type = 'PUBLIC' AND external_id = '376593';
UPDATE festival SET title = '2026 소나기마을 문학교실 <나태주 시인과의 만남>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '378430';
UPDATE festival SET title = '다사랑 클라리넷 앙상블 창단 20주년 기념 음악회 - 스무 살의 울림 “열정”', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '376886';
UPDATE festival SET title = 'LG아트센터 제작, 손상규 연출 ''바냐 삼촌''', content = '', place = 'LG아트센터 서울 LG SIGNATURE 홀' WHERE provider_type = 'PUBLIC' AND external_id = '375247';
UPDATE festival SET title = '가족서커스 〈칠드런 아 스팅키〉', content = '어린이 공연 최고 평점, 국제 무대에서 인정받은 에든버러 프린지 페스티벌 공식 선정작. 움직임과 리듬 중심의 무대를 통해 아이의 신체 표현과 창의적 사고를 확장하는 <가족 서커스>', place = '성남아트센터 앙상블씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '376086';
UPDATE festival SET title = 'GS아트센터 X 국립발레단 더블 빌_맥그리거 & 테틀리', content = 'GS아트센터와 국립발레단은 5월, 동시대 예술의 정점에 이른 현대 발레 작품 두 편—웨인 맥그리거의 <인프라>와 글렌 테틀리의 <봄의 제전>을 한 무대에 올린다. 도시의 심연을 응시하는 절제된 시선과 원초적 에너지가 분출되는 뜨거운 제의가 선명한 대비를 이루며, 현대 발레가 지닌 폭넓은 미학적 스펙트럼을 경험하게 할 것이다.', place = 'GS아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '376084';
UPDATE festival SET title = '제목전(展) ', content = '사람이든 사물이든, 어떤 대상을 맞닥뜨릴 때 가장 먼저 마주하는 것이 바로 ‘이름’이다. 이름은 그 대상을 인식하는 가장 짧고도 강력한 언어다. 그렇기에 우리는 이름을 짓는 데 적지 않은 시간과 에너지를 들인다.수십 억의 예산과 수많은 인력이 투입되는 영화에서 제목은 어떠한 의미를 지닐까. 영화 제목은 영화가 품고 있는 세계의 다성적 측면들을 한 줄, 혹은 한 단어로 응축한 결과물이다. 제목은 스크린이 열리기도 전에, 관객으로 하여금 영화의 본질을 상상하면서 자신만의 예고편을 머릿속에서 상영하게 한다. 또한 제목은 그 자체로 특정 시대를 반영하는 징후이자, 대중의 감각을 드러내는 기호다. 한자가 섞인 고풍스러운 문어체가 스크린을 지배했던 시대가 있는가 하면, 정체불명의 외래어가 ‘세련’의 징표처럼 불려 나온 시대가 있었고, 생활의 요청을 반영하는 나른한 구어체 제목이 풍미하기도 했다. 곧 제목 짓기의 변천사는 한국 사회의 문화 트렌드, 변덕스러운 대중의 감성을 반영해 왔다. < 제목전(展) – 텍스트, 타이포그래피, 무빙 이미지>은 1919년부터 2025년까지 공개된 한국영화 8,400여 편의 제목을 다양한 키워드로 재배열하고 분석해 한국영화를 바라보는 새로운 레퍼런스를 제시한다. 가장 빈번하게 등장하는 단어를 통해 시대별 정서와 서사의 흐름을 읽어내고, 한국영화사를 대표하는 배우의 필모그래피를 제목의 관점에서 조명한다. 또한 젠더, 색채, 문장 구조 등 여러 층위의 필터를 가져와 한국영화사를 새로운 관점으로 바라보고자 한다. 제목이 지닌 조형적 미학에도 주목한다. 오프닝 시퀀스 속 제목의 움직임, 포스터와 전단에서 마주하는 다양한 제목 서체와 디자인은 영화의 정서를 시각적으로 구현하는 장치인 동시에 그 자체로 한글의 아름다움을 증명한다. 전시실 벽면을 가득 채운 자유롭게 생동하는 레터링과 캘리그래피, 동시대 감독과 그래픽 디자이너가 각자의 시선으로 재해석한 애니메이션과 영상 작업은, 익숙한 영화 제목에 새로운 호흡을 불어넣는다.< 제목전(展) – 텍스트, 타이포그래피, 무빙 이미지>은 정지된 텍스트로 존재하던 영화 제목을 다시 움직이게 하고, 새로이 읽히도록 하는 것을 넘어 ‘경험’의 대상으로 확장한다. 이름은 더 이상 부르는 것에 머무르지 않는다. 이곳에서 제목은, 다시 살아 움직인다.', place = '한국영화박물관' WHERE provider_type = 'PUBLIC' AND external_id = '378574';
UPDATE festival SET title = '[인천] 라하브 샤니 & 뮌헨 필하모닉 ', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '375144';
UPDATE festival SET title = '[서울 강동] 지브리 & 디즈니 OST 콘서트 ', content = '', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '375110';
UPDATE festival SET title = '[꿈의숲아트센터] 올리브와 찐콩 <나와 몬스터 그리고 가방>', content = '', place = '꿈의숲아트센터 퍼포먼스홀' WHERE provider_type = 'PUBLIC' AND external_id = '375820';
UPDATE festival SET title = '<감정 연습> - 제47회 서울연극제 공식선정작', content = '', place = '서울연극창작센터 서울씨어터 202 (5F )' WHERE provider_type = 'PUBLIC' AND external_id = '378370';
UPDATE festival SET title = '김선주 피아노 독주회 XXI-''피아노에게 관현악이란?..''(Symphonic Imagination in Piano)', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '376071';
UPDATE festival SET title = '바흐솔리스텐서울 - 헨델의 오페라 <아치스와 갈라테아>', content = '', place = '예술의전당 [서울]' WHERE provider_type = 'PUBLIC' AND external_id = '375244';
UPDATE festival SET title = '트라이보울 클래식 페스티벌, 실내악 시리즈: 문태국 & 박종해 듀오', content = '', place = '트라이보울 공연장 (2층)' WHERE provider_type = 'PUBLIC' AND external_id = '375120';
UPDATE festival SET title = '[남원] 2026 어린이 국악뮤지컬 <별이와 무지개다리>', content = '', place = '국립민속국악원 예원당' WHERE provider_type = 'PUBLIC' AND external_id = '378202';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 <체어, 테이블, 체어>', content = '', place = '국립극장 무대예술지원센터' WHERE provider_type = 'PUBLIC' AND external_id = '378544';
UPDATE festival SET title = '<안녕, 잠!> 2026 꿈밭펀딩 그린 스테이지', content = '', place = '아르코 꿈밭극장' WHERE provider_type = 'PUBLIC' AND external_id = '376375';
UPDATE festival SET title = '뮤지컬 <100층짜리 집>', content = '도치가 초대장을 따라 100층 집을 오르며 다양한 친구들을 만나는 이야기로, 베스트셀러 원작을 바탕으로 한 가족 뮤지컬', place = '세종문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '373931';
UPDATE festival SET title = '2026 모두를 위한 예술 프로그램 〈쉬운 미술관〉 ''끝없는 이야기’', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '377052';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 모두를 위한 감각 식탁', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376725';
UPDATE festival SET title = '''사색의 운동회-장애물을 긍정하며'' 전시연계 교육 《좋았어 장애물》', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '377632';
UPDATE festival SET title = '최현우 WORK IN PROGRESS Vol.1 <FaTe>', content = '', place = '소월아트홀(성동문화회관)' WHERE provider_type = 'PUBLIC' AND external_id = '375100';
UPDATE festival SET title = '디바만리 D.Va.Man.Ri 김만리·타이헨전', content = '', place = '모두예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '379921';
UPDATE festival SET title = '김광훈 바이올린 독주회: Beethoven & Ysaye Solo Sonatas Complete Series Ⅲ', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '375518';
UPDATE festival SET title = '[인천] 트라이보울 클래식 페스티벌, 아렌트 & 정민호: Early Musique', content = '', place = '트라이보울 공연장 (2층)' WHERE provider_type = 'PUBLIC' AND external_id = '375911';
UPDATE festival SET title = '모소 박명주 개인전 <꽃으로 쓴 시>', content = '', place = '비커밍갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '378269';
UPDATE festival SET title = '信 Young Artist X K''ARTS Audition 수상자 리사이틀: 피아니스트 김영현', content = '', place = '신영체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '376780';
UPDATE festival SET title = '쓰리 커튼콜', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '375590';
UPDATE festival SET title = '2026 김근태기념도서관 민주주의·인권 기획전 《닿다》', content = '', place = '김근태기념도서관' WHERE provider_type = 'PUBLIC' AND external_id = '381212';
UPDATE festival SET title = '제23회 부산국제연극제, 초청작 <탐엣더팜(Tom at the Farm)>', content = '', place = '(재)영화의전당 하늘연극장' WHERE provider_type = 'PUBLIC' AND external_id = '375495';
UPDATE festival SET title = '안성맞춤아트홀 문화가 있는 날: 아트-데이 창극 <나무, 물고기, 달> (영상화)', content = '', place = '안성맞춤아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '375714';
UPDATE festival SET title = '국립합창단 제207회 정기연주회 <모차르트 c단조 대미사>', content = '모차르트의 <참회자의 엄숙한 저녁 기도>와 <c단조 대미사>는 종교를 넘어서 인간 내면의 깊은 감정과 숭고한 울림을 전해주는 위대한 걸작으로 평가 받는 작품이다.', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '376022';
UPDATE festival SET title = '제23회 부산국제연극제, 삶과 죽음: 아주 오래된 이야기 (Life & Death: the old, old story)', content = '', place = '어댑터씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '375713';
UPDATE festival SET title = '[울산] 넌버벌퍼포먼스 <페인터즈> ', content = '', place = '현대예술관' WHERE provider_type = 'PUBLIC' AND external_id = '375901';
UPDATE festival SET title = '2026 <이응노 아카데미: 아시아 현대미술 다시보기> (5/14)', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '378131';
UPDATE festival SET title = '국립국악관현악단 소년소녀를 위한 <소소 음악회>', content = '', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '373963';
UPDATE festival SET title = '서리풀 전곡 연주 시리즈 <하이든 교향곡 33 ''Military''>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '378416';
UPDATE festival SET title = '소년소녀를 위한 <소소 음악회>', content = '너의 감정이 들려! 국악관현악판 ''인사이드 아웃''듣고 보는 즐거움이 가득한 청소년 맞춤 국악 콘서트', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '375806';
UPDATE festival SET title = '연극 <국어의시간> ', content = '', place = '한국콘텐츠진흥원 CKL스테이지' WHERE provider_type = 'PUBLIC' AND external_id = '376061';
UPDATE festival SET title = '629돌 세종대왕 나신 날, <여민락, 세상과 함께 즐기다>', content = '', place = '경복궁 흥례문 광장' WHERE provider_type = 'PUBLIC' AND external_id = '379675';
UPDATE festival SET title = '세종대왕 나신 날 기념 <가나다락-글놀이 말놀이> 특별 해설', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '380187';
UPDATE festival SET title = '[대전] 유병혜 첼로 리사이틀 Ⅷ. Monologue & Dialogue', content = '', place = '대전예술의전당 앙상블홀' WHERE provider_type = 'PUBLIC' AND external_id = '376944';
UPDATE festival SET title = '2026 성남작가조명전 Ⅱ <김홍년: 꿈의 대화>', content = '', place = '성남큐브미술관' WHERE provider_type = 'PUBLIC' AND external_id = '385363';
UPDATE festival SET title = '[화성] 경기공연 예술 어워즈, 말러 교향곡 4번 "천상의 삶" ', content = '', place = '반석아트홀(동탄복합문화센터)' WHERE provider_type = 'PUBLIC' AND external_id = '379042';
UPDATE festival SET title = '[서울] ACC x QUAD 기언치, 봄 <아따, 구보씨>', content = '', place = '서울문화재단 대학로극장 쿼드' WHERE provider_type = 'PUBLIC' AND external_id = '373330';
UPDATE festival SET title = '2026 어텐션라이브 Ⅰ - 스컬&하하 + 별 + Band SRG', content = '스컬&하하''가 선보이는 레게의 열기에 감성보컬 ''별'' 한 스푼 더', place = '용인시문화예술회관 처인홀' WHERE provider_type = 'PUBLIC' AND external_id = '375823';
UPDATE festival SET title = '2026 브런치 콘서트 <5월 : 유럽을 건너, 바로크부터 현대까지>', content = '귀로 듣는 미술관, 명화 해설과 함께 듣는 클래식 공연', place = '용인시평생학습관 큰어울마당' WHERE provider_type = 'PUBLIC' AND external_id = '375824';
UPDATE festival SET title = '[PAC] 국립심포니오케스트라 <파리의 아메리카인>', content = '', place = '평택아트센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '376490';
UPDATE festival SET title = '윤경온 첼로 독주회 "All Beethoven Part I"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '374307';
UPDATE festival SET title = '경기리베라오케스트라 제2회 정기연주회 <봄의 소동(騷動)>', content = '피아니스트 김정원과 함께하는 경기리베라오케스트라 제2회 정기연주회', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375024';
UPDATE festival SET title = '《내가 만든 규칙》강석호 × 남다현 × 허창범', content = '', place = 'PS CENTER' WHERE provider_type = 'PUBLIC' AND external_id = '378695';
UPDATE festival SET title = '[부산] 제2회 뮤지컬아! 놀자!, 뮤지컬 <영웅> ', content = '', place = '을숙도문화회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '376422';
UPDATE festival SET title = '2026년 국립해양박물관 테마전시 <푸른 심장, 맹그로브>', content = '', place = '국립해양박물관' WHERE provider_type = 'PUBLIC' AND external_id = '387676';
UPDATE festival SET title = '[원주 갤러리 원] 마해송 개인전 ''1평''', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '380785';
UPDATE festival SET title = '제68회 창악회 정기발표회: CMSS Festival Ⅱ & Ⅲ', content = '', place = '일신홀' WHERE provider_type = 'PUBLIC' AND external_id = '379839';
UPDATE festival SET title = '바이올린 윤여영 & 첼로 장우리 듀오 리사이틀', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '378302';
UPDATE festival SET title = '동대문구 아르코 2026년 기획공연 <콘서트 청(淸):ON(5월)>', content = '', place = '동대문구 아르코(DDM ARCO)' WHERE provider_type = 'PUBLIC' AND external_id = '377525';
UPDATE festival SET title = '[제천] 클라라 주미강 & 김선욱 듀오 리사이틀', content = '', place = '제천예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '377407';
UPDATE festival SET title = '5월 국회문화극장 <국립창극단과 함께 하는 ''우리 소리,판소리''> ', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '380280';
UPDATE festival SET title = '﻿2026 대전테미예술창작센터 오픈스튜디오·전시', content = '', place = '대전문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '379924';
UPDATE festival SET title = '[대구] DSAC 아트 셀렉션, 이혁 & 이효 듀오 리사이틀', content = '', place = '웃는얼굴아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '376967';
UPDATE festival SET title = '[부천] 부천아트센터 개관 3주년 페스티벌: 클라라 주미 강 & 김선욱 듀오 리사이틀', content = '', place = '부천아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '376981';
UPDATE festival SET title = 'Hide and Seek', content = '<!-- wp:image {"id":18810,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/06/DSC3761.jpg" alt="" class="wp-image-18810" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>■ Artist : 박진주 (Park Jin-ju)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■ Title : Hide and Seek </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■ Dates : 2026. 05. 27(Wed) — 06. 17(Wed)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■ Venue : GALLERY J. ONE (대구 중구 봉산문화길 60) </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■ Hours : 10:30 AM — 06:30 PM (Sun Closed) </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■ Inquiry : 053-252-0614</p>
<!-- /wp:paragraph -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity" />
<!-- /wp:separator -->

<!-- wp:paragraph -->
<p>박진주의 작업은 타자라는 거대한 숲에서 어느 곳에도 온전히 섞이지 못한 채 부유하던 연약한 자아가, 스스로를 지켜내기 위해 채택한 가장 애틋하고도 당당한 생존의 방법론이다. 작가는 외부로부터 내면을 숨기고 드러내는 경계로서의 신체를 제시해왔다. 그 외피에 맺히는 상처와 흔적들을 반투명한 비단 위에 물붓질로 섬세히 그려내며, 숨겨진 내면을 조심스레 더듬어보는 과정을 보여준다. 그러한 과정을 여전히 하나의 층위로 함께 두면서, 이번 전시 Hide and Seek는 그 은밀한 숨바꼭질의 문법이 한층 더 내밀한 심연으로 침잠하고 있음을 보여준다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 이제 단순히 내면의 흔적을 더듬어보는 것에 머물지 않고 오랫동안 외면해왔던 그들의 근원, 내면의 밀실인 붉은 방의 문을 기어코 열어젖히려 한다. 누군가 은밀히 숨어 있을만한 방은 신체의 외피가 아닌 내피, 즉 내장의 질감과 붉은 색채를 띄고 있고, 그 안에서는 무슨 일이 일어났을지, 어떤 불온한 서사가 이루어지고 있을지 상상하게 만든다. 작가는 사람들의 애정을 갈구하는 모습이 추하게 느껴지던 순간들, 당연하게 느낄 수밖에 없는 슬픔이 죄스러웠던 때, 삶의 한가운데 있으면서 죽음과 타인을 동시에 떠올리던 어느 밤이 그곳에 축축하게 존재한다고 증언한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그러나 작가는 이 죄의식과 욕망으로 뒤엉킨 방 한켠에서 절망 대신 새로운 통로를 발견한다. 세상과 불화할 수밖에 없는 모습들이 이곳에 있는 이유가, 불완전한 스스로가 누군가와 함께하기 위함이었을지도 모른다는 생각에 이르게 된다. 자신 혹은 타인일지도 모르는 두루뭉술한 인물들, 붉은 벽과 검푸른 밤이 얇은 한지 위에서 한데 뒤엉키고 번져나가 서로에게 가닿으며, 이 지독한 자기 응시는 역설적이게도 가장 강력한 연결의 의지로 귀결된다. 세상에서 사라지게 하고 싶은 면모조차 결국 나를 이루는 일부임을 인정하게 된 용기는, 이제 자신의 상흔을 불온한 치부가 아닌 타인과 연결될 수 있는 투명한 통로로 치환한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그리하여 박진주가 제안하는 이번 전시는 단순한 유희의 차원을 넘어선다. 스스로를 숨기고(숨), 세상를 향해 역할을 바꾸며(바), 마침내 오롯한 자신으로 회복하고자 하는 열망(꿈)에 도달하는 것. 이것은 작가가 온몸으로 밀고 나간 숨바꿈의 뜨거운 숨결이자, 붉은 방의 문을 열고 나온 자만이 건넬 수 있는 가장 당당한 고백이다. 전시장에 부유하는 흐릿한 몸의 초상들은 단순한 재현을 넘어, 작가가 세상과 공존하기 위해 버텨온 흔적이자 차마 입 밖으로 내지 못한 말들이 맺힌 심리적 자화상으로 다가온다. 관객들은 작가가 마련한 붉은 방의 술래가 되어, 그가 견딜 수 있을 만큼만 꺼내놓은 진실의 조각들을 발견하게 될 것이다. 그것은 비단 한 예술가의 기록을 넘어, 각자의 내면에 저마다의 방을 품고 살아가는 우리 모두에게 “나는 세상을 이렇게 보고 있으며, 그럼에도 불구하고 당신과 함께 살아가고 싶다”라고 건네는 지독하고도 아름다운 위로의 잔상이다.</p>
<!-- /wp:paragraph -->', place = '갤러리제이원' WHERE provider_type = 'PUBLIC' AND external_id = '382519';
UPDATE festival SET title = '[평택] 클라라 주미 강 & 김선욱 듀오 리사이틀', content = '', place = '평택아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '377120';
UPDATE festival SET title = 'MU&A 스튜디오 기획 시리즈, 귀로 읽는 밤', content = '', place = '뮤직앤아트스튜디오' WHERE provider_type = 'PUBLIC' AND external_id = '379493';
UPDATE festival SET title = '[PAC] 클라라 주미 강 & 김선욱 듀오 리사이틀', content = '', place = '평택아트센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '376564';
UPDATE festival SET title = '소프라노 이지혜 & 피아노 심관섭 ''Duo Lieder Abend''', content = '', place = '영산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '378495';
UPDATE festival SET title = 'ASAC 연극 화류비련극 <홍도>', content = '예지원·박하선·정보선 등 연기파 배우 총출동! 2026년 가장 완벽한 <홍도>가 온다. 신파의 틀을 깨고 탄생한 가장 뜨겁고 세련된 비극', place = '안산문화예술의전당 해돋이극장' WHERE provider_type = 'PUBLIC' AND external_id = '374595';
UPDATE festival SET title = '<화성에서의 나날> - 제47회 서울연극제 공식선정작', content = '화성 탐사와 개발을 위해 환과 욱, 그리고 5명의 지원자들이 우주선에 오른다. 동료들을 잃고 서로만 남은 두 사람은 무엇을 할 수 있을까?', place = '대학로예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375761';
UPDATE festival SET title = '2026 창작ing 연극 <양떼목장의 대혈투>', content = '비인간의 시선으로 인간을 되비추는 우화극', place = '국립정동극장 세실' WHERE provider_type = 'PUBLIC' AND external_id = '375046';
UPDATE festival SET title = '비바아첼 듀오콘서트 시리즈 2. 바이올리니스트 조혜란 & 이 진', content = '', place = '비바아첼 Chamber Hall & Academy' WHERE provider_type = 'PUBLIC' AND external_id = '380900';
UPDATE festival SET title = '[서울] 클라라 주미 강 & 김선욱 듀오 리사이틀 (05.23)', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '377346';
UPDATE festival SET title = '한경진 & 이영희의 브람스: 세 개의 소나타, 하나의 여정', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '377400';
UPDATE festival SET title = '[대전] KBS 환경사랑음악회: 다니엘 린데만 & 천지윤의 푸른음악회 ', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379232';
UPDATE festival SET title = '[전주] 2026년 전주브랜드공연(마당창극) ''별향단젼이라''', content = '', place = '전주한벽문화관 야외공연장' WHERE provider_type = 'PUBLIC' AND external_id = '379831';
UPDATE festival SET title = '[인천 서구] 미디어 상상놀이극 ''거인의 책상''', content = '', place = '문화공간터틀 검단 4F' WHERE provider_type = 'PUBLIC' AND external_id = '379590';
UPDATE festival SET title = '2026 제작공연 시리즈 名作 2. 명창 박정욱 <황해도 철물이굿>', content = '', place = '평택서부문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '376766';
UPDATE festival SET title = '영등포아트홀 기획공연 발레 <피터팬>', content = '', place = '영등포아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '377303';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 <붐업 Boom up!>', content = '', place = '국립극장 무대예술지원센터' WHERE provider_type = 'PUBLIC' AND external_id = '379916';
UPDATE festival SET title = '공감 사랑, 행복 뮤지컬 콘서트 <힐링 인 더 라디오>', content = '', place = '인천수봉문화회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '379554';
UPDATE festival SET title = '[인천] 클래식 인사이트 I: 명 앙상블, 러브 & 그레이스', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '377421';
UPDATE festival SET title = '마이온무브 현대무용 기획공연 <ACCOMPANY>', content = '', place = '서강대 메리홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '379399';
UPDATE festival SET title = '[동해] 클라라 주미 강 & 김선욱 듀오 리사이틀', content = '', place = '동해문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '377589';
UPDATE festival SET title = '이혁 & 이효 듀오 리사이틀', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '377499';
UPDATE festival SET title = '[강릉] 클라라 주미 강 & 김선욱 듀오 리사이틀', content = '', place = '강릉아트센터 사임당홀' WHERE provider_type = 'PUBLIC' AND external_id = '377670';
UPDATE festival SET title = '임재민 기타 리사이틀 "The Dual Crown: Sor & Giuliani"', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '376014';
UPDATE festival SET title = '트로트 뮤지컬 <명랑가족>', content = '개그맨&트로트 가왕 심해룡의 세상에서 가장 열광적인 로그아웃', place = '경기아트센터 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '375023';
UPDATE festival SET title = '2026 다담', content = '2월부터 11월까지 매월 마지막 주 수요일 오전 11시에는 국악과 차, 그리고 이야기가 함께하는 <다담>이 열립니다.다담지기 황수경 아나운서의 진행으로 예술같은 삶을 살고 있는사회 각 분야의 저명 인사를 초청해 이야기와 우리 음악을 나누는토크 콘서트 입니다.진솔한 삶의 이야기에 더해지는 우리 음악 한 잔!오전의 설레이는 햇살 같은 특별한 시간을 느껴보세요.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '376218';
UPDATE festival SET title = '안성맞춤아트홀 ''문화가 있는 날:아트-데이'' 가장 가까운 국립극장 창극 <귀토, 토끼의 팔란>', content = '', place = '안성맞춤아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '377752';
UPDATE festival SET title = '[성남] 2026 성남아트리움 <모닝 콘서트> 재즈보컬리스트 웅산 ', content = '', place = '성남아트리움' WHERE provider_type = 'PUBLIC' AND external_id = '377941';
UPDATE festival SET title = '[이천] 마티네콘서트 이응광의 음악공방 3rd, 재즈피아니스트 조윤성 & 재즈보컬리스트 베티황', content = '', place = '이천아트홀 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '377943';
UPDATE festival SET title = '이응노 아카데미 <한국의 단색화 : 전통과 결합한 추상>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '380132';
UPDATE festival SET title = '2026 로컬레이어 <사물이 비워진 자리> 장백순 작가와의 대화', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '379322';
UPDATE festival SET title = '2026 동시대미감전 <김덕용: 빛과 결, 自生之美> 전시 연계_두 번째, 미감', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '379531';
UPDATE festival SET title = ' (사)서울클래식앙상블 창단연주회 "First Resonance: Beyond Time and Borders"', content = '', place = '일신홀' WHERE provider_type = 'PUBLIC' AND external_id = '374312';
UPDATE festival SET title = '[연희예술극장 X 더 베터하프] 연극 <꿰맨 눈의 마을>', content = '', place = '연희예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '378141';
UPDATE festival SET title = '판소리 시(詩)네마 오페라 <소월>', content = '', place = '문학시어터' WHERE provider_type = 'PUBLIC' AND external_id = '377852';
UPDATE festival SET title = '정태후: 벤딩 노터 호랑이, 후 (BENDING NOTER TIGER, HU)', content = '<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">갤러리FM은 2026년 5월 28일부터 6월 16일까지 정태후 개인전 《벤딩 노터 호랑이, 후》를 개최한다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">정태후는 인간의 고유한 감정이 어떻게 고양되고, 미끄러져 나가는지에 관심을 둔다. 재즈 연주자가 음을 꺾고 올리는 벤딩을 통해, 제도화된 음표와 가공되지 않은 인간의 감정 사이에 존재하는 미세한 어긋남의 영역을 포착하는 것과 같다. 《벤딩 노터 호랑이, 후 (BENDING NOTER TIGER, HU)》에는 새떼들처럼 집단이 등장하기도 하지만 대체로, 호랑이, 소년 등 홀로 있는 경우가 많다. 그럼에도 불구하고 우리가 태고적부터 쌓아왔을 인간이라는 존재가 쌓아두었을 ‘감정의 테’에 더 가까이 다가려고 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">‘벤딩 노터 호랑이 후’라는 전시명은 한 문장으로 완결되지 않는다. 음과 음 사이, 어디에도 속하지 않는 소리. 연주자는 악보를 따르는 대신 본래의 음을 의도적으로 미끄러뜨리고 구부리는 것을 ‘벤딩(Bending)’이라 부르듯이 전시명도 일부러 미끄러뜨리고 구부렸다. 재즈 연주자가 음을 블루 노트(Blue Note)를 향해 음을 끌어올릴 때 생기는 그 긴장감처럼 작가는 푸른색과 붉은 색, 주황색, 노랑계열의 색을 거침없이 사용한다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">작가는 살갗에 바람이 스치는 순간을 그린 <살바람>, <허공의 틈>, 숨이 턱끝까지 차오르며 질주하는 소년, 새 떼가 한꺼번에 날아오를 때의 황홀감을 담은 다수의 작품들, 푸른 물 속에 잠긴 수영하는 소년을 그린 <헤에엄>을 통해 진정한 자유로움에 대해 질문을 던진다. 푸른 호랑이를 그린 작품 <아우라>는 마치 패션쇼 무대로 걸어나오는 것처럼 보인다. 그동안 클리셰로 자주 등장하는 호랑이는 신성함(Sacredness)과 공포(Terror) 사이의 아슬아슬한 경계에 있었다. 호랑이는 동아시아 신화 속에 자주 등장하는 영물로 최근엔 ‘식민지적 비애(Melancholy)’ 같은 거대한 집단적 감정을 대체해왔다. 하지만 <아우라>의 호랑이는 K-POP스타처럼 오로지 신비롭고도 위풍당당하게 등장한다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">AI시대는 어쩌면 뒤에 혁명을 붙여야 할 수 도 있을 것이다. 농업혁명, 산업혁명처럼. 정태후는 이 혁명과 같은 시대에 인간의 고유한 감각과 기계가 대체할 수 없는 감정, 여전히 미끄러지는 일상에서도 붙들어매는 인간의 자유에 대해 질문을 던진다.</p>
<!-- /wp:paragraph -->', place = '갤러리FM' WHERE provider_type = 'PUBLIC' AND external_id = '382349';
UPDATE festival SET title = '2026 수주문학관 기획전시 <술로 자라서 글에 살고>展', content = '', place = '부천문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '382397';
UPDATE festival SET title = '아트내상스 디스커버리시리즈1 <20세기 명품 영미음악을 만나다 -Gilbert, Sullivan Gershwin>', content = '', place = '금정문화회관 대공연장(금빛누리홀)' WHERE provider_type = 'PUBLIC' AND external_id = '380276';
UPDATE festival SET title = '박유신 & 한지호 듀오 리사이틀', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '378904';
UPDATE festival SET title = '연극 <벌쓰>', content = '', place = '나인진홀 1관 (1층)' WHERE provider_type = 'PUBLIC' AND external_id = '380613';
UPDATE festival SET title = '[익산] 클라라 주미 강 & 김선욱 듀오 리사이틀', content = '', place = '익산예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '378328';
UPDATE festival SET title = '이금희와 함께하는 오후 2시 <다정한 클래식> 5월 - 봄날의 하루', content = '', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '377468';
UPDATE festival SET title = '2026 서리풀 작곡가 탐구 시리즈 <더블베이스의 시작과 여정>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '378367';
UPDATE festival SET title = '고양시의 노래: Let''s Go 미국, 캐나다, 멕시코', content = '', place = '고양아람누리 새라새극장' WHERE provider_type = 'PUBLIC' AND external_id = '381510';
UPDATE festival SET title = '평화체험축제 ''동탄에 평화온:담''', content = '', place = '동탄호수공원 운답원 잔디마당' WHERE provider_type = 'PUBLIC' AND external_id = '380581';
UPDATE festival SET title = '2026 상반기 시민 교양 강좌 <경계 위의 그녀, 우리의 삶을 말하다>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '386849';
UPDATE festival SET title = '[남원] 2026 어린이 무용극 <공주전> ', content = '', place = '국립민속국악원 예원당' WHERE provider_type = 'PUBLIC' AND external_id = '379058';
UPDATE festival SET title = '[대전] 어린이 서커스쇼 & 초대형레이져공연 ', content = '', place = '대전평송청소년문화센터' WHERE provider_type = 'PUBLIC' AND external_id = '378791';
UPDATE festival SET title = '이경현 개인전 <우리의 이야기>', content = '', place = '비커밍갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '381350';
UPDATE festival SET title = '2026 이우림 초대전 <푸른잠 The Blue Slumber>', content = '', place = '갤러리 제이원 서울' WHERE provider_type = 'PUBLIC' AND external_id = '389040';
UPDATE festival SET title = '류정하 개인전 <닿아 있는 벽 사이의 벽 Structures That Lean>', content = '', place = '16아카이브' WHERE provider_type = 'PUBLIC' AND external_id = '381954';
UPDATE festival SET title = '[부산] 극단 ''포용무대'' 창단 기념 공연 - 연극 <청춘 사진관>', content = '', place = '공간소극장 [대연역]' WHERE provider_type = 'PUBLIC' AND external_id = '382008';
UPDATE festival SET title = '[원주 갤러리 원] 서민지 개인전 "DAZZLING APPLE : 나의 꿈, 나의 사과"', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '382940';
UPDATE festival SET title = '겹쳐진 온도', content = '<!-- wp:paragraph -->
<p>히든엠갤러리는 6월4일부터 6월 25일까지 김기정, 권소영, 박성수, 윤수현 작가의 4인전 <겹쳐진 온도>를 개최한다. 서로 다른 감정의 결을 지닌 네 명의 작가가 각자의 방식으로 구축해온 내면의 풍경과 감각의 흐름을 한 공간 안에 펼쳐 보인다. 이번 전시는 색채와 질감, 회화와 자수, 빛과 이미지의 언어를 통해 감정이 형성되고 스며드는 과정을 탐색하며, 익숙한 일상과 자연, 기억과 불안, 온기와 고요 사이를 오가는 감각의 층위를 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>서로 다른 감각과 정서는 개인의 내면 안에서 끊임없이 교차하고 중첩되며 복합적인 층위를 형성한다. 이러한 감정의 비가시적인 흐름에 주목하며, 네 명의 작가가 각자의 시선과 조형 언어를 통해 구축해온 내면의 풍경들을 하나의 공간 안에 펼쳐 보인다. 서로 다른 작업들은 독립적인 감각 체계를 유지하면서도 전시장 안에서 서로의 정서를 느슨하게 연결하고 반응시키며 하나의 감각적 흐름을 형성한다. 작품 사이를 이동하는 과정 속에서 색채와 질감, 밀도와 여백이 만들어내는 감각을 따라가며 각기 다른 감정의 온도를 경험하게 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시에서 작가들은 감정을 직접적으로 설명하거나 재현하기보다 사물과 풍경, 동물과 빛, 색채와 물성을 통해 내면의 상태를 우회적으로 드러낸다. 작품들은 명확한 서사보다는 감각의 여운으로 남고, 화면 안에 축적된 흔적들은 설명 이전의 감정을 환기시킨다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이처럼 <겹쳐진 온도>는 특정한 감정을 하나의 방향으로 수렴시키기보다 서로 다른 감각의 층위들이 공존하고 스며드는 상태 자체를 보여주고자 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>김기정작가는 집과 방, 이불과 벽지처럼 가장 가까이에 존재하는 일상의 풍경을 통해 익숙함에서 비롯되는 안정과 포근함의 감각을 담아낸다. 작가의 작품 속 공간은 단순한 장소의 재현이 아니라 감정이 머무는 심리적 공간으로 작동하며, 부드러운 질감과 푸른 색조의 잔상은 쉽게 드러낼 수 없었던 내면의 감정을 조용히 감싸 안는다. 반복적으로 등장하는 사물과 공간은 기억과 감정이 축적된 흔적으로 남아 관람자 각자의 사적인 풍경을 떠올리게 만든다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>권소영작가는 자연을 고정된 풍경으로 재현하기보다 감각과 기억, 인식이 끊임없이 교차하는 유동적인 상태로 바라본다. 작품속에서는 인간과 자연의 경계, 현실과 감각의 층위가 흐릿하게 뒤섞이며 하나의 낯선 풍경을 형성한다. 색채와 형태는 고정되지 않은 채 서로 스며들고 이는 끊임없이 흔들리고 이동하는 내면의 흐름을 은유적으로 드러낸다. 작가의 작업은 외부 세계를 묘사하는 데 머물지 않고, 감각이 생성되고 해체되는 과정을 시각적으로 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>박성수작가는 유화와 자수, 바느질의 행위를 더하며 감정의 밀도를 축적해나간다. 작품 속 실의 흔적과 반복적인 바느질의 과정은 감정을 천천히 축적하고 기록하는 방식으로 작동한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>선명한 색채와 자수의 흔적은 작품에 강렬한 인상을 남기지만, 작가는 자신의 감정을 직접적으로 드러내기보다 익숙한 이미지들을 통해 간접적으로 풀어낸다. 작품 속에 반복적으로 등장하는 개와 고양이는 단순한 동물의 이미지가 아니라 작가 자신을 대신하는 존재로 등장하며, 내면의 상태와 감정을 간접적으로 드러낸다. 친숙한 이미지 속에는 작가의 감정과 기억이 조용히 스며들어 있으며, 작품 특유의 정서를 만들어낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>윤수현작가는 불안과 죄책감, 우울과 같은 내면의 감정을 흑백의 화면 안에서 응시한다. 절제된 색감 속에서 반복적으로 등장하는 새와 집의 형상은 고정된 존재가 아니라 변화하는 심리와 감정의 상태를 반영하는 매개체로 존재한다. 화면 속 어둠은 단순한 침잠이나 절망에 머물지 않고, 오히려 감정을 깊이 들여다보기 위한 조용한 공간으로 작동한다. 그 안에서 희미하게 드러나는 빛의 흔적은 완전한 해답이나 구원이 아닌, 감정의 깊이 속에서도 여전히 남아 있는 희망의 가능성을 암시한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><겹쳐진 온도>는 서로 다른 감정의 결을 하나의 방향으로 묶어내기보다, 각기 다른 온도들이 한 공간 안에서 공존하는 순간에 주목한다. 따뜻함과 불안, 선명함과 고요함, 감각과 기억은 화면 위에서 서로 겹쳐지고 스며들며 새로운 정서를 만들어낸다. 작품들은 각자의 독립적인 세계를 유지하면서도 전시 공간 안에서 서로의 감각을 비추고 반응하며 느슨한 관계를 형성한다. 관람자는 그 사이에서 특정한 해석보다 자신의 감정과 기억을 자연스럽게 투영하게 되며, 작품과 자신 사이에 형성되는 미묘한 감각의 흐름을 경험하게 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>어떤 감정은 선명한 언어보다 희미한 색과 질감, 남겨진 여백을 통해 오래 머물고, 어떤 기억은 특정한 장면의 잔상 속에서 뒤늦게 떠오르기도 한다. <겹쳐진 온도>는 서로 다른 네 개의 시선이 만들어낸 감각의 흐름 속에서 오늘의 감정들이 어떻게 화면 위에 머물고 스며드는지를 보여주고자 한다. 동시에 이번 전시는 서로 다른 내면의 온도들이 하나의 공간 안에서 어떻게 공존하고 교차할 수 있는지를 조용히 제안하며, 자신의 감각과 기억을 천천히 들여다볼 수 있는 시간을 마련한다.</p>
<!-- /wp:paragraph -->', place = '히든엠갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '382939';
UPDATE festival SET title = '쥬세뻬 비탈레 그림책 원화전 <동물의 세계_몬도 아니말레展>', content = '쥬세뻬 비탈레는 이탈리아 출신의 아티스트이자 그림책 작가, 교육자인 쥬세뻬 비탈레의 그림책 원화 전시와 레지오 에밀리아 접근법을 기반으로 하는 전시 연계 교육 프로그램', place = '강동아트센터 복합문화공간 아트랑' WHERE provider_type = 'PUBLIC' AND external_id = '375753';
UPDATE festival SET title = '[과천] 과천시립교향악단 실내악시리즈1 <20세기의 로맨티시즘＞', content = '', place = '과천시민회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '378908';
UPDATE festival SET title = '아름다운 목요일 요하네스: 이한나 Viola & 김다솔 Piano', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '378951';
UPDATE festival SET title = '[부산] 센텀아트홀 기획공연, 강소연 & 조영훈 듀오 콘서트: 시, 삶을 노래하다 ', content = '', place = '센텀아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382453';
UPDATE festival SET title = '크리스탈 파이트 & 조너선 영의 어셈블리 홀', content = '', place = 'LG아트센터 서울 LG SIGNATURE 홀' WHERE provider_type = 'PUBLIC' AND external_id = '378942';
UPDATE festival SET title = '[대전] 동해안 오구굿의 장단을 국악기로 풀어내다, 불세출 <밤쩌:사라져가는 것에 대하여>', content = '', place = '대전시립연정국악원 작은마당' WHERE provider_type = 'PUBLIC' AND external_id = '378866';
UPDATE festival SET title = 'Violinist 박정현 & Harpist 이진 듀오 리사이틀', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '377623';
UPDATE festival SET title = '[오산] 경기도민을 위한 어울림 콘서트: 국악과 트롯의 향연 <온고지신> ', content = '', place = '오산문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '379001';
UPDATE festival SET title = '연극 <빵야>', content = '화제의 연극 <빵야>  1945년에 태어난 ’99식 소총‘ 한 자루 그리고 그 총에 얽힌 삶을 기록하려는 한 작가의 뜨거운 만남', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '376295';
UPDATE festival SET title = '다정한 배웅', content = '', place = 'KT&G 상상마당 대치아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '378888';
UPDATE festival SET title = '[부산] NAC 렉처콘서트: BSO 솔로이스츠, 실내악 ① 현악 6중주 & 현악 8중주 ', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '381829';
UPDATE festival SET title = '속임수에 걸린 꾀보토끼 - 2026 금남로 차 없는 거리 ''걷자잉'' 연계프로그램', content = '', place = '공연일번지' WHERE provider_type = 'PUBLIC' AND external_id = '381324';
UPDATE festival SET title = '2026 남산 국악위크 <Vocal Space ''조각눈''>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '380413';
UPDATE festival SET title = '2026 국립극장 <완창판소리> 6월', content = '판소리의 긴 여정을 처음부터 끝까지 함께하는 국립극장 <완창판소리>. 박성희 명창이 ''수궁가'' 미산제로 과거와 현재, 그리고 미래를 잇는 완창의 숨결을 선보인다.', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '375812';
UPDATE festival SET title = '지브리 & 디즈니 영화음악 FESTA', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379075';
UPDATE festival SET title = '제15회 남양주시립소년소녀합창단 정기연주회: LOVE & DREAM', content = '', place = '다산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '380903';
UPDATE festival SET title = '<International Spark Place #1> MODAFE 2026', content = '', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '380001';
UPDATE festival SET title = '2026 수원은학교 <1인 1악기 학교> 여름학기 ', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394108';
UPDATE festival SET title = '제18회 성북세계음식축제 누리마실 <지구맛대로>', content = '', place = '성북로 일대' WHERE provider_type = 'PUBLIC' AND external_id = '380579';
UPDATE festival SET title = '[안산] 26’ Violinist 박준희 독주회', content = '', place = '안산문화예술의전당 해돋이극장' WHERE provider_type = 'PUBLIC' AND external_id = '381513';
UPDATE festival SET title = '[대학로] 뮤지컬 <더 라스트맨> 2차', content = '', place = '링크더스페이스(LINK THE SPACE) 1관' WHERE provider_type = 'PUBLIC' AND external_id = '379616';
UPDATE festival SET title = '당신에게 가려구요', content = '이 공연은 “기계에게 영혼이 생기기를 기원한다”는 상상에서 출발한다. 열차는 자신을 “영혼 없는 기계”라 말하지만, 그것을 사랑하는 인간의 기원 속에서 새로운 생을 부여받는다.', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '375766';
UPDATE festival SET title = '제16회 대원하모니 정기연주회 with 하트하트오케스트라 "Annual Concert"', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '380473';
UPDATE festival SET title = '한국예술종합학교 상반기 마지막 수요영화관 <드라이브 마이 카>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '382207';
UPDATE festival SET title = '<뮤지엄 모먼트> ''유물로 만나는 흑역사''', content = '유물에 담긴 잘 알려지지 않은 이야기를 통해 성장 과정의 실패와 시행착오를 자연스럽게 공감하고 이해하는 시간', place = '국립중앙박물관 극장 용' WHERE provider_type = 'PUBLIC' AND external_id = '376233';
UPDATE festival SET title = '해움·새들 제4기 입주작가 프리뷰전 다른 속도로 움직이는〈 〉들 사이에서', content = '', place = '일산호수공원 고양시 예술창작공간 해움새들' WHERE provider_type = 'PUBLIC' AND external_id = '383621';
UPDATE festival SET title = '한화생명과 함께하는 예술의전당 11시 콘서트(6월)', content = '피아니스트 박경선, 하모니시트스 박종성의 협연과 함께 생상스 ''죽음의 무도'', 스트라빈스키의 ''불새 모음곡'' 등 여름의 시작과 잘 어우러지는 프로그램으로 구성된 마티네 콘서트', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '374351';
UPDATE festival SET title = '코러스극 <히로시마 메시지>', content = '', place = '효로인디아트홀 효로소극장' WHERE provider_type = 'PUBLIC' AND external_id = '375480';
UPDATE festival SET title = '노지영 피아노 독주회, With: Classic & Jazz', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379643';
UPDATE festival SET title = '2026 기획공연 뮤지컬 <피리 부는 사나이>', content = '포크 음악의 거장, 송창식의 명곡으로 되살아난 격동의 시대', place = '국립정동극장' WHERE provider_type = 'PUBLIC' AND external_id = '375048';
UPDATE festival SET title = '[양양] 구석구석 찾아가는 영화관 <좀비딸>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '383869';
UPDATE festival SET title = '[부산] BTS WORLD TOUR ''ARIRANG''', content = '', place = '부산아시아드 경기장' WHERE provider_type = 'PUBLIC' AND external_id = '379767';
UPDATE festival SET title = '국악의날 기념 기악단 기획공연, 지금 비우다 ''여(餘)유(YOU)'' ', content = '', place = '국립민속국악원 예원당' WHERE provider_type = 'PUBLIC' AND external_id = '381628';
UPDATE festival SET title = '클래시컬 브릿지 국제 음악 페스티벌, 고티에 카퓌송,엘렌 메르시에,다니엘 로자코비치,미하일 플레트네프&RIO', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379787';
UPDATE festival SET title = ' 김진욱 피아노 독주회 "Ballades by J. Brahms, F. Liszt, and F. Chopin"', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '377020';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 <러브레터>', content = '', place = '국립극장 무대예술지원센터' WHERE provider_type = 'PUBLIC' AND external_id = '381327';
UPDATE festival SET title = '[화성] 화성시 오케스트라 콘서트 라운지 Ⅱ: Cinema & Classic ', content = '', place = '반석아트홀(동탄복합문화센터)' WHERE provider_type = 'PUBLIC' AND external_id = '381499';
UPDATE festival SET title = '더중앙플러스 클래식 시리즈: 임윤찬 & 카메라타 잘츠부르크', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '380009';
UPDATE festival SET title = '광명문화재단 기획공연 <얼쑤,얼쓰 ULSSU, EARTH> ', content = '', place = '광명시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '380586';
UPDATE festival SET title = 'Alpha', content = '<Alpha>는 ‘흙에서 태어나 흙으로 돌아가는’ 인간 존재의 순환을 통해, 연약함 속에서 강인함을 발견하는 여정을 그린다.', place = '대학로예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375768';
UPDATE festival SET title = '[문화릴레이티켓] 창작가무극 <신과 함께_저승편>', content = '창작가무극 <신과 함께_저승편>은 단행본 누적 판매 100만 부 이상을 기록한 주호민의 웹툰을 원작으로 사후 세계를 ‘재판’이라는 구조로 풀어내며 ‘인간의 삶’을 이야기하는 작품', place = 'NOL 씨어터 대학로 우리카드홀' WHERE provider_type = 'PUBLIC' AND external_id = '382173';
UPDATE festival SET title = '[안산] 지브리 & 디즈니 영화음악 오케스트라 콘서트 ', content = '', place = '안산문화예술의전당 해돋이극장' WHERE provider_type = 'PUBLIC' AND external_id = '380245';
UPDATE festival SET title = '우리동네사람들 시즌6 ''소리를 넘어, 마음으로''', content = '', place = '영산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '381211';
UPDATE festival SET title = '[인천] 엘렌 메르시에 & 다니엘 로자코비치 듀오 리사이틀', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '380240';
UPDATE festival SET title = '베르누스 무지카 정기연주회 Ⅲ. Light & Lyricism (빛과 서정)', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '380277';
UPDATE festival SET title = 'Tiffany & Co.와 함께하는 임윤찬 & 카메라타 잘츠부르크', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '380278';
UPDATE festival SET title = '한밭교육박물관, 국립임시정부기념관 공동전시 <대한민국 임시정부 기억상자>', content = '', place = '한밭교육박물관' WHERE provider_type = 'PUBLIC' AND external_id = '386738';
UPDATE festival SET title = '귀신날 : The Day the Gate Opens', content = '"한국에도 할로윈(Halloween)이 있었다”는 발상에서 출발하여, 한국의 샤머니즘과 민속놀이를 현대적으로 재해석한 대극장형 창작무용극이다. ', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375769';
UPDATE festival SET title = 'It"s Real : 진짜 세계', content = '', place = '개나리미술관' WHERE provider_type = 'PUBLIC' AND external_id = '385575';
UPDATE festival SET title = '지구독대여자', content = '<!-- wp:image {"id":19035,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/06/지구독대여자_정정엽_대지-1-사본-23.jpg" alt="" class="wp-image-19035" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong>전시 서문<br>독대의 방법론</strong><a href="/Users/LG/Downloads/%EB%8F%85%EB%8C%80%EC%9D%98%20%EB%B0%A9%EB%B2%95%EB%A1%A0%20(1)%20(3).docx#_ftn1"><sup>[1]​</sup></a></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이연숙(리타)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>‘독대’는 한자로 ‘홀로 독(獨)’에 ‘대답할/마주할 대(對)’를 쓴다. 풀어쓰면 ‘다른 누구 없이 홀로 마주한다’라는 의미이다. 통상 용례로는 윗사람과 비밀리에 특정 사안에 대해 논의하는 상황을 가리키며 불평등한 위계 질서를 전제하는 단어이다. 그렇지만 이번 전시 제목에서 정정엽은 이를 다른 관점으로 전환한다. 나는 이를 내 식대로 풀어본다: 흔히 ‘대’는 두 적수 사이를 구분하는 표기로서 쓰이는데 이는 영어의 ‘VS’와 대응한다. 그러면서 ‘대’는 다른 누군가에 ‘대항하다(against)’로도 확장된다. 알다시피 대항은 늘 다른 누군가에 ‘대해’ 반대 방향으로 향하려는 운동이다. 그러려면 나와 반대 방향에 있는 상대(相對)가 반드시 존재해야 한다. 대답 또한 마찬가지이다. 거기에는 내가 말을 돌려줘야 할 책임 있는 누군가가 이미 있다. 그러므로 ‘홀로’ ‘마주한다’라는 뜻이라곤 해도 실제 ‘독대’라는 글자에는 드러나지 않는 어떤 존재—‘타자’가 항상 포함되어 있다. ‘독대’는 나와 다른 타자와의 대면이자 대답이다. 이는 물론 나와 불화하는 사건이다. 오직 수직(│)수평(─) 획으로만 이루어진 빳빳하게 곧은 ‘독대’ 두 글자에는 화해, 협상, 합의 불가능한 타자와의 절대적인 차이가 이미 자기 형태로서 예시되고 보존된다. 나와 타자에겐 교차점은 있지만 평행선은 없다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>한치 양보 없는 존재와 존재의 만남이자 대결—이를 페미니즘 언어로는 ‘평등’이라 쓴다. 통상 평등이란 인간 간에 차별 없이 같은 권리를 보장 받는 상태를 의미한다. 그렇지만 ‘독대’ 관계에서 발생하는 평등에는 긴장이 수반된다. 타자는 불편하고 내게 두려움을 주기 때문이다. 기실 페미니스트 정치성, 감수성이란 종과 비/생물의 구분을 초월하여 나와 다른 무언가에 대한 두려움을 존중, 경탄—무엇보다 ‘연민’으로 전환하는 일종의 도착(perversion) 능력과도 같다. 전문 페미니스트 주체라면 나와 대상 간의 힘, 크기, 능력 ‘차이’를 가부장적 위계 질서의 언어로서 자동 번역하는 사고 방식에 부동의할 뿐만 아니라 무감동하다. 이런 경지에 도달하기까지는 부단한 훈련이 뒤따른다. 아마 그렇기에 많은 평자들이 정정엽의 그림에서 통상 ‘화가’라는 말이 부여하는 권위와는 다른 대안적인 태도를 읽어내는 것이겠다. 과연 벌레-여자-화가로서 정정엽은 “두렵지만” “어둠” 속을 “촉각”으로 “더듬”으며 매일 수종(種)수족(足)의 타자를 “쓸쓸”하고 “쏠쏠”하게 마주하며 나무 판넬 캔버스를 무대 삼아 이들과의 ‘독대’를 온몸으로 재연한다. 그의 스케일에 맞춰 1:1로 뻥튀기된 거대 나방과 거대 풀들의 거친 표면은 작가의 신체가 수행했을 그리기의 안무(choreography)를 재생한다. 매순간이 “최초의” “원초적” 접촉인 타자와의 경이로운 만남은 그림이란 수행으로 반복된다. 이제 그림이란 ‘독대’의 다른 형식이다. 반복 불가능한 타자와의 관계가 거기 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>한편 ‘독대’는 정정엽에게 자유로도 번역된다. 제멋대로 말하자면 내겐 대선배인 그는 지난 세월 동안 민중(민족/노동)-여성(‘변방’)의 경계 현장에서 예술-생활 간의 긴장과 그런 긴장이 외려 가능하게 하는 재미를 단 한순간도 포기하지 않았으며 또한 그런 긴장으로부터 살아남은 예술가다. 그는 그런 경험을 통해 내장으로 익힌 본능 같은 직관으로 자유란—물론 ‘평등’ 또한 마찬가지로—무한정의 몫이 아닌 극단적인 대립 사이에서 찰나 체험되는 “균형” 상태라고 간주한다. 이런 관점에서 자유는 일반적인 용례와는 달리 자기 한계를 인지하고 이를 시험하는 자기 수양이자 자기 돌봄이다. 그림은 이에 대한 구체적인 실천이다. 타자와 자기 자신 간의 ‘독대’ 관계를 수련하는 정신적인 공간이자 물리적인 장소로서 캔버스는 ‘화가’ 정정엽의 의도를 제한하며 동시에는 ‘그로부터’ 가능해진 우연을 개방한다. 각기 다른 결을 가진 나무 판넬 캔버스라는 불균질한 환경은 이런 긴장 상태에서만 획득되는 회화적인 쾌(pleasure)를 낳기 딱 좋은 매트릭스다. 다시 ‘독대’라는 단어를 분해하면—‘대’는 또한 현대 중국어에서 상대방의 말에 대한 동의를 의미한다. 그의 붓이 의도하는 방향은 나무 판넬에 저항하고(against) 또한 우연히도 일치(correct)하며 물질적인 접촉의 관능적인 재미를 산출한다. 오직 주체-세계 간의 긴장 사이에서 발생하는 ‘틈새’ 찰나 즐김은 회화라는 “본능”적인 움직임의 근본 동력이다. 또한 슬라보예 지젝의 말에 따르자면 이는 자유라는 “역설과 불화로 맹렬하게 타오르는”<a href="/Users/LG/Downloads/%EB%8F%85%EB%8C%80%EC%9D%98%20%EB%B0%A9%EB%B2%95%EB%A1%A0%20(1)%20(3).docx#_ftn2"><sup>[2]</sup></a> 개념에서 우리가 기대할 수 있는 거의 모든 것이기도 하다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>‘독대’가 일견 암시하는 고독과는 달리 화가의 태도이자 방법으로서 여기에는 미지의 타자에 대한 우연적 만남과 필연적 접촉에 대한 기쁨과 유희가 넘치도록 있다. 그가 나무 결을 따라 붓과 눈으로써 쓰다 듬은 캔버스의 표면으로부터 우리는 새삼 우리가 태어나기 이전부터 우리를 둘러싸고 있던 지구라는 행성에서 함께 나온 이종(異種)친족들을 ‘다시’ 타자로서 경이롭게 보는 육감을 발견한다. 이는 다른 무엇보다 우리 삶을 타자라는 차이가 주는 긴장과 경이로 채울 것을 제안한다. 그런 모든 과정에서 결국 우리에게 남는 것은…다름아닌 생이 주는 재미이다! </p>
<!-- /wp:paragraph -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity" />
<!-- /wp:separator -->

<!-- wp:paragraph -->
<p><a href="/Users/LG/Downloads/%EB%8F%85%EB%8C%80%EC%9D%98%20%EB%B0%A9%EB%B2%95%EB%A1%A0%20(1)%20(3).docx#_ftnref1"><sup>[1]</sup></a> 별도 표기가 없는 한 이 글의 직접 인용은 모두 정정엽의 ‘작가의 말’, ‘낱말 놀이’, 작가와의 대화에서 가져왔다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><a href="/Users/LG/Downloads/%EB%8F%85%EB%8C%80%EC%9D%98%20%EB%B0%A9%EB%B2%95%EB%A1%A0%20(1)%20(3).docx#_ftnref2"><sup>[2]</sup></a> 슬라보예 지젝, 노윤기 옮김, 『자유』, 현암사, 2025, 205p.<strong>​</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong><br><br><br>작업노트 (2026.5.15.)</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>대부분 나는 벌레다. 촉각을 곤두세워 방향을 주시한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>진짜로 원하는 게 뭔지 더듬어간다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>벌레 한 마리 힘차게 기어 갈 때, 내 몸속에 꿈틀대는 최초의 몸짓</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>절벽 같은 어둠속에 손을 휘저었을 때 두렵지만 지구 독대 충만</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>태어나 매일 만나는 밤길을 온전히 호흡하고 싶다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>내가 여자라는 사실을 알게 된 순간</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>스며든 공포, 이 태생적 불안은 어디서 왔을까.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>음악 소리를 들으며 혼자 식당으로 가는 길</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>먼 곳의 총탄 한 방 이 고요를 날려버리리라.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>소녀생존기의 몸짓을 들여다본다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그림은 분명한 마음의 결을 따라 </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>움찔, 획, 머뭇 머뭇, 바닥을 더듬어 없는 길을 찾아가는 일</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>어느 날 가만히 들여다 본 나무의 결들이 나를 움직이게 했다.  </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>붓질로 더듬어가며 ‘소녀생존기-몸짓’ 7개의 나무 판넬 연작을 그렸다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>물속에서 춤추는 여자의 몸짓이 물방울, 어둠 속의 동굴, </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>고사리 이파리와 섞이며 이야기를 만들어 간다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>기괴한 감자 싹이 거대한 획을 그으며 존재를 뽐낸다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>지난 여름 만났던 나방들의 눈빛과 날개 짓이 나무결의 흐름과 섞인다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>커다란 캔버스에 내가 먹은 풀들이 벌레들과 뒤섞여 </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>오래전 동굴 벽화처럼 원초적 기운을 뿜어낸다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>정적과 역동, 흔들리며 걸어가는 동안 새로운 호흡을 즐긴다​.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>정정엽 Jung Jungyeob</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>b. 1962</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>1985  이화여자대학교 미술대학 서양화과 졸업</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>SOLO Exhibition</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td>2026 </td><td> 지구독대여자, 갤러리밈, 서울</td></tr><tr><td>2025 </td><td> 콩은 어디든 굴러 간다, 스텔라갤러리, 서울​</td></tr><tr><td>2023 </td><td> 정정엽의 연결고리, A.P23, 서울</td></tr><tr><td> </td><td> 모욕을 당한 자이며 위대한, 갤러리밈, 서울</td></tr><tr><td>2022 </td><td> 34회 이중섭미술상 수상 기념전, 아트조선 스페이스, 서울</td></tr><tr><td> </td><td> 물어보는 노동, 전태일 기념관, 서울</td></tr><tr><td> </td><td> 여자는 길을 좋아한다, 동양장B1, 대전</td></tr><tr><td> </td><td> 물구나무 팥, 봉산문화회관, 대구</td></tr><tr><td>2021 </td><td> 걷는 달, 아트센터 화이트 블록, 헤이리 경기</td></tr><tr><td> </td><td> 조용한 소란, 서울식물원, 서울</td></tr><tr><td>2019 </td><td> 최초의 만찬 - 고암미술상수상기념전, 이응노의 집, 홍성</td></tr><tr><td> </td><td> 어디에서나 발생하는 별, 조은숙 갤러리, 서울</td></tr><tr><td>2018 </td><td> 나의 작업실 변천사, 이상원미술관, 춘천 </td></tr><tr><td>2017 </td><td> 콩 그리고 위대한 촛불, 트렁크 갤러리, 서울</td></tr><tr><td> </td><td> 아무데서나 발생하는 별, 갤러리 노리, 제주</td></tr><tr><td> </td><td> 49개의 거울, 스페이스몸 미술관, 청주</td></tr><tr><td>2016 </td><td> 벌레, 갤러리 스케이프, 서울</td></tr><tr><td>2014 </td><td> 길을 찾는 그림, 길들여지지 않는 삶, 길담서원, 서울</td></tr><tr><td>2011 </td><td> off bean, 갤러리 스케이프, 서울</td></tr><tr><td>2009 </td><td> 얼굴 풍경, 대안공간 아트포럼 리, 부천</td></tr><tr><td> </td><td> red bean, 갤러리 스케이프, 서울</td></tr><tr><td>2006 </td><td> 지워지다, 아르코미술관, 서울</td></tr><tr><td> </td><td> 멸종, 비나리미술관, 봉화</td></tr><tr><td>2002 </td><td> 정정엽 개인전, 서호갤러리, 서울 / 서호미술관, 경기</td></tr><tr><td>2001 </td><td> 낯선 생명, 그 생명의 두께, 신세계 갤러리, 인천</td></tr><tr><td>2000 </td><td> 봇물, 인사미술공간, 서울</td></tr><tr><td>1998 </td><td> 정정엽 개인전, 금호미술관, 서울</td></tr><tr><td>1995 </td><td> 생명을 아우르는 살림, 이십일세기화랑, 서울</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>GROUP Exhibition (selected) </strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td>2025 </td><td> 숨어서 숨 쉬는 작가 연합 - 이피, 정정엽, 누크갤러리, 서울</td></tr><tr><td> </td><td> 오''오브젝트, 미메시스 아트 뮤지움, 파주</td></tr><tr><td>2024 </td><td> The 3rd Two - 아시아 여성미술전, 독일BBK. 뮌헨</td></tr><tr><td> </td><td> 말하는 몸 : 아시아 여성 미술가들, 국립현대미술관 서울관</td></tr><tr><td>2023 </td><td> 아르코미술관 50주년 ''어디로 주름이 지나가는가'', 아르코미술관, 서울</td></tr><tr><td>2022 </td><td> 누구의 이야기, 부산현대미술관</td></tr><tr><td>2020 </td><td> 그림 그리다, 경기도미술관, 안산, 야만의 꿈 - 핵몽4, 예술지구p, 부산</td></tr><tr><td>2019 </td><td> 세상에 눈뜨다 : 아시아 미술과 사회 1960s~1990s, 도쿄국립근대미술관, 한국국립현대미술관, 싱가포르국립미술관</td></tr><tr><td colspan="2">2013~2009  OFF THE BEATEN PATH : VIOLENCE, WOMEN AND ART : An International Contemporary Art Exhibition </td></tr><tr><td> </td><td> (An International Contemporary Art Exhibition Stenersen Museum, Oslo, Norway | 2009, University Art Gallery, San Diego, USA | 2009)</td></tr><tr><td>2012 </td><td> Women In-Between : Asian Women Artists 1984-2012, 후쿠오카 아시아 미술관, 후쿠오카, 일본</td></tr><tr><td>2008 </td><td> The Offering Table : Activist Women from Korea, 밀스 컬리지 뮤지움, 미국</td></tr><tr><td>2002 </td><td> 광주비엔날레 프로젝트3, 광주</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>Awards</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td>2022 </td><td> 34회 이중섭미술상</td></tr><tr><td>2020 </td><td> 양성평등문화인상</td></tr><tr><td>2018 </td><td> 제 4회 고암미술상</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>Collections </strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>후쿠오카 아시아 미술관, 국립현대미술관, 서울시립미술관, 아르코 미술관, 광주시립미술관, 경기도 미술관, 수원시립아이파크미술관, 부산현대미술관 등</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Publications</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>​「작고 물렁하고 위대한」 미디어 버스 2025, 「콩은 어디든 굴러 간다」 이른비 2025, 「나의 작업실 변천사」 헥사곤, 2018, 「한국현대미술선 정정엽」 헥사곤, 2011</p>
<!-- /wp:paragraph -->', place = '갤러리밈' WHERE provider_type = 'PUBLIC' AND external_id = '384797';
UPDATE festival SET title = '2026 보훈무용제 사전축제 <젊은예인전>', content = '', place = '나루아트센터 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '380476';
UPDATE festival SET title = 'Anthony Gray and Jiyeon Lee Piano Solo and duo Recital 앤서니 그레이 & 이지연 피아노 솔로와 듀엣 리사이틀', content = '', place = '꿈의숲아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '380908';
UPDATE festival SET title = '6월 국회문화극장 <세계의 주인>', content = '', place = '국회의원회관' WHERE provider_type = 'PUBLIC' AND external_id = '382204';
UPDATE festival SET title = ' 김재훈 <아이 아이>', content = '', place = '갤러리 스페이스포포' WHERE provider_type = 'PUBLIC' AND external_id = '382215';
UPDATE festival SET title = '서리풀 전곡 연주 시리즈, 하이든 교향곡 시리즈 34 ‘Drum Roll’', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '380532';
UPDATE festival SET title = '김현서 & 이향숙 듀오 리사이틀: 베토벤 소나타 전곡 시리즈 Ⅱ', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382755';
UPDATE festival SET title = '2026년 6월 도봉톡톡극장 <파블로의 세계음악여행>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '382838';
UPDATE festival SET title = '왝왝이가 그곳에 있었다', content = '<왝왝이가 그곳에 있었다>를 통해 기억을 말하거나재현하는 데 그치지 않고, 살아있는 몸과 감각을 통해 함께 새기고 기꺼이 머무르는 기억의가능성에 다가가고자 한다.', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '375770';
UPDATE festival SET title = '영극 <모린>', content = '', place = '서울연극창작센터' WHERE provider_type = 'PUBLIC' AND external_id = '380694';
UPDATE festival SET title = '한국예술연구소 학술대회 <돌봄의 예술, 담론과 실천의 새로운 연결>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '383910';
UPDATE festival SET title = '권병준 작가 <로보틱 사운드 워크숍>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '371996';
UPDATE festival SET title = '<2026 김포예술활동지원사업 성과전시> 박영균 개인전 Overground : 너른 땅과 솟아오른 주거', content = '', place = '김포문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '386752';
UPDATE festival SET title = '2026 창작ing 뮤지컬 <던터치(Dawn Touch)>', content = '던 터치(Dawn Touch)''에 이르는 8시간의 여정을 다룬 작품', place = '국립정동극장 세실' WHERE provider_type = 'PUBLIC' AND external_id = '375047';
UPDATE festival SET title = '2026 공예주간 (Korea Craft Week 2026)', content = '', place = '거점도시 부여 / 권역별 도시 세종·공주, 전주·고창, 칠곡·구미, 울산·부산, 제주·서귀포 / 전국 공예주간 프렌즈 참여 지역' WHERE provider_type = 'PUBLIC' AND external_id = '382435';
UPDATE festival SET title = '2026 실내악 시리즈 <브라보 브라스(Bravo Brass)>', content = '', place = '솔가람아트홀 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '380706';
UPDATE festival SET title = '오페라 <광대들>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '380823';
UPDATE festival SET title = '국악크로스오버밴드 시오트(SYOT) <무아 無我>', content = '', place = '구로창의아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '380887';
UPDATE festival SET title = '헐리우드 블록버스터 & 디즈니 픽사 OST 오케스트라 콘서트', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '380840';
UPDATE festival SET title = '[세종] 강윤미 & 존 스토웰, A Timeless Place: 시간을 초월한 재즈의 대화 ', content = '', place = '재즈인연구소' WHERE provider_type = 'PUBLIC' AND external_id = '380914';
UPDATE festival SET title = '[익산] 최향 & 채수현의 듀엣 콘서트: 트로트의 향기를 노래하다 ', content = '', place = '솜리문화예술회관 중공연장' WHERE provider_type = 'PUBLIC' AND external_id = '380808';
UPDATE festival SET title = 'SUKIMASWITCH “POPMAN’S WORLD 2026 in Seoul”', content = '', place = '예스24 원더로크홀' WHERE provider_type = 'PUBLIC' AND external_id = '380978';
UPDATE festival SET title = '[광주] 제3회 광산구립합창단 영·호남 친선음악회: 마음을 잇는 따뜻한 울림 ', content = '', place = '광산문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '383314';
UPDATE festival SET title = '국립극단 [공동기획] <사사로운 사서>', content = '"도시의 거실"이라고 할 수 있는 도서관에서 벌어지는 사사롭지만 사사롭지 않은 사서들의 이야기', place = '국립극단 [명동] 명동예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '375068';
UPDATE festival SET title = '낭독극 ''믿고 보는 하늘(가제)''', content = '', place = '성수 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '383177';
UPDATE festival SET title = '[서울] 어린이 공포 체험 뮤지컬 <MBC 심야괴담회×니니키즈 : 학교에서 살아남기>', content = '', place = '한전아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '380806';
UPDATE festival SET title = '뮤지컬 <파가니니>', content = '', place = '홍익대 대학로 아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '380631';
UPDATE festival SET title = '청주문화나눔 & 동부창고 예술교육 <나, 여기서 기다릴게>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '380470';
UPDATE festival SET title = '[서울영화센터] <스마트폰으로 만드는 나만의 영화 - Ⅰ.기획/개발> 교육 오픈!', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '382009';
UPDATE festival SET title = '[의정부] The Magic 팬텀 & 퀸 ', content = '', place = '의정부예술의전당 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '380797';
UPDATE festival SET title = '[군산] 마법선물상자&책읽는마법사', content = '', place = '군산어린이공연장' WHERE provider_type = 'PUBLIC' AND external_id = '383777';
UPDATE festival SET title = '> "Hello World";', content = '〈인간의 구성〉은 인간의 내면을 해부하듯 탐구하며, 신체와 정신, 감정과 기술의 경계에서 ‘인간다움’의 의미를 재구성한다.', place = '대학로예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375771';
UPDATE festival SET title = '2026 서울시향 체임버 클래식스 III: 독일 & 오스트리아', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '376256';
UPDATE festival SET title = '[여수] 노올량의 <섬 아리랑>', content = '', place = '복합문화공간 여수살롱' WHERE provider_type = 'PUBLIC' AND external_id = '385934';
UPDATE festival SET title = '시모노 타츠야 & 오케스트라 디 오리지널 with 한수진', content = '', place = '서울아트센터 도암' WHERE provider_type = 'PUBLIC' AND external_id = '380812';
UPDATE festival SET title = '[대전] 헐리우드 블록버스터 & 디즈니 픽사 OST 오케스트라 콘서트 ', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '381255';
UPDATE festival SET title = '대전광역시 서예진흥원 <2026 서예교육 전문인력 양성과정 수료생 역량강화 과정>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '384567';
UPDATE festival SET title = '2026 모두를 위한 예술 프로그램 〈몸으로 만나는 미술관〉''스침의 변주’', content = '', place = '서울시립미술관' WHERE provider_type = 'PUBLIC' AND external_id = '385591';
UPDATE festival SET title = '2026 보훈무용제 부대행사 <보훈무용제 학술심포지엄>', content = '', place = '나루아트센터 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '382603';
UPDATE festival SET title = '2026년 기획전시 <호랑이 담배 피던 시절>', content = '', place = '사상생활사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '386328';
UPDATE festival SET title = '2026 보훈무용제 개막공연 <춤 전시회>', content = '', place = '나루아트센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '380436';
UPDATE festival SET title = '뮤지엄 씨어터 <잊히지 않을 이름>', content = '', place = '국립6.25전쟁납북자기념관' WHERE provider_type = 'PUBLIC' AND external_id = '384536';
UPDATE festival SET title = '2026 구석구석 문화가 있는 날 × 문화제조창 달밤 투어', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '385370';
UPDATE festival SET title = '김조민·한봄이 2인전 《PATINA 손때: 인내에 깃든 탐욕》', content = '', place = '경인미술관 제1전시실' WHERE provider_type = 'PUBLIC' AND external_id = '385730';
UPDATE festival SET title = '충북갤러리 현대미술동인 SLIPPER 단체전 《테·이·크·아·웃》', content = '', place = '인사아트센터 충북갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '385607';
UPDATE festival SET title = '2026 경춘선숲길 갤러리 <닿는 언어>', content = '', place = '경춘선숲길 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '385585';
UPDATE festival SET title = '다미앵 잘레 × 코헤이 나와 ''플래닛[방랑자]''', content = '', place = 'GS아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '377850';
UPDATE festival SET title = '임선혜 & 이동규, 러브 듀엣 : Mozart and Handel in Love', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '381435';
UPDATE festival SET title = '그럼에도 불구하고', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '384603';
UPDATE festival SET title = '손철주의 오래된 그림공부 <표정이 왜 저럴까?>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '383241';
UPDATE festival SET title = '2026 보훈무용제 경연부문 <보훈무용제>', content = '', place = '나루아트센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '380444';
UPDATE festival SET title = '유진규마임 2026 ''꽃'' - 사라지며 피어나다 ', content = '', place = '축제극장 몸짓' WHERE provider_type = 'PUBLIC' AND external_id = '385567';
UPDATE festival SET title = '윤소영 & 마르친 시코르스키 듀오 리사이틀', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '381421';
UPDATE festival SET title = '배윤환: 무거운 숨', content = '<!-- wp:paragraph -->
<p>갤러리바톤은 배윤환(b. 1983)의 개인전 《무거운 숨(Heavy Breathers)》을 2026년 6월 27일부터 7월 31일까지 한남동 전시 공간에서 개최한다. 수집된 정보와 경험을 회화적 스토리텔링으로 재구성하며 회화라는 매체의 서사적 가능성을 확장해 온 작가는, 최근 들어 인류세적 관점에서 동시대의 비가역적 변화를 자신의 시각으로 섬세하게 감지하고 기록하는 방향으로 관심을 옮겨가고 있다. 코끼리와 코, 기능적 오브제가 새롭게 등장하며 우리를 둘러싼 생존의 풍경을 자신의 지각과 상상력에 투영한 이번 신작들은, 몸과 사물, 감각과 구조가 서로를 지탱하며 형성하는 경계적 풍경을 제시한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2010년부터 작가는 그림을 생산하는 작가의 처지와 공간을 점유하는 작품의 조건, 작업실이라는 사적 공간과 외부 세계가 충돌하는 지점에 주목해왔다. 작업 속 이미지와 재료들은 고정된 의미를 갖기보다 이동하고 축적되며 새로운 관계를 형성했다. 이러한 관심은 영상 작업인 <자화상>(2017), <스튜디오 B로 가는 길>(2018),  <3시에 추는 춤>(2024)에서도 확인된다. 이와 같이 회화, 영상 작업을 병행해온 작가는 생산과 소모, 축적과 소멸, 이미지와 물질이 순환하는 과정을 통해 작업을 둘러싼 생태를 탐색해왔다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":19257,"width":840,"height":1046,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full is-resized"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/06/GB_BYH_2026_Baritone_charcoal-on-canvas_162.2-x-130.3-cm.jpg" alt="" class="wp-image-19257" width="840" height="1046" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>이번 전시에서 코끼리의 몸과 코, 그리고 신체로부터 분리된 오브제들은 화면을 구성하는 핵심적인 도상으로 자리한다. 코끼리는 그 거대한 몸으로 인해 세계의 속도와 질서에 쉽게 편입되지 못하는 존재이며, 동시에 개인이 짊어진 무게와 불안을 비추는 은유적 표상이다. 이때 사회적 조건 속에서 밀려나는 몸과 개인이 짊어진 불안은 서로 겹쳐지고, 외부 세계의 질서와 내면의 감각은 하나의 형상 속에 응축되어 나타난다. 화면 속 코끼리는 더 이상 힘이나 권위의 상징이 아니라, 무게와 시간의 압력을 묵묵히 견뎌내는 몸으로 현전한다. 코는 사고 이전의 감각과 본능이 거주하는 기관으로 기능하며, 사고보다 먼저 반응하고 기억하는 몸의 감각적 층위를 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":19255,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/06/GB_BYH_2026_222MHz_charcoal-on-canvas_162.2-x-130.3-cm-1.jpg" alt="" class="wp-image-19255" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>최근 작가는 서사적 요소를 점차 축소하는 과정에 있다. 특히, 목탄을 중심으로 한 회화는 선과 면, 명암의 관계를 통해 보다 압축되고 감각적인 화면을 제시한다.  <Baritone>, <222MHz>, <March> 에서 작가는 구체적 형상을 부분적으로 해체하고 화면의 긴장과 밀도를 강조한다. 이러한 변화는 배윤환이 서사를 축소하고 화면의 여백과 생략을 적극적으로 활용하면서도, 비워낸 자리에 어떠한 상태를 제시할 수 있는지에 대한 조형적 균형을 모색하고 있음을 나타낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":19259,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/06/GB_BYH_2026_숨-쉬세요-Breathe_oil-on-canvas_130.3-x-193.9-cm-1.jpg" alt="" class="wp-image-19259" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>전시 제목인 “무거운 숨(Heavy Breathers)”은 살아 있음의 가장 작은 단위인 호흡에서 출발한다. 작품 <숨 쉬세요(Breathe)>에서 코끼리는 모두 떠난 황량한 풍경에서 홀로이 남아 자신의 동작을 반복하며 작은 숨 하나를 공중에 떠올린다. 여기서 호흡은 희망의 은유가 아니라 압력에 대한 지속적인 반응에 가깝다. 몸은 사회적 조건과 개인적 기억이 교차하는 장소가 되며, 반복되는 행위는 살아남기 위한 기제로 자리한다. 이번 전시에서 작가는 인류세라는 비가역적 조건 위에 놓인 존재를 추적한다. 생존을 향한 의지와 환경 앞에서 점차 사물화 되어가는 수동성 사이 그 알레고리적 긴장이 화면 전면에 자리한다.</p>
<!-- /wp:paragraph -->', place = '갤러리바톤' WHERE provider_type = 'PUBLIC' AND external_id = '386735';
UPDATE festival SET title = '연극 <아고라포비아>', content = '', place = '문래예술공장 박스씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '381620';
UPDATE festival SET title = '제30회 춘천여성미술작가회전 <춘천에 산다>', content = '', place = '봄내극장' WHERE provider_type = 'PUBLIC' AND external_id = '386320';
UPDATE festival SET title = '문화공간 터틀(석남) 기획전시 <골목의 결> 기획전시', content = '', place = '문화공간 터틀' WHERE provider_type = 'PUBLIC' AND external_id = '386316';
UPDATE festival SET title = '부부', content = '“변수를 두려워하지 말자”는 주제로, 불완전함을 받아들이는 용기와 함께 살아간다는 것의 현실적 아름다움을 무대 위에서 보여준다.', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '375774';
UPDATE festival SET title = '인문학콘서트 <공존(Survive)>', content = '차가운 알고리즘과 뜨거운 시김새의 만남, ''공존(共存)''일까 ''생존(Survive)''일까? 기술과 예술의 내일을 고민하는 인문학콘서트!', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '375808';
UPDATE festival SET title = '2026 예술의전당 월드스타시리즈 - 르 콩소르', content = '전 세계를 매혹시킨 바로크 음악의 새로운 아이콘,프랑스 앙상블 ''르 콩소르''의 첫 내한 무대', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '374353';
UPDATE festival SET title = '권민정 & 박민정 피아노 조인트 리사이틀', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '381674';
UPDATE festival SET title = '피아니스트 이섬승의 슈만 & 브람스 시리즈 Ⅱ', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '381660';
UPDATE festival SET title = '6월, 월간듀오 바이올리니스트 박정현 & 하피스트 이진', content = '', place = '갤러리 디 아르테 청담' WHERE provider_type = 'PUBLIC' AND external_id = '381901';
UPDATE festival SET title = '아트리움 클래식 시리즈, 임선혜 & 이동규 Love Duet', content = '', place = '성남아트리움' WHERE provider_type = 'PUBLIC' AND external_id = '381908';
UPDATE festival SET title = '[광주] ACC 렛츠플레이 <꼬마장승 가출기> ', content = '', place = '국립아시아문화전당 어린이극장' WHERE provider_type = 'PUBLIC' AND external_id = '381875';
UPDATE festival SET title = '6월 문화가 있는 날 교육 <소리-몸-명상>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '381088';
UPDATE festival SET title = '2026 통진두레문화센터 기획공연 <어린이 아트스테이지>', content = '', place = '통진두레문화센터' WHERE provider_type = 'PUBLIC' AND external_id = '387188';
UPDATE festival SET title = '[영등포아트스퀘어] 배우 문정희 북콘서트 ''금빛 동행, 마누 이야기''', content = '', place = '영등포아트스퀘어 스퀘어A' WHERE provider_type = 'PUBLIC' AND external_id = '383422';
UPDATE festival SET title = '가족이 좋아서(書)×쉼표가 있는 책마당', content = '', place = '파주 아시아출판문화정보센터 다목적홀(지혜의숲)' WHERE provider_type = 'PUBLIC' AND external_id = '384470';
UPDATE festival SET title = '춘천예술촌 야외 공간 활성화 <플리플라 아트 파크>', content = '', place = '춘천예술촌 야외 잔디마당' WHERE provider_type = 'PUBLIC' AND external_id = '384195';
UPDATE festival SET title = '2026 수봉IN기획공연 <Sound Of Cinema>', content = '', place = '인천수봉문화회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '384323';
UPDATE festival SET title = '[제주] 내 곁에, 클래식: 바흐 & 헨델 ', content = '', place = '애월뮤직팩토리' WHERE provider_type = 'PUBLIC' AND external_id = '382506';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 <수묵ㆍ담채>', content = '', place = '국립극장 무대예술지원센터' WHERE provider_type = 'PUBLIC' AND external_id = '384108';
UPDATE festival SET title = '[울산] 아즈마 아키와 함께하는 영화음악 콘서트: 지브리 & 월드 무비 OST ', content = '', place = '울산문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '381810';
UPDATE festival SET title = '[부산] NAC 시그니처 클래식: Symphony No.5 & Choral Series Ⅳ 쇼스타코비치 No.5 엘가 첼로 협주곡', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '381865';
UPDATE festival SET title = '주현미 데뷔 40주년 콘서트 <The Queen>', content = '', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '380464';
UPDATE festival SET title = '2026 보훈무용제 폐막공연 <세월을 가진 춤을 추다>', content = '', place = '나루아트센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '380477';
UPDATE festival SET title = '2026 종로 문화예술 지원사업 <디그업 종로> 킴콜린 개인전《THE UNSTILL LIFE TOUR》', content = '', place = '종로문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '387418';
UPDATE festival SET title = '2026년 아동·청소년 도박문제예방 포럼', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '382813';
UPDATE festival SET title = '[대전] 한재민 & 루체른 심포니 ', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382141';
UPDATE festival SET title = '봄봄 <어반스케치회원전>', content = '', place = '애니메이션박물관' WHERE provider_type = 'PUBLIC' AND external_id = '387413';
UPDATE festival SET title = '2026 해움·새들 입주작가 프로젝트 박경종(해움4기) - 토탈 리콜: 응축의 프리즘', content = '', place = '일산호수공원 고양시 예술창작공간 해움새들' WHERE provider_type = 'PUBLIC' AND external_id = '386435';
UPDATE festival SET title = '[마포문화재단] 제11회 M 클래식 축제 <불멸의 오페라>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '385004';
UPDATE festival SET title = '박효진 개인전 <따뜻하기도, 때로는 차기도 한.>', content = '', place = 'BoB House [성남]' WHERE provider_type = 'PUBLIC' AND external_id = '383875';
UPDATE festival SET title = 'BREEZE 《감각의 온도》', content = '<!-- wp:paragraph -->
<p><strong>BREEZE <감각의 온도></strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리나우는 해마다 <BREEZE>展을 통해 동시대 미술의 새로운 흐름을 만들어가며 미래의 미술 현장을 이끌어갈 젊은 작가들을 지속적으로 소개해오고 있다. 2026년 7월 개최되는 이번 전시는 박은영, 오지은, 전희경, 정윤영 네 명의 작가와 함께한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>감각은 눈에 보이지 않지만 분명하게 남는다. 어떤 기억은 특정한 색으로 떠오르고, 어떤 감정은 냄새나 소리로 되살아난다. 이미 지나가 버린 순간임에도 불구하고 몸은 그것을 기억한다. 오래전 바닷가에서 마주한 빛의 색감, 한여름 저녁의 습한 공기, 설명하기 어려운 불안의 진동, 문득 찾아오는 그리움의 기척. 감각은 사건보다 오래 남아 삶의 깊은 곳에 머문다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 서로 다른 방식으로 세계를 감각하는 네 작가의 작업을 통해 그 흔적들을 살펴본다. 이들이 관심을 두는 것은 특정한 대상을 묘사하는 일이 아니다. 오히려 기억이 지나간 자리, 감정이 머물렀던 흔적, 삶이 몸에 새겨놓은 미세한 결들에 가깝다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>박은영은 일상 속에서 발견한 색을 수집하고 기록한다. 조개껍데기와 유리 조각, 꽃잎과 나뭇잎에서 발견한 색들은 화면 위에서 다시 만나 하나의 풍경을 이룬다. 그의 작업에서 색은 단순한 재료가 아니라 경험이 남긴 기억의 저장소이자 시간을 축적하는 방식이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>오지은은 사라진 시간과 부재의 감정을 이야기한다. 시간이 흐를수록 구체적인 장면은 흐려지지만, 이상하게도 그때의 분위기와 색감은 더욱 선명하게 남는다. 작가는 붙잡을 수 없는 기억을 재현하기보다 그 주변을 맴도는 정서의 기류를 화면 위에 옮긴다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전희경은 일상의 불안과 생명력을 동시에 응시한다. 꿈과 현실, 통제와 충동 사이를 오가며 포착한 감각들은 화면 속에서 하나의 리듬을 형성한다. 특히 자연에서 마주한 소리와 에너지는 그의 작업에서 중요한 원천이 되며, 살아 있다는 감각 자체를 일깨운다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>정윤영은 존재의 불완전함과 삶의 위태로움을 들여다본다. 화면 속 유동적인 형상들은 완성된 모습이 아니라 끊임없이 흔들리고 변화하는 상태에 가깝다. 그는 삶의 균열을 외면하지 않고 그 안에서 발견되는 연민과 의지, 그리고 생의 아름다움을 조용히 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>네 작가의 작업은 서로 다른 방향에서 출발하지만 결국 감각이라는 하나의 지점에서 만난다. 기억은 색이 되고, 부재는 분위기가 되며, 불안은 리듬이 되고, 존재에 대한 질문은 형상으로 드러난다. 그렇게 각자의 경험은 저마다의 온도를 품은 채 화면 위에 머문다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>오늘, 우리는 수많은 이미지와 정보 속에서 살아가지만 정작 자신의 감각에 귀 기울이는 시간은 점점 줄어들고 있다. 이번 전시는 작품을 통해 잠시 멈춰 서서 자신 안에 남아 있는 감각의 흔적을 들여다보는 시간을 제안한다. 작품 앞에서 마주하게 되는 것은 어쩌면 작가의 이야기가 아닐지도 모른다. 오래전 잊고 있었던 자신의 기억, 자신의 감정, 그리고 자신만의 온도일 것이다.</p>
<!-- /wp:paragraph -->', place = '갤러리나우' WHERE provider_type = 'PUBLIC' AND external_id = '386737';
UPDATE festival SET title = '7월 한평갤러리 "이달의 작가" 김희망 《함께·행복》', content = '', place = '중랑아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '387194';
UPDATE festival SET title = '[서초문화재단x한국하프시코드협회 공동기획] ''건반 음악의 이정표를 찾아'' 시리즈1 <마디가 없는 프렐류드>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379726';
UPDATE festival SET title = '미하엘 잔데를링 & 루체른 심포니', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382480';
UPDATE festival SET title = '[대학로] 세이렌: 심연의 전이 ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '384908';
UPDATE festival SET title = '이사라 <A Girl From Wonderland>', content = '', place = '노화랑' WHERE provider_type = 'PUBLIC' AND external_id = '385433';
UPDATE festival SET title = '2026 MASTER''S SERIES II, New World America 250', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382474';
UPDATE festival SET title = '2026 뮤지컬 <숲속 100층짜리 집>', content = '', place = '성균관대학교 새천년홀' WHERE provider_type = 'PUBLIC' AND external_id = '385368';
UPDATE festival SET title = '김대유 개인전 <미워하는 미워하는 미워하는 마음 없이 A Rose by Any Other Name>', content = '', place = '16아카이브' WHERE provider_type = 'PUBLIC' AND external_id = '386198';
UPDATE festival SET title = '서울교방 홀춤전 김경희의 춤 ‘초음(初音)’', content = '', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '385530';
UPDATE festival SET title = '김응수 & 카메라타 솔, 겹의 미학 SERIES Ⅲ: Barber & Brahms & Bartok', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382579';
UPDATE festival SET title = '[과천] 2026 재즈로 푸른 밤 <Jazz＆Dance> Vol.1 - Swing', content = '', place = '과천시민회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '384611';
UPDATE festival SET title = '[제주 서귀포] 아동생태 그림자극 <리부이 떠오르는 빛>', content = '', place = '서귀포예술의전당 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '384628';
UPDATE festival SET title = '둘리뮤지엄 태백고생대자연사박물관 <K 라면과 구공탄> 순회전시', content = '', place = '태백고생대자연사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '387826';
UPDATE festival SET title = '[청주] 몰입형 근접마술공연 <미스테리움> ', content = '', place = '더매직스튜디오 ' WHERE provider_type = 'PUBLIC' AND external_id = '387551';
UPDATE festival SET title = '[고양] 리얼공룡쇼 <다이노>', content = '', place = '고양어울림누리 별모래극장' WHERE provider_type = 'PUBLIC' AND external_id = '382786';
UPDATE festival SET title = '뮤지컬 <로봇사용 설명서> 프리뷰공연', content = '', place = '성수아트홀(성수문화복지회관)' WHERE provider_type = 'PUBLIC' AND external_id = '386892';
UPDATE festival SET title = '토요명품', content = '전통 국악을 최적의 공간에서 가장 깊이 있고 다채롭게 만날 수 있는 국립국악원의 대표 주말 공연 <토요명품>한민족의 흥과 신명이 살아 숨 쉬는 노래와 음악, 춤을 비롯해세계가 인정한 유네스코 등재 무형문화유산까지.한국인과 외국인 모두 꼭 봐야할 한국의 전통 공연 예술이매주 토요일, 우면당 무대를 가득 채웁니다.대한민국 최고의 연주가들이 선사하는 <토요명품>을 통해 국악이가진 아름다움을 느껴보세요.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '384316';
UPDATE festival SET title = '피아니스트 염지원 독주회: The Flip, Vivace & Grave', content = '', place = '피오레아트앤엔터(피오레움) 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '386302';
UPDATE festival SET title = '[인천] M & M 시리즈 Ⅱ: 구노의 장엄미사 ', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382716';
UPDATE festival SET title = '[김포] 국립정동극장, 전통연희극 <광대:GWANGDAE>', content = '', place = '김포아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '383940';
UPDATE festival SET title = '국립심포니오케스트라 <베토벤, 교향곡 7번>', content = '괴테 문학과 엮은 낭만주의와 베토벤의 교향곡 7번으로 구성된 음악감독 로베르토 아마도의 무대', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382408';
UPDATE festival SET title = '[부산] 2026 짙은 콘서트: 고요한 여름 ', content = '', place = 'KT&G 상상마당 라이브홀 [부산] 라이브홀' WHERE provider_type = 'PUBLIC' AND external_id = '382672';
UPDATE festival SET title = '호기우타', content = '일본 현대희곡의 거장 기타무라 소의 부조리극 <호기우타>인류세의 종말이라는 무거운 주제를 독특하고 유머러스한 ''밝은 허무''의 정서로 풀어낸다', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '383624';
UPDATE festival SET title = '김우진 첼로 독주회 "Russian Cello Sonatas"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '385137';
UPDATE festival SET title = '[상주단체 공공프로그램] 찾아가는 음악회 <한 교시 클래식>', content = '', place = '구로문화원' WHERE provider_type = 'PUBLIC' AND external_id = '388032';
UPDATE festival SET title = '2026 도민의 집 하반기 ''화·목''한 아카데미', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '386424';
UPDATE festival SET title = '성북문화예술교육 실험실 <다른 속도로, 아직 가는 중입니다> 참여자 모집 (~7/2)', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '384366';
UPDATE festival SET title = '2026년 특별기획전 ''시간 저장소 : 그날의 데이터''', content = '', place = '울산암각화박물관' WHERE provider_type = 'PUBLIC' AND external_id = '387819';
UPDATE festival SET title = '진용재 & 진성민 듀오 리사이틀', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '384877';
UPDATE festival SET title = '<함께 양양> ''함께 요가 - 서로의 마음을 잇는 호흡''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '386429';
UPDATE festival SET title = '토끼의 자격', content = '<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>화면에 등장하는 형상들은 완전한 토끼의 모습을 갖추고 있지 않다. 몸의 구조는 불분명하고, 서로 관계없어 보이는 이미지와 기호가 뒤섞여 있으며, 때로는 생물보다 사물이나 흔적에 가까워 보인다. 그럼에도 긴 귀가 더해지는 순간, 관객은 대체로 그것을 토끼라고 읽는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>긴 귀만 붙였다고 모든 형상이 토끼가 되는 것은 아니다. 그러나 실제 이미지 앞에서는 그 단서가 생각보다 빠르고 강하게 작동한다. 관객은 형상의 정체를 충분히 검토하기 전에 토끼라는 이름을 떠올리고, 그 뒤에야 자신이 내린 판단을 의심한다. 논리적인 설명보다 인식이 먼저 도착하는 셈이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>긴 귀는 토끼의 본질을 증명하기보다 이미지를 특정한 방향으로 읽게 만드는 최소한의 표식에 가깝다. 서로 다른 형상도 긴 귀가 더해지면 하나의 범주 안으로 들어오고, 반대로 그 귀가 사라지면 전혀 다른 것으로 보일 가능성이 커진다. 적은 정보가 강한 인식을 만들어내지만, 그 인식이 형상의 모든 것을 설명해주지는 않는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작업 과정에서는 토끼라고 읽힐 만큼의 단서를 남기되, 화면 전체가 그 이름에 완전히 귀속되지는 않도록 한다. 형상은 토끼처럼 보이면서도 사물, 인물, 기계, 기호, 기억의 잔상 같은 다른 가능성을 함께 품는다. 하나의 이름이 형상을 빠르게 이해하게 만들지만, 화면 안의 다른 요소들은 그 이름과 계속 어긋난다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>우리는 몇 가지 익숙한 특징을 근거로 낯선 이미지를 분류하고, 그 안에서 표정과 의도, 감정과 기억의 흔적을 읽어낸다. 형상이 실제로 무엇인지 충분히 알기 전에도, 닮았다는 감각만으로 하나의 존재를 상상하기 시작한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그러나 어떤 형상을 익숙한 존재처럼 읽는 것과 그것을 온전히 같은 존재로 받아들이는 일은 다르다. 인간과 닮은 얼굴이나 몸, 반응과 기억을 가진 형상 앞에서도 그 닮음이 어디까지 유효한지는 쉽게 결정되지 않는다. 익숙한 표식은 낯선 존재를 가까이 끌어당기지만, 설명되지 않는 차이는 다시 경계를 만들어낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>화면 속 형상들은 토끼와 토끼가 아닌 것, 생물과 사물, 익숙한 존재와 아직 분류되지 않은 존재 사이를 오간다. 무엇을 닮았는지에 따라 이름은 빠르게 주어지지만, 그 이름만으로 형상의 정체와 지위까지 모두 설명할 수 있는지는 남겨진다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>긴 귀는 정답이 아니라 방향이다. 그것은 토끼라는 이름을 불러내면서도, 그 이름으로는 설명되지 않는 나머지를 함께 남긴다. 토끼는 하나의 대상을 재현하기 위한 형상이라기보다, 이미지가 만들어지고 읽히는 방식을 드러내는 장치에 가깝다. 화면은 토끼로 읽히는 순간과 다시 낯선 형상으로 흩어지는 순간 사이에 머문다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>임정철  Lim Jungcheol</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>SOLO Exhibition</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td>2026 </td><td> 토끼의 자격 갤러리밈, 서울​</td></tr><tr><td>2025 </td><td> 토끼 귀는 그렇게 길었나?, CYART Space, 서울​​ </td></tr><tr><td> </td><td> 선 위의 토끼, 블루원 갤러리, 서울, 한국​​</td></tr><tr><td>2024</td><td> 말하지 않는 토끼, 갤러리 O, 서울, 한국​​</td></tr><tr><td>2023 </td><td> 고대 토끼 미스터리, 라운디드 플랫, 서울, 한국​​</td></tr><tr><td> </td><td> 게임: 토끼 퍼즐, 갤러리 이데아 홀, 서울, 한국​​</td></tr><tr><td>2021</td><td> 스페이스 버니, 아트스페이스 그로브, 서울, 한국​</td></tr><tr><td>2018</td><td> 카툰리스틱, 아트스페이스 노, 서울, 한국</td></tr><tr><td>2017</td><td> 스트리트 X 온라인, 청년문화공간 주, 서울, 한국</td></tr><tr><td>2016</td><td> WE GIG, 메이드 바이 앙코 갤러리, 콜럼버스, 오하이오 미국</td></tr><tr><td>2014</td><td> Independent, 언노운 개러지, 콜럼버스, 오하이오, 미국​</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>GROUP Exhibition</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td>2026 </td><td> Frame2026, 갤러리 키퍼리, 서울</td></tr><tr><td>2025 </td><td> 무지개오징어, 갤러리 아이디어회관,서울, 한국​</td></tr><tr><td> </td><td> 라​​포디움, 로하 갤러리, 서울, 한국​​​​</td></tr><tr><td> </td><td> 트웬티파이브, YK 갤러리, 서울, 한국​​</td></tr><tr><td> </td><td> UPRISING FESTA Vol.1, SETEC, 서울, 한국​​</td></tr><tr><td> </td><td> 세컨핸드 니코틴; 패시브 스모킹, POV 갤러리, 서울, 한국​​</td></tr><tr><td> </td><td> 문라이트 전시, 갤러리 B, 서울, 한국​​</td></tr><tr><td> </td><td> 동묘 한마당, 갤러리 이데아 홀, 서울, 한국​​</td></tr><tr><td> </td><td> 미확인 오브젝트, 갤러리 온도, 서울, 한국​​</td></tr><tr><td>2024</td><td> 코스모스, 블루원 갤러리, 서울, 한국</td></tr><tr><td> </td><td> 인피니티, 춘천미술관, 춘천, 한국​ ​</td></tr><tr><td> </td><td> 라스트 나잇 드림, 블루원 갤러리, 서울, 한국​</td></tr><tr><td> </td><td> R.road, 아카이브, 춘천, 한국​</td></tr><tr><td> </td><td> 서울 아트, 갤러리 이데아 홀, 서울, 한국​</td></tr><tr><td> </td><td> 리-제너레이션, 한가람미술관, 서울, 한국 </td></tr><tr><td> </td><td> 스프링 멜로디, 블루원 갤러리, 서울, 한국​ </td></tr><tr><td>2023</td><td> 컬러풀 이스케이프, 갤러리 A&C 성수, 서울, 한국</td></tr><tr><td> </td><td> BAMA 호텔 아트페어, 그랜드 조선 부산, 부산, 한국</td></tr><tr><td> </td><td> 성수 아트페어, S-팩토리, 서울, 한국  </td></tr><tr><td> </td><td> TO THE FUTURE, 동대문디자인플라자(DDP), 서울, 한국</td></tr><tr><td> </td><td> 미스틱 버니즈, 클램프 갤러리, 서울, 한국  </td></tr><tr><td> </td><td> 춘천 아트로드, 춘천문화예술회관, 춘천, 한국</td></tr><tr><td> </td><td> 블루밍 아트, 현대 프리미엄 아울렛 김포, 김포, 한국 </td></tr><tr><td> </td><td> 두 낫 리드, 에코락 갤러리, 고양, 한국 ​ </td></tr><tr><td>2022</td><td> 뭄바이 비엔날레, Sir J.J. 아트 홀, 뭄바이, 인도</td></tr><tr><td> </td><td> 상상력은 비범하다, 갤러리 EO, 서울, 한국</td></tr><tr><td> </td><td> 위드 아트페어, 인터컨티넨탈 호텔, 서울, 한국 </td></tr><tr><td> </td><td> 인공 자연, CCA 갤러리, 서울, 한국</td></tr><tr><td> </td><td> NET FAIR ART DMZ, 지지향, 파주, 한국 </td></tr><tr><td> </td><td> 패뷸러스 랑데부, 클램프 갤러리, 서울, 한국</td></tr><tr><td> </td><td> FLEA GROUND, KT&G 상상마당 홍대, 서울, 한국   </td></tr><tr><td> </td><td> So Fun & Life Show, 코엑스, 서울, 한국</td></tr><tr><td> </td><td> 핑크 아트페어, 인터컨티넨탈 호텔, 서울, 한국</td></tr><tr><td> </td><td> 어반브레이크, 코엑스, 서울, 한국    </td></tr><tr><td> </td><td> 컴포트: 비타민을 섭취하는 것처럼, 금산갤러리, 서울, 한국 </td></tr><tr><td> </td><td> 언유주얼, 몬드리안 호텔 이태원, 서울, 한국 </td></tr><tr><td> </td><td> BAMA (부산국제화랑아트페어), 벡스코, 부산, 한국​</td></tr><tr><td>2021​</td><td> BIAF (부산국제아트페어), 벡스코, 부산, 한국</td></tr><tr><td> </td><td> BIAF 선정작가 특별전, 마루갤러리, 인사동, 서울, 한국 </td></tr><tr><td> </td><td> 아트마켓, 갤러리25, 서울, 한국</td></tr><tr><td> </td><td> 어반브레이크, 코엑스, 서울, 한국 </td></tr><tr><td> </td><td> BAMA (부산국제화랑아트페어), 벡스코, 부산, 한국​ </td></tr><tr><td>2020 </td><td> 호프 동동, 강원대학교 어린이병원, 춘천, 한국</td></tr><tr><td> </td><td> 뉴 웨이브, 아틀리에 갤러리, 서울, 한국 </td></tr><tr><td> </td><td> BAMA (부산국제화랑아트페어), 벡스코, 부산, 한국​ </td></tr><tr><td>2018</td><td> TRAP ON SHORT NORTH, 크리에이티브 플러그 갤러리, 콜럼버스, 오하이오, 미국</td></tr></tbody></table></figure>
<!-- /wp:table -->', place = '갤러리밈' WHERE provider_type = 'PUBLIC' AND external_id = '390092';
UPDATE festival SET title = 'Calling from the Eye of the Storm', content = '<!-- wp:paragraph -->
<p>Park Sebin</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>우리는 보이지 않는 전쟁 속에 있다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>세상에 만연한 악과 영원한 사랑, </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>육과 영, 어두움과 빛의 세력 사이의 싸움.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>태풍의 눈은 가장 거센 바람벽으로 둘러싸여 있으면서도</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그 중심은 기이할 정도로 맑고 평온하다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>스스로를 구원할 수 없는 이 가벼운 흙 한 줌이 </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>휘몰아치는 태풍 한가운데 평안할 수 있음은</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>오직 승리하신 사랑 안에 거하기 때문이라.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>하늘로부터 온 화평과 영원에 대해 다룬 지난 개인전 </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><Peace from Above>의 맥락을 이어</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>빛을 따라 걷는 길에서 비롯된 심상을 </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>암시적인 풍경으로 표현한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>기쁨과 인내, 간구와 믿음의 복합적인 온도가</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>한 화면에 고요함으로 담긴다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이들은 쌓이고 응축되어 </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>오묘한 긴장감과 따스한 희망감을 형성한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>묵상적인 제목과 이미지 사이에서</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>스미는 빛이 그림 앞에 선 분들의 마음에 읊조려지길 바란다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>모든 혼란과 아우성 가운데 유일한 참 피난처로,</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>통제할 수 없는 마지막 태풍이 오기 전에</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>진실을 마주하는 부르심을 듣게 되기를 간절히 구한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>SOLO Exhibition</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td>2026 </td><td> Calling from the Eye of the Storm, 갤러리밈, 서울</td></tr><tr><td> </td><td> ‘Peace from Above’, 리나 갤러리, 서울​​</td></tr><tr><td>2023 </td><td> ‘Silent Regards’ 초대 개인전, 갤러리 위, 경기​</td></tr><tr><td> </td><td> ‘Reminder’ 자체기획 개인전·오픈스튜디오, 경기​​</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>GROUP Exhibition</strong><strong>  </strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td>2026​ </td><td>San Francisco Art Fair 2026 (Gallery Playlist)​​</td></tr><tr><td> </td><td> ‘Art We Love’, 카린 갤러리, 부산​</td></tr><tr><td>2025</td><td>​ 서울 아트쇼, 서울​</td></tr><tr><td> </td><td> Art Gaga 11월 그룹전·12월 선물전, 아트가가, 서울​​</td></tr><tr><td> </td><td> COLLECTIBLES : 공간미학, 신세계갤러리 센텀시티, 부산​</td></tr><tr><td> </td><td> Soft Landing, 갤러리 플레이리스트, 샌프란시스코​​</td></tr><tr><td> </td><td> The Moment Between 2인전, 갤러리 플레이리스트, 부산​​</td></tr><tr><td> </td><td> The Still Hour 3인전, 카린 갤러리, 부산</td></tr><tr><td> </td><td> San Francisco Art Fair 2025 (Gallery Playlist)​</td></tr><tr><td> </td><td> ‘Post Scripts’ 3인전, 갤러리 로윤, 서울​​</td></tr><tr><td>2024<strong> </strong>​</td><td><strong> </strong>‘Montage of Love’, 뚝섬미술관, 서울​​</td></tr><tr><td> </td><td> ‘We are rising’ 2인전, 미기 갤러리, 서울​​</td></tr><tr><td> </td><td>‘Pit-a-pat’ 7인전, 카린 갤러리, 부산​​</td></tr><tr><td>2023</td><td><strong> </strong>‘감은 눈만 뜨시면 됩니다’, 갤러리 누아, 서울​</td></tr><tr><td> </td><td><strong> </strong>‘사실상상실’, 서교예술실험센터, 서울​</td></tr><tr><td> </td><td><strong> </strong>‘PRO_logue’ 6인전, 현대백화점 PBG 판교​​</td></tr><tr><td>2022<strong> </strong>​</td><td><strong> </strong>‘나의 여름에게’ 4인전, 폴스타 아트갤러리 성수, 서울​</td></tr><tr><td> </td><td> ‘가끔은 숲으로 도망치고 싶어져’ 5인전, 무목적, 서울​</td></tr><tr><td> </td><td>​<strong> </strong>하남 스타필드 상생 아트 페스티벌, 경기​</td></tr><tr><td>2021 </td><td> ‘This or that’ 4인전, 무우수 갤러리, 서울​</td></tr><tr><td> </td><td> ‘Spread & Pause’ 연합전, 홍익대학교, 서울​</td></tr><tr><td> </td><td><strong> </strong>라코스테 × 폴라로이드 콜라보, 가로수길, 서울</td></tr><tr><td>2020​</td><td>제5회 서울 국제 아트쇼, 갤러리 보다, 서울​</td></tr><tr><td>2016​</td><td> 서울 국제 아트쇼, 갤러리 라메르, 서울​​</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>Projects / 협업</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td>2025 </td><td> 혜진 ‘모닥불’ 앨범 커버 아트​​</td></tr><tr><td> </td><td> Artsy Foundations 2025 — Curator’s Pick 선정​​</td></tr><tr><td>2024 </td><td> 혜진 ‘수몽’ 앨범 커버 아트​​</td></tr><tr><td>2023</td><td> 《Life Stills》 아트북, Victionary (6점 수록)​</td></tr><tr><td>2022</td><td> 밀리의 서재 오브제북 영상 6건​​</td></tr><tr><td> </td><td> 밀리의 서재 — 황인찬 《잃어버린 마음을 찾아서》 표지·일러스트​​</td></tr><tr><td> </td><td> 밀리의 서재 — 오은 《시간의 뒷면》 표지·일러스트​​</td></tr><tr><td> </td><td> 혜진 ‘작은별’ · 태리 ‘하루살이’ 앨범 커버 아트​​</td></tr><tr><td>2021 </td><td><strong> </strong>K옥션 프리미엄 온라인 경매 참가 (각 1점 낙찰)​​</td></tr><tr><td> </td><td> Poset · Collected · 오픈갤러리 입점​​</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>수상</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td>2019 </td><td> 경희대 제24회 전국 학생미술 실기대회 동상​​</td></tr><tr><td> </td><td> 동덕여대 제6회 전국 학생미술 실기대회 동상​</td></tr><tr><td>2016</td><td> 월간 《아트》 / 서울 국제 아트쇼 대회장상</td></tr></tbody></table></figure>
<!-- /wp:table -->', place = '갤러리밈' WHERE provider_type = 'PUBLIC' AND external_id = '390093';
UPDATE festival SET title = ' 박재준 무반주 전곡 바이올린 독주회 YSAŸE and the Partitas "Part 1. The Abyss"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '374309';
UPDATE festival SET title = '제1015회 목요예술무대 <세 번째 파장, 민우혁>', content = '', place = '강남씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '384701';
UPDATE festival SET title = '연극 <더 헬멧>', content = '', place = '홍익대 대학로 아트센터 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '383335';
UPDATE festival SET title = '[대구] DSAC 프로덕션 뮤지컬 <월곡> ', content = '', place = '웃는얼굴아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '383302';
UPDATE festival SET title = '김성훈 피아노 독주회 Great Composer "B"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '379930';
UPDATE festival SET title = '서리풀 전곡 연주 시리즈 <하이든 교향곡 35"London">', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '385173';
UPDATE festival SET title = '한화생명과 함께하는 예술의전당 11시 콘서트(7월)', content = '7월 9일, 친구콘서트 특집! 최형록 & 이동하 피아노 듀오, 김영욱 바이올린 & 이한나 비올라 듀오로 꾸려진 두 친구 앙상블을 만날 수 있는 특별한 마티네 콘서트', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384241';
UPDATE festival SET title = '공포스릴러 연극 <시그널>', content = '', place = '공간아울' WHERE provider_type = 'PUBLIC' AND external_id = '383663';
UPDATE festival SET title = '2026 공성환 개인전 <파문 ; Ripple>', content = '', place = '갤러리 제이원 서울' WHERE provider_type = 'PUBLIC' AND external_id = '389420';
UPDATE festival SET title = '[울산] 울산광역시 승격 29주년 기념오페라 <사랑의 묘약> ', content = '', place = '울산문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '383574';
UPDATE festival SET title = '[부평] 테이블 인형극 <꼬마오즈> ', content = '', place = '부평문화사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '387314';
UPDATE festival SET title = '연극 <빵야>', content = '역사를 ''관통한'' 장총과 역사를 ''써먹을'' 궁리만 하던 작가의 뜨거운 만남. 모두에게 잊혀 버린 ''낡은 장총 한 자루''에 담긴 이야기와 그 시선에서 바라본 우리의 현대사', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '383457';
UPDATE festival SET title = '[연천] 秀(수)''s PICK, 분홍립스틱 ', content = '', place = '연천수레울아트홀 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '383929';
UPDATE festival SET title = '서구가요무대 <남진 콘서트>', content = '', place = '인천서구문화회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '380782';
UPDATE festival SET title = '테너 최원혁 리사이틀: Romantic & Verismo', content = '', place = '영산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '383802';
UPDATE festival SET title = '[부산] 부산오페라하우스 야외오페라 <카르멘> ', content = '', place = '부산 북항 랜드마크 부지 야외 특설무대 ' WHERE provider_type = 'PUBLIC' AND external_id = '385486';
UPDATE festival SET title = '강북Festa, 극창작소 별별생각 ‘삼색이의 대모험’', content = '', place = '강북문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '383939';
UPDATE festival SET title = '신구＆박근형 <베니스의 상인> 기부공연', content = '', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '383782';
UPDATE festival SET title = '[JS아트홀] 연극 <2호선세입자> 지하철 생존 코미디', content = '', place = 'JS아트홀 (구. 고스트씨어터 구.다소니씨어터)' WHERE provider_type = 'PUBLIC' AND external_id = '384861';
UPDATE festival SET title = '[서울남산국악당] 동해안별신굿 <굿도 보고 떡도 먹고>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '385144';
UPDATE festival SET title = '2026 성남아트센터 오페라 정원〈바람의 노래〉', content = '오페라 <바람의 노래>는 일제강점기부터 한국전쟁을 거쳐 근현대에 이르는 격동의 시간 속에서도 우리말과 우리글, 민족의 정서를 노래로 지켜 온 작곡가 박태현의 음악을 모티프로 삼은 창작 오페라', place = '성남아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '383240';
UPDATE festival SET title = '2026 수봉IN기획공연 <에코와 멜로디의 애니멀 심포니>', content = '', place = '인천수봉문화회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '384349';
UPDATE festival SET title = '[대전] 2026 베스트셀러 뮤지컬 <커다란 방귀> ', content = '', place = '대전평송청소년문화센터' WHERE provider_type = 'PUBLIC' AND external_id = '383824';
UPDATE festival SET title = '2026 놀이기반 문화예술교육 프로그램 <더 놀다가>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '386196';
UPDATE festival SET title = '사물의 가치', content = '로댄스프로젝트 <사물의 가치> “기술의 시대, 누구도 복제할 수 없는 몸의 떨림과 숨의 리듬으로 인간다움의 가치를 묻는다.”', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '383630';
UPDATE festival SET title = '[나주] 판타지발레 <구미호>', content = '', place = '나주문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '387142';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 <여름, 제주바다>', content = '', place = '국립극장 무대예술지원센터' WHERE provider_type = 'PUBLIC' AND external_id = '387270';
UPDATE festival SET title = '로데아트센터 개관 2주년 기념 FRIENDS 시리즈, Generations & Friends', content = '', place = '로데아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '385829';
UPDATE festival SET title = '조혜정 피아노 독주회: Debussy''s Images', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '383706';
UPDATE festival SET title = '[대전] 리얼공룡쇼 <다이노>', content = '', place = '대전평송청소년문화센터' WHERE provider_type = 'PUBLIC' AND external_id = '386053';
UPDATE festival SET title = '[전주] 샌드아트 & 오케스트라 호두까기인형 ', content = '', place = '한국소리문화의전당 연지홀' WHERE provider_type = 'PUBLIC' AND external_id = '384674';
UPDATE festival SET title = '2026 창작ing 무용 <몸 4개의 강 (一夜九渡河)>', content = '칠흑 같은 밤, 오감에 의지해 아홉 번 강을 건너는 연암의 여정을 몸의 서사로 무대화한다', place = '국립정동극장 세실 (구.세실극장)' WHERE provider_type = 'PUBLIC' AND external_id = '382608';
UPDATE festival SET title = '연극 배우 워크숍 <2026 전집: 나는 배우, 배우는 나>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '388286';
UPDATE festival SET title = '2026 춘천문화예술회관 고음악 시리즈 ''고음악의 향연'' <이탈리안 바로크 Ⅳ >', content = '춘천고음악제CIEMF앙상블과 소프라노 임선혜가 선사하는 오페라 세리아와 바로크 협주곡의 만남. 성악과 기악이 함께 완성하는 찬란한 바로크 무대', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '384407';
UPDATE festival SET title = '광명문화재단 여름방학 기획 전시 <뒹굴고, 반짝이고, 하이파이브!> 안내', content = '', place = '광명시민회관 전시실' WHERE provider_type = 'PUBLIC' AND external_id = '387916';
UPDATE festival SET title = '2026 여우락 페스티벌 - 하림X구이임 <먼 아리랑, Part Ⅱ :닿은 시선, 그은 시선>', content = '싱어송라이터이자 월드뮤직 음악의 선구자인 하림과 국악그룹 구이임이 만나 콘서트 형식으로 새롭게 꾸미는 먼 아리랑 무대', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '384076';
UPDATE festival SET title = '2026 소울 첼로 앙상블 정기연주회 “꿈결의 리듬”', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '385143';
UPDATE festival SET title = '동대문구 아르코 2026년 기획공연 <콘서트 청(淸):ON(7월)> 장하은 클래식 기타 콘서트', content = '', place = '동대문구 아르코(DDM ARCO)' WHERE provider_type = 'PUBLIC' AND external_id = '385701';
UPDATE festival SET title = '제3회 R&J씨어터 창작극 페스티벌, 환몽소설', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '384616';
UPDATE festival SET title = '대학로1등 코믹판타지연극 <타임> ', content = '', place = '대학로 스타릿홀 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '383662';
UPDATE festival SET title = 'AI 미디어아트 전시 워크숍 ''맛을 깨우는 빛''', content = '', place = '양양문화복지회관' WHERE provider_type = 'PUBLIC' AND external_id = '387517';
UPDATE festival SET title = '아름다운 목요일 영 오디세이: 베토벤, Ⅰ. 이현정 & 손지우 Violin', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '386697';
UPDATE festival SET title = '무용단 기획공연 <춤, 화찬(畵贊)>', content = '조선 후기 화가 혜원 신윤복의 그림을 춤으로 재해석한 무용극으로 그림 속 인물들의 감정과 사랑 이야기를 현대적인 춤으로 풀어내며, 사회적 통념 속에서 억눌린 인간 본연의 감정을 탐구합니다. 130석 규모의 소극장에서 관객과 가까이 호흡하며 ‘작은 공간의 큰 춤’을 보여주는 이번 공연은 삶과 사랑의 본질에 대한 질문을 던지는 무대가 될 것입니다.', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '384319';
UPDATE festival SET title = '[파주] 전통은 지금, 춤춘다 NOW & ROOT ', content = '', place = '운정주민자치센터' WHERE provider_type = 'PUBLIC' AND external_id = '385491';
UPDATE festival SET title = '2026 여우락 페스티벌 - 상자루X안예은 <4는1>', content = '전통 정서를 현대의 언어로 노래하는 안예은과 다양한 전통 악기를 연주하는 3인조 밴드 상자루와의 독특하고 개성 강한 만남', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '384077';
UPDATE festival SET title = '연극 <낭만적인 개소리>', content = '', place = '서강대 메리홀 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '384556';
UPDATE festival SET title = '2026년 홍익대학교 박물관 교육프로그램 <사유의 발화점 - 나의 시선으로 읽기> 참여자 모집', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389131';
UPDATE festival SET title = '[부안] 콘사노 체임버 오케스트라 열린 음악회: 장사익 & 김주환 밴드 ', content = '', place = '부안예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '388212';
UPDATE festival SET title = '특별기획전시 <마티에르! 박수근과 함께한 동시대작가展>', content = '', place = '양구군립 박수근미술관' WHERE provider_type = 'PUBLIC' AND external_id = '394077';
UPDATE festival SET title = '광명문화재단 [광명 스테이지 ON:] <구름도사와 송이도사: 빨간 괴물의 습격>', content = '', place = '광명시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '384969';
UPDATE festival SET title = '[평택] 아시아국제피아노 아카데미 & 페스티벌 (AIPAF), 교수연주회', content = '', place = '평택남부문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '386252';
UPDATE festival SET title = '소프라노 양귀비 & 메조소프라노 김미영의 혁신', content = '', place = '예술의전당 [서울]' WHERE provider_type = 'PUBLIC' AND external_id = '384865';
UPDATE festival SET title = '[고양] 화류비련극 <홍도> ', content = '', place = '고양어울림누리 어울림극장' WHERE provider_type = 'PUBLIC' AND external_id = '386552';
UPDATE festival SET title = '2026 꿈다락문화예술학교 <조각의 공원: 공간을 조형하다>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '385337';
UPDATE festival SET title = '맥화랑연례기획전20th《10-200, 행복한그림전》', content = '<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left"><strong>20년 동안 이어진 ‘미술품 소장의 시작’</strong> <strong>맥화랑연례기획 《10-200, 행복한 그림전》 20주년 개최</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">부산 해운대 맥화랑은 7월 18일부터 8월 22일까지 《10-200, 행복한 그림전》을 개최한다. <strong>올해로 스무 번째를 맞이한 이번 전시</strong>는 2007년 시작 이후 단 한 해도 거르지 않고 이어져 온 맥화랑의 대표 여름 연례기획전으로, ‘미술품 소장의 대중화’와 ‘갤러리 문턱 낮추기’라는 기치 아래 20년 동안 많은 작가와 컬렉터들의 사랑을 받아왔다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">2007년, 《10만원대 행복그림전》이라는 이름으로 처음 시작된 전시는 당시 40여 명의 작가와 80여 점의 작품을 선보이며 일회성 기획으로 출발했다. 그러나 좋은 작품을 보다 많은 사람들이 부담 없이 소장할 수 있도록 하자는 취지에 공감한 작가들과 꾸준한 참여와 관람객들의 성원 속에 해마다 규모를 키워왔고, 이제는 여름이면 전국의 컬렉터들이 기다리는 연례기획 전시로 자리매김했다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">20년의 시간은 전시뿐 아니라 참여 작가들의 성장도 함께 기록했다. 초기 전시에 참여했던 신진, 청년 작가들은 한국 미술계를 대표하는 중견 작가로 성장했고, 학생 시절 이 전시를 관람했던 이들이 시간이 흘러 작가가 되어 다시 전시에 참여하는 일도 이어졌다. 한 해의 전시가 다음 해의 인연이 되고, 한 작가의 참여가 또 다른 작가를 소개하며 《10-200, 행복한 그림전》은 작가와 컬렉터, 갤러리가 함께 만들어온 살아있는 아카이브가 되었다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"center"} -->
<p class="has-text-align-center"></p>
<!-- /wp:paragraph -->

<!-- wp:image {"align":"center","id":19685,"sizeSlug":"thumbnail","linkDestination":"none"} -->
<figure class="wp-block-image aligncenter size-thumbnail"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/07/2026-행복한그림전-카드형_이미지-13-480x639.jpg" alt="" class="wp-image-19685" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">1회부터 20회까지의 참여 명단을 종합해보면 지금까지 총 448명의 작가가 전시에 참여했으며, 20회 누적 참여 건수는 1,580건, 누적 출품작 수는 약 3,860여 점에 이른다.<strong> 2026년 올해도 신진, 청년, 중견, 원로, 작고 작가까지 61명의 작가들이 전시에 참여하며, 회화, 조각, 사진, 판화 등 다양한 장르의 작품 200여 점을 선보인다. </strong>참여작가로는 작고 작가인 <strong>김점선, 성백주</strong> 작가부터 2021 국립현대미술관 ''올해의 작가상''의 <strong>방정아</strong> 작가, 2022 부산 비엔날레 참여를 통해 예술계의 큰 주목을 받은 <strong>감민경</strong> 작가, 40년 가까운 시간을 연필 하나로 작업하며 국립현대미술관, 부산시립미술관, 광주시립미술관 등에서 전시를 한 <strong>김은주</strong> 작가, 2018 광주비엔날레와 2023 부산비엔날레 바다미술제 등에서 장소특정적 설치작업을 선보여 온 <strong>손몽주</strong> 작가를 비롯하여 중견 작가 <strong>강혜은, 김섭, 신철, 신홍직, 안윤모, 조현서, 허문희,</strong> 청년 작가 <strong>김서울, 김현수, 김효은, 박진성, 임승현, 장건율, 최례, 태우</strong> 등 현재 미술 시장에서 활발하게 활동하는 여러 작가들의 작품을 200만 원 이하라는 합리적인 가격으로 만나볼 수 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">활발히 활동하는 작가들에게, 특히 가격대가 맞지 않는 중견, 원로 작가들에게 200만 원이라는 가격 제한에 맞춰 작품을 출품 요청하는 것은 결코 쉬운 일이 아니다. 그럼에도 많은 작가들이 전시의 취지에 공감하며 특별히 소품을 준비하거나 기존 작품가보다 낮은 가격으로 작품을 출품하며 전시에 동참한다.<strong> </strong>''좋은 작품을 더 많은 사람들에게 소개하고 싶다''라는 전시의 철학에 함께 해주는 작가들 덕분에 이 전시가 스무 해를 이어올 수 있었다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">20년 전만 해도 미술품을 소장한다는 일은 일부 컬렉터만의 특권처럼 여겨졌다. 그러나 지금은 자신의 공간에 어울리는 작품 한 점을 선택하고, 그 작품과 함께 일상을 살아가는 일이 많은 사람들에게 자연스러운 문화가 되었다. 《10-200, 행복한 그림전》은 이러한 변화와 함께 성장하며 <strong>''좋은 작품을 더 많은 사람들에게''</strong>라는 처음의 취지를 꾸준히 실천해 왔다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">이 전시는 수많은 사람들의 ''첫 컬렉션''이 시작된 곳이기도 하다. 갤러리를 찾고, 그림을 스스럼없이 구매하는 관람객들의 연령대도 갓 사회생활을 시작하는 20대 청년들부터 자녀들과 함께 방문하는 가족 단위의 관람객, 결혼하는 자녀나 손자, 손녀에게 작품을 선물하고 싶어 방문했다는 6-70대까지 다양하다. 전시를 관람하는 모든 이의 얼굴엔 설렘과 행복이 가득하다. 이런 이들을 보면 ‘10-200만원, 행복한 그림전’이 2007년 처음 시작되었을 때의 기획 의도였던<strong> </strong><strong>‘</strong><strong>갤러리 문턱 낮추기</strong><strong>’</strong>와<strong> </strong><strong>‘</strong><strong>미술품 소장의 대중화</strong><strong>’</strong>가 분명 실현되고 있음을 체감한다. 스무 번의 전시를 이어 온 맥화랑 장영호 대표는 "《10-200, 행복한 그림전》은 단순히 합리적인 가격의 작품을 판매하는 전시에 그치지 않는다. 예술이 일상 가까이에 머물 수 있다는 가능성을 20년 동안 함께 만들어온 프로젝트"라며 "이번 스무 번째 전시 역시 더 많은 분들이 자신의 취향에 맞는 작품을 만나고, 작품을 소장하는 기쁨을 경험하는 계기가 되길 바란다"고 전했다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">맥화랑 연례기획 스무 번째 《10-200, 행복한 그림전》은 오는 7월 18일부터 8월 22일까지 부산 해운대 맥화랑에서 개최되며, 별도의 예약 없이 관람 및 작품 구매가 가능하다. 전시장에는 지난 20회 동안 작품을 출품한 작가들의 명단이 정리된 아카이브 자료도 함께 살펴볼 수 있다.</p>
<!-- /wp:paragraph -->', place = '맥화랑' WHERE provider_type = 'PUBLIC' AND external_id = '389883';
UPDATE festival SET title = '2026 뮤직아트센터 프로젝트 #12 자연 《아 템포 a tempo》', content = '', place = 'KT&G 상상마당 [춘천]' WHERE provider_type = 'PUBLIC' AND external_id = '392284';
UPDATE festival SET title = '2026 여우락 페스티벌 - 컨트리공방X정윤형 <놀:음>', content = '이야기를 들려주는 음악, 컨트리음악 장르 중 하나인 블루그래스 5인조 밴드와 젊고 깊은 소리꾼 정윤형과의 만남', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '384078';
UPDATE festival SET title = '[제주 서귀포] 끌로드아트홀 99th 심소연 설민주 장유림 <삶과사랑>', content = '', place = '끌로드아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '388329';
UPDATE festival SET title = '[인천] 클래식 인사이트 Ⅲ : 인천 클라리넷 앙상블 <한국의 전래놀이 콘서트>', content = '', place = '아트센터 인천 다목적홀' WHERE provider_type = 'PUBLIC' AND external_id = '386689';
UPDATE festival SET title = 'IBK기업은행과 함께하는 예술의전당 토요콘서트 - 프리뷰 베토벤(7월)', content = '토요일 오후, 베토벤 피아노 협주곡 제4번과 교향곡 제9번 "합창"을 한 자리에서 만나볼 수 있는 특별한 무대', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384243';
UPDATE festival SET title = '2026 강북Festa, 데마시아 ‘디어산타’', content = '', place = '강북문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '384889';
UPDATE festival SET title = '[꿈의숲아트센터] 올리브와 찐콩 <피노키오 트라이얼>', content = '', place = '꿈의숲아트센터 퍼포먼스홀' WHERE provider_type = 'PUBLIC' AND external_id = '383463';
UPDATE festival SET title = '2026 여우락 페스티벌 - 김백찬X김반장과 생기복덕 <생기로운 장단생활>', content = '작곡가 김백찬과 록 밴드 김반장과 생기복덕이 만나 음악이 주는 치유와 환기의 효과를 중점에 둔 대중적인 굿 무대', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '384079';
UPDATE festival SET title = '첼로 안소연 & 플루트 차민경 듀오 리사이틀', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384871';
UPDATE festival SET title = '제23회 서울 국제 무용 콩쿠르, 컨템포러리 & 안무 페스티벌', content = '', place = '나루아트센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '387067';
UPDATE festival SET title = '2026 찾아가는 공예 명작전', content = '<2026 찾아가는 공예명작전> 전시 소개<2026 찾아가는 공예명작전>은 우리 공예의 아름다움을 널리 알리기 위해, 전국 4개 권역 13곳의 문화공간으로 직접 찾아가는 특별한 순회전시입니다.공예 전문 큐레이터들의 시선으로 각 지역의 특성에 맞춰 새롭게 재조명한 한국 공예 명작들을 일상 속에서 즐겁게 경험해 보시기 바랍니다. 전시 기간2026.7.21.(화)~2026.8.18(화) 29일간 입장료: 무료', place = '국립익산박물관' WHERE provider_type = 'PUBLIC' AND external_id = '386949';
UPDATE festival SET title = '[대학로] 우석훈 코미디 단편선 ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '384811';
UPDATE festival SET title = '국토발전전시관 정기강연 ''이 땅 위에 우리 이야기''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '386153';
UPDATE festival SET title = '「2026 전통문화 전문인력 양성 콘텐츠 기획자·유통전문가 과정」 교육생 모집', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389991';
UPDATE festival SET title = '박경희 개인전 <기억의 레이어, 골목이 품은 푸른 숨의 방>', content = '', place = '복합문화예술공간MERGE' WHERE provider_type = 'PUBLIC' AND external_id = '388285';
UPDATE festival SET title = '창작음악극 <영산_도자기편경 이야기>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '388287';
UPDATE festival SET title = '[서천] 꿈의 오케스트라 ''서천'' 향상음악회 ', content = '', place = '기벌포복합문화센터 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '388007';
UPDATE festival SET title = '2026 여우락 페스티벌 - 김수인X리치맨과 그루브나이스 <장마>', content = '국립창극단 단원, 크로스오버 그룹 크레즐 멤버 김수인과 세계 블루스 대회 TOP5, 국제적 실력을 지닌 리치맨과 그루브나이스와의 폼나는 공연', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '384080';
UPDATE festival SET title = '제4회 연무 전통 페스티벌, 명인전 & 차세대예인전', content = '', place = '서울돈화문국악당' WHERE provider_type = 'PUBLIC' AND external_id = '386880';
UPDATE festival SET title = '아름다운 목요일 영 오디세이: 베토벤, Ⅱ. 윤해원 & 박원민 & 진영훈 Violin', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '386508';
UPDATE festival SET title = '2026 서울시향 수산나 멜키의 슈베르트 ''그레이트''', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384324';
UPDATE festival SET title = '[체코] 잠들고 싶지 않아!', content = '“오늘 밤은 제발 일찍 좀 자자!” 그냥 잠들기 아쉬운 아이들과 피곤에 지친 아빠의 유쾌한 한판승부!', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '383628';
UPDATE festival SET title = '미스앤줄리 (Miss&Julie)', content = '', place = '성균소극장' WHERE provider_type = 'PUBLIC' AND external_id = '387757';
UPDATE festival SET title = '국립극단 [공동기획] <갈매기>', content = '전 세계적으로 사랑받는 체호프의 대표작 <갈매기>,  국립극단은 충북도립극단을 초청하여, 새로운 감각이 돋보이는 무대를 선보인다.', place = '국립극단 명동예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '383501';
UPDATE festival SET title = '[연희예술극장 X 창작집단 여기에 있다] 연극 <등 좀 밀어줘>', content = '', place = '연희예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '385691';
UPDATE festival SET title = '2026 마포문화재단 가족ㆍ어린이 축제 [해피 마포 와글와글] 이머시브 뮤지컬 <고래밥 - 바다 대운동회>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '384985';
UPDATE festival SET title = '2026 부평문화포럼 ‘전환의 시대, 부평 문화정책의 새로운 과제’', content = '', place = '음악문화공간 지음' WHERE provider_type = 'PUBLIC' AND external_id = '389630';
UPDATE festival SET title = 'PAVILION', content = '<!-- wp:paragraph -->
<p>송하영 개인전<br>SONG HAYOUNG SOLO EXHIBITION</p>
<!-- /wp:paragraph -->

<!-- wp:columns -->
<div class="wp-block-columns"><!-- wp:column -->
<div class="wp-block-column"><!-- wp:paragraph -->
<p><strong>경계에서 파빌리온으로 (From Boundary To Pavilion)</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시장을 하나의 구조물로, 벽도 지붕도 결정되지 않은 채 정해진 기간 동안 존재하기 위해 세워지는 임시 구조물로 상상해본다. 일시적이지만 지금 이 순간의 밀도를 택한 건축물, 파빌리온. 이번 신작은 송하영 작가의 언급대로 "파빌리온이 가진 모듈성과 임시성, 층위, 그리고 안과 밖이 서로 이어지는 개방적인 구조에서 출발"한다. 작가는 회화 역시 그렇게 존재할 수 있다고 말하는 듯하다. 작가는 전시가 열리는 동안 정해진 결론으로 굳어지기보다, 관람자의 감각과 사유가 평소와는 다른 방식으로 움직이는 자리가 되기를 바라는 마음이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그 개방적인 구조를 이루는 것은 그가 지속적으로 탐구하고 있는 화두, ''경계(boundary)''다. 작가는 기차의 역방향 좌석에 앉아 이미 지나온 풍경을 마주하는 것처럼 이 ''경계''를 특별한 장소가 아닌 대개 이동 중에 포착한다. 시차를 두고 응시한 풍경은 방향과 속도에 따라 다르게 느껴진다. 건물의 외벽, 유리창의 반사, 공사장의 임시 구조물, 오래된 표면에 남은 시간의 흔적들이 그렇게 스쳐 지나가며 눈에 들어온다. 그에게 이런 순간들은 고정된 풍경이라기보다, 시간과 방향, 표면과 흔적, 빛과 반사가 겹쳐지는 상태에 가깝다. 그가 도시에서 포착하는 것은 특정한 장소나 장면이라기보다, 그 안에서 감각이 나타났다 사라지고 다시 흔적으로 남는 과정 그 자체다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이렇게 포착되는 경계는 다양한 표정을 담고 있다. 도로의 선, 구조물의 모서리처럼 뚜렷하게 나뉘는 지점이 있는가 하면, 빛과 그림자처럼 서서히 겹쳐지는 자리, 색이 조금씩 다른 색으로 변화하는 순간처럼 나뉨과 만남이 동시에 일어나는 지점도 있다. 전자가 도시의 인공적이고 질서 있는 경계라면, 후자는 자연이 가진 유동적이고 감각적인 경계다. 화면 위에서 이 경계는 각기 다른 방식으로 번역된다. 뚜렷한 경계는 선으로, 스며드는 경계는 면과 면이 밀고 당기며 교차하고, 그 위에 빛이 잠깐 맺히거나 시선이 멈추는 곳에는 점이 놓인다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>결국 경계란 무언가를 나누는 선이기에 앞서, 서로 다른 것들이 마주하며 관계를 맺는 접점이라는 것이 그의 작업을 이끌어온 핵심이다. 나뉘어 있지 않았다면 애초에 마주칠 일도 없었을 것이다. 분리는 관계의 결핍이 아니라, 관계가 성립하기 위한 전제다. 그가 화면에 옮기는 것은 눈 앞의 풍경 그 자체라기보다, 그 풍경 속에 있으면서도 좀처럼 드러나지 않는 속도와 거리감, 온도와 감정의 층위에 가깝다. 작가는 눈에 보이는 장면을 그대로 옮기는 대신, 그 안에 숨은 비가시적 감각과 지각의 영역을 색면과 구조라는 언어로 번역한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이 화두는 십여 년에 걸쳐 여러 작업을 통해 드러났다. 2010년대 초반, 작가는 원형 액자나 목재 가구 위에 인물과 사물의 이미지를 그려 넣는 방식으로 작업을 시작했다. 《Hot Place》(2013)의 원형 프레임, 《Time to leave》(2014)의 벤치와 테이블 위에 놓인 서사적인 장면들에는 아직 개념보다 이야기와 오브제를 향한 관심이 짙게 남아 있었다. 이야기를 덜어내는 과정에서 작가가 다음으로 주목한 것은 오브제 위의 서사가 아니라, 그 서사를 담아내던 틀 자체였다. 2017년 무렵부터 화면은 급격히 절제되고, 팔레트는 청색과 무채색으로 좁혀진다. 《Boundary》(2017)의 다이아몬드 캔버스, 부유하는 사각형이 놓인 화면은 캔버스의 형태 자체를 경계의 문제로 다루기 시작했음을 보여준다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>평면 회화를 오래 다루면서, 작가에게는 자연스럽게 ‘회화의 표면이 어디까지 확장될 수 있는가’라는 질문이 따라붙었다. 경계를 고정된 선이 아니라 유동하는 관계로 본다면, 회화의 표면 역시 2차원에 갇히지 않고 주변 공간과 함께 움직일 수 있다는 데 생각이 닿았다. 이 발상은 2020년 회화를 캔버스 밖으로 밀어낸다. 《틈(사이에서 빛나고 있던 것들)》(2020)의 네온 조명, 《Beyond the times》(2020)에서는 단색 패널과 타일 조각이 공간에 기대어 선다. 빛과 반사, 움직임, 그 앞을 지나는 관람자의 위치 같은 조건들이 작품 안으로 밀려들면서, 회화는 매번 다르게 반응하는 구조로 변모하였다. 보는 각도와 자세, 몸의 위치가 바뀔 때마다 인상이 달라진다는 것, 그리고 그 변화 자체를 작업의 일부로 끌어안으려는 생각이 이 시기를 관통한다. 회화가 품을 수 있는 폭을 다시 가늠해보려는 시도에 가까웠다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 2022년 이후 작은 단위들이 모여 하나의 전체를 이루는 모듈 형식을 탐구하며 채도 높은 색상을 선택한다. 《수축과 팽창》(2022)처럼 벽을 따라 리본처럼 이어지는가 하면 《Reassemblage》(2023)의 기하학적 조각들이 그리드로 반복된다. 그리드 위에 반복되던 조각들이 만들어내는 빛의 잔상과 움직임은, 작가의 관심을 구조 자체에서 그 구조가 만들어내는 빛의 현상으로 옮겨놓는다. 2024년에는 빛이 은유를 벗고 직접적인 형태로 그려진다. 《Flare & Highlight》(2024)의 수렴하는 흰 삼각형, 모터로 실제 움직이는 캔버스를 구현한 최근작 《Sequence: Overlay》(2025)까지 다양한 매체와 구성을 통해 회화의 표면이 어디까지 확장될 수 있는지를 실험하였다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이 모든 확장의 이면에는 오히려 절제를 향한 태도가 자리한다. 건축과 음악, 도시의 장면들, 동시대의 속도감 같은 이질적인 장면들이 작업 곳곳에 혼재되어 있지만, 그 장면들이 화면 위에 그대로 드러나지는 않는다. 작업은 단순하고 절제된 색면추상의 형태로 남는다. 작업의 실행에 앞서 개념과 구조를 먼저 세우려는 작가의 태도가 이 과정을 이끈다. 체화된 여러 겹의 감각이 소수의 색과 면, 구조로 압축될 때 그것이 보는 이에게 어떻게 전달될지, 이 물음이 그가 화면 앞에서 가장 오래 머무는 지점이다. 레이어를 쌓는 시간 역시 그 절제를 몸으로 익히는 수행에 가깝다. 색이 정해지고 붓이 움직이기 시작하면, 반복되는 행위 속에서 잡념 없이 화면에 머무르게 된다. 고른 리듬으로 붓질을 이어가는 동안, 화면 안에는 색의 깊이와 밀도, 그리고 지향했던 결이 서서히 쌓여간다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 이 모든 실험 이후, 벽 앞에 선 관람자와 마주하는 회화의 가장 오래된 조건으로의 복귀다. 이 회귀는 그동안 쌓아온 질문들을 가장 정제된 형식으로 드러낸다. 신작에서 색은 눈에 띄게 줄었다. 노랑 계열의 작업은 열림과 통과의 감각에 가깝다. 빛과 신호, 환기를 동시에 품은 노랑은 조합과 배치에 따라 온도와 밀도를 달리한다. 주황 계열에서는 그 감각이 한층 압축되고 물성을 띤 상태로 나타난다. 따뜻하면서도 강한 밀도로 화면 안의 긴장과 구조를 더 선명하게 드러낸다. 이 색들은 일상에서 마주하는 감각, 도시의 표면, 흔들리는 경계, 그리고 동시대의 리듬에서 길어 올린 것들이다. 색을 정하는 데 일정한 규칙은 없다. 다만 그 색이 다른 색 옆에 놓였을 때 어떤 온도와 밀도, 긴장이 생기는지 화면 안에서 끝없이 되짚어보는 시간이 있을 뿐이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그 과정은 결국 경계를 하나의 결론으로 규정하지 않고 끊임없이 새로 확장해가려는 태도와 다르지 않다. 여기에 펄과 실버가 섞인 면들이 더해지면서, 정면에서는 하나의 색처럼 보이던 것이 위치를 조금만 옮기면 다른 온도로 다가온다. 여러 겹의 캔버스가 쌓여 만드는 물리적 단차 역시 같은 논리다. 층은 물리적 두께라기보다 색과 구조가 겹겹이 축적되는 방식인 동시에, 회화가 공간 쪽으로 뻗어나가는 또 다른 조건이다. 전시장의 구성 역시 이전보다 절제되어 있다. 알루미늄 프로파일이나 모터 같은 장치로 작품을 벽에서 떼어내고 공간을 적극적으로 끌어들였던 이전 전시들과 달리, 이번에는 캔버스가 벽에 걸리고 관람자가 정면에 서는 회화의 가장 전통적인 방식을 택했다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그러나 이 단순함은 비어 있지 않다. 제한된 색과 요소 안에서 색면과 선이 만드는 균형과 긴장은 오히려 더 예민하게 조율되어 있다. 작업은 가까이서, 옆에서 그리고 다시 멀리서 볼 것을 제안한다. 다가서면 색면과 색면이 만나는 단차, 표면에 밴 밀도, 빛의 방향에 따라 뒤바뀌는 색의 인상이 눈에 들어온다. 물러서면 그 개별적인 감각들이 하나의 구조와 리듬으로 통합되는 순간이 온다. 화면은 어느 한 시점에서 완결되지 않고 관람자의 위치와 움직임에 따라 계속 변화한다. 전시가 끝나면 이 임시 구조물은 흔적 없이 해체된다. 다만 한동안 색과 면 사이에서 열려 있던 감각은, 저마다의 방식으로 지속될 것이다.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column --></div>
<!-- /wp:columns -->', place = '호리아트스페이스' WHERE provider_type = 'PUBLIC' AND external_id = '390417';
UPDATE festival SET title = '세계명화 레플리카전 <불멸의 화가 빈센트 반 고흐>', content = '', place = '포천반월아트홀 전시장' WHERE provider_type = 'PUBLIC' AND external_id = '387523';
UPDATE festival SET title = '국토발전전시관 여름방학 행사 ''ROOM7 : 건축가의 방''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '388804';
UPDATE festival SET title = '2026 여우락 페스티벌 - 유태평양 <네, 다음 곡은요>', content = '유태평양쇼!유태평양의 전통적인 모습부터 펑키한 모습까지 장르를 초월하는 유태평양의 다양한 모습을 볼 수 있는 독보적인 쇼', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '384081';
UPDATE festival SET title = '영등포아트홀 기획공연, 죠지 & 김뜻돌', content = '', place = '영등포아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '386607';
UPDATE festival SET title = '[용인] 해외 우수작 초청 어린이 인형극 <Dragon> ', content = '', place = '경기국악원' WHERE provider_type = 'PUBLIC' AND external_id = '389826';
UPDATE festival SET title = '2026 Doam Summer Kids Art Camp <미술사로 여름 바캉스>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '385430';
UPDATE festival SET title = '[노원구 5개 기관 연합] 2026여름방학 SAM& 스탬프 에듀투어', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '388935';
UPDATE festival SET title = '제11회 한강·낙동강 발원지 축제', content = '', place = '황지연못 일원' WHERE provider_type = 'PUBLIC' AND external_id = '388107';
UPDATE festival SET title = '김포 어린이 아트스테이지 <일장일딴컬렉션>', content = '', place = '통진두레문화센터 두레홀' WHERE provider_type = 'PUBLIC' AND external_id = '387912';
UPDATE festival SET title = '정혜성·김정호 《In-Between》', content = '', place = '온에어갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '390379';
UPDATE festival SET title = '[의정부] 레빛투더문 버블 & 매직쇼', content = '', place = '우리소극장 [의정부]' WHERE provider_type = 'PUBLIC' AND external_id = '387785';
UPDATE festival SET title = '7월 교육 <예술가처럼 작업하기: PIET MONDRIAN>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '387272';
UPDATE festival SET title = '국립오페라단 - 잔니 스키키', content = '국립오페라단이 엄선한 정상급 성악가들이 선사하는 푸치니의 유일한 희극오페라 ''잔니 스키키''', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '384468';
UPDATE festival SET title = '동행(同行): 차이콥스키 5번 & 한중 합동 연주회', content = '', place = '부천아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '388161';
UPDATE festival SET title = '[전주] 고영열의 피아노병창:춘향  <불과 눈물>', content = '', place = '전주한벽문화관 한벽공연장' WHERE provider_type = 'PUBLIC' AND external_id = '386887';
UPDATE festival SET title = '이금희와 함께하는 오후 2시 <다정한 클래식> 7월-모두의 클래식', content = '', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '383458';
UPDATE festival SET title = '[꿈의숲아트센터] 2026 여름방학 시즌공연 <최태지의 발레 보물상자>', content = '', place = '꿈의숲아트센터 퍼포먼스홀' WHERE provider_type = 'PUBLIC' AND external_id = '381739';
UPDATE festival SET title = '[원주 갤러리 원] 아라 회화전 "별밤사계"', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '390467';
UPDATE festival SET title = '그린피그 <진노 震怒>', content = '', place = '예술공간 혜화' WHERE provider_type = 'PUBLIC' AND external_id = '387279';
UPDATE festival SET title = '오연경 가야금 독주회 <승화시 勝花時 Ⅲ>', content = '', place = '정약용도서관' WHERE provider_type = 'PUBLIC' AND external_id = '386982';
UPDATE festival SET title = '[부산] 더하우스콘서트 줄라이페스티벌 비바아첼 공동 주관 기획공연, 첼리스트 김대준 리사이틀', content = '', place = '비바아첼 Chamber Hall & Academy' WHERE provider_type = 'PUBLIC' AND external_id = '386022';
UPDATE festival SET title = '[인천] 선데이콘서트, 신정아 & 홍은영 피아노 듀오 리사이틀', content = '', place = '엘림아트센터 엘림홀' WHERE provider_type = 'PUBLIC' AND external_id = '387148';
UPDATE festival SET title = '[안산] 춤추는 발레 FESTA: 백조의호수 & 호두까기인형 ', content = '', place = '안산문화예술의전당 해돋이극장' WHERE provider_type = 'PUBLIC' AND external_id = '386595';
UPDATE festival SET title = '제23회 평창대관령음악제 찾아가는음악회 #6 엔리코 파체 & 평창페스티벌스트링즈', content = '', place = '동해문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '386018';
UPDATE festival SET title = '고창문화의전당 하우스콘서트, July Festival in 고창 2. 프랑스의 빛 (Lumières de France) (07.28)', content = '', place = '고창문화의전당 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '389736';
UPDATE festival SET title = '이해니 <EGG.jpg> & 김원영 <교차> - 크리틱스초이스댄스페스티벌 2026', content = '<에그.jpg>생명이 시작되는 곳이자, 아직 아무것도 아닌 상태<교차>“우리의 시계는 단 한 번이라도 똑같이 흐른 적이 있을까?”', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '383631';
UPDATE festival SET title = '다담', content = '2월부터 11월까지 매월 마지막 주 수요일 오전 11시에는 국악과 차, 그리고 이야기가 함께하는 <다담>이 열립니다.다담지기 황수경 아나운서의 진행으로 예술같은 삶을 살고 있는사회 각 분야의 저명 인사를 초청해 이야기와 우리 음악을 나누는토크 콘서트 입니다.진솔한 삶의 이야기에 더해지는 우리 음악 한 잔!오전의 설레이는 햇살 같은 특별한 시간을 느껴보세요.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '384317';
UPDATE festival SET title = '제43회 정재영 명인의 초적소리 & 김화선 명창의 가야금소리45', content = '', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '388830';
UPDATE festival SET title = '연극 <사이버펑크 미술관>', content = '', place = '반석아트홀(동탄복합문화센터)' WHERE provider_type = 'PUBLIC' AND external_id = '388490';
UPDATE festival SET title = '2026 강릉시립미술관 솔올 <뮤지엄 아카데미> 20세기 유명 미술가 이야기', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '388279';
UPDATE festival SET title = '2026 소나기마을 수숫단문화마당 ''차인표 작가 문학교실''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389353';
UPDATE festival SET title = '2026 국제수면치유박람회 (Sleep & Wellness Festa)', content = '', place = '코엑스 1층 B홀 전관' WHERE provider_type = 'PUBLIC' AND external_id = '389396';
UPDATE festival SET title = 'π(파이)의 변주: 강강술래', content = '', place = '한국문화의집 KOUS' WHERE provider_type = 'PUBLIC' AND external_id = '389830';
UPDATE festival SET title = 'MMCA×LG OLED 시리즈 2026', content = '<p style="line-height: 1.8;"><span style="font-size: 12pt;">국립현대미술관과 LG전자의 중장기 협력 프로그램인 «MMCA x LG OLED 시리즈»는 역량 있는 동시대 작가에게 작품 제작비 및 기술 인프라를 지원함으로써 동시대 현대미술의 새로운 매체 실험 및 담론을 형성하고, 기술과 예술을 바탕으로 한 대형 신작 제작을 통해 현대미술의 대중화에 기여하고자 한다. 서울관의 상징적 전시공간 서울박스(Seoul Box)의 공간적 특성을 반영한 설치작품을 전시하여 현대미술의 독창적 예술 경험을 관객에게 제공한다. 시리즈의 두 번째 작가는 2026년 초 발표된다.</span></p>', place = '국립현대미술관 서울관' WHERE provider_type = 'PUBLIC' AND external_id = '364982';
UPDATE festival SET title = '(7.31) 피아니스트 고예린 & 김경진 듀오 리사이틀', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '386425';
UPDATE festival SET title = '시크릿콘서트 <스트라빈스키와 위스키-발트앙상블>', content = '', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '387974';
UPDATE festival SET title = '[양평] 사물놀이 느닷 <양평아리랑> 쇼케이스 ', content = '', place = '양평문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '388811';
UPDATE festival SET title = '[평택] 비가 톡! 바람이 쓩! <Grand Soft Day>', content = '', place = '평택시북부문예회관' WHERE provider_type = 'PUBLIC' AND external_id = '387347';
UPDATE festival SET title = '[과천] 2026 재즈로 푸른 밤 <Jazz＆Dance> Vol.2 - New Orleans', content = '', place = '과천시민회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '387160';
UPDATE festival SET title = '[서울영화센터] <스크린 뒤, 영화 이야기: 배우 엄정화 x 제작자 김윤미 무비 토크>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '387913';
UPDATE festival SET title = '제7회 실험극 페스티벌, 연극 <CODE: 404> ', content = '', place = '골목실험극장' WHERE provider_type = 'PUBLIC' AND external_id = '364543';
UPDATE festival SET title = '[대구] 베토벤 & 라흐마니노프 ', content = '', place = '대구콘서트하우스 그랜드홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '363190';
UPDATE festival SET title = '[대구] 대구시립교향악단, 말러 교향곡 제1번 ''거인'' ', content = '', place = '대구문화예술회관 팔공홀' WHERE provider_type = 'PUBLIC' AND external_id = '363615';
UPDATE festival SET title = '삼청공원 숲속도서관 온라인 필사동아리 6기 <오늘의 시선곡>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394083';
UPDATE festival SET title = '연희놀이극 <한글먹고 얌얌> 한국문화예술위원회 ''2026년 어린이청소년을위한예술지원'' 선정작', content = '', place = '안성맞춤아트홀 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '389159';
UPDATE festival SET title = '[서울 강남] 고래의 아이 ', content = '', place = 'KT&G 상상마당 대치아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '387753';
UPDATE festival SET title = '[강북문화재단] 우리 아기의 첫 오페라 <오르페오의 포근>', content = '', place = '강북문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '386406';
UPDATE festival SET title = ' Typography Oblique – 활자의 여름 展', content = '', place = '복합문화예술공간MERGE' WHERE provider_type = 'PUBLIC' AND external_id = '389155';
UPDATE festival SET title = '2026 남양주문화재단 서머페스티벌(무용) <발레 갈라 – 그랑 파드되>', content = '', place = '다산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '385724';
UPDATE festival SET title = 'KT&G 장학재단과 함께하는 BALLET SHOWING', content = '', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '389255';
UPDATE festival SET title = '루아 (RUA) 개인전 <일방통행적 구애>', content = '', place = '비커밍갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '389431';
UPDATE festival SET title = ' [서울영화센터] <스크린 속 미술 이야기> 수강생 모집!', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '391613';
UPDATE festival SET title = '연극 <사라세니아>', content = '', place = '나인진홀 1관 (1층)' WHERE provider_type = 'PUBLIC' AND external_id = '392317';
UPDATE festival SET title = '2026 충북콘텐츠코리아랩 10주년 기념 CON×10(콘텐) 콜로키움', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389978';
UPDATE festival SET title = '어린이 여름방학 워크숍 <나의 첫 번째 사진책>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389961';
UPDATE festival SET title = '[파주] 이지훈과 함께 하는 음악 여행, 영국 & 오스트리아 ', content = '', place = '솔가람아트홀 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '387996';
UPDATE festival SET title = '[안산] 이미지극 쇼케이스 <the Atomic War> A cloud is best measured when it up', content = '', place = '안산문화예술의전당 별무리극장' WHERE provider_type = 'PUBLIC' AND external_id = '390824';
UPDATE festival SET title = '[원주 갤러리 원] 장혜선 개인전 "월하연희" ', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '392288';
UPDATE festival SET title = '서울시립교향악단 <2026 작은음악회>', content = '', place = '동대문구 아르코(DDM ARCO)' WHERE provider_type = 'PUBLIC' AND external_id = '389499';
UPDATE festival SET title = '제26회 대전국제음악제, 파가니니 & 세헤라자데', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '387955';
UPDATE festival SET title = '국립심포니오케스트라 <파야, 삼각모자 모음곡>', content = '뜨거운 여름, 스페인 레퍼토리 특유의 열정적 색채와 리듬의 공연', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382409';
UPDATE festival SET title = '세계합창심포지엄 초청기념 특별기획공연 안산, 즐거움을 노래하다Ⅸ ‘We are the Ansan’', content = '', place = '안산문화예술의전당 해돋이극장' WHERE provider_type = 'PUBLIC' AND external_id = '390951';
UPDATE festival SET title = '[대학로] 고스트 스트리머 ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '389758';
UPDATE festival SET title = '[인천] 명랑 동화 뮤지컬, 삼양동화: 헨젤과 새엄마 & 거울을 깬 왕비 ', content = '', place = '인천아트플랫폼' WHERE provider_type = 'PUBLIC' AND external_id = '388838';
UPDATE festival SET title = '[안산] 리얼공룡쇼 <다이노>', content = '', place = '안산문화예술의전당 달맞이극장' WHERE provider_type = 'PUBLIC' AND external_id = '388229';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 <오페라 산책>', content = '', place = '국립극장 무대예술지원센터' WHERE provider_type = 'PUBLIC' AND external_id = '390391';
UPDATE festival SET title = '수원시립공연단 기획공연 무예 뮤지컬 <1790> ', content = '', place = '정조테마공연장' WHERE provider_type = 'PUBLIC' AND external_id = '388910';
UPDATE festival SET title = '[서울시립과학관] 2026 영메이커 LAB : 생존미션 ‘스페이스 서바이벌’', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389395';
UPDATE festival SET title = '대전광역시 서예진흥원 <충남의대 서예전>', content = '', place = '대전광역시 서예진흥원' WHERE provider_type = 'PUBLIC' AND external_id = '390404';
UPDATE festival SET title = '진채연구소 기획전 <별쭈부전 & 콩쥐도 팥쥐도>', content = '', place = '한벽원미술관' WHERE provider_type = 'PUBLIC' AND external_id = '392876';
UPDATE festival SET title = '2026 남양주문화재단 서머페스티벌(창작가무) <청사초롱 불 밝혀라>', content = '', place = '다산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '385725';
UPDATE festival SET title = '[부산] 프로젝트 X 오케스트라, Project: Organ & Rachmaninoff ', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '388820';
UPDATE festival SET title = '信 Young Artist, 작곡가 박이은 & 앙상블 위로', content = '', place = '신영체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '391199';
UPDATE festival SET title = '이든 콰르텟 리사이틀 ''Radiance''', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '387471';
UPDATE festival SET title = '2026 사유의 기억들 <이재동,조경희,경금자,박경숙,정귀수,정재섭,정시권> ', content = '', place = '애니메이션박물관' WHERE provider_type = 'PUBLIC' AND external_id = '394096';
UPDATE festival SET title = '춘천공연예술제, MISFIT 프로젝트 & 이창민 & 모므로살롱', content = '', place = '축제극장 몸짓' WHERE provider_type = 'PUBLIC' AND external_id = '389570';
UPDATE festival SET title = '푸르지오아트홀 수요초대석 39, 김유정의 오페라 <봄봄>', content = '', place = '푸르지오아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390561';
UPDATE festival SET title = '2026 서울시향 유럽 투어 프리뷰 콘서트: 베토벤 ‘합창’', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384360';
UPDATE festival SET title = 'Heritage Series; The Fellowship 피아니스트 신수정 & 김송현', content = '', place = '신영체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '389842';
UPDATE festival SET title = '[대학로] 27년 ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '390758';
UPDATE festival SET title = '2026 길 위의 인문학 <종로, 골목의 시(詩)인들>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394091';
UPDATE festival SET title = '국립심포니콘서트오케스트라 영유아 음악회 <킨더콘서트> : KNCO 금관 앙상블', content = '영유아와 가족이 함께 경험할 수 있는, 처음 만나는 클래식.국립심포니콘서트오케스트라 금관 앙상블이 들려주는 연주의 매력을 영유아와 가족이 함께 경험할 수 있는 공연.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '383084';
UPDATE festival SET title = '아름다운 목요일 영 오디세이: 모차르트, Ⅱ. 남예서 & 이정우 Piano', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '389222';
UPDATE festival SET title = '(8.13) 이신규 비올라 독주회 "ANALEMMA : Variations of Time"', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '386976';
UPDATE festival SET title = '김희정 & 선소진 피아노 듀오 리사이틀', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '391005';
UPDATE festival SET title = '2026 어린이 가족 페스티벌 <빨간모자와 늑대>', content = '동화처럼 친숙한 이야기와 음악으로 아이의 첫 오페라를 열어주는 무대', place = '예술의전당 [서울] 자유소극장' WHERE provider_type = 'PUBLIC' AND external_id = '384364';
UPDATE festival SET title = '[화성] 화성시 예술단 <화음 Ⅲ : 화성의 음악, 화성을 연주하다>', content = '', place = '반석아트홀(동탄복합문화센터)' WHERE provider_type = 'PUBLIC' AND external_id = '390513';
UPDATE festival SET title = '최세린 피아노 독주회 "Strum und Drang"', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '389156';
UPDATE festival SET title = '국립합창단 광복절 기념음악회 <눈물상자>', content = '노벨문학상 수상 작가 한강의 동명 작품을 원작으로, ‘어른들을 위한 동화’의 정서 속에서 인간의 슬픔과 치유, 희망의 메시지를 담아낸 창작 합창음악극', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384346';
UPDATE festival SET title = '부천필하모닉오케스트라, 바그너 <니벨룽의 반지> 하이라이트', content = '', place = '부천아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '389011';
UPDATE festival SET title = '[성남] 성남아트센터 키즈 페스티벌, 패브릭오브제 가족극 <코 잃은 코끼리 코바> ', content = '', place = '성남아트센터 앙상블씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '389032';
UPDATE festival SET title = '극단 명작옥수수밭  <세기의 사나이>', content = '제4회 서울예술상 스팍 포커스상 연극 부문 수상, 3.1 운동에서 한국전쟁까지 125년의 역사가 된 한 남자의 이야기', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '384321';
UPDATE festival SET title = '[화성] 매직스크린 가족극 <오버코트> ', content = '', place = '모두누림센터' WHERE provider_type = 'PUBLIC' AND external_id = '389190';
UPDATE festival SET title = '2026 제6회 <S Classic Week> 3rd ''모두의 조화''', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '390745';
UPDATE festival SET title = '[용인] 다움 & 김상범 듀오 콘서트: 리멤버 재즈 Vol.4 ', content = '', place = '글로리어겐 스튜디오 마이너스윙 스튜디오 (구. 본회퍼홀)' WHERE provider_type = 'PUBLIC' AND external_id = '389173';
UPDATE festival SET title = '제25회 전주세계소리축제, 한국 X 폴란드: 쇼팽 & 아리랑', content = '', place = '한국소리문화의전당 명인홀' WHERE provider_type = 'PUBLIC' AND external_id = '389182';
UPDATE festival SET title = 'The Father''s Way', content = '', place = '가빈아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390823';
UPDATE festival SET title = '2026 학산어린이극 <여름엔 학산소극장> 공연 안내', content = '', place = '학산소극장' WHERE provider_type = 'PUBLIC' AND external_id = '383623';
UPDATE festival SET title = '2026 청소년 음악회 “스쿨 클래식”', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '386818';
UPDATE festival SET title = '2026 희망 Dream NEXT Concert ''STAGE''', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '391002';
UPDATE festival SET title = '그림그리는 영심 개인전 <찰나의 연(緣), 영원의 빛>', content = '', place = '비커밍갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '391523';
UPDATE festival SET title = '[행정안전부] 2026 을지연습 <함께해요 을지연습! 든든한 대한민국!>', content = '', place = '전국' WHERE provider_type = 'PUBLIC' AND external_id = '392811';
UPDATE festival SET title = '재오 소프라노 유소영 & KTPO 함께하는 음악여행', content = '', place = '세라믹팔레스홀' WHERE provider_type = 'PUBLIC' AND external_id = '392353';
UPDATE festival SET title = '2026 예술의전당 국제음악제 - 이승원 & 케빈 첸 with SAC 페스티벌 오케스트라', content = '쇼팽콩쿠르 이후 활발하게 활동하는 피아니스트 케빈 첸과 지휘자 이승원이 이끄는 SAC 페스티벌 오케스트라가 라벨의 눈부신 색채와 에너지를 선사하는 화려한 무대', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384246';
UPDATE festival SET title = '2026 예술의전당 국제음악제 - 케빈 첸 피아노 리사이틀', content = '"쇼팽 콩쿠르 이후 세계가 주목하는 케빈 첸의 국내 첫 리사이틀" 리스트의 음악 세계를 집중 조명하는 공연', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384249';
UPDATE festival SET title = '영도문화예술회관 Re:Star 시리즈 영상으로 만나는 발레 <안중근, 천국에서의 춤> (영상화)', content = '', place = '영도문화예술회관 소공연장(절영홀)' WHERE provider_type = 'PUBLIC' AND external_id = '390257';
UPDATE festival SET title = '김영헌: 프록시마', content = '<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":19733,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/07/1_리사이징_홍보-포스터_김영헌_프록시마_갤러리JJ.jpg" alt="" class="wp-image-19733" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>생경한 그리움</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리JJ는 김영헌Kim Young-Hun 작가의 전시를 개최한다. 독특한 잔물결 패턴과 색채로 잘 알려진 그의 회화 작업은 동시대 과학문명의 패러다임 전환 속에서 흔들리는 우리의 감각과 세계 인식을 매개로 새로운 회화의 지평을 열어 보인다. 그것은 비가시적인 전자 파동wave이 진동하는 에너지 세계의 현전인 동시에 메타적 시공간의 기억과 그리움을 향한 시적 은유로 나타난다. 이번 전시 《김영헌: 프록시마》는 더욱 확장된 회화 언어를 보여주는 <프리퀀시Frequency>시리즈와 2009년부터 시작된 대표적인 시리즈 <일렉트로닉 노스탤지어Electronic Nostalgia>의 신작을 포함한 20여 점으로 구성된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>물감의 층위, 얼룩과 스크래치, 진동하는 선과 면의 생성과 사라짐은 화면에서 연속과 불연속을 오가며 공명하는 아름다운 변주를 만들어낸다. 리듬을 타고 화면을 가로지르는 획들은 역동성의 한편에 신체의 떨림과 움직임을 섬세하게 전하고, 오래된 듯 벗겨진 색면의 틈새로 드러나는 다른 색의 층위와 함께 시간의 흔적을 담아 노스탤지어적 감성을 불러일으킨다. 상반된 요소들이 만들어내는 대립과 조화는 작업 특징 가운데 하나로, 디지털의 화려한 인공적 색감, 선들의 질서와 노이즈가 빚어내는 혼돈이 교차하는 회화 세계는 오히려 조화롭게 아름다우며 시선을 끈다. 그것은 때로 가상 풍경Virtual-scape 혹은 음악적 추상처럼 보인다.<br>가상공간에서의 기억과 함께 시작된 ‘일렉트로닉 노스탤지어’ 시리즈는 전자 노이즈로 인한 형상의 파편과 해체에 이어 유토피아적 풍경, 기하적인 픽셀과 파동의 세계로 더욱 추상화되며 지금까지 이어져 오고 있다. ‘노이즈’ 요소보다 회화의 물질 언어에 더 집중한 ‘프리퀀시’ 시리즈는 흐름의 일관된 방향성과 질서를 부여하고, 묵직한 물감의 두께 즉 물질의 강도로 리듬을 만들어낸다. 좀 더 달라진 신작을 발표하는 이번 전시는 김영헌 작업의 중심에 있는 두 시리즈의 흐름과 현재의 변화를 살피면서 작업세계의 독자성을 조명하고, 이러한 전자적 미시세계를 우주로 확장시켜 본다. 하나로 결국 연결되는 미시세계와 거대한 세계는 우리의 인식 바깥에 있으며, 경험한 적 없는 시공간으로 우리를 데려간다. 전시 제목인 ‘프록시마’는 우리가 사는 태양계에서 가장 가까운 별의 이름이다. 그것은 지구의 가장 가까운 이웃별이지만 실제로는 결코 갈 수도 닿을 수 없는 아득히 먼 곳으로, 별은 우리에게 무한한 상상력과 함께 광활한 우주 공간을 떠올리게 한다. 별빛은 이미 지나간 시간으로부터 우리에게 오고, 우리는 오래된 과거의 별을 보고 있다. 별 헤는 밤의 그리움과 파동으로 가득한 과학적 우주가 교차한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Ⅰ. <br>눈으로 볼 수 없는 파동 혹은 주파수Frequency로 이루어진 비물질적인 전자 세계는 김영헌의 작업세계에서 회화의 물질 언어로 치환된다. 그것은 자신이 감각하고 인식한, 전자로 만들어진 디지털 이미지나 가상 세계의 풍경이 될 수도 있고, 혹은 우리의 일상을 감싸는 빛과 음악 소리의 시각화, 나아가 우주 만물을 구성하는 에너지와 과학적 실재계 같은 비가시적 세계를 감각의 영역으로 끌어내는 작업으로 설명될 수 있다. 전자electronic는 세계를 구성하는 기본 요소로, 이들의 파동 패턴은 작가와 세계를 연결하는 매개체이다. 곧 그의 작업은 파동으로 가득한 우주의 역동적인 에너지에 다름 아니다.<br>무엇보다 작가에게 중요한 것은 ‘그림은 모험’이라는 자각이다. 그는 붓, 물감, 캔버스, 나이프 등 작업 재료 자체가 그 본성에 충실하도록 철저한 탐구로 새로운 회화적 언어를 실험하고 창출한다. 회화 속 반복적인 줄무늬 요소는 전자적 느낌의 추상 언어를 발생시킨다. 이 줄무늬 파동은 여러 색채가 단 한 번의 붓질로 미끄러지듯 연속하여 생성되는 획들로서, 매끄러운 리듬감과 획 특유의 자유로움으로 인해 드로잉이 갖는 명랑한 즐거움을 획득한다. 이러한 파동 패턴은 노이즈 및 서로 상반되는 색채의 충돌과 절단으로 인해 구축과 동시에 해체되는 형태들로 작동하면서 역동성 있는 에너지 장으로서의 회화적 현실을 구축한다. 그것은 디지털적 신호인 0과 1 사이에 보이지 않는 미지의 세계의 무한함에 대한 탐구에서부터 현실과 가상이 중첩되는 세상, 그리고 파동의 간섭과 생성의 세계로 수렴한다. 화면 속 리듬은 끊임없이 변화하는 세계의 움직임과 생명력을 환기하며, 얼룩이나 색면처럼 다양하게 나타나는 노이즈는 세계의 불연속을 야기한다. 작가의 아날로그를 향한 그리움은 어느새 현대물리학이 밝혀낸 양자역학의 세계를 관통하면서 곧 견고한 것이 아닌, 입자이면서 파동으로 이루어진 우주와 세계의 본질에 대한 사유 역시 가능하게 한다. 디지털 플랫폼으로 인해 더욱 가속화되는 현대사회의 흐르고 사라지는 유동성, 정박하지 못하고 부유하는 동시대인의 정체성처럼 작업 역시 흔들리며 이동하고 왜곡되는 어느 지점에서 진동한다. 그의 회화 작업은 오늘날 달라진 디지털의 환영 속 파편화된 감각을 지극히 아날로그적 매체인 회화 평면 위로 끌어와 현 세대에게 스며든 새로운 감각으로 일깨워 준다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그렇다면 김영헌에게 왜 ‘전자’ 세계인가? 현재 그의 회화 작업의 개념적 저변을 이루는 동시대 미디어 기술, 아날로그와 디지털의 전자 세계, 기술 문명에 관한 깊은 사유에는 다분히 그의 누적된 경험들이 탄탄하게 받쳐주고 있다. 작가에게 디지털 미디어는 꽤 오랫동안 친숙하게 다루어온 매체로서 일찍이 전자 테크놀로지의 빠른 변화와 그에 따른 인간 지각 방식의 변화를 인지하고 있었다. 그는 1995년 중앙미술대전에서 미디어설치 작업 <현기증처럼 찾아온 단잠>(1995)으로 대상을 수상하여 미술계의 기대를 모았다. 이후 유럽으로 건너가 2009년 귀국하기 전까지 10여 년간 주로 인간 삶의 실존적 양태 등을 주제로 한 특유의 설치 및 영상작품으로 프랑스, 영국 등지에서도 주목을 받았다. 당시 몇 년간의 영상 촬영 기자 경험 또한 미디어의 실과 허를 목격하고 깨닫게 해주었다. 귀국 후 성곡미술관에서 열린 전시 《일렉트로닉 노스탤지어: 깨어진 꿈》(2010)은 디지털 기술을 이용한 설치영상 작업과 함께 2008년 이후 제작한 독특한 형식과 내용의 회화 작업을 발표하며, 빠르게 닥쳐오는 테크놀로지에 대한 미래적 노스탤지어를 제시하였다.<br>부제인 ‘깨어진 꿈’에서 암시하듯 사물 및 신체는 해체되어 나타나고, 왜곡된 미디어와 최첨단 통신의 급속한 발달 속에서 교묘하게 조작되고 세뇌되는 현실에 대한 문명비평적 시각이 작품을 통해 표현되었다. 현재 그의 작업이 몰두하는 회화적 물질의 실재성이 주는 감각 뒤에는 이러한 미디어의 편재와 디지털 기술에 대한 생각, 지난 것에 대한 그리움과 닥쳐올 것에 대한 불안이 여전히 남아있다. 김영헌은 2020년 하인두미술상을 수상하는 등 현재 서울을 중심으로 뉴욕, 프랑스, 홍콩을 무대로 왕성하게 활동하고 있다. 그의 작품은 리움미술관, 자하미술관, 성곡미술관, 국립현대미술관 미술은행, 코오롱그룹, 뱅크오브아메리카 등 국내외 주요 기관에 소장되어 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시장에서 작품들은 최근 그가 모색하는 형식적 실험들과 함께, 일견 하얀 배경 위로 물결 패턴들이 유유히 공간 속을 가볍게 부유하고 때로는 서서히 희미해지면서 화면이 틀 바깥으로 확장된다. ‘프리퀀시’ 시리즈는 예전과 달리 파동 패턴의 균질한 올오버페인팅 양상을 띠며, 밝은 파스텔톤 색조와 함께 가느다란 세필이 이루어낸 수많은 섬세한 선들의 흔들림이 일정하게 높은 주파수의 변주로 화면을 맑은 기운으로 가득 메운다. 이는 마치 어떤잔잔한 미니멀리즘 현대음악의 선율처럼 리듬 자체로 울려퍼진다. 한편 ‘일렉트로닉 노스탤지어’는 하늘에서 내려다본 항공 장면처럼 지층 혹은 물결 위로 내려앉은 사각의 픽셀 노이즈와 함께 더욱 아름다운 패턴의 변이를 창출한다. 작품 <p23055-Electronic Nostalgia>(2023-2026)는 넓은 붓질과 세필이 대조를 이루고 그 위를 원과 사각 형태가 마치 우주를 떠다니는 듯 입체적 구성을 보인다. 하지만 그의 작품들은 가까이 들여다볼수록 이미지는 사라지고 평면 위 두텁거나 얇고, 투명하거나 매끈한 질료적 느낌, 회화적 감각에 집중된다. 대치하던 파동과 노이즈는 어느덧 함께 리듬을 이루며 화합하는 중이다.<br>작가는 물결, 빛, 음악 소리, 커피 향을 자주 언급한다. 기술 매체와 동시대 감각 그리고 회화적 상상, 그의 그림은 어떻게 지각되고 경험되는가? 전시는 떠오르는 여러 질문과 함께 회화의 새로운 예술 체험을 기대한다. 동시대적 감각에 기반하여 그것은 아날로그와 디지털, 과거와 미래, 현실과 가상, 물질과 비물질, 과학과 자연, 낭만과 불안 같은 상반되어 보이는 것들의 틈, 경계에서 작동할 것임을 예감한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><em>“우리는 끊임없이 일렁이는 파동 속에 살고 있다. 브라운관 TV의 주사선, 레코드판에 새겨진 소리골, 바람과 물결, 첼로의 아다지오, 휘어진 시간과 공간, 쿼크 사이의 틈, 은하의 소용돌이, 제임스 웹이 바라본 우주, 디지털 가상공간 속의 삶···</em>”<em> </em>—작가노트</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Ⅱ.<br>작업 초기에 시선을 끌었던 테크놀로지 발전과 미래에 대한 이율배반적 생각이나 실존적 불안감은 어느덧 낯설고도 익숙한 추억이나 그리움으로 옮겨오는 듯하다. 돌이켜보면, <미래를 넘어서> 시리즈(2008-2009)와 <클라우드 맵> 시리즈(2010-2013)의 회화들은 마치 20세기 초 미래주의처럼 기계적인 운동감의 형상으로 역동적 화면을 보여주었고, 이어서 어떤 징후가 감도는 가상 풍경이자 미래의 풍경화인 듯 나타났다. <일렉트로닉 노스탤지어> 시리즈 역시 초기에는 파편화된 형상을 보여주었으나, 그럼에도 불구하고 노이즈와 함께 만들어내는 세상은 어느새 한 폭의 동양 산수화 같은 찬연한 유토피아를 꿈꾸었고, 그것은 다시 현재의 기하학적 도형의 픽셀이 변주를 이끄는 추상의 세계로 수렴되었다.<br>작업에서 픽셀로 된 노이즈는 넓은 공간을 차지하는 색면으로서 전체 분위기를 좌우한다. 스퀴즈나 팔레트 나이프에 의해 색이 벗겨지고 긁힌 채 오히려 고색창연한 자태가 되어 그 자체로 아름답다. 이들은 화면에서 파동의 질서를 교란시킨다. 우리가 미디어에서 접하는 전자적 노이즈 역시 부지불식간에 알 수 없는 공간으로 나타나며, 그것은 전자 세계와 연결하는 인터페이스이자 매트릭스이며 혹은 온라인 공간, 가상현실로 이어진다. 곧 노이즈는 틈이자 균열이며, 파동을 교란시키는 동시에 새로운 리듬이나 공간을 생성하는 인터페이스이다.<br>김영헌은 전자 세계의 감각을 매개하면서도 오히려 컴퓨터 기술이 아닌 전통적인 회화 매체를 택했다. 노스탤지어는 단순한 향수라기보다 현재의 결핍을 반영하는 감정이며, 오늘날에는 모든 것이 가속화된 시대의 불안 같은 것에 대한 방어 기제일 수 있다. 작가에 의하면 그에게는 그리운 기억이 있다. 그의 작업에는 애초에 자신의 감각에 포착된 잔잔한 물결의 일렁임, 즉 물의 파문과 부드럽게 다가오는 바람의 매혹적인 움직임이 몸의 감각으로 전이되는 경험이 내재해 있다. 이러한 자연의 감각적 현상에 대한 경험 이후, 디지털 기술 이전에 흔히 접했던 LP판의 사운드 감성, TV나 전자 기기의 화이트 노이즈 현상이나 빛의 스펙트럼에 대한 기계적 인지와 감각적 느낌, 특히 아들과 인터넷 게임의 가상공간에서 함께했던 기억과 그리움의 감정은 그의 노스탤지어의 기반이 된다. 작가는 이에 관해 발생하는 자신의 감각과 인식을 더듬어 자신만의 현대적 회화 언어로 생성하고 발전시켜왔다. 그것은 한편 가속화된 기술 발전 속에서 예견한 ‘경험한 적 없는 것에 대한’ 노스탤지어(이하림, 2019), 미래적 노스탤지어일 수 있다. 총체성과 연속성이 어려운 시공간, 경험과 기억 사이의 불일치, 가상현실이 남긴 알 수 없는 상실감과 생경한 그리운 감정 같은 것. 이는 전자적 실재와 달리 아련함이 감도는 김영헌의 회화에 전통적인 회화와는 또 다른 미학적 실마리를 제공하고 있다. 가상현실은 또 다른 가상으로 쉽게 대체되고 휘발되지만 그 소중한 기억은 ‘회화’로 포착되어 그의 현재와 관계 짓고 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Ⅲ.<br><em>“그의 삶은 서로 전혀 연결고리가 없는 감각들의 불연속적 연쇄가 될 것이다.”</em> —드니 디드로Denis Diderot</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>디지털 환경과 미디어는 우리의 사고와 지각 체계 자체를 변화시켜왔다. 마셜 매클루언Herbert Marshall McLuhan 에 의하면, 인간은 자신이 사용하는 미디어에 의해 감각 비율과 사고방식이 재편되지만, 정작 그 변화를 잘 인식하지 못한다. 미디어의 영향은 개인의 의견이나 의식 수준과 무관하게 우리의 감각과 인식 구조 자체를 변화시킨다. 스마트폰과 초고속 네트워크가 모든 순간을 파편화하면서 시공간의 거리를 상실한 과잉 초연결 상태로 내몰린 우리는 맞춤형 알고리즘에 의해 저항과 마찰을 제거한 매끄러움의 감각, 끊임없는 정보의 소비로 비물질적인 ‘부유’ 감각에 익숙해졌다. 철학자 한병철이 사유한 바, 디지털화는 인간이 세상과 맺고 있던 단단한 감각의 끈을 끊어버리고 모든 것을 가볍고 매끄러우며 얕게 만들었다.<br>이러한 디지털 세계를 가능하게 한 데에는 양자역학이 있다. 세상에 존재하는 모든 것은 예측하지 못하는 우연한 이탈에 의해 생겨난 것. 이탈이 없으면 자연은 아무것도 만들어내지 못한다. 20세기 초 현대물리학은 우리가 사는 세상의 인식을 바꾸어놓았다. 그것은 세상 만물이 견고한 실체가 아니라 결맞음coherence의 양자 상태 그리고 중첩과 얽힘 가운데 아무것도 결정되지 않은 여러 상태일 뿐, 결이 어긋나고 중첩 상태가 무너져야 비로소 확률적으로 가능한 상태 중 하나가 우리 눈앞에 드러난다는 것이다. 자연이 이처럼 연속적인 흐름의 견고함이 아니라 본질적으로 불연속적으로 구성되어 있음은 당시의 예술에서도 나타났다. 불확실성은 예술에서 추상화, 사실적 재현의 파괴와 변화로 나타났고, 현대미술에서 심리학적이고 형이상학적 내면세계의 반영으로 표현되었다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>디지털화는 결국은 현실 자체를 없애고 머지않아 우리의 시야는 3차원 디스플레이와 같아질 것이라고도 예견하는가 하면, 다양한 강도로 이루어지는 네트워크로서의 이미지 경험은 피에르 위그의 작품 등 동시대의 수많은 영상 작품의 미적 체험에도 나타났다. 우리 시대의 시각 조건 자체가 변화함에 따라 회화의 경험은 어떻게 새로울 수 있는가? 김영헌은 전자기술의 발달이 가져온 디지털적 감각과 존재 방식에 주목하여, 기존과는 달라진 감각과 감수성으로 회화의 새로운 형식과 색채를 탐구한다. 그의 회화 작업에는 디지털 이미지 및 속성에 대한 다양한 연구가 따른다.<br>웨이브 리듬의 왜곡과 절단, 보색 대비가 다채롭게 어우러지는 화면은 판타지적 감각과 에너지의 생동감이 교차한다. 그것은 마치 물리학적 진실처럼 이탈과 중첩, 생성과 단절을 거듭하는 일련의 불연속성이 회화적 특성으로 나타난다. 화면 속 추상의 필치가 빚어내는 과감하게 분할 절단된 구성으로 인한 불연속은 현대인이 디지털 기기를 사용할 때 겪는 파편화된 감각의 경험일 수 있다. 한편 사랑스러운 파스텔톤의 맑고 옅은 느낌을 오가면서도 인공적인 선명한 색채나 형광색은 스스로 빛을 내는 RGB 가시광선과 유사하여 현실감에서 멀어진 사이버틱한 분위기 혹은 가상공간의 느낌마저 준다. 자주 나타나는 초록과 핑크, 노랑과 파랑 등의 보색 관계는 디지털이 가진 속성이다. 작가에 의하면 “화면 위의 색면, 형광색, 절단된 구성 등이 디지털적 속성을 환기한다면, 혁필 줄무늬, 뿌려진 물감 자국, 팔레트 나이프의 흔적, 기하학적 선과 스크래치는 아날로그적 속성을 드러낸다.” 작품에서 대비되는 요소들의 충돌과 간섭 현상은 마치 진동하고 공명하는 파동처럼 또 다른 생성을 유도하면서 화면의 리듬과 에너지는 무한히 확산된다. 개념적으로, 시각적으로 디지털의 분절과 아날로그적 유연함이 공존하는 그의 작업은 매체의 물질성과 신체적 행위에 의한 회화적 표현, 회화 평면의 경험으로 초점이 모아진다.<br>일찍이 지난 세기에 들로네는 색채의 동시성Simultaneity 감각으로, 색채가 나란히 놓였을 때 착시와 감각적 반응을 통해 음악처럼 역동적인 움직임을 표현하고자 했다. 다양한 색상의 상호작용이 움직임과 깊이의 인상을 생성하는 방식, 보색과 상반되는 색을 나란히 배치하여 색조의 효과를 연구했고 칸딘스키 역시 색채의 감정적 효과, 보색 대비의 색채 효과에 몰두하였다. 김영헌의 파동 이미지의 일렁이는 리듬감은 공감각적으로 작동하여 마치 음악에서처럼 즉각적으로 관람자의 신체 파동과 공명하고 새로운 관계를 창출하기도 한다. 평론가 김윤섭은 ‘적당한 호흡 주기와 시각화된 음표의 언어들은 그대로 추상미술의 시적 언어의 재탄생’이라고 말하기도 했다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>철학자 그레이엄 하먼Graham Harman에 의하면 예술은 직접 서술하지 않아도 실재를 은유적으로 접촉할 수 있게 함으로써 실재를 인식하는 기능을 갖는다. 화면의 세련된 감각과 리듬, 부유하고 흔들리는 시적 언어는 작가가 가진 노스탤지어의 은유이자 그 틈새로 확률적으로만 존재하는 미시세계, 수많은 별이 가득한 우주, 불연속적이며 서로 중첩되고 연결되어 있는 우리 삶과 세계의 근원이 어른거린다. 과학적 실재와 생경한 그리움<em>···</em> 실재와 감각 사이의 긴장감은 김영헌의 회화를 아름답게 만든다. 별이 빛나는 밤하늘처럼.   </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>“끊임없이 변화하는 우리의 디지털 삶 혹은 현실 삶의 모호한 경계 일부를 간섭하는, 전자electronic와도 같은 추상 회화 언어를 생성한다.” —작가노트</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"right"} -->
<p class="has-text-align-right">글│강주연 Gallery JJ Director</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '갤러리JJ' WHERE provider_type = 'PUBLIC' AND external_id = '390875';
UPDATE festival SET title = 'Nothing is Forever <영원한 것은 없다>', content = '<!-- wp:paragraph -->
<p><strong><em>Nothing is Forever</em></strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong><em>영원한 것은 없다</em></strong><em></em></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이동기는 한국 현대미술에서 대중문화의 이미지를 가장 적극적으로 미술의 언어로 표현해 온 한국 팝아트의 선구자이자 1세대 팝아트 작가이다. 1993년 발표한 <아토마우스>는 미국 디즈니의 미키마우스와 일본 애니메이션의 아톰을 결합하여 탄생된 캐릭터로, 서로 다른 문화와 시대, 원본과 차용이라는 경계를 유희적으로 넘나드는 현대미술의 새로운 아이콘이다. 어린 시절 작가의 기억을 채웠던 두 캐릭터는 하나의 새로운 존재로 재탄생하고, 이후 교복을 입거나, 하늘을 날고, 꽃밭에 서거나, 부처의 형상을 취하는 등 다양한 모습으로 변주되며 새로운 맥락 속에서 끊임없이 진화한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><코믹스>, <더블 비전>, <절충주의>, <소프 오페라>, <낱말들>​에 이르기까지 그의 작업은 만화, 애니메이션, 광고, 영화, 추상회화 등 서로 다른 출처의 이미지들이 화면 위에서 특별한 위계 없이 중첩되고 병치된다. 그것들은 원래의 맥락을 벗어난 이미지들이 새로운 관계를 형성하는 브리콜라주(Bricolage)의 방식으로 이루어지며, 하나의 진실이나 단일한 의미를 제시하기보다, 현대사회가 지닌 복합적인 현실을 시각적으로 나타낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>우리는 끊임없이 생성되고 소비되는 이미지를 통해 세상을 보고 이해한다. 그러나 시대가 변하면 상징은 다른 의미를 갖고, 익숙했던 서사는 새로운 맥락 속에서 다시 읽힌다. 오늘날처럼 무수한 이미지와 정보가 실시간으로 생성되고 폐기되는 시대에 ''영원한 것''은 존재하지 않는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><Nothing is Forever>는 이러한 동시대의 조건을 누구보다 일찍 예견해 온 이동기의 작업 세계를 새롭게 들여다보는 전시이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><Nothing is Forever>”영원한 것은 없다.” 그렇기에 모든 것은 다시 시작될 수 있다. 이동기의 회화는 끝없이 변화하는 세계속에서 사라짐이 아니라 생성의 가능성을 이야기한다. 오히려 모든 것이 변화하기 때문에 새로운 관계가 가능하고, 새로운 해석이 탄생한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그리고 바로 그 변화 속에서 예술은 언제나 새로운 현재를 만들어낸다.</p>
<!-- /wp:paragraph -->', place = '갤러리나우' WHERE provider_type = 'PUBLIC' AND external_id = '394051';
UPDATE festival SET title = '푸르지오아트홀 수요초대석 40, 김유정의 오페라 <봄봄>', content = '', place = '푸르지오아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390564';
UPDATE festival SET title = '문화예술교육 매개자 네트워크 <모닥> 신청 안내 - (8/20)', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '390945';
UPDATE festival SET title = '《Cloud 9》', content = '<!-- wp:image {"id":19925,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/세로-이미지-배너.jpg" alt="" class="wp-image-19925" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>갤러리조은은 전속작가 성률(b. 1994)​의 개인전 《Cloud 9》을 오는 8월 20일부터 9월 19일까지 개최한다. 이번 전시는 성률이 지속적으로 탐구해 온 기억과 시간, 성장, 그리고 흘러가 버리는 순간에 대한 감각을 최근작을 통해 집중적으로 조명한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>성률은 한국예술종합학교에서 애니메이션을 전공했다. 2022년 《여름 안에서(In Summer)》로 일본 국제만화상 대상을 수상했으며, 이후 장면을 구성하고 이미지를 통해 이야기를 전달해 온 경험을 회화적 언어로 확장하며 자신만의 독자적인 작품 세계를 구축해 왔다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>봉준호 감독이 매료된 ‘조용히 움직이는’ 성률의 회화</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 개인전을 맞아 영화감독 봉준호는 전시 도록에 성률의 작품에 대한 자신의 시선을 글로 풀어냈다. 봉준호 감독은 성률의 회화를 처음 마주했을 때 느껴지는 섬세한 아름다움과 함께, 그 이면에 자리한 설명하기 어려운 ‘미묘한 불안감’​에 주목한다. 눈부신 햇살과 뭉게구름, 아이들, 고양이와 골목은 아름답지만, 동시에 이미 사라져 버렸거나 곧 사라질 것처럼 느껴진다는 것이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>특히 봉준호 감독은 성률의 그림을 바라보면 “화면 속 모든 것이 조용히 움직이고 있는 듯한 느낌”​을 받는다고 말한다. 햇살이 조금씩 이동하고, 운동장 골대의 그림자가 미세하게 길어지며, 바람 없는 날에도 나뭇잎의 그림자가 아주 조금 흔들리는 듯한 감각이다. 이러한 미세한 움직임의 착시는 성률의 그림 안에서 아름다움과 불안, 현재와 과거가 공존하는 독특한 감각​을 만들어낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>봉준호 감독은 글의 마지막을 다음과 같이 맺는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>“2026</strong><strong>년 이제 사람들은 푸른 하늘에 흰 뭉게구름을 보면 성률의 그림을 떠올릴 것이다.”</strong><strong></strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>‘</strong><strong>성장’을 그리는 화가</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>성률의 작품은 푸른 하늘과 거대한 흰 구름, 눈부신 햇빛 때문에 흔히 ‘여름의 그림’​으로 인식된다. 그러나 부산시립미술관 정종효 학예연구실장은 성률의 회화를 단순한 여름 풍경이 아닌 ‘성장에 관한 그림’​으로 바라본다. 정종효 학예연구실장은 성률에게 여름은 하나의 계절이라기보다 생명력이 가장 왕성한 순간이자 인간의 성장을 상징하는 시간이라고 설명한다. 거대한 구름은 끊임없이 흘러가는 시간을 의미하고, 빛은 기억을 다시 불러오는 매개가 된다. 결국 성률이 그리고 있는 것은 풍경 그 자체라기보다 시간과 기억, 그리고 성장의 과정​에 가깝다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>《Cloud 9》 행복과 기억, 그리고 흘러가는 순간</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시 제목 《Cloud 9》은 구름 위에 떠 있는 듯한 황홀함, 즉 더없이 행복한 상태를 뜻한다. 그러나 성률의 작품에서 행복은 거대하거나 극적인 사건의 모습으로 등장하지 않는다. 오히려 당시에는 너무 평범해 미처 알아차리지 못했지만, 시간이 지나고 나서야 소중했음을 깨닫게 되는 순간에 가깝다. 성률은 2025년 작가노트에서 ‘기분이 좋아지는 순간들’​에 대해 이야기하는 동시에, 그 순간들이 언젠가는 지나가 버릴 것임을 느낀다고 말한다. 그리고 그렇게 흘러가는 시간 속에서 서로를 아끼고 기억하는 것이 어쩌면 삶이 아닐까 질문한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>성률에게 그림을 그리는 행위는 그렇게 지나가는 순간을 붙잡아 두는 방식이다. 작품 표면에 물을 뿌리고 물감을 풀어 자연스럽게 번지도록 하는 과정에서 생겨나는 색의 농담과 흔적 역시 시간의 흐름을 떠올리게 한다.  가가 말하듯, 우리의 삶이 계속 흘러가다 언젠가 어디론가 사라진다 해도, 모든 순간이 반드시 흔적을 남기듯 그는 그 흔적들을 화면 위에 남긴다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>따라서 《Cloud 9》은 행복했던 순간에 대한 기억인 동시에, 사라지는 순간을 붙잡고 간직하고 기억하고자 하는 인간의 마음에 관한 이야기이기도 하다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>성률은 아크릴 과슈를 사용해 얇고 투명한 색을 여러 겹 쌓아 올린다. 물감이 마르는 과정에서 자연스럽게 만들어지는 경계와 흔적을 지우기보다 그대로 받아들이며, 중첩된 색을 통해 공기와 시간의 깊이를 만들어낸다. 작가는 풍경 자체를 그리는 것이 아니라, 그 풍경 속에 존재하는 ‘공기’를 그리고 싶다​고 말한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>“</strong><strong>세계를 여행하기 시작한 그림”</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리조은 조인숙 대표는 성률의 작품에 대해 다음과 같이 말한다. 처음 성률의 작품을 만났을 때 익숙한 풍경을 그리고 있음에도 기존 미술의 장르 안에서 어디에 속하는 작품인지 쉽게 규정하기 어려웠습니다. 그러나 바로 그 낯섦에서 성률만의 회화적 언어가 시작되었고, 지금은 그 언어를 바탕으로 자신만의 독특한 장르를 만들어가고 있다고 생각합니다.”</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이어 조 대표는, 성률 작가는 자신의 그림들이 전 세계를 자유롭게 여행했으면 좋겠다고 말합니다. 앞으로 그의 작품들이 더 넓은 세상으로 나아가 다양한 사람들을 만나고, 그 안에서 새로운 의미와 가치를 만들어가는 모습을 기대하고 있습니다.”라고 덧붙였다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>《Cloud 9》은 지금까지 성률이 구축해 온 회화 세계를 집약적으로 보여주는 전시인 동시에, 한 작가의 그림이 더 넓은 세계를 향해 본격적인 여행을 시작하는 순간을 기록하는 전시이기도 하다.  관람객은 작품 속에서 작가 개인의 이야기를 찾기보다, 자신이 지나온 어느 여름날과 어떤 장소, 한때 사랑했던 사람, 그리고 이미 사라져 버린 순간들을 떠올리게 된다. 그 순간 성률의 풍경은 더 이상 작가 개인의 기억 속에 머물지 않는다. 그의 그림을 마주하는 각자의 기억이자, 각자의 풍경이 된다.<strong><u></u></strong></p>
<!-- /wp:paragraph -->', place = '갤러리조은' WHERE provider_type = 'PUBLIC' AND external_id = '394047';
UPDATE festival SET title = '백남준·김류 《백색소음 White Noise》', content = '', place = 'BHAK' WHERE provider_type = 'PUBLIC' AND external_id = '394963';
UPDATE festival SET title = '차계남 개인전 《One Day, Perhaps…》', content = '<!-- wp:paragraph -->
<p><strong>2026</strong><strong>년 8월 20일(목)부터 10월 10일(토)</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>갤러리 세줄</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>차계남의 작업은 언제나 재료에서 출발했지만, 그 끝은 재료에 머물지 않았다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>섬유, 사이잘 마, 한지, 먹. 작가가 선택한 재료들은 부드럽고 유연하며, 때로는 쉽게 찢기고 흩어질 수 있는 것들이었다. 그러나 차계남은 이 연약한 재료들을 반복적으로 물들이고, 꼬고, 쌓아 올리며 하나의 단단한 세계로 이끌었다. 그의 작업에서 재료는 형태가 되고, 형태는 시간이 되며, 시간은 다시 침묵의 공간으로 남는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>초기 섬유 조형 작업에서 차계남은 사이잘 마를 염색하고 압축하며 섬유의 가능성을 조각적 차원으로 확장했다. 실과 섬유는 더 이상 평면 위에 머무는 장식적 요소가 아니었다. 그것은 스스로 서고, 공간을 점유하며, 관람자의 신체와 마주하는 구조가 되었다. 부드러운 재료가 단단한 존재감을 획득하는 이 과정은 차계남의 작업 세계를 이해하는 중요한 출발점이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그의 작품에서 침묵은 단순한 고요가 아니라 시간의 축적과 사유가 머무는 공간이며, 검정은 종결의 색이 아니라 생성과 가능성을 품은 깊이로 읽힌다. 반복된 행위가 만들어낸 구조와 화면은 형태를 넘어 삶과 죽음, 존재와 부재, 유(有)와 무(無)가 공존하는 하나의 공간으로 만들어내고 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2000년대 이후 한지와 먹으로 이어진 작업에서도 이러한 태도는 계속된다. 작가는 한지 위에 먹으로 마음에 품어온 글귀들을 적고, 그 글이 담긴 종이를 잘라 실처럼 꼬았다. 글자는 형태를 잃지만 완전히 사라지지는 않는다. 점과 선의 흔적으로 남아 화면 위에서 또 다른 풍경이 된다. 이렇게 만든 실을 화면에 한 가닥씩 붙여 나가는 행위는 단순한 제작 방식이 아니라, 반복을 통해 시간을 축적하는 수행의 과정이었다. 작가는 이를 두고 그리려는 욕구를 스스로 통제하고 무심(無心)의 상태에서 행위 자체에 집중하는 일이라 말했다. 검정과 흰색이 만들어내는 화면은 산수의 풍경처럼 보이기도 하고, 어떤 기억의 지층처럼 다가오기도 한다. 그 안에서 우리는 보이는 것과 보이지 않는 것, 사라지는 것과 남는 것 사이의 조용한 긴장을 마주한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 작가의 삶을 회고하는 전시에 머물지 않는다. 오히려 그의 작품이 오늘의 시간 속에서 어떻게 새로운 의미를 획득하는지를 살펴보는 자리이며, 작품을 바라보는 자들은 작품을 감상하는 것을 넘어 그 안에 축적된 작가의 시간과 공간을 경험하게 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>“언젠가, 어쩌면”이라는 말에는 아직 끝나지 않은 도착의 감각이 있다. 어느 날, 어쩌면, 우리는 차계남의 작업 앞에서 다시 묻게 된다. 무엇이 사라지고, 무엇이 남는가? 침묵은 어떻게 형태가 되는가? 검정 안에서 무엇이 다시 태어나는가?</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong><em>“보이지 않는 것은 어떻게 존재하는가”</em></strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이 시점에서 차계남작가의 예술적 작품의 의미를 다시한번 새롭게 조명하고자 합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":19979,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/08/IMG_2292.jpg" alt="" class="wp-image-19979" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":19980,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/08/IMG_2295.jpg" alt="" class="wp-image-19980" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":19981,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/08/IMG_2294.jpg" alt="" class="wp-image-19981" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":19982,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/08/IMG_2263.jpg" alt="" class="wp-image-19982" /></figure>
<!-- /wp:image -->', place = '갤러리세줄' WHERE provider_type = 'PUBLIC' AND external_id = '394462';
UPDATE festival SET title = '국립국악원 <연희-판, 흥으로 잇는 세상>', content = '전국 팔도 연희의 정수를 한자리에 모아 신명 나는 재담과 화려한 기예를 선보이는 축제. 관객과 연희자가 함께 호흡하며 우리 민족 특유의 낙천적인 ''흥''과 공동체 정신을 나누는 공연.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '383085';
UPDATE festival SET title = '2026 서울시향 얍 판 츠베덴의 레스피기 ‘로마의 소나무’ ①', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390001';
UPDATE festival SET title = '월간 다온 스테이지 - 8월, ''Ich liebe dich''', content = '', place = '문화공간 스페이스다온' WHERE provider_type = 'PUBLIC' AND external_id = '391488';
UPDATE festival SET title = '[부산] 김유빈 & 리처드 이가 듀오 리사이틀', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '389866';
UPDATE festival SET title = '[원주] 세상의 모든 플레이리스트, 김남훈 & 홍진호 & 김종윤 ', content = '', place = '플레이리스트' WHERE provider_type = 'PUBLIC' AND external_id = '389721';
UPDATE festival SET title = '국립국어원 국어문화학교 8월 특강 <마주하다>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394268';
UPDATE festival SET title = '2026년 제물포구 구립합창단 단원 모집교육·체험진행중', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394842';
UPDATE festival SET title = '접근성 높은 뮤지컬 <극장의 마법사>', content = '''오즈의 마법사''를 모티브로 모두가 함께 만들어가는 무대예술의 가치를 쉽고 재미있게 풀어낸 창작 작품', place = '강동아트센터 소극장 드림' WHERE provider_type = 'PUBLIC' AND external_id = '384555';
UPDATE festival SET title = '2026 서울시향 얍 판 츠베덴의 레스피기 ‘로마의 소나무’ ②', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390107';
UPDATE festival SET title = '[세종] 시크릿 콘서트 <브람스와 와인-노부스 콰르텟> ', content = '', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '389865';
UPDATE festival SET title = '인천시립극단 특별기획 리딩스테이지, ‘가족의 의미’를 되묻는 시간 <배: 웅>', content = '', place = '인천문화예술회관 복합문화공간 ' WHERE provider_type = 'PUBLIC' AND external_id = '391704';
UPDATE festival SET title = '박예솔, The Flip: Sonata & Valse', content = '', place = '피오레아트앤엔터(피오레움) 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '392384';
UPDATE festival SET title = '항구로 간 아트마켓&포차 ''동진항 아트포차''', content = '', place = '울산시 동구 성끝길 74 커피명가 뒤편 주차장 일대' WHERE provider_type = 'PUBLIC' AND external_id = '393223';
UPDATE festival SET title = '예술가처럼 작업하기 ''피에트 몬드리안'' 가족체험', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '391516';
UPDATE festival SET title = '안녕, 나의 웬수', content = '', place = 'KT&G 상상마당 대치아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '387748';
UPDATE festival SET title = '창작가무극 <청사초롱 불 밝혀라>', content = '창작가무극 <청사초롱 불 밝혀라>는 결혼이라는 제도보다 사랑받고 축복받고 싶은 인간의 보편적인 갈망을 다루며 세대와 시대를 초월한 공감을 선사하는 작품', place = '국립정동극장' WHERE provider_type = 'PUBLIC' AND external_id = '392514';
UPDATE festival SET title = '2026 인천아트플랫폼 지역연계 프로젝트 <IAP 아트랩> 컬쳐컴퍼니 봉봉 《취향발견 썸머바캉스》', content = '', place = '인천아트플랫폼' WHERE provider_type = 'PUBLIC' AND external_id = '394843';
UPDATE festival SET title = '김원숙 개인전-Eternal Spring', content = '<!-- wp:image {"id":20167,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/09/Gallery-Yeh_Kim-Wonsook_018.jpg" alt="" class="wp-image-20167" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong><전시소개></strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>영원한 봄</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>김 원 숙</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>“이번 전시 제목을 무엇이라 하면 좋을까요?”<br>여러 가지를 생각해보다가 아버지께 물었더니, 기다리신 듯<br>"혹시 ''장춘(長春眞人)'' 이라는 시인을 아느냐? 그 ''영원한 봄''이 어떠냐" 하셨다.<br>99세의 언덕 위에서 보시는 내 그림에 대한 이해와  희망이 담긴 그 한마디가 정답이었다.<br>해마다 기적같이 피어나는 봄. 그 영원한 생명력, 늙어 쇠하지 않는 젊음, 아름다움의 염원을 담은 귀한 제목이다.<br>몇 가지 다른 이야기들을 담은 이번 전시는 시간이나 소재에 묶이지 않고, 내가 오랜 세월 그려왔던 나의 삶 언저리의 이미지들을 모아 보았다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>결국은 아름다움과 연민이라는 믿음으로.<br>이런 재미난 일을 하루 종일, 매일 할 수 있는 나는 참으로 행복한 사람이다.<br> </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Eternal Spring</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>-Kim Wonsook</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>“What would be a good title for this show?”</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>I was tossing around several ideas, and I asked my father.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>He asked, "Do you know the poem, “Eternal Spring” by Jang Chun, the Daoist Chinese poet?" Of course, I didn''t know. That phrase, embodying both his understanding of my paintings and his hopes for them, viewed from the hilltop of his ninety-nine years, was the perfect answer.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>A yearning for the eternal spring that magically surprises us every year with vitality and beauty that never fades with time.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>This exhibition contains several stories from my life, presented together regardless of time period or medium, all seeking beauty and compassion as their ultimate goal.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>I get to draw and paint this magical life every day, all day long. I am blessed.</p>
<!-- /wp:paragraph -->', place = '예화랑' WHERE provider_type = 'PUBLIC' AND external_id = '396379';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 <기린자리>', content = '', place = '국립극장 무대예술지원센터' WHERE provider_type = 'PUBLIC' AND external_id = '392949';
UPDATE festival SET title = '[서울남산국악당] 2026 젊은국악 단장 - 김성 <자람의 기술 RE:GROW>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '390805';
UPDATE festival SET title = '[부천] BAC 클래식: 김유빈 & 리처드 이가 듀오 리사이틀', content = '', place = '부천아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390256';
UPDATE festival SET title = '국립남도국악원 토요상설: 국악이 좋다, 국립남도국악원 국악연주단 <국악의 향연>', content = '', place = '국립남도국악원 진악당' WHERE provider_type = 'PUBLIC' AND external_id = '390019';
UPDATE festival SET title = '[김근태기념도서관] TEAM낙원장×김근태기념도서관 8월 오픈도서관 <기억을 바꿔놓기>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '392833';
UPDATE festival SET title = '[부산] 비바아첼 인문학콘서트: 음악으로 흐르는 다섯가지 기운, 오행 콘서트 ', content = '', place = '비바아첼 Chamber Hall & Academy' WHERE provider_type = 'PUBLIC' AND external_id = '394023';
UPDATE festival SET title = '영화 상영 <딸기와 초콜릿>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '392982';
UPDATE festival SET title = '2026 고성 문화예술 아카데미 <쓸모있는예술>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394799';
UPDATE festival SET title = '진행 제2회 수그나 <김희선, 원영미, 김혜정, 염미희, 김경숙, 이은미, 이현실, 이현심, 이성진>', content = '', place = '애니메이션박물관' WHERE provider_type = 'PUBLIC' AND external_id = '395752';
UPDATE festival SET title = '[원주 갤러리 원] 유미숙 초대개인전 "어울다-소통"', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '395974';
UPDATE festival SET title = '국립심포니콘서트오케스트라 <브람스, 교향곡 1번>', content = '서로 다른 시대에 탄생한 세 작품이 한 무대 안에서 어떻게 연결될 수 있는지 국립심포니콘서트오케스트라의 젋은 사운드로 확인해보자', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384283';
UPDATE festival SET title = '순환: 비우고 채우며 흐르다, 극단 이단아 <잊지 마, 숨비!>', content = '', place = '소극장 혜화당(구. 까망소극장)' WHERE provider_type = 'PUBLIC' AND external_id = '393466';
UPDATE festival SET title = '국토발전전시관 정기강연 ''이 땅 위에 우리 이야기''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '390577';
UPDATE festival SET title = '강연 <벨키스 아욘 작품에 나타난 시칸의 시각적 언어>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '392986';
UPDATE festival SET title = '이종관 개인전 < SECOND LIFE >   ', content = '', place = '갤러리 인사 1010' WHERE provider_type = 'PUBLIC' AND external_id = '395757';
UPDATE festival SET title = '배준현·황예랑 《빌려온 믿음 Borrowed Faith》', content = '', place = '오에이오에이' WHERE provider_type = 'PUBLIC' AND external_id = '396072';
UPDATE festival SET title = '[평택] 정명훈 & KBS교향악단 with 김세현 ', content = '', place = '평택아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '390515';
UPDATE festival SET title = '낭만주의 거장, 차이코프스키 & 라흐마니노프', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390517';
UPDATE festival SET title = '2026 로데아트센터 마티네 콘서트 시리즈 <클래식 모닝> 레피데 트리오 ＆ Sop. 윤나영', content = '', place = '로데아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '390535';
UPDATE festival SET title = '중구민을 위한 무료 영화 상영 목요일N씨네마 <왕과 사는 남자>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389969';
UPDATE festival SET title = '2026 창작ing 전통 <수난이대>', content = '일제 강제징용으로 팔을 잃은 아버지 ''만도''와 한국전쟁에서 다리를 잃은 아들 ''진수''가 재회해 집으로 돌아가는 여정을 그린다', place = '국립정동극장 세실 (구.세실극장)' WHERE provider_type = 'PUBLIC' AND external_id = '382609';
UPDATE festival SET title = '수림뉴웨이브 2026 - 정상희 <엇:박>', content = '', place = '김희수아트센터 SPACE 1' WHERE provider_type = 'PUBLIC' AND external_id = '388738';
UPDATE festival SET title = '아름다운 목요일 영 오디세이: 모차르트, Ⅳ. 이정우 & 김아인 Piano', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '390692';
UPDATE festival SET title = '2026 산울림 고전극장 <쿠쉬나메 - 끝나지 않는 이야기>', content = '', place = '산울림소극장' WHERE provider_type = 'PUBLIC' AND external_id = '391160';
UPDATE festival SET title = '대전광역시 서예진흥원 <2026 전통서예교육프로그램-한글>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389075';
UPDATE festival SET title = '2026 지역예술인 지원사업 선정작 <설봉산의 반마술 소년-마술의 씨앗 이야기> ', content = '', place = '이천문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '395925';
UPDATE festival SET title = '연극 <고양이라서 괜찮아>', content = '', place = '아신극장 2관 (2층)' WHERE provider_type = 'PUBLIC' AND external_id = '390912';
UPDATE festival SET title = '2026 서울시립 미술아카이브 주제연구포럼 <미술과 문학>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '392283';
UPDATE festival SET title = '청년 대상 체류형 관광 프로그램 <문득, 서천>', content = '', place = '서천군 일대(장항송림자연휴양림, 송석항 등)' WHERE provider_type = 'PUBLIC' AND external_id = '391167';
UPDATE festival SET title = '제19회 K-Ballet World <K-발레레퍼토리>', content = '신인 안무가의 창작 레퍼토리와 국내외에서 활발한 활동을 펼치는 안무가의 예술성 있는 레퍼토리를 공모하여 더블/트리플빌 형식으로 엮어 공연하는 창작 발레 프로그램이다.', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '383636';
UPDATE festival SET title = '⟪본연⟫ 구본창×연진영', content = '', place = 'PS CENTER' WHERE provider_type = 'PUBLIC' AND external_id = '392375';
UPDATE festival SET title = '[부산] 서머 오르간 시리즈, 신동일 & 김효영 듀오 콘서트 ', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390816';
UPDATE festival SET title = '[울산] 국립 합창단 <카르미나 부라나> ', content = '', place = '울산문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '390830';
UPDATE festival SET title = '금정클래식위크 3rd. 울림, Opening Concert: 울림의 서막: 김재원 & Friends', content = '', place = '금정문화회관 대공연장(금빛누리홀)' WHERE provider_type = 'PUBLIC' AND external_id = '390838';
UPDATE festival SET title = '수원시립합창단 잔디밭음악회 <한여름 밤의 싱어롱>', content = '', place = '수원제1야외음악당' WHERE provider_type = 'PUBLIC' AND external_id = '393091';
UPDATE festival SET title = '[삼척] 클래식 마스터피스 시리즈, 그랜드필하모닉오케스트라 & 백건우 ', content = '', place = '삼척문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '392205';
UPDATE festival SET title = '[강북문화재단] 어린이연극 <강아지똥>', content = '', place = '강북문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '389153';
UPDATE festival SET title = '북콘서트 ''이달의 작가'' <수박수영장> 읽고, 수박에 퐁당 빠지기', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '395453';
UPDATE festival SET title = '[울산 울주] 가족음악극 <모차르트>: 영원한 피리와 마지막 선율', content = '', place = '울주문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '395046';
UPDATE festival SET title = '최정원, 홍지민 토크 & 라이브 뮤지컬 콘서트 ‘한여름의 수다’', content = '', place = '소월아트홀(성동문화회관)' WHERE provider_type = 'PUBLIC' AND external_id = '392190';
UPDATE festival SET title = '음악낭독극 < 완벽한 결혼식>', content = '', place = '소극장공유(구. 키작은소나무극장)' WHERE provider_type = 'PUBLIC' AND external_id = '395020';
UPDATE festival SET title = '[서울남산국악당] 2026 젊은국악 단장 - 창작아티스트 오늘 <다들 그러고 삽니다>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '390732';
UPDATE festival SET title = '2026 돌담숲풍류 <지브리, 풍류에 빠지다>', content = '', place = '개포율방' WHERE provider_type = 'PUBLIC' AND external_id = '389509';
UPDATE festival SET title = '[고양] 시민과 함께하는 음악여행 한·일 문화교류 음악회: 음색으로 하나되는 한·일 ', content = '', place = '고양아람누리 새라새극장' WHERE provider_type = 'PUBLIC' AND external_id = '392176';
UPDATE festival SET title = '지브리 & 디즈니 영화음악 FESTA', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '391916';
UPDATE festival SET title = '[대학로] 연극 <VL> ', content = '', place = '링크더스페이스(LINK THE SPACE)' WHERE provider_type = 'PUBLIC' AND external_id = '391699';
UPDATE festival SET title = '홍종화 & 김정수 듀오 연주회', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '391223';
UPDATE festival SET title = '제9회 힉엣눙크! 뮤직 페스티벌, 젊은 비르투오소 시리즈, 데이비드 버넷 & 니나 버넷 듀오 한국 데뷔 리사이틀', content = '', place = '일신홀' WHERE provider_type = 'PUBLIC' AND external_id = '392124';
UPDATE festival SET title = '신성아 개인전 “상상 : Imagination”', content = '', place = '갤러리 스페이스포포' WHERE provider_type = 'PUBLIC' AND external_id = '393418';
UPDATE festival SET title = 'What Holds Us | 우리를 붙드는 것', content = '<!-- wp:paragraph -->
<p>갤러리 세줄은 오는 2026년 2월 26일부터 04월 04일까지 작가 정보원과 최정윤의 2인 전 《What Holds Us | 우리를 붙드는 것》을 개최합니다. 이번 전시는 세대와 표현 방식이 다른 두 작가의 작업을 한 공간에 병치함으로써, 우리를 지탱하고 붙드는 힘의 본질에 대해 질문을 던집니다. 우리를 붙드는 것은 언제나 눈에 보이는 것만은 아닙니다. 구조일 수도 있고 관계나 기억, 혹은 말없는 긴장감일 수도 있습니다. 두 작가는 각자의 방식으로 이처럼 보이지 않는 힘을 탐색해 왔으며, 그들의 작업은 공간과 감정, 질서와 불안 사이를 넘나들며 조각이 도달할 수 있는 감각적 영역을 확장합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>정보원은 건축과 조각을 함께 공부하며 오랜 시간 ‘공간’이라는 개념을 중심에 두고 조각의 언어를 발전시켜 왔습니다. 공공 조형물과 금속 구조물을 통해 구조와 긴장, 흐름, 음향까지도 작품의 일부로 받아들이는 입체적인 감각이 특징입니다. 음악의 리듬이나 주파수를 시각화한 평면 및 입체 작업을 통해, 감각과 기술, 구조와 흐름을 유연하게 넘나드는 조형 언어를 보여줍니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>최정윤은 검, 실, 소금, 꽃 같은 상징적인 재료를 활용해 인간의 욕망과 권력, 시간의 흔적을 조형화해 왔습니다. 검을 실로 감거나 소금으로 봉인하는 행위를 통해 욕망을 억누르고 감정을 봉인하며, 한(恨)의 미학을 구현합니다. 상징과 물성을 결합한 조형 언어는 강한 내면성과 함께 긴장감을 자아냅니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>《What Holds Us》는 구조와 봉인, 공간과 욕망, 추상과 상징이라는 각기 다른 미학 언어가 맞닿으며 새로운 균형을 만들어냅니다. 관람자는 두 작가의 작업을 통해 ‘무엇이 우리를 붙들고 있는가’라는 질문과 자신만의 답을 마주하게 될 것입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Gallery Sejul presents the two person exhibition <em>What Holds Us</em> featuring artists Chung Bowon and Choi Jeongyun, on view from February 26 to April 4, 2026.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Bringing together two sculptors of different generations and artistic approaches, the exhibition poses a fundamental question about the forces that sustain and bind us. What holds us is not always something visible. It may take the form of structure, relationships, memory, or a silent tension that exists just beneath the surface. Through distinct yet resonant practices, both artists have long explored these invisible forces. Their works move fluidly between space and emotion, order and unease, expanding the sensory territory that sculpture can inhabit.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Chung Bowon has developed his sculptural language around the concept of space, shaped by his background in both architecture and sculpture. His practice is characterized by an expanded spatial sensibility that embraces structure, tension, flow, and even sound as integral elements of form. Through metal constructions and public sculptures, as well as two dimensional and three dimensional works that visualize musical rhythm and frequency, he navigates seamlessly between sensation and technology, structure and movement.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Choi Jeongyun employs symbolic materials such as swords, thread, salt, and flowers to give form to human desire, power, and the traces of time. By wrapping swords with thread or sealing them in salt, she enacts gestures of restraint and containment, suppressing desire and sealing emotion. Her work evokes the aesthetics of han, a deeply rooted sense of restrained sorrow, and generates a palpable tension through the convergence of symbolism and material presence.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>In <em>What Holds Us</em>, differing sculptural languages intersect structure and sealing, space and desire, abstraction and symbolism to create a new and delicate balance. Through their encounter with the works, viewers are invited to confront the question of what holds them and to arrive at their own answer.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17435,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/02/KakaoTalk_Photo_2026-02-26-12-49-16.jpeg" alt="" class="wp-image-17435" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":17436,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/02/KakaoTalk_Photo_2026-02-26-12-48-28-001_compressed.jpg" alt="" class="wp-image-17436" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":17437,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/02/KakaoTalk_Photo_2026-02-26-12-48-29-002_compressed.jpg" alt="" class="wp-image-17437" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":17438,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/02/KakaoTalk_Photo_2026-02-26-12-48-29-004_compressed.jpg" alt="" class="wp-image-17438" /></figure>
<!-- /wp:image -->', place = '갤러리세줄' WHERE provider_type = 'PUBLIC' AND external_id = '370038';
UPDATE festival SET title = '손 끝의 포에마', content = '<!-- wp:image {"id":19032,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/06/고현정-이도경-이인전_손-끝의-포에마_final_대지-1-사본-23.jpg" alt="" class="wp-image-19032" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>손 끝의 포에마</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>-고현정, 이도경 작가에게</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>비밀이 담겨있을 듯한 편지 형식을 빌려 기획글을 쓰게 된 이유는 세상과 ''어떻게 마주할 것인가''를 고민하는 두 작가의 작업 방식이 편지라는 본질과 닮아있기 때문입니다.<br>받는 사람에 가닿기 위한 말을 고르고 오래 망설이는 편지의 과정처럼, 두 작가는 무엇을 드러낼까보다 대상과 어떻게 관계 맺을지를 먼저 질문합니다.<br>이 전시는 완성된 결론을 통보하는 자리가 아니라, 세상과 밀어를 나누어 가는 과정의 자리에 관람객을 초대하는 것이기에 편지 형식을 빌려왔습니다</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><br>두 작가의 작품 앞에서 오랜 시간 머물다보니 자연스럽게 그들의 손 끝에 집중하게 되었습니다. 긴 시간에 걸쳐 무수한 반복을 이어가는 손 끝을 통해 만들어진 궤적은 두 작가가 세상을 어떻게 마주해왔는지 보여줍니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그 시선의 방식이 그들의 형식을 만들어 냈습니다. 영상 속의 손 때 묻은 천이 그저 특정 매체의 물성으로 선택된 것이 아니라, 미처 말로 다 할 수 없는 마음에 닿고자 하는 간절한 바램 끝에 비로소 언어가 골라지는 시의 과정과 비슷한 여정을 거치지 않았을까 하는 생각이 들었습니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><br>이런 손 끝의 움직임을 우리는 ''포에마(Poiema)''라 부를 수 있을 것 같습니다. 고대 그리스어 ''포이에오(Poieo, 만들다)''에서 파생된 이 단어는 오늘날 ''시(Poem)''의 어원입니다.<br>사전적으로 포에마는 ''만들어진 것'', ''장인의 창조물''을 뜻하지만, 이 전시에서 포에마는 완성된 결과물이 아닙니다. 세계를 향한 태도가 시선이 되고, 그 시선이 손 끝을 거쳐 재료에 닿기까지의 행위 전체이자, 그 행위가 시간과 함께 겹겹이 쌓여가는 과정입니다.<br>작품 앞에 선다는 것은 두 작가가 세계와 마주해 온 시간 전체를 보는 것입니다.<br>흔적들이 쌓일수록 포에마는 깊어집니다. 두 작가의 작업이 각기 다른 방향의 시선임에도 그 과정을 멈추지 않았기 때문에 결국은 한 자리에서 만날 수 있었다고 생각합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><br>고현정 작가의 시선은 작가의 내면에서 외부의 존재로 향합니다. 강아지, 고양이, 나비 등 일상 속에서 무심히 지나치는 뭇생명의 존재들을 향해 내면의 에너지가 지속적으로 흘러갑니다.<br>일상 속 견디기 힘든 어려움이 밀려와도 그 시선을 거두지 않습니다. 캔버스 위에 두텁게 쌓인 마띠에르는 그 시선의 축적입니다. 붓터치의 집적은 시선의 반복이고, 시선이 쌓인 만큼 물감의 두께가 된 것입니다. 그 과정이 거듭될수록 작가와 대상 사이의 경계는 흐려집니다.<br>작가에게 특정 형태의 이미지를 표현해 나간다는 것은, 바라보는 그 대상과 하나가 되어가는 지점과 만나게 되는 까닭입니다.<br>나와 저 존재가 같은 조건 안에 있다는 것, 거대한 시스템 안에서 마주하게 되는 어쩔 수 없다는 감각, 그 취약함 앞에서 우리가 다르지 않다는 일종의 연대의 감정이 작은 위안으로 느껴지기도 합니다.<br></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이도경 작가의 시선은 반대 방향으로 움직입니다. 대상의 표면에서 출발해 그 안으로 파고듭니다. 손 때가 밴 낡고 오래된 천, 누군가의 시간이 묻어 있는 사물들 안에 숨겨진 의미를 찾아 해체하고 다시 붙여 새로운 의미를 만들어냅니다.<br>스톱모션 영상도 한 겹씩 시간을 열어가는 작가의 방식과 닮아 있습니다. 동물탈을 쓰고 등장하는 존재들도 마찬가지입니다. 작품 속 탈은 무언가를 감추기 위한 도구가 아닙니다.<br>동물의 탈을 씌우는 순간 그 이야기는 더 이상 나만의 것이 아닌 모두의 것이 되고, 관람객은 그 안으로 더 깊이 들어갈 수 있게 됩니다.<br>이도경 작가의 시선 속에서는 끝난 것처럼 보이는 것들은 아직 끝나지 않았으며, 버려진 것 안에서도 새로운 의미가 시작될 수 있습니다.<br>작가는 지름길이 아닌 돌아가는 길로 시선을 택하지만, 그 길이 결국 가장 깊은 곳까지 닿습니다.<br></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>안에서 밖으로 뻗어나오는 시선과 밖에서 안으로 파고드는 시선은 서로 방향은 다르지만 같은 자리에서 만납니다.<br>손 끝의 흔적 앞에서 두 작가의 포에마는 완성이라는 목적지가 아닌 지금도 움직이는 손 끝의 흔적 안에 존재합니다.<br>좋은 날이 올지 묻지 않고, 오늘도 무언가를 다루고 그 흔적을 남기는 두 작가의 손 끝은 이미 알고 있지 않을까 싶습니다.<br>지나간 시간은 되돌릴 수 없지만, 손 끝이 남긴 흔적은 사라지지 않는다는 것을.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><br>글. 양수인 (갤러리밈 큐레이터)<br><br><br><br><br><br><strong>고현정</strong><br><br><strong>작가노트</strong> </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>내가 그리고자 하는 것은 삶을 지속해나가는 존재들입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>때로는 생존을 눈앞에 둔 채, 혹은 인생이나 자연이 준 어쩔수 없음 앞에서</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>온몸으로 그것을 받아내는 생명체들입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>나는 그들에게서 위로를 받기도하고, 용기와 의연함을 배우기도 합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그들은 나를 다른 세계로 데려가기도 하고, 한편으로는 현실에 발을 디디게 하기도 합니다. <br> </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Education</strong>​</p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td> 2019​</td><td> 한국예술종합학교 조형예술학과 (평면) 전문사 졸업</td></tr><tr><td> 2015 </td><td> 가천대(구 경원대) 회화조소과 (동양화) 학사 졸업​</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>SOLO Exhibition</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td> 2024 </td><td> 우리는 매일 다시 태어난다, 상업화랑 용산, 서울​</td></tr><tr><td> </td><td> 지난 밤에 본 그 개는 어디로 갔을까, 응접실, 인천​​​​</td></tr><tr><td> 2022</td><td>  잃어버린 것을 찾아서, Graphite on pink Factory, 서울​  말하지 않는 토끼, 갤러리 O, 서울, 한국​​</td></tr><tr><td>  </td><td> The Sweet Sunburn, 아트랩반, 서울​고대 토끼 미스터리, 라운디드 플랫, 서울, 한국​​</td></tr><tr><td> 2019</td><td> 낯(face,sur-face), A-lounge Gallery, 서울​게임: 토끼 퍼즐, 갤러리 이데아 홀, 서울, 한국​​</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>TWO Person Exhibition</strong>​</p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td> 2026</td><td> 손 끝의 포에마, 고현정, 이도경 이인전, 갤러리밈, 서울 </td></tr><tr><td> 2025</td><td> Fur, Fur, 고현정, 황예랑 이인전, 갤러리 호호, 서울</td></tr><tr><td> 2023</td><td> One Fine Day, 김도연, 고현정, 페이토 갤러리, 서울</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>GROUP Exhibition</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td> 2025 </td><td> 신과 함께, 대구아트웨이, 대구</td></tr><tr><td> 2023</td><td> 물의 왕: 동학과 화엄의 두물머리, 자하 미술관, 서울</td></tr><tr><td> </td><td> 경험의 아치, 갤러리인HQ, 서울 </td></tr><tr><td> </td><td> Green Luminance, 갤러리 호호, 서울</td></tr><tr><td> </td><td>​ 초식그림, 큐아카이브, 서울​​</td></tr><tr><td> 2022</td><td> BGA INDEX : Open Storage , BGA INDEX, 서울​​</td></tr><tr><td> </td><td> DRAWIING GROWING, 미학관, 서울​​</td></tr><tr><td> </td><td> 마치 피크닉, 아트비프로젝트, 서울​​</td></tr><tr><td> 2021</td><td> 전시후도록, WESS, 서울</td></tr><tr><td> </td><td> 5518. 8880 - <문화적 거리; in between>,코번트리 한국학 연구소, 코번트리, 영국​​ ​</td></tr><tr><td> 2020</td><td> 10의 N승, 문화역서울 284 TMO, 서울</td></tr><tr><td> </td><td> Cutting Edges 12 Printmakers, 스페이스나인, 서울​</td></tr><tr><td> </td><td>  BGA 오프라인 쇼케이스 : PSYSICAL 팩토리2, 서울​</td></tr><tr><td> </td><td> 단독주연, 중간지점, 서울​</td></tr><tr><td> 2018</td><td>​ Thin/K 복도갤러리, 서울​</td></tr><tr><td> </td><td>  드로잉의 무게, Gallery 9P, 서울​</td></tr><tr><td> 2016</td><td>  낯선 이웃들, 서울시립 북서울미술관, 서울​</td></tr><tr><td> 2014</td><td> 3x4 사각의 초상, 암웨이미술관, 경기​</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>Project</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td> 2023​</td><td> 인천 연수 예술지원사업 <고현정 오픈 스튜디오></td></tr><tr><td> 2016</td><td> <동북부 미술대학 연계 발굴 프로젝트: 낯선 이웃들> 독립연구팀 </td></tr><tr><td> </td><td> 노원구 공공미술, 여긴 어디, 나는 누구?, 서울 시립 북서울미술관, 서울</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong><br></strong><strong>Collections</strong>​​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>인천미술은행 소장</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p> ​<br><br> </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>이도경</strong>​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><br><strong>작가노트</strong> </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>어떤 이는 삶을 처절하게 산다. 좋은날이 올지 안 올지 모르겠지만, 그래도 영위어 나아간다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>살아있는 사람들은 겁쟁이 같기도, 용기있는 사람같기도 하다는 생각이 든다.<br>언제 한번 비가 우장창 오고 난 다음에 </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>무지개가 크게 뜨던게 생각난다. 무지개 보면서 언젠가 좋은날이 오겠지라고 생각했는데. 언젠가 좋은 날 오겠지​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Education</strong>​</p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td> 2022​</td><td>  이화여자대학교 조형예술대학 일반대학원 서양화과 졸업</td></tr><tr><td> 2018 </td><td> 이화여자대학교 조형예술대학 서양화과 졸업​</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>SOLO Exhibition</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td> 2025 </td><td>  <포실로스티 Poshlosti>, 래빗앤타이거 갤러리, 서울​</td></tr><tr><td> 2022</td><td>   브레멘 음악대 Town Musicians of Bremen, 아트큐브, 서울​​​​​</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>TWO Person Exhibition</strong>​</p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td> 2026</td><td> 손 끝의 포에마, 고현정, 이도경 이인전, 갤러리밈, 서울 </td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>GROUP Exhibition</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td> 2024 </td><td> 우리로부터 멀어지는 것들 All that Escapes from Us, 도잉아트, 서울 </td></tr><tr><td> 2024​</td><td> 어 피스 오브 페이퍼 A Piece of Paper, 갤러리 프로젝트 케이, 서울​</td></tr><tr><td> 2023​</td><td> 일상의 시 The Poetry of Daily Life, 스페이스 비투, 서​</td></tr><tr><td> 2022</td><td> 경쾌한 자서전, 도잉아트, 서울​</td></tr><tr><td> 2019</td><td>​ 테이크 오프 Take-off, 스페이스55, 서울​​​</td></tr><tr><td> 2018</td><td> 흐르는 공기처럼, 움직이는 바람처럼 flowing air, moving wind, 유중아트센터, 서울​​​</td></tr></tbody></table></figure>
<!-- /wp:table -->', place = '갤러리밈' WHERE provider_type = 'PUBLIC' AND external_id = '384016';
UPDATE festival SET title = 'K''urius의 피아노 스펙트럼 2 (큐리어스의 피아노 스펙트럼 2)', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390905';
UPDATE festival SET title = '몰리에르와 샤르팡티에의 코믹발레오페라 <상상병 환자 2026>', content = '', place = '구로아트밸리 예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '392106';
UPDATE festival SET title = '2026 이병찬 안무전 <Before Touch>', content = '', place = '송파구민회관 대강당' WHERE provider_type = 'PUBLIC' AND external_id = '395506';
UPDATE festival SET title = 'Mike Nesbit 《MEASURED RESOLVE》', content = '<!-- wp:paragraph -->
<p>마이크 네스빗에게 회화는 평면 위에 이미지를 얹는 일로 한정되지 않는다. 건축을 전공하고 실제 건설 현장을 경험한 그는 콘크리트, 목재, 합판, 철망처럼 구조를 만들기 위해 사용되는 재료와 함께 자르고, 조립하고, 붓고, 지지하고, 세우는 구축의 과정 자체를 회화의 언어로 끌어들인다. 그의 작품에서 재료는 이미지를 전달하기 위한 수단이 아니라, 스스로 무게와 압력, 중력과 시간의 흔적을 남기는 능동적인 요소다. 따라서 작품은 미리 정해진 화면을 재현하기보다 제작 과정에서 발생하는 물리적 조건과 현장의 변화 속에서 형성된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이러한 태도는 《Pour Tomorrow》(2025)와 《Built Like Us》(2026)를 거치며 더욱 분명해졌다. 《Pour Tomorrow》에서 네스빗은 건설 현장을 전시장으로, 전시장을 다시 건설 현장으로 바라보며 콘크리트와 거푸집, 도구와 노동을 하나의 조형 체계 안에 놓았다. 이어 《Built Like Us》에서는 손수레, 양동이, 작업화, 철망과 콘크리트 블록처럼 본래 제작을 위해 존재하는 요소들이 회화와 조각의 표면, 지지체, 설치 구조로 확장되었다. 《MEASURED RESOLVE》는 이 언어를 새롭게 바꾸기보다, 서울의 특정 전시장 안에서 다시 조합하며 작품과 장소의 관계를 한층 직접적으로 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>《MEASURED RESOLVE》는 이러한 제작 방식을 이끄는 두 태도를 함께 가리킨다. ‘Measured’는 단순한 수치의 정확성보다 몸을 통해 무게와 거리, 균형과 저항을 가늠하는 측정에 가깝다. 치수를 재고 순서를 계획하며 구조를 준비해야 하지만, 재료와 공간은 언제나 계획대로만 움직이지 않는다. ‘Resolve’는 계획을 끝까지 관철한다는 의미와 동시에, 현장에서 무엇을 받아들이고 무엇을 수정하며 어디에서 멈출 것인지를 결정하는 판단을 뜻한다. 네스빗에게 완성은 예정된 형태에 도달하는 순간이 아니라 계획과 재료, 통제와 우연 사이의 협상을 통해 잠정적으로 선택된 상태다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시에서 사다리와 손수레는 조각으로 제시되는 동시에 회화가 만들어지는 과정에 직접 참여한다. 전시장 바닥에서 수평으로 제작된 《Vertical Easement》에는 이 사물들이 남긴 접촉과 압력, 재료의 흐름이 화면의 흔적으로 이어지고, 완성된 작업은 다시 수직으로 세워져 회화가 된다. 이 수평에서 수직으로의 전환은 제작과 전시, 도구와 작품 사이의 경계를 흔든다. 또한 바닥 타일을 제거하던 중 예상하지 못한 이전 타일층이 드러나자 작가는 처음 계획한 깊이까지 철거하지 않고 그 지점에서 작업을 멈추었다. 발견된 조건을 실패가 아니라 새로운 판단의 기준으로 받아들이는 이 선택은 전시 제목의 ‘Resolve’를 가장 구체적으로 보여준다. 전시의 제작과 설치는 행림종합건축사사무소(Haenglim Architects & Engineers)와의 협업으로 진행되었다. 대형 구조물과 콘크리트, 목재 프레임을 실제 공간 안에서 구현하고 조정하는 과정에서 제작과 설치는 작품 이후의 기술적 단계가 아니라 작업의 형성에 참여하는 일부가 된다. 바닥의 노출, 거울의 반사, 사다리와 손수레의 물리적 존재, 벽에 세워진 회화는 서로 독립된 요소로 남지 않고 관람객의 이동에 따라 계속 새로운 관계를 만든다. 결국 《MEASURED RESOLVE》에서 회화는 벽에 걸린 하나의 대상에 머물지 않는다. 그것은 도구와 조각, 바닥과 건축, 노동과 협업, 그리고 관람객의 몸 사이에서 계속 구축되는 하나의 공간적 사건이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>For Mike Nesbit, painting is less a bounded medium than a field of construction. Trained in architecture and shaped by work in building environments, he mobilizes concrete, timber, plywood, and steel mesh alongside the procedures through which structures are made: cutting, bracing, pouring, lifting, positioning. Materials are not neutral supports but agents that register force, gravity, duration, and contact. The image therefore emerges not from a fixed composition but from the contingencies of fabrication and site.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>This logic has developed across Pour Tomorrow (2025) and Built Like Us (2026). In Pour Tomorrow, the construction site and exhibition space were treated as reciprocal conditions, with formwork, tools, concrete, and labor occupying a single spatial system. Built Like Us pushed these provisional supports further into the work itself: wheelbarrows, buckets, work boots, mesh, and concrete blocks became surface, structure, and sculptural form. MEASURED RESOLVE relocates this vocabulary within UM Gallery, where the relation between object, process, and architecture becomes immediate and site-specific.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The title names two interdependent modes of working. “Measured” suggests not numerical exactitude alone, but an embodied calibration of distance, balance, weight, and resistance. Structures are planned and dimensions taken, yet matter and site remain only partially governable. “Resolve” thus signifies both determination and judgment: the capacity to continue, revise, accept, or stop. Completion appears not as the realization of a fixed plan, but as a provisional resolution negotiated between intention and contingency.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Here, a ladder and wheelbarrow function simultaneously as sculpture and as instruments in the making of painting. Vertical Easement was produced horizontally on the gallery floor, where contact, pressure, and material movement registered across its surface before the work was raised upright. The shift from horizontal fabrication to vertical display collapses distinctions between tool and artwork, production and exhibition. The same logic governs the floor intervention: when removing the existing tile exposed an earlier layer, Nesbit chose not to continue toward the intended concrete slab. The decision to stop turns discovery into a material form of resolve. The exhibition was realized in collaboration with Haenglim Architects & Engineers. Within a practice dependent on concrete, timber frameworks, tools, and architectural conditions, fabrication and installation do not follow conception; they are constitutive of it. Exposed floor, mirrored surfaces, ladder, wheelbarrow, and paintings operate as a shifting field of relations activated by the viewer’s movement. MEASURED RESOLVE consequently positions painting not as an autonomous object but as a spatial event produced through material, labor, architecture, and bodies in motion.</p>
<!-- /wp:paragraph -->', place = '유엠 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '395976';
UPDATE festival SET title = '[대학로] 뮤지컬 리딩 쇼케이스 <더 스윙>', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '393682';
UPDATE festival SET title = '2026 부천문화재단 어린이공연, 옴니버스 넌버벌 인형극 <환상공간>', content = '', place = '복사골문화센터 판타지아극장' WHERE provider_type = 'PUBLIC' AND external_id = '391748';
UPDATE festival SET title = '옹옹옹', content = '''옹고집전''을 강훈구 연출과 서동민 작가가 유쾌하게 비튼다. 우리는 과연 ''진짜''로 살아가고 있을까. 풍자와 해학이 살아 숨 쉬는 음악극!', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392829';
UPDATE festival SET title = '연극 벚꽃동산 <화림 광장>', content = '', place = '지구인아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393809';
UPDATE festival SET title = '국립극단 [창작희곡공모 대상 수상작] <역행기>', content = '15년 만에 부활한 국립극단 창작희곡공모, 그 첫 결실! 공모와 낭독공연을 거쳐 마침내 본공연으로!', place = '국립극단 [명동] 명동예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '392924';
UPDATE festival SET title = '플라멩코와 함께하는 모던 팝 클래식 콘서트 ‘날 것. 놀러. Ole!’', content = '', place = '고양아람누리 새라새극장' WHERE provider_type = 'PUBLIC' AND external_id = '393296';
UPDATE festival SET title = '2026년 열 번째 플루트 부케를 드립니다. "감사"', content = '', place = '성남아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390442';
UPDATE festival SET title = '[원주] 백건우 <슈베르트> ', content = '', place = '원주백운아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '396584';
UPDATE festival SET title = '[평택] 한국소리터 어린이 동물탈놀이 창작연희극 <만보와 별별머리> ', content = '', place = '한국소리터 지영희홀' WHERE provider_type = 'PUBLIC' AND external_id = '391744';
UPDATE festival SET title = '강성아 개인전 <가만히>', content = '', place = '비커밍갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '395931';
UPDATE festival SET title = '[서울] 국립창극단 <귀토>', content = '''수궁가'' 이후를 유쾌한 상상력으로 풀어낸 국립창극단 대표 흥행작', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392777';
UPDATE festival SET title = '아티스트 IN 과천, 2026 재인청춤판 <왕! 발로 새긴 태평> 정주미재인청예술단', content = '', place = '과천시민회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '395662';
UPDATE festival SET title = '대전광역시 서예진흥원 <제2회 ''붓의 울림'' 한글사랑 서원회전>', content = '', place = '대전광역시 서예진흥원' WHERE provider_type = 'PUBLIC' AND external_id = '394572';
UPDATE festival SET title = '[인천] 포스트드라마 연극 <기록된, 기록될>', content = '', place = '작은극장 돌체' WHERE provider_type = 'PUBLIC' AND external_id = '396234';
UPDATE festival SET title = '[대학로] 26세에 의사를 시작해서 58세에 의사를 그만뒀고 철이 없어서 연극을 시작했다. 62세에… ', content = '', place = '효천아트센터 그라운드씬' WHERE provider_type = 'PUBLIC' AND external_id = '395914';
UPDATE festival SET title = '외경', content = '뱀이 비정한 사회에서 더 비정하게 살아가기 위한 이 시대의 탈무드! “악착같이 일하고, 희망을 갖고, 남을 배려하고, 할 수 있는 최선을 다해 살면 이 꼴이 되고 말지.”  -외경 대사 中-', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '393115';
UPDATE festival SET title = '[대전] 블랙코미디연극 <죽여주는 이야기> ', content = '', place = '런던스테이지 [대전 중구] 2F' WHERE provider_type = 'PUBLIC' AND external_id = '393558';
UPDATE festival SET title = '<2026 STAGE 100: 연극제> 동물농장', content = '', place = 'NC문화재단 홀' WHERE provider_type = 'PUBLIC' AND external_id = '392053';
UPDATE festival SET title = '[대구] 지브리 & 디즈니 영화음악 FESTA ', content = '', place = '대구콘서트하우스 그랜드홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '363703';
UPDATE festival SET title = '[대구 동성로] 연극 <그녀를 믿지마세요>', content = '', place = '아트플러스씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '393363';
UPDATE festival SET title = '[대구] 창작연극팩토리 연극 <햄릿>', content = '', place = '수성아트피아' WHERE provider_type = 'PUBLIC' AND external_id = '395208';
UPDATE festival SET title = '취미인간에서 들리는 전시 프로젝트 Vol. 2 박소진 개인전 <잠시 후 우회전입니다>', content = '', place = '취미인간' WHERE provider_type = 'PUBLIC' AND external_id = '401529';
UPDATE festival SET title = '[대구 동성로] 연극 <굿프렌즈> ', content = '', place = '아트플러스씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '401597';
UPDATE festival SET title = '청주시립합창단 제87회 정기연주회 헨델 오라토리오 <Alexander’s Feast>', content = '', place = '청주아트홀 (구. 청주시민회관)' WHERE provider_type = 'PUBLIC' AND external_id = '394813';
UPDATE festival SET title = '2025년 독도박물관 특별전시회 ''어부지용''', content = '', place = '독도박물관' WHERE provider_type = 'PUBLIC' AND external_id = '325772';
UPDATE festival SET title = '[경산] Neo Opera 퓨전 가족음악극 <거북이의 꾀> ', content = '', place = '경산시민회관 대강당' WHERE provider_type = 'PUBLIC' AND external_id = '400779';
UPDATE festival SET title = '[경주] 뮤지컬 <더 쇼! 신라>', content = '', place = '경주세계문화엑스포 문화센터공연장' WHERE provider_type = 'PUBLIC' AND external_id = '399706';
UPDATE festival SET title = '[구미] 예술경영지원센터 대표공연 지원사업 연극 <꽃, 별이지나>', content = '', place = '구미시문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '400877';
UPDATE festival SET title = '[창원] 지브리 & 디즈니 영화음악 오케스트라 콘서트 ', content = '', place = '성산아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '373756';
UPDATE festival SET title = '[속초] 우리 소리극 <까만 인절미> ', content = '', place = '속초문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '391974';
UPDATE festival SET title = '[과천] 브라소닛 빅밴드와 앰비규어스 댄스 컴퍼니, Body & Voice ', content = '', place = '과천시민회관 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '392169';
UPDATE festival SET title = '[서울영화센터] <스마트폰으로 만드는 나만의 영화 - Ⅲ.포스트프로덕션> 공고 오픈!', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '391331';
UPDATE festival SET title = '국립기상박물관 9월 체험교육 프로그램 <측우기 만들기>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '393064';
UPDATE festival SET title = '2026 인천아트플랫폼 <창작스튜디오 프로젝트> 시민참여 워크숍 9월', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '393360';
UPDATE festival SET title = '「담쟁이 창작소」 문화예술교육 프로그램 <움직임코드>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396674';
UPDATE festival SET title = '🟢 2026 디지털아트 컬처랩｜유스랩 참여자 모집 (교육 수료증 발급!)', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '395871';
UPDATE festival SET title = 'TWO GUITARS: 박규희×박주원', content = '클래식 기타리스트 박규희와 집시 기타리스트 박주원이 만나 두 기타만으로 펼쳐낼 수 있는 다채로운 음악 세계를 선보이는 특별한 듀오 콘서트.', place = '세종문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '392999';
UPDATE festival SET title = '2026 감성콘서트 <가을을 여는 소리 아름다운 동행>', content = '', place = '평택시북부문예회관' WHERE provider_type = 'PUBLIC' AND external_id = '394944';
UPDATE festival SET title = '음악그룹 오롯 콘서트 <화성탐사 III : 결>', content = '', place = '소다미술관' WHERE provider_type = 'PUBLIC' AND external_id = '392890';
UPDATE festival SET title = '비바아첼 V.I.P 리사이틀시리즈 1. 바이올리니스트 김덕우 & 시명운', content = '', place = '비바아첼 Chamber Hall & Academy' WHERE provider_type = 'PUBLIC' AND external_id = '392623';
UPDATE festival SET title = '미네소타 컨템퍼러리 앙상블 MCE 정기연주회 “소리의 풍경”', content = '', place = '영산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '388803';
UPDATE festival SET title = '[울산] 입과손스튜디오 <긴긴밤> ', content = '', place = '울산중구문화의전당 함월홀(2층)' WHERE provider_type = 'PUBLIC' AND external_id = '392032';
UPDATE festival SET title = '[안성] 김정원과 친구들 20주년 기념 콘서트 <로맨틱 아틀리에>', content = '', place = '안성맞춤아트홀 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '392117';
UPDATE festival SET title = '허원경 클래식 기타 리사이틀 "Echoes of Iberia"', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '391889';
UPDATE festival SET title = '2026 최북미술관 반딧불축제 특별전 ''김순금의 반딧불이야'' 작가와의 대화', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396277';
UPDATE festival SET title = '창작ing 연극 <고쳐서 나가는 곳>', content = '1970년대 조선소 여성 노동자들의 이름과 시간, 시대를 견뎌낸 그 강인한 생명력이 오늘의 관객과 마주한다', place = '국립정동극장 세실' WHERE provider_type = 'PUBLIC' AND external_id = '392740';
UPDATE festival SET title = '연극 <방공호>', content = '', place = '나인진홀 1관 (1층)' WHERE provider_type = 'PUBLIC' AND external_id = '392330';
UPDATE festival SET title = '[부산] 제58회 BSO 정기연주회, 오충근 & BSO: 차라투스트라', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '392456';
UPDATE festival SET title = '황인정 & 권현진 피아노 듀오 리사이틀', content = '', place = '꿈의숲아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393807';
UPDATE festival SET title = '[대전] 어린이오페라 ''빨간 모자''', content = '', place = '복합문화공간 플랜에이' WHERE provider_type = 'PUBLIC' AND external_id = '392455';
UPDATE festival SET title = '조윤라발레단 <어제 같은 오늘 그리고 내일은 III>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '393691';
UPDATE festival SET title = '[2026 PLOT STAGE] 극단 광대 - 퓨전마당극 <나는 선인이다>', content = '', place = '극장 PLOT' WHERE provider_type = 'PUBLIC' AND external_id = '395425';
UPDATE festival SET title = '[경기 광주] 레오나르도 다빈치의 <판타스틱 애니멀즈> ', content = '', place = '광주시문화예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '392655';
UPDATE festival SET title = '김정원과 친구들 <로맨틱 아틀리에>', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '392671';
UPDATE festival SET title = '제8회 어텀실내악페스티벌 ''소리의 결 - Sound in Motion'' 세개의 그림자 : 브람스', content = '', place = '예술의전당 [서울]' WHERE provider_type = 'PUBLIC' AND external_id = '392673';
UPDATE festival SET title = '⟪흔적: 표면의 대화⟫', content = '<!-- wp:paragraph {"align":"center"} -->
<p class="has-text-align-center">유희 & 디트리히 끌링에 2인전<br>2026. 09. 09 - 09. 30</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20202,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/09/KakaoTalk_20260909_103022274_02.jpg" alt="" class="wp-image-20202" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>유희와 디트리히 끌링에는 도구가 지나간 자국을 지우지 않는다. 유희는 스퀴즈로 물감을 밀어내고, 끌링에는 톱과 끌로 나무의 표면을 파고든다. 밀어낸 자리와 깎아낸 자리에는 몸의 움직임과 그 움직임이 걸린 시간이 남는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>유희의 화면은 여러 방향으로 밀린 검정색 스퀴즈 자국이 먼저 장을 이루고, 그 위를 가느다란 흰색 또는 노란색 선이 가로지르거나 관통한다. 시선은 스퀴즈의 흐름을 따라가다 선에 막혀 멈추고, 그 멈춤에서 다른 경로를 찾는다. 획이 나아가려는 힘과 선이 끊어내는 힘이 맞물리며 화면의 리듬이 만들어진다. 밀린 물감은 쌓이지만 그 층은 두께를 감추지 않는다. 손의 압력이 어디서 세졌는지, 스퀴즈 도구의 각도가 어디서 꺾였는지를 자국의 농도와 끝자락이 그대로 알려준다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>디트리히 끌링에는 나무를 거칠고 대담하게 깎아 인간의 몸을 연상시키는 형상을 만든다. 작품은 크지 않은 두상이거나 반신상 내지 전신상이다. 실재하는 몸을 모델로 삼지 않고 상상으로 변형한 이 인간상은 나무와 인간 사이를 오가며 식물처럼 자라난 것처럼 보인다. 사람의 얼굴과 몸을 재현하고 있지만 온전한 사람의 모습은 아니다. 자르고 밀고 나간 자국은 붓질에 가까운 터치를 남긴다. 그 결이 뼈대와 근육, 살과 표정을 이루며 동세와 시선을 유인한다. 작가는 표면을 다듬지 않고 남겨둠으로써 재료가 변해온 과정을 시각적으로 증명한다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그런데 몸처럼 읽히던 이 표면은 몸의 구조와 맞지 않는다. 깊게 패인 자리는 근육이 두꺼운 곳이 아닌, 도구가 힘을 준 지점에 생긴다. 표면은 우리가 아는 몸을 덮지 않은 피부가 되고, 그래서 그의 조각은 인체보다 물체로 먼저 인지된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>두 표면은 반대 방향으로 만들어졌다. 유희는 얹으면서 자국을 남기고 끌링에는 덜어내면서 자국을 남긴다. 유희에게 흔적은 다음 시선을 부르는 리듬이 되고, 끌링에에게 흔적은 형상과 어긋나는 깊이가 된다. 관람자는 밀어낸 물감의 방향과 파고든 도구의 깊이를 따라가며 표면이 무엇을 드러내고 무엇을 감추는지 보게 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Yu Hee and Dietrich Klinge do not erase the marks left behind by their tools. Yu Hee pushes paint away with a squeegee, while Klinge carves into the surface of wood with a saw and chisel. The spaces where material has been pushed aside or carved away retain the physical movements of the artists and the time those movements took.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Yu Hee’s canvas is first grounded by black squeegee marks pushed in various directions, which are then crossed or pierced by thin white or yellow lines. The viewer’s gaze follows the flow of the squeegee only to be halted by a line, and from this pause, it seeks out another path. The advancing momentum of the stroke and the severing force of the line interlock, generating the rhythm of the canvas. Although the pushed paint accumulates, its layers do not conceal their thickness. The density and the edges of the marks clearly reveal where the pressure of the hand intensified and where the angle of the squeegee shifted.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Dietrich Klinge roughly and boldly carves wood to create figures reminiscent of the human body. His works take the form of modest-sized heads, busts, or full-body figures. Rather than modeling after actual physical bodies, these imaginatively transformed human figures appear to have grown like plants, oscillating between the realms of wood and human. While they represent human faces and bodies, they are not entirely intact human forms. The marks left by cutting and thrusting create textures akin to brushstrokes. These textures form the structural bones, muscles, flesh, and facial expressions, drawing in dynamic movement and the viewer''s gaze. The artist visually attests to the material''s transformation process by leaving the surface unpolished.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>However, this surface—which is read as a body—does not align with actual anatomical structures. Deeply gouged indentations appear not where muscles are thickest, but rather where the tool exerted the most force. The surface becomes a skin that does not cover the human body as we know it; thus, his sculptures are perceived first as objects rather than human figures.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The two surfaces are constructed in opposite directions. Yu Hee leaves marks by adding material, whereas Klinge leaves his by taking it away. For Yu Hee, these traces create a rhythm that guides the viewer''s next gaze; for Klinge, they create a depth that contradicts the physical form. By tracing the direction of the pushed paint and the depth of the carved tools, the viewer ultimately discovers what the surface reveals and what it conceals.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>⟪흔적: 표면의 대화⟫<br>유희 & 디히트리히 끌링에 2인전<br>2026. 09. 09(수) - 09. 30(수)<br>*일•월요일 휴무입니다.</p>
<!-- /wp:paragraph -->', place = '두루아트스페이스' WHERE provider_type = 'PUBLIC' AND external_id = '397408';
UPDATE festival SET title = '「담쟁이 창작소」 문화예술교육 프로그램 <사천을 기억하는 방법>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396675';
UPDATE festival SET title = '[강북문화재단] 익스트림 퍼포먼스 <인피니티 플라잉>', content = '', place = '강북문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '392701';
UPDATE festival SET title = 'A_PRO 아마추어 라이선스 뮤지컬 <긴긴밤>', content = '', place = '업스테이지(UP Stage)' WHERE provider_type = 'PUBLIC' AND external_id = '393903';
UPDATE festival SET title = '이세빈, 이채원 <흔들리는 작은 풍경 Where Small Things Shimmer>', content = '', place = '16아카이브' WHERE provider_type = 'PUBLIC' AND external_id = '397112';
UPDATE festival SET title = '안애순 컴퍼니 가족무용극 <어린 왕자>', content = '생텍쥐페리의 고전 <어린 왕자>를 안무가 안애순만의 감각적인 움직임과 환상적인 무대로 재해석한 가족무용극.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '393000';
UPDATE festival SET title = '창작악단 기획공연 <연주자 그리고 작곡가Ⅲ>', content = '2024년과 2025년 이은 세 번째 시리즈 공연으로 올해는 거문고, 가야금, 피리, 아쟁, 대금, 해금의 6명의 연주자가 직접 만들고 협연하는 작품이 관객들과 만납니다. 연주자가 곧 작곡가였던 전통 음악 시대의 창작 활동을 되살려 창작 국악의 영역을 넓히고 전통 음악의 미래를 그려봅니다.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '393103';
UPDATE festival SET title = '한화생명과 함께하는 예술의전당 11시 콘서트(9월)', content = '오페라 <박쥐> 서곡에서부터 생상스의 피아노 협주곡 제2번과 베토벤 로망스와 차이콥스키 교향곡 제5번에 이르기까지, 낭만적 선율로 가을 아침을 여는 국내 대표 마티네 콘서트', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393151';
UPDATE festival SET title = '[주워담는 클래식] ‘코렐리’라는 유산', content = '', place = '서울문화예술교육센터 서초 서울체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '396094';
UPDATE festival SET title = '아카데미 열정과 나눔 RE & NEW 프로젝트3 "대립과 화합 II"', content = '', place = '광림아트센터 장천홀' WHERE provider_type = 'PUBLIC' AND external_id = '389633';
UPDATE festival SET title = '국립심포니콘서트오케스트라 심야음악회 <별 헤는 밤, 별 둘>', content = '늦은 저녁, 클래식이 일상의 틈으로 스며드는 순간. 객석과 가까이 호흡하는 섬세한 앙상블의 울림, 곡 사이사이 더해지는 해설과 시 한 편의 낭독이 함께하는 공연', place = '세종예술의전당 3층 시크릿씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '393001';
UPDATE festival SET title = '연극 <나와 할아버지>', content = '', place = '예스24아트원 3관' WHERE provider_type = 'PUBLIC' AND external_id = '397033';
UPDATE festival SET title = '[용인] 뮤지컬 <그날들> ', content = '', place = '용인포은아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '395288';
UPDATE festival SET title = '민서 개인전 <ㅁㅜㄴㄷㅡㄱ>', content = '', place = '봄내극장 춘천미술관' WHERE provider_type = 'PUBLIC' AND external_id = '398159';
UPDATE festival SET title = '제2회 정병규 개인전 : ON & OFF 켜지고, 멈추고, 다시 움직이는 것들', content = '', place = '복합문화예술공간MERGE' WHERE provider_type = 'PUBLIC' AND external_id = '394949';
UPDATE festival SET title = '최방원 <눈동자 속의 계절>', content = '', place = '갤러리 스페이스포포' WHERE provider_type = 'PUBLIC' AND external_id = '396497';
UPDATE festival SET title = '박영성 <불편한 휴식>', content = '', place = 'M극장' WHERE provider_type = 'PUBLIC' AND external_id = '396321';
UPDATE festival SET title = '김보람 <관통시팔>', content = '', place = '성수아트홀(성수문화복지회관)' WHERE provider_type = 'PUBLIC' AND external_id = '389612';
UPDATE festival SET title = '2026 부평 특성화 문화예술교육 <예술교육랩> 참여자 모집', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '395594';
UPDATE festival SET title = '[인천] 제물포문화재단 창작뮤지컬 <켈로> ', content = '', place = '인천중구문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '395680';
UPDATE festival SET title = '[서울 강북] 어린이 베스트셀러 뮤지컬 <피터래빗> ', content = '', place = '꿈의숲아트센터 퍼포먼스홀' WHERE provider_type = 'PUBLIC' AND external_id = '393609';
UPDATE festival SET title = '제43회 순천팔마문화제', content = '', place = '남문터광장·문화의 거리 일원' WHERE provider_type = 'PUBLIC' AND external_id = '397098';
UPDATE festival SET title = '국가무형유산 종묘제례악 일무 전장 ''팔풍의 몸짓, 일무'' 열한번째 연작', content = '', place = '국립국악원 예악당' WHERE provider_type = 'PUBLIC' AND external_id = '394455';
UPDATE festival SET title = '국립민속국악원 <독갑이댁 수레노래>', content = '2026 창극 중심 세계음악극축제 국내초청작. 지리산이 품은 전설과 생명의 이야기! 남원다운 해학과 위로를 담은 창작 국악극', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '392781';
UPDATE festival SET title = '[용인] 음악동화 <조금은 특별한 피노키오>', content = '', place = '용인시문화예술회관 처인홀' WHERE provider_type = 'PUBLIC' AND external_id = '393927';
UPDATE festival SET title = '국립남도국악원 토요상설: 국악이 좋다, 우수작품 공모 선정작 <명창 박정욱의 배뱅이굿 완창>', content = '', place = '국립남도국악원 진악당' WHERE provider_type = 'PUBLIC' AND external_id = '395333';
UPDATE festival SET title = '[부산] 2026 앙상블 부산 “현의 물결” 시리즈: 동서남북 ', content = '', place = 'F1963' WHERE provider_type = 'PUBLIC' AND external_id = '395253';
UPDATE festival SET title = '프로젝트 솔로이스츠 제12회 정기연주회 "Brahms_Sounds of Youth"', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '390935';
UPDATE festival SET title = '피아니스트 고연경 & 오르가니스트 이예원 듀오 콘서트', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '394711';
UPDATE festival SET title = '연극 <나는 코다입니다>', content = '코다(CODA)로 살아온 도영의 이야기를 통해 농인·청인·코다의 경계를 넘어 서로를 이해하고 함께 살아가는 의미를 그린 베리어프리 연극', place = '경기아트센터 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '393169';
UPDATE festival SET title = '인천시립극단 제98회 정기공연 <배:웅>', content = '', place = '인천문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '393737';
UPDATE festival SET title = '미완의 낙원: Paradise in Progress 전시 연계 프로그램 <작가와의 만남>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '397103';
UPDATE festival SET title = '‘2026 고택종갓집 활용사업’ 꿈꾸는 고헌고택-가락으로 배우고 공예로 만나는 문화유산', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '398624';
UPDATE festival SET title = '제43회 인하오케스트라 정기연주회: Prélude', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393968';
UPDATE festival SET title = '[전주] 디즈니 & 지브리 OST 콘서트 ', content = '', place = '전북대학교 삼성문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '394013';
UPDATE festival SET title = '[화성] 제2회 화성특례시 남양성모성지 클래식 음악제, 국립합창단 & 강남심포니오케스트라 주페 ‘레퀴엠’', content = '', place = '남양성모성지 대성당' WHERE provider_type = 'PUBLIC' AND external_id = '395144';
UPDATE festival SET title = '강지영 & 정나영 피아노 듀오 리사이틀 Concert for 4 Hands', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390149';
UPDATE festival SET title = '[고양] 어느 멋진 날 ''아름다운 동행''', content = '', place = '고양어울림누리 별모래극장' WHERE provider_type = 'PUBLIC' AND external_id = '393704';
UPDATE festival SET title = '2026 금천 러닝 그라운드 파일럿 프로젝트 <시간 잇기 : 내 일과 내일> 참여자 모집', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '397257';
UPDATE festival SET title = '[1주차 화도읍] 남양주시립합창단 해설이 있는 음악회 <데어몬트>', content = '', place = '화도수동행정복지센터 천마홀(다목적공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '396171';
UPDATE festival SET title = '[강릉] 조선나이트 국악×디스코 Vol.2', content = '', place = '강릉아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '393939';
UPDATE festival SET title = '[2026 PLOT STAGE] 송지연 - 낭독쇼케이스 <Wharton>', content = '', place = '극장 PLOT' WHERE provider_type = 'PUBLIC' AND external_id = '395450';
UPDATE festival SET title = '대전광역시 서예진흥원 <2026 서예 역사문화기행>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394229';
UPDATE festival SET title = '9월 셋째 주 수요영화관 상영 안내 <세계의 주인>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '398029';
UPDATE festival SET title = '문학주간2026 ''곁눈질'' (아르코꿈밭극장)', content = '', place = '아르코 꿈밭극장' WHERE provider_type = 'PUBLIC' AND external_id = '397792';
UPDATE festival SET title = '문학주간2026 ''곁눈질'' (아르코예술극장)', content = '', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '397793';
UPDATE festival SET title = '한대식의 금야월명 네 번째 “가사(歌詞)를 공부하는 선비” 그리고 가곡(歌曲)과 시조(時調)', content = '', place = '서울돈화문국악당' WHERE provider_type = 'PUBLIC' AND external_id = '396962';
UPDATE festival SET title = '[강북문화재단] 2026 마티네 콘서트 <클래식 인 시네마>', content = '', place = '강북문화예술회관 강북진달래홀' WHERE provider_type = 'PUBLIC' AND external_id = '392733';
UPDATE festival SET title = '연극 <여행의 지도>', content = '', place = '나인진홀 1관 (1층)' WHERE provider_type = 'PUBLIC' AND external_id = '392331';
UPDATE festival SET title = '2026 산울림 고전극장 <헤라 아프로디테 아르테미스 - 리부트>', content = '', place = '산울림소극장' WHERE provider_type = 'PUBLIC' AND external_id = '397034';
UPDATE festival SET title = '9월 국회문화극장 <퍼펙트슛>', content = '', place = '국회의원회관' WHERE provider_type = 'PUBLIC' AND external_id = '396323';
UPDATE festival SET title = '[고양] 2026 아침음악나들이 4, 서영택 & 이승민 ', content = '', place = '고양어울림누리 어울림극장' WHERE provider_type = 'PUBLIC' AND external_id = '395017';
UPDATE festival SET title = '[마포문화재단] 제11회 M 클래식 축제 <소프라노 황수미 리사이틀>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '388200';
UPDATE festival SET title = '바리톤 안대현 & 피아니스트 김은진의 LIederabend Series Ⅳ', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '394600';
UPDATE festival SET title = '[인천] 줄타기x연극 <라인 - 두줄광대>', content = '', place = '인천동구문화체육센터' WHERE provider_type = 'PUBLIC' AND external_id = '395164';
UPDATE festival SET title = '경기필 마스터피스 시리즈 IV <베토벤 교향곡 7번>', content = '2026시즌 경기필하모닉 마스터피스 시리즈의 4번째 공연으로,지휘자 이얼과 피아노 백건우가 출연', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '393171';
UPDATE festival SET title = '[대전] 대전시립교향악단 마스터즈 시리즈 7, 말러 교향곡 제2번 ‘부활’', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '395013';
UPDATE festival SET title = '연극 <벚꽃동산>', content = '', place = '문학시어터' WHERE provider_type = 'PUBLIC' AND external_id = '393219';
UPDATE festival SET title = '경기도극단 기획공연 - 연극 <버닝:타오르는 삶>', content = '''제4회 창작희곡공모 대상 수상작''. 학교 교육의 필수인력이지만 비정규직으로 고용되어 불안정 속에 방관된 급식조리사들의 이야기! On Stage and Remember. 우리가 기억해야 할 이들의 이야기, 무대로 만난다!', place = '경기아트센터 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '393172';
UPDATE festival SET title = '피지컬 시어터 <네이처 오브 포겟팅> : 연극열전10_열 번째 작품', content = '', place = '세종문화회관 세종S씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '393731';
UPDATE festival SET title = '청운문학도서관 2026 <별 헤는 밤, 책 읽는 밤> 이가희 작가와의 만남', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396317';
UPDATE festival SET title = '국립창극단 <귀토-토끼의 팔란>', content = '판소리 <수궁가>를 현대적으로 재해석한 작품. 수궁가 그 이후, 토끼 아들의 육지 탈출기를 그린 현대 창극의 정수.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '393002';
UPDATE festival SET title = '신영진 작품전 <﻿낮달 - 압록강의 기억>', content = '', place = '공립 인제내설악미술관' WHERE provider_type = 'PUBLIC' AND external_id = '398297';
UPDATE festival SET title = '제22회 춘천현대사생회展 <2026 봄내 풍경 사랑展>', content = '', place = '봄내극장 춘천미술관' WHERE provider_type = 'PUBLIC' AND external_id = '399717';
UPDATE festival SET title = '이은경 안무가 <사알-짝, 여기까지만>', content = '', place = '플랫폼 엘' WHERE provider_type = 'PUBLIC' AND external_id = '396487';
UPDATE festival SET title = '[원주] 우리소리극 <까만 인절미> ', content = '', place = '원주치악예술관' WHERE provider_type = 'PUBLIC' AND external_id = '394660';
UPDATE festival SET title = 'ACC 초이스 이자람 판소리 <눈, 눈, 눈>', content = '', place = '국립아시아문화전당 극장2' WHERE provider_type = 'PUBLIC' AND external_id = '393798';
UPDATE festival SET title = '[서울] 한샘블 BGM 시리즈 Ⅰ<자연을 담다>', content = '', place = '서울돈화문국악당' WHERE provider_type = 'PUBLIC' AND external_id = '396229';
UPDATE festival SET title = '만나필하모닉 오케스트라 ''조성의 끝에선 가을낭''', content = '', place = '소월아트홀(성동문화회관)' WHERE provider_type = 'PUBLIC' AND external_id = '395022';
UPDATE festival SET title = '[서울] 경기필 마스터피스 시리즈 IV <베토벤 교향곡 7번>', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '395305';
UPDATE festival SET title = '서빛마루문예회관 명작콘서트 9월 Opera On Stage ''버섯피자''', content = '', place = '서빛마루문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '395893';
UPDATE festival SET title = '2026 (재)광명문화재단 기획공연 <젤리피쉬>', content = '', place = '광명시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '394756';
UPDATE festival SET title = '2026 남해바래길 월정기걷기 ''작은 소풍'' 9월', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '393305';
UPDATE festival SET title = '2026 해움·새들 오픈스튜디오 #4《문을 괴는 말들》', content = '', place = '일산호수공원 고양시 예술창작공간 해움새들' WHERE provider_type = 'PUBLIC' AND external_id = '397495';
UPDATE festival SET title = '8th Altimeets - 존재를 움직이는 힘', content = '무용단알티밋의 여덟 번째 정기공연! 인간을 움직이는 내면과 외부의 힘을 두 안무가의 서로 다른 시선과 움직임으로 풀어내는 새로운 무대', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '393117';
UPDATE festival SET title = '[부천] Autumn Echoes: Cello & Harp', content = '', place = '부천아트센터 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '397696';
UPDATE festival SET title = '<완창판소리> 9월', content = '판소리 다섯 바탕을 한 명의 소리꾼이 처음부터 끝까지 펼쳐 보이는, 오랜 전통의 힘과 묵직한 감동을 느낄 수 있는 공연', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392775';
UPDATE festival SET title = '[인천] Wine & Music Night, 그 시절 우리가 사랑했던 7080 LEGENDS ', content = '', place = '엘림아트센터 챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '395663';
UPDATE festival SET title = '[고양] 마임배우 류성국의 ''빈손으로 드리는 이야기''', content = '', place = '이앤아이 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '397678';
UPDATE festival SET title = '[김근태기념도서관] TEAM낙원장×김근태기념도서관 9월 오픈도서관 <당신의 왜?>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '397200';
UPDATE festival SET title = '2026 문화예술교육 활성화 사업 <예술 그리고, 전통> 「단아하고 청아하게, 단청」', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396681';
UPDATE festival SET title = '국가무형유산 보유자작품전 <궤적 TRACE>', content = '', place = '국립무형유산원' WHERE provider_type = 'PUBLIC' AND external_id = '399971';
UPDATE festival SET title = '<낙원에 갇힌 날들, 하와이 포로수용소 한인 포로의 기록>', content = '', place = '한국이민사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '400753';
UPDATE festival SET title = '음악극 <섬: 1933~2019>', content = '', place = '국립정동극장' WHERE provider_type = 'PUBLIC' AND external_id = '394717';
UPDATE festival SET title = '광명심포니오케스트라 평화콘서트: "평화"잇다', content = '', place = '광명시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '397842';
UPDATE festival SET title = '[2주차 다산아트홀] 남양주시립합창단 해설이 있는 음악회 <데어몬트>', content = '', place = '다산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '396237';
UPDATE festival SET title = '[부산] 부산시립교향악단 기획음악회 <세계 클래식 음악산책Ⅲ>', content = '', place = '부산문화회관 중극장' WHERE provider_type = 'PUBLIC' AND external_id = '395136';
UPDATE festival SET title = '국립부산과학관 2026년도 추석맞이 민속놀이 체험행사 ''쿵떡쿵떡, 한가위 놀이장터''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '398431';
UPDATE festival SET title = 'YONSEI ARTS WEEK 연세아츠위크 Page & Stage', content = '', place = '연세대학교 미래캠퍼스 일대' WHERE provider_type = 'PUBLIC' AND external_id = '400333';
UPDATE festival SET title = '‘2026 꿈의 극단 부평’  어린이 연극교육 프로그램', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '398417';
UPDATE festival SET title = '[수원] 2026 유네스코 · 경기도 세계무형문화유산축전 ', content = '', place = '경기아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '397726';
UPDATE festival SET title = 'MU&A 스튜디오 기획 시리즈, 피아니스트 노예진 리사이틀', content = '', place = '뮤직앤아트스튜디오' WHERE provider_type = 'PUBLIC' AND external_id = '399422';
UPDATE festival SET title = '[울산] 아트 온 스크린 - 크리스토퍼 에센바흐 & KBS 교향악단', content = '', place = '울산중구문화의전당 함월홀(2층)' WHERE provider_type = 'PUBLIC' AND external_id = '396184';
UPDATE festival SET title = '구석구석 문화가 있는 날 <모여라 책 놀이터>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400082';
UPDATE festival SET title = '[2026 PLOT STAGE] 하이웨이브 - 연극 <파도를 달리는, 빛으로 흐르는>', content = '', place = '극장 PLOT' WHERE provider_type = 'PUBLIC' AND external_id = '395454';
UPDATE festival SET title = '제6회 여주인공 페스티벌, <늙은 여자, 아쿨리나>', content = '', place = '미마지아트센터 물빛극장' WHERE provider_type = 'PUBLIC' AND external_id = '396181';
UPDATE festival SET title = '뮤지컬 <늦봄의 길> 갈라 콘서트', content = '', place = '광명시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '397174';
UPDATE festival SET title = '국립합창단 제209회 정기연주회 <베토벤 & 슈베르트>', content = '베토벤의 깊은 성찰과 슈베르트의 따뜻한 위로, 두 거장의 미사곡으로 만나는 장대한 합창의 울림', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393259';
UPDATE festival SET title = '<2026년 국가무형유산 이수자 지원 사업 공연> 사이, 소리', content = '', place = '한국문화의집 KOUS' WHERE provider_type = 'PUBLIC' AND external_id = '398726';
UPDATE festival SET title = '경기시나위 <해금가락을 爲하다>', content = '', place = '서울돈화문국악당' WHERE provider_type = 'PUBLIC' AND external_id = '396691';
UPDATE festival SET title = '큐레이터와의 대화 <한국의 영산, 계룡산>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '398691';
UPDATE festival SET title = '한국예술종합학교 수요영화관 <이처럼 사소한 것들>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400083';
UPDATE festival SET title = '국토발전전시관 정기강연 ''이 땅 위에 우리 이야기''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '397194';
UPDATE festival SET title = '2026년 남북문화교류 교육 <북한의 전통공연예술과 민족음악>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400462';
UPDATE festival SET title = '연극 <탠덤>', content = '', place = '여행자극장' WHERE provider_type = 'PUBLIC' AND external_id = '399245';
UPDATE festival SET title = '[대전] 김우경 & 유신희 & 정다은 성악 트리오 리사이틀', content = '', place = '대전예술의전당 앙상블홀' WHERE provider_type = 'PUBLIC' AND external_id = '396591';
UPDATE festival SET title = '국회 개방 정오의 콘서트 <10월 국회 버스킹>', content = '', place = '국회사무처' WHERE provider_type = 'PUBLIC' AND external_id = '400086';
UPDATE festival SET title = '수림뉴웨이브 2026 - 최태영 <비사비죽>', content = '', place = '김희수아트센터 SPACE 1' WHERE provider_type = 'PUBLIC' AND external_id = '392747';
UPDATE festival SET title = '프랑스 스트라스부르 국립극장 ''라크리마''', content = '유럽 연극계를 사로잡은 화제작, 프랑스 스트라스부르 국립극장 <라크리마> 한국 초연. 화려한 패션 산업 이면의 현실과 장인정신의 가치를 깊이 있게 그려낸 작품.', place = '성남아트센터 오페라하우스' WHERE provider_type = 'PUBLIC' AND external_id = '391328';
UPDATE festival SET title = '강남문화재단 제1021회 목요예술무대 <여섯 번째 파장, 유리아>', content = '', place = '강남씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '397862';
UPDATE festival SET title = '[대학로] 소리없는 정원', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '396845';
UPDATE festival SET title = '박성미 & 이미진 피아노 듀오 리사이틀 ''교과서 속 클래식''', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '395635';
UPDATE festival SET title = '비올리스트 강동엽 보웬 전곡 시리즈 II "The English Rachmaninoff"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '394941';
UPDATE festival SET title = '춘천시립국악단 제10회 정기공연 <춘천풍류>', content = '', place = '국립국악원 예악당' WHERE provider_type = 'PUBLIC' AND external_id = '399138';
UPDATE festival SET title = '탱고 부에노스아이레스', content = '춘천에서 경험하는 탱고음악의 정수! 부에노스아리레스의 정통 탱고를 경험할수 있는 단한번의 기회! 아르헨티나 정통 탱고악단 ''탱고 바르도''와 ''미스테리오사 부에노스아이레스''와 함께 정상급 탱고댄스팀, 뮤지컬배우 배해선이 선사하는 탱고음악의 정수!', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '393095';
UPDATE festival SET title = '사진전 <우리는 자연스러웠고 거침없었다>', content = '', place = '와이아트갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '399977';
UPDATE festival SET title = '[원주 갤러리 원] 유시라 초대개인전 "그것을 묶음으로 : Birth –Death"', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '400771';
UPDATE festival SET title = '2026 장위공 서희 외교문화제 <서희, K-외교를 말하다>', content = '', place = '서희테마파크 일원' WHERE provider_type = 'PUBLIC' AND external_id = '397104';
UPDATE festival SET title = '[인천] 웰메이드 연극 <내 모든 걸 >', content = '', place = '계양문화회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '396881';
UPDATE festival SET title = '[화성] 창극 <흥보 마누라 이혼소송 사건>', content = '', place = '반석아트홀(동탄복합문화센터)' WHERE provider_type = 'PUBLIC' AND external_id = '396880';
UPDATE festival SET title = '지브리&디즈니 영화음악 FESTA(10/3)', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '396936';
UPDATE festival SET title = '제63회 수원화성문화제 ''새빛홍민''', content = '', place = '수원화성 일원' WHERE provider_type = 'PUBLIC' AND external_id = '399329';
UPDATE festival SET title = 'Minor Beings 숨은 존재들', content = '몸, 교란 그리고 서식지 <숨은 존재들 Minor Beings> 은 몸을 독립적이고 완결된 존재가 아닌, 다양한 존재들과 관계를 맺으며 끊임없이 변화하는 생태로 탐구하는 안무 작업이다. 작품은 폐허를 단순히 버려진 공간이 아니라, 인간의 질서가 느슨해진 자리에서 서로 다른 존재들이 새로운 관계를 만들어 가는 생태로 바라본다. 이러한 시선을 몸으로 확장하며, 몸 역시 하나의 개체가 아닌 관계의 장으로 다시 질문한다. 공연은 알아차림, 안으로 말림, 교란 의 과정을 따라 전개된다. 몸은 익숙한 감각과 질서를 잠시 유보하고, 다른 존재의 시간과 리듬을 받아들이기 위해 자신의 중심을 느슨하게 만든다. 그 틈으로 서로 다른 감각과 호흡이 스며들고, 몸은 불안정성과 불확정성 속에서 관계를 맺으며 새로운 존재 방식으로 변형된다. 이 작품에서 서식지는 고정된 장소가 아니라, 서로 다른 존재들이 영향을 주고받으며 함께 변화하는 관계의 상태이다. <숨은 존재들>은 몸을 인간만의 것이 아닌, 다양한 존재들이 머물고 관계를 생성하는 살아 있는 생태로 제안한다.', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '393147';
UPDATE festival SET title = '심리스릴러 연극 <베팅>', content = '', place = '극장 봄 (봄소극장) 극장 봄' WHERE provider_type = 'PUBLIC' AND external_id = '396902';
UPDATE festival SET title = '뮤지컬 <당신의 과녁> 리딩 쇼케이스', content = '', place = '소월아트홀(성동문화회관)' WHERE provider_type = 'PUBLIC' AND external_id = '399896';
UPDATE festival SET title = '[전시] 박승일 유화 전시 ''사람과 숲''', content = '', place = '문화공간 스페이스다온' WHERE provider_type = 'PUBLIC' AND external_id = '400682';
UPDATE festival SET title = '송휘석 & 이영주의 피아노 듀오 리사이틀', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '397863';
UPDATE festival SET title = '⟪John Doe – The Unnamed⟫', content = '<!-- wp:paragraph -->
<p><strong>부제: 익명적 인물 ‘존도’와 현대 사회의 은유</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>‘존 도(John Doe)’는 영어권에서 신원을 알 수 없거나 이름을 모르는 사람에게 임시로 쓰는 이름이다. 키미작의 화면에 등장하는 인물들도 누구인지 밝혀지지 않은 채 등장한다. 얼굴의 세부는 지워져 있고 눈과 입이 있어야 할 자리는 비어 있다. 우리는 이들의 이름도 표정도 알 수 없다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>얼굴이 사라지면 관람자의 시선은 몸으로 옮겨 간다. 팔을 뻗는 방향, 어깨의 기울기, 몸과 몸 사이의 거리가 인물의 감정과 처지를 전한다. 존도를 보는 것은 관람자가 인물 하나하나를 읽어낸다기보다 인물이 처한 상황을 해석하는 것에 더 가깝다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 이 인물들에게 수구 모자를 씌운다. 수구 경기에서 선수들은 물 위로 머리만 내놓은 채 같은 모자를 쓰고 움직인다. 누가 누구인지 가려내기 어렵고 공은 쉴 새 없이 이 손에서 저 손으로 건너간다. 작가는 이 장면에서 오늘날 현대 사회의 관계를 들여다본다. 우리는 서로를 충분히 인지하지 못한 채 공을 주고받듯 관계성을 맺는다. 때로는 스스로 얼굴을 감추고 무리 속에 섞이기를 택한다. 존도는 그렇게 주체적인 이름 없이 살아가는 우리의 모습이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>존도의 손과 발은 몸에 비해 작다. 손과 발은 실제로 일을 하는 몸의 부분이다. 성과와 이력을 부풀려 내보이는 사회에서 그 성과를 만들어 낸 노동은 점점 작게 취급된다. 작은 손발은 이 불균형을 꼬집는다. 작가는 예술을 천재성이나 영감으로만 설명하는 태도와도 거리를 둔다. 그림은 매일의 손노동이 쌓여 완성된다. 이름 없는 인물의 작은 손은 드러나지 않는 노동을 암시한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>수구라는 종목을 고른 이유도 여기에 있다. 많은 스포츠가 한 명의 스타로 기억되지만 수구는 팀 전체가 함께 움직이지 않으면 경기가 성립하지 않는다. 화면 속 선수들 가운데 누구도 주인공이 되지 않는다. 그들이 서로를 향해 몸을 기울이며 만드는 흐름이 그림의 중심에 선다. 이를 기반으로, 초기 서커스 연작에서 여러 사람이 함께 균형을 유지해야만 성공할 수 있는 상황을 보여준다. 이후 스포츠 연작에서 그 균형의 개념을 보다 일상적인 장면으로 확장시킨다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이 인물들은 린넨 위에 그려진다. 거친 결을 지닌 천은 물감을 머금으며 은은하게 스며 나오는 듯한 발색을 구현한다. 물감을 겹겹이 쌓기보다 하나의 층으로 담백하게 펼쳐놓은 화면의 존도들은 튀지 않고 주변에 섞여 든다. 재료의 성질이 익명의 인물이 놓인 처지와 비슷한 결을 가진다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>⟪John Doe – The Unnamed⟫ 에서 관람자는 이름 없는 인물들과 마주한다. 화면 속 누구에게도 이름을 붙일 수 없듯 우리도 매일 스치는 대부분의 사람에게 이름 없는 존재로 지나간다. 그림을 보고 돌아서는 관람자도 누군가에게는 얼굴이 지워진 인물로 남는다. 화면 앞에 선 관람자 역시 한 명의 존도다.</p>
<!-- /wp:paragraph -->', place = '두루아트스페이스' WHERE provider_type = 'PUBLIC' AND external_id = '401508';
UPDATE festival SET title = '대전광역시 서예진흥원 <2026 서예 인문학 특강>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '395629';
UPDATE festival SET title = '제14회 한국남성합창단 & 도쿄리더타펠 합동 연주회', content = '', place = '세종문화회관 세종대극장' WHERE provider_type = 'PUBLIC' AND external_id = '397647';
UPDATE festival SET title = '마티네 콘서트: 김영하 작가의 <여행의 이유, 그리고 음악> Ⅳ', content = '김영하 작가의 프랑스 여행 이야기와 클래식 연주가 어우러지는 고품격 렉처 콘서트', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '392885';
UPDATE festival SET title = '예술이야 <하나린주간보호소>', content = '', place = '애니메이션박물관' WHERE provider_type = 'PUBLIC' AND external_id = '402115';
UPDATE festival SET title = '한국예술종합학교 수요영화관 <콘클라베>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '401042';
UPDATE festival SET title = '2026 구석구석 문화가 있는 날 <구석구석 찾아가는 영화관>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '401032';
UPDATE festival SET title = '2026 북(BOOK)돋는 양양 _ 인문학 클래스 <이호선 교수>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '399311';
UPDATE festival SET title = '<함께 양양> ''함께 요리 - 우리 집 식탁 이야기''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '399643';
UPDATE festival SET title = '[마포문화재단] [2026 M 초이스] 연극 <욕망이라는 이름의 전차> ', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '393353';
UPDATE festival SET title = '[파주] 이지훈과 함께하는 음악여행: 프랑스 & 독일 ', content = '', place = '솔가람아트홀 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '397864';
UPDATE festival SET title = '경기 심포닉 윈드오케스트라 제5회 정기연주회 ''Song of Our Life 음악, 추억 그리고 삶''', content = '', place = '과천시민회관 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '396415';
UPDATE festival SET title = '정순민 <감정찾기놀이>', content = '', place = '갤러리 스페이스포포' WHERE provider_type = 'PUBLIC' AND external_id = '400275';
UPDATE festival SET title = '더블빌:시나위', content = '각 세대를 대표하는 두 안무가가 서로 다른 감각과 스타일로 전통음악 ''시나위''를 춤으로 풀어내며, 한국 창작춤의 새로운 패러다임을 제시한다.', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392830';
UPDATE festival SET title = '[용산문화재단] 릴레이 상영전 <용산 필름 인사이드>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '401531';
UPDATE festival SET title = '인천연극주간 연극 <바리 다시 피다>', content = '', place = '문학시어터' WHERE provider_type = 'PUBLIC' AND external_id = '400208';
UPDATE festival SET title = '조윤정 바이올린 독주회 “Ysaÿe and His Circle”', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '395837';
UPDATE festival SET title = 'Terrain Vague 테란바그: 루트 룩셈부르크 & 김신욱', content = '', place = '갤러리JJ' WHERE provider_type = 'PUBLIC' AND external_id = '402459';
UPDATE festival SET title = '피아니스트 김선주 & 문세희 듀오 콘서트', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401299';
UPDATE festival SET title = '제21회 임산부의 날 기념 공연 <최고맘을 위한 태교음악회>', content = '', place = '서귀포예술의전당 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '399319';
UPDATE festival SET title = '아리랑 코러스 서울 2026 정기연주회 "Song of Arirang"', content = '', place = '성남아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '398566';
UPDATE festival SET title = '[인천] 낭만주의 거장, 차이코프스키 & 라흐마니노프', content = '', place = '인천학생교육문화회관 싸리재홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '400857';
UPDATE festival SET title = '2026 인천아트플랫폼 <창작스튜디오 프로젝트> 시민참여 워크숍 10-11월', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '399620';
UPDATE festival SET title = '[마포문화재단] 마포 공방 작가들과 함께하는 2026년 제1회 <공방전>', content = '', place = '마포아트센터 앞 광장' WHERE provider_type = 'PUBLIC' AND external_id = '398899';
UPDATE festival SET title = '수집가들의 산책 : Collectors'' Walk', content = '<!-- wp:paragraph -->
<p>히든엠갤러리는 오는 10월 10일부터 11월 7일까지 윤종석 작가와 베를린을 기반으로 활동하는 일본 작가 Ken’ichiro Taniguchi의 2인전 <수집가들의 산책 : Collectors'' Walk>를 개최한다. 이번 전시는 서로 다른 장소를 거닐며 그곳에서 우연히 마주한 풍경과 흔적을 수집해온 두 작가의 작업을 소개한다. 윤종석은 여행지에서 만난 풍경과 사물, 그 순간에 남겨진 감각을 기록한다면, Taniguchi는 도시의 도로와 벽에 생겨난 균열과 손상에 주목한다. 서로 다른 대상을 바라보는 두 작가의 시선은 일상적인 풍경과 흔적을 새롭게 발견하고, 이를 각자의 조형 언어로 변화시킨다는 점에서 만난다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>윤종석의 작업은 여행을 통해 마주한 풍경과 사물, 그리고 그 안에서 경험한 감각을 기록하는 일에서 출발한다. 작가에게 여행은 낯선 장소를 경험하는 동시에, 평소와는 다른 시선으로 주변을 바라보게 하는 시간이다. 익숙한 환경에서라면 무심히 지나쳤을 장면들도 낯선 곳에서는 새롭게 다가오고, 특정한 색과 형태, 사물의 배치가 유난히 선명하게 기억되기도 한다. 작가는 여행 중 마주한 풍경을 눈앞에 보이는 모습 그대로 옮기기보다, 그곳에서 무엇을 발견하고 어떤 인상을 받았는지를 자신의 조형 언어로 기록한다. 그렇게 작품은 특정 장소의 재현을 넘어, 한 장소를 경험한 시선과 감각이 남긴 기록이 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시를 위해 윤종석은 홋카이도에 머물며 새로운 풍경과 사물들을 관찰하고 이를 바탕으로 그안에서 발견한 사물이나 장면들을 작품에 담았다. 작가는 홋카이도 상공에서 내려다본 땅의 풍경을 인상적으로 기억한다. 가지런하게 정돈된 농경지는 넓게 펼쳐져 있었고, 연한 녹색의 들판 사이로 드러난 황토빛 붉은 흙은 풍경에 선명한 대비와 긴장감을 만들어냈다. 상공에서 바라본 풍경은 개별적인 사물의 형태를 넘어 땅의 구조와 색채가 이루는 전체적인 장면으로 다가온다. 한편 홋카이도에 머무는 동안 곳곳에서 마주한 사물들은 또 다른 방식으로 작가의 시선에 포착된다. 이번 전시에서 선보이는 15점의 드로잉을 비롯한 신작에는 넓게 펼쳐진 풍경의 인상과 여행 중 개별적으로 발견한 대상들이 각기 다른 방식으로 담겨 있다. 전체적인 풍경을 바라보는 시선과 눈앞의 사물에 가까이 다가가는 시선은 여행이라는 하나의 경험 안에서 서로 다른 기록으로 남는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>윤종석의 작업에서 여행은 눈앞의 풍경을 기록하는 데 그치지 않는다. 작가는 그곳에서 마주한 장면과 사물에 주목하고, 그로부터 받은 인상을 자신만의 조형 언어로 풀어낸다. 여행지에서 마주한 장면은 그 순간의 경험과 함께 기억되지만, 작품으로 옮겨지는 과정에서 다시 선택되고 구성된다. 어떤 풍경은 전체적인 색과 형태의 인상으로 남고, 어떤 사물은 주변과 구별되는 모습으로 기억된다. 그렇게 수집된 장면들은 하나의 장소를 설명하는 정보가 아니라, 그곳에서 보낸 시간과 시선이 축적된 기록이 된다. 작가의 작업은 여행지의 풍경을 다시 보여주는 동시에, 한 장소가 개인의 감각을 통과하며 어떻게 서로 다른 이미지로 남을 수 있는지를 보여준다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Ken’ichiro Taniguchi는 도시의 도로와 벽에 생겨난 균열과 움푹 팬 흔적을 관찰하고 수집해 왔다. 작가는 이러한 흔적을 일본어 동사 ‘헤코무(heko-mu)’에서 파생한 ‘헤코미(hecomi)’라고 부른다. 헤코무는 사물의 표면이 물리적으로 움푹 들어간 상태를 뜻하는 동시에, 감정적으로 침체되거나 우울한 상태를 의미하기도 한다. Taniguchi가 주목하는 것은 인공적으로 만들어진 도시의 표면에 자연스럽게 생겨난 균열과 손상이다. 일반적으로 이러한 흔적은 낡고 더러운 것, 복구하거나 감춰야 할 결함으로 여겨진다. 그러나 작가는 그 안에서 고유한 형태와 표정을 발견한다. 손상된 표면을 단순히 결함으로 바라보는 대신, 그 형태 자체를 세심하게 관찰하면 매력과 강인함, 슬픔을 비롯한 다양한 특성이 드러난다고 본다. 그의 작업은 우리가 도시의 일상적인 표면에서 무엇을 보고, 무엇을 지나쳐 왔는지에 관한 질문에서 출발한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2000년부터 이어온 헤코미 작업에서 Taniguchi는 세계 여러 도시의 도로와 벽을 관찰하며 마음에 드는 형태를 수집하고, 이를 ‘스톡 형태(stock shapes)’로 기록해 왔다. 현재까지 약 50개국에서 수집한 600여 개의 헤코미는 작가가 지속적으로 탐구해 온 형태의 아카이브를 이룬다. 그러나 수집된 흔적은 원래의 장소를 기록하는 데 머물지 않는다. 작가는 이를 드로잉과 지도 형식의 배열, 입체 조각 등 다양한 방식으로 변환하며 형태가 지닌 가능성을 탐구한다. 도시의 표면에서 우연히 발생한 균열은 작가의 관찰과 개입을 거치면서 본래의 장소에서 분리되고, 새로운 조형적 존재로 드러난다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이러한 변환 과정은 작가의 여러 작업에서 구체적으로 나타난다. Taniguchi는 수집한 헤코미의 형태를 기록하고 배열하며, 이를 새로운 조형적 구조로 발전시켜 왔다. ‘Hecomi Maps’ 시리즈에서는 각각의 형태를 일정한 방식으로 배열해 서로 비교하고 관찰할 수 있도록 한다. 개별적인 흔적들은 하나의 도감처럼 펼쳐지며, 저마다 다른 윤곽과 형태가 지닌 차이를 드러낸다. 반면 ‘Hecomi Fitting’ 시리즈에서는 재활용 압축 PVC 판에서 헤코미의 형태를 오려내어 실제 균열에 다시 끼워 넣는다. 선명한 노란색의 인공적인 소재와 도시 표면의 유기적인 균열이 만나면서, 결함으로 여겨지던 흔적은 밝고 생동감 있는 존재로 변화한다. 작가에게 이러한 과정은 균열을 단순히 감추거나 복구하는 것이 아니라, 그 형태를 존중하고 새로운 방식으로 드러내는 조형적 행위다. 헤코미의 형태를 다루는 작가의 관심은 평면에서 입체로 확장된다. ‘Hecomi Study’ 시리즈에서 형태를 여러 부분으로 나누고 경첩을 이용해 연결한 뒤, 접고 펼치는 과정을 통해 가장 적절한 입체적 형태를 찾아간다. 평면의 윤곽은 접히고 움직이면서 공간을 차지하는 조각으로 변화하며, 고정된 하나의 형태에 머물지 않고 다양한 방식으로 재구성된다. 장난감처럼 움직일 수 있는 이 조각들은 헤코미의 형태를 반복해서 탐구하고 변형하는 과정 자체를 작업의 일부로 만든다. 도시의 표면에서 우연히 발견한 작은 흔적은 이처럼 관찰과 기록, 변형과 재구성의 과정을 거치며 새로운 조형적 가능성을 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>최근 Taniguchi의 관심은 개별적인 균열에서 도시 전체를 바라보는 시점으로 확장되고 있다. ‘City Study Series’에서 작가는 도시를 공중에서 내려다보는 관점으로 탐구하며, 미시적인 형태와 거시적인 도시 구조 사이를 오가는 시선에 주목한다. 도시의 표면에서 발견한 작은 흔적을 관찰하던 시선이 이제는 그것들이 자리한 공간 전체로 이동하는 것이다. 개별적인 균열과 도시의 구조는 서로 분리된 대상이 아니라, 서로 다른 규모에서 도시를 이해하게 하는 장면으로 연결된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시에서 선보이는 공중 설치 작업 ‘City Study for Seoul, Korea’는 이러한 관심을 서울이라는 장소로 확장한다. 도시의 표면에서 흔적을 수집해 온 작가는 이번 작업에서 서울을 대상으로 새로운 조형적 탐구를 이어간다. 공중에 매달린 설치는 작품을 익숙한 지면의 맥락에서 벗어나 바라보게 하며, 관람자가 작품과 공간의 관계를 새롭게 인식하도록 한다. 이는 도시의 표면에서 발견한 형태를 다른 위치와 시선 속에 놓음으로써, 우리가 장소를 바라보는 방식 자체를 환기하는 시도이기도 하다. 개별적인 흔적에서 출발한 작가의 관심이 도시 전체를 바라보는 시점으로 확장되는 가운데, 이번 신작은 특정한 도시를 관찰하고 그 구조를 조형적으로 탐구하는 작업의 새로운 국면을 보여준다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>두 작가의 작업은 서로 다른 장소와 대상에서 출발하지만, 그 안에는 공통으로 발견과 관찰의 과정이 놓여 있다. 윤종석은 여행지에서 마주한 풍경과 사물에 주목하고, 그 순간의 감각을 작품으로 기록한다. Taniguchi는 도시의 표면에 남겨진 균열을 발견하고, 그 형태를 추출해 새로운 조형적 존재로 변환한다. 한 작가가 여행 중 만난 풍경을 감각과 기억의 기록으로 남긴다면, 다른 작가는 도시의 흔적을 수집하고 재구성하며 그 안에 잠재된 형태의 가능성을 드러낸다. 두 작가가 수집하는 대상은 다르지만, 모두 익숙한 세계를 당연하게 지나치지 않고 자신의 시선으로 다시 바라보는 데서 작업을 시작한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>또한 두 작가의 작업은 장소를 바라보는 시선의 거리에서도 흥미로운 관계를 형성한다. 윤종석의 신작에는 상공에서 내려다본 넓은 풍경과 여행 중 가까이에서 마주한 사물들이 함께 놓인다. Taniguchi의 작업 역시 개별적인 균열의 형태를 관찰하는 데서 출발해 도시 전체를 바라보는 시점으로 확장된다. 서로 다른 맥락에서 출발한 두 작가의 작업은 가까이 들여다보는 시선과 멀리서 전체를 바라보는 시선이 한 장소를 이해하는 서로 다른 방식임을 보여준다. 멀리서 풍경을 바라볼 때는 전체를 이루는 구조가 드러나고, 가까이 다가갈 때는 그 안에 자리한 작은 형태와 흔적이 눈에 들어온다. 이처럼 두 작가의 작업은 장소를 하나의 고정된 이미지로 제시하기보다, 여러 거리와 시선 속에서 새롭게 발견되는 대상으로 바라보게 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><수집가들의 산책 : Collectors'' Walk>에서 산책은 단순히 장소를 이동하는 행위가 아니다. 그것은 주변을 관찰하고, 우연히 마주한 장면에 머물며, 그 안에서 발견한 것을 자신만의 방식으로 기록하는 과정이다. 윤종석에게 여행은 풍경과 사물을 통해 새로운 감각을 발견하는 시간이고, Taniguchi에게 도시는 평범하게 지나칠 수 있는 흔적을 찾아내는 장소다. 그렇게 발견된 것들은 작품으로 옮겨지면서 원래의 장소에서 경험했던 순간을 넘어 새로운 의미를 만들어낸다. 수집은 지나간 장면을 보존하는 일이면서 동시에 그것을 다른 방식으로 다시 바라보게 하는 일이 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>우리는 매일 수많은 풍경과 흔적을 마주하지만, 그 모든 것을 기억하거나 자세히 들여다보지는 않는다. 익숙한 풍경은 배경이 되고, 작은 균열은 손상으로 여겨져 시선에서 멀어진다. 그러나 잠시 걸음을 늦추고 바라보면, 무심히 지나쳤던 장면 안에서도 저마다의 형태와 시간이 드러난다. 두 작가가 각자의 여정에서 발견하고 수집한 것들은 바로 그러한 시선의 변화에서 비롯된다. 이번 전시가 익숙한 풍경과 일상의 흔적을 조금 다른 거리에서 바라보고, 그 안에 남겨진 새로운 장면들을 발견하는 시간이 되기를 바란다.</p>
<!-- /wp:paragraph -->', place = '히든엠갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '402099';
UPDATE festival SET title = '2026 은평에브리바디페스티벌 <오!마이라이프 무브먼트 씨어터-과일·악기·그림책>', content = '', place = '은평문화예술회관 숲속극장' WHERE provider_type = 'PUBLIC' AND external_id = '397978';
UPDATE festival SET title = '[2026 PLOT STAGE] 디아트리베 - 무용 <Nonfiction MUTE>', content = '', place = '극장 PLOT' WHERE provider_type = 'PUBLIC' AND external_id = '395461';
UPDATE festival SET title = '2026 신진 청년작가 지원사업 <사이>', content = '', place = '은평문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '402286';
UPDATE festival SET title = '한지연 · 박세빈 석사학위 청구전 《Our Own Shelter》', content = '', place = '갤러리 지하' WHERE provider_type = 'PUBLIC' AND external_id = '401390';
UPDATE festival SET title = '2026 D.FESTA 소극장축제 <밤빛괴담(The Demon of the Night)>', content = '', place = '공간아울' WHERE provider_type = 'PUBLIC' AND external_id = '401943';
UPDATE festival SET title = '[수원] 량성희 소해금 평화콘서트 ''잇고, 있고''', content = '', place = '경기아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '398357';
UPDATE festival SET title = '<공간드림 1472> 신진예술인 단체전 *다층시선* ', content = '', place = '관천로 문화플랫폼 S1472' WHERE provider_type = 'PUBLIC' AND external_id = '402288';
UPDATE festival SET title = '2026 트라이보울 기획전시 <살아있는 척>', content = '', place = '트라이보울' WHERE provider_type = 'PUBLIC' AND external_id = '402537';
UPDATE festival SET title = '2026 공생광장 문화예술교육 <너그런 아트랩&아틀리에> 가을학기', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400687';
UPDATE festival SET title = '2026년 문화가 있는날 <추사 이야기마당> 10월', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400477';
UPDATE festival SET title = '아트하우스 17 내한공연', content = '"고음악의계의 무법자" 오스트리아 그라츠를 기반으로 활동하는 유럽의 대표적인 고음악 연주단체. 고전 레퍼토리를 현대적 감각으로 재해석하여 음악과 연극, 무용을 결합한 독창적인 공연', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '393005';
UPDATE festival SET title = '흙, 물 그리고 시간의 묘법', content = '<!-- wp:paragraph -->
<p>‘익명의 땅’에서 ‘묘법(Inscription)’까지</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2018년 갤러리그림손 10주년 기념 개인전 이후 8년 만에 갤러리그림손에서 개인전을 진행한다. 그 동안 많은 국내외 전시와 아트페어를 통해 ‘흙의 작가’로 알려진 작가는 흙과 물을 매개로 자연과 시간, 물질의 흔적을 탐구해 온 작업 세계를 한자리에서 선보인다. 이번 전시에서는 <익명의 땅(Terre Anonyme)>, <대지의 몽상>, <물의 초상(Portrait d''eau)>과 함께 최근 새롭게 시작한 <묘법(Inscription)>을 선보인다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>채성필에게 흙은 단순한 회화의 재료가 아니다. 인간이 존재하기 이전부터 존재해온 오래된 물질이자 시간과 장소, 수많은 존재의 흔적을 품고 있는 물질이다. 작가는 흙을 물에 풀고 화면 위에 흘려보내며, 물질이 흐르고 스며들고 쌓이고 마르는 과정을 통해 자연의 물성과 그 안에서 발생하는 우연을 회화의 중요한 요소로 다루어왔다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><익명의 땅>과 <대지의 몽상>에서는 특정한 장소의 풍경을 넘어 땅이 품고 있는 시간과 기억, 그리고 원초적인 자연의 이미지를 탐구했다. 이어 <물의 초상>에서는 흙과 만난 물의 흐름에 주목하며, 중력에 따라 움직이고 갈라지고 합쳐지는 물의 움직임을 화면에 담아냈다. 작가는 물질의 과정을 완전히 통제하기보다 그 안에서 발생하는 우연과 변화에 개입하며 작업을 완성해왔다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번에 새롭게 선보이는 <묘법>은 이러한 작업의 흐름 속에서 발견한 ‘흔적’과 ‘기록’에 대한 새로운 회화적 탐구 이다. ‘묘법(描法)’은 그림을 그리는 행위와 방법을 의미하지만, 작가에게 묘법은 대상을 재현하는 방법이 아니라 물질과 시간이 화면 위에 남긴 흔적을 기록하고 새기는 행위에 가깝다. 작가는 이를 Inscription, 즉 기록과 흔적, 각인의 의미로 확장한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><묘법>의 수직적인 선들은 붓으로 그어진 선이 아니다. 흙과 물, 안료가 만나고 중력과 시간이 개입하면서 자연스럽게 만들어진 흔적이다. 반복되는 선과 입자, 얼룩은 일정한 질서를 형성하면서도 각각 다른 형태와 밀도를 가진다. 멀리서는 하나의 추상적인 색면처럼 보이지만 가까이 다가갈수록 수많은 흔적이 드러나며, 때로는 산의 능선이나 계곡, 강줄기와 같은 풍경을 떠올리게 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>채성필의 회화에서 풍경은 재현되는 것이 아니라 물질과 시간의 작용을 통해 발생한다. 작가는 자연을 직접 그리기보다 자연과 물질이 스스로 만들어내는 흔적을 화면 위에 기록한다. <익명의 땅>에서 땅을 바라보고, <대지의 몽상>에서 시간과 기억을 탐구하며, <물의 초상>에서 물의 흐름을 따라갔다면, <묘법>에서는 그 흐름이 남긴 흔적 자체를 바라본다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>땅에서 물로, 물에서 흐름으로, 흐름에서 흔적으로.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 채성필이 오랜 시간 흙과 물을 통해 이어온 회화적 탐구를 하나의 흐름으로 보여주는 동시에, 그 탐구가 새로운 언어인 <묘법>으로 확장되는 과정을 보여준다. 작가와 물질, 중력과 시간, 통제와 우연이 함께 만들어낸 흔적은 화면 위에서 겹쳐지고 반복되며 하나의 풍경이자 하나의 시간이 된다. </p>
<!-- /wp:paragraph -->', place = '갤러리 그림손' WHERE provider_type = 'PUBLIC' AND external_id = '400890';
UPDATE festival SET title = 'Li Chen: A New Eastern Spirit—Genuine and Otherworldly', content = '<!-- wp:paragraph -->
<p>가나아트는 아시아아트센터와 함께 대만의 현대 조각가 리첸(李真, b. 1963)의 개인전, 《Li Chen: A New Eastern Spirit—Genuine and Otherworldly》을 개최한다. 그는 청동과 같은 무거운 재료를 사용하여 부유하듯 가볍고 둥근 형태의 조각을 빚어내며, 전통에 머무르지도 서구의 형식을 그대로 옮겨오지도 않는 독특한 조형 언어를 선보여 왔다. 그는 제52회 베니스 비엔날레 공식 병행전시로 개인전을 열었으며, 중국미술관, 국립중정기념당, 프라이 미술관 등에서도 개인전을 가졌다. 또한 그의 작품은 세르누치 미술관, 올렌스카 재단, 국립대만미술관, 가오슝시립미술관, 타이중미술관 등 세계 주요 공공 기관에 소장되어 있다.  또한 2025년에는 프랑스 미술 전문 출판사 세르클 다르에서 모노그래프를 출간하여 동시대 조각에 미친 영향을 인정받았다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시는 〈Energy of Emptiness(虛空中的能量)〉, 〈Spiritual Journey through the Great Ether(大氣神遊)〉, 〈Ordinary People(凡夫)〉, 〈Ethereal Cloud(青煙)〉 등 대표작을 비롯해 최근작 〈Celestial Manuscripts(天文)〉까지, 1999년부터 2025년에 이르는 리첸의 작업을 선별하여 선보인다. 그에게 조각을 만든다는 것은, 단순히 덩어리를 깎아 형태를 만드는 일이 아닌 기운의 흐름을 다루는 일이다. 기운생동(氣韻生動), 곧 대상에 생명의 기운이 감돌아 살아 움직이는 것 같은 상태를 이루기 위해, 그는 조각에서 선적인 요소를 덜어내고, 굴곡진 면이 반복되며 형성되는 흐름을 조형의 중심에 두었다. 이러한 작가의 의도는 조각의 형상에서 직접적으로 드러나는데, 청동 같은 무거운 재료를 사용하지만 안에서부터 차오르듯 부푼 형태는 오히려 기체나 에너지로 채워진 듯 가볍게 느껴진다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시의 제목이기도 한 ‘신동방정신(New Eastern Spirit)’은 고전이라는 깊은 우물에서 동시대라는 새로운 물을 길어 올린 그의 예술 여정을 상징한다. 그의 조각은 동양의 전통 도상을 경유해 정신적 공간을 구축한다는 점에서 동양 조각의 전통 위에 서 있다. 그러나 리첸의 조각은 전통에 머물지 않고 동시대 미술의 흐름과 접점을 찾는다. 즉, 그에게 ‘신동방정신‘이란 고대의 사유 체계를 동시대의 새로운 형식으로 옮겨와 대화하는 과정이자, 그의 예술 여정 전반에 걸쳐 견지해 온 태도이다. 리첸의 국내 첫 개인전인 이번 전시가 그의 미학과 예술 여정을 폭넓게 조망하고, 국내 관객이 그 여정에 첫발을 내딛는 자리가 되기를 기대한다.</p>
<!-- /wp:paragraph -->', place = '가나아트' WHERE provider_type = 'PUBLIC' AND external_id = '402284';
UPDATE festival SET title = '[대구] 2026 문예회관 특성화 지원사업 연극 <바람꽃>', content = '', place = '어울아트센터(구 대구북구문예회관) 함지홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '399118';
UPDATE festival SET title = '로맨틱코미디연극 <그새끼>', content = '', place = '맥거핀 서교' WHERE provider_type = 'PUBLIC' AND external_id = '400159';
UPDATE festival SET title = '지하침공! (地下侵功!)', content = '', place = 'KT&G 상상마당 라이브홀 [마포]' WHERE provider_type = 'PUBLIC' AND external_id = '400451';
UPDATE festival SET title = '유미향 피아노 독주회 “베토벤 피아노 소나타 전곡 연주회 Ⅳ”', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '395775';
UPDATE festival SET title = '신음악회 제49회 정기작품발표회 - 이ㅅ음 VI <틈>', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '399797';
UPDATE festival SET title = '수원시립합창단 제196회 정기연주회 | 합창음악극 <행복시계방>', content = '', place = '수원SK아트리움 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '398897';
UPDATE festival SET title = '제62회 인천 시민의 날 & IFEZ 개청 23주년 기념 음악회', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399073';
UPDATE festival SET title = '2026 서울시향 얍 판 츠베덴의 모차르트 ''주피터'' ① ②', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399610';
UPDATE festival SET title = '[2026 SPAF] 황수현 <히히히스토리>', content = '', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '399021';
UPDATE festival SET title = '<정오의 음악회> 10월', content = '이금희 아나운서와 함께하는 브런치 데이트', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392774';
UPDATE festival SET title = '[서울남산국악당] 헤이스트링 <서큘레이터>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '398924';
UPDATE festival SET title = '박성민 <형태를 지나 결에 머물다>', content = '', place = '노화랑' WHERE provider_type = 'PUBLIC' AND external_id = '401161';
UPDATE festival SET title = '전문가 포럼 ''설악에서 DMZ까지, 사람과 자연이 함께 여는 미래''', content = '', place = '국회고성연수원 2층 중강의실' WHERE provider_type = 'PUBLIC' AND external_id = '400270';
UPDATE festival SET title = '인천연극주간 연극 <PAWN>', content = '', place = '문학시어터' WHERE provider_type = 'PUBLIC' AND external_id = '400211';
UPDATE festival SET title = '이재문 작곡 멀티아트 퍼포먼스 <로우 앤 쿡드>', content = '', place = '트라이보울' WHERE provider_type = 'PUBLIC' AND external_id = '400765';
UPDATE festival SET title = '<가을엔 포크 콘서트> 송창식×정미조×함춘호 밴드', content = '한국 포크음악을 대표하는 전설이 뭉쳤다! 송창식 x 정미조 x 함춘호 밴드 with 남궁옥분과 함께하는 낭만과 위로가 있는 가을밤의 포크 콘서트', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '393076';
UPDATE festival SET title = '[마포문화재단] 2026 <인디스커버리 : FESTA> TRACK 01', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '386989';
UPDATE festival SET title = '[안양] 신현필×고희안, 디어 모차르트 ', content = '', place = '안양아트센터 수리홀' WHERE provider_type = 'PUBLIC' AND external_id = '398806';
UPDATE festival SET title = '2026 D.FESTA 소극장축제 <희망없는 자(砦なき者)>', content = '', place = '공간아울' WHERE provider_type = 'PUBLIC' AND external_id = '401944';
UPDATE festival SET title = '[부산] 2026 NAC 문화예술교육 공연 및 악기체험 클클클 ''도레미''', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '399125';
UPDATE festival SET title = '[경기 광주] 제6회 광주시심포니오케스트라 정기연주회, 오페라 여행: 춘향 & 피가로', content = '', place = '광주시문화예술의전당 남한산성홀' WHERE provider_type = 'PUBLIC' AND external_id = '399464';
UPDATE festival SET title = ' [마포문화재단] 2026 <인디스커버리 : FESTA> TRACK 02', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '386954';
UPDATE festival SET title = '이준서 비올라 독주회 ''비외땅의 색채''', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '395492';
UPDATE festival SET title = '2026 은평에브리바디페스티벌 <앰비규어스댄스컴퍼니-더 벨트(The Belt)>', content = '', place = '은평문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '397562';
UPDATE festival SET title = '현대무용 <시간과 공간의 순환>', content = '', place = '인천아트플랫폼 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '400896';
UPDATE festival SET title = '‘ONEPIECE’(원피스)', content = '', place = '노들섬 라이브하우스' WHERE provider_type = 'PUBLIC' AND external_id = '399046';
UPDATE festival SET title = '남해의 가을밤, 야외에서 즐기는 영화 한 편 ''GKL과 함께하는 우리동네 문화탐방''', content = '', place = '남해대교 웰컴센터 야외광장' WHERE provider_type = 'PUBLIC' AND external_id = '401159';
UPDATE festival SET title = '[여수] 2026년 가족뮤지컬 "겨울이야기" ', content = '', place = '여수시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '399109';
UPDATE festival SET title = '팸투어 ''설악에서 DMZ까지, 사람과 자연이 함께 여는 미래''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400273';
UPDATE festival SET title = '계절향유 프로그램 <가을 기록실>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400461';
UPDATE festival SET title = '[서울시립과학관] 2026년 하반기 가족 과학 실험교실 ''과학에 물들다''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '397995';
UPDATE festival SET title = '스트링 앙상블과 함께 하는 앨범 발표 기념 콘서트: 스콧해밀턴 & 롭반바벨 트리오', content = '', place = 'JCC 아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399529';
UPDATE festival SET title = '성북아트위크 특별전시 《서세옥·서도호: 어루만지다(撫)》', content = '', place = '성북구립미술관' WHERE provider_type = 'PUBLIC' AND external_id = '402890';
UPDATE festival SET title = '강윤주의 전통춤 2026 ‘화무화시 花舞畵詩’', content = '', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '400717';
UPDATE festival SET title = '제29회 한국성악예술학회 정기연주회 <리스트 서거 140년 기념음악회 리스트가 사랑한 시인들>', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '401241';
UPDATE festival SET title = '[부산] 정명훈, 막심 벤게로프 & 도쿄 필하모닉', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399498';
UPDATE festival SET title = '2026 고음악 오디세이 <음악의 언어 "몸짓_Gesture">', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399786';
UPDATE festival SET title = '권효진의 춤 <이 곳, 생명의 그물 X 생명의 DNA>', content = '', place = '서울남산국악당' WHERE provider_type = 'PUBLIC' AND external_id = '401812';
UPDATE festival SET title = '푸르지오아트홀 수요초대석 45 예울음악무대 “Opera Collage” 애정과 우정, 그 사이 Between Love and Friendship', content = '', place = '푸르지오아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '398279';
UPDATE festival SET title = '광명전통예술플랫폼 Vol.1 피리 & 댄스 <날좀보쑈!>', content = '', place = '광명시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '398586';
UPDATE festival SET title = '2026 대관령음악제 기획공연 <4色 콘서트> "인다코 콰르텟"', content = '', place = '명주예술마당' WHERE provider_type = 'PUBLIC' AND external_id = '400428';
UPDATE festival SET title = '김예진 동초제 심청가 <경심수예>', content = '', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '399941';
UPDATE festival SET title = '수림뉴웨이브 2026 - 김효영 <비껴선 시선>', content = '', place = '김희수아트센터 SPACE 1' WHERE provider_type = 'PUBLIC' AND external_id = '397462';
UPDATE festival SET title = '창작ing 연극 <꼭두각, 시간놀음>', content = '인형과 인간의 경계가 무너지는 순간, 놀이가 시작된다', place = '국립정동극장 세실 (구.세실극장)' WHERE provider_type = 'PUBLIC' AND external_id = '392741';
UPDATE festival SET title = '[김천] 제38회 김천시립교향악단 정기연주회 <가을의사랑 낭만의 노래>', content = '', place = '김천시문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '401492';
UPDATE festival SET title = 'Heritage Series; The Masters 피아니스트 손열음 & 고잉홈프로젝트', content = '', place = '신영체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '401632';
UPDATE festival SET title = '2026 김만덕주간 ''마음을 잇다, 세상을 밝히다''', content = '', place = '김만덕기념관 만덕홀 및 모충사 경내 김만덕묘탑' WHERE provider_type = 'PUBLIC' AND external_id = '401175';
UPDATE festival SET title = '[강원 양구] 강원문화재단 공연장예술단체 육성지원사업 <백자한상> (10.23) ', content = '', place = '양구문화복지센터' WHERE provider_type = 'PUBLIC' AND external_id = '402431';
UPDATE festival SET title = '뮤지컬 ＜윌리엄과 윌리엄의 윌리엄들＞', content = '세익스피어의 작품이냐 아니냐, 그것이 문제로다! 런던 최고의 스캔들, 셰익스피어의 미공개 작품 <보르티게른>에 대한 위작 논란! 1796년 4월, 헨리와 사무엘 아일랜드의 재판이 시작된다.', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '393097';
UPDATE festival SET title = '[창원] 연극 <행복> ', content = '', place = '진해아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399864';
UPDATE festival SET title = '[대전] 창작극 <농>', content = '', place = '드림아트홀 [대전]' WHERE provider_type = 'PUBLIC' AND external_id = '402903';
UPDATE festival SET title = '<완창판소리> 10월', content = '판소리 다섯 바탕을 한 명의 소리꾼이 처음부터 끝까지 펼쳐 보이는, 오랜 전통의 힘과 묵직한 감동을 느낄 수 있는 공연', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392776';
UPDATE festival SET title = '[부천] 테너 김우경 & 소프라노 여지영 듀오 리사이틀: 노래가 흐르고, 영화가 펼쳐진다', content = '', place = '부천아트센터 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '400027';
UPDATE festival SET title = '제36회 아주여성합창단 & 제24회 아주남성합창단 정기연주회: 지금 여기, 그대로 빛나', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '400809';
UPDATE festival SET title = '에너미', content = '헨리크 입센의 <민중의 적>을 현대적으로 각색한 키어런 헐리의 화제작 연극 <에너미> 한국 초연', place = '세종M씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '402379';
UPDATE festival SET title = '국립극단 [안트로폴리스Ⅳ] <이오카스테>', content = '오프 더 레코드, <이오카스테>. 테베의 왕비? 라이오스의 아내? 오이디푸스의 어머니이자 아내? 이오카스테, 드디어 자신의 말을 시작한다.', place = '국립극단 [명동] 명동예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '392936';
UPDATE festival SET title = '10.28 오상은 피아노 독주회 Romanticism "Schumann & Liszt"', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '400431';
UPDATE festival SET title = '[꿈의숲아트센터] 꿈의숲 마티네 콘서트 <벨에포크 아트 & 뮤직> 시리즈 3', content = '', place = '세종문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '386401';
UPDATE festival SET title = '[대학로] 바르도, 경계에 선 자들 ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '400940';
UPDATE festival SET title = '대전광역시 서예진흥원 <2026 서예 학술대회>', content = '', place = '대전광역시 서예진흥원' WHERE provider_type = 'PUBLIC' AND external_id = '396657';
UPDATE festival SET title = '수림뉴웨이브 2026 - 이화영 <化寧; 편안하게 되리라>', content = '', place = '김희수아트센터 SPACE 1' WHERE provider_type = 'PUBLIC' AND external_id = '397463';
UPDATE festival SET title = '아가페미션코랄 32주년 정기연주회 <장엄미사>', content = '', place = '영산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401903';
UPDATE festival SET title = '경기필 마스터피스 시리즈 V <말러 교향곡 1번>', content = '2026 시즌 경기필하모닉 마스터피스 시리즈의 5번째 공연으로, 지휘자 홍석원과 소프라노 서선영이 출연', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '393178';
UPDATE festival SET title = '서리풀 오페라 파노라마 <Belcanto Collage "도니제티&로시니">', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '403037';
UPDATE festival SET title = '2026년 제2회 디지털출판 세미나 <출판사의 디지털 전환과 새로운 비즈니스 기회>', content = '', place = '창비서교빌딩 B2 50주년 기념홀' WHERE provider_type = 'PUBLIC' AND external_id = '401031';
UPDATE festival SET title = '<끝내지 못한 이야기-국민화가 이중섭> 전시연계 강연', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '402863';
UPDATE festival SET title = '2026 순천문화기획학교 로컬기획자 페스티벌 ''ST.ART''', content = '', place = '순천부 읍성 남문터광장' WHERE provider_type = 'PUBLIC' AND external_id = '402756';
UPDATE festival SET title = '벽산 × 아르코 <프라우드 메리> 2025년 벽산예술상 희곡상 수상작', content = '', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '401016';
UPDATE festival SET title = '[부산] NAC@시그니처클래식 Symphony No.5 & Choral Series Ⅵ. 말러 5번 & 모차르트 플루트 협주곡', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '400780';
UPDATE festival SET title = '🎻중랑문화재단 × 서울시립교향악단 협력공연 <우리동네 실내악>', content = '', place = '중랑구청 강당 ' WHERE provider_type = 'PUBLIC' AND external_id = '403100';
UPDATE festival SET title = '이은지 작곡발표회 <조각 붙이기>', content = '', place = '일신홀' WHERE provider_type = 'PUBLIC' AND external_id = '402675';
UPDATE festival SET title = 'CTS 장로합창단 제7회 정기연주회 "걱정 말아요 그대"', content = '', place = '부천아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401430';
UPDATE festival SET title = '2026 DOAM Winter Kids Art Camp <미술사 속 겨울여행>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '361538';
UPDATE festival SET title = '당산 생각의 벙커 ''별별공감''', content = '', place = '당산 생각의 벙커' WHERE provider_type = 'PUBLIC' AND external_id = '361083';
UPDATE festival SET title = 'Scenery', content = '<!-- wp:paragraph -->
<p>Fill Gallery Group Exhibition _시각적 대상으로서의 풍경을 넘어서..</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>우리는 ''풍경(Scenery)''이라는 단어를 들을 때, 흔히 눈앞에 펼쳐진 익숙한 자연의 전경이나 도시의 정지된 모습을 떠올립니다. 하지만 이번 전시는 그 시각적 대상으로서의 풍경을 넘어섭니다. 《Scenery》는 각 작가가 마주하고 해석한 ''내면의 풍경'', ''사회적 관계의 풍경'', 나아가 ''인식의 구조가 만들어낸 철학적 풍경''을 총체적으로 아우릅니다. 21세기, 우리의 풍경은 더 이상 단순한 외부의 기록이 아니라, 실재와 허상의 경계가 무너지고, 관계의 층위가 복잡하게 얽힌, 끊임없이 ''변동하는 인식의 지형(知形)''이 되었습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 《Scenery》 전시는 동시대 한국 미술의 가장 첨예한 주제인 ''시각적 진실의 모순''과 ''존재의 유동적인 구조''를 탐구하는 8인의 시선을 한데 모았습니다. 8명의 작가는 회화의 전통적인 프레임을 해체하고, 미디어 시대의 조작된 이미지부터 인간 사회의 근원적 갈등까지, 우리의 삶을 이루는 모든 요소를 새로운 ''풍경''의 언어로 재구성합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>서웅주</strong>는 미디어를 통해 주입된 이미지가 가진 조작성과 허상을 극사실 회화로 역설합니다. 구겨진 사진을 재현하는 그의 작업은 우리가 보는 모든 것이 ''사실과 다른 복제물''일 수 있다는 냉철한 비판적 시선을 던지며, 《Scenery》의 첫 문을 엽니다. 이어 <strong>정재철</strong>은 인간 관계와 사회 구조에서 필연적으로 발생하는 모순과 갈등을 붓질의 겹침과 지움, 즉 ''타협의 흔적''으로 가시화합니다. 그의 추상 화면은 현실이라는 풍경을 유지하기 위해 치러야 했던 수많은 폭력과 양보의 기록입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>한편, <strong>박수형</strong> 작가가 지속적인 선 긋기로 쌓아 올린 풀의 형상은 사회 집단 속에서 꿈틀대는 개인의 욕망과 저항을 상징합니다. ''무(無의 공간)''와 대비되는 생장의 발악은 현대인의 실존적 투쟁이 만들어내는 역동적인 풍경입니다. 이러한 유동적 구조는 <strong>이혁</strong>의 작업에서 더욱 존재론적으로 확장됩니다. 그는 ''머무름''을 거부하고, ‘되기의 리듬''을 포착하며, 겹겹이 쌓이고 미세하게 어긋나는 색의 결을 통해 관계 속에서 끊임없이 재탄생하는 유동적인 존재의 방식을 시각화합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이 유기적인 흐름 속에서 <strong>김지훈</strong>은 ''노화중(aging)과 녹화중(rusting)''이라는 화두를 통해 회화의 ''시간성의 깊이''를 탐구합니다. 생활용 페인트와 도상(원, 삼각뿔)의 중첩을 사용하는 그의 작업은 완성 이후에도 변화하며 생을 이어가는 형상의 운명을 보여줍니다. <strong>이호섭</strong>은 도시의 기하학적 이미지와 옵티컬 효과를 통해 ''가상의 창조''를 구현하며, 시각적 진동과 울림이 만들어내는 감정의 풍경을 제시합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>위영일</strong>은 이러한 회화적 담론을 더욱 구조적으로 심화시키며, 직선 없는 만곡의 ''중성적 구조''와 변형된 지지체를 통해 회화의 전통적 한계를 극복하고 동시대 미술 환경에 적합한 새로운 회화의 조건을 제시합니다. 마지막으로, <strong>이현배</strong> 작가는 물감의 ''현존(Present)''을 추구하며, 순간적인 직관과 실존적 제스처를 기록하여 구름, 파도와 같이 유동적이고 자율적인 회화 자체의 실체를 화면 위에 펼쳐냅니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>8인의 작가는 각기 다른 매체와 조형 언어로 《Scenery》라는 주제에 접근하지만, 결국 ''우리가 보고 있는 현실이 과연 진실인가'', 그리고 ''이 현실 속에서 우리의 존재는 어떤 형태로 흘러가는가''라는 현시대적 질문으로 수렴됩니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 관람객이 단순히 작품을 감상하는 것을 넘어, 능동적인 시선으로 참여하기를 제안합니다. 전시를 통해 관람객은 우리가 ''진실이라고 믿었던 이미지''의 이면을 탐색하고, 복잡하게 얽힌 ''관계의 층위''를 해독해 보며, 궁극적으로는 이 모든 풍경 속에서 ''나 자신의 실존적인 위치''를 재확인하는 사유의 여정이 될 것입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul><!-- wp:list-item -->
<li>참여작가 | 서웅주, 김지훈, 정재철, 박수형, 이혁, 이호섭, 위영일, 이현배</li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li>전시장소 | 서울시 용산구 유엔빌리지길 24 1F, B1F</li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li>기간 | 2025.12.6 - 2026.2.10</li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li>관람시간 | 화-토 11AM - 6PM</li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li>문의 | T. +82 02.795.0046 / E. fillgallery@naver.com</li>
<!-- /wp:list-item --></ul>
<!-- /wp:list -->', place = '필 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '367345';
UPDATE festival SET title = '한국영상자료원 영화상영 <웨폰>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365357';
UPDATE festival SET title = '2026 토요명품 1,2월', content = '전통 국악을 최적의 공간에서 가장 깊이 있고 다채롭게 만날 수 있는 국립국악원의 대표 주말 공연 ''토요명품''. 한민족의흥과 신면이 살아 숨 쉬는 노래와 음악, 춤을 비롯해 세계가 인정한 유네스코 등재 무형문화유산까지. 한국인과 외국인 모두 꼭 봐야할 한국의 전통 공연 예술이 매주 토요일, 우면당 무대를 가득 채웁니다. 국립국악원 연주단의 수준 높은 연주의 향연, ''토요명품''을 통해 전통 국악의 품격과 아름다움을 느껴보세요.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '362612';
UPDATE festival SET title = '가족뮤지컬 <가방 들어주는 아이들>', content = '', place = '상상나라극장' WHERE provider_type = 'PUBLIC' AND external_id = '362649';
UPDATE festival SET title = '한국영상자료원 영화상영 <달팽이의 회고록>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365368';
UPDATE festival SET title = '한국영상자료원 영화상영 <3학년 2학기>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365358';
UPDATE festival SET title = '박희수의 정가 <설화(說花)> 말은 입김이 되어 눈꽃처럼 흩어진다', content = '', place = '서울돈화문국악당' WHERE provider_type = 'PUBLIC' AND external_id = '401931';
UPDATE festival SET title = '2026-2027 국립극장 레퍼토리시즌 국립창극단 <2026 창극 작가 프로젝트 시연회>', content = '', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '401013';
UPDATE festival SET title = '2026 청주 원도심 골목길축제 <가을 : 잔치집,대성>', content = '', place = '대성로 122번길 일원' WHERE provider_type = 'PUBLIC' AND external_id = '399624';
UPDATE festival SET title = '사육신역사관 <추억의 토요시네마>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '403102';
UPDATE festival SET title = '2026 까망돌어울마당 아트홀 개관 1주년 공연연계 예술교육 프로그램 <STAGE ON : 덩실덩실 깨비깨비 연극 워크숍>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '402690';
UPDATE festival SET title = '2026 서리풀 재즈페스타 <Remembering Bud Powell>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399791';
UPDATE festival SET title = '박혜준 첼로 독주회 "Cello Project XV [Bel Canto: 첼로, 노래하다]"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '401419';
UPDATE festival SET title = '아트파파라치 "마크 로스코 – 감정의 형상"', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '402795';
UPDATE festival SET title = '예술의전당 토요콘서트 - 프리뷰 베토벤(12월)', content = '베토벤이 빚어낸 숭고한 예술혼의 정수! ''장엄미사''와 함께 깊은 감동과 여운으로 물드는 연말', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401069';
UPDATE festival SET title = '뮤지컬 <광화문연가>', content = '전 세대가 사랑하는 작곡가 이영훈의 명곡들을 하나의 이야기로 엮어낸 주크박스 뮤지컬, 봄의 설렘, 여름의 열정, 가을의 그리움, 겨울의 추억까지. 계절마다 흐르는 노래 속에 아로새겨진 우리의 인생, 모두가 하나 되는 인생 뮤지컬.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '402178';
UPDATE festival SET title = '축구와 그 이야기 «Golpe de estadio»', content = '', place = '주한 세르반테스 스페인 문화원' WHERE provider_type = 'PUBLIC' AND external_id = '383257';
UPDATE festival SET title = '축구와 그 이야기 «Metegol»', content = '', place = '주한 세르반테스 스페인 문화원' WHERE provider_type = 'PUBLIC' AND external_id = '383274';
UPDATE festival SET title = '[부산] 2026 앙상블 부산 “현의 물결” 시리즈 <Summertime>', content = '', place = 'F1963' WHERE provider_type = 'PUBLIC' AND external_id = '382757';
UPDATE festival SET title = '<제45회 밀양예술제> 밀양미술협회전', content = '', place = '밀양아리랑아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '402983';
UPDATE festival SET title = '살롱음악회: 소프라노 김유진 & 피아니스트 이루미, Happy Birthday!', content = '', place = '매일의 기쁨과 위로' WHERE provider_type = 'PUBLIC' AND external_id = '382904';
UPDATE festival SET title = '국악인과 청소년의 동행 <국악, 함께 짓다>', content = '', place = '서빛마루문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '401173';
UPDATE festival SET title = '안중근 의사 음악연가(連歌), <하얼빈의 열 하루> *2026년 여수세계섬박람회 개최 기념공연', content = '', place = '여수시민회관' WHERE provider_type = 'PUBLIC' AND external_id = '401428';
UPDATE festival SET title = '퓨전국악밴드 날다의 음악극 ‘심청날다’ 공연', content = '', place = '한국트로트가요센터' WHERE provider_type = 'PUBLIC' AND external_id = '402880';
UPDATE festival SET title = '2026 서울시향 얍 판 츠베덴의 모차르트 ''레퀴엠'' ①', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399612';
UPDATE festival SET title = '[대전] 테너들의 맛있는 노래한상! <소리맛집 : 퓨전요리의 향연> ', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '400162';
UPDATE festival SET title = '開人展', content = '<!-- wp:image {"id":20789,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/10/포스터.png" alt="" class="wp-image-20789" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>■ Artist : 한영준</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■ Title : 開人展</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■ Dates : 2026. 11. 10(화) - 11. 28(토)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■ Venue : 갤러리제이원 대구 (대구 중구 봉산문화길 60) </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■ Hours : 10:30 AM — 06:00 PM (Sun Closed) </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>■ Inquiry : 053-252-0614</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><br>■Opening : 2026. 11. 11(수) 오후 5:00</p>
<!-- /wp:paragraph -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity" />
<!-- /wp:separator -->

<!-- wp:paragraph -->
<p>開人</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>현대 미술이 품고 있는 깊이 있는 개념과 담론도 중요하지만, 때로는 붓끝에 담긴 화가의 진솔한 시선 그 자체가 예술의 가장 선명한 본질로 다가오기도 합니다. 우리는 종종 세상의 속도나 정해진 규격에 발맞추려 애쓰지만, 예술이 지닌 순수한 힘은 목적의 굴레에서 잠시 벗어나 화가가 마주한 세상과 감정을 캔버스 위에 자연스럽게 펼쳐내는 자유에 있을 것입니다. 11월 10일부터 GALLERY J. ONE 대구에서 열리는 한영준 작가의 개인전 《開人전》은 이론의 무게를 잠시 내려놓고, 붓이 이끄는 가장 자연스러운 궤적을 따라가는 전시입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시명 《開人》은 닫힌 틀을 열고 스스로를 확장해 나가는 사람을 의미함과 동시에, 한 개인(個人)이 삶 속에서 겪어낸 시간과 감정을 캔버스 위에 부드럽게 열어가는 과정을 뜻합니다.<br>한영준 작가에게 그림을 그리는 행위는 정해진 정답을 향해 달려가는 일이 아닙니다. 초기작인 색채 실험과 팬데믹 시기의 인물에서부터, 어머니의 투병과 간병, 그리고 새롭게 맞이한 가족의 모습까지, 삶의 궤적은 자연스럽게 그림의 대상이자 방식으로 캔버스에 스며들었습니다. 답답한 병원 실내에서 바깥 풍경을 갈망하며 시작된 사생(寫生) 역시 이러한 궤적과 깊이 맞닿아 있습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 삶을 스쳐간 이 모든 순간들을 인위적으로 통제하거나 하나의 세련된 화풍으로 포장하려 하지 않습니다. 자신이 통과해 온 시간을 특정한 목적에 얽매이지 않고 기록하며, ‘나는 이곳에 존재했고 세상을 이토록 담담하게 바라보았다’는 것을 묵묵히 보여줍니다. 그저 삶의 풍경 속을 천천히 거니는 ''소요(逍遙)''의 태도로, 매 순간 자신이 마주하고 싶은 장면에 온전히 집중할 뿐입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시에는 하나의 스타일이나 완성된 시리즈로 묶이지 않은 그림들이 나란히 놓여 있습니다. 굳이 뚜렷한 방향을 제시하지 않아도, 화가가 그리고 싶은 것을 담담하게 캔버스에 담아내는 진솔한 태도는 보는 이의 마음에 가닿아 깊은 공명을 만들어냅니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>반드시 어딘가를 향해 쉼 없이 달려가지 않아도 괜찮다는 위로, 매 순간 자신에게 집중하는 덤덤한 시선. 이번 《開人전》이 관람객 각자의 삶 속에서 닫혀 있던 시선을 열고, 그림이 선사하는 순수한 위로 속에서 고요하게 소요(逍遙)하는 시간이 되기를 바랍니다.</p>
<!-- /wp:paragraph -->', place = '갤러리제이원' WHERE provider_type = 'PUBLIC' AND external_id = '403447';
UPDATE festival SET title = '사당생활문화센터 계절향유 프로그램 <겨울 다락방>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '403185';
UPDATE festival SET title = '[칠곡] 이희문프로젝트 <陧>', content = '', place = '칠곡향사아트센터 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '401683';
UPDATE festival SET title = '문준호 전 - 남겨진 것들을 위한 풍경', content = '<!-- wp:post-featured-image /-->

<!-- wp:paragraph -->
<p>《문준호 - 남겨진 것들을 위한 풍경》</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2026.10.20(화)~11.13(금) (일요일, 공휴일 휴관)<br>10:00 ~ 18:00 (평일)<br>11:00 ~ 17:00 (토요일) 하루 전 사전예약 권장</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리소헌 & 소헌컨템포러리<br>대구광역시 중구 동덕로 18 (대봉동) 2F</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>연락처<br>art422@hanmail.net / 053-426-0621 / Instagram @gallerysoheon<br>010-9955-0621 (갤러리폰)<br>갤러리 공식 홈페이지 www.gallerysoheon.com<br>공식 블로그 blog.naver.com/soheoncontem</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>낭만적 폐허, 남겨진 것들을 위한 풍경<br>무한한 자연의 숭고함과 ‘유한한’ 인간의 문명<br>강렬한 빛이 만들어내는 낯설고도 신비한 풍경</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>무한하고 경이로운 자연과 그 속의 유한한 인간에 대한 이야기를 현대사회의 상징 재료인 실리콘의 물성으로 표현한 문준호 작가의 개인전이다.<br>사실적으로 묘사되었으나 작가의 시각에서 재구성된 유토피아적 자연 풍경은 흑백의 강한 대조효과와 독특하고 두꺼운 마티에르, 재료가 주는 말랑함과 거칠고 묵직한 느낌 등 여러가지 감상포인트가 있다. 관람자는 작가가 만들어낸 인공적인 유토피아의 풍경에서 사색을 하기도 하고, 독특한 마티에르와 사실적 표현에 감탄하기도 하며 우리시대 새로운 풍경화의 의미를 되새겨 볼 수 있을 것이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20718,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/10/전시전경-2.jpg" alt="" class="wp-image-20718" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph {"align":"right"} -->
<p class="has-text-align-right"><strong>남겨진 것들을 위한 풍경, 이선영(미술평론가)</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>문준호는 실리콘 실란트를 마치 유화나 아크릴 물감처럼 사용한다. 물론 분리된 것을 연결하는 접착 기능의 활용은 기본이다. 캔버스 위에 그리는 작품뿐 아니라, 나무, 철사, 철망 등 여러 재료를 실리콘으로 접합하여 조각과 설치 작품으로 만들기도 한다. 접합에 대한 그의 생각은 나무못이나 각목같이 일정한 구조의 재료와 결합하여 좌대나 또 다른 화면으로 변신한다. 실리콘을 쏴서 그린 작품은 언뜻 보통 그림과 다르지 않다. 하지만 그림틀 바깥으로 비죽비죽 나와 굳은 고무 질감의 덩어리들은 이물감 있는 재료의 특성을 단적으로 보여준다. 그는 실리콘을 2016년부터 사용해 왔고, 그동안 회화부터 조각에 이르는 실험을 거쳤다. 한 재료로 펼칠 수 있는 최대치의 실험은 매체의 특수성을 드러나게 했다. 그는 ‘자연의 풍경을 그리는 과정에서 실리콘을 회화의 재료이자 하나의 조형적 언어로 사용해 왔다’고 말한다. 분리된 것을 연결하는 방식은 작품 내용과도 이어진다.<br>문준호의 풍경은 사실에 기초한 것이든 환상적이든 스산하다. 우선은 주요 재료의 칙칙한 색감이 풍기는 분위기 탓이 크다. 아크릴 실리콘 실란트는 색도 가능하지만, 2019년 이래의 작업은 주로 검은 실리콘으로 만들어졌다. 무채색의 어두운 분위기에 산업 재료 자체가 가지는 딱딱한 속성이 더해진다. …(후략)</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20720,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/10/전시전경-3.jpg" alt="" class="wp-image-20720" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":20717,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/10/전시전경-4.jpg" alt="" class="wp-image-20717" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시의 주요 작품은 대형 회화지만, 그는 평소에도 실리콘으로 드로잉을 많이 한다. 이번 전시에서도 큰 작품들과 함께 전시된다. 실리콘에 면봉이나 드라이버 같은 단단한 도구로 긁어 그린 공장 같은 산업사회의 풍경이나 군대에서의 경험이 드러난 작품은 재료와 내용을 연결시킨다. 이런 드로잉은 차가운 금속 프레임과 잘 어울린다. 그에게 드로잉은 작업의 첫 단추로, 캔버스를 20x20cm로 잘라서 바로 액자로 옮길 수 있게 만들고, 그중에는 큰 캔버스에 회화로 옮겨지기도 한다. 작업 중의 공장 노동자나 최전방의 군인과 관련된 이미지는 작가의 경험이 녹아있지만, 집단과 강제, 잠재적인 전쟁과 경쟁이라는, 자유로운 예술가라면 피하고 싶은 삶이 스며있다. 요즘 작품은 초현실주의적인 신비로움이 감돌지만, 폐허같은 느낌은 여전하다. 근대의 키치가 순수 예술의 이면이듯이 낭만주의는 가혹한 현실의 이면이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>문준호에게 실리콘은 음울한 현실과 그로부터 파생된 낭만적 환상을 연결시켜주는 것이다. 석탄을 동력으로 공장들이 쉴새 없이 돌아가며, 온 천지가 시커멓게 변화했던 산업혁명기의 영국에서 비약적으로 발전한 환상적인 문화예술을 생각해 보라. 존 하비는 [블랙 패션의 문화사]에서 디킨스를 비롯한 영국의 작가들에게 등장하는 ‘어두운’, ‘검은’이라는 단어는 부두, 철도, 공장, 사무실, 교회, 감옥을 묘사할 때도 계속 등장하며, ‘어둡고 쓸쓸한 거리’, ‘검은 흙과 썩은 물이 가득한’. 런던의 연기 가득한 매연은 검은색을 연상시킨다고 말한다. 반대로 블랙과 낭만적인 것이 연결되기도 한다. ‘거기에는 낭만적 영웅의 한가한 멜랑콜리가 결합되며… 무덤같은 태도, 불가사의한 과거, 황폐함, 죽음의 과시…’ (존 하비)등이 그것이다. 2019년부터 본격적으로 그린 풍경은 숲, 빛, 폭포, 강 등이 포함된 낭만적 자연이며 실제 풍경을 보고 그린 것은 아니다.<br>게임을 포함해서 여러 기원을 가진 그럴듯한 이미지들을 편집하고 합성하여 만든 풍경이다. 그림 안에 실리콘 폐기물을 이용해 만든 조각 작품들 뿐 아니라, 세월에 무너진 인공물 이미지가 포함된 것에 대해 작가는 ‘버려진 것을 위한 풍경’이라고 말한다. 햇빛을 가득 받고 있는 폐허의 풍경 유적지의 풍경은 시간이 무너뜨린 것, 그럼에도 불구하고 남아있는 잔해들이 감상에 빠지게 한다. … (후략)</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20719,"width":840,"height":560,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full is-resized"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/10/전시전경-1.jpg" alt="" class="wp-image-20719" width="840" height="560" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>문준호 작가는 사실적 구상화에 강한 계명대 미술대학을 졸업하고 2024년 2024년H-EAA 호반 청년작가 미술공모전 대상을 수상하고 아트스페이스 호화에서 수상작가 그룹전 당시 놀라운 스케일과 재료의 감각적인 표현으로 주목을 받았다. 2026 안국문화재단 주최 AG신진작가대상 선정작가 우수상 수상을 하였다.<br>현재는 평면을 넘어서 입체와 설치작업도 병행하고 있으며, 일상 속의 인물들을 포착한 순간을 드로잉 기록해 실리콘 회화속에 도입하는 등 다양한 장르를 넘나들며 작업의 폭을 넓혀가고 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '갤러리소헌&소헌컨템포러리' WHERE provider_type = 'PUBLIC' AND external_id = '402907';
UPDATE festival SET title = '하남역사박물관 이성산성 실감관 <이성산성, 한강을 지배하다>', content = '', place = '하남역사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '396296';
UPDATE festival SET title = '2025 기형도문학관 기획 전시 <바람은 그대 쪽으로>', content = '', place = '기형도문학관' WHERE provider_type = 'PUBLIC' AND external_id = '325792';
UPDATE festival SET title = '2025년 기획전 <흥.화. 잊혀진 교실을 열다>', content = '', place = '용인시박물관' WHERE provider_type = 'PUBLIC' AND external_id = '326033';
UPDATE festival SET title = '양구인문학박물관 1관 상설전 ''이어짐의 시작(해인글방)展''', content = '', place = '양구인문학박물관' WHERE provider_type = 'PUBLIC' AND external_id = '329949';
UPDATE festival SET title = '2025년 서울우리소리박물관 기획전 ''한강, 소리로 흐르다''', content = '', place = '서울우리소리박물관' WHERE provider_type = 'PUBLIC' AND external_id = '331121';
UPDATE festival SET title = '2025년 제주추사관 기획전시 <추사 김정희와 소치 허련>', content = '', place = '제주추사관' WHERE provider_type = 'PUBLIC' AND external_id = '365855';
UPDATE festival SET title = '부안역사문화관 기획전시 <심청 위도에 피어나다 : 바다에 띄운 마음>', content = '', place = '재단법인 부안군문화재단(마실영화관)' WHERE provider_type = 'PUBLIC' AND external_id = '376891';
UPDATE festival SET title = '타임슬립 코믹연극 <영시기>', content = '', place = '성수 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '372264';
UPDATE festival SET title = '2025년 특별기획전 ''세계유산: 우리가 사랑한 반구천의 암각화''', content = '', place = '울산암각화박물관' WHERE provider_type = 'PUBLIC' AND external_id = '344665';
UPDATE festival SET title = '한국 무속의 원형을 만나는 특별한 전시 <안녕, 금성당>', content = '', place = '은평역사한옥박물관' WHERE provider_type = 'PUBLIC' AND external_id = '351298';
UPDATE festival SET title = '2025년 기획전시 <사상, 맛의 기억>', content = '', place = '사상생활사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '359122';
UPDATE festival SET title = '국립극장 마당놀이 <홍길동이 온다>', content = '연말연시 온 가족이 함께 즐기는 국립극장 마당놀이가 신작으로 찾아온다. 이번엔 K-히어로 ‘홍길동’이 주인공! 서자로 태어난 설움을 딛고 활빈당 수장이 되어 부패한 세상을 향해 통쾌한 한 방을 날리는 홍길동의 이야기를 유쾌하게 풀어낸다.', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '348392';
UPDATE festival SET title = '뮤지컬 <보니 앤 클라이드>', content = '', place = '홍익대 대학로 아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '355992';
UPDATE festival SET title = '2025 특별전 <밤풍경>', content = '', place = '대한민국역사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '371276';
UPDATE festival SET title = '뮤지컬 슈가 <SUGAR> ', content = '', place = '한전아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '356157';
UPDATE festival SET title = '한-캐나다 상호 문화교류의 해 기념 특별전 <버틴스키: 추출 / 추상>', content = '', place = '서울역사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '360136';
UPDATE festival SET title = '한규남 초대전 《MANHATTAN & EMPTY SPACE》', content = '', place = '서호미술관' WHERE provider_type = 'PUBLIC' AND external_id = '364510';
UPDATE festival SET title = '서리풀 휴(休) 갤러리 <서리풀페스티벌 사생대회 수상작 전시>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '363045';
UPDATE festival SET title = '거인의 식탁 Feast of the Giant', content = '<!-- wp:paragraph -->
<p>김진 개인전</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":16547,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2025/12/거인의식탁-최최최종-포스터.jpg" alt="" class="wp-image-16547" /></figure>
<!-- /wp:image -->

<!-- wp:columns -->
<div class="wp-block-columns"><!-- wp:column {"width":"100%"} -->
<div class="wp-block-column" style="flex-basis:100%"><!-- wp:paragraph -->
<p>갤러리 플래닛은 2025년 12월 17일부터 2026년 1월 09일까지 김진 작가의 개인전 《거인의 식탁(Feast of the Giant)》를 개최한다. 이번 전시는 작가의 대표 시리즈인, <핑크는 없다> 시리즈와 <거인의 시선은 어디에나 있다> 시리즈를 함께 선보인다. 두 시리즈를 통해 현대 소비사회가 어떻게 사물과 몸, 욕망과 권력을 동시에 조직하는지에 대한 작가의 오랜 탐구를 보여주며, 우리가 매일 마주하지만 쉽게 보지 못하는 체계의 단면을 다시 바라보게 하는 시각적 성찰을 제안한다.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column --></div>
<!-- /wp:columns -->

<!-- wp:columns -->
<div class="wp-block-columns"><!-- wp:column {"width":"100%"} -->
<div class="wp-block-column" style="flex-basis:100%"><!-- wp:paragraph -->
<p>김진은 일상의 사물이 소비 구조 속에서 어떻게 이미지화되고 상품화되는지를 꾸준히 탐구해왔다. 작가는 하나의 주제를 오래 반복하기보다, 생활 속에서 자연스럽게 감각되는 사회적 징후와 현상을 포착하며 그때마다 새로운 주제로 전환해 나가는 방식을 따른다. 동시대의 사회문제에 민감하게 반응하고 이를 회화로 번역하는 자신의 태도를 두고 스스로를 ‘풍속화가’라 칭하는데, 이는 김홍도·신윤복식 풍속도와는 결이 다른 개념이다. 김진에게 풍속화란 “우리 삶에 작동하는 가치와 이데올로기 같은 무형의 질서를 다루는 회화”로, 사물뿐 아니라 오늘의 감각과 현실을 함께 포착해낸다.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column --></div>
<!-- /wp:columns -->

<!-- wp:columns -->
<div class="wp-block-columns"><!-- wp:column {"width":"100%"} -->
<div class="wp-block-column" style="flex-basis:100%"><!-- wp:paragraph -->
<p><strong>‘</strong><strong>정물:핑크는 없다’는 </strong>과도한 빛과 조명이 사물의 본래 색과 질감을 지워내며, 현실의 ‘살(肉)’이 소비 가능한 이미지로 재포장되는 과정을 드러낸다. 과일과 고기는 광택과 부피감만을 남긴 채 핑크빛 잔여로 변하며, 고통·흠집·기원의 흔적은 시야에서 사라진다. 작가는 이렇게 정제된 표면을 통해 현대 소비사회가 불편한 현실을 어떻게 부드럽고 매혹적인 색으로 은폐하는지를 질문한다. 따라서 「핑크는 없다」는 사물이 ‘먹음’의 대상이기 이전에, 체계가 설계한 욕망의 언어로 변모한 순간을 비판적으로 보여준다.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column --></div>
<!-- /wp:columns -->

<!-- wp:columns -->
<div class="wp-block-columns"><!-- wp:column {"width":"100%"} -->
<div class="wp-block-column" style="flex-basis:100%"><!-- wp:paragraph -->
<p><strong>‘</strong><strong>거인의 시선은 어디에나 있다’는 </strong>식량·자본·자원의 흐름을 통제하는 익명적 권력을 ‘거인’이라는 형상으로 제시하며, 식탁의 이면에서 작동하는 구조적 힘을 가시화한다.<br>얼굴 없는 거인의 손, 저울, 트로피화된 동물 사체는 식량이 생존의 조건을 넘어 <strong>가장 기초적인 권력</strong>으로 작동하는 현실을 드러낸다. 작가는 이 장면들을 통해 우리가 소비하는 음식과 몸을 둘러싼 체계―축산, 유통, 가공, 가격 결정―가 어떻게 폭력과 착취를 은폐하는지를 질문한다.<br>따라서 이 시리즈는 식탁이라는 친숙한 풍경 속에 감춰진 <strong>자본·권력·생태의 불균형</strong>을 시각적으로 해부하며, 우리의 ‘먹는 행위’ 자체가 이미 정치적임을 환기한다.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column --></div>
<!-- /wp:columns -->

<!-- wp:columns -->
<div class="wp-block-columns"><!-- wp:column {"width":"100%"} -->
<div class="wp-block-column" style="flex-basis:100%"><!-- wp:paragraph -->
<p>《거인의 식탁》은 빛 아래 고유색이 지워진 정물에서 출발해, 권력이 작동하는 거대한 구조로 시야를 확장한다. 두 시리즈는 서로 다른 장면을 다루지만, 모두 <strong>빛과 표면,자본과 권력, 이미지의 논리</strong>가 사물과 몸을 재구성하는 동일한 구조를 공유한다. 정물의 핑크빛 표면은 거인의 세계에서 ‘살과 시장의 색’으로 이어지며, 소비 가능한 이미지로 대체되는 오늘의 조건을 압축한다. 작가는 이 과정을 통해 우리가 무엇을 먹고, 무엇을 보고, 무엇을 믿으며 살아가는지에 대한 은폐된 질문들을 드러낸다. 이번 전시는 일상의 식탁 속에 스며든 권력과 감각의 작동 방식을 다시 바라보게 하는 시각적 성찰의 자리로 관객을 초대한다.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column --></div>
<!-- /wp:columns -->', place = '갤러리 플래닛' WHERE provider_type = 'PUBLIC' AND external_id = '362771';
UPDATE festival SET title = '광복 80주년 기념 특별전 <1945-1948 역사 되찾기, 다시 우리로>', content = '', place = '대한민국역사박물관' WHERE provider_type = 'PUBLIC' AND external_id = '371277';
UPDATE festival SET title = '한·일 국교정상화 60주년 기념 특별전 <천년을 흘러온 시간>', content = '', place = '국립고궁박물관' WHERE provider_type = 'PUBLIC' AND external_id = '364838';
UPDATE festival SET title = '산울림 편지콘서트 <에릭 사티와 벨 에포크의 예술가들>', content = '', place = '산울림소극장' WHERE provider_type = 'PUBLIC' AND external_id = '357747';
UPDATE festival SET title = '2025년 대전근현대사전시관 특별전 <추억의 문방구>', content = '', place = '대전근현대사전시관' WHERE provider_type = 'PUBLIC' AND external_id = '366670';
UPDATE festival SET title = '2026 인천수봉문화회관 기획공연 & 기획전시 공모', content = '', place = '인천수봉문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '363860';
UPDATE festival SET title = '복합문화공간 111CM 기획전시 <유머의 맛, 서현 그림책>', content = '', place = '수원문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '368267';
UPDATE festival SET title = '2025 오산시립미술관 <지역 상생전>', content = '', place = '오산시립미술관' WHERE provider_type = 'PUBLIC' AND external_id = '368963';
UPDATE festival SET title = '더 드레서', content = '아카데미 각본상 ''로널드 하우드'' X 올라운드 플레이어 ''장유정'' X 박근형·정동환·송승환·오만석·송옥숙·정재은 등 베테랑 배우 총출동!', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '362175';
UPDATE festival SET title = '속초고등학교 국제견문록 ‘아바이(갯배) 아바이’ 전시회', content = '', place = '속초시립박물관' WHERE provider_type = 'PUBLIC' AND external_id = '366786';
UPDATE festival SET title = '용인포은아트갤러리 기획전시 <미술관의 동물원 - 종이의 발견>', content = '', place = '용인포은아트갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '367107';
UPDATE festival SET title = '연극 <과속스캔들>', content = '', place = '나인진홀 2관 (B1층)' WHERE provider_type = 'PUBLIC' AND external_id = '361850';
UPDATE festival SET title = '한국영상자료원 영화상영 <테헤란, 끝나지 않은 역사>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365356';
UPDATE festival SET title = '한국영상자료원 영화상영 <마른 잎>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365362';
UPDATE festival SET title = '2026년 문화 예술 공모 지원사업 <용인 예술 창작 지원 사업 설명회>', content = '', place = '문화예술원 마루홀' WHERE provider_type = 'PUBLIC' AND external_id = '364629';
UPDATE festival SET title = '[대학로] 낭독 음악극 <백의신ㆍ백의손> : 널 데려가기 위해 천릿길을 걸어온 것이야', content = '', place = '드림시어터 [대학로]' WHERE provider_type = 'PUBLIC' AND external_id = '364073';
UPDATE festival SET title = '한국영상자료원 영화상영 <마젤란>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365369';
UPDATE festival SET title = '한국영상자료원 영화상영 <검은 소>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365361';
UPDATE festival SET title = '한국영상자료원 영화상영 <어친>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '365359';
UPDATE festival SET title = '가족뮤지컬 <알파블록스>', content = '장난꾸러기 PEN의 초대로 미로 속으로 빨려 들어간 알파 블록들이, 해적 선장 R과 함께 하늘과 바다를 넘나들며 진정한 함께의 마법을 찾아 떠나는 환상적인 모험', place = '국립중앙박물관 극장 용' WHERE provider_type = 'PUBLIC' AND external_id = '362011';
UPDATE festival SET title = 'AOU 신년음악회: L''amour', content = '', place = '부천아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '363961';
UPDATE festival SET title = '제 16회 스카우트 展', content = '<!-- wp:paragraph -->
<p>2026 갤러리 이마주 연례 기획전: 스카우트展</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리 이마주는 매년 뛰어난 가능성을 지닌 미대 졸업 예정자를 선발해, 작가로서의 첫 출발을 지원하는 연례 기획전 <스카우트展>을 개최해왔습니다.<br>제 16회를 맞은 이번 전시에서는 엄정한 심사를 거쳐 선정된 신진 작가들의 독창적인 작업을 선보입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 스카우트展은 작가들에게는 실질적인 도약의 계기가 되고, 관람객들에게는 동시대 미술의 새로운 감각과 가능성을 마주하는 시간이 될 것입니다.<br>예비 작가들의 현재와 가능성이 교차하는 이 자리에서, 각기 다른 시선과 언어로 구축된 작업들을 만나보시기 바랍니다.</p>
<!-- /wp:paragraph -->', place = '갤러리 이마주' WHERE provider_type = 'PUBLIC' AND external_id = '365219';
UPDATE festival SET title = '병맛코믹 로맨스연극 <어쩌다 보니>', content = '', place = '샤봉디씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '388545';
UPDATE festival SET title = '고전과 낭만사이 <베토벤 & 차이코프스키 & 드보르작>', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '363307';
UPDATE festival SET title = '저마다의 시선', content = '<!-- wp:heading -->
<h2 class="wp-block-heading"><strong>박수형 송지연 지승배</strong></h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":16858,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/01/1-3.jpg" alt="" class="wp-image-16858" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>청화랑은 2026년 1월, 첫 전시로 <저마다의 시선〉을 선보입니다. 2023년부터 이어져 온 <저마다의 시선> 은 세 명의 작가가 한 공간에서 비슷하면서도 서로 다른 감성과 시선을 펼쳐 보이는 전시입니다. 다양한 기법과 장르를 통해 관람객에게 작가들을 다시 한 번 각인시키는 의미 있는 전시입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2026<저마다의 시선> 전시에는 지승배 송지연 박수형 세 명의 작가가 참여합니다. 세명의 작가는 홍익대 대학원 회화과 출신, 80년대생 이라는 공통점을 가지고 있습니다. 작가들에게 풍경은 재현의 대상이 아니라, 내면과 외부 세계가 교차하는 하나의 장면이자 , 감각과 기억 감정을 거친 회화적 탐구의 결과물입니다. 형태는 흐려지고 색과 리듬, 밀도는 각자의 방식으로 축적되며, 점차 개인의 언어가 됩니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":16859,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/01/KakaoTalk_20260114_142708629_01.jpg" alt="" class="wp-image-16859" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":16860,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/01/KakaoTalk_20260114_142708629_02.jpg" alt="" class="wp-image-16860" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":16861,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/01/KakaoTalk_20260114_142708629_04.jpg" alt="" class="wp-image-16861" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '청화랑' WHERE provider_type = 'PUBLIC' AND external_id = '365421';
UPDATE festival SET title = '2026 공생광장 문화예술교육 미리보기 <너그런 아트랩 & 아틀리에>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '364628';
UPDATE festival SET title = '겨울방학 특강 <성균관대학교와 함께하는 문해력 향상교실>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366686';
UPDATE festival SET title = '오페라박물관 Lecture Series <오페라 가수가 들려주는 오페라 이야기>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '364066';
UPDATE festival SET title = 'K-Arts space 전시 가로고침 《무한차원의 놂 Norms on infinite-dimensional', content = '무한차원의 놂norms on infinite-dimensional spaces참여 작가 가로고침박지원 @jiweon554조수현 @tide1h홍유라 @youryoura기획 홍유라디자인 조수현전시 기간2026. 1. 15. (목) - 2026. 1. 30. (금)월요일 휴관오프닝2026. 1. 15. (목) 18:00오프닝날은 오후 6시부터 관람이 가능합니다전시 장소k-arts space서울특별시 성북구 돌곶이로 34 (현승빌딩 2, 3층)12:00 - 18:00 (월요일 휴관)-규범(norm)은 촘촘한 그물망에 우리를 포획한다. 유용성과 효율성의 잣대로 모든 행위를 판단할 때, 삶은 스스로의 리듬을 잃어버리고 만다. 이때 가로고침은 ‘norm’을 유사한 발음으로 치환한 ‘놂’에서 규범의 전복 가능성을 발견한다. 그리고 놀이를 통해 어떠한 값도 할당되지 않은 공백(null)에 가닿기를 시도해본다. 사실, 단어를 재조합하는 ‘놂’의 순간부터 규범은 이미 해체되기 시작했다.', place = 'K-Arts Space' WHERE provider_type = 'PUBLIC' AND external_id = '365695';
UPDATE festival SET title = '[대학로] 뮤지컬 <비포어던> 리딩 쇼케이스', content = '', place = 'VERY(베리컴퍼니) 1관' WHERE provider_type = 'PUBLIC' AND external_id = '364524';
UPDATE festival SET title = 'Overlap', content = '<!-- wp:paragraph -->
<p>가나아트는 박철호(Park Chelho, b.1965)의 개인전 《Overlap》을 개최한다. 박철호는 1990년대 판화 작업을 출발점으로, 자연의 형상과 그 이면에서 작동하는 자연의 내적 원리를 지속적으로 탐구해 왔다. 초기 작업에서는 자연의 외형을 비교적 직접적으로 다루었으나, 점차 재현적 접근에서 벗어나 자연이 만들어내는 흐름과 운율을 추상적 화면으로 전환하는 데 주력해왔다. 본 전시는 초기 판화와 드로잉 작업을 비롯해 회화 연작 〈Ripple (물결)〉과 신작 〈Overlap (중첩)〉에 이르기까지 주요 작업을 아우르며, 서로 다른 매체와 형식 속에서 지속되어 온 작가의 조형적 실험과 그 사유의 궤적을 조망한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시의 중심을 이루는 신작 <Overlap (중첩)> 연작은 작가가 30여 년 전 수행했던 작업 방식과 긴밀하게 맞닿아 있다. 당시 작가는 석판 위에 분말 안료를 붓고 알코올이나 용제를 더해, 순간적으로 발생하는 화학적 반응 속에서 즉각적으로 도상을 그려냈다. 이러한 과정에서 체득된 신체적 감각은 여전히 그의 작업에 내재해 있으며, 초기의 매체 실험은 시간을 가로질러 오늘날의 신작으로 자연스럽게 이어진다. 작가는 세워진 캔버스에 안료를 흘려보내는 행위를 반복하며, 이 과정에서 선은 통제의 대상이 되기보다 중력과 물성에 반응하며 스스로 생성된다. 그는 자신의 개입을 최소화한 채 재료와 과정이 작동하도록 함으로써, 작품을 하나의 열린 장으로 남겨둔다. 그 안에서 30여 년 전의 작업 방식은 현재와 병치되고, 시간의 흔적은 화면 위에 축적되어 ‘중첩(overlap)’의 상태에 이른다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>박철호의 작업은 인간의 삶 또한 자연 일부로서 순환한다는 인식에서 출발하며, 존재의 위치를 사유하는 과정이 축적된 결과이다. 이러한 인식은 시간이 흐르며 작가라는 주체를 전면에 드러내기보다는 자연의 움직임 속으로 스며드는 방향으로 전개되어 왔다.지난 30여 년에 걸친 예술 여정은 자연의 동세를 좇아온 작가의 현재를 형성하며, 《Overlap》은 그 여정이 이른 하나의 지점을 담아낸다.</p>
<!-- /wp:paragraph -->', place = '가나아트' WHERE provider_type = 'PUBLIC' AND external_id = '365022';
UPDATE festival SET title = '강북문화재단 신년음악회: 한빛예술단 & 라포엠', content = '', place = '강북문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '362970';
UPDATE festival SET title = '창작스튜디오 8기 입주작가 결과보고전 <사라지는 순간, 남겨진 형상>', content = '', place = '팔복예술공장' WHERE provider_type = 'PUBLIC' AND external_id = '367935';
UPDATE festival SET title = '2026 궁중무용 <춘앵전> 교원연수 오픈클래스', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366685';
UPDATE festival SET title = '이혜인 & 이기상 피아노 조인트 리사이틀: La Musique de paris en Janvier', content = '', place = '아트홀제이' WHERE provider_type = 'PUBLIC' AND external_id = '365190';
UPDATE festival SET title = 'L.E.A.P', content = '<!-- wp:paragraph -->
<p>서울 인사동의 갤러리그림손에서 1월 21일부터 2월 12일까지 기획전 <L.E.A.P>를 개최 합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리그림손은 2026년 기획전시의 시작으로 < L.E.A.P > 전시를 진행합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2021년에 시작한 프로젝트 < L.E.A.P > 전시는 갤러리그림손에서 매년 선정된 신진작가들 중 활발한 전시와 작품활동을 하고 있는 작가들로 구성되었습니다. 이번 전시에 참여하는 작가들은 그 동안 갤러리그림손 신진작가를 시작으로, 이제는 현대미술에서 활발하게 자신만의 조형성과 작가의 역량을 선보이는 6명의 작가가 참여하였습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>16년 동안 시작된 많은 갤러리그림손 신진작가들이 미술시장의 여러 분야에서 작품을 선보이고 주목을 받아오면서 작가로써 도약하고 성장하는 과정을 함께 나아가고 바라보는 것은 갤러리그림손에게는 매우 고무적인 일이었습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시에서 작가들이 표현한 각자의 예술방식과 의미를 관람자들과 소통, 관계를 이어가면서 작가로써 더 더욱 나아가는 과정을 만나 볼 수 있을 것입니다.  </p>
<!-- /wp:paragraph -->', place = '갤러리 그림손' WHERE provider_type = 'PUBLIC' AND external_id = '366073';
UPDATE festival SET title = '제10회 모자이크페스티벌: 창작집단 모르Z <카페人중독 투샷>', content = '', place = '연희예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '364076';
UPDATE festival SET title = '[대학로] 저니스 엔드 (Journey''s End) ', content = '', place = '스튜디오 블루' WHERE provider_type = 'PUBLIC' AND external_id = '363459';
UPDATE festival SET title = '강상우 개인전 <환상을 휘젓는 방법 Ways of Agitating Illusions>', content = '', place = '16아카이브' WHERE provider_type = 'PUBLIC' AND external_id = '367082';
UPDATE festival SET title = '[세종] 찹아저씨 김인수 마술사의 샌드 & 쉐도우쇼 오아시스: 마술로 예술을 보다 ', content = '', place = '비오케이아트센터(BOK아트센터) 다목적공연장' WHERE provider_type = 'PUBLIC' AND external_id = '363463';
UPDATE festival SET title = '[대학로] 쉘터 ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '363795';
UPDATE festival SET title = '국립극단 2026 기획초청 Pick크닉 <셋톱박스>', content = '2020년 창작산실 대본공모 선정작! 연출이 실제 경험한 일을 심도 있게 그러나 유쾌하게 담아낸 자전적 작품 <셋톱박스>', place = '국립극단 명동예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '361844';
UPDATE festival SET title = '[세종] 국립심포니콘서트오케스트라 <브람스, 교향곡 2번>', content = '', place = '세종예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '363845';
UPDATE festival SET title = '[안산] 고유앙상블 제3회 정기연주회 ''겨울을 건너, 봄을 향해''', content = '', place = '안산문화예술의전당 달맞이극장' WHERE provider_type = 'PUBLIC' AND external_id = '365479';
UPDATE festival SET title = '강현아 개인전 <그림자 산책>', content = '', place = '일산호수공원 고양시 예술창작공간 해움새들' WHERE provider_type = 'PUBLIC' AND external_id = '366582';
UPDATE festival SET title = '[대학로] 우리 학교 운동장에는 파란 고래가 있다 ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '364521';
UPDATE festival SET title = '[부산] ''개관 팡파르'' 아르고브라스콰이어', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '363969';
UPDATE festival SET title = '정명훈 & 드레스덴 슈타츠카펠레', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '363978';
UPDATE festival SET title = '연극 <사의 찬미> ', content = '', place = '세종문화회관 세종M씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '364554';
UPDATE festival SET title = '제10회 모자이크페스티벌: NO LIMIT, yp <saramshow>', content = '', place = '연희예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '365079';
UPDATE festival SET title = '[평택] 정명훈 & 드레스덴 슈타츠카펠레 with 임윤찬 ', content = '', place = '평택아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '364192';
UPDATE festival SET title = '[부산] 어텀실내악페스티벌: 노부스 콰르텟 & Friends ', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '364217';
UPDATE festival SET title = '한국영상자료원 영화상영 <나쁜 놈일 수록 잘 잔다>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366569';
UPDATE festival SET title = '한국영상자료원 영화상영 <진흙강>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366567';
UPDATE festival SET title = '복합극 <환어>', content = '', place = '금나래아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '364194';
UPDATE festival SET title = '[성남] 고전과 낭만사이 <베토벤 ＆ 차이코프스키 ＆ 라흐마니노프>', content = '', place = '성남아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '364242';
UPDATE festival SET title = '국립극단 2026 기획초청 Pick크닉 <이상한어린이연극-오감도>', content = '2024년 초연 후, 각종 저명한 상을 휩쓸며 나타났다. 어린이와 가장 가까운 어린이연극, 어린이를 넘어 우리 모두를 향하는 섬세한 질문들!', place = '국립극단 명동예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '361845';
UPDATE festival SET title = '연극 리타길들이기 <Educating Rita> ', content = '', place = '아트하우스' WHERE provider_type = 'PUBLIC' AND external_id = '365198';
UPDATE festival SET title = '신세계 더 헤리티지 뮤지엄 설날 특별전 <길상만물>', content = '', place = '신세계백화점 본점' WHERE provider_type = 'PUBLIC' AND external_id = '367104';
UPDATE festival SET title = '[인천] 사물놀이 공감 20주년 기념 공연: 공감의 사물놀이 & 국악관현악 ', content = '', place = '인천문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '366585';
UPDATE festival SET title = '밤이 전하는 이야기 with 소프라노 오은지 & 테너 김래주 & 베이스바리톤 윤종민', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '365072';
UPDATE festival SET title = '판타지 어드벤처 가족마당 <토끼전>', content = '', place = '금나래아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '365196';
UPDATE festival SET title = '프로젝트집단 세사람 ＜멸종위기종＞- 2025 창작산실 올해의신작 연극', content = '“존재의 중요성은 누구의 시선으로 규정되는가?”', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '362098';
UPDATE festival SET title = ' 감성로코 연극 <사실은>: 만약에,우리', content = '', place = '창조소극장 (구. 민아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '366053';
UPDATE festival SET title = '복싱연극 <터치(TOUCH)>', content = '', place = '한성아트홀(구. 인켈아트홀) 1관' WHERE provider_type = 'PUBLIC' AND external_id = '365929';
UPDATE festival SET title = '구리문화재단 무대기술체험 <백스테이지 투어>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '364622';
UPDATE festival SET title = '한국영상자료원 영화상영 <여행과 나날>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '366592';
UPDATE festival SET title = '[대학로] 뮤지컬 <스톤> ', content = '', place = '예그린씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '366009';
UPDATE festival SET title = '[대학로] 위에 선 자 ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '367583';
UPDATE festival SET title = '[부산] 한정민 피아노 독주회: Image & Feeling', content = '', place = '금정문화회관 소공연장(은빛샘홀)' WHERE provider_type = 'PUBLIC' AND external_id = '366428';
UPDATE festival SET title = '2026 도민의 집 ''도민의 집에서 설레는 설날''', content = '', place = '경남도민의 집 일원' WHERE provider_type = 'PUBLIC' AND external_id = '367910';
UPDATE festival SET title = '2026 설맞이 특별행사 ''설''레는 상상, 가득한 福', content = '', place = '용인어린이상상의숲, 공생광장' WHERE provider_type = 'PUBLIC' AND external_id = '367108';
UPDATE festival SET title = '2026 설맞이 특별행사 ''설레는 과학놀이 한마당''', content = '', place = '국립광주과학관 본관 상설전시관' WHERE provider_type = 'PUBLIC' AND external_id = '367109';
UPDATE festival SET title = '[부산] 비바아첼 기획공연, 라이크앙상블과 함께하는 발렌타인데이 와인콘서트 ', content = '', place = '비바아첼 Chamber Hall & Academy' WHERE provider_type = 'PUBLIC' AND external_id = '366446';
UPDATE festival SET title = '[세종] 낭만주의 거장, 차이코프스키 & 라흐마니노프 & 신세계로부터', content = '', place = '세종예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '366068';
UPDATE festival SET title = '더 듀오 - 조소연 & 조윤경 피아노 듀오 리사이틀', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '365668';
UPDATE festival SET title = '2026 Lover’s Concert', content = '', place = '군포문화예술회관 철쭉홀' WHERE provider_type = 'PUBLIC' AND external_id = '364714';
UPDATE festival SET title = '제25회 줄리아발레아카데미 & 주니어컴퍼니 발레축제', content = '', place = '서울아트센터 도암' WHERE provider_type = 'PUBLIC' AND external_id = '368195';
UPDATE festival SET title = '건우회 제14회 정기연주회 ''Variation''', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '366308';
UPDATE festival SET title = '심아일랜드 X 와와와', content = '', place = 'KT&G 상상마당 라이브홀 [마포]' WHERE provider_type = 'PUBLIC' AND external_id = '367604';
UPDATE festival SET title = '진홍빛 소녀', content = '2025년 11월 네이버 대중문화/예술 베스트셀러 7위, 미래연극인들에게 가장 사랑받는 작품, 한민규 작,연출의 <진홍빛 소녀>', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '362101';
UPDATE festival SET title = '2026년 플루트 인포메이션 4번째 프로젝트 크리스티나 파스벤더 & 안네 카테리네 하인츠만 듀오 리사이틀', content = '', place = '예술의전당 [서울]' WHERE provider_type = 'PUBLIC' AND external_id = '366620';
UPDATE festival SET title = '2026년 문화소외계층 교육 <손끝 가야, 패총 비누 만들기>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '367921';
UPDATE festival SET title = '연극 <아빠들의 소꿉놀이> ', content = '', place = '제이원씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '367869';
UPDATE festival SET title = '포옹:포용', content = '<!-- wp:image {"align":"center","id":17553,"width":502,"height":298,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image aligncenter size-full is-resized"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/금산홈페이지.jpg" alt="" class="wp-image-17553" width="502" height="298" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>이윤정은 드로잉과 회화를 통해 일상 속 감정과 관계의 경험을 기록해 온 작가입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그의 화면에 등장하는 인물과 사물들은 구체적인 사건을 설명하기보다,</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>불안과 기대, 상처와 위로가 뒤섞인 마음의 상태를 보여주는 상징으로 기능합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>꽃, 손, 몸의 흔적과 같은 이미지들은 타인과의 관계 속에서 흔들리는 감정을 은유하며,</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>동시에 다시 연결되기를 바라는 마음을 담고 있습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 개인적인 경험에서 출발하지만,</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이를 특정한 이야기로 한정하지 않고 누구나 공감할 수 있는 감정의 풍경으로 확장시킵니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가에게 그림은 현실에서 벗어나기 위한 장치가 아니라 스스로를 지탱하고 이해하기 위한 과정입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>반복적인 드로잉은 자신을 받아들이고 마음을 회복해 가는 시간의 기록이자,</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>타인과 온기를 나누기 위한 시도이기도 합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong><포옹 : 포용></strong>은 관계 속에서 상처받고 다시 회복되는 과정을 통해 결국 자기 자신을 돌보는 일로 나아가는 이야기를 담고 있습니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 작은 희망과 다정한 상상을 통해, 관람자가 자신의 감정을 돌아보고 스스로에게 건네는 안부의 순간을 제안합니다.</p>
<!-- /wp:paragraph -->', place = '금산갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '370975';
UPDATE festival SET title = '연극 <사랑해 엄마>', content = '세대를 초월한 가족의 사랑을 담은 힐링 연극 <사랑해 엄마> ', place = '용인시문화예술회관 처인홀' WHERE provider_type = 'PUBLIC' AND external_id = '362666';
UPDATE festival SET title = '국립합창단 3·1절 기념음악회 <거룩한 함성, 그날 이후…>', content = '지난해 세계 초연으로 관객의 뜨거운 호응을 얻은 3·1절 기념음악회 <거룩한 함성, 그날 이후...>는 올해 재연을 통해 그 메시지와 감동을 다시 선명하게 전한다. 일제강점기의 억압과 저항 속에서 주인공 정옥분이 시대의 모진 시련 앞에서도 삶과 사랑을 지켜내려는 여정을 따라가며, 해방 이후에도 계속되는 삶을 통해 상처를 품은 이들이 어떻게 아픔을 넘어 희망으로 나아가는지를 그린다. 단지 과거를 재현하는 데 머물지 않고, 고통 속에서도 끝내 꺼지지 않았던 인간 내면의 외침과 존엄이 세대를 넘어 새로운 희망으로 이어지는 과정을 합창의 울림으로 증언한다.', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '368641';
UPDATE festival SET title = '낭만주의 거장, 차이코프스키 & 라흐마니노프', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '366975';
UPDATE festival SET title = '민트페스타 vol.81', content = '', place = 'KT&G 상상마당 라이브홀 [마포]' WHERE provider_type = 'PUBLIC' AND external_id = '366976';
UPDATE festival SET title = '[광주] 백설공주 & 초대형레이져쇼 ', content = '', place = '518기념문화센터 민주홀' WHERE provider_type = 'PUBLIC' AND external_id = '366955';
UPDATE festival SET title = '2026 신진작가 공모 선정전: 지금, 바로 여기 Here and now', content = '<!-- wp:paragraph -->
<p>갤러리그림손은 2026년 신진작가 공모전에 선정된 6명의 작가 김정희, 김형욱, 박정규, 민리, 조희주, 황정원 전시를 진행합니다. 매년 공모를 통해 개인전 2회 미만의 작가들 중 자신만의 스타일로 참신하고 독창적인 조형 예술성을 선보이는 작가들을 선정합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p> 이번 전시는 동시대를 살아가는 작가들의 질문과 고민, 그리고 자신만의 언어로 풀어낸 세계를 한자리에서 만나볼 수 있는 기회입니다. 익숙함을 새롭게 바라보는 시선, 경계를 넘나드는 표현 방식, 그리고 개인적 경험에서 출발해 보편적 공감으로 확장되는 이야기가 전시장 곳곳에 담겨 있습니다. 이번 전시를 통해 가능성과 잠재력을 지닌 작가들이 관객과 처음으로 깊이 있게 만나는 장을 마련하고자 합니다. 새로운 이름이 앞으로의 동시대 미술을 어떻게 확장해 나갈지, 그 출발점이 되는 순간을 함께해 보시기 바랍니다</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>김정희 작가는 한지를 이용하며 한지는 빛과 세계를 은유와 여운으로 건네는 반투명의 문턱이며, 그 섬세한 경계에서 드러남과 숨김, 안과 밖 사이의 ‘저편’을 탐구합니다. 김형욱 작가는 감각이 빚어낸 세계의 불확실성과 각자의 인식이 만든 개별적 우주 속에서 ‘완전한 실재’에 대한 의구심을 드러내며, 화면의 사각형 여백을 통해 에너지이자 공(空)의 상태를 시각화합니다. 박정규 작가는 과거의 후회와 감정들을 스스로 재정의해 배움과 추억으로 승화시키고, 점과 색의 조화를 통해 그것들이 결국 하나의 단단한 배경이 되기를 바라는 마음을 작업에 담아냅니다. 민리 작가는 내면의 감각이 외부 공간과 맞물려 형태로 드러나는 경계를 탐구하며, 빛과 상징적 이미지들이 상호작용하는 화면을 통해 관람자가 각자의 형태를 상상하도록 여지를 남기는 작업을 합니다. 조희주 작가는 사라져가는 공간과 어린 시절의 기억을 따뜻한 색과 주관적 시선으로 재해석해 ‘추억의 형상’을 기록하며, 이를 통해 위로와 노스텔지아의 감정을 전합니다. 황정원 작가는 공간이 불러일으키는 빛과 공기, 기억과 감정의 순간들을 온전히 받아들여, 각 공간이 내게 건네는 사적인 감정을 날것 그대로 작업으로 풀어냅니다.</p>
<!-- /wp:paragraph -->', place = '갤러리 그림손' WHERE provider_type = 'PUBLIC' AND external_id = '370291';
UPDATE festival SET title = '대학기록관 기획전시 <1996, 무용원 한 발>', content = '', place = '한국예술종합학교 석관동캠퍼스' WHERE provider_type = 'PUBLIC' AND external_id = '371541';
UPDATE festival SET title = '오페라박물관 Lecture Series <리하르트 바그너와 니벨룽의 반지>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '370233';
UPDATE festival SET title = '이응노의 집 공방프로그램 <이응노의 뿌리: 어린 고암의 붓 끝 서예>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '369558';
UPDATE festival SET title = '<소리내기> 워크샵 & 퍼포먼스 - <블랙홀 스파게티> 연계 프로그램', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '369692';
UPDATE festival SET title = '한국예술종합학교 3월 첫주 수요영화관 <서브스턴스>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '370104';
UPDATE festival SET title = '2026 상반기 국회어린이박물관 단체 관람 <우리들의 작은 국회>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '371596';
UPDATE festival SET title = '2026 토요명품', content = '전통 국악을 최적의 공간에서 가장 깊이 있고 다채롭게 만날 수 있는 국립국악원의 대표 주말 공연 <토요명품>한민족의 흥과 신명이 살아 숨 쉬는 노래와 음악, 춤을 비롯해세계가 인정한 유네스코 등재 무형문화유산까지.한국인과 외국인 모두 꼭 봐야할 한국의 전통 공연 예술이매주 토요일, 우면당 무대를 가득 채웁니다.대한민국 최고의 연주가들이 선사하는 <토요명품>을 통해 국악이가진 아름다움을 느껴보세요.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '368375';
UPDATE festival SET title = '극단 적 ＜내가 살던 그 집엔＞- 2025 창작산실 올해의신작 연극', content = '내가 살던 그 집엔 나는 없었다. 떠나고 싶어했던 ''엄마'', 돌아가고 싶어했던 ''마마'', 쉬고 싶었던 ''꾸엔‘, 이들을 만나며 이제 어디로 가야할지 생각하는 ''나’', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '368304';
UPDATE festival SET title = '[부산] Drop the NEWBEAT: NEURO 1000 PROJECT ', content = '', place = 'KT&G 상상마당 라이브홀 [부산] 라이브홀' WHERE provider_type = 'PUBLIC' AND external_id = '370382';
UPDATE festival SET title = '연극 <술 취한 사람들>', content = '', place = '씨어터 쿰' WHERE provider_type = 'PUBLIC' AND external_id = '369154';
UPDATE festival SET title = '｢푸른눈의 연서(戀書) – 100년 전 판화, 오늘의 한복으로 피어나다｣ 展', content = '', place = '순천창작예술촌 장안창작마당' WHERE provider_type = 'PUBLIC' AND external_id = '370988';
UPDATE festival SET title = '2026 학교연계 프로그램 <구석구석 만나는 IAP 탐험대>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '371789';
UPDATE festival SET title = '뮤지컬 <조커>', content = '', place = 'CJ아지트 대학로 (구. SM아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '369578';
UPDATE festival SET title = '일상을 건너는 시간들', content = '<!-- wp:paragraph -->
<p>비디갤러리에서는 03월 12일부터 04월 04일까지 도이, 모모킴, 이승은, 이종호 작가의 4인전인 <일상을 건너는 시간들>을 진행한다. 기억은 시간 속에서 사라지지 않고, 일상의 장면들을 통해 다시 현재로 떠오른다. 이번 전시는 우리가 지나온 시간과 지금의 삶이 어떻게 서로를 비추며 이어지는지를 조용히 바라본다. 풀잎이 흔들리는 산책길, 집 안의 사소한 사물, 어디론가 이어지는 길과 문득 떠오른 기억의 조각들까지, 평범한 순간들은 각자의 시간과 감정을 품은 풍경이 된다. 작품들은 일상의 감각을 새롭게 조명하며, 삶의 흐름 속에서 우리가 마주하는 작은 위로와 희망의 순간들을 드러낸다.</p>
<!-- /wp:paragraph -->', place = '비디 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '371896';
UPDATE festival SET title = '이정빈 개인전 <드는 것, 나는 것 그리고 곁 The Passing, Standing By>', content = '', place = '16아카이브' WHERE provider_type = 'PUBLIC' AND external_id = '370664';
UPDATE festival SET title = '홍석원 & 카메라타 안티콰 서울의 모차르트', content = '', place = 'GS아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '368477';
UPDATE festival SET title = '연극 <벙커 트릴로지 THE BUNKER TRILOGY>', content = '제1차 세계대전 참호를 배경으로 펼쳐지는 세 편의 공연!전쟁의 광기와 비극으로 숨 막히는 75분', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '368362';
UPDATE festival SET title = '[부산] F1963 겨울음악회5 마지막, 사무엘 윤 & 바그너 ', content = '', place = 'F1963 석천홀' WHERE provider_type = 'PUBLIC' AND external_id = '368554';
UPDATE festival SET title = '황윤정 첼로 독주회 ''Infinite Spectrum I - Celebrating Gubaidulina''', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '366688';
UPDATE festival SET title = '[서울] ZEROBASEONE WORLD TOUR: HERE & NOW ENCORE IN SEOUL', content = '', place = '올림픽공원 KSPO DOME(체조경기장)' WHERE provider_type = 'PUBLIC' AND external_id = '368507';
UPDATE festival SET title = '대구예술발전소 특별기획전시 <꼬레아 힙!> 전시연계프로그램 1회', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '369842';
UPDATE festival SET title = '2026 어린이 연극학교 <느낌의 반딧불>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '370067';
UPDATE festival SET title = '더블 빌 Bliss & Jakie', content = '순수한 황홀함과 관능적인 에너지가 어우러진 서울시발레단의 더블 빌 발레 공연', place = '세종문화회관 세종M씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '367371';
UPDATE festival SET title = '창밖의 비창 Pathétique beyond the Pane : 김이안 피아노살롱', content = '', place = '서울숲 스튜디오301 Studio301' WHERE provider_type = 'PUBLIC' AND external_id = '369353';
UPDATE festival SET title = '더 베스트 무비 OST 콘서트 with 팬텀 <진원, 존노, 김현수>', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '368476';
UPDATE festival SET title = '[수원] 양인모 & 잘츠부르크 모차르테움 오케스트라 ', content = '', place = '경기아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '368813';
UPDATE festival SET title = '서촌마치 <르 쁘띠 앙상블> 키즈 클래식', content = '', place = '크레디아 클래식 클럽' WHERE provider_type = 'PUBLIC' AND external_id = '368812';
UPDATE festival SET title = '2026 스타인웨이 위너콘서트 <이판 우 리사이틀>', content = '제65회 페루초 부소니 국제 피아노 콩쿠르 우승자 ''이판 우(YIFAN WU) 리사이틀''', place = '용인포은아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '368438';
UPDATE festival SET title = '양인모 & 잘츠부르크 모차르테움 오케스트라', content = '바이올리니스트 양인모와 잘츠부르크 모차르테움 오케스트라가 선사하는 모차르트, 베토벤 명작 무대', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '371014';
UPDATE festival SET title = '나다솜 피아노 독주회 <Palette : Red>', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '366306';
UPDATE festival SET title = '살롱클래식, 이은선 & 리즈 문: 포레(Gabriel Faure)의 봄', content = '', place = '라율아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '370413';
UPDATE festival SET title = '[이천] 마티네콘서트, 이응광의 음악공방 2nd, 피아니스트 성해린 & 피아니스트 이선호', content = '', place = '이천아트홀 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '369488';
UPDATE festival SET title = '대학(원)생 대상 전시 연계 교육 <서화무진, 한국화를 다시 묻다>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '373647';
UPDATE festival SET title = '잠시, 여기에', content = '<!-- wp:paragraph -->
<p>갤러리FM은 2026년 3월16일부터 31일까지 전영진·이시현 2인전  《잠시, 여기에》를 개최한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>우리는 매일 수많은 풍경을 마주하지만 대부분의 장면은 오래 머무르지 않은 채 스쳐 지나간다. 빠르게 흘러가는 시간 속에서 풍경은 하나의 이미지처럼 소비되고, 우리는 그것을 천천히 바라볼 기회를 잃어버리기도 한다. 그러나 어떤 순간, 우리는 발걸음을 멈추고 그 자리에 잠시 머문다. 《잠시, 여기에》는 이러한 흐름 속에서 잠시 멈추어 풍경을 다시 바라보는 순간에서 시작된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전영진의 작업에서 풍경은 자연을 재현하기 위한 대상이 아니라 회화의 구조와 본질을 드러내기 위한 장치로 등장한다. 화면 속 풍경은 색과 면의 기하학적 구성으로 단순화되며, 분할된 색면들은 마치 픽셀처럼 화면을 구성하며 절제된 회화적 구조를 형성한다. 이러한 단순화는 자연의 장면을 색과 면의 관계 속에서 다시 바라보게 하며, 관람자는 화면 속 풍경을 바라보는 동시에 회화 자체를 인식하게 된다. 전영진의 단순한 풍경은 복잡한 세계 속에서 잠시 시선을 멈추게 하며, 풍경을 바라보는 우리의 감각을 다시 환기시킨다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이시현의 작업은 자연 속에서 몸이 경험한 감각에서 출발한다. 작가는 도시의 질서에서 벗어나 자연 속으로 들어가며 그 안에서 마주하는 에너지와 감각을 화면 위에 남긴다. 작가에게 자연은 단순히 바라보는 대상이 아니라 감각이 깨어나는 경험의 장이며, 몸으로 체득한 감각과 온도를 통해 풍경이 형성된다. 화면 위에 남겨진 거친 질감과 물성은 자연의 촉각적 경험을 환기시키며, 관람자는 풍경을 바라보는 동시에 그 안에 잠시 머무르게 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>두 작가는 서로 다른 방식으로 풍경을 다루지만, 작품 앞에서 우리는 하나의 공통된 경험을 마주하게 된다. 전영진의 풍경이 단순한 색과 면의 구조 속에서 시선을 멈추게 한다면, 이시현의 풍경은 자연의 감각 속에서 몸을 머물게 한다. 서로 다른 두 방식의 풍경은 우리가 지나쳐왔던 장면을 다시 바라보게 하며, 풍경 앞에서 잠시 머무는 시간을 만들어낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>《잠시, 여기에》는 빠르게 흘러가는 시간 속에서 잠시 멈추어 풍경을 바라보는 순간을 제안하는 전시이다. 작품 앞에 선 우리는 익숙했던 장면을 다시 바라보며, 지금 이 자리에서 새로운 감각과 시선을 발견하게 된다.</p>
<!-- /wp:paragraph -->', place = '갤러리FM' WHERE provider_type = 'PUBLIC' AND external_id = '372098';
UPDATE festival SET title = '네오 유니버스, MAHAGÖNNY: THE 5 CARDS', content = '', place = '브릭스씨어터 (구. 콘텐츠 그라운드 구. 브로드웨이아트홀 [3관])' WHERE provider_type = 'PUBLIC' AND external_id = '370532';
UPDATE festival SET title = '머더: 나는 오늘, 사람을 죽였다. ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '370006';
UPDATE festival SET title = '한국예술종합학교 3월 셋째 주 수요영화관 <그녀>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '371977';
UPDATE festival SET title = '김은미 개인전 - 옻+칠', content = '<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17710,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/KakaoTalk_20260319_122602507_01-복사본.jpg" alt="" class="wp-image-17710" /><figcaption class="wp-element-caption"><em>토포하우스 제1전시실</em> </figcaption></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><옻+칠 작가노트></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>"옻은 나에게 재료이기 이전에 행위다.<br>붓을 대고, 마르고, 다시 올리고, 기다리는 반복 속에서 표면은 만들어진다.<br>나는 결과보다 그 이전에 존재하는 시간의 축적에 주목한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작업은 하나의 완결된 이미지라기보다, 미세한 행위들이 겹쳐 형성된 흔적에 가깝다.<br>칠해지는 순간보다 마르는 시간, 덮이는 층보다 남아 있는 간극이 작업의 중심이 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>보이지 않는 시간은 표면 아래에서 밀도를 만들고,<br>그 밀도는 빛과 색을 통해 드러난다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>색과 금, 그리고 옻의 층은 물질적 깊이를 넘어 시간의 깊이를 만든다.<br>빛은 단순히 반사되는 것이 아니라, 축적된 시간 위에서 발생한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>관객이 마주하는 것은 하나의 화면이 아니라,<br>지나온 시간의 단면이다."</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17715,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/KakaoTalk_20260319_122602507_02-복사본.jpg" alt="" class="wp-image-17715" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":17714,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/KakaoTalk_20260319_115153377_02-복사본.jpg" alt="" class="wp-image-17714" /></figure>
<!-- /wp:image -->', place = '토포하우스' WHERE provider_type = 'PUBLIC' AND external_id = '372639';
UPDATE festival SET title = '제24회 한국예술종합학교 미술원 조형예술과 예술전문사과정 졸업전시회 개최', content = '〈2026년도 제4회 한국예술종합학교 미술원 조형예술과 예술전문사과정 졸업전시회 〉개최 안내ㅇ 장소 : k-arts 갤러리 / k-arts spcaeㅇ 일시 : 2026.03.18.(수)-04.10.(금)      1차 : 2026.03.18.(수)-03.26.(금) / 2차 : 04.01.(수)-04.10.(금)ㅇ 시간 : 일요일 휴무 제외, 매일 오전 11시-오후 7시 /      단, 전시 종료일인 03.26.(금), 04.10.(금)은 17:00까지 운영ㅇ 주관 : 한국예술종합학교 미술원 조형예술과ㅇ 참여작가      1차 k-arts 갤러리 : 김민경, 박원근, 양윤석, 이동원, 이인혜, 최호영, 황효덕      1차 k-arts space : 김현철, 신석호, 한봄      2차 k-arts 갤러리 : 김규상, 박소현, 손지혜, 이준학, 조무현, 최용혁      2차 k-arts space : 김루이, 성의석, 최인영                                                                            2026년 재24회를 맞이한 ''조형예술과 예술전문사 졸업전시회"로 학생들의 작품 전시를 통해 교육성과를 홍보하고,대내외적으로 학생들의 작품을 널리 홍보하고자 합니다.전시는 학교 k-arts 갤러리와 k-arts space에서 두 차례 기간으로 나누어 동시 개최하며,1차는 3월 18일(수)뿌터 27일(금)까지, 2차는 4월 1일(수)부터 4월 10일(금)까지 전시가 진행됩니다.학교 k-arts 갤러리에서는 1차-김민경, 박원근, 양윤석, 이동원, 이인혜, 최호영, 황효덕 졸업생,2차-김규상, 박소현, 손지혜, 이준학, 조무현, 최용혁 졸업생의 작품을 선보이며,k-arts space에서는 1차-김현철, 신석호, 한봄 졸업생, 2차-김루이, 성의석, 최인영 졸업생의 작품이 전시됩니다.회화, 조각, 설치, 사진, 영상 작품 등 다양한 매체의 작품을 선보입니다.많은 관심과 참여 부탁드립니다.', place = 'K-Arts Space' WHERE provider_type = 'PUBLIC' AND external_id = '378171';
UPDATE festival SET title = '[대학로] 연극 <고등어> ', content = '', place = '씨어터조이 (구. 마당세실극장)' WHERE provider_type = 'PUBLIC' AND external_id = '371865';
UPDATE festival SET title = '연극 <키리에>', content = '제 60회 동아연극상 3관왕 수상작 죽어서 집이 되어버린 사람, 그 안으로 찾아온 기적같은 사랑의 이야기', place = '국립정동극장 세실' WHERE provider_type = 'PUBLIC' AND external_id = '367734';
UPDATE festival SET title = '2026 서울시향 얍 판 츠베덴의 말러 교향곡 6번 ''비극적'' ①, ②', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '367820';
UPDATE festival SET title = '픽셀 킴 <비행을 위한 기도>', content = '', place = '노화랑' WHERE provider_type = 'PUBLIC' AND external_id = '372158';
UPDATE festival SET title = '까치 아미 : within movement', content = '<!-- wp:image {"align":"center","id":17739,"width":590,"height":423,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image aligncenter size-full is-resized"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/IMG_5887.jpg" alt="" class="wp-image-17739" width="590" height="423" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>이번 전시 <까치 아미 : within movement> 에서 고아빈 작가는 오랜 시간 눈길을 머물러온 ‘까치’라는 존재, 그리고 두 눈썹 사이를 가리키는 순우리말 ‘아미’가 품고 있는 경계와 틈새의 감각을 한 올 한 올 정성스럽게 짜 올립니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작품 서사의 중심에 선 까치는, 별다른 예고 없이 일상의 중심부에 불쑥 등장합니다. 흔하디 흔한 산책길에서 마주친 까치는, 단 한 번의 날갯짓으로 작가의 시선을 송두리째 흔들어 놓습니다. 평소엔 흑백의 무채색으로만 기억되던 새의 깃털 사이로, 어쩌면 감춰져 있던 총천연색의 푸르름과 높이 날아오르는 생동감이 퍼져 나옵니다. 익숙함에 가려 몰랐던 세계, 우리가 미처 발견하지 못한 이면의 생명력이 눈앞에 모습을 드러내는, 경이롭고도 아찔한 순간이었습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시를 통해 고아빈 작가가 일상에서 포착한 사적인 순간들을 바탕으로 표현한 까치의 형상과, 그 안에 녹아든 경계의 감각을 직접 느껴볼 수 있습니다. 이번 전시가 각자에게 세상을 조금 다르게 바라볼 수 있는 새로운 시선이 되고, 익숙한 일상 속에 숨어 있던 저마다의 ''까치''를 발견하는 시간이 되길 바랍니다.</p>
<!-- /wp:paragraph -->', place = '금산갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '373156';
UPDATE festival SET title = '연극 <나의 아저씨>', content = '', place = '인천서구문화회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '369630';
UPDATE festival SET title = '뮤지컬 <렘피카>', content = '', place = '코엑스아티움(Coex Artium)' WHERE provider_type = 'PUBLIC' AND external_id = '369067';
UPDATE festival SET title = '[대전] 지브리 & 디즈니 OST 콘서트 ', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '369291';
UPDATE festival SET title = '[수주문학관] 책과 함께 잠시 기대어 쉬는 곳, 수주 북클럽 <그늘>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '371787';
UPDATE festival SET title = '"충북도청이 새롭게 태어납니다" 「그림책정원1937」 곧 문 열어요!', content = '', place = '그림책정원1937(옛 충북도청 본관)' WHERE provider_type = 'PUBLIC' AND external_id = '371764';
UPDATE festival SET title = '국립합창단 제206회 정기연주회 창작 합창음악극 <어느 봄날의 꿈>', content = '작곡가 이성준(Brandon Lee)의 음악이 김솔지의 대본을 만나 마법 같은 경험을 선사한다.  아직 찬 바람이 머무는 봄밤, 외로운 소년의 상상이 웅장한 합창과 넘버로 무대 위에 살아난다. <벤허>, <프랑켄슈타인>, <베르사유의 장미>, <비밀의 화원>, <한복입은 남자> <메리셸리> 책 속 장면들이 눈앞에 생생하게 그려지며 소년의 잠들었던 여러 감정을 깨워간다. 두려움, 분노를 지나 슬픔과 사랑까지  마음의 결을 넓혀간 소년은 마침내 닫혀 있던 세상으로 한 걸음 내딛을 용기를 얻는다.', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '368642';
UPDATE festival SET title = '[원주 갤러리 원] 오얏 개인전 ''Dreaming''', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '373572';
UPDATE festival SET title = '2026년 부산박물관 테마특별전 <부산 개항 150년: 바다를 건너간 녀석들>', content = '', place = '부산시립박물관' WHERE provider_type = 'PUBLIC' AND external_id = '373046';
UPDATE festival SET title = '뮤지컬 <로미오와 줄리엣> ', content = '', place = '한전아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '369492';
UPDATE festival SET title = '[한성백제박물관] 초등 4~6학년 단체 대면 교육 <한강삼국지: 삼국의 한강 쟁탈전>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '368367';
UPDATE festival SET title = '[한성백제박물관] 초등 4~6학년 단체 비대면 교육 <한강삼국지: 삼국의 한강 쟁탈전>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '368368';
UPDATE festival SET title = '2026 다담', content = '2월부터 11월까지 매월 마지막 주 수요일 오전 11시에는 국악과 차, 그리고 이야기가 함께하는 <다담>이 열립니다.다담지기 황수경 아나운서의 진행으로 예술같은 삶을 살고 있는사회 각 분야의 저명 인사를 초청해 이야기와 우리 음악을 나누는토크 콘서트 입니다.진솔한 삶의 이야기에 더해지는 우리 음악 한 잔!오전의 설레이는 햇살 같은 특별한 시간을 느껴보세요.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '368377';
UPDATE festival SET title = '[울산] 뮤지컬로 보는 동화 3월 <백설공주> ', content = '', place = '온양문화복지센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '370194';
UPDATE festival SET title = '2026년 <밤풍경> 특별전 연계 교사 프로그램', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '371274';
UPDATE festival SET title = '한국예술종합학교 3월 넷째 주 수요영화관 <그저 사고였을 뿐>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '372448';
UPDATE festival SET title = '2026년 내포 힐링 아카데미 <온도락>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '370888';
UPDATE festival SET title = '연극 <노인의 꿈>', content = '세상 힙한 할머니 ''춘애''의 인생 마지막 프로젝트가 시작된다. 지금 당신의 꿈은 안녕하신가요?', place = '춘천문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '368264';
UPDATE festival SET title = '연극 <그때도 오늘2: 꽃신>', content = '각기 다른 시대와 장소에서 이어지는 4개의 에피소드여성 2인극으로 새롭게 돌아온 <그때도 오늘>, 그 두 번째 이야기', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '368364';
UPDATE festival SET title = '대구예술발전소 특별기획전시 <꼬레아 힙!> 전시연계프로그램 2회', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '369843';
UPDATE festival SET title = '[부산] NAC시그니처클래식: 심포니5번 & 코랄시리즈Ⅰ', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '369869';
UPDATE festival SET title = '[인천] 클래식시리즈, 산책 Ⅰ. 박규희 & 양방언 듀오 콘서트: 두 개의 빛', content = '', place = '인천동구문화체육센터 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '369903';
UPDATE festival SET title = '[광주] MelON 지브리 & 뮤지컬 갈라 오케스트라 콘서트 ', content = '', place = '광주예술의전당 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '369942';
UPDATE festival SET title = '박일광 초대전 <찾아헤맨 모든 꿈>', content = '', place = '영암군립 하정웅미술관 창작교육관' WHERE provider_type = 'PUBLIC' AND external_id = '372787';
UPDATE festival SET title = '2026 성남큐브미술관 동시대미감전 <김덕용: 빛과 결, 自生之美>', content = '', place = '성남큐브미술관' WHERE provider_type = 'PUBLIC' AND external_id = '377627';
UPDATE festival SET title = '백건우&슈베르트', content = '거장의 오늘, 슈베르트로 흐르다. 백건우가 열어가는 또 하나의 여정', place = '춘천문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '368265';
UPDATE festival SET title = '소요유_ 逍遙遊', content = '<!-- wp:paragraph -->
<p>곽남신 작가는 형식주의 모더니즘에서 주장했던 평면성과 매체의 물성, 거기서 발생하는 예술의 전통을 버리지 않습니다. 일상적인 이미지들, 주변의 환경, 사회와 대중문화가 생산하는 자본주의적 부산물들을 포함한 인간들의 아이러니한 삶을 소재로 담아냅니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>소요유(逍遙遊)는 문자 그대로 ‘노닐 소(逍)·노닐 요(遙)·놀 유(遊)’로, 어떤 것에도 얽매임 없이 자유롭게 노니는 정신을 말합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>곽남신 작가의 <소요유_ 逍遙遊>를 관람하시는 동안, 잠시 일상의 무게를 내려놓고, 어떤 것에도 얽매이지 않은 채 자유롭게 거니는 시간을 가져보시길 바랍니다. 마음이 머무는 곳마다 진정한 ''소요유''의 경험이 깃들 전시에 많은 관심 부탁드립니다.</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul><!-- wp:list-item -->
<li>참여작가 | 곽남신</li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li>전시장소 | 서울시 용산구 유엔빌리지길 24 1F, B1F</li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li>기간 | 2026. 3. 31 - 2026. 5. 15</li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li>관람시간 | 화-토 11AM - 6PM</li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li>문의 | T. +82 02.795.0046 / E. fillgallery@naver.com</li>
<!-- /wp:list-item --></ul>
<!-- /wp:list -->', place = '필 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '377605';
UPDATE festival SET title = '2026 중랑청소년문화예술창작센터 청소년운영위원회 <아트틴즈>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '370663';
UPDATE festival SET title = '2026 국립정동극장 예술단 <광대>', content = '1902년 12월 2일 막 올랐던 최초의 유료공연 <소춘대유희>120년 전 무대를 모티브로 새로운 <소춘대유희>를 다시 올리려는 예술단장 순백과 단원 모두리의 고군분투 하룻밤이 펼쳐진다!', place = '국립정동극장' WHERE provider_type = 'PUBLIC' AND external_id = '367733';
UPDATE festival SET title = '안애순 컴퍼니 <춤이 말하다: 문소리Ｘ리아킴>', content = '배우 문소리, 안무가 리아킴 두 아티스트가 ''말''과 ''춤''이라는 언어로 풀어내는 신체와 감각의 에너지를 공유하는 새로운 무대', place = '강동아트센터 소극장 드림' WHERE provider_type = 'PUBLIC' AND external_id = '368154';
UPDATE festival SET title = '머스탱과 개꿈', content = '꿈의 감각을 통해 언어 너머의 정서를 탐구하는 정록이 안무가의 ''개꿈''과 야생마 머스탱에 빗대어 자유의 본질적 의미를 재해석하는 정재우 안무가의 ''머스탱''까지 남다른 시선과 새로운 감각으로 펼치는 신진 안무가들의 더블 빌 <머스탱과 개꿈>.', place = '예술의전당 CJ 토월극장' WHERE provider_type = 'PUBLIC' AND external_id = '367154';
UPDATE festival SET title = '서윤정 개인전_형태의 변주', content = 'Spectrum in shapeYOUNJEONG SEO Textile Design Exhibition서윤정 텍스타일디자인전2026.4.3.FRI-4.12.SUN 10:00-19:00(월요일 휴관)예술의전당 한가람미술관 제7전시실                                           Specterum in shape / 93x93cm / 작가고유기법 / 2026                                                                Specterum in shape / 93x93cm / 작가고유기법 / 2026                                                           Specterum in shape / 93x93cm / 작가고유기법 / 2026     Detile View   <작품설명>Spectrum in shape형태의 변주작가는 한국적인 사물에서 모티브를 발견하고 선과 구조의 반복을 통해 그 안에 내재된 조형적 특징과 의미를 탐구하고 있다. 최근 작업에서는 도자기의 실루엣에서 발견되는 다양한 곡선에 주목하여 서로 다른 선들이 반복, 중첩되는 패턴에서 리듬과 화음을 찾아내고 있다.이러한 형태적 탐구는 자수, 자카드 직조, 프린팅과 같은 다양한 텍스타일 표현기법을 통해 발현된다. 도자기의 형태는 투명한 노방 위에 중첩되며, 반투명한 원단이 겹쳐질 때 색은 서로 스며들어 미묘한 색의 스펙트럼을 만들어낸다. 또한 원단과 원단 사이에 형성되는 공간은 빛의 투과와 색의 농도에 따라 변화되어 또다른 시각적 층위를 형성한다.교차하고 겹쳐지는 선과 색, 그리고 그 사이의 공간 속에서 형태는 하나의 스펙트럼으로 확장된다.<작가소개> 학력 홍익대학교 미술대학 섬유미술과 학사홍익대학교 일반대학원 섬유미술과 석사FIT, Fashion Merchandising Management 수학, New York홍익대학교 디자인공예학과 박사개인전2008 서윤정 드로잉전 (갤러리가이아, 서울)2011 Facets of View (한전아트센터 갤러리, 서울)2016 Layers of Illusion (가나아트스페이스, 서울)2017 Layers of Illusion (유나이티드갤러리, 서울)2021 E’stro 한글 (예술의전당 한가람미술관, 서울)2023 Inside Pattern (갤러리반포대로5, 서울)2024 Waves of Illusion (예술의전당 한가람미술관 제7전시실, 서울)2024 환상의결x유금와당박물관 중국전돌전 (유금와당박물관, 서울)2026 Spectrum in Shape (예술의전당 한가람미술관 제7전시실, 서울)현재홍익대, 이화여대, 국민대, 덕성여대 출강', place = '예술의전당(한가람미술관)' WHERE provider_type = 'PUBLIC' AND external_id = '374436';
UPDATE festival SET title = '서울시향&얍 판 츠베덴의 차이콥스키 교향곡 5번', content = '얍 판 츠베덴과 서울시향이 선사하는 관현악의 정수', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '368366';
UPDATE festival SET title = '[춘천] 백건우 피아노 리사이틀: 백건우 & 슈베르트', content = '', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '371495';
UPDATE festival SET title = '한국예술종합학교 4월 셋째 주 수요영화관 <바톤 핑크>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '375307';
UPDATE festival SET title = 'The Blade of the Forest Within', content = '<!-- wp:paragraph -->
<p>가나아트는 일본 현대미술계에서 주목받는 여성 작가 가와우치 리카코(Kawauchi Rikako, b.1990)의 국내 첫 개인전 《The Blade of the Forest Within》을 개최한다. 가와우치는 신체와 정신, 내부와 외부 사이의 경계를 탐구하는 작업을 지속해왔으며, 강렬한 색채와 두터운 마티에르를 긁어내 형상을 구축하는 방식을 통해 고유의 조형 언어를 드러낸다. 이번 전시는 작가가 2023년 가나아트센터에서 열린 그룹전에 참여한 이후 국내에서 처음 선보이는 개인전으로, 대형 신작을 포함한 회화와 드로잉 30여 점을 가나아트 한남과 가나아트 남산 두 공간에 걸쳐 선보인다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>가와우치의 회화에는 과일과 채소, 야자수, 재규어와 개미핥기, 심장과 같은 장기, 부유하는 머리에 이르기까지 이질적인 형상들이 단일한 장면 안에 병치되며 구성된다. 이때 식물의 줄기와 뿌리는 근육이나 핏줄을, 동물의 형상은 인간의 장기를 연상시키며 서로 다른 신체 감각을 교차시킨다. 이러한 형상들은 적색 계열의 물감과 안료를 거칠게 얹어 밀어 올린 화면 속에서 서로 맞물리며, 그것이 숲의 풍경인지 혹은 신체의 내부인지 가늠하기 어려운 경계가 모호한 하나의 공간을 형성한다. 이처럼 가와우치는 몸의 내면을 거대한 야생의 ‘숲’과 같은 공간으로 바라본다. 전시 제목 《The Blade of the Forest Within》은 이러한 운동에 깃든 힘과 그 안에 잠재된 날것의 강인함을 함축한다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>두 공간에서 동시에 진행되는 이번 개인전은 서로 다른 접근을 통해 작가의 작업을 입체적으로 조망한다. 가나아트 한남에서는 작가가 집중하고 있는 신체 내부의 순환과 자연의 이미지에 주목하며, 이를 회화적으로 풀어낸 작업이 중심을 이룬다. 한편 가나아트 남산에서는 신체의 외부, 즉 타자와의 관계 속에서 형성되고 인식되는 존재로서의 신체에 주목한다. 두 공간은 신체 내부의 감각과 외부와의 관계라는 상이한 층위를 따라 전개되지만, 그 경계가 흐려지는 지점을 향한 가와우치의 시선은 일관되게 이어진다. </p>
<!-- /wp:paragraph -->', place = '가나아트' WHERE provider_type = 'PUBLIC' AND external_id = '374163';
UPDATE festival SET title = '[고양] 지브리 & 디즈니 콘서트 ', content = '', place = '고양아람누리 아람음악당' WHERE provider_type = 'PUBLIC' AND external_id = '370797';
UPDATE festival SET title = '[대전] 국립오페라단 모차르트 오페라 <마술피리>', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '370804';
UPDATE festival SET title = '조수현 개인전 <일상의 밀도, 사소함의 결>', content = '', place = '비커밍갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '373667';
UPDATE festival SET title = 'SBS ''교양이를 부탁해'' 오픈캠퍼스 특강', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '373928';
UPDATE festival SET title = '포르테피아노와 함께하는 최연우 바이올린 독주회 "선율의 기억 From Elegance to Emotion" [Recital II] 시간의 실루엣 ', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '370308';
UPDATE festival SET title = '제40회 한국무용제전 ＜The Path, 몸의 궤적＞', content = '‘한국무용제전’은 1985년 시작된 이래로 한국춤계의 선구적인 역할을 하는 춤축제로서 주목받으며 전통에 기반한 한국창작춤 발전에 기여하고 있습니다. 한국창작춤을 통한 전통문화 계승을 도모하며 대한민국 한국무용계의 유수 안무가 인재 발굴에 앞장서는 축제입니다. 2026년 40주년 제전은 <The Path, 몸의 궤적>을 대주제로 선정하여 미래의 화두로 떠오르는 신체, 그리고 춤의 원형이 되는 몸의 감각을 되짚고자 합니다. 한국적 움직임의 정체성과 동시대적 감수성을 새롭게 길어 올리는 축제가 될 것입니다.', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '368355';
UPDATE festival SET title = '2026 안전 연극제: 면역력 <이제야 조금 안심이 된다>', content = '', place = '연극실험실 혜화동1번지' WHERE provider_type = 'PUBLIC' AND external_id = '372824';
UPDATE festival SET title = '한국 근현대미술 속 광주를 읽다 ''근대를 열다: 시각 체계의 변화''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '373002';
UPDATE festival SET title = '한 점의 시작, ‘봄, 소품’展', content = '<!-- wp:paragraph -->
<p><strong>강준영, 권지안, 권하나, 박서보, 손진형, 신지아, 음하영, 잠산, 최영욱, 최하나, 콰야, 허필석</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>The First Piece of Your Collection</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>April 9 – May 16, 2026</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>OPENING HOURS l TUE-SAT 10:00 AM-6:30 PM</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":18111,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/04/봄소품_포스터이미지-2.png" alt="" class="wp-image-18111" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong>한 점의 시작, </strong><strong>‘</strong><strong>봄, 소품’</strong><strong>展</strong><strong><br></strong><strong>The First Piece of Your Collection</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리위(Gallery We)는 오는 4월 9일부터 소품 기획전 ‘봄, 소품’展을 선보인다. 이번 전시는 The First Piece of Your Collection이라는 메시지 아래, 컬렉션의 출발점이 되는 ‘첫 한 점’에 집중한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작품을 감상하는 데서 나아가 자신의 취향에 맞는 한 점을 선택하는 순간, 그 선택은 곧 컬렉션의 시작이 된다. 이번 전시는 이러한 출발을 가장 적절한 시점에서 제안한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시는 소품을 중심으로 구성하되 일부 중형 작품을 함께 선보이며, 크기와 표현의 스펙트럼을 확장한다. 공간에 부담 없이 놓을 수 있는 규모이면서도 충분한 완성도와 존재감을 갖춘 작업들로 이루어져 있으며, 한 점의 작품은 공간의 분위기를 바꾸고 취향을 선명하게 드러내는 가장 직접적인 방식이 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>특히 이번 전시는 합리적인 가격대 안에서 높은 완성도를 갖춘 작품들로 구성되어, 첫 컬렉션을 시작하기에 현실적이면서도 효과적인 선택지를 제시한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시에는 <강준영, 권지안, 권하나, 박서보, 손진형, 신지아, 음하영, 잠산, 최영욱, 최하나, 콰야, 허필석> 등 12인의 작가가 참여한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>서로 다른 세대의 작가들이 한자리에 모여 각기 다른 작업 세계와 감각이 교차하며, 이들은 현재 미술 시장에서 꾸준한 수요와 높은 선호도를 기반으로 컬렉터층을 빠르게 확장하고 있는 작가들로, 지금 시점에서 주목해야 할 작업들이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 단순한 감상을 넘어, 지금 선택해도 좋은 작업들을 직접 확인하고 결정할 수 있는 자리다. 컬렉션의 시작을 고민하고 있다면 더없이 적절한 타이밍이 될 것이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리위는 이번 전시가 작품 한 점을 선택하는 경험을 통해 각자의 취향을 발견하고 확장하는 출발점이 되기를 기대한다. ‘봄, 소품’展은 그 시작을 가장 현실적이고 확실한 방식으로 제안한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>GALLERY We 수지ㅣ031-266-3266</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>gallerywe@gallerywe.com</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>www.gallerywe.com</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>경기도 용인시 수지구 호수로 52번길 25-17</p>
<!-- /wp:paragraph -->', place = '갤러리위' WHERE provider_type = 'PUBLIC' AND external_id = '377434';
UPDATE festival SET title = '《슈태테바우 – 도시의 DNA 읽기(Städtebau – Decoding Urban DNA)》', content = '', place = '갤러리 지하' WHERE provider_type = 'PUBLIC' AND external_id = '374626';
UPDATE festival SET title = '[대학로] 벼랑끝에서 ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '371939';
UPDATE festival SET title = '리브 어 라이브', content = '〈리브 어 라이브 (Live-A-Live)〉는 전쟁, 노동, 예술, 자본이 서로를 비추며 얽혀 있는 세계 속에서 ‘살아 있음’의 의미를 묻는 세 개의 이야기이자, 공존을 향한 연작 드라마다.', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '368356';
UPDATE festival SET title = '2026 함석헌기념관 사상강좌 ‘평화로 깃들다’', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '372450';
UPDATE festival SET title = '2026 대한민국 문화도시 통영 뮤직웨이브 ''리베란테''', content = '', place = '통영 강구안 해상무대' WHERE provider_type = 'PUBLIC' AND external_id = '374794';
UPDATE festival SET title = '2026 KT&G 상상실현 페스티벌', content = '', place = 'KT&G 상상마당 춘천' WHERE provider_type = 'PUBLIC' AND external_id = '374105';
UPDATE festival SET title = '르 보야즈 보칼레 앙상블과 함께 하는 바로크 음악 여행 시리즈 ⅩⅠ. 오페라의 시작, 바로크 & 모짜르트', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '371828';
UPDATE festival SET title = '안전 연극제: 면역력 <라스트 댄스 @ 보광떡방앗간> 떡사랑사랑같이자유기념박수', content = '', place = '연극실험실 혜화동1번지' WHERE provider_type = 'PUBLIC' AND external_id = '376330';
UPDATE festival SET title = '[대전] 이정호 & 부산청년국악관현악단, 웨이브x: 송현민의 국악 내비게이션 ', content = '', place = '대전시립연정국악원 큰마당' WHERE provider_type = 'PUBLIC' AND external_id = '371626';
UPDATE festival SET title = '[대전] 베토벤 & 라흐마니노프 ', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '371659';
UPDATE festival SET title = '아카데미 열정과 나눔 RE & NEW 프로젝트3 "대립과 화합 I"', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '370503';
UPDATE festival SET title = '이디오마 델라 무지카 정기연주회 ''Telemann Fantasia''', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '369422';
UPDATE festival SET title = '[인천] 제97회 인천시립극단 정기공연: 니들이 인천을 알어¿!', content = '', place = '인천문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '372045';
UPDATE festival SET title = '하피스트 우지현 & 피아니스트 전유진 듀오 리사이틀', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '371598';
UPDATE festival SET title = '[광주] 지브리 & 디즈니 영화음악 오케스트라 콘서트', content = '', place = '광주예술의전당 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '371851';
UPDATE festival SET title = '2026 성북문화예술교육센터 <오늘도 예술로> 봄 시즌 프로그램 참여자 모집', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '375359';
UPDATE festival SET title = '2026 심산영화관 <로마의 휴일>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '373904';
UPDATE festival SET title = '2026 안전 연극제: 면역력 <소거된 몸짓: 연극in 미게재 희곡 작가 페스티벌 >', content = '', place = '연극실험실 혜화동1번지' WHERE provider_type = 'PUBLIC' AND external_id = '372929';
UPDATE festival SET title = '한국인의 이상향Ⅱ', content = '“한국인의 이상향 II” - 제19회 사단법인 우리민화협회 정기회원전 (사)우리민화협회는 2007년 설립된 비영리법인으로, 민화의 저변 확대를 위해 힘써왔으며 국내외 전시를 통해 다양한 교류 활동을 이어오고 있습니다.2026년 제19회 정기회원전에는 106명의 회원이 참여하여, 한국 전통예술인 민화의 전통성과 우수성을 조명하는 뜻깊은 자리를 마련하였습니다.<!--[if !supportEmptyParas]--><!--[endif]-->「한국인의 이상향 II」 전시는 약 200여 년의 역사를 이어온 민화가 오늘을 살아가는 우리의 삶을 더욱 풍요롭고 의미 있게 만드는 예술 장르로 자리매김했음을 보여주고자 합니다. 나아가 세계 속에서 주목받는 민화의 아름다움과 한층 성숙해진 예술적 깊이를 선보입니다.<!--[if !supportEmptyParas]--><!--[endif]-->이번 전시는 우리의 삶과 사회상을 반영한 현대민화를 통해 민화를 보다 쉽게 이해하고, 동시대 미술로서의 가치를 체감할 수 있는 장(場)을 지향합니다. <!--[if !supportEmptyParas]--><!--[endif]-->옛 선비들의 학문적 열망과 염원을 담은 책거리, 자연의 아름다움을 담아낸 화훼도, 그리고 장수·건강·복을 기원하는 다채로운 작품들이 과거와 현재를 아우르며 현대민화의 새로운 매력을 전합니다. 또한 족자와 액자 작품을 비롯해 가구, 병풍 등의 대형 작품과 도자·섬유 작품까지 폭넓게 소개하며, 다양한 아트 상품도 함께 선보입니다.<!--[if !supportEmptyParas]--><!--[endif]-->(사)우리민화협회는 전시 기간 동안 시민 참여형 체험 갤러리를 운영하여, 민화의 저변 확대는 물론 대중과의 소통과 문화 향유의 기회를 더욱 넓히고자 합니다.', place = '예술의전당 [서울] 서예박물관' WHERE provider_type = 'PUBLIC' AND external_id = '376669';
UPDATE festival SET title = '書境 새로운 지평 - 동양서예의 현재와 미래', content = '사단법인 동양서예협회가 주최하는 《書境 새로운 지평 — 동양서예의 현재와 미래》는 전통 동양서예의 깊이를 계승하면서 현대적 감성으로 새로운 ''書의 境地''를 열어가는 전시입니다.16인의 작가가 약 100여 점의 작품을 통해 한문서예, 한글서예, 문인화, 선묵화, 현대서예 등 동양서예의 다채로운 면모를 선보입니다.전시는 두 개의 섹션으로 구성됩니다.▸ 書境 I — 거장의 필묵, 전통의 울림芽南 배옥영 선생의 개인전과 함께, 惺谷 임현기 명예이사장, 虎岩 임국환 상임고문, 中觀 황재국 고문의 특별출품, 그리고 초대작가 惠田 김정례, 西川 김정희, 石堂 손윤기, 曉泉 임상숙과 외부 협회 단체 초대작가 海巖 김인재, 회원작가 仲垣 손진명이 전통 서예의 깊이와 격조를 보여드립니다.▸ 書境 II — 전통의 현재, 창조의 미래초대작가 煕勆 공경순, 소담 김혜란, 珍湖 소정아, 靑筍 장기영과 외부 협회 단체 초대작가 雨庭 민지현, 회원작가 紅苑 손지영이 전통에 뿌리를 두면서도 자신만의 예술 세계를 펼치며 동양서예의 새로운 가능성을 제시합니다.전서, 예서, 해서, 행서, 초서, 고체, 궁체, 흘림체 등 다양한 서체와 문인화, 선묵화까지 아우르는 이번 전시는 동양서예의 과거와 현재, 그리고 미래를 한자리에서 만나볼 수 있는 뜻깊은 기회가 될 것입니다.', place = '예술의전당 [서울] 서예박물관' WHERE provider_type = 'PUBLIC' AND external_id = '376671';
UPDATE festival SET title = '함석헌기념관 씨알갤러리 8차 장세정 개인전 ‘시간의 색채’', content = '', place = '함석헌기념관' WHERE provider_type = 'PUBLIC' AND external_id = '375646';
UPDATE festival SET title = 'ONGOING', content = '<!-- wp:paragraph -->
<p>< ONGOING>전시는 갤러리그림손에서 지속적으로 기획전에 참여한 작가들로 이루어진 단체전입니다. 서로 다른 주제의 작품들이 한 공간에서 서로 다른 시선과 경험을 겹쳐 만들어내는 전시입니다. 작품 각각이 지닌 고유한 흐름과 에너지는 현재 시간 속에서 서로 마주하고, 이어지며, 새로운 의미와 가능성을 생성합니다. 주제의 의미는 현재 감각을 주목하고자 기획되었습니다. 개인과 사회 그리고 예술이 끊임없이 변화하고 축적되는 흐름 속에 놓여 있음을 조명합니다. 참여 작가들은 각자의 시선으로 변화와 흐름을 탐구하며 작품을 통해 멈추지 않는 사유와 움직임을 드러냅니다. 본 전시는 답이나 결론을 제시하기보다 관람객 각자가 현재의 시간과 상태를 다시 바라볼 수 있는 열린 장을 마련하고자 합니다.</p>
<!-- /wp:paragraph -->', place = '갤러리 그림손' WHERE provider_type = 'PUBLIC' AND external_id = '376159';
UPDATE festival SET title = '흰 그림자들', content = '<!-- wp:paragraph -->
<p>히든엠갤러리는 최혜연의 개인전 <흰 그림자들>을 통해 개인과 사회의 무의식, 그리고 트라우마의 흔적이 어떻게 시각화될 수 있는지를 탐색한다. 이번 전시는 작가가 지속적으로 다뤄온 ‘숲’의 이미지를 중심으로, 변화 속에서 형성되는 존재의 상태와 그 이면에 잠재된 감각의 층위를 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>최혜연작가에게 숲은 단순한 자연의 재현이나 치유의 공간이 아니다. 그것은 경쟁과 긴장이 공존하는 비가시적 질서의 구조이자, 개인의 기억과 사회적 폭력성, 그리고 집단적 무의식이 중첩되는 심리적 장소이다. 정돈되지 않은 숲의 구조는 예측 불가능한 흐름 속에서 끊임없이 생성되고 해체되며, 이는 곧 변화하는 인간 존재의 방식과 맞닿아 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 이러한 흐름 속에서 형상을 계획하기보다, 단순화된 획 위에 우연적인 흔적을 축적하고, 그 안에서 떠오르는 이미지를 길어 올리듯 화면을 구성한다. 이는 고정된 자아가 아닌, 수많은 선택과 변화 속에서 형성되는 존재의 상태를 반영한다. 형상들은 명확히 규정되지 않은 채 서로 연결되고 흩어지며, 하나의 단일한 의미로 수렴되기보다 열린 서사로 확장된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>특히 이번 전시에서 제시되는 ‘흰 그림자들’은 존재와 부재, 가시성과 비가시성 사이의 역설적 상태를 환기한다. 일반적으로 그림자가 어둠 속에서 드러나는 것과 달리, ‘흰 그림자’는 밝은 빛 속에서도 사라지지 않고 남아 있는 흔적을 가리킨다. 이는 쉽게 인식되지 않지만 여전히 현재에 영향을 미치는 무의식과 트라우마, 그리고 감정의 잔여를 상징한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>최혜연의 숲은 본능적이고 비이성적인 감정, 그리고 언어로 규정되기 어려운 대상을 포용하는 공간이다. 무질서 속에서 생성된 형상들과 우연적 흔적들은 서로 얽히며 새로운 관계를 만들어내고, 관람자는 이 열린 구조 안에서 각자의 기억과 감각을 통해 작품과 마주하게 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><흰 그림자들>은 고정된 실체로서의 인간이 아닌, 끊임없이 변화하며 형성되는 존재로서의 인간을 사유하게 한다. 동시에, 보이지 않지만 분명히 존재하는 것들을 감각하는 또 다른 방식을 제안한다.</p>
<!-- /wp:paragraph -->', place = '히든엠갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '376479';
UPDATE festival SET title = '서용선의 단종그림 _한(恨)과 충(忠)의 노래: 단종과 김시습', content = '<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17905,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/04/0319-2.jpg" alt="" class="wp-image-17905" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong></strong><strong></strong><strong>서용선의 단종그림</strong><strong>​   _한(恨)과 충(忠)의 노래: 단종과 김시습​​</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>전시장소:</strong> </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>① 갤러리밈(MEME) _  한(恨)과 충(忠)의 노래: 단종과 김시습​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>② 디스코스 온 아트(Discourse on Art)​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>③ 갤러리 제이제이(JJ)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>④ 아트스페이스 3</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>⑤ 영월관광센터</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>전시기간</strong><strong>: 2026</strong><strong>년 </strong><strong>4</strong><strong>월 </strong><strong>20</strong><strong>일 </strong><strong>~ 6</strong><strong>월 </strong><strong>6</strong><strong>일</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong></strong>(​전시 오픈, 마감일은 장소마다 조금씩 다름)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>전시연계 영월답사여행</strong><strong>: 4</strong><strong>월 </strong><strong>30</strong><strong>일</strong><strong>(</strong><strong>목</strong><strong>) </strong><strong>오전 </strong><strong>9</strong><strong>시</strong><strong>, </strong><strong>인사동 </strong><strong>‘</strong><strong>갤러리밈</strong><strong>’ </strong><strong>출발</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong></strong>(참가신청 마감되었습니다.)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>세미나</strong><strong><</strong><strong>서용선의 단종그림</strong><strong>>: 5</strong><strong>월 </strong><strong>6</strong><strong>일 오후 </strong><strong>2~5</strong><strong>시</strong><strong>, </strong><strong>아트스페이스 </strong><strong>3</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong></strong>(세부사항은 각 갤러리에 문의)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17907,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/04/0225-3.jpg" alt="" class="wp-image-17907" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong><서용선의 단종 그림> 기획글 ​</strong>​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p> ​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>서용선 화백은 40여년 동안 150여 점의 유화와 350여 점의 드로잉으로 조선시대 단종 관련 그림을 제작해왔다. 그 외에도 ‘동학농민혁명’과 ‘일제강점기’, 제주도의 ‘4.3 민중항쟁’, ‘노근리 학살’과 ‘6.25 전쟁’, 그 이후의 분단을 떠오르게 하는 ‘백령도’와 세월호의 ‘진도’ 앞바다에 이르기까지 장소적 특수성으로서의 풍경에 녹아든 역사적 심성을 그림으로 표현해왔다. 단종의 유배지였던 영월도 마찬가지로 이를 미술사에서는 ‘역사화(history painting)’라 부른다.<br>​ </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가의 역사화는 서사적이며 표현적이다. 때문에, 읽어야 할 작품이지 보고 느끼기만 할 작품은 아니다. 그의 역사화에서 우리는 거기에 내재한 ‘비극’의 진상을 읽는다. ‘사건’과 ‘장소’의 실체를 넘어 감성으로 느끼며 읽히기를 화가는 원한다. 주제와 형식의 ‘서술’과 ‘재현’ 그리고 ‘압축’과 ‘표현’이라는 기능을 발휘함으로써 역사적 실체에 다가가려는 작가의 인문학적 노력은 지금도 진행형이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>역사화로서 서용선이 가장 많이 다룬 주제는 조선 초기의 ‘단종애사’로 작가의 역사화에 대한 지속적인 관심은 다음과 같은 원초적인 정치, 사회적 질문을 다시 갖게 한다. 국가, 이념, 전쟁, 권력으로 무고하게 희생당한 ‘국민’ 혹은 ‘민중’의 실체는 무엇인가? 그렇다면 국가란 무엇인가? 하는 질문과 ‘단종애사’는 시공간을 초월한 지금의 이 세계에서도 통하는 바 역사의 끈을 놓지 않는 우리의 태도 역시 AI만큼이나 중요하다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>기획/글 정영목(서울대 명예교수)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17908,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/04/0302-01.jpg" alt="" class="wp-image-17908" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong></strong><strong><서용선의 단종그림_한과 충의 노래: 단종과 김시습> 기획글</strong><strong>​</strong><strong>​</strong><strong>​</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>서용선 작가는 김시습을 단종 역사화 시리즈의 핵심 소재로 다루어오고  있습니다. 비극적 죽임을 당한 군주와 신의를 지킨 지식인이라는 두 인물의 관계를 현대적 해석의 관점으로 풀어냅니다. 단종 연작이 권력에 의한 희생에 초점을 맞춘다면, 김시습 연작은 그 비극을 목격한 자의 사유와 방랑, 저항, 그리고 예술로의 승화에 다다르는 여정을 따라갑니다. 거대한 권력 앞에서 자신만의 길을 걸어간 한 개인의 삶이 지금 우리에게도 유효한 질문을 던진다는 믿음에서 이어오는 작업일 것입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><한(恨)과 충(忠)의 노래: 단종과 김시습>은 역사의 풍랑 속에서 단종과 김시습의 삶이 어떻게 교차했는지를 들여다보는 전시입니다. 가련한 자신의 처지를 읊어낸 어린 왕의 애처로운 자규사*(子規詞)와 그런 임금을 향한 충심을 담은 김시습의 비장한 자규사를 전시의 출발점으로 삼았습니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이 전시는 ‘서용선의 단종 그림’이라는 제목으로 서울 소재 4개 갤러리와 영월 등 총 5개 전시공간에서 동시에 개최되는 합동전시 중 하나입니다. 단행본을 발간하였고(정영목 엮음/연립서가) 세미나와 청령포 답사를 진행합니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시에 포함된 두 수의 자규사는 ''서용선의 단종 그림''의 공동저자 심경호(고려대학교 명예교수)의 글 ‘김시습과 자규사’에서 가져왔습니다.                                       </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리밈 </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>*자규사(子規詞):단종이 두견새의 울음에 자신의 처지를 비유해 지은 시</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>​</strong></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17909,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/04/web_〈청령포〉2026_-Acrylic-on-canvas_90.8x116.7cm.jpg" alt="" class="wp-image-17909" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph {"align":"center"} -->
<p class="has-text-align-center">청령포, 2026, Acrylic on canvas, 90.8x116.7cm</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>서용선​​ Suh Yongsun 徐庸宣​</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>b. 1951 </strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>​ </strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>cv축약본​</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Selected </strong><strong>​Solo Exhibition</strong></p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td colspan="8">2026 </td><td colspan="8"> 서용선의 단종그림 _한(恨)과 충(忠)의 노래: 단종과 김시습​, 갤러리밈, 서울, 한국​</td></tr><tr><td colspan="8">​ </td><td colspan="8"> A Bold Attention​, 갤러리장 뉴욕​, 미국​​</td></tr><tr><td colspan="8">2025 </td><td colspan="8">​ 서용선 도시와 사람들 : PIBI Gallery, 서울​</td></tr><tr><td colspan="8"> </td><td colspan="8"> 서용선 역사화, 1453년 10월10일 계유정난癸酉靖難 게릴라展, 디스코스온아트Discourse on Art, 서울​​​​</td></tr><tr><td colspan="8">2024</td><td colspan="8"> 서용선, 모건 애비뉴 300 :갤러리 JJ, 서울</td></tr><tr><td colspan="8"> </td><td colspan="8"> 서용선, Portrait of Ourselves: Forests to Cities : Cromwell Place, Gallery 12( One and J Gallery), 런던, 영국</td></tr><tr><td colspan="8"> </td><td colspan="8"> 서용선, New Works: 원앤제이 갤러리, 서울</td></tr><tr><td colspan="8"> </td><td colspan="8"> 나를 그리다, 서용선:  토포하우스, 서울</td></tr><tr><td colspan="8">2023</td><td colspan="8"> 서용선, 삶의 노래 : 스페이스138, 서울</td></tr><tr><td colspan="8"> </td><td colspan="8"> 서용선 I see you : 장 디자인아트 갤러리, 서울 </td></tr><tr><td colspan="8">2022</td><td colspan="8"> 서용선_회상, 소나무 : 갤러리JJ, 서울</td></tr><tr><td colspan="8">2021</td><td colspan="8">​ 서용선의 마고이야기, 우리 안의 여신을 찾아서 : 서울여성역사문화공간 여담재, 서울</td></tr><tr><td colspan="8"> </td><td colspan="8"> 서용선의 자화상 : 갤러리하이, 부산</td></tr><tr><td colspan="8"> </td><td colspan="8"> Mago, The Myth_Suh Yongsun :  JNO갤러리, 서울 </td></tr><tr><td colspan="8"> </td><td colspan="8"> 서용선의 생각, 가루개 프로젝트 : 갤러리JJ, 서울</td></tr><tr><td colspan="8"> </td><td colspan="8"> 만첩산중萬疊山中 서용선회화 : 여주미술관, 여주</td></tr><tr><td colspan="8">2020  </td><td colspan="8"> 직관적 사유로서의 선_ 서용선 종이그림 : 올미 아트스페이스, 서울</td></tr><tr><td colspan="8"> </td><td colspan="8"> 고구려, 산수 : 갤러리이마주, 서울 </td></tr><tr><td colspan="8"> </td><td colspan="8"> 서용선의 풍경화 : 리씨갤러리, 서울</td></tr><tr><td colspan="8"> </td><td colspan="8"> Men in the History : 604J 갤러리 / 604H 갤러리, 부산</td></tr><tr><td colspan="8"> </td><td colspan="8"> Men in the History : 스페이스홍지, 서울</td></tr><tr><td colspan="8"> </td><td colspan="8"> 서용선 : 갤러리이마주, 서울</td></tr><tr><td colspan="8"> </td><td colspan="8"> 6 Downtown : Kips Gallery, 뉴욕, 미국</td></tr></tbody></table></figure>
<!-- /wp:table -->

<!-- wp:paragraph -->
<p><strong>Selected Group </strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong> Exhibition</strong>​</p>
<!-- /wp:paragraph -->

<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td> 2026</td><td> 보이는 것 너머의 질서 : Gallery Chang, 서울​​</td></tr><tr><td> 2025​</td><td>​ 통일이 독립이다 : 경기도박물관 기증실, 용인 </td></tr><tr><td> </td><td>​ 사진이 할 수 있는 모든 것: 서울 시립 사진미술관, 서울​</td></tr><tr><td> </td><td>​ 신형상미술, 삶의 언어가 되다: 권정호미술관, 대구​</td></tr><tr><td> </td><td>​ 이음의 합: 창덕궁 낙선재 일원, 서울​</td></tr><tr><td> </td><td>​ Sydeny, Lines of Memory : LNL Gallery, 시드니, 호주​</td></tr><tr><td> </td><td> 역사화의 새 지평, 시대를 보다 : 제주도립미술관, 제주  ​​</td></tr><tr><td> </td><td>​ Art Critic’s Choice : Samwon Gallery, 서울​</td></tr><tr><td> 2024</td><td> 시천여민侍天與民, 동학에서 오월로, 광주비엔날레 30주년기념특별전 : 광주시립미술관 본관, 광주​</td></tr><tr><td> </td><td> 경계없이, 낯설게 : 열린송현녹지광장, 서울​​</td></tr><tr><td> </td><td> 어느 시간에 탑승 하시겠습니까? :  페이스갤러리, 서울​</td></tr><tr><td> </td><td> 용 (龍.用.勇) : 김종영미술관, 서울</td></tr><tr><td>2023 </td><td>​ 어디로 주름이 지나가는가 : 아르코미술관, 서울​</td></tr><tr><td> </td><td>​ 보통사람들의 찬란한 역사 : 경남도립미술관, 창원​</td></tr><tr><td> </td><td>​ 시간의 두 증명, 모순과 순리 : 서울대학교미술관, 서울​</td></tr><tr><td> </td><td>​ 연옥에 핀 꽃 : 엑스포아트갤러리, 여수​</td></tr><tr><td> 2022</td><td>​ 기억의 장면들 : 두남재아트센터, 서울​</td></tr><tr><td> </td><td> 하나이면서 셋 : 누크갤러리, 서울​​</td></tr><tr><td> </td><td> 긴호흡-다섯작가의 드로잉 :  토포하우스, 서울​​</td></tr><tr><td> </td><td> 그림의 탄생 : 예술의전당 한가람미술관, 서울  </td></tr><tr><td> </td><td>​ 남한의 산, 북한의 산 : 산악문화체험센터, 서울​</td></tr><tr><td> </td><td>​ 오픈업! 2021-2022 한중문화교류의 해 기념 한중 작가 온라인 교류전 : http ://<a href="http://www.kode.or.kr/">www.kode.or.kr</a>​</td></tr><tr><td> </td><td>​ 우리가 마주한 찰나 : 수원시립아이파크미술관, 수원 ​</td></tr><tr><td> </td><td> PEACE for CHILD전쟁 속 어린이를 위한 평화의 기도 : 서소문성지 역사박물관, 서울​</td></tr><tr><td> </td><td> Hi_story.gif : 자하미술관, 서울</td></tr><tr><td> </td><td> 한중수교 30주년 기념전, 공감_한국현대미술을 바라보다 : 주중한국문화원, 베이징 / 광쩌우 미술대학교 미술관, 광쩌우, 중국</td></tr><tr><td> </td><td> 정진국의 건축과 서용선 박인혁의 그림 : 토포하우스, 서울</td></tr><tr><td> </td><td> 미니멀리즘-맥시멀리즘-메커니니즘(1막-2막) : 아트선재센터, 서울</td></tr><tr><td> 2021</td><td> 달빛이 연못을 뚫어도 : 난계로 로얄빌딩 팝업전시장. 서울</td></tr><tr><td> </td><td> 할아텍 철암그리기 20주년 기념전 : 태백석탄박물관 기념전시실, 태백 / 목포문화예술회관, 목포</td></tr><tr><td> </td><td> 여수국제미술제_흐르는 것은 멈추길 거부한다 : 엑스포컨벤션센터, 여수</td></tr><tr><td> </td><td> 전방前方, 20인의 예술가가 전하는 한반도평화이야기 : 오두산통일전망대전시실, 파주</td></tr><tr><td> </td><td> 약속의 땅 : 더 그레이트 컬렉션, 서울</td></tr><tr><td> </td><td> 시대와 개성 : 해든뮤지움, 인천</td></tr><tr><td> </td><td> 한국 스페인 특별전-마주하는 풍경, 일상의 시선 : 소마뮤지엄, 서울</td></tr><tr><td> </td><td> 신 자연주의_리좀이 화엄을 만날때 : 전북도립미술관, 완주</td></tr><tr><td> 2020</td><td> ㄱ의 순간: 예술의전당 서예박물관, 서울</td></tr><tr><td> </td><td> 인간과 도시_권순철 서용선 : 와우갤러리, 서울</td></tr><tr><td> </td><td> 2020 부산비엔날레_열 장의 이야기와 다섯 편의 시 : 부산현대미술관 외, 부산</td></tr><tr><td> </td><td> 평화, 바람이 불다_남북한 특별전시회 : 오두산통일전망대, 파주</td></tr><tr><td> </td><td> 회화의 서사 : 뮤지엄산, 원주</td></tr><tr><td> </td><td> 진달래 꽃 피고 지고 : 전북도립미술관, 완주</td></tr><tr><td> </td><td> 새로운 시의 시대 : 경남도립미술관, 창원</td></tr><tr><td> </td><td> 이른 봄나들이-예술가의 집 : 여주미술관, 여주</td></tr><tr><td> </td><td> Trahere 화가의 자화상 : 어울림누리 어울림미술관, 고양</td></tr><tr><td> </td><td> Suh Yongsun & Kathleen J Graves : MK Gallery, Vienna, 버지니아, 미국</td></tr></tbody></table></figure>
<!-- /wp:table -->', place = '갤러리밈' WHERE provider_type = 'PUBLIC' AND external_id = '375296';
UPDATE festival SET title = '경기필 마스터피스 시리즈 II <라흐마니노프 교향곡 2번>', content = '경기필 2026 시즌 마스터피스 시리즈의 두 번째 무대로, 지휘자 홀리 최와 첼리스트 최하영이 함께하며 낭만시대 특유의 풍부한 선율과 서정성을 느낄 수 있는 무대 마련', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '371019';
UPDATE festival SET title = '국립합창단 기획공연 <폴란드 합창 음악의 향연>', content = '르네상스부터 현대에 이르는 폴란드 합창음악의 흐름을 한 무대에서 조망하는 시간이다. 폴란드 지휘자 다리우시 짐니츠키(Dr. Dariusz Zimnicki)의 객원 지휘 아래, 국립합창단은 폴란드 작곡가들의 작품을 중심으로 전통과 현재가 공존하는 합창의 색채를 펼쳐 보인다. 바로크 시대부터 현대에 이르기까지 각 시대의 음악 언어와 종교적 텍스트가 만들어내는 폴란드 합창 음악의 울림을 한국 무대에서 입체적으로 경험하게 할 예정이다.', place = '예술의전당 IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '368643';
UPDATE festival SET title = '안전 연극제: 면역력 <가장 낮은 곳에서> 가슴이 처진 여자의 이야기', content = '', place = '연극실험실 혜화동1번지' WHERE provider_type = 'PUBLIC' AND external_id = '372851';
UPDATE festival SET title = '안전 연극제: 면역력 <이불 없는 자들의 밤>', content = '', place = '연극실험실 혜화동1번지' WHERE provider_type = 'PUBLIC' AND external_id = '372827';
UPDATE festival SET title = '복도에서 만나', content = '<복도에서 만나>는 오피스텔 복도라는 ''경계의 공간''에서 만난 네 명의 인물을 통해, 우리 사회에서 ''밀려난'' 이들의 삶을 조명하는 작품이다.', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '368357';
UPDATE festival SET title = '접근성 높은 연극 <해리엇>', content = '강동문화재단 제작 창작 레퍼토리로, 거북 해리엇과 원숭이 찰리의 여정을 통해 돌봄과 공존을 전하는 접근성 높은 연극', place = '강동아트센터 소극장 드림' WHERE provider_type = 'PUBLIC' AND external_id = '368152';
UPDATE festival SET title = '[인천] 지브리 & 디즈니 OST 콘서트 with 첼로댁 ', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '372564';
UPDATE festival SET title = '제953회 전남도립국악단 토요가무악희 시즌 2 <그린국악> 수어로 만나는 우리소리', content = '', place = '남도소리울림터' WHERE provider_type = 'PUBLIC' AND external_id = '373796';
UPDATE festival SET title = '[서울] 지브리 & 디즈니 영화음악 FESTA (앵콜)', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '373106';
UPDATE festival SET title = '닐루파르 무히디노바 & 백동현 듀오 리사이틀', content = '', place = '클래시카 서울' WHERE provider_type = 'PUBLIC' AND external_id = '375162';
UPDATE festival SET title = '김보람 피아노 독주회 "환상에서 열정으로 (Fantasy to Passion)"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '370856';
UPDATE festival SET title = 'N 클래스 스테이지 두 번째 – 희곡 <진짜 나쁜 소녀>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '377037';
UPDATE festival SET title = '함평군립미술관 4월 <요가하는 미술관>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '372447';
UPDATE festival SET title = '[원주 갤러리 원] 이현주 개인전 "잠시 머무는 붉은 시간"', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '377272';
UPDATE festival SET title = '오채현: 돌 호랭이 납신다', content = '<!-- wp:paragraph -->
<p><오채현 돌 호랭이 납신다/ OH Chae Hyun: The Happy Tiger Descends></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Artist: OH Chae Hyun<br>Date: APR 22 – MAY 16, 2026<br>Wed – Sun pm 13:00-18:00<br>Opening Reception: 4.22 (Wed) 5pm</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리 진선, 오채현 개인전  ''돌 호랭이 납신다'' 개최</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p> 40여 년간 한국적인 정서를 담아내고 사람과 공존하는 친근한 호랑이를 경주 화강석으로 표현해 온 오채현 작가의 개인전 ‘돌 호랭이 납신다(The Happy Tiger Descends)’가 서울 종로구 삼청동 소재 갤러리 진선 2층에서 오는 4월 22일부터 5월 16일까지 열린다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 작가의 대표작 ''해피 타이거(Happy Tiger)'' 시리즈를 새롭게 변화시켜 작은 호랑이 조각부터 대형 호랑이 조각까지 총 14점의 신작과  호랑이 드로잉 작품도 함께 전시될 예정이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>호랑이는 단군신화부터 고구려 고분벽화, 조선시대의 맹호도, 민화까지 한민족의 상징으로 대표되는 동물이다. 작가는 어려서부터 호랑이와 관련된 민간신화를 접하며 호랑이에 대한 호기심을 가지게 되었고 그 관심이 그대로 이어져 민족의 본질과 전통미술, 우리 미술이 가지는 원형에 대해 탐구하기 시작했다고 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>특히 민화(民畫) 속 호랑이는 맹수로서의 두려운 존재가 아니라 친숙하고 해학적인 존재로 묘사되는데 작가는 이점에 주목하여 호랑이 조각에 자신만의 독창적인 감성과 이해를 더해 사랑스럽게 정면을 응시하는 호랑이, 크게 웃는 호랑이, 서로를 다정하게 껴안는 호랑이 등 무서운 모습은 드러내지 않고 오히려 장난기 가득하고 익살스러운 돌 호랑이들을 만들어냈다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>여러 작품들 중에서 두세 마리의 호랑이가 함께 있는 ''해피 패밀리(Happy Family)''는 현대 사회가 가지는 작은 규모의 가족을 상징적으로 표현했다. 서로의 얼굴을 맞대며 온기를 나누는 이 작품은 정서적 결속과 강한 유대감을 형상화하고, 머리 혹은 꼬리에 내려앉은 ‘작은 새’는 가족 간의 소통과 교감의 의미를 가지고 있다. 학업과 취업으로 인해 거주지를 달리하는 가족도 일상적 삶을 공유하지는 못하지만 단단한 유대관계로 이어져 있는 가족으로서의 속성은 환경의 지배를 받지 않는다는 뜻도 내포하고 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 “한국 문화에 전 세계인의 관심이 집중되는 요즘, 관객이 이번 전시로 전통적 소재와 우리 민족의 해학적 요소를 이해하며 정겨운 가족애에 대해 다시 한 번 생각해 볼 수 있는 기회가 될 수 있길 바란다”고 말했다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>오채현 작가는 경북대학교 미술학과 및 동 대학원을 졸업하고, 이탈리아 까라라 국립미술대학에서 조소를 전공했으며  국내외 아트페어와 40여회의 개인전을 통해 다양한 조각 작품을 대중에게 선보이고 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Gallery Jinsun to Host Oh Chae Hyun’s Solo Exhibition “The Happy Tiger Descends”</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The solo exhibition by artist Oh Chae Hyun, who has spent over 40 years capturing Korean sentiments and depicting friendly tigers coexisting with humans using granite from Gyeongju, titled “The Happy Tiger Descends,” will be held on the 2nd floor of Gallery Jinsun in Samcheong-dong, Jongro-gu, Seoul, from April 22 to May 16.         </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>This exhibition features a new take on the artist''s representative works, the “Happy Tiger” series, showcasing a total of 14 new works ranging from small to large tiger sculptures, along with tiger paintings.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The tiger is an animal that symbolizes Korean people, spanning from the Dangun myth to Goguryeo tomb murals, and paintings of fierce tigers and folk art from the Joseon Dynasty. The artist states that he became curious about tigers after encountering folk myths related to them from a young age, and that this interest continued, leading him to begin exploring the essence of the Korean people, traditional art, and the archetypes inherent in our traditional art.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>In particular, the tigers in folk paintings are depicted not as fearsome beasts but as familiar and humorous creatures. The artist focused on this point and added his own unique sensibility and understanding to the tiger sculptures, creating stone tigers that do not reveal a scary appearance but are instead full of playfulness and humor, such as lovely tigers gazing straight ahead, tigers laughing heartily, and tigers affectionately hugging each other.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Among the various works, “Happy Family,” which features two to three tigers together, represents a small-scale family of modern society. This piece, depicting the tigers sharing warmth with their faces close together, embodies an emotional bond and strong connection, while the “small birds” perched on their heads or tails signify communication and communion within the family. It also implies that even families living apart due to studies or employment and unable to share daily lives remain bound through a solid bond. This means that their nature as a family is not controlled by surrounding environments.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The artist said, “In these times when the whole world’s attention is focused on Korean culture, I hope this exhibition will provide an opportunity for the audience to understand traditional themes and the humorous elements of Korean people and to reflect once again on heartwarming love of family.”</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Artist Oh Chae Hyun has graduated from the Department of Fine Arts and the Graduate School of Kyungpook National University and has majored in sculpture at the National Academy of Fine Arts in Carrara, Italy. He has been showcasing various<strong> </strong>sculptural worksto the public through domestic and international art fairs and over 40 solo exhibitions.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '갤러리진선' WHERE provider_type = 'PUBLIC' AND external_id = '376477';
UPDATE festival SET title = '성인 대상 전시 연계 교육 <지금, 한국화를 말하다>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '374793';
UPDATE festival SET title = '어린이 음악회 <신나락 만나락>', content = '세상에서 유일하게 노래하는 아이 ''선율''.엄마를 찾아 악기친구들과 모험을 떠나다!', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '368166';
UPDATE festival SET title = '서용선의 생생한 생각: 단종 드로잉', content = '<!-- wp:image {"id":17957,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/04/ver1_홍보-포스터_서용선-개인전.jpg" alt="" class="wp-image-17957" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>’<em>그리기’라는 것은 하나의 행위이자 태도죠, 이것은 작가의 정신과 연결되는 가장 긴밀한 것이라 생각됩니다</em>.” <em>─</em>서용선, 2016년</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리JJ는 ‘그리기’를 중심으로 ‘인간’ 탐구를 실천해오고 있는 작가 서용선의 개인전을 개최한다. 이번 전시 《서용선의 생생한 생각: 단종 드로잉》은 갤러리JJ에서 열리는 서용선의 여섯 번째 전시로, 역사 연작 가운데 단종 주제의 드로잉 작업을 조명한다. 본 전시는 서울의 네 개 갤러리와 영월의 전시관에서 각각의 특성을 가지고 동시에 진행되는 《서용선의 단종 그림》 연합전시 중 하나로, 작가가 1986년부터 현재까지 40여 년을 이어 온 단종 작업의 흐름을 드로잉을 통해 살펴본다. 지금까지 우리에게 익숙한 그의 작품들은 강렬한 색채의 표현성이 짙은 회화였다. 이와 관련되었지만 좀처럼 볼 기회가 없었거나 세상에 처음 모습을 드러내는 단종 드로잉들을 마주하는 일은 무척 새롭고 재미가 있다. 지금까지 작가의 작업에 대한 수많은 고찰이 있어 왔음에도, 이번 전시는 그의 작업을 관통하는 드로잉이라는 방식과 서용선 예술 화두의 정점인 ‘역사’ 작업 가운데 가장 오랜 시간을 탐색해온 단종 주제의 특성상, 그의 작업 근원에서의 깊은 소통이 기대된다. 전시는 익숙하고도 낯선 단종 역사, 서용선의 생생한 생각들은 어떻게 그림의 공간에서 만날 수 있으며, 지금도 어떤 예술적 화두로서 새로운지 들여다보고자 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>서용선은 일찍이 1980년대 초 작업 활동을 시작한 이래 현재까지 한반도를 포함하여 지구촌 곳곳을 끊임없이 다니고 세상을 관찰하면서 작업을 펼쳐왔다. 서울, 뉴욕, 베를린과 같은 현대 도시 공간에서부터 철암(2001-), 독도(2003-), 양평 가루개마을(2020-2021), 암태도(2022-2023) 등 공동체 현장과 공공미술프로젝트, 영월의 청령포와 같은 역사ㆍ문화적 기억이 깃든 장소에 이르기까지 인간 삶의 조건을 마주하는 그의 곁에는 늘 스케치북이 있었다. 그는 역사와 신화를 문헌으로 고찰하고 현장을 방문하여 실제로 ‘장소’에서 일어나는 사건과 사람들과의 진솔한 만남과 이야기를 자신만의 감각으로 체화해 드로잉으로 남겨왔다. 스치는 순간이나 인상을 재빠르게 드로잉으로 생생하게 포착하고 기억하며, 현장에서의 광고 전단지나 포장지조차도 적극 활용하는 등 순간의 사고와 활동의 흔적들을 남기고 치밀한 생각 전개의 자취를 남긴다. 곧 작가는 자신이 속한 도시의 분위기를 기록하고, 역사의 기록과 이야기로부터 생각을 끌어오고 기억하는 행위로서 드로잉을 일상 속에서 습관처럼 실천해 오고 있는 것이다. 인간을 궁금해하는 그의 관심사가 결국 삶의 세계 속으로 들어가 목격하고 몸으로 체험해야 가능한 일이기에, 신체 행위가 적극 반영되는 날것 그대로의 드로잉 표현 기법이야말로 그의 작업 세계를 아우를 수 있는 최적의 방식일 수 있다. 시각예술 자체가 드로잉을 품고 있겠지만, 역동적인 ‘선’들의 터치가 특징적인 서용선의 작업은 선의 기본인 드로잉과 본질적으로 다르지 않아 보인다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이처럼 작가가 늘 자기 자신에서 시작하여 세상을 알아가고 기록하기 위해 그림을 시작한 이후 지금껏 일관되게 이어온 작업 방식 중 하나가 바로 드로잉이다. 드로잉은 그의 작업세계의 근간을 이루고 있으며 그의 회화적 관심이 가져온 독특한 조형세계의 흔적이다. 이미 그의 1986년까지의 초기 드로잉을 모은 두 권의 책이 출간되어 있다. 또한 작가가 직접 저술한 소책자 『유럽미술의 변화ㆍ소묘』(1986)를 통해서 동서양의 전통회화 이론과 함께 드로잉, ‘그린다는 것’에 관해 깊은 관심과 이해를 보임으로써 드로잉이 그의 시각 언어에서 주요한 수단으로 작동하고 있음을 알 수 있다. 한편 2006년에 국내에서 최초의 드로잉센터인 소마드로잉센터(SOMA Drawing Center)가 개관할 당시 뉴욕의 드로잉센터를 방문하는 등 그가 초기 준비위원으로서 역할을 한 바 있다. 그의 드로잉 개인전은 1995년 뉴욕에서의 《자화상 드로잉》을 시작으로 2016년 아르코미술관에서는 대표작가전시로 방대한 규모의 서용선 드로잉을 택했다.<br>이번 ‘단종’ 주제의 연합전시는 2014년 아트센터 화이트블럭의 《역사적 상상-서용선의 단종실록》 전시 이후에 이 주제를 가장 폭넓게 집중적으로 조명하는 전시일 것이다. 1993년 신세계갤러리의 개인전 《서용선 1987-93 노산군(단종)일기》를 시작으로, 그동안 수많은 전시를 통해 잊을 만하면 우리는 단종 역사 그림을 다시 마주하곤 했다. 오랜 시간 축적되어 온 단종 연작은 ‘역사’를 화두로 서용선 작업세계의 중추를 이루며, 우리의 집단기억(Collective Memory) 속 흔적 같은 독특한 위상으로 대중에게 잘 알려져 있다. 그것은 당시 우리가 시각예술에서 흔히 접할 수 없었던 한국 역사의 기억을 형상화하여 시선을 사로잡았고 현대 역사화에 관한 논의를 한국 화단에 불러올 수 있었다.<br>소나무 그림으로 화단에 데뷔한 이후 서용선의 ‘역사’ 작업은 자화상, 당시 변화무쌍하게 현대화되어 가는 도시 서울의 모습을 지나서 지구촌 도시 공간을 향한 작업, 신화 작업으로 모습을 바꾸면서 저마다의 군락으로 오늘날 삶의 현실과 조건에 본질적으로 연결된다. 작가는 “현실의 모습은 역사화된 것”이며, “그림 그리기는 현실의 겉모습을, 사실의 흔적들을 헤쳐 내는 것.”이라고 말한다. 과거나 현재나 어김없이 작동하는 부조리한 삶의 현장에 내재한 메커니즘이나 보이지 않는 힘은 특유의 표현성으로 왜곡된 비현실적인 평면을 가로지르는 불가사의한 에너지로 나타나 우리 앞에 리얼한 기록으로 다가선다. 노산군일기를 시작으로 한국전쟁, 철암그리기 등 대부분의 연작들은 각각 십수 년 전에 시작하여 현재까지도 그에 관련된 이야기, 역사의 기억들을 소환하면서 긴 궤적을 남기는데, 이는 서용선 예술의 특별한 점이다. 단종의 비극적 삶을 둘러싼 수많은 이야기는 그중 작가가 가장 오래도록 천착하고 있는 소재다. 누구에게는 아니 대부분에게는 구태의연하거나 이미 잊힌 작은 역사, 혹은 역사가 되지 못한 한 조각 이야기일 수 있으나, 작가에게 그것은 ‘지금 여기’에 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>1. 서용선의 단종 드로잉</strong><br>현재까지 단종 드로잉 작업은 무려 380여 점에 이른다. 이번 전시는 <오세암>(2025), <청룡포>(2026) 등 신작을 비롯하여 약 40여 점의 드로잉 작품들로 구성되며, 노트 및 스케치북, 자료들도 함께 전시된다. 전시는 단종 그림의 단초가 되는 1980년대 초기 드로잉 습작까지 맥락을 따라가 본다. 단종 그림은 1986년 영월의 청령포에서 시작되었지만, 이러한 역사 주제의 그림에 대한 생각은 그 이전으로 거슬러 올라가 효종의 북벌계획과 임진왜란 등의 드로잉들로 남아있다.<br>단종 드로잉은 <계유년>, <모의> 등 수양대군이 왕위를 찬탈한 계유정난과 단종복위운동을 둘러싼 사건의 재구성, <소년왕>(2006)의 단종을 비롯한 세조 및 김시습 등 사건 속 인물들, 이와 관련된 장소들이 그 내용을 이룬다. 이들은 페인팅보다 더 다양한 구성과 같은 제목의 여러 유형으로 재구성되었다. 전시 공간은 약 40년에 걸친 결코 짧지 않은 시간의 흐름을 내재하고, 드로잉의 특징인 선을 중심으로 면과 형태의 조형적 요소를 반영하여 전개된다. 시간의 흐름에 따라 비중이 달라지는 인물이나 사건, 상호 간의 조형요소들의 변화나 혹은 직접적으로 포착된 생각으로부터의 의식적 흐름과 같은 간극이 드러나면서 이에 관객 스스로 역사의 파편들을 재조립하고 질문을 던질 수 있을 것으로 기대한다.<br>단종 드로잉은 페인팅과 비교했을 때, 단종 역사 작업에 대한 작가의 여러 가지 생각들이 좀 더 생생하게 드러나는 듯하다. 먼저 회화의 표출적인 색채에서 오는 주관적 감성을 배제한 개념에 더욱 집중할 수 있다. 또한 선을 중심으로 하는 조형요소들이 그림 속 어떤 세계를 향해 무한히 열리고 확장되는 듯 결코 하나의 의미로 환원되지 않아 상상력이 확장되고 자유로울 수 있다. 서용선 특유의 일필휘지 단호한 선들은 페인팅이 가진 묵직한 물질성 대신 날것의 즐거움, 신체 움직임이 주는 원초적 에너지를 감각하게 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>2. 확장하는 선, ‘미완’의 특성</strong><br>드로잉에서 ‘draw’는 ‘그리다’이면서 동시에 ‘끌어내다’라는 의미를 지닌다. 즉 드로잉은 무언가를 끌어내어 흔적으로 남기는 행위이며, 인류의 가장 오래된 예술적 행위 가운데 하나이다. 드로잉과 같은 의미로 르네상스 미술에서 중요하게 다루어진 ‘디세뇨(disegno)’ 역시 단순한 선긋기를 넘어 정신 속 관념이 시각적 형태로 나타나는 과정으로 이해되었다. 20세기에 들어 조형요소인 선과 색의 공존과 함께 회화와의 경계가 흐려졌고, 특히 세계적인 미술 경향이었던 1960년대의 개념미술을 거치면서 드로잉은 더 이상 회화의 준비 단계에 머무르지 않고 그 자체의 미적 가치를 지닌 독립적인 예술 형식으로 인식되기 시작했다. 서용선에게 또한 드로잉은 단순한 밑그림이 아니라 생각과 기억을 끌어내는 행위이며, 자신의 작업 의도를 가장 직접적으로 드러내는 매체이다.<br>곧 단종 연작에서 드로잉은 역사적 사건을 재현하는 도구라기보다 작가의 사유가 생성되는 장으로 작동한다. <계유년>, <모의> 등 계유정난을 둘러싼 장면들은 인물과 건축, 사건이 하나의 평면적 공간 안에서 교차하며 구성된다. 서로 다른 시간과 사건들이 동시에 한 화면에 등장하기도 하며, 궁궐 지붕을 투과해 내부 사건을 드러내는 등 독특한 공간 구성은 역사적 서사를 하나의 ‘그려진 사건’으로 제시한다. 이러한 방식은 사건의 서술성을 유지하면서도 관람자가 일정한 거리를 두고 역사적 장면을 바라보도록 만든다.<br>단순한 선과 색으로 지극히 절제된 요소들의 화면은 오히려 디테일한 내러티브를 희생하는 대신 불분명하지만 어떤 의도를 향한 가능성과 창작의지가 직관적으로 와닿을 경우가 많다. 작품들은 서사적인 내용을 다루면서도 단순하고 원초적인 조형언어로 인해 직관과 생명력을 잃지 않는다. 힘찬 획을 중심으로, 회화에서 분위기를 주도하던 색채는 색선이 되거나 자체로 형태를 이끌어내면서 함께 드라마틱한 그림의 공간을 창출한다. 이들은 어떠한 의미를 발생시키지만 또한 선과 형태들이 바깥과 내부로 열려 있어 그 어떤 하나의 의미로 고정되지는 않는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>드로잉 자체로 그려진 것도 있지만, <계유년>(2006) 등 많은 드로잉들이 캔버스로 다시 옮겨졌다. 이때 드로잉들은 작은 지면일지라도 화면을 가로지르는 긴장감이나 에너지는 거대한 페인팅과 다를 바가 없다. 오히려 어디론가 결정되지 않은 채 확장하고 생성하는 듯한 추상적인 선들이 생생하게 드러나면서 무한함과 연결되는 어떠한 자유로운 감각적 즐거움도 준다. 대상의 충실한 재현보다 움직임에 열려있는 ‘선의 충동’이 전체 화면에 생명력을 부여하고 있음이다. 선이 원칙이라는 고전적인 견해를 깬 세잔과 같은 반아카데믹적 작가들이 색으로 그 경계를 해체했지만 인간의 원초적 행위인 드로잉에서 선은 가장 본질적이자 일차적이다. 디세뇨가 ‘선’으로 끌어내는 시각 형태의 의미로 강조되었듯 회화와 조각과 건축이 독립하여 자율적 형식을 갖추게 되었지만, 조형예술의 근간을 이루는 것은 선묘(dessin)에 의한 형상화이다.<br>철학자 장 뤽 낭시(Jean-Luc Nancy)는 드로잉을 “시작도 끝도 없는 선의 존재”라고 말하며 그것을 하나의 고정된 의미가 아니라 도래하는 흔적으로 이해했다. 예술이 “세계에 없는 것이 세계에 도래하는 사건”이라면 드로잉은 단순히 이전에 있던 것을 시연하는 것이 아니라, “어떤 형식도 앞서 주어지지 않은 사물의 드러남”이다. 서용선의 드로잉 역시 신체의 움직임에서 비롯된 선의 충동을 통해 역사와 기억을 현재 속으로 불러온다. 그것은 출발점이 된 참조대상 그대로 고정되거나 견고한 의미를 보장해주지는 않는다. 도식적이거나 정형적인 것으로부터 탈피하는 불명확성, 시작인 동시에 끝, 완성인 동시에 미완성인 열림의 미학이 가능해지는 지점이다. 미완은 결핍이 아니라 그 자체로 열림의 형식이다. 서용선은 “선을 긋는 데에서는 이미 완성된 그림을 암시하기 시작한다”고 말한다. 선은 서용선의 드로잉에서는 그의 또 다른 예술적 원천일 수 있는, 모든 것의 시작이자 모든 형상의 근원인 ‘일획’(석도)의 단호함이 또 다르게 작동하고 있는지도 모른다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>3. 기억과 기록, 삶의 역사성</strong><br>애초에 쓰기와 그리기, 읽기와 보기에 함께 열려 있는 ‘선’의 존재로서, 작가의 드로잉은 마치 일기처럼 작동하여 사건들, 이야기들 혹은 장소에서 매 순간 호출되는 것들을 이미지의 형태로 고정시켜 펼쳐놓는다. 그는 늘 기록하고 과거사를 보존하는 태도를 보인다. 시간의 흐름에서 탈락하여 스치는 이미지와 글쓰기는 그 순간에 인식되지 않으면 복원할 수 없는 과거의 진정한 모습일 수 있다. 서용선은 자신의 처음 생각이나 기억을 유지시키기 위한 장치로서, 드로잉이 어떤 점에서는 완결된 조형적 요소와 장치가 많은 페인팅보다 자신이 무엇을 하려고 하는지 생각이 더 잘 드러나 보인다고 말한다. 감각적으로 체험될 수 있는 드로잉의 조형성은 모방론에 근거하기보다 사실적인 것을 지배하고 파악하려는 정신성에 기초를 둔다고 할 수 있다. 읽기와 보기가 중첩되는 드로잉의 매력은 선의 감각성과 더불어 이처럼 마음속의 불분명한 구상을 선명하게 가시화하는 데 있을 것이다. 곧 그것은 르네상스 시대에 바사리(Giorgio Vasari)의 말처럼, 인간과 삶에 대해 우리가 지닌 생각, 아이디어들을 구체적인 형상으로 열매 맺게 하는 일이다. 대상이 주는 느낌이나 눈앞에 대상이 없더라도 섬광처럼 스치는 기억과 이미지, 그 단초를 붙잡아두는 즉각적인 기록으로서의 드로잉은 곧 사회와 역사물의 시작이다. 이러한 드로잉은 서용선의 작품세계의 근본적인 골조이자 지지하는 단단한 토대로 작용한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>단종 작업은 동서양미술의 과거 역사에 대한 많은 관심과 함께 특히 작가가 오래전에 토로했듯, 당시 한국미술현장은 물론 우리 미술역사에서 잘 볼 수 없는, 역사나 신화를 소재로 하는 서양 고전작품의 탄탄한 전통과 대비하여 작가 스스로의 정체성과 관련한 독자적인 ‘역사 그리기’에 대한 나름의 모색에서 출발한다. 고대 비극이나 문학에서의 비극성에 대한 서사적 관심은 한국 과거사 속 단종과 세조라는 인물을 통한 비극의 감정과 인간의 욕망에 대한 회화적 표현으로 나타났다. 여기에는 서로 다른 사유와 경험에서 나오는 동서양의 감각 사이에서 다분히 한국인 작가로서의 정체성, 살면서 저절로 ‘몸’에 배어 있는 것들에 대한 궁금증 같은 것들이 작용했다고 할 수 있다.<br>작가는 ‘그림 그리기’란 자신과 주변에 대한 형태 표현을 통한 이해 과정이며, ‘역사 그리기’ 또한 자신을 형성시킨 과정을 알아내고 다른 사람들과의 관계에서 오는 차이와 특성을 드러내기 위한 것이라고 생각한다. 역사학자 딜타이(Wilhelm Dilthey)에 의하면, ‘역사적 의식’이 곧 자기인식의 한 방법일 수 있다. 삶이란 타인들과의 상호작용의 연속이며, 또한 그 가운데 타인들과의 연관관계가 생성되는 과정이다. 역사 그리기를 포함해 그동안의 철암부터 암태도까지 수많은 공동체 프로젝트를 거치면서 ‘삶 자체’로 이어지는 서용선의 작업은 결국 삶의 공동체로서 더불어 함께 하고자 하는 열망으로 향하고 있지 않은가? 시공을 넘어 조건 지어진 ‘사회 구조’ 속에 얽혀 자아를 상실한 인간의 비애와 그 본질적 특성, 인간의 역사적 운명과 실존적 삶에 대한 질문을 던지면서 말이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>배제되거나 괄호 쳐진 것들의 침묵은 역사에 본래부터 내재해 있다. 역사에서 배제된 노산군은 물론 엄흥도, 송씨부인, 안평대군 등 작가는 상징적 질서로부터 추방되거나 흔적이 희미해진 실재들을 소환하기 위해 재현체계의 틈을 내고, 그것들은 그림의 실재가 된다. 다른 연작 속 이름 없는 광부들, 세월호 사건, 현재 도시를 떠도는 이름 없는 소시민들도 마찬가지다. 그의 작업이 수많은 문헌적 기록을 탐색하면서 전쟁이나 정치적 상황 등 역사적 사실에 근거하지만 그것이 특정 이데올로기나 정치적 선호, 영웅의 신화가 될 수 없는 것은 주어진 시대 상황 속에 얽혀 살아가는 개인들이 겪는 삶의 흔적과 실존적 고통에 관한 질문이자 결정할 수 없는 사람 내면의 모습을 포착하고자 하는 시도이기 때문이다.<br>역사는 종결된 것이 아니라 시간을 관통하여 현재가 된다. 지속적인 탐사와 기록을 통해 역사에서 건져 올린 기억들, 현 상황에 따라 떠오르면서 끊임없이 변화하는 것들이 있다. 최근 작가와의 인터뷰에 의하면, 노산군의 비극적 삶에서 비롯된 단종 그림 연작은 “처음에는 인간사의 이야기에서 시작되어 어느덧 조선의 성립 초기 역사 그림으로서 관심의 폭이 넓어졌다.” 역사는 끊임없는 해석이 뒤따르고 작가의 생각도 변화와 새로운 사실들에 놓이면서, 자신에 대한 궁금증에서 시작된 삶의 세계를 향한 탐색은 그 넓이와 깊이를 더해가고 있다. 역사 서술이란 “위험의 순간에 섬광처럼 스치는 어떤 기억을 붙잡는다는 것”이라는 벤야민(Walter Benjamin)의 생각처럼, 그의 회화적 기록은 다만 시간의 흐름 속에서 떼어낸 어떠한 역사의 이미지들에서 성좌를 만들어 현재를 풍부하게 인식하고 우리의 현재 모습을 새롭게 바라보는 것이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>최근 작가가 뉴욕에서 그린 <오세암>(2025) 드로잉은 마치 투명한 형상의 한 폭 산수화를 보는 듯하다. 서용선 예술 기저에 흐르는 동양 전통회화의 기본을 반추하는 듯, 그의 작업을 특징짓던 강렬한 표현보다는 단순함과 관조적 양상으로 다가선다. 단종 역사 드로잉은 작가가 치밀한 인문학적 연구와 함께 역사와 그 기억이 새겨진 온갖 현장을 누비며 몸 체험으로 엮어내는 지난한 예술 노정의 최전선에서 맞닥뜨린 생각과 감각의 뭉치이다. 본 전시는 드로잉이라는 근원적 방식으로 서용선 예술 세계의 핵심을 만날 수 있는 뜻깊은 기회가 될 것이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"right"} -->
<p class="has-text-align-right">글│강주연 Gallery JJ Director</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '갤러리JJ' WHERE provider_type = 'PUBLIC' AND external_id = '375297';
UPDATE festival SET title = '한국 근현대미술 속 광주를 읽다 "희망과 고난의 소용돌이에서: 광복과 전쟁, 재편되는 미술계"', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '374334';
UPDATE festival SET title = '[대학로] 카라마조프: 시리즈, 이반 편 & 그루첸카 편 ', content = '', place = '업스테이지(UP Stage)' WHERE provider_type = 'PUBLIC' AND external_id = '373154';
UPDATE festival SET title = '국립오페라단 정기공연 오페라 <베르테르>', content = '국립오페라단은 2026년 정기공연 첫 번째 작품으로 쥘 마스네의 <베르테르>를 무대에 올린다. 총 4막으로 구성된 이 작품은 소설 『젊은 베르테르의 슬픔』을 원작으로, 이루어질 수 없는 운명 속에서 점점 파멸로 향하는 한 인간의 내면을 섬세하고 서정적인 음악으로 그려낸다. 마스네 특유의 유려한 선율과 감정의 결을 따라 흐르는 관현악은 사랑과 고독, 절망의 감정을 극적으로 응축하여 깊은 심리의 세계로 이끈다. 영화적 시선과 서사 감각을 오페라 무대에 접목해, 파멸로 향하는 베르테르의 내면 풍경을 현대적이면서도 밀도 있게 그려낸다.​', place = '예술의전당 [서울] 오페라극장' WHERE provider_type = 'PUBLIC' AND external_id = '368390';
UPDATE festival SET title = '퍼포먼스 씨어터 <극무서사> 존재의 잔해 편', content = '', place = '서울연극창작센터' WHERE provider_type = 'PUBLIC' AND external_id = '375379';
UPDATE festival SET title = '절창Ⅵ', content = '젊은 소리꾼 최호성, 김우정의 ‘절창(絶唱)’두 소리꾼의 재기 넘치는 호흡으로 전하는 가장 젊고 가장 흥겨운 판소리 무대!', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '368172';
UPDATE festival SET title = '2026 경기시나위오케스트라 치유음악회 <숨, Breath> with 이두헌 밴드', content = '다섯손가락의 리더 이두헌밴드와 전통음악의 현재를 이끌어가는 경기시나위오케스트라의 ‘함께 회복’하는 치유음악회', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '371081';
UPDATE festival SET title = '호남 ICT이노베이션스퀘어 확산사업」 호남 AI·SW 장기과정', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '370103';
UPDATE festival SET title = '오스카상 수상 작곡가 제임스 호너의 <타이타닉> 라이브 필름 콘서트', content = '', place = '세종문화회관 세종대극장' WHERE provider_type = 'PUBLIC' AND external_id = '373779';
UPDATE festival SET title = '[경기 광주] 오감클래식 & 아람북스와 함께하는 촉감콘서트 (4월)', content = '', place = '아람북스 본사 [경기 광주]' WHERE provider_type = 'PUBLIC' AND external_id = '374970';
UPDATE festival SET title = '피예나 그리그 바이올린 소나타 전곡 연주 "Grieg: The Complete Violin Sonatas"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '373028';
UPDATE festival SET title = '[김포] 어린이날 기념 <코드네임X> ', content = '', place = '김포아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '374948';
UPDATE festival SET title = '김치찌개 웨스턴 - 밥주걱과 45구경 권총의 결투', content = '공용 우물이 말라버린 ‘뉴 밀리언 골드 타운’에 희대의 탕아 ‘J.B’가 찾아온다. J.B는 우연히 공용 우물에 관한 비밀을 알게 되고, 이를 독점하고 있는 퀸즈 가(家)의 첫째 에슐리 퀸즈, 유산을 모두 빼앗긴 에드먼드 퀸즈의 싸움에 휘말리게 된다. 물값이 치솟자 망해버린 마을의 살롱을 지키고 있는 잭 솔로는, 말라비틀어진 선인장처럼 위태로워 보인다. 잭 솔로는 J.B.의 다친 다리를 고쳐주고는, 보답으로 총알 한 발을 받는다. 오로지 자신의 이익과 안전만이 주요한 이들의 쫓고 혈투가 벌어지고, 위대한 기다림의 끝에 자연의 반란이 시작된다.', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '368358';
UPDATE festival SET title = '[부산] 베토벤 & 라흐마니노프 ', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '373745';
UPDATE festival SET title = '[인천] 지브리 & 디즈니 영화음악 FESTA (앵콜)', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '373755';
UPDATE festival SET title = '서서울미술관 개관특별 프로젝트 <태각(胎刻)>', content = '', place = '서울시립 서서울미술관' WHERE provider_type = 'PUBLIC' AND external_id = '378438';
UPDATE festival SET title = '한국예술종합학교 4월 마지막주 수요영화관 <어파이어>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '377526';
UPDATE festival SET title = '통영리스타트플랫폼 취·창업 프로그램 <향기 나눔 클래스>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376194';
UPDATE festival SET title = '최정윤의 춤 열세 번째 이야기 <쌍쌍무브>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '374803';
UPDATE festival SET title = '안소희 개인전 《Moiré, 조용히 바라보기》', content = '', place = '인사아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '377014';
UPDATE festival SET title = '동편제 박봉술바디 김금미 완창판소리 <적벽가>', content = '', place = '민속극장풍류' WHERE provider_type = 'PUBLIC' AND external_id = '376700';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 빛을 찾다 나를 보다', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376526';
UPDATE festival SET title = '국립세계문자박물관 특별전시 <글씨상점: 당신의 글씨, 당신의 취향>', content = '', place = '국립세계문자박물관' WHERE provider_type = 'PUBLIC' AND external_id = '387704';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 물길따라 사람 길을 잇다', content = '', place = '김만덕기념관' WHERE provider_type = 'PUBLIC' AND external_id = '376703';
UPDATE festival SET title = '갈현생활문화센터 5월 체험·감상·맞춤형 프로그램', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376235';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 폭풍이 지나간 뒤 다시 시작되는 숲', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376524';
UPDATE festival SET title = '어린이날 행사 <송파 아이 상상 업>', content = '', place = '송파근린공원' WHERE provider_type = 'PUBLIC' AND external_id = '376569';
UPDATE festival SET title = '2026 서울재즈페스타', content = '', place = '여의도 한강공원 물빛광장 특설무대 ''윈더스테이지''' WHERE provider_type = 'PUBLIC' AND external_id = '376499';
UPDATE festival SET title = '2026 정기연주회 중앙환희 & 여명합창단 "행복한 동행"', content = '', place = '인천문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '376847';
UPDATE festival SET title = '어린이날 공연 <중섭, 빛깔 있는 꿈>', content = '과거를 회상하는 한 화가의 그림.그림 속 이미지는 살아 움직이며 이중섭의 서귀포 피난 시절을 보여줍니다. 그리움을 그린 그림이 꿈이 되고, 그런 꿈에서 본 것을 그린 그림들.화가 이중섭이 그린 빛깔 있는 꿈이 우리 곁을 찾아옵니다.', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '376219';
UPDATE festival SET title = '[서울 중구] 지브리 & 디즈니 OST 콘서트 with 첼로댁 ', content = '', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '374422';
UPDATE festival SET title = '2026년 K-뮤지엄 지역 순회 전시 및 투어 지원사업 <이음-확장>', content = '', place = '숙명여자대학교 정영양자수박물관' WHERE provider_type = 'PUBLIC' AND external_id = '383876';
UPDATE festival SET title = '푸투라서울 지구의 밤, 연극 <아트>', content = '', place = '푸투라 서울' WHERE provider_type = 'PUBLIC' AND external_id = '376949';
UPDATE festival SET title = 'Saint-Saëns: 어린이와 함께 연주하는 동물의 사육제', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '375868';
UPDATE festival SET title = '국립항공박물관 어린이날 기념 진로 특화 강연 <Dream Talk>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376527';
UPDATE festival SET title = '2026 부평키즈페스티벌 × 굴포천천히 ‘초록초록 놀이터’', content = '', place = '부평아트센터 야외광장' WHERE provider_type = 'PUBLIC' AND external_id = '376513';
UPDATE festival SET title = '2026 어린이날 아트페스타 ''ON''', content = '', place = '제주아트플랫폼, 예술공간이아, 서귀포꿈꾸는예술터' WHERE provider_type = 'PUBLIC' AND external_id = '377242';
UPDATE festival SET title = '소프라노 강태은 귀국 독창회 "Spectrum"', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '373411';
UPDATE festival SET title = '라하브 샤니 & 뮌헨 필하모닉 (05.06)', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '375194';
UPDATE festival SET title = '한국 근현대미술 속 광주를 읽다 "사회를 반영하는 미술: 앵포르멜의 실상과 새로운 미술들"', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '374335';
UPDATE festival SET title = 'DISTANCE', content = '<!-- wp:paragraph -->
<p>갤러리그림손은 5월 6일(수) - 12일(월)까지 양인숙 개인전 <Distance>을 진행합니다.<strong></strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p> 작가의 작업은 ‘풍선’이라는 익숙하고 가벼운 사물에서 출발합니다. 반복되어 온 형태이자 단순한 기호처럼 여겨졌던 풍선은, 촬영의 과정 속에서 점차 다른 층위의 의미를 드러내기 시작합니다. 작가에게 풍선은 더 이상 특정한 상징으로 고정되지 않고, 기억과 현재 사이를 유영하는 존재로 변화합니다. 그것은 개인적인 감정과 언어로 명확히 설명하기 어려운 상태를 담아내며, 미묘한 감각의 매개로 자리합니다</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>우리는 하나의 자아로 살아가지만, 시간의 흐름 속에서 서로 다른 모습의 자신을 동시에 지닙니다. 완전히 포개어지지 않는 그 사이에는 분명한 간극이 존재하며, 풍선은 바로 그 틈 위에 놓입니다. 어디에도 완전히 닿지 못한 채 부유하는 풍선의 상태는, 지나온 나와 현재의 나 사이에서 발생하는 거리와 닮아 있습니다..</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>자연 속에 놓인 풍선은 특정한 의미를 전달하기보다, 붙잡히지 않는 상태 그 자체로 존재합니다. 그것은 머무르지 못하는 감각, 정의되지 않는 감정을 환기시키며, 관람자로 하여금 자신의 시간과 내면을 비껴 바라보게 만듭니다. 작가는 그 장면을 통해 지금의 자신과 이미 지나온 자신을 일정한 거리 위에서 마주하는 경험을 제안합니다..</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 ‘나와 나 사이의 거리’라는 비가시적인 감각을 시각적으로 기록한 작업입니다. 이미지들은 어떤 결론을 제시하기보다, 잠시 멈춰 서서 스스로의 내면을 응시하도록 이끌고 관람자는 각자의 시간과 감정이 교차하는 지점에서, 조용히 자신만의 거리를 들여다보는 순간을 마주하게 될 것입니다.</p>
<!-- /wp:paragraph -->', place = '갤러리 그림손' WHERE provider_type = 'PUBLIC' AND external_id = '378455';
UPDATE festival SET title = '김경렬 초대전', content = '<!-- wp:paragraph -->
<p>''After Human : 일상의 조각''</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리 전은 2026년 5월 6일부터 5월 30일까지 <청년작가 Project> 선정 작가 2인 중 김경렬의 초대전 <After Human : 일상의 조각>을 개최한다. 이번 전시는 기능을 상실한 전자부품과 일상에서 밀려난 사물들을 재구성하여, 소멸 이후에도 지속되는 존재의 흔적과 새로운 질서를 탐구하는 작업을 선보인다. 김경렬(K-LYUL)은 ‘순환조각’이라는 조형 언어를 통해 버려진 물질이 단순한 폐기가 아닌 또 다른 존재로 전환되는 과정을 시각화해 왔다. 작가는 회로기판, 금속 구조물, 배선, 스피커 등의 전자부품을 해체하고 재결합하여 인간의 얼굴과 신체를 연상시키는 형상을 구축한다. 이때 중요한 것은 재료의 기능이나 출처가 아닌 기능을 잃은 물질이 새로운 구조와 질서를 획득하는 과정이다. 산업적 역할을 벗어난 부품들은 정지된 인체와 같은 형태로 놓이며 인간 이후에도 지속될 감각의 흔적을 드러낸다.</p>
<!-- /wp:paragraph -->', place = '갤러리전' WHERE provider_type = 'PUBLIC' AND external_id = '378268';
UPDATE festival SET title = '<연쇄된 악의> - 제47회 서울연극제 자유참가작', content = '', place = '공간아울' WHERE provider_type = 'PUBLIC' AND external_id = '376838';
UPDATE festival SET title = '절레절레동화', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '378233';
UPDATE festival SET title = '<밑바닥1930> - 제47회 서울연극제 자유경연작', content = '', place = '열린극장' WHERE provider_type = 'PUBLIC' AND external_id = '375892';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 오늘이 내 인생의 가장 젊은 날 "자연을 잇고, 삶을 엮다"', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376705';
UPDATE festival SET title = '<PORTRAIT : 초상사진이 빚어내는 심연의 미학>', content = '', place = '갤러리 스페이스포포' WHERE provider_type = 'PUBLIC' AND external_id = '378068';
UPDATE festival SET title = '겹처진 시간의 흔적', content = '<!-- wp:image {"id":18274,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/05/홈피-배너.jpg" alt="" class="wp-image-18274" /></figure>
<!-- /wp:image -->

<!-- wp:separator {"className":"is-style-default"} -->
<hr class="wp-block-separator has-alpha-channel-opacity is-style-default" />
<!-- /wp:separator -->

<!-- wp:heading -->
<h2 class="wp-block-heading">Info</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p><strong>Title </strong>: 겹쳐진 시간의 흔적</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Artist </strong>: Kwon Ki-ja (권기자)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Dates </strong>: 2026. 05. 07 – 05. 23</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Venue </strong>: 대구광역시 중구 봉산문화길 60</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Hours </strong>: 10:30 AM – 6:30 PM(Closed on Sundays)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>Inquiry </strong>: 053-252-0614</p>
<!-- /wp:paragraph -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity" />
<!-- /wp:separator -->

<!-- wp:heading -->
<h2 class="wp-block-heading">Exhibition Statement</h2>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p>현대 미술에서 ‘시간’은 오랫동안 추상적이고 비물질적인 영역으로 머물러 왔습니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>많은 작가들이 찰나의 순간을 기록하거나 영원을 갈구해 왔으나, 시간을 물리적인 부피와 질량으로 치환하여 눈앞에 제시하는 시도는 드뭅니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>권기자의 작업은 바로 이 지점, 즉 보이지 않는 시간의 흐름을 ‘물성(Materiality)’이라는 실체로 고정하고 집적하는 미학적 실험에서 출발합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>권기자에게 물감은 형상을 재현하기 위한 도구를 넘어, 그 자체로 존재론적 의미를 지니는 ‘물질’입니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 평면의 캔버스가 지닌 숙명적 한계를 극복하기 위해 물감을 고체화하고 오브제화하는 독창적인 조형 언어를 구축해 왔습니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그녀의 화면 위에서 물감은 더 이상 색채의 수단이 아니라, 겹겹이 쌓여 굳어진 ‘시간의 화석’이자 작가의 사유가 응축된 ‘지층’으로 기능합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시 《Time Accumulation》에서 선보이는 작품들은 치열한 수행성(Performativity)의 결과물입니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>물감을 흘리고, 건조하고, 압축하여 단면을 베어내는 7단계 이상의 고된 공정은 작가의 신체가 직접 개입된 노동의 기록입니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>지문이 마모될 정도의 반복적인 행위 끝에 드러나는 매끄러운 단면(Stratum)은 작가가 캔버스 앞에서 보낸 인내의 시간을 정직하게 증언합니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>중력에 의한 자연스러운 흐름과 작가의 의지적인 절단이 교차하는 이 지점에서, 작품은 회화의 평면성을 탈피하여 조각적인 실재감을 획득합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>권기자의 작업은 관람객에게 현상학적인 경험을 제안합니다. 멀리서 마주하는 서정적인 색채의 울림은 감각의 희열을 선사하지만, </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>가까이 다가섰을 때 마주하는 물감의 조밀한 층위는 삶의 무게와 존재의 숭고함을 환기시킵니다. 이번 전시는 찰나의 시각적 즐거움을 넘어, </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>억겁의 시간이 응축된 물성의 결을 통해 ‘그저 존재하는 것’만으로도 충분한 예술적 위로를 전달하는 자리가 될 것입니다.</p>
<!-- /wp:paragraph -->', place = '갤러리제이원' WHERE provider_type = 'PUBLIC' AND external_id = '378336';
UPDATE festival SET title = '소나기마을 어버이날 특별체험 <부모님께 드리는 꽃 한 송이>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '378426';
UPDATE festival SET title = '김영찬 <감각의 분모>_아르코 댄스 UP:RISE 2026', content = '<감각의 분모>는 감각의 차이와 공존의 가능성을 탐구하는 작업이다.', place = '대학로예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375757';
UPDATE festival SET title = '판소리 음악극 <긴긴밤>', content = '제21회 문학동네어린이문학상 대상. 판소리로 재탄생한 동화 ‘긴긴밤’. 전 연령이 공감할 ‘삶’과 ‘용기’, ‘기적’의 스토리', place = '강동아트센터 소극장 드림' WHERE provider_type = 'PUBLIC' AND external_id = '375816';
UPDATE festival SET title = '설불연(舌不燃) - 단초 최창덕의 춤·잇다', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '378454';
UPDATE festival SET title = '[서울] ACC x QUAD 기언치, 봄 <헉_Hug>', content = '', place = '서울문화재단 대학로극장 쿼드' WHERE provider_type = 'PUBLIC' AND external_id = '373329';
UPDATE festival SET title = '2026 국립극장 <완창판소리> 5월', content = '판소리의 긴 여정을 처음부터 끝까지 함께하는 국립극장 <완창판소리>. 김미진 명창이 ''춘향가'' 김세종제로 단정한 미감과 서정성을 온전히 전하며 판소리 한 바탕의 깊이를 선보인다.', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '375810';
UPDATE festival SET title = '[인천] M&M 시리즈 Ⅰ: 프로코피예프 & 최송하 ', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '375200';
UPDATE festival SET title = 'GS아트센터 X 국립심포니오케스트라 <피터와 늑대 ＆ 어미 거위>', content = '', place = 'GS아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '377957';
UPDATE festival SET title = '여는마당 : 프로파간다', content = '“극장에서 공연을 보는 관객은 혁명적일 수 있다.”', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375755';
UPDATE festival SET title = '2026 부모교육 강연 시리즈 <온-아이> : 김붕년 교수편', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376019';
UPDATE festival SET title = '''장욱진의 대화: 서로가 된 풍경'' 전시연계 교육 《행복한 우리집》', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '377629';
UPDATE festival SET title = '2026 마포아트센터 광장문화축제 <무대위의 책방>', content = '', place = '마포아트센터 앞 광장' WHERE provider_type = 'PUBLIC' AND external_id = '377854';
UPDATE festival SET title = '어린이 전시 프로젝트 《아뜰리에 아이 atelier I》', content = '', place = 'KT&G 상상마당 [춘천]' WHERE provider_type = 'PUBLIC' AND external_id = '381363';
UPDATE festival SET title = '2026년 예술공간 광명시작 <광명시작에서 예술하기>', content = '', place = '광명문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '380351';
UPDATE festival SET title = '라하브 샤니 & 뮌헨 필하모닉 (05.09)', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '375262';
UPDATE festival SET title = '우리동네사람들 시즌6 “소리를 넘어, 마음으로”', content = '', place = '세종문화회관 세종M씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '376697';
UPDATE festival SET title = '지브리 & 디즈니 오케스트라 콘서트', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '375913';
UPDATE festival SET title = '로드 무비: 1945년 이후 한·일 미술', content = '<p style="line-height: 1.8;"><span style="font-size: 12pt;">지리적으로도 문화적으로도 가까운 타자로서 오랜 역사를 걸어온 한국과 일본. 1945년 이후 오늘날에 이르기까지 양국의 현대미술은 어떠한 관계를 맺어왔을까. 양국간의 접점과 단절, 공통점과 차이점을 살펴보면 서로의 미술사를 새로운 시각으로 보게될 수도 있습니다. 1965년 한일국교정상화 60주년을 맞아 국립현대미술관과 일본의 요코하마미술관이 공동 기획으로 한국과 일본의 현대미술 교류사를 살펴보고자 합니다. 이번 전시는 2025년 12월 요코하마미술관에서 먼저 개막한 후, 2026년 국립현대미술관에서 개최될 예정입니다.</span></p>', place = '국립현대미술관 과천관' WHERE provider_type = 'PUBLIC' AND external_id = '292206';
UPDATE festival SET title = '[보성] 송소희 Χ 두번째달 Χ 오단해: 모던민요 ', content = '', place = '보성군문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '376388';
UPDATE festival SET title = '클래시칸앙상블 시그니처콘서트 Vol. 3 “The String Sound”', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '374306';
UPDATE festival SET title = '찾아가는 시민 참여형 워크숍 <미술관 가까이>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '376882';
UPDATE festival SET title = '[경주] 가족뮤지컬 <겨울이야기> ', content = '', place = '서라벌문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '388064';
UPDATE festival SET title = '해리 포터와 죽음의 성물™ Part II 인 콘서트', content = '마침내 최후의 전투가 시작된다. 라이브 심포니 오케스트라가 선사하는 알렉상드르 데스플라의 생생한 음악과 함께, 거대한 스크린 위에서 펼쳐지는 단 한 번뿐인 감동의 순간을 직접 경험해보자.', place = '세종문화회관 세종대극장' WHERE provider_type = 'PUBLIC' AND external_id = '388194';
UPDATE festival SET title = '앙상블 플루텟 제11회 정기연주회 "Classic & Modern"', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '375079';
UPDATE festival SET title = '국립발레단 〈더블 빌_맥그리거＆테틀리〉', content = '도심의 분주한 표면 아래 숨겨진 인간의 내면 풍경웨인 맥그리거 <인프라>10년 만에 다시 만나는 무대! 원초적 제의의 뜨거운 에너지와 압도적인 군무글렌 테틀리 <봄의 제전> 동시대 예술의 정점에 이른 현대 발레 두 편을 한 무대에서!', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '373932';
UPDATE festival SET title = '디즈니 인 콘서트 <Beyond the Magic>', content = '대형 스크린에서 펼쳐지는 디즈니 애니메이션 영상과 실력파 뮤지컬 배우들, 오케스트라가 어우러져 완벽한 하모니를 선사하는 공식 라이선스 콘서트', place = '춘천문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '376201';
UPDATE festival SET title = '2026 로열인문학 <윤일상의 창작노트를 훔치다>', content = '', place = '관악문화재단 관악아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379188';
UPDATE festival SET title = '한국페스티발앙상블 창단 40주년 : 유혹, 마흔번째 악장 <콘서트, 첫 나들이>', content = '', place = '일신홀' WHERE provider_type = 'PUBLIC' AND external_id = '377744';
UPDATE festival SET title = '[부평] 제15회 부평구립소년소녀합창단 정기연주회 <우리들의 시간>  ', content = '', place = '부평아트센터 달누리극장' WHERE provider_type = 'PUBLIC' AND external_id = '379573';
UPDATE festival SET title = '박유라 <스턴트>_아르코 댄스 UP:RISE 2026', content = '몸을 하나의 통합된 주체가 아닌 기능, 표현, 감각이 분리된 상태로 상상하며, 가시화된 힘, 충돌하는 몸과 그 사이에서 발생하는 관계성을 탐구', place = '대학로예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375758';
UPDATE festival SET title = 'In search of paradise: 낙원을 찾아서', content = '“어디에도 없다. 동시에 어디에나 존재한다.” 낙원은 낙원을 찾는 이의 눈 속 세계다.', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375759';
UPDATE festival SET title = '국립현대무용단 어린이 무용 <젤리디너>', content = '천천히 돌아가도, 실수투성이어도 괜찮아! 구르고, 넘어지고, 튀어오르며 돌아가는 달콤한 젤리 공장의 우당탕탕 하루! 편한 지름길 대신 돌고 돌아 가는 과정이 얼마나 흥미롭고 재미난 이야기로 넘쳐나는지에 대해 이야기하는 <젤리디너>', place = '예술의전당 [서울] 자유소극장' WHERE provider_type = 'PUBLIC' AND external_id = '374798';
UPDATE festival SET title = '장사익 소리판 <봄바람>', content = '전통 소리꾼 장사익의 다양한 음악세계를 통해 인생의 희로애락과 위로의 메시지를 전합니다. 우리 소리의 본질적 가치와 정서를 현대적으로 풀어내며 감동을 선사하는 장사익의 소리판에 여러분을 초대합니다.', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375814';
UPDATE festival SET title = '2026 <내가Green양양> 에코 웨이브 페스티벌', content = '', place = '웨이브웍스' WHERE provider_type = 'PUBLIC' AND external_id = '379353';
UPDATE festival SET title = '박주원 개인전 : 0시의 온도', content = '<!-- wp:paragraph -->
<p> 어떤 말과 행동은 끝내 언어가 되지 못한 채, 침묵과 흔적으로만 남는다. 박주원의 회화는 의미가 부여되지 못한 침묵의 감각, 그리고 부재가 남긴 흔적에서 시작된다. 작가는 타인과의 만남이 단순한 사건이 아니라, 자아가 형성되고 흔들리는 근원적인 장면이라고 느꼈다. 그녀는 고정된 형태가 아니라 서로의 감정과 기억이 스치고 겹쳐지며 끊임없이 변하는 ‘관계의 서사’의 흐름에 주목한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>회화 속 반복되는 이미지들은 개별적인 단위로 존재하지만, 서로의 자리를 침범하고 중첩되며 하나의 심리적 풍경을 만든다. 시간 속에서 겹겹이 쌓이고 퇴적되는 관계처럼 단순한 배경이 아니라, 기억과 감정이 스며드는 시간의 밀도이자 침묵의 공간이 된 화면 속에서 관람자는 자신이 지나온 관계의 흔적들을 마주하게 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>박주원의 회화에서 느껴지는 관계와 부재, 기억과 침묵 사이의 모호한 경계 위에 서 있는 관람자가 느낄 온도는 하루가 끝나고 또 다른 시간이 시작되기 직전의 시각, 모든 움직임과 소음이 잠시 멈춘 듯한 0시의 시간과 닮아 있다.</p>
<!-- /wp:paragraph -->', place = '갤러리 이마주' WHERE provider_type = 'PUBLIC' AND external_id = '380275';
UPDATE festival SET title = '2026 남해바래길 월정기걷기 ''작은 소풍'' 5월', content = '', place = '본선 3코스 동대만길' WHERE provider_type = 'PUBLIC' AND external_id = '378413';
UPDATE festival SET title = '국립익산박물관 월간 버스킹 <박물관 속 음악산책>', content = '', place = '국립익산박물관 ''역사의 거울'' 야외공간' WHERE provider_type = 'PUBLIC' AND external_id = '379528';
UPDATE festival SET title = '국립세계문자박물관 특별전시 연계 <작가와의 대화>', content = '', place = '국립세계문자박물관' WHERE provider_type = 'PUBLIC' AND external_id = '387906';
UPDATE festival SET title = '헤르만아트홀 기획연주, 김성은 & 손가슬 소프라노 듀오 리사이틀', content = '', place = '헤르만아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '378461';
UPDATE festival SET title = ' 김민준 피아노 독주회 ‘Fantasy II’', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '374308';
UPDATE festival SET title = 'Heritage Series: The Masters, 토마스 체헤트마이어 & 프랑스 오베르뉴론알프 국립 오케스트라', content = '', place = '신영체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '377159';
UPDATE festival SET title = '소설 창작 워크숍 <봄비> [가정법 클럽]', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '377866';
UPDATE festival SET title = '임주빈의 Listen & Lesson 클래식의 첫걸음', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '374797';
UPDATE festival SET title = '2026 심산 영화관 <하얼빈>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '378364';
UPDATE festival SET title = '이영주 피아노 리사이틀 “슈베르트 피아노 소나타 전곡 시리즈 I”', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '374327';
UPDATE festival SET title = '클라라 주미 강 & 김선욱 듀오 리사이틀', content = '흠잡을 데 없는 우아함과 균형감을 갖춘 바이올리니스트 클라라 주미 강,그리고 피아니스트이자 지휘자로서 한층 깊어진 음악세계를 펼쳐온 김선욱2021년 이후 5년 만의 듀오 무대!', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '373933';
UPDATE festival SET title = '태수연 피아노 독주회 "IMMEASURABLE LOVE: FROM EDEN TO ETERNITY"', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '372152';
UPDATE festival SET title = '축구와 그 이야기 «골, 그 너머»', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '383256';
UPDATE festival SET title = '2026 동시대미감전 <김덕용: 빛과 결, 自生之美> 전시 연계 세미나', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '377626';
UPDATE festival SET title = '토크 음감회 <오디오 라이브, 바이닐 라이프>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '379529';
UPDATE festival SET title = '민속악단 기획공연 <인생, 노래로 흐르다>', content = '전통 성악곡에 담긴 삶의 태도와 지혜를 짚어보고, 오늘날 우리의 삶과 연결해 이야기를 나누는 무대입니다. 서도와 경기의 긴소리, 남도의 단가와 가야금병창 등 지역마다 다른 소리를 통해 민초들의 위대한 관조와 해학, 그리고 수용의 정신을 만나봅니다. 출연자와 객석의 소통을 통해 서로의 삶을 나누고 치유를 경험하는 따뜻한 시간을 함께하시기 바랍니다.', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '376220';
UPDATE festival SET title = '한국 근현대미술 속 광주를 읽다 "형상미술과 민중미술: 주변부 의식에서 역사의 주체로"', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '374337';
UPDATE festival SET title = '김정아 개인전 - 푸른 골목의 안쪽', content = '<!-- wp:paragraph -->
<p>2026. 05. 20 - 06. 07 토포하우스 제 3전시실</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":18530,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/05/전경사진-small.jpg" alt="" class="wp-image-18530" /><figcaption class="wp-element-caption">토포하우스 제 3전시실</figcaption></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong>전시 개요</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>서울 종로구 인사동의 토포하우스는 김정아(Kim Jungah·56) 작가 개인전, <푸른 골목의 안쪽>을 5. 20일부터 6. 7일까지 개최한다. 작가가 대학과 대학원을 다닌 서울 변두리와 이후 25년을 거주한 경남 거제도가 모티브이며 공간및 장소 탐미적 작품 20여점을 선 보인다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":18531,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/05/작품사진-small.jpg" alt="" class="wp-image-18531" /><figcaption class="wp-element-caption">김정아 밤의 숲 72x194cm 캔버스에 아크릴릭 2020.</figcaption></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><strong>작가 소개</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>김정아<strong> </strong>(1970년생)<br>전북 전주시 전주여고(1989년)졸업<br>서울대학교 미술대학 서양화과(1995년)및 동대학원 서양화과 판화전공(2002년) 졸업<br>2025 제10회 메디치상 수상</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>개인전</strong><br>2026 푸른 골목의 안쪽, 토포하우스, 서울<br>2025 한걸음 다가서면 바꿀 수 있어요, 두손갤러리, 학고재아트센터, 서울<br>총 18회 개인전</p>
<!-- /wp:paragraph -->', place = '토포하우스' WHERE provider_type = 'PUBLIC' AND external_id = '380726';
UPDATE festival SET title = '제47회 서울연극제, 나도향 소설전: 물레방아 & 벙어리 삼룡이', content = '', place = '열린극장' WHERE provider_type = 'PUBLIC' AND external_id = '380316';
UPDATE festival SET title = '예술의전당 X 서울시립교향악단', content = '"낯선 설렘이 깊은 감동으로 이어지는 시간"  서울시립교향악단, 홍석원, 이관욱의 첫 호흡이 눈부신 음악의 순간으로 펼쳐집니다.', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '374348';
UPDATE festival SET title = '<춘섬이의 거짓말> - 제47회 서울연극제 공식선정작', content = '최초의 한글소설 《홍길동전》의 숨겨진 시작아무도 몰랐던 홍길동의 어머니, 열여덟 춘섬이.아버지를 아버지라 부르지 못하는 진짜 이유', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375762';
UPDATE festival SET title = '미미의 미미한 연애', content = '미미의 복잡한 속마음이 환상적인 장면으로 구현되는 공놀이클럽 특유의 유쾌한 ‘놀이의 연극’. ​', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '375763';
UPDATE festival SET title = '국립극단 <반야 아재>', content = '웃음 뒤에 남은 가장 깊은 감정의 폭발, 연극 <반야 아재> 흔들리는 삶 속에서도 멈추지 않는 것, 결국 그것이 우리의 이야기.', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '375067';
UPDATE festival SET title = '이자람 판소리 〈눈, 눈, 눈〉', content = '광활한 설원, 하룻밤 사이 펼쳐지는 생의 노래. 판소리 창작자이자 한국 공연계를 대표하는 퍼포머인 이자람의 신작으로 톨스토이 단편 ''주인과 하인''을 판소리로 재창작한 작품이다.', place = '성남아트센터 오페라하우스' WHERE provider_type = 'PUBLIC' AND external_id = '376085';
UPDATE festival SET title = '연극 <렁스> : 연극열전10_아홉 번째 작품', content = '', place = '충무아트센터 중극장 블랙' WHERE provider_type = 'PUBLIC' AND external_id = '377367';
UPDATE festival SET title = '[전주] 서커스쇼&초대형레이져공연 ', content = '', place = '전주교육문화회관(전북교육문화회관) 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '377502';
UPDATE festival SET title = '2026 사단법인 포아피아노연구회 기획 - 모차르트 피아노 협주곡 전곡 연주 프로젝트 "음악의 위대한 유산, <모차르트의 Artistry>"', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '374311';
UPDATE festival SET title = '로데아트센터 개관 2주년 기념 FRIENDS 시리즈: Clarinet & Friends', content = '', place = '로데아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '377594';
UPDATE festival SET title = '모스크바홀 초청연주, 이재유 피아노 독주회 <Chopin Etudes>', content = '', place = '모스크바홀' WHERE provider_type = 'PUBLIC' AND external_id = '378976';
UPDATE festival SET title = '[전시 공모] 2026 남산골 아트 프로젝트 <겹, Layer-層>', content = '', place = '남산골한옥마을' WHERE provider_type = 'PUBLIC' AND external_id = '381551';
UPDATE festival SET title = '2026 동대문문화재단 기획공연 <브런치 콘서트 아트리움 "국립오페라스튜디오">', content = '', place = '선농단역사문화관' WHERE provider_type = 'PUBLIC' AND external_id = '381343';
UPDATE festival SET title = '손철주의 오래된 그림공부 <그림을 듣거나 만지다>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '380584';
UPDATE festival SET title = '《서화무진》전시 연계 라운드 테이블 <끝나지 않는 한국화 이야기, 함께 말하다>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '379530';
UPDATE festival SET title = '한국예술종합학교 5월 넷째 주 수요영화관 <죠스>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '381230';
UPDATE festival SET title = '[서초문화원] 서초인문학 아카데미 [환상의 섬 제주 이어도, 세계를 잇는 한국 문화]  강병철 시인·양금희 시인', content = '', place = '서초문화예술회관(구. 서초구민회관) 아트홀(대강당)' WHERE provider_type = 'PUBLIC' AND external_id = '377622';
UPDATE festival SET title = '보이는 현대사 들리는 현대사 <DMZ 경계와 시선>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '377859';
UPDATE festival SET title = '춤기획 舞 & 무...열 겹, 칠보 II: 일곱 가지 보석', content = '', place = '서울돈화문국악당' WHERE provider_type = 'PUBLIC' AND external_id = '380539';
UPDATE festival SET title = '오페라박물관 야외음악회 <Blooming Sounds>', content = '', place = '오페라박물관' WHERE provider_type = 'PUBLIC' AND external_id = '379097';
UPDATE festival SET title = '인상주의를 넘어: 르누아르·드가·고흐·마티스·피카소', content = '', place = '세종문화회관 미술관' WHERE provider_type = 'PUBLIC' AND external_id = '381354';
UPDATE festival SET title = '[서천] 가족매직쇼, 서커스 & 매직 ', content = '', place = '기벌포복합문화센터 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '377922';
UPDATE festival SET title = '이보라 피아노 독주회 "바흐의 아들들 시리즈 III : The Art of Fantasy"', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '372999';
UPDATE festival SET title = '국립극장 기획 <당신 좋을 대로>', content = '셰익스피어 희극 『As You Like It』. 20여 명의 인물로 구성된 이야기를 7명의 배우가 새롭게 풀어내고, 배우들만의 고유한 신체 표현과 감각으로 언어유희를 넘어서는 리듬과 유머를 만들어 객석을 뒤집는다.', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '375811';
UPDATE festival SET title = '뮤지컬 <전설의 리틀 농구단>', content = '"그냥 농구나 한판 하는 거야!" 젊은 창작 뮤지컬의 신화로 불리는 뮤지컬 <전설의 리틀 농구단> 10주년 기념공연! 가장 빛나던 그때 그 시절, 코트 위에서 터지는 웃음과 땀 그리고 푸른 청춘들의 뜨거운 농구 한 판!', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '373934';
UPDATE festival SET title = '김창열 화가의 집 개관전 <김창열, 물방울의 흔적>', content = '', place = '종로문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '394839';
UPDATE festival SET title = 'Re-프로젝트 형식의 재발견', content = '국악관현악을 동시대적 시각에서 실험적으로 재해석하는 ''Re-프로젝트''. 작곡가 이하느리의 서곡과 정일련의 장편 심포니 형식 신작을 초연, 국악관현악에도 교향곡적 서사와 긴 호흡의 구조를 시도한다.', place = '세종문화회관 세종M씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '375021';
UPDATE festival SET title = '[부산] 클라라 주미 강 & 김선욱 듀오 리사이틀', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '378896';
UPDATE festival SET title = '[부산] 지브리 & 디즈니 영화음악 FESTA ', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379022';
UPDATE festival SET title = 'ASAC 가족뮤지컬 <할머니의 여름휴가>', content = '손자의 꿈을 따라 나선 할머니의 재미있는 추억선물! 6m 거대 고래와 인어 플라잉쇼, 화려한 볼거리가 넘치는 무대', place = '안산문화예술의전당 해돋이극장' WHERE provider_type = 'PUBLIC' AND external_id = '374596';
UPDATE festival SET title = '가가호호 홍보형 기획사업 <우리 가족 다 함께>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '381089';
UPDATE festival SET title = '박선주 <Practice Room> - 가야금 연습실 워크숍', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '378690';
UPDATE festival SET title = '제7회 이수진 가야금 독주회 <絃의 여행 IV>', content = '', place = '한국문화의집 KOUS' WHERE provider_type = 'PUBLIC' AND external_id = '378431';
UPDATE festival SET title = '2026 국립극장 지역문화거점 공연 창극콘서트 <토선생, 용궁가다> ', content = '', place = '제천예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '377995';
UPDATE festival SET title = '[제주 서귀포] 우리음악앙상블 풍경소리 <웡이자랑> ', content = '', place = '김정문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '380519';
UPDATE festival SET title = '광명 스테이지 ON: 리처드 용재 오닐 & 박종해 듀오 리사이틀', content = '', place = '광명시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '378521';
UPDATE festival SET title = '[부산] NAC 시그니처 클래식 Ⅲ, 슈베르트 5번 & 베토벤 3중 협주곡', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '378246';
UPDATE festival SET title = '재즈in강서: TAP & TALK', content = '', place = '강서아트리움 아리홀' WHERE provider_type = 'PUBLIC' AND external_id = '378197';
UPDATE festival SET title = '2026 창작ing 연극 <양떼목장의 대혈투> 관객과의 대화', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '379446';
UPDATE festival SET title = '[서울시립과학관]  2026년 성인을 위한 은근히 밀도있는 과학교실 ''은밀한 사이언스''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '388932';
UPDATE festival SET title = '2026년 <문화:소셜 플래너> 양성과정(진입/성장과정)', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '380467';
UPDATE festival SET title = '뮤지컬 <공명>', content = '', place = '브릭스씨어터 (구. 콘텐츠 그라운드 구. 브로드웨이아트홀 [3관])' WHERE provider_type = 'PUBLIC' AND external_id = '380204';
UPDATE festival SET title = '[강북문화재단] 2026 강북문화대학 문화예술교육 전문가 과정 <예술놀이 기획자 과정> 참여자 모집 공고', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '384384';
UPDATE festival SET title = '2026 기형도문학관 기획전시 <다시, 그 길 위의 우리: 길 위에서 중얼거리다>', content = '', place = '기형도문학관' WHERE provider_type = 'PUBLIC' AND external_id = '384083';
UPDATE festival SET title = '[부산] 제22회 부산국제무용제 <제1회 BIDF 프린지: DAY 1>', content = '', place = '(재)영화의전당 하늘연극장' WHERE provider_type = 'PUBLIC' AND external_id = '378488';
UPDATE festival SET title = '박은하 한빛전통예술단, “십이지정(十二支情)ㆍ하나의 숨”', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '382060';
UPDATE festival SET title = '원민지 첼로 독주회 "바흐 무반주 첼로 모음곡 전곡 시리즈 II"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '378166';
UPDATE festival SET title = '[부산] 제22회 부산국제무용제 <제1회 BIDF 프린지: DAY 2>', content = '', place = '(재)영화의전당 하늘연극장' WHERE provider_type = 'PUBLIC' AND external_id = '380528';
UPDATE festival SET title = '연극 <미미의 미미한 연애>', content = '', place = '마포아트센터 플레이맥' WHERE provider_type = 'PUBLIC' AND external_id = '381958';
UPDATE festival SET title = '국회 개방 정오의 콘서트 <6월 국회 버스킹>', content = '', place = '국회사무처' WHERE provider_type = 'PUBLIC' AND external_id = '381396';
UPDATE festival SET title = '[PAC] 키다리밴드 <추억을 노래하다>', content = '', place = '평택아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '377275';
UPDATE festival SET title = '[서초문화재단 x 이탈리아문화원 공동기획 시리즈 1] 낭만주의와 현대음악 사이 <시간 속의 대화>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379727';
UPDATE festival SET title = '[청주문화의집] 2026 문화예술 교육프로그램 <코끼리를 삼킨 보아뱀> 프로그램 참여자 모집', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '383276';
UPDATE festival SET title = '제22회 부산국제무용제 특별초청공연-캐나다 퀘벡 포커스 <위기의 시대 존재를 묻다>', content = '', place = '(재)영화의전당 하늘연극장' WHERE provider_type = 'PUBLIC' AND external_id = '378815';
UPDATE festival SET title = '변정은 & 유예지 피아노 듀오 리사이틀', content = '', place = '꿈의숲아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382337';
UPDATE festival SET title = '광주시립교향악단, GSO 오티움 콘서트 Ⅱ. ''Viola''', content = '', place = '광주예술의전당 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '378752';
UPDATE festival SET title = '관현악시리즈IV <이병우와 국립국악관현악단>', content = '그가 참여하면, 천만 관객은 따놓은 당상! <국제시장> <해운대> <괴물> <왕의 남자>의 감동을 이어갈 이병우와 국립국악관현악단의 만남.', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '375807';
UPDATE festival SET title = '[서초문화재단] 서리풀청년예술단 [서초M.스타즈] 5기 예술가곡 시리즈 2] Les Nuits d’ete <여름밤>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379673';
UPDATE festival SET title = '애기봉평화생태공원 6~8월 토요상설공연 <애기봉 플레이리스트> Vol.3 그 여름 날, 애기봉', content = '', place = '김포문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '387186';
UPDATE festival SET title = '제958회 전남도립국악단 토요가무악희 시즌 2, 그린국악: 제71주년 현충일 기념 특집공연 판페라 이순신 & 약무호남 시무국가', content = '', place = '남도소리울림터' WHERE provider_type = 'PUBLIC' AND external_id = '378860';
UPDATE festival SET title = 'Uncaught Third Strike (Not Out)', content = '발레의 형식미와 스포츠의 속도·폭발력을 결합해 ‘확장된 발레’의 예술적 가능성을 제시하며, 사회적으로는 ‘끝나지 않은 경기’라는 메시지를 전한다', place = '대학로예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375767';
UPDATE festival SET title = '<International Spark Place #2> MODAFE 2026', content = '', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '380014';
UPDATE festival SET title = '<MODAFE Choice> MODAFE 2026', content = '', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '379937';
UPDATE festival SET title = ' [서울 송파] 라흐마니노프 피아노 협주곡 <1, 2, 3, 4번>', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379471';
UPDATE festival SET title = '정음피아노앙상블 제7회 정기연주회 "음악으로의 세계여행 02 체코, 헝가리"', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '378602';
UPDATE festival SET title = '더 트라이브', content = '런던의 한 박물관, ''절대 거짓말을 하지 않는 부족''의 전설에 휘말린 두 남녀의 좌충우돌 여정! 예상치 못한 사건과 솔직한 진심이 뒤섞이며 웃음과 순간의 열기가 터져나오고, 경쾌한 리듬과 재치 넘치는 넘버들이 무대를 활보한다.', place = '세종문화회관 세종M씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '375020';
UPDATE festival SET title = '축구와 그 이야기 «한국 속 스페인 축구: 라리가의 전략»', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '383263';
UPDATE festival SET title = '국악주간 기획공연 <관.조.Ⅱ- 나를 비추어 보다>', content = '이 공연은 명상+국악+극장의 본질적 요소들을 결합하여 새로운 극장 경험을 제공합니다.명상을 통해 ''지금 여기''에 존재하는 자신에게 집중하고, 감각들을 깨운 상태에서 공연을 감상하도록 안내함으로써 선율과 장단, 호흡, 움직임, 연주자의 아우라 등 무대 위의 세계에 깊고 섬세하게 몰입할 수 있도록 돕습니다.', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '376221';
UPDATE festival SET title = '국악주간 기획공연 <산조>', content = '한국 전통음악의 미학을 집약한 산조의 전통과 확장, 창작의 흐름을 한자리에서 조명하는 공연으로 ''산조 명인전'', ''산조의 몸짓'', ''오늘의 산조'' 세 가지 프로그램을 만나실 수 있습니다. 명인들의 깊이 있는 연주로 전통 산조의 정수를 만나실 수 있습니다. 연주자와 무용가의 협업으로 산조의 장단과 호흡을 몸짓으로 새롭게 해석하고, 재구성·창작 작품을 통해 오늘의 산조가 지닌 가능성도 함께 선보입니다.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '376242';
UPDATE festival SET title = '제11회 늘푸른연극제, 공호석 <작은할머니_그 여자의 소설>', content = '', place = '서울연극창작센터' WHERE provider_type = 'PUBLIC' AND external_id = '383327';
UPDATE festival SET title = '2026 꿈다락문화예술학교 <조각의 뿌리: 입체를 읽다>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '385336';
UPDATE festival SET title = '클래시컬 브릿지 국제 음악 페스티벌, 다비드 첸 & 루카 시쉬 조인트 리사이틀 (06.10)', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379666';
UPDATE festival SET title = '한국 근현대미술 속 광주를 읽다 "세계화, 국제화, 다원: 민족미술에서 동시대 미술로"', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '374338';
UPDATE festival SET title = '제3회 R&J씨어터 창작극 페스티벌, 고무동력기', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '381277';
UPDATE festival SET title = '2026 부평문화포럼 <문화로 성장하는 도시, 부평>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '382208';
UPDATE festival SET title = '2026 마포 골목 문화예술교육 <취향도감> 참여자 모집 ', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '383668';
UPDATE festival SET title = '[부산] 목요상설음악회 아트살롱 ''음악을 잊은 그대에게 : 인문학콘서트'' <이탈리아, 영혼의 지도를 그린다>', content = '', place = '동래문화회관 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '379983';
UPDATE festival SET title = '국립국악원 대표공연 <종묘·사직 - 왕의 제단, 백성의 땅>', content = '조선시대 국가의 근간인 ‘종묘’와 ‘사직’에서 거행되었던 제례와 음악을 무대화한 국립국악원의 대표 공연입니다. 향악적 요소가 강한 <종묘제례악>과 중국 아악 계통의 <사직제례악>을 음악적으로 대비시켜, 다채로운 들을거리와 볼거리를 선사합니다. 철저한 고증을 바탕으로 한 악·가·무와 국내 최고의 연주를 통해 궁중 의례 음악의 정수를 만나보시기 바랍니다.', place = '국립국악원 예악당' WHERE provider_type = 'PUBLIC' AND external_id = '376243';
UPDATE festival SET title = '클래시컬 브릿지 국제 음악 페스티벌, 다니엘 로자코비치, 미하일 플레트네프 & 라흐마니노프 인터내셔널 오케스트라 (06.11)', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379670';
UPDATE festival SET title = '노예리 바이올린 독주회 ‘Sonatas in Time and Color’', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '376016';
UPDATE festival SET title = '경기필 마스터피스 시리즈 III <시벨리우스 교향곡 2번>', content = '경기필 마스터피스 시리즈의 세 번째 공연으로, 지휘자 윤한결과 피아니스트 데니스 코츠킨이 호흡을 맞춰 독일 낭만주의의 깊이와 북유럽의 장엄한 서사를 집중 조명한다.', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '375022';
UPDATE festival SET title = '국립현대무용단 <내가 물에서 본 것>', content = '의학 기술에서 몸의 위치는 과연 어디에 있을까? 주변부에 머물러 있는 몸에 관한 의심과 질문  수차례 난임 시술을 받은 안무가의 경험을 통한 포스트휴먼적 몸의 형상화 국립현대무용단 김보라 안무 <내가 물에서 본 것>', place = '예술의전당 [서울] CJ 토월극장' WHERE provider_type = 'PUBLIC' AND external_id = '374831';
UPDATE festival SET title = ' <오리지날 드로잉 쇼!>', content = '', place = '인천수봉문화회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '379463';
UPDATE festival SET title = '<싱글즈> 런＆플로우 페스티벌 SRFF2026 with 엠스컬프 네오', content = '', place = '문화비축기지 문화마당' WHERE provider_type = 'PUBLIC' AND external_id = '380021';
UPDATE festival SET title = '가족오페라 <신콩쥐>', content = '전래동화 ''콩쥐팥쥐''를 현대적으로 재해석한 가족오페라로 음악·연기·무대미술이 어우러진 감동적인 스토리를 통해 아동과 가족 관객이 함께 공감하고 즐길 수 있는 공연', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '380188';
UPDATE festival SET title = '오영수문학관 ''2026년 상반기 명사초청 특강'' - 황유원', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '380744';
UPDATE festival SET title = '2026 남해바래길 월정기걷기 ''작은 소풍'' 6월', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '381346';
UPDATE festival SET title = '[부산] NAC 렉처콘서트, BSO 솔로이스츠 실내악 ② 목관5중주 & 금관5중주 ', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '381828';
UPDATE festival SET title = '김송하 피아노 독주회 "내면을 노래하다"', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '378167';
UPDATE festival SET title = '김인하 첼로 독주회 "Cello Essay-X : Between Tradition and Innovation전통과 혁신 사이에서"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '380175';
UPDATE festival SET title = '[인천] Wine & Music Night, 투첼로와 대금의 만남 ', content = '', place = '엘림아트센터 챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '380225';
UPDATE festival SET title = '2026 서울시 민간축제 지원 및 육성사업 <2026 보훈무용제>', content = '', place = '나루아트센터 대, 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '380475';
UPDATE festival SET title = '2026 창운 이열모 기증특별전 <어지러이 푸르른... 필묵의 귀환>', content = '', place = '인천광역시립박물관' WHERE provider_type = 'PUBLIC' AND external_id = '385590';
UPDATE festival SET title = '국토발전전시관 정기강연 ''대한민국 보물지도''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '381581';
UPDATE festival SET title = '제3회 소담정기회원전 "복(福):행복을 담다"', content = '', place = '남도향토음식박물관' WHERE provider_type = 'PUBLIC' AND external_id = '385602';
UPDATE festival SET title = '정명숙 춤 & 최승희 춤의 기억: 現, 마음 자리', content = '', place = '나루아트센터 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '385953';
UPDATE festival SET title = '[특별기획전] 2026년 서울시립과학관 ''지구의 맥박 : EARTH''S PULSE''', content = '', place = '서울시립과학관' WHERE provider_type = 'PUBLIC' AND external_id = '388945';
UPDATE festival SET title = '강서연 두번째 전시 ''시절인연''', content = '기간: 2026.6.16.(화) ~6.28.(일)9:30 - 5:30장소: 국립춘천박물관 어린이박물관 2층 열린전시실주최: 강원서예연합회후원: 국립춘천박물관', place = '국립춘천박물관' WHERE provider_type = 'PUBLIC' AND external_id = '380097';
UPDATE festival SET title = '3초 포토에세이 <김지민>', content = '', place = '애니메이션박물관' WHERE provider_type = 'PUBLIC' AND external_id = '385601';
UPDATE festival SET title = '연극 <꽃, 별이 지나>', content = '', place = '서경대학교 공연예술센터 스콘1관' WHERE provider_type = 'PUBLIC' AND external_id = '391139';
UPDATE festival SET title = '[부천] 드레스덴 필하모닉 & 제임스 에네스 ', content = '', place = '부천아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '380402';
UPDATE festival SET title = '동대문구 아르코 2026년 기획공연 <콘서트 청(淸):ON(6월)>', content = '', place = '동대문구 아르코(DDM ARCO)' WHERE provider_type = 'PUBLIC' AND external_id = '382411';
UPDATE festival SET title = '피터 그라임스', content = '국립오페라단은 2026년 정기공연의 두 번째 작품으로 벤자민 브리튼의 오페라〈피터 그라임스〉를 국내제작초연으로 무대에 올린다.  3막으로 구성된 이 작품은 1945년 영국 초연 이후 현대 영어 오페라를 대표하는 걸작으로 자리해왔다. 외딴 어촌 마을에서 발생한 소년의 죽음, 그리고 그를 둘러싼 끊임없는 의혹이 인간 소외의 문제와 인간 사냥에 휘말려 죽음으로 내몰리는 과정을 보여준다. 지휘는 영국의 피아니스트이자 지휘자인 알렉산더 조엘이 맡아, 브리튼 특유의 긴장감 넘치는 거친 바다의 풍경과 서늘한 긴장감을 풀어낸다. 연출은 2024년 <죽음의 도시>에서 절제된 미학과 섬세함으로 주목받은 줄리앙 샤바가 참여해, 폐쇄적인 공동체와 그 안에서 붕괴되어 가는 인간의 초상을 긴장감 있는 무대로 구현한다.', place = '예술의전당 오페라극장' WHERE provider_type = 'PUBLIC' AND external_id = '376018';
UPDATE festival SET title = '취중연담', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '381611';
UPDATE festival SET title = '연극 <플리백 (Fleabag)> 한국 초연', content = '', place = '두산아트센터 연강홀' WHERE provider_type = 'PUBLIC' AND external_id = '380975';
UPDATE festival SET title = '[부산] 세종국악관현악단 & 김경호의 아리랑목동 ', content = '', place = '동래문화회관 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '381877';
UPDATE festival SET title = '서울시무용단 <미메시스>', content = '여덟 가지 전통춤, 그 본질을 다시 묻다. 한국 창작춤의 산실, 전통춤의 본질을 현대적 감각으로 재해석한 무대', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '375815';
UPDATE festival SET title = '2026 보훈무용제 사전축제 <무색(舞色)-춤의 빛깔>', content = '', place = '나루아트센터 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '380434';
UPDATE festival SET title = '오지랖(OZ Rab) 2.0', content = '오지랖''을 개인화된 사회에서 소원해지기 쉬운 사회적 유대 관계를 끈끈하게 형성하고 유지하며, 정보와 감정을 교환하는 긍정적인 사회적 메신저의 역할로 재해석한다.', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '375772';
UPDATE festival SET title = '[서울 금천] 더작은공연장, 신경다양성 어린이를 위한 참여형 무용 공연 <야호야호 Echoing Dance>', content = '', place = '금천뮤지컬센터 금천예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '380854';
UPDATE festival SET title = '국립합창단 제208회 정기연주회 <하이든 천지창조>', content = '하이든의 오라토리오 <천지창조>는 빛의 탄생부터 만물이 빚어지는 7일간의 과정을 웅장한 합창과 정교한 관현악으로 찬란하게 펼쳐낸 고전주의 걸작이다.', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '376101';
UPDATE festival SET title = '김상진 & 김규연 듀오 리사이틀', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '380799';
UPDATE festival SET title = '[평택] 정여진 & TULA 애니송 콘서트: The Collection ', content = '', place = '평택시북부문예회관' WHERE provider_type = 'PUBLIC' AND external_id = '380922';
UPDATE festival SET title = '[무료공연] 게임음악 오케스트라 콘서트 <LEVEL-UP>에 초대합니다📣', content = '', place = '국립중앙박물관 극장 용' WHERE provider_type = 'PUBLIC' AND external_id = '381751';
UPDATE festival SET title = '[원주 갤러리 원] 정경훈 개인전 "나무 그리고 삶"', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '385171';
UPDATE festival SET title = '2026 주니어아트하우스 1학기 결과전시 《꿈의 공간, 헤테로토피아!》', content = '', place = 'KT&G 상상마당 [춘천]' WHERE provider_type = 'PUBLIC' AND external_id = '387299';
UPDATE festival SET title = '창극 <돈의 신:神>', content = '돈 내려온다! 배우, 악사, 소리꾼, 춤꾼이 한데 펼치는 유쾌한 전통 창극', place = '춘천문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '376202';
UPDATE festival SET title = '2026 보훈무용제 시민참여형 부대행사 <무작(舞作)-춤을 만들다>', content = '', place = '나루아트센터 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '382602';
UPDATE festival SET title = '손영경 & 신애영 피아노 듀오 리사이틀', content = '', place = '영산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382461';
UPDATE festival SET title = '조은정 개인전 <선물 같은 하루>', content = '', place = '비커밍갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '383909';
UPDATE festival SET title = '[광주] 지브리 & 디즈니 영화음악 오케스트라 콘서트 (앵콜)', content = '', place = '광주예술의전당 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '381256';
UPDATE festival SET title = '국립창극단 <효명>', content = '조선 제23대 왕 순조의 아들이자, 궁중무용 정재를 집대성한 인물 효명 세자의 이야기가 펼쳐진다. 창극과 궁중무용이 만나 인간 효명의 내면을 섬세하게 풀어내고, 전통의 깊이를 새롭게 빚어낸다.', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '375813';
UPDATE festival SET title = '청(靑) · 청(淸) · 청(聽)', content = '', place = '슈페리어갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '384471';
UPDATE festival SET title = '2026 이응노미술관 기획전 《이응노·김창열》', content = '', place = '대전 이응노미술관' WHERE provider_type = 'PUBLIC' AND external_id = '385358';
UPDATE festival SET title = '2026 김포예술활동지원사업 성과전시_수사랑회 회원전 ''일상의 행복을 그리다''', content = '', place = '김포문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '385578';
UPDATE festival SET title = '대전광역시 서예진흥원 <서예교육 전문인력양성과정 제3기 작품전> ', content = '', place = '대전광역시 서예진흥원' WHERE provider_type = 'PUBLIC' AND external_id = '384998';
UPDATE festival SET title = '이수민 & 신호철 듀오 리사이틀', content = '', place = '꿈의숲아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384014';
UPDATE festival SET title = '[꿈의숲아트센터] 꿈의숲 마티네 콘서트 <벨에포크 아트 & 뮤직> 시리즈 2', content = '', place = '꿈의숲아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '378601';
UPDATE festival SET title = '존 오코너 피아노 리사이틀', content = '"음악이 시가 되는 밤, 피아노 시인 존 오코너가 남기는 깊은 여운" 아일랜드의 거장 피아니스트 존 오코너가 세월의 깊이를 담은 연주로 다시 찾는 한국 무대', place = '예술의전당 IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '374352';
UPDATE festival SET title = '2026 코르딕 커넥션 프로젝트 <베이비 오페라 전문 워크숍>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '387286';
UPDATE festival SET title = '오페라 <봄봄> & <아리랑 난장>', content = '', place = '금정문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '385852';
UPDATE festival SET title = 'I''m here, the room next door', content = '', place = 'PS CENTER' WHERE provider_type = 'PUBLIC' AND external_id = '385463';
UPDATE festival SET title = '[부산] 제4회 부산소극장오페라축제 창작오페라 <봄·봄> & 전통연희 <아리랑 난장>', content = '', place = '금정문화회관 대공연장(금빛누리홀)' WHERE provider_type = 'PUBLIC' AND external_id = '381425';
UPDATE festival SET title = '낙동아트센터 마티네 콘서트, 성악 앙상블 시리즈 Ⅲ 오네스토 앙상블의 ‘힐링 뮤직브런치’', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '381522';
UPDATE festival SET title = ' <인디스커버리 : CHALLENGE> STAGE 03-04', content = '', place = '마포아트센터 플레이맥' WHERE provider_type = 'PUBLIC' AND external_id = '382172';
UPDATE festival SET title = '이윤지 피아노 독주회 "Shades of Monologue"', content = '', place = '영산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379725';
UPDATE festival SET title = '연극 <나의 완벽한 파트너>', content = '', place = '아신극장 1관 (3층)' WHERE provider_type = 'PUBLIC' AND external_id = '384008';
UPDATE festival SET title = '[인천] 클래식시리즈, 산책Ⅱ. 김홍박 & 아레테 콰르텟: GOLDEN', content = '', place = '인천동구문화체육센터' WHERE provider_type = 'PUBLIC' AND external_id = '381793';
UPDATE festival SET title = '종이여행Ⅱ·Ⅲ 번지면 어떻고, 스며들면 어때', content = '', place = '원주한지테마파크' WHERE provider_type = 'PUBLIC' AND external_id = '386322';
UPDATE festival SET title = '음악공장 노올량 <플레이리스트 : 세대별 아리랑>', content = '', place = '관악문화재단 관악아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '379104';
UPDATE festival SET title = '2026 양평청년작가회 기획전 LIFE·ON·LIFE', content = '', place = '양평군립미술관' WHERE provider_type = 'PUBLIC' AND external_id = '386312';
UPDATE festival SET title = '피아니스트 손영경 & 오보이스트 손연지 듀오 리사이틀', content = '', place = '영산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384773';
UPDATE festival SET title = '서은영 가야금 독주회 공력 Ⅴ <철가락 - 이태백류 철가야금산조 전바탕>', content = '', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '382383';
UPDATE festival SET title = '광주시립교향악단, GSO 체임버 시리즈 Ⅲ ‘Brahms ＆ Schumann’', content = '', place = '광주예술의전당 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '382774';
UPDATE festival SET title = '[기획] K-뮤지엄 지역순회 전시 및 투어 지원사업 <생태의 집-한옥>', content = '', place = '한국소리문화의전당 국제회의장' WHERE provider_type = 'PUBLIC' AND external_id = '386742';
UPDATE festival SET title = '로비상설전 "행복이 머무는 순간"', content = '', place = '울산북구문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '387192';
UPDATE festival SET title = '부산항 개항 150주년 기념 기획전시 <개항, 부산항 150년>', content = '', place = '국립해양박물관' WHERE provider_type = 'PUBLIC' AND external_id = '387697';
UPDATE festival SET title = '뮤지컬 <블랙메리포핀스> 리턴즈 데이', content = '', place = '링크아트센터 벅스홀' WHERE provider_type = 'PUBLIC' AND external_id = '383116';
UPDATE festival SET title = '2026 글로벌 문학 포럼 ‘한국문학, 끌림과 울림’', content = '', place = '호텔코리아나 그랜드볼룸' WHERE provider_type = 'PUBLIC' AND external_id = '383854';
UPDATE festival SET title = '제12회 깐따피아 정기연주회: 테너 민현기 & 바리톤 임창한 듀오 리사이틀', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '382343';
UPDATE festival SET title = '2026 미디어아트 프로젝트 "줄리안 오피"', content = '', place = '울산시립미술관' WHERE provider_type = 'PUBLIC' AND external_id = '401518';
UPDATE festival SET title = '[마포문화재단] 제11회 M 클래식 축제 <한여름 밤의 뮤지컬>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '385005';
UPDATE festival SET title = '창작악단 기획공연 <작곡가 시리즈 V-이건용>', content = '국악 창작곡의 토대가 된 대표적인 작곡가의 작품을 선정하여 현재의 그 의미를 되새겨보는 작곡가 시리즈 다섯 번째 무대로 올해는 한국 창작음악의 방향성을 진지하게 모색해 온, 작곡가 이건용의 초연곡을 비롯한 대표작들로 꾸며집니다.', place = '국립국악원 예악당' WHERE provider_type = 'PUBLIC' AND external_id = '384318';
UPDATE festival SET title = '제13회 제주지원문인화 회원전 ''오늘도 내일도 활짝''', content = '', place = '제주특별자치도문예회관' WHERE provider_type = 'PUBLIC' AND external_id = '387610';
UPDATE festival SET title = '어느 여름날의 시간들', content = '<!-- wp:paragraph -->
<p>비디갤러리에서는 07월 02일부터 07월 28일까지 강희영, 김재현, 제이조 작가의 3인전인 <어느 여름날의 시간들>을 진행한다. 짙어지는 녹음과 따뜻한 빛이 머무는 계절, 우리는 자연과 삶의 풍경 속에서 스쳐 지나가는 감정과 기억을 다시 한 번 마주하게 된다. 이번 전시는 자연을 바라보는 시선에서 출발해 인간 내면의 정서와 관계, 기억의 흔적을 탐색하는 작업들을 선보인다. 화면 위에 펼쳐진 풍경은 단순한 묘사를 넘어 각자의 경험과 감각이 스며든 심리적 공간이 되며, 관람자는 그 안에서 자신만의 기억과 감정을 발견하게 된다. 자연과 인간, 외부의 풍경과 내면의 세계가 공존하는 이 전시는 일상 속에서 잊고 지낸 감각과 삶의 의미를 천천히 되돌아보는 시간을 제안한다.</p>
<!-- /wp:paragraph -->', place = '비디 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '387179';
UPDATE festival SET title = '국제 하이퍼-리얼리즘 <가장 완벽한 환영>', content = '', place = '울산시립미술관' WHERE provider_type = 'PUBLIC' AND external_id = '388573';
UPDATE festival SET title = '국회 개방 정오의 콘서트 <7월 국회 버스킹>', content = '', place = '국회사무처' WHERE provider_type = 'PUBLIC' AND external_id = '385731';
UPDATE festival SET title = '김재령 초대전', content = '<!-- wp:paragraph -->
<p><신진작가 리뷰전>은 갤러리전 <신진작가 프로젝트>를 통해 선정된 작가 중에 지속적으로</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작업을 하고 성장 가능성이 있는 작가를 다시 조명하는 전시이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2022년 갤러리전 신진작가전을 통해 데뷔한 김재령 작가의 초기 작업은 여성 인물과 공간을 통해 꿈과 기억의 서정성을 표현했다면 최근 작업은 자아의 분열, 시선의 문제, 존재의 불확실성을 다루는 방향으로 확장되고 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>인물들은 자신의 얼굴을 온전히 드러내지 않는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>접시 속에 투영된 인물, 얼굴 대신 풍경이 들어선 인물, 책 속에 가려진 인물 등 모두 ‘나는 누구인가’라는 질문을 서로 다른 방식으로 변주하고 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>현대인이 경험하는 존재의 불확실성과 정체성을 시각화하고 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>실제로 작가는 신경 손상으로 인해 움직일 수 없었던 경험을 통해 몸을 단순한 도구가 아닌 존재 자체로 인식하게 되었다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>얼굴의 부재를 통해 정체성을 탐구하는 작가의 성장과 사유의 진화를 보여주는 전시이다.</p>
<!-- /wp:paragraph -->', place = '갤러리전' WHERE provider_type = 'PUBLIC' AND external_id = '386736';
UPDATE festival SET title = '노우찬·이기찬 《입으로 부는 바람 When breath turns to Wind》', content = '', place = '스페이스 카다로그' WHERE provider_type = 'PUBLIC' AND external_id = '388258';
UPDATE festival SET title = '경기도무용단경기도당 춤 드라마 <귀귀내력(貴貴來歷)>', content = '세상 모든 귀한 것들의 내력''을 찾아 떠나는 시월이의 여정', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '384382';
UPDATE festival SET title = '[마포문화재단] 제11회 M 클래식 축제 <한국가곡의 밤>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '384967';
UPDATE festival SET title = '2026 여우락 페스티벌 - 이한철 <마침내 민요>', content = '싱어송라이터 겸 밴드 불독맨션의 리더 이한철이 발매한 ''생활국악'' 앨범의 라이브 무대', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '384070';
UPDATE festival SET title = '연극 <햄릿의 변호사>', content = '', place = '나인진홀 2관 (B1층)' WHERE provider_type = 'PUBLIC' AND external_id = '386431';
UPDATE festival SET title = '연극 <동백당; 빵집의 사람들>', content = '', place = '한국콘텐츠진흥원 CKL스테이지' WHERE provider_type = 'PUBLIC' AND external_id = '384386';
UPDATE festival SET title = '2026 부천문화재단 어린이축제 <들썩들썩 연희놀이터>', content = '', place = '판타지아 극장, 연희마당, 복사골문화센터 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '381407';
UPDATE festival SET title = '[서울 송파] 지브리 & 디즈니 오케스트라 콘서트 ', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382784';
UPDATE festival SET title = '경기팝스앙상블 안사훈&정동규의 팝스콘서트', content = '', place = '경기아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '386525';
UPDATE festival SET title = '2026 여우락 페스티벌 - 강산에X정보권 <물꼬>', content = '한국대중음악의 획을 그은 강산에와 만능 소리꾼 정보권과의 만남', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '384071';
UPDATE festival SET title = '[대학로] 혜은이 ''26 썸머파티', content = '', place = '굿씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '382674';
UPDATE festival SET title = '2026년 강북Festa 공연안내, 극단 상상구락부 ‘어린도비와 흰소’', content = '', place = '강북문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '383688';
UPDATE festival SET title = '모차르트 탄생 270주년 기념, 김응수 & 카메라타 솔: 모차르트의 초대장', content = '', place = '예술의전당 [서울]' WHERE provider_type = 'PUBLIC' AND external_id = '382911';
UPDATE festival SET title = '제6회 김상국 개인전 ‘공존의 시선’', content = '', place = '원주문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '388038';
UPDATE festival SET title = '[원주 갤러리 원] 최재규 개인전 "잔상 - 목조형展"', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '387943';
UPDATE festival SET title = '2026 여우락 페스티벌 - 선우정아X채지혜 <원(願)의 노래>', content = '독보적 음색의 싱어송라이터 선우정아와 거꾸로프로젝트의 국악 작곡가 채지혜의 만남', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '384072';
UPDATE festival SET title = '인사이드더플레이 : 뮤지컬 <룰렛>', content = '', place = '롯데시네마 [도곡]  7관' WHERE provider_type = 'PUBLIC' AND external_id = '383322';
UPDATE festival SET title = 'Elsewhere', content = '<!-- wp:paragraph -->
<p>히든엠갤러리는 오는 7월 9일부터 7월 30일까지 김연홍, 서지인, 하정현 작가의 3인전 <Elsewhere>를 개최한다. 이번 전시는 기억과 시간, 빛과 공기, 몸에 남겨진 감각이 새로운 풍경으로 형성되는 과정을 조명한다. 세 작가는 실제 풍경을 그대로 재현하기보다 경험과 기억, 상상과 감각이 교차하며 만들어낸 또 다른 장소를 각자의 회화적 언어로 구축한다. 이번 전시는 서로 다른 방식으로 축적된 감각의 흔적들이 화면 위에서 어떻게 새로운 풍경으로 변환되는지를 보여준다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>우리가 하나의 장소를 기억하는 방식은 단순히 눈앞에 보았던 장면을 떠올리는 것과는 다르다. 어떤 장소는 그곳의 형태보다 당시의 빛과 온도, 공기의 밀도, 바람의 움직임, 그리고 몸에 남겨진 감각으로 오래 기억된다. 시간이 지나며 구체적인 모습은 흐려질 수 있지만, 한순간 경험했던 감각은 오히려 더욱 선명한 이미지로 남기도 한다. 이처럼 풍경은 외부에 존재하는 고정된 대상이 아니라 개인의 경험과 기억을 통과하며 새롭게 형성되는 감각의 층위이다. 이러한 보이지 않는 감각들을 시각적인 언어로 변환하는 과정이다. 이는 특정한 장소를 그대로 옮기는 대신, 그 장소가 자신에게 남긴 흔적과 정서를 다시 구축한다. 실제와 기억, 현재와 과거, 현실과 상상이 겹쳐지는 순간 하나의 새로운 풍경이 생성된다. <Elsewhere>는 바로 이러한 감각의 변환 과정에 주목한다. 그것은 경험과 기억, 감각과 상상이 만나 만들어내는 또 하나의 장소이며, 어디에도 없지만 분명 존재했던 것처럼 느껴지는 풍경이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>세 작가는 각기 다른 출발점에서 작업하지만, 모두 현실을 재현하는 것을 넘어 감각이 만들어내는 새로운 세계를 탐색한다. 김연홍작가는 이미지 속 자연을 감각적으로 재구성하며, 서지인작가는 몸에 축적된 장소의 기억을 화면 위에서 증식시키고, 하정현작가는 일상의 순간이 새로운 밀도를 획득하는 과정을 담아낸다. 서로 다른 방식으로 생성된 세 개의 풍경은 하나의 감각적 흐름을 형성하며, 관람자로 하여금 익숙한 세계를 새로운 시선으로 바라보게 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>김연홍작가는 온라인에서 수집한 익명의 이미지에서 출발해 자연에 대한 새로운 감각을 구축한다. 작가에게 화면 속 물결은 특정한 장소를 재현하기 위한 대상이 아니라, 이미지 너머에 존재하는 계절과 기후, 시간의 흔적을 상상하게 하는 매개체이다. 작가는 어떤 날씨와 계절, 장소인지 명확히 알 수 없는 장면 속에서 빛의 온도와 공기의 밀도, 바람의 움직임과 같은 비가시적인 요소들을 포착한다. 향기와 기온은 색채로, 바람의 세기는 흐릿한 윤곽과 화면의 움직임으로 전환되며, 보이지 않는 감각은 회화의 언어 안에서 새로운 형태를 획득한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 중요한 것은 실제 자연을 경험했는가의 여부가 아니라, 이미지로 접한 자연이 어떻게 개인적인 감각으로 전환되는가에 있다. 스크린을 통해 마주한 장면을 단순히 재현하지 않고, 그 순간 느껴진 빛과 분위기, 개인적인 감정의 흔들림을 화면 위에 축적한다. 특히 물을 머금은 천 위에서 물감이 번지고 스며드는 과정은 작가의 의도와 우연이 만나 새로운 이미지를 만들어내며, 강조하려 했던 대상보다 회화적 흔적 자체를 남긴다. 그렇게 생성된 화면은 현실과 비현실 사이에 위치하며, 존재하지 않았지만 마치 경험한 듯한 감각의 풍경을 만들어낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>서지인작가는 이스라엘 사막을 오가며 경험한 장소의 감각을 회화의 출발점으로 삼는다. 유대사막과 팀나사막, 길갈에서 마주한 풍경은 작가에게 단순히 아름다운 자연의 장면으로 남지 않았다. 강렬한 생명의 빛과 척박한 환경, 대지의 뜨거운 온도와 바람의 움직임, 그리고 그 공간을 둘러싼 정치적 긴장과 생존의 불안은 서로 상반된 감각으로 몸에 축적되었다. 작가가 그리고자 하는 것은 사막이라는 장소 자체가 아니라, 그 장소가 신체에 남긴 내적 흔적이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 하나의 중심으로 정리되거나 안정된 풍경으로 수렴하지 않는다. 분절된 이미지와 감각의 조각들은 서로 충돌하고 연결되며 반복적으로 증식한다. 이러한 화면의 구조는 정착하지 못하고 끊임없이 이동하는 존재의 감각과 맞닿아 있으며, 불안정한 시대를 살아가는 개인의 경험을 반영한다. ‘증식하는 풍경’ 연작에서 풍경은 더 이상 고정된 대상이 아니라 계속 생성되고 변화하는 감각의 장으로 존재한다. 회화는 지나간 장소를 복원하는 동시에 다시는 동일하게 돌아갈 수 없는 기억과 아직 도착하지 않은 미래의 풍경을 함께 품는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>하정현작가는 평범한 일상이 문득 다른 밀도로 다가오는 순간에 주목한다. 익숙한 공간을 떠나 낯선 환경에 머무르는 경험은 작가에게 일상의 순간들을 새롭게 바라보게 하는 계기가 되었다. 이전에는 지나쳤던 빛과 소리, 움직임과 시간이 낯선 감각으로 다가오며, 가장 현실적인 순간은 어느 순간 아름다운 환상으로 변한다. 작가는 이러한 순간의 감각을 특정한 이미지로 고정하기보다, 화면 위에서 흔적이 생성되고 사라지는 회화의 과정 속에 담아낸다. 긋고, 덮고, 문지르고, 다시 드러내는 반복적인 행위는 기억과 감각이 현재 안에서 형성되는 방식을 보여준다. 이런 남겨진 흔적들은 과거의 경험을 재현하는 것이 아니라 새로운 시간 속에서 다시 구축된다. 구체적인 형상은 점차 흐려지고, 빠르고 직접적인 움직임과 느리고 서정적인 흐름이 교차하며 현실과 환상이 함께 머무는 장소가 된다. 작가의 회화는 익숙한 일상이 지닌 잠재적인 아름다움을 발견하고, 지나가는 순간을 오래 머무는 풍경으로 전환한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><Elsewhere>는 세 작가가 각자의 방식으로 구축해온 감각의 풍경들을 하나의 공간 안에 펼쳐 보인다. 김연홍작가의 상상된 자연, 서지인작가의 신체에 남은 장소의 기억, 하정현작가의 새롭게 감각된 일상은 서로 다른 출발점을 가지고 있지만 모두 경험 이후에 남겨진 감각이 회화 안에서 새로운 풍경으로 생성되는 과정을 보여준다. 작품들은 특정한 장소를 설명하지 않지만, 화면 속에 축적된 빛과 시간, 기억과 흔적을 통해 관람자가 자신의 감각과 기억을 마주하도록 한다. 결국 이번 전시는 현실을 벗어난 미지의 공간에 대한 상상이 아니다. 그것은 우리가 경험한 세계가 기억과 감각을 통과하며 어떻게 새로운 풍경으로 변화하는지를 보여준다. 세 작가의 회화는 보이는 풍경 너머에 존재하는 감각의 층위를 드러내며, 익숙한 현실 안에서 발견되는 또 다른 장소를 제안한다. 작품 속에 축적된 빛과 시간, 기억과 흔적은 관람자의 경험과 만나 새로운 감각의 풍경으로 확장되며, 우리가 바라보는 세계를 다시 인식하게 하는 시간을 마련한다.</p>
<!-- /wp:paragraph -->', place = '히든엠갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '389038';
UPDATE festival SET title = '2026 여우락 페스티벌 - 립제이X유희X박동석 <몽중유희>', content = '대한민국 최고의 댄서이자 안무가, 립제이와 한국의 전통연희를 동시대적 퍼포먼스로 해석한 유희의 콜라보 무대', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '384073';
UPDATE festival SET title = '국립심포니콘서트오케스트라 영유아 음악회 <킨더콘서트> : KNCO 목관 앙상블', content = '영유아와 가족이 함께 경험할 수 있는, 처음 만나는 클래식.국립심포니콘서트오케스트라 목관 앙상블이 들려주는 연주의 매력을 영유아와 가족이 함께 경험할 수 있는 공연.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '383081';
UPDATE festival SET title = '중국 공동기획 뮤지컬 ＜보옥＞', content = '중국 문학의 정수로 손꼽히는 <홍루몽>을 원작으로,주인공 가보옥의 청춘과 운명에 대한 치열한 갈등과 투쟁을 무대 위에 펼쳐낸다.2025년 4월 중국 초연 후 현재까지 약 13개 도시 4만명의 관람을 통해 관객과 평단에서 중국 전통과 현대 뮤지컬의 미학적 융합이라는 극찬을 받고 있다.', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '383627';
UPDATE festival SET title = '2026 어린이문화원 추석 한마당 <보름달 아시아>', content = '', place = '국립아시아문화전당 어린이문화원 일대' WHERE provider_type = 'PUBLIC' AND external_id = '397165';
UPDATE festival SET title = '대구향토역사관 2026 길 위의 인문학 특강 ''대구지역 누정문화''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '387698';
UPDATE festival SET title = '서서울미술관 건립 아카이브 토크 <여기, 미술관을 만든 시간들>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '386984';
UPDATE festival SET title = '[대구] 인디神 페스티벌, SOLE & THAMA ', content = '', place = '어울아트센터(구 대구북구문예회관) 함지홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '384748';
UPDATE festival SET title = '[충주] 탄금풍류 [彈琴風流] “우륵의 길”', content = '', place = '충주음악창작소' WHERE provider_type = 'PUBLIC' AND external_id = '383808';
UPDATE festival SET title = '2026 상상톡톡미술관 기획전시 <빠씨를 찾아서>', content = '', place = '북서울 꿈의숲 상상톡톡미술관' WHERE provider_type = 'PUBLIC' AND external_id = '383911';
UPDATE festival SET title = '2026 여우락 페스티벌 - 동양고주파X최예림 <악어떼 : 정글 숲을 지나서>', content = 'JTBC 풍류대장을 통해 국악과 힙합, 뮤지컬을 넘나들어 극찬을 받았던 최예림과 강렬한 사운드 동양고주파의 카리스마 있는 무대', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '384074';
UPDATE festival SET title = '2026 여우락 페스티벌 - 삼산x서의철 가단 <여기 우리 MZ가 있다>', content = '국악계의 장기하로 불리는 새로운 국악 크로스오버 싱어송라이터 삼산과 MZ세대를 대표하는 민속악단 서의철 가단과의 현재이자 미래의 만남', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '384075';
UPDATE festival SET title = 'K''urius의 피아노 스펙트럼 1 (큐리어스의 피아노 스펙트럼 1)', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '383250';
UPDATE festival SET title = '국립세계문자박물관 여름방학 문화행사 <MoW Summer Classic Concert>', content = '', place = '국립세계문자박물관' WHERE provider_type = 'PUBLIC' AND external_id = '388512';
UPDATE festival SET title = '제26회 코리아 합창 페스티벌 "세대를 잇는 선율, 마음을 여는 하모니"', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '382197';
UPDATE festival SET title = '2026년 특별기획전 <태(胎), 왕실의 영원을 기리다>', content = '', place = '부천시립박물관' WHERE provider_type = 'PUBLIC' AND external_id = '396243';
UPDATE festival SET title = '영화 <호프> 경남 도민 상영회', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '387260';
UPDATE festival SET title = '고창문화의전당 하우스콘서트, July Festival in 고창 1. 프랑스의 빛 (Lumières de France)', content = '', place = '고창문화의전당 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '388142';
UPDATE festival SET title = '📢 [중랑문화재단] 서울 문화예술교육 지원사업 ''망우 쓰다'' 참여자 모집', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '387524';
UPDATE festival SET title = '제48차 세계유산위원원회 부산총회 개최 기념 음악회: 홍석원&부산시립교향악단 with 김태한', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '386643';
UPDATE festival SET title = '대전광역시 서예진흥원 <매곡 최수룡 개인전>', content = '', place = '대전광역시 서예진흥원' WHERE provider_type = 'PUBLIC' AND external_id = '387734';
UPDATE festival SET title = '박제된 기억', content = '<!-- wp:image {"id":19605,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/07/홍성용작가_전시장.png" alt="" class="wp-image-19605" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>금산갤러리는 2026년 7월 15일(수)부터 8월 15일(수)까지 홍성용 작가의 개인전, <박제된 기억>을 선보입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>정보가 끝없이 쏟아지고 소통이 멈추지 않는 오늘날, 수많은 감각과 기억, 사소한 순간들은 너무나 쉽게 휘발되곤 합니다. 홍성용 작가는 사람들과 함께한 소중한 순간들을 붙잡아두고픈 마음을 담아, 기억의 파편들을 ‘박제’라는 형태로 기록해 왔습니다. 이번 전시는 전통 옻칠의 겹겹이 쌓인 층을 통해, 희미해져 가는 감정과 기억의 흔적을 머물게 하는 자리입니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>영원히 기억을 붙잡아두고 싶어 하는 작가의 마음은 층층이 쌓여가는 옻칠의 시간을 통해 표현됩니다. 작가는 그렇게 칠을 올리며 사라져 버릴 사람과 장소, 특정한 순간들을 붙잡고, 지나간 기억을 캔버스로 소환해 냅니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>7월 17일(금) 오후 5시 오프닝 리셉션, 작가님과 관람객이 함께 보내는 시간이 그 자체로 또 하나의 ''박제된 기억''이 되는 자리이길 바랍니다. 많은 참석 부탁드립니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>※ Opening Reception</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>일시 : 2026년 7월 17일(금) 오후 5시</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>프로그램 : 오후 5시-7시 DJ OSORI / 오후 7시-8시 AUCTION</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>장소 : 금산갤러리 (서울 중구 소공로 46, 남산쌍용플래티넘 B103 </p>
<!-- /wp:paragraph -->', place = '금산갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '389274';
UPDATE festival SET title = 'K-콘텐츠 미디어아트 기획전시 <영원한 안녕>', content = '', place = '김포아트빌리지 아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '394148';
UPDATE festival SET title = '제4회 지속가능한 마이스·관광 울산포럼', content = '', place = 'UECO 컨벤션홀' WHERE provider_type = 'PUBLIC' AND external_id = '387521';
UPDATE festival SET title = '우진청년작가회 정기전시 "미공개작"', content = '', place = '우진문화공간 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '390910';
UPDATE festival SET title = '7월 국회문화극장 <흘려보낸 여름>', content = '', place = '국회의원회관' WHERE provider_type = 'PUBLIC' AND external_id = '386109';
UPDATE festival SET title = '서리풀 서초9 시리즈 3 [그녀는 사랑하고, 그는 꿈꾼다 Sie liebt, Erträumt]', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '385206';
UPDATE festival SET title = '뮤지컬 <은밀하게 위대하게:THE LAST>', content = '더 강력해진 5446부대와 11명의 국정원 요원들이 펼치는 압도적 액션 뮤지컬.2016년 초연 이후, 11만 관객을 사로잡은 K-창작뮤지컬의 대표작.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '383082';
UPDATE festival SET title = '부산발레시즌Ⅱ <사계 : Time in Tides>', content = '', place = '부산문화회관 중극장' WHERE provider_type = 'PUBLIC' AND external_id = '386711';
UPDATE festival SET title = '2026 부산원먼스페스티벌 비바아첼챔버홀 스트라바간자 4 바이올린', content = '', place = '비바아첼 Chamber Hall & Academy' WHERE provider_type = 'PUBLIC' AND external_id = '384631';
UPDATE festival SET title = '2026 윤성주 춤 아카데미 창단 공연 <월-月>', content = '', place = '국립국악원 예악당' WHERE provider_type = 'PUBLIC' AND external_id = '383459';
UPDATE festival SET title = '국립발레단 <KNB Movement Series 10>', content = '2015년 시작된 국립발레단의 안무가 육성 프로젝트 KNB Movement Series가 열 번째 무대로 돌아왔습니다. 송정빈, 김나연, 정은영, 박예은, 배민순 다섯 명의 안무가가 각자의 예술적 시선과 독창적인 움직임을 담은 신작을 선보이며, 발레의 새로운 가능성과 동시대적 감각을 무대 위에 펼쳐낼 예정입니다.', place = '예술의전당 자유소극장' WHERE provider_type = 'PUBLIC' AND external_id = '384315';
UPDATE festival SET title = '[서울남산국악당] 소나기 Project 20th <삼채 三彩>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '385146';
UPDATE festival SET title = '살롱클래식, 듀오 트라베르소 <여름, 슈베르트, 그리고 방랑>', content = '', place = '라율아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '388714';
UPDATE festival SET title = '조지 할리오노 Q&A with Friends', content = '', place = '푸르지오아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '386394';
UPDATE festival SET title = '제9회 1번출구 연극제, 벚꽃 졸업식 & 청춘 라디오 & 방명녹', content = '', place = '대학로 자유극장 (자유문화발전소)' WHERE provider_type = 'PUBLIC' AND external_id = '385526';
UPDATE festival SET title = '<양양 너머> ''쓰다-내 인생의 책 만들기''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '385352';
UPDATE festival SET title = '2026 공연활성 무대지원사업 ⌈수요일 수많은 콘서트⌋ ', content = '', place = '전주한벽문화관' WHERE provider_type = 'PUBLIC' AND external_id = '391491';
UPDATE festival SET title = '2026 예술의전당 오페라 <투란도트>', content = '예술의전당 기획으로 오페라극장에서 선보이는 첫 번째 <투란도트>! 최고의 캐스팅과 압도적인 음악으로 예술의전당 대표 레퍼토리로 남을 명작이 온다.', place = '예술의전당 [서울] 오페라극장' WHERE provider_type = 'PUBLIC' AND external_id = '384466';
UPDATE festival SET title = '대전광역시 서예진흥원 <2026 어린이 여름방학 서예캠프>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '380326';
UPDATE festival SET title = '부산시립무용단 특별공연, 이정윤의 댄스살롱 <신성>', content = '', place = '백양문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '388657';
UPDATE festival SET title = '음악극 <백범 김구 - 문화의 나라>', content = ' 백범 김구 탄생 150주년 유네스코 기념해 지정을 맞아 ‘문화의 힘’을 외친 선구자, 김구 선생의 서사와 철학을 역동적인 음악으로 풀어낸 음악극', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '384383';
UPDATE festival SET title = '[갤러리조이] Summer Affordable', content = '<!-- wp:image {"id":19759,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/07/KakaoTalk_20260725_171527550_05.jpg" alt="" class="wp-image-19759" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":19760,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/07/KakaoTalk_20260725_171527550_17.jpg" alt="" class="wp-image-19760" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":19761,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/07/KakaoTalk_20260725_171527550_01.jpg" alt="" class="wp-image-19761" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":19763,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/07/KakaoTalk_20260725_171527550_11.jpg" alt="" class="wp-image-19763" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>𝗦𝘂𝗺𝗺𝗲𝗿 𝗔𝗳𝗳𝗼𝗿𝗱𝗮𝗯𝗹𝗲<br>2026. 7. 24 — 8. 31</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><Summer Affordable>은 갤러리조이의 여름 특별 기획전으로, 예술을 일상 가까이에서 경험하고 소장할 수 있는 기회를 확장하고자 기획되었다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>회화, 조각, 도예 등 다양한 장르의 작품들을 20만 원부터 300만 원까지의 합리적인 가격대로 소개하며, 예술 작품을 보다 쉽고 부담 없이 소장할 수 있는 장을 마련하였다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작지만 깊은 울림을 지닌 작품들은 각기 다른 감각과 서사를 담아, 일상 속에 자연스럽게 스며드는 예술적 경험을 제안한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>공간에 가볍게 스며드는 오브제부터 분위기를 전환하는 작품에 이르기까지, 폭넓은 스펙트럼의 작업을 통해 개인의 취향과 공간에 맞는 선택이 가능하도록 구성하였으며, 이는 단순한 감상을 넘어, 자신만의 감각으로 작품을 선택하고 소장하는 경험으로 이어진다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>여름의 시간성과 어우러진 이번 전시는, 여유로운 흐름 속에서 작품과 마주하는 순간의 밀도를 한층 깊게 만들고, 일상과 예술 사이의 거리를 부드럽게 좁혀, 지속 가능한 컬렉팅의 즐거움을 제안하고자 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Gallery JOY</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Busan, Korea<br>부산광역시 해운대구 달맞이길 65번길 56(중동) CK빌딩 1F</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>T. 051.746.5030<br>galleryjoy.com</p>
<!-- /wp:paragraph -->', place = '갤러리 조이' WHERE provider_type = 'PUBLIC' AND external_id = '391099';
UPDATE festival SET title = '김채은 플루트 리사이틀 (Flutist Evelyn Chayeun Kim) : Dreams & Fantasies', content = '', place = '아트센터 림 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '387767';
UPDATE festival SET title = '제23회 평창대관령음악제, 찾아가는 음악회 #4 파벨 하스 콰르텟 & 선우예권', content = '', place = '강릉아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '386700';
UPDATE festival SET title = '제23회 평창대관령음악제, 찾아가는 음악회 #3 크리스토프 쿠앵 & 알테 무지크 서울', content = '', place = '월정사 성보박물관' WHERE provider_type = 'PUBLIC' AND external_id = '386015';
UPDATE festival SET title = '[화성] 이면(裏面), 하고 싶었던 말: 출세가 & 정조가 & 노라를 놓아라', content = '', place = '모두누림센터' WHERE provider_type = 'PUBLIC' AND external_id = '389800';
UPDATE festival SET title = 'ASAC 클래식 <서곡이란 무엇인가>', content = '지휘, 렉쳐 구자범, 연주 봄프로젝트오케스트라 오페라 서곡에서 환상서곡, 축제서곡, 뮤지컬까지 장르와 시대를 넘나드는 서곡들이 한 무대에 펼쳐지며, 지휘자 구자범이 직접 해설하고 연주를 이끌어 가는 공연.', place = '안산문화예술의전당 해돋이극장' WHERE provider_type = 'PUBLIC' AND external_id = '383896';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 <해설과 함께 하는 우리 소리, 판소리>', content = '', place = '국립극장 무대예술지원센터' WHERE provider_type = 'PUBLIC' AND external_id = '388923';
UPDATE festival SET title = '2026 기획전시 <여름 이야기: 바닷속 탐험>', content = '', place = '양천문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '394125';
UPDATE festival SET title = '제23회 평창대관령음악제 찾아가는음악회 #5 아오이 트리오 & 신경식', content = '', place = '강릉시립미술관 솔올' WHERE provider_type = 'PUBLIC' AND external_id = '386019';
UPDATE festival SET title = '이안아 피콜로 & 플루트 리사이틀', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '385779';
UPDATE festival SET title = '태릉선수촌 개촌 60주년 특별전시 ''미션 1966, 태릉선수촌 아시아를 겨냥하다''', content = '', place = '태릉선수촌' WHERE provider_type = 'PUBLIC' AND external_id = '387694';
UPDATE festival SET title = 'KF–조지아공과대학교 협력전시 <크로싱 그라운드>', content = '', place = 'KF갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '391800';
UPDATE festival SET title = '2026년 특별전 ''나뭇결에 담긴 장인의 숨결''', content = '', place = '송암미술관' WHERE provider_type = 'PUBLIC' AND external_id = '394089';
UPDATE festival SET title = '2026 코리아라운드 컬처 <한국-인도네시아 클래시컬 브릿지>', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '390695';
UPDATE festival SET title = '어반브레이크 & 토이콘 서울 2026', content = '', place = '코엑스 D홀' WHERE provider_type = 'PUBLIC' AND external_id = '381549';
UPDATE festival SET title = '2026 어린이 가족 페스티벌 <코 잃은 코끼리 코바>', content = '작은 옷방에서 나타난 드넓은 상상, 놀이가 연극이 되는 순간, 옷과 신발 모자 등으로 표현하는 패브릭오브제극', place = '예술의전당 [서울] 자유소극장' WHERE provider_type = 'PUBLIC' AND external_id = '384363';
UPDATE festival SET title = '아름다운 목요일 영 오디세이: 베토벤, Ⅲ. 윤해원 & 박원민 & 진영훈 Violin', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '386636';
UPDATE festival SET title = '일미터클래식 20주년 기념 프로젝트 - 오케스트라의 12개의 목소리 <악기탐구>', content = '', place = '대원 팝콘D 스퀘어 대원 콘텐츠 라이브' WHERE provider_type = 'PUBLIC' AND external_id = '387349';
UPDATE festival SET title = '2026년 강북Festa, 김진환 예술원 ''나비의 노래 Ⅱ''', content = '', place = '강북문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '387135';
UPDATE festival SET title = '[진천] 오페라 <세비야의 이발사> ', content = '', place = '진천예술의전당 진아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '389553';
UPDATE festival SET title = '2026 원주생활문화센터 활성화사업 <생활문화정원> 원데이클래스', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '388925';
UPDATE festival SET title = '알록달록 동자상', content = '<p style="line-height: 120%;"><span style="font-family: ''맑은 고딕''; font-size: 16px;">2025 국립대구박물관상설주제전</span><p style="line-height: 120%;"><span style="font-family: ''맑은 고딕''; font-size: 28px; font-weight: bold;">알록달록 동자상</span><p style="line-height: 150%;"><span style="font-family: ''맑은 고딕'';"></span><p style="line-height: 150%;"><span style="font-family: ''맑은 고딕'';">무채색의 석조 동자상과 알록달록한 목조 동자상이 한자리에!</span><p style="line-height: 150%;"><span style="font-family: ''맑은 고딕'';"></span><p style="line-height: 150%;"><span style="font-family: ''맑은 고딕'';">색과 형태의 대비 속에서 동자상의 복식과 의미를 살펴보고, 상상력을 더해 동자 모습을 표현해보세요.</span><p style="line-height: 150%;"><span style="font-family: ''맑은 고딕'';"></span><p style="line-height: 150%;"><span style="font-family: ''맑은 고딕'';">또한, 동자상이 지닌 지물(持物)을 직접 꽂아보는 체험과 회화 속 동자의 모습을 찾아 그려보는 프로그램도 마련될 예정입니다.</span>', place = '국립대구박물관' WHERE provider_type = 'PUBLIC' AND external_id = '347140';
UPDATE festival SET title = '사람과 땅, 지리지에 담다', content = '<p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕''; font-size: 16px;">2025 국립대구박물관특별전</span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕''; font-size: 28px; font-weight: bold;">사람과 땅, 지리지에 담다</span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕''; font-size: 16px;"></span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';">우리 선조들이 들려주는 땅의 이야기, 특별전 ''사람과 땅, 지리지에 담다''</span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';"></span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';">이번 전시는 ''지리지(地理誌)''가 주인공이 되는 최초의 전시입니다.</span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';"></span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';">『세종실록지리지』와 『신중동국여지승람』에 담긴 우리 국토의 모습이 자세하게 펼쳐지고,</span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';"></span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';">조선 사람들의 진짜 삶과 꿈, 그리고 고향을 향한 뜨거운 자부심을 만나 볼 수 있습니다.</span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';"></span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';">600년 전, 이 땅 대구에서 태동한 『경상도지리지』의 첫 숨결부터</span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';">지도와 글이 만나 비로소 완성된 『신중동국여지승람』의 정겨운 모습까지,</span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';">당신이 딛고 선 바로 이 땅의 이야기가 당신을 기다립니다.</span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';"></span><p style="line-height: 21.6px;"><span style="font-family: ''맑은 고딕'';">이 땅을 살다 간 선조들이 남긴 따뜻한 시선과 지혜를 나누는 시간이 되시길 바랍니다.</span>', place = '국립대구박물관' WHERE provider_type = 'PUBLIC' AND external_id = '359116';
UPDATE festival SET title = '''Invisible Actors''', content = '<!-- wp:table -->
<figure class="wp-block-table"><table><tbody><tr><td>조경재 작가는 뮌스터 미술대학 마이스터슐러 과정을 마치고 유럽과 한국에서 활발히 활동해 온 사진 작가입니다. 그는 카메라의 제한된 화각 안에서 실제 공간을 마치 추상 회화처럼 연출하고 이를 사진으로 기록합니다. 조경재의 작업은 공간, 사물, 빛과 시간에 대한 섬세한 탐구에 초점을 맞춥니다. 그는 사진을 중심으로 설치, 퍼포먼스 등 다양한 매체적 실험을 활용하며, 일상적 사물과 공간을 재배치하고 재연출함으로써 우리가 흔히 지나치는 순간과 존재의 행위성을 포착합니다 특히, 그의 작업은 제한된 화각 안에서 공간과 물체를 추상적으로 재구성하고 기록하는 방식으로, 물체와 공간, 시간 간의 미묘한 상호작용과 내재된 변화를 드러냅니다. 그는 또한 공간과 오브제, 그리고 시간의 상호작용을 유심히 관찰하며, 이러한 탐구의 결과물이 사진작업에 고스란히 반영됩니다. 그의 사진은 콜라주나 디지털 편집을 사용하지 않고, 실제 공간과 물리적인 오브제를 설치하여 아날로그 카메라로 촬영한 순수 사진입니다. 이 과정에서 물체는 원래의 기능과 형태를 잃고 물질의 고유한 색채와 형태로 변형되며, 새로운 시각적 언어를 만들어냅니다. 이번 전시 “Invisible Actors (보이지 않는 배우들)”에서는 이러한 탐구가 카메라 안에서 펼쳐지는 ‘보이지 않는 배우들의 연극’을 통해 드러나며, 존재 자체가 이미 하나의 행위임을 보여줍니다. 관객은 작품을 통해 사물과 공간, 시간의 미묘한 상호작용을 직접 경험할 수 있습니다. 조경재는 전시를 통해 사진작업을 그 자체로 완성된 형식에 머물지 않고, 설치와 사운드 등 다양한 물리적 매체로 확장하는 시도를 이어왔습니다. 그의 이전 전시들에서처럼, 이번 전시에서도 사진 작업의 구조적 특성을 다른 형식으로 변형하고 해체하는 과정을 볼 수 있습니다.   <br><br><strong>조경재 ‘Invisible Actors’</strong> <br>조경재의 사진은 무대를 닮았다. 그리고 그 무대 위에는 배우가 없다. 대신, 사물과 빛, 그리고 그리고 시간의 흐름이 각자의 역할을 부여받아 조용히 장면을 만들어낸다. 작가는 하루의 빛이 변해가는 과정을 따라가며, 그 빛이 사물에 묻는 풍경을 세심하게 관찰한다. 그가 포착하는 순간들은 완결된 연극이 아니라, 지속되는 리허설의 시간, 혹은 빛이 사물에게 말을 거는 찰나의 대화에 가깝다. 그의 사진을 오래 들여다보고 있으면, 사물들이 서로를 의식하며 배치된 듯한 미묘한 군무성이 드러난다. 줄과 각을 정확히 맞추는 질서 있는 정렬이 있는가 하면, 각 사물이 지닌 고유한 성질은 흐트러뜨리지 않은 채 서로에게 반응하며 관계를 만들어가는 간접적인 군무성도 존재한다. 이 두 가지의 움직임은 겉으로는 정적이지만, 내부적으로는 장면을 조율하는 신호처럼 느린 파동을 일으킨다. 조경재의 시선 아래에서 사물들은 빛을 단순히 반사하는 대상이 아니다. 그들은 빛이 있는 공간 안에서 풍경을 밀고 당기며, 무대 위에서 상대를 인지하는 퍼포머처럼 조용히 자기 위치를 조정한다. 작가는 이러한 장면을 통해, 사물이 ‘존재한다’는 사실 자체가 이미 하나의 행위임을 드러낸다. 그 순간 카메라는 단순한 기록 장치가 아니라, 보이지 않는 관찰자이자 관객, 그리고 빛과 사물 사이의 미세한 긴장을 매개하는 존재로 자리한다. 그래서 그의 사진은 비어 있는 무대를 떠올리게 하면서도, 그 안에서 보이지 않는 배우들이 끊임없이 서로에게 반응하며 자신만의 장면을 만들어내고 있는 듯한 인상을 남긴다. 장면은 고정된 이미지가 아니라, 빛과 사물, 거리와 각도가 함께 호흡하며 생성하는 작은 리허설에 가깝다. 바로 이 지점에서, 조경재의 사진이 무대를 닮았다는 사실이 자연스럽게 이해된다. 그것은 연극적 장치의 모방이 아니라, 사물들 사이에 이미 흐르고 있는 질서와 긴장, 관계의 총합이 하나의 무대를 구성하기 때문이다.<br><br>Cho Kyungjae is a photographer who completed the Meisterschuler program at Kunstakademie Munster and has been active in both Europe and Korea. His work revolves around constructing actual spaces within the limited frame of the camera, often transforming them into abstract compositions, which he captures through photography.<br>His work focuses on a subtle exploration of the intricate interactions between space, objects, light, and time. Using photography as his primary medium, along with installations and performances, he experiments with various forms to rearrange and reinterpret everyday objects and spaces. Through this, he captures the inner transformations and subtle interactions of fleeting moments that are often overlooked. His work reconstructs and records space and objects within the limited frame of the camera in an abstract manner, revealing the delicate interplay and inherent changes between objects, space, and time. He also observes these interactions with great care, and these explorations are clearly reflected in his photographic work. His photographs are pure images captured with an analog camera, where physical objects are installed in real spaces without the use of collage or digital manipulation. In this process, objects lose their original function and form, transforming into their intrinsic colors and shapes, thereby creating a new visual language.<br>This exhibition, <em>Invisible Actors</em>, presents these explorations as a ''theater of invisible actors'' unfolding within the frame of the camera, demonstrating that existence itself is already an act. Through this exhibition, the audience can directly experience the subtle interactions between objects, space, and time. Cho KyungJae expands his photographic work beyond its finished form by incorporating various physical media, such as installation and sound. As in his previous exhibitions, this exhibition continues to transform and deconstruct the structural characteristics of photography into other formats.<br> <br><strong>Cho Kyoungjae ‘Invisible Actors’</strong><br>Cho’s photographs resemble a stage―one in which no actors appear. Instead, objects, light, and the passage of time are each assigned quiet roles, composing scenes in their own restrained manner. The artist follows the shifting light throughout the day, observing with care the landscapes it leaves upon objects. What he captures is not a completed performance but an ongoing rehearsal, or the brief moment in which light attempts a small chat with the things it touches.<br>When one lingers on his images, a subtle ensemble choreography among the objects begins to surface. There is a deliberate alignment―a direct, ordered kind of group movement―yet alongside it exists another, more indirect choreography, where each object preserves its own distinct character while gently responding to others. These dual movements, though visually still, generate slow internal waves, as if signaling the continuous negotiation of a scene.<br>Under his gaze, objects are never mere surfaces that re？ect light. They become responsive presences that push and pull the surrounding landscape, adjusting their positions like performers aware of their partners onstage. Through these scenes, the artist reveals that the simple act of an object existing is already a form of action. In such moments, the camera ceases to be a recording device; it becomes an unseen observer, a spectator, and a mediator of the faint tension between light and matter.<br>Thus his photographs evoke a stage stripped of actors yet ？lled with invisible performers quietly responding to one another, each revealing their own ？eeting scene within every-changing natural light. The image is not a ？xed tableau but a small rehearsal shaped by breath, distance, angle, and illumination. In this sense, it becomes clear why his work feels theatrical―not because it imitates drama, but because the order, tension, and relationships already ？owing between things compose a stage of their own.</td></tr></tbody></table></figure>
<!-- /wp:table -->', place = '갤러리 팔조' WHERE provider_type = 'PUBLIC' AND external_id = '362073';
UPDATE festival SET title = '제7회 실험극 페스티벌, 연극 <비평가>', content = '', place = '골목실험극장' WHERE provider_type = 'PUBLIC' AND external_id = '364446';
UPDATE festival SET title = '우지영 <지진> & 장두익 <스태프 온리> - 크리틱스초이스댄스페스티벌 2026', content = '<지진: 러브 웨이브>지진은 삶을 앞으로 밀어내는 사건이다흔들림 속에서 마주하게 되는 선택의 순간, 그리고 이전에 머무는 감각에 대한 이야기이다.<스태프 온리>관계자 외 출입금지누군가에게는 허용되고, 누군가에게는 닿을 수 없는 경계.서로를 지나고, 마주하고, 엇갈리며변화하는 관계 속에서 장면을 만든다.우리는 그 안과 밖을 오가며 각자의 방식으로 그 공간에 머문다.', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '383632';
UPDATE festival SET title = '2026 구나리 개인전 <Body of the Soul ; 영혼의 몸통을 드러내는 것>', content = '', place = '갤러리제이원' WHERE provider_type = 'PUBLIC' AND external_id = '390413';
UPDATE festival SET title = '최일준 개인전 <다른 이름으로 저장 Save As: Re-capture>', content = '', place = '16아카이브' WHERE provider_type = 'PUBLIC' AND external_id = '390443';
UPDATE festival SET title = '지브리 & 디즈니 오케스트라 콘서트 (08.02)', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '387339';
UPDATE festival SET title = '기획전시 시리즈 S.N.A. EXHIBITION#41 박상빈<찰나의 삶>', content = '', place = '영도문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '394056';
UPDATE festival SET title = '한국·프랑스 수교 140주년 특별전 《두 도시, 하나의 불꽃》 2 FEUX 2 FLAMMES', content = '', place = '전남미술관' WHERE provider_type = 'PUBLIC' AND external_id = '391842';
UPDATE festival SET title = '뮤지컬 <사칠>', content = '', place = '대학로 드림아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '387590';
UPDATE festival SET title = '자녀와 함께 듣는 교양 교육 <예술 그리고, 이야기> 8월', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '387262';
UPDATE festival SET title = '''2026 지혜학교'' <세계문학으로 읽는 12가지 지혜>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396802';
UPDATE festival SET title = '박민지 <체리피커> & 김다애 <게팅 옐로우> - 크리틱스초이스댄스페스티벌 2026', content = '<체리피커>가장 달콤한 것은 누구의 것인가경쟁과 효율이 강조되는 사회에서 우리는 매 순간 ‘취할 것’과 ‘물러설 것’ 사이의 아슬아슬한 경계를 외줄 타기 하듯 오간다.이 선택의 기로에서 마주하는 혼란과 고민을 무대 위에 펼쳐 보인다.<게팅 옐로우>우리의 시선은 서서히 ‘노랗게’ 물들어 간다보이지 않는 믿음이 퍼지고, 그 속에서 우리의 시선은 서서히 ‘노랗게’ 물들어 간다. <Geting Yellow>는 ‘노랑’을 색이 아닌 시간이 남긴 착색의 흔적으로 바라보며, 우리가 언제, 어떻게 물들었는지를 추적한다.', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '383633';
UPDATE festival SET title = '2026 해움·새들 입주작가 프로젝트: 지알원 《거리에서 온 아카이브》', content = '', place = '일산호수공원 고양시 예술창작공간 해움새들' WHERE provider_type = 'PUBLIC' AND external_id = '392729';
UPDATE festival SET title = '이브 초대전: I am what I eat', content = '<!-- wp:paragraph -->
<p>이브(EVE)의 초대전 <I am what I eat>는 우리를 이루는 것이 무엇인지에 대한 작가의 사유에서 출발한다. 이번 전시는 갤러리 전 〈신진작가 프로젝트〉로 선정된 이브 작가의 첫 초대전으로, 작가가 오랫동안 구축해 온 ‘동산바치’의 세계를 본격적으로 소개하는 자리이다. 작가는 어린 시절 작은 아오리사과를 건네받았던 기억을 출발점 삼아, 삶 속에서 축적된 다정함과 관계의 흔적을 조각으로 풀어낸다. 과거와 현재, 나와 타인의 경계를 넘나들며 우리가 서로의 삶 속에서 어떻게 영향을 주고받으며 성장하는지를 보여준다. 작가는 보고, 듣고, 느끼며 받아들인 모든 경험이 결국 삶의 양분이 되어 오늘의 자신을 만든다고 말한다. 이번 전시는 보이지 않는 마음의 교류가 한 사람의 내면을 형성하고, 또 다른 누군가에게 새로운 씨앗으로 이어지는 과정을 담아낸다.</p>
<!-- /wp:paragraph -->', place = '갤러리전' WHERE provider_type = 'PUBLIC' AND external_id = '391501';
UPDATE festival SET title = '제11회 여성연극제 기획전 <이민선>', content = '', place = '서울연극창작센터 서울씨어터 202' WHERE provider_type = 'PUBLIC' AND external_id = '390179';
UPDATE festival SET title = '영어 뮤지컬 <정글북>', content = '', place = '성신여자대학교 운정그린캠퍼스 대강당' WHERE provider_type = 'PUBLIC' AND external_id = '388817';
UPDATE festival SET title = '내게 머문 시선', content = '<!-- wp:paragraph -->
<p>히든엠갤러리는 오는 8월 6일부터 8월 27일까지 이지우, 홍수정, 황호석 작가의 3인전 <내게 머문 시선>을 개최한다. 이번 전시는 하나의 대상을 오래 바라본다는 것이 무엇을 의미하는지, 그리고 그 시선이 어떻게 감각과 기억을 형성하며 회화라는 언어 안에서 새로운 세계를 구축하는지를 조명한다. 세 작가는 풍경과 생명, 일상이라는 서로 다른 대상을 바라보지만, 그들의 작업은 모두 보이는 세계를 재현하는 데 머물지 않는다. 오히려 시선이 머문 자리에서 비로소 드러나는 감정과 시간, 존재의 흔적을 화면 위에 쌓아 올리며, 익숙한 세계를 새롭게 인식하게 만든다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>우리는 하루에도 수많은 장면을 바라보며 살아간다. 그러나 모든 풍경이 우리 안에 같은 깊이로 남는 것은 아니다. 어떤 장면은 스쳐 지나가지만, 어떤 장면은 오랜 시간 마음속에 머물며 삶의 일부가 된다. 그것은 눈에 보이는 형상 때문이 아니라, 그 순간의 빛과 공기, 감정과 시간, 그리고 설명하기 어려운 감각이 함께 축적되기 때문이다. 시선은 단순히 대상을 바라보는 행위에 머물지 않는다. 어떤 감각은 시선을 이끌고, 어떤 장면은 오래 머문 끝에 비로소 하나의 기억과 감정으로 남는다. 우리가 마음속에 간직하는 것은 눈앞에 스쳐 지나간 풍경이 아니라, 시선이 머문 시간 속에서 새롭게 형성된 세계일지도 모른다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><내게 머문 시선>은 이러한 시선의 지속성에 주목한다. 회화는 눈앞의 현실을 그대로 옮기는 매체가 아니라, 시선이 통과한 시간과 감정을 다시 구축하는 언어이다. 화면 위에 남겨진 색과 선, 질감과 흔적은 단순한 표현이 아니라 바라봄의 시간이 축적된 결과이며, 그 안에는 작가가 세계와 맺어온 관계가 고스란히 스며 있다. 세 작가는 서로 다른 조형 언어를 사용하지만, 모두 자신에게 오래 머물렀던 감각을 회화를 통해 다시 현재로 불러온다. 그들의 작업은 하나의 장면을 설명하기보다, 시선이 지나간 이후에도 계속 남아 있는 감각의 깊이를 보여준다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이지우 작가의 회화는 풍경을 바라보는 순간에서 시작되기보다, 오래 머문 하루의 감각을 다시 읽어내는 과정에서 시작된다. 그러나 작가가 화면에 담아내는 것은 특정한 장소나 풍경의 형태가 아니다. 머리맡 어제 읽던 책, 정오의 의자, 여름 빛에 푸른 무늬가 새겨진 문, 여름 저녁 창가, 각본집 옆 레몬 한 시와 열 시 사이, 구름 그림자와 촛농과 같은 일상의 장면들은 오래 머문 시선을 통해 하나의 감각과 기억으로 남는다. 오랜 시간 바라본 풍경은 어느 순간 얼굴처럼 표정을 띠기 시작하고, 작가는 그 미묘한 감정의 기색을 ''낯빛''이라 부른다. 쓸쓸함과 설렘, 애틋함과 같은 감정은 빛과 색의 층으로 응축되어 기억 속에 남고, 다시 화면 위에서 하나의 표정으로 드러난다. 풍경은 더 이상 외부의 대상이 아니라, 자신과 세계가 만나는 감각의 접점이 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 굵은 입자의 안료와 오일, 물감을 위에 쌓으며 하루의 감각이 축적되는 과정을 물성으로 드러낸다. 어떤 것은 화면에 머물고, 어떤 것은 스쳐 지나가며 홈과 흔적을 남긴다. 그 요철의 두께와 밀도는 지나간 시간과 기억이 쌓여 만들어낸 하나의 층이 된다. 쌓고 지우는 과정 속에서 하나의 기억처럼 층을 이루고, 압력과 마찰이 남긴 흔적들은 감정의 결을 만들어낸다. 이러한 반복은 단순한 조형적 효과가 아니라, 말로 기록되지 않은 하루의 감각이 축적되고 변형되는 시간의 구조를 닮아 있다. 작가의 특별한 사건을 기록하기보다, 너무 가까이 있어 쉽게 지나쳤던 하루를 다시 읽어내는 과정이다. 일기에 적히지 않고 말로 뱉지 않은 감각들은 화면 위에 겹겹이 쌓이며 하나의 풍경이 된다. 그렇게 형성된 ''낯빛''은 특정한 인물의 초상이 아니라, 풍경을 통해 마주한 세계와 자신의 내면이 교차하는 또 하나의 초상이 된다. 작가의 시선은 풍경을 바라보는 데서 멈추지 않고, 그 안에 스며 있는 존재의 감정을 읽어내며 우리 역시 세계를 조금 더 깊이 바라보게 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>홍수정 작가는 삶을 끊임없이 생성과 소멸을 반복하는 거대한 순환으로 바라본다. 화면 위에 펼쳐지는 아름다운 색면은 완결된 형상이 아니라, 그 아래에서 끊임없이 요동치는 생명의 기운을 잠시 감싸고 있는 얇은 막과도 같다. 작가는 가장 먼저 붉은 아크릴층을 화면에 남긴다. 그것은 생명의 원초적인 맥박이자, 인간 내면 깊숙한 곳에서 끓어오르는 에너지의 흔적이다. 이후 차분한 색조의 유화 물감을 두껍게 덮어 원초적인 생명의 기운을 잠시 감춘다. 그러나 화면 아래 잠재된 에너지는 사라지지 않은 채, 다시 모습을 드러낼 순간을 기다린다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>유화가 굳기 전, 작가는 니들로 화면을 파내고 긁어낸다. 이 행위는 단순한 조형적 기법이 아니라 감춰진 생명력을 다시 세상 밖으로 드러내는 몸짓이며, 상처를 회피하지 않고 정면으로 마주하는 치유의 과정이다. 긁혀 열린 틈 사이로 붉은 색층이 다시 숨을 쉬기 시작하고, 화면은 비로소 호흡을 얻는다. 이후 수없이 중첩되는 가느다란 선들은 니들이 남긴 상처를 메우기보다 새로운 생명의 흐름을 만들어낸다. 거칠고 섬세한 선들이 유기적으로 얽히며 형성하는 거대한 밀도는 우주의 파동을 닮았고, 삶이 끝없이 생성되고 회복되는 순환을 보여준다. 홍수정의 회화는 아직 형상화되기 이전의 감각과 에너지, 그리고 보이지 않는 생명의 흐름을 화면 위에 드러낸다. 작가의 시선은 대상을 바라보는 것을 넘어, 그 안에 잠재된 움직임과 존재의 힘을 감지하는 방식으로 확장된다. 작가의 회화는 상처를 감추는 공간이 아니라, 생명이 다시 피어나는 시간을 기록하는 장이 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>황호석 작가는 가장 가까이에 있어 쉽게 지나치는 일상을 오래 바라본다. 가족과 친구, 반복되는 하루, 작업실과 집을 오가는 익숙한 시간들은 특별한 사건 없이 흘러가는 것처럼 보이지만, 작가의 시선 안에서는 가장 소중한 삶의 기록으로 변화한다. 수많은 이미지가 빠르게 소비되는 시대 속에서 우리는 하루에도 셀 수 없이 많은 장면을 마주하지만, 대부분은 기억되지 못한 채 사라진다. 작가는 바로 이러한 사라지는 순간들 가운데 오래 마음에 남은 장면들을 선택하고, 그것이 가진 시간과 감정을 회화 안에서 다시 바라본다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>사진으로 기록한 장면들은 회화를 통해 다시 천천히 호흡을 얻는다. 화면 속에는 특정한 사건보다 그 순간의 공기와 감정, 관계의 온도가 스며 있다. 아무것도 아닌 것처럼 지나갔던 하루는 회화를 통해 새로운 시간의 밀도를 획득하고, 평범한 사물과 풍경은 삶을 이루는 중요한 기억으로 자리한다. 작가가 붙잡고자 하는 것은 특별한 순간이 아니라, 너무 가까이 있어 오히려 보지 못했던 것들이다. 그의 작업은 익숙한 일상의 장면들이 어떻게 우리의 기억 속에 남고, 시간이 지난 뒤에도 하나의 이미지로 지속되는지를 보여준다. 그의 시선은 평범한 일상을 낯설게 만드는 것이 아니라, 익숙함 속에 숨어 있던 소중함을 다시 발견하게 한다. 그렇게 사라진 시간을 기록하는 매체가 아니라, 잊혀가는 삶의 감각을 현재로 되돌리는 하나의 기억 장치가 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>세 작가는 서로 다른 세계를 바라보지만, 그들의 시선은 결국 하나의 지점에서 만난다. 오래 머문 시선은 대상을 소비하지 않는다. 그것은 세계를 이해하기 위해 천천히 바라보고, 그 안에 숨어 있던 감정과 생명, 시간을 발견하는 과정이다. 이지우는 풍경에서 인간의 표정을 발견하고, 홍수정은 상처 속에서 생명의 호흡을 드러내며, 황호석은 평범한 일상 속에서 삶의 가장 깊은 의미를 길어 올린다. 그들의 회화는 모두 각자가 오래 바라본 세계가 시간과 감각을 거쳐 다시 생성된 결과이며, 시선이 머문 자리에 비로소 나타나는 감각의 풍경이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><내게 머문 시선>은 세 명의 작가가 바라본 세계를 보여주는 전시에 머물지 않는다. 이번 전시는 우리가 무엇을 바라보며 살아가는지, 그리고 무엇이 우리 안에 오래 머물러 삶의 일부가 되는지를 다시 묻는다. 작품 앞에 머무는 시간은 곧 자신의 삶을 천천히 되돌아보는 시간이 된다. 세 작가가 화면 위에 남겨놓은 시선의 흔적은 관람자의 기억과 감각을 조용히 흔들며, 지나쳐왔던 풍경과 관계, 그리고 일상의 순간들을 새로운 시선으로 다시 마주하도록 이끌 것이다.</p>
<!-- /wp:paragraph -->', place = '히든엠갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '392373';
UPDATE festival SET title = '(8.6) (사)서울클래식오케스트라 제3회 정기연주회 "한여름의 사계와 세레나데"', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '385722';
UPDATE festival SET title = '아름다운 목요일 영 오디세이: 모차르트, Ⅰ. 홍석영 & 박해림 & 김아인 Piano', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '387810';
UPDATE festival SET title = '2026 서울시립교향악단 <작은 음악회>', content = '', place = '금천누리종합사회복지관 5F' WHERE provider_type = 'PUBLIC' AND external_id = '390497';
UPDATE festival SET title = '2026 산울림 고전극장 <플레이위드 햄릿>', content = '', place = '산울림소극장' WHERE provider_type = 'PUBLIC' AND external_id = '391158';
UPDATE festival SET title = '2026 국립경찰박물관 8월 문화행사 ''빛과 모래로 들려주는 샌드아트 공연''', content = '', place = '국립경찰박물관 4층 폴리스홀' WHERE provider_type = 'PUBLIC' AND external_id = '389352';
UPDATE festival SET title = 'Tourist', content = '본 작품은 ‘공허함’과 ‘외로움’이라는 인간 존재의 근원적 감정에서 출발한다. 공허함은 단순한 결핍이 아니라, 삶이 반복되는 과정 속에서 서서히 증폭되는 감각이다. 반복과 상실, 그리고 무의미하게 흘러가는 시간 속에서 공허함은 어느 순간 삶의 방향을 묻는 질문으로 전환된다.', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '383637';
UPDATE festival SET title = '2026 작은미술관 보구곶 기획전시 <보구곶, 시간을 걷다>', content = '', place = '작은미술관 보구곶' WHERE provider_type = 'PUBLIC' AND external_id = '394054';
UPDATE festival SET title = '(8.7) Drei Blicke “세개의 시선”', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '388270';
UPDATE festival SET title = '연극 <렁스>', content = '아이와 환경, 책임에 대한 고민을 밀도 높은 대사로 풀어낸 2인극. 최소한의 무대 장치와 배우의 연기만으로 인간의 생애와 사랑을 탐구하는 독창적인 연출이 특징.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '383083';
UPDATE festival SET title = '송지원 바이올린 리사이틀 <Inspiration>', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '384989';
UPDATE festival SET title = '노모스 트리오 ‘영혼의 포옹’', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '388384';
UPDATE festival SET title = '성남아트센터 키즈 페스티벌, 전래동화 클래식 <별주부전>', content = '', place = '성남아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '388391';
UPDATE festival SET title = '전막 초연 150주년 기념 갈라콘서트, 바그너 <니벨룽의 반지> 하이라이트', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '388406';
UPDATE festival SET title = '와이즈발레단 <백조왕자>', content = '안데르센 원작<백조 왕자>의 국내 최초 발레화. 슈베르트가 생애 마지막 해에 남긴 현악 5중주와 중세 유럽의 배경에서 펼쳐지는 순수한 동화 속 상상의 세계는 아이에게는 신비한 모험을, 어른들에게는 희생과 인내의 성찰을 전한다.', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '384348';
UPDATE festival SET title = '강요찬 <Buchae> & 박수윤 <Untitled> - 크리틱스초이스댄스페스티벌 2026', content = '<Buchae>가장 낯선 부채춤한국 전통춤의 원형을 현대적 시각으로 재해석해 온 ‘컨템포러리 클래식 3부작’의 대미를 장식하는 작품이다. 2024년 ‘크리틱스초이스프론티어’ 수상작 ‘GangGang’(강강), 2025년 서울세계무용축제에서 선보인 ‘HAK’(학)에 이어, 세 번째 작품을 2026년 크리틱스초이스 신작으로 선보인다.Untitled가장 무방비한 순간, 시작과 끝은 하나로 겹쳐진다우리는 선택한다고 믿지만, 대부분은 떠밀려 움직인다.부서지는 대신 더 나아가기 위해 더 망가져서라도 움직이려는 상태.', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '383634';
UPDATE festival SET title = '공존 할수 없는 공존', content = '공존은 共存(함께 존재함)이고 뒤의 공존은 空 zone(비어있음/구획)을 뜻한다. 작품은 함께 있으나 비어있는 상태, 즉 두 사물·현상이 공존하지만 동시에 ‘틈(공백)’을 남기는 역설적 상황에서 발생하는 관계와 흔적을 탐구한다.', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '383638';
UPDATE festival SET title = '국립남도국악원 토요상설: 국악이 좋다, 국립남도국악원 국악연주단 <국악의 향연>', content = '', place = '국립남도국악원 진악당' WHERE provider_type = 'PUBLIC' AND external_id = '389813';
UPDATE festival SET title = '김유빈 & 리처드 이가 듀오 리사이틀', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390519';
UPDATE festival SET title = '지브리 & 디즈니 영화음악 FESTA (08.09)', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '388234';
UPDATE festival SET title = '2026 수원은학교 <1인 1악기 학교> 가을학기 ', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394103';
UPDATE festival SET title = '바이올린 강보라 & 피아노 홍지영 듀오 리사이틀', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '388827';
UPDATE festival SET title = '2026년 제1회 디지털출판 세미나 <AI시대, 출판 콘텐츠 비즈니스의 재구성>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389605';
UPDATE festival SET title = '김현희 해금풍류 IV <김영재류 해금산조>', content = '', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '389452';
UPDATE festival SET title = '[원주 갤러리 원] 김미애 초대개인전 "초록의 위로" ', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '393124';
UPDATE festival SET title = '한국예술종합학교 합창지휘과 송아연 & 구예지 졸업연주회', content = '', place = '꿈의숲아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '392612';
UPDATE festival SET title = '2026 제6회 <S Classic Week> 1st ''악기의 조화''', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '390747';
UPDATE festival SET title = '2026 남양주문화재단 서머페스티벌(클래식) <2026 경기필하모닉 실내악 콘서트 – 남양주>', content = '', place = '다산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '385726';
UPDATE festival SET title = '헤르만아트홀 기획연주, 김다민 & 문웅휘 듀오 리사이틀', content = '', place = '헤르만아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '391090';
UPDATE festival SET title = '안성맞춤아트홀 ''문화가 있는 날:아트-데이'' 국립극단 온라인 극장 <영지> (영상화)', content = '', place = '안성맞춤아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '388683';
UPDATE festival SET title = '어린이 공연 "넌버벌 <네네네>"', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '388636';
UPDATE festival SET title = '[대전] 연극 <럭키!전당포> 2026 심야N연극제', content = '', place = '아신극장 1관 (3층)' WHERE provider_type = 'PUBLIC' AND external_id = '388843';
UPDATE festival SET title = '제11회 여성연극제 연출가전 <사천의 착한 여자>', content = '', place = '드림시어터 [대학로]' WHERE provider_type = 'PUBLIC' AND external_id = '389739';
UPDATE festival SET title = '2027년 특별전 ‘시대를 바꾸는 힘: 서학과 천주교’ 연계 강연', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '391848';
UPDATE festival SET title = '중구민을 위한 무료 영화 상영 목요일N씨네마 <동주>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389967';
UPDATE festival SET title = '예술의전당 & 유니버설발레단: 백조의 호수', content = '', place = '예술의전당 [서울] 오페라극장' WHERE provider_type = 'PUBLIC' AND external_id = '389015';
UPDATE festival SET title = 'BPS Chamber & Youth Orchestra "빛을 향한 여정"', content = '', place = '성남아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '389004';
UPDATE festival SET title = '2026 제6회 <S Classic Week> 4th ''사람의 조화''', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '390763';
UPDATE festival SET title = '유지원 & 염지수 조인트 피아노 리사이틀', content = '', place = '꿈의숲아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390700';
UPDATE festival SET title = '2026 서울시향 시민과 함께하는 광복절 기념 음악회: 베토벤 ''합창''', content = '', place = '세종문화회관 세종대극장' WHERE provider_type = 'PUBLIC' AND external_id = '384361';
UPDATE festival SET title = '<거문고를 위한>: Etude 2', content = '', place = '서교스퀘어' WHERE provider_type = 'PUBLIC' AND external_id = '389552';
UPDATE festival SET title = '[인천] 매직퍼포먼스 <홀릭>', content = '', place = '인천어린이과학관 강당' WHERE provider_type = 'PUBLIC' AND external_id = '391014';
UPDATE festival SET title = '연극 <결혼식 2시간 전>', content = '', place = '나인진홀 1관 (1층)' WHERE provider_type = 'PUBLIC' AND external_id = '392319';
UPDATE festival SET title = '2026 예술의전당 국제음악제 - 티모시 리다우트 & 프랑크 뒤프레 듀오 리사이틀', content = '현 시대 최고의 비올리스트 티모시 리다우트와 가장 대담한 리듬의  피아니스트 프랑크 뒤프레가 선사하는 환상적인 호흡 "브람스에서 나흐레 솔까지, 시간의 그림자를 따라 걷는 음악적 여정"', place = '예술의전당 IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '384247';
UPDATE festival SET title = '2026 예술의전당 국제음악제 - 파씨오 콰르텟', content = '"파씨오 콰르텟이 펼쳐내는 프랑스 피아노4중주의 스펙트럼" 프랑크, 생상스, 포레의 아름다운 곡에 매료되는 환상적인 무대', place = '예술의전당 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '384248';
UPDATE festival SET title = '2026 차세대전문예술활동지원 <내일의 예술가> 아티스트 프레젠테이션', content = '', place = '복사골문화센터 판타지아극장' WHERE provider_type = 'PUBLIC' AND external_id = '391781';
UPDATE festival SET title = '2026 길 위의 인문학 <너덜겅, 함께 이루는 풍경>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '390191';
UPDATE festival SET title = '안성맞춤아트홀 ''문화가 있는 날:아트-데이'' 국립극단 온라인 극장 <십이야> (영상화)', content = '', place = '안성맞춤아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '389879';
UPDATE festival SET title = '2026 서울 문화예술교육 지원사업 <언어의 발견 : 이어지는 여정>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '387520';
UPDATE festival SET title = '창작악단 기획공연 <긴산조 협주곡 III>', content = '산조의 전바탕을 담아낸 긴산조 협주곡 세 번째 무대로 올해는 거문고산조와 해금산조가 무대에 오릅니다. 느린 장단에서 시작해 빠른 장단으로 연주하는 민속 음악의 기악 독주 음악의 꽃인 산조의 모든 선율과 장단을 온전하게 아우르며 긴 호흡으로 감상할 수 있습니다.', place = '국립국악원 예악당' WHERE provider_type = 'PUBLIC' AND external_id = '384320';
UPDATE festival SET title = '아름다운 목요일 영 오디세이: 모차르트, III. 남예서 & 홍석영 & 박해림 Piano', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '389725';
UPDATE festival SET title = '2026 예술의전당 국제음악제 - 베조드 압두라이모프 피아노 리사이틀', content = '"단연코 가장 완벽한 기량을 갖춘 피아니스트"로 평가받는 피아니스트, 3년만에 진행되는 베조드 압두라이모프의 내한 리사이틀', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384252';
UPDATE festival SET title = '2026 예술의전당 국제음악제 - 유치엔 쳉 & 신창용 듀오 리사이틀', content = '대만을 대표하는 바이올리니스트 유치엔 쳉과 한국을 대표하는 피아니스트 신창용의 만남! 두 스타가 선보이는 최초의 듀오 무대', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '384253';
UPDATE festival SET title = '2026 예술의전당 국제음악제 - 트리오 아니모소', content = '"플루트, 비올라, 하프 트리오로 전하는 여름밤의 색채" 몽환적이고 동화적인 음색과 마주하게 될 아름다운 음악적 서사', place = '예술의전당 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '384254';
UPDATE festival SET title = '중구민을 위한 무료 영화 상영 목요일N씨네마 <위키드: 포 굿>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389968';
UPDATE festival SET title = '"제12언어연극스튜디오 스무돌!" 기념공연 <S고원에서>', content = '', place = '서강대 메리홀 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '392458';
UPDATE festival SET title = '[연희예술극장 X 극공작소 마방진] 연극 <(빌린)결혼 2.0>', content = '', place = '연희예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '391171';
UPDATE festival SET title = '다 내 아이들', content = '전쟁 이후 미국의 한 가족을 통해 책임과 양심의 의미를 묻은 아서 밀러의 <다 내아이들>. 2026 서울예술상 연극부문 최우수상을 받은 극단 백수광부의 화제작.', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '383625';
UPDATE festival SET title = '《사이의 선 THE LINES IN BETWEEN》', content = '', place = '갤러리 지하' WHERE provider_type = 'PUBLIC' AND external_id = '392515';
UPDATE festival SET title = '윤영복 개인전 <찰나의 마법 시간선에 서다>', content = '', place = '봄내극장 춘천미술관' WHERE provider_type = 'PUBLIC' AND external_id = '394704';
UPDATE festival SET title = '2026 예술의전당 국제음악제 - 사무엘 마리뇨 with 카메라타 안티콰 서울', content = '"세계가 주목한 가장 희귀한 목소리, 남성 소프라노와 한국 바로크의 정수의 만남" 헨델의 아리아로 만나는 ''바리데기'' ', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384255';
UPDATE festival SET title = '2026 춘천오페라페스티벌 요한 슈트라우스 2세의 오페레타: 박쥐', content = '', place = 'KT&G 상상마당 [춘천] 야외공연장' WHERE provider_type = 'PUBLIC' AND external_id = '389684';
UPDATE festival SET title = '[대구] 유지영 & 정현진 조인트 피아노 리사이틀', content = '', place = '수성아트피아' WHERE provider_type = 'PUBLIC' AND external_id = '400728';
UPDATE festival SET title = '독일 가곡 시리즈 4 <낭만주의 가곡의 종착지, Hugo Wolf를 노래하다>', content = '', place = '부산문화회관 챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '394706';
UPDATE festival SET title = '국립국악관현악단 <2026 작곡가 프로젝트>', content = '공개 모집과 시연회로 최종 선정된 5인의 신작.우리 음악의 멋진 미래를 만나볼 수 있는 다채로운 무대!', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '384109';
UPDATE festival SET title = '2026 예술의전당 국제음악제 - 아나스타샤 코베키나 첼로 리사이틀', content = '"무대 위 맨발의 뮤즈, 첼리스트 아나스타샤 코베키나" 바흐 무반주 첼로 모음곡과 현대음악을 아우르는 폭넓은 레퍼토리', place = '예술의전당 IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '384258';
UPDATE festival SET title = '심포니 오브 뮤지컬 II  <주소연의 Dear My Music>', content = '당신의 마음에 오래도록 머무는 음악, 악보 너머의 감정까지 담아내는 음악감독 주소연의 아름다운 작품을 한자리에서 만나보는 시간', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '384345';
UPDATE festival SET title = '<미스터리 컨퍼런스 2026: 미스터리의 시대>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389943';
UPDATE festival SET title = '이응노미술관 전시연계 어린이 교육 프로그램 <군상아, 무슨 일이야?>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '393090';
UPDATE festival SET title = '2026 문화예술교육사 현장역량강화사업 <그린마인드>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '390190';
UPDATE festival SET title = '[수봉IN기획공연] <디스이즈아트지 - 이게 예술이지>', content = '', place = '인천수봉문화회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '392325';
UPDATE festival SET title = '담양군문화재단·이강하미술관 협력전시 《집 그리고 또 다른 장소들》', content = '', place = '담빛예술창고' WHERE provider_type = 'PUBLIC' AND external_id = '401652';
UPDATE festival SET title = '[부산] 비바아첼 인문학콘서트: 역학으로 듣는 베토벤, 사주로 읽는 한 천재의 삶과 음악 ', content = '', place = '비바아첼 Chamber Hall & Academy' WHERE provider_type = 'PUBLIC' AND external_id = '394024';
UPDATE festival SET title = '2026 예술의전당 국제음악제 - 이승원 & 아나스타샤 코베키나 with SAC 페스티벌 오케스트라', content = '국제 무대에서 주목받는 첼리스트 아나스타샤 코베키나와 지휘자 이승원, SAC 페스티벌 오케스트라가 펼쳐내는 쇼스타코비치 음악의 강렬한 에너지와 깊은 서사', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '384260';
UPDATE festival SET title = '뮤지컬 <오디세아:키르케의 섬> 쇼케이스', content = '', place = 'KT&G 상상마당 대치아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393543';
UPDATE festival SET title = '2026 KIAFRIEZE 특별 기획전 | 8/24-9/7, 갤러리제이원 서울', content = '<!-- wp:image {"id":20144,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/갤러리제이원-삼청나잇2-1.jpg" alt="" class="wp-image-20144" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시명: <2026키아프리즈 특별기획전> / 2026 KIAFRIEZE Special exhibition<br>갤러리제이원 서울 전시공간에서는 키아프와 프리즈를 맞이하여 기획한 특별 단체전을 진행합니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Participating Artists: 이건용 · 이미 크뇌벨 · 이여몽 · 전광영 · 이원희 · 이우림 · 권순창 · 조명학 · 박준우 · 공성환 </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>| 8/24(월)-9/7(일), 갤러리제이원 서울. 02-733-0101</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20146,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/갤러리제이원-삼청나잇_4-1.jpg" alt="" class="wp-image-20146" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":20147,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/갤러리제이원-삼청나잇_7-1.jpg" alt="" class="wp-image-20147" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":20148,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/갤러리제이원-삼청나잇_8.jpg" alt="" class="wp-image-20148" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":20149,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/갤러리제이원-삼청나잇_5-1.jpg" alt="" class="wp-image-20149" /></figure>
<!-- /wp:image -->', place = '갤러리제이원' WHERE provider_type = 'PUBLIC' AND external_id = '395978';
UPDATE festival SET title = '2026 S1472 공간지원 기획사업 <공간드림 1472> 선정작가 전시_이찌고세연 개인전', content = '', place = '관천로 문화플랫폼 S1472' WHERE provider_type = 'PUBLIC' AND external_id = '395760';
UPDATE festival SET title = '제19회 K-Ballet World <K-발레월드스타>', content = 'K-Ballet World의 대표 프로그램으로 한국에 있는 무용수를 포함해 해외에서 활동하는 한국인, 세계 유명한 발레리나와 발레리노를 초청해 공연함.', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '383635';
UPDATE festival SET title = '[안성] 까꿍이가 들려주는 행복박스 <까꿍이와 동화나무> ', content = '', place = '용설아트스페이스' WHERE provider_type = 'PUBLIC' AND external_id = '395279';
UPDATE festival SET title = '푸르지오아트홀 수요초대석 38, 리에종 앙상블 정기공연 Liaison Ensemble <THE BRIDGE>', content = '', place = '푸르지오아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390576';
UPDATE festival SET title = '안성맞춤아트홀 문화가 있는 날: 아트-데이 <조씨고아, 복수의 씨앗> (영상화)', content = '', place = '안성맞춤아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390478';
UPDATE festival SET title = '연극 <하얀상자>', content = '', place = '나인진홀 1관 (1층)' WHERE provider_type = 'PUBLIC' AND external_id = '391521';
UPDATE festival SET title = 'CLASSIC이 있는 뮤지컬 <이원복의 먼나라 이웃나라 영국여행>', content = '', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '389154';
UPDATE festival SET title = '생애주기 프로그램(중장년) <어른을 위한 말 공부>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '392546';
UPDATE festival SET title = '안진선·임동현 《아주 얇은 막 A Very Thin Membrane》', content = '', place = '씨스퀘어' WHERE provider_type = 'PUBLIC' AND external_id = '394391';
UPDATE festival SET title = '타(打) & 현(絃) : 평택, 리듬에 물들다', content = '', place = '평택아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '392412';
UPDATE festival SET title = '배리어 프리 & 센서리-프렌들리 음악회: 감각의 숲에서 피터를 만나다', content = '', place = '로데아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '392209';
UPDATE festival SET title = '한지영 & 심선혜 피아노 듀오 연주회', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390962';
UPDATE festival SET title = '한여름의 메시아', content = '세기의 걸작이자 바로크 합창 레퍼토리의 정수인 헨델의 불멸의 명작 <메시아>는 여름 시즌 서울시합창단의 <한여름의 메시아>로 다시 관객들을 맞이한다.', place = '세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '384343';
UPDATE festival SET title = '[광명 스테이지 ON:] 광명 전통예술플랫폼 Vol.1 춤 & 사운드 <시그날>', content = '', place = '광명시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '391834';
UPDATE festival SET title = '라운드테이블 <쿠바 바로크에서 라틴아메리카의 경이로운 현실까지>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '392991';
UPDATE festival SET title = '수림뉴웨이브 2026 - 이준 <Golden Hour>', content = '', place = '김희수아트센터 SPACE 1' WHERE provider_type = 'PUBLIC' AND external_id = '388739';
UPDATE festival SET title = '2026년 사회적경제 단기기획전 <더 좋은 소비 페스타 in 하남>', content = '', place = '스타필드 하남 센트럴 아트리움' WHERE provider_type = 'PUBLIC' AND external_id = '393386';
UPDATE festival SET title = '판소리 <긴긴밤>', content = '', place = '문학시어터' WHERE provider_type = 'PUBLIC' AND external_id = '392935';
UPDATE festival SET title = '전시+악회 <나무와 풀과 꽃들>', content = '', place = '보헤미안 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '389362';
UPDATE festival SET title = '[이천] 지브리 & 디즈니 OST 콘서트 with 첼로댁 ', content = '', place = '이천아트홀 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '391072';
UPDATE festival SET title = '[순천] 낭만주의 거장, 차이코프스키 & 라흐마니노프 ', content = '', place = '순천문화예술회관 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '392212';
UPDATE festival SET title = '[세종] 연극 <걸리버여행기 : 줌 인 아웃>', content = '연극<걸리버여행기 : 줌 인 아웃>은 고전 ''걸리버여행기''를 현대적인 감각으로 재해석한 가족극으로,아이의 성장과 자기결정의 순간을 환상적이면서도 섬세하게 그려낸 작품', place = '세종문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '383086';
UPDATE festival SET title = '[시흥] 입체낭독극 <시련> ', content = '', place = '리치버번 [시흥]' WHERE provider_type = 'PUBLIC' AND external_id = '393978';
UPDATE festival SET title = '[안산] 2026 가족 라이브 뮤지컬 <라푼젤>', content = '', place = '안산문화예술의전당 달맞이극장' WHERE provider_type = 'PUBLIC' AND external_id = '391045';
UPDATE festival SET title = '원재연 & 김수연 피아노 듀오 리사이틀', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '386964';
UPDATE festival SET title = '지브리&디즈니 영화음악 FESTA 앙코르', content = '', place = '부산콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '391009';
UPDATE festival SET title = '[부산] 김준수, 유태평양 출연 창극 <살로메>', content = '', place = '부산시민회관 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '391012';
UPDATE festival SET title = 'IN SCALE', content = '<!-- wp:image {"id":20110,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/08/배너업로드_.png" alt="" class="wp-image-20110" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>금산갤러리는 2026년 8월 31일(월)부터 9월 30일(수)까지 이재형, 정정주, 박근호, 한승구 작가가 참여하는 단체전 《IN SCALE》을 선보입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 각 작가의 작업이 모듈과 오브제, 스케치, 이미지, 프로젝션, 공공조형물 등 서로 다른 형태와 규모를 거치며 확장되고 구현되는 과정을 살펴봅니다. 전시 제목의 ‘Scale’은 작품의 물리적인 크기뿐만 아니라, 작은 유닛이 전체 구조를 이루는 조형적 관계와 작업이 스튜디오에서 미술관, 건축, 도시로 이어지는 과정까지 아우릅니다.전시장에서는 모듈과 오브제, 스케치를 통해 작품이 만들어지는 과정을 가까이에서 살펴볼 수 있습니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>8월 31일(월) 오후 5시에는 작가들과 함께하는 오프닝 리셉션이 진행됩니다. 작품이 서로 다른 장소와 규모를 넘나들며 새로운 관계를 만들어가는 자리에 많은 관심과 참석 부탁드립니다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>일시 : 2026년 8월 31일(월)부터 9월 30일(수)까지</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>오프닝 : 2026년 8월 31일(월) 오후 5시</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>장소 : 금산갤러리 (서울 중구 소공로 46, 남산쌍용플래티넘 B103)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>관람 시간 : 월–금 10:00–18:30 / 토 10:00–18:00 / 매주 일요일 휴관 </p>
<!-- /wp:paragraph -->', place = '금산갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '395915';
UPDATE festival SET title = '《(Who, What, When, Where & Why) I am》', content = '', place = '갤러리 지하' WHERE provider_type = 'PUBLIC' AND external_id = '395778';
UPDATE festival SET title = '클래식 레볼루션, 레오니다스 카바코스 & 키릴 게르스타인 듀오 리사이틀 (09.01)', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '391912';
UPDATE festival SET title = '2026년 함석헌기념관 씨알갤러리 하반기 5차 대관 전시 서정희 개인전 ‘해중목-바다 속 나무''', content = '', place = '함석헌기념관' WHERE provider_type = 'PUBLIC' AND external_id = '396805';
UPDATE festival SET title = '[전시] 스페이스다온 초대전 <소망의 조각들>', content = '', place = '문화공간 스페이스다온' WHERE provider_type = 'PUBLIC' AND external_id = '396307';
UPDATE festival SET title = '동대문 무장애 문화향유주간 <DADA:예술로>', content = '', place = '동대문구 아르코' WHERE provider_type = 'PUBLIC' AND external_id = '393218';
UPDATE festival SET title = '[서울시립과학관]  2026 과학관 성인교육 ''식물 아뜰리에: 관찰과 표본''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394753';
UPDATE festival SET title = '체험형 목재놀이터 <춘천 플레이데이>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400091';
UPDATE festival SET title = '대전광역시 서예진흥원 <2026 제4기 서예교육 전문인력 양성과정>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '389043';
UPDATE festival SET title = '프로젝트모락, 블랙코미디 옴니버스 연극 <미명>', content = '', place = '극장 봄 (봄소극장) 극장 봄' WHERE provider_type = 'PUBLIC' AND external_id = '393901';
UPDATE festival SET title = '연극 <#정답을작성해주세요>', content = '', place = '나인진홀 1관 (1층)' WHERE provider_type = 'PUBLIC' AND external_id = '392321';
UPDATE festival SET title = '2026 제16회 춤 & 판고무신춤축제, 춤 & 판', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '391668';
UPDATE festival SET title = 'KOSOUND+STAGETECH / 코사운드 국제 무대음향·영상·조명·산업전', content = '', place = 'SETEC' WHERE provider_type = 'PUBLIC' AND external_id = '373006';
UPDATE festival SET title = '2026KIAF 갤러리제이원GALLERY J. ONE | COEX, B홀51번', content = '<!-- wp:image {"id":20123,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/조명학-홍보오-1.jpg" alt="" class="wp-image-20123" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>KIAF SEOUL 키아프 서울은 2002년 처음 문을 연 한국 최초의 국제아트페어로 매해년 그 규모와 퀄리티는 높아져 왔습니다. 엄격한 심사를 통해 선정된 세계 주요 갤러리와 미술인이 한자리에 모여 동시대 미술의 현재와 미래를 조망하는 자리이기도 한 키아프 서울에 갤러리제이원 GALLERY J. ONE 은 박준우, 이우림, 조명학, 권순창 작가를 선보입니다. | 9/2(수)-9/7(일), COEX B홀 부스번호 51번.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>🌟2026KIAF ✨Booth No.51✨<br>location | COEX 코엑스, 강남구 삼성동<br>2026.9.2-9.6</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>[참여작가] 박준우, 이우림, 조명학, 권순창</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>[관람 시간 안내]<br>소지하신 티켓 등급에 따라 입장 가능 시간이 상이하오니, 방문 전 아래 일정을 확인해 주시기 바랍니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>1.VIP 및 Preview 관람<br>9월2일(수) 11AM-8PM<br>9월3일(목)~9월5일(토) 11AM-7PM<br>9월6일(일) 11AM-6PM</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2.일반관람 (General Admission 및 특별 할인권)<br>9월3일(목) 3PM-7PM(First Preview한정)<br>9월4일(금)~9월5일(토)11AM-7PM (First Access /Afternoon Access등)<br>9월6일(일) 11AM-6PM (General, Student포함)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>[온라인 뷰잉룸(OVR)안내]<br>페어 현장에서 방문하기 어려우시거나 출품작을 미리 확인하고 싶으신 분들을 위해 키아프 공식홈페이지에서 온라인 뷰잉룸이 운영됩니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리 제이원 부스번호 51번</p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">2026kiaf #갤러리제이원 #박준우작가 #조명학작가 #이우림작가 #권순창작가 #키아프 #키아프리즈 #2026프리즈 #galleryjone</h3>
<!-- /wp:heading -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity" />
<!-- /wp:separator -->

<!-- wp:heading -->
<h2 class="wp-block-heading">About 조명학, <FREE#: 안식></h2>
<!-- /wp:heading -->

<!-- wp:spacer {"height":"34px"} -->
<div style="height:34px" aria-hidden="true" class="wp-block-spacer"></div>
<!-- /wp:spacer -->

<!-- wp:gallery {"linkTo":"none"} -->
<figure class="wp-block-gallery has-nested-images columns-default is-cropped"><!-- wp:image {"id":20139,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/조명학1.jpg" alt="" class="wp-image-20139" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":20140,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/조명학4.jpg" alt="" class="wp-image-20140" /></figure>
<!-- /wp:image --></figure>
<!-- /wp:gallery -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">2026 KIAF 에서 선보이는 조명학 작가의 신작</h3>
<!-- /wp:heading -->

<!-- wp:spacer {"height":"22px"} -->
<div style="height:22px" aria-hidden="true" class="wp-block-spacer"></div>
<!-- /wp:spacer -->

<!-- wp:paragraph -->
<p>분홍빛 하늘 아래, 새의 얼굴을 한 인물이 작은 배를 타고 천천히 어딘가를 향해 간다. 처음 마주하는 순간에는 사랑스럽고 환상적인 장면처럼 보이지만, 조금 더 오래 바라보면 이 세계에 다른 표정이 있음을 알아차리게 된다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>살구빛과 장밋빛이 겹쳐진 부드러운 세계 옆에 짙은 어둠이 고개를 내밀고 있다. 왼쪽의 깊은 어둠 속에는 죽음을 연상시키는 형상이 조용히 모습을 드러내고, 오른쪽에는 갑옷을 입은 기사가 나무 아래 서 있다. 화면 곳곳에는 신체의 장기를 닮은 문양들이 숨어 있다. 그러나 이 모든 요소들은 공포스럽거나 잔혹하게 다가오기보다, 마치 꿈속에서만 만날 수 있는 기묘한 상징처럼 존재한다. 갑옷을 입은 인물조차 위협적인 전사라기보다 어릴 적 장난감 상자 속에서 막 걸어 나온 병정처럼 보여, 무거운 상징들은 다시 한번 천진하고 몽환적인 모습으로 변한다. 작품이 담고 있는 어둠은 화면을 집어삼키지 않는다. 불안은 소리치지 않고, 그저 아름다운 풍경의 한쪽에서 조용히 바라보고 있을 뿐이다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>어쩌면 이 작품은 우리가 살아가는 마음의 풍경과 닮아있다. 아름다운 순간 곁에도 설명하기 어려운 두려움이 있고, 가장 순수한 마음 안에도 스스로를 지키기 위한 단단한 갑옷 하나쯤은 숨겨져 있다. 그럼에도 중앙의 인물은 노를 놓지 않는다. 무엇이 기다리고 있는지 알 수 없는 세계를 향해 조용히 앞으로 나아간다. 아름답지만 어딘가 기묘하고, 사랑스럽지만 결코 가볍지만은 않은 세계. 그 서로 다른 감정들이 한 화면 안에서 부딪히지 않고 나란히 존재한다는 점이 이 작품을 오래 바라보게 만드는 힘이라 생각한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Beneath a pink sky, a bird-faced figure rows a small boat slowly toward an unknown destination. At first glance, the scene appears tender and fantastical, but the longer we look, the more we begin to sense another expression within this world.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Beside the soft realm of apricot and rose tones, a deep darkness begins to emerge. From the shadows on the left, a figure evocative of death quietly reveals itself, while on the right, an armored knight stands beneath a tree. Motifs resembling human organs are scattered throughout the composition. Yet none of these elements feels overtly frightening or violent. Instead, they exist like strange symbols encountered only in dreams. Even the armored figure seems less like a threatening warrior than a toy soldier who has just stepped out of a childhood toy box, transforming these heavier symbols into something innocent and dreamlike once again. The darkness within the work never overwhelms the scene. Anxiety does not cry out; it simply remains at the edge of this beautiful landscape, quietly watching.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Perhaps this painting resembles the inner landscape of our lives. Even beside our most beautiful moments, there are fears we cannot fully explain, and even within the purest part of ourselves, we may carry a suit of armor to protect what is fragile within us. And yet, the figure at the center does not let go of the oar. Without knowing what lies ahead, it continues to move quietly forward.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Beautiful yet strangely unsettling, tender yet never entirely lighthearted, this is a world in which contrasting emotions exist side by side without colliding. It is precisely this quiet coexistence that gives the painting its lingering power and keeps us looking.</p>
<!-- /wp:paragraph -->

<!-- wp:spacer {"height":"44px"} -->
<div style="height:44px" aria-hidden="true" class="wp-block-spacer"></div>
<!-- /wp:spacer -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity" />
<!-- /wp:separator -->

<!-- wp:heading -->
<h2 class="wp-block-heading">연계전시</h2>
<!-- /wp:heading -->

<!-- wp:columns -->
<div class="wp-block-columns"><!-- wp:column {"width":"100%"} -->
<div class="wp-block-column" style="flex-basis:100%"><!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">전시명: <2026키아프리즈 특별기획전> / 2026 KIAFRIEZE Special exhibition</h3>
<!-- /wp:heading -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:heading {"level":3} -->
<h3 class="wp-block-heading">2026년 8/24(월)-9/7(일)</h3>
<!-- /wp:heading --></div>
<!-- /wp:column -->

<!-- wp:column {"width":"100%"} -->
<div class="wp-block-column" style="flex-basis:100%"><!-- wp:spacer {"height":"10px"} -->
<div style="height:10px" aria-hidden="true" class="wp-block-spacer"></div>
<!-- /wp:spacer -->

<!-- wp:paragraph -->
<p>갤러리제이원 서울 전시공간에서는 키아프와 프리즈를 맞이하여 기획한 특별 단체전을 진행합니다. Participating Artists: 이건용 · 이미 크뇌벨 · 이여몽 · 전광영 · 이원희 · 이우림 · 권순창 · 조명학 · 박준우 · 공성환 | 갤러리제이원 서울. 02-733-0101</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column --></div>
<!-- /wp:columns -->

<!-- wp:image {"id":20131,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/갤러리제이원-삼청나잇2.jpg" alt="" class="wp-image-20131" /></figure>
<!-- /wp:image -->

<!-- wp:spacer {"height":"37px"} -->
<div style="height:37px" aria-hidden="true" class="wp-block-spacer"></div>
<!-- /wp:spacer -->

<!-- wp:gallery {"linkTo":"none"} -->
<figure class="wp-block-gallery has-nested-images columns-default is-cropped"><!-- wp:image {"id":20128,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/갤러리제이원-삼청나잇_5.jpg" alt="" class="wp-image-20128" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":20126,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/갤러리제이원-삼청나잇_4.jpg" alt="" class="wp-image-20126" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":20127,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/갤러리제이원-삼청나잇_7.jpg" alt="" class="wp-image-20127" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":20130,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/갤러리제이원-삼청나잇_1-1.png" alt="" class="wp-image-20130" /></figure>
<!-- /wp:image --></figure>
<!-- /wp:gallery -->

<!-- wp:spacer {"height":"58px"} -->
<div style="height:58px" aria-hidden="true" class="wp-block-spacer"></div>
<!-- /wp:spacer -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity" />
<!-- /wp:separator -->

<!-- wp:heading -->
<h2 class="wp-block-heading">연계전시</h2>
<!-- /wp:heading -->

<!-- wp:columns -->
<div class="wp-block-columns"><!-- wp:column -->
<div class="wp-block-column"><!-- wp:heading -->
<h2 class="wp-block-heading">9월3일(목) 삼청나잇 Samcheong Night</h2>
<!-- /wp:heading -->

<!-- wp:heading -->
<h2 class="wp-block-heading">6pm-11pm </h2>
<!-- /wp:heading --></div>
<!-- /wp:column -->

<!-- wp:column -->
<div class="wp-block-column"><!-- wp:paragraph -->
<p>키아프와 프리즈를 맞이하여 서울의 주요 갤러리들에서 야간 프로그램 ''Gallery NIght - 한남/청담/삼청''이 진행됩니다. 한남동, 청담동, 삼청동에서 개최되는 키아프 참여 주요 갤러리들의 야간행사로 갤러리제이원은 9월3일(목) 삼청나잇 Samcheong Night에 참가합니다. 9월 3일에 갤러리 전시공간에서 진행중인 <2026 KIAFRIEZE Special exhibition>전시를 11PM까지 야간운영 합니다. | 삼청나잇, 9/3(목) 6PM-11PM, 갤러리제이원 서울.</p>
<!-- /wp:paragraph --></div>
<!-- /wp:column --></div>
<!-- /wp:columns -->

<!-- wp:image {"id":20132,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/08/삼청나잇갤러리제이원서울.jpg" alt="" class="wp-image-20132" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>현대적인 전시공간과 북악산의 능선, 국립민속박물관의 기와 지붕선 같이 서울의 오래된 풍경이 함께 스며드는 갤러리제이원의 전시공간에서 어스름한 저녁 시간대에만 감상할 수 있는 정취를 즐겨보시길 바랍니다. (참고로 옥상 테라스뷰가 너무 이뻐요)</p>
<!-- /wp:paragraph -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity" />
<!-- /wp:separator -->', place = '갤러리제이원' WHERE provider_type = 'PUBLIC' AND external_id = '395977';
UPDATE festival SET title = '송채림·박상은 《환-영사》', content = '', place = '공간일리' WHERE provider_type = 'PUBLIC' AND external_id = '397170';
UPDATE festival SET title = '2026년 하반기 첫 수요영화관 <원 배틀 애프터 어나더>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '395790';
UPDATE festival SET title = '손철주의 오래된 그림공부 <‘몸매’-몸에 매질하다>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394910';
UPDATE festival SET title = '사육신역사관 9월 <사육신시네마>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396412';
UPDATE festival SET title = '국회 개방 정오의 콘서트 <9월 국회 버스킹>', content = '', place = '국회사무처' WHERE provider_type = 'PUBLIC' AND external_id = '395826';
UPDATE festival SET title = '2026 서울시민예술학교 서초 예술마스터 ''AMUSS 합창단'' 합창단원 모집', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '388922';
UPDATE festival SET title = '창작 국악 시리즈 신풍류전', content = '김홍도의 ''월야선유도''에서 영감을 받아 자연과 물의 이미지를 오늘의 국악관현악으로 새롭게 풀어내는 창작 프로젝트', place = '세종문화회관 세종M씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '393237';
UPDATE festival SET title = '태국 문화예술부 왕립무용단 <콘 : 라마끼엔의 이야기>', content = '2026 창극 중심 세계음악극축제 해외초청작. 태국 문화예술부 왕립무용단이 선보이는 유네스코 인류무형문화유산 ''콘(Khon)'', 국내 최초 전막 공개!', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '392780';
UPDATE festival SET title = '뮤지컬 <헤어드레서>', content = '최초의 여성 헤어드레서였던 실존인물 ''오엽주''를 모티브로 한 감동의 스토리! 동서양의 미가 공존하는 화려한 패션·헤어·음악이 어우러진 웰메이드 창작뮤지컬!', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '393075';
UPDATE festival SET title = '2026 창작오페라 <이중섭> 10주년 기념 공연', content = '', place = '서귀포예술의전당 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '390469';
UPDATE festival SET title = '늙지 않는 마음', content = '가난한 청년 ‘강’과 ‘현’이 ‘초저속 노화 센터’에 들어가기 위해 5년씩 번갈아 고된 경제 활동으로 센터비를 감당하기로 한다. 한 사람이 초저속 노화 상태로 센터 생활을 하는 동안 다른 한 사람은 노동과 스트레스로 야기되는 급속 노화를 견뎌야 하는 것이다. 하지만 약속한 5년은 10년을 넘어 버렸고, ‘강’을 찾아 온 ‘현’은 삶에 찌들어 알아보기조차 힘든 모습이 되었다. 과연 그들의 관계는 그대로 유지될 수 있을까?', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '393114';
UPDATE festival SET title = '[대구] 시대를 잇는 서정의 울림, 유진아 & 장나원 리사이틀 ', content = '', place = '대구콘서트하우스 챔버홀(소공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '366054';
UPDATE festival SET title = '[대구] 이은결 <META> ', content = '', place = '수성아트피아' WHERE provider_type = 'PUBLIC' AND external_id = '365608';
UPDATE festival SET title = '[대구] 이든 콘서트: DREAM & WISH CONCERT ', content = '', place = '대구서구문화회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '367336';
UPDATE festival SET title = '[대구] 모노 오페라 <라 칼라스> ', content = '', place = '대구오페라하우스' WHERE provider_type = 'PUBLIC' AND external_id = '369136';
UPDATE festival SET title = '[대구] 수성아트피아 시즌페스티벌, 봄 음악제: 대구KBS포시즌 ''봄: 열린음악회''', content = '', place = '수성아트피아' WHERE provider_type = 'PUBLIC' AND external_id = '369273';
UPDATE festival SET title = '[대구] 수성아트피아 시즌페스티벌, 봄 음악제: 김우경 & 구민영 듀오 콘서트', content = '', place = '수성아트피아' WHERE provider_type = 'PUBLIC' AND external_id = '369490';
UPDATE festival SET title = '[대구] 발레 <지젤> ', content = '', place = '대구오페라하우스' WHERE provider_type = 'PUBLIC' AND external_id = '367657';
UPDATE festival SET title = 'Nocturama', content = '<!-- wp:image {"id":17720,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/11-1.jpg" alt="" class="wp-image-17720" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":17721,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/22.jpg" alt="" class="wp-image-17721" /></figure>
<!-- /wp:image -->

<!-- wp:gallery {"linkTo":"none"} -->
<figure class="wp-block-gallery has-nested-images columns-default is-cropped"><!-- wp:image {"id":17723,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/33.jpg" alt="" class="wp-image-17723" /></figure>
<!-- /wp:image --></figure>
<!-- /wp:gallery -->

<!-- wp:paragraph -->
<p>사진 매체를 통해 기억의 단편을 현실로 소환하고 소멸해가는 존재의 자리를 기록해 온 권도연 작가의 개인전 《녹투라마 (Nocturama)》 가 3월 13일부터 4월 29일까지 대구 021갤러리에서 개최된다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 2021년 이후 작가가 지속적으로 천착해 온 작업 세계를 집약적으로 선보이는 자리로, <야간행>, <반짝반짝 빛나는>, <파도> 연작을 포함한 주요 작품 20점을 소개한다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시명 ‘녹투라마(Nocturama)’는 W.G. 제발트의 소설 《아우스터리츠》에 등장하는 안트베르펜 동물원의 ‘야행성 동물관’에서 차용했다. 소설 속 화자가 인공적인 어둠 속에서 유리 너머의 동물들과 시선을 교환하며 시간과 기억의 심연을 마주했듯, 권도연은 사진을 통해 우리 주변의 밤과 그 속에 부유하는 존재들을 깊이 있게 응시한다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>주요 연작인 <야간행(Nocturama)>은 인간이 잠든 적막한 밤, 어둠 속에서 움직이는 반짝이는 존재들을 담아냈다. 칠흑 같은 어둠 속에서 터지는 플래시는 대상을 하얗게 날려버리거나 흐릿하게 만들며, 마치 잡힐 듯 잡히지 않는 기억의 속성을 시각화한다. 작가는 빛이 닿는 순간 과거가 되어버리는 찰나를 포착하며, “사진은 우리의 현재를 오려낸다”는 매체의 본질적인 성격을 드러낸다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>함께 전시되는 <반짝반짝 빛나는(Twinkling)>은 한강 하구의 인공 시설 녹지나 섬과 같은 ‘생태적 틈새’에서 살아가는 생명들을 기록했다. 행주대교와 올림픽대로 사이, 도로에 갇혀 마치 블랙홀처럼 작용하는 고립된 장소에서 작가는 삵, 너구리, 고라니와 같은 동물들을 마주한다. 2년여의 시간 동안 그들이 내뿜는 미세한 빛과 생명력을 서정적으로 포착한 이 작업은 소멸해가는 것들에 대한 애도이자 기록이다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>특히 이번 전시의 서사를 완성하는 신작 <파도(Wave)>는 소백산에서 해운대까지 약 400km를 이동한 여우(KM-2121)의 여정을 쫓은 기록이다. 작가는 여우가 바라보았을 풍경과 시간을 수행적으로 뒤따르며, “누군가가 잊은 기억은 차마 그것을 잊지 못한 누군가의 기억으로 다시 돌아온다”는 메시지를 던진다. 파도가 밀려오듯 되돌아오는 기억과 존재의 흔적을 통해, 작가는 타자가 머물던 시공간을 자신의 프레임 안으로 끌어안는다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>권도연 작가는 작가 노트를 통해 “세상에는 기록해야 할 빛나는 존재들이 분명히 있다”며, “어둠 속에서 그들을 마주하고 기록하는 일은 단순한 관찰이 아니라 기법의 문제를 넘어선 윤리의 문제”라고 전했다. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2019년 제10회 일우사진상, 2023년 제1회 랄프 깁슨 어워드를 수상하며 독보적인 작품성을 인정받은 권도연은 이번 전시를 통해 어둠(Nocturama) 속에서도 눈을 뜨고 있는 존재들을 향한 다정하고도 집요한 시선을 관람객들에게 선사할 예정이다.</p>
<!-- /wp:paragraph -->', place = '021갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '372693';
UPDATE festival SET title = '[대구] 2026 우수공연시리즈 Ⅱ 국악콘서트 <풍류일가(風流一家)>', content = '', place = '봉산문화회관 가온홀' WHERE provider_type = 'PUBLIC' AND external_id = '396868';
UPDATE festival SET title = '[대구] 명연주시리즈: 양인모 & 잘츠부르크 모차르테움 오케스트라', content = '', place = '대구콘서트하우스 그랜드홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '368516';
UPDATE festival SET title = '[대구] 김영주 플루트 독주회 Ⅸ: Musique Français Ⅲ (프랑스 음악 3)', content = '', place = '대구콘서트하우스 챔버홀(소공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '369454';
UPDATE festival SET title = '[대구] 상상팡팡 뮤지컬  <할머니 엄마> (1회차) ', content = '', place = '달성문화센터 백년홀' WHERE provider_type = 'PUBLIC' AND external_id = '371524';
UPDATE festival SET title = '[대구] 박규희 & 양방언 듀오 콘서트: 두 개의 빛 ', content = '', place = '비원뮤직홀 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '373233';
UPDATE festival SET title = '[대구] 상상팡팡 뮤지컬 <할머니 엄마> (2회차)', content = '', place = '국립대구과학관 사이언트리홀' WHERE provider_type = 'PUBLIC' AND external_id = '371498';
UPDATE festival SET title = '[대구] 지브리 & 디즈니 영화음악 FESTA (앵콜)', content = '', place = '대구콘서트하우스 그랜드홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '369924';
UPDATE festival SET title = '[대구] 수성키즈클래식, Cinema Classic: 지브리 & 영화 OST', content = '', place = '수성아트피아' WHERE provider_type = 'PUBLIC' AND external_id = '372379';
UPDATE festival SET title = '[대구] DSAC 시그니처, 키안 솔타니 & 박재홍 듀오 리사이틀', content = '', place = '달서아트센터 청룡홀' WHERE provider_type = 'PUBLIC' AND external_id = '371170';
UPDATE festival SET title = '[대구] 효성피아노연구회 & 효음성악회 정기연주회 ', content = '', place = '대구콘서트하우스 챔버홀(소공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '375125';
UPDATE festival SET title = '토크 콘서트: 음, 향 Music & Scent', content = '', place = '비원뮤직홀 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '376379';
UPDATE festival SET title = '[대구] 송영주의 재즈 포레스트 ep0. 송영주트리오 & 호림 ', content = '', place = '수성아트피아' WHERE provider_type = 'PUBLIC' AND external_id = '373279';
UPDATE festival SET title = 'ONLY FOR YOU, 카운터테너 지필두 & 피아니스트 김지영', content = '', place = '에이치아츠(H-Art) 스튜디오' WHERE provider_type = 'PUBLIC' AND external_id = '373488';
UPDATE festival SET title = '[대구] 연극 <타임>', content = '', place = '아트플러스씨어터 2관' WHERE provider_type = 'PUBLIC' AND external_id = '376381';
UPDATE festival SET title = 'DAF 레지던시 교류전 <교류/횡단>', content = '', place = '대구예술발전소' WHERE provider_type = 'PUBLIC' AND external_id = '380610';
UPDATE festival SET title = 'RE:ART 프로젝트 1부 <시감지우>', content = '', place = '대구예술발전소 수창홀' WHERE provider_type = 'PUBLIC' AND external_id = '380611';
UPDATE festival SET title = '대구시립교향악단 <스쿨 콘서트 : Classics in K-Pop>', content = '', place = '대구콘서트하우스 그랜드홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '379829';
UPDATE festival SET title = '[대구] 수성아트피아 스테이지 S시리즈, 연극 화류비련극 <홍도> ', content = '', place = '수성아트피아' WHERE provider_type = 'PUBLIC' AND external_id = '376332';
UPDATE festival SET title = '[대구] DSAC 아트 셀렉션, 리처드 용재 오닐 & 박종해 듀오 리사이틀', content = '', place = '달서아트센터 청룡홀' WHERE provider_type = 'PUBLIC' AND external_id = '377665';
UPDATE festival SET title = '2026년 방짜유기박물관 ‘팔공산 선비의 멋, 공산의 구곡’', content = '', place = '대구방짜유기박물관' WHERE provider_type = 'PUBLIC' AND external_id = '399970';
UPDATE festival SET title = '대구콘서트하우스 명연주시리즈, 클라라 주미 강 & 김선욱 듀오 리사이틀', content = '', place = '대구콘서트하우스 그랜드홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '377954';
UPDATE festival SET title = '[대구] 라 트라비아타 & 루치아 디 람메르무어: 두 여인의 초상 ', content = '', place = '수성아트피아' WHERE provider_type = 'PUBLIC' AND external_id = '378867';
UPDATE festival SET title = '대구시립교향악단 <스쿨 콘서트 : Classics in K-Pop>', content = '', place = '대구콘서트하우스 그랜드홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '381644';
UPDATE festival SET title = '이윤동 - 겹쳐진 시간들', content = '<!-- wp:paragraph -->
<p>일시 : 2026. 6. 9 (Tue) ~ 6. 23(Tue)<br>작가 : 이윤동<br>장소 : 대구광역시 중구 동덕로 18, 2층 (대봉동) 갤러리소헌&소헌컨템포러리</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:post-featured-image /-->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리소헌&소헌컨템포러리는 오는 6월 9일부터 6월 23일까지 이윤동 작가의 텍스트 콜라주 작업을 조명하는 초대전 《겹쳐진 시간들》을 개최한다. 이번 전시는 2003년부터 시작된 작가의 텍스트 콜라주 작업 가운데 시리즈를 중심으로, 시간과 기억, 삶의 여정에 대한 사유를 펼쳐 보인다. “우리는 지금 어디에 있으며, 어디로 향해 가고 있는가.” 이번 전시는 이 질문을 따라, 관람객이 자기 삶의 궤적을 조용히 되돌아보는 자리를 마련한다. 이윤동 작가는 갤러리소헌과 여러 차례 개인전을 개최해왔으나, 특정 시기에 집중적으로 작업한 콜라주 시리즈를 한자리에서 조명하는 것은 이번 전시가 처음이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2003년부터 시작된 이윤동의 텍스트 콜라주(Text Collage) 작업은 그가 2004년 캐나다의 대학에 객원교수로 1년간 체류하던 시기의 작품전을 계기로 본격화되었으며, 이후 2012년까지 시리즈로 콜라주 작업을 이어왔다. 이 시기는 추상 회화 작업을 꾸준히 이어오던 작가의 작업 세계가 다른 방식으로 확장되던 시기로, 다양한 재료가 겹쳐진 화면 위로 절제된 구성, 직관적인 조형감각, 따뜻한 색면의 조화가 드러난다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작품에는 풀과 꽃, 때로는 마른 풀과 마른 꽃과 함께한 작고 고요한 인간의 모습이 주로 등장한다. 어디론가 이어지는 길을 따라 걷는 뒷모습, 잠시 멈춰 서 있는 존재, 혹은 기억 속의 한 장면. 이들은 무엇을 말하지 않는다. 다만 그 자리에 머물며 시간 속에 놓인 인간의 상태를 드러낼 뿐이다. 시간 속에서 피어나고 시들어가는 해바라기 뒤로 묵묵히 걸어가는 어르신의 뒷모습, 잠시 멈춰 서서 저 멀리 푸른 사각형을 응시하는 청년의 뒷모습은 관람객이 캔버스 속 인물에 자신을 겹쳐 보며 생각에 잠기도록 이끈다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>중첩된 텍스트들은 인물의 사연이자 지나온 시간의 흔적으로 읽힌다. 관람객은 그 조각들 사이에서 자신의 기억 속 한 장면을 떠올리게 된다. 작가는 관람객이 작품을 감상하며 자유롭게 생각하도록 작품의 의미를 제한 없이 열어두었다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>한편으로, 작가는 명화의 일부분을 작품 속에 들여오기도 한다. 로댕의 《생각하는 사람》과 밀레의 《만종》 속 기도하는 농부 이미지의 오마주는 관람객이 다시금 자기 자신을 바라보게 하는 장치가 된다. 과거와 현재를 잇는 작품 속 인물들은 쓸쓸함보다는 깊은 평온함에 가깝게 다가온다. 그들은 삶의 바깥이 아니라 한가운데에 머물며, 고요한 사유의 시간을 보여준다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이윤동 작가의 작업은 손으로 찢고, 붙이고, 덮고, 다시 덮는 긴 시간의 인내 속에서 이루어진다. 시간은 재료 위에 스며들고, 화면은 점차 하나의 층이 아닌 여러 겹의 기억으로 두터워진다. 그리고 그 위에 더해진 페인팅 요소들은 또 다른 기억의 편린처럼 작용하며 화면에 사유의 깊이를 더한다. 그 위를 덮는 부드러운 그리드 메쉬는 화면 전체를 은은하게 감싸며, 아련하고 편안한 시각적 효과를 만든다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":18937,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/06/이윤동-Journey-People부분-Collage-Gauze-Acrylic-on-Canvas-162.2-x-130.3-cm-2011.jpg" alt="" class="wp-image-18937" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>작가가 찢어낸 신문 조각과 인쇄물은 화면 위에 겹겹이 쌓이며 시간과 기억의 층위를 이룬다. 신문과 인쇄물은 특정한 시기의 사건과 정보를 담아낸 산업사회의 산물이자, 시간성을 드러내는 오브제이다. 그날의 사건과 정보를 빽빽하게 담고 있던 텍스트는 작품 안에서 더 이상 읽히기 위한 문자가 아니다. 해체된 언어는 의미를 잃는 대신, 또 다른 시간의 결을 드러낸다. 화면을 채우는 수많은 텍스트 조각들은 부딪혀 온 많은 정보와 관념, 머물다 사라진 생각과 감정들, 그리고 여전히 남아 있는 질문들의 파편과 흔적이 된다. 텍스트 사이로 스며든 여린 색채는 고단한 삶의 여정 속에서도 사라지지 않는 순수함과 서정성을 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이윤동의 시리즈는 인간이 묵묵히 걸어가는 삶의 길을 떠올리게 한다. 명확한 목적지를 제시하기보다, 화면 속 인물과 겹겹이 쌓인 텍스트 사이에서 관람객 스스로 자신의 시간을 마주하도록 이끈다. 이번 전시는 “우리는 지금 어디에 있으며, 어디로 향해 가고 있는가”라는 질문을 통해 삶의 방향과 기억의 의미를 조용히 되묻는 자리가 될 것이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":18938,"width":840,"height":699,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full is-resized"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/06/그림13-Journey-나뭇잎과-감꼭지-53×45.5cm-collage-mesh-cloth-acrylic-on-canvas-20크기변환.jpg" alt="" class="wp-image-18938" width="840" height="699" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Journey-나뭇잎과 감꼭지 53×45.5cm, collage, mesh cloth, acrylic on canvas</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이윤동 작가는 홍익대학교와 동 대학원에서 서양화를 전공하고, 2022년 초까지 국립안동대학교 교수로 재직하며 예술·체육대학 학장과 캐나다 UFV대학 객원교수(2004년)를 역임하였다. 또한 대한민국미술대전, 나혜석미술대전, 신라미술대전, 경북미술대전 등의 심사위원을 지냈다. 개인전 23회, 아트페어 부스전 4회를 개최했으며, 2인의 호흡전과 오리진회화협회전, 에꼴 드 서울전, 한국현대미술백인백색전, 아시안정신전, KOREAN MODERN ART(코스타리카), 한·중협력과 모색전 등 국내외 단체전에 다수 참여하였다. 현재 국립경국대학교 명예교수로 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '갤러리소헌&소헌컨템포러리' WHERE provider_type = 'PUBLIC' AND external_id = '382938';
UPDATE festival SET title = '이윤동 초대전 - 겹쳐진 시간들 ', content = '', place = '갤러리소헌&소헌컨템포러리' WHERE provider_type = 'PUBLIC' AND external_id = '382837';
UPDATE festival SET title = '[대구] 미하일 플레트네프& 고티에 카퓌송 & 라흐마니노프 인터네셔널 오케스트라 ', content = '', place = '대구콘서트하우스 그랜드홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '379479';
UPDATE festival SET title = '[대구] 신지아 & 디토 체임버 오케스트라: 두 번의 사계 ', content = '', place = '대구문화예술회관 팔공홀' WHERE provider_type = 'PUBLIC' AND external_id = '382481';
UPDATE festival SET title = '대구시립교향악단 <제59회 청소년 협주곡의 밤 : 영 아티스트 콘서트>', content = '', place = '대구콘서트하우스 그랜드홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '380890';
UPDATE festival SET title = '[대구] 강윤미 & 존 스토웰, A Timeless Place: 시간을 초월한 재즈의 대화 ', content = '', place = '베리어스 재즈클럽' WHERE provider_type = 'PUBLIC' AND external_id = '380690';
UPDATE festival SET title = '[대구] 국립오페라단 솔리스트 & 영아티스트 시리즈, 더 오페라(The OPERA) 라 트라비아타 & 마술피리 ', content = '', place = '대구학생문화센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '381863';
UPDATE festival SET title = '[대구] 친절한 오케스트라 시리즈 Ⅱ, 지브리 & 디즈니 애니메이션 콘서트 ', content = '', place = '대구서구문화회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '385507';
UPDATE festival SET title = '[대구] 윤소영 & 마르친 시코르스키 듀오 리사이틀', content = '', place = '대구콘서트하우스 챔버홀(소공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '382080';
UPDATE festival SET title = '[대구] 황찰리 퍼커션 & 드럼 리사이틀', content = '', place = '대구문화예술회관 팔공홀' WHERE provider_type = 'PUBLIC' AND external_id = '386582';
UPDATE festival SET title = 'ONLY FOR YOU, 사공유정 & 박시연 듀오 리사이틀: 클래식, 이야기가 되다', content = '', place = '에이치아츠(H-Art) 스튜디오' WHERE provider_type = 'PUBLIC' AND external_id = '387576';
UPDATE festival SET title = '비원뮤직홀 클래식 시리즈, 노희재 & 경세현 듀오 리사이틀', content = '', place = '비원뮤직홀 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '392138';
UPDATE festival SET title = '곽윤정 전 《Runaway Bride - 흔들리지 않는 요람》', content = '<!-- wp:post-featured-image /-->

<!-- wp:image {"id":19873,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/08/exhibition-view-2-2small.jpg" alt="" class="wp-image-19873" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>곽윤정 전 《Runaway Bride - 흔들리지 않는 요람》<br>8.10–8.28</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>순백의 드레스를 입고 진정한 자신을 향해 달리다<br>런어웨이 브라이드, 새로운 삶을 향한 용기 있는 출발</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>흔들리지 않는 요람, 아름다움과 생명력을 지켜내는 자생적인 세계</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>온전하게 자신을 품고 지켜주는<br>초록과 빛, 수많은 꽃으로 펼쳐낸 유토피아</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>대봉동 갤러리소헌&소헌컨템포러리는 8월 10일부터 28일까지 곽윤정 작가의 14번째 개인전 《Runaway Bride- 흔들리지 않는 요람》을 개최한다. 곽윤정은 러시아 유학 1세대 작가로 상트페테르부르크 국립미술대학 레핀스쿨 석사과정을 마친 뒤 러시아에서 익힌 리얼리즘을 바탕으로 출발했으나, 이를 자신만의 섬세한 색채 감각과 독창적인 표현으로 변주하며 점차 개인적인 화풍으로 확장해왔다. 현재는 러시아 리얼리즘의 흔적보다는 유럽의 인상주의를 연상시키는 부드러운 색채와 빛의 감각이 두드러지며, 자연과 자연 속 인간의 모습을 따뜻한 심상으로 그려내는 가운데 자연 속에서 인간이 치유되고 회복되는 순간들을 작업해오고 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 작가가 최근 집중적으로 작업하고 있는 ‘런어웨이 브라이드(Runaway Bride)’ 시리즈를 중심으로, 작품 세계의 핵심 모티프인 ‘흔들리지 않는 요람’을 통해 세상의 기준에서 벗어나 새로운 마음가짐으로 온전한 자신을 찾아가는 여정을 보여주고자 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>런어웨이 브라이드(Runaway Bride)는 일반적으로 결혼을 앞둔 두려움이나 부담감 때문에 결혼식장 또는 연인의 곁을 떠나는 신부를 뜻한다. 하지만 곽윤정은 이 말에 새로운 의미를 부여한다. 작가의 ‘런어웨이 브라이드’는 두려움 때문에 달아나는 존재가 아니다. 자신을 둘러싼 세상의 기준과 고정관념, 그동안 얽매여 있던 모든 것을 벗어던지고 자기 자신에게 집중하며 새로운 삶을 향해 나아가는 존재다. 화면 속 신부의 달리기는 현실로부터의 도피가 아니라, 진정한 자신에게로 향하는 능동적인 여정이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그 여정의 배경이자 시리즈의 서사를 이루는 핵심 공간이 바로 ‘흔들리지 않는 요람’이다. 본래 요람은 부모의 손길로 만들어지는 부드럽고 규칙적인 흔들림을 통해 아기를 안정시키고 편안한 잠으로 이끄는 최초의 보금자리다. 그러나 작가가 말하는 ‘흔들리지 않는 요람’은 외부의 힘에 의해 움직이거나 보호받는 수동적인 공간이 아니다. ‘흔들리지 않는 요람’은 외부의 힘에 의존하지 않고 스스로 균형을 이루고, 바깥세상에 흔들리거나 오염되지 않은 채 아름다움과 생명력을 지켜내는 자생적인 세계다. 외부의 위협으로부터 존재를 보호하고 치유하며, 편안하게 지켜주는 수호의 공간이며, 동시에 영원히 아름답고 풍요로운 유토피아를 지켜주는 방어막이 된다. 작가는 이곳을 타인의 시선과 세상의 기준에서 벗어나 진정한 자신을 마주하고, 자유롭고 행복한 존재로 다시 태어날 수 있는 유토피아로 그려낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이러한 유토피아 공간은 캔버스 위에서 초록과 수많은 꽃들이 어우러진 아름다운 정원의 모습으로 펼쳐진다. 웨딩드레스를 입은 주인공은 정원을 자유롭게 내달리고, 요람 세계를 지키는 ‘수호견’과 ‘수호 고양이’들은 멀리서 그녀를 지켜보거나 무리지어 공간을 순찰한다. 여러 마리의 강아지와 고양이와 함께 살아온 작가답게 등장하는 동물들의 표정과 동세 표현이 섬세하고 생동감 있게 살아있다. 자연스러운 몸짓과 사랑스러운 움직임은 화면에 따뜻한 활기를 더한다. 정원에는 곽윤정 작가의 이전 작품들에서 꾸준히 등장해 온 수국과 자작나무, 동백을 비롯해 꽃양귀비, 리시안셔스 등 다양한 꽃과 풀들이 피어난다. 짙은 청록에서부터 블루, 그린, 민트 컬러로 이어지는 바탕 색들과 그 위에 신비로운 바이올렛과 핑크, 레드 계열이 조화를 이루며 피어난다. 여기에 작가 특유의 부드러운 빛과 아스라한 음영 표현이 더해져 깊이 있는 풍경을 만들어낸다. 오랫동안 자신만의 색채를 탐구해 온 작가의 완숙한 표현은 신비롭고 아름다운 요람의 모습을 효과적으로 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작품 속 주인공은 요람 안에 머물며 치유와 회복의 시간을 보내고, 점차 진정한 자신의 모습을 발견해간다. 그리고 마침내 자유로워진 자신과 마주하며 비로소 행복에 이른다. 작가는 전시를 관람하는 관객들 역시 초록과 수많은 꽃들이 어우러진 아름다운 요람에 잠시 머물며 작품 속 주인공처럼 자신의 내면을 돌아보고 따뜻한 위로와 치유의 시간을 보내고 행복해지기를 바란다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>곽윤정의 ‘요람’은 앞으로 캔버스의 경계를 넘어 실제 대지로 확장될 예정이다. 작가는 회화 속 상상의 공간으로 존재해 온 요람을 현실의 땅 위에 구현하는 장기적인 대지 미술 프로젝트를 준비 중이다. 작품 속에 등장해 온 식물들이 실제 공간에 어떻게 자리하게 될지, 그 변화의 과정 자체가 하나의 서사가 될 것으로 보인다. 요람에 뿌리 내린 자연물들이 시간과 계절의 흐름에 따라 무한히 변화하고 성장하는 생명력이 포인트가 될 것 같다고 작가는 말한다. 요람이 현실의 풍경 속에서 어떤 모습으로 확장될지, 그 구체적인 장면은 앞으로 점차 드러날 예정이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 곽윤정이 장기적으로 진행하는 대지 미술 ‘요람’ 프로젝트의 첫걸음이자, 앞으로 실제 땅 위에 펼쳐질 세계를 캔버스로 먼저 보여주는 회화적 스케치다. 진정한 자신을 향해 달려가는 행복한 주인공과 그 존재를 따뜻하게 품고 지켜주는 ‘흔들리지 않는 요람’의 이야기는 8월 28일까지 대봉동 갤러리소헌&소헌컨템포러리에서 만날 수 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><br></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '갤러리소헌&소헌컨템포러리' WHERE provider_type = 'PUBLIC' AND external_id = '394044';
UPDATE festival SET title = '[대구] 2026 봉산공연창작소, 뮤직드라마 개발 리딩쇼케이스<반월당 안내원>', content = '', place = '봉산문화회관 스페이스라온' WHERE provider_type = 'PUBLIC' AND external_id = '388965';
UPDATE festival SET title = '취미인간에서 들리는 전시 프로젝트 Vol. 1 노비스르프 개인전 <공룡인간>', content = '', place = '취미인간' WHERE provider_type = 'PUBLIC' AND external_id = '392526';
UPDATE festival SET title = '[대구] 여름방학 키즈 패밀리 페스타 <이원복의 먼나라 이웃나라, 영국여행>', content = '', place = '대구서구문화회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '390514';
UPDATE festival SET title = '2026년 K-뮤지엄 지역 순회 전시 및 투어 지원사업 <이음-확장> 순회전', content = '', place = '대구섬유박물관' WHERE provider_type = 'PUBLIC' AND external_id = '397311';
UPDATE festival SET title = '[대구] 봉산공연창작소 Ⅲ. 쇼케이스 북성로 사운드스케이프 & 스트릿댄스쇼 <철의 리듬 (Rhythm of Iron)>', content = '', place = '봉산문화회관 스페이스라온' WHERE provider_type = 'PUBLIC' AND external_id = '390828';
UPDATE festival SET title = '[대구] 그림이 오감을 만났을 때 <감각주의>', content = '', place = '대덕문화전당' WHERE provider_type = 'PUBLIC' AND external_id = '391053';
UPDATE festival SET title = '[대구] 창작연극팩토리 연극 <십이야>', content = '', place = '수성아트피아' WHERE provider_type = 'PUBLIC' AND external_id = '392071';
UPDATE festival SET title = '[대구] 가족뮤지컬 <폭풍우 치는 밤에> ', content = '', place = '국립대구과학관 사이언트리홀' WHERE provider_type = 'PUBLIC' AND external_id = '395653';
UPDATE festival SET title = '컨템포러리 색면추상의 변주 2인전- 디터발처, 임소아', content = '', place = '갤러리소헌&소헌컨템포러리' WHERE provider_type = 'PUBLIC' AND external_id = '397205';
UPDATE festival SET title = '《컨템포러리 색면추상의 변주 2인전- 디터발처, 임소아》 9.7–9.23', content = '<!-- wp:post-featured-image /-->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>《컨템포러리 색면추상의 변주 2인전- 디터발처, 임소아》 (9.7–9.23), 갤러리소헌</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>날짜</p>
<!-- /wp:paragraph -->

<!-- wp:list {"ordered":true,"start":2026} -->
<ol start="2026"><!-- wp:list-item -->
<li>9.7(월)~9.23(금) (일요일, 공휴일 휴관)<br>10:00 ~ 18:00 (평일)<br>11:00 ~ 17:00 (토요일) 하루 전 사전예약 권장</li>
<!-- /wp:list-item --></ol>
<!-- /wp:list -->

<!-- wp:paragraph -->
<p>전시장소<br>갤러리소헌 & 소헌컨템포러리<br>대구광역시 중구 동덕로 18 (대봉동) 2F</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>연락처<br>art422@hanmail.net / 053-426-0621 / Instagram @gallerysoheon<br>010-9955-0621 (갤러리폰)<br>갤러리 공식 홈페이지 www.gallerysoheon.com<br>공식 블로그 blog.naver.com/soheoncontem</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20190,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/09/20260907_132836.jpg" alt="" class="wp-image-20190" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>독일 미술계에서 꾸준히 활동해 온 디터 발처(Dieter Balzer)​와 재독작가 임소아(So-Ah Yim)​의 개성 넘치는 현대 추상미술을 한자리에서 만나는 2인전이다.<br>두 작가는 색과 면, 기하학적 형태라는 간결한 조형언어를 바탕으로 각기 독창적인 작품세계를 구축해 왔다. 선명한 색면들이 반복되거나 교차하며 만들어내는 리듬과 예상치 못한 색의 조합은 엄격한 기하학적 질서에 생동감과 활력을 불어넣는다.<br>단순해 보이는 형태 속에는 색의 깊이와 공간의 변화, 치밀하게 조율된 긴장과 균형이 숨어 있어 바라볼수록 새로운 감각을 발견하게 한다. 절제된 형식과 화려한 색채가 만나 만들어내는 경쾌하고 세련된 화면은 관람자에게 순수한 시각적 즐거움을 선사할 것이다.<br>독일과 유럽을 중심으로 국제적인 활동을 이어오며 아시아까지 활동 영역을 넓혀온 두 중진작가의 대표적인 작업세계를 함께 살펴볼 수 있다.<br>《컨템포러리 색면추상의 변주》는 색과 기하학이라는 가장 단순한 미술의 언어가 얼마나 풍부하고 다채로운 세계로 확장될 수 있는지를 보여주는 전시이다.</p>
<!-- /wp:paragraph -->

<!-- wp:gallery {"linkTo":"none"} -->
<figure class="wp-block-gallery has-nested-images columns-default is-cropped"><!-- wp:image {"id":20193,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/09/20260907_132704.jpg" alt="" class="wp-image-20193" /></figure>
<!-- /wp:image --></figure>
<!-- /wp:gallery -->

<!-- wp:paragraph -->
<p>임소아 작가 작품</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>두 작가는 서로 다른 문화적 배경과 작업의 출발점을 지니고 있지만, 선과 면, 색, 형태 등 기본적인 조형요소에 집중한다는 점에서 맞닿아 있다. 현실의 대상을 사실적으로 재현하기보다 기하학적인 질서와 색채의 관계를 통해 화면과 공간을 구성하고, 색과 형태 그 자체가 만들어내는 긴장과 균형, 리듬과 조형적 아름다움을 탐구한다.<br>특히 두 작가의 작업에서 색은 형태를 채우는 부수적인 요소가 아니라 작품을 구축하는 핵심적인 조형언어로 작용한다. 서로 다른 색면은 반복되고 교차하며 때로는 서로 밀고 당기는 긴장을 만들어내고, 정돈된 기하학적 구조 속에서도 예상하지 못한 시각적 움직임과 경쾌한 리듬을 만들어낸다.<br>그러나 색과 기하학을 다루는 두 작가의 방식은 서로 다르다. 디터 발처가 실제 구조를 구축한 뒤 색을 입혀 물리적인 공간과 형태의 관계를 변화시킨다면, 임소아는 도시와 삶, 인간의 내면에서 출발한 경험과 감정을 사각형과 수직·수평선, 색이라는 절제된 조형언어로 환원한다.<br>이번 전시는 이러한 공통점과 차이를 한 공간에서 마주하게 하며, 색과 기하학을 다루는 각 작가의 작업이 어떻게 서로 다른 방식으로 확장되고 변주되는지를 보여준다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20195,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/09/전시전경4.jpg" alt="" class="wp-image-20195" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>Dieter Balzer</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>구조 위에서 움직이는 색 - Dieter Balzer</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>디터 발처(Dieter Balzer, 1958~)​는 독일 베를린을 기반으로 활동하며 구체미술(Concrete Art)과 기하학적 추상의 전통을 바탕으로, 미니멀리즘과 초기 개념미술의 영향을 자신만의 조형언어로 발전시켜 왔다.<br>그는 MDF를 절단하고 결합하여 기하학적 형태가 반복되고 교차하는 구조를 만들고, 그 표면에 정교하게 재단한 특수 컬러 필름을 입힌다. 작품의 구조는 엄격하고 치밀하게 구축되어 있지만, 그 위에 놓이는 색은 반드시 구조의 방향과 일치하지 않는다. 색은 구조의 질서를 따르기도 하고 때로는 그 질서와 어긋나며, 형태를 새롭게 인식하게 하는 시각적 긴장을 만들어낸다.<br>이 과정에서 색은 단순히 표면을 장식하는 요소가 아니라 구조를 변화시키고 공간을 새롭게 인식하도록 만드는 독립적인 조형요소가 된다. 그에게 특수 필름은 단순히 색을 더하기 위한 재료가 아니라, 구조물 위에 또 하나의 물질적 층을 만들어내는 요소이다. 작가는 이를 “몸에 피부를 덧입히는 것”에 비유한다. 그렇기에 그는 개인적인 붓질이나 손의 흔적을 작품 전면에 드러내지 않고 산업적으로 생산된 필름을 활용함으로써 개인적인 제스처를 최소화하고, 관람자의 시선을 색과 형태, 구조와 공간 사이의 관계에 집중시킨다.<br>엄격한 기하학적 질서와 선명한 색채의 대비, 반복과 변형에서 발생하는 리듬과 역동성은 디터발처 작업의 중요한 특징이다. 작품 속 작가의 의도아래 계획적으로 만들어진 건축적인 구조와 여러 층으로 분할되는 색면은 관람자의 위치와 시선에 따라 서로 다른 깊이와 공간감을 만들어낸다.<br>1958년 독일 노이호펜/팔츠에서 태어난 디터 발처는 독일 하이델베르크대학교에서 철학과 미술사를 공부한 뒤 영국과 노르웨이에서 미술을 수학했다. 1984년부터 베를린을 기반으로 활동해 왔으며 독일을 비롯한 유럽과 미국 등지에서 꾸준히 작품을 발표해 왔다. 그의 작품은 오스트리아 그라츠 지각 박물관(MUWA), 독일 빌헬름 하크 미술관, 기하학적 추상과 구체미술 컬렉션으로 잘 알려진 리터 뮤지엄 등에 소장되어 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>사각형과 색에 담긴 질서와 삶 - So-Ah Yim</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>임소아(So-Ah Yim, 1965~)​는 독일 함부르크를 기반으로 한국과 유럽을 오가며 활동해 온 작가로, 수직과 수평, 사각형과 색을 중심으로 자신만의 색면추상 회화를 발전시켜 왔다.<br>임소아의 화면에는 불필요한 서사적 요소들이 걷히고, 작가가 가장 완전한 형태로 바라보는 사각형과 색이 남는다. 작가에게 사각형은 단순한 기하학적 도형을 넘어 질서와 완전성, 영원성을 향한 동경을 담아내는 하나의 조형언어이다. 작가는 수직선과 수평선, 반복되는 사각형의 구조 안에서 색을 조율하며 최소한의 형태를 통해 순수한 조형성과 정신적인 세계를 드러내고자 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>색 역시 임소아의 작업을 이루는 중요한 축이다. 노란색과 파란색, 빨간색을 비롯한 선명한 색들은 오랜 시간 반복되는 붓질과 여러 차례의 중첩을 거쳐 완성된다. 작가는 색을 수차례 겹쳐 쌓아 올리면서도 붓질의 흔적을 최대한 드러내지 않아, 마치 처음부터 하나의 색이었던 듯 매끈하고 정제된 표면을 만들어낸다. 이러한 색면을 완성하기 위해서는 붓을 멈추거나 방향을 바꾸지 않고 한 호흡에 직선을 긋듯 색을 올려야 하며, 작은 어긋남도 허용하지 않는 높은 집중력과 섬세한 조율이 필요하다. 색들은 서로 조합되고 어우러지는 과정에서 화면에 깊이감과 공간감을 형성하며, 색면 사이의 관계와 미묘한 조화는 단순히 시각적인 아름다움을 넘어 다양한 감정과 정서를 은유적으로 환기한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그러나 임소아의 기하학은 순수한 형식에만 머물지 않는다. 그가 반복해 온 수직과 수평, 사각형의 질서 뒤에는 도시와 그 안에서 살아가는 인간에 대한 오랜 관심이 자리한다.<br>대도시에서 성장한 작가는 수직으로 솟은 건축물과 그 사이를 살아가는 인간, 인간관계와 삶의 모습을 일정한 거리를 두고 바라본다. 작가에게 대도시는 자연과 대비되는 인공적인 입체물이면서도, 아이러니하게 익숙함과 평안을 느끼게 하는 공간이다. 복잡하게 얽힌 도시의 구조와 그 안에서 경험하는 삶의 모습은 작가의 시선을 거쳐 수직과 수평, 사각형과 색이라는 절제된 형태로 정제된다.<br>따라서 겉으로는 엄격하고 질서정연한 기하학적 화면이지만, 그 안에는 인간의 삶과 감정, 현실과 보이지 않는 세계에 대한 작가의 사유가 함께 자리한다. 임소아는 동시대의 소외나 상실에 머무르기보다 미래에 대한 긍정적인 기대와 즐거움, 그리고 인간이 끊임없이 추구하는 정신적인 세계를 색과 기하학적 형태를 통해 표현하고자 한다.<br>작품의 제목에서도 이러한 태도를 엿볼 수 있다. 룩스(Lux)와 루멘(Lumen)은 ‘빛’, 스파티움(Spatium)은 ‘공간’, 옵타툼(Optatum)은 ‘소망’을 의미한다. 간결한 라틴어 제목들은 작품의 구체적인 이야기를 설명하기보다 빛과 공간, 소망과 기쁨처럼 작가가 작품에 담고자 하는 긍정적인 의미를 은유적으로 드러낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>성신여자대학교와 동 대학원을 졸업한 임소아는 이후 독일 국립 브라운슈바이크 조형미술대학에서 순수미술을 전공하고 최고수제자과정을 마쳤다. 현재 독일 함부르크에 거주하며 작업하고 있으며, 독일을 비롯해 프랑스, 일본, 네덜란드, 홍콩 등 국내외에서 꾸준히 전시 활동을 이어왔다. 독일과 뉴욕의 레지던시 및 여러 예술재단의 지원을 받았으며, 한국에서는 고양 국립미술창작스튜디오와 청주 창작스튜디오 등에서 작업했다. 그의 작품은 독일 리터뮤지엄, 대한민국 외교통상부, 독일 C15 하인즈&울라 컬렉션, 스위스 호벡컬렉션, 독일 피르마젠스 뮤지엄 등 국내외 기관과 컬렉션에 소장되어 있다. 국내에서는 갤러리소헌의 개인전과 기획전, Kiaf seoul, 화랑미술제 아트페어 등을 통해 꾸준히 작품을 선보여 왔다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>같은 언어, 다른 변주</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>디터 발처와 임소아의 작품은 선명한 색면과 기하학적 형태, 반복과 질서라는 점에서 서로 닮아 있다.<br>그러나 두 작가가 그 언어에 도달하는 방식은 다르다.<br>디터 발처가 구조와 재료 자체에서 출발해 색을 통해 물리적인 공간을 다시 조직한다면, 임소아는 ​도시와 인간의 삶, 내면의 감정과 정신적인 세계를 기하학적인 색과 형태로 정제한다. 발처는 필름을 사용해 개인적인 붓질의 흔적을 제거한다. 임소아는 오히려 수 차례 붓질을 반복하지만, 완성된 화면에서는 그 흔적을 거의 지워낸다. 서로 다른 과정이지만 두 작가는 결국 개인적인 제스처보다 색과 면, 형태 그 자체가 가진 힘​을 전면에 드러낸다.<br>이처럼 《컨템포러리 색면추상의 변주》는 색과 기하학이라는 공통의 조형언어가 두 작가의 서로 다른 경험과 태도를 만나 어떻게 새로운 형태의 작품으로 변주되는지를 보여주는 전시이다.<br>작가 스스로가 의도하는 엄격한 질서 속에서 끊임없이 달라지는 색의 조합과 형태의 리듬, 그리고 그 안에 숨어 있는 공간과 감정을 따라가다 보면 관람자는 추상미술이 가진 순수한 조형적 아름다움과 함께 색 자체가 전달하는 경쾌하고 긍정적인 에너지를 만나게 될 것이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>《컨템포러리 색면추상의 변주》 전시는 9월 23일까지 대봉동 갤러리소헌에서 열린다. (053-426-0621, 토요일 사전예약, 일요일 휴관)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '갤러리소헌&소헌컨템포러리' WHERE provider_type = 'PUBLIC' AND external_id = '397407';
UPDATE festival SET title = '2026월드오케스트라페스티벌, 신창용 & 프랑스 메스 그랑테스트 국립 오케스트라', content = '', place = '대구콘서트하우스 그랜드홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '393567';
UPDATE festival SET title = '[대구] 서구! 서풍(西風) 콘서트 with 김희재·홍지윤·고성현', content = '', place = '이현공원 [대구] 잔디광장' WHERE provider_type = 'PUBLIC' AND external_id = '398382';
UPDATE festival SET title = '[대구] 2026 동빈이네 콘서트 ''사계(四季)''', content = '', place = '스테이지엠' WHERE provider_type = 'PUBLIC' AND external_id = '398343';
UPDATE festival SET title = '작곡가 장은호 작품 발표회 ''침묵의 밀도''', content = '', place = '수성아트피아' WHERE provider_type = 'PUBLIC' AND external_id = '397493';
UPDATE festival SET title = '문준호 《남겨진 것들을 위한 풍경》', content = '', place = '갤러리소헌&소헌컨템포러리' WHERE provider_type = 'PUBLIC' AND external_id = '403033';
UPDATE festival SET title = '[대구 동성로] 연극 <운빨로맨스>', content = '', place = '아트플러스씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '401659';
UPDATE festival SET title = '[청주] 힐링코미디연극 <뷰티풀라이프>', content = '', place = '소명아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '351873';
UPDATE festival SET title = '제16회 기획전시 『여성, 삶을 이끌다!: 사랑 & 헌신』 전(展)', content = '', place = '반기문평화기념관' WHERE provider_type = 'PUBLIC' AND external_id = '363990';
UPDATE festival SET title = '[청주] 겨울이야기&초대형레이져쇼', content = '', place = '청주예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '363700';
UPDATE festival SET title = '[청주 갤러리 원] B관 황보태훈 개인전 ''입체적 선과 추상 조각들''', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '366950';
UPDATE festival SET title = '[청주 갤러리 원] A관 김희라 개인전 ''숲의 여운''', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '366951';
UPDATE festival SET title = '[청주] 지브리 & 디즈니 영화음악 FESTA ', content = '', place = '청주예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '365694';
UPDATE festival SET title = '[청주 갤러리 원] A관 김다은 개인전 "﻿지금, 여기"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '368964';
UPDATE festival SET title = '[청주 갤러리 원] B관 정진희 개인전 "﻿삶의 궤적 : 빙렬"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '368966';
UPDATE festival SET title = '[청주 갤러리 원] A관 이종화 개인전 "﻿Space Imagination"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '370242';
UPDATE festival SET title = '[청주 갤러리 원] B관 이경선 개인전 "﻿강아지풀에서 현실을 만나다"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '370243';
UPDATE festival SET title = '청주 갤러리원 2026년 공예·도예 공모 모집', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '366029';
UPDATE festival SET title = '[청주] 피터 야블론스키 & 김정원 피아노 듀오 리사이틀', content = '', place = '청주아트홀 (구. 청주시민회관)' WHERE provider_type = 'PUBLIC' AND external_id = '369360';
UPDATE festival SET title = '[청주 갤러리 원] B관 김기택 개인전 "﻿어느 날 - 파편화된 기억"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '373335';
UPDATE festival SET title = '[청주 갤러리 원] A관 나기성 초대 개인전 "﻿naki-jaki butterfly-moon"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '373422';
UPDATE festival SET title = '[청주 갤러리 원] B관 김철윤 개인전 "﻿희망을 찾아서"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '376258';
UPDATE festival SET title = '[청주 갤러리 원] A관 김인수 초대 개인전 "﻿제5회 김인수 초대개인전"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '376259';
UPDATE festival SET title = '빛·울림·힘 - 금속, 감각을 깨우다', content = '2026년 국립청주박물관 특별전빛·울림·힘-금속, 감각을 깨우다●​전시기간2025. 4. 28.(화) ~ 8. 30.(일)전시장소국립청주박물관 특별전시실(청명관)●​전시개요​2026년 국립청주박물관 특별전 <빛·울림·힘-금속, 감각을 깨우다>는 서봉총 금관, 운천동 동종, 사인검 단 세 점의 전시품을 중심으로 금속이 이끄는 감각의 여정에 주목합니다.감각이란 단순히 보고, 듣고, 인지하는 신체적 기능을 넘어, 세계를 이해하고 의미를 만들어가는 방식입니다. 눈에 보이는 빛, 귀에 머무는 소리, 손끝에 닿는 질감은 각자의 경험과 기억을 만나 새로운 해석으로 확장됩니다. 결국 감각은 단순한 ‘느낌’을 넘어 ‘사유와 인식’으로 이어지는 가장 개인적인 언어입니다.이 전시는 ‘빛·울림·힘’이라는 세 가지 감각의 흐름을 따라 여러분이 스스로 보고, 느끼고, 해석하는 과정을 경험하도록 구성되었습니다. 문화유산의 역사적 가치를 이해하는 데에서 한 걸음 더 나아가 금속이 전하는 감각과 그 안에 담긴 당신만의 세계를 발견해 보시기 바랍니다.​', place = '국립청주박물관' WHERE provider_type = 'PUBLIC' AND external_id = '374512';
UPDATE festival SET title = '[청주 갤러리 원] B관 안수빈 개인전 "﻿산책 + 바느질 : 어울숲"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '378139';
UPDATE festival SET title = '[청주 갤러리 원] A관 정지광 개인전 "﻿숨결에 물든 시간의 흔적"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '378138';
UPDATE festival SET title = '[청주 갤러리 원] B관 김영옥 초대개인전 "﻿빛이 지나간 자리"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '379348';
UPDATE festival SET title = '[청주 갤러리 원] A관 문희 초대개인전 "﻿살아있다는 것은_"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '379349';
UPDATE festival SET title = '[청주 갤러리 원] B관 이문종 개인전 "歲寒心事久彌堅 - 세한이 오래될수록 내면은 더욱 견고해진다."', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '382114';
UPDATE festival SET title = '[청주 갤러리 원] A관 안혜리 개인전 "﻿﻿마음의 머무는 결"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '382115';
UPDATE festival SET title = '3대가 함께 볼 수 있는 따뜻한 연극!  <마지막 소원>', content = '', place = '제천시문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '380416';
UPDATE festival SET title = '[청주 갤러리 원] A관 한수희 개인전 "﻿﻿아리랑 회화"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '384803';
UPDATE festival SET title = '[청주 갤러리 원] B관 정철호 개인전 "평면과 입체사이"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '384804';
UPDATE festival SET title = '네오아트센터_정창훈 초대전 "아리랑을 다시 쓰다"   ', content = '', place = '충북문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '385582';
UPDATE festival SET title = '[청주 갤러리 원] A관 ''전호 수채화 기획 초대전''', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '387429';
UPDATE festival SET title = '청주시립국악단 제146회 정기연주회 <소리놀이 판Ⅱ>', content = '', place = '청주예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '386820';
UPDATE festival SET title = '[청주 갤러리 원] B관 "﻿조개더미의 비밀"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '389398';
UPDATE festival SET title = '청주시립교향악단 <클래식 판타지아>', content = '', place = '청주아트홀 (구. 청주시민회관)' WHERE provider_type = 'PUBLIC' AND external_id = '386099';
UPDATE festival SET title = '[청주 갤러리 원] A관 이정현 초대개인전 "음악을 그리다 II"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '389419';
UPDATE festival SET title = '[충주공예전시관] ''세상에서 가장 이상한 버스''', content = '', place = '충주문화관광재단' WHERE provider_type = 'PUBLIC' AND external_id = '394053';
UPDATE festival SET title = '[청주 갤러리 원] A관 최철기 도예 개인전 "선(線), 가장 단순한 것에서 가장 깊은 아름다움을 찾다."', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '391644';
UPDATE festival SET title = '[청주 갤러리 원] A관 김다겸 개인전 "일상의 바다"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '394611';
UPDATE festival SET title = '청주시립교향악단 ''청소년과 함께하는 콘서트 오페라-사랑의 묘약''', content = '', place = '청주예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '390378';
UPDATE festival SET title = '[청주 갤러리 원] B관 청주 공예협회전"﻿초대작가전"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '394612';
UPDATE festival SET title = '부조리극 <먼지 아기>', content = '', place = '제천시민회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '393368';
UPDATE festival SET title = '청주예술의전당 개관 30주년 기념작 앙코르 창작뮤지컬 <청주>', content = '', place = '청주예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '389611';
UPDATE festival SET title = '[청주 갤러리 원] B관 김초윤 개인전 "﻿카이로스로 만나는 감성적 순간들"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '395933';
UPDATE festival SET title = '[청주 갤러리 원] A관 송원혜 개인전 "﻿매란국죽 이야기-행복을 건네다-"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '395934';
UPDATE festival SET title = '[청주 갤러리 원] B관 한국수묵캘리협회전 "﻿글씨가 위로가 되는 순간"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '397031';
UPDATE festival SET title = '[청주 갤러리 원] A관 예술별찌문화사회적협동조합 회원전 "잇다,있다,-있다"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '398168';
UPDATE festival SET title = '청주시립교향악단 ''Elegance & Passion(우아함 그리고 열정)''', content = '', place = '청주아트홀 (구. 청주시민회관)' WHERE provider_type = 'PUBLIC' AND external_id = '394964';
UPDATE festival SET title = '[청주 갤러리 원] B관 정미경 개인전 ''뻔할 FUN : 행복의 순환''', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '398692';
UPDATE festival SET title = '[청주 갤러리 원] A관 배진석 개인전"마음결-시간이 머문 자리"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '400368';
UPDATE festival SET title = '[청주 갤러리 원] B관 이종화 개인전 "﻿제 59회 이종화 개인전"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '401420';
UPDATE festival SET title = '[청주 갤러리 원] A관 조만호 개인전 "윤슬[빛,산산이 흩뿌려지다]"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '401393';
UPDATE festival SET title = '청주시립교향악단 2026 파안 박영희 음악제 특별연주회 ''자유와 창조''-with 대니구', content = '', place = '청주예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '400472';
UPDATE festival SET title = '[청주 갤러리 원] B관 이원 개인전 "﻿파도가 지나간 자리"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '402694';
UPDATE festival SET title = '[청주 갤러리 원] A관 에코 개인전 "﻿야곡"', content = '', place = 'CGV청주(서문) 갤러리원 1층 ' WHERE provider_type = 'PUBLIC' AND external_id = '402693';
UPDATE festival SET title = '청주시립교향악단 문화가 있는날 특별기획 <마티네 콘서트-현이 그리는 햇살>', content = '', place = '청주아트홀 (구. 청주시민회관)' WHERE provider_type = 'PUBLIC' AND external_id = '401171';
UPDATE festival SET title = '뮤지컬 <연하>', content = '', place = '괴산문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '399369';
UPDATE festival SET title = '[의령] 박중훈과 유리상자의 토크 & 뮤직 콘서트 ', content = '', place = '의령군민문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '376916';
UPDATE festival SET title = '노순천·최수환 《자리잡기》', content = '', place = '프로젝트 아이' WHERE provider_type = 'PUBLIC' AND external_id = '377856';
UPDATE festival SET title = '공주시충남교향악단 신년음악회 New Year‘s Concert', content = '', place = '공주문예회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '362212';
UPDATE festival SET title = '[서산] 신년음악회, 함신익 & 심포니 송 ', content = '', place = '서산시문화회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '365572';
UPDATE festival SET title = '[의성] 신지아&디토 체임버 오케스트라 : 두 번의 사계', content = '', place = '의성문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '401501';
UPDATE festival SET title = '[공주] 오프닝 콘서트: 신세계교향곡 & 카르미나 부라나 ', content = '', place = '공주문예회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '365600';
UPDATE festival SET title = '[천안] 아즈마 아키와 함께하는 영화음악 콘서트: 지브리 & 월드무비 OST ', content = '', place = '천안예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '366380';
UPDATE festival SET title = '[당진] 힐링코미디 연극 <사돈언니> ', content = '', place = '당진문예의전당 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '368537';
UPDATE festival SET title = '[공주] 공주시충남교향악단과 함께하는 명곡시리즈 Ⅰ, 백건우 & 브람스 ', content = '', place = '공주문예회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '369734';
UPDATE festival SET title = '[부여] 백제대향로관 개관 공연 시리즈 Ⅳ. 연극 <사랑해 엄마> ', content = '', place = '국립부여박물관 사비마루' WHERE provider_type = 'PUBLIC' AND external_id = '370349';
UPDATE festival SET title = '[공주] 제19회 공주시립합창단 정기연주회: 시를 노래하다 - 셰익스피어 & 나태주', content = '', place = '공주문예회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '374972';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 박물관 안 수선집 Ⅳ ‘헌물과 선물’', content = '', place = '온양민속박물관' WHERE provider_type = 'PUBLIC' AND external_id = '376522';
UPDATE festival SET title = '[당진] 송승환의 <난타>', content = '', place = '당진문예의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '374454';
UPDATE festival SET title = '[공주] 공주시충남교향악단 가정의 달 기념 지브리 & 디즈니 패밀리 콘서트 ', content = '', place = '공주문예회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '375859';
UPDATE festival SET title = '[공주] 공주시충남교향악단과 함께하는 명곡시리즈 Ⅱ, 리처드 용재 오닐 & 라흐마니노프 ', content = '', place = '공주문예회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '378921';
UPDATE festival SET title = '[천안] 지브리 & 디즈니 OST 콘서트 with 첼로댁 ', content = '', place = '천안예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '378899';
UPDATE festival SET title = '이재환 개인전 <공백의 기록>', content = '', place = '공간 들' WHERE provider_type = 'PUBLIC' AND external_id = '384945';
UPDATE festival SET title = '2026 천안시립미술관·충남미술관 협력전 《균열: 충남의 아방가르드》', content = '', place = '천안시립미술관' WHERE provider_type = 'PUBLIC' AND external_id = '389357';
UPDATE festival SET title = '[당진] 남상일 & 박애리 국악 버라이어티쇼: 잔치 ', content = '', place = '당진문예의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '382881';
UPDATE festival SET title = '[예산] 지브리 & 디즈니 애니메이션 콘서트 ', content = '', place = '충청남도 문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '384800';
UPDATE festival SET title = '[당진] 지브리 & 디즈니 영화음악 오케스트라 콘서트 ', content = '', place = '당진문예의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '387359';
UPDATE festival SET title = '[천안] 창극 <살로메> ', content = '', place = '천안예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '390550';
UPDATE festival SET title = '[천안] 제2회 한국스즈키 대전·충청·호남 연합 오케스트라 정기연주회', content = '', place = '천안예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '391669';
UPDATE festival SET title = '국립공주박물관 특별전 ''한국의 영산, 계룡산(가제)''', content = '', place = '국립공주박물관' WHERE provider_type = 'PUBLIC' AND external_id = '374510';
UPDATE festival SET title = '2025 상주박물관 특별기회전 ''화령, 백두대간이 품은 마을''', content = '', place = '상주박물관' WHERE provider_type = 'PUBLIC' AND external_id = '361461';
UPDATE festival SET title = '포항시립미술관 초대개인전 <땅, 물, 불, 바람 : 윤옥순의 회향>', content = '', place = '포항시립미술관' WHERE provider_type = 'PUBLIC' AND external_id = '345845';
UPDATE festival SET title = '2025 김천시립박물관 특별전 ''유럽의 차 문화''', content = '', place = '김천시립박물관' WHERE provider_type = 'PUBLIC' AND external_id = '366672';
UPDATE festival SET title = '2025 예천박물관 기탁문중 특별전 ''記錄, 역사가 되다''', content = '', place = '예천박물관' WHERE provider_type = 'PUBLIC' AND external_id = '364002';
UPDATE festival SET title = '[구미] 신년음악회: 정명훈 & 레오니다스 카바코스 & KBS교향악단', content = '', place = '구미시문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '363064';
UPDATE festival SET title = '<매치-업: 연결되는 우리> Match-up: We Connect', content = '', place = '포항문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '366141';
UPDATE festival SET title = '[문경] 지브리 & 디즈니 OST 콘서트 ', content = '', place = '문경문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '366056';
UPDATE festival SET title = '[포항] 가족뮤지컬 겨울이야기 & 초대형 레이져쇼 ', content = '', place = '포항문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '366190';
UPDATE festival SET title = '[경주] New year''s voice: 새해를 여는 목소리', content = '', place = '경주예술의전당 대공연장(화랑홀)' WHERE provider_type = 'PUBLIC' AND external_id = '366709';
UPDATE festival SET title = '[상주] V.O.S & J-CERA CONCERT ', content = '', place = '상주문화회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '369669';
UPDATE festival SET title = ' [영주] 개그연극 <안녕, 할배>', content = '', place = '영주문화예술회관 까치홀' WHERE provider_type = 'PUBLIC' AND external_id = '371418';
UPDATE festival SET title = '[안동] 정태춘 & 박은옥 문학콘서트: 나의 시, 나의 노래 ', content = '', place = '안동문화예술의전당 웅부홀' WHERE provider_type = 'PUBLIC' AND external_id = '369735';
UPDATE festival SET title = '[영덕] 춤추는 지휘자 백윤학과 함께하는 지브리 & 디즈니 OST FESTA ', content = '', place = '예주문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '372131';
UPDATE festival SET title = '[예천] 송소희 Χ 두번째달 Χ 김준수: 모던민요 ', content = '', place = '예천군문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '372186';
UPDATE festival SET title = '[안동] 서울예술단 창작가무극 <나빌레라> ', content = '', place = '안동문화예술의전당 웅부홀' WHERE provider_type = 'PUBLIC' AND external_id = '373305';
UPDATE festival SET title = '[김천] 바리톤 이응광 & 유럽의 별들 ', content = '', place = '김천시립율곡도서관 율곡홀 (다목적강당)' WHERE provider_type = 'PUBLIC' AND external_id = '376768';
UPDATE festival SET title = '[안동] 가수 인순이 & 명창 유지숙 <두 사랑 이야기>', content = '', place = '안동문화예술의전당 웅부홀' WHERE provider_type = 'PUBLIC' AND external_id = '375291';
UPDATE festival SET title = '[2026년 박물관·미술관 주간] 상식이 된 파격_그때는 힙스터: 지금은 꼰대', content = '', place = '대구대학교박물관' WHERE provider_type = 'PUBLIC' AND external_id = '376704';
UPDATE festival SET title = '[구미] 무장애 접근성 활성화 공연 음악극 ''하늘, 바람, 바다''', content = '', place = '강동문화복지회관 천생아트홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '378847';
UPDATE festival SET title = '[포항] 패밀리 재즈 콘서트: 재즈로 듣는 지브리 & 디즈니 OST ', content = '', place = '포항문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '381260';
UPDATE festival SET title = '[의성] 임선혜&이동규, 러브 듀엣: Mozart and Handel in Love ', content = '', place = '의성문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '383556';
UPDATE festival SET title = '[안동] 소프라노 황수미 & 베이스 바리톤 사무엘 윤 듀오 리사이틀', content = '', place = '안동문화예술의전당 웅부홀' WHERE provider_type = 'PUBLIC' AND external_id = '381699';
UPDATE festival SET title = '[경주] 제17회 대한민국 국공립극단 페스티벌 in 경주경주시립극단 <줄없는 나무 인형>', content = '', place = '경주예술의전당 소공연장(원화홀)' WHERE provider_type = 'PUBLIC' AND external_id = '382468';
UPDATE festival SET title = '[경산] 경산시립극단, SF연극 <햄버거 먹다가 생각날 이야기> ', content = '', place = '경산시민회관 대강당' WHERE provider_type = 'PUBLIC' AND external_id = '387098';
UPDATE festival SET title = '[경주] 제17회 대한민국 국공립극단 페스티벌 in 경주, 포항시립연극단 <생존의 법칙>', content = '', place = '경주예술의전당 대공연장(화랑홀)' WHERE provider_type = 'PUBLIC' AND external_id = '386690';
UPDATE festival SET title = '[경주] 제17회 대한민국 국공립극단 페스티벌 in 경주, 인천시립극단 <니들이 인천을 알어?!>', content = '', place = '경주예술의전당 소공연장(원화홀)' WHERE provider_type = 'PUBLIC' AND external_id = '386729';
UPDATE festival SET title = '[의성] 유앤잇 (YOU & IT)', content = '', place = '의성문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '387958';
UPDATE festival SET title = '[포항] 국악가족뮤지컬 <강치傳>', content = '', place = '포항문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '385876';
UPDATE festival SET title = '[경주] 지브리 & 디즈니 영화음악 오케스트라 콘서트 ', content = '', place = '경주예술의전당 대공연장(화랑홀)' WHERE provider_type = 'PUBLIC' AND external_id = '387361';
UPDATE festival SET title = '[안동] 2026 창작가무극 독립의혼 임청각 ''대동의 꿈''', content = '', place = '안동문화예술의전당 웅부홀' WHERE provider_type = 'PUBLIC' AND external_id = '390631';
UPDATE festival SET title = '2026년 수토역사전시관 공동기획전 "울릉도, 1919"', content = '', place = '독도박물관' WHERE provider_type = 'PUBLIC' AND external_id = '395920';
UPDATE festival SET title = '[안동] 무장애 접근성 활성화 제작공연 연극 ''순남이와 순이'' ', content = '', place = '안동문화예술의전당 백조홀' WHERE provider_type = 'PUBLIC' AND external_id = '392038';
UPDATE festival SET title = '[구미] 예술경영지원센터 지역유통사업 연극 <파랑새> ', content = '', place = '구미시문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '391741';
UPDATE festival SET title = '[안동] “육사시집(陸史詩集)” 초판본 발간 80주년 기념 이육사 시음악회', content = '', place = '안동문화예술의전당 웅부홀' WHERE provider_type = 'PUBLIC' AND external_id = '393511';
UPDATE festival SET title = '[경산] 안다미로아트컴퍼니 현대무용 <문> ', content = '', place = '경산시민회관 대강당' WHERE provider_type = 'PUBLIC' AND external_id = '393708';
UPDATE festival SET title = '2026년 상주박물관 기증유물전 ''당신이 건넨 시간, 상주의 역사가 되다''', content = '', place = '상주박물관' WHERE provider_type = 'PUBLIC' AND external_id = '402794';
UPDATE festival SET title = '[안동] 한·불 수교 140주년 기념 프랑스 메스 그랑테스트 국립 오케스트라 공연스트라 공연 ', content = '', place = '안동문화예술의전당 웅부홀' WHERE provider_type = 'PUBLIC' AND external_id = '395324';
UPDATE festival SET title = '경주-대구-말레이시아 청소년국제교류 연합연주회: Harmony of Silk Road & beyond', content = '', place = '경주예술의전당 대공연장(화랑홀)' WHERE provider_type = 'PUBLIC' AND external_id = '395105';
UPDATE festival SET title = '[구미] 마당극 <아도가 남쪽으로 온 까닭은>', content = '', place = '신라불교초전지' WHERE provider_type = 'PUBLIC' AND external_id = '399900';
UPDATE festival SET title = '[구미] 마당극 <아도가 남쪽으로 온 까닭은> ', content = '', place = '강동문화복지회관 천생아트홀(대공연장)' WHERE provider_type = 'PUBLIC' AND external_id = '399702';
UPDATE festival SET title = ' [예주] 인형극 <꽃잠: 별별수다>', content = '', place = '예주문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '397839';
UPDATE festival SET title = '[구미] SF 연극 <우리가 빛의 속도로 갈 수 없다면>', content = '', place = '구미시문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '399437';
UPDATE festival SET title = '[영덕] 영덕보엠앙상블, 피터와 늑대 & 동물의 사육제 ', content = '', place = '예주문화예술회관 무형문화재전수교육관' WHERE provider_type = 'PUBLIC' AND external_id = '399890';
UPDATE festival SET title = '[경주] 합창 오페라 ''천년의 빛, 하나의 울림''', content = '', place = '경주예술의전당 대공연장(화랑홀)' WHERE provider_type = 'PUBLIC' AND external_id = '398536';
UPDATE festival SET title = '[영덕] 국립정동극장 <광대>', content = '', place = '예주문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '399910';
UPDATE festival SET title = '[경북 경산] 창작뮤지컬 <압독의 노래>', content = '', place = '경산시민회관 대강당' WHERE provider_type = 'PUBLIC' AND external_id = '399633';
UPDATE festival SET title = '포항국제음악제, 포커스 스테이지 Ⅰ. 이한나 & 박영성', content = '', place = '포항시청 대잠홀' WHERE provider_type = 'PUBLIC' AND external_id = '401665';
UPDATE festival SET title = '시간의 공존 김해 대성동 고분군', content = '세계유산 가야 2주년 특별전 <시간의 공존 김해 대성동 고분군>', place = '국립김해박물관' WHERE provider_type = 'PUBLIC' AND external_id = '344503';
UPDATE festival SET title = '[창원] 창원시립교향악단 신년음악회 "2026 NEW YEAR''S CONCERT"', content = '', place = '3.15아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '365525';
UPDATE festival SET title = '여정의 순간', content = '<!-- wp:paragraph -->
<p>갤러리 오로라 "2026 신진작가 초대 기획전 - 여정의 순간"</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2026. 1. 28 - 2. 23</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17043,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/01/momets-01-1.jpg" alt="" class="wp-image-17043" /></figure>
<!-- /wp:image -->

<!-- wp:quote -->
<blockquote class="wp-block-quote"><!-- wp:paragraph -->
<p>" 류아영, 문혜연, 박웅배, 이다현, 정진하, 최윤정 "</p>
<!-- /wp:paragraph --><cite>참여작가</cite></blockquote>
<!-- /wp:quote -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17044,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/01/moments-02.jpg" alt="" class="wp-image-17044" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>깊어가는 겨울, 양산에 위치한 복합문화공간 스페이스나무에서 볼만한 전시가 열립니다. 신진작가를 발굴하고 지원해 온 스페이스나무는 올해 첫 전시로 <2026 신진작가 초대기획전-여정의 순간->을 준비했습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시는 2026년 1월 28일부터 2월 23일까지 스페이스나무 갤러리 오로라에서 진행됩니다. 추운 겨울을 이겨내고 따뜻한 봄을 준비하는 작가 6인의 개성 넘치는 작품이 전시됩니다. 작가로서 첫 발을 내딛는 여정의 순간을 조명하는 전시입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17061,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/01/moment-14.jpg" alt="" class="wp-image-17061" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>류아영, 문혜연, 박웅배, 이다연, 정진하, 최윤정 작가는 저마다의 색깔로 여정의 순간을 담았습니다. 새로운 시작이라 불리는 지금은, 작가들이 걸어왔던 과정에서 하나의 단계로 나아가는 시점입니다. 소속과 집단을 벗어나 또 다른 준비를 시작하는 발돋움을 스페이스나무가 함께합니다. 본 전시는 작가들이 그동안 쌓아온 작업의 흔적과 여정 속에서 마주한 순간들을 담아냅니다. 이미 시작된 여정을 되돌아보고, 앞으로 나아갈 길을 응원하는 자리를 마렵합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17045,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/01/moment-03.jpg" alt="" class="wp-image-17045" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>작은 나무들은 언젠가 세상에서 가장 큰 나무로 자랄지도 모릅니다. 꿀보다 달콤한 열매를 맺고, 저마다의 색깔로 숲을 이룰 것입니다. 그 숲이 무성해지기 위해서는 따뜻한 손길과 아낌없는 물줄기가 필요합니다. 작은 나무들이 담아낸 여정의 순간을 스페이스나무 갤러리 오로라에서 만나볼 수 있습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17062,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/01/moment-15.jpg" alt="" class="wp-image-17062" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>스페이스나무 갤러리 오로라<br>경상남도 양산시 하북면 충렬로 1733 스페이스 나무<br>055-374-3500</p>
<!-- /wp:paragraph -->', place = '갤러리오로라' WHERE provider_type = 'PUBLIC' AND external_id = '366958';
UPDATE festival SET title = '조용한 시선들', content = '<!-- wp:paragraph -->
<p>갤러리 오로라 “2026년 신진작가 선정 특별전 – 조용한 시선들”</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2026.01.28. - 2.23</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17025,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/01/clam-gazes_image-01-1.jpg" alt="" class="wp-image-17025" /></figure>
<!-- /wp:image -->

<!-- wp:quote -->
<blockquote class="wp-block-quote"><!-- wp:paragraph -->
<p>“ 강미혜, 김혜진, 이수연, 이플, 최신희 ”</p>
<!-- /wp:paragraph --><cite>참여작가</cite></blockquote>
<!-- /wp:quote -->

<!-- wp:image {"id":17026,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/01/clam-gazes_image-02.jpg" alt="" class="wp-image-17026" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>스페이스나무 갤러리 오로라(Gallery Aurora)는 오는 2026년을 맞아 “2026년 신진작가 선정 특별전”을 통해 독창적인 시각과 감각을 지닌 신진 작가 다섯 명을 선정했습니다. 이번 전시는 젊은 작가들이 각자의 언어와 개성 있는 방식으로 풀어낸 작품들을 소개합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가는 저마다 자신의 고유한 세계를 가지고 있습니다. 그 세계는 단번에 드러나지 않습니다. 꾸준한 관찰 속에서 천천히 형성된 그 세계는 우리가 익숙하게 인식한 현실과 다릅니다. 작가는 작품을 통해 그들이 보아온 세계를 이야기합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17027,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/01/clam-gazes_image-03.jpg" alt="" class="wp-image-17027" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>작가들은 풀잎, 해파리와 같은 작고 미세한 존재부터 우주와 꿈 같은 비현실적인 세상 그리고 욕망, 기억 등 자신들의 내면을 들여다봅니다. 그 속에서 포착된 인상과 사유는 보는 이로 하여금 새롭고 낯선 감각을 불러일으킵니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이 전시에서 ''조용함''은 단순히 정적이나 침묵을 의미하지 않습니다. 쉽게 지나쳐버릴 수 있는 장면을 붙잡아두고 알 수 없는 세계를 조우하고 있는 상태를 뜻합니다. 때문에 강미혜, 김혜진, 이수연, 이플, 최신희 다섯 작가의 작업은 관람자에게 즉각적인 해석을 요구하지 않습니다. 작품 앞에 머무른 관람자는 작가의 시선을 통해 본 세계를 경험하게 됩니다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17028,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/01/clam-gazes_image-04-rotated.jpg" alt="" class="wp-image-17028" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>스페이스나무 갤러리 오로라는 <조용한 시선들>을 통해 신진 예술가들의 창의적 잠재력을 발굴하고, 그들의 작품을 가진 예술적 메시지를 널리 알리고자 합니다. 그들이 가진 독창적인 시각을 대중에게 선보이는 중요한 무대가 될 것입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:separator -->
<hr class="wp-block-separator has-alpha-channel-opacity" />
<!-- /wp:separator -->

<!-- wp:buttons -->
<div class="wp-block-buttons"><!-- wp:button /--></div>
<!-- /wp:buttons -->

<!-- wp:paragraph -->
<p>스페이스나무 갤러리 오로라</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>경남 양산시 하북면 충렬로 1733</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>055) 374 3500</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '갤러리오로라' WHERE provider_type = 'PUBLIC' AND external_id = '366959';
UPDATE festival SET title = '잠들지않는 형상들 존재는 어떻게 기념되는가', content = '<!-- wp:image {"id":17419,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/02/M.jpg" alt="" class="wp-image-17419" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>스페이스나무 갤러리 오로라가 기획한 이번 박성열 초대전은 ‘존재는 어떻게 기념되는가’라는 질문에서 출발한다. 작가는 형상을 통해 기억을 다룬다. 그것은 굳어버린 과거의 기록이 아니며 지금도 호흡하며 살아 움직인다. 화면 위에 등장하는 거대한 얼굴과 동물, 그리고 기념비적 구조물들은 침묵 속에 서 있으면서도 관객을 응시하며 질문을 던진다. 이 전시는 ‘기념’의 방식과 ‘존재’의 의미를 다시 생각하는 자리다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시에서 선보이는 형상들은 완결된 기념비가 아니다. 전통적 기념비가 영웅과 승리를 돌과 금속으로 고정해 시간을 멈추는 장치였다면, 박성열의 형상은 균열과 침식, 이동의 상태를 내포한다. 단단해 보이는 얼굴은 어딘가 부서져 있고, 상징적 인물들은 중심을 장악하지 못한 채 불안정하게 놓여 있다. 그것은 승리의 표정이라기보다 시간의 무게를 견뎌온 얼굴에 가깝다. 작가는 확고한 선언 대신 흔들리는 상태를, 단적인 메시지 대신 질문을 선택한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:gallery {"linkTo":"none"} -->
<figure class="wp-block-gallery has-nested-images columns-default is-cropped"><!-- wp:image {"id":17430,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/02/KakaoTalk_20260226_114545039.jpg" alt="" class="wp-image-17430" /></figure>
<!-- /wp:image --></figure>
<!-- /wp:gallery -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><br>말, 늑대, 고릴라, 사자 등 동물의 형상 또한 주요한 모티프다. 이들은 인간 이전의 시간과 본능, 생명의 원형을 상징한다. 인간의 얼굴이 역사와 문명을 대변한다면, 동물은 생명 그 자체에 가까운 존재다. 두 세계가 한 화면 안에서 중첩될 때, 존재는 하나의 의미로 고정되지 않고 다층적으로 진동한다. 문명과 본능, 이상과 현실 사이의 긴장이 회화적 공간 안에서 팽팽히 교차한다.</p>
<!-- /wp:paragraph -->

<!-- wp:gallery {"linkTo":"none"} -->
<figure class="wp-block-gallery has-nested-images columns-default is-cropped"><!-- wp:image {"id":17431,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/02/KakaoTalk_20260226_114545039_04.jpg" alt="" class="wp-image-17431" /></figure>
<!-- /wp:image --></figure>
<!-- /wp:gallery -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><br>박성열의 화면은 두터운 마티에르가 특징적이다. 그는 물감을 쌓고, 긁고, 다시 덧입히는 과정을 반복하며 화면을 조각처럼 밀어 올린다. 이 물성은 단순한 질감을 넘어 시간의 퇴적을 드러낸다. 매끈하게 정리된 표면 대신 남겨진 흔적들은 ‘완성’이 아니라 ‘과정’을 증언한다. 형상은 굳어 있으면서도 살아 있고, 멈춰 있으면서도 움직이는 상태로 존재한다.<br>작가는 특정한 메시지를 전달하기보다 관객 각자의 기억을 환기하는 공간을 제안한다. 거대한 얼굴과 마주하는 순간, 혹은 정면으로 다가오는 동물의 시선을 받는 순간, 우리는 스스로에게 묻게 된다. 무엇이 기억으로 남는가. 무엇이 기념될 가치가 있는가. 그리고 우리는 어떤 형상으로 남게 될 것인가.<br>스페이스나무 갤러리 오로라가 기획한 이번 초대전은 동시대 구상 회화의 확장 가능성을 보여주는 동시에, 기념과 기억, 존재의 의미를 새롭게 사유하는 자리다. 끊임없는 변화와 도전을 거듭해 온 박성열의 치열한 작가정신은 이번 전시를 통해 더욱 선명하게 드러날 것이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>‘존재는 어떻게 기념되는가’라는 물음은 전시의 출발점이며, 관객 각자에게 남겨질 질문이다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17433,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/02/KakaoTalk_20260226_114545039_03.jpg" alt="" class="wp-image-17433" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시명 : 박성열 초대전 <잠들지 않는 형상들, 존재는 어떻게 기념되는가><br>참여작가 : 박성열<br>전시 기간 : 2026. 2. 25 ~ 2026. 3. 23<br>장소 : 스페이스 나무 갤러리 오로라<br>문의: 055-374-3500</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p> </p>
<!-- /wp:paragraph -->', place = '갤러리오로라' WHERE provider_type = 'PUBLIC' AND external_id = '370037';
UPDATE festival SET title = '꿈이 머문 자리, 빛으로 흐르는 순간', content = '<!-- wp:paragraph -->
<p>김진섭 초대전 </p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17753,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/03/poster01.jpg" alt="" class="wp-image-17753" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>김진섭이 여행을 기억하는 방법은 특별하다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그는 스치는 순간을 흘려보내지 않는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>지나간 자리에 붓을 대어,</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>기억을 다시 살아있게 만든다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:gallery {"linkTo":"none"} -->
<figure class="wp-block-gallery has-nested-images columns-default is-cropped"><!-- wp:image {"id":17754,"sizeSlug":"large","linkDestination":"none"} -->
<figure class="wp-block-image size-large"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/KakaoTalk_20260325_143315854_14.jpg" alt="" class="wp-image-17754" /></figure>
<!-- /wp:image --></figure>
<!-- /wp:gallery -->

<!-- wp:paragraph -->
<p>여행은 일상에서 잠시 벗어나 낯선 공간과 감정, 예기치 못한 경험을 선사한다. 김진섭은 그 순간들을 그냥 흘려보내지 않는다. 그는 스치는 풍경과 감정을 화면 위에 붙잡아 두는 방식으로 여행을 기억한다. 여행 속에서 마주한 기억이 꿈과 희망이 되어 삶을 살아가는 힘이 된다는 것, 그것이 그가 그림을 그리는 이유다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작업은 언제나 낯선 곳에 직접 발을 내딛는 것으로 시작된다. 프라하, 뉴욕, 스톡홀름, 런던, 아말피 등 세계 곳곳을 누비며 그 순간을 온몸으로 받아들인다. 빛의 방향, 공기의 질감, 그 자리에서만 느낄 수 있는 감각 하나하나가 작업의 출발점이 된다. 그렇게 몸으로 담아 온 경험은 캔버스 위에서 서서히 형태를 갖춰 간다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17756,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/KakaoTalk_20260325_143315854_04.jpg" alt="" class="wp-image-17756" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>작업은 언제나 낯선 곳에 직접 발을 내딛는 것으로 시작된다. 프라하, 뉴욕, 스톡홀름, 런던, 아말피 등 세계 곳곳을 누비며 그 순간을 온몸으로 받아들인다. 빛의 방향, 공기의 질감, 그 자리에서만 느낄 수 있는 감각 하나하나가 작업의 출발점이 된다. 그렇게 몸으로 담아 온 경험은 캔버스 위에서 서서히 형태를 갖춰 간다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17757,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/KakaoTalk_20260325_143315854_03.jpg" alt="" class="wp-image-17757" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17759,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/KakaoTalk_20260325_143315854.jpg" alt="" class="wp-image-17759" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>그의 작품 앞에 서면 유리창 너머를 바라보는 듯한 느낌이 든다. 이는 특정 장소를 그대로 옮긴 것이 아니다. 아름다운 풍경 앞에서 오래도록 잊히지 않는 순간을 떠올릴 때, 마음속에 자연스럽게 맺히는 그 이미지에 가깝다. 작가는 자신만의 여행을 기록하는 데 그치지 않는다. 그는 그림을 통해 관람자 저마다의 기억을 불러일으키고, 그 이야기를 함께 나누기를 바란다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":17758,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/03/KakaoTalk_20260325_143315854_08.jpg" alt="" class="wp-image-17758" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>이번 전시는 여행의 기억을 매개로 작가와 관람자가 각자의 경험을 나누는 자리다. 그가 머물렀던 순간들은 이 공간 안에서 조용히 다시 흐를 것이다. 스페이스나무 갤러리 오로라에서, 당신만의 여행이 새롭게 시작될지도 모른다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>전시명 : 김진섭 초대전 <꿈이 머문 자리, 빛으로 흐르는 순간><br>참여작가 : 김진섭<br>전시 기간 : 2026. 03. 25. - 2026. 04. 20.<br>장소 : 스페이스 나무 갤러리 오로라<br>문의: 055-374-3500</p>
<!-- /wp:paragraph -->', place = '갤러리오로라' WHERE provider_type = 'PUBLIC' AND external_id = '373508';
UPDATE festival SET title = '통영국제음악제, 베르비에 페스티벌 체임버 오케스트라 with 니콜라스 알트슈태트 & 김유빈', content = '', place = '통영국제음악당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '369966';
UPDATE festival SET title = '통영국제음악제, 재즈 콘서트: 미하엘 볼니 & 에밀 파리지앵', content = '', place = '통영국제음악당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '370098';
UPDATE festival SET title = '통영국제음악제, 루카스 & 아르투르 유센 듀오 리사이틀', content = '', place = '통영국제음악당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '370353';
UPDATE festival SET title = '[김해] 넌버벌 <네네네> 시즌3 Skoj ', content = '', place = '김해문화의전당 누리홀' WHERE provider_type = 'PUBLIC' AND external_id = '374067';
UPDATE festival SET title = '[창원] 모닝콘서트, 더블베이시스트 성민제의 ‘베스트 베이스 콰르텟’ (4월)', content = '', place = '성산아트홀 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '371946';
UPDATE festival SET title = '[창원] 창원시립교향악단 제373회 정기연주회 "2026 교향악축제 프리뷰"', content = '', place = '3.15아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '374750';
UPDATE festival SET title = '[김해] 서울예술단 창작가무극 <나빌레라>', content = '', place = '김해문화의전당 마루홀' WHERE provider_type = 'PUBLIC' AND external_id = '373068';
UPDATE festival SET title = '클레이아크김해미술관 개관 20주년 특별기획전 <주름과 덧댐>', content = '', place = '클레이아크 김해미술관' WHERE provider_type = 'PUBLIC' AND external_id = '376498';
UPDATE festival SET title = '금정클래식위크 3rd. 울림, 듀오 리사이틀: Violin 김서현 & Piano 일리야 라쉬코프스키', content = '', place = '금정문화회관 소공연장(은빛샘홀)' WHERE provider_type = 'PUBLIC' AND external_id = '392151';
UPDATE festival SET title = 'ONE HOUR', content = '', place = 'KT&G 상상마당 라이브홀 [부산] 라이브홀' WHERE provider_type = 'PUBLIC' AND external_id = '399709';
UPDATE festival SET title = '[양양] 국립오페라단 ’푸치니 오페라’ <잔니 스키키>', content = '', place = '양양문화복지회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '395742';
UPDATE festival SET title = '[대전] 대전시립연정국악원 시즌 웨이브 Ⅹ <내일(來日)>', content = '', place = '대전시립연정국악원 큰마당' WHERE provider_type = 'PUBLIC' AND external_id = '395063';
UPDATE festival SET title = '토요명품', content = '전통 국악을 최적의 공간에서 가장 깊이 있고 다채롭게 만날 수 있는 국립국악원의 대표 주말 공연 <토요명품> 한민족의 흥과 신명이 살아 숨 쉬는 노래와 음악, 춤을 비롯해 세계가 인정한 유네스코 등재 무형문화유산까지. 한국인과 외국인 모두 꼭 봐야할 한국의 전통 공연 예술이 매주 토요일, 우면당 무대를 가득 채웁니다. 대한민국 최고의 연주가들이 선사하는 <토요명품>을 통해 국악이 가진 아름다움을 느껴보세요.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '393100';
UPDATE festival SET title = '연극 <최고네>', content = '', place = '광명시민회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '391846';
UPDATE festival SET title = '[수원] 신체극 <월화수목금토일>', content = '', place = '경기상상캠퍼스 M3 공간1986' WHERE provider_type = 'PUBLIC' AND external_id = '392941';
UPDATE festival SET title = '"브람스의 숲 브루흐의 노래" 소사벌챔버오케스트라 정기연주회', content = '', place = '평택아트센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '393167';
UPDATE festival SET title = '2026 국립민속국악원 명창무대 <소리 판> 모보경의 정정렬제 춘향가', content = '', place = '국립민속국악원 예음헌' WHERE provider_type = 'PUBLIC' AND external_id = '394593';
UPDATE festival SET title = '더 씬 2026, 해서웨이 × 잭킹콩 × 산보', content = '', place = '인천문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '391967';
UPDATE festival SET title = '국립남도국악원 토요상설: 국악이 좋다, 국립남도국악원 국악연주단 <국악의 향연>', content = '', place = '국립남도국악원 진악당' WHERE provider_type = 'PUBLIC' AND external_id = '395336';
UPDATE festival SET title = '앙상블 자비에 정기연주회 "Echoes of Norway"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '389501';
UPDATE festival SET title = '김정원과 친구들 20주년 기념콘서트 <로맨틱 아틀리에>', content = '‘김정원과 친구들’이 20주년을 맞아 특별한 무대로 찾아온다. 피아니스트 김정원을 중심으로 이진상(피아노), 임지영(바이올린), 김동현(바이올린), 신경식(비올라), 문태국(첼로) 등 국내 최정상급 연주자들이 함께 선보이는 로맨틱 앙상블 무대.', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '393092';
UPDATE festival SET title = '제4회 코트뮤 KOTMU 정기연주회 가야금병창 콘서트 <Ongo>', content = '', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '394946';
UPDATE festival SET title = '[서울남산국악당] 춤추는 여자들 <당신은 지금 바비레따에 살고 있군요 ver.2>', content = '', place = '남산골한옥마을 서울남산국악당 야외마당' WHERE provider_type = 'PUBLIC' AND external_id = '394712';
UPDATE festival SET title = '2026 인천아트플랫폼 지역연계 프로젝트 <IAP 아트랩> 바니아랜드 《ARTPORT: Goods to Declare》', content = '', place = '인천아트플랫폼' WHERE provider_type = 'PUBLIC' AND external_id = '397954';
UPDATE festival SET title = '2026 신광호 개인전, <21st 殘骸_21번째 잔해> ', content = '', place = '갤러리 제이원 서울' WHERE provider_type = 'PUBLIC' AND external_id = '396771';
UPDATE festival SET title = '기획공연 11시 음악산책 단편선 시리즈Ⅴ ''살로메''', content = '', place = '광주예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '393599';
UPDATE festival SET title = '[화성] 화성시 오케스트라 특별연주회, 콘서트 라운지 Ⅲ: Masterpiece & Classic', content = '', place = '모두누림센터' WHERE provider_type = 'PUBLIC' AND external_id = '393912';
UPDATE festival SET title = '동대문문화재단 「브런치 콘서트 아트리움 "국립국악관현악단 청년교육단원"」', content = '', place = '선농단역사문화관' WHERE provider_type = 'PUBLIC' AND external_id = '389673';
UPDATE festival SET title = '기하학적 공생 : 연결', content = '<!-- wp:paragraph -->
<p>서현규의 작업은 볼트, 너트, 스테인리스 스틸 미러와 같은 차가운 산업용 소재들이 얽히고설켜 창조해낸 ‘인공의 생태계’를 향합니다. 작가는 기계적 부품의 반복적인 결합을 통해 무기질의 금속을 마치 살아 숨 쉬는 유기체와 같은 나무의 형상으로 변모시킵니다. 이번 전시 <기하학적 공생 : 연결>은 현대 사회의 복잡하게 얽힌 관계망과 기술적 시스템 속에서 탄생한 새로운 생명성에 대해 철학적 질문을 던집니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20231,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/09/제목-없음-4.jpg" alt="" class="wp-image-20231" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가의 작업에서 ‘연결’은 가장 근본적인 조형 원리이자 은유입니다. 수많은 패스너와 와이어로 구성된 프레임워크는 개별 부품들이 상호 의존하여 거대한 전체를 이루는 현대적 관계의 단면을 투영합니다. 관람객의 움직임을 끊임없이 반사하는 미러 표면과 이를 잇는 전선들은 작품 내부의 에너지 순환을 상징하며, 실재와 환영의 경계를 허무는 역동적인 네트워크를 형성합니다. 이로써 작품은 관람객과 함께 호흡하는 하나의 살아있는 공간이 됩니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20232,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/09/제목-없음-2.jpg" alt="" class="wp-image-20232" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이러한 조각적 탐구는 전시장 벽면에 걸린 페인팅 작업을 통해 감정적 울림으로 깊숙이 확장됩니다. Sensitivity 연작이나 <Don''t Cry>, <위로>와 같은 작품들은 조각이 가진 기하학적 구조 이면에 숨겨진 인간의 얼굴과 눈물, 소통의 갈증을 날것 그대로 드러냅니다. 조각이 차가운 금속과 디지털 매체를 통해 구조적 생명력을 이야기한다면, 회화는 그 구조 속 인간의 응시와 내면의 파편을 통해 관계의 취약성과 치유의 가능성을 시각화합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20233,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/09/제목-없음-6.jpg" alt="" class="wp-image-20233" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시를 통해 서현규는 기술적 인프라가 인간의 삶과 얼마나 긴밀하게 얽혀 있는지를 다시금 성찰하게 합니다. 조각의 기하학적 질서와 페인팅의 심리적 파노라마는 서로 다른 매체를 통해 동일한 주제로 수렴하며, 기계와 인간, 물질과 감정이 교차하는 공생의 풍경을 완성합니다. 이번 전시는 다가올 미래의 관계와 생태계에 대한 작가만의 독창적인 시적 언어를 관람객들에게 전할 것입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20234,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/09/제목-없음-10.jpg" alt="" class="wp-image-20234" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>"Geometric Symbiosis : Connection" </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Seo, Hyeon-Gyu </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>September 9 – October 14, 2026 | Gallery Dasun, Korea </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">Seo Hyeon Gyu’s work moves toward an "artificial ecosystem" created by the entanglement of cold industrial materials—bolts, nuts, and stainless steel mirrors. Through the repetitive assembly of mechanical components, the artist transforms inorganic metal into tree-like structures that appear to breathe like living organisms. This exhibition, Geometric Symbiosis : Connection, poses philosophical questions about the new forms of vitality emerging within the complex networks and technological systems of contemporary society. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">In Seo’s practice, "connection" serves as both the fundamental sculptural principle and a core metaphor. The frameworks, composed of countless fasteners and wires, project a cross-section of modern relationships where individual components exist independently yet rely on one another to constitute a larger whole. This structural assembly is not a fixed form, but functions as a dynamic network that continuously reflects the movements of viewers and the surrounding environment. The space and figures mirrored on the surfaces become part of the work, creating a landscape of "geometric symbiosis" that dissolves the boundaries between reality and illusion. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">This sculptural investigation extends into a deeper emotional resonance through the paintings displayed on the gallery walls. As suggested by the Sensitivity series or works such as Don''t Cry and Consolation, the rough, honest brushstrokes and vivid color fields on canvas expose the raw, sensitive nerve endings of the human psyche and the thirst for communication. While the sculptures speak of structural vitality through the circulatory systems of cold metal and "digital fruits," the paintings visualize the vulnerability of relationships and the possibilities for healing through the human faces, tears, and mutual gazes hidden behind those structures. </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph {"align":"left"} -->
<p class="has-text-align-left">Through this exhibition, Seo Hyeon Gyu invites reflection on how deeply technological infrastructure is interwoven with human life. The geometric order of the sculptures and the psychological panorama of the paintings converge toward the same theme through different media. In this space where machine and human, analog and digital, and cold materiality and warm emotion intersect, the two realms mirror and collide with each other to complete a true "symbiosis." This exhibition offers a unique poetic language on the future of relationships and ecosystems, drawing the viewer into the artist’s vision.</p>
<!-- /wp:paragraph -->', place = '갤러리 다선' WHERE provider_type = 'PUBLIC' AND external_id = '397952';
UPDATE festival SET title = '춘천고음악시리즈 6 <오페라 콘체르탄테 ''요정여왕''>', content = '바로크 음악의 거장 헨리 퍼셀의 ''요정 여왕'', 음악과 이야기가 어우러지는 환상적인 바로크의 세계를 만나는 단 한번의 무대.', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '393093';
UPDATE festival SET title = '국립창극단 <창극콘서트-흥보, 박을 타다>', content = '창극을 처음 만나는 관객도 부담없이 즐기는 ''흥보가''', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392778';
UPDATE festival SET title = '어린이 가족 뮤지컬 <나는 반딧불>', content = '', place = '예림당아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393442';
UPDATE festival SET title = '자연의 울림, 빛의 결', content = '<!-- wp:paragraph -->
<p>김일권 회화의 중요한 특징인 수평적으로 펼쳐진 구도는 관객으로 하여금 시, 공간에 걸쳐서 화면을 바라보게 만든다. 이에 김일권의 회화를 영화의 스크린에 비교하고자 한다. 매우 단순하고 절제된 색면으로 이뤄진 회화는 영화의 화면처럼 캔버스를 넘어서서 새로운 경험의 창(窓)을 연다. 하늘과 땅을, 하늘과 바다를 가르는 수평선이나 지평선은 옆으로 끝없이 펼쳐지는 광경을 암시한다. 멀리서 아지랑이와 같이 수면 위를 올라오는 자연의 풍경이나 땅의 지축을 멀리서 바라본 풍경은 화면 안에 담길 수 없는 무한대를 의미한다. 영화의 스크린처럼 김일권의 회화는 화면 안에 포함된 부분만큼이나 보여지지 않는 화면 밖의 프레임을 넘어선 세계를 포용한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>회화를 특정 프레임을 넘어선 펼쳐진 세상으로 인식하는 관점은 서양 미학의 오래된 전통이기도 하다. 고대 그리스 신화의 제욱시스 (Zeuxis)와 파라시우스(Parrhasius)의 일화는 기술적인 측면에서 서구 회화가 내세워온 사실주의 전통을 상기시킨다.2) 나아가서 커텐 이미지의 아티스트리(Artistry)가 너무 탁월해서 그림을 보기 위하여 제육시스가 커텐을 걷히는 대목은 서구의 회화가 결국 화면 밖, 커텐 너머의 펼쳐진 세상을 프레임하기 위한 수단이라는 사실을 보여준다. 서구 회화가 화면에 담고자 했던 것은 물체가 아닌 2차원의 평면을 넘어선 바깥 세상에 해당한다. 커텐 너머의 세상 말이다. 관객이 영화를 감상하기 위해서 카메라가 보여주는 프레임 바깥 세상을 계속 상상해야 하듯이 말이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>김일권 회화의 수평적인 구도 덕택에 관객은 캔버스의 프레임을 극복하고, 화면 바깥을 상상하게 된다. 특히 영화 속 공간으로부터 점차로 주인공을 따라 관객이 물리적, 상징적 공간을 넓혀가듯이. 김일권의 수평선 구도는 관객의 눈과 마음을 천천히 확장시킨다. 특정 시점이 아니라 시간을 두고 수평선을 따라 걸어가면서 말이다. 관람객의 눈은 화면 위를 ‘순례자’와 같이 배회하게 된다. 마음을 비우고 가장 진솔한 형태로 자연과 마주하게 되는 순례자처럼 그의 그림이 지닌 매우 단순한 수평구도는 회화를 화면 내부에서 화면 외부로, 시간을 두고 감상하게 만든다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>여기서 작가에게 시간성은 다양한 차원을 연관된다. 일차적으로 수평선은 작가가 순천만의 자연을 멀리서 바라보았을 때의 시점을 의미한다. 작가는 작업의 제목을 자신이 풍경을 바라본 물리적인 시간에 따라 부친다. 연도와 날짜 순서에 따라 제목이 부쳐지는데 흡사 1960년대 온카와라(On Kawara)와 같은 행위예술가들이 작업을 일기와 같이 일상을 기록하는 수단으로 사용하였듯이 순천만을 대하는 자신의 ‘과거-(거기 있었음)’ 시점이 제목이자 일차적인 시간적 배경이 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>수평선을 통해서 작가가 암시하고 있는 두 번째 시간성은 영원하고 보편적인 시간성이다. 원래 수평선은 시간의 영원한 흐름을 상징하여왔다. 종교화에서 초월적인 시간성을 의미하는 십자가 사건이 주로 수직적으로 표현되는 것에 반하여 수평적인 구도는 연속성을 의미한다. 작가는 수평선을 전체 화면에서 황금비율에 따라 정한다. 이때 수평선은 보평적인 조형 요소로서 의미를 지닌다. 연장선상에서 시간성은 더 이상 특정 장소와 작가의 관점을 넘어선 영원하고 영속적인 의미를 지닌다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20747,"width":262,"height":279,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full is-resized"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/10/image.jpeg" alt="" class="wp-image-20747" width="262" height="279" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>2025.06.09_163 X 132 X 3cm oil on linen</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>마지막으로 관객의 시점에서 시간성을 생각해 볼 수 있다. 그의 회화에서 수평선은 전체 화면에서 작품마다 위치를 달리한다. 수평선이 가늘게 그려진 경우 멀리서 바라본 풍경을, 수평선이 넓고 굵게 펼쳐져서 아래쪽에 그어진 경우 작가나 관객이 자연 풍경 속에 거의 들어가 있는 상태를 연상시킨다. 흥미로운 점은 수평선의 위치에 따라 관객은 회화 속 풍경과 다른 위치에 놓이게 된다. 그의 미디어 작업을 통해서 더 잘 드러나는 바와 같이 시점의 변화는 작가나 관객의 입장에서 자연과 자신의 신체적 관계에 따른 가변적인 시, 공간성을 암시하고 있다. 자연을 거니는 순례자가 다양한 시, 공간의 접점에서 자연을 관찰하고 자연 속에서 거닐 듯이 말이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>따라서 김일권의 회화는 공간의 무한한 확장성과 함께 관객이 가변적인 시간성을 경험하게 만든다. 수평선의 다양한 위치에 따라 관객은 여러 시, 공간에 걸쳐서 자신의 신체와 자연 풍경과의 관계를 설정하게 된다. 덧붙여서 불명확하게 그어진 수평선은 하늘과 물이 만나는 순간을 암시하는데 밑 색과 덧칠한 색이 만나면서 자연스럽게 화면의 표면 위에 떨림을 만들어낸다. 특히 하늘과 물의 경계를 가르는 수평선은 배경의 풍경과 만나면서 서로를 덮고 감싸고 지우면서 미묘한 자연의 떨림을 표현한다. 그리고 그 떨림을 시시각각으로 감지하려는 관객에게 비로소 수평선은 자신을 드러내게 된다. </p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20749,"width":251,"height":307,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full is-resized"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/10/image-2.jpeg" alt="" class="wp-image-20749" width="251" height="307" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>2024.12.17_61 X 73cm, Linen and acrylic on canvas           </p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20751,"width":260,"height":312,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full is-resized"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/10/image-4.jpeg" alt="" class="wp-image-20751" width="260" height="312" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>2025.03.07_61 X 73cm, Linen and acrylic on canvas           </p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>갤러리위 수지ㅣ031-266-3266</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>경기도 용인시 수지구 호수로 52번길 25-17</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>쾌적한 관람을 위해 예약(전화, 네이버) 후 방문 가능합니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>OPENING HOURS l TUE-SAT 10AM-6:30PM</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>DAY OFF l SUN-MON</p>
<!-- /wp:paragraph -->', place = '갤러리위' WHERE provider_type = 'PUBLIC' AND external_id = '402978';
UPDATE festival SET title = '한국예술종합학교 수요영화관 <힌드의 목소리>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396778';
UPDATE festival SET title = '2026 성북문화예술교육센터 <오늘도 예술로> 가을 시즌 프로그램 참여자 모집', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394890';
UPDATE festival SET title = '수요일마다 출근하는 문화기획사, <수요기획> 신입 기획자 모집!', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '393309';
UPDATE festival SET title = '나혜수 클라리넷 독주회 "Music in color"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '391888';
UPDATE festival SET title = '그럼에도 불구하고', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '395356';
UPDATE festival SET title = '중구민을 위한 무료 영화 상영 프로그램 <목요일N씨네마> 9월', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394790';
UPDATE festival SET title = '제14회 서울국제어린이영화제 14th Seoul Int''l Children''s Film Festival', content = '', place = '롯데시네마 은평, 은평문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '391526';
UPDATE festival SET title = '[마포문화재단] 별★걸 다 파는 마포 주민 아트 마켓 <2026 궁금한 시장> 참여 셀러 모집', content = '', place = '마포아트센터 앞 광장' WHERE provider_type = 'PUBLIC' AND external_id = '398013';
UPDATE festival SET title = 'ASAC 판소리 동화 콘서트 <자라는 자라>', content = '판소리 동화 콘서트 <자라는 자라>는 판소리 다섯 바탕 중〈수궁가〉를 어린이와 가족의 눈높이에 맞게 재해석한 공연으로, 용왕의 병을 고치기 위해 토끼를 찾아 나서는 자라의 모험을 통해 판소리의 흥겨움과 우리 전통문화의 매력을 쉽고 재미있게 전한다.', place = '안산문화예술의전당 달맞이극장' WHERE provider_type = 'PUBLIC' AND external_id = '392950';
UPDATE festival SET title = 'A Place We Have Never Been', content = '<!-- wp:paragraph -->
<p>히든엠갤러리는 오는 9월 10일부터 10월 2일까지 이지선 작가의 <A Place We Have Never Been>을 개최한다. 이번 전시는 유년기의 기억과 상상에서 출발해 작가의 내면에 형성된 하나의 세계를 선보입니다. 기억과 경험, 상상이 중첩된 풍경을 통해 현실과 비현실의 경계를 오가며, 성장과 시간의 흐름 속에서 변화하는 내면의 모습을 담아낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이지선 작가는 유년기의 기억과 상상, 시간이 지나며 내면에 남겨진 감각과 풍경을 다시 바라보는 일에서 출발한다. 어린 시절 자연과 가까이 지내며 바라보았던 집 주변의 풍경, 익숙했던 방의 벽지무늬, 즐겨보던 동화책과 삽화, 종이인형놀이와 친구와 함께했던 아지트의 기억은 시간이 지나면서 하나의 내면의 풍경으로 남겨졌다. 당시에는 그저 익숙한 일상의 일부였던 장면들은 시간이 흐른 뒤 서로 다른 기억과 상상 속 이미지들이 서로 스며들면서 새로운 세계를 이루게 된다. 실제로 경험했던 풍경과 책 속에서 마주했던 이미지, 혼자 만들어낸 이야기와 그때의 감정이 뒤섞이며 작가만의 내면의 숲이 형성된 것이다. 작가에게 유년기는 단순히 지나간 시간의 한 부분이 아니다. 사회의 기준과 타인의 시선, 스스로를 규정하고 검열하는 의식이 자리하기 이전의 시간에는 무엇이 현실이고 무엇이 상상인지 구분하지 않아도 되는 자유가 있었다. 마음이 가는 대로 이야기를 만들고, 익숙한 공간에 새로운 세계를 덧입히며, 존재하지 않는 인물과도 친구가 될 수 있었던 시절의 감각은 오랜 시간이 지난 후에도 내면 깊숙한 곳에 남아 있다. 작가는 그곳에 남겨진 자유롭고 천진한 감각을 다시 바라본다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>그렇게 형성된 ‘내면의 숲’은 작가에게 무의식의 깊은 곳으로 들어가는 통로이자 유년의 천진함이 머무는 마음속 낙원이다. 숲은 익숙한 자연의 풍경에서 시작하지만 현실의 풍경에 머물지 않는다. 깊은 숲으로 들어갈수록 오래된 기억과 상상 속 인물들이 모습을 드러내고, 동화나 삽화 속에서 걸어 나온 듯한 존재들이 그곳을 자유롭게 오간다. 그들은 함께 놀이를 하거나 자신들만의 비밀스러운 의식을 이어가며, 때로는 작가의 내면을 수호하는 존재처럼 숲의 세계를 지킨다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이러한 존재들과 풍경이 자리한 캔버스는 하나의 내면의 공간이 된다. 기억과 경험, 상상이 현재의 자신과 만나 서로 얽히는 장소이자, 현실에서는 이어지지 않는 시간과 장면들이 한 화면 안에서 만나는 곳이다. 작가의 회화는 특정한 장소를 재현하기보다 기억이 작가의 현재를 통과하며 만들어낸 풍경을 보여준다. 익숙한 자연과 낯선 이미지가 함께 놓이고, 현실적인 장면과 비현실적인 존재가 자연스럽게 공존하면서 화면은 현실과 상상의 경계에 놓인다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이전 작업에서 작가는 이러한 숲을 향해 들어가는 사람으로서 자신의 내면을 탐색해왔다. 그리고 이번 전시에서 작가는 한 걸음 더 나아가 그 세계를 오가는 여행자가 된다. 작가는 내면의 숲으로 들어가 오래된 기억과 마주하고, 그곳에서 기쁨과 그리움, 성장과 상실의 감정을 다시 경험한다. 작가가 만나는 유년기의 세계는 과거에 그대로 남아 있는 세계가 아니라, 현재의 자신에 의해 다시 바라보고 다시 구성되는 세계이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시 <The Place We Have Never Been>은 바로 이러한 기억과 상상의 관계에서 시작된다. 전시 제목이 던지는 질문처럼, 작가는 가본 적 없는 세계를 그리워하는 마음을 바라본다. 우리는 실제로 존재했던 장소만을 그리워하지 않는다. 한때 머물렀던 공간에 대한 기억은 시간이 흐르면서 그곳에서 느꼈던 감정과 상상 속 이미지가 더해져 현실과 다른 모습으로 남는다. 동화책 속 풍경이나 어린 시절 혼자 만들어낸 이야기처럼 실제로 경험하지 않았던 세계 역시 이상할 만큼 선명한 감정으로 기억되기도 한다. 그렇게 실제의 기억과 상상이 서로 스며들어 한 번도 가본 적 없는 세계가 마음속에서는 오래전부터 존재했던 장소처럼 느껴진다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>선보이는 이번 신작 작품 속 곳곳에 레몬이 등장한다. 작가는 레몬의 신맛에서 떠오르는 순간적인 감각에 주목한다. 입안에 퍼지는 레몬의 신맛이 문득 지나간 시간을 떠올리게 하듯, 어떤 기억은 예고 없이 떠오르고 지나간 시간의 감정을 현재로 불러온다. 과거와 현재가 한순간 뒤섞이는 그 감각은 작가가 이번 작업에서 바라보는 시간의 모습과 닿아 있다. 그것이 오래된 기억이나 무엇을 의미하는지 명확하게 규정하기보다, 작가는 레몬을 자신의 내면의 세계에 남겨두고 다시 현재로 돌아온다. 그렇게 레몬은 작품 속에서 하나의 장면으로 자리하며, 기억과 상상이 만들어낸 세계에 또 다른 감각을 더한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시에서 30여점의 신작을 통해 이러한 변화와 확장을 보여준다. 작가는 익숙한 풍경과 기억 속 이미지들을 다시 불러내면서 이전보다 더욱 깊어진 색감과 풍부한 화면을 통해 내면의 세계를 확장한다. 화면 속 숲과 풍경, 인물과 사물은 각각 하나의 장면을 이루지만 동시에 서로 이어지며 하나의 세계를 구성한다. 작품과 작품 사이를 오가다 보면 개별적인 기억의 장면들은 어느 순간 하나의 긴 이야기처럼 연결되고, 관객은 그 세계의 여러 순간을 함께 마주하게 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이지선 작가에게 풍경은 고정되어 있지 않다. 익숙한 자연은 기억을 통과하며 다른 모습이 되고, 현실의 공간은 상상에 의해 낯선 장소로 변한다. 어린 시절 보았던 것과 지금 바라보는 것이 한 화면 안에서 만나면서, 과거와 현재는 서로의 경계를 흐린다. 따라서 작가가 그리는 세계는 과거의 재현도, 순수한 환상의 세계도 아니다. 그것은 기억과 상상이 현재의 자신과 만나며 만들어낸 새로운 풍경이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>또한 이번 전시에서 작가는 처음으로 설치작업을 통해 화면 밖으로 확장된다. 작가가 처음 시도하는 설치작업은 새로운 형식을 더하는 데 그치지 않는다. 오랫동안 회화 안에서 구축해온 ‘내면의 숲’을 실제 공간으로 옮겨오면서, 작가가 상상해온 세계의 경계를 넓히는 시도이다. 캔버스 안에서 바라보던 풍경은 이제 하나의 공간을 이루고, 회화와 설치는 서로 관계를 맺으며 보다 입체적인 장면을 만들어낸다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이러한 확장은 ‘내면의 숲’이 더 이상 과거의 기억에 머무르지 않는다는 것을 보여준다. 숲은 기억을 보관하는 장소가 아니라, 현재의 자신과 기억이 함께 쌓여 만들어가는 낙원이다. 시간이 흐를수록 새로운 기억이 더해지고, 과거의 장면은 현재의 시선에 의해 다시 해석된다. 그렇게 숲은 계속해서 모습을 바꾸며 살아 있는 세계로 남는다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>작가에게 내면의 숲은 과거의 기억에 머무는 곳이 아니라, 현재의 자신과 기억이 함께 쌓여가는 낙원이다. 어쩌면 가본 적 없는 세계를 그리워한다는 것은 존재하지 않았던 장소를 향한 그리움이 아닐지도 모른다. 실제로 있었던 기억과 상상 속에서만 존재했던 장면들이 뒤섞여 만들어낸 세계, 그 안에서 한때 자유롭게 상상하고 놀았던 자신, 그리고 시간이 흐른 뒤에도 여전히 마음 한편에 남아 있는 어떤 감각을 그리워하는 것일지도 모른다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이지선 작가가 만들어낸 내면의 숲은 기억과 상상, 과거와 현재가 만나 새로운 풍경을 이루는 곳이다. 그곳을 따라가다 보면 잊고 있던 어린 시절의 감각과 마음의 한 조각을 마주하게 될지도 모른다. 가본 적 없는 세계를 그리워하는 마음이 결국 자신 안에 오래 머물러온 세계를 다시 바라보는 일이듯, 이번 전시가 각자의 기억과 상상을 천천히 들여다보는 시간이 되기를 바란다.</p>
<!-- /wp:paragraph -->', place = '히든엠갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '398149';
UPDATE festival SET title = '[무안] 연극 <염쟁이 유씨>', content = '', place = '무안승달문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '397961';
UPDATE festival SET title = '우리신화이야기 <이야기장수와 도깨비>', content = '', place = '종로아이들극장' WHERE provider_type = 'PUBLIC' AND external_id = '393284';
UPDATE festival SET title = '[전주] 아퀴×아트룸 ''사계(四季)''', content = '', place = '서학예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '396969';
UPDATE festival SET title = '춘천 실내악 페스티벌, 해금 이시연 & 이유주 <우리 가락 이야기>', content = '', place = '예나아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '396809';
UPDATE festival SET title = '[마포문화재단] 제11회 M 클래식 축제 <백건우 피아노 리사이틀>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '388199';
UPDATE festival SET title = '2026 경기상상캠퍼스 개관 10주년 프로젝트 <샘 스쿨 SAM School>', content = '', place = '경기상상캠퍼스 공간1986' WHERE provider_type = 'PUBLIC' AND external_id = '397504';
UPDATE festival SET title = '제79회 미술동인 혁展 - Beyond the frame ·· (경계를 넘어··)', content = '<!-- wp:paragraph -->
<p>제 79회 미술동인 혁 展<br>Beyond the frame ·· (경계를 넘어··)<br>2026. 9. 11 - 9.30</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20260,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/09/KakaoTalk_20260912_132502385_08.jpg" alt="" class="wp-image-20260" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":20261,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/09/KakaoTalk_20260912_132502385_02.jpg" alt="" class="wp-image-20261" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":20262,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/09/KakaoTalk_20260912_132502385_03.jpg" alt="" class="wp-image-20262" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>1963년 부산에서 창립해 올해 64주년을 맞은 미술동인 혁은 한국 현대미술의 실험정신을 이끌어온 최장수 동인이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>창조적 자유의지를 기본으로 현실에 안주하지 않고 새로운 변화를 추구해 온 혁은 어떠한 사조나 사상, 관념도 창조를 통해 넘어서는 힘을 보여주며 한국 미술사에 독특한 위상을 차지해 왔다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 제79회 정기전의 주제는 ‘Beyond the frame (경계를 넘어)’이다. 우리는 살아가면서 현실과 이상, 자아와 타인, 과거와 미래와 같은 수많은 경계와 마주하게 된다. 그러나 예술은 언제나 이러한 틀을 넘어 새로운 시각을 제시하고, 서로 다른 생각과 감정을 연결해 주는 힘을 지니고 있다. 이번 전시에 참여한 작가들은 각자의 개성과 예술적 철학을 바탕으로 서로 다른 방식으로 예술적 소통을 실천하고 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>미술동인 혁 회원들은 각자의 독창성을 표현하면서도, 언제나 틀을 벗어나 새로운 미래를 그리려 한다. 그들이 보여주는 다양성에서 우리는 현대미술이 지닌 자유로움과 확장 가능성, 그리고 새로운 희망의 단초를 발견하게 될 것이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>미술동인 혁의 79번째 정기전이 단순한 감상의 자리를 넘어, 우리 스스로의 고정관념과 한계를 성찰하고 새로운 영감을 얻는 계기가 되기를 바란다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>참여작가<br>강귀화, 강선보, 금 경, 김남주, 김미화, 김정희, 김주희, 띠그란아코피얀, 박수진, 박순연, 박태홍, 석점덕 , 유순천, 유진재, 윤미희, 이명호, 이상희, 이승현, 이연희, 이주영, 조연승, 지경희, 최영아, 최예원, 최창임, 하훈수, 허종하</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>부산광역시 해운대구 달맞이길 65번길 56(중동) CK빌딩 1F.갤러리조이</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Tel:051.746.5030 Homepage:http://www.galleryjoy.com</p>
<!-- /wp:paragraph -->

<!-- wp:embed {"url":"https://youtu.be/E-98xNilNn0?si=V8Dn45GCfRIami81","type":"video","providerNameSlug":"youtube","responsive":true,"className":"wp-embed-aspect-16-9 wp-has-aspect-ratio"} -->
<figure class="wp-block-embed is-type-video is-provider-youtube wp-block-embed-youtube wp-embed-aspect-16-9 wp-has-aspect-ratio"><div class="wp-block-embed__wrapper">
https://youtu.be/E-98xNilNn0?si=V8Dn45GCfRIami81
</div></figure>
<!-- /wp:embed -->', place = '갤러리 조이' WHERE provider_type = 'PUBLIC' AND external_id = '398194';
UPDATE festival SET title = '전남광주통합특별시립합창단 기획연주회 Ⅴ. 합창뮤지컬 맘마미아: Dona’s Diary', content = '', place = '광주예술의전당 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '393946';
UPDATE festival SET title = '[전주] 2026 전북예술회관 어린이극장 <점프 JUMP> ', content = '', place = '전북예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '393702';
UPDATE festival SET title = '제2회 김한백 소금 독주회 <소금창고 프로젝트 Ⅱ >', content = '', place = 'JCC 아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '391347';
UPDATE festival SET title = '[마포문화재단] 제11회 M 클래식 축제 <발렌티나 이고시나 피아노 리사이틀>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '388267';
UPDATE festival SET title = '상하이 경극원 <지단 왕자의 복수>', content = '2026 창극 중심 세계음악극축제 해외초청작. 국제적 호평을 받은 상하이 경극원의 대표작, 셰익스피어 고전 햄릿의 재탄생', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392782';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 <탭 쇼>', content = '', place = '국립극장 무대예술지원센터' WHERE provider_type = 'PUBLIC' AND external_id = '394758';
UPDATE festival SET title = '[성남] 판타지 가족무용극 <어린 왕자> ', content = '', place = '성남아트리움' WHERE provider_type = 'PUBLIC' AND external_id = '395152';
UPDATE festival SET title = '《 InnerSpace#26 》', content = '<!-- wp:paragraph -->
<p> 필 갤러리는 오는 9월 12일부터 10월 24일까지 김정한 작가의 개인전 《InnerSpace#26》을 개최한다. 빠른 이미지 소비와 AI의 등장으로 생성과 소멸의 가속화가 이어지는 동시대 속에서, 이번 전시는 전통적 미디어로서 회화가 지닌 의미와 가능성을 다시금 확장하고자 기획되었다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>김정한 작가는 언어적 기호인 ‘문자’를 회화의 한 단위로 삼아, 문자의 구조와 여백, 그리고 이를 거듭 겹치고 덮는 행위를 통해 회화적 공간을 구축한다. 캔버스 위에서 의미를 상실하고 선과 면, 리듬과 밀도로 변모한 문자는 수직의 붓질과 아크릴 과슈의 오목볼록한 마티에르를 만나 깊은 시간의 층(layer)을 이룬다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong> </strong>작가는 오랫동안 ‘채움’과 ‘비움’의 관계를 탐구해 왔다. 캔버스 바탕 위에 문장을 겹쳐 쓰고 네 방향으로 돌려가며 수직 붓질을 반복하는 작업은, 요철의 도드라진 부분에만 색이 얹히고 파인 자리는 비워두는 절제된 행위의 연속이다. 이는 단순한 상징을 의도하기보다 붓질의 반복을 통해 시간의 흔적을 담아내는 일이다. 최근 작업에서는 해체와 재조합을 거쳐 얼굴이나 캐릭터, 기존 회화의 이미지를 다시 끌어들임으로써 문자와 여백, 표면 사이의 새로운 회화적 가능성을 모색하고 있다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>미술평론가 칸바라 마사아키(Masaaki Kambara)는 *"김정한의 작품은 회화라는 전통 미디어가 아직 건재함을 일깨워 준다. 한순간에 사라지지 않는 존재의 중후함을 밑받침하는 그의 그림은 레이어케이크처럼 층층이 쌓여 있다"*고 평가하며, 축적된 레이어가 지닌 존재감을 강조했다. 또한 미술평론가 서명리는 *"서양화에서 여백이 ''안 그린 곳''이라면, 김작가에게 여백은 시작이자 멈춤, 반전이 되는 작품의 중요한 구성 요소"*라며 작가가 다루는 여백의 독창적 의미를 짚었다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong> </strong>작가는 자신의 작업을 "하나의 답을 제시하는 것이 아니라, 그리고, 덮고, 남기고, 비워두는 되풀이를 통해 아직 말이 되지 않은 감각을 바라보는 일"이라고 말하며 그 공간에 ‘InnerSpace’라는 이름을 부여한다. 필 갤러리에서 펼쳐지는 이번 전시를 통해 관람객들이 속도의 시대에서 벗어나 회화가 주는 중후한 물질성과 비워진 여백 속 깊은 감각을 체감하길 기대한다.</p>
<!-- /wp:paragraph -->

<!-- wp:list -->
<ul><!-- wp:list-item -->
<li><strong>전시 제목:</strong> 김정한 개인전 《 InnerSpace#26 》</li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li><strong>전시 기간:</strong> 2026년 9월 12일(토) – 10월 24일(토)</li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li><strong>운영 시간:</strong> 화요일 – 토요일 11:00 – 18:00<br>(일, 월, 공휴일 휴관 / 9월 26일, 10월 3일 정상운영)</li>
<!-- /wp:list-item -->

<!-- wp:list-item -->
<li><strong>전시 장소:</strong> 필 갤러리 제 1 전시실, 제 2 전시실 (서울 용산구 유엔빌리지길 24)</li>
<!-- /wp:list-item --></ul>
<!-- /wp:list -->', place = '필 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '399949';
UPDATE festival SET title = '[서울] 김덕우 & 시명운 바이올린 듀오 리사이틀', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '394001';
UPDATE festival SET title = '2026 브런치 콘서트 <9월: 스크린의 미학, 에드워드 호퍼부터 에드가 드가까지>', content = '명화 해설과 함께 듣는 클래식 공연', place = '용인시평생학습관 큰어울마당' WHERE provider_type = 'PUBLIC' AND external_id = '393211';
UPDATE festival SET title = '[2026 PLOT STAGE] 극단 주의 - 연극 <그립고 아름다운 내 별나라로 갈 수 있...을 걸?!>', content = '', place = '극장 PLOT' WHERE provider_type = 'PUBLIC' AND external_id = '395447';
UPDATE festival SET title = '스미레 미용실', content = '''야끼니꾸 드래곤'' 정의신의 재일 코리안 3부작, 그 마지막 장', place = '세종문화회관 세종M씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '393240';
UPDATE festival SET title = '2026 창작ing 연극 <고쳐서 나가는 곳> 관객과의 대화', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '393111';
UPDATE festival SET title = '2026 원주전통문화교육원 초대전 <지광국사탑비 돌 그림,색실로 피다>', content = '', place = '원주문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '398610';
UPDATE festival SET title = '서울남산국악당 X SIDance <회귀의 궤적>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '394713';
UPDATE festival SET title = '제8회 어텀실내악페스티벌 ‘소리의 결 - Sound in Motion’ - 춤의 얼굴들', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '395223';
UPDATE festival SET title = '서울남산국악당 X SIDance <살아 있는 모든 순간>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '394716';
UPDATE festival SET title = '[대학로] 뮤지컬 <곤 투모로우> 10주년 기념 공연', content = '', place = '홍익대 대학로 아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '393489';
UPDATE festival SET title = 'All Do Art & 이음 전시회', content = '', place = '강원문화재단' WHERE provider_type = 'PUBLIC' AND external_id = '398604';
UPDATE festival SET title = '2026년 하반기 북토크 <책으로 만나는 박물관 전시> : 음식유산으로 보는 한식 인문학', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '395832';
UPDATE festival SET title = '고희동미술관 시니어 교육프로그램 <예술한폭> - 화과자만들기', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396318';
UPDATE festival SET title = '뮤지컬 <진령> 쇼케이스', content = '', place = 'KOCCA콘텐츠문화광장 스테이지66' WHERE provider_type = 'PUBLIC' AND external_id = '396166';
UPDATE festival SET title = '우리 꽃 섬유그림 "화가림 회원전"', content = '', place = '원주한지테마파크' WHERE provider_type = 'PUBLIC' AND external_id = '398608';
UPDATE festival SET title = '강북문화재단-주한중국문화원 특별교류전 <판다만 있는게 아닌 청두-강북에서 만나는 청두의 모든 순간>', content = '', place = '강북문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '392834';
UPDATE festival SET title = '서울남산국악당 X SIDance <무악(巫樂)과 만나는 몸의 자전>', content = '', place = '남산골한옥마을 서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '394715';
UPDATE festival SET title = '정연주 해금 독주회 <Seasons>', content = '', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '394270';
UPDATE festival SET title = '[철원] 천지윤의 ∞무한계절 ', content = '', place = '철원군 화강문화센터 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '397659';
UPDATE festival SET title = '홍은선 음반 발매기념 리사이틀 “Luigi Boccherini Cello Sonatas Ⅰ”', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '392326';
UPDATE festival SET title = '[수원] 2026 살롱 드 아트리움 시즌 Ⅵ(9월), 바실리 칸딘스키 <선율처럼 흐르는 점, 선, 면>', content = '', place = '수원SK아트리움 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '395224';
UPDATE festival SET title = '[천안시립문학관] 책크숍 9월 프로그램 ''차선책茶線冊''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396465';
UPDATE festival SET title = '연극 <리시스트라타 리부트>', content = '', place = '연희예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '393835';
UPDATE festival SET title = '연극 <하녀들>', content = '', place = '나온씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '394759';
UPDATE festival SET title = '청소년 진로·직업 체험프로그램 <미술관에서 만나는 내:일>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396146';
UPDATE festival SET title = '[부산] 매직드로잉 가족극 <두들팝> ', content = '', place = '부산시민회관 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '395300';
UPDATE festival SET title = '대전광역시 서예진흥원 <제14회 해촌묵연전>', content = '', place = '대전광역시 서예진흥원' WHERE provider_type = 'PUBLIC' AND external_id = '397989';
UPDATE festival SET title = '2026년 경운박물관 특별기획전 <아름다운 기증, 소중한 모음Ⅴ>', content = '', place = '경운박물관' WHERE provider_type = 'PUBLIC' AND external_id = '400464';
UPDATE festival SET title = '김란수 개인전 "희망의 공간"', content = '', place = '디크레센도' WHERE provider_type = 'PUBLIC' AND external_id = '398953';
UPDATE festival SET title = '전남광주통합특별시립창극단 <희경루방회도>', content = '2026 창극 중심 세계음악극축제 국내초청작. 광주를 대표하는 문화유산이자 보물 『희경루방회도』가 창극으로 다시 태어나다.', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392783';
UPDATE festival SET title = '모스크바홀 기획공연 시리즈, 이문선 피아노 독주회 ''Franz to Franz''', content = '', place = '모스크바홀' WHERE provider_type = 'PUBLIC' AND external_id = '398570';
UPDATE festival SET title = '피아니스트 최현아의 다이얼로그 시리즈 Vol. 1 – Source & Structure ‘Bach & Beethoven’', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '395607';
UPDATE festival SET title = '제1회 2026 출판 데이터 마케팅 포럼 <데이터로 읽는 출판시장>', content = '', place = '한빛미디어 L60' WHERE provider_type = 'PUBLIC' AND external_id = '397254';
UPDATE festival SET title = '유니버설발레단 <잠자는 숲속의 미녀>', content = '클래식 발레의 웅장함과 완결성을 집약적으로 보여주는 최고의 작품. 19세기 황실 발레의 황금기를 그대로 느낄 수 있는 화려하고 정교한 무대와 환상적인 군무, 고난도 테크닉으로 펼쳐지는 고전발레의 교과서가 펼쳐진다.', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '393094';
UPDATE festival SET title = 'Deconstructed Radios, Broadcasting - Who’s listening? Konnekt, Geneva, CH', content = '', place = '복합문화예술공간MERGE' WHERE provider_type = 'PUBLIC' AND external_id = '396996';
UPDATE festival SET title = 'GRACE', content = '<!-- wp:image {"id":20284,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/09/Gallery-Baton_GRACE_Exhibition-view-1.jpg" alt="" class="wp-image-20284" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>갤러리바톤은 확장 이전한 한남동의 새로운 전시 공간에서 재개관전 《GRACE》를 2026년 9월 18일부터 10월 10일까지 개최한다. 이번 전시는 갤러리 작가들을 중심으로 구성되며, 다양한 주제와 예술적 실천을 아우르는 작품을 통해 바톤이 지향해온 폭넓은 예술적 스펙트럼을 한자리에서 조명한다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20285,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/09/Gallery-Baton_GRACE_Exhibition-view-3.jpg" alt="" class="wp-image-20285" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>두 개의 전시층(G1B, G2B)에서 열리는 전시는 작가들의 대표작과 근작을 통해 서로 다른 예술적 실천이 교차하는 지점을 보여준다. 故전국광의 조각 <매스의 내면>(1987)은 한국 현대조각의 독자적인 조형 언어를 보여준다. 리암 길릭은 구조와 관계에 대한 지속적인 탐구를, 조나단 몽크는 미술의 형식을 재구성하는 개념적 접근을 이어가는 신작을 공개한다. 허달재와 빈우혁은 자연을 회화의 대상으로 삼아 서로 다른 회화적 시선과 기법으로 풍경을 풀어낸다. 한 벽면을 가득채운 리너스 반 데 벨데의 목탄 회화들은 가상과 실제가 교차하는 가운데 독자적인 서사 세계를 펼쳐 보인다. 또한, 이재석과 최민영은 개인의 경험과 상상에서 출발해 고유한 회화적 이미지를 구축한다. 노에미 구달의 영상 〈Below the Deep. South〉(2021)는 열대 숲의 이미지가 불에 의해 소실되는 과정을 보여주며, 지구의 시간과 자연 환경의 변화를 탐구한다.</p>
<!-- /wp:paragraph -->

<!-- wp:image {"id":20282,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/09/Gallery-Baton_GRACE_Exhibition-view-4.jpg" alt="" class="wp-image-20282" /></figure>
<!-- /wp:image -->

<!-- wp:image {"id":20283,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image size-full"><img src="http://koreagalleries.or.kr/wp-content/uploads/2026/09/Gallery-Baton_GRACE_Exhibition-view-2.jpg" alt="" class="wp-image-20283" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p>회화, 조각, 영상 등 폭넓은 매체를 아우르는 이번 전시는 갤러리바톤의 확장 이전을 기점으로, 그동안 소개해온 동시대 미술의 다양한 흐름과 작업을 한자리에서 보여주고자 한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '갤러리바톤' WHERE provider_type = 'PUBLIC' AND external_id = '398537';
UPDATE festival SET title = '겹겹', content = '작품 겹겹은 개인의 홀춤에서 출발하여 무용수 각자의 내면에 축적된 삶의 경험과 감정의 ‘겹(layer)’을 탐구하고 이를 하나의 공동 서사로 확장해 나가는 작품이다.', place = '대학로예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '393146';
UPDATE festival SET title = '관현악시리즈Ⅰ<협연의 연대기>', content = '1970년대부터 2020년대에 이르기까지 현대화와 대중화의 물결 속에서 확장과 도약을 이루었던 국악관현악의 협연과 역사를 함께 조망하는 특별한 무대가 찾아온다.', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392772';
UPDATE festival SET title = '판소리공장 바닥소리 <해녀탐정 홍설록>', content = '2026 창극 중심 세계음악극축제 국내초청작. 일제강점기, 제주 해녀들의 목숨 건 항일운동을 담아낸 추리극', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '392784';
UPDATE festival SET title = '[인천] 루돌프 부흐빈더 & 루체른 페스티벌 스트링스 ', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393606';
UPDATE festival SET title = '2026 BMA 미래미술관 포럼 <공명하는 미술관 - 다감각적 공간, 다성적 공공>', content = '', place = '부산시립미술관 1층 다목적홀' WHERE provider_type = 'PUBLIC' AND external_id = '397166';
UPDATE festival SET title = '양평군립미술관 2026 세미나 <한국현대미술, 원로작가에게 듣는다>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '398021';
UPDATE festival SET title = '국립청주박물관 하반기 1차 ''박물관과 나무 이야기''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '395830';
UPDATE festival SET title = '전시 연계 체험 ''팝업 꽃 카드 만들기&캘리그라피''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '397251';
UPDATE festival SET title = '2026 융·복합 문화예술교육 프로그램 <틔·키·피 마음정원>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396794';
UPDATE festival SET title = '인천시립미술관 사전프로젝트 미술축제 <인천을 색칠하다>', content = '', place = '인천시청 애뜰광장' WHERE provider_type = 'PUBLIC' AND external_id = '397997';
UPDATE festival SET title = '[원주 갤러리 원] 한국수묵캘리협회전 "글씨가 위로가 되는 순간"  ', content = '', place = '갤러리 원' WHERE provider_type = 'PUBLIC' AND external_id = '399273';
UPDATE festival SET title = '오페라 넥스트 : 세비야의 이발사 & 피가로의 결혼', content = '', place = '서울문화예술교육센터 서초 서울체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '396095';
UPDATE festival SET title = '[2026 PLOT STAGE] Atchi - 낭독쇼케이스 <STEAK-DIVE!>', content = '', place = '극장 PLOT' WHERE provider_type = 'PUBLIC' AND external_id = '395451';
UPDATE festival SET title = '2026 고양무용페스타, 춤·향: 명품춤전', content = '', place = '고양아람누리 새라새극장' WHERE provider_type = 'PUBLIC' AND external_id = '397697';
UPDATE festival SET title = '[서울] 뮤지컬 브람스 ', content = '', place = 'KT&G 상상마당 대치아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '394439';
UPDATE festival SET title = '<김지후 - 길의언어> 수어판소리, 몸으로 건너는 시', content = '', place = '쎄서미 뮤지엄' WHERE provider_type = 'PUBLIC' AND external_id = '398473';
UPDATE festival SET title = '2026 제작공연 시리즈 名作 3. 판소리 명인전 <세바탕>', content = '', place = '평택남부문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '398045';
UPDATE festival SET title = 'NAC@시그니처 클래식 시리즈 Ⅴ. 차이콥스키 5번 & 쇼스타코비치 첼로 협주곡1번', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '394420';
UPDATE festival SET title = '[전주] 예술공간휘게 콘서트, 휘게 조인트 리사이틀 Vol.1: 정귀원 & 서현경 듀오 리사이틀', content = '', place = '휘게홀' WHERE provider_type = 'PUBLIC' AND external_id = '394726';
UPDATE festival SET title = '국립심포니콘서트오케스트라 <라흐마니노프, 교향곡 2번>', content = '라흐마니노프 특유의 깊은 서정과 장대한 선율을 한 무대에서 조명한다. 지휘자 김성진이 이끄는 국립심포니콘서트오케스트라와 피아니스트 안드레이 구그닌이 피아노 협주곡 2번과 교향곡 2번을 연주한다.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '393003';
UPDATE festival SET title = 'K-Sori 플랫폼 : 판소리 생태계 구축 - 해설이 있는 판소리 다섯바탕 <최현주의 동초제 흥보가>', content = '', place = '우진문화공간' WHERE provider_type = 'PUBLIC' AND external_id = '393099';
UPDATE festival SET title = '나홀로여행연극시리즈, 배고픈 날개: ¿꽃들도 밥을 먹나요？', content = '', place = '성북마을극장' WHERE provider_type = 'PUBLIC' AND external_id = '395877';
UPDATE festival SET title = '아트내상스 <STORY STAGE 시리즈2> 굿모닝 콘서트', content = '', place = '대동대학교 한울관 DART홀' WHERE provider_type = 'PUBLIC' AND external_id = '398589';
UPDATE festival SET title = '바리톤 방찬우 독창회 <삶 속의 빛>', content = '', place = '푸르지오아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '398640';
UPDATE festival SET title = '고요한 풍류 Ⅰ <서용석의 潭(담)>', content = '', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '395623';
UPDATE festival SET title = '김수연 바이올린 독주회 "회상"', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '392867';
UPDATE festival SET title = 'Project 9의 시리즈 1. Beethoven Symphony 9 "Choral"', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '394723';
UPDATE festival SET title = '9월 넷째 주 수요영화관 상영 <더 퍼스트 슬램덩크>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '398893';
UPDATE festival SET title = 'ART CABINET: PICASSO+DALÍ×TÀPIES - 더하고 교차하다', content = '', place = '하슬라아트월드' WHERE provider_type = 'PUBLIC' AND external_id = '398947';
UPDATE festival SET title = '연극 <럭키! 전당포>', content = '', place = '나인진홀 1관 (1층)' WHERE provider_type = 'PUBLIC' AND external_id = '394380';
UPDATE festival SET title = '국립극단 [안트로폴리스Ⅲ] <오이디푸스>', content = '관객과 평단이 주목한 안트로폴리스 5부작 대장정, 세 번째 이야기! 우리가 알고 있던 오이디푸스는 없다!', place = '국립극단 명동예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '392945';
UPDATE festival SET title = '전기숙·정은혜 《날개가 한 번 펄럭일 때》', content = '', place = '인사아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '400035';
UPDATE festival SET title = '혜성컴퍼니 <백만사>', content = '2026 창극 중심 세계음악극축제 국내초청작. 히트 가요 42곡으로 완성한 음악극! 대한민국의 연애의 역사가 무대 위에 펼쳐진다', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392825';
UPDATE festival SET title = '<추석엔 국악가요>', content = '유쾌함 가득! 어깨 들썩! 경기·서도·남도 지역을 대표하는 소리꾼들과 가수들이 지역별 민요와 친숙한 가요로 함께하며 추석 명절을 더욱 풍성하게 만들어줄 특별한 공연', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '392773';
UPDATE festival SET title = '[남산골한옥마을] 2026 남산골 추석축제 <남산달빛마당>', content = '', place = '남산골한옥마을 일원' WHERE provider_type = 'PUBLIC' AND external_id = '398567';
UPDATE festival SET title = 'NT Live <서쪽 나라의 멋쟁이>', content = '살인자가 영웅이 된 마을, 가장 발칙한 블랙 코미디. 원작 존 밀링턴 싱, 연출 카트리오나 맥러플린 그리고 니콜라 코클란의 명연기까지!', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392826';
UPDATE festival SET title = '제4회 월드 판소리 페스티벌, 청년 소리꾼 판소리 100일 독공 지원사업 결과발표회 <고선화의 적벽가 완창>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '399075';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 <이날치 콘서트>', content = '', place = '국립극장 무대예술지원센터' WHERE provider_type = 'PUBLIC' AND external_id = '398293';
UPDATE festival SET title = 'NT Live <모두가 나의 아들>', content = '올리비에상이 인정한 최고의 리바이벌, 이보 반 호브 손에 재탄생한 아서 밀러의 명작. 브라이언 크랜스톤, 마리안 장 바티스트 등 최고의 배우들이 선보이는 완벽한 앙상블', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392827';
UPDATE festival SET title = '[대전] 뮤지컬 <그날들>', content = '', place = '대전예술의전당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '395696';
UPDATE festival SET title = 'NT Live <더 피프스 스텝>', content = '치유와 파멸, 경계, 숨 막히는 도발적 심리극. 큰 화제를 모은 마틴 프리먼과 잭 로던의 팽팽한 연기대결!', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392828';
UPDATE festival SET title = '대전광역시 서예진흥원 <제26회 아천서회전>', content = '', place = '대전광역시 서예진흥원' WHERE provider_type = 'PUBLIC' AND external_id = '399304';
UPDATE festival SET title = '[광주] 2026 아르플래닛 피아노 콘서트 | 피아노 듀오 & 협주곡', content = '', place = '광주예술의전당 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '395869';
UPDATE festival SET title = '윤학원 코랄 22주년 기념 연주 "하모니로 드리는 감사의 합창"', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393165';
UPDATE festival SET title = '제2회 스카이씨어터 연극제-연극에 의한 연극 <나, 배우_보르헤스식 꿈꾸기>', content = '', place = '대학로 스카이씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '399978';
UPDATE festival SET title = '푸르지오아트홀 수요초대석 43, 소프라노 신효진 독창회 <헌정: 로베르트와 클라라 사랑으로 노래하다>', content = '', place = '푸르지오아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393261';
UPDATE festival SET title = '다담', content = '2월부터 11월까지 매월 마지막 주 수요일 오전 11시에는 국악과 차, 그리고 이야기가 함께하는 <다담>이 열립니다. 다담지기 황수경 아나운서의 진행으로 예술같은 삶을 살고 있는 사회 각 분야의 저명 인사를 초청해 이야기와 우리 음악을 나누는 토크 콘서트 입니다. 진솔한 삶의 이야기에 더해지는 우리 음악 한 잔! 오전의 설레이는 햇살 같은 특별한 시간을 느껴보세요.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '393101';
UPDATE festival SET title = '[대전] 소프라노 박지영 & 피아니스트 양기훈 듀오 리사이틀', content = '', place = '복합문화공간 플랜에이' WHERE provider_type = 'PUBLIC' AND external_id = '398995';
UPDATE festival SET title = '2026 나루아티스트와 함께하는 <살롱음악회> (9월)', content = '', place = '나루아트센터 갤러리(전시실)' WHERE provider_type = 'PUBLIC' AND external_id = '397602';
UPDATE festival SET title = '[서초문화원] 서초인문학 아카데미 <AI 시대의 인간다움> 김기현 교수', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '393395';
UPDATE festival SET title = '「2026 일상문화예술실험실」선정 프로젝트 <육퇴 엄마 클럽>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '397252';
UPDATE festival SET title = '2026 천안시립문학관 문학창작아카데미 <책크숍>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '399316';
UPDATE festival SET title = '[부천] 2026 부천문화재단 어린이공연 - 페이퍼아트 뮤지컬 <종이아빠> ', content = '', place = '복사골문화센터 판타지아극장' WHERE provider_type = 'PUBLIC' AND external_id = '396599';
UPDATE festival SET title = '[서울 서대문] 앤서니 브라운의 베스트 플레이: 우리 가족 & 난 책이 좋아요 ', content = '', place = '북아현아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '396586';
UPDATE festival SET title = '뮤지컬 <오페라>', content = '', place = '이화여자대학교 삼성홀' WHERE provider_type = 'PUBLIC' AND external_id = '396581';
UPDATE festival SET title = '[여수] 어린이 뮤지컬 <달 샤베트> ', content = '', place = '예울마루' WHERE provider_type = 'PUBLIC' AND external_id = '396602';
UPDATE festival SET title = '오페라박물관 야외음악회 <사랑의 묘약>', content = '', place = '오페라박물관' WHERE provider_type = 'PUBLIC' AND external_id = '396409';
UPDATE festival SET title = 'W필하모닉오케스트라 마스터 시리즈 Ⅲ. 로맨틱 러시아 2026 : 차이코프스키&라흐마니노프', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '396608';
UPDATE festival SET title = '제8회 공연예술축제 그라제×시립국악관현악단: 추상(秋想)', content = '', place = '광주예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '397798';
UPDATE festival SET title = '안소연 피아노 독주회 "변주곡의 오후"', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '393009';
UPDATE festival SET title = '[순천] 모던민요 ''송소희X두번째달X김준수'' 기획공연', content = '', place = '순천문화예술회관 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '399883';
UPDATE festival SET title = '어느 날의 빛은 천천히', content = '<!-- wp:paragraph -->
<p>비디갤러리에서는 10월 01일부터 10월 22일까지 김진영, 정석우 작가의 2인전인 <어느 날의 빛은 천천히>를 진행한다. 이번 전시는 비움과 축적, 변화와 흔적의 관계를 통해 회화가 자연의 존재를 풀어내는 과정을 살펴본다. 서로 다른 방식으로 물질과 환경을 탐구해온 두 작가의 작업은 화면을 고정된 이미지가 아닌, 시간과 감각이 머무르고 변화하는 장으로 확장한다. 비어 있는 공간과 쌓여가는 물질, 우연히 남겨진 흔적은 서로 긴장하며 하나의 리듬을 만들고, 그 안에서 자연과 인간의 관계가 새롭게 드러난다. 관람자는 작품을 바라보는 동시에 그 변화의 흐름 속에서 익숙한 이미지 너머에 감춰진 새로운 의미를 발견하게 된다.</p>
<!-- /wp:paragraph -->', place = '비디 갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '401075';
UPDATE festival SET title = '[대전] 바리톤 유진백 독창회 <언어유희>', content = '', place = '대전예술의전당 앙상블홀' WHERE provider_type = 'PUBLIC' AND external_id = '400168';
UPDATE festival SET title = '국립현대무용단 <트리플 빌>', content = '국립현대무용단이 다시 펼치는 세 개의 시선, 하나의 무대 <트리플 빌>. 세계 현대무용사의 핵심 작품을 한국 무용수의 몸으로 재맥락화한 ‘하나의 편평한 것, 복제된’ 9명의 무용수로 확장된 규모, 다이내믹을 더한 ‘메커니즘’ 익스트림 스포츠와 협업으로 역동성을 극대화한 ‘비보호’', place = '예술의전당 CJ 토월극장' WHERE provider_type = 'PUBLIC' AND external_id = '391295';
UPDATE festival SET title = '길 위의 인문학 현장답사 ''발굴조사로 새롭게 밝혀지는 달성토성''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '399969';
UPDATE festival SET title = '대한외국인 마크테토의 특강 <외국인의 시선으로 바라보는 한국적인 아름다움>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '399677';
UPDATE festival SET title = '제1302회 서초금요음악회, 쇼(Show) & 보이스(Voice)', content = '', place = '서초문화예술회관(구. 서초구민회관) 아트홀(대강당)' WHERE provider_type = 'PUBLIC' AND external_id = '399432';
UPDATE festival SET title = '낭독뮤지컬 <약국 식후30분>', content = '', place = '봄날아트홀(구. 아리랑소극장) 1관(지하1층)' WHERE provider_type = 'PUBLIC' AND external_id = '399905';
UPDATE festival SET title = '[울산] 뮤지컬 <배니싱> ', content = '', place = '울산문화예술회관 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '396850';
UPDATE festival SET title = '창작ing 뮤지컬 <돌쇠전>', content = '육체적 사랑의 대명사, 돌쇠와 마님에게 육체와 영혼의 사랑 이야기인 에로스와 프시케의 이야기를 부어본다.', place = '국립정동극장 세실' WHERE provider_type = 'PUBLIC' AND external_id = '392739';
UPDATE festival SET title = '[2026 PLOT STAGE] 프로젝트520 - 연극 <현대사회 청년 고독사에 관한 원인 분석: 고독사는 존재하지 않는다.>', content = '', place = '극장 PLOT' WHERE provider_type = 'PUBLIC' AND external_id = '395455';
UPDATE festival SET title = '제8회 공연예술축제 그라제 온가족 클래식 콘서트, 엉클영버×백조의 호수', content = '', place = '광주예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '397341';
UPDATE festival SET title = '이수연 & 김정민 피아노 듀오 리사이틀', content = '', place = '모차르트홀' WHERE provider_type = 'PUBLIC' AND external_id = '396968';
UPDATE festival SET title = '지브리&디즈니 오케스트라 콘서트 (10.4)', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '396909';
UPDATE festival SET title = 'A tempo, #여유와 설빈', content = '', place = 'KT&G 상상마당 [춘천]' WHERE provider_type = 'PUBLIC' AND external_id = '396858';
UPDATE festival SET title = '2026 대한민국 피아노페스티벌 - 베토벤 피아노 협주곡 전곡 Ⅰ(제1,2,4번)', content = '''2026년 대한민국 피아노페스티벌'' 베토벤 피아노 협주곡 전곡 연주의 시작. 김대진 지휘, 김규연, 유성호, 김세현 협연의 협주곡 무대', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '393173';
UPDATE festival SET title = '2026 평남수건춤보존회 정기공연 ″舞響″', content = '', place = '국립국악원 풍류사랑방' WHERE provider_type = 'PUBLIC' AND external_id = '399458';
UPDATE festival SET title = '2026 크리에이티브X성수 ''필름성수'' 제7회 다양성洞 영화제', content = '', place = '성수아트홀, 서울숲 야외무대, (온라인 상영) 퍼플레이' WHERE provider_type = 'PUBLIC' AND external_id = '398030';
UPDATE festival SET title = '2026 오르간 시리즈 II. 올리비에 라트리 & 이신영 <포 핸즈>', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '397884';
UPDATE festival SET title = '[2026 PLOT STAGE] 김호영 - 음악무용극 <틱, 틱, 끼익>', content = '', place = '극장 PLOT' WHERE provider_type = 'PUBLIC' AND external_id = '395434';
UPDATE festival SET title = '[인천오리지널탐방] 인천 구석구석을 각 분야의 ‘인천잘알’ 전문가들과 함께 탐방합니다.', content = '', place = '프로그램별 장소 상이' WHERE provider_type = 'PUBLIC' AND external_id = '401158';
UPDATE festival SET title = '제6회 소극장 공유 페스티벌  <차카니>', content = '', place = '소극장공유(구. 키작은소나무극장)' WHERE provider_type = 'PUBLIC' AND external_id = '399994';
UPDATE festival SET title = '손철주의 오래된 그림공부 <노래와 춤의 달인들>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400215';
UPDATE festival SET title = 'CMSS Festival IV & V', content = '', place = '푸르지오아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399753';
UPDATE festival SET title = '예기치 못한 손님', content = '<!-- wp:paragraph -->
<p>김연수의 회화에서 자연은 기억과 감정이 개입하면서 새롭게 구성된다. 이동 중 스쳐 지나간 풍경을 그리기 시작한 초기 작업부터 최근의 들풀과 나무, 구름과 파도에 이르기까지, 김연수의 관심은 객관적인 형상을 옮기는 데 있지 않았다. 실제로 보았던 장면은 기억 속에서 변형되고, 다시 그 장면을 마주하는 순간의 감정과 결합한다. 자연은 외부의 대상인 동시에, 그것을 바라보는 자신의 상태를 확인하게 하는 매개가 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이런 작업은 이미 알고 있는 감정을 그림으로 옮기는 일과는 다르다. 일상에서 우연히 마주친 장면이 설명하기 어려운 감정적 반응을 일으키고, 작가는 그 반응의 실체를 알아가는 과정에서 붓을 든다. 얇은 물감을 비비고 긋고 쌓아가는 행위는 대상을 묘사하는 동시에 불분명한 감각을 점차 구체화하는 과정이다. 동양화의 획과 호흡, 유화의 물성과 색의 중첩이 결합된 화면에서 명확하게 닫히지 않는 외곽선과 반복되는 붓질은 대상의 형태를 고정하기보다 시간과 환경에 따라 달라지는 상태를 드러낸다. 회화는 완성된 감정을 전달하는 수단이 아닌, 감정이 인식되는 과정을 포함하는 형식이 된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 전시 <예기치 못한 손님>은 이러한 흐름 위에서 풍경과 감정을 대하는 태도에 새로운 강조점을 둔다. 예기치 않게 찾아오는 감정처럼, 우연히 마주친 자연은 어느 순간 작가의 시선을 붙잡고 미처 인식하지 못했던 마음을 드러낸다. 작가의 이전의 작업이 불분명한 감정을 회화의 과정에서 조금씩 알아가고 정리하는 일이었다면, 이번 전시는 그 감정을 반드시 명확한 의미로 귀결시키지 않으려 한다. 감정의 탐색을 포기하는 것이 아니라, 회화가 도달해야 할 결론을 미리 설정하지 않는 것이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>풀숲 사이의 작은 꽃과 바람에 흔들리는 갈대, 흐르는 물가의 새처럼 일상에서 쉽게 지나칠 수 있는 자연에서 작가는 이들을 설명하기보다, 우연히 마주한 순간의 인상과 그때의 감정을 화면에 남긴다. 여러 색을 섞고 붓질을 반복하면서 자연의 형태와 분위기를 구성하지만, 그 감정이 무엇인지 하나의 답으로 정리하지는 않는다. <예기치 못한 손님>은 작가에게는 알 수 없는 감정을 그대로 받아들이는 시도이며, 관람자에게는 익숙한 자연을 자신의 경험을 통해 다시 바라보는 기회를 제안한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p><strong>-</strong><strong>갤러리나우 큐레이터 유한식</strong></p>
<!-- /wp:paragraph -->', place = '갤러리나우' WHERE provider_type = 'PUBLIC' AND external_id = '401074';
UPDATE festival SET title = '대전광역시 서예진흥원 <대전서예 청년대표작가 초대전>', content = '', place = '대전광역시 서예진흥원' WHERE provider_type = 'PUBLIC' AND external_id = '387942';
UPDATE festival SET title = '니나전 개인전 ''Fly to the Cosmos - Ceramic Balloons''', content = '<!-- wp:paragraph -->
<p id="SE-96248790-1814-49db-9c7e-c589987fbb1f">2026년 10월 7일(수)~10월 31일(토)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-c38931b5-630e-43d4-9811-34855772dc5e">I 관 : 갤러리가이아 서울</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-f3ae3124-f30b-48a4-aa24-0ddd37f9d9ea">T. 02-733-3373</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-95ee33df-358d-4fac-a7a0-1b4efd8fdd5a">(서울시 강남구 청담동 80-5 1F)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-ae4e1e89-f787-4b03-8fe6-9e35cd76b58a">관람시간 : 화~토 10am~6pm (일요일, 월요일, 공휴일 예약관람)</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-d62f3fed-df8f-49c0-a3f0-2ba57da723bd">[작가 설명]</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-0ec11378-8bca-4af8-ae77-658fb1bddc93"><strong>니나전 Nina Jun</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-fd6322e8-dea5-4f6e-a14e-1c3a1358568a">Nina Jun (니나 전) 선생님은 한국에서 태어나 20대 초반 미국으로 이주해 현재 캘리포니아를 기반으로 활동하는 조각·설치미술가입니다. California State University, Long Beach에서 조각을 전공해 BFA와 MFA를 취득했으며, 대학원 졸업 당시 Distinguished Achievement in Creative Activity Award를 수상했습니다. 조각, 브론즈 캐스팅, 세라믹, 비디오 및 설치미술 등 다양한 매체를 연구했으며, 특히 무거운 세라믹을 이용해 가볍게 떠 있는 헬륨 풍선의 모습을 구현한 ‘Ceramic Balloon’ 연작으로 독창적인 작품세계를 구축했습니다. Skidmore Contemporary Art를 비롯한 미국 갤러리에서 개인전과 그룹전을 개최했으며, 뉴욕, 마이애미, LA, 홍콩, 싱가포르, 서울 등 세계 각지의 국제 아트페어에 참여하며 활발하게 활동하고 있습니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-3d0e9bd2-832c-476e-998c-cbc0d590294d">니나 전은 즐거움과 행복의 심볼인 마일라 풍선을 세라믹 조각으로 재탄생합니다. 그로써 일시적인 소재를 영원히 간직할 수 있는 아트로 만듭니다. 그녀는 어느 날 헬륨가스가 든 풍선이 방 한 가운데 정지한 채 고요히 공간에 떠 있는 것을 보고 중력과 부력의 평형관계에서 오는 평온함을 발견하고는 마치 나비가 꽃 위에서 날개 짓을 할 때의 평형(equilibrium)의 아름다움을 떠올리게 됩니다. 작가는 그 속에서 삶의 모든 것들 속의 아름다운 평형(Eqillibrium)을 느꼈습니다. 그녀의 작품은 아름다운 삶의 균형을 꿈꾸는 작가의 메타포입니다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-6823245e-21a0-4fd4-b6da-ade1fda78314">​</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-ffe09656-bfd7-488e-8a6b-93d1460e35cb">Nina Jun is a Korean-born sculptor and installation artist who moved to the United States in her early twenties and is now based in California. She earned her BFA and MFA in Sculpture from California State University, Long Beach, receiving the Distinguished Achievement in Creative Activity Award upon completing her graduate studies. Her practice spans sculpture, bronze casting, ceramics, video, and installation. She is particularly known for her *Ceramic Balloon* series, which captures the lightness and buoyancy of helium balloons through the weight and solidity of ceramics, establishing a distinctive artistic language. Jun has presented solo and group exhibitions at American galleries, including Skidmore Contemporary Art, and has participated in international art fairs in New York, Miami, Los Angeles, Hong Kong, Singapore, and Seoul.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-f1c45699-1599-4fb4-b499-c9ba08a7b851">Nina Jun transforms Mylar balloons—symbols of joy and happiness—into ceramic sculptures, turning an ephemeral material into art that can be cherished forever. One day, she noticed a helium-filled balloon floating silently and motionlessly in the middle of a room. She discovered a sense of serenity in the equilibrium between gravity and buoyancy, recalling the beauty of a butterfly hovering above a flower, its wings gently beating.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p id="SE-32156e61-9974-40ab-a5ca-215bf2786f11">​</p>
<!-- /wp:paragraph -->', place = '갤러리 가이아' WHERE provider_type = 'PUBLIC' AND external_id = '401334';
UPDATE festival SET title = '국립발레단 <스페셜 갈라>', content = '대한민국의 발레를 대표하는 국립발레단의 주요 레퍼토리와 세계적인 명작들의 하이라이트를 선보이는 갈라 공연', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '393004';
UPDATE festival SET title = '[서초문화원] 서초인문학 아카데미 <한류 메가트렌드: 문화가 만드는 새로운 글로벌 경쟁력> 문시연 총장', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '394939';
UPDATE festival SET title = '텅에 NEST', content = '<!-- wp:image {"align":"center","id":20454,"sizeSlug":"full","linkDestination":"none"} -->
<figure class="wp-block-image aligncenter size-full"><img src="https://koreagalleries.or.kr/wp-content/uploads/2026/10/박지은_웹포스터_260903_주소포함_ss.jpg" alt="" class="wp-image-20454" /></figure>
<!-- /wp:image -->

<!-- wp:paragraph -->
<p><텅에 NEST></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Artist: PARK Ji Eun<br>Date: OCT 7 – OCT 24, 2026<br>Wed – Sun pm 13:00-18:00<br>Opening Reception: 10.7 (Wed) 5pm</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>갤러리진선, 옻칠 화가 박지은 개인전 〈텅에-nest〉전 개최</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>• 옻칠 화가 박지은, 현대인의 심리적 보금자리를 의미하는 〈텅에〉전 개최</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>• 집과 둥지, 쉼터와 보금자리라는 현대인의 희비애환을 담은 주제 탐구</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>• “한국 전통의 기와집에서 나아가 확장된 세계관의 동양적 풍경” 선보여 • 옻칠 기법과 계란 껍질 등 천연재료를 바탕으로 심상적 회화 구축</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>옻칠과 전통재료를 바탕으로 공감대 넓은 조형언어를 펼치는 박지은 작가의 개인전 ‘텅에(Nest)’가 서울 종로구 삼청동 소재 갤러리 진선에서 오는 10월 7일부터 10월 24일까지 열린다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>이번 개인전의 주제인 ‘텅에-nest’는 어린새들의 보금자리 역할을 하는 둥지(둥우리)의 제주방언으로 부담없이 편안하게 쉴 수 있는 보금자리를 의미한다. 박지은 작가는 ‘텅에’의 모티프를 확장해 현대인의 정서적 심리적 보금자리를 표현한다. 돌아가고 싶은 곳이자 머물고 싶은 곳, 이상향이자 상상의 공간으로 등장하는 박지은의 ‘텅에’적 풍경은 저마다의 귀소처를 찾는 현대인들에게 포근하고 편안한 감상을 전달한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>박지은의 작품에서 나타나는 지붕의 형상은 기억과 정서가 안착하는 공간을 상징한다. 작가는 “내 마음이 편한 곳이 내 보금자리가 될 수 있다”는 심리적 양상을 조형화했다고 한다. 이러한 표현의 연구로 등장한 화면 속 지붕을 이루는 기와라는 동양적 양식은 굳건하고 안전한 공간을 표현하는 작가의 개성적 요소이다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>박지은 작가의 화면은 옻칠기법과 계란껍질을 비롯한 자연적 소재를 적극적으로 활용한다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>알껍질로 이루어진 난각의 물성은 생명을 보호하는 껍질이자 둥지의 모티프로 작동하고, 그의 화면에 일관적으로 등장하는 가옥은 단순한 건축물을 넘어 보호와 안전을 은유한다. 이주희 미술평론가는 박지은의 풍경에 대해 “기와로 대표되는 우리의 친근한 실재와 상상적 자연의 규모가 결합 된, 작가만의 견고한 풍경”이라고 말했다. 또한 “동양적 화재(畫材)와 집과 보금자리라는 현대인의 정감이 함께 작용”하는 작품이라 평했다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>박지은은 동덕여대 동양화과를 졸업해 지필묵을 중심으로 자신의 감성과 동양적 문화상이 혼합된 조형언어를 탐색해왔다. 2008년 옻칠 기법과의 만남 이후 확장된 조형언어를 전개하고 있다. 전북 완주 누에아트홀(2024, 2023), 삼례미술관(2022), 한국소리문화의전당(2020) 등 현재까지 25회의 개인전을 개최했으며 우진문화재단 청년작가, 가송문화재단 작가, 이랜드문화재단 작가 등에 선정된 바 있으며 국립현대미술관 미술은행, 전라북도립미술관, 부안군청, 포스코, 완주문화재단 등에 작품이 소장되어 있다. 현재 전북 완주와 서울을 거점으로 작품활동 중이며, 이번 전시에는 박지은 작가의 풍경작품 총 25점이 출품된다.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Title: Teonge - Nest</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>▪  Dates: 2026. 10. 07 – 10. 24</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>▪  Artist: PARK, Ji Eun</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>▪  Exhibition Location: Gallery Jinsun</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>2F, 59 Samcheong-ro, Jongno-gu, Seoul</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>▷ About the Exhibition</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>Gall<strong>ery Jinsun to Host Solo Exhibition by Ottchil (Lacquer) Artist PARK, Ji Eun “Teonge - Nest”</strong></p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>• The Ottchil artist PARK, Ji Eun is mounting a new solo exhibition entitled “Teonge - Nest,” which explores how people in the modern era find psychological sanctuary</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>• Investigates the joys and sorrows of modern life through concepts of home, nests, shelters, and sanctuaries</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>• Showcases an expanded world view of the “Oriental landscape,” one which has evolved from the traditional Korean tiled-roof (Giwa) houses</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>• Paintings utilize natural materials such as Ottchil (lacquer) and eggshells</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p> PARK, Ji Eun’ s solo exhibition “Teonge - Nest,” in which the artist’s work embodies a broadly resonant visual language based on Ottchil (lacquer) and traditional materials, will be held at Gallery Jinsun in Samcheong-dong, Jongno-gu, Seoul, from October 7 to October 24.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The theme of this solo exhibition, “Teonge -Nest,” is derived from the word for a nest acting as home for young birds in the Jeju Island dialect of South Korea, and means a place of shelter in which one can rest comfortably and without burden. PARK, Ji Eun expands upon the motif of “Nest” to invoke an emotional and psychological sanctuary for people of the modern era. Appearing as places one longs to return to and wishes to remain, as well as ideal and imagined spaces, PARK, Ji Eun’s “Teonge - Nest” landscapes offer a warm and comforting experience to viewers searching for their own place of return.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The roofs that appear in PARK, Ji Eun’s works symbolize spaces on which memories and emotions come to rest. The artist explains that she has given form to the psychological idea that “a place where my heart feels at ease can become my home.” Emerging from this exploration of expression, Giwa, or traditional roof tiles, is an Oriental form constituting the roofs within her compositions and is a distinctive element through which the artist conveys a solid and secure space.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>PARK, Ji Eun’s compositions actively employ natural materials, including Ottchil technique and eggshells.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>The physical properties of eggshells both connect to the ‘nest’ motif through proximity and thematically, as a shell that protects life, while the houses that consistently appear in her works metaphorically convey protection and safety, beyond mere architecture. Art critic LEE, Ju Hee has described PARK, Ji Eun’s landscapes as "a solid landscape unique to the artist, combining our familiar reality represented by tiles with the scale of imaginary nature." He also notes that the artist''s pieces are "works in which Eastern painting materials and the modern human sentiment of home and nest operate together."</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p>PARK, Ji Eun graduated from Department of Oriental Painting of Dongduk Women''s University,  has explored a way of working that combines her sensitivity with Eastern cultural sensibilities, primarily through ink and brush techniques. Since having encountered Ottchil technique in 2008, she has been developing an expanded creative language. She has held a total of 25 solo exhibitions to date, including at Nu- Art Hall in Wanju, Jeonbuk (2024, 2023), Picture Book Art Museum in Samnye (2022), and Sori Arts Center of Jeonbuk State (2020). She has received the Woojin Young Artist Prize and the Ghasong Art Award, and has been selected as an E-Land Cultural Foundation Artist. Her works are held in the collections of the Art Bank at the National Museum of Modern and Contemporary Art, Jeonbuk Museum of Art, Buan County Office, POSCO, and Wanju Culture & Tourism Foundation. Currently, she works from studios in Wanju, Jeonbuk, and Seoul. In this exhibition, a total of 25 landscape works by PARK, Ji Eun will be presented.</p>
<!-- /wp:paragraph -->

<!-- wp:paragraph -->
<p></p>
<!-- /wp:paragraph -->', place = '갤러리진선' WHERE provider_type = 'PUBLIC' AND external_id = '401692';
UPDATE festival SET title = '서리풀 고음악 시리즈 <불멸의 바로크>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399783';
UPDATE festival SET title = '[10월 8일] 김종미 & 윤다정 피아노 듀오 리사이틀', content = '', place = '성남아트센터 앙상블씨어터' WHERE provider_type = 'PUBLIC' AND external_id = '396682';
UPDATE festival SET title = '한화생명과 함께하는 예술의전당 11시 콘서트(10월)', content = '차세대 피아노 유망주 임주희가 선보이는 모차르트 피아노 협주곡 제21번과 지휘자 홍석원&국립심포니콘서트오케스트라가 선보이는 슈베르트 교향곡 제3번', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393152';
UPDATE festival SET title = '수림뉴웨이브 2026 - 이재하 <현금제: 이중번역 (二重飜譯)>', content = '', place = '김희수아트센터 SPACE 1' WHERE provider_type = 'PUBLIC' AND external_id = '392737';
UPDATE festival SET title = '브릿지클래식시리즈1 <Colors : 리듬의 색채>', content = '다채로운 타악기의 울림으로 펼쳐지는 리듬의 색채, 춘천의 예술을 연결할 새로운 클래식 무대. 강원대학교 교수진과 춘천시립교향악단이 함께 선보이는 그 첫 번째 이야기.', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '393096';
UPDATE festival SET title = '[세종] 국립오페라단 킨더오페라 <세비야의 이발사>', content = '', place = '세종문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '397903';
UPDATE festival SET title = '고희동미술관 시니어 교육프로그램 <예술한폭> - 전통 한국화 그리기', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '396319';
UPDATE festival SET title = '2026 은평에브리바디페스티벌 <와이즈발레단-지젤(GISELLE)>', content = '', place = '은평문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '397973';
UPDATE festival SET title = '《2026년 10월 9일부터 23일까지¹ 매일 오전 11시와 오후 8시 사이²에 주석모음집(서울 종로구 창신동 627-23)³에서 열리는 이 전시는 …》', content = '', place = '주석모음집' WHERE provider_type = 'PUBLIC' AND external_id = '402147';
UPDATE festival SET title = '시민과 함께하는 <Pride 클래식 콘서트>', content = '', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '399321';
UPDATE festival SET title = '2026 큰새공연 <클라우드 쿠쿠랜드>', content = '', place = '소극장 플랫폼74' WHERE provider_type = 'PUBLIC' AND external_id = '398083';
UPDATE festival SET title = '[부산] 김혜정 & 공수미 플루트 리사이틀: Women in Music with Flutes', content = '', place = '부산문화회관 챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '400324';
UPDATE festival SET title = '2026 국립남도국악원 토요상설 : 국악이 좋다, 우수작품 공모 선정작_성금연가락보존회 초청공연 <소리길을 찾아서-현의 어울림>', content = '', place = '국립남도국악원 진악당' WHERE provider_type = 'PUBLIC' AND external_id = '399454';
UPDATE festival SET title = '2026 문화가 있는 날 청춘마이크 수도•강원권 스핀오프 ''청춘들의 보물섬'' 기획공연', content = '', place = '신시모도 삼형제 보물섬' WHERE provider_type = 'PUBLIC' AND external_id = '399646';
UPDATE festival SET title = '[대학로] 카페 론리 Cafe Lonely ', content = '', place = 'R&J씨어터(구. 연진아트홀)' WHERE provider_type = 'PUBLIC' AND external_id = '397870';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 <코리안 집시 KOREAN GIPSY>', content = '', place = '국립극장 무대예술지원센터' WHERE provider_type = 'PUBLIC' AND external_id = '400429';
UPDATE festival SET title = '[서울남산국악당] 2026 한국장단음악축제 <장단유희>', content = '', place = '서울남산국악당' WHERE provider_type = 'PUBLIC' AND external_id = '398917';
UPDATE festival SET title = '2026 서울국제음악제 ''SIMF오케스트라 : 빛과 그림자''', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '398082';
UPDATE festival SET title = '2026 은평에브리바디페스티벌 <99아트컴퍼니-에카(Ekah)&심연(Abyss)>', content = '', place = '은평문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '397980';
UPDATE festival SET title = '찰리 푸스 내한공연, Charlie Puth - Whatever’s Clever! World Tour in Seoul', content = '', place = '고양종합운동장 주경기장' WHERE provider_type = 'PUBLIC' AND external_id = '398133';
UPDATE festival SET title = '[서울] 국내 최초 <인터스텔라 필름콘서트> 한국 초연', content = '', place = '경희대학교 평화의전당' WHERE provider_type = 'PUBLIC' AND external_id = '398140';
UPDATE festival SET title = '테너 김민석 리사이틀: Love & Destiny', content = '', place = '금호아트홀 연세' WHERE provider_type = 'PUBLIC' AND external_id = '399418';
UPDATE festival SET title = '코리아나 챔버 뮤직 소사이어티 제92회 정기연주회 "음악의 그라데이션"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '396145';
UPDATE festival SET title = '김상희, 박나은 2인전 <안녕을 빌었다>', content = '', place = '비커밍갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '400898';
UPDATE festival SET title = '국립발레단 <지젤>', content = '숭고한 사랑을 지키려는 ''지젤''과 진실한 사랑을 깨닫게 된 ''알브레히트''의 애절한 파드외와 사랑에 배신당한 ''월리''들이 선보이는 황홀한 발레블랑의 무대가 깊은 감동은 선사한다.', place = '예술의전당 오페라극장' WHERE provider_type = 'PUBLIC' AND external_id = '393308';
UPDATE festival SET title = '[사상아트갤러리] 2026 한국창조미술협회 부산지회 Sea & Light project전', content = '', place = '사상갤러리(구청1층 갤러리)' WHERE provider_type = 'PUBLIC' AND external_id = '402918';
UPDATE festival SET title = '크리오아트컴퍼니 초청음악회 <소프라노 김성은 독창회>', content = '', place = 'JCC 아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '401653';
UPDATE festival SET title = '제16회 서초구립여성합창단 정기연주회 <첫사랑>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399789';
UPDATE festival SET title = '[서울시립과학관]  2026 과학관 성인교육 ''전통자수: 자수를 수놓다''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400282';
UPDATE festival SET title = '2026 시민랩 히읗(ㅎ) ''히죽히죽 팝업 실험실'' 결과공유 전시 연계 워크숍', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '402759';
UPDATE festival SET title = '한국예술종합학교 수요영화관 <센티멘탈 밸류>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '401818';
UPDATE festival SET title = '용인시 드림스타트 <드림플라이>', content = '', place = '용인문화예술원 마루홀' WHERE provider_type = 'PUBLIC' AND external_id = '402293';
UPDATE festival SET title = '양나희 개인전 “Useless... but Beautiful”', content = '', place = '인사아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '402452';
UPDATE festival SET title = '무수민, 슈퍼포지션 <아직 그 자리를 비워야 한다 A Place Must Still Be Left (   )>', content = '', place = '16아카이브' WHERE provider_type = 'PUBLIC' AND external_id = '401910';
UPDATE festival SET title = '임정민 대금 독주회 <마주하다: Dialogue>', content = '', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '401151';
UPDATE festival SET title = '2026 서리풀 재즈페스타 <A Night in New Orleans>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399790';
UPDATE festival SET title = '[마포문화재단] 제11회 M 클래식 축제 <하나의 울림>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '388201';
UPDATE festival SET title = '박준선 작곡발표회 <머리카락 보일라>', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '399756';
UPDATE festival SET title = 'K''urius의 피아노 스펙트럼 3 (큐리어스의 피아노 스펙트럼 3)', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390906';
UPDATE festival SET title = '2026 K-뮤지엄 지역순회전 <활의 길, 도시를 잇다>', content = '', place = '부천활박물관' WHERE provider_type = 'PUBLIC' AND external_id = '398921';
UPDATE festival SET title = '독립기념관 현충시설 순회전 <태극기, 모두의 염원을 담다>', content = '', place = '제주항일기념관' WHERE provider_type = 'PUBLIC' AND external_id = '402469';
UPDATE festival SET title = '전남광주통합특별시예술의전당, 기획공연 그랜드스테이지 ‘Into the New World''', content = '', place = '광주예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '399049';
UPDATE festival SET title = '수림뉴웨이브 2026 - 이준형 <길굿>', content = '', place = '김희수아트센터 SPACE 1' WHERE provider_type = 'PUBLIC' AND external_id = '396054';
UPDATE festival SET title = '국립국악원 무용단 정기공연 <상선약수>', content = '변화하면서도 본질을 잃지 않는 우리 츰, 흐를수록 깊어진 <상선약수>는 8개의 서로 다른 민속춤의 움직임과 미학을 동시대의 감각과 군무의 언어로 펼쳐 보이는 작품입니다.  ', place = '국립국악원 예악당' WHERE provider_type = 'PUBLIC' AND external_id = '402893';
UPDATE festival SET title = '클래식 토크 콘서트 <두 남자 이야기>', content = '피아니스트 다니엘 린데만과 바리톤 우주호가 클래식부터 영화음악, 재즈까지 다양한 음악과 토크를 선보이는 콘서트', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '391525';
UPDATE festival SET title = 'ASAC 연극 <레오폴트슈타트>', content = '토니상·올리비에상 수상! 브로드웨이·웨스트엔드 뒤흔든 최고의 화제작으로 영국 현대 연극의 거장 톰 스토파드가 자신의 가족사와 정체성에 대한 성찰을 담아 완성한 마지막 작품이다. 20세기 초반 비엔나를 배경으로 한 유대인 가문의 50년에 걸친 격동의 역사를 세밀하고 웅장하게 그려낸다.', place = '안산문화예술의전당 달맞이극장' WHERE provider_type = 'PUBLIC' AND external_id = '392951';
UPDATE festival SET title = '국립심포니콘서트오케스트라 <말러, 교향곡 4번>', content = '고전의 균형, 삶의 노래. 김성진 지휘, 김도현 피아노, 홍주영 소프라노, 국립심포니콘서트오케스트라 연주로 만나는 고전적 균형과 후기 낭만의 서정성, 베토벤 피아노 협주곡 1번과 말러 교향곡 4번.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '393006';
UPDATE festival SET title = '홍지연 첼로 독주회 “헌정”', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '396466';
UPDATE festival SET title = '[대전] 김지연 피아노 리사이틀: PRELUDE & SONATA', content = '', place = '대전예술가의집 누리홀' WHERE provider_type = 'PUBLIC' AND external_id = '399019';
UPDATE festival SET title = '[군산] 가족무용극 <왕비의 잔치> ', content = '', place = '군산예술의전당 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '399085';
UPDATE festival SET title = '[부산] 뮤지컬 <그날들> ', content = '', place = '드림씨어터 [부산]' WHERE provider_type = 'PUBLIC' AND external_id = '399537';
UPDATE festival SET title = '미디어아트 뮤지컬 <파랑새>', content = '노벨문학상 수상자 마테를링크의 대표작 <파랑새>의 미디어아트 뮤지컬로, 남녀노소 모두가 공감할 수 있는 이야기와 풍부한 볼거리로 구성되어 있는 작품', place = '용인시평생학습관 큰어울마당' WHERE provider_type = 'PUBLIC' AND external_id = '393212';
UPDATE festival SET title = '최법진 개인전 <검은 땅 - 기억의 풍경>', content = '', place = '봄내극장 춘천미술관' WHERE provider_type = 'PUBLIC' AND external_id = '402914';
UPDATE festival SET title = '길 위의 인문학 특강 ''조선시대 과거제도와 대구 출신 과거급제자''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '399967';
UPDATE festival SET title = '국립극단 〈태풍〉', content = '셰익스피어의 마지막 걸작 <태풍>. 복수와 화해, 용서의 메시지를 현대적 감각으로 재해석한 국립극단 화제작.', place = '성남아트센터 오페라하우스' WHERE provider_type = 'PUBLIC' AND external_id = '391329';
UPDATE festival SET title = '연극 <유리동물원>', content = '시놉시스 SYNOPSIS: 1930 년대 미국 세인트루이스의 허름한 아파트 오래전 남편이 가족을 버리고 떠난 뒤, 아만다는 젊은 시절 수많은 구혼자에게 둘러싸였던 화려한 과거에 기대어 살고 있다. 언젠가 두 자녀에게 더 밝은 내일이 찾아올 것을 믿으면서. 하지만 다리가 불편하고 수줍음이 많은 로라는 사람들과 어울리는 대신 집 안에 머물며 작은 유리 동물들과 함께 자신만의 조용한 세계에 숨어 살아간다. 구두 창고에서 일하며 가족의 생계를 책임지는 톰 역시 답답한 현실에 갇혀 있다. 시인을 꿈꾸는 그는 매일 이 집을 떠날 순간만을 상상하지만, 가족에 대한 책임감은 쉽사리 그를 놓아주지 않는다. 로라의 결혼만이 가족의 희망이라 믿는 아만다는 톰에게 멋진 청년 한 사람을 데려오라 재촉하고, 결국 톰은 직장 동료 짐을 저녁 식사에 초대한다. 밝고 자신감 넘치는 짐의 방문으로 오래 침묵에 잠겨 있던 집 안에는 오랜만에 낯선 활기가 스며든다. 그리고 그날 저녁, 윙필드 가족이 애써 붙들고 있던 희망과 환상은 조금씩 흔들리기 시작하는데…', place = '예술의전당 CJ토월극장' WHERE provider_type = 'PUBLIC' AND external_id = '400463';
UPDATE festival SET title = '넌버벌 퍼포먼스 <페인터즈>', content = '화려한 라이브 드로잉과 미디어아트, 퍼포먼스가 결합된 세계적인 넌버벌 공연으로, 그림이 완성되는 순간마다 놀라움과 감동을 선사하는 오감만족 아트퍼포먼스', place = '세종문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '393007';
UPDATE festival SET title = '2026 김동률 콘서트 ''오래된 노래''', content = '', place = '세종문화회관 세종대극장' WHERE provider_type = 'PUBLIC' AND external_id = '399086';
UPDATE festival SET title = '트럼페터 안희찬 추모 음악회 "선생님의 발자취"', content = '', place = '영산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '396288';
UPDATE festival SET title = '2026 NAC 문화예술교육 공연 및 악기체험 클클클 ''동물원에 간 오케스트라''', content = '', place = '낙동아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '399132';
UPDATE festival SET title = '[인천] 파보 예르비 & 에스토니안 페스티벌 오케스트라', content = '', place = '아트센터 인천 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399191';
UPDATE festival SET title = '[2026 PAMSxSPAF] 제로셋 프로젝트 <어서오세요_2026>', content = '', place = '아르코예술극장 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '399480';
UPDATE festival SET title = '2026 D.FESTA 소극장축제 <토스트 구워주는 남자>, <전하지 못한 진심>', content = '', place = '열린극장' WHERE provider_type = 'PUBLIC' AND external_id = '401945';
UPDATE festival SET title = '[참여자 모집] 〈2026 디지털아트 컬처랩 – 유스랩〉 온라인 미디어아트 교육 프로그램', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '401974';
UPDATE festival SET title = '[서울영화센터] <2026 AI 영화 쇼케이스> 모집 대상 확대!', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '399959';
UPDATE festival SET title = '[세종] 모노오페라 <라 칼라스>', content = '', place = '세종예술의전당 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '399505';
UPDATE festival SET title = '[안성] 다비드 바뱅 & 아드리앙 몽도의 피아노 피아노', content = '', place = '안성맞춤아트홀 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '399516';
UPDATE festival SET title = '슈테른 필하모닉 더블 심포니 베토벤 7&5', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399523';
UPDATE festival SET title = '[마포문화재단] 제11회 M 클래식 축제 <김도현x이수빈 듀오 리사이틀>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '388268';
UPDATE festival SET title = '앙상블 ‘공간’ 프로젝트 열일곱 번째 이야기 ''여행과 이방인(Voyage & Strangers)''', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '398486';
UPDATE festival SET title = '''쓰기를 위한 읽기'' 워크숍 <봄비> <문학의 미스터리>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '403108';
UPDATE festival SET title = '[울산] 아트 온 스크린, 오페라 <아디나> (영상화) ', content = '', place = '울산중구문화의전당 함월홀(2층)' WHERE provider_type = 'PUBLIC' AND external_id = '400593';
UPDATE festival SET title = '[마포문화재단] 제11회 M 클래식 축제 <전수진의 피아니즘>', content = '', place = '마포아트센터 플레이맥' WHERE provider_type = 'PUBLIC' AND external_id = '388202';
UPDATE festival SET title = '푸르지오아트홀 수요초대석 46 마크와 친구들 Marc & Friends (A Night at the Opera)', content = '', place = '푸르지오아트홀 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '399268';
UPDATE festival SET title = '[10월28일] 빛과 여백사이 ENTRE… lumière & vide', content = '', place = '일신홀' WHERE provider_type = 'PUBLIC' AND external_id = '400770';
UPDATE festival SET title = '[마포문화재단] 제11회 M 클래식 축제 <뮤라벨 콘서트>', content = '', place = '마포아트센터 플레이맥' WHERE provider_type = 'PUBLIC' AND external_id = '388203';
UPDATE festival SET title = '[10.28.(수) / 예술의전당 콘서트홀] 서울오라토리오 제88회 정기연주회 - 멘델스존 ‘엘리야’', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '400704';
UPDATE festival SET title = '2026 서리풀 재즈페스타 <Golden October>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399808';
UPDATE festival SET title = '작곡가 김청묵 80세 기념음악회 <전통과 현대>', content = '', place = '세종문화회관 세종체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '402736';
UPDATE festival SET title = '[강릉] 아트필 재즈밴드 제7회 정기연주회 “Jazz in Motion”', content = '', place = '강릉아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '402096';
UPDATE festival SET title = 'ASAC 클래식 구자범의 <The Sound of Music>', content = '우리가 너무나도 ''잘'' 알고 있는 노래들을 다시 들여다 보며, 사실 우리가 잘''못''알고 있는 모래였다는 것을 깨닫게 된다. 음악감독이 직접 피아노를 연주하며 설명하는 음악이 있는 강의.', place = '안산문화예술의전당 별무리극장' WHERE provider_type = 'PUBLIC' AND external_id = '392952';
UPDATE festival SET title = '창작악단 정기공연 <전통의 재발견Ⅶ>', content = '전통의 선율과 몸짓이 국악관현악으로 재창조되는 국립국악원 창작악단의 전통의 재발견 시리즈 일곱 번째 무대로 오늘날 전승되고 있는 정가로 노래하는 대표적인 곡들인 가곡, 가사, 시조, 창사, 악장을 주제로 한 다섯 작품을 선보입니다.', place = '국립국악원 예악당' WHERE provider_type = 'PUBLIC' AND external_id = '393104';
UPDATE festival SET title = '파트리샤 코파친스카야 & 솔 가베타 듀오 콘서트', content = '경계를 허무는 파격과 혁신의 바이올리니스트 파트리샤 코파친스카야, 깊고 완벽한 음색을 자랑하는 이 시대 독보적 첼리스트 솔 가베타의 국내 첫 듀오 콘서트', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '393158';
UPDATE festival SET title = '현대음악앙상블 ‘소리’ 2026 정기연주회 “Dream & Life”', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '400612';
UPDATE festival SET title = '[양산] 패밀리 재즈 콘서트: 재즈로 듣는 지브리 & 디즈니 OST ', content = '', place = '쌍벽루아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '378855';
UPDATE festival SET title = '오페라 <라인의 황금>', content = '국립오페라단은 바그너의 오페라 <라인의 황금>을 무대에 올리며, ‘니벨룽의 반지’  링 시리즈의 서막을 연다. <라인의 황금>은 바그너가 26년에 걸쳐 완성한 4부작 대서사시의 출발점으로 사랑과 권력, 탐욕과 저주의 기원을 신화적 서사 속에 집약한 작품이다. 라인강의 황금을 둘러싼 갈등을 통해 세계의 질서가 균열되는 순간을 그리는 이 작품은 시리즈 전체를 관통하는 사상이 처음으로 제시되는 작품이다. 지휘는 2024년 <죽음의 도시>에서 밀도 높은 지휘로 깊은 인상을 남긴 로타 쾨닉스가 맡아, 바그너 음악의 구조적 긴장과 에너지를 드러낸다. 연출은 2025년 <세 개의 오렌지에 대한 사랑>에서 유연한 상상력과 동시대적 감각을 선보인 로렌조 피오로니가 참여해, 신화 속 이야기를 해석하며 2029년까지 이어지는 국내 오페라계에 전례 없는 장기 프로젝트의 시작을 알린다.', place = '예술의전당 [서울] 오페라극장' WHERE provider_type = 'PUBLIC' AND external_id = '393166';
UPDATE festival SET title = '이루이사 피아노 & 쳄발로 리사이틀: 바흐 건반음악전곡시리즈 Ⅲ', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '400836';
UPDATE festival SET title = '광대생각, 신작 창작연희극 <코공>', content = '', place = '서울돈화문국악당' WHERE provider_type = 'PUBLIC' AND external_id = '400737';
UPDATE festival SET title = '사진전 <兪 ; 그러하다>', content = '', place = '와이아트갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '403116';
UPDATE festival SET title = '연극 <강아지똥>', content = '권정생 원작의 깊은 감동을 무대에 담아, 작은 존재의 소중한 가치와 희망의 메시지를 전하며 온 가족이 함께 웃고 공감하는 따뜻한 가족공연', place = '세종문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '393008';
UPDATE festival SET title = '옴니버스 넌버벌 인형극 <환상공간>', content = '', place = '광진어린이공연장' WHERE provider_type = 'PUBLIC' AND external_id = '400846';
UPDATE festival SET title = '🌿엄마 말 안 듣는 우리 아이, 혹시 청개구리?! ''거꾸로 청개구리''🐸', content = '', place = '미로센터 [광주] 미로극장1관(신관)' WHERE provider_type = 'PUBLIC' AND external_id = '402968';
UPDATE festival SET title = '소리 : 성덕대왕신종', content = '성덕대왕신종, 오늘 우리의 소리로 다시 올리다. 성덕대왕신종을 ''보는 유물''이 아닌 ''듣는 유물''로 새롭게 만나는 공연', place = '국립중앙박물관 극장 용' WHERE provider_type = 'PUBLIC' AND external_id = '398630';
UPDATE festival SET title = '제4회 김지현 작곡발표회 <꿈의 세계>', content = '', place = '서울문화예술교육센터 서초 서울체임버홀' WHERE provider_type = 'PUBLIC' AND external_id = '402737';
UPDATE festival SET title = '차동수 초대 개인전 <마음 따라 떠나는 즐거운 나들이>', content = '', place = '복합문화예술공간MERGE' WHERE provider_type = 'PUBLIC' AND external_id = '403099';
UPDATE festival SET title = '뮤지컬 <더 스토리 오브 언더더씨>', content = '신비로운 바닷속 세계를 배경으로 토끼가 자라의 꾐에 빠져 용궁에 가는 이야기. 모험을 통한 우정과 지혜, 생명의 소중함과 해양환경의 가치를 전하는 신나는 가족뮤지컬!', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '393063';
UPDATE festival SET title = '[서울시립과학관] 2026 과학관 성인교육 ''호르몬 다이어리''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400977';
UPDATE festival SET title = '2026 상도어울마당 아트홀 개관 3주년 기획 프로그램 <상도 놀이터>', content = '', place = '상도어울마당 아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '402527';
UPDATE festival SET title = '창작ing 무용 <멈추고-17, 다시-19>', content = '움직임과 미디어의 실시간 교감을 통해 새로운 감각의 시각적 경험 구축', place = '국립정동극장 세실' WHERE provider_type = 'PUBLIC' AND external_id = '400667';
UPDATE festival SET title = 'piknic 무성영화극장, 뉴욕의 선창 & 색소포니스트 김성완', content = '', place = '피크닉' WHERE provider_type = 'PUBLIC' AND external_id = '401319';
UPDATE festival SET title = '푸르지오아트홀 수요초대석 47  바리톤 류승완 독창회– Tutto il Bel Canto!', content = '', place = '푸르지오아트홀 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '400517';
UPDATE festival SET title = '2026 서리풀 어울림 콘서트 [피아니스트 양지우의 with IN&OUT II]', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '402964';
UPDATE festival SET title = '[서울 강남] 러브레터 ', content = '', place = 'KT&G 상상마당 대치아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401865';
UPDATE festival SET title = '<정오의 음악회> 11월', content = '이금희 아나운서와 함께하는 브런치 데이트', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402026';
UPDATE festival SET title = '이희문 쏭폼스토리즈 Ⅱ <강남무지개>', content = '경기민요의 금맥을 잇는 파격의 아이콘 소리꾼 이희문의 달콤짭조름한 자전적 성장 스토리. 민요의 경계를 또 한 번 넘어서는 무대.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '402170';
UPDATE festival SET title = '수림뉴웨이브 2026 - 이나연 <귀류 歸流>', content = '', place = '김희수아트센터 SPACE 1' WHERE provider_type = 'PUBLIC' AND external_id = '397464';
UPDATE festival SET title = '한중일 융합예술 교류사업 <Collective Karma, Who is We?> 포럼 개최 안내', content = '', place = '정동1928 아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '402698';
UPDATE festival SET title = '시민문화ON페스타 <2026 부천 미디어 페스티벌>', content = '', place = '부천시민미디어센터' WHERE provider_type = 'PUBLIC' AND external_id = '402552';
UPDATE festival SET title = '국립무용단 <2026 안무가 프로젝트>', content = '국립무용단이 주목한 차세대 예술가들의 재기발랄한 실험과 도전, 반짝이는 상상력으로 제시하는 새로운 한국춤!', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402023';
UPDATE festival SET title = '<펄 벅의 여정 : 문학, 예술 그리고 인도주의> 연계 특강', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '403106';
UPDATE festival SET title = '[한국문화예술교육진흥원] 아르떼 아카데미 ''인문X예술'' 주제 연수', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '402762';
UPDATE festival SET title = '[부산] 위일청 & 양현경 콘서트: 노래가 머문 자리 ', content = '', place = '동래문화회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '401559';
UPDATE festival SET title = '[부산] 제106회 명품 콘서트, 바이올리니스트 김희정의 사계: 비발디 & 피아졸라', content = '', place = '을숙도문화회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '402083';
UPDATE festival SET title = '국립심포니콘서트오케스트라 심야음악회 <별 헤는 밤, 별 셋>', content = '늦은 저녁, 클래식이 일상의 틈으로 스며드는 순간. 객석과 가까이 호흡하는 섬세한 앙상블의 울림, 곡 사이사이 더해지는 해설과 시 한 편의 낭독이 함께하는 공연.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '402171';
UPDATE festival SET title = '토요명품', content = '전통 국악을 최적의 공간에서 가장 깊이 있고 다채롭게 만날 수 있는 국립국악원의 대표 주말 공연 <토요명품>한민족의 흥과 신명이 살아 숨 쉬는 노래와 음악, 춤을 비롯해세계가 인정한 유네스코 등재 무형문화유산까지.한국인과 외국인 모두 꼭 봐야할 한국의 전통 공연 예술이매주 토요일, 우면당 무대를 가득 채웁니다.대한민국 최고의 연주가들이 선사하는 <토요명품>을 통해 국악이가진 아름다움을 느껴보세요.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '402249';
UPDATE festival SET title = '제네시스와 함께하는 필라델피아 오케스트라 & 마린 알솝', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401641';
UPDATE festival SET title = '2026 동대문문화재단과 함께하는 <KBS교향악단 태교음악회>', content = '', place = '동대문구 아르코(DDM ARCO)' WHERE provider_type = 'PUBLIC' AND external_id = '402515';
UPDATE festival SET title = '서울특별시교육청 연계 교원 자율연수 <기념관에서 배우는 대한민국 임시정부>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '400680';
UPDATE festival SET title = '국립창극단 <2026 창극 작가 프로젝트 시연회>', content = '네 명의 작가 × 네 명의 작창가 = 네 편의 창극 신작 <서천> <깡철, 씨> <클리타임네스트라> <모차르트의 여덟 마디>', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '402018';
UPDATE festival SET title = '제네시스와 함께하는 필라델피아 오케스트라 & 마린 알솝 with 임윤찬', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401643';
UPDATE festival SET title = '[서울] Tiffany & Co.와 함께하는 필라델피아 오케스트라 & 마린 알솝 with 임윤찬', content = '', place = '롯데콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401664';
UPDATE festival SET title = '대전광역시 서예진흥원 <2026 송암서학회전>', content = '', place = '대전광역시 서예진흥원' WHERE provider_type = 'PUBLIC' AND external_id = '403177';
UPDATE festival SET title = '전태일 56주기 초청공연 <연극 전태일-네 이름은 무엇이냐>', content = '', place = '서강대 메리홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '402334';
UPDATE festival SET title = '정악단 정기공연 <영산회상>', content = '영산회상은 노래에서 기악곡으로, 하나의 선율에서 여러 악곡으로, 오랜 시간 연주되고 전승되면서 편성과 음역, 연주 방식에 따라 끊임없이 새로운 모습으로 변화해 온 풍류음악의 진수입니다. 수백 년 동안 변하면서도 사라지지 않은 음악, 영산회상. 국립국악원 정악단이 빚어내는 깊이 있는 오랜 시간의 변화를 만나보시기 바랍니다.', place = '국립국악원 예악당' WHERE provider_type = 'PUBLIC' AND external_id = '402252';
UPDATE festival SET title = '2026 창작ing 연극 <장소>', content = '"나는 누구로 남을 수 있을까." 1989년, 일본 오사카의 조선고급학교. 싸움의 힘이 곧 민족의 힘이었던 시절, 1학년 현장소에게 주어진 마지막 120초의 싸움.', place = '국립정동극장 세실' WHERE provider_type = 'PUBLIC' AND external_id = '402204';
UPDATE festival SET title = '[마포문화재단] 2026 M 초이스 연극 <투신 Two Scenes>', content = '', place = '마포아트센터 아트홀맥' WHERE provider_type = 'PUBLIC' AND external_id = '402346';
UPDATE festival SET title = '뮤지컬 ＜사의 찬미＞', content = '삶과 죽음의 경계에 선 자들의 마지막 선택! 격동의 시대 1926년, 한 척의 배 위에서 벌어진 의문의 동반 투신 사건. 조선 최초의 신극 운동을 이끈 천재 극작가 ‘김우진’. 조선 최초의 소프라노이자 일제강점기 신여성의 대표주자 ‘윤심덕’. 그리고 언제나 그들 곁에 존재했던 정체불명의 남자 ‘사내’. 엇갈린 사랑, 반복되는 비극, 설명되지 않는 죽음. 그들의 죽음을 둘러싼 숨겨진 진실을 추적하는 심리 서스펜스.', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '401963';
UPDATE festival SET title = '판소리음악극 <오버더떼창: 문전본풀이>', content = '', place = '트라이보울' WHERE provider_type = 'PUBLIC' AND external_id = '399785';
UPDATE festival SET title = '이서현 바이올린 독주회 "뭉크의 색채, 음악이 되다"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '396770';
UPDATE festival SET title = '국립심포니콘서트오케스트라 <드보르자크, 교향곡 9번 ''신세계로부터''>', content = '젊음과 이상, 새로운 세계를 향한 시선. 김성진 지휘, 김희재 피아노, 국립심포니콘서트오케스트라 연주로 만나는브람스의 활기, 슈만의 깊은 서정, 드보르자크의 장대한 동경.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '402172';
UPDATE festival SET title = '테너 최원혁 리사이틀 〈Romantic & Verismo〉 Dramatic Tenor Series II – Songs of Becoming', content = '', place = '광주시문화예술의전당 맹사성홀' WHERE provider_type = 'PUBLIC' AND external_id = '402348';
UPDATE festival SET title = '[세종] 국립심포니콘서트오케스트라 <드보르자크, 교향곡 9번 ''신세계로부터''>', content = '독일 학생들의 노래를 경쾌하게 풀어낸 브람스의 〈대학 축전 서곡〉, 피아노와 오케스트라의 긴밀한 조화가 돋보이는 슈만의 피아노 협주곡, 그리고 드보르자크의 교향곡 9번 ‘신세계로부터’를 한 무대에서 선보입니다.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '402196';
UPDATE festival SET title = '<완창판소리> 11월', content = '판소리 다섯 바탕을 한 명의 소리꾼이 처음부터 끝까지 펼쳐 보이는, 오랜 전통의 힘과 묵직한 감동을 느낄 수 있는 공연', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402030';
UPDATE festival SET title = '창작가무극 <백범>', content = '백범 탄생 150주년·서울예술단 40주년 기념 공연 우리가 기억해야 할 이름은  단 한 사람뿐이었을까? 가장 평범한 이름으로 시작된 모두의 역사 지루한 위인전은 찢었다. 2026년, 가장 뜨겁고 젊은 백범이 온다. 영웅의 역사가 아닌 위인전 속에 박제된 한 사람의 신화에서 벗어나, 시대와 치열하게 부딪쳤던 청년의 뜨거운 고뇌를 그려낸다. 이름 없는 사람들의 역사 어둠 속에서 독립과 해방을 위해 피 흘린 수많은 민초들의 숨결과 분노가 무대 위에서 살아 움직인다. 그리고 그들이 선택한 이름, 백범  평범한 백성(白)과 범부(凡)가 모여 이뤄낸 거대한 물결, 오늘을 살아가는 우리 모두의 이야기로 다시 태어난다.', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '400988';
UPDATE festival SET title = '2026 성남아트센터 오페라 정원 <라 보엠>', content = '2026 성남아트센터 <오페라 정원>의 마지막 무대, 푸치니 <라 보엠>으로 만나는 사랑과 우정, 이별의 감동.', place = '성남아트센터 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401029';
UPDATE festival SET title = '[한국문화예술교육진흥원] 2026 청소년 인문캠프 <문문문> (14~19세)', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '402865';
UPDATE festival SET title = '국립심포니콘서트오케스트라 <드보르자크, 교향곡 9번 ''신세계로부터''>', content = '"국립심포니오케스트라가 창단한 청년 중심 오케스트라"  독일 학생들의 노래를 경쾌하게 풀어낸 브람스의 〈대학 축전 서곡〉, 피아노와 오케스트라의 긴밀한 조화가 돋보이는 슈만의 피아노 협주곡, 그리고 드보르자크의 교향곡 9번 ‘신세계로부터’를 한 무대에서 선보인다.', place = '포천반월아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '402195';
UPDATE festival SET title = '제주특별자치도립 서귀포관악단 2026 청소년·대학생 협주곡의 밤', content = '', place = '서귀포예술의전당 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '401198';
UPDATE festival SET title = '국립합창단 기획공연 <신진지휘자 초청연주회>', content = '국립합창단과 차세대 합창지휘자 염혜경·임수진이 함께하는 무대. 남성·여성·혼성합창의 다채로운 레퍼토리를 통해 두 지휘자의 개성 있는 해석과 음악적 감각을 선보인다.', place = '예술의전당 IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '401940';
UPDATE festival SET title = '2026 고음악 오디세이 <음악의 언어"수사학_Rhetoric">', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399798';
UPDATE festival SET title = '수원시립합창단 제197회 정기연주회 <하늘, 바람, 별 그리고 詩>', content = '', place = '수원SK아트리움 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '402887';
UPDATE festival SET title = '제47회 서울무용제_명작무극장', content = '명작무극장 : 협회 공식 지정 ‘명작무’의 계승과 우수성을 알리는 무대', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '402193';
UPDATE festival SET title = '경기시나위오케스트라 <젊은명인 : Young Virtuoso>', content = '창단 30주년을 맞은 경기시나위오케스트라 공연으로 한국음악의 내일을 빛낼 젊은 명인의 새로운 감각과 개성이 더해진 특별한 협연 무대', place = '경기국악원 국악당' WHERE provider_type = 'PUBLIC' AND external_id = '401482';
UPDATE festival SET title = '제47회 서울무용제_경연대상', content = '경연대상 : 서울무용제 ‘올해의 춤 작가’로 선정된 빛나는 안무가  4인의 열정과 예술혼이 녹아든 대작!  안무가로서 위상을 드높일 무대! #랑만(기무간) - 그것을 우리는 사랑이라 부른다 #가림다댄스컴퍼니(최재혁) - 인(仁)의 상실  #프로젝트 창(최자인) - 새벽 #댄스PRO젝트점선면(한정미) - 실컷, 유토피아', place = '아르코예술극장 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '402194';
UPDATE festival SET title = '[PAC] 유니버설발레단 <호두까기 인형>', content = '', place = '평택아트센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '397099';
UPDATE festival SET title = '예술의전당 토요콘서트 - 프리뷰 베토벤(11월)', content = '베토벤 피아노 협주곡 제2번, 강렬한 ''운명''의 울림이 빛나는 교향곡 제5번을 만나는 시간', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401068';
UPDATE festival SET title = '오페라 카르멘  < 정열>', content = '', place = '성남아트리움 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '399234';
UPDATE festival SET title = 'THE LEGEND CONCERT <015B 콘서트>', content = '지금은 아련한 기억 속에 남은 90년대의 음악. 015B만의 독창적인 감성과 깊이 있는 음악을 다시 만나다.', place = '용인시문예회관 처인홀' WHERE provider_type = 'PUBLIC' AND external_id = '401934';
UPDATE festival SET title = '[서울남산국악당] 불세출 <일상풍류방>', content = '', place = '서울남산국악당 크라운해태홀' WHERE provider_type = 'PUBLIC' AND external_id = '402971';
UPDATE festival SET title = '송윤진 피아노 독주회 “Fantasy-Scenes”', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '400757';
UPDATE festival SET title = '국립심포니오케스트라 6 첼리스트 <실내악 시리즈 III>', content = '때론 먹의 농담으로만 완성된 수묵화가 그 어떤 화려한 빛을 쏟아내는 그림보다 묵직하다. 무채색으로 휘갈긴 선들의 향연이 높은 해상도를 자랑하는 그 어느 질 좋은 사진보다 더 큰 경이를 일으킨다. 첼로 앙상블의 매력이 바로 그런 것이다. 첼로만으로 빚어내는 단일한 질감은 외려 연주자 개개인의 고유한 빛깔을 가장 선명하게 발산한다.  박수인(음악학자)', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '402187';
UPDATE festival SET title = '장은주 피아노 독주회 "EVOCATION - 회상"', content = '', place = '세종문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '402866';
UPDATE festival SET title = '현대무용 기획공연 <소년의 외침은 파도로 번져>', content = '', place = '포스트극장' WHERE provider_type = 'PUBLIC' AND external_id = '400677';
UPDATE festival SET title = '[함께걷는아이들] 제14회 올키즈스트라 정기연주회 <Overture>', content = '', place = '고양아람누리 아람음악당' WHERE provider_type = 'PUBLIC' AND external_id = '403087';
UPDATE festival SET title = '다담', content = '2월부터 11월까지 매월 마지막 주 수요일 오전 11시에는 국악과 차, 그리고 이야기가 함께하는 <다담>이 열립니다.다담지기 황수경 아나운서의 진행으로 예술같은 삶을 살고 있는사회 각 분야의 저명 인사를 초청해 이야기와 우리 음악을 나누는토크 콘서트 입니다.진솔한 삶의 이야기에 더해지는 우리 음악 한 잔!오전의 설레이는 햇살 같은 특별한 시간을 느껴보세요.', place = '국립국악원 우면당' WHERE provider_type = 'PUBLIC' AND external_id = '402250';
UPDATE festival SET title = '2026 브릿지 클래식 2 - Light : 빛의 선율', content = '강원대학교 음악학과 교수이자 국내 정상급 바이올리니스트 이석중과 춘천지역을 대표하는 예술단체 춘천시립교향악단의 현악 수석·단원들이 함께 만드는 특별한 무대! 바로크 음악의 대표작 비발디 「사계」를 통해 봄의 생동감부터 여름의 격정, 가을의 풍요로움, 겨울의 날카로운 정취까지 네 계절의 변화가 현악기의 풍성한 울림으로 펼쳐진다.', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '401965';
UPDATE festival SET title = '관현악시리즈 II <2026 디스커버리>', content = '클래식계의 젊은 거장, 홍석원 지휘자가 발견한 국악의 새로운 매력! 국립국악관현악단의 섬세한 연주로 잠재된 우리의 감각을 새롭게 깨워줄 공연', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402028';
UPDATE festival SET title = 'ASAC 클래식 구자범의 <가을 콘서트 렉쳐>', content = '지휘자 구자범이 직접 피아노를 연주하며 강의하는 콘서트 렉쳐', place = '안산문화예술의전당 별무리극장' WHERE provider_type = 'PUBLIC' AND external_id = '402181';
UPDATE festival SET title = '창작음악극 <가명>', content = '', place = '꿈의숲아트센터 퍼포먼스홀' WHERE provider_type = 'PUBLIC' AND external_id = '402754';
UPDATE festival SET title = '민속악단 정기공연 <풍화風化>', content = '자연의 풍화 작용처럼 한 세대의 음악이 다음 세대로 이어져 온 민속악의 전승 과정을 담아낸 이번 공연은 45년간 축적된 민속기악의 역사와 예술성을 조명하는 무대입니다. 1981년 초연된 ‘남도굿거리·성주풀이·육자배기·흥타령’과 ‘산조’를 관악·현악·타악의 다채로운 음색과 47인 연주자들의 호흡으로 새롭게 풀어내며, 민속기악합주의 진수를 선보입니다. 시간을 품고 다듬어져 온 대표 레퍼토리를 통해 민속악의 깊이와 생명력, 그리고 오늘까지 이어져 온 전통의 의미를 만나볼 수 있습니다.', place = '국립국악원 예악당' WHERE provider_type = 'PUBLIC' AND external_id = '402253';
UPDATE festival SET title = '국립창극단 <오이디푸스>', content = '여성 소리꾼들이 왕과 왕비, 예언자와 증인이 되어 비극을 빚어낸다. 진실을 좇는 오이디푸스, 그가 끝내 마주할 것은 무엇일까.', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402019';
UPDATE festival SET title = '코레오 커넥션: 서울', content = '지역 안무가와 함께 춤의 가능성을 확장해온 국립현대무용단 <코레오 커넥션: 서울> 기은주, 김현재, 안선희 안무가의 작품을 통해 몸에 축적된 시간과 흔적 그 사이에서 끊임없이 변화하는 몸의 가능성을 탐색한다.', place = '예술의전당 자유소극장' WHERE provider_type = 'PUBLIC' AND external_id = '401708';
UPDATE festival SET title = 'ASAC 청소년 연극 <유원>', content = '제13회 창비청소년문학상 수상작 원작! 모순투성이 마음을 딛고 날아오르는 모든 이를 위한 성장 이야기', place = '안산문화예술의전당 달맞이극장' WHERE provider_type = 'PUBLIC' AND external_id = '402182';
UPDATE festival SET title = '국립극장 마당놀이 <춘풍처도 온다>', content = '허랑방탕한 춘풍을 잡으러, 조선판 여장부 ''춘풍처''가 떴다! 대한민국 대표 소리꾼 박애리와 정은혜, 서로 다른 매력의 두 춘풍처를 기대하시라!', place = '국립극장 하늘극장' WHERE provider_type = 'PUBLIC' AND external_id = '402024';
UPDATE festival SET title = '오페라 스타파티 <돈죠반니의 초대>', content = '', place = '평택남부문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '401793';
UPDATE festival SET title = '경기도무용단 기획공연 <태평의 춤>', content = '경기도무용단의 춤과 경기시나위오케스트라의 음악이 어우러지는 무대. 궁중무용의 우아함과 민속춤의 흥과 신명으로 새해의 평안과 안녕을 기원한다.', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '401484';
UPDATE festival SET title = '건우회 제16회 정기연주회 "Beethoven Symphony"', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '398898';
UPDATE festival SET title = '허은 피아노 독주회 "향음환상 香音幻想"', content = '', place = '일신홀' WHERE provider_type = 'PUBLIC' AND external_id = '402045';
UPDATE festival SET title = '이수빈 하프 리사이틀 <거인, Titan>', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '402882';
UPDATE festival SET title = '[서울] 국립심포니콘서트오케스트라 <베토벤, 교향곡 9번 ''합창''>', content = '오케스트라의 웅장한 울림과 마지막 악장에서 독창과 합창이 더해지는 베토벤 교향곡 9번 ‘합창’을 선보입니다. KNCO의 여정을 마무리하며 음악이 전하는 화합과 환희의 메시지로 대미를 장식합니다.', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402197';
UPDATE festival SET title = '2026 국립정동극장 예술단 <아리랑>', content = '2026 국립정동극장 예슬단 신작, 10곡의 뉴-아리랑으로 만나는 대륙횡단열차 탑승기', place = '국립정동극장' WHERE provider_type = 'PUBLIC' AND external_id = '400669';
UPDATE festival SET title = '국립심포니콘서트오케스트라 <베토벤, 교향곡 9번 ''합창''>', content = '한 해의 끝에서, 다시 함께 부르는 노래. 김성진 지휘, 소프라노 박소영, 메조소프라노 김정미, 테너 김효종, 베이스 송일도, 국립심포니콘서트오케스트라 연주로 만나는 베토벤 교향곡 9번 ''합창''.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '402175';
UPDATE festival SET title = '서리풀 고음악 시리즈 <바로크 노엘>', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399784';
UPDATE festival SET title = '[세종] 국립심포니콘서트오케스트라 <베토벤, 교향곡 9번 ''합창''>', content = '오케스트라의 웅장한 울림과 마지막 악장에서 독창과 합창이 더해지는 베토벤 교향곡 9번 ‘합창’을 선보입니다. KNCO의 여정을 마무리하며 음악이 전하는 화합과 환희의 메시지로 대미를 장식합니다.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '402200';
UPDATE festival SET title = '[안트로폴리스Ⅴ] <안티고네/에필로그>', content = '마침내 완성되는 테베의 핏빛 신화! 야성적인 무대로 한국 연극계에 반향을 일으킨 [안트로폴리스] 시리즈의 장엄한 피날레가 펼쳐진다.', place = '국립극단 [명동] 명동예술극장' WHERE provider_type = 'PUBLIC' AND external_id = '402017';
UPDATE festival SET title = '국립오페라단 정기공연 <돈 카를로스 Don Carlos>', content = '국립오페라단은 2026년 정기공연의 마지막 작품으로 베르디의 오페라〈돈 카를로스〉를 무대에 올린다. 총 5막으로 구성된 이 작품은 19세기 그랜드 오페라의 정점으로 꼽히는 오페라로, 스페인 제국이 최전성기를 구가하던 시대를 배경으로 사랑과 권력, 자유와 억압에 대한 궁정 비극을 그린 그랜드 오페라이다. 한 여인을 둘러싼 아들과 아버지의 대립은 개인의 사랑을 넘어 국가와 이념의 문제로 확장되며, 궁정은 거대한 갈등의 무대로 변모한다. 이번 무대는 프랑스어로 진행되며, 지휘는 2022년 <아틸라>로 인연을 맺은 발레리오 갈리가 맡아 베르디 음악의 극적 에너지를 펼쳐낸다. 연출은 파리 오페라, 라 스칼라 극장, 빈 국립오페라극장, 로열 오페라 하우스 코벤트 가든 등 세계 유수의 오페라 극장과 페스티벌 무대를 섭렵한 세계적 오페라 연출가 야니스 코코스가 맡아, 스페인 궁정의 권력 구조와 인물들의 비극적 운명을 밀도 높은 무대로 그려낸다.', place = '예술의전당 오페라극장' WHERE provider_type = 'PUBLIC' AND external_id = '402191';
UPDATE festival SET title = '국립심포니오케스트라 <멘델스존, 교향곡 3번 ''스코틀랜드''>', content = '풍요로운 문화적 환경 속에서 성장한 펠릭스 멘델스존은 일찍이 비범한 재능을 드러냈지만, 그에게 중요한 것은 조건이나 명성이 아니라 자신이 보고 듣고 느낀 세계를 음악으로 옮기는 일이었다. 감상에 머무르지 않고 창작으로 스스로를 증명하려는 태도는 그의 작품 전반을 관통한다. 이번 프로그램은 그러한 멘델스존의 시선에서 출발해, 젊은 천재의 기지와 상상력이 응축된 현악 8중주 스케르초, 여행의 기억을 교향적 서사로 확장한 교향곡 3번 ''스코틀랜드''로 이어진다. 그 사이에는 멘델스존 이후 세대가 바라본 음악의 또 다른 가능성, 부소니의 세련된 형식미와 달바비의 현대적 감각이 플루트를 매개로 펼처진다. 시대와 언어는 달라도, 보고 듣고 느낀 세계를 자신만의 음악으로 옮기려는 열망은 하나의 흐름으로 이어지며 오늘의 무대를 완성한다.', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '402188';
UPDATE festival SET title = '<정오의 음악회> 12월', content = '이금희 아나운서와 함께하는 브런치 데이트', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402027';
UPDATE festival SET title = '더블 빌: 허성임 & 레아 티라바소', content = '각기 다른 움직임이 교차하며 서로를 잇고, 함께 일어서 뛰어오르는 몸들. 흔들림 속에서 관계를 맺으며 흩어진 몸들은 마침내 하나의 흐름이 된다. 인간 존재를 향한 예리한 시선으로 밀도 있고 강렬한 몸의 언어를 선보여 온 허성임과 레아 티라바소, 두 안무가의 세계를 2026 청년교육단원의 무대를 통해 만난다.', place = '예술의전당 [서울] 자유소극장' WHERE provider_type = 'PUBLIC' AND external_id = '402685';
UPDATE festival SET title = 'ASAC 뮤지컬 <오지게 재밌는 가시나들>', content = '작품상(400석 미만), 극본상, 연출상 2025 제10회 한국뮤지컬어워즈 3관왕 인기 다큐멘터리 <칠곡 가시나들>의 감동이 뮤지컬로 재탄생하다.', place = '안산문화예술의전당 달맞이극장' WHERE provider_type = 'PUBLIC' AND external_id = '402184';
UPDATE festival SET title = '리트플레이 <겨울나그네>', content = '슈베르트의 연가곡 〈겨울나그네〉 24곡을 음악과 연극으로 새롭게 풀어낸 무대', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '401890';
UPDATE festival SET title = '조인혁 클라리넷 리사이틀 <Sentimental>', content = '', place = '예술의전당 [서울] IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '402965';
UPDATE festival SET title = '창작ing 연극 <멜로드라마 열차>', content = '열차에 올라탄 사랑의 멜로드라마', place = '국립정동극장 세실' WHERE provider_type = 'PUBLIC' AND external_id = '400668';
UPDATE festival SET title = '한국·벨기에 수교 125주년 기념음악회', content = '피아니스트 발레르 뷔르농과 첼리스트 문태국, 두 연주자의 섬세한 호흡과 깊이 있는 선율이 어우러져 음악으로 이어지는 125년의 특별한 울림', place = '예술의전당 IBK기업은행챔버홀' WHERE provider_type = 'PUBLIC' AND external_id = '401066';
UPDATE festival SET title = '국립합창단 <한국 가곡의 모든 것>', content = '한국 가곡의 과거와 현재를 한 무대에서 만나다. 국립합창단의 깊이 있는 화음에 섬세하고 청아한 음색의 소프라노 강혜정, 풍부한 성량과 깊은 울림의 바리톤 강형규, 오케스트라의 선율이 더해져 한국 가곡의 아름다움을 전한다.', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402842';
UPDATE festival SET title = '[수원] 경기필 마스터피스 시리즈 VI <무소륵스키 전람회의 그림>', content = '경기필 2026 시즌의 마지막 공연으로, 지휘자 지중배와 바이올린 김서현의 협연으로 클래식 공연의 진수를 선보인다.', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '401485';
UPDATE festival SET title = '[평택] [PAC] 이은결 30주년 <ONE OF ONE>', content = '', place = '평택아트센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '396316';
UPDATE festival SET title = '<2026 윈터콘서트>', content = '국악관현악의 풍성하고 포근한 연주 속에서, 사랑하는 사람들과 함께 잊지 못할 연말의 감동을 채워보세요!', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402029';
UPDATE festival SET title = '2026 고음악 오디세이 <음악의 언어 "극장_Theatrum">', content = '', place = '반포심산아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399788';
UPDATE festival SET title = '[서울] 경기필 마스터피스 시리즈 VI <무소륵스키 전람회의 그림>', content = '''경기필 2026 시즌의 마지막 공연으로, 지휘자 지중배와 바이올린 김서현의 협연으로 클래식 공연의 진수를 선보인다.', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401530';
UPDATE festival SET title = '이자람 판소리 <눈, 눈, 눈>', content = '톨스토이의 단편 『주인과 일꾼』을 재해석한 이자람의 판소리. 광활한 설원을 배경으로 소리와 재담, 북장단이 어우러져 삶과 인간을 이야기한다.', place = '경기아트센터 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '401593';
UPDATE festival SET title = '국립합창단 제210회 정기연주회 <헨델 메시아>', content = '국립합창단이 선사하는 헨델의 불멸의 걸작〈메시아〉. 장엄한 합창과 아름다운 선율로 절망에서 희망으로, 고난에서 환희로 나아가는 감동의 대서사를 펼친다.', place = '예술의전당 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401941';
UPDATE festival SET title = '윈터 마티네(Winter Matinée) <송영훈의 4 첼리스트>', content = '송영훈과 세 명의 첼리스트가 클래식부터 영화음악, 캐럴까지 네 대의 첼로로 전하는 따뜻한 겨울 이야기', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '401891';
UPDATE festival SET title = '국립극장 기획 <다정히 세상을 누리면>', content = '1811년 조선, 세상을 뒤집겠다고 사람들이 들고일어났다.그리고 한 마리 개가 이것을 목격한다!', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402020';
UPDATE festival SET title = '함안문화예술회관 하우스콘서트, 김재영 & 유성호 (5월)', content = '', place = '함안문화예술회관  대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '377948';
UPDATE festival SET title = '연극 ＜킬미 나우＞', content = '사랑하는 사람을 더 이상 돌볼 수 없을때, 우리는 서로를 어떻게 지켜야 할까? 뜨거운 감동, 묵직한 메시지. 연극열전이 제작한 명품연극 <킬미나우>. 2016년 국내 초연 당시 전 회차 기립박수, 평균 객석점유율 95%를 기록하며 이후 재공연을 통해 검증된 작품. 2026년, 여전히 유효한 질문과 더욱 깊어진 울림으로 관객을 만난다.', place = '춘천문화예술회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '401966';
UPDATE festival SET title = '연극 <더 드레서>', content = '대한민국 최고 배우들의 압도적인 연기 앙상블. 막이 오르기 전, 무대 뒤에서 벌어지는 진짜 이야기. 무대 뒤 찬란하고도 치열한 연극의 세계.', place = '세종예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '402177';
UPDATE festival SET title = '이자람 판소리 갈라 시리즈 <바탕>', content = '소리꾼 이자람의 깊이 있는 소리와 해석으로 만나는 전통 판소리의 진정한 맛과 멋', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '401893';
UPDATE festival SET title = '국립무용단 <향연>', content = '2015년 초연 이래 연일 매진으로 ''한국춤 신드롬''을 불러일으킨 한국무용의 독보적인 브랜드, 정구호 연출의 <향연>', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402025';
UPDATE festival SET title = '2026 필하모닉스 내한공연', content = '빈·베를린 필하모닉 단원들이 함께하는 필하모닉스! 클래식과 재즈, 팝을 넘나드는 유쾌한 앙상블', place = '강동아트센터 대극장 한강' WHERE provider_type = 'PUBLIC' AND external_id = '401894';
UPDATE festival SET title = 'ASAC 클래식 구자범의 겨울음악회 <Melancholy in Christmas>', content = '매서운 겨울, 길거리의 들뜬 소리에서 벗어나 벽난로 옆의 따듯한 소리로 중세 캐롤부터 현대 성탄 레파토리를 아울러, 고요하고 처연한 음악을 들려준다.', place = '안산문화예술의전당 달맞이극장' WHERE provider_type = 'PUBLIC' AND external_id = '402185';
UPDATE festival SET title = '국립창극단 <2026 송년판소리-소리정담>', content = '국가무형문화재 ''적벽가'' 예능보유자 윤진철 명창의 깊은 소리와 진솔한 삶의 이야기를 가까이에서 만나는 시간.', place = '국립극장 달오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402021';
UPDATE festival SET title = 'ASAC 콘서트 <주현미, 가요 100년을 노래하다>', content = '대한민국 대중음악의 살아있는 전설 주현미가 전하는, 우리 삶과 애환이 담긴 한국 가요 100년의 감동 무대!', place = '안산문화예술의전당 달맞이극장' WHERE provider_type = 'PUBLIC' AND external_id = '402186';
UPDATE festival SET title = 'PLAY:LIST <정준일 X 신인류 콘서트>', content = '서로 다른 음악적 색깔을 가진 두 아티스트 정준일, 신인류의 대표곡과 특별한 무대를 통해 한 해의 마지막을 음악으로 채운다.', place = '경기아트센터 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '402782';
UPDATE festival SET title = '국립창극단 <2026 송년음악회-어질더질>', content = '국립창극단 대표 레퍼토리의 명장면, 명곡으로 마무리하는 2026년 마지막 밤. 웃음과 감동, 희망과 설렘이 함께하는 갈라 콘서트.', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '402022';
UPDATE festival SET title = '경상남도, 치앙마이 춤의 동행: 꽃과 축제의 땅, 치앙마이 & 경남', content = '', place = '경상남도문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '375180';
UPDATE festival SET title = '함안문화예술회관 클래식 시리즈 Ⅲ. 백건우 & 슈베르트', content = '', place = '함안문화예술회관  대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '374990';
UPDATE festival SET title = '[김해] 어린이 연극 <어디로 가야 하지?>', content = '', place = '김해문화의전당 누리홀' WHERE provider_type = 'PUBLIC' AND external_id = '380068';
UPDATE festival SET title = '''고향의 봄'' 창작 100주년 기념 교성곡: 고향의 봄', content = '', place = '경상남도문화예술회관 로비' WHERE provider_type = 'PUBLIC' AND external_id = '380377';
UPDATE festival SET title = '[창원] 국립국악원 <연희 (人) - 판>', content = '', place = '성산아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '383325';
UPDATE festival SET title = '[경남] 손열음 & 고잉홈프로젝트', content = '', place = '경상남도문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '383601';
UPDATE festival SET title = '[창원] 2026모닝콘서트, 뮤지컬 ‘명성황후’의 고종황제 테너 박완 with Sarah J트리오 ‘여름을 깨우는 하모니’ (7월)', content = '', place = '성산아트홀 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '386465';
UPDATE festival SET title = '[사천] 지브리&디즈니 OST FESTA', content = '', place = '사천문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '386459';
UPDATE festival SET title = '[산청] 판타지 발레 <구미호> ', content = '', place = '산청문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '385228';
UPDATE festival SET title = '2026 지역전시 활성화 사업 <펫아트뮤지엄>  ', content = '', place = '밀양아리랑아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '394070';
UPDATE festival SET title = '[창원] 코믹오페라 <놀부전> ', content = '', place = '성산아트홀 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '387331';
UPDATE festival SET title = '제26회 밀양공연예술축제, 뮤지컬 You & It', content = '', place = '밀양아리랑아트센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '387087';
UPDATE festival SET title = '이성륙·최가효 《맞닿은 살, 숨 쉬는 세계》', content = '', place = '프로젝트 아이' WHERE provider_type = 'PUBLIC' AND external_id = '393258';
UPDATE festival SET title = '[거제] 가무백희악극 <토끼, 날다!> ', content = '', place = '거제문화예술회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '389759';
UPDATE festival SET title = '[창원] 미디어아트 콘서트 <빈센트 반 고흐, 별을 닮다> ', content = '', place = '성산아트홀 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '390031';
UPDATE festival SET title = '[거제] 창작뮤지컬 <거제도> ', content = '', place = '거제문화예술회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '390508';
UPDATE festival SET title = '국악 <영남의 전통예술, 밀양이 잇다Ⅰ: 동래야류 겨루기>', content = '', place = '밀양아리랑아트센터 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '395529';
UPDATE festival SET title = '[사천] 가무백희악극 <토끼, 날다! >', content = '', place = '사천문화예술회관 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '391215';
UPDATE festival SET title = '[창원] 가족오페라 <해와 달이 될뻔한 오누이> ', content = '', place = '성산아트홀 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '393750';
UPDATE festival SET title = '[밀양] 창작하는 타루 소리극 <두아: 유월의 눈>', content = '', place = '밀양아리랑아트센터 대공연장' WHERE provider_type = 'PUBLIC' AND external_id = '394690';
UPDATE festival SET title = '[거제] 경남도립극단 순회공연 <반야 삼촌> ', content = '', place = '거제문화예술회관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '393699';
UPDATE festival SET title = '[창원] 창원시립예술단 창작뮤지컬 ''겨울 건너 봄''', content = '', place = '성산아트홀 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '395717';
UPDATE festival SET title = '두암 김용두 기증 30년 기념 특별전 ''나의 인생 박물관''', content = '', place = '국립진주박물관' WHERE provider_type = 'PUBLIC' AND external_id = '377787';
UPDATE festival SET title = '[밀양] 영남의 전통예술, 밀양이 잇다Ⅱ: 밀양백중놀이&밀양법흥상원놀이 겨루기', content = '', place = '밀양아리랑아트센터 소공연장' WHERE provider_type = 'PUBLIC' AND external_id = '396838';
UPDATE festival SET title = '장건율·정진경 《달과 포도 Moon and Grapes》', content = '', place = '프로젝트 아이' WHERE provider_type = 'PUBLIC' AND external_id = '401650';
UPDATE festival SET title = '[창원] 2026모닝콘서트 - 10월 트리오바스의 ''실내악살롱콘서트''', content = '', place = '성산아트홀 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '398262';
UPDATE festival SET title = '고려청자박물관 특별전 <보배로운 달빛, 월남사月南寺>', content = '', place = '고려청자박물관' WHERE provider_type = 'PUBLIC' AND external_id = '354396';
UPDATE festival SET title = '하정웅청년작가초대전 <빛 2025>', content = '', place = '광주시립미술관 하정웅미술관' WHERE provider_type = 'PUBLIC' AND external_id = '357450';
UPDATE festival SET title = '박물관 하반기 기획전 <기억의 윤리, 평화의 언어>', content = '', place = '광주역사민속박물관' WHERE provider_type = 'PUBLIC' AND external_id = '362891';
UPDATE festival SET title = '기획전시 《확장의 순간 : 설박·이성경》', content = '', place = '함평군립미술관' WHERE provider_type = 'PUBLIC' AND external_id = '366898';
UPDATE festival SET title = '《파편의 파편: 박치호·정광희》', content = '', place = '국립아시아문화전당 문화창조원 복합 6관' WHERE provider_type = 'PUBLIC' AND external_id = '367839';
UPDATE festival SET title = '[광주광역시 남구 이강하미술관] 3·1만세운동 기념 전시 《결연한 기록들》', content = '', place = '이강하 미술관' WHERE provider_type = 'PUBLIC' AND external_id = '369658';
UPDATE festival SET title = '해동문화예술촌 어린이 체험형 예술전시 ''장미 작가와 함께하는 마음보관소'' 展', content = '', place = '해동문화예술촌' WHERE provider_type = 'PUBLIC' AND external_id = '373043';
UPDATE festival SET title = '2026년 어린이 단체 교육 프로그램 ''학교 밖 아시아 여행''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '368045';
UPDATE festival SET title = '하세연 첼로 독주회 "결"', content = '', place = '예술의전당 [서울] 리사이틀홀' WHERE provider_type = 'PUBLIC' AND external_id = '397247';
UPDATE festival SET title = 'GOOD MORNING MR. PAIK & JUNG - 정기용 컬렉션: 백남준, 존 케이지, 요제프 보이스가 그린 우정의 지도', content = '', place = '전남미술관' WHERE provider_type = 'PUBLIC' AND external_id = '375306';
UPDATE festival SET title = '[광주] 베토벤 & 라흐마니노프 ', content = '', place = '광주예술의전당 대극장' WHERE provider_type = 'PUBLIC' AND external_id = '372091';
UPDATE festival SET title = '서빛마루문예회관 기획공연, 명작콘서트 ''Wind On Stage''', content = '', place = '서빛마루문화예술회관' WHERE provider_type = 'PUBLIC' AND external_id = '373542';
UPDATE festival SET title = '윤재천 개인전 <인간, 희망>', content = '', place = 'KR갤러리' WHERE provider_type = 'PUBLIC' AND external_id = '378368';
UPDATE festival SET title = '폴란드 포스터전 <침묵, 그 고요한 외침>', content = '1950–1960년대, 세계 그래픽 디자인의 흐름을 바꾼 ‘폴란드 포스터 학파’를 만나는 특별한 순간!', place = '국립아시아문화전당 문화창조원 복합 1관' WHERE provider_type = 'PUBLIC' AND external_id = '375523';
UPDATE festival SET title = '[광주광역시 남구 이강하미술관] 5·18광주민주화운동 특별전시 《새로운 창작, 미래의 숨결》', content = '', place = '이강하 미술관' WHERE provider_type = 'PUBLIC' AND external_id = '381179';
UPDATE festival SET title = '한국예술종합학교 수요영화관 <도그맨>', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '403187';
UPDATE festival SET title = '[여수] 국립심포니오케스트라 <피터와 늑대 & 어미 거위> ', content = '', place = '예울마루' WHERE provider_type = 'PUBLIC' AND external_id = '378825';
UPDATE festival SET title = '연극 <백조의 노래> (6.17~6.27)', content = '', place = '예린소극장' WHERE provider_type = 'PUBLIC' AND external_id = '383620';
UPDATE festival SET title = '이경옥개인전 ''자연의 결, 마음의 결''', content = '', place = '남도향토음식박물관' WHERE provider_type = 'PUBLIC' AND external_id = '387832';
UPDATE festival SET title = '뮤지컬 <피아노의 숲> ', content = '', place = '국립아시아문화전당 극장1' WHERE provider_type = 'PUBLIC' AND external_id = '387046';
UPDATE festival SET title = '제29회 광주소극장축제, 피아노&캔들 콘서트', content = '', place = '광주아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390704';
UPDATE festival SET title = '제29회 광주소극장축제, 연극 <양팔저울>', content = '', place = '공연일번지' WHERE provider_type = 'PUBLIC' AND external_id = '390070';
UPDATE festival SET title = '전남광주통합특별시립교향악단, 체임버 시리즈 Ⅴ ‘Brass ＆ Beat’', content = '', place = '광주예술의전당' WHERE provider_type = 'PUBLIC' AND external_id = '390067';
UPDATE festival SET title = '[곡성] 유앤잇 (YOU&IT) ', content = '', place = '곡성레저문화센터 동악아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '390867';
UPDATE festival SET title = '국립남도국악원 토요상설: 국악이 좋다, 이선화의 진도·琴·歌', content = '', place = '국립남도국악원 진악당' WHERE provider_type = 'PUBLIC' AND external_id = '391034';
UPDATE festival SET title = '2026 한국근현대미술명작전 <시선>', content = '', place = '함평군립미술관' WHERE provider_type = 'PUBLIC' AND external_id = '396417';
UPDATE festival SET title = '2026년 한국수중발굴 50년 기념 특별전 <바다를 건넌 나무, 자단>', content = '', place = '국립해양문화재연구소 목포해양유물전시관' WHERE provider_type = 'PUBLIC' AND external_id = '399972';
UPDATE festival SET title = '[광주] 김주상 & 한규호 듀오 리사이틀: 두 명의 피아니스트가 연주하는 모차르트', content = '', place = '아트스페이스 흥학관' WHERE provider_type = 'PUBLIC' AND external_id = '397645';
UPDATE festival SET title = '[경주] WEST&EAST 서쪽남자 동쪽여자', content = '', place = '경주예술의전당 대공연장(화랑홀)' WHERE provider_type = 'PUBLIC' AND external_id = '399924';
UPDATE festival SET title = '[남산골한옥마을] 2026 남산골 한옥콘서트 <시공이음>', content = '', place = '남산골한옥마을 민씨가옥' WHERE provider_type = 'PUBLIC' AND external_id = '398587';
UPDATE festival SET title = '2026 펄벅국내학술심포지엄 ''펄 벅의 문학, 예술 그리고 인도주의''', content = '', place = '부천시립박물관 통합관 1층 강당' WHERE provider_type = 'PUBLIC' AND external_id = '403105';
UPDATE festival SET title = '[김해] 2026 동아시아문화도시 ‘세개의 몸짓’ 그림자극, 핸드쉐도우 판타지 ANIMARE', content = '', place = '김해서부문화센터 하늬홀' WHERE provider_type = 'PUBLIC' AND external_id = '401442';
UPDATE festival SET title = '[태릉국제스케이트장] 한국체육박물관 기획전시 ''step by step, 얼음 위의 발자취''', content = '', place = '태릉선수촌' WHERE provider_type = 'PUBLIC' AND external_id = '403183';
UPDATE festival SET title = '2026 창작ing 연극 <장소> 관객과의 대화', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '403181';
UPDATE festival SET title = '2026 서울문화재단 예술로 매력서울 선정사업 「도시의 리듬, 일상의 예술」', content = '', place = '양천구·구로구·금천구 및 안양천 일대' WHERE provider_type = 'PUBLIC' AND external_id = '403139';
UPDATE festival SET title = '2026 청주 국가유산 미디어아트 ''빛으로 여는 청주의 보물''', content = '', place = '청주 원도심 일원(철당간, 망선루, 압각수, 충청도병마절도사영문)' WHERE provider_type = 'PUBLIC' AND external_id = '400283';
UPDATE festival SET title = '[문화공간 정담] <그날의 반짝임이 빛이 되어 피어나다>', content = '', place = '노원문화원' WHERE provider_type = 'PUBLIC' AND external_id = '402468';
UPDATE festival SET title = '음악극 ''저승난장''', content = '', place = '드림시어터 [대학로]' WHERE provider_type = 'PUBLIC' AND external_id = '398596';
UPDATE festival SET title = '청소년극 릴-레이, 노래←말', content = '', place = '서강대 메리홀 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '399037';
UPDATE festival SET title = '국립극장 기획 <2026 대한민국 전통춤 축제>', content = '전국 10개 단체가 함께하는 전통춤의 향연!', place = '국립극장 해오름극장' WHERE provider_type = 'PUBLIC' AND external_id = '392779';
UPDATE festival SET title = '연극 <과부들>', content = '', place = '성균관대학교 경영관 소극장' WHERE provider_type = 'PUBLIC' AND external_id = '401481';
UPDATE festival SET title = '청주 무형유산 도감 ''대운설경(大運說經)·대운(大運)상담소''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '399623';
UPDATE festival SET title = '작가와의 만남-슬미 앤 재앤더플루이드 ''레진 워터쉐이커 만들기''', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '401410';
UPDATE festival SET title = '2026년 청년문화행사 ''문-카니발(MOON CARNIVAL)''  ', content = '', place = '영암군청년센터 달빛청춘마루 일원' WHERE provider_type = 'PUBLIC' AND external_id = '402564';
UPDATE festival SET title = '별★걸 다 파는 마포 주민 아트 마켓 <2026 궁금한 시장>', content = '', place = '마포아트센터 앞 광장' WHERE provider_type = 'PUBLIC' AND external_id = '401387';
UPDATE festival SET title = '[국립극장 무대예술지원센터] 쏙쏙들이 페스티벌 가을축제 <가을 쏙!, 낭만 쏙!>', content = '', place = '국립극장 무대예술지원센터 야외광장' WHERE provider_type = 'PUBLIC' AND external_id = '402393';
UPDATE festival SET title = 'ABOPF×최우형 〈‘숨 고르기’ 프로젝트: 숨 좀 쉬고 갈래?〉', content = '', place = '안양아트센터 수리홀' WHERE provider_type = 'PUBLIC' AND external_id = '400206';
UPDATE festival SET title = '[강원 양구] 강원문화재단 공연장예술단체 육성지원사업 <백자한상> (10.24) ', content = '', place = '양구문화복지센터' WHERE provider_type = 'PUBLIC' AND external_id = '402430';
UPDATE festival SET title = '2026 서울시향 얍 판 츠베덴의 모차르트 ''레퀴엠'' ②', content = '', place = '예술의전당 [서울] 콘서트홀' WHERE provider_type = 'PUBLIC' AND external_id = '399579';
UPDATE festival SET title = '[Dialogues] 송윤원 & 이상현 Joint Recital', content = '', place = '클래시카 서울' WHERE provider_type = 'PUBLIC' AND external_id = '402679';
UPDATE festival SET title = 'CBS 콰이어 & CBS 소년소녀합창단 2026년 정기연주회 심히 좋았더라 VERY GOOD', content = '', place = 'KBS홀' WHERE provider_type = 'PUBLIC' AND external_id = '396422';
UPDATE festival SET title = '음악오늘 스물 한 번째 이야기 <전기의 맛>', content = '', place = '서울생활문화센터 서교 서교스퀘어' WHERE provider_type = 'PUBLIC' AND external_id = '402674';
UPDATE festival SET title = '[제주 서귀포] 제주체임버오케스트라 <가장 오래된 미래> ', content = '', place = '김정문화회관' WHERE provider_type = 'PUBLIC' AND external_id = '402086';
UPDATE festival SET title = '국립남도국악원 토요상설: 국악이 좋다, 남사당놀이 초청공연 <언제까지 꼭두각시놀음만 할 건데!>', content = '', place = '국립남도국악원 진악당' WHERE provider_type = 'PUBLIC' AND external_id = '400025';
UPDATE festival SET title = '2026 D.FESTA 소극장축제 <달빛수리점>', content = '', place = '열린극장' WHERE provider_type = 'PUBLIC' AND external_id = '401932';
UPDATE festival SET title = '바이올리니스트 김민희 & 피아니스트 김진겸 듀오 리사이틀: 피아노와 바이올린을 위한 모차르트 소나타 전곡 연주회 Ⅰ', content = '', place = '예술의전당 [서울] 인춘아트홀' WHERE provider_type = 'PUBLIC' AND external_id = '401295';
UPDATE festival SET title = '2026 창작ing 전통 <꼭두각, 시간놀음> 관객과의 대화', content = '', place = '' WHERE provider_type = 'PUBLIC' AND external_id = '399639';
UPDATE festival SET title = '[김해] 2026 동아시아문화도시 ‘세개의 몸짓’ 그림자극, 코믹넌버벌 카툰마임쇼', content = '', place = '김해서부문화센터 하늬홀' WHERE provider_type = 'PUBLIC' AND external_id = '401500';
UPDATE festival SET title = '[김해] 2026 동아시아문화도시 ‘세개의 몸짓’ 무용극. 신공작동남비', content = '', place = '김해서부문화센터 하늬홀' WHERE provider_type = 'PUBLIC' AND external_id = '401445';
UPDATE festival SET title = '제13회 목은문화제 ''이색적인 하루, 목은을 만나다''', content = '', place = '영덕군 영해면 괴시전통마을 일원' WHERE provider_type = 'PUBLIC' AND external_id = '403225';
UPDATE festival SET title = '진행 42.195km, a Story on the Road 길 위의 이야기 <최순연> ', content = '', place = '애니메이션박물관' WHERE provider_type = 'PUBLIC' AND external_id = '403458';
UPDATE festival SET title = '제3회 아트미션展 <은혜의 기쁨>', content = '', place = '봄내극장 춘천미술관' WHERE provider_type = 'PUBLIC' AND external_id = '403461';
UPDATE festival SET title = '이혜숙 제3회 개인전 <춘천, 색으로 머물다>', content = '', place = '봄내극장 춘천미술관' WHERE provider_type = 'PUBLIC' AND external_id = '403455';
UPDATE festival SET title = '부평영아티스트 8기 선정작가전 <Perennial Inspiration>', content = '', place = '부평아트센터' WHERE provider_type = 'PUBLIC' AND external_id = '403251';
UPDATE festival SET title = '[군위] 지브리 & 엔니오모리꼬네 클림오케스트라 콘서트 ', content = '', place = '군위 삼국유사교육문화회관 공연장' WHERE provider_type = 'PUBLIC' AND external_id = '403328';
UPDATE festival SET title = '2026 국립남도국악원 토요상설: 국악이 좋다, 국립남도국악원 국악연주단 <국악의 향연>', content = '', place = '국립남도국악원 진악당' WHERE provider_type = 'PUBLIC' AND external_id = '404401';
UPDATE festival SET title = '[대전(앵콜)] 지브리 & 디즈니 영화음악 오케스트라 콘서트 ', content = '', place = '충남대학교 정심화국제문화회관 정심화홀' WHERE provider_type = 'PUBLIC' AND external_id = '404133';

COMMIT;
