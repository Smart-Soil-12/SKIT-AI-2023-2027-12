/// Domain entity representing an authenticated farmer user profile.
class FarmerUser {
  final String uid;
  final String email;
  final String? displayName;
  final String? phoneNumber;
  final String? idToken;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const FarmerUser({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.idToken,
    required this.createdAt,
    this.lastLoginAt,
  });

  /// Validates standard email address format.
  static bool isValidEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email.trim());
  }

  /// Validates password security (minimum 6 characters as required by Firebase Auth).
  static bool isValidPassword(String? password) {
    if (password == null) return false;
    return password.length >= 6;
  }

  /// Factory constructor to deserialize from a JSON or Firebase profile map.
  factory FarmerUser.fromJson(Map<String, dynamic> json) {
    return FarmerUser(
      uid: json['uid']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? json['displayName']?.toString(),
      phoneNumber: json['phone_number']?.toString() ?? json['phoneNumber']?.toString(),
      idToken: json['id_token']?.toString() ?? json['token']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'].toString())
          : null,
    );
  }

  /// Serializes the farmer profile to JSON.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      if (displayName != null) 'display_name': displayName,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (idToken != null) 'id_token': idToken,
      'created_at': createdAt.toIso8601String(),
      if (lastLoginAt != null) 'last_login_at': lastLoginAt!.toIso8601String(),
    };
  }

  /// Creates a copy with specified fields replaced.
  FarmerUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phoneNumber,
    String? idToken,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return FarmerUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      idToken: idToken ?? this.idToken,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FarmerUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email;

  @override
  int get hashCode => uid.hashCode ^ email.hashCode;
}
