import 'dart:convert';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final String loginMethod;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.loginMethod = 'email',
  });

  bool get isGuest => loginMethod == 'guest';

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toIso8601String(),
    'loginMethod': loginMethod,
  };

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'] ?? '',
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    photoUrl: j['photoUrl'],
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
    loginMethod: j['loginMethod'] ?? 'email',
  );

  String encode() => jsonEncode(toJson());
  factory UserModel.decode(String s) => UserModel.fromJson(jsonDecode(s));

  UserModel copyWith({String? name, String? email, String? photoUrl}) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt,
        loginMethod: loginMethod,
      );
}