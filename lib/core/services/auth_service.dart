import 'dart:async';

// Local Mock User class since we removed Firebase
class MockUser {
  final String uid;
  final String? email;
  final String? displayName;

  MockUser({required this.uid, this.email, this.displayName});
}

abstract class AuthService {
  Stream<MockUser?> get authStateChanges;
  Future<MockUser?> signInWithEmail(String email, String password);
  Future<MockUser?> signInWithGoogle();
  Future<void> signOut();
  Future<MockUser?> signUpWithEmail(String email, String password);
}

class MockAuthService implements AuthService {
  // Simulate a logged out state initially
  final _controller = StreamController<MockUser?>.broadcast();

  @override
  Stream<MockUser?> get authStateChanges => _controller.stream;

  @override
  Future<MockUser?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final user = MockUser(uid: 'mock_123', email: email, displayName: 'Parent Demo');
    _controller.add(user);
    return user;
  }

  @override
  Future<MockUser?> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1));
    final user = MockUser(uid: 'mock_google_123', email: 'demo@gmail.com', displayName: 'Google User');
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _controller.add(null);
  }

  @override
  Future<MockUser?> signUpWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final user = MockUser(uid: 'mock_new_123', email: email, displayName: 'New User');
    _controller.add(user);
    return user;
  }
}
