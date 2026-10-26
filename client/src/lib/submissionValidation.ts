export const submissionLimits = {
  title: 255,
  category: 50,
  regionDetail: 255,
  referenceUrl: 2048,
  imgUrl: 2048,
} as const;

export const invalidReferenceUrlMessage =
  "행사 참고 링크는 호스트가 있는 http:// 또는 https:// 주소로 입력해 주세요.";

export const submissionLengthMessages = {
  title: "행사 이름은 255자 이하여야 합니다.",
  category: "제보 행사 카테고리는 50자 이하여야 합니다.",
  regionDetail: "행사 상세 주소는 255자 이하여야 합니다.",
  referenceUrl: "행사 참고 링크는 2,048자 이하여야 합니다.",
  imgUrl: "이미지 URL은 2,048자 이하여야 합니다.",
} as const;

export function isValidSubmissionReferenceUrl(value: string): boolean {
  const normalized = value.trim().replace(/\/+$/, "");
  // URL()은 일부 불완전한 주소와 공백을 자동 보정하므로 입력 형태도 확인한다.
  const authority = /^https?:\/\/([^/\s?#]+)(?:[/?#]|$)/i.exec(normalized)?.[1];
  if (!authority || /[^\x21-\x7e]|@/.test(authority) || /[\s\\<>"{}|^`]/.test(normalized) || /%(?![\da-f]{2})/i.test(normalized)) return false;
  try {
    const url = new URL(normalized);
    return Boolean(url.hostname) && !url.username && !url.password;
  } catch {
    return false;
  }
}
