// Converts the page-layout source into an ayah-addressed Warsh dataset.
// This is an audit artifact: every record retains its source page range.
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const input = resolve(
  process.cwd(),
  'assets/json/quran_warsh_nafi_text_pages.v1.json',
);
const output = resolve(
  process.cwd(),
  'assets/json/quran_warsh_nafi_ayahs.audit.v1.json',
);

// The source uses the Madani final verse count used by Warsh: 6214 ayahs.
const warshAyahCounts = [
  7, 285, 200, 175, 122, 167, 206, 76, 130, 109, 121, 111, 44, 54, 99,
  128, 110, 105, 99, 134, 111, 76, 119, 62, 77, 226, 95, 88, 69, 59, 33,
  30, 73, 54, 46, 82, 182, 86, 72, 84, 53, 50, 89, 56, 36, 34, 39, 29, 18,
  45, 60, 47, 61, 55, 77, 99, 28, 21, 24, 13, 14, 11, 11, 18, 12, 12, 31,
  52, 52, 44, 30, 28, 18, 55, 39, 31, 50, 40, 45, 42, 29, 19, 36, 25, 22,
  17, 19, 26, 32, 20, 15, 21, 11, 8, 8, 20, 5, 8, 9, 11, 10, 8, 3, 9, 5,
  5, 6, 3, 6, 3, 5, 4, 5, 6,
];

const arabicNumber = (value) =>
  Number([...value].map((char) => char.codePointAt(0) - 0x0660).join(''));

const cleanVerseText = (value) =>
  value
    .replace(/[\u06D6-\u06ED]/gu, '')
    .replace(/\s+/gu, ' ')
    .trim();

const source = JSON.parse(readFileSync(input, 'utf8'));
if (source.reading !== 'warsh-an-nafi-tariq-al-azraq' || source.pages?.length !== 603) {
  throw new Error('Unexpected Warsh source metadata');
}

const verses = [];
let surah = 0;
let expectedAyah = 1;
let pending = '';
let pendingStartPage = 1;

for (let pageIndex = 0; pageIndex < source.pages.length; pageIndex += 1) {
  const page = pageIndex + 1;
  for (const line of source.pages[pageIndex].split('\n')) {
    if (/^سُورَةُ/u.test(line)) {
      if (pending.trim()) {
        throw new Error(`Unfinished ayah before title on page ${page}`);
      }
      surah += 1;
      expectedAyah = 1;
      if (surah > 114) throw new Error('More than 114 surah titles');
      continue;
    }

    const digitPattern = /[\u0660-\u0669]+/gu;
    let cursor = 0;
    for (const match of line.matchAll(digitPattern)) {
      if (!pending) pendingStartPage = page;
      pending += line.slice(cursor, match.index);
      const ayah = arabicNumber(match[0]);
      if (surah === 0 || ayah !== expectedAyah) {
        throw new Error(
          `Unexpected ayah ${match[0]} at page ${page}; expected ${surah}:${expectedAyah}`,
        );
      }
      const text = cleanVerseText(pending);
      if (!text) throw new Error(`Empty ayah ${surah}:${ayah}`);
      verses.push({
        key: `${surah}:${ayah}`,
        surah,
        ayah,
        text,
        startPage: pendingStartPage,
        endPage: page,
      });
      pending = '';
      expectedAyah += 1;
      cursor = match.index + match[0].length;
    }
    if (!pending && line.slice(cursor).trim()) pendingStartPage = page;
    pending += line.slice(cursor);
  }
}

if (pending.trim()) throw new Error('Unfinished ayah at end of source');
if (surah !== 114 || verses.length !== 6214) {
  throw new Error(`Expected 114 surahs / 6214 ayahs, got ${surah} / ${verses.length}`);
}
for (let index = 0; index < warshAyahCounts.length; index += 1) {
  const count = verses.filter((verse) => verse.surah === index + 1).length;
  if (count !== warshAyahCounts[index]) {
    throw new Error(`Ayah count mismatch in surah ${index + 1}: ${count}`);
  }
}

const payload = {
  schemaVersion: 1,
  reading: source.reading,
  source: source.source,
  layoutSource: source.layoutSource,
  sourceTextSha256: source.textSha256,
  ayahCount: verses.length,
  auditNotice:
    'Extracted mechanically from the Warsh page source; not a tajweed-rule map.',
  verses,
};
payload.sha256 = createHash('sha256')
  .update(JSON.stringify(verses), 'utf8')
  .digest('hex');

writeFileSync(output, `${JSON.stringify(payload)}\n`, 'utf8');
console.log(`Saved ${output}`);
console.log(`Validated ${surah} surahs, ${verses.length} ayahs`);
console.log(`SHA-256 ${payload.sha256}`);
