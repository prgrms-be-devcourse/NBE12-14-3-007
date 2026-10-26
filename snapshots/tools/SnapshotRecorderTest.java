package com.team007.room_escape.api;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;

import com.team007.room_escape.domain.member.infra.entity.Member;
import com.team007.room_escape.domain.member.infra.entity.MemberRole;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockHttpServletRequestBuilder;

/**
 * 스냅샷 기록기. 이 파일은 snapshots/tools 에만 두고 src/test 에는 커밋하지 않는다.
 * record.ps1 / record.sh 가 실행 직전에 src/test 로 복사하고 끝나면 지운다.
 *
 * 주요 API 요청을 보내 상태 코드와 응답 본문을 파일로 저장한다. (SNAPSHOT_OUT 환경변수가 파일 경로)
 * 매번 달라지는 값(UUID, 시각, 임의 문자열)은 자리표시자로 바꿔서 두 번의 결과를 비교할 수 있게 한다.
 * 요청을 추가하려면 record() 호출을 더하면 된다. 추가하면 기준선 파일도 다시 만들어야 한다.
 */
class SnapshotRecorderTest extends ApiContractSupport {

	private final StringBuilder out = new StringBuilder();

	@Test
	void record() throws Exception {
		Member me = saveMember(MemberRole.ROLE_UNVERIFIED);
		Member other = saveMember(MemberRole.ROLE_UNVERIFIED);
		String meToken = bearer(me);
		String otherToken = bearer(other);
		String adminToken = tokenOf(MemberRole.ROLE_ADMIN);

		// ---- 인증·공통 오류 ----
		record("미인증 내 문의 목록", get("/api/v1/inquiries/me"));
		record("없는 경로", get("/api/v1/does-not-exist"));
		record("잘못된 메서드", delete("/api/v1/weather"));
		record("깨진 JSON 문의 등록", as(post("/api/v1/inquiries"), meToken)
			.contentType("application/json").content("{broken"));

		// ---- 문의 ----
		record("문의 등록 - 제목 없음", as(post("/api/v1/inquiries"), meToken)
			.contentType("application/json").content("{\"category\":\"QUESTION\",\"content\":\"내용\"}"));
		record("문의 등록 - 종류 없음", as(post("/api/v1/inquiries"), meToken)
			.contentType("application/json").content("{\"title\":\"제목\",\"content\":\"내용\"}"));
		record("문의 등록 - 일반 문의에 대상 지정", as(post("/api/v1/inquiries"), meToken)
			.contentType("application/json")
			.content("{\"category\":\"QUESTION\",\"targetType\":\"POST\",\"targetId\":\"1\",\"title\":\"제목\",\"content\":\"내용\"}"));
		record("문의 등록 - 없는 대상 신고", as(post("/api/v1/inquiries"), meToken)
			.contentType("application/json")
			.content("{\"category\":\"REPORT\",\"targetType\":\"POST\",\"targetId\":\"" + java.util.UUID.randomUUID()
				+ "\",\"title\":\"신고\",\"content\":\"내용\"}"));

		String created = record("문의 등록 성공", as(post("/api/v1/inquiries"), meToken)
			.contentType("application/json")
			.content("{\"category\":\"QUESTION\",\"title\":\"스냅샷 문의\",\"content\":\"문의 내용\"}"));
		String inquiryId = idOf(created);

		record("내 문의 목록", as(get("/api/v1/inquiries/me"), meToken));
		record("내 문의 상세", as(get("/api/v1/inquiries/" + inquiryId), meToken));
		record("남의 문의 상세", as(get("/api/v1/inquiries/" + inquiryId), otherToken));
		record("문의 수정", as(patch("/api/v1/inquiries/" + inquiryId), meToken)
			.contentType("application/json").content("{\"title\":\"수정된 제목\"}"));
		record("관리자 문의 목록", as(get("/api/v1/admin/inquiries"), adminToken));
		record("관리자 문의 목록 - 잘못된 정렬", as(get("/api/v1/admin/inquiries?sort=nope,asc"), adminToken));
		record("관리자 문의 목록 - 일반 회원", as(get("/api/v1/admin/inquiries"), meToken));
		record("관리자 문의 상세", as(get("/api/v1/admin/inquiries/" + inquiryId), adminToken));
		record("관리자 답변 - 빈 답변", as(patch("/api/v1/admin/inquiries/" + inquiryId + "/answer"), adminToken)
			.contentType("application/json").content("{\"answer\":\"  \"}"));
		record("관리자 답변", as(patch("/api/v1/admin/inquiries/" + inquiryId + "/answer"), adminToken)
			.contentType("application/json").content("{\"answer\":\"  확인했습니다  \"}"));
		record("답변 후 문의 수정", as(patch("/api/v1/inquiries/" + inquiryId), meToken)
			.contentType("application/json").content("{\"title\":\"또 수정\"}"));
		record("남의 문의 삭제", as(delete("/api/v1/inquiries/" + inquiryId), otherToken));
		record("내 문의 삭제", as(delete("/api/v1/inquiries/" + inquiryId), meToken));
		record("삭제 후 내 문의 상세", as(get("/api/v1/inquiries/" + inquiryId), meToken));

		// ---- 후기 ----
		long festival = festivalId();
		record("후기 작성 - 제목 짧음", as(post("/api/v1/festivals/" + festival + "/posts"), meToken)
			.contentType("application/json").content("{\"title\":\"a\",\"content\":\"<p>본문</p>\"}"));
		record("후기 작성 - 내용 없음", as(post("/api/v1/festivals/" + festival + "/posts"), meToken)
			.contentType("application/json").content("{\"title\":\"스냅샷 후기\",\"content\":\"<p> </p>\"}"));
		String createdPost = record("후기 작성", as(post("/api/v1/festivals/" + festival + "/posts"), meToken)
			.contentType("application/json")
			.content("{\"title\":\"스냅샷 후기\",\"content\":\"<p>본문 <b>굵게</b> <script>x</script></p>\"}"));
		String postId = idOf(createdPost);
		record("후기 상세(비회원)", get("/api/v1/posts/" + postId));
		record("후기 상세(회원)", as(get("/api/v1/posts/" + postId), meToken));
		record("후기 목록", get("/api/v1/posts"));
		record("행사별 후기 목록", get("/api/v1/festivals/" + festival + "/posts"));
		record("후기 목록 - 좋아요순", get("/api/v1/posts?sort=likeCount,desc"));
		record("후기 검색", get("/api/v1/posts?type=TITLE&keyword=스냅샷"));
		record("관리자 후기 목록", as(get("/api/v1/admin/posts"), adminToken));
		record("후기 수정 - 남의 후기", as(patch("/api/v1/posts/" + postId), otherToken)
			.contentType("application/json").content("{\"title\":\"남이 수정\",\"content\":\"<p>x</p>\"}"));
		record("후기 수정", as(patch("/api/v1/posts/" + postId), meToken)
			.contentType("application/json").content("{\"title\":\"수정된 후기\",\"content\":\"<p>수정 본문</p>\"}"));
		record("후기 삭제", as(delete("/api/v1/posts/" + postId), meToken));
		record("삭제된 후기 상세", get("/api/v1/posts/" + postId));

		// ---- 날씨 ----
		String today = LocalDate.now().toString();
		record("날씨", get("/api/v1/weather?region=SEOUL&date=" + today));
		record("날씨 - 먼 미래", get("/api/v1/weather?region=SEOUL&date=" + LocalDate.now().plusYears(1)));
		record("날씨 - 지역 없음", get("/api/v1/weather?date=" + today));
		record("날씨 - 없는 지역", get("/api/v1/weather?region=NOPE&date=" + today));
		record("날씨 - 날짜 형식 오류", get("/api/v1/weather?region=SEOUL&date=abc"));

		// ---- 이미지 ----
		record("이미지 업로드 - 파일 없음", as(post("/api/v1/images"), meToken)
			.contentType("multipart/form-data"));

		// ---- 문서 ----
		record("OpenAPI 문서", get("/v3/api-docs"));

		String path = System.getenv("SNAPSHOT_OUT");
		if (path == null || path.isBlank()) {
			throw new IllegalStateException("SNAPSHOT_OUT 환경변수가 필요합니다.");
		}
		String label = System.getenv().getOrDefault("SNAPSHOT_LABEL", "(라벨 없음)");
		Files.writeString(Path.of(path), "# label: " + label + "\n\n" + out, StandardCharsets.UTF_8);
	}

	private String record(String name, MockHttpServletRequestBuilder request) throws Exception {
		MvcResult result = mvc.perform(request).andReturn();
		String body = result.getResponse().getContentAsString(StandardCharsets.UTF_8);
		String contentType = result.getResponse().getContentType();
		out.append("### ").append(name).append('\n')
			.append("status: ").append(result.getResponse().getStatus()).append('\n')
			.append("content-type: ").append(contentType == null ? "-" : contentType.split(";")[0]).append('\n')
			.append(normalize(canonical(body))).append("\n\n");
		return body;
	}

	private String idOf(String body) {
		return objectMapper.readTree(body).path("data").path("id").asString();
	}

	/** JSON이면 키를 정렬해서 같은 내용이 같은 문자열이 되게 한다. */
	private String canonical(String body) {
		if (body == null || body.isBlank()) {
			return "(빈 본문)";
		}
		try {
			Object parsed = objectMapper.readValue(body, Object.class);
			return objectMapper.writerWithDefaultPrettyPrinter().writeValueAsString(sort(parsed));
		} catch (Exception e) {
			return body;
		}
	}

	private Object sort(Object value) {
		if (value instanceof Map<?, ?> map) {
			TreeMap<String, Object> sorted = new TreeMap<>();
			map.forEach((k, v) -> sorted.put(String.valueOf(k), sort(v)));
			return sorted;
		}
		if (value instanceof List<?> list) {
			return list.stream().map(this::sort).toList();
		}
		return value;
	}

	/** 실행마다 달라지는 값을 자리표시자로 바꾼다. */
	private String normalize(String text) {
		// 날씨 응답은 요청한 날짜(오늘, 1년 뒤)를 "date"로 그대로 돌려준다. 찍는 날마다 달라지므로 자리표시자로 바꾼다.
		// 행사 날짜 같은 고정 값까지 바꾸지 않도록 "date" 키에만 적용한다.
		String today = "\"date\" : \"" + LocalDate.now() + "\"";
		String nextYear = "\"date\" : \"" + LocalDate.now().plusYears(1) + "\"";
		return text
			.replace(nextYear, "\"date\" : \"<today+1y>\"")
			.replace(today, "\"date\" : \"<today>\"")
			.replaceAll("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}", "<uuid>")
			.replaceAll("\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?", "<ts>")
			.replaceAll("계약테스트 (행사 )?[0-9a-f]{8}", "계약테스트 $1<t>")
			.replaceAll("\"(festivalId|id)\" : \\d+", "\"$1\" : <n>");
	}
}
