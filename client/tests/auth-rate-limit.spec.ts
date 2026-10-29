import { test, expect } from "@playwright/test";

test("로그인 요청이 너무 많으면 남은 시간을 보여 주고 시간이 지나면 다시 시도할 수 있다", async ({
  page,
}) => {
  await page.addInitScript(() => sessionStorage.setItem("eventus.mode", "api"));
  await page.route("**/api/v1/auth/login", (route) =>
    route.fulfill({
      status: 429,
      json: {
        success: false,
        code: "AUTH007",
        message: "로그인 시도가 너무 많습니다. 잠시 후 다시 시도해 주세요.",
        data: { retryAfterSeconds: 3 },
      },
    }),
  );
  await page.goto("/login");
  await page.getByLabel("이메일").fill("member@example.com");
  await page.locator('input[type="password"]').fill("wrong-password");
  const login = page.getByRole("button", { name: "로그인", exact: true });
  await login.click();

  const alert = page.getByRole("alert");
  await expect(alert).toContainText("로그인 시도가 너무 많습니다.");
  await expect(alert).toContainText("초 뒤에 다시 시도할 수 있어요.");
  await expect(login).toBeDisabled();

  // 서버가 알려 준 시간이 지나면 안내가 사라지고 버튼이 다시 열린다.
  await expect(login).toBeEnabled({ timeout: 6_000 });
  await expect(alert).toHaveCount(0);
});

test("푸터에는 관리자 화면으로 가는 링크가 없다", async ({ page }) => {
  await page.goto("/");
  const footer = page.locator("footer.site-footer");
  await expect(footer).toBeVisible();
  await expect(footer.getByRole("link", { name: "시스템 관리자" })).toHaveCount(0);
  await expect(footer.locator('a[href="/admin"]')).toHaveCount(0);
});
