// content/guides.json 을 Firestore 에 업로드한다 (Admin SDK, 규칙을 우회).
// 사용: GOOGLE_APPLICATION_CREDENTIALS=<서비스 계정 키 경로, 저장소 밖> node tool/seed/seed.mjs
// 에뮬레이터: FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 node tool/seed/seed.mjs
import { readFileSync } from 'node:fs';
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { validate } from '../validate_content.mjs';

const data = JSON.parse(readFileSync(new URL('../../content/guides.json', import.meta.url), 'utf8'));
const errors = validate(data);
if (errors.length) {
  console.error('검증 실패, 업로드하지 않습니다:\n' + errors.join('\n'));
  process.exit(1);
}

initializeApp({
  credential: process.env.FIRESTORE_EMULATOR_HOST ? undefined : applicationDefault(),
  projectId: process.env.GCLOUD_PROJECT,
});
const db = getFirestore();
const batch = db.batch();

batch.set(db.doc('meta/app'), data.meta);
for (const { id, ...rest } of data.bodyParts) batch.set(db.doc(`bodyParts/${id}`), rest);
for (const { id, ...rest } of data.guides) batch.set(db.doc(`guides/${id}`), rest);
for (const { id, ...rest } of data.references) batch.set(db.doc(`references/${id}`), rest);

await batch.commit();
console.log(`업로드 완료 (contentVersion ${data.meta.contentVersion})`);
