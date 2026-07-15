import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islamic_app/screens/radio/data/recitation_categories_data.dart';
import 'package:islamic_app/screens/radio/recitations_screen.dart';
import 'package:islamic_app/screens/radio/services/Radio_Intillegence.dart';
import 'package:islamic_app/screens/radio/services/audio_coordinator.dart';
import 'package:islamic_app/screens/radio/services/offline_radio_service.dart';
import 'package:islamic_app/screens/radio/services/online_surah_service.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/services/item_download_service.dart';
import 'package:islamic_app/screens/radio/widgets_recitations_screen/theme/rec_shapes.dart';
import 'package:provider/provider.dart';

void main() {
  tearDown(() {
    RecitationCategoriesData.resetForTesting();
  });

  testWidgets('recitations screen updates when remote categories stream in',
      (tester) async {
    final initialCategory = _category(
      id: 'local',
      title: 'قسم أولي',
    );
    final remoteCategory = _category(
      id: 'github_sheikh',
      title: 'شيخ من GitHub',
    );

    RecitationCategoriesData.resetForTesting(
      categories: [initialCategory],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AudioCoordinator()),
          ChangeNotifierProvider(create: (_) => RadioIntillegence()),
          ChangeNotifierProvider(create: (_) => OfflineRadioService()),
          ChangeNotifierProvider(create: (_) => OnlineSurahService()),
          ChangeNotifierProvider(create: (_) => ItemDownloadService()),
        ],
        child: MaterialApp(
          home: RecitationsScreen(
            primary: Colors.green,
            embedded: true,
          ),
        ),
      ),
    );

    expect(find.text('قسم أولي'), findsOneWidget);
    expect(find.text('1 عنصر'), findsOneWidget);
    expect(find.text('تلاوة اختبارية'), findsNothing);
    expect(find.text('شيخ من GitHub'), findsNothing);

    RecitationCategoriesData.emitForTesting([
      initialCategory,
      remoteCategory,
    ]);
    await tester.pump();

    expect(find.text('شيخ من GitHub'), findsOneWidget);

    await tester.tap(find.text('قسم أولي'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('تلاوة اختبارية'), findsOneWidget);
  });

  test('recitation cards use compact dimensions on phone screens', () {
    final imageHeight = RecSizes.imageHeight(800);

    expect(imageHeight, lessThanOrEqualTo(120));
    expect(RecSizes.cardWidth(imageHeight), lessThanOrEqualTo(145));
  });
}

RecitationCategory _category({
  required String id,
  required String title,
}) {
  return RecitationCategory(
    id: id,
    title: title,
    emoji: '🎧',
    description: 'اختبار مصدر البيانات',
    gradientColors: const [Color(0xFF123C33), Color(0xFF1B5E20)],
    items: [
      RecitationItem(
        title: 'تلاوة اختبارية',
        subtitle: 'اختبار',
        emoji: '🎧',
        audioUrl: 'https://example.com/test.mp3',
      ),
    ],
  );
}
