import type {
  EventView,
  Member,
  PostDetail,
  Comment,
  Inquiry,
  SubmissionDetail,
  SupportArticle,
} from "./types";
import { parseDateTime } from "./format";

export type ReviewSort = "likeCount,desc" | "createdAt,desc" | "createdAt,asc";

// Fictional UI examples. Never sent to the backend or used as a network fallback.
const eventBase = {
  instNm: "예시 문화재단",
  manager: "행사 운영팀",
  referenceUrl: null,
  eventTmInfo: "10:00 — 18:00",
  partcptExpnInfo: "무료",
  telnoInfo: null,
  hostInstNm: "예시 행사 운영위원회",
  writngDe: "2026-09-01T09:00:00",
  status: "OPEN" as const,
  preview: true,
};
export const demoEvents: EventView[] = [
  {
    ...eventBase,
    festivalId: 1001,
    source: "PUBLIC",
    title: "달빛 아래, 수원화성 문화산책",
    category: "축제",
    region: "GYEONGGI_SUWON",
    regionDetail: "화성행궁과 방화수류정 일대",
    imgUrl: "/images/palace.jpg",
    beginDe: "2026-09-25T18:00:00",
    endDe: "2026-10-11T22:00:00",
    eventTmInfo: "18:00 — 22:00",
    festivalContent:
      "낮과는 또 다른 표정을 가진 수원화성을 만나보세요. 은은하게 빛나는 성곽을 따라 걷고, 고즈넉한 풍경 속에서 가을밤의 여유를 즐겨요.\n\n가족과 함께 천천히 걷기에도, 친구와 특별한 추억을 남기기에도 좋은 문화산책입니다. 편안한 신발과 가벼운 겉옷을 준비해 주세요.\n\n이 내용과 일정은 화면 구성을 위한 예시입니다.",
  },
  {
    ...eventBase,
    festivalId: 1002,
    source: "PUBLIC",
    title: "가을빛으로 물든 정원",
    category: "전시",
    region: "GYEONGGI_GAPYEONG",
    regionDetail: "가평 가을정원",
    imgUrl: "/images/garden.jpg",
    beginDe: "2026-09-20T09:00:00",
    endDe: "2026-10-25T18:00:00",
    partcptExpnInfo: "입장권 별도",
    festivalContent:
      "색색의 국화와 가을 나무 사이를 걸으며 나만의 계절을 담아보세요. 꽃길을 따라 마련된 작은 정원에서 잠시 쉬어가도 좋아요.\n\n화면 미리보기를 위한 예시 행사입니다.",
  },
  {
    ...eventBase,
    festivalId: 1003,
    source: "PUBLIC",
    title: "우리의 주말, 잔디밭 음악회",
    category: "공연",
    region: "GYEONGGI_GOYANG",
    regionDetail: "호수공원 야외무대",
    imgUrl: "/images/music.jpg",
    beginDe: "2026-09-26T16:00:00",
    endDe: "2026-09-27T21:00:00",
    eventTmInfo: "16:00 — 21:00",
    festivalContent:
      "좋아하는 음악과 함께하는 느긋한 주말. 탁 트인 야외무대에서 다양한 공연을 즐겨보세요.\n\n화면 미리보기를 위한 예시 행사입니다.",
  },
  {
    ...eventBase,
    festivalId: 1004,
    source: "PUBLIC",
    title: "꽃길 따라 만나는 가을 축제",
    category: "축제",
    region: "GYEONGGI_PAJU",
    regionDetail: "시민공원 꽃정원",
    imgUrl: "/images/flowers.jpg",
    beginDe: "2026-09-19T10:00:00",
    endDe: "2026-10-18T18:00:00",
    festivalContent:
      "분홍빛 꽃밭부터 노란 국화길까지, 계절의 색을 가까이에서 만나는 하루.\n\n화면 미리보기를 위한 예시 행사입니다.",
  },
  {
    ...eventBase,
    festivalId: 2001,
    submissionId: "demo-submission-1",
    source: "MEMBER",
    title: "이웃과 함께하는 주말 플리마켓",
    category: "플리마켓",
    region: "GYEONGGI_SUWON",
    regionDetail: "행궁동 공방거리",
    imgUrl: "/images/market.jpg",
    beginDe: "2026-09-27T11:00:00",
    endDe: "2026-09-27T17:00:00",
    festivalContent:
      "작은 가게의 정성, 이웃의 취향이 모이는 주말 장터예요. 손으로 만든 소품과 신선한 먹거리를 만나보세요.\n\n화면 미리보기를 위한 예시 제보입니다.",
  },
  {
    ...eventBase,
    festivalId: 2002,
    submissionId: "demo-submission-2",
    source: "MEMBER",
    title: "나의 첫 번째, 드로잉 피크닉",
    category: "체험",
    region: "GYEONGGI_SEONGNAM",
    regionDetail: "분당 중앙공원",
    imgUrl: "/images/art.jpg",
    beginDe: "2026-10-03T13:00:00",
    endDe: "2026-10-03T16:00:00",
    partcptExpnInfo: "재료비 10,000원 (예시)",
    festivalContent:
      "그림을 잘 그리지 않아도 괜찮아요. 공원의 작은 풍경을 나만의 선과 색으로 기록해 보세요.\n\n화면 미리보기를 위한 예시 제보입니다.",
  },
];
/**
 * 미리보기 모드의 고객센터 글. 실제 서비스는 관리자가 쓴 글을 서버에서 받는다.
 * 서버 마이그레이션(V51)에 처음 넣은 내용과 같다.
 */
const supportArticle = (
  id: number,
  type: SupportArticle["type"],
  title: string,
  content: string[],
  displayOrder = 0,
): SupportArticle => ({
  id,
  type,
  title,
  content: content.join("\n"),
  displayOrder,
  createdAt: "2026-10-27T09:00:00",
  updatedAt: "2026-10-27T09:00:00",
});
export const previewNotices: SupportArticle[] = [
  supportArticle(3, "NOTICE", "고객센터를 열었어요", [
    "공지사항과 자주 묻는 질문을 고객센터 한곳에서 볼 수 있어요.",
    "여기서 답을 찾지 못했다면 문의하기로 남겨 주세요. 답변은 마이페이지 문의 탭에서 확인할 수 있어요.",
  ]),
  supportArticle(2, "NOTICE", "행사 제보 전에 확인해 주세요", [
    "행사 이름, 일정, 장소, 안내 링크를 공식 채널에서 한 번 더 확인한 뒤 제보해 주세요.",
    "사실과 다른 제보는 다른 이웃의 신고를 받을 수 있고, 운영 정책에 따라 활동이 제한될 수 있어요.",
  ]),
  supportArticle(1, "NOTICE", "커뮤니티에서 함께 지켜 주세요", [
    "동행을 구할 때는 공개된 장소에서 만나고, 연락처 같은 개인정보는 글에 남기지 말아 주세요.",
    "불편한 글이나 댓글은 신고 버튼으로 알려 주시면 운영진이 확인할게요.",
  ]),
];
export const previewFaqs: SupportArticle[] = [
  supportArticle(
    4,
    "FAQ",
    "행사는 어떻게 제보하나요?",
    [
      "화면 위의 ‘행사 제보하기’ 버튼을 눌러 주세요. 행사 이름, 종류, 시작일과 종료일, 시·도와 시·군·구, 행사 참고 링크는 꼭 적어야 해요.",
      "제보한 행사는 행사 상세 화면에서 고치거나 지울 수 있고, 마이페이지 ‘내가 작성한 글’에서 모아 볼 수 있어요.",
    ],
    1,
  ),
  supportArticle(
    5,
    "FAQ",
    "공공 행사와 민간 행사는 무엇이 다른가요?",
    [
      "공공 행사는 공공데이터로 받아 온 행사예요. 민간 행사는 회원이 직접 제보한 행사예요.",
      "행사 메뉴에서 공공 행사나 민간 행사를 고르면 그 행사만 모아 볼 수 있어요.",
    ],
    2,
  ),
  supportArticle(
    6,
    "FAQ",
    "제보자 등급은 어떻게 올라가나요?",
    [
      "처음에는 ‘탈출 꿈나무’로 시작해요.",
      "내 제보가 좋아요 또는 정확해요를 10개 이상 받으면 ‘탈출 메이커’, 좋아요와 정확해요를 모두 10개 이상 받으면 ‘탈출 마스터’가 돼요.",
    ],
    3,
  ),
  supportArticle(
    7,
    "FAQ",
    "행사 정보가 실제와 달라요.",
    [
      "민간 행사는 상세 화면에서 ‘부정확해요’를 눌러 알려 주세요. 부정확해요가 10개 이상 쌓이면 상세 화면에 확인이 필요하다는 안내가 떠요.",
      "행사가 취소됐거나 정보가 빠졌다면 상세 화면 위쪽의 ‘신고 및 제보’로 알려 주세요.",
    ],
    4,
  ),
  supportArticle(
    8,
    "FAQ",
    "불편한 후기나 글을 봤어요.",
    [
      "후기와 커뮤니티 글 위쪽의 신고 버튼, 댓글 옆의 신고 버튼으로 알려 주세요. 운영진이 확인한 뒤 처리해요.",
    ],
    5,
  ),
  supportArticle(
    9,
    "FAQ",
    "문의한 내용의 답변은 어디서 보나요?",
    [
      "마이페이지 문의 탭에서 볼 수 있어요. 문의 내용과 답변은 작성한 본인만 볼 수 있어요.",
    ],
    6,
  ),
  supportArticle(
    10,
    "FAQ",
    "회원 탈퇴는 어디서 하나요?",
    ["마이페이지 내 정보 화면 아래쪽의 ‘회원 탈퇴’에서 할 수 있어요."],
    7,
  ),
];
export const demoMember: Member = {
  id: "demo-member",
  nickname: "산책하는 하루",
  email: "preview@example.com",
  phone: null,
  profileImg: null,
  role: "ROLE_UNVERIFIED",
  createdAt: "2026-09-01T09:00:00",
  updatedAt: "2026-09-01T09:00:00",
};
export const demoCommunityEvents: EventView[] = [
  {
    ...demoEvents[4],
    festivalId: 3001,
    submissionId: undefined,
    submitter: {
      id: "demo-neighbor",
      nickname: "소소한 여행자",
      profileImg: null,
      role: "ROLE_RECOGNIZED",
    },
    title: "동네 책방, 가을 낭독회",
    category: "체험",
    regionDetail: "행궁동 작은 책방",
    imgUrl: "/images/art.jpg",
    festivalContent:
      "이웃과 좋아하는 문장을 나누는 작은 낭독회입니다. 다른 회원이 제보한 행사를 둘러보기 위한 예시입니다.",
  },
  {
    ...demoEvents[5],
    festivalId: 3002,
    submissionId: undefined,
    submitter: {
      id: "demo-neighbor-2",
      nickname: "주말 수집가",
      profileImg: null,
      role: "ROLE_TRUSTED",
    },
    title: "호숫가 작은 음악회",
    partcptExpnInfo: "무료",
    category: "공연",
    region: "GYEONGGI_GOYANG",
    regionDetail: "호수공원 야외무대",
    imgUrl: "/images/music.jpg",
    festivalContent:
      "호숫가에서 함께 즐기는 작은 음악회입니다. 다른 회원이 제보한 행사를 둘러보기 위한 예시입니다.",
  },
];
export function previewSubmittedEvents(): EventView[] {
  const data = readDemo();
  return [
    ...demoCommunityEvents,
    ...data.submissions.map(({ submission }) => ({
      ...submission.festival,
      manager: null,
      submissionId: undefined,
      source: "MEMBER" as const,
      preview: true,
      submitter: {
        id: data.member.id,
        nickname: data.member.nickname,
        profileImg: data.member.profileImg,
        role: data.member.role,
      },
    })),
  ];
}
interface DemoState {
  member: Member;
  submissions: SubmissionDetail[];
  posts: PostDetail[];
  comments: Comment[];
  inquiries: Inquiry[];
  likes: Record<string, number>;
  liked: string[];
}
const initial: DemoState = {
  member: demoMember,
  submissions: demoEvents
    .filter((e) => e.source === "MEMBER")
    .map((e) => ({
      submission: {
        festivalSubmissionId: e.submissionId!,
        createdAt: "2026-09-15T10:00:00",
        updatedAt: "2026-09-15T10:00:00",
        festival: e,
      },
    })),
  posts: [
    {
      id: "demo-post-1",
      member: {
        id: "demo-neighbor",
        nickname: "소소한 여행자",
        profileImg: null,
      },
      festivalId: 1001,
      festivalTitle: demoEvents[0].title,
      title: "걷는 것만으로도 좋았던 저녁",
      content:
        "해가 지고 조명이 켜지니 분위기가 정말 달라졌어요.\n성곽을 따라 천천히 걷다가 쉬어 갈 곳도 많아서 좋았습니다. 다음에는 가족과 함께 와보고 싶어요.\n\n이 후기는 디자인 미리보기용 예시입니다.",
      thumbnail: "/images/palace.jpg",
      date: "2026-09-20T20:30:00",
    },
    {
      id: "demo-post-2",
      member: {
        id: "demo-member",
        nickname: demoMember.nickname,
        profileImg: null,
      },
      festivalId: 1002,
      festivalTitle: demoEvents[1].title,
      title: "가을 색을 가득 담아 왔어요",
      content:
        "사진으로 다 담기지 않는 가을빛이었어요. 꽃길 사이사이 벤치가 있어 여유롭게 둘러봤습니다.\n\n이 후기는 디자인 미리보기용 예시입니다.",
      thumbnail: "/images/garden.jpg",
      date: "2026-09-21T10:00:00",
    },
    {
      id: "demo-post-3",
      member: {
        id: "demo-neighbor-2",
        nickname: "주말 수집가",
        profileImg: null,
      },
      festivalId: 1003,
      festivalTitle: demoEvents[2].title,
      title: "음악과 함께 쉬어가는 하루",
      content:
        "돗자리 하나 챙겨서 편하게 즐기기 좋았어요.\n\n이 후기는 디자인 미리보기용 예시입니다.",
      thumbnail: "/images/music.jpg",
      date: "2026-09-19T19:00:00",
    },
  ],
  comments: [
    {
      id: 1,
      postId: "demo-post-1",
      parentId: null,
      deleted: false,
      member: {
        id: "demo-neighbor-2",
        nickname: "주말 수집가",
        profileImg: null,
        role: "ROLE_UNVERIFIED",
      },
      content: "저녁 산책 코스로 기억해 둘게요! (예시 댓글)",
      date: "2026-09-21T09:00:00",
      replies: [],
    },
  ],
  inquiries: [],
  likes: { "demo-post-1": 12, "demo-post-2": 8, "demo-post-3": 6 },
  liked: [],
};
export function readDemo(): DemoState {
  try {
    const saved = sessionStorage.getItem("eventus.preview.v1");
    return saved ? JSON.parse(saved) : structuredClone(initial);
  } catch {
    return structuredClone(initial);
  }
}
export function previewPosts(
  festivalId?: number,
  sort: ReviewSort = "likeCount,desc",
) {
  const data = readDemo();
  return data.posts
    .filter(
      (post) => festivalId === undefined || post.festivalId === festivalId,
    )
    .map((post) => ({ ...post, likeCount: data.likes[post.id] || 0 }))
    .sort((a, b) => {
      const newestFirst =
        parseDateTime(b.date).getTime() - parseDateTime(a.date).getTime();
      if (sort === "likeCount,desc")
        return (
          b.likeCount - a.likeCount || newestFirst || a.id.localeCompare(b.id)
        );
      return (
        (sort === "createdAt,asc" ? -newestFirst : newestFirst) ||
        a.id.localeCompare(b.id)
      );
    });
}
export function updateDemo<T>(fn: (state: DemoState) => T): T {
  const data = readDemo();
  const result = fn(data);
  sessionStorage.setItem("eventus.preview.v1", JSON.stringify(data));
  return result;
}
