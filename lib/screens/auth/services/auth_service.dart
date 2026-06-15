import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailjs/emailjs.dart';
import 'package:emailjs/emailjs.dart' as EmailJS;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  needsOTP,
  authenticated,
}

class AuthResult {
  final bool success;
  final String? error;
  const AuthResult({required this.success, this.error});
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _google = GoogleSignIn(scopes: ['email']);

  // ═══════════════════════════════════════════
  // ✅ ضع معلومات EmailJS هنا
  // ═══════════════════════════════════════════
  static const _emailJsServiceId = 'service_xxxxxxx';
  static const _emailJsTemplateId = 'template_xxxxxxx';
  static const _emailJsPublicKey = 'xxxxxxxxxxxx';

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  bool _loading = false;

  // ═══ OTP ═══
  String? _generatedOTP;
  DateTime? _otpExpiry;
  String? _otpEmail;
  String? _otpUserName;
  String? _otpPassword;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get isLoading => _loading;
  bool get isLoggedIn => _status == AuthStatus.authenticated;
  bool get needsOTP => _status == AuthStatus.needsOTP;
  String? get pendingEmail => _otpEmail;

  // ══════════════════════════════════════════════
  // تهيئة
  // ══════════════════════════════════════════════
  Future<void> init() async {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (_) {}

    try {
      final firebaseUser = _auth.currentUser;

      if (firebaseUser == null) {
        _status = AuthStatus.unauthenticated;
      } else if (firebaseUser.isAnonymous) {
        _user = _buildModel(firebaseUser, 'guest');
        _status = AuthStatus.authenticated;
      } else {
        try {
          _user = await _loadFromCloud(firebaseUser.uid)
              .timeout(const Duration(seconds: 4));
        } catch (_) {}

        _user ??= _buildModel(
          firebaseUser,
          firebaseUser.providerData
              .any((p) => p.providerId == 'google.com')
              ? 'google'
              : 'email',
        );

        try {
          await _saveToCloud(_user!)
              .timeout(const Duration(seconds: 3));
        } catch (_) {}

        _status = AuthStatus.authenticated;
      }
    } catch (e) {
      debugPrint('⚠️ Auth init error: $e');
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  // ══════════════════════════════════════════════
  // توليد OTP
  // ══════════════════════════════════════════════
  String _generateOTP() {
    final random = Random.secure();
    return List.generate(6, (_) => random.nextInt(10)).join();
  }

  // ══════════════════════════════════════════════
  // إرسال OTP عبر EmailJS
  // ══════════════════════════════════════════════
  Future<bool> _sendOTP(String email) async {
    try {
      _generatedOTP = _generateOTP();
      _otpExpiry = DateTime.now().add(const Duration(minutes: 5));
      _otpEmail = email;

      debugPrint('🔐 OTP: $_generatedOTP for $email');

      // ✅ الطريقة الصحيحة
      await EmailJS.send(
        _emailJsServiceId,
        _emailJsTemplateId,
        {
          'to_email': email,
          'otp_code': _generatedOTP!,
        },
        Options(
          publicKey: _emailJsPublicKey,
        ),
      );

      debugPrint('✅ OTP sent to $email');
      return true;
    } catch (e) {
      debugPrint('❌ OTP error: $e');
      return false;
    }
  }

  // ══════════════════════════════════════════════
  // إعادة إرسال OTP
  // ══════════════════════════════════════════════
  Future<bool> resendOTP() async {
    if (_otpEmail == null) return false;
    return await _sendOTP(_otpEmail!);
  }

  // ══════════════════════════════════════════════
  // التحقق من OTP → إنشاء الحساب
  // ══════════════════════════════════════════════
  Future<AuthResult> verifyOTP(String enteredCode) async {
    _setLoading(true);
    try {
      // تحقق من الصلاحية
      if (_otpExpiry != null && DateTime.now().isAfter(_otpExpiry!)) {
        _setLoading(false);
        return const AuthResult(
          success: false,
          error: 'انتهت صلاحية الرمز، أعد الإرسال',
        );
      }

      // تحقق من الرمز
      if (enteredCode != _generatedOTP) {
        _setLoading(false);
        return const AuthResult(
          success: false,
          error: 'الرمز غير صحيح',
        );
      }

      // ═══ الرمز صحيح → أنشئ الحساب ═══
      UserCredential result;

      if (_auth.currentUser?.isAnonymous == true) {
        final cred = EmailAuthProvider.credential(
          email: _otpEmail!,
          password: _otpPassword!,
        );
        result = await _auth.currentUser!.linkWithCredential(cred);
      } else {
        result = await _auth.createUserWithEmailAndPassword(
          email: _otpEmail!,
          password: _otpPassword!,
        );
      }

      await result.user?.updateDisplayName(_otpUserName);

      final u = result.user!;
      _user = UserModel(
        id: u.uid,
        name: _otpUserName ?? 'مستخدم',
        email: _otpEmail!,
        photoUrl: u.photoURL,
        createdAt: DateTime.now(),
        loginMethod: 'email',
      );

      await _saveToCloud(_user!);
      await _migrateGuestData(u.uid);

      // نظّف
      _generatedOTP = null;
      _otpExpiry = null;
      _otpEmail = null;
      _otpUserName = null;
      _otpPassword = null;

      _status = AuthStatus.authenticated;
      _setLoading(false);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return AuthResult(success: false, error: _mapError(e));
    } catch (e) {
      _setLoading(false);
      return AuthResult(success: false, error: 'خطأ: $e');
    }
  }

  // ══════════════════════════════════════════════
  // إنشاء حساب → يرسل OTP أولاً
  // ══════════════════════════════════════════════
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      // ═══ تحقق أن البريد غير مستخدم ═══
      try {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        // إذا نجح → البريد جديد → احذف الحساب المؤقت
        await cred.user?.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          _setLoading(false);
          return const AuthResult(
            success: false,
            error: 'هذا البريد مُسجَّل بالفعل',
          );
        }
        // أي خطأ آخر نتجاهله ونكمل
      }

      // ═══ احفظ البيانات مؤقتاً ═══
      _otpUserName = name.trim();
      _otpEmail = email.trim();
      _otpPassword = password;

      // ═══ أرسل OTP ═══
      final sent = await _sendOTP(email.trim());

      if (!sent) {
        _setLoading(false);
        return const AuthResult(
          success: false,
          error: 'فشل إرسال رمز التحقق، حاول مرة أخرى',
        );
      }

      _status = AuthStatus.needsOTP;
      _setLoading(false);
      return const AuthResult(success: true);
    } catch (_) {
      _setLoading(false);
      return const AuthResult(success: false, error: 'حدث خطأ غير متوقع');
    }
  }

  // ══════════════════════════════════════════════
  // تسجيل الدخول → مباشرة بدون OTP
  // ══════════════════════════════════════════════
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final u = result.user!;

      _user = await _loadFromCloud(u.uid);
      _user ??= _buildModel(u, 'email');
      await _saveToCloud(_user!);

      _status = AuthStatus.authenticated;
      _setLoading(false);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return AuthResult(success: false, error: _mapError(e));
    } catch (_) {
      _setLoading(false);
      return const AuthResult(success: false, error: 'حدث خطأ غير متوقع');
    }
  }

  // ══════════════════════════════════════════════
  // Google
  // ══════════════════════════════════════════════
  Future<AuthResult> signInWithGoogle() async {
    _setLoading(true);
    try {
      final googleUser = await _google.signIn();
      if (googleUser == null) {
        _setLoading(false);
        return const AuthResult(success: false, error: 'تم إلغاء العملية');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result;
      if (_auth.currentUser?.isAnonymous == true) {
        result = await _auth.currentUser!.linkWithCredential(credential);
      } else {
        result = await _auth.signInWithCredential(credential);
      }

      final u = result.user!;
      _user = await _loadFromCloud(u.uid);
      _user ??= _buildModel(u, 'google');
      await _saveToCloud(_user!);
      await _migrateGuestData(u.uid);

      _status = AuthStatus.authenticated;
      _setLoading(false);
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      return AuthResult(success: false, error: _mapError(e));
    } catch (_) {
      _setLoading(false);
      return const AuthResult(
          success: false, error: 'فشل تسجيل الدخول بـ Google');
    }
  }

  // ══════════════════════════════════════════════
  // زائر
  // ══════════════════════════════════════════════
  Future<void> continueAsGuest() async {
    _setLoading(true);
    try {
      final result = await _auth.signInAnonymously();
      _user = _buildModel(result.user!, 'guest');
      _status = AuthStatus.authenticated;
    } catch (_) {
      _user = UserModel(
        id: 'local_guest_${DateTime.now().millisecondsSinceEpoch}',
        name: 'زائر',
        email: '',
        createdAt: DateTime.now(),
        loginMethod: 'guest',
      );
      _status = AuthStatus.authenticated;
    }
    _setLoading(false);
  }

  // ══════════════════════════════════════════════
  // تسجيل الخروج
  // ══════════════════════════════════════════════
  Future<void> signOut() async {
    try { await _google.signOut(); } catch (_) {}
    try { await _auth.signOut(); } catch (_) {}
    _user = null;
    _generatedOTP = null;
    _otpExpiry = null;
    _otpEmail = null;
    _otpUserName = null;
    _otpPassword = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ══════════════════════════════════════════════
  // إعادة تعيين كلمة المرور
  // ══════════════════════════════════════════════
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const AuthResult(success: true);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, error: _mapError(e));
    } catch (_) {
      return const AuthResult(success: false, error: 'حدث خطأ غير متوقع');
    }
  }

  // ══════════════════════════════════════════════
  // حفظ واستعادة التقدم
  // ══════════════════════════════════════════════
  Future<void> saveProgress(String key, dynamic value) async {
    if (_user == null) return;
    if (_user!.isGuest) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('guest_$key', jsonEncode(value));
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_${_user!.id}_$key', jsonEncode(value));
      try {
        await _db.collection('users').doc(_user!.id).set(
          {'progress': {key: value}},
          SetOptions(merge: true),
        ).timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
  }

  Future<dynamic> loadProgress(String key) async {
    if (_user == null) return null;
    if (_user!.isGuest) {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('guest_$key');
      return raw != null ? jsonDecode(raw) : null;
    } else {
      try {
        final doc = await _db.collection('users').doc(_user!.id).get()
            .timeout(const Duration(seconds: 4));
        final data = doc.data();
        if (data?['progress'] != null) {
          return (data!['progress'] as Map<String, dynamic>)[key];
        }
      } catch (_) {}
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('local_${_user!.id}_$key');
      return raw != null ? jsonDecode(raw) : null;
    }
  }

  Future<Map<String, dynamic>> loadAllProgress() async {
    if (_user == null) return {};
    if (_user!.isGuest) {
      final prefs = await SharedPreferences.getInstance();
      final map = <String, dynamic>{};
      for (final k in prefs.getKeys().where((k) => k.startsWith('guest_'))) {
        final raw = prefs.getString(k);
        if (raw != null) {
          try { map[k.replaceFirst('guest_', '')] = jsonDecode(raw); } catch (_) {}
        }
      }
      return map;
    } else {
      try {
        final doc = await _db.collection('users').doc(_user!.id).get();
        return Map<String, dynamic>.from(doc.data()?['progress'] ?? {});
      } catch (_) { return {}; }
    }
  }

  // ═══ مساعدات ═══
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  UserModel _buildModel(User u, String method) => UserModel(
    id: u.uid,
    name: u.displayName ?? (method == 'guest' ? 'زائر' : 'مستخدم'),
    email: u.email ?? '',
    photoUrl: u.photoURL,
    createdAt: u.metadata.creationTime ?? DateTime.now(),
    loginMethod: method,
  );

  Future<void> _saveToCloud(UserModel user) async {
    if (user.isGuest) return;
    try {
      await _db.collection('users').doc(user.id)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (_) {}
  }

  Future<UserModel?> _loadFromCloud(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _migrateGuestData(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('guest_')).toList();
    if (keys.isEmpty) return;
    final progress = <String, dynamic>{};
    for (final k in keys) {
      final raw = prefs.getString(k);
      if (raw != null) {
        try { progress[k.replaceFirst('guest_', '')] = jsonDecode(raw); }
        catch (_) { progress[k.replaceFirst('guest_', '')] = raw; }
      }
    }
    if (progress.isNotEmpty) {
      try {
        await _db.collection('users').doc(uid).set(
            {'progress': progress}, SetOptions(merge: true));
      } catch (_) {}
    }
    for (final k in keys) { await prefs.remove(k); }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use': return 'هذا البريد مُسجَّل بالفعل';
      case 'invalid-email': return 'البريد غير صحيح';
      case 'weak-password': return 'كلمة المرور ضعيفة';
      case 'user-disabled': return 'الحساب مُعطَّل';
      case 'user-not-found': return 'لا يوجد حساب بهذا البريد';
      case 'wrong-password': return 'كلمة المرور غير صحيحة';
      case 'too-many-requests': return 'محاولات كثيرة، حاول لاحقاً';
      case 'network-request-failed': return 'تحقق من اتصالك بالإنترنت';
      case 'credential-already-in-use': return 'الحساب مرتبط بمستخدم آخر';
      case 'invalid-credential': return 'بيانات الاعتماد غير صحيحة';
      default: return 'حدث خطأ (${e.code})';
    }
  }
}