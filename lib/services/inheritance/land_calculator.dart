// services/land_calculator.dart

import '../../models/inheritance_models.dart';

class LandCalculator {
  /// حساب أنصبة الأراضي
  static List<HeirLandShare> calculateLandShares(
      LandEstate totalLand,
      InheritanceResult result,
      ) {
    List<HeirLandShare> shares = [];
    double totalQirats = totalLand.totalInQirats;

    List<Heir> activeHeirs =
    result.heirs.where((h) => !h.isBlocked && h.actualShare > 0).toList();

    for (var heir in activeHeirs) {
      double heirQirats = totalQirats * heir.actualShare;
      LandEstate heirLand = LandEstate.fromQirats(heirQirats);

      shares.add(HeirLandShare(
        heirName: heir.nameAr,
        landShare: heirLand,
        percentage: heir.actualShare * 100,
        count: heir.count,
      ));
    }

    return shares;
  }

  /// تحويل فدادين إلى قراريط
  static double feddansToQirats(double feddans) => feddans * 24;

  /// تحويل قراريط إلى فدادين
  static double qiratsToFeddans(double qirats) => qirats / 24;

  /// تحويل قراريط إلى أسهم
  static double qiratsToSahms(double qirats) => qirats * 24;

  /// تحويل أسهم إلى قراريط
  static double sahmsToQirats(double sahms) => sahms / 24;

  /// تحويل فدادين إلى متر مربع
  static double feddansToMeters(double feddans) => feddans * 4200.83;

  /// تحويل متر مربع إلى فدادين
  static double metersToFeddans(double meters) => meters / 4200.83;

  /// تحويل قراريط إلى متر مربع
  static double qiratsToMeters(double qirats) => qirats * 175.035;

  /// التحقق من صحة المدخلات
  static String? validateLandInput(int feddans, int qirats, int sahms) {
    if (feddans < 0) return 'عدد الفدادين لا يمكن أن يكون سالباً';
    if (qirats < 0 || qirats > 23) return 'القراريط يجب أن تكون بين 0 و 23';
    if (sahms < 0 || sahms > 23) return 'الأسهم يجب أن تكون بين 0 و 23';
    if (feddans == 0 && qirats == 0 && sahms == 0) {
      return 'يجب إدخال مساحة الأرض';
    }
    return null;
  }
}