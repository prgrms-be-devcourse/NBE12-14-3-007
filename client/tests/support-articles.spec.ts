import { test, expect, type Page, type Route } from "@playwright/test";
import AxeBuilder from "@axe-core/playwright";
import { adminToken, loginAdmin } from "./helpers/admin";

async function expectAccessible(page: Page, name: string) {
  const result = await new AxeBuilder({ page })
    .withTags(["wcag2a", "wcag2aa", "wcag21aa"])
    .analyze();
  expect(
    result.violations.map((v) => ({
      id: v.id,
      targets: v.nodes.map((n) => n.target),
    })),
    name,
  ).toEqual([]);
}

type Article = {
  id: number;
  type: "NOTICE" | "FAQ";
  title: string;
  content: string;
  displayOrder: number;
  createdAt: string;
  updatedAt: string;
};

const article = (
  id: number,
  type: Article["type"],
  title: string,
  content: string,
  displayOrder = 0,
): Article => ({
  id,
  type,
  title,
  content,
  displayOrder,
  createdAt: `2026-10-${10 + id}T09:00:00`,
  updatedAt: `2026-10-${10 + id}T09:00:00`,
});

async function respond(route: Route, data: unknown, status = 200) {
  await route.fulfill({
    status,
    contentType: "application/json",
    body: JSON.stringify({
      success: status < 400,
      data: status < 400 ? data : null,
      message: status < 400 ? "" : data,
    }),
  });
}

function pageOf<T>(items: T[], number: number, size: number) {
  return {
    content: items.slice(number * size, (number + 1) * size),
    number,
    size,
    totalElements: items.length,
    totalPages: Math.ceil(items.length / size),
    first: number === 0,
    last: (number + 1) * size >= items.length,
  };
}

/**
 * 실제 서버처럼 동작하는 고객센터 API. 공지는 최신순, 질문은 표시 순서대로 돌려준다.
 * 쓰기 요청은 관리자 토큰이 있어야 받는다.
 */
async function supportServer(page: Page, initial: Article[], role = "") {
  await page.addInitScript(() => sessionStorage.setItem("eventus.mode", "api"));
  const articles = [...initial];
  let nextId = 100;
  const writes: { method: string; path: string; body: unknown }[] = [];
  await page.route("**/api/v1/**", async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace("/api/v1", "");
    if (path === "/auth/login")
      return respond(route, { accessToken: adminToken() });
    if (path === "/auth/refresh")
      return role
        ? respond(route, { accessToken: adminToken(role) })
        : respond(route, "로그인 필요", 401);
    if (path === "/members/me")
      return respond(route, {
        id: "admin",
        nickname: "운영자",
        role: role || "ROLE_ADMIN",
        email: "admin@example.com",
      });
    if (path === "/support/notices") {
      const notices = articles
        .filter((a) => a.type === "NOTICE")
        .sort((a, b) => b.createdAt.localeCompare(a.createdAt));
      return respond(
        route,
        pageOf(
          notices,
          Number(url.searchParams.get("page") || 0),
          Number(url.searchParams.get("size") || 20),
        ),
      );
    }
    if (path === "/support/faqs")
      return respond(
        route,
        articles
          .filter((a) => a.type === "FAQ")
          .sort((a, b) => a.displayOrder - b.displayOrder || a.id - b.id),
      );
    if (path.startsWith("/admin/support/articles")) {
      expect(request.headers().authorization).toBe("Bearer " + adminToken());
      const body = request.postDataJSON();
      writes.push({ method: request.method(), path, body });
      const id = Number(path.split("/").at(-1));
      if (request.method() === "POST") {
        const faqs = articles.filter((a) => a.type === body.type);
        const created = article(
          nextId++,
          body.type,
          body.title,
          body.content,
          body.displayOrder ??
            Math.max(0, ...faqs.map((a) => a.displayOrder)) + 1,
        );
        created.createdAt = "2026-10-30T09:00:00";
        articles.push(created);
        return respond(route, created);
      }
      const index = articles.findIndex((a) => a.id === id);
      if (request.method() === "PUT") {
        articles[index] = {
          ...articles[index],
          title: body.title,
          content: body.content,
          displayOrder: body.displayOrder ?? articles[index].displayOrder,
        };
        return respond(route, articles[index]);
      }
      articles.splice(index, 1);
      return respond(route, null);
    }
    // 관리자 화면이 처음 부르는 통계·목록 API. 이 테스트와 관계없다.
    if (path.startsWith("/admin/") || path === "/festivals")
      return respond(route, pageOf([], 0, 20));
    return respond(route, "예상하지 않은 요청", 404);
  });
  return writes;
}

test("preview support pages show the bundled notices and questions", async ({
  page,
}) => {
  await page.goto("/support/notices");
  const notices = page.getByRole("region", { name: "공지사항" });
  await expect(notices.locator("details").first()).toHaveAttribute("open", "");
  await expect(notices.locator("summary").first()).toContainText(
    "고객센터를 열었어요",
  );
  await expect(notices.locator("details")).toHaveCount(3);

  await page.goto("/support/faq");
  const faq = page.getByRole("region", { name: "자주 묻는 질문" });
  await expect(faq.locator("details")).toHaveCount(7);
  await expect(faq.locator("summary").first()).toContainText(
    "행사는 어떻게 제보하나요?",
  );
});

test("support page reads notices from the server, splits paragraphs and pages", async ({
  page,
}) => {
  const notices = Array.from({ length: 11 }, (_, i) =>
    article(i + 1, "NOTICE", `서버 공지 ${i + 1}`, "첫 문단\n\n둘째 문단"),
  );
  await supportServer(page, notices);
  await page.goto("/support/notices");
  const list = page.getByRole("region", { name: "공지사항" });
  await expect(list.locator("summary").first()).toContainText("서버 공지 11");
  await expect(list.locator("details").first().locator("p")).toHaveText([
    "첫 문단",
    "둘째 문단",
  ]);
  await expect(list.locator("details")).toHaveCount(10);
  await page
    .getByRole("navigation", { name: "페이지 이동" })
    .getByRole("button", { name: "2", exact: true })
    .click();
  await expect(page).toHaveURL(/page=1/);
  await expect(list.locator("details")).toHaveCount(1);
  await expect(list.locator("summary")).toContainText("서버 공지 1");
});

test("support page shows an empty state when nothing is published", async ({
  page,
}) => {
  await supportServer(page, []);
  await page.goto("/support/faq");
  await expect(page.getByText("아직 등록된 질문이 없어요")).toBeVisible();
});

test("administrator writes, edits and deletes support articles", async ({
  page,
}) => {
  const writes = await supportServer(
    page,
    [
      article(1, "NOTICE", "기존 공지", "기존 공지 내용"),
      article(2, "FAQ", "기존 질문", "기존 답변", 1),
    ],
    "ROLE_ADMIN",
  );
  await loginAdmin(page, "/admin/support");
  await expect(
    page.getByRole("navigation", { name: "관리자 메뉴" }).getByRole("link", {
      name: "고객센터 관리",
    }),
  ).toHaveAttribute("aria-current", "page");
  const table = page.getByRole("region", { name: "공지사항 목록" });
  await expect(table).toContainText("기존 공지");

  // 새 공지 쓰기
  await page.getByRole("button", { name: "새 공지 쓰기" }).click();
  const dialog = page.getByRole("dialog", { name: "새 공지 쓰기" });
  await dialog.getByLabel("제목").fill("  연휴 운영 안내  ");
  await dialog.getByLabel("내용").fill("첫 줄\n둘째 줄");
  await dialog.getByRole("button", { name: "저장" }).click();
  await expect(dialog).toBeHidden();
  await expect(table.locator("tbody tr").first()).toContainText(
    "연휴 운영 안내",
  );
  expect(writes.at(-1)).toEqual({
    method: "POST",
    path: "/admin/support/articles",
    body: {
      type: "NOTICE",
      title: "연휴 운영 안내",
      content: "첫 줄\n둘째 줄",
    },
  });

  // 질문 탭에서 고치기
  await page
    .getByRole("button", { name: "자주 묻는 질문", exact: true })
    .click();
  await expect(page).toHaveURL(/tab=faq/);
  await page.getByRole("button", { name: "기존 질문 수정" }).click();
  const edit = page.getByRole("dialog", { name: "질문 수정" });
  await expect(edit.getByLabel("표시 순서")).toHaveValue("1");
  await edit.getByLabel("질문").fill("고친 질문");
  await edit.getByLabel("표시 순서").fill("0");
  await edit.getByRole("button", { name: "저장" }).click();
  await expect(edit).toBeHidden();
  const faqTable = page.getByRole("region", { name: "자주 묻는 질문 목록" });
  await expect(faqTable).toContainText("고친 질문");
  expect(writes.at(-1)).toEqual({
    method: "PUT",
    path: "/admin/support/articles/2",
    body: { title: "고친 질문", content: "기존 답변", displayOrder: 0 },
  });

  // 지우기
  await page.getByRole("button", { name: "고친 질문 삭제" }).click();
  await page
    .getByRole("dialog", { name: "질문을 삭제할까요?" })
    .getByRole("button", { name: "삭제", exact: true })
    .click();
  await expect(page.getByText("아직 자주 묻는 질문이 없습니다")).toBeVisible();
  expect(writes.at(-1)?.method).toBe("DELETE");
});

test("administrator keeps the draft when saving fails", async ({ page }) => {
  await supportServer(page, [], "ROLE_ADMIN");
  await page.route("**/api/v1/admin/support/articles", (route) =>
    respond(route, "제목은 100자 이하로 써 주세요.", 400),
  );
  await loginAdmin(page, "/admin/support");
  await page.getByRole("button", { name: "새 공지 쓰기" }).click();
  const dialog = page.getByRole("dialog", { name: "새 공지 쓰기" });
  await dialog.getByLabel("제목").fill("실패할 공지");
  await dialog.getByLabel("내용").fill("내용");
  await dialog.getByRole("button", { name: "저장" }).click();
  await expect(dialog.getByRole("alert")).toContainText("100자");
  await expect(dialog.getByLabel("제목")).toHaveValue("실패할 공지");
});

test("support pages and the admin editor meet automated accessibility checks", async ({
  page,
}) => {
  await supportServer(
    page,
    [
      article(1, "NOTICE", "접근성 공지", "첫 문단\n둘째 문단"),
      article(2, "FAQ", "접근성 질문", "답변", 1),
    ],
    "ROLE_ADMIN",
  );
  for (const path of ["/support/notices", "/support/faq"]) {
    await page.goto(path);
    await expect(page.locator(".support-list summary").first()).toBeVisible();
    await expectAccessible(page, path);
  }
  await loginAdmin(page, "/admin/support");
  await expect(
    page.getByRole("region", { name: "공지사항 목록" }),
  ).toBeVisible();
  await expectAccessible(page, "/admin/support");
  await page.getByRole("button", { name: "새 공지 쓰기" }).click();
  await expect(
    page.getByRole("dialog", { name: "새 공지 쓰기" }),
  ).toBeVisible();
  await expectAccessible(page, "/admin/support 새 공지 쓰기");
});
