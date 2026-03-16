/// Entity representing a user in the application.
class User {
  final int? id;
  final String name;
  final String email;
  final String password; // hashed password
  final String? phone;
  final String? address;
  final String? birthDate;
  final String? gender;
  final String? resetCode; // OTP code for password reset
  final DateTime createdAt;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.address,
    this.birthDate,
    this.gender,
    this.resetCode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create a User from a database map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      phone: map['phone'] as String?,
      address: map['address'] as String?,
      birthDate: map['birth_date'] as String?,
      gender: map['gender'] as String?,
      resetCode: map['reset_code'] as String?,
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
      'phone': phone,
      'address': address,
      'birth_date': birthDate,
      'gender': gender,
      'reset_code': resetCode,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create a copy with optional field overrides.
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? address,
    String? birthDate,
    String? gender,
    String? resetCode,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      resetCode: resetCode ?? this.resetCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
