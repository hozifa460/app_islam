// services/inheritance_calculator.dart

import '../../models/inheritance_models.dart';

/// محرك حساب المواريث الإسلامية
/// المصادر:
/// - القرآن الكريم (سورة النساء: الآيات 11، 12، 176)
/// - السنة النبوية الشريفة
/// - إجماع العلماء
/// - كتاب "الرحبية" في علم الفرائض
/// - كتاب "السراجية" في المواريث
class InheritanceCalculator {
  List<Heir> heirs = [];
  double estate = 0;

  // ============ الحجب ============
  /// تطبيق قواعد الحجب
  void applyBlocking() {
    bool has(HeirType t) =>
        heirs.any((h) => h.type == t && h.count > 0);

    int countOf(HeirType t) {
      final h = heirs.where((h) => h.type == t);
      return h.isEmpty ? 0 : h.first.count;
    }

    bool hasSon = has(HeirType.son);
    bool hasSonOfSon = has(HeirType.sonOfSon);
    bool hasFather = has(HeirType.father);
    bool hasGrandfather = has(HeirType.grandfather);
    bool hasBrother = has(HeirType.brother);
    bool hasHalfBrotherFather = has(HeirType.halfBrotherFather);
    bool hasDaughter = has(HeirType.daughter);
    bool hasSister = has(HeirType.sister);

    // فرع ذكر وارث
    bool hasMaleDescendant = hasSon || hasSonOfSon;

    for (var heir in heirs) {
      switch (heir.type) {

      // --------- حجب الجد ---------
      // الجد يُحجب بالأب
        case HeirType.grandfather:
          if (hasFather) heir.isBlocked = true;
          break;

      // --------- حجب الجدة ---------
      // الجدة تُحجب بالأم، وجدة الأب تُحجب بالأب
        case HeirType.grandmother:
          if (has(HeirType.mother)) heir.isBlocked = true;
          break;

      // --------- حجب ابن الابن ---------
      // ابن الابن يُحجب بالابن
        case HeirType.sonOfSon:
          if (hasSon) heir.isBlocked = true;
          break;

      // --------- حجب بنت الابن ---------
      // بنت الابن تُحجب بالابن
      // بنت الابن تُحجب ببنتين فأكثر إلا إذا وُجد ابن ابن يعصبها
        case HeirType.sonsDaughter:
          if (hasSon) {
            heir.isBlocked = true;
          } else if (countOf(HeirType.daughter) >= 2 && !hasSonOfSon) {
            heir.isBlocked = true;
          }
          break;

      // --------- حجب الأخ الشقيق ---------
      // يُحجب بالابن وابن الابن والأب
        case HeirType.brother:
          if (hasSon || hasSonOfSon || hasFather) {
            heir.isBlocked = true;
          }
          break;

      // --------- حجب الأخت الشقيقة ---------
      // تُحجب بالابن وابن الابن والأب
        case HeirType.sister:
          if (hasSon || hasSonOfSon || hasFather) {
            heir.isBlocked = true;
          }
          break;

      // --------- حجب الأخ لأب ---------
      // يُحجب بالابن وابن الابن والأب والأخ الشقيق
      // وبالأخت الشقيقة إذا صارت عصبة مع الغير
        case HeirType.halfBrotherFather:
          if (hasSon || hasSonOfSon || hasFather || hasBrother) {
            heir.isBlocked = true;
          }
          // الأخت الشقيقة عصبة مع البنات تحجب الأخ لأب
          if (hasSister && (hasDaughter || hasSonOfSon)) {
            heir.isBlocked = true;
          }
          break;

      // --------- حجب الأخت لأب ---------
      // تُحجب بالابن وابن الابن والأب والأخ الشقيق
      // تُحجب بأختين شقيقتين فأكثر إلا بوجود أخ لأب يعصبها
        case HeirType.halfSisterFather:
          if (hasSon || hasSonOfSon || hasFather || hasBrother) {
            heir.isBlocked = true;
          }
          if (countOf(HeirType.sister) >= 2 && !hasHalfBrotherFather) {
            heir.isBlocked = true;
          }
          // الأخت الشقيقة عصبة مع البنات تحجب الأخت لأب
          if (hasSister && (hasDaughter || has(HeirType.sonsDaughter))) {
            heir.isBlocked = true;
          }
          break;

      // --------- حجب الأخ لأم والأخت لأم ---------
      // يُحجبان بالفرع الوارث (ابن، بنت، ابن ابن، بنت ابن)
      // ويُحجبان بالأب والجد
        case HeirType.halfBrotherMother:
        case HeirType.halfSisterMother:
          if (hasSon || hasSonOfSon || hasDaughter ||
              has(HeirType.sonsDaughter) || hasFather || hasGrandfather) {
            heir.isBlocked = true;
          }
          break;

      // --------- حجب ابن الأخ الشقيق ---------
        case HeirType.sonOfBrother:
          if (hasSon || hasSonOfSon || hasFather || hasGrandfather ||
              hasBrother || hasHalfBrotherFather) {
            heir.isBlocked = true;
          }
          break;

      // --------- حجب ابن الأخ لأب ---------
        case HeirType.sonOfHalfBrotherFather:
          if (hasSon || hasSonOfSon || hasFather || hasGrandfather ||
              hasBrother || hasHalfBrotherFather ||
              has(HeirType.sonOfBrother)) {
            heir.isBlocked = true;
          }
          break;

      // --------- حجب العم الشقيق ---------
        case HeirType.uncle:
          if (hasSon || hasSonOfSon || hasFather || hasGrandfather ||
              hasBrother || hasHalfBrotherFather ||
              has(HeirType.sonOfBrother) ||
              has(HeirType.sonOfHalfBrotherFather)) {
            heir.isBlocked = true;
          }
          break;

      // --------- حجب العم لأب ---------
        case HeirType.halfUncleFather:
          if (hasSon || hasSonOfSon || hasFather || hasGrandfather ||
              hasBrother || hasHalfBrotherFather ||
              has(HeirType.sonOfBrother) ||
              has(HeirType.sonOfHalfBrotherFather) ||
              has(HeirType.uncle)) {
            heir.isBlocked = true;
          }
          break;

      // --------- حجب ابن العم الشقيق ---------
        case HeirType.sonOfUncle:
          if (hasSon || hasSonOfSon || hasFather || hasGrandfather ||
              hasBrother || hasHalfBrotherFather ||
              has(HeirType.sonOfBrother) ||
              has(HeirType.sonOfHalfBrotherFather) ||
              has(HeirType.uncle) || has(HeirType.halfUncleFather)) {
            heir.isBlocked = true;
          }
          break;

      // --------- حجب ابن العم لأب ---------
        case HeirType.sonOfHalfUncleFather:
          if (hasSon || hasSonOfSon || hasFather || hasGrandfather ||
              hasBrother || hasHalfBrotherFather ||
              has(HeirType.sonOfBrother) ||
              has(HeirType.sonOfHalfBrotherFather) ||
              has(HeirType.uncle) || has(HeirType.halfUncleFather) ||
              has(HeirType.sonOfUncle)) {
            heir.isBlocked = true;
          }
          break;

        default:
          break;
      }
    }
  }

  // ============ حساب الأنصبة ============
  InheritanceResult calculate(List<Heir> inputHeirs, double estateAmount) {
    estate = estateAmount;
    heirs = inputHeirs.map((h) => h.copyWith()).toList();

    // تطبيق الحجب
    applyBlocking();

    // إزالة المحجوبين من الحساب
    List<Heir> activeHeirs = heirs.where((h) => !h.isBlocked).toList();

    // تحديد الأنصبة
    _assignShares(activeHeirs);

    // حساب أصل المسألة
    int baseDenom = _calculateBaseDenominator(activeHeirs);

    // حساب مجموع السهام
    double totalSharesSum = 0;
    for (var h in activeHeirs) {
      if (h.shareDenominator > 0) {
        totalSharesSum += (h.shareNumerator / h.shareDenominator);
      }
    }

    // تحديد نوع المسألة
    String caseType = 'عادية';
    String explanation = '';

    if (totalSharesSum > 1.0001) {
      caseType = 'عول';
      explanation = 'المسألة فيها عول: مجموع الفروض أكبر من الواحد الصحيح، '
          'فيتم تقسيم التركة بنسبة كل فرض إلى مجموع الفروض.';
      // العول: توزيع بالنسبة
      for (var h in activeHeirs) {
        h.actualShare = (h.shareNumerator / h.shareDenominator) / totalSharesSum;
      }
    } else if (totalSharesSum < 0.9999 && !_hasAsaba(activeHeirs)) {
      caseType = 'رد';
      explanation = 'المسألة فيها رد: مجموع الفروض أقل من الواحد الصحيح '
          'ولا يوجد عاصب، فيُرد الباقي على أصحاب الفروض عدا الزوجين.';
      _applyRadd(activeHeirs, totalSharesSum);
    } else {
      // عادية أو فيها عاصب
      explanation = 'مسألة عادية';
      for (var h in activeHeirs) {
        if (h.shareDenominator > 0) {
          h.actualShare = h.shareNumerator / h.shareDenominator;
        }
      }
      // حساب الباقي للعصبات
      double assignedShares = 0;
      for (var h in activeHeirs) {
        if (h.shareDescription != 'عصبة' &&
            h.shareDescription != 'عصبة بالغير' &&
            h.shareDescription != 'عصبة مع الغير') {
          assignedShares += h.actualShare;
        }
      }
      double remainder = 1.0 - assignedShares;
      if (remainder > 0.0001) {
        _distributeAsaba(activeHeirs, remainder);
      }
    }

    return InheritanceResult(
      heirs: heirs,
      totalShares: totalSharesSum,
      baseDenominator: baseDenom,
      caseType: caseType,
      estate: estate,
      explanation: explanation,
    );
  }

  // ============ تحديد الأنصبة لكل وارث ============
  void _assignShares(List<Heir> activeHeirs) {
    bool has(HeirType t) =>
        activeHeirs.any((h) => h.type == t && !h.isBlocked);

    int countOf(HeirType t) {
      final h = activeHeirs.where((h) => h.type == t && !h.isBlocked);
      return h.isEmpty ? 0 : h.first.count;
    }

    bool hasMaleDescendant = has(HeirType.son) || has(HeirType.sonOfSon);
    bool hasFemaleDescendant = has(HeirType.daughter) ||
        has(HeirType.sonsDaughter);
    bool hasDescendant = hasMaleDescendant || hasFemaleDescendant;

    // عدد الإخوة لأم
    int maternalSiblings = countOf(HeirType.halfBrotherMother) +
        countOf(HeirType.halfSisterMother);

    for (var heir in activeHeirs) {
      if (heir.isBlocked) continue;

      switch (heir.type) {

      // ========== الزوج ==========
      // النصف: إذا لم يكن فرع وارث
      // الربع: إذا كان فرع وارث
      // سورة النساء آية 12
        case HeirType.husband:
          if (hasDescendant) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 4;
            heir.shareDescription = 'الربع (وجود فرع وارث)';
          } else {
            heir.shareNumerator = 1;
            heir.shareDenominator = 2;
            heir.shareDescription = 'النصف (عدم وجود فرع وارث)';
          }
          break;

      // ========== الزوجة ==========
      // الربع: إذا لم يكن فرع وارث
      // الثمن: إذا كان فرع وارث
      // سورة النساء آية 12
        case HeirType.wife:
          if (hasDescendant) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 8;
            heir.shareDescription = 'الثمن (وجود فرع وارث)';
          } else {
            heir.shareNumerator = 1;
            heir.shareDenominator = 4;
            heir.shareDescription = 'الربع (عدم وجود فرع وارث)';
          }
          break;

      // ========== الأب ==========
      // السدس + عصبة: مع الابن أو ابن الابن
      // السدس: مع البنت أو بنت الابن (والباقي إن وُجد)
      // عصبة: عند عدم وجود فرع وارث
      // سورة النساء آية 11
        case HeirType.father:
          if (hasMaleDescendant) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 6;
            heir.shareDescription = 'السدس فرضاً (وجود فرع ذكر وارث)';
          } else if (hasFemaleDescendant) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 6;
            heir.shareDescription = 'السدس فرضاً + الباقي تعصيباً';
          } else {
            heir.shareDescription = 'عصبة';
            heir.shareNumerator = 0;
            heir.shareDenominator = 1;
          }
          break;

      // ========== الأم ==========
      // السدس: مع فرع وارث أو جمع من الإخوة (2 فأكثر)
      // الثلث: عند عدم وجود فرع وارث ولا جمع من الإخوة
      // ثلث الباقي: في العمريتين (زوج/زوجة + أم + أب)
      // سورة النساء آية 11
        case HeirType.mother:
          bool hasMultipleSiblings = _totalSiblingsCount(activeHeirs) >= 2;

          if (hasDescendant || hasMultipleSiblings) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 6;
            heir.shareDescription = hasDescendant
                ? 'السدس (وجود فرع وارث)'
                : 'السدس (وجود جمع من الإخوة)';
          } else {
            // التحقق من العمريتين
            bool isGharawiyyah = _isGharawiyyah(activeHeirs);
            if (isGharawiyyah) {
              // العمريتان: الأم تأخذ ثلث الباقي
              if (has(HeirType.husband)) {
                // زوج + أم + أب: الزوج النصف، الأم ثلث الباقي = 1/6
                heir.shareNumerator = 1;
                heir.shareDenominator = 3;
                heir.shareDescription = 'ثلث الباقي (المسألة العمرية)';
                // سيتم تعديلها في منطق خاص
              } else {
                // زوجة + أم + أب: الزوجة الربع، الأم ثلث الباقي = 1/4
                heir.shareNumerator = 1;
                heir.shareDenominator = 3;
                heir.shareDescription = 'ثلث الباقي (المسألة العمرية)';
              }
            } else {
              heir.shareNumerator = 1;
              heir.shareDenominator = 3;
              heir.shareDescription = 'الثلث (عدم وجود فرع وارث ولا جمع من الإخوة)';
            }
          }
          break;

      // ========== الجدة ==========
      // السدس
        case HeirType.grandmother:
          heir.shareNumerator = 1;
          heir.shareDenominator = 6;
          heir.shareDescription = 'السدس';
          break;

      // ========== الجد ==========
      // مثل الأب عند عدم وجود الأب (مع خلاف في مسائل الإخوة)
        case HeirType.grandfather:
          if (hasMaleDescendant) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 6;
            heir.shareDescription = 'السدس فرضاً (وجود فرع ذكر وارث)';
          } else if (hasFemaleDescendant) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 6;
            heir.shareDescription = 'السدس فرضاً + الباقي تعصيباً';
          } else {
            heir.shareDescription = 'عصبة';
            heir.shareNumerator = 0;
            heir.shareDenominator = 1;
          }
          break;

      // ========== الابن ==========
      // عصبة بالنفس - يأخذ الباقي
      // للذكر مثل حظ الأنثيين مع البنت
        case HeirType.son:
          heir.shareDescription = 'عصبة';
          heir.shareNumerator = 0;
          heir.shareDenominator = 1;
          break;

      // ========== ابن الابن ==========
      // عصبة بالنفس
        case HeirType.sonOfSon:
          heir.shareDescription = 'عصبة';
          heir.shareNumerator = 0;
          heir.shareDenominator = 1;
          break;

      // ========== البنت ==========
      // النصف: إذا كانت واحدة ولا يوجد ابن
      // الثلثان: إذا كانتا اثنتين فأكثر ولا يوجد ابن
      // عصبة بالغير: مع الابن (للذكر مثل حظ الأنثيين)
      // سورة النساء آية 11
        case HeirType.daughter:
          if (has(HeirType.son)) {
            heir.shareDescription = 'عصبة بالغير';
            heir.shareNumerator = 0;
            heir.shareDenominator = 1;
          } else if (heir.count == 1) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 2;
            heir.shareDescription = 'النصف (انفرادها وعدم وجود ابن)';
          } else {
            heir.shareNumerator = 2;
            heir.shareDenominator = 3;
            heir.shareDescription = 'الثلثان (تعددهن وعدم وجود ابن)';
          }
          break;

      // ========== بنت الابن ==========
      // النصف: واحدة ولا بنت ولا ابن ابن
      // الثلثان: اثنتان فأكثر ولا بنت
      // السدس: تكملة الثلثين مع بنت واحدة
      // عصبة بالغير: مع ابن الابن
        case HeirType.sonsDaughter:
          if (has(HeirType.sonOfSon)) {
            heir.shareDescription = 'عصبة بالغير';
            heir.shareNumerator = 0;
            heir.shareDenominator = 1;
          } else if (countOf(HeirType.daughter) == 1) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 6;
            heir.shareDescription = 'السدس تكملة الثلثين';
          } else if (!has(HeirType.daughter) && heir.count == 1) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 2;
            heir.shareDescription = 'النصف';
          } else if (!has(HeirType.daughter) && heir.count >= 2) {
            heir.shareNumerator = 2;
            heir.shareDenominator = 3;
            heir.shareDescription = 'الثلثان';
          }
          break;

      // ========== الأخ الشقيق ==========
      // عصبة بالنفس
        case HeirType.brother:
          heir.shareDescription = 'عصبة';
          heir.shareNumerator = 0;
          heir.shareDenominator = 1;
          break;

      // ========== الأخت الشقيقة ==========
      // النصف: واحدة ولا أخ شقيق ولا فرع وارث
      // الثلثان: اثنتان فأكثر
      // عصبة بالغير: مع الأخ الشقيق
      // عصبة مع الغير: مع البنت أو بنت الابن
      // سورة النساء آية 176
        case HeirType.sister:
          if (has(HeirType.brother)) {
            heir.shareDescription = 'عصبة بالغير';
            heir.shareNumerator = 0;
            heir.shareDenominator = 1;
          } else if (hasFemaleDescendant) {
            heir.shareDescription = 'عصبة مع الغير';
            heir.shareNumerator = 0;
            heir.shareDenominator = 1;
          } else if (heir.count == 1) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 2;
            heir.shareDescription = 'النصف';
          } else {
            heir.shareNumerator = 2;
            heir.shareDenominator = 3;
            heir.shareDescription = 'الثلثان';
          }
          break;

      // ========== الأخت لأب ==========
      // مثل الشقيقة عند عدم وجود الأشقاء
      // السدس: تكملة الثلثين مع أخت شقيقة واحدة
        case HeirType.halfSisterFather:
          if (has(HeirType.halfBrotherFather)) {
            heir.shareDescription = 'عصبة بالغير';
            heir.shareNumerator = 0;
            heir.shareDenominator = 1;
          } else if (countOf(HeirType.sister) == 1 && !has(HeirType.brother)) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 6;
            heir.shareDescription = 'السدس تكملة الثلثين';
          } else if (!has(HeirType.sister) && !has(HeirType.brother)) {
            if (hasFemaleDescendant) {
              heir.shareDescription = 'عصبة مع الغير';
              heir.shareNumerator = 0;
              heir.shareDenominator = 1;
            } else if (heir.count == 1) {
              heir.shareNumerator = 1;
              heir.shareDenominator = 2;
              heir.shareDescription = 'النصف';
            } else {
              heir.shareNumerator = 2;
              heir.shareDenominator = 3;
              heir.shareDescription = 'الثلثان';
            }
          }
          break;

      // ========== الأخ لأم ==========
      // السدس: واحد
      // الثلث: اثنان فأكثر (يقتسمونه بالتساوي ذكوراً وإناثاً)
      // سورة النساء آية 12
        case HeirType.halfBrotherMother:
          if (maternalSiblings == 1) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 6;
            heir.shareDescription = 'السدس';
          } else {
            // يشتركون في الثلث
            heir.shareNumerator = 1;
            heir.shareDenominator = 3;
            heir.shareDescription = 'الثلث (يشتركون فيه)';
          }
          break;

      // ========== الأخت لأم ==========
        case HeirType.halfSisterMother:
          if (maternalSiblings == 1) {
            heir.shareNumerator = 1;
            heir.shareDenominator = 6;
            heir.shareDescription = 'السدس';
          } else {
            heir.shareNumerator = 1;
            heir.shareDenominator = 3;
            heir.shareDescription = 'الثلث (يشتركون فيه)';
          }
          break;

      // ========== ابن الأخ الشقيق ==========
        case HeirType.sonOfBrother:
          heir.shareDescription = 'عصبة';
          heir.shareNumerator = 0;
          heir.shareDenominator = 1;
          break;

      // ========== ابن الأخ لأب ==========
        case HeirType.sonOfHalfBrotherFather:
          heir.shareDescription = 'عصبة';
          heir.shareNumerator = 0;
          heir.shareDenominator = 1;
          break;

      // ========== العم الشقيق ==========
        case HeirType.uncle:
          heir.shareDescription = 'عصبة';
          heir.shareNumerator = 0;
          heir.shareDenominator = 1;
          break;

      // ========== العم لأب ==========
        case HeirType.halfUncleFather:
          heir.shareDescription = 'عصبة';
          heir.shareNumerator = 0;
          heir.shareDenominator = 1;
          break;

      // ========== ابن العم الشقيق ==========
        case HeirType.sonOfUncle:
          heir.shareDescription = 'عصبة';
          heir.shareNumerator = 0;
          heir.shareDenominator = 1;
          break;

      // ========== ابن العم لأب ==========
        case HeirType.sonOfHalfUncleFather:
          heir.shareDescription = 'عصبة';
          heir.shareNumerator = 0;
          heir.shareDenominator = 1;
          break;
        case HeirType.halfBrotherFather:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    }
  }

  // ============ توزيع العصبة ============
  void _distributeAsaba(List<Heir> activeHeirs, double remainder) {
    // ترتيب العصبات حسب الأولوية
    List<HeirType> asabaOrder = [
      HeirType.son,
      HeirType.sonOfSon,
      HeirType.father,
      HeirType.grandfather,
      HeirType.brother,
      HeirType.sister, // عصبة مع الغير
      HeirType.halfBrotherFather,
      HeirType.halfSisterFather, // عصبة مع الغير
      HeirType.sonOfBrother,
      HeirType.sonOfHalfBrotherFather,
      HeirType.uncle,
      HeirType.halfUncleFather,
      HeirType.sonOfUncle,
      HeirType.sonOfHalfUncleFather,
    ];

    for (var asabaType in asabaOrder) {
      var asabaHeirs = activeHeirs.where(
              (h) => h.type == asabaType && !h.isBlocked &&
              (h.shareDescription.contains('عصبة') ||
                  h.shareDescription == 'عصبة')).toList();

      if (asabaHeirs.isEmpty) continue;

      // الابن مع البنت: للذكر مثل حظ الأنثيين
      if (asabaType == HeirType.son) {
        var daughters = activeHeirs.where(
                (h) => h.type == HeirType.daughter && !h.isBlocked).toList();

        if (daughters.isNotEmpty) {
          int totalParts = 0;
          for (var h in asabaHeirs) {
            totalParts += h.count * 2; // الذكر بحصتين
          }
          for (var h in daughters) {
            totalParts += h.count; // الأنثى بحصة
          }

          for (var h in asabaHeirs) {
            h.actualShare = (h.count * 2 * remainder) / totalParts;
            h.shareDescription = 'عصبة بالنفس (للذكر مثل حظ الأنثيين)';
          }
          for (var h in daughters) {
            h.actualShare = (h.count * remainder) / totalParts;
            h.shareDescription = 'عصبة بالغير (للذكر مثل حظ الأنثيين)';
          }
          return;
        }
      }

      // ابن الابن مع بنت الابن
      if (asabaType == HeirType.sonOfSon) {
        var sonsDaughters = activeHeirs.where(
                (h) => h.type == HeirType.sonsDaughter && !h.isBlocked &&
                h.shareDescription.contains('عصبة')).toList();

        if (sonsDaughters.isNotEmpty) {
          int totalParts = 0;
          for (var h in asabaHeirs) {
            totalParts += h.count * 2;
          }
          for (var h in sonsDaughters) {
            totalParts += h.count;
          }

          for (var h in asabaHeirs) {
            h.actualShare = (h.count * 2 * remainder) / totalParts;
          }
          for (var h in sonsDaughters) {
            h.actualShare = (h.count * remainder) / totalParts;
          }
          return;
        }
      }

      // الأخ الشقيق مع الأخت الشقيقة
      if (asabaType == HeirType.brother) {
        var sisters = activeHeirs.where(
                (h) => h.type == HeirType.sister && !h.isBlocked &&
                h.shareDescription.contains('عصبة بالغير')).toList();

        if (sisters.isNotEmpty) {
          int totalParts = 0;
          for (var h in asabaHeirs) {
            totalParts += h.count * 2;
          }
          for (var h in sisters) {
            totalParts += h.count;
          }

          for (var h in asabaHeirs) {
            h.actualShare = (h.count * 2 * remainder) / totalParts;
          }
          for (var h in sisters) {
            h.actualShare = (h.count * remainder) / totalParts;
          }
          return;
        }
      }

      // الأخ لأب مع الأخت لأب
      if (asabaType == HeirType.halfBrotherFather) {
        var halfSisters = activeHeirs.where(
                (h) => h.type == HeirType.halfSisterFather && !h.isBlocked &&
                h.shareDescription.contains('عصبة بالغير')).toList();

        if (halfSisters.isNotEmpty) {
          int totalParts = 0;
          for (var h in asabaHeirs) {
            totalParts += h.count * 2;
          }
          for (var h in halfSisters) {
            totalParts += h.count;
          }

          for (var h in asabaHeirs) {
            h.actualShare = (h.count * 2 * remainder) / totalParts;
          }
          for (var h in halfSisters) {
            h.actualShare = (h.count * remainder) / totalParts;
          }
          return;
        }
      }

      // عصبة مع الغير (الأخت مع البنات)
      if ((asabaType == HeirType.sister || asabaType == HeirType.halfSisterFather)
          && asabaHeirs.first.shareDescription.contains('عصبة مع الغير')) {
        for (var h in asabaHeirs) {
          h.actualShare = remainder / h.count;
        }
        return;
      }

      // الأب أو الجد مع فرع أنثوي (السدس + الباقي)
      if ((asabaType == HeirType.father || asabaType == HeirType.grandfather)
          && asabaHeirs.first.shareDescription.contains('+ الباقي')) {
        for (var h in asabaHeirs) {
          h.actualShare = (h.shareNumerator / h.shareDenominator) + remainder;
          h.shareDescription = 'السدس + الباقي تعصيباً';
        }
        return;
      }

      // عصبة عادية
      int totalCount = 0;
      for (var h in asabaHeirs) {
        totalCount += h.count;
      }

      for (var h in asabaHeirs) {
        h.actualShare = remainder;
        h.shareDescription = 'عصبة (الباقي)';
      }
      return;
    }
  }

  // ============ الرد ============
  void _applyRadd(List<Heir> activeHeirs, double totalShares) {
    // الرد على أصحاب الفروض عدا الزوجين
    List<Heir> raddHeirs = activeHeirs.where(
            (h) => h.type != HeirType.husband && h.type != HeirType.wife &&
            !h.isBlocked && h.shareNumerator > 0).toList();

    // حصة الزوج/الزوجة تبقى كما هي
    double spouseShare = 0;
    for (var h in activeHeirs) {
      if ((h.type == HeirType.husband || h.type == HeirType.wife) &&
          !h.isBlocked) {
        h.actualShare = h.shareNumerator / h.shareDenominator;
        spouseShare += h.actualShare;
      }
    }

    double remainingAfterSpouse = 1.0 - spouseShare;
    double raddTotalFractions = 0;
    for (var h in raddHeirs) {
      raddTotalFractions += (h.shareNumerator / h.shareDenominator);
    }

    if (raddTotalFractions > 0) {
      for (var h in raddHeirs) {
        double originalFraction = h.shareNumerator / h.shareDenominator;
        h.actualShare = (originalFraction / raddTotalFractions) *
            remainingAfterSpouse;
        h.shareDescription += ' + رد';
      }
    }
  }

  // ============ مساعدات ============

  bool _hasAsaba(List<Heir> activeHeirs) {
    return activeHeirs.any((h) => !h.isBlocked &&
        (h.shareDescription.contains('عصبة') ||
            h.shareDescription == 'عصبة'));
  }

  int _totalSiblingsCount(List<Heir> activeHeirs) {
    int count = 0;
    for (var h in heirs) { // نحسب من كل الورثة (حتى المحجوبين بحجب نقصان)
      if (h.type == HeirType.brother ||
          h.type == HeirType.sister ||
          h.type == HeirType.halfBrotherFather ||
          h.type == HeirType.halfSisterFather ||
          h.type == HeirType.halfBrotherMother ||
          h.type == HeirType.halfSisterMother) {
        count += h.count;
      }
    }
    return count;
  }

  bool _isGharawiyyah(List<Heir> activeHeirs) {
    // العمريتان: أحد الزوجين + أم + أب فقط (لا فرع ولا جمع إخوة)
    bool hasSpouse = activeHeirs.any((h) =>
    (h.type == HeirType.husband || h.type == HeirType.wife) &&
        !h.isBlocked);
    bool hasMother = activeHeirs.any((h) =>
    h.type == HeirType.mother && !h.isBlocked);
    bool hasFather = activeHeirs.any((h) =>
    h.type == HeirType.father && !h.isBlocked);

    if (!hasSpouse || !hasMother || !hasFather) return false;

    // لا يوجد ورثة آخرون غير الزوج/الزوجة والأم والأب
    int otherHeirs = activeHeirs.where((h) =>
    !h.isBlocked &&
        h.type != HeirType.husband &&
        h.type != HeirType.wife &&
        h.type != HeirType.mother &&
        h.type != HeirType.father).length;

    return otherHeirs == 0;
  }

  int _calculateBaseDenominator(List<Heir> activeHeirs) {
    Set<int> denominators = {};
    for (var h in activeHeirs) {
      if (!h.isBlocked && h.shareDenominator > 1) {
        denominators.add(h.shareDenominator.toInt());
      }
    }
    if (denominators.isEmpty) return 1;
    int result = denominators.first;
    for (var d in denominators.skip(1)) {
      result = _lcm(result, d);
    }
    return result;
  }

  int _lcm(int a, int b) => (a * b) ~/ _gcd(a, b);

  int _gcd(int a, int b) {
    while (b != 0) {
      int temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }
}