import { MapPin } from "lucide-react";
import { regionGroups, selectedRegion } from "../lib/regions";

export function RegionSelects({
  value,
  onChange,
  variant = "filter",
}: {
  value: string;
  onChange: (value: string) => void;
  variant?: "filter" | "discovery" | "form";
}) {
  const { province, district } = selectedRegion(value);
  const className =
    variant === "filter"
      ? "filter-select region-select"
      : variant === "form"
        ? "form-region-select"
        : "region-select";
  return (
    <>
      <label className={className}>
        {variant !== "form" && <MapPin size={18} />}
        <div>
          <span>
            시·도
            {variant === "form" && <b className="required">*</b>}
          </span>
          <select
            aria-label="시·도 선택"
            required={variant === "form"}
            value={province?.value || ""}
            onChange={(e) => onChange(e.target.value)}
          >
            <option value="">
              {variant === "form" ? "시·도 선택" : "전국"}
            </option>
            {regionGroups.map((group) => (
              <option key={group.value} value={group.value}>
                {group.label}
              </option>
            ))}
          </select>
        </div>
      </label>
      {/* 제보 폼은 "상세 주소" 자유 입력란이 따로 있어서, 여기선 검색·둘러보기 화면에만 보여준다. */}
      {variant !== "form" && province && province.districts.length > 0 && (
        <label className={className}>
          <div>
            <span>시·군·구</span>
            <select
              aria-label="시·군·구 선택"
              value={district}
              onChange={(e) => onChange(e.target.value || province.value)}
            >
              <option value="">전체</option>
              {province.districts.map((d) => (
                <option key={d.value} value={d.value}>
                  {d.label}
                </option>
              ))}
            </select>
          </div>
        </label>
      )}
    </>
  );
}
