class IqamaSound {
  final String id;
  final String name;
  final String description;
  final String url;
  final bool isBuiltIn;

  const IqamaSound({
    required this.id,
    required this.name,
    required this.description,
    required this.url,
    this.isBuiltIn = false,
  });
}

const String _iqamaBaseUrl = 'https://raw.githubusercontent.com/hozifa460/islamic-audios/main/iqama';

final List<IqamaSound> iqamaCatalog = [
  IqamaSound(
    id: 'iqama1',
    name: 'iqamaName1', // مفتاح الترجمة
    description: 'iqamaDesc1', // مفتاح الترجمة
    url: '$_iqamaBaseUrl/iqama1.mp3',
  ),
  IqamaSound(
    id: 'iqama2',
    name: 'iqamaName2',
    description: 'iqamaDesc2',
    url: '$_iqamaBaseUrl/iqama2.mp3',
  ),
  IqamaSound(
    id: 'iqama3',
    name: 'iqamaName3',
    description: 'iqamaDesc3',
    url: '$_iqamaBaseUrl/iqama3.mp3',
  ),
];