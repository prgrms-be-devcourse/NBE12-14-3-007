import { BookOpen, CalendarDays, MapPin, Music2, Palette, Ticket } from "lucide-react";
import { period, regions } from "../lib/format";
import type { EventView } from "../lib/types";

/** 이미지 없는 회원 제보 행사에만 쓰는, 행사 정보로 구성한 표지입니다. */
export function FestivalCover({ event }: { event: EventView }) {
  const category = event.category || "행사";
  const theme = /전시|미술/.test(category) ? "exhibition"
    : /교육|체험/.test(category) ? "class"
    : /공연|음악|콘서트|연극|뮤지컬|국악|무용/.test(category) ? "performance"
    : "festival";
  const Icon = theme === "exhibition" ? Palette
    : theme === "class" ? BookOpen
    : theme === "performance" ? Music2 : Ticket;
  const regionName = (regions[event.region] || event.region || "").trim();
  const area = (event.district || event.regionDetail || "").replace(/\s+/g, " ").trim();
  // 기존 상세 위치에 시·도가 이미 적혀 있으면 그대로 사용해 중복 표시를 피합니다.
  const location = (area === regionName || area.startsWith(`${regionName} `)
    ? area
    : [regionName, area].filter(Boolean).join(" ")) || "지역 미정";

  return (
    <div className={`festival-cover festival-cover-${theme}`} role="img" aria-label={`${event.title}, ${location}, ${period(event.beginDe, event.endDe)}`}>
      <span className="festival-cover-category"><Icon size={19} aria-hidden="true" />{category}</span>
      <strong className="festival-cover-title">{event.title}</strong>
      <span className="festival-cover-location"><MapPin size={14} aria-hidden="true" />{location}</span>
      <span className="festival-cover-date"><CalendarDays size={14} aria-hidden="true" />{period(event.beginDe, event.endDe)}</span>
    </div>
  );
}
