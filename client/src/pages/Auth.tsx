import {
  useEffect,
  useState,
  type CSSProperties,
  type FormEvent,
} from "react";
import { Link, useNavigate, useSearchParams } from "react-router-dom";
import { ArrowLeft, ArrowRight, Eye, EyeOff, ShieldCheck } from "lucide-react";
import { useApp } from "../lib/context";
import { ApiError } from "../lib/api";
import { errorText, waitText } from "../lib/format";
import { Field, FormError, Logo, SubmitButton } from "../components/ui";

/** 서버의 로그인 실패 허용 횟수(auth-rate-limit.login-max-failures)와 같다. 문구에 쓰기만 한다. */
const LOGIN_MAX_FAILURES = 5;

export function AuthPage({ signup = false }: { signup?: boolean }) {
  const { api, setMember, toast, authLoading } = useApp();
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [nickname, setNickname] = useState("");
  const [phone, setPhone] = useState("");
  const [consents, setConsents] = useState({
    terms: false,
    privacy: false,
    age: false,
    marketing: false,
  });
  const [visible, setVisible] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  // 요청 횟수 제한(429)에 걸리면 서버가 알려 준 시각까지 남은 시간을 보여 주고 버튼을 잠근다.
  const [retryAt, setRetryAt] = useState<number | null>(null);
  // 비밀번호가 틀렸을 때 서버가 알려 준, 막히기 전까지 더 틀릴 수 있는 횟수.
  const [remaining, setRemaining] = useState<number | null>(null);
  const [now, setNow] = useState(() => Date.now());
  const waitSeconds = retryAt === null ? 0 : Math.ceil((retryAt - now) / 1000);
  useEffect(() => {
    if (retryAt === null) return;
    const timer = window.setInterval(() => {
      const current = Date.now();
      setNow(current);
      if (current >= retryAt) {
        setRetryAt(null);
        setRemaining(null);
        setError("");
      }
    }, 1000);
    return () => window.clearInterval(timer);
  }, [retryAt]);
  const next = params.get("next");
  const target =
    next?.startsWith("/") && !next.startsWith("//") && !next.includes("\\")
      ? next
      : "/mypage";
  async function submit(e: FormEvent) {
    e.preventDefault();
    setError("");
    setRetryAt(null);
    setRemaining(null);
    if (signup && password !== confirm) {
      setError("비밀번호가 서로 달라요. 다시 확인해 주세요.");
      return;
    }
    setBusy(true);
    try {
      if (signup) {
        await api.signup({
          email: email.trim(),
          password,
          nickname: nickname.trim(),
          ...(phone ? { phone } : {}),
        });
        toast("가입했어요. 이제 로그인해 주세요.");
        navigate(`/login?next=${encodeURIComponent(target)}`);
      } else {
        setMember(await api.login(email.trim(), password));
        navigate(target);
        toast("다시 만나 반가워요.");
      }
    } catch (e) {
      const data = e instanceof ApiError ? e.data : undefined;
      const seconds = data?.retryAfterSeconds;
      if (typeof seconds === "number" && seconds > 0) {
        setNow(Date.now());
        setRetryAt(Date.now() + seconds * 1000);
      }
      if (typeof data?.remainingAttempts === "number") {
        setRemaining(data.remainingAttempts);
      }
      setError(errorText(e));
    } finally {
      setBusy(false);
    }
  }
  return (
    <div className="container auth-page">
      <section className="auth-collage" aria-label="방구석탈출 소개">
        <p className="eyebrow">{signup ? "처음 오셨군요" : "로그인"}</p>
        <h2>
          {signup ? "동네 행사를" : "이번 주말 갈 곳,"}
          <br />
          {signup ? "같이 채워 가요" : "같이 골라 봐요"}
        </h2>
        <p>
          {signup
            ? "가입하면 마음에 드는 행사를 모아 두고, 다녀온 이야기를 이웃과 나눌 수 있어요."
            : "로그인하고 이번 주말에 갈 곳을 골라 보세요."}
        </p>
        <div className="auth-board" aria-hidden="true">
          <span
            className="poster"
            style={
              {
                "--r": "-6deg",
                left: 0,
                top: 30,
                width: "46%",
                background: "#fffdf6",
              } as CSSProperties
            }
          >
            <span
              className="poster-tape"
              style={{
                left: "50%",
                marginLeft: -39,
                transform: "rotate(4deg)",
                background: "#f2c14ed9",
              }}
            />
            <img src="/images/palace.jpg" alt="" />
            <span className="poster-title">달빛 아래 산책</span>
          </span>
          <span
            className="poster"
            style={
              {
                "--r": "4deg",
                left: "34%",
                top: 0,
                width: "44%",
                background: "#e23e96",
                color: "#fff",
                zIndex: 1,
              } as CSSProperties
            }
          >
            <span
              className="poster-tape"
              style={{
                left: 16,
                transform: "rotate(-6deg)",
                background: "#fffdf6b3",
              }}
            />
            <img
              src="/images/music.jpg"
              alt=""
              style={{ filter: "grayscale(1) contrast(1.15)" }}
            />
            <span className="poster-title">잔디밭 음악회</span>
          </span>
          <span
            className="poster"
            style={
              {
                "--r": "-2deg",
                left: "18%",
                top: 200,
                width: "48%",
                background: "#f2c14e",
                zIndex: 2,
              } as CSSProperties
            }
          >
            <span
              className="poster-tape"
              style={{
                right: 20,
                transform: "rotate(5deg)",
                background: "#fffdf6cc",
              }}
            />
            <img src="/images/market.jpg" alt="" />
            <span className="poster-title">주말 플리마켓</span>
          </span>
          <span
            className="sticky-note"
            style={
              {
                "--r": "3deg",
                right: 0,
                top: 180,
                width: "34%",
                background: "#f6c6c0",
                zIndex: 3,
                padding: "18px 16px 16px",
              } as CSSProperties
            }
          >
            <strong className="auth-note-title">로그인하면</strong>
            <span className="auth-note-body">
              좋아요한 행사 모아 보기
              <br />
              후기와 쪽지 남기기
              <br />
              동네 행사 제보하기
            </span>
          </span>
        </div>
      </section>
      <div className="auth-panel">
        <Link className="back-link" to="/">
          <ArrowLeft size={15} />
          홈으로
        </Link>
        <Logo />
        <h1>{signup ? "새로운 즐거움에 함께해요" : "다시 만나 반가워요"}</h1>
        <p className="muted">
          {signup
            ? "일상을 특별하게 만드는 첫걸음, 회원가입."
            : "로그인하고 나만의 즐거운 순간을 기록해요."}
        </p>
        <form onSubmit={submit}>
          <Field label="이메일" required>
            <input
              type="email"
              autoComplete="email"
              required
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="example@email.com"
            />
          </Field>
          <Field
            label="비밀번호"
            required
            hint={
              signup ? "8~25자, 영문·숫자·특수문자(!@#%^&*) 포함" : undefined
            }
          >
            <span className="password-field">
              <input
                type={visible ? "text" : "password"}
                required
                autoComplete={signup ? "new-password" : "current-password"}
                minLength={signup ? 8 : undefined}
                maxLength={signup ? 25 : undefined}
                pattern={
                  signup
                    ? "(?=.*[A-Za-z])(?=.*[0-9])(?=.*[!@#%^&*]).{8,25}"
                    : undefined
                }
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="비밀번호를 입력해 주세요"
              />
              <button
                type="button"
                aria-label={visible ? "비밀번호 숨기기" : "비밀번호 표시"}
                onClick={() => setVisible(!visible)}
              >
                {visible ? <EyeOff size={18} /> : <Eye size={18} />}
              </button>
            </span>
          </Field>
          {signup && (
            <>
              <Field label="비밀번호 확인" required>
                <input
                  type="password"
                  autoComplete="new-password"
                  required
                  value={confirm}
                  onChange={(e) => setConfirm(e.target.value)}
                  placeholder="비밀번호를 다시 입력해 주세요"
                />
              </Field>
              <Field label="닉네임" required hint="2~30자로 입력해 주세요.">
                <input
                  required
                  minLength={2}
                  maxLength={30}
                  autoComplete="nickname"
                  value={nickname}
                  onChange={(e) => setNickname(e.target.value)}
                  placeholder="이웃에게 보여줄 이름"
                />
              </Field>
              <Field
                label="휴대폰 번호"
                hint="선택 항목 · 하이픈 없이 숫자만 입력해 주세요."
              >
                <input
                  type="tel"
                  autoComplete="tel"
                  pattern="01[016789][0-9]{7,8}"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value.replace(/\D/g, ""))}
                  placeholder="01012345678"
                />
              </Field>
              <Consents value={consents} onChange={setConsents} />
            </>
          )}
          <FormError
            message={
              waitSeconds > 0
                ? `${error} ${waitText(waitSeconds)} 뒤에 다시 시도할 수 있어요.`
                : remaining !== null && remaining > 0
                  ? `${error} (${LOGIN_MAX_FAILURES}회 중 ${LOGIN_MAX_FAILURES - remaining}회 실패, ${remaining}회 더 틀리면 잠시 로그인할 수 없어요.)`
                  : error
            }
          />
          <SubmitButton
            busy={busy || authLoading}
            // 필수 동의를 받지 않으면 가입 자체를 막는다. 요청이 너무 많다는 안내가 떠 있는 동안에도 막는다.
            disabled={
              waitSeconds > 0 ||
              (signup && !(consents.terms && consents.privacy && consents.age))
            }
          >
            {signup ? "회원가입" : "로그인"}
            <ArrowRight size={17} />
          </SubmitButton>
        </form>
        <p className="auth-switch">
          {signup ? "이미 함께하고 계신가요?" : "방구석탈출이 처음이신가요?"}
          <Link
            to={`${signup ? "/login" : "/signup"}?next=${encodeURIComponent(target)}`}
          >
            {signup ? "로그인" : "회원가입"}
          </Link>
        </p>
        <p className="auth-foot">
          <ShieldCheck size={15} />
          당신의 새로운 일상을 응원해요.
        </p>
      </div>
    </div>
  );
}

interface ConsentState {
  terms: boolean;
  privacy: boolean;
  age: boolean;
  marketing: boolean;
}
/**
 * 가입 시 법적 고지·동의.
 *
 * 개인정보 수집 항목·목적·보유기간은 개인정보보호법이 고지를 요구하는 항목이라
 * 링크 뒤에 숨기지 않고 화면에 바로 적는다.
 *
 * TODO 동의 시각과 약관 버전을 서버에 기록할 것.
 *      동의를 받았다는 입증 책임은 서비스 쪽에 있는데 지금은 화면에서만 확인한다.
 *      member_consent 테이블과 가입 API 파라미터가 필요하다.
 */
function Consents({
  value,
  onChange,
}: {
  value: ConsentState;
  onChange: (next: ConsentState) => void;
}) {
  const set = (key: keyof ConsentState) => (checked: boolean) =>
    onChange({ ...value, [key]: checked });
  const allRequired = value.terms && value.privacy && value.age;
  const all = allRequired && value.marketing;
  return (
    <div className="consent-box">
      <label className="consent-all">
        <input
          type="checkbox"
          checked={all}
          onChange={(e) => {
            const next = e.target.checked;
            onChange({
              terms: next,
              privacy: next,
              age: next,
              marketing: next,
            });
          }}
        />
        <strong>전체 동의</strong>
        <span>선택 항목을 포함합니다.</span>
      </label>
      <label className="consent-row">
        <input
          type="checkbox"
          checked={value.age}
          onChange={(e) => set("age")(e.target.checked)}
        />
        <span>
          <b>[필수]</b> 만 14세 이상입니다.
        </span>
      </label>
      <label className="consent-row">
        <input
          type="checkbox"
          checked={value.terms}
          onChange={(e) => set("terms")(e.target.checked)}
        />
        <span>
          <b>[필수]</b> 이용약관에 동의합니다.
        </span>
      </label>
      <label className="consent-row">
        <input
          type="checkbox"
          checked={value.privacy}
          onChange={(e) => set("privacy")(e.target.checked)}
        />
        <span>
          <b>[필수]</b> 개인정보 수집·이용에 동의합니다.
        </span>
      </label>
      <dl className="consent-detail">
        <div>
          <dt>수집 항목</dt>
          <dd>이메일, 비밀번호, 닉네임 (선택: 휴대폰 번호, 프로필 사진)</dd>
        </div>
        <div>
          <dt>이용 목적</dt>
          <dd>회원 식별과 로그인, 행사 제보·후기 작성, 문의 응대</dd>
        </div>
        <div>
          <dt>보유 기간</dt>
          <dd>
            탈퇴 후 6개월까지 보관한 뒤 파기합니다. 이 기간에는 같은 이메일로
            다시 가입할 수 없습니다.
          </dd>
        </div>
      </dl>
      <p className="consent-note">
        필수 항목에 동의하지 않으면 가입할 수 없지만, 동의를 거부할 권리가
        있습니다.
      </p>
      <label className="consent-row">
        <input
          type="checkbox"
          checked={value.marketing}
          onChange={(e) => set("marketing")(e.target.checked)}
        />
        <span>
          <b className="optional">[선택]</b> 새로운 행사 소식 메일을 받겠습니다.
        </span>
      </label>
    </div>
  );
}
