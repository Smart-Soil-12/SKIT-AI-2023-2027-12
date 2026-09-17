import 'dart:async';
import '../../domain/models/farmer_user.dart';

/// Exception thrown when an authentication operation fails.
class AuthException implements Exception {
  final String message;
  final String code;

  const AuthException(this.message, {this.code = 'auth_error'});

  @override
  String toString() => 'AuthException($code): $message';
}

/// Abstract contract for farmer authentication services.
abstract class AuthService {
  /// Signs in an existing farmer using email and password.
  Future<FarmerUser> signInWithEmailPassword(String email, String password);

  /// Registers a new farmer account (aligns with backend register_user).
  Future<FarmerUser> registerWithEmailPassword(
    String email,
    String password, {
    String? displayName,
    String? phoneNumber,
  });

  /// Verifies the validity of a farmer's session ID token (aligns with verify_user_token).
  Future<bool> verifyToken(String idToken);

  /// Signs out the active farmer and terminates the session.
  Future<void> signOut();

  /// Gets the currently authenticated farmer profile, if any.
  FarmerUser? get currentUser;

  /// Stream emitting changes to the authenticated user profile.
  Stream<FarmerUser?> get authStateChanges;
}

/// In-memory & simulation implementation of [AuthService] for development,
/// testing, and offline precision agriculture environments.
class MockAuthService implements AuthService {
  final Map<String, _StoredUser> _registeredUsers = {};
  final StreamController<FarmerUser?> _authController = StreamController<FarmerUser?>.broadcast();
  FarmerUser? _currentUser;

  MockAuthService() {
    // Seed an initial demo farmer account for immediate testing
    final demoUser = FarmerUser(
      uid: 'farmer_chaitanya_01',
      email: 'chaitanya@smartsoil.org',
      displayName: 'Chaitanya Sharma',
      phoneNumber: '+91-8302114479',
      idToken: 'mock_jwt_token_farmer_chaitanya_01',
      createdAt: DateTime(2026, 8, 10),
    );
    _registeredUsers['chaitanya@smartsoil.org'] = _StoredUser(
      user: demoUser,
      passwordHash: 'Farmer@123',
    );
  }

  @override
  FarmerUser? get currentUser => _currentUser;

  @override
  Stream<FarmerUser?> get authStateChanges => _authController.stream;

  @override
  Future<FarmerUser> registerWithEmailPassword(
    String email,
    String password, {
    String? displayName,
    String? phoneNumber,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (!FarmerUser.isValidEmail(cleanEmail)) {
      throw const AuthException('Invalid email address format.', code: 'invalid_email');
    }
    if (!FarmerUser.isValidPassword(password)) {
      throw const AuthException('Password must be at least 6 characters.', code: 'weak_password');
    }
    if (_registeredUsers.containsKey(cleanEmail)) {
      throw const AuthException('An account already exists with this email.', code: 'email_already_in_use');
    }

    // Generate UID matching backend convention
    final uid = 'farmer_${DateTime.now().millisecondsSinceEpoch}';
    final token = 'mock_jwt_token_$uid';
    final newUser = FarmerUser(
      uid: uid,
      email: cleanEmail,
      displayName: displayName ?? cleanEmail.split('@').first,
      phoneNumber: phoneNumber,
      idToken: token,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );

    _registeredUsers[cleanEmail] = _StoredUser(user: newUser, passwordHash: password);
    _currentUser = newUser;
    _authController.add(_currentUser);

    return newUser;
  }

  @override
  Future<FarmerUser> signInWithEmailPassword(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    if (!FarmerUser.isValidEmail(cleanEmail)) {
      throw const AuthException('Invalid email address format.', code: 'invalid_email');
    }

    final stored = _registeredUsers[cleanEmail];
    if (stored == null) {
      throw const AuthException('No account found for this email.', code: 'user_not_found');
    }
    if (stored.passwordHash != password) {
      throw const AuthException('Incorrect password. Please try again.', code: 'wrong_password');
    }

    final updatedUser = stored.user.copyWith(
      lastLoginAt: DateTime.now(),
      idToken: 'mock_jwt_token_${stored.user.uid}',
    );

    _registeredUsers[cleanEmail] = _StoredUser(user: updatedUser, passwordHash: stored.passwordHash);
    _currentUser = updatedUser;
    _authController.add(_currentUser);

    return updatedUser;
  }

  @override
  Future<bool> verifyToken(String idToken) async {
    if (idToken.trim().isEmpty) return false;
    return idToken.startsWith('mock_jwt_token_');
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authController.add(null);
  }

  void dispose() {
    _authController.close();
  }
}

class _StoredUser {
  final FarmerUser user;
  final String passwordHash;

  _StoredUser({required this.user, required this.passwordHash});
}
