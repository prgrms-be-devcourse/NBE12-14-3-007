import { NavLink, useOutletContext, useSearchParams } from "react-router-dom";
import { ChevronDown, MessageSquareText } from "lucide-react";
import {
  Empty,
  ErrorState,
  Loading,
  Pagination,
} from "../components/ui";
import { useApp, useLoad } from "../lib/context";
import { dateText } from "../lib/format";
import type { SupportArticle } from "../lib/types";
import type { LayoutContext } from "../components/Layout";

type Kind = "notices" | "faq";


const TABS: { kind: Kind; label: string }[] = [
  { kind: "notices", label: "공지사항" },
  { kind: "faq", label: "자주 묻는 질문" },
];

/** 고객센터: 공지사항과 자주 묻는 질문, 문의하기 바로가기. 글은 관리자 화면에서 쓴다. */
export function SupportPage({ kind }: { kind: Kind }) {
  const { api } = useApp();
  const { openInquiry } = useOutletContext<LayoutContext>();
  const [params, setParams] = useSearchParams();
  const page = Math.max(0, Number(params.get("page")) || 0);
  const notices = kind === "notices";
  const { data, loading, error, reload } = useLoad(
    async () =>
      notices
        ? api.supportNotices(page)
        : { content: await api.supportFaqs(), totalPages: 1, number: 0 },
    [api, notices, page],
  );
  return (
    <div className="container page-space support-page">
      <p className="page-eyebrow eyebrow">CUSTOMER CENTER</p>
      <h1 className="compact-title">고객센터</h1>
      <nav className="support-tabs" aria-label="고객센터 메뉴">
        {TABS.map((tab) => (
          <NavLink key={tab.kind} to={`/support/${tab.kind}`}>
            {tab.label}
          </NavLink>
        ))}
        <button type="button" onClick={openInquiry}>
          문의하기
        </button>
      </nav>
      {loading ? (
        <Loading />
      ) : error ? (
        <ErrorState message={error} retry={reload} />
      ) : !data?.content.length ? (
        <Empty
          title={
            notices ? "아직 공지사항이 없어요" : "아직 등록된 질문이 없어요"
          }
          description="궁금한 점은 문의하기로 남겨 주세요."
        />
      ) : (
        <>
          <section
            className="support-list"
            aria-label={notices ? "공지사항" : "자주 묻는 질문"}
          >
            {data.content.map((article, index) => (
              <SupportEntry
                key={article.id}
                article={article}
                faq={!notices}
                open={notices && page === 0 && index === 0}
              />
            ))}
          </section>
          <Pagination
            page={data.number}
            total={data.totalPages}
            onChange={(next) =>
              setParams((current) => {
                const query = new URLSearchParams(current);
                if (next) query.set("page", String(next));
                else query.delete("page");
                return query;
              })
            }
          />
        </>
      )}
      <aside className="support-contact">
        <MessageSquareText size={26} aria-hidden="true" />
        <div>
          <h2>찾는 답이 없나요?</h2>
          <p>문의를 남기면 운영진이 확인하고 답변해 드려요.</p>
        </div>
        <button type="button" className="btn primary" onClick={openInquiry}>
          문의하기
        </button>
      </aside>
    </div>
  );
}

function SupportEntry({
  article,
  faq,
  open,
}: {
  article: SupportArticle;
  faq: boolean;
  open: boolean;
}) {
  const date = article.createdAt.slice(0, 10);
  return (
    <details open={open}>
      <summary>
        {faq && (
          <span className="support-q" aria-hidden="true">
            Q
          </span>
        )}
        <span className="support-title">{article.title}</span>
        {!faq && <time dateTime={date}>{dateText(date)}</time>}
        <ChevronDown size={18} aria-hidden="true" />
      </summary>
      <div className="support-body">
        {paragraphs(article.content).map((line, index) => (
          <p key={index}>{line}</p>
        ))}
      </div>
    </details>
  );
}

/** 본문은 줄바꿈으로 문단을 나눈다. 빈 줄은 건너뛴다. */
export function paragraphs(content: string) {
  return content
    .split("\n")
    .map((line) => line.trim())
    .filter(Boolean);
}
