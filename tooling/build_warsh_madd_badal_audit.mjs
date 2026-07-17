// Builds an ayah-addressed audit map for madd al-badal in Warsh 'an Nafi.
// The character offsets intentionally use UTF-16 code units, matching Dart.
import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

const input = resolve(
  process.cwd(),
  'assets/json/quran_warsh_nafi_ayahs.audit.v1.json',
);
const output = resolve(
  process.cwd(),
  'assets/json/warsh_madd_badal_ayah_audit.v1.json',
);

const fatha = 0x064e;
const dammah = 0x064f;
const kasrah = 0x0650;
const sukun = 0x0652;

const isArabicMark = (code) =>
  (code >= 0x064b && code <= 0x065f) ||
  code === 0x0670 ||
  (code >= 0x06d6 && code <= 0x06ed);

const isHamzah = (code) =>
  [0x0621, 0x0623, 0x0624, 0x0625, 0x0626].includes(code);

const followingVowel = (text, hamzahIndex) => {
  for (let index = hamzahIndex + 1; index < text.length; index += 1) {
    const code = text.charCodeAt(index);
    if (!isArabicMark(code)) return null;
    if (code === fatha || code === kasrah || code === dammah) return code;
  }
  return null;
};

const nextBaseLetter = (text, from) => {
  let index = from;
  while (index < text.length && isArabicMark(text.charCodeAt(index))) index += 1;
  return index < text.length ? index : null;
};

// Mushaf Unicode often leaves the madd letter unmarked instead of adding an
// explicit sukun. Both forms are sakin; a vowel or shaddah is not.
const isSakin = (text, letterIndex) => {
  for (let index = letterIndex + 1; index < text.length; index += 1) {
    const code = text.charCodeAt(index);
    if (!isArabicMark(code)) return true;
    if (code === sukun) return true;
    if ([0x064b, 0x064c, 0x064d, fatha, dammah, kasrah, 0x0651].includes(code)) {
      return false;
    }
  }
  return true;
};

const letterEnd = (text, letterIndex) => {
  let index = letterIndex + 1;
  while (index < text.length && isArabicMark(text.charCodeAt(index))) index += 1;
  return index;
};

const vowelName = (vowel) =>
  ({ [fatha]: 'fathah', [kasrah]: 'kasrah', [dammah]: 'dammah' })[vowel];

const findMaddBadal = (text) => {
  const marks = [];
  for (let index = 0; index < text.length; index += 1) {
    const code = text.charCodeAt(index);
    if (code === 0x0622) {
      marks.push({
        start: index,
        end: index + 1,
        text: text.slice(index, index + 1),
        form: 'fathah_alif_precomposed',
      });
      continue;
    }
    if (!isHamzah(code)) continue;

    const vowel = followingVowel(text, index);
    const letterIndex = nextBaseLetter(text, index + 1);
    if (letterIndex === null || vowel === null) continue;
    const letter = text.charCodeAt(letterIndex);
    const isMatch =
      (vowel === fatha && (letter === 0x0627 || letter === 0x0649)) ||
      (vowel === kasrah &&
        (letter === 0x064a || letter === 0x06d2) &&
        isSakin(text, letterIndex)) ||
      (vowel === dammah && letter === 0x0648 && isSakin(text, letterIndex));
    if (!isMatch) continue;

    const end = letterEnd(text, letterIndex);
    marks.push({
      start: index,
      end,
      text: text.slice(index, end),
      form: `${vowelName(vowel)}_${
        vowel === fatha ? 'alif' : vowel === kasrah ? 'yaa' : 'waw'
      }`,
    });
    index = letterIndex;
  }
  return marks;
};

const audit = JSON.parse(readFileSync(input, 'utf8'));
if (audit.reading !== 'warsh-an-nafi-tariq-al-azraq' || audit.ayahCount !== 6214) {
  throw new Error('Unexpected Warsh ayah source');
}

const ayahs = audit.verses.map((verse) => ({
  key: verse.key,
  startPage: verse.startPage,
  endPage: verse.endPage,
  maddBadal: findMaddBadal(verse.text),
}));
const totalMarks = ayahs.reduce((total, ayah) => total + ayah.maddBadal.length, 0);

const payload = {
  schemaVersion: 1,
  reading: audit.reading,
  ayahCountAudited: ayahs.length,
  rule: {
    id: 'madd_badal',
    description:
      'fathah-hamzah followed by alif, kasrah-hamzah followed by sakin yaa, or dammah-hamzah followed by sakin waw in the same word.',
    selectedFace: 'tawassut_al_badal',
    selectedFaceDescription: 'Four counts; qasr is a valid alternate face.',
  },
  evidence: {
    textSource: audit.source,
    textSha256: audit.sourceTextSha256,
    ruleReferences: [
      {
        publisher: 'Sharjah Quran Complex',
        title: "Warsh 'an Nafi al-Madani, Shatibiyyah, tawassut al-badal and taqlil",
        url: 'https://holyquran.shj.ae/publications/warsh-aan-nafi',
      },
      {
        publisher: 'King Fahd Glorious Qur’an Printing Complex',
        title: 'Unicode Uthmanic Font (Warsh Narration)',
        url: 'https://qurancomplex.gov.sa/quran-dev/',
      },
    ],
    status:
      'Every ayah is mechanically checked against the stated rule. Institutional references identify the selected Warsh face; they do not replace specialist review of the map.',
  },
  ayahs,
};
payload.sha256 = createHash('sha256')
  .update(JSON.stringify(ayahs), 'utf8')
  .digest('hex');

writeFileSync(output, `${JSON.stringify(payload)}\n`, 'utf8');
console.log(`Saved ${output}`);
console.log(`Audited ${ayahs.length} ayahs; found ${totalMarks} madd-badal marks`);
console.log(`SHA-256 ${payload.sha256}`);
