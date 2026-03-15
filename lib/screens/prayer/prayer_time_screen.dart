import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/prayer/muezzin_catalog.dart';
import '../../services/adahn_audio_services.dart';
import '../../services/adhan_manager.dart';
import '../../services/muazzin_store.dart';
import '../../services/adahn_notification.dart';

import '../../utils/radio_widget.dart';
import 'adhan_player_screen.dart';
import 'muzzin_settings.dart';

class PrayerTimesScreen extends StatefulWidget {
  final Color primaryColor;
  final Map<String, String>? prayerTimes;
  final String? cityName;
  final Future<void> Function()? onRefreshLocation;

  const PrayerTimesScreen({
    super.key,
    required this.primaryColor,
    this.prayerTimes,
    this.cityName, this.onRefreshLocation,
  });

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // UI colors (نفس تصميمك)
  final Color _gold = const Color(0xFFE6B325);
  final Color _bgDark = const Color(0xFF0A0E17);
  final Color _bgCard = const Color(0xFF151B26);
  String _selectedMethod = 'umm_al_qura';
  int _reminderOffset = 10;

  bool _loading = true;
  bool _adhanEnabled = false;
  bool _isWaitingForSettingsReturn = false;

  // default + effective per prayer
  MuezzinInfo? _defaultMuezzin;
  final Map<String, MuezzinInfo> _effective = {}; // key -> muezzin

  // prayer list
  late List<_PrayerRow> _rows;
  int _currentIndex = -1;
  int _nextIndex = -1;

  Timer? _tick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bootstrap();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tick?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // إذا عاد التطبيق للشاشة (Resumed) وكنا ننتظر عودته من الإعدادات
    if (state == AppLifecycleState.resumed && _isWaitingForSettingsReturn) {
      _isWaitingForSettingsReturn = false; // نغلق الانتظار
      _verifyPermissionsAfterReturn();     // نفحص الصلاحيات الآن!
    }
  }

  Future<void> _verifyPermissionsAfterReturn() async {
    final prefs = await SharedPreferences.getInstance();

    // فحص الصلاحيات الأساسية التي يمكن فحصها برمجياً
    bool hasNotification = await Permission.notification.isGranted;
    bool hasExactAlarm = await Permission.scheduleExactAlarm.isGranted;
    bool ignoresBattery = await Permission.ignoreBatteryOptimizations.isGranted;

    // إذا تم منح الصلاحيات الأساسية
    if (hasNotification && ignoresBattery) {
      if (mounted) setState(() => _adhanEnabled = true);
      await prefs.setBool('adhan_enabled', true);
      await _scheduleAllAdhans();

      // ✅ الرسالة أصبحت أكثر ذكاءً وصدقاً مع المستخدم
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ تم الجدولة. تأكد أنك فعلت "التشغيل التلقائي" يدوياً لضمان عمل الأذان.',
              style: GoogleFonts.cairo(fontSize: 13),
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 5), // مدة أطول ليقرأها
          ),
        );
      }
    } else {
      // ❌ المستخدم رفض صلاحية البطارية أو الإشعارات الأساسية
      if (mounted) setState(() => _adhanEnabled = false);
      await prefs.setBool('adhan_enabled', false);
      _showErrorSnackBar('لم تمنح الصلاحيات الأساسية! الأذان قد لا يعمل.');
    }
  }

  Future<void> _bootstrap() async {
    await _loadDefaultAndEffective();
    _buildPrayerRows();
    await _loadAdhanEnabled();

    // تحديث كل ثانية: current/next + remaining
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _computeCurrentNext();
      });
    });

    setState(() => _loading = false);
  }

  Future<void> _loadAdhanEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    _adhanEnabled = prefs.getBool('adhan_enabled') ?? false;
  }

  Future<void> _loadDefaultAndEffective() async {
    _defaultMuezzin = await MuezzinStore.getDefault();

    _effective.clear();
    for (final key in const ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      _effective[key] = await MuezzinStore.getEffectiveForPrayer(key);
    }
  }

  void _buildPrayerRows() {
    final times = widget.prayerTimes ?? {
      'Fajr': '05:30',
      'Sunrise': '06:45',
      'Dhuhr': '12:15',
      'Asr': '15:45',
      'Maghrib': '18:20',
      'Isha': '19:45',
    };

    final now = DateTime.now();

    _rows = [
      _PrayerRow(key: 'Fajr',    name: 'الفجر',   time: times['Fajr'] ?? '05:30',    icon: Icons.wb_twilight),
      _PrayerRow(key: 'Sunrise', name: 'الشروق',  time: times['Sunrise'] ?? '06:45', icon: Icons.wb_sunny_outlined, noAdhan: true),
      _PrayerRow(key: 'Dhuhr',   name: 'الظهر',   time: times['Dhuhr'] ?? '12:15',   icon: Icons.sunny),
      _PrayerRow(key: 'Asr',     name: 'العصر',   time: times['Asr'] ?? '15:45',     icon: Icons.filter_drama),
      _PrayerRow(key: 'Maghrib', name: 'المغرب',  time: times['Maghrib'] ?? '18:20', icon: Icons.nights_stay),
      _PrayerRow(key: 'Isha',    name: 'العشاء',  time: times['Isha'] ?? '19:45',    icon: Icons.star_rounded),
    ];

    for (final r in _rows) {
      r.dateTime = _parseTimeToday(r.time, now);
    }

    _computeCurrentNext();
  }

  DateTime _parseTimeToday(String timeStr, DateTime now) {
    final clean = timeStr.split(' ').first;
    final parts = clean.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return DateTime(now.year, now.month, now.day, h, m);
  }

  void _computeCurrentNext() {
    final now = DateTime.now();

    _currentIndex = -1;
    _nextIndex = -1;

    // past markers
    for (final r in _rows) {
      r.isPast = now.isAfter(r.dateTime);
      r.isCurrent = false;
      r.isNext = false;
    }

    // find next
    for (int i = 0; i < _rows.length; i++) {
      final t = _rows[i].dateTime;
      if (now.isBefore(t) || now.isAtSameMomentAs(t)) {
        _nextIndex = i;
        _rows[i].isNext = true;
        if (i > 0) {
          _currentIndex = i - 1;
          _rows[i - 1].isCurrent = true;
        }
        return;
      }
    }

    // if all passed -> next is fajr tomorrow
    if (_rows.isNotEmpty) {
      _currentIndex = _rows.length - 1;
      _rows[_currentIndex].isCurrent = true;

      _nextIndex = 0;
      _rows[0].isNext = true;
      _rows[0].isTomorrow = true;
    }
  }

  Duration _remainingToNext() {
    if (_nextIndex < 0) return Duration.zero;
    final now = DateTime.now();
    final nextRow = _rows[_nextIndex];
    var target = nextRow.dateTime;
    if (nextRow.isTomorrow == true || now.isAfter(target)) {
      target = target.add(const Duration(days: 1));
    }
    final d = target.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  String _fmtRemain(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _runAdhanDiagnostic() async {
    // فحص الصلاحيات باستخدام حزمة permission_handler
    bool hasNotification = await Permission.notification.isGranted;
    bool hasExactAlarm = await Permission.scheduleExactAlarm.isGranted;
    bool ignoresBattery = await Permission.ignoreBatteryOptimizations.isGranted;

    // فحص "التشغيل التلقائي" (خاص بشاومي وبعض الأجهزة)
    // لا توجد مكتبة مباشرة له، لذا نفتح إعدادات التطبيقات كبديل

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151B26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('فحص جاهزية الأذان', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDiagnosticItem('إذن الإشعارات', hasNotification, () => openAppSettings()),
            _buildDiagnosticItem('المنبهات الدقيقة (أندرويد 12+)', hasExactAlarm, () => Permission.scheduleExactAlarm.request()),
            _buildDiagnosticItem('استثناء البطارية', ignoresBattery, () => Permission.ignoreBatteryOptimizations.request()),
            const SizedBox(height: 15),
            Text(
              '⚠️ ملاحظة: إذا كنت تستخدم شاومي/ريدمي، يرجى تفعيل "التشغيل التلقائي" (Autostart) من إعدادات التطبيق في الهاتف يدوياً.',
              style: GoogleFonts.cairo(color: Colors.orange, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إغلاق', style: GoogleFonts.cairo(color: _gold)),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticItem(String title, bool isOk, VoidCallback fixAction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(isOk ? Icons.check_circle : Icons.error, color: isOk ? Colors.green : Colors.red, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: GoogleFonts.cairo(color: Colors.white, fontSize: 14))),
          if (!isOk)
            TextButton(
              onPressed: fixAction,
              child: Text('إصلاح', style: GoogleFonts.cairo(color: _gold, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  // متغيرات حالة يجب إضافتها في أعلى كلاس State إذا لم تكن موجودة
  // String _selectedMethod = 'umm_al_qura';
  // int _reminderOffset = 10;

  void _showAdhanSettings() async {
    // جلب الإعدادات الحالية قبل فتح النافذة
    final prefs = await SharedPreferences.getInstance();
    String currentMethod = prefs.getString('calc_method') ?? 'umm_al_qura';
    int currentOffset = prefs.getInt('reminder_offset') ?? 10;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // للسماح بظهور القائمة كاملة
      builder: (BuildContext bottomSheetContext) {
        // نستخدم StatefulBuilder لتحديث حالة النافذة السفلية داخلياً
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _gold.withOpacity(0.2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'إعدادات الأذان التلقائي',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. مفتاح تفعيل/تعطيل الأذان
                  SwitchListTile(

                    title: Text(
                      'تفعيل الأذان عند كل صلاة',
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
                    subtitle: Text(
                      'سيتم تشغيل الأذان تلقائياً',
                      style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                    ),
                    value: _adhanEnabled,
                    // ✅ هنا يتم استدعاء الدالة
                    onChanged: (bool value) {
                      Navigator.pop(context); // إغلاق النافذة قبل تنفيذ الدالة
                      _toggleAdhan(value);    // استدعاء الدالة
                    },

                    activeColor: _gold,
                  ),
                  const Divider(color: Colors.white24),

                  // 2. اختيار طريقة الحساب
                  ListTile(
                    title: Text('طريقة الحساب', style: GoogleFonts.cairo(color: Colors.white)),
                    subtitle: DropdownButton<String>(
                      isExpanded: true,
                      dropdownColor: _bgDark,
                      value: currentMethod,
                      style: GoogleFonts.cairo(color: _gold),
                      underline: Container(height: 1, color: _gold.withOpacity(0.3)),
                      items: const [
                        DropdownMenuItem(value: 'umm_al_qura', child: Text('أم القرى (مكة المكرمة)')),
                        DropdownMenuItem(value: 'egyptian', child: Text('الهيئة العامة المصرية')),
                        DropdownMenuItem(value: 'mwl', child: Text('رابطة العالم الإسلامي')),
                      ],
                      onChanged: (String? newValue) async {
                        if (newValue != null) {
                          setModalState(() => currentMethod = newValue);
                          await prefs.setString('calc_method', newValue);
                          // ✅ إعادة الجدولة
                          await AdhanManager.schedulePrayersForNextWeek();
                        }
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24),

                  // 3. التذكير قبل الصلاة
                  ListTile(
                    title: Text('تنبيه قبل الصلاة', style: GoogleFonts.cairo(color: Colors.white)),
                    subtitle: DropdownButton<int>(
                      isExpanded: true,
                      dropdownColor: _bgDark,
                      value: currentOffset,
                      style: GoogleFonts.cairo(color: _gold),
                      underline: Container(height: 1, color: _gold.withOpacity(0.3)),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('إيقاف التنبيه المسبق')),
                        DropdownMenuItem(value: 5, child: Text('قبل الصلاة بـ 5 دقائق')),
                        DropdownMenuItem(value: 10, child: Text('قبل الصلاة بـ 10 دقائق')),
                        DropdownMenuItem(value: 15, child: Text('قبل الصلاة بـ 15 دقيقة')),
                      ],
                      onChanged: (int? newValue) async {
                        if (newValue != null) {
                          setModalState(() => currentOffset = newValue);
                          await prefs.setInt('reminder_offset', newValue);
                          await prefs.setBool('reminder_enabled', newValue > 0);
                          // ✅ إعادة الجدولة
                          await AdhanManager.schedulePrayersForNextWeek();
                        }
                      },
                    ),
                  ),
                  const Divider(color: Colors.white24),

                  // زر الفحص الذكي (يحتفظ بشكله القديم)
                  ListTile(
                    leading: const Icon(Icons.health_and_safety, color: Colors.blueAccent),
                    title: Text(
                      'فحص جاهزية الهاتف للأذان',
                      style: GoogleFonts.cairo(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'اكتشف لماذا لا يعمل الأذان في الخلفية',
                      style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueAccent),
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _runAdhanDiagnostic();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // =========================
  // (1) عرض المؤذن تحت كل صلاة
  // (2) تخصيص لكل صلاة
  // =========================

  MuezzinInfo _effectiveForKey(String key) {
    // Sunrise no adhan => still show default name or "لا يوجد"
    if (key == 'Sunrise') {
      return _defaultMuezzin ??
          (muezzinCatalog.first.items.first);
    }
    return _effective[key] ?? _defaultMuezzin ?? muezzinCatalog.first.items.first;
  }

  Future<void> _openCustomizeForPrayer(_PrayerRow row) async {
    if (row.noAdhan == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الشروق ليس له أذان', style: GoogleFonts.cairo()), backgroundColor: Colors.orange),
      );
      return;
    }

    final current = _effectiveForKey(row.key);

    final selected = await showModalBottomSheet<MuezzinInfo?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _MuezzinPickerSheet(
        gold: _gold,
        bg: _bgCard,
        title: 'تخصيص مؤذن لصلاة ${row.name}',
        currentId: current.id,
      ),
    );

    if (!mounted) return;

    // null => user closed
    if (selected == null) return;

    if (selected.id == '__DEFAULT__') {
      await MuezzinStore.clearCustomForPrayer(row.key);
    } else {
      await MuezzinStore.setCustomForPrayer(row.key, selected);
    }

    // reload effective map + update UI
    await _loadDefaultAndEffective();
    setState(() {});

    // if enabled -> reschedule (to match effective muezzin)
    if (_adhanEnabled) {
      await AdhanManager.schedulePrayersForNextWeek();
    }
  }

  Future<void> _openDefaultMuezzinSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MuezzinSettingsScreen(primaryColor: widget.primaryColor),
      ),
    );

    // IMPORTANT: When user chooses new default from catalog list,
    // our store uses resetAllCustom:true => it clears all custom prayer muezzins.
    await _loadDefaultAndEffective();
    setState(() {});

    if (_adhanEnabled) {
      await _scheduleAllAdhans();
    }
  }

  Future<void> _toggleAdhan(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value) {
      bool hasNotification = await Permission.notification.isGranted;
      bool hasExactAlarm = await Permission.scheduleExactAlarm.isGranted;
      bool ignoresBattery = await Permission.ignoreBatteryOptimizations.isGranted;

      // إذا كانت كل الصلاحيات ممنوحة من قبل، فعل فوراً
      if (hasNotification && hasExactAlarm && ignoresBattery) {
        if (mounted) setState(() => _adhanEnabled = true);
        await prefs.setBool('adhan_enabled', true);
        await _scheduleAllAdhans();
        _showSuccessMessage();
        return;
      }

      // إذا كان هناك صلاحية ناقصة، نظهر التنبيه
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            backgroundColor: _bgCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: _gold.withOpacity(0.3), width: 1),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: _gold),
                const SizedBox(width: 10),
                Text('صلاحيات ناقصة', style: GoogleFonts.cairo(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لضمان عمل الأذان 100%، يرجى تفعيل الآتي في الإعدادات:',
                    style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  if (!ignoresBattery) _buildInstructionRow('1', 'استثناء البطارية (بدون قيود)'),
                  if (!hasExactAlarm) _buildInstructionRow('2', 'المنبهات والتذكيرات'),
                  if (!hasNotification) _buildInstructionRow('3', 'السماح بالإشعارات'),
                  const SizedBox(height: 10),
                  Text(
                    'ملاحظة: لشاومي وأوبو يجب أيضاً تفعيل (التشغيل التلقائي) و(الظهور فوق شاشة القفل).',
                    style: GoogleFonts.cairo(color: Colors.orange, fontSize: 11),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (mounted) setState(() => _adhanEnabled = false);
                  prefs.setBool('adhan_enabled', false);
                },
                child: Text('إلغاء', style: GoogleFonts.cairo(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _gold),
                onPressed: () async {
                  Navigator.pop(ctx);

                  // ✅ نخبر التطبيق أننا ننتظر عودة المستخدم
                  _isWaitingForSettingsReturn = true;

                  // طلب الصلاحيات التي قد تفتح نوافذ منبثقة أولاً
                  if (!hasNotification) await Permission.notification.request();
                  if (!hasExactAlarm) await Permission.scheduleExactAlarm.request();
                  if (!ignoresBattery) await Permission.ignoreBatteryOptimizations.request();

                  // فتح الإعدادات ليقوم بتفعيل الباقي يدوياً
                  await openAppSettings();

                  // 🛑 لا نجدول هنا! الجدولة ستحدث في didChangeAppLifecycleState عند عودته
                },
                child: Text('الذهاب للإعدادات', style: GoogleFonts.cairo(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } else {
      // حالة الإغلاق
      if (mounted) setState(() => _adhanEnabled = false);
      await prefs.setBool('adhan_enabled', false);
      await AdahnNotification.instance.cancelAll();
      _showErrorSnackBar('تم إيقاف الأذان التلقائي', isOrange: true);
    }
  }

  void _showSuccessMessage() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ تم تفعيل وجدولة الأذان بنجاح', style: GoogleFonts.cairo()), backgroundColor: Colors.green),
      );
    }
  }

  void _showErrorSnackBar(String message, {bool isOrange = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.cairo()),
          backgroundColor: isOrange ? Colors.orange : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _scheduleAllAdhans() async {
    // ids ثابتة لكل صلاة
    const ids = {
      'Fajr': 100,
      'Dhuhr': 101,
      'Asr': 102,
      'Maghrib': 103,
      'Isha': 104,
    };

    // امسح القديم ثم جدولة جديد (أضمن وأبسط)
    await AdahnNotification.instance.cancelAll();

    final now = DateTime.now();

    for (final row in _rows) {
      if (row.noAdhan == true) continue;
      final m = _effectiveForKey(row.key);

      // local path if downloaded
      final local = await AdhanAudioService.instance.getLocalPath(m.id);

      // وقت اليوم أو غدًا لو فات
      var t = row.dateTime;
      if (now.isAfter(t)) t = t.add(const Duration(days: 1));

      await AdahnNotification.instance.schedulePrayerNotification(
        id: ids[row.key]!,
        dateTime: t,
        title: 'حان وقت صلاة ${row.name}',
        body: 'المؤذن: ${m.name}',
        payload: {
          'type': 'adhan',
          'prayerKey': row.key,
          'prayerName': row.name,
          'muezzinId': m.id,
          'muezzinName': m.name,
          'muezzinUrl': m.url,
          'localPath': local, // قد تكون null
        },
      );
    }
  }

  Future<void> _playNextAdhanPreview() async {
    if (_nextIndex < 0) return;
    final row = _rows[_nextIndex];

    // Sunrise has no adhan, if next is Sunrise => play next adhan after it (optional)
    if (row.noAdhan == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الشروق ليس له أذان', style: GoogleFonts.cairo()), backgroundColor: Colors.orange),
      );
      return;
    }

    final m = _effectiveForKey(row.key);
    final local = await AdhanAudioService.instance.getLocalPath(m.id);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdhanPlayerScreen(
          primaryColor: widget.primaryColor,
          prayerName: row.name,
          muezzinName: m.name,
          url: m.url,
          localPath: local,
        ),
      ),
    );
  }



  // ========================= UI =========================

  @override
  Widget build(BuildContext context) {
    // ✅ 1. تحديد الوضع (فاتح / داكن)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ 2. تعريف الألوان الديناميكية بناءً على الوضع
    // الذهب ثابت ليعطي الفخامة في الوضعين
    final _gold = const Color(0xFFE6B325);

    // الخلفيات تتغير
    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF151B26) : Colors.white;

    // النصوص تتغير
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    // حدود وظلال البطاقات تتغير لتكون مناسبة للخلفية
    final listCardGradient = isDark
        ? [Colors.white.withOpacity(0.05), Colors.white.withOpacity(0.02)]
        : [Colors.white, Colors.white]; // في الفاتح نستخدم أبيض نقي أو تدرج خفيف جداً

    final listCardBorder = isDark
        ? Colors.white.withOpacity(0.1)
        : _gold.withOpacity(0.2); // في الفاتح نجعل الحدود ذهبية خفيفة بدلاً من الأبيض الشفاف

    if (_loading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator(color: _gold)),
      );
    }

    final nextRemain = _fmtRemain(_remainingToNext());
    final nextRow = _nextIndex >= 0 ? _rows[_nextIndex] : null;
    final nextM = nextRow == null ? null : _effectiveForKey(nextRow.key);

    return Scaffold(
        backgroundColor: bgColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(widget.cityName ?? 'مواقيت الصلاة',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 20, color: textColor)),
          actions: [
            IconButton(
              icon: Icon(Icons.my_location, color: isDark ? _gold : _gold), // الأيقونة ذهبية في الوضعين
              tooltip: 'تحديث الموقع',
              onPressed: () async {
                if (widget.onRefreshLocation != null) {
                  await widget.onRefreshLocation!();
                }
              },
            ),
            IconButton(
              icon: Icon(_adhanEnabled ? Icons.notifications_active : Icons.notifications_off,
                  color: _adhanEnabled ? _gold : (isDark ? Colors.white54 : Colors.black45)),
              onPressed: () => _showAdhanSettings(),
            ),
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)
              ),
              child: IconButton(
                icon: Icon(Icons.settings_voice, color: _gold),
                onPressed: _openDefaultMuezzinSettings,
              ),
            ),
          ],
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.1) : _gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12)
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 20),

              // ====== بطاقة الصلاة القادمة ======
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [_gold.withOpacity(0.2), _gold.withOpacity(0.05)]),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: _gold.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _gold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _gold.withOpacity(0.4)),
                              ),
                              child: Text('الصلاة القادمة',
                                  style: GoogleFonts.cairo(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 12),
                            Text(nextRow?.name ?? '--',
                                style: GoogleFonts.amiri(fontSize: 36, color: textColor, fontWeight: FontWeight.bold, height: 1)),
                            const SizedBox(height: 4),
                            Text(nextRow?.time ?? '--:--',
                                style: GoogleFonts.cairo(fontSize: 18, color: subTextColor)),
                            const SizedBox(height: 6),
                            if (nextM != null)
                              Text('المؤذن: ${nextM.name}',
                                  style: GoogleFonts.cairo(fontSize: 13, color: _gold.withOpacity(0.9))),
                          ]),
                        ),
                        Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _gold, width: 3),
                            color: cardColor, // تتغير حسب الوضع
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(nextRemain,
                                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                              Text('متبقي', style: GoogleFonts.cairo(fontSize: 10, color: _gold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _playNextAdhanPreview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _gold.withOpacity(0.2),
                              foregroundColor: _gold,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: _gold.withOpacity(0.3)),
                              ),
                            ),
                            icon: const Icon(Icons.play_arrow),
                            label: Text('استمع للأذان', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ====== الراديو ======
              RadioMiniPlayer(gold: _gold),

              const SizedBox(height: 20),

              // ====== عنوان الجدول ======
              Row(
                children: [
                  Container(width: 4, height: 24, decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 12),
                  Text('جدول المواقيت',
                      style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                  const Spacer(),
                  if (nextRow != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _gold.withOpacity(0.35)),
                      ),
                      child: Text('التالية: ${nextRow.name}', style: GoogleFonts.cairo(color: _gold, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ====== قائمة الصلوات ======
              ..._rows.map((row) {
                final isCurrent = row.isCurrent;
                final isNext = row.isNext;
                final isPast = row.isPast;
                final m = _effectiveForKey(row.key);

                return GestureDetector(
                  onTap: () => _openCustomizeForPrayer(row),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCurrent
                            ? [_gold.withOpacity(0.15), _gold.withOpacity(0.05)]
                            : isNext
                            ? [_gold.withOpacity(0.10), _gold.withOpacity(0.03)]
                            : listCardGradient, // استخدام المتغير الديناميكي
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCurrent
                            ? _gold.withOpacity(0.9)
                            : isNext
                            ? _gold.withOpacity(0.55)
                            : listCardBorder, // استخدام المتغير الديناميكي
                        width: isCurrent ? 2.0 : 1.0,
                      ),
                      boxShadow: isNext
                          ? [BoxShadow(color: _gold.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8))]
                          : [
                        BoxShadow(
                          color: isDark ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isPast ? Colors.grey.withOpacity(0.2) : _gold.withOpacity(isCurrent || isNext ? 0.25 : 0.10),
                            borderRadius: BorderRadius.circular(15),
                            border: (isCurrent || isNext) ? Border.all(color: _gold.withOpacity(0.8), width: 1.5) : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(row.icon, color: isPast ? Colors.grey : (isCurrent || isNext ? _gold : subTextColor), size: 24),
                              if (isNext)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _gold,
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: _gold.withOpacity(0.8), blurRadius: 6, spreadRadius: 1)],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(row.name,
                                      style: GoogleFonts.amiri(
                                        fontSize: 22,
                                        color: isPast ? subTextColor.withOpacity(0.5) : textColor,
                                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                      )),
                                  const SizedBox(width: 8),
                                  if (isCurrent) _badge('الآن', bg: _gold, fg: Colors.black),
                                  if (isNext && !isCurrent)
                                    _badge('التالية', bg: _gold.withOpacity(0.2), fg: _gold, border: _gold.withOpacity(0.5)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_outline, size: 14, color: _gold.withOpacity(0.9)),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        m.name,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: _gold.withOpacity(0.9),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.edit, size: 12, color: subTextColor.withOpacity(0.5)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(row.time,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  color: isPast ? subTextColor.withOpacity(0.4) : (isCurrent || isNext ? _gold : textColor),
                                  fontWeight: FontWeight.bold,
                                )),
                            if (row.noAdhan == true)
                              Text('بدون أذان', style: GoogleFonts.cairo(fontSize: 11, color: subTextColor.withOpacity(0.5))),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 20),
            ],
          ),
            )
        );
    }



  Widget _buildInstructionRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: _gold.withOpacity(0.2), shape: BoxShape.circle),
            child: Text(number, style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: GoogleFonts.cairo(color: Colors.white, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, {required Color bg, required Color fg, Color? border}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Text(text, style: GoogleFonts.cairo(fontSize: 11, color: fg, fontWeight: FontWeight.bold)),
    );
  }
}

class _PrayerRow {
  final String key;
  final String name;
  final String time;
  final IconData icon;
  final bool? noAdhan;

  late DateTime dateTime;

  bool isPast = false;
  bool isCurrent = false;
  bool isNext = false;
  bool isTomorrow = false;

  _PrayerRow({
    required this.key,
    required this.name,
    required this.time,
    required this.icon,
    this.noAdhan,
  });
}

/// BottomSheet اختيار مؤذن لصلاة معينة
class _MuezzinPickerSheet extends StatelessWidget {
  final Color gold;
  final Color bg;
  final String title;
  final String currentId;

  const _MuezzinPickerSheet({
    required this.gold,
    required this.bg,
    required this.title,
    required this.currentId,
  });

  @override
  Widget build(BuildContext context) {
    final all = <_PickItem>[];

    // خيار: العودة للافتراضي
    all.add(_PickItem(
      isHeader: false,
      categoryName: '',
      m: MuezzinInfo(
        id: '__DEFAULT__',
        name: 'استخدام المؤذن الافتراضي',
        url: '',
        description: 'إلغاء التخصيص لهذه الصلاة',
        imageUrl: '',
      ),
    ));

    for (final cat in muezzinCatalog) {
      all.add(_PickItem(isHeader: true, categoryName: cat.name, m: null));
      for (final m in cat.items) {
        all.add(_PickItem(isHeader: false, categoryName: cat.name, m: m));
      }
    }

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withOpacity(0.25)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(title, style: GoogleFonts.cairo(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24, height: 1),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: all.length,
                itemBuilder: (context, i) {
                  final it = all[i];

                  if (it.isHeader) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
                      child: Text(it.categoryName, style: GoogleFonts.cairo(color: gold, fontWeight: FontWeight.bold)),
                    );
                  }

                  final m = it.m!;
                  final isDefaultOption = m.id == '__DEFAULT__';
                  final isSel = (!isDefaultOption && m.id == currentId);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)]),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSel ? gold.withOpacity(0.6) : Colors.white.withOpacity(0.1), width: isSel ? 2 : 1),
                    ),
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: gold.withOpacity(0.25)),
                        ),
                        child: Icon(isDefaultOption ? Icons.restore : Icons.person, color: gold),
                      ),
                      title: Text(m.name, style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        isDefaultOption ? m.description : '${it.categoryName} • ${m.description}',
                        style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSel ? Icon(Icons.check_circle, color: gold) : null,
                      onTap: () => Navigator.pop(context, m),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickItem {
  final bool isHeader;
  final String categoryName;
  final MuezzinInfo? m;

  _PickItem({
    required this.isHeader,
    required this.categoryName,
    required this.m,
  });
}