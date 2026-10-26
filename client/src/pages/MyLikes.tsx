import { Link, useSearchParams } from "react-router-dom";
import { Heart } from "lucide-react";
import { ReviewRow } from "../components/ReviewRow";
import {
  Empty,
  ErrorState,
  EventCard,
  Loading,
  Pagination,
} from "../components/ui";
import { useApp, useLoad } from "../lib/context";

type Kind = "festivals" | "posts";

const KINDS: { key: Kind; label: string }[] = [
  { key: "festivals", label: "행사" },
  { key: "posts", label: "후기" },
];

/** 마이페이지 "좋아요한 목록": 좋아요한 행사·후기를 탭으로 나눠 보여 준다. */
export function MyLikes() {
  const { api } = useApp();
  const [params, setParams] = useSearchParams();
  const kind: Kind = params.get("kind") === "posts" ? "posts" : "festivals";
  const page = Math.max(0, Number(params.get("page")) || 0);

  function move(next: { kind?: Kind; page?: number }) {
    const query = new URLSearchParams(params);
    query.set("tab", "likes");
    query.set("kind", next.kind ?? kind);
    if (next.page) query.set("page", String(next.page));
    else query.delete("page");
    setParams(query);
  }

  const festivals = useLoad(
    () =>
      kind === "festivals" ? api.myLikedFestivals(page) : Promise.resolve(null),
    [api, kind, page],
  );
  const posts = useLoad(
    () => (kind === "posts" ? api.myLikedPosts(page) : Promise.resolve(null)),
    [api, kind, page],
  );
  const result = kind === "festivals" ? festivals : posts;
  const data = result.data;
  const label = kind === "festivals" ? "행사" : "후기";

  return (
    <section className="my-likes" aria-label="좋아요한 목록">
      <div className="section-heading">
        <div>
          <h2>좋아요한 목록</h2>
          <p className="muted">
            마음에 들어 좋아요를 누른 행사와 후기예요. 최근에 누른 순서로
            보여요.
          </p>
        </div>
      </div>
      <div className="category-tabs" role="group" aria-label="좋아요 종류">
        {KINDS.map((item) => (
          <button
            key={item.key}
            type="button"
            className={kind === item.key ? "active" : ""}
            aria-pressed={kind === item.key}
            onClick={() => move({ kind: item.key, page: 0 })}
          >
            {item.label}
          </button>
        ))}
      </div>

      {result.loading ? (
        <Loading cards={kind === "festivals"} />
      ) : result.error ? (
        <ErrorState message={result.error} retry={result.reload} />
      ) : !data?.content.length ? (
        <Empty
          icon={<Heart size={30} />}
          title={
            page > 0
              ? "이 페이지에는 좋아요한 항목이 없어요"
              : `아직 좋아요한 ${label}가 없어요`
          }
          description={
            kind === "festivals"
              ? "마음에 드는 행사에 좋아요를 누르면 여기에 모여요."
              : "도움이 된 후기에 좋아요를 누르면 여기에 모여요."
          }
          action={
            <div className="my-likes-links">
              <Link className="btn primary" to="/explore">
                지역 문화행사 보러 가기
              </Link>
              <Link className="btn secondary" to="/reviews">
                행사 후기 보러 가기
              </Link>
            </div>
          }
        />
      ) : (
        <>
          <p className="my-likes-count">
            좋아요한 {label} <strong>{data.totalElements}</strong>개
          </p>
          {kind === "festivals" && festivals.data ? (
            <div className="event-grid">
              {festivals.data.content.map((event) => (
                <EventCard key={event.festivalId} event={event} />
              ))}
            </div>
          ) : posts.data ? (
            <div className="post-list">
              {posts.data.content.map((post) => (
                <ReviewRow key={post.id} post={post} placeholder />
              ))}
            </div>
          ) : null}
          <Pagination
            page={data.number}
            total={data.totalPages}
            onChange={(next) => move({ page: next })}
          />
        </>
      )}
    </section>
  );
}
