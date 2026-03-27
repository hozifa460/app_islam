// lib/data/prayer/iqama_catalog.dart

class IqamaSound {
  final String id;
  final String name;
  final String description;
  final String url; // رابط GitHub
  final bool isBuiltIn;

  const IqamaSound({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    this.isBuiltIn = false,
  });
}

// ✅ غيّر الروابط هنا لروابط GitHub الخاصة بك
const String _iqamaBaseUrl =
    'https://raw.githubusercontent.com/hozifa460/islamic-audios/main/iqama';

final List<IqamaSound> iqamaCatalog = [
  IqamaSound(
    id: 'iqama1',
    name: 'إقامة 1',
    description: 'إقامة بصوت جميل',
    url: '$_iqamaBaseUrl/iqama1.mp3',
  ),
  IqamaSound(
    id: 'iqama2',
    name: 'إقامة 2',
    description: 'إقامة بصوت هادئ',
    url: '$_iqamaBaseUrl/iqama2.mp3',
  ),
  IqamaSound(
    id: 'iqama3',
    name: 'إقامة 3',
    description: 'إقامة مكة المكرمة',
    url: '$_iqamaBaseUrl/iqama3.mp3',
  ),
  // ✅ أضف المزيد هنا حسب ما لديك في GitHub
];