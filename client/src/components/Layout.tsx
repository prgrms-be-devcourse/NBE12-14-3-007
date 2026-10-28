import { useEffect, useId, useRef, useState } from "react";
import { Link, NavLink, Outlet, useLocation, useNavigate } from "react-router-dom";
import { ChevronDown, Menu, Plus, UserRound, X } from "lucide-react";
import { useApp } from "../lib/context";
import { Logo } from "./ui";
import { InquiryModal } from "./InquiryModal";

type SubItem = { label: string; to?: string; action?: "inquiry" };

/** 화면(Outlet)에서 바로 문의 창을 열 수 있게 Layout이 내려주는 값. */
export type LayoutContext = { openInquiry: () => void };

/** 머리 메뉴. 하위 항목이 있는 메뉴(고객센터)만 드롭다운으로 연다. */
const NAV: { label: string; to: string; items?: SubItem[] }[] = [
  { label: "행사", to: "/explore" },
  { label: "후기", to: "/reviews" },
  { label: "커뮤니티", to: "/community" },
  {
    label: "고객센터",
    to: "/support",
    items: [
      { label: "공지사항", to: "/support/notices" },
      { label: "자주 묻는 질문", to: "/support/faq" },
      { label: "문의하기", action: "inquiry" },
    ],
  },
];

/** 하위 항목이 지금 주소와 같은지. 경로와 쿼리를 함께 비교한다. */
function isCurrent(to: string, pathname: string, search: string) {
  const [path, query = ""] = to.split("?");
  if (path !== pathname) return false;
  const want = new URLSearchParams(query);
  const now = new URLSearchParams(search);
  // 마이페이지처럼 탭을 쿼리로 고르는 화면은 탭까지 같아야 현재 위치다.
  const keys = ["tab"];
  return keys.every((key) => (want.get(key) || "") === (now.get(key) || ""));
}

function NavGroup({
  label,
  to,
  items,
  onAction,
}: {
  label: string;
  to: string;
  items: SubItem[];
  onAction: (action: "inquiry") => void;
}) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);
  const menuId = useId();
  const location = useLocation();
  useEffect(() => setOpen(false), [location.pathname, location.search]);
  useEffect(() => {
    if (!open) return;
    function onDown(event: MouseEvent) {
      if (!ref.current?.contains(event.target as Node)) setOpen(false);
    }
    function onKey(event: KeyboardEvent) {
      if (event.key === "Escape") setOpen(false);
    }
    document.addEventListener("mousedown", onDown);
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("mousedown", onDown);
      document.removeEventListener("keydown", onKey);
    };
  }, [open]);
  return (
    <div className={`nav-group${open ? " open" : ""}`} ref={ref}>
      <NavLink to={to}>{label}</NavLink>
      <button
        type="button"
        className="nav-toggle"
        aria-label={`${label} 하위 메뉴 ${open ? "닫기" : "열기"}`}
        aria-expanded={open}
        aria-controls={menuId}
        onClick={() => setOpen(!open)}
      >
        <ChevronDown size={14} aria-hidden="true" />
      </button>
      <ul className="nav-sub" id={menuId} aria-label={`${label} 하위 메뉴`}>
        {items.map((item) => {
          if (item.action) {
            const action = item.action;
            return (
              <li key={item.label}>
                <button type="button" onClick={() => onAction(action)}>
                  {item.label}
                </button>
              </li>
            );
          }
          const target = item.to ?? "/";
          const current = isCurrent(
            target,
            location.pathname,
            location.search,
          );
          return (
            <li key={target}>
              <Link
                to={target}
                aria-current={current ? "page" : undefined}
                className={current ? "current" : undefined}
              >
                {item.label}
              </Link>
            </li>
          );
        })}
      </ul>
    </div>
  );
}

export function Layout() {
  const { member, toast } = useApp();
  const [open, setOpen] = useState(false);
  const [inquiryOpen, setInquiryOpen] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();
  function openInquiry() {
    if (!member) {
      toast("로그인하면 문의를 남길 수 있어요.");
      navigate(`/login?next=${encodeURIComponent(location.pathname + location.search)}`);
      return;
    }
    setInquiryOpen(true);
  }
  useEffect(() => {
    window.scrollTo({ top: 0, behavior: "instant" });
  }, [location.pathname]);
  // 하위 메뉴는 같은 경로에 쿼리만 바꾸기도 해서, 모바일 메뉴는 쿼리가 바뀔 때도 닫는다.
  useEffect(() => setOpen(false), [location.pathname, location.search]);
  return (
    <div className="theme-c">
      <a className="skip-link" href="#main">
        본문으로 바로가기
      </a>
      <header className="site-header">
        <div className="container header-inner">
          <Link to="/" aria-label="방구석탈출 홈">
            <Logo />
          </Link>
          <nav
            className={`main-nav ${open ? "open" : ""}`}
            aria-label="메인 메뉴"
          >
            {NAV.map((item) =>
              item.items ? (
                <NavGroup
                  key={item.to}
                  label={item.label}
                  to={item.to}
                  items={item.items}
                  onAction={openInquiry}
                />
              ) : (
                <NavLink key={item.to} to={item.to}>
                  {item.label}
                </NavLink>
              ),
            )}
          </nav>
          <div className="header-actions">
            <Link className="header-submit" to="/submissions/new">
              <Plus size={15} />
              행사 제보하기
            </Link>
            <span className="header-divider" />
            <Link
              to={member ? "/mypage" : "/login"}
              className="account-link"
              aria-label={member ? "마이페이지" : "로그인"}
            >
              <UserRound size={18} />
              <span>{member ? "마이페이지" : "로그인"}</span>
              <ChevronDown size={12} />
            </Link>
            <button
              className="icon-btn mobile-menu"
              aria-label={open ? "메뉴 닫기" : "메뉴 열기"}
              aria-expanded={open}
              onClick={() => setOpen(!open)}
            >
              {open ? <X /> : <Menu />}
            </button>
          </div>
        </div>
      </header>
      <main id="main" className="main-content">
        <Outlet context={{ openInquiry } satisfies LayoutContext} />
      </main>
      <footer className="site-footer">
        <div className="container">
          <div className="footer-top">
            <div>
              <Link to="/">
                <Logo />
              </Link>
            </div>
            <div className="footer-links">
              <Link to="/support/notices">공지사항</Link>
              <Link to="/support/faq">자주 묻는 질문</Link>
              <button type="button" onClick={openInquiry}>
                문의하기
              </button>
              <Link to="/admin">시스템 관리자</Link>
            </div>
          </div>
          <div className="footer-bottom">
            <span>© 2026 roomescape.</span>
          </div>
        </div>
      </footer>
      {inquiryOpen && <InquiryModal onClose={() => setInquiryOpen(false)} />}
    </div>
  );
}
