import { Link, NavLink } from "react-router-dom";
import { ChevronDown, MessageSquareText } from "lucide-react";
import { PageTitle } from "../components/ui";

type Kind = "notices" | "faq";

type Entry = { title: string; body: string[]; date?: string };

/*
 * 공지사항과 자주 묻는 질문은 아직 서버 기능이 없어 화면에 고정해 둔다.
 * 내용을 바꾸려면 아래 목록을 고치면 된다. 최신 공지를 위에 둔다.
 */
const NOTICES: Entry[] = [
  {
    date: "2026-10-27",
    title: "고객센터를 열었어요",
    body: [
      "공지사항과 자주 묻는 질문을 고객센터 한곳에서 볼 수 있어요.",
      "여기서 답을 찾지 못했다면 문의하기로 남겨 주세요. 답변은 마이페이지 문의 탭에서 확인할 수 있어요.",
    ],
  },
  {
    date: "2026-10-27",
    title: "행사 제보 전에 확인해 주세요",
    body: [
      "행사 이름, 일정, 장소, 안내 링크를 공식 채널에서 한 번 더 확인한 뒤 제보해 주세요.",
      "사실과 다른 제보는 다른 이웃의 신고를 받을 수 있고, 운영 정책에 따라 활동이 제한될 수 있어요.",
    ],
  },
  {
    date: "2026-10-27",
    title: "커뮤니티에서 함께 지켜 주세요",
    body: [
      "동행을 구할 때는 공개된 장소에서 만나고, 연락처 같은 개인정보는 글에 남기지 말아 주세요.",
      "불편한 글이나 댓글은 신고 버튼으로 알려 주시면 운영진이 확인할게요.",
    ],
  },
];

const FAQ: Entry[] = [
  {
    title: "행사는 어떻게 제보하나요?",
    body: [
      "화면 위의 ‘행사 제보하기’ 버튼을 눌러 주세요. 행사 이름, 종류, 시작일과 종료일, 시·도와 시·군·구, 행사 참고 링크는 꼭 적어야 해요.",
      "제보한 행사는 행사 상세 화면에서 고치거나 지울 수 있고, 마이페이지 ‘내가 작성한 글’에서 모아 볼 수 있어요.",
    ],
  },
  {
    title: "공공 행사와 민간 행사는 무엇이 다른가요?",
    body: [
      "공공 행사는 공공데이터로 받아 온 행사예요. 민간 행사는 회원이 직접 제보한 행사예요.",
      "행사 메뉴에서 공공 행사나 민간 행사를 고르면 그 행사만 모아 볼 수 있어요.",
    ],
  },
  {
    title: "제보자 등급은 어떻게 올라가나요?",
    body: [
      "처음에는 ‘탈출 꿈나무’로 시작해요.",
      "내 제보가 좋아요 또는 정확해요를 10개 이상 받으면 ‘탈출 메이커’, 좋아요와 정확해요를 모두 10개 이상 받으면 ‘탈출 마스터’가 돼요.",
    ],
  },
  {
    title: "행사 정보가 실제와 달라요.",
    body: [
      "민간 행사는 상세 화면에서 ‘부정확해요’를 눌러 알려 주세요. 부정확해요가 10개 이상 쌓이면 상세 화면에 확인이 필요하다는 안내가 떠요.",
      "행사가 취소됐거나 정보가 빠졌다면 상세 화면 위쪽의 ‘신고 및 제보’로 알려 주세요.",
    ],
  },
  {
    title: "불편한 후기나 글을 봤어요.",
    body: [
      "후기와 커뮤니티 글 위쪽의 신고 버튼, 댓글 옆의 신고 버튼으로 알려 주세요. 운영진이 확인한 뒤 처리해요.",
    ],
  },
  {
    title: "문의한 내용의 답변은 어디서 보나요?",
    body: [
      "마이페이지 문의 탭에서 볼 수 있어요. 문의 내용과 답변은 작성한 본인만 볼 수 있어요.",
    ],
  },
  {
    title: "회원 탈퇴는 어디서 하나요?",
    body: ["마이페이지 내 정보 화면 아래쪽의 ‘회원 탈퇴’에서 할 수 있어요."],
  },
];

const TABS: { kind: Kind; label: string }[] = [
  { kind: "notices", label: "공지사항" },
  { kind: "faq", label: "자주 묻는 질문" },
];

/** 고객센터: 공지사항과 자주 묻는 질문, 문의하기 바로가기. */
export function SupportPage({ kind }: { kind: Kind }) {
  const entries = kind === "notices" ? NOTICES : FAQ;
  return (
    <div className="container page-space support-page">
      <PageTitle
        eyebrow="CUSTOMER CENTER"
        title="고객센터"
        description="방구석탈출을 쓰다가 궁금한 점이 생기면 여기서 찾아보세요."
      />
      <nav className="support-tabs" aria-label="고객센터 메뉴">
        {TABS.map((tab) => (
          <NavLink key={tab.kind} to={`/support/${tab.kind}`}>
            {tab.label}
          </NavLink>
        ))}
        <Link to="/mypage?tab=inquiries">문의하기</Link>
      </nav>
      <section
        className="support-list"
        aria-label={kind === "notices" ? "공지사항" : "자주 묻는 질문"}
      >
        {entries.map((entry, index) => (
          <details key={entry.title} open={kind === "notices" && index === 0}>
            <summary>
              {kind === "faq" && (
                <span className="support-q" aria-hidden="true">
                  Q
                </span>
              )}
              <span className="support-title">{entry.title}</span>
              {entry.date && (
                <time dateTime={entry.date}>
                  {entry.date.split("-").join(".")}
                </time>
              )}
              <ChevronDown size={18} aria-hidden="true" />
            </summary>
            <div className="support-body">
              {entry.body.map((line) => (
                <p key={line}>{line}</p>
              ))}
            </div>
          </details>
        ))}
      </section>
      <aside className="support-contact">
        <MessageSquareText size={26} aria-hidden="true" />
        <div>
          <h2>찾는 답이 없나요?</h2>
          <p>문의를 남기면 운영진이 확인하고 답변해 드려요.</p>
        </div>
        <Link className="btn primary" to="/mypage?tab=inquiries">
          문의하기
        </Link>
      </aside>
    </div>
  );
}
