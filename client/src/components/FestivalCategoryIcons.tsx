import type { SVGProps } from "react";

type IconProps = SVGProps<SVGSVGElement> & { size?: number };

/** 분류를 직접 알아볼 수 있도록 무대·발레 슈즈·장구의 형태를 그립니다. */
export function StageIcon({ size = 24, ...props }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M2 3h20v3H2zM2 21h20" />
      <path d="M3 6h7c0 4-2 6-5 7l-2 7zM21 6h-7c0 4 2 6 5 7l2 7z" fill="currentColor" fillOpacity={0.15} />
      <path d="M3 6h7c0 4-2 6-5 7l-2 7zM21 6h-7c0 4 2 6 5 7l2 7zM5 6v5M7 6v3M19 6v5M17 6v3M3 13h3M18 13h3" />
    </svg>
  );
}

export function FamilyIcon({ size = 24, ...props }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} strokeLinecap="round" strokeLinejoin="round" {...props}>
      <circle cx="6" cy="4.5" r="2.3" />
      <circle cx="18" cy="8" r="1.8" />
      <path d="M3 14v-3.5C3 9 4 8 6 8s3 1 3 2.5V14M4.5 13v8M7.5 13v8M9 11l3 3 3-2M15 15v-1.5c0-1.4 1-2.5 3-2.5s3 1.1 3 2.5V16M16.5 15v6M19.5 15v6M15 13l-3 1" />
    </svg>
  );
}

export function BalletShoesIcon({ size = 24, ...props }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} strokeLinecap="round" strokeLinejoin="round" {...props}>
      <path d="M6 2v7c0 3 2 5 2.5 8L9 21h3l-.5-5C11 12 10 10 10 7V2" />
      <path d="M14 2v5c0 3-1 5-1.5 9l-.5 5h3l.5-4C16 14 18 12 18 9V2" />
      <path d="m6 5 4 3M10 4 6 8M14 4l4 4M18 5l-4 3" />
      <path d="m7 12 3.5-1M13.5 11l3.5 1M8.5 17h3M12.5 17h3M7 22h10" />
    </svg>
  );
}

export function JangguIcon({ size = 24, ...props }: IconProps) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth={1.5} strokeLinecap="round" strokeLinejoin="round" {...props}>
      <ellipse cx="4" cy="13" rx="2" ry="7" />
      <ellipse cx="20" cy="13" rx="2" ry="7" />
      <path d="M4 6c4 0 4 4 8 4s4-4 8-4M4 20c4 0 4-4 8-4s4 4 8 4" />
      <path d="m6 8 12 10M6 18 18 8M6 13h12M8 2l12 3" />
    </svg>
  );
}
