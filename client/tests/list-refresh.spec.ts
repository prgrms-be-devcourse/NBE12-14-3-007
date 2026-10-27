import { expect, test, type Page, type Route } from "@playwright/test";

// 필터를 바꿔 목록을 다시 불러오는 동안 이전 목록이 로딩 화면으로 바뀌면 화면이 깜빡인다.
// 새 결과가 올 때까지 이전 목록을 그대로 두는지 확인한다.

function pageOf<T>(content: T[]) {
  return {
    content,
    number: 0,
    size: 9,
    totalElements: content.length,
    totalPages: 1,
    first: true,
    last: true,
  };
}
function festival(id: number, title: string) {
  return {
    festivalId: id,
    providerType: "PUBLIC",
    title,
    category: "축제",
    instNm: null,
    imgUrl: null,
    beginDe: "2026-10-01T00:00:00",
    endDe: "2026-12-31T23:59:59",
    region: "SEOUL",
    district: null,
    regionDetail: "마포구",
    status: "OPEN",
    likeCount: 0,
    accurateCount: 0,
    inaccurateCount: 0,
    member: null,
  };
}
function communityPost(id: string, title: string) {
  return {
    id,
    category: "FREE",
    title,
    member: { id: "m1", nickname: "이웃", profileImg: null, role: null },
    viewCount: 1,
    commentCount: 0,
    createdAt: "2026-10-20T10:00:00",
  };
}
async function respond(route: Route, data: unknown, status = 200) {
  await route.fulfill({
    status,
    contentType: "application/json",
    body: JSON.stringify({ success: status < 400, data, message: "" }),
  });
}

/**
 * 처음 목록은 바로 돌려주고, 필터를 바꾼 요청(isNext)은 release()를 부를 때까지 붙잡아 둔다.
 * 개발 모드에서는 첫 요청이 두 번 갈 수 있어 요청 횟수 대신 주소로 구분한다.
 */
async function slowNextList(
  page: Page,
  path: string,
  isNext: (url: URL) => boolean,
  first: unknown,
  next: unknown,
) {
  let release = () => {};
  const held = new Promise<void>((resolve) => (release = resolve));
  await page.addInitScript(() => sessionStorage.setItem("eventus.mode", "api"));
  await page.route("**/api/v1/**", async (route) => {
    const url = new URL(route.request().url());
    if (url.pathname === "/api/v1/auth/refresh")
      return respond(route, null, 401);
    if (url.pathname === path) {
      if (!isNext(url)) return respond(route, first);
      await held;
      return respond(route, next);
    }
    return respond(route, pageOf([]));
  });
  return () => release();
}

test("event filters keep the previous list while the next page loads", async ({
  page,
}) => {
  const release = await slowNextList(
    page,
    "/api/v1/festivals",
    (url) => !url.searchParams.has("excludeClosed"),
    pageOf([festival(1, "이전 결과 행사")]),
    pageOf([festival(2, "새 결과 행사")]),
  );
  await page.goto("/explore");
  const cards = page.locator(".event-grid .event-card");
  await expect(cards).toHaveCount(1);

  await page.getByLabel("종료 행사 제외").click();
  await expect(page.locator(".event-grid[aria-busy='true']")).toBeVisible();
  await expect(cards).toContainText("이전 결과 행사");
  await expect(page.locator(".skeleton-card")).toHaveCount(0);

  release();
  await expect(cards).toContainText("새 결과 행사");
  await expect(page.locator(".event-grid[aria-busy='true']")).toHaveCount(0);
});

test("community category tabs keep the previous list while loading", async ({
  page,
}) => {
  const release = await slowNextList(
    page,
    "/api/v1/community/posts",
    (url) => url.searchParams.get("category") === "FREE",
    pageOf([communityPost("a", "이전 글")]),
    pageOf([communityPost("b", "새 글")]),
  );
  await page.goto("/community");
  const rows = page.locator(".community-row");
  await expect(rows).toHaveCount(1);

  await page
    .getByRole("navigation", { name: "커뮤니티 카테고리" })
    .getByRole("button", { name: "자유" })
    .click();
  await expect(rows).toContainText("이전 글");
  await expect(page.getByRole("status")).toHaveCount(0);

  release();
  await expect(rows).toContainText("새 글");
});
