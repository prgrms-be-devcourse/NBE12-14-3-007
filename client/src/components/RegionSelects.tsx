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
  const hasDistricts = Boolean(province?.districts.length);
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
            {province && !regionGroups.some((group) => group.value === province.value) && (
              <option value={province.value}>{province.label} (기존 제보)</option>
            )}
            {regionGroups.map((group) => (
              <option key={group.value} value={group.value}>
                {group.label}
              </option>
            ))}
          </select>
        </div>
      </label>
      {(variant === "form" || hasDistricts) && (
        <label className={className}>
          <div>
            <span>
              시·군·구
              {variant === "form" && (!province || hasDistricts) && <b className="required">*</b>}
            </span>
            <select
              aria-label="시·군·구 선택"
              required={variant === "form" && hasDistricts}
              disabled={!hasDistricts}
              value={district}
              onChange={(e) => onChange(e.target.value || province?.value || "")}
            >
              <option value="">
                {!province
                  ? "시·도를 먼저 선택해 주세요"
                  : !hasDistricts
                    ? "시·군·구 선택 대상 없음"
                    : variant === "form" ? "시·군·구 선택" : "전체"}
              </option>
              {province?.districts.map((d) => (
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
