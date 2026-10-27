import { useState } from "react";
import { Link, useSearchParams } from "react-router-dom";
import { ExternalLink, Plus } from "lucide-react";
import { Empty, Field, Loading, Modal, Pagination } from "../components/ui";
import { useApp, useLoad } from "../lib/context";
import { dateText, errorText } from "../lib/format";
import type {
  SupportArticle,
  SupportArticleInput,
  SupportArticleType,
} from "../lib/types";

const TITLE_MAX = 100;
const CONTENT_MAX = 5000;

const kinds: {
  type: SupportArticleType;
  param: string;
  label: string;
  noun: string;
  nounObject: string;
  publicPath: string;
}[] = [
  {
    type: "NOTICE",
    param: "notices",
    label: "공지사항",
    noun: "공지",
    nounObject: "공지를",
    publicPath: "/support/notices",
  },
  {
    type: "FAQ",
    param: "faq",
    label: "자주 묻는 질문",
    noun: "질문",
    nounObject: "질문을",
    publicPath: "/support/faq",
  },
];

/** 고객센터 공지사항·자주 묻는 질문을 쓰고 고치는 관리자 화면. */
export function AdminSupport() {
  const { api } = useApp();
  const [params, setParams] = useSearchParams();
  const kind = kinds.find((k) => k.param === params.get("tab")) ?? kinds[0];
  const faq = kind.type === "FAQ";
  const page = faq ? 0 : Math.max(0, Number(params.get("page")) || 0);
  const [editing, setEditing] = useState<SupportArticle | "new" | null>(null);
  const [deleting, setDeleting] = useState<SupportArticle | null>(null);
  const { data, loading, error, reload } = useLoad(
    async () =>
      faq
        ? {
            content: await api.adminSupportFaqs(),
            totalPages: 1,
            totalElements: 0,
            number: 0,
          }
        : api.adminSupportNotices(page),
    [api, faq, page],
  );
  function move(next: { tab?: string; page?: number }) {
    setParams((current) => {
      const query = new URLSearchParams(current);
      if (next.tab !== undefined) {
        query.set("tab", next.tab);
        query.delete("page");
      }
      if (next.page) query.set("page", String(next.page));
      else if (next.page === 0) query.delete("page");
      return query;
    });
  }
  return (
    <>
      <div className="adm-heading">
        <div>
          <span className="adm-eyebrow">SUPPORT</span>
          <h1>고객센터 관리</h1>
          <p>
            고객센터에 보이는 공지사항과 자주 묻는 질문을 쓰고 고칩니다.
            저장하면 바로 서비스에 보입니다.
          </p>
        </div>
      </div>
      <section className="adm-panel">
        <div className="adm-tab-row adm-tab-row-wrap">
          <div className="adm-tabs" role="group" aria-label="고객센터 글 종류">
            {kinds.map((item) => (
              <button
                key={item.type}
                className={item.type === kind.type ? "active" : ""}
                aria-pressed={item.type === kind.type}
                onClick={() => move({ tab: item.param })}
              >
                {item.label}
              </button>
            ))}
          </div>
          <div className="adm-filters">
            <Link
              className="adm-row-button"
              to={kind.publicPath}
              target="_blank"
            >
              고객센터에서 보기
              <ExternalLink size={14} />
            </Link>
            <button
              type="button"
              className="btn primary small"
              onClick={() => setEditing("new")}
            >
              <Plus size={16} />새 {kind.noun} 쓰기
            </button>
          </div>
        </div>
        <p className="adm-dialog-note">
          {faq
            ? "질문은 표시 순서가 작은 것부터 보입니다. 순서를 비우고 쓰면 맨 아래에 붙습니다."
            : "공지사항은 최근에 쓴 글부터 보이고, 맨 위 공지는 펼쳐진 채로 보입니다."}
        </p>
        {error && (
          <p className="adm-dialog-note" role="alert">
            {error}{" "}
            <button type="button" className="adm-row-button" onClick={reload}>
              다시 시도
            </button>
          </p>
        )}
        {loading ? (
          <Loading />
        ) : !data?.content.length ? (
          !error && (
            <Empty
              title={`아직 ${kind.label}이 없습니다`}
              description={`새 ${kind.noun} 쓰기로 첫 글을 올려 주세요.`}
            />
          )
        ) : (
          <div
            className="adm-table-scroll"
            role="region"
            aria-label={`${kind.label} 목록`}
            tabIndex={0}
          >
            <table className="adm-table">
              <thead>
                <tr>
                  {faq && <th scope="col">순서</th>}
                  <th scope="col">{faq ? "질문" : "제목"}</th>
                  <th scope="col">{faq ? "수정일" : "등록일"}</th>
                  <th scope="col">관리</th>
                </tr>
              </thead>
              <tbody>
                {data.content.map((article) => (
                  <tr key={article.id}>
                    {faq && <td>{article.displayOrder}</td>}
                    <td>
                      <div className="adm-content-cell">
                        <div>
                          <strong>{article.title}</strong>
                          <small>{firstLine(article.content)}</small>
                        </div>
                      </div>
                    </td>
                    <td>
                      {dateText(faq ? article.updatedAt : article.createdAt)}
                    </td>
                    <td>
                      <div className="adm-row-actions">
                        <button
                          type="button"
                          className="adm-row-button"
                          aria-label={`${article.title} 수정`}
                          onClick={() => setEditing(article)}
                        >
                          수정
                        </button>
                        <button
                          type="button"
                          className="adm-row-button danger"
                          aria-label={`${article.title} 삭제`}
                          onClick={() => setDeleting(article)}
                        >
                          삭제
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        {!faq && data && (
          <Pagination
            page={data.number}
            total={data.totalPages}
            onChange={(next) => move({ page: next })}
          />
        )}
      </section>
      {editing && (
        <ArticleDialog
          type={kind.type}
          noun={kind.noun}
          article={editing === "new" ? null : editing}
          onClose={() => setEditing(null)}
          onSaved={() => {
            setEditing(null);
            reload();
          }}
        />
      )}
      {deleting && (
        <DeleteDialog
          article={deleting}
          nounObject={kind.nounObject}
          onClose={() => setDeleting(null)}
          onDeleted={() => {
            setDeleting(null);
            reload();
          }}
        />
      )}
    </>
  );
}

function ArticleDialog({
  type,
  noun,
  article,
  onClose,
  onSaved,
}: {
  type: SupportArticleType;
  noun: string;
  /** null이면 새 글 */
  article: SupportArticle | null;
  onClose: () => void;
  onSaved: () => void;
}) {
  const { api } = useApp();
  const faq = type === "FAQ";
  const [title, setTitle] = useState(article?.title ?? "");
  const [content, setContent] = useState(article?.content ?? "");
  const [order, setOrder] = useState(
    article && faq ? String(article.displayOrder) : "",
  );
  const [saving, setSaving] = useState(false);
  const [saveError, setSaveError] = useState("");
  const ready = title.trim() && content.trim();
  return (
    <Modal
      title={article ? `${noun} 수정` : `새 ${noun} 쓰기`}
      onClose={onClose}
    >
      <form
        onSubmit={async (event) => {
          event.preventDefault();
          setSaving(true);
          setSaveError("");
          const input: SupportArticleInput = {
            type,
            title: title.trim(),
            content: content.trim(),
            displayOrder: faq && order.trim() ? Number(order) : undefined,
          };
          try {
            if (article) await api.updateSupportArticle(article.id, input);
            else await api.createSupportArticle(input);
            onSaved();
          } catch (error) {
            // 실패하면 닫지 않는다. 쓴 내용이 남아 있어야 다시 시도한다.
            setSaveError(errorText(error));
          } finally {
            setSaving(false);
          }
        }}
      >
        <Field label={faq ? "질문" : "제목"} required>
          <input
            required
            maxLength={TITLE_MAX}
            value={title}
            onChange={(event) => setTitle(event.target.value)}
            placeholder={
              faq ? "행사는 어떻게 제보하나요?" : "추석 연휴 고객센터 운영 안내"
            }
          />
        </Field>
        <Field
          label={faq ? "답변" : "내용"}
          required
          hint={`줄을 바꾸면 문단이 나뉘어 보여요. ${content.length.toLocaleString()} / ${CONTENT_MAX.toLocaleString()}자`}
        >
          <textarea
            rows={8}
            required
            maxLength={CONTENT_MAX}
            value={content}
            onChange={(event) => setContent(event.target.value)}
          />
        </Field>
        {faq && (
          <Field
            label="표시 순서"
            hint={
              article
                ? "작을수록 위에 보여요. 비우면 지금 순서를 유지해요."
                : "작을수록 위에 보여요. 비우면 맨 아래에 붙어요."
            }
          >
            <input
              type="number"
              min={0}
              step={1}
              inputMode="numeric"
              value={order}
              onChange={(event) => setOrder(event.target.value)}
            />
          </Field>
        )}
        {saveError && (
          <p className="adm-dialog-note" role="alert">
            {saveError}
          </p>
        )}
        <div className="adm-dialog-actions">
          <button type="button" className="btn secondary" onClick={onClose}>
            취소
          </button>
          <button className="btn primary" disabled={!ready || saving}>
            {saving ? "저장 중…" : "저장"}
          </button>
        </div>
      </form>
    </Modal>
  );
}

function DeleteDialog({
  article,
  nounObject,
  onClose,
  onDeleted,
}: {
  article: SupportArticle;
  /** "공지를"처럼 조사까지 붙인 이름 */
  nounObject: string;
  onClose: () => void;
  onDeleted: () => void;
}) {
  const { api } = useApp();
  const [busy, setBusy] = useState(false);
  const [deleteError, setDeleteError] = useState("");
  return (
    <Modal title={`${nounObject} 삭제할까요?`} onClose={onClose}>
      <p className="adm-dialog-copy">
        <strong>{article.title}</strong>
        <br />
        고객센터에서 바로 내려가고, 되돌릴 수 없습니다.
      </p>
      {deleteError && (
        <p className="adm-dialog-note" role="alert">
          {deleteError}
        </p>
      )}
      <div className="adm-dialog-actions">
        <button type="button" className="btn secondary" onClick={onClose}>
          취소
        </button>
        <button
          type="button"
          className="btn danger"
          disabled={busy}
          onClick={async () => {
            setBusy(true);
            setDeleteError("");
            try {
              await api.deleteSupportArticle(article.id);
              onDeleted();
            } catch (error) {
              setDeleteError(errorText(error));
              setBusy(false);
            }
          }}
        >
          {busy ? "삭제 중…" : "삭제"}
        </button>
      </div>
    </Modal>
  );
}

/** 목록에서 본문을 짧게 보여 준다. */
function firstLine(content: string) {
  return content.split("\n").find((line) => line.trim()) ?? "";
}
