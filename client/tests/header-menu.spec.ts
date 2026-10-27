import { expect, test } from "@playwright/test";

test("header dropdowns open sub menus that keep list filters", async ({
  page,
}) => {
  await page.setViewportSize({ width: 1280, height: 900 });
  await page.goto("/explore");
  const nav = page.getByRole("navigation", { name: "메인 메뉴", exact: true });
  for (const name of ["홈", "행사 제보"])
    await expect(nav.getByRole("link", { name, exact: true })).toHaveCount(0);

  await nav.getByRole("button", { name: "행사 하위 메뉴 열기" }).click();
  await nav.getByRole("link", { name: "민간 행사", exact: true }).click();
  await expect(page).toHaveURL("/explore?providerType=MEMBER");

  await nav.getByRole("button", { name: "커뮤니티 하위 메뉴 열기" }).click();
  await nav.getByRole("link", { name: "맛집", exact: true }).click();
  await expect(page).toHaveURL("/community?category=RESTAURANT");
  await nav.getByRole("button", { name: "커뮤니티 하위 메뉴 열기" }).click();
  await expect(
    nav.getByRole("link", { name: "맛집", exact: true }),
  ).toHaveAttribute("aria-current", "page");
  await page.keyboard.press("Escape");
  await page.mouse.move(640, 700);
  await expect(
    nav.getByRole("link", { name: "맛집", exact: true }),
  ).toBeHidden();

  await nav.getByRole("button", { name: "고객센터 하위 메뉴 열기" }).click();
  await nav.getByRole("link", { name: "자주 묻는 질문", exact: true }).click();
  await expect(page).toHaveURL("/support/faq");
  await expect(
    page.getByRole("heading", { name: "고객센터", level: 1 }),
  ).toBeVisible();
  await page.getByText("제보자 등급은 어떻게 올라가나요?").click();
  await expect(page.getByText("‘탈출 마스터’가 돼요")).toBeVisible();
});

test("support root opens notices", async ({ page }) => {
  await page.goto("/support");
  await expect(page).toHaveURL("/support/notices");
  await expect(
    page
      .getByRole("navigation", { name: "고객센터 메뉴" })
      .getByRole("link", { name: "공지사항" }),
  ).toHaveAttribute("aria-current", "page");
});

test("event report button sits in the top action row", async ({ page }) => {
  await page.goto("/events/1001");
  const report = page.getByRole("button", { name: "이 행사 신고 및 제보" });
  await expect(report).toBeVisible();
  const reportTop = (await report.boundingBox())!.y;
  const titleTop = (await page
    .getByRole("heading", { level: 1 })
    .boundingBox())!.y;
  expect(reportTop).toBeLessThan(titleTop);
});
