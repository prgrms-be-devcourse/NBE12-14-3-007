import { useState, type FormEvent } from "react";
import { useApp } from "../lib/context";
import { errorText } from "../lib/format";
import type { Inquiry, InquiryInput } from "../lib/types";
import { Field, FormError, Modal, SubmitButton, Upload } from "./ui";

export function InquiryForm({
  existing,
  report,
  onSave,
}: {
  existing?: Inquiry;
  report: string;
  onSave: () => void;
}) {
  const { api, toast } = useApp();
  const [category, setCategory] = useState<InquiryInput["category"]>(
    existing?.category || (report ? "REPORT" : "QUESTION"),
  );
  const [title, setTitle] = useState(existing?.title || "");
  const [content, setContent] = useState(existing?.content || report);
  const [img, setImg] = useState<string | undefined>();
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  async function submit(e: FormEvent) {
    e.preventDefault();
    if (!title.trim() || !content.trim()) {
      setError("제목과 내용을 입력해 주세요.");
      return;
    }
    setBusy(true);
    setError("");
    try {
      const body = {
        category,
        title: title.trim(),
        content: content.trim(),
        ...(img !== undefined ? { img } : {}),
      };
      if (existing) await api.updateInquiry(existing.id, body);
      else await api.createInquiry(body);
      toast("문의를 저장했어요.");
      onSave();
    } catch (e) {
      setError(errorText(e));
    } finally {
      setBusy(false);
    }
  }
  return (
    <form onSubmit={submit}>
      <Field label="문의 종류" required>
        <select
          value={category}
          onChange={(e) =>
            setCategory(e.target.value as InquiryInput["category"])
          }
        >
          <option value="QUESTION">일반 문의</option>
          <option value="REPORT">잘못된 정보·게시물 신고</option>
          <option value="TIP">행사 정보 제보</option>
        </select>
      </Field>
      <Field label="제목" required>
        <input
          required
          maxLength={255}
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="어떤 도움이 필요하신가요?"
        />
      </Field>
      <Field label="내용" required>
        <textarea
          required
          rows={5}
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="자세히 알려주시면 확인에 도움이 돼요."
        />
      </Field>
      <Upload type="INQUIRY" value={existing?.img} onChange={setImg} useKey />
      <FormError message={error} />
      <div className="form-actions">
        <SubmitButton busy={busy}>
          {existing ? "수정 내용 저장" : "문의 등록"}
        </SubmitButton>
      </div>
    </form>
  );
}

/** 고객센터 메뉴처럼 어느 화면에서든 바로 문의를 남기는 창. 마이페이지의 문의하기 창과 같은 모양이다. */
export function InquiryModal({ onClose }: { onClose: () => void }) {
  return (
    <Modal title="문의하기" onClose={onClose}>
      <InquiryForm report="" onSave={onClose} />
    </Modal>
  );
}
