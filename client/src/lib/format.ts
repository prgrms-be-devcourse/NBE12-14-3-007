export const regions: Record<string, string> = {
  SEOUL: "서울특별시",
  BUSAN: "부산광역시",
  DAEGU: "대구광역시",
  INCHEON: "인천광역시",
  GWANGJU: "광주광역시",
  DAEJEON: "대전광역시",
  ULSAN: "울산광역시",
  SEJONG: "세종특별자치시",
  GANGWON: "강원특별자치도",
  CHUNGBUK: "충청북도",
  CHUNGNAM: "충청남도",
  JEONBUK: "전북특별자치도",
  JEONNAM: "전라남도",
  GYEONGBUK: "경상북도",
  GYEONGNAM: "경상남도",
  JEJU: "제주특별자치도",
  GYEONGGI: "경기도",
  JEONNAM_GWANGJU: "전남광주통합특별시",
  ...Object.fromEntries(
    [
      ["SUWON", "수원시"],
      ["GOYANG", "고양시"],
      ["YONGIN", "용인시"],
      ["SEONGNAM", "성남시"],
      ["BUCHEON", "부천시"],
      ["HWASEONG", "화성시"],
      ["ANSAN", "안산시"],
      ["NAMYANGJU", "남양주시"],
      ["ANYANG", "안양시"],
      ["PYEONGTAEK", "평택시"],
      ["SIHEUNG", "시흥시"],
      ["PAJU", "파주시"],
      ["UIJEONGBU", "의정부시"],
      ["GIMPO", "김포시"],
      ["GWANGJU", "광주시"],
      ["GWANGMYEONG", "광명시"],
      ["GUNPO", "군포시"],
      ["HANAM", "하남시"],
      ["OSAN", "오산시"],
      ["YANGJU", "양주시"],
      ["ICHEON", "이천시"],
      ["GURI", "구리시"],
      ["ANSEONG", "안성시"],
      ["POCHEON", "포천시"],
      ["UIWANG", "의왕시"],
      ["YANGPYEONG", "양평군"],
      ["YEOJU", "여주시"],
      ["DONGDUCHEON", "동두천시"],
      ["GWACHEON", "과천시"],
      ["GAPYEONG", "가평군"],
      ["YEONCHEON", "연천군"],
    ].map(([key, name]) => [`GYEONGGI_${key}`, `경기도 ${name}`]),
  ),
};
/** 등록·수정과 홈·행사 검색에서 함께 사용하는 분류입니다. */
export const festivalCategories = [
  "연극",
  "음악/콘서트",
  "뮤지컬/오페라",
  "무용/발레",
  "국악",
  "아동/가족",
  "공연",
  "전시",
  "교육/체험",
  "행사/축제",
  "플리마켓/팝업",
  "기타",
];
export const categories = ["전체", ...festivalCategories];

/** 이전 제보 분류도 현재 검색 분류로 조회하고 수정할 수 있도록 연결합니다. */
export function normalizeFestivalCategory(value?: string | null) {
  const category = value?.trim() || "";
  switch (category) {
    case "축제": return "행사/축제";
    case "플리마켓": return "플리마켓/팝업";
    case "교육":
    case "체험": return "교육/체험";
    default: return category;
  }
}
export const roleNames: Record<string, string> = {
  ROLE_WARNING: "활동 제한",
  ROLE_UNVERIFIED: "탈출 꿈나무",
  ROLE_RECOGNIZED: "탈출 메이커",
  ROLE_TRUSTED: "탈출 마스터",
  ROLE_ADMIN: "관리자",
};
export function dateText(value?: string | null) {
  return value ? value.slice(0, 10).replaceAll("-", ".") : "일정 미정";
}
export function parseDateTime(value: string) {
  const hasTime = /T\d{2}:\d{2}/.test(value);
  const hasZone = /(?:Z|[+-]\d{2}:?\d{2})$/i.test(value);
  return new Date(hasTime && !hasZone ? `${value}+09:00` : value);
}
export function dateTimeText(value: string) {
  const date = parseDateTime(value);
  if (Number.isNaN(date.getTime())) return dateText(value);
  const parts = new Intl.DateTimeFormat("ko-KR", {
    timeZone: "Asia/Seoul",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  }).formatToParts(date);
  const part = (type: Intl.DateTimeFormatPartTypes) =>
    parts.find((p) => p.type === type)?.value;
  return `${part("year")}.${part("month")}.${part("day")} ${part("hour")}:${part("minute")}`;
}
export function period(start?: string, end?: string) {
  return start?.slice(0, 10) === end?.slice(0, 10)
    ? dateText(start)
    : `${dateText(start)} — ${dateText(end)}`;
}
export function eventState(start: string, end: string) {
  const now = Date.now();
  return new Date(end).getTime() < now
    ? "종료"
    : new Date(start).getTime() > now
      ? "개최 예정"
      : "진행 중";
}
export function safeUrl(value?: string | null): string | undefined {
  if (!value) return undefined;
  try {
    const u = new URL(value);
    return ["https:", "http:"].includes(u.protocol) ? u.href : undefined;
  } catch {
    return undefined;
  }
}
// 서버가 준 주소는 그대로 보여 준다. 리사이즈 프록시로 다시 보내지 않는다.
// 주소가 없거나 http(s)가 아니면 호출하는 쪽에서 기본 이미지를 쓴다.
export function imageUrl(value?: string | null) {
  if (!value) return undefined;
  if (value.startsWith("/images/") || value.startsWith("blob:")) return value;
  return safeUrl(value);
}
/** 남은 초를 "1분 30초", "45초"처럼 읽기 좋게 바꾼다. */
export function waitText(seconds: number) {
  const total = Math.max(0, Math.ceil(seconds));
  const minutes = Math.floor(total / 60);
  const rest = total % 60;
  if (minutes === 0) return `${rest}초`;
  return rest === 0 ? `${minutes}분` : `${minutes}분 ${rest}초`;
}
export function errorText(error: unknown) {
  return error instanceof Error
    ? error.message
    : "요청을 처리하지 못했어요. 잠시 후 다시 시도해 주세요.";
}

/** 시군구가 원본 상세 지역에도 포함되어 있으면 한 번만 표시한다. */
export function formatRegionDetail(district?: string | null, detail?: string | null) {
  const area = district?.trim() || "";
  const address = detail?.trim() || "";
  if (!area) return address;
  if (!address || address === area) return area;
  if (address.startsWith(`${area} `)) return address;
  return `${area} ${address}`;
}
