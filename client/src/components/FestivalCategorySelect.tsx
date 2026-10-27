import { festivalCategories } from "../lib/format";

/** 등록·홈·검색에서 동일한 순서와 배치로 보여주는 행사 분류 선택입니다. */
export function FestivalCategorySelect({
  value,
  onChange,
  includeAll = false,
}: {
  value: string;
  onChange: (category: string) => void;
  includeAll?: boolean;
}) {
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
