import { useEffect, useState } from "react";
import { Link, useSearchParams } from "react-router-dom";
import {
  ArrowRight,
  CalendarDays,
  Grid2X2,
  MapPin,
  ChevronDown,
  Check,
  List,
  RotateCcw,
  Search,
} from "lucide-react";
import { useApp, useLoad } from "../lib/context";
import { normalizeFestivalCategory } from "../lib/format";
import { FestivalCategorySelect } from "../components/FestivalCategorySelect";
import { selectedRegion, regionGroups } from "../lib/regions";
import { PROVINCES } from "../lib/koreaMap";
import {
  Empty,
  ErrorState,
  EventCard,
  Loading,
  Pagination,
  WeatherBadge,
} from "../components/ui";

export function Explore() {
  const { api, mode } = useApp();
  const [params, setParams] = useSearchParams();
  const [layout, setLayout] = useState("grid");
  const [searchExpanded, setSearchExpanded] = useState(false);
  const [regionExpanded, setRegionExpanded] = useState(false);

  const category = normalizeFestivalCategory(params.get("category") || "전체");
  const region = params.get("region") || "";
  const date = params.get("date") || "";
  const query = params.get("q") || "";
  const sort = params.get("sort") || "soon";
  const providerType = params.get("providerType") || "";
  const excludeClosed = params.get("excludeClosed") !== "false";
  const page = Math.max(0, Number(params.get("page")) || 0);
  const [text, setText] = useState(query);

  useEffect(() => setText(query), [query]);

  function setFilter(key: string, value: string) {
    const next = new URLSearchParams(params);
    if (value) next.set(key, value);
    else next.delete(key);
    if (key !== "page") next.delete("page");
    setParams(next);
  }

  const { province, district } = selectedRegion(region);
  const apiRegion = province?.value || region;
  const apiRegionDetail = province?.districts.find(
    (d) => d.value === district,
  )?.label;
  const weather = useLoad(
    () =>
      apiRegion && date ? api.weather(apiRegion, date) : Promise.resolve(null),
    [api, apiRegion, date],
  );
  const { data, loading, refreshing, error, reload } = useLoad(
    () =>
      api.festivals({
        keyword: query || undefined,
        region: apiRegion || undefined,
        regionDetail: apiRegionDetail || undefined,
        providerType:
          providerType === "PUBLIC" || providerType === "MEMBER"
            ? providerType
            : undefined,
        category: category === "전체" ? undefined : category,
        date: date || undefined,
        excludeClosed,
        page,
        sort:
          sort === "name" || sort === "likes" || sort === "recent"
            ? sort
            : "soon",
      }),
    [
      api,
      query,
      apiRegion,
      apiRegionDetail,
      providerType,
      category,
      date,
      excludeClosed,
      page,
      sort,
    ],
    { keepPrevious: true },
  );

  const events = data?.content || [];
  const currentPage = data?.number ?? page;

  return (
    <div className="container page-space explore-page home-c">
      <h1 className="explore-title">행사</h1>

      <section className="home-search" aria-label="행사 검색 조건">
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
            setSearchExpanded(false);
            setRegionExpanded(false);
            (event.target as HTMLElement).blur();
          }
        }}
        onSubmit={(event) => {
          event.preventDefault();
          setFilter("q", text.trim());
        }}
      >
        <div className="discovery-search-filters" id="explore-search-options" hidden={!searchExpanded}>
          <div className="filter-chip">
            <MapPin size={15} />
            <span className="home-search-field-label">지역</span>
            <button type="button" className="home-region-trigger" aria-expanded={regionExpanded} aria-controls="explore-region-options" onClick={() => setRegionExpanded(!regionExpanded)}>
              {province ? [PROVINCES[province.value]?.short || province.label, apiRegionDetail].filter(Boolean).join(" ") : "전국"}
              <ChevronDown size={14} />
            </button>
          </div>
          <label className="filter-chip">
            <CalendarDays size={17} />
            <span className="home-search-field-label">날짜</span>
            <input
              type="date"
              aria-label="날짜 필터"
              value={date}
              onChange={(event) => setFilter("date", event.target.value)}
              onClick={(event) => event.currentTarget.showPicker?.()}
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
            <div className="explore-region-options" id="explore-region-options">
              <div className="home-region-grid" role="group" aria-label="시·도 선택">
                {[{ value: "", label: "전국" }, ...regionGroups].map((option) => (
                  <button key={option.value} type="button" className={apiRegion === option.value ? "selected" : ""} aria-pressed={apiRegion === option.value} onClick={() => setFilter("region", option.value)}>
                    <span>{PROVINCES[option.value]?.short || option.label}</span>
                    {apiRegion === option.value && <Check size={14} />}
                  </button>
                ))}
              </div>
              {province && province.districts.length > 0 && (
                <div className="home-region-grid" role="group" aria-label="시·군·구 선택">
                  {[{ value: province.value, label: "전체" }, ...province.districts].map((option) => (
                    <button key={option.value} type="button" className={region === option.value ? "selected" : ""} aria-pressed={region === option.value} onClick={() => { setFilter("region", option.value); setRegionExpanded(false); }}>
                      {option.label}
                    </button>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
        <div className="discovery-search-bar">
          <input
            aria-label="행사 검색"
            placeholder="행사명 또는 지역 검색"
            aria-expanded={searchExpanded}
            aria-controls="explore-search-options"
            value={text}
            onChange={(event) => setText(event.target.value)}
          />
          <button type="submit" className="home-search-submit" aria-label="행사 검색">
            <Search size={21} />
          </button>
        </div>
      </form>
      </section>

      <div className="filter-bottom festival-category-toolbar">
        <FestivalCategorySelect
          value={category}
          includeAll
          variant="icons"
          onChange={(next) => setFilter("category", next)}
        />
        <button
          className="text-button muted"
          onClick={() => {
            setParams({});
            setText("");
          }}
        >
          <RotateCcw size={14} />
          필터 초기화
        </button>
      </div>

      <div className="results-toolbar">
        <p>
          총 <strong>{data?.totalElements || 0}</strong>개의 행사
          {mode === "preview" && <span className="muted">· 예시 데이터</span>}
        </p>
        <div className="result-options">
          <label className="checkbox-label compact-checkbox">
            <span>종료 행사 제외</span>
            <input
              type="checkbox"
              checked={excludeClosed}
              onChange={(event) =>
                setFilter(
                  "excludeClosed",
                  event.target.checked ? "true" : "false",
                )
              }
            />
          </label>
          <select
            aria-label="데이터 출처"
            value={providerType}
            onChange={(event) => setFilter("providerType", event.target.value)}
          >
            <option value="">모든 출처</option>
            <option value="PUBLIC">공공 행사</option>
            <option value="MEMBER">회원제보 행사</option>
          </select>
          <select
            aria-label="행사 정렬"
            value={sort}
            onChange={(event) => setFilter("sort", event.target.value)}
          >
            <option value="soon">시작일순</option>
            <option value="recent">최근 등록순</option>
            <option value="likes">좋아요순</option>
            <option value="name">이름순</option>
          </select>
          <div className="layout-toggle">
            <button
              onClick={() => setLayout("grid")}
              className={layout === "grid" ? "active" : ""}
              aria-label="카드로 보기"
              aria-pressed={layout === "grid"}
            >
              <Grid2X2 size={17} />
            </button>
            <button
              onClick={() => setLayout("list")}
              className={layout === "list" ? "active" : ""}
              aria-label="목록으로 보기"
              aria-pressed={layout === "list"}
            >
              <List size={18} />
            </button>
          </div>
        </div>
      </div>

      {loading && !data ? (
        <Loading cards />
      ) : error ? (
        <ErrorState message={error} retry={reload} />
      ) : events.length ? (
        <div
          className={`${layout === "grid" ? "event-grid" : "event-list"}${refreshing ? " is-refreshing" : ""}`}
          aria-busy={refreshing}
        >
          {events.map((event) => (
            <EventCard
              key={event.festivalId}
              event={event}
              list={layout === "list"}
            />
          ))}
        </div>
      ) : (
        <Empty
          title="조건에 맞는 행사가 없어요"
          description="날짜나 지역을 바꾸면 새로운 행사를 만날 수 있어요."
          action={
            <button
              className="btn secondary"
              onClick={() => {
                setParams({});
                setText("");
              }}
            >
              전체 행사 보기
            </button>
          }
        />
      )}

      {!error && data && (
        <Pagination
          page={currentPage}
          total={data.totalPages}
          onChange={(nextPage) => setFilter("page", String(nextPage))}
        />
      )}

      <div className="soft-callout">
        <span>
          찾던 행사가 보이지 않나요? 알고 있는 행사를 직접 알려주세요.
        </span>
        <Link to="/submissions/new">
          행사 제보하기
          <ArrowRight size={16} />
        </Link>
      </div>
    </div>
  );
}
