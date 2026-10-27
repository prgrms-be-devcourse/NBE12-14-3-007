import { useState, type CSSProperties } from "react";
import { Link, useNavigate } from "react-router-dom";
import {
  AlertTriangle,
  ArrowRight,
  CalendarDays,
  CheckCircle2,
  ChevronDown,
  Heart,
  MapPin,
  Search,
  X,
} from "lucide-react";
import { useApp, useLoad } from "../lib/context";
import { previewPosts } from "../lib/demo";
import { categories, dateText, period, regions } from "../lib/format";
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

/** 분류 태그 색. 색은 태그에만 쓰고 카드 바탕에는 쓰지 않는다. */
const TAG_COLORS: Record<string, string> = {
  축제: "#c8401c",
  공연: "#2343d1",
  전시: "#1b1b1b",
  플리마켓: "#1f6b4a",
  체험: "#7a5a00",
  교육: "#5b3a8c",
};
/** 홈 포스터 4종. 지도 옆 게시판에서만 장식으로 쓴다. */
const PAPERS = [
  {
    r: -1.6,
    bg: "#fffdf6",
    fg: "#1b1b1b",
    tape: {
      left: "50%",
      marginLeft: -39,
      transform: "rotate(3deg)",
      background: "#f2c14ed9",
    },
    line: "#1b1b1b",
  },
  {
    r: 1.4,
    bg: "#2343d1",
    fg: "#ffffff",
    tape: { left: 18, transform: "rotate(-5deg)", background: "#fffdf6b3" },
    line: "#ffffff66",
    gray: true,
  },
  {
    r: 1.1,
    bg: "#f2c14e",
    fg: "#1b1b1b",
    tape: { right: 22, transform: "rotate(4deg)", background: "#fffdf6cc" },
    line: "#1b1b1b",
  },
  {
    r: -1.3,
    bg: "#1b1b1b",
    fg: "#fffdf6",
    tape: { left: "40%", transform: "rotate(-3deg)", background: "#f2c14ed9" },
    line: "#ffffff4d",
  },
] as const;
const NOTES = ["#f7e27a", "#f6c6c0", "#cfe3c4"];
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
  const today = new Date().toISOString().slice(0, 10);
  const begin = event.beginDe.slice(0, 10);
  const end = event.endDe.slice(0, 10);
  const days = (a: string, b: string) =>
    Math.round((Date.parse(b) - Date.parse(a)) / 86400000);
  if (begin > today) return { text: `D-${days(today, begin)}`, hot: false };
  if (end < today) return { text: "기간 종료", hot: false };
  if (days(today, end) <= 2) return { text: "곧 마감", hot: true };
  return { text: "진행 중", hot: false };
}

export function Home() {
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
  );
  const board = useLoad(
    () =>
      api.festivals({
        region: picked || undefined,
        category: categoryParam,
        excludeClosed: true,
      }),
    [api, picked, categoryParam],
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
  const empties = counts.data
    ? PROVINCE_ORDER.filter((code) => !counts.data![code]).map(
        (code) => PROVINCES[code].short,
      )
    : [];

  function pick(code: string | null) {
    setPicked(code);
    setHover(null);
  }

  return (
    <div className="home-c">
      <section className="home-hero container" aria-labelledby="home-title">
        <h1 id="home-title">이번 주말, 어디로 떠나볼까요?</h1>
        <div className="category-tabs" role="group" aria-label="행사 종류">
          {categories.map((c) => (
            <button
              key={c}
              type="button"
              className={category === c ? "active" : ""}
              aria-pressed={category === c}
              onClick={() => {
                setCategory(c);
                setHover(null);
              }}
            >
              {c}
            </button>
          ))}
        </div>
      </section>

      <section className="home-map container" aria-label="지역 지도와 행사">
        <div className="home-map-col">
          <div className="home-map-weather" role="status" aria-live="polite">
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
                <h2>지역별 행사 찾기</h2>
                <p>지도에서 지역을 눌러보세요.</p>
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
          <div className="map-legend">
            <span aria-hidden="true">
              행사 수 <i className="lv0" /> <i className="lv1" />
              <i className="lv2" /> <i className="lv3" /> 많음
            </span>
            <span>진행 중인 {label} 기준</span>
          </div>
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
          {board.loading ? (
            <Loading />
          ) : posters.length ? (
            <>
              <div className="home-grid map-posters">
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
                            background: TAG_COLORS[event.category] || "#1b1b1b",
                          }}
                        >
                          {event.category}
                        </span>
                        <span
                          className={`poster-stamp ${stamp.hot ? "hot" : ""}`}
                        >
                          {stamp.text}
                        </span>
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
                { "--r": "-1.2deg", background: "#f7e27a" } as CSSProperties
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

      <section className="home-search container" aria-label="조건으로 행사 검색">
        <form
          className="discovery-search"
          onSubmit={(e) => {
            e.preventDefault();
            const params = new URLSearchParams();
            if (region) params.set("region", region);
            if (date) params.set("date", date);
            if (query.trim()) params.set("q", query.trim());
            navigate(`/explore?${params}`);
          }}
        >
          <div className="discovery-search-filters">
            <label className="filter-chip">
              <MapPin size={15} />
              <select
                aria-label="지역 선택"
                value={region}
                onChange={(e) => setRegion(e.target.value)}
              >
                <option value="">전국</option>
                {regionGroups.map((group) => (
                  <option key={group.value} value={group.value}>
                    {group.label}
                  </option>
                ))}
              </select>
              <ChevronDown size={14} />
            </label>
            <label className="filter-chip">
              <CalendarDays size={15} />
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
          </div>
          <div className="discovery-search-bar">
            <Search size={19} />
            <input
              aria-label="행사 검색어"
              placeholder="어떤 행사를 찾고 있나요?"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
            <button className="btn primary">검색</button>
          </div>
        </form>
      </section>

      <section className="home-band" aria-labelledby="home-reports">
        <div className="container">
          <div className="home-band-head">
            <div>
              <h2 id="home-reports">이웃이 제보한 행사</h2>
              <p>
                공공데이터에 없는 작은 행사를 이웃들이 직접 알려 줬어요.
                정확해요 투표로 함께 확인해요.
              </p>
            </div>
            <div className="home-band-actions">
              <Link className="btn secondary" to="/explore?providerType=MEMBER">
                제보 행사 모두 보기
              </Link>
              <Link className="btn dark" to="/submissions/new">
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
                        background: TAG_COLORS[event.category] || "#1b1b1b",
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
              description="알고 있는 동네 행사를 첫 번째로 알려 주세요."
            />
          )}
        </div>
      </section>

      <section
        className="home-notes container"
        aria-labelledby="home-notes-title"
      >
        <div className="home-notes-intro">
          <h2 id="home-notes-title">이웃이 붙이고 간 쪽지</h2>
          <p>
            행사에 다녀온 이웃들이 남긴 후기예요. 좋아요를 많이 받은 후기부터
            보여드려요.
          </p>
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
              description="다녀온 행사의 이야기를 첫 쪽지로 남겨 주세요."
            />
          )}
        </div>
      </section>

      <section className="container home-cta">
        <div>
          <h2>비어 있는 지역을 같이 채워 주세요</h2>
          <p>
            {empties.length
              ? `지금 ${empties.join(", ")}에는 열리는 행사가 없어요. 알고 있는 행사가 있다면 제보해 주세요.`
              : "작은 동네 행사도 좋아요. 알고 있는 행사가 있다면 제보해 주세요."}
          </p>
        </div>
        <Link className="btn primary" to="/submissions/new">
          행사 제보하기
        </Link>
      </section>
    </div>
  );
}
