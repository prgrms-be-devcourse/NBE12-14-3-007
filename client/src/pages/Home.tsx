import { useState, type CSSProperties } from "react";
import { Link, useNavigate } from "react-router-dom";
import {
  AlertTriangle,
  ArrowRight,
  CalendarDays,
  CheckCircle2,
  Check,
  Plus,
  Search,
  ChevronDown,
  Heart,
  MapPin,
  X,
} from "lucide-react";
import { useApp, useLoad } from "../lib/context";
import { previewPosts } from "../lib/demo";
import { dateText, period, regions } from "../lib/format";
import { FestivalCategorySelect } from "../components/FestivalCategorySelect";
import { regionGroups } from "../lib/regions";
import { DISTRICT_POINTS, PROVINCE_ORDER, PROVINCES } from "../lib/koreaMap";
import { richTextToPlainText } from "../components/RichText";
import { KoreaMap, zoomFor, type MapPin as Pin } from "../components/KoreaMap";
import { TrustGradeBadge } from "../components/TrustGradeBadge";
import { FestivalCover } from "../components/FestivalCover";
import {
  Empty,
  FESTIVAL_DEFAULT_IMAGE,
  Loading,
  Photo,
  WeatherBadge,
} from "../components/ui";
import type { EventView } from "../lib/types";

/** 행사 분류 태그는 동일한 색으로 표시합니다. */
const CATEGORY_TAG_COLOR = "#875b3e";
const NOTES = ["#f7e27a", "#f6c6c0", "#cfe3c4"];
/** 홈 포스터 4종. 지도 옆 게시판에서만 장식으로 쓴다. */
const PAPERS = [
  {
    r: -1.6,
    bg: NOTES[0],
    fg: "#222321",
    tape: {
      left: "50%",
      marginLeft: -39,
      transform: "rotate(3deg)",
      background: "#d9a05ad9",
    },
    line: "#dedfd9",
  },
  {
    r: 1.4,
    bg: NOTES[1],
    fg: "#222321",
    tape: { left: 18, transform: "rotate(-5deg)", background: "#fffdf6b3" },
    line: "#dedfd9",
    gray: true,
  },
  {
    r: 1.1,
    bg: NOTES[2],
    fg: "#222321",
    tape: { right: 22, transform: "rotate(4deg)", background: "#fffdf6cc" },
    line: "#dedfd9",
  },
  {
    r: -1.3,
    bg: "#d4e7f5",
    fg: "#222321",
    tape: { left: "40%", transform: "rotate(-3deg)", background: "#d9a05ad9" },
    line: "#dedfd9",
  },
] as const;
const NOTE_TILT = ["-1.5deg", "1.2deg", "-0.6deg"];
const MEMO_TILT = ["-0.8deg", "0.6deg", "-0.4deg"];

/** 행사 지역 코드를 시도 코드로 바꾼다. 경기도 시군 코드(GYEONGGI_*)도 경기도로 본다. */
function provinceOf(region: string) {
  if (region.startsWith("GYEONGGI")) return "GYEONGGI";
  return PROVINCES[region] ? region : null;
}
/** 시군구 이름으로 지도 위 핀 좌표를 찾는다. 못 찾으면 시도 중심 근처에 흩어 놓는다. */
function pinPoint(event: EventView, index: number): [number, number] | null {
  const code = provinceOf(event.region);
  if (!code) return null;
  const points = DISTRICT_POINTS[code] || {};
  const name =
    regions[event.region]?.replace("경기도 ", "") || event.regionDetail || "";
  const hit =
    points[name] ||
    Object.entries(points).find(
      ([key]) => event.regionDetail?.includes(key) || name.includes(key),
    )?.[1];
  if (hit) return [hit[0], hit[1]];
  const shape = PROVINCES[code];
  const angle = index * 2.1;
  return [
    shape.cx + Math.cos(angle) * shape.bb[2] * 0.12,
    shape.cy + Math.sin(angle) * shape.bb[3] * 0.12,
  ];
}
function stampOf(event: EventView) {
  // 한국 시간 기준 오늘 날짜. toISOString은 UTC라 오전 9시 전에는 하루 늦게 나온다.
  const now = new Date();
  const today = [
    now.getFullYear(),
    String(now.getMonth() + 1).padStart(2, "0"),
    String(now.getDate()).padStart(2, "0"),
  ].join("-");
  const begin = event.beginDe.slice(0, 10);
  const end = event.endDe.slice(0, 10);
  const days = (a: string, b: string) =>
    Math.round((Date.parse(b) - Date.parse(a)) / 86400000);
  if (begin > today) return `D-${days(today, begin)}`;
  if (end < today) return "기간 종료";
  return "진행 중";
}

export function Home() {
  const [searchExpanded, setSearchExpanded] = useState(false);
  const [regionExpanded, setRegionExpanded] = useState(false);
  const { mode, api } = useApp();
  const navigate = useNavigate();
  const [category, setCategory] = useState("전체");
  const [region, setRegion] = useState("");
  const [date, setDate] = useState("");
  const [query, setQuery] = useState("");
  const [picked, setPicked] = useState<string | null>(null);
  const [hover, setHover] = useState<number | null>(null);
  const categoryParam = category === "전체" ? undefined : category;
  const label = category === "전체" ? "행사" : category;

  const weather = useLoad(
    () => (region && date ? api.weather(region, date) : Promise.resolve(null)),
    [api, region, date],
  );
  const today = new Intl.DateTimeFormat("sv-SE", {
    timeZone: "Asia/Seoul",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(new Date());
  const mapWeather = useLoad(
    () =>
      picked
        ? api.weather(picked, today).then((weather) => ({ region: picked, weather }))
        : Promise.resolve(null),
    [api, picked, today],
  );
  const selectedWeather =
    mapWeather.data?.region === picked ? mapWeather.data.weather : null;
  // 시도별 진행 중인 행사 수. 개수 전용 API가 없어 목록 API의 totalElements를 쓴다.
  const counts = useLoad(
    () =>
      Promise.all(
        PROVINCE_ORDER.map((code) =>
          api
            .festivals({
              region: code,
              category: categoryParam,
              excludeClosed: true,
            })
            .then((page) => [code, page.totalElements] as const),
        ),
      ).then(
        (entries) => Object.fromEntries(entries) as Record<string, number>,
      ),
    [api, categoryParam],
    { keepPrevious: true },
  );
  const board = useLoad(
    () =>
      api.festivals({
        region: picked || undefined,
        category: categoryParam,
        excludeClosed: true,
      }),
    [api, picked, categoryParam],
    { keepPrevious: true },
  );
  const reports = useLoad(
    () => api.festivals({ providerType: "MEMBER", excludeClosed: true }),
    [api],
  );
  const reviews = useLoad(
    () =>
      mode === "preview"
        ? Promise.resolve(previewPosts().slice(0, 3))
        : api
            .posts(undefined, 0, "likeCount,desc")
            .then((p) => p.content.slice(0, 3)),
    [api, mode],
  );

  const posters = (board.data?.content || []).slice(0, 4);
  const total = board.data?.totalElements ?? 0;
  const pickedShape = picked ? PROVINCES[picked] : null;
  const pickedName = picked ? regions[picked] : "전국";
  const highlighted =
    !picked && hover !== null && posters[hover]
      ? provinceOf(posters[hover].region)
      : null;
  // 같은 시군구에 행사가 여럿이면 핀이 겹치지 않게 옆으로 벌린다(확대 배율 기준 약 30px).
  const zoomScale = zoomFor(picked).s;
  const seen = new Map<string, number>();
  const pins: Pin[] = picked
    ? posters.flatMap((event, i) => {
        const point = pinPoint(event, i);
        if (!point) return [];
        const key = `${Math.round(point[0])},${Math.round(point[1])}`;
        const dup = seen.get(key) || 0;
        seen.set(key, dup + 1);
        const spread = (30 / zoomScale) * dup;
        return point
          ? [
              {
                no: i + 1,
                x: point[0] + spread,
                y: point[1] - spread * 0.4,
                label: `${event.title}, ${event.regionDetail || pickedName}`,
                active: hover === i,
                onEnter: () => setHover(i),
                onLeave: () => setHover((h) => (h === i ? null : h)),
              },
            ]
          : [];
      })
    : [];

  function pick(code: string | null) {
    setPicked(code);
    setHover(null);
  }

  return (
    <div className="home-c">


      <section className="home-search container" aria-label="조건으로 행사 검색">
        <form
          className={`discovery-search${searchExpanded ? " is-expanded" : ""}`}
          onFocus={() => setSearchExpanded(true)}
          onBlur={(event) => {
            if (!event.currentTarget.contains(event.relatedTarget as Node | null)) {
              setSearchExpanded(false);
              setRegionExpanded(false);
            }
          }}
          onKeyDown={(event) => {
            if (event.key === "Escape") {
              event.preventDefault();
              setSearchExpanded(false);
              setRegionExpanded(false);
              (event.target as HTMLElement).blur();
            }
          }}
          onSubmit={(e) => {
            e.preventDefault();
            const params = new URLSearchParams();
            if (categoryParam) params.set("category", categoryParam);
            if (region) params.set("region", region);
            if (date) params.set("date", date);
            if (query.trim()) params.set("q", query.trim());
            navigate(`/explore?${params}`);
          }}
        >
          <div className="discovery-search-bar">
            <input
              aria-label="행사 검색어"
              aria-expanded={searchExpanded}
              aria-controls="home-search-options"
              placeholder="행사명 또는 지역 검색"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
            />
            <button type="submit" className="home-search-submit" aria-label="행사 검색"><Search size={21} /></button>
          </div>
          <div className="discovery-search-filters" id="home-search-options" hidden={!searchExpanded}>
            <div className="filter-chip">
              <MapPin size={15} />
              <span className="home-search-field-label">지역</span>
              <button
                type="button"
                className="home-region-trigger"
                aria-label="지역 선택"
                aria-expanded={regionExpanded}
                aria-controls="home-region-options"
                onClick={() => setRegionExpanded((open) => !open)}
              >
                {region ? PROVINCES[region]?.short || regions[region] || region : "전국"}
                <ChevronDown size={14} aria-hidden="true" />
              </button>
            </div>
            <label className="filter-chip">
              <CalendarDays size={15} />
              <span className="home-search-field-label">날짜</span>
              <input
                aria-label="행사 날짜"
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                onClick={(e) => e.currentTarget.showPicker?.()}
              />
            </label>
            {weather.data && weather.data.condition !== "UNKNOWN" && (
              <WeatherBadge
                condition={weather.data.condition}
                precipitationProbability={weather.data.precipitationProbability}
              />
            )}
            {weather.data && weather.data.condition === "UNKNOWN" && (
              <span className="weather-hint">
                {date < new Date().toISOString().slice(0, 10)
                  ? "지난 날짜는 날씨 제공이 불가합니다"
                  : "오늘 기준 +4일치만 날씨 제공이 가능합니다"}
              </span>
            )}
            {regionExpanded && (
              <div className="home-region-grid" id="home-region-options" role="group" aria-label="검색 지역">
                {[{ value: "", label: "전국" }, ...regionGroups].map((option) => (
                  <button
                    key={option.value}
                    type="button"
                    aria-pressed={region === option.value}
                    className={region === option.value ? "selected" : ""}
                    onClick={(event) => {
                      setRegion(option.value);
                      setRegionExpanded(false);
                      event.currentTarget.closest("form")?.querySelector<HTMLButtonElement>(".home-region-trigger")?.focus();
                    }}
                  >
                    <span>{PROVINCES[option.value]?.short || option.label}</span>
                    {region === option.value && <Check size={14} aria-hidden="true" />}
                  </button>
                ))}
              </div>
            )}
          </div>

        </form>
        {!searchExpanded && (region || date) && (
          <p className="home-search-selection">
            {[region ? regions[region] || region : "전국", date ? dateText(date) : null].filter(Boolean).join(" · ")}
          </p>
        )}
      </section>

      <section className="home-hero container" aria-label="행사 분류 선택">
        <FestivalCategorySelect
          value={category}
          includeAll
          variant="icons"
          onChange={(next) => {
            setCategory(next);
            setHover(null);
          }}
        />
      </section>

      <section className="home-map container" aria-label="지역 지도와 행사">
        <div className="home-map-col">
          <div className={`home-map-weather${picked ? " has-weather" : ""}`} role="status" aria-live="polite">
            {picked ? (
              <>
              <h2>{regions[picked]} 오늘의 날씨</h2>
              {mapWeather.loading ? (
                <p>날씨를 불러오는 중이에요.</p>
              ) : mapWeather.error || !selectedWeather || selectedWeather.condition === "UNKNOWN" ? (
                <p>날씨 정보를 불러올 수 없어요.</p>
              ) : (
                <>
                  <WeatherBadge condition={selectedWeather.condition} />
                  {selectedWeather.precipitationProbability != null && (
                    <p>강수확률 {selectedWeather.precipitationProbability}%</p>
                  )}
                </>
              )}
              <small>지역 대표 지점 기준 예보{mode === "preview" ? " · 미리보기 데이터" : ""}</small>
              </>
            ) : (
              <>
                <h2>원하는 지역을 클릭해보세요</h2>

              </>
            )}
          </div>
          <KoreaMap
            counts={counts.data}
            selected={picked}
            highlighted={highlighted}
            pins={pins}
            onSelect={pick}
          />
        </div>

        <aside
          className="map-board"
          aria-live="polite"
          aria-labelledby="board-title"
        >
          <div className="map-board-head">
            <div>
              <h2 id="board-title">
                {pickedName} {label}
              </h2>
            </div>
            {picked && (
              <button
                type="button"
                className="map-board-close"
                onClick={() => pick(null)}
                aria-label="행사 목록 닫고 전국 지도로"
              >
                <X size={18} />
              </button>
            )}
          </div>
          {board.loading && !board.data ? (
            <Loading />
          ) : posters.length ? (
            <>
              <div
                className={`home-grid map-posters${board.refreshing ? " is-refreshing" : ""}`}
                aria-busy={board.refreshing}
              >
                {posters.map((event, i) => {
                  const paper = PAPERS[i % PAPERS.length];
                  const stamp = stampOf(event);
                  return (
                    <Link
                      key={event.festivalId}
                      to={
                        event.submissionId
                          ? `/submissions/${event.submissionId}`
                          : `/events/${event.festivalId}`
                      }
                      className={`event-card poster ${hover === i ? "on" : ""}`}
                      style={
                        {
                          "--r": `${paper.r}deg`,
                          background: paper.bg,
                          color: paper.fg,
                          marginTop: i % 2 ? 18 : 0,
                        } as CSSProperties
                      }
                      onMouseEnter={() => setHover(i)}
                      onMouseLeave={() => setHover((h) => (h === i ? null : h))}
                      onFocus={() => setHover(i)}
                      onBlur={() => setHover((h) => (h === i ? null : h))}
                    >
                      <span
                        className="poster-tape"
                        aria-hidden="true"
                        style={paper.tape}
                      />
                      <span className="poster-photo">
                        <Photo
                          src={event.imgUrl}
                          alt=""
                          fallbackSrc={FESTIVAL_DEFAULT_IMAGE}
                          className={"gray" in paper ? "gray" : ""}
                        />
                        {picked && (
                          <span className="poster-no" aria-hidden="true">
                            {i + 1}
                          </span>
                        )}
                      </span>
                      <span className="poster-row">
                        <span
                          className="poster-tag"
                          style={{
                            background: CATEGORY_TAG_COLOR,
                          }}
                        >
                          {event.category}
                        </span>
                        <span className="poster-stamp">{stamp}</span>
                      </span>
                      <h3 className="poster-title">{event.title}</h3>
                      <span
                        className="poster-meta"
                        style={{ borderTopColor: paper.line }}
                      >
                        <b>{period(event.beginDe, event.endDe)}</b>
                        <span>
                          {(picked
                            ? event.regionDetail
                            : regions[event.region]) || "지역 미정"}
                        </span>
                      </span>
                    </Link>
                  );
                })}
              </div>
              <Link
                className="map-board-more"
                to={`/explore?${new URLSearchParams({
                  ...(picked ? { region: picked } : {}),
                  ...(categoryParam ? { category: categoryParam } : {}),
                })}`}
              >
                {pickedName} {label} {total}개 모두 보기
                <ArrowRight size={17} />
              </Link>
            </>
          ) : (
            <div
              className="sticky-note map-board-empty"
              style={
                { "--r": "-1.2deg", background: "#f4e2c3" } as CSSProperties
              }
            >
              <strong>아직 찾은 행사가 없어요</strong>
              <span>
                {pickedShape ? `${pickedName}에서` : "지금"} 열리는 행사를 알고
                있다면 제보해 주세요. 확인 후 지도에 올려 드려요.
              </span>
              <Link className="btn dark small" to="/submissions/new">
                행사 제보하기
              </Link>
            </div>
          )}
        </aside>
      </section>



      <section className="home-band" aria-labelledby="home-reports">
        <div className="container">
          <div className="home-band-head">
            <div>
              <h2 id="home-reports">회원제보 행사</h2>

            </div>
            <div className="home-band-actions">
              <Link className="btn secondary" to="/explore?providerType=MEMBER">
                제보 행사 모두 보기
              </Link>
              <Link className="btn dark" to="/submissions/new">
                <Plus size={15} aria-hidden="true" />
                행사 제보하기
              </Link>
            </div>
          </div>
          {reports.loading ? (
            <Loading />
          ) : reports.data?.content.length ? (
            <div className="memo-grid">
              {reports.data.content.slice(0, 3).map((event, i) => (
                <article
                  key={event.festivalId}
                  className="memo-card"
                  style={{ "--r": MEMO_TILT[i] } as CSSProperties}
                >
                  <span className="memo-tape" aria-hidden="true" />
                  <span className="memo-photo">
                    <Photo
                      src={event.imgUrl}
                      alt=""
                      fallbackSrc={FESTIVAL_DEFAULT_IMAGE}
                      fallback={<FestivalCover event={event} />}
                    />
                    <span className="memo-where">
                      {[regions[event.region], event.regionDetail]
                        .filter(Boolean)
                        .join(" ") || "지역 미정"}
                    </span>
                  </span>
                  <span className="memo-row">
                    <span
                      className="poster-tag"
                      style={{
                        background: CATEGORY_TAG_COLOR,
                      }}
                    >
                      {event.category}
                    </span>
                    {event.accuracyVote && (
                      <span className="memo-votes">
                        <span
                          className="vote-accurate"
                          aria-label={`정확해요 ${event.accuracyVote.accurateCount}개`}
                        >
                          <CheckCircle2 size={14} />
                          {event.accuracyVote.accurateCount}
                        </span>
                        <span
                          className="vote-inaccurate"
                          aria-label={`부정확해요 ${event.accuracyVote.inaccurateCount}개`}
                        >
                          <AlertTriangle size={14} />
                          {event.accuracyVote.inaccurateCount}
                        </span>
                      </span>
                    )}
                  </span>
                  <h3>
                    <Link
                      className="memo-link"
                      to={
                        event.submissionId
                          ? `/submissions/${event.submissionId}`
                          : `/events/${event.festivalId}`
                      }
                    >
                      {event.title}
                    </Link>
                  </h3>
                  <span className="memo-foot">
                    <span className="memo-by">
                      {event.submitter ? (
                        <>
                          <b>{event.submitter.nickname}</b> 님이 제보
                          <TrustGradeBadge member={event.submitter} />
                        </>
                      ) : (
                        "이웃 제보"
                      )}
                    </span>
                    <b>{period(event.beginDe, event.endDe)}</b>
                  </span>
                </article>
              ))}
            </div>
          ) : (
            <Empty
              title="아직 진행 중인 이웃 제보가 없어요"

            />
          )}
        </div>
      </section>

      <section
        className="home-notes container"
        aria-labelledby="home-notes-title"
      >
        <div className="home-notes-intro">
          <h2 id="home-notes-title">후기</h2>

          <div className="home-band-actions">
            <Link className="btn secondary" to="/reviews">
              후기 전체 보기
            </Link>
            <Link className="btn dark" to="/reviews/new">
              후기 쓰기
            </Link>
          </div>
        </div>
        <div className="note-grid">
          {reviews.loading ? (
            <Loading />
          ) : reviews.data?.length ? (
            reviews.data.map((post, i) => (
              <Link
                key={post.id}
                to={`/reviews/${post.id}`}
                className="sticky-note review-teaser"
                style={
                  {
                    "--r": NOTE_TILT[i % 3],
                    background: NOTES[i % 3],
                  } as CSSProperties
                }
              >
                <span className="note-event">{post.festivalTitle}</span>
                <h3>{post.title}</h3>
                {(post as { content?: string }).content ? (
                  <p>
                    {richTextToPlainText(
                      (post as { content?: string }).content,
                    ).slice(0, 80)}
                  </p>
                ) : null}
                <span className="note-foot">
                  <span>
                    {post.member.nickname} · {dateText(post.date)}
                  </span>
                  {post.likeCount !== undefined && (
                    <span
                      className="note-likes"
                      aria-label={`좋아요 ${post.likeCount}개`}
                    >
                      <Heart size={14} />
                      {post.likeCount}
                    </span>
                  )}
                </span>
              </Link>
            ))
          ) : (
            <Empty
              title="아직 남겨진 후기가 없어요"

            />
          )}
        </div>
      </section>

    </div>
  );
}
