import 'package:flutter/material.dart';

class MiracleHelpers {
  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'علم الفلك':           return Icons.stars_rounded;
      case 'علم الأجنة':          return Icons.child_care_rounded;
      case 'علم البحار':          return Icons.water_rounded;
      case 'علم الجيولوجيا':      return Icons.terrain_rounded;
      case 'علم الفيزياء':        return Icons.science_rounded;
      case 'علم المياه':          return Icons.water_drop_rounded;
      case 'علم النبات':          return Icons.local_florist_rounded;
      case 'علم الأحياء':         return Icons.biotech_rounded;
      case 'علم الأحياء الدقيقة': return Icons.coronavirus_rounded;
      case 'علم الطب':            return Icons.medical_services_rounded;
      case 'علم الأعصاب':         return Icons.psychology_rounded;
      case 'علم الجغرافيا':       return Icons.public_rounded;
      case 'علم النفس':           return Icons.self_improvement_rounded;
      case 'علم الحشرات':         return Icons.bug_report_rounded;
      case 'علم التغذية':         return Icons.restaurant_rounded;
      case 'علم الصحة العامة':    return Icons.health_and_safety_rounded;
      case 'إعجاز غيبي':         return Icons.visibility_rounded;
      case 'إعجاز تاريخي':       return Icons.history_edu_rounded;
      case 'معجزات نبوية':        return Icons.auto_awesome_rounded;
      case 'علم الرياضيات':       return Icons.calculate_rounded;
      case 'علم الكيمياء':        return Icons.science_rounded;
      default:                    return Icons.lightbulb_rounded;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case 'علم الفلك':           return const Color(0xFF64B5F6);
      case 'علم الأجنة':          return const Color(0xFFF48FB1);
      case 'علم البحار':          return const Color(0xFF4DD0E1);
      case 'علم الجيولوجيا':      return const Color(0xFFBCAAA4);
      case 'علم الفيزياء':        return const Color(0xFFB39DDB);
      case 'علم المياه':          return const Color(0xFF4DB6AC);
      case 'علم النبات':          return const Color(0xFF81C784);
      case 'علم الأحياء':         return const Color(0xFFA5D6A7);
      case 'علم الأحياء الدقيقة': return const Color(0xFFEF9A9A);
      case 'علم الطب':            return const Color(0xFFE57373);
      case 'علم الأعصاب':         return const Color(0xFFCE93D8);
      case 'علم الجغرافيا':       return const Color(0xFF80CBC4);
      case 'علم النفس':           return const Color(0xFFBCAAA4);
      case 'علم الحشرات':         return const Color(0xFFFF8A65);
      case 'علم التغذية':         return const Color(0xFFFFCC02);
      case 'علم الصحة العامة':    return const Color(0xFF81D4FA);
      case 'إعجاز غيبي':         return const Color(0xFFFFD54F);
      case 'إعجاز تاريخي':       return const Color(0xFFA1887F);
      case 'معجزات نبوية':        return const Color(0xFFFFD740);
      case 'علم الرياضيات':       return const Color(0xFF80DEEA);
      case 'علم الكيمياء':        return const Color(0xFFF48FB1);
      default:                    return const Color(0xFF64B5F6);
    }
  }

  static String getCategoryEmoji(String category) {
    switch (category) {
      case 'علم الفلك':           return '🌌';
      case 'علم الأجنة':          return '🧬';
      case 'علم البحار':          return '🌊';
      case 'علم الجيولوجيا':      return '🏔️';
      case 'علم الفيزياء':        return '⚛️';
      case 'علم المياه':          return '💧';
      case 'علم النبات':          return '🌿';
      case 'علم الأحياء':         return '🔬';
      case 'علم الأحياء الدقيقة': return '🦠';
      case 'علم الطب':            return '🏥';
      case 'علم الأعصاب':         return '🧠';
      case 'علم الجغرافيا':       return '🌍';
      case 'علم النفس':           return '🧘';
      case 'علم الحشرات':         return '🐝';
      case 'علم التغذية':         return '🥗';
      case 'علم الصحة العامة':    return '❤️';
      case 'إعجاز غيبي':         return '✨';
      case 'إعجاز تاريخي':       return '📜';
      case 'معجزات نبوية':        return '🌙';
      case 'علم الرياضيات':       return '📐';
      case 'علم الكيمياء':        return '⚗️';
      default:                    return '💡';
    }
  }

  static String getCategoryEnglish(String category) {
    switch (category) {
      case 'علم الفلك':           return 'Astronomy';
      case 'علم الأجنة':          return 'Embryology';
      case 'علم البحار':          return 'Oceanology';
      case 'علم الجيولوجيا':      return 'Geology';
      case 'علم الفيزياء':        return 'Physics';
      case 'علم المياه':          return 'Hydrology';
      case 'علم النبات':          return 'Botany';
      case 'علم الأحياء':         return 'Biology';
      case 'علم الأحياء الدقيقة': return 'Microbiology';
      case 'علم الطب':            return 'Medicine';
      case 'علم الأعصاب':         return 'Neuroscience';
      case 'علم الجغرافيا':       return 'Geography';
      case 'علم النفس':           return 'Psychology';
      case 'علم الحشرات':         return 'Entomology';
      case 'علم التغذية':         return 'Nutrition';
      case 'علم الصحة العامة':    return 'Public Health';
      case 'إعجاز غيبي':         return 'Unseen Miracles';
      case 'إعجاز تاريخي':       return 'Historical';
      case 'معجزات نبوية':        return 'Prophetic';
      case 'علم الرياضيات':       return 'Mathematics';
      case 'علم الكيمياء':        return 'Chemistry';
      default:                    return 'Science';
    }
  }
}