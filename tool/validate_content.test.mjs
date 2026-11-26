// T-25 Node 쪽: test/fixtures/invalid_cases.json 의 잘못된 데이터를 검증 스크립트가 모두 거부하는지 확인한다.
// 실행: node --test tool/validate_content.test.mjs
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { test } from 'node:test';
import { validate } from './validate_content.mjs';

const read = (p) => JSON.parse(readFileSync(new URL(p, import.meta.url), 'utf8'));
const base = () => read('../content/guides.json');
const cases = read('../test/fixtures/invalid_cases.json');

function applyValue(v) {
  return v && typeof v === 'object' && '$repeat' in v ? v.$repeat.repeat(v.count) : v;
}

function setPath(root, path, value) {
  const keys = path.split('.');
  let node = root;
  for (const k of keys.slice(0, -1)) node = node[k];
  node[keys.at(-1)] = applyValue(value);
}

test('콘텐츠 원본은 통과한다', () => {
  assert.deepEqual(validate(base()), []);
});

for (const c of cases) {
  test(`거부: ${c.name} → ${c.code}`, () => {
    const data = base();
    for (const [path, value] of Object.entries(c.set)) setPath(data, path, value);
    const errors = validate(data);
    assert.ok(errors.some((e) => e.startsWith(c.code)), `${c.code} 필요, 실제: ${errors.join(' | ')}`);
  });
}
