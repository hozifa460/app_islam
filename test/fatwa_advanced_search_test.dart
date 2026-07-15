import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/screens/fatwa/models/fatwa_model.dart';
import 'package:islamic_app/screens/fatwa/services/advanced_search_service.dart';

Fatwa _fatwa({
  required String id,
  required String question,
  String answer = 'هذا جواب فقهي مفصل يوضح الحكم المتعلق بالسؤال للمستخدم.',
  String source = 'مصدر اختباري',
  String book = 'كتاب اختباري',
}) {
  return Fatwa(
    id: id,
    question: question,
    title: question,
    answer: answer,
    source: source,
    book: book,
    category: 'عام',
  );
}

void main() {
  test(
    'exactly matching question outranks words scattered in an answer',
    () async {
      final exact = _fatwa(
        id: 'exact',
        question: 'ما حكم الصلاة جالساً للمريض؟',
      );
      final scattered = _fatwa(
        id: 'scattered',
        question: 'أحكام متنوعة',
        answer:
            'توجد مسائل كثيرة للمريض، ومن بينها الصلاة، وقد يكون جالساً في بعض الأحوال.',
      );

      final results = await AdvancedSearchService.search(
        'ما حكم الصلاة جالساً للمريض؟',
        [scattered, exact],
        topK: null,
      );

      expect(results, isNotEmpty);
      expect(results.first.fatwa.id, 'exact');
    },
  );

  test('source and file names never change relevance score', () async {
    final first = _fatwa(
      id: 'github-id',
      question: 'حكم زكاة المال المدخر',
      source: 'GitHub',
      book: 'github_file.json',
    );
    final second = _fatwa(
      id: 'gitlab-id',
      question: 'حكم زكاة المال المدخر',
      source: 'GitLab',
      book: 'gitlab_file.json',
    );

    final results = await AdvancedSearchService.search('زكاة المال المدخر', [
      first,
      second,
    ], topK: null);

    expect(results, hasLength(2));
    expect(results[0].relevanceScore, results[1].relevanceScore);
  });

  test(
    'small Arabic spelling mistake still finds the close question',
    () async {
      final results = await AdvancedSearchService.search('زكاة الماال', [
        _fatwa(id: 'zakat', question: 'كيفية إخراج زكاة المال'),
        _fatwa(id: 'fasting', question: 'حكم الإفطار في السفر'),
      ], topK: null);

      expect(results, isNotEmpty);
      expect(results.first.fatwa.id, 'zakat');
    },
  );

  test(
    'unlimited search keeps accurate results beyond the first page',
    () async {
      final fatawa = List.generate(
        27,
        (index) => _fatwa(
          id: 'prayer-$index',
          question: 'أحكام صلاة المسافر رقم $index',
        ),
      );

      final allResults = await AdvancedSearchService.search(
        'صلاة المسافر',
        fatawa,
        topK: null,
      );
      final firstPage = await AdvancedSearchService.search(
        'صلاة المسافر',
        fatawa,
        topK: 20,
      );

      expect(allResults, hasLength(27));
      expect(firstPage, hasLength(20));
    },
  );
}
