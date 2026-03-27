// models/inheritance_models.dart

/// أصحاب الفروض والعصبات
enum HeirType {
  // الذكور
  husband, // الزوج
  father, // الأب
  grandfather, // الجد (أب الأب)
  son, // الابن
  sonOfSon, // ابن الابن
  brother, // الأخ الشقيق
  halfBrotherFather, // الأخ لأب
  halfBrotherMother, // الأخ لأم
  sonOfBrother, // ابن الأخ الشقيق
  sonOfHalfBrotherFather, // ابن الأخ لأب
  uncle, // العم الشقيق
  halfUncleFather, // العم لأب
  sonOfUncle, // ابن العم الشقيق
  sonOfHalfUncleFather, // ابن العم لأب

  // الإناث
  wife, // الزوجة
  mother, // الأم
  grandmother, // الجدة
  daughter, // البنت
  sonsDaughter, // بنت الابن
  sister, // الأخت الشقيقة
  halfSisterFather, // الأخت لأب
  halfSisterMother, // الأخت لأم
}

/// وحدة قياس الأراضي الزراعية في مصر والدول العربية
/// 1 فدان = 24 قيراط
/// 1 قيراط = 24 سهم
/// 1 فدان = 4200.83 متر مربع
/// 1 قيراط = 175.035 متر مربع

enum EstateType {
  money, // مال نقدي
  land, // أرض (فدادين وقراريط)
  both, // الاثنان معاً
}

enum LandUnit {
  feddan, // فدان
  qirat, // قيراط
  sahm, // سهم
  meter, // متر مربع
}

class LandEstate {
  int feddans; // عدد الفدادين
  int qirats; // عدد القراريط
  int sahms; // عدد الأسهم

  LandEstate({
    this.feddans = 0,
    this.qirats = 0,
    this.sahms = 0,
  });

  /// التحويل الكلي إلى قراريط
  double get totalInQirats {
    return (feddans * 24.0) + qirats + (sahms / 24.0);
  }

  /// التحويل الكلي إلى أسهم
  double get totalInSahms {
    return (feddans * 24.0 * 24.0) + (qirats * 24.0) + sahms;
  }

  /// التحويل الكلي إلى فدادين (كسر عشري)
  double get totalInFeddans {
    return feddans + (qirats / 24.0) + (sahms / 576.0);
  }

  /// التحويل إلى متر مربع
  double get totalInMeters {
    return totalInFeddans * 4200.83;
  }

  /// إنشاء من قراريط
  factory LandEstate.fromQirats(double totalQirats) {
    int feddans = totalQirats ~/ 24;
    double remainingQirats = totalQirats - (feddans * 24);
    int qirats = remainingQirats.floor();
    double remainingSahms = (remainingQirats - qirats) * 24;
    int sahms = remainingSahms.round();

    // تصحيح التقريب
    if (sahms >= 24) {
      qirats += 1;
      sahms = 0;
    }
    if (qirats >= 24) {
      feddans += 1;
      qirats = 0;
    }

    return LandEstate(feddans: feddans, qirats: qirats, sahms: sahms);
  }

  /// إنشاء من أسهم
  factory LandEstate.fromSahms(double totalSahms) {
    return LandEstate.fromQirats(totalSahms / 24.0);
  }

  /// تنسيق العرض
  String get formatted {
    List<String> parts = [];
    if (feddans > 0) parts.add('$feddans فدان');
    if (qirats > 0) parts.add('$qirats قيراط');
    if (sahms > 0) parts.add('$sahms سهم');
    return parts.isEmpty ? '0' : parts.join(' و ');
  }

  /// تنسيق مختصر
  String get shortFormatted {
    return '$feddans ف - $qirats ق - $sahms س';
  }

  @override
  String toString() => formatted;
}

class HeirLandShare {
  final String heirName;
  final LandEstate landShare;
  final double percentage;
  final int count;

  HeirLandShare({
    required this.heirName,
    required this.landShare,
    required this.percentage,
    this.count = 1,
  });

  LandEstate get perPersonShare {
    if (count <= 1) return landShare;
    return LandEstate.fromQirats(landShare.totalInQirats / count);
  }
}

/// نتيجة حساب المواريث الشاملة
class FullInheritanceResult {
  final InheritanceResult baseResult;
  final LandEstate? totalLand;
  final List<HeirLandShare>? landShares;
  final double? moneyAmount;
  final EstateType estateType;

  FullInheritanceResult({
    required this.baseResult,
    this.totalLand,
    this.landShares,
    this.moneyAmount,
    required this.estateType,
  });
}

class Heir {
  final HeirType type;
  final String nameAr;
  final int count;
  bool isBlocked; // محجوب
  String shareDescription; // وصف النصيب
  double shareNumerator; // البسط
  double shareDenominator; // المقام
  double actualShare; // النصيب الفعلي كنسبة

  Heir({
    required this.type,
    required this.nameAr,
    this.count = 1,
    this.isBlocked = false,
    this.shareDescription = '',
    this.shareNumerator = 0,
    this.shareDenominator = 1,
    this.actualShare = 0,
  });

  Heir copyWith({
    HeirType? type,
    String? nameAr,
    int? count,
    bool? isBlocked,
    String? shareDescription,
    double? shareNumerator,
    double? shareDenominator,
    double? actualShare,
  }) {
    return Heir(
      type: type ?? this.type,
      nameAr: nameAr ?? this.nameAr,
      count: count ?? this.count,
      isBlocked: isBlocked ?? this.isBlocked,
      shareDescription: shareDescription ?? this.shareDescription,
      shareNumerator: shareNumerator ?? this.shareNumerator,
      shareDenominator: shareDenominator ?? this.shareDenominator,
      actualShare: actualShare ?? this.actualShare,
    );
  }
}

class InheritanceResult {
  final List<Heir> heirs;
  final double totalShares;
  final int baseDenominator; // أصل المسألة
  final String caseType; // عادية / عول / رد
  final double estate; // قيمة التركة
  final String explanation;

  InheritanceResult({
    required this.heirs,
    required this.totalShares,
    required this.baseDenominator,
    required this.caseType,
    required this.estate,
    required this.explanation,
  });
}

class SelectedHeir {
  final HeirType type;
  final String nameAr;
  int count;
  bool isSelected;

  SelectedHeir({
    required this.type,
    required this.nameAr,
    this.count = 1,
    this.isSelected = false,
  });
}