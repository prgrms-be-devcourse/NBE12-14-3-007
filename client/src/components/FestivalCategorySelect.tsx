import { festivalCategories } from "../lib/format";
import { useRef } from "react";
import { LayoutGrid, Music2, Mic2, Ticket, Image, GraduationCap, PartyPopper, ShoppingBag, Ellipsis, ChevronRight, ChevronLeft } from "lucide-react";
import { StageIcon, BalletShoesIcon, JangguIcon, FamilyIcon } from "./FestivalCategoryIcons";

const categoryIcons = [StageIcon, Music2, Mic2, BalletShoesIcon, JangguIcon, FamilyIcon, Ticket, Image, GraduationCap, PartyPopper, ShoppingBag, Ellipsis];

/** 등록·홈·검색에서 동일한 순서와 배치로 보여주는 행사 분류 선택입니다. */
export function FestivalCategorySelect({
  value,
  onChange,
  includeAll = false,
  variant = "grid",
}: {
  value: string;
  onChange: (category: string) => void;
  includeAll?: boolean;
  variant?: "grid" | "icons";
}) {
  const strip = useRef<HTMLDivElement>(null);
  if (variant === "icons") {
    const items = includeAll ? ["전체", ...festivalCategories] : festivalCategories;
    return (
      <div className="festival-category-navigation">
        <button type="button" className="festival-category-next" aria-label="이전 행사 분류 보기" onClick={() => strip.current?.scrollBy({ left: -330, behavior: "smooth" })}><ChevronLeft size={19} /></button>
        <div className="festival-category-strip" ref={strip} role="group" aria-label="행사 종류">
          {items.map((category) => {
            const Icon = category === "전체" ? LayoutGrid : categoryIcons[festivalCategories.indexOf(category)];
            return <button key={category} type="button" className={value === category ? "active" : ""} aria-pressed={value === category} onClick={() => onChange(category)}>
              <Icon size={23} strokeWidth={1.5} aria-hidden="true" />
              <span>{category}</span>
            </button>;
          })}
        </div>
        <button type="button" className="festival-category-next" aria-label="다음 행사 분류 보기" onClick={() => {
          const list = strip.current;
          if (!list) return;
          list.scrollBy({ left: 330, behavior: "smooth" });
        }}><ChevronRight size={19} /></button>
      </div>
    );
  }
  function option(category: string, className = "") {
    return (
      <button
        key={category}
        type="button"
        className={`${className}${value === category ? " active" : ""}`.trim()}
        aria-pressed={value === category}
        onClick={() => onChange(category)}
      >
        {category}
      </button>
    );
  }

  return (
    <div
      className={`category-tabs festival-category-select${includeAll ? " has-all" : ""}`}
      role="group"
      aria-label="행사 종류"
    >
      {includeAll && option("전체", "festival-category-all")}
      <div className="festival-category-grid">
        {festivalCategories.map((category) => option(category))}
      </div>
    </div>
  );
}
