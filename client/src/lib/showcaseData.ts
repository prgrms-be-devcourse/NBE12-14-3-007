import type {
  CommunityCategory,
  CommunityMember,
  EventView,
  PostDetail,
  Role,
} from "./types";

/**
 * 서버에 없는, 프론트에 넣어 둔 회원 제보 행사·후기·댓글·커뮤니티 데이터.
 *
 * 제보 행사는 2026-10-29 기준 실제로 열려 있는 팝업이다. 기간·장소·운영시간은
 * 팝가(popga.co.kr)·팝놀(popnol.co.kr) 안내와 각 브랜드 공식 인스타그램 공지로 확인했다.
 * 공공데이터 행사와 겹치지 않는 것만 골랐다.
 * 후기·댓글·커뮤니티 글과 작성자는 지어낸 내용이다.
 * 사진은 모두 Unsplash 무료 이미지를 그대로 불러 쓴다(ASSETS.md 참조).
 */

const photo = (id: string, width = 1200) =>
  `https://images.unsplash.com/${id}?auto=format&fit=crop&w=${width}&q=80`;

const PHOTO = {
  latteArt: "photo-1742549626436-bf3c11dab212",
  cafeLatte: "photo-1559001724-fbad036dbc9e",
  matchaLatte: "photo-1766426910014-63a302fa137e",
  icedMatcha: "photo-1785711571852-8edfd71e92ef",
  coffeeShop: "photo-1567880905822-56f8e06fe630",
  serumShelf: "photo-1787569499510-ef18cc7ba7a5",
  amberDropper: "photo-1608571423902-eed4a5ad8108",
  creamSwatch: "photo-1585945037805-5fd82c2e60b1",
  saunaRoom: "photo-1759302353458-3c617bfd428b",
  toyStoryFigures: "photo-1718804715033-8e045415f6f3",
  colorfulToys: "photo-1663850697008-29fd8ea8e941",
  figureShelf: "photo-1608278047522-58806a6ac85b",
  characterShop: "photo-1792019626300-2911392d6c82",
  keychainWall: "photo-1764788127523-ac9fd80be5f3",
  teddyOnSofa: "photo-1641085809270-71f722611ce1",
  teddyBowtie: "photo-1602734846297-9299fc2d4703",
  autumnGarden: "photo-1581524070124-957d29ec032f",
  parkPath: "photo-1742744132094-26fa77a4163f",
  autumnPond: "photo-1619441207978-3d326c46e2c9",
  marketCrates: "photo-1631692994621-d26f83cf4db8",
  stationeryShop: "photo-1779684998897-ce5de594a5ac",
  shelfGoods: "photo-1598305762558-328f599df683",
  pinkTumbler: "photo-1729192293999-ffbdc97cbac9",
  bottles: "photo-1679310289576-8e1b68b808ba",
  hoodedJacket: "photo-1567955465154-078c60ff5c9e",
  brownJacket: "photo-1649937408746-4d2f603f91c8",
  gameOnNeon: "photo-1546443046-ed1ce6ffd1ab",
  cdWall: "photo-1760931657888-87514a4e6c25",
  photoBooth: "photo-1744189578759-5103cc188897",
  brickStreet: "photo-1652618959145-1d58531713d4",
  redBrick: "photo-1697201193383-601d4f3b7339",
  queue: "photo-1743324754696-c636e1aed0b6",
  mallAtrium: "photo-1761333485882-c60907725574",
  galleryCrowd: "photo-1743119844808-fefd446de533",
  museumHall: "photo-1774514580599-c3dae376348e",
  hamster: "photo-1425082661705-1834bfd09dca",
  toteBag: "photo-1544816155-12df9643f363",
  stickerWall: "photo-1625768376503-68d2495d78c5",
  stickerCollage: "photo-1778278553405-09b847a2af3e",
} as const;
type PhotoName = keyof typeof PHOTO;

const member = (
  no: number,
  nickname: string,
  role: Role,
): CommunityMember & { id: string; role: Role } => ({
  id: `sc-member-${String(no).padStart(2, "0")}`,
  nickname,
  profileImg: null,
  role,
});
const M = {
  seongsu: member(1, "성수동 산책러", "ROLE_TRUSTED"),
  hunter: member(2, "팝업헌터 지니", "ROLE_TRUSTED"),
  weekend: member(3, "주말엔 전시", "ROLE_RECOGNIZED"),
  escape: member(4, "오늘도 탈출", "ROLE_RECOGNIZED"),
  bread: member(5, "빵순이 하루", "ROLE_UNVERIFIED"),
  hongdae: member(6, "홍대 고양이", "ROLE_RECOGNIZED"),
  busan: member(7, "부산 바다곰", "ROLE_RECOGNIZED"),
  daegu: member(8, "대구 토박이", "ROLE_UNVERIFIED"),
  jeju: member(9, "제주 귤밭", "ROLE_UNVERIFIED"),
  collector: member(10, "굿즈 수집가", "ROLE_TRUSTED"),
  family: member(11, "아이랑 나들이", "ROLE_UNVERIFIED"),
  ilsan: member(12, "일산 사는 곰", "ROLE_UNVERIFIED"),
  centum: member(13, "센텀 출근러", "ROLE_UNVERIFIED"),
};
type MemberKey = keyof typeof M;

interface EventSeed {
  id: number;
  by: MemberKey;
  reportedAt: string;
  title: string;
  category: string;
  region: string;
  district: string;
  address: string;
  begin: string;
  end: string;
  hours: string;
  fee?: string;
  host: string;
  venue?: string;
  url: string;
  cover: PhotoName;
  content: string[];
  likes: number;
  votes: [accurate: number, inaccurate: number];
}

const events: EventSeed[] = [
  {
    id: 900001,
    by: "weekend",
    reportedAt: "2026-10-17T22:40:00",
    title: "짱구는 못말려 전시 - 놀자! 시공간 대모험",
    category: "전시",
    region: "SEOUL",
    district: "성동구",
    address: "연무장5길 9-29",
    begin: "2026-10-17T11:00:00",
    end: "2027-01-24T20:00:00",
    hours: "매일 11:00 — 20:00 (입장 마감 19:00)",
    fee: "사전 예약 또는 현장 대기 (요금은 예약 페이지 확인)",
    host: "짱구는 못말려 전시 운영사무국",
    url: "https://www.instagram.com/shinchan_spacetime_kr",
    cover: "colorfulToys",
    content: [
      "떡잎마을 방범대가 시공간에 휩쓸렸다는 콘셉트의 짱구 몰입형 전시예요. 공간마다 인터랙티브 체험이 있어서 캐릭터들과 사진도 찍고 뛰어놀 수 있어요.",
      "입장 마감이 저녁 7시라 늦게 가면 못 들어가요. 사전 예약을 못 했다면 현장 대기로도 입장할 수 있어요.",
      "내년 1월 24일까지 길게 열지만 주말에는 붐비니 방문 전에 공식 인스타그램 공지를 확인해 주세요.",
    ],
    likes: 128,
    votes: [31, 0],
  },
  {
    id: 900002,
    by: "family",
    reportedAt: "2026-09-12T10:15:00",
    title: "탐정 스누피의 잃어버린 단서 in 유니세프 정원",
    category: "교육/체험",
    region: "SEOUL",
    district: "성동구",
    address: "뚝섬로 273 서울숲 유니세프 정원 (제이홉숲 근처)",
    begin: "2026-09-10T12:00:00",
    end: "2026-11-16T19:00:00",
    hours: "매일 12:00 — 19:00",
    host: "유니세프한국위원회",
    venue: "서울숲",
    url: "https://popga.co.kr/popup/8882",
    cover: "autumnGarden",
    content: [
      "서울숲 유니세프 정원에 탐정 스누피 콘셉트의 탐험 공간이 생겼어요. 정원을 산책하며 단서를 찾다 보면 유니세프의 활동과 메시지를 자연스럽게 알게 되는 구성이에요.",
      "미션을 완료하고 인증하면 스누피 스티커팩을 받을 수 있어요. 야외 정원이라 아이와 서울숲 나들이 코스로 묶어 가기 좋아요.",
    ],
    likes: 64,
    votes: [17, 1],
  },
  {
    id: 900003,
    by: "bread",
    reportedAt: "2026-09-09T19:30:00",
    title: "메이드바이 X 맘마 햄스토어 팝업",
    category: "플리마켓/팝업",
    region: "SEOUL",
    district: "성동구",
    address: "서울숲길 38 메이드바이 성수점",
    begin: "2026-09-08T12:00:00",
    end: "2026-11-04T20:00:00",
    hours: "매일 12:00 — 20:00",
    host: "메이드바이",
    venue: "메이드바이 성수점",
    url: "https://www.instagram.com/madeby.official/",
    cover: "hamster",
    content: [
      "햄스터 캐릭터 '맘마'와 메이드바이가 함께 연 햄스토어 마트 콘셉트 팝업이에요. 선공개 신상과 콜라보 상품을 지하 1층부터 4층까지 둘러볼 수 있어요.",
      "나만의 만두 만들기에 참여하고 완성한 만두 얼굴을 SNS에 인증하면 말랑 키링(10종 중 랜덤 1종)을 줘요. 층마다 있는 스탬프 5개를 모두 모으면 팝업 한정 랜덤 스티커도 받을 수 있어요.",
    ],
    likes: 57,
    votes: [14, 0],
  },
  {
    id: 900004,
    by: "seongsu",
    reportedAt: "2026-09-02T12:05:00",
    title: "카카오페이 팝업 - 오래오래 함께가게",
    category: "플리마켓/팝업",
    region: "SEOUL",
    district: "성동구",
    address: "연무장3길 8-27",
    begin: "2026-09-01T11:00:00",
    end: "2026-10-31T20:00:00",
    hours: "매일 11:00 — 20:00",
    fee: "무료 관람",
    host: "카카오페이",
    url: "https://www.instagram.com/kakaopay.oraeorae/",
    cover: "shelfGoods",
    content: [
      "카카오페이가 소상공인 브랜드와 함께 만든 상생 팝업이에요. 진심·감각·일상·지속·지역 다섯 가지 테마로 꾸민 아틀리에 존에서 작은 브랜드들이 재료 하나로 제품을 만들어 가는 이야기를 볼 수 있어요.",
      "10월 31일(토)까지라 이번 주말이 마지막이에요.",
    ],
    likes: 23,
    votes: [9, 0],
  },
  {
    id: 900005,
    by: "hunter",
    reportedAt: "2026-09-04T21:20:00",
    title: "토이 스토리 팝업 - 하우스 오브 토이스토리",
    category: "플리마켓/팝업",
    region: "SEOUL",
    district: "성동구",
    address: "연무장3길 8-9 +LECT HOUSE",
    begin: "2026-09-04T12:00:00",
    end: "2026-10-31T21:00:00",
    hours: "매일 12:00 — 21:00",
    host: "스모어마켓",
    venue: "+LECT HOUSE",
    url: "https://www.instagram.com/smoremarket/",
    cover: "toyStoryFigures",
    content: [
      "우디와 버즈를 실제 크기로 만날 수 있는 토이 스토리 팝업이에요. 1층부터 4층까지 건물 전체가 토이 스토리 상품과 포토존으로 채워져 있어요.",
      "10월 31일(토)에 끝나니 아직 못 가셨다면 서두르세요!",
    ],
    likes: 96,
    votes: [26, 1],
  },
  {
    id: 900006,
    by: "escape",
    reportedAt: "2026-10-22T09:40:00",
    title: "리바이포유 10주년 팝업",
    category: "플리마켓/팝업",
    region: "SEOUL",
    district: "성동구",
    address: "연무장길 65 LECT 성수",
    begin: "2026-10-28T11:00:00",
    end: "2026-11-12T19:00:00",
    hours: "매일 11:00 — 19:00",
    fee: "네이버 사전 예약 가능",
    host: "리바이포유",
    venue: "LECT 성수",
    url: "https://www.instagram.com/rbfy_official/",
    cover: "serumShelf",
    content: [
      "스킨케어 브랜드 리바이포유가 10주년을 맞아 연 팝업이에요. 히알프렙 라인을 중심으로 인기 제품을 직접 발라 보고 고를 수 있어요.",
      "방문하면 팝업 한정 가방과 거울 키링을 줘요. 사전 예약을 받고 있어서 예약하고 가면 더 편해요.",
    ],
    likes: 18,
    votes: [6, 0],
  },
  {
    id: 900007,
    by: "weekend",
    reportedAt: "2026-10-26T18:10:00",
    title: "바이탈뷰티 팝업 - SUPER GLOW SAUNA",
    category: "플리마켓/팝업",
    region: "SEOUL",
    district: "성동구",
    address: "연무장길 31-1 103호",
    begin: "2026-10-28T14:00:00",
    end: "2026-11-03T19:00:00",
    hours: "10/28(수) 14:00 — 19:00, 그 외 10:00 — 19:00",
    host: "바이탈뷰티",
    url: "https://www.instagram.com/vitalbeautie_official/",
    cover: "saunaRoom",
    content: [
      "바이탈뷰티 슈퍼레티놀 라인을 사우나 콘셉트로 풀어낸 팝업이에요. 새로 나온 슈퍼레티놀 라인업을 직접 써 보고 나에게 맞는 글로우 루틴을 찾아볼 수 있어요.",
      "팝업 안 미션을 깨면 샘플 2종을, 슈퍼글로우 사우나 체험을 하면 팝업 한정 사우나 굿즈를 줘요. 11월 3일(화)까지 딱 일주일만 열어요.",
    ],
    likes: 11,
    votes: [4, 0],
  },
  {
    id: 900008,
    by: "collector",
    reportedAt: "2026-10-27T13:25:00",
    title: "뮤직 & 월즈26 팝업스토어 IN 트렌드팟 바이 올리브영 N성수",
    category: "플리마켓/팝업",
    region: "SEOUL",
    district: "성동구",
    address: "연무장7길 13 트렌드팟 바이 올리브영 N성수",
    begin: "2026-10-29T11:00:00",
    end: "2026-11-08T20:00:00",
    hours: "매일 11:00 — 20:00",
    fee: "사전 예약 없이 현장 대기로 입장",
    host: "라이엇 게임즈 코리아",
    venue: "올리브영 N성수",
    url: "https://www.instagram.com/leagueoflegendskorea/",
    cover: "gameOnNeon",
    content: [
      "리그 오브 레전드 월즈와 롤 음악을 한자리에서 만나는 MUSIC & WORLDS26 팝업이 올리브영 N성수에 열려요. 이곳에서만 받을 수 있는 리워드도 준비돼 있대요.",
      "사전 예약 없이 현장 대기로 입장하니 오픈 시간에 맞춰 가는 걸 추천해요.",
    ],
    likes: 42,
    votes: [12, 0],
  },
  {
    id: 900009,
    by: "hongdae",
    reportedAt: "2026-09-19T23:05:00",
    title: "주술회전 콜라보 카페",
    category: "플리마켓/팝업",
    region: "SEOUL",
    district: "마포구",
    address: "양화로 188 AK플라자 홍대 3층 BOX cafe&space",
    begin: "2026-09-23T11:00:00",
    end: "2026-12-01T22:00:00",
    hours: "월–금 11:00 — 22:00, 토–일 10:30 — 22:00",
    fee: "음료·MD 구매 시 특전 증정",
    host: "BOX cafe&space",
    venue: "AK플라자 홍대",
    url: "https://www.instagram.com/box_cafe_ak/",
    cover: "coffeeShop",
    content: [
      "애니메이션 「주술회전」 시부야사변을 테마로 한 콜라보 카페예요. 이타도리, 메구미, 노바라, 고죠, 나나미 등 캐릭터 콘셉트 음료와 시즌 한정 메뉴가 있어요.",
      "전기(9/23–10/28)와 후기(10/29–12/1)로 나뉘어 메뉴 구매 특전이 달라져요. 메뉴를 사면 특전 코스터 랜덤 1종을, MD를 3만 원 이상 사면 오리지널 티켓 5종 중 랜덤 1종을 줘요.",
    ],
    likes: 73,
    votes: [21, 0],
  },
  {
    id: 900010,
    by: "collector",
    reportedAt: "2026-10-24T20:45:00",
    title: "핫토이 팝업스토어",
    category: "플리마켓/팝업",
    region: "SEOUL",
    district: "마포구",
    address: "양화로 188 AK플라자 홍대 2층",
    begin: "2026-10-27T11:00:00",
    end: "2026-11-09T22:00:00",
    hours: "월–금 11:00 — 22:00, 토–일 10:30 — 22:00",
    host: "핫토이 코리아",
    venue: "AK플라자 홍대",
    url: "https://www.instagram.com/hottoyskr/",
    cover: "figureShelf",
    content: [
      "홍콩 컬렉터블 피규어 브랜드 핫토이 팝업이 AK플라자 홍대 2층에 열렸어요. 마블·DC 1:6 스케일 피규어부터 코스비·코스베이비, 플러쉬 굿즈까지 온라인에서만 보던 라인업을 직접 볼 수 있어요.",
      "어벤져스: 둠스데이 스티브 로저스, 슈페리어 아이언맨 같은 한정판은 현장 선착순 판매와 프리오더로 진행돼 수량이 빨리 빠질 수 있어요.",
    ],
    likes: 38,
    votes: [10, 1],
  },
  {
    id: 900011,
    by: "hongdae",
    reportedAt: "2026-10-27T23:30:00",
    title: "아일릿 팝업 - BREAK EVEN @홍대",
    category: "플리마켓/팝업",
    region: "SEOUL",
    district: "마포구",
    address: "와우산로21길 29 올리브영 홍대놀이터점",
    begin: "2026-10-29T10:00:00",
    end: "2026-11-03T23:00:00",
    hours: "매일 10:00 — 23:00",
    host: "올리브영",
    venue: "올리브영 홍대놀이터점",
    url: "https://www.instagram.com/oliveyoung_official/",
    cover: "cdWall",
    content: [
      "아일릿(ILLIT) 미니 5집 'BREAK EVEN' 발매 기념 팝업이 올리브영 홍대놀이터점에서 열려요.",
      "대상 앨범을 사면 미공개 셀피 포토카드 4종 중 1종을 랜덤으로 줘요(구매 수량만큼). Weverse Albums ver.와 Photo Dump ver.는 특전 대상이 아니니 참고하세요.",
    ],
    likes: 49,
    votes: [13, 0],
  },
  {
    id: 900012,
    by: "hunter",
    reportedAt: "2026-10-13T10:20:00",
    title: "2026 스텔라이브 팝업 - STELLA MODE:ON",
    category: "전시",
    region: "SEOUL",
    district: "광진구",
    address: "광나루로 441 본다빈치뮤지엄 능동",
    begin: "2026-10-23T10:00:00",
    end: "2026-11-01T20:00:00",
    hours: "매일 10:00 — 20:00",
    fee: "네이버 사전 예약 (만 14세 미만은 보호자 ID로 예약)",
    host: "스텔라이브",
    venue: "본다빈치뮤지엄 능동",
    url: "https://www.instagram.com/p/DdyPVt-CWeK/",
    cover: "galleryCrowd",
    content: [
      "스텔라이브 공식 팝업스토어가 본다빈치뮤지엄 능동에서 열려요. 멤버들 개성대로 꾸민 전시 공간과, 스마트폰으로 주문하고 현장에서 받는 굿즈존으로 운영돼요.",
      "만 14세 미만은 보호자 ID로 예약하고, 현장에서 예약 화면이나 출력물을 보여 줘야 입장할 수 있어요.",
    ],
    likes: 35,
    votes: [8, 0],
  },
  {
    id: 900013,
    by: "busan",
    reportedAt: "2026-10-20T18:00:00",
    title: "힐리먼트 팝업스토어 (신세계 센텀시티)",
    category: "플리마켓/팝업",
    region: "BUSAN",
    district: "해운대구",
    address: "센텀남대로 35 신세계 센텀시티 지하 2층 하이퍼스테이지",
    begin: "2026-10-20T10:30:00",
    end: "2026-11-04T20:00:00",
    hours: "10:30 — 20:00 (연장 영업일 20:30)",
    host: "힐리먼트",
    venue: "신세계 센텀시티",
    url: "https://www.instagram.com/helement_official/",
    cover: "hoodedJacket",
    content: [
      "낚시복의 기능을 일상복으로 풀어낸 '피싱코어' 아웃도어 브랜드 힐리먼트 팝업이에요. 26FW 신상품을 20% 할인하고, 일부 품목은 최대 40%까지 할인해요.",
      "매주 금·토요일 오후 2시에 선착순 뽑기 행사가 있어요.",
    ],
    likes: 9,
    votes: [3, 0],
  },
  {
    id: 900014,
    by: "busan",
    reportedAt: "2026-10-20T13:15:00",
    title: "% 아라비카 '응 커피' 팝업 (신세계 센텀시티)",
    category: "플리마켓/팝업",
    region: "BUSAN",
    district: "해운대구",
    address: "센텀남대로 35 신세계 센텀시티 지하 1층",
    begin: "2026-10-20T10:30:00",
    end: "2026-12-14T20:00:00",
    hours: "10:30 — 20:00 (11/9 백화점 휴점일 휴무)",
    fee: "음료 구매 (교토 라떼·마차 라떼 각 7,900원)",
    host: "신세계 센텀시티",
    venue: "신세계 센텀시티",
    url: "https://www.instagram.com/arabica.kr/",
    cover: "latteArt",
    content: [
      "교토에서 시작한 스페셜티 커피 % 아라비카가 신세계 센텀시티 지하 1층에 약 8주 동안 팝업 매장을 열었어요. 로고가 '응'처럼 보여서 '응 커피'로 불리는 그곳이에요.",
      "대표 메뉴 교토 라떼와 마차 라떼가 각 7,900원이고, 로고 머그컵 같은 굿즈도 팔아요. 11월 9일(월)은 백화점 휴점일이라 쉬어요.",
    ],
    likes: 44,
    votes: [15, 0],
  },
  {
    id: 900015,
    by: "daegu",
    reportedAt: "2026-10-21T19:50:00",
    title: "체로프 몽모 팝업스토어 (더현대 대구)",
    category: "플리마켓/팝업",
    region: "DAEGU",
    district: "중구",
    address: "달구벌대로 2077 더현대 대구 9층 더 포럼 by 하이메 아욘",
    begin: "2026-10-21T10:30:00",
    end: "2026-11-11T20:00:00",
    hours: "월–목 10:30 — 20:00, 금–일 10:30 — 20:30",
    host: "체로프",
    venue: "더현대 대구",
    url: "https://www.instagram.com/thehyundai_daegu/",
    cover: "teddyBowtie",
    content: [
      "비숑 강아지 캐릭터 '몽모'로 알려진 애착인형 브랜드 체로프 팝업이에요. 인형과 립밤 키링, 허그 키링에 더현대 대구 전용 굿즈까지 모여 있어요.",
      "몽모 프레임 포토네컷이랑 몽모 그리기 체험도 있어서 아이랑 가기 좋아요. 5만 원 이상 사면 리유저블백, 10만 원 이상 사면 몽모 얼굴인형을 줘요.",
    ],
    likes: 27,
    votes: [7, 0],
  },
  {
    id: 900016,
    by: "ilsan",
    reportedAt: "2026-10-22T20:30:00",
    title: "써모스 '럭키 아일랜드' 체험형 팝업 (스타필드 고양)",
    category: "교육/체험",
    region: "GYEONGGI",
    district: "고양시",
    address: "덕양구 고양대로 1955 스타필드 고양 1층 고메 아트리움",
    begin: "2026-10-22T10:00:00",
    end: "2026-11-04T22:00:00",
    hours: "매일 10:00 — 22:00",
    host: "써모스코리아",
    venue: "스타필드 고양",
    url: "https://www.instagram.com/thermoskorea/",
    cover: "pinkTumbler",
    content: [
      "써모스가 스타필드 고양 1층 고메 아트리움에 행운의 섬을 꾸민 체험형 팝업이에요. 행운의 오솔길·연못·오두막을 지나며 행운 도감 미션을 채우는 방식이에요.",
      "행운의 상점에서는 텀블러 30%, 키친웨어 최대 60% 현장 할인을 해요. 먼저 열렸던 스타필드 수원과는 장소가 다르니 헷갈리지 마세요.",
    ],
    likes: 15,
    votes: [5, 0],
  },
  {
    id: 900017,
    by: "jeju",
    reportedAt: "2026-10-26T16:40:00",
    title: "제주 로컬 브랜드 팝업스토어 '주도적 장터'",
    category: "플리마켓/팝업",
    region: "JEJU",
    district: "제주시",
    address: "관덕로8길 15-3 LPP(Local Player Platform)",
    begin: "2026-10-29T11:00:00",
    end: "2026-11-01T17:00:00",
    hours: "매일 11:00 — 17:00",
    host: "제주시",
    venue: "LPP",
    url: "https://www.instagram.com/lpp_jeju/",
    cover: "marketCrates",
    content: [
      "제주시 원도심 로컬 거점공간 LPP에서 나흘 동안 열리는 제주 로컬 브랜드 팝업이에요. 제주에서 주도적으로 브랜드를 만드는 24개 팀이 상품을 전시하고 판매해요.",
      "현장 할인쿠폰과 선물 꾸러미도 준비돼 있어요. 11월 1일(일)까지예요.",
    ],
    likes: 7,
    votes: [2, 0],
  },
];

export const showcaseEvents: EventView[] = events.map((seed) => ({
  festivalId: seed.id,
  source: "MEMBER",
  title: seed.title,
  category: seed.category,
  instNm: seed.venue ?? null,
  manager: null,
  festivalContent: seed.content.join("\n\n"),
  referenceUrl: seed.url,
  region: seed.region,
  district: seed.district,
  regionDetail: `${seed.district} ${seed.address}`,
  imgUrl: photo(PHOTO[seed.cover]),
  beginDe: seed.begin,
  endDe: seed.end,
  eventTmInfo: seed.hours,
  partcptExpnInfo: seed.fee ?? null,
  telnoInfo: null,
  hostInstNm: seed.host,
  writngDe: seed.reportedAt,
  status: "OPEN",
  submitter: M[seed.by],
}));

/** 좋아요 기본 개수. 키는 "festival:{id}" 또는 후기 ID */
export const showcaseLikes: Record<string, number> = Object.fromEntries(
  events.map((seed) => [`festival:${seed.id}`, seed.likes]),
);
export const showcaseVotes: Record<number, [number, number]> =
  Object.fromEntries(events.map((seed) => [seed.id, seed.votes]));

const p = (text: string) => `<p>${text}</p>`;
const img = (name: PhotoName, alt: string) =>
  `<img src="${photo(PHOTO[name])}" alt="${alt}">`;

interface PostSeed {
  id: string;
  festivalId: number;
  by: MemberKey;
  date: string;
  title: string;
  thumbnail: PhotoName;
  content: string[];
  likes: number;
}

const postSeeds: PostSeed[] = [
  {
    id: "sc-post-01",
    festivalId: 900001,
    by: "escape",
    date: "2026-10-18T19:20:00",
    title: "짱구 덕후라면 무조건, 시공간 대모험 다녀왔어요",
    thumbnail: "colorfulToys",
    content: [
      p(
        "오픈 이튿날 오후에 다녀왔어요. 사전 예약을 못 해서 현장 대기를 걸었는데 생각보다 금방 들어갔어요.",
      ),
      img("colorfulToys", "전시장 입구 포토존"),
      p(
        "공간마다 콘셉트가 확 바뀌어서 지루할 틈이 없었어요. 화면이 몸짓에 반응하는 인터랙티브 존이 많아서 어른도 신나게 놀았네요.",
      ),
      img("photoBooth", "마지막 구역의 포토부스"),
      p(
        "마지막 입장이 저녁 7시라 퇴근하고 가실 분들은 시간 꼭 확인하세요. 굿즈존은 나가는 길에 들르는 구조예요.",
      ),
    ],
    likes: 34,
  },
  {
    id: "sc-post-02",
    festivalId: 900001,
    by: "family",
    date: "2026-10-25T16:05:00",
    title: "7살 아이랑 짱구 전시, 2시간 꽉 채워 놀았어요",
    thumbnail: "keychainWall",
    content: [
      p(
        "짱구를 좋아하는 아이랑 일요일 오후에 갔어요. 체험 공간이 많아서 아이가 지칠 때까지 뛰어다녔어요.",
      ),
      p(
        "주말 오후라 사람이 꽤 많았어요. 여유 있게 보시려면 오전 시간대를 추천해요.",
      ),
      img("keychainWall", "출구 쪽 굿즈존"),
      p(
        "굿즈존에서 키링 하나씩 사 들고 나왔어요. 아이가 아직도 떡잎마을 방범대 노래를 불러요 😂",
      ),
    ],
    likes: 21,
  },
  {
    id: "sc-post-03",
    festivalId: 900002,
    by: "family",
    date: "2026-10-04T14:30:00",
    title: "서울숲 산책하다가 탐정 스누피 미션 완료!",
    thumbnail: "autumnGarden",
    content: [
      p(
        "주말에 서울숲 산책하다가 들렀어요. 유니세프 정원 안을 걸으면서 단서를 찾는 방식이라 아이가 보물찾기처럼 좋아했어요.",
      ),
      img("autumnGarden", "정원 안 산책로"),
      p(
        "단서마다 유니세프 활동 이야기가 붙어 있어서 아이한테 설명해 주기도 좋았어요.",
      ),
      img("parkPath", "서울숲 산책로"),
      p(
        "미션을 다 하고 인증하면 스누피 스티커팩을 줘요. 정오에 열어서 점심 먹고 가기 딱 좋아요.",
      ),
    ],
    likes: 18,
  },
  {
    id: "sc-post-04",
    festivalId: 900002,
    by: "seongsu",
    date: "2026-10-19T12:40:00",
    title: "단풍 들기 시작한 서울숲, 스누피 단서 찾기 코스 추천",
    thumbnail: "autumnPond",
    content: [
      p(
        "서울숲이 슬슬 물들기 시작해서 산책 겸 다녀왔어요. 평일 낮이라 정원이 한산했어요.",
      ),
      img("autumnPond", "단풍 든 서울숲 연못"),
      p(
        "단서 찾기는 천천히 걸어도 30분 정도면 충분해요. 끝나고 받은 스티커팩은 노트북에 붙였습니다.",
      ),
      img("stickerCollage", "받은 스티커들"),
      p("11월 16일까지라 단풍 절정 때 한 번 더 가 볼 생각이에요."),
    ],
    likes: 12,
  },
  {
    id: "sc-post-05",
    festivalId: 900003,
    by: "bread",
    date: "2026-09-13T17:10:00",
    title: "햄스터 마트 콘셉트 너무 귀여워요, 맘마 햄스토어",
    thumbnail: "hamster",
    content: [
      p(
        "햄스터들이 마트를 차렸다는 콘셉트인데 층마다 소품이 너무 귀여워서 사진만 백 장 찍었어요.",
      ),
      img("hamster", "맘마 생각나는 햄스터"),
      p(
        "만두 만들기 코너에서 만두 얼굴을 꾸미고 SNS 인증하면 말랑 키링을 랜덤으로 줘요. 저는 두 번 만에 원하던 아이가 나왔어요!",
      ),
      img("keychainWall", "키링 진열대"),
      p(
        "선공개 신상도 있어서 구경할 게 많아요. 서울숲이랑 가까워서 산책 코스로 묶기 좋아요.",
      ),
    ],
    likes: 27,
  },
  {
    id: "sc-post-06",
    festivalId: 900003,
    by: "hunter",
    date: "2026-10-11T15:25:00",
    title: "지하 1층부터 4층까지 스탬프 다 모았어요",
    thumbnail: "shelfGoods",
    content: [
      p(
        "층마다 스탬프가 하나씩 숨어 있어서 다 모으려면 건물을 꼼꼼히 돌아야 해요. 5개 다 모아서 직원분께 보여 드리면 한정 스티커를 줘요.",
      ),
      img("shelfGoods", "층별 진열 상품"),
      img("stickerWall", "스티커 존"),
      p(
        "콜라보 상품은 층마다 종류가 달라서 위층까지 다 보고 사는 걸 추천해요.",
      ),
    ],
    likes: 15,
  },
  {
    id: "sc-post-07",
    festivalId: 900004,
    by: "seongsu",
    date: "2026-09-20T13:00:00",
    title: "작은 브랜드 발견하는 재미, 오래오래 함께가게",
    thumbnail: "stationeryShop",
    content: [
      p(
        "카카오페이가 소상공인 브랜드랑 같이 만든 팝업이에요. 화려한 체험보다는 브랜드 이야기를 천천히 읽는 전시에 가까워요.",
      ),
      img("stationeryShop", "아틀리에 존 진열"),
      p(
        "재료 하나가 제품이 되기까지의 과정을 보여 줘서, 평소 그냥 지나치던 동네 브랜드를 다시 보게 됐어요.",
      ),
      img("toteBag", "구매한 에코백"),
      p("붐비지 않아서 연무장길 돌다가 쉬어 가기에도 좋았어요."),
    ],
    likes: 9,
  },
  {
    id: "sc-post-08",
    festivalId: 900005,
    by: "hunter",
    date: "2026-09-06T18:30:00",
    title: "실물 크기 우디랑 버즈… 어릴 적 꿈 이뤘어요",
    thumbnail: "toyStoryFigures",
    content: [
      p(
        "오픈 첫 주말에 다녀왔어요. 1층 들어서자마자 실물 크기 캐릭터가 반겨 줘서 소리 지를 뻔했어요.",
      ),
      img("toyStoryFigures", "토이 스토리 캐릭터들"),
      p(
        "4층 건물 전체가 팝업이라 층마다 분위기가 달라요. 계단 오르내리는 게 조금 힘들지만 볼거리가 정말 많아요.",
      ),
      img("redBrick", "팝업이 열린 성수 건물"),
      p("포토존 줄은 층마다 따로 있어서 생각보다 오래 기다리지 않았어요."),
    ],
    likes: 41,
  },
  {
    id: "sc-post-09",
    festivalId: 900005,
    by: "collector",
    date: "2026-10-03T14:15:00",
    title: "굿즈 위주로 정리한 하우스 오브 토이스토리 후기",
    thumbnail: "figureShelf",
    content: [
      p(
        "굿즈 보러 간 사람 기준 후기예요. 피규어, 키링, 문구류까지 종류가 정말 많아요.",
      ),
      img("figureShelf", "피규어 진열장"),
      p(
        "층마다 파는 상품이 달라서 마음에 드는 게 있으면 그 층에서 바로 사는 게 좋아요. 다시 내려오기 번거로워요.",
      ),
      img("keychainWall", "키링 코너"),
      p("31일에 끝나니 아직 안 가셨다면 이번 주가 마지막 기회예요."),
    ],
    likes: 19,
  },
  {
    id: "sc-post-10",
    festivalId: 900006,
    by: "escape",
    date: "2026-10-28T18:30:00",
    title: "리바이포유 10주년 팝업 첫날 다녀왔어요",
    thumbnail: "serumShelf",
    content: [
      p(
        "사전 예약하고 오픈 첫날 퇴근길에 들렀어요. 히알프렙 라인을 전부 테스트해 볼 수 있게 되어 있어요.",
      ),
      img("serumShelf", "제품 진열대"),
      img("creamSwatch", "크림 테스트"),
      p(
        "방문 선물로 팝업 한정 가방이랑 거울 키링을 받았어요. 가방이 생각보다 튼튼해요.",
      ),
      img("toteBag", "팝업 한정 가방"),
    ],
    likes: 7,
  },
  {
    id: "sc-post-11",
    festivalId: 900007,
    by: "weekend",
    date: "2026-10-28T17:50:00",
    title: "사우나 콘셉트 진짜 잘 살렸어요, SUPER GLOW SAUNA",
    thumbnail: "saunaRoom",
    content: [
      p(
        "오픈 첫날 오후 2시에 문 열자마자 갔어요. 나무로 꾸민 사우나 공간이 생각보다 그럴듯해서 사진 찍기 좋아요.",
      ),
      img("saunaRoom", "사우나 콘셉트 체험 공간"),
      p(
        "슈퍼레티놀 신제품을 써 보고 미션을 깨면 샘플 2종을 줘요. 사우나 체험까지 하면 한정 굿즈도 받을 수 있어요.",
      ),
      img("amberDropper", "체험한 앰플"),
    ],
    likes: 5,
  },
  {
    id: "sc-post-12",
    festivalId: 900009,
    by: "hongdae",
    date: "2026-09-27T20:10:00",
    title: "주술회전 콜라보 카페 전기 메뉴 먹어 봤어요",
    thumbnail: "icedMatcha",
    content: [
      p(
        "오픈 첫 주말에 다녀왔어요. 캐릭터마다 콘셉트 음료가 있어서 최애 음료부터 골랐어요.",
      ),
      img("icedMatcha", "캐릭터 콘셉트 음료"),
      p(
        "메뉴를 사면 특전 코스터를 랜덤으로 하나 줘요. 최애가 안 나와서 한 잔 더 시킬 뻔했어요.",
      ),
      img("coffeeShop", "카페 내부"),
      p(
        "10월 29일부터는 후기 메뉴로 바뀌고 특전도 달라진대요. 후기 때 한 번 더 가려고요.",
      ),
    ],
    likes: 23,
  },
  {
    id: "sc-post-13",
    festivalId: 900009,
    by: "collector",
    date: "2026-10-12T13:40:00",
    title: "MD 3만 원 특전 티켓 받았어요 + 후기 일정 정리",
    thumbnail: "characterShop",
    content: [
      p(
        "MD를 3만 원 이상 사면 오리지널 티켓 5종 중 하나를 랜덤으로 줘요. 저는 두 번째 방문에 원하던 티켓이 나왔어요.",
      ),
      img("characterShop", "MD 진열"),
      p(
        "전기는 10월 28일까지, 후기는 10월 29일부터 12월 1일까지예요. 시즌마다 메뉴 특전이 달라서 두 번 가는 분들이 많더라고요.",
      ),
    ],
    likes: 14,
  },
  {
    id: "sc-post-14",
    festivalId: 900010,
    by: "collector",
    date: "2026-10-27T21:00:00",
    title: "핫토이 팝업 오픈 첫날 줄 서서 다녀왔어요",
    thumbnail: "queue",
    content: [
      p(
        "한정판 선착순 판매가 있어서 오픈 전에 도착했는데 이미 줄이 꽤 길었어요.",
      ),
      img("queue", "오픈 전 대기 줄"),
      p(
        "1:6 스케일 피규어를 실물로 보니 디테일이 확실히 달라요. 사진으로만 보던 라인업을 한 번에 볼 수 있어서 좋았어요.",
      ),
      img("figureShelf", "피규어 전시"),
      p(
        "한정판이 목표라면 무조건 일찍 가세요. 전시만 볼 거면 저녁 시간이 한산해요.",
      ),
    ],
    likes: 11,
  },
  {
    id: "sc-post-15",
    festivalId: 900012,
    by: "hunter",
    date: "2026-10-24T16:40:00",
    title: "스텔라이브 팝업, 현장 픽업 방식이 편했어요",
    thumbnail: "galleryCrowd",
    content: [
      p(
        "예약 시간에 맞춰 들어갔어요. 멤버별로 꾸민 공간이 다 달라서 한 바퀴 도는 데 꽤 걸렸어요.",
      ),
      img("galleryCrowd", "전시 공간"),
      p(
        "굿즈는 스마트폰으로 주문해 두고 현장에서 받는 방식이라 계산 줄이 거의 없었어요. 이 방식 다른 팝업도 했으면 좋겠어요.",
      ),
      img("museumHall", "본다빈치뮤지엄 내부"),
      p(
        "만 14세 미만은 보호자 ID로 예약해야 하니 가족 단위로 가실 분들은 꼭 확인하세요.",
      ),
    ],
    likes: 16,
  },
  {
    id: "sc-post-16",
    festivalId: 900014,
    by: "busan",
    date: "2026-10-21T11:30:00",
    title: "센텀에서 만난 응 커피, 교토 라떼 맛있네요",
    thumbnail: "latteArt",
    content: [
      p("부산에서도 응 커피를 마실 수 있다니! 오픈 이튿날 오전에 다녀왔어요."),
      img("latteArt", "교토 라떼"),
      p(
        "교토 라떼가 7,900원이라 저렴하진 않지만 고소하고 부드러워요. 로고 머그컵도 팔아요.",
      ),
      img("cafeLatte", "라떼 한 잔"),
      p(
        "백화점 지하 1층이라 쇼핑하다 들르기 좋아요. 12월 14일까지 연다니 자주 갈 것 같아요.",
      ),
    ],
    likes: 25,
  },
  {
    id: "sc-post-17",
    festivalId: 900014,
    by: "centum",
    date: "2026-10-26T13:05:00",
    title: "점심시간에 마차 라떼 한 잔, 웨이팅 팁",
    thumbnail: "matchaLatte",
    content: [
      p(
        "센텀 근처 직장인이라 점심시간에 들렀어요. 12시 반쯤이 제일 붐비고, 1시 넘으면 좀 나아요.",
      ),
      img("matchaLatte", "마차 라떼"),
      p("마차 라떼는 쌉싸름한 맛이 진해서 단 거 안 좋아하는 분들께 추천해요."),
    ],
    likes: 8,
  },
  {
    id: "sc-post-18",
    festivalId: 900015,
    by: "daegu",
    date: "2026-10-24T15:20:00",
    title: "몽모 얼굴인형 받으려고 10만 원 채웠어요 ㅎㅎ",
    thumbnail: "teddyBowtie",
    content: [
      p("조카 선물 사러 갔다가 제가 더 신났어요. 애착인형이 정말 폭신해요."),
      img("teddyBowtie", "애착인형"),
      p(
        "포토네컷 프레임이 몽모라서 조카랑 한 장 찍었어요. 몽모 그리기 체험도 있어서 아이들이 줄 서 있더라고요.",
      ),
      img("teddyOnSofa", "집에 온 인형"),
      p("10만 원 넘게 사면 몽모 얼굴인형을 줘서 결국 채웠습니다…"),
    ],
    likes: 13,
  },
  {
    id: "sc-post-19",
    festivalId: 900016,
    by: "ilsan",
    date: "2026-10-25T14:00:00",
    title: "럭키 아일랜드 도감 미션 채우고 텀블러 득템",
    thumbnail: "pinkTumbler",
    content: [
      p(
        "스타필드 고양 1층 고메 아트리움에 행운의 섬이 꾸며져 있어요. 오솔길, 연못, 오두막을 돌면서 도감 칸을 채우는 방식이에요.",
      ),
      img("mallAtrium", "스타필드 고양 아트리움"),
      p(
        "행운의 상점에서 텀블러를 30% 할인해 줘서 하나 샀어요. 키친웨어는 최대 60%까지 할인하더라고요.",
      ),
      img("pinkTumbler", "새로 산 텀블러"),
      img("bottles", "진열된 보틀"),
    ],
    likes: 10,
  },
  {
    id: "sc-post-20",
    festivalId: 900013,
    by: "busan",
    date: "2026-10-23T19:45:00",
    title: "금요일 2시 뽑기 도전! 힐리먼트 팝업 후기",
    thumbnail: "hoodedJacket",
    content: [
      p(
        "매주 금·토요일 오후 2시에 선착순 뽑기를 해서 맞춰서 갔어요. 결과는 꽝이었지만 재밌었어요.",
      ),
      img("hoodedJacket", "26FW 아우터"),
      p(
        "26FW 신상이 20% 할인이라 바람막이를 하나 샀어요. 주머니가 많아서 진짜 낚시 갈 때도 입을 수 있겠어요.",
      ),
      img("brownJacket", "매장에 걸린 재킷"),
    ],
    likes: 6,
  },
];

const titleOf = (festivalId: number) =>
  events.find((seed) => seed.id === festivalId)!.title;

export const showcasePosts: PostDetail[] = postSeeds.map((seed) => ({
  id: seed.id,
  member: M[seed.by],
  festivalId: seed.festivalId,
  festivalTitle: titleOf(seed.festivalId),
  title: seed.title,
  thumbnail: photo(PHOTO[seed.thumbnail], 800),
  content: seed.content.join(""),
  date: seed.date,
}));
for (const seed of postSeeds) showcaseLikes[seed.id] = seed.likes;

export interface CommentSeed {
  id: number;
  parentId: number | null;
  member: CommunityMember;
  content: string;
  date: string;
}
/** 대댓글은 바로 앞 일반 댓글에 붙인다. */
function thread(
  firstId: number,
  items: [by: MemberKey, date: string, content: string, reply?: boolean][],
): CommentSeed[] {
  let parent: number | null = null;
  return items.map(([by, date, content, reply], index) => {
    const id = firstId + index;
    if (!reply) parent = id;
    return {
      id,
      parentId: reply ? parent : null,
      member: M[by],
      content,
      date,
    };
  });
}

/** 후기 ID → 댓글 */
export const showcaseComments: Record<string, CommentSeed[]> = {
  "sc-post-01": thread(9000101, [
    [
      "hunter",
      "2026-10-18T21:02:00",
      "현장 대기 몇 분 정도 걸리셨어요? 이번 주말에 가려고요!",
    ],
    [
      "escape",
      "2026-10-18T21:30:00",
      "저는 20분 안쪽이었어요. 오픈 직후가 제일 한산했어요.",
      true,
    ],
    ["bread", "2026-10-19T09:14:00", "포토부스 사진 너무 귀엽네요 ㅠㅠ"],
  ]),
  "sc-post-02": thread(9000201, [
    [
      "weekend",
      "2026-10-25T18:40:00",
      "아이랑 가기 좋다니 저도 조카 데리고 가 봐야겠어요.",
    ],
  ]),
  "sc-post-03": thread(9000301, [
    [
      "seongsu",
      "2026-10-04T19:00:00",
      "서울숲 근처 살아서 산책 겸 가 봐야겠네요. 스티커팩 귀여워요?",
    ],
    [
      "family",
      "2026-10-04T20:12:00",
      "네! 아이가 받자마자 가방에 붙였어요 ㅎㅎ",
      true,
    ],
  ]),
  "sc-post-04": thread(9000401, [
    [
      "weekend",
      "2026-10-19T18:22:00",
      "단풍 사진 예쁘네요. 주말에도 사람 많지 않았나요?",
    ],
    [
      "seongsu",
      "2026-10-19T19:05:00",
      "주말엔 가족 단위가 많아요. 평일 낮이 여유로워요.",
      true,
    ],
  ]),
  "sc-post-05": thread(9000501, [
    ["hongdae", "2026-09-13T20:41:00", "햄스터 너무 귀여워서 저장했어요"],
    [
      "collector",
      "2026-09-14T10:02:00",
      "말랑 키링 랜덤인 거 무섭네요… 원하는 거 나오셨다니 부러워요.",
    ],
    [
      "bread",
      "2026-09-14T12:30:00",
      "운이 좋았어요! 꼭 원하는 아이 나오길 바라요 🍀",
      true,
    ],
  ]),
  "sc-post-06": thread(9000601, [
    [
      "escape",
      "2026-10-11T19:20:00",
      "스탬프 다 모으면 스티커 주는 거 몰랐네요. 꿀팁 감사해요.",
    ],
  ]),
  "sc-post-07": thread(9000701, [
    [
      "hunter",
      "2026-09-21T08:50:00",
      "10월 말까지라니 성수 갈 때 꼭 들러야겠어요.",
    ],
  ]),
  "sc-post-08": thread(9000801, [
    ["hongdae", "2026-09-06T21:10:00", "건물 전체가 토이 스토리라니 미쳤다…"],
    [
      "family",
      "2026-09-07T08:35:00",
      "아이가 버즈 광팬이라 꼭 가 보고 싶어요. 주말에 많이 붐비나요?",
    ],
    [
      "hunter",
      "2026-09-07T09:12:00",
      "주말 오전에 가시면 그나마 한산해요!",
      true,
    ],
  ]),
  "sc-post-09": thread(9000901, [
    [
      "hunter",
      "2026-10-03T17:28:00",
      "굿즈 정리 최고예요. 키링 가격대는 어땠어요?",
    ],
    [
      "collector",
      "2026-10-03T18:02:00",
      "종류마다 달라서 현장에서 보시는 게 정확해요!",
      true,
    ],
  ]),
  "sc-post-10": thread(9001001, [
    ["bread", "2026-10-28T20:15:00", "한정 가방 실물 예쁜가요?"],
    [
      "escape",
      "2026-10-28T21:40:00",
      "생각보다 튼튼해서 장 볼 때 잘 쓸 것 같아요.",
      true,
    ],
  ]),
  "sc-post-12": thread(9001201, [
    [
      "weekend",
      "2026-09-28T09:30:00",
      "고죠 음료 비주얼 궁금했는데 후기 감사합니다",
    ],
    [
      "collector",
      "2026-09-28T12:44:00",
      "후기 메뉴도 기대되네요. 같이 정리해 주세요!",
    ],
  ]),
  "sc-post-13": thread(9001301, [
    ["hongdae", "2026-10-12T16:20:00", "저도 같은 티켓 나왔어요 ㅋㅋ 반가워요"],
  ]),
  "sc-post-14": thread(9001401, [
    ["hunter", "2026-10-27T22:10:00", "한정판 피규어 남아 있었나요?"],
    [
      "collector",
      "2026-10-27T22:31:00",
      "인기 있는 건 금방 빠지는 분위기라 일찍 가시는 게 좋아요.",
      true,
    ],
  ]),
  "sc-post-15": thread(9001501, [
    ["weekend", "2026-10-24T19:00:00", "사전 예약 꼭 해야 하나요?"],
    [
      "hunter",
      "2026-10-24T19:26:00",
      "네, 네이버 예약으로 받고 있어요. 14세 미만은 보호자 ID로 예약해야 해요.",
      true,
    ],
  ]),
  "sc-post-16": thread(9001601, [
    [
      "centum",
      "2026-10-21T13:10:00",
      "저도 출근 전에 들렀어요. 머그컵 할인은 아직 하나요?",
    ],
    [
      "busan",
      "2026-10-21T14:02:00",
      "오픈 기념 수량이 200개라 이미 끝났을 수도 있어요 ㅠ",
      true,
    ],
  ]),
  "sc-post-17": thread(9001701, [
    [
      "busan",
      "2026-10-26T18:30:00",
      "저는 교토 라떼만 마셔 봤는데 다음엔 마차 라떼 먹어 볼게요.",
    ],
  ]),
  "sc-post-18": thread(9001801, [
    [
      "family",
      "2026-10-24T20:45:00",
      "몽모 너무 귀여워요. 포토네컷 프레임 예쁘네요",
    ],
  ]),
  "sc-post-19": thread(9001901, [
    [
      "escape",
      "2026-10-25T19:12:00",
      "수원에서 놓쳤는데 고양에서 하는군요! 감사합니다",
    ],
  ]),
};

interface CommunitySeed {
  id: string;
  category: CommunityCategory;
  by: MemberKey;
  createdAt: string;
  title: string;
  content: string;
  views: number;
  comments: [by: MemberKey, date: string, content: string, reply?: boolean][];
}

const communitySeeds: CommunitySeed[] = [
  {
    id: "sc-talk-01",
    category: "EVENT",
    by: "hunter",
    createdAt: "2026-10-28T22:10:00",
    title: "이번 주에 끝나는 팝업 정리 (주말 동선용)",
    content: [
      "이번 주말 전후로 끝나는 팝업들 정리해 봤어요. 날짜는 꼭 공식 계정에서 한 번 더 확인하세요!",
      "",
      "- 카카오페이 오래오래 함께가게 (성수) ~10/31",
      "- 하우스 오브 토이스토리 (성수) ~10/31",
      "- 스텔라이브 STELLA MODE:ON (능동) ~11/1",
      "- 주도적 장터 (제주 LPP) ~11/1",
      "- 바이탈뷰티 SUPER GLOW SAUNA (성수) ~11/3",
      "- 아일릿 BREAK EVEN (홍대) ~11/3",
      "",
      "성수에서 능동까지 지하철로 금방이라 토요일에 묶어서 돌 생각이에요.",
    ].join("\n"),
    views: 412,
    comments: [
      [
        "escape",
        "2026-10-28T22:31:00",
        "정리 감사합니다! 토이 스토리 아직 못 가서 토요일에 가려고요",
      ],
      [
        "hongdae",
        "2026-10-28T22:50:00",
        "아일릿 팝업은 밤 11시까지라 퇴근하고 가기 좋아요",
      ],
      [
        "hunter",
        "2026-10-28T23:02:00",
        "오 늦게까지 하는 거 몰랐어요. 감사해요!",
        true,
      ],
    ],
  },
  {
    id: "sc-talk-02",
    category: "FREE",
    by: "seongsu",
    createdAt: "2026-10-26T20:30:00",
    title: "성수 팝업 하루 코스 (연무장길 기준)",
    content: [
      p("연무장길 쪽에 팝업이 몰려 있어서 걸어서 돌기 좋아요."),
      p(
        "1) 서울숲 탐정 스누피 (12시 오픈이라 점심 먹고 가도 돼요)<br>2) 메이드바이 햄스토어 (서울숲길)<br>3) 연무장길: 리바이포유 → 바이탈뷰티 → 올리브영 N성수 월즈 팝업<br>4) 마무리: 짱구 전시",
      ),
      img("brickStreet", "연무장길 골목"),
      p(
        "짱구 전시는 입장 마감이 저녁 7시라 마지막에 넣으면 아슬아슬해요. 시간 꼭 확인하세요!",
      ),
    ].join(""),
    views: 538,
    comments: [
      ["weekend", "2026-10-26T21:10:00", "동선 그대로 따라가 볼게요!"],
      [
        "bread",
        "2026-10-26T21:44:00",
        "짱구 전시 입장 마감 시간 몰랐는데 감사합니다",
      ],
      [
        "family",
        "2026-10-27T08:20:00",
        "아이랑 가면 스누피를 오전에 넣는 게 좋겠네요",
      ],
    ],
  },
  {
    id: "sc-talk-03",
    category: "FREE",
    by: "hongdae",
    createdAt: "2026-10-27T22:45:00",
    title: "AK플라자 홍대 2층·3층 같이 돌기 좋아요",
    content:
      "2층 핫토이 팝업, 3층 주술회전 콜라보 카페가 같은 건물이라 한 번에 돌았어요.\n둘 다 평일 11시, 주말 10시 30분에 열어요. 카페는 메뉴 사면 코스터 특전이 있으니 참고하세요.",
    views: 203,
    comments: [
      [
        "collector",
        "2026-10-27T23:10:00",
        "핫토이 보고 카페에서 쉬면 딱이겠네요",
      ],
    ],
  },
  {
    id: "sc-talk-04",
    category: "EVENT",
    by: "weekend",
    createdAt: "2026-10-28T12:20:00",
    title: "[동행] 11/1(일) 오후 짱구 전시 같이 보실 분",
    content:
      "11월 1일 일요일 오후 3시쯤 짱구 전시 가려고 해요. 혼자 가기 아쉬워서 같이 보실 분 계시면 댓글 주세요!\n\n공지대로 연락처는 남기지 않고, 전시장 입구에서 만나는 걸로 해요.",
    views: 97,
    comments: [
      [
        "escape",
        "2026-10-28T13:05:00",
        "저 그날 성수 가는데 시간 맞으면 갈게요!",
      ],
      [
        "weekend",
        "2026-10-28T13:40:00",
        "좋아요! 3시에 입구 앞에서 봬요 :)",
        true,
      ],
    ],
  },
  {
    id: "sc-talk-05",
    category: "EVENT",
    by: "collector",
    createdAt: "2026-10-28T19:05:00",
    title: "월즈26 팝업 단독 리워드 뭐 주는지 아시는 분?",
    content:
      "올리브영 N성수에서만 주는 리워드가 있다던데 혹시 공지 보신 분 계세요?\n현장 대기 입장이라 오픈런 해야 할지 고민이에요.",
    views: 156,
    comments: [
      [
        "hunter",
        "2026-10-28T19:40:00",
        "자세한 건 아직 공식 계정에 안 올라온 것 같아요. 첫날 다녀오신 분 후기 기다려 봐요.",
      ],
    ],
  },
  {
    id: "sc-talk-06",
    category: "FREE",
    by: "ilsan",
    createdAt: "2026-10-25T18:20:00",
    title: "써모스 럭키 아일랜드 행운 도감 다 채웠어요",
    content: [
      p(
        "스타필드 고양 고메 아트리움이에요. 오솔길·연못·오두막 돌면서 도감 칸 채우는 방식이라 아이들이 엄청 좋아하더라고요.",
      ),
      img("pinkTumbler", "할인받아 산 텀블러"),
      p("텀블러 30% 할인이라 하나 장만했습니다."),
    ].join(""),
    views: 88,
    comments: [
      [
        "family",
        "2026-10-25T19:02:00",
        "아이랑 가기 좋아 보이네요! 많이 붐볐나요?",
      ],
      [
        "ilsan",
        "2026-10-25T19:30:00",
        "일요일 오후였는데 도감 미션 줄은 금방 빠졌어요.",
        true,
      ],
    ],
  },
  {
    id: "sc-talk-07",
    category: "RESTAURANT",
    by: "bread",
    createdAt: "2026-10-24T11:40:00",
    title: "성수 팝업 돌고 먹을 만한 곳 추천해 주세요",
    content:
      "이번 주말에 연무장길 팝업 돌 예정인데 웨이팅 짧은 밥집 아시는 분 계세요? 빵 말고 밥이요 ㅎㅎ",
    views: 264,
    comments: [
      [
        "seongsu",
        "2026-10-24T12:10:00",
        "큰길보다 골목 안쪽으로 조금 들어가면 칼국수·국밥집이 꽤 있어요. 웨이팅도 짧아요.",
      ],
      [
        "bread",
        "2026-10-24T12:25:00",
        "골목 안쪽 공략해 볼게요 감사해요!",
        true,
      ],
      [
        "escape",
        "2026-10-24T13:02:00",
        "서울숲 쪽으로 가면 브런치 카페도 많아요!",
      ],
    ],
  },
  {
    id: "sc-talk-08",
    category: "RESTAURANT",
    by: "centum",
    createdAt: "2026-10-23T12:50:00",
    title: "센텀시티 근처 점심 어디 가세요?",
    content:
      "센텀 근처 직장인인데 아라비카 생기고 나서 커피는 해결됐어요 ㅋㅋ\n점심은 백화점 식당가 말고 근처에 괜찮은 곳 있으면 공유해 주세요.",
    views: 71,
    comments: [
      [
        "busan",
        "2026-10-23T13:20:00",
        "영화의전당 쪽으로 조금 걸으면 밥집이 많아요.",
      ],
    ],
  },
  {
    id: "sc-talk-09",
    category: "EVENT",
    by: "jeju",
    createdAt: "2026-10-28T17:30:00",
    title: "내일부터 제주 원도심에서 주도적 장터 열려요",
    content:
      "제주 로컬 브랜드 24개 팀이 나온대요. 11시부터 5시까지라 늦게 가면 못 볼 수도 있어요.\n현장 할인쿠폰이랑 선물 꾸러미도 있다니 제주 계신 분들 가 보세요!",
    views: 45,
    comments: [
      ["busan", "2026-10-28T18:12:00", "부산에서 비행기 타고 가고 싶다…"],
      [
        "jeju",
        "2026-10-28T18:40:00",
        "해피빈 펀딩으로도 같은 브랜드들 만날 수 있어요!",
        true,
      ],
    ],
  },
  {
    id: "sc-talk-10",
    category: "EVENT",
    by: "daegu",
    createdAt: "2026-10-22T20:15:00",
    title: "더현대 대구 9층 몽모 팝업 다녀오신 분",
    content:
      "체로프 몽모 팝업 이번 주말에 가 보려는데 포토네컷 줄 긴가요? 조카 데리고 가려고 해요.",
    views: 63,
    comments: [
      [
        "family",
        "2026-10-22T21:05:00",
        "서울이라 못 가지만 몽모 너무 귀여워요ㅠ",
      ],
    ],
  },
  {
    id: "sc-talk-11",
    category: "FREE",
    by: "escape",
    createdAt: "2026-10-20T21:00:00",
    title: "팝업 사전예약 실패 덜 하는 법",
    content: [
      "1. 예약 오픈 시간에 알림 맞춰 두기",
      "2. 네이버 예약은 미리 로그인해 두기",
      "3. 예약 못 했으면 현장 대기 운영하는지 공식 계정 공지 확인",
      "4. 평일 오픈 직후가 제일 한산해요",
      "",
      "다들 꿀팁 있으면 댓글로 공유해 주세요!",
    ].join("\n"),
    views: 389,
    comments: [
      ["hunter", "2026-10-20T21:30:00", "취소표가 전날 밤에 많이 풀려요!"],
      [
        "collector",
        "2026-10-20T22:05:00",
        "굿즈가 목표면 첫날보다 둘째 날 오전이 덜 붐볐어요",
      ],
      ["bread", "2026-10-21T08:40:00", "1번 진짜 중요해요 ㅋㅋ"],
    ],
  },
  {
    id: "sc-talk-12",
    category: "FREE",
    by: "busan",
    createdAt: "2026-10-23T20:40:00",
    title: "신세계 센텀 지하 2층 힐리먼트 할인 괜찮네요",
    content:
      "금요일 오후 2시 뽑기 도전했는데 꽝 ㅋㅋ\n그래도 26FW 신상 20% 할인이라 바람막이 하나 샀어요. 11월 4일까지래요.",
    views: 58,
    comments: [
      [
        "centum",
        "2026-10-23T21:15:00",
        "주말에 가 볼게요! 토요일도 뽑기 있죠?",
      ],
      ["busan", "2026-10-23T21:40:00", "네 금·토 오후 2시예요", true],
    ],
  },
  {
    id: "sc-talk-13",
    category: "RESTAURANT",
    by: "hongdae",
    createdAt: "2026-10-26T15:30:00",
    title: "홍대 AK플라자 근처 디저트 카페 추천 받아요",
    content:
      "콜라보 카페 다녀오고 나서 디저트가 더 당기는데… 연남동 쪽으로 걸어갈 만한 곳 있을까요?",
    views: 112,
    comments: [
      [
        "weekend",
        "2026-10-26T16:05:00",
        "경의선숲길 따라 연남동 쪽으로 걸으면 카페가 많아요!",
      ],
    ],
  },
  {
    id: "sc-talk-14",
    category: "FREE",
    by: "family",
    createdAt: "2026-10-27T09:30:00",
    title: "아이랑 가기 좋은 이번 주 팝업",
    content: [
      "아이 데리고 다니기 편했던 곳 위주로 적어요.",
      "- 서울숲 탐정 스누피 (야외 정원)",
      "- 짱구 전시 (체험형)",
      "- 써모스 럭키 아일랜드 (스타필드 고양)",
      "- 체로프 몽모 (더현대 대구, 몽모 그리기 체험)",
      "",
      "다른 추천 있으면 알려 주세요!",
    ].join("\n"),
    views: 147,
    comments: [
      [
        "ilsan",
        "2026-10-27T10:15:00",
        "써모스는 쇼핑몰 안이라 날씨 상관없어서 좋았어요",
      ],
    ],
  },
];

export interface ShowcaseCommunityPost {
  id: string;
  category: CommunityCategory;
  title: string;
  content: string;
  member: CommunityMember;
  viewCount: number;
  createdAt: string;
}
export const showcaseCommunityPosts: ShowcaseCommunityPost[] =
  communitySeeds.map((seed) => ({
    id: seed.id,
    category: seed.category,
    title: seed.title,
    content: seed.content,
    member: M[seed.by],
    viewCount: seed.views,
    createdAt: seed.createdAt,
  }));
/** 커뮤니티 글 ID → 댓글 */
export const showcaseCommunityComments: Record<string, CommentSeed[]> =
  Object.fromEntries(
    communitySeeds.map((seed, index) => [
      seed.id,
      thread(9100101 + index * 100, seed.comments),
    ]),
  );
export const showcaseMemberIds = new Set(
  Object.values(M).map((item) => item.id),
);
