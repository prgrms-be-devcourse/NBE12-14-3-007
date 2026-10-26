package com.team007.room_escape.global.response.code

import com.team007.room_escape.global.exception.ExceptionCode
import org.springframework.http.HttpStatus

/**
 * 행사(festival) 도메인 에러 코드 (API 연동 관련 실패에 사용)
 */
enum class FestivalExceptionCode(
    override val code: String,
    override val status: HttpStatus,
    override val message: String
) : ExceptionCode {
    INVALID_SUBMISSION_REGION("FESTIVAL013", HttpStatus.BAD_REQUEST, "시·도에 맞는 시·군·구를 선택해 주세요."),

    /** festival 테이블에서 행사 자체를 찾을 수 없을 때 */
    FESTIVAL_NOT_FOUND("FESTIVAL001", HttpStatus.NOT_FOUND, "존재하지 않는 행사입니다."),

    EDIT_VERSION_REQUIRED("FESTIVAL011", HttpStatus.BAD_REQUEST, "최신 행사 내용을 조회한 뒤 수정해 주세요."),
    EDIT_CONFLICT("FESTIVAL012", HttpStatus.CONFLICT, "다른 화면에서 행사 정보가 변경되었습니다. 작성 중인 내용을 보관하고 최신 내용을 확인해 주세요."),

    /** 공공 API 호출 자체가 실패 (네트워크 오류, 타임아웃, 4xx/5xx 응답 등) */
    PUBLIC_API_CALL_FAILED("FESTIVAL002", HttpStatus.SERVICE_UNAVAILABLE, "공공 API 호출에 실패했습니다."),

    /** 공공 API 응답 파싱 실패 */
    PUBLIC_API_PARSE_FAILED("FESTIVAL003", HttpStatus.INTERNAL_SERVER_ERROR, "공공 API 응답 파싱에 실패했습니다."),

    /** 행사 제보가 존재하지 않거나 로그인한 회원의 제보가 아닐 때 */
    FESTIVAL_SUBMISSION_NOT_FOUND("FESTIVAL004", HttpStatus.NOT_FOUND, "요청하신 행사 제보를 찾을 수 없습니다."),

    /** 이미 다른 동기화가 실행 중일 때 (버튼 연타 등) */
    SYNC_ALREADY_RUNNING("FESTIVAL005", HttpStatus.CONFLICT, "이미 공공 행사 동기화가 진행 중입니다."),

    /** 동일한 행사명·시군구·일정의 행사가 존재할 때 */
    DUPLICATE_FESTIVAL("FESTIVAL006", HttpStatus.CONFLICT, "이미 등록된 행사입니다."),

    /** 삭제되지 않은 행사에 복구를 요청한 경우 */
    FESTIVAL_NOT_DELETED("FESTIVAL007", HttpStatus.CONFLICT, "삭제되지 않은 행사입니다."),

    // FESTIVAL008 은 삭제 주체 검증이 DeletionExceptionCode.RESTORE_NOT_ALLOWED 로 합쳐지면서 비었다.
    // 다른 코드가 밀리지 않도록 번호는 재사용하지 않는다.

    /** 본인이 제보한 행사를 직접 정확하다고 평가하는 경우 */
    SELF_ACCURACY_VOTE_NOT_ALLOWED(
        "FESTIVAL009", HttpStatus.FORBIDDEN,
        "본인이 제보한 행사의 정확도는 평가할 수 없습니다."
    ),

    /** 중복 검사에 필요한 행사명·시군구·일정이 비어 있어 복구 가능 여부를 판단할 수 없는 경우 */
    RESTORE_DATA_INCOMPLETE(
        "FESTIVAL010", HttpStatus.CONFLICT,
        "행사명·시군구·일정이 비어 있어 복구할 수 없습니다."
    )
}
