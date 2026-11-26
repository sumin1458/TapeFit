// 업로드 전 콘텐츠 검증 (TRD 6.2절 규칙). 사용: node tool/validate_content.mjs [경로]
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

// 증상별 필수 단계 수. lib/core/validation.dart 의 expectedSteps 와 같아야 한다.
const expectedSteps = { ankle_instability: 5 };
const versionPattern = /^\d+\.\d+\.\d+$/;

export function validate(data) {
  const errors = [];
  const refIds = new Set((data.references ?? []).map((r) => r.id));
  const checkSources = (where, ids) => {
    if (new Set(ids ?? []).size !== (ids ?? []).length) errors.push(`${where}: 중복된 출처`);
    for (const id of ids ?? []) if (!refIds.has(id)) errors.push(`${where}: 존재하지 않는 출처 ${id}`);
  };
  if (!versionPattern.test(data.meta?.contentVersion ?? '')) errors.push('meta: contentVersion 형식 오류');
  if (!data.meta?.disclaimer) errors.push('meta: disclaimer 필요');
  const partIds = new Set((data.bodyParts ?? []).map((p) => p.id));

  for (const g of data.guides ?? []) {
    if (!partIds.has(g.bodyPartId)) errors.push(`${g.id}: 존재하지 않는 bodyPartId`);
    if (!g.name) errors.push(`${g.id}: 이름 없음`);
    if (!g.sources?.length) errors.push(`${g.id}: 출처 없음`);
    checkSources(g.id, g.sources);
    if (!['pending', 'verified'].includes(g.review?.status)) errors.push(`${g.id}: review.status 오류`);
    if (g.review?.status === 'verified' && !g.review.reviewedAt) errors.push(`${g.id}: 검수 일자 없음`);
    if (!g.steps?.length) errors.push(`${g.id}: 단계 없음`);
    const want = expectedSteps[g.id];
    if (want !== undefined && g.steps?.length !== want) errors.push(`${g.id}: 단계 수 오류`);
    const orders = (g.steps ?? []).map((s) => s.order).sort((a, b) => a - b);
    if (orders.some((o, i) => o !== i + 1)) errors.push(`${g.id}: 단계 order 가 1부터 연속·중복 없음이 아님`);
    for (const s of g.steps ?? []) {
      const w = `${g.id} 단계 ${s.order}`;
      if (!s.title || !s.body) errors.push(`${w}: 제목/본문 없음`);
      if (!s.tension) errors.push(`${w}: 당김 강도 없음`);
      if (!s.sources?.length) errors.push(`${w}: 출처 없음`);
      checkSources(w, s.sources);
      for (const line of s.tape ?? []) {
        const okPoints = line.every(
          (p) => p.length === 2 && p.every(Number.isFinite) && p[0] >= 0 && p[0] <= 210 && p[1] >= 0 && p[1] <= 230,
        );
        if (line.length < 2 || !okPoints) errors.push(`${w}: tape 좌표 오류`);
      }
    }
    if (!g.cautions?.length) errors.push(`${g.id}: 주의사항 없음`);
    for (const c of g.cautions ?? []) {
      if (!c.text) errors.push(`${g.id}: 빈 주의사항`);
      checkSources(`${g.id} 주의사항`, c.sources);
    }
  }
  return errors;
}

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  const path = process.argv[2] ?? 'content/guides.json';
  const errors = validate(JSON.parse(readFileSync(path, 'utf8')));
  if (errors.length) {
    console.error(errors.join('\n'));
    process.exit(1);
  }
  console.log('콘텐츠 검증 통과');
}
