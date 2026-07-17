// Downloads the text-only Warsh (Nafi') page layout used by tafsir.app.
// The resulting file is deliberately generated, never hand-edited: use this
// script again whenever the source needs to be re-validated.
import { createHash } from 'node:crypto';
import {
  existsSync,
  mkdirSync,
  readFileSync,
  rmSync,
  writeFileSync,
} from 'node:fs';
import { dirname, resolve } from 'node:path';

const pageCount = 603;
const output = resolve(
  process.cwd(),
  'assets/json/quran_warsh_nafi_text_pages.v1.json',
);
const checkpoint = resolve(
  process.cwd(),
  'assets/json/quran_warsh_nafi_text_pages.partial.json',
);
const batchSize = 120;

async function fetchPage(page, attempt = 1) {
  const url = `https://tafsir.app/get_mushaf.php?src=warsh&pg=${page}`;
  try {
    const response = await fetch(url, {
      headers: { accept: 'application/json' },
      signal: AbortSignal.timeout(20_000),
    });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const payload = await response.json();
    if (typeof payload.data !== 'string' || !payload.data.trim()) {
      throw new Error('empty page');
    }
    return payload.data.replace(/\r\n/g, '\n').trim();
  } catch (error) {
    if (attempt >= 4) throw new Error(`page ${page}: ${error.message}`);
    await new Promise((resolve) => setTimeout(resolve, attempt * 750));
    return fetchPage(page, attempt + 1);
  }
}

mkdirSync(dirname(output), { recursive: true });
const pages = existsSync(checkpoint)
  ? JSON.parse(readFileSync(checkpoint, 'utf8')).pages
  : [];
const stopAt = Math.min(pageCount, pages.length + batchSize);

for (let page = pages.length + 1; page <= stopAt; page += 1) {
  pages.push(await fetchPage(page));
  writeFileSync(checkpoint, JSON.stringify({ pages }), 'utf8');
  if (page % 25 === 0 || page === pageCount) {
    console.log(`Validated ${page}/${pageCount} pages`);
  }
  await new Promise((resolve) => setTimeout(resolve, 80));
}

if (pages.length !== pageCount) {
  console.log(`Checkpoint saved: ${pages.length}/${pageCount} pages`);
  process.exit(0);
}

const pageText = pages.join('\n\f\n');
const payload = {
  schemaVersion: 1,
  reading: 'warsh-an-nafi-tariq-al-azraq',
  source: 'https://tafsir.app/m-warsh-text/1/1',
  layoutSource: 'https://tafsir.app/get_mushaf.php?src=warsh&pg={page}',
  pageCount,
  textSha256: createHash('sha256').update(pageText, 'utf8').digest('hex'),
  pages,
};

writeFileSync(output, `${JSON.stringify(payload)}\n`, 'utf8');
rmSync(checkpoint, { force: true });
console.log(`Saved ${output}`);
console.log(`SHA-256 ${payload.textSha256}`);
