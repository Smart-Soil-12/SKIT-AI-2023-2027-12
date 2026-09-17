import 'dart:async';
import '../../domain/models/auth_state.dart';
import '../../domain/models/farmer_user.dart';
import '../services/auth_service.dart';

/// Repository managing the farmer authentication session, state transitions,
/// and error notifications for UI consumption.
class AuthRepository {
  final AuthService _authService;
  final StreamController<AuthState> _stateController = StreamController<AuthState>.broadcast();
  AuthState _currentState = const AuthState.unauthenticated();

  AuthRepository({AuthService? authService})
      : _authService = authService ?? MockAuthService() {
    // Listen to underlying service auth changes
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        _updateState(AuthState.authenticated(user));
      } else {
        _updateState(const AuthState.unauthenticated());
      }
    });

    // Initialize session if user already exists
    if (_authService.currentUser != null) {
      _updateState(AuthState.authenticated(_authService.currentUser!));
    }
  }

  /// Current snapshot of the authentication state.
  AuthState get currentState => _currentState;

  /// Currently logged-in farmer profile, or null.
  FarmerUser? get currentFarmer => _authService.currentUser;

  /// Stream of authentication states (useful for StreamBuilder or Bloc/Provider).
  Stream<AuthState> get authStateStream => _stateController.stream;

  /// Registers a new farmer account and updates the reactive session.
  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
    String? phoneNumber,
  }) async {
    _updateState(const AuthState.authenticating());
    try {
      final user = await _authService.registerWithEmailPassword(
        email,
        password,
        displayName: displayName,
        phoneNumber: phoneNumber,
      );
      _updateState(AuthState.authenticated(user));
      return true;
    } on AuthException catch (e) {
      _updateState(AuthState.error(e.message));
      return false;
    } catch (e) {
      _updateState(AuthState.error('An unexpected error occurred: $e'));
      return false;
    }
  }

  /// Logs in an existing farmer.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _updateState(const AuthState.authenticating());
    try {
      final user = await _authService.signInWithEmailPassword(email, password);
      _updateState(AuthState.authenticated(user));
      return true;
    } on AuthException catch (e) {
      _updateState(AuthState.error(e.message));
      return false;
    } catch (e) {
      _updateState(AuthState.error('Login failed. Please check network connectivity: $e'));
      return false;
    }
  }

  /// Verifies current session token validity.
  Future<bool> verifyCurrentSession() async {
    final user = _authService.currentUser;
    if (user == null || user.idToken == null) {
      _updateState(const AuthState.unauthenticated());
      return false;
    }
    final isValid = await _authService.verifyToken(user.idToken!);
    if (!isValid) {
      await logout();
      return false;
    }
    return true;
  }

  /// Terminates the current farmer session.
  Future<void> logout() async {
    await _authService.signOut();
    _updateState(const AuthState.unauthenticated());
  }

  void _updateState(AuthState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  void dispose() {
    _stateController.close();
  }
}
