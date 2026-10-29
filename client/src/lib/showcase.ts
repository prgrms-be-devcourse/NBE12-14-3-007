import type {
  Comment,
  CommunityCategory,
  CommunityComment,
  CommunityMember,
  CommunityPostDetail,
  CommunityPostSummary,
  EventView,
  FestivalAccuracyVote,
  FestivalSearchInput,
  Member,
  Page,
  PostDetail,
  PostInput,
  PostSearch,
  PostSummary,
} from "./types";
import {
  showcaseComments,
  showcaseCommunityComments,
  showcaseCommunityPosts,
  showcaseEvents,
  showcaseLikes,
  showcaseMemberIds,
  showcasePosts,
  showcaseVotes,
  type CommentSeed,
} from "./showcaseData";
import { normalizeFestivalCategory } from "./format";

/**
 * 실제 서비스(api 모드)에서 공공 행사는 서버에서 받고, 회원 제보 행사·후기·댓글·좋아요·커뮤니티 글은
 * 프론트에 넣어 둔 데이터(showcaseData.ts)를 서버 목록에 섞어 보여 준다.
 * 방문자가 이 데이터에 남긴 좋아요·댓글·후기는 서버로 보내지 않고 이 브라우저에만 저장한다.
 * VITE_SHOWCASE=off 로 빌드하면 끈다.
 */
export const SHOWCASE_ENABLED = import.meta.env.VITE_SHOWCASE !== "off";

const STORAGE_KEY = "eventus.showcase.v1";
/** 서버가 삭제된 댓글 자리에 내려주는 문구와 같다. */
const DELETED_COMMENT = "삭제된 댓글입니다";

interface LocalComment extends CommentSeed {
  postId: string;
  updatedAt: string;
}
interface LocalState {
  /** 좋아요 키("festival:{id}" 또는 후기 ID) → 회원 ID → 누른 시각 */
  likes: Record<string, Record<string, string>>;
  /** 행사 ID → 회원 ID → 정확도 투표 */
  votes: Record<string, Record<string, "ACCURATE" | "INACCURATE">>;
  /** 예시 행사에 남긴 후기 */
  posts: PostDetail[];
  comments: LocalComment[];
  communityComments: LocalComment[];
  /** 지운 댓글 ID. 예시 댓글과 이 브라우저에서 단 댓글 모두 */
  deletedComments: number[];
  views: Record<string, number>;
}
const emptyState = (): LocalState => ({
  likes: {},
  votes: {},
  posts: [],
  comments: [],
  communityComments: [],
  deletedComments: [],
  views: {},
});
function read(): LocalState {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    return saved ? { ...emptyState(), ...JSON.parse(saved) } : emptyState();
  } catch {
    return emptyState();
  }
}
function update<T>(fn: (state: LocalState) => T): T {
  const state = read();
  const result = fn(state);
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  } catch {
    // 저장소를 못 쓰면 이번 화면에서만 반영된다.
  }
  return result;
}
const now = () => {
  // 서버 응답과 같은 한국 시간 LocalDateTime 모양으로 맞춘다.
  const kst = new Date(Date.now() + 9 * 3600 * 1000);
  return kst.toISOString().slice(0, 19);
};

const eventIds = new Set(showcaseEvents.map((event) => event.festivalId));
const postIds = new Set(showcasePosts.map((post) => post.id));
const communityIds = new Set(showcaseCommunityPosts.map((post) => post.id));
const commentIds = new Set(
  Object.values(showcaseComments).flatMap((items) => items.map((c) => c.id)),
);
const communityCommentIds = new Set(
  Object.values(showcaseCommunityComments).flatMap((items) =>
    items.map((c) => c.id),
  ),
);

export const isShowcaseFestival = (festivalId: number) =>
  eventIds.has(festivalId);
export const isShowcasePost = (postId: string) =>
  postIds.has(postId) || read().posts.some((post) => post.id === postId);
export const isShowcaseCommunityPost = (postId: string) =>
  communityIds.has(postId);
export const isShowcaseComment = (commentId: number) =>
  commentIds.has(commentId) ||
  read().comments.some((comment) => comment.id === commentId);
export const isShowcaseCommunityComment = (commentId: number) =>
  communityCommentIds.has(commentId) ||
  read().communityComments.some((comment) => comment.id === commentId);
/** 신고 대상이 프론트 데이터인지. 서버는 이 대상을 모른다. */
export function isShowcaseTarget(type: string, id: string) {
  switch (type) {
    case "FESTIVAL":
      return isShowcaseFestival(Number(id));
    case "POST":
      return isShowcasePost(id);
    case "COMMENT":
      return isShowcaseComment(Number(id));
    case "MEMBER":
      return showcaseMemberIds.has(id);
    case "COMMUNITY_POST":
      return isShowcaseCommunityPost(id);
    case "COMMUNITY_COMMENT":
      return isShowcaseCommunityComment(Number(id));
    default:
      return false;
  }
}

function likeState(state: LocalState, key: string, memberId?: string) {
  const likedBy = state.likes[key] || {};
  return {
    likeCount: (showcaseLikes[key] || 0) + Object.keys(likedBy).length,
    likedByMe: Boolean(memberId && likedBy[memberId]),
  };
}
/** 좋아요를 누르거나 취소한다. 키는 "festival:{id}" 또는 후기 ID */
export function likeShowcase(key: string, memberId: string, remove: boolean) {
  return update((state) => {
    const likedBy = (state.likes[key] ||= {});
    if (remove) delete likedBy[memberId];
    else likedBy[memberId] ||= now();
    return { likeCount: likeState(state, key, memberId).likeCount };
  });
}

function voteState(
  state: LocalState,
  festivalId: number,
  memberId?: string,
): FestivalAccuracyVote {
  const [accurate, inaccurate] = showcaseVotes[festivalId] || [0, 0];
  const votes = Object.values(state.votes[festivalId] || {});
  return {
    accurateCount: accurate + votes.filter((v) => v === "ACCURATE").length,
    inaccurateCount:
      inaccurate + votes.filter((v) => v === "INACCURATE").length,
    myVote: (memberId && state.votes[festivalId]?.[memberId]) || null,
  };
}
/** voteType이 null이면 투표를 취소한다. */
export function voteShowcase(
  festivalId: number,
  memberId: string,
  voteType: "ACCURATE" | "INACCURATE" | null,
) {
  return update((state) => {
    const votes = (state.votes[festivalId] ||= {});
    if (voteType) votes[memberId] = voteType;
    else delete votes[memberId];
    return voteState(state, festivalId, memberId);
  });
}

function eventView(
  state: LocalState,
  event: EventView,
  memberId?: string,
): EventView {
  return {
    ...event,
    category: normalizeFestivalCategory(event.category),
    ...likeState(state, `festival:${event.festivalId}`, memberId),
    accuracyVote: voteState(state, event.festivalId, memberId),
  };
}
export function showcaseFestival(festivalId: number, memberId?: string) {
  const event = showcaseEvents.find((e) => e.festivalId === festivalId);
  return event && eventView(read(), event, memberId);
}
/** 서버 검색(GET /festivals)과 같은 조건으로 예시 행사를 거른다. 정렬은 하지 않는다. */
export function searchShowcaseFestivals(
  input: FestivalSearchInput,
  memberId?: string,
): EventView[] {
  if (input.providerType === "PUBLIC") return [];
  const state = read();
  const keyword = input.keyword?.trim().toLowerCase() || "";
  const category = input.category && normalizeFestivalCategory(input.category);
  const district = input.regionDetail?.trim().toLowerCase();
  const nowTime = Date.now();
  return showcaseEvents
    .filter(
      (event) =>
        (!keyword ||
          event.title.toLowerCase().includes(keyword) ||
          event.regionDetail.toLowerCase().includes(keyword)) &&
        (!input.region || event.region === input.region) &&
        (!district ||
          (event.district || event.regionDetail).toLowerCase() === district) &&
        (!category || normalizeFestivalCategory(event.category) === category) &&
        (!input.date ||
          (event.beginDe.slice(0, 10) <= input.date &&
            event.endDe.slice(0, 10) >= input.date)) &&
        (!input.excludeClosed ||
          new Date(`${event.endDe}+09:00`).getTime() >= nowTime),
    )
    .map((event) => eventView(state, event, memberId));
}

const stripTags = (html: string) =>
  html
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
function postView(
  state: LocalState,
  post: PostDetail,
  memberId?: string,
): PostDetail {
  return {
    ...post,
    preview: stripTags(post.content).slice(0, 240),
    ...likeState(state, post.id, memberId),
  };
}
function allPosts(state: LocalState) {
  return [...state.posts, ...showcasePosts];
}
/** 서버 목록 응답처럼 본문 대신 미리보기만 둔다. */
function postSummary(
  state: LocalState,
  post: PostDetail,
  memberId?: string,
): PostSummary {
  const { content: _, ...summary } = postView(state, post, memberId);
  return summary;
}
export function showcasePost(postId: string, memberId?: string) {
  const state = read();
  const post = allPosts(state).find((p) => p.id === postId);
  return post && postView(state, post, memberId);
}
/** 서버 후기 검색과 같은 조건으로 거른다. festivalId가 있으면 그 행사 후기만. */
export function searchShowcasePosts(
  festivalId: number | undefined,
  search: PostSearch,
  memberId?: string,
): PostSummary[] {
  const state = read();
  const keyword = search.keyword?.trim().toLowerCase();
  return allPosts(state)
    .filter((post) => {
      if (festivalId !== undefined) return post.festivalId === festivalId;
      if (!keyword) return true;
      const value =
        search.type === "MEMBER_NICKNAME"
          ? post.member.nickname
          : search.type === "FESTIVAL_TITLE"
            ? post.festivalTitle
            : post.title;
      return value.toLowerCase().includes(keyword);
    })
    .map((post) => postSummary(state, post, memberId));
}
export function createShowcasePost(
  festivalId: number,
  input: PostInput,
  author: Member,
) {
  const festival = showcaseEvents.find((e) => e.festivalId === festivalId)!;
  return update((state) => {
    const id = `sc-local-${crypto.randomUUID()}`;
    state.posts.unshift({
      ...input,
      thumbnail: input.thumbnail || null,
      id,
      festivalId,
      festivalTitle: festival.title,
      member: {
        id: author.id,
        nickname: author.nickname,
        profileImg: author.profileImg,
      },
      date: now(),
    });
    return { id };
  });
}
export function updateShowcasePost(postId: string, input: PostInput) {
  return update((state) => {
    const post = state.posts.find((p) => p.id === postId);
    if (!post) throw new Error("이 후기는 수정할 수 없어요.");
    Object.assign(post, input, { thumbnail: input.thumbnail || null });
    return postView(state, post);
  });
}
export function deleteShowcasePost(postId: string) {
  update((state) => {
    state.posts = state.posts.filter((p) => p.id !== postId);
  });
}
/** 내가 이 브라우저에서 좋아요한 예시 행사·후기. 최근에 누른 순 */
export function likedShowcase(memberId: string) {
  const state = read();
  const likedAt = (key: string) => state.likes[key]?.[memberId];
  const byRecent = (a: string, b: string) =>
    likedAt(b)!.localeCompare(likedAt(a)!);
  return {
    festivals: showcaseEvents
      .filter((e) => likedAt(`festival:${e.festivalId}`))
      .sort((a, b) =>
        byRecent(`festival:${a.festivalId}`, `festival:${b.festivalId}`),
      )
      .map((event) => eventView(state, event, memberId)),
    posts: allPosts(state)
      .filter((post) => likedAt(post.id))
      .sort((a, b) => byRecent(a.id, b.id))
      .map((post) => postSummary(state, post, memberId)),
  };
}

const authorOf = (member: Member): CommunityMember => ({
  id: member.id,
  nickname: member.nickname,
  profileImg: member.profileImg,
  role: member.role,
});
function commentsOf(
  seeds: CommentSeed[],
  local: LocalComment[],
  deleted: number[],
) {
  return [...seeds.map((seed) => ({ ...seed, updatedAt: seed.date })), ...local]
    .map((comment) => ({
      ...comment,
      deleted: deleted.includes(comment.id),
    }))
    .sort((a, b) => a.date.localeCompare(b.date) || a.id - b.id);
}
/** 서버와 같다: 일반 댓글 기준으로 오래된 순 페이지를 나누고, 대댓글은 replies에 붙인다. */
function threadPage<T extends { id: number; parentId: number | null }>(
  items: T[],
  page: number,
  size: number,
  view: (item: T, replies: T[]) => T,
): Page<T> {
  const roots = items
    .filter((item) => item.parentId === null)
    .map((root) =>
      view(
        root,
        items.filter((item) => item.parentId === root.id),
      ),
    );
  return pageOf(roots, page, size);
}
export function showcaseCommentPage(
  postId: string,
  page: number,
  size: number,
): Page<Comment> {
  const state = read();
  const items: Comment[] = commentsOf(
    showcaseComments[postId] || [],
    state.comments.filter((c) => c.postId === postId),
    state.deletedComments,
  ).map(({ updatedAt: _, ...comment }) => ({
    ...comment,
    postId,
    replies: [],
  }));
  const hide = (c: Comment): Comment =>
    c.deleted ? { ...c, member: null, content: DELETED_COMMENT } : c;
  return threadPage(items, page, size, (root, replies) => ({
    ...hide(root),
    replies: replies.map(hide),
  }));
}
export function showcaseCommunityCommentPage(
  postId: string,
  page: number,
  size: number,
): Page<CommunityComment> {
  const state = read();
  const items: CommunityComment[] = commentsOf(
    showcaseCommunityComments[postId] || [],
    state.communityComments.filter((c) => c.postId === postId),
    state.deletedComments,
  ).map(({ date, ...comment }) => ({
    ...comment,
    postId,
    createdAt: date,
    replies: [],
  }));
  const hide = (c: CommunityComment): CommunityComment =>
    c.deleted ? { ...c, member: null, content: DELETED_COMMENT } : c;
  return threadPage(items, page, size, (root, replies) => ({
    ...hide(root),
    replies: replies.map(hide),
  }));
}
/** parentId가 대댓글이면 서버처럼 그 부모 아래에 붙인다. */
function addComment(
  list: LocalComment[],
  seeds: CommentSeed[],
  postId: string,
  content: string,
  parentId: number | undefined,
  author: Member,
): LocalComment {
  const parent = [...seeds, ...list].find((c) => c.id === parentId);
  const date = now();
  const comment: LocalComment = {
    id: Date.now(),
    postId,
    parentId: parent ? (parent.parentId ?? parent.id) : null,
    member: authorOf(author),
    content,
    date,
    updatedAt: date,
  };
  list.push(comment);
  return comment;
}
export function createShowcaseComment(
  postId: string,
  content: string,
  parentId: number | undefined,
  author: Member,
): Comment {
  return update((state) => {
    const { updatedAt: _, ...comment } = addComment(
      state.comments,
      showcaseComments[postId] || [],
      postId,
      content,
      parentId,
      author,
    );
    return { ...comment, deleted: false, replies: [] };
  });
}
export function createShowcaseCommunityComment(
  postId: string,
  content: string,
  parentId: number | undefined,
  author: Member,
): CommunityComment {
  return update((state) => {
    const { date, ...comment } = addComment(
      state.communityComments,
      showcaseCommunityComments[postId] || [],
      postId,
      content,
      parentId,
      author,
    );
    return { ...comment, createdAt: date, deleted: false, replies: [] };
  });
}
/** 이 브라우저에서 단 댓글만 고칠 수 있다. */
export function updateShowcaseComment(commentId: number, content: string) {
  update((state) => {
    const comment = [...state.comments, ...state.communityComments].find(
      (c) => c.id === commentId,
    );
    if (!comment) throw new Error("이 댓글은 수정할 수 없어요.");
    comment.content = content;
    comment.updatedAt = now();
  });
}
export function deleteShowcaseComment(commentId: number) {
  update((state) => {
    if (!state.deletedComments.includes(commentId))
      state.deletedComments.push(commentId);
  });
}

function communityCommentCount(state: LocalState, postId: string) {
  return [
    ...(showcaseCommunityComments[postId] || []),
    ...state.communityComments.filter((c) => c.postId === postId),
  ].filter((c) => !state.deletedComments.includes(c.id)).length;
}
function communitySummary(
  state: LocalState,
  postId: string,
): CommunityPostSummary & { content: string } {
  const post = showcaseCommunityPosts.find((p) => p.id === postId)!;
  return {
    ...post,
    viewCount: post.viewCount + (state.views[postId] || 0),
    commentCount: communityCommentCount(state, postId),
  };
}
/** 서버 커뮤니티 검색과 같은 조건(제목·본문)으로 거른다. */
export function searchShowcaseCommunity(
  category?: CommunityCategory,
  keyword?: string,
): CommunityPostSummary[] {
  const state = read();
  const word = keyword?.trim().toLowerCase();
  return showcaseCommunityPosts
    .filter(
      (post) =>
        (!category || post.category === category) &&
        (!word ||
          post.title.toLowerCase().includes(word) ||
          stripTags(post.content).toLowerCase().includes(word)),
    )
    .map((post) => {
      const { content: _, ...summary } = communitySummary(state, post.id);
      return summary;
    });
}
/** 서버처럼 부를 때마다 조회수를 올린다. */
export function showcaseCommunityPost(
  postId: string,
  countView: boolean,
): CommunityPostDetail {
  return update((state) => {
    if (countView) state.views[postId] = (state.views[postId] || 0) + 1;
    const post = communitySummary(state, postId);
    return { ...post, updatedAt: post.createdAt };
  });
}

export function pageOf<T>(items: T[], page: number, size: number): Page<T> {
  return {
    content: items.slice(page * size, (page + 1) * size),
    totalElements: items.length,
    totalPages: Math.ceil(items.length / size),
    number: page,
    size,
    first: page === 0,
    last: (page + 1) * size >= items.length,
  };
}
/**
 * 서버 목록 한 페이지에 예시 항목을 정렬 순서대로 끼워 넣는다.
 *
 * extras는 compare 순으로 정렬해서 넘긴다. 예시 항목이 서버 항목 사이 어디에 들어가는지
 * 정확히 알려고, 이번 페이지 앞쪽으로 예시 개수만큼 서버 항목을 더 받아 온다(요청은 최대 두 번).
 * 그보다 앞에 들어가는 예시 항목은 반드시 앞 페이지에, 뒤에 들어가는 항목은 뒤 페이지에 놓인다.
 */
export async function mergeWithServer<T>(
  extras: T[],
  page: number,
  size: number,
  compare: (a: T, b: T) => number,
  fetchServer: (page: number, size: number) => Promise<Page<T>>,
): Promise<Page<T>> {
  if (!extras.length) return fetchServer(page, size);
  const start = page * size;
  const end = start + size;
  const from = Math.max(0, start - extras.length);
  const span = end - from;
  const firstPage = Math.floor(from / span);
  const lastPage = Math.floor((end - 1) / span);
  const pages = await Promise.all(
    Array.from({ length: lastPage - firstPage + 1 }, (_, i) =>
      fetchServer(firstPage + i, span),
    ),
  );
  const serverTotal = pages[0].totalElements;
  const offset = from - firstPage * span;
  const window = pages.flatMap((p) => p.content).slice(offset, offset + span);
  // 예시 항목마다 그보다 앞에 오는 서버 항목 수
  const before = extras.map((item) => {
    const index = window.findIndex((server) => compare(server, item) > 0);
    return Math.min(serverTotal, from + (index === -1 ? window.length : index));
  });
  const placed = [
    ...window.map((item, i) => ({
      item,
      at: from + i + before.filter((b) => b <= from + i).length,
    })),
    ...extras.map((item, i) => ({ item, at: before[i] + i })),
  ]
    .filter(({ at }) => at >= start && at < end)
    .sort((a, b) => a.at - b.at);
  const total = serverTotal + extras.length;
  return {
    content: placed.map(({ item }) => item).slice(0, size),
    totalElements: total,
    totalPages: Math.ceil(total / size),
    number: page,
    size,
    first: page === 0,
    last: end >= total,
  };
}
