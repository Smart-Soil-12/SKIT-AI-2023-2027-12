import 'farmer_user.dart';

/// Enum representing the state of user authentication.
enum AuthStatus {
  unauthenticated,
  authenticating,
  authenticated,
  error,
}

/// Immutable state container holding authentication lifecycle status,
/// the current [FarmerUser], and any error feedback.
class AuthState {
  final AuthStatus status;
  final FarmerUser? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  /// Initial idle unauthenticated state.
  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = null;

  /// Loading state while communicating with Firebase Auth / Backend.
  const AuthState.authenticating()
      : status = AuthStatus.authenticating,
        user = null,
        errorMessage = null;

  /// Successfully authenticated state with active farmer profile.
  const AuthState.authenticated(FarmerUser farmer)
      : status = AuthStatus.authenticated,
        user = farmer,
        errorMessage = null;

  /// Failed authentication state with user-facing error message.
  const AuthState.error(String message)
      : status = AuthStatus.error,
        user = null,
        errorMessage = message;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isAuthenticating => status == AuthStatus.authenticating;
  bool get hasError => status == AuthStatus.error && errorMessage != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => status.hashCode ^ user.hashCode ^ errorMessage.hashCode;
}
