// 업로드 전 콘텐츠 검증 (TRD 6.2절 규칙). 사용: node tool/validate_content.mjs [경로]
// 오류는 `코드: 위치` 형식이며 코드 정의는 TRD 6.2.2절이다. lib/core/validation.dart 와 같은 규칙이어야 한다.
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';

// 증상별 필수 단계 수. lib/core/validation.dart 의 expectedSteps 와 같아야 한다.
const expectedSteps = { ankle_instability: 5 };
const tensionValues = ['없음', '당기지 않음', '약하게'];
const referenceTypes = ['학술', '의료기관', '교육 자료', '콘텐츠 검수'];
const versionPattern = /^\d+\.\d+\.\d+$/;
const datePattern = /^\d{4}-\d{2}-\d{2}$/;

const len = (s) => [...s].length;

export function validate(data) {
  const errors = [];
  const text = (where, value, max) => {
    const v = typeof value === 'string' ? value : '';
    if (v.trim() === '') errors.push(`FIELD_EMPTY: ${where}`);
    else if (len(v) > max) errors.push(`FIELD_LENGTH: ${where}`);
  };
  const refIds = new Set((data.references ?? []).map((r) => r.id));
  const checkSources = (where, ids, required) => {
    const list = ids ?? [];
    if (required && list.length === 0) errors.push(`SOURCE_MISSING: ${where}`);
    if (list.length > 10) errors.push(`FIELD_LENGTH: ${where} sources`);
    if (new Set(list).size !== list.length) errors.push(`SOURCE_DUPLICATE: ${where}`);
    for (const id of list) if (!refIds.has(id)) errors.push(`REF_BROKEN: ${where} ${id}`);
  };

  if (!versionPattern.test(data.meta?.contentVersion ?? '')) errors.push('VERSION_FORMAT: meta.contentVersion');
  text('meta.disclaimer', data.meta?.disclaimer, 200);

  for (const r of data.references ?? []) {
    if (!referenceTypes.includes(r.type)) errors.push(`ENUM_INVALID: ${r.id} type`);
    text(`${r.id} title`, r.title, 200);
    if (r.url && (len(r.url) > 500 || !r.url.startsWith('https://'))) errors.push(`FIELD_LENGTH: ${r.id} url`);
  }

  const partIds = new Set((data.bodyParts ?? []).map((p) => p.id));
  for (const g of data.guides ?? []) {
    if (!partIds.has(g.bodyPartId)) errors.push(`REF_BROKEN: ${g.id} bodyPartId`);
    text(`${g.id} name`, g.name, 60);
    text(`${g.id} tape`, g.tape, 60);
    text(`${g.id} tapeNeeded`, g.tapeNeeded, 60);
    checkSources(g.id, g.sources, true);

    const status = g.review?.status ?? 'pending';
    if (!['pending', 'verified'].includes(status)) errors.push(`REVIEW_INVALID: ${g.id}`);
    if (status === 'verified' && !datePattern.test(g.review?.reviewedAt ?? '')) {
      errors.push(`REVIEW_DATE_MISSING: ${g.id}`);
    }
    text(`${g.id} review.reviewer`, g.review?.reviewer, 30);

    const steps = g.steps ?? [];
    const want = expectedSteps[g.id];
    if (steps.length === 0 || (want !== undefined && steps.length !== want)) errors.push(`STEP_COUNT: ${g.id}`);
    const orders = steps.map((s) => s.order).sort((a, b) => a - b);
    if (orders.some((o, i) => o !== i + 1)) errors.push(`STEP_ORDER: ${g.id}`);

    for (const s of steps) {
      const w = `${g.id} step ${s.order}`;
      text(`${w} title`, s.title, 20);
      text(`${w} body`, s.body, 200);
      if (!s.tension || String(s.tension).trim() === '') errors.push(`FIELD_EMPTY: ${w} tension`);
      else if (!tensionValues.includes(s.tension)) errors.push(`ENUM_INVALID: ${w} tension`);
      checkSources(w, s.sources, true);
      const lines = s.tape ?? [];
      if (lines.length > 10) errors.push(`FIELD_LENGTH: ${w} tape`);
      const tapeOk = lines.every(
        (line) =>
          line.length >= 2 &&
          line.every((p) => p.length === 2 && p.every(Number.isFinite) && p[0] >= 0 && p[0] <= 210 && p[1] >= 0 && p[1] <= 230),
      );
      if (!tapeOk) errors.push(`TAPE_RANGE: ${w}`);
    }

    const cautions = g.cautions ?? [];
    if (cautions.length === 0) errors.push(`CAUTION_MISSING: ${g.id}`);
    if (cautions.length > 10) errors.push(`FIELD_LENGTH: ${g.id} cautions`);
    for (const c of cautions) {
      text(`${g.id} caution`, c.text, 120);
      checkSources(`${g.id} caution`, c.sources, false);
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
