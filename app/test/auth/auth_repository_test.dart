import 'package:flutter_test/flutter_test.dart';
import 'package:smart_soil/smart_soil.dart';

void main() {
  group('FarmerUser Validation & Serialization', () {
    test('validates standard email formatting', () {
      expect(FarmerUser.isValidEmail('farmer@smartsoil.org'), isTrue);
      expect(FarmerUser.isValidEmail('chaitanya.sharma@skit.ac.in'), isTrue);
      expect(FarmerUser.isValidEmail('invalid-email'), isFalse);
      expect(FarmerUser.isValidEmail(''), isFalse);
      expect(FarmerUser.isValidEmail(null), isFalse);
    });

    test('validates password minimum length requirement (>= 6)', () {
      expect(FarmerUser.isValidPassword('123456'), isTrue);
      expect(FarmerUser.isValidPassword('Farmer@2026'), isTrue);
      expect(FarmerUser.isValidPassword('12345'), isFalse);
      expect(FarmerUser.isValidPassword(''), isFalse);
      expect(FarmerUser.isValidPassword(null), isFalse);
    });

    test('roundtrips through JSON serialization with full fidelity', () {
      final now = DateTime(2026, 9, 15, 10, 30);
      final user = FarmerUser(
        uid: 'farmer_test_99',
        email: 'test@farm.in',
        displayName: 'Test Farmer',
        phoneNumber: '+91-9876543210',
        idToken: 'token_xyz_123',
        createdAt: now,
      );

      final json = user.toJson();
      expect(json['uid'], 'farmer_test_99');
      expect(json['email'], 'test@farm.in');
      expect(json['display_name'], 'Test Farmer');

      final reconstructed = FarmerUser.fromJson(json);
      expect(reconstructed.uid, user.uid);
      expect(reconstructed.email, user.email);
      expect(reconstructed.displayName, user.displayName);
      expect(reconstructed.phoneNumber, user.phoneNumber);
    });
  });

  group('AuthRepository & Service Authentication Flows', () {
    late AuthRepository repo;
    late MockAuthService service;

    setUp(() {
      service = MockAuthService();
      repo = AuthRepository(authService: service);
    });

    tearDown(() {
      repo.dispose();
      service.dispose();
    });

    test('successfully signs in with valid credentials', () async {
      final success = await repo.login(
        email: 'chaitanya@smartsoil.org',
        password: 'Farmer@123',
      );

      expect(success, isTrue);
      expect(repo.currentState.isAuthenticated, isTrue);
      expect(repo.currentFarmer?.email, 'chaitanya@smartsoil.org');
      expect(repo.currentFarmer?.displayName, 'Chaitanya Sharma');
    });

    test('rejects login with wrong password and updates error state', () async {
      final success = await repo.login(
        email: 'chaitanya@smartsoil.org',
        password: 'WrongPassword!',
      );

      expect(success, isFalse);
      expect(repo.currentState.hasError, isTrue);
      expect(repo.currentState.errorMessage, contains('Incorrect password'));
    });

    test('rejects login with non-existent user email', () async {
      final success = await repo.login(
        email: 'unknown@farmer.org',
        password: 'Password123',
      );

      expect(success, isFalse);
      expect(repo.currentState.hasError, isTrue);
      expect(repo.currentState.errorMessage, contains('No account found'));
    });

    test('registers a new farmer account successfully', () async {
      final success = await repo.register(
        email: 'ramesh@farm.org',
        password: 'RameshPass@2026',
        displayName: 'Ramesh Kumar',
        phoneNumber: '+91-9988776655',
      );

      expect(success, isTrue);
      expect(repo.currentState.isAuthenticated, isTrue);
      expect(repo.currentFarmer?.email, 'ramesh@farm.org');
      expect(repo.currentFarmer?.displayName, 'Ramesh Kumar');
      expect(repo.currentFarmer?.uid, startsWith('farmer_'));
    });

    test('rejects registration with existing email', () async {
      final success = await repo.register(
        email: 'chaitanya@smartsoil.org',
        password: 'NewPassword@123',
      );

      expect(success, isFalse);
      expect(repo.currentState.hasError, isTrue);
      expect(repo.currentState.errorMessage, contains('already exists'));
    });

    test('rejects registration with weak password', () async {
      final success = await repo.register(
        email: 'newuser@farm.org',
        password: '123',
      );

      expect(success, isFalse);
      expect(repo.currentState.hasError, isTrue);
      expect(repo.currentState.errorMessage, contains('at least 6 characters'));
    });

    test('signs out active farmer and transitions to unauthenticated state', () async {
      await repo.login(
        email: 'chaitanya@smartsoil.org',
        password: 'Farmer@123',
      );
      expect(repo.currentState.isAuthenticated, isTrue);

      await repo.logout();
      expect(repo.currentState.status, AuthStatus.unauthenticated);
      expect(repo.currentFarmer, isNull);
    });

    test('verifies active session token validity', () async {
      await repo.login(
        email: 'chaitanya@smartsoil.org',
        password: 'Farmer@123',
      );

      final isValid = await repo.verifyCurrentSession();
      expect(isValid, isTrue);
    });
  });
}
