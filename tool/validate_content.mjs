// 업로드 전 콘텐츠 검증 (TRD 6.2절 규칙). 사용: node tool/validate_content.mjs [경로]
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

export function validate(data) {
  const errors = [];
  const refIds = new Set((data.references ?? []).map((r) => r.id));
  const checkSources = (where, ids) => {
    for (const id of ids ?? []) if (!refIds.has(id)) errors.push(`${where}: 존재하지 않는 출처 ${id}`);
  };
  if (!data.meta?.contentVersion || !data.meta?.disclaimer) errors.push('meta: contentVersion/disclaimer 필요');
  const partIds = new Set((data.bodyParts ?? []).map((p) => p.id));

  for (const g of data.guides ?? []) {
    if (!partIds.has(g.bodyPartId)) errors.push(`${g.id}: 존재하지 않는 bodyPartId`);
    if (!g.name) errors.push(`${g.id}: 이름 없음`);
    if (!g.sources?.length) errors.push(`${g.id}: 출처 없음`);
    checkSources(g.id, g.sources);
    if (!['pending', 'verified'].includes(g.review?.status)) errors.push(`${g.id}: review.status 오류`);
    if (g.review?.status === 'verified' && !g.review.reviewedAt) errors.push(`${g.id}: 검수 일자 없음`);
    if (!g.steps?.length) errors.push(`${g.id}: 단계 없음`);
    for (const s of g.steps ?? []) {
      const w = `${g.id} 단계 ${s.order}`;
      if (!s.title || !s.body) errors.push(`${w}: 제목/본문 없음`);
      if (!s.tension) errors.push(`${w}: 당김 강도 없음`);
      if (!s.sources?.length) errors.push(`${w}: 출처 없음`);
      checkSources(w, s.sources);
      for (const line of s.tape ?? [])
        for (const p of line)
          if (p.length !== 2 || !p.every(Number.isFinite)) errors.push(`${w}: tape 좌표 형식 오류`);
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
