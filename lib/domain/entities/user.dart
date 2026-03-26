/// Entity representing a user in the application.
class User {
  final int? id;
  final String name;
  final String email;
  final String password; // hashed password
  final String role; // user | admin
  final String? googleId;
  final String authProvider; // local | google
  final String? avatarUrl;
  final String? phone;
  final String? address;
  final String? birthDate;
  final String? gender;
  final String? resetCode; // OTP code for password reset
  final DateTime? resetCodeExpiresAt;
  final bool resetCodeVerified;
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = 'user',
    this.googleId,
    this.authProvider = 'local',
    this.avatarUrl,
    this.phone,
    this.address,
    this.birthDate,
    this.gender,
    this.resetCode,
    this.resetCodeExpiresAt,
    this.resetCodeVerified = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a User from a database map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: (map['role'] as String?) ?? 'user',
      googleId: map['google_id'] as String?,
      authProvider: (map['auth_provider'] as String?) ?? 'local',
      avatarUrl: map['avatar_url'] as String?,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      birthDate: map['birth_date'] as String?,
      gender: map['gender'] as String?,
      resetCode: map['reset_code'] as String?,
      resetCodeExpiresAt: map['reset_code_expires_at'] == null
          ? null
          : DateTime.tryParse(map['reset_code_expires_at'] as String),
      resetCodeVerified: (map['reset_code_verified'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to a map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'google_id': googleId,
      'auth_provider': authProvider,
      'avatar_url': avatarUrl,
      'phone': phone,
      'address': address,
      'birth_date': birthDate,
      'gender': gender,
      'reset_code': resetCode,
      'reset_code_expires_at': resetCodeExpiresAt?.toIso8601String(),
      'reset_code_verified': resetCodeVerified ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with optional field overrides.
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? role,
    String? googleId,
    String? authProvider,
    String? avatarUrl,
    String? phone,
    String? address,
    String? birthDate,
    String? gender,
    String? resetCode,
    DateTime? resetCodeExpiresAt,
    bool? resetCodeVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      googleId: googleId ?? this.googleId,
      authProvider: authProvider ?? this.authProvider,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      resetCode: resetCode ?? this.resetCode,
      resetCodeExpiresAt: resetCodeExpiresAt ?? this.resetCodeExpiresAt,
      resetCodeVerified: resetCodeVerified ?? this.resetCodeVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
