import { ChevronLeft } from "lucide-react";
import { MAP_VIEWBOX, PROVINCE_ORDER, PROVINCES } from "../lib/koreaMap";

export interface MapPin {
  no: number;
  /** 지도 좌표(MAP_VIEWBOX 기준) */
  x: number;
  y: number;
  label: string;
  active: boolean;
  onEnter: () => void;
  onLeave: () => void;
}

const V = MAP_VIEWBOX;
const CX = V.x + V.w / 2;
const CY = V.y + V.h / 2;

/** 선택한 시도를 화면 가운데로 키울 때의 배율과 중심 */
export function zoomFor(code: string | null) {
  const shape = code ? PROVINCES[code] : null;
  if (!shape) return { s: 1, cx: CX, cy: CY };
  const [bx, by, bw, bh] = shape.bb;
  return {
    s: Math.min((V.w * 0.62) / bw, (V.h * 0.62) / bh, 7),
    cx: bx + bw / 2,
    cy: by + bh / 2,
  };
}

function level(count: number, max: number) {
  if (!count) return 0;
  if (count <= max * 0.15) return 1;
  if (count <= max * 0.45) return 2;
  return 3;
}

export function KoreaMap({
  counts,
  selected,
  highlighted,
  pins,
  onSelect,
}: {
  counts: Record<string, number> | null;
  selected: string | null;
  /** 전국 화면에서 포스터에 마우스를 올렸을 때 칠할 지역 */
  highlighted: string | null;
  pins: MapPin[];
  onSelect: (code: string | null) => void;
}) {
  const max = Math.max(1, ...Object.values(counts || {}));
  const zoom = zoomFor(selected);
  const transform = `translate(${CX}px, ${CY}px) scale(${zoom.s}) translate(${-zoom.cx}px, ${-zoom.cy}px)`;
  const toPercent = (x: number, y: number) => ({
    left: `${((zoom.s * (x - zoom.cx) + CX - V.x) / V.w) * 100}%`,
    top: `${((zoom.s * (y - zoom.cy) + CY - V.y) / V.h) * 100}%`,
  });

  return (
    <div className="korea-map">
      <svg
        viewBox={`${V.x} ${V.y} ${V.w} ${V.h}`}
        role="group"
        aria-label="대한민국 시도 지도. 시도 이름 버튼으로도 고를 수 있어요."
      >
        <g className="korea-map-zoom" style={{ transform }}>
          {PROVINCE_ORDER.map((code) => {
            const shape = PROVINCES[code];
            const lv = counts ? level(counts[code] || 0, max) : 1;
            const state =
              selected === code
                ? "on"
                : selected
                  ? "dim"
                  : highlighted === code
                    ? "on"
                    : "";
            return (
              <path
                key={code}
                className={`map-region lv${lv} ${state}`}
                d={shape.d}
                onClick={() => onSelect(code)}
              />
            );
          })}
          <g
            className={`map-leaders ${selected ? "hide" : ""}`}
            aria-hidden="true"
          >
            {PROVINCE_ORDER.filter((code) => PROVINCES[code].leader).map(
              (code) => {
                const p = PROVINCES[code];
                return (
                  <g key={code}>
                    <line x1={p.cx} y1={p.cy} x2={p.label[0]} y2={p.label[1]} />
                    <circle cx={p.cx} cy={p.cy} r={3} />
                  </g>
                );
              },
            )}
          </g>
        </g>
      </svg>

      {!selected &&
        PROVINCE_ORDER.map((code) => {
          const p = PROVINCES[code];
          const count = counts?.[code];
          return (
            <button
              key={code}
              type="button"
              className={`map-label ${count === 0 ? "zero" : ""} ${highlighted === code ? "on" : ""}`}
              style={{
                left: `clamp(64px, ${((p.label[0] - V.x) / V.w) * 100}%, calc(100% - 64px))`,
                top: `${((p.label[1] - V.y) / V.h) * 100}%`,
              }}
              onClick={() => onSelect(code)}
              aria-label={`${p.short}${count === undefined ? "" : `, 진행 중인 행사 ${count}개`}`}
            >
              {p.short}
              {count !== undefined && <b>{count}</b>}
            </button>
          );
        })}

      {selected && (
        <>
          <button
            type="button"
            className="map-back"
            onClick={() => onSelect(null)}
          >
            <ChevronLeft size={18} />
            전국 지도
          </button>
          {pins.map((pin) => (
            <button
              key={pin.no}
              type="button"
              className={`map-pin ${pin.active ? "on" : ""}`}
              style={toPercent(pin.x, pin.y)}
              onMouseEnter={pin.onEnter}
              onMouseLeave={pin.onLeave}
              onFocus={pin.onEnter}
              onBlur={pin.onLeave}
              aria-label={`${pin.no}번 ${pin.label}`}
            >
              {pin.no}
            </button>
          ))}
        </>
      )}
    </div>
  );
}
