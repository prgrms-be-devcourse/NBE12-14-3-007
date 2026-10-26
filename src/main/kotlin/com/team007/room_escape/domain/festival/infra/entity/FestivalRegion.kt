package com.team007.room_escape.domain.festival.infra.entity

enum class FestivalRegion(val displayName: String) {

    // 광역 지역
    SEOUL("서울특별시"),
    BUSAN("부산광역시"),
    DAEGU("대구광역시"),
    INCHEON("인천광역시"),
    GWANGJU("광주광역시"),
    DAEJEON("대전광역시"),
    ULSAN("울산광역시"),
    SEJONG("세종특별자치시"),
    GANGWON("강원특별자치도"),
    CHUNGBUK("충청북도"),
    CHUNGNAM("충청남도"),
    JEONBUK("전북특별자치도"),
    JEONNAM("전라남도"),
    GYEONGBUK("경상북도"),
    GYEONGNAM("경상남도"),
    JEJU("제주특별자치도"),
    GYEONGGI("경기도"),

    // 전라남도·광주광역시 행정구역 통합(전남광주통합특별시). 공공 API가 이 지역 행사의 area를
    // 더 이상 "전남"/"광주"로 나눠 보내지 않고 통합 명칭으로 보내서 별도 enum으로 분리했다.
    // GWANGJU/JEONNAM은 과거 데이터·회원 제보용으로 남겨두고 삭제하지 않는다.
    JEONNAM_GWANGJU("전남광주통합특별시"),

    // TODO: 사용자 제보 데이터가 충분히 쌓이면 시·군·구를 별도 필드로 분리하고 검색 필터 도입 검토
    // 경기도 31개 시·군
    GYEONGGI_SUWON("경기도 수원시"),
    GYEONGGI_GOYANG("경기도 고양시"),
    GYEONGGI_YONGIN("경기도 용인시"),
    GYEONGGI_SEONGNAM("경기도 성남시"),
    GYEONGGI_BUCHEON("경기도 부천시"),
    GYEONGGI_HWASEONG("경기도 화성시"),
    GYEONGGI_ANSAN("경기도 안산시"),
    GYEONGGI_NAMYANGJU("경기도 남양주시"),
    GYEONGGI_ANYANG("경기도 안양시"),
    GYEONGGI_PYEONGTAEK("경기도 평택시"),
    GYEONGGI_SIHEUNG("경기도 시흥시"),
    GYEONGGI_PAJU("경기도 파주시"),
    GYEONGGI_UIJEONGBU("경기도 의정부시"),
    GYEONGGI_GIMPO("경기도 김포시"),
    GYEONGGI_GWANGJU("경기도 광주시"),
    GYEONGGI_GWANGMYEONG("경기도 광명시"),
    GYEONGGI_GUNPO("경기도 군포시"),
    GYEONGGI_HANAM("경기도 하남시"),
    GYEONGGI_OSAN("경기도 오산시"),
    GYEONGGI_YANGJU("경기도 양주시"),
    GYEONGGI_ICHEON("경기도 이천시"),
    GYEONGGI_GURI("경기도 구리시"),
    GYEONGGI_ANSEONG("경기도 안성시"),
    GYEONGGI_POCHEON("경기도 포천시"),
    GYEONGGI_UIWANG("경기도 의왕시"),
    GYEONGGI_YANGPYEONG("경기도 양평군"),
    GYEONGGI_YEOJU("경기도 여주시"),
    GYEONGGI_DONGDUCHEON("경기도 동두천시"),
    GYEONGGI_GWACHEON("경기도 과천시"),
    GYEONGGI_GAPYEONG("경기도 가평군"),
    GYEONGGI_YEONCHEON("경기도 연천군");

    companion object {
        // 긴 접미사부터 검사해야 "특별자치시"가 "시"로 먼저 잘리는 걸 막는다.
        private val ADMIN_SUFFIXES = listOf(
            "특별자치시", "특별자치도", "광역시", "특별시", "자치도", "도", "시", "군", "구"
        )

        // 경기도 하위 시·군(공백 포함 displayName)은 제외하고, 광역 단위만 미리 인덱싱해둔다.
        private val BY_NORMALIZED_AREA: Map<String, FestivalRegion> =
            values().filter { !it.displayName.contains(" ") }
                .associateBy { normalizeUnit(it.displayName) }

        // 줄임말 중 normalizeUnit()의 접미사 제거 로직으로는 원래 이름과 매칭이 안 되는 경우를 직접 등록해둔다.
        // - "대구": 끝의 "구"가 "~구"(강남구 등) 접미사로 오인되어 "대"로 잘림
        // - "충북"/"충남"/"경북"/"경남": 끝 글자가 "도"가 아니라 접미사 제거가 안 되고,
        //   저장된 키는 풀네임에서 "도"만 뗀 "충청북"/"충청남"/"경상북"/"경상남"이라 매칭이 안 됨
        // - "광주"/"전남": 행정구역 통합 이후 공공 API가 이 두 값을 전부 통합 지역(JEONNAM_GWANGJU)으로 보낸다.
        //   그대로 두면 "광주"는 normalizeUnit 결과가 우연히 GWANGJU 키("광주")와 같아서 옛 단독 광주로 잘못 분류된다.
        private val SHORT_NAME_ALIASES: Map<String, FestivalRegion> = mapOf(
            "대구" to DAEGU,
            "충북" to CHUNGBUK,
            "충남" to CHUNGNAM,
            "경북" to GYEONGBUK,
            "경남" to GYEONGNAM,
            "광주" to JEONNAM_GWANGJU,
            "전남" to JEONNAM_GWANGJU
        )

        /**
         * 새 API의 area를 FestivalRegion(광역 단위)으로 바꾼다.
         * "강원특별자치도"처럼 접미사가 풀로 오든 "강원"처럼 줄여서 오든 둘 다 받아들인다.
         * 시군구는 여기서 다루지 않고 Festival.regionDetail에 별도로 저장한다.
         */
        fun fromDisplayName(area: String?): FestivalRegion? {
            if (area == null || area.isBlank()) {
                return null
            }
            val trimmed = area.trim()
            return SHORT_NAME_ALIASES[trimmed] ?: BY_NORMALIZED_AREA[normalizeUnit(trimmed)]
        }

        private fun normalizeUnit(value: String): String {
            val trimmed = value.trim()
            for (suffix in ADMIN_SUFFIXES) {
                if (trimmed.length > suffix.length && trimmed.endsWith(suffix)) {
                    return trimmed.substring(0, trimmed.length - suffix.length)
                }
            }
            return trimmed
        }
    }
}
