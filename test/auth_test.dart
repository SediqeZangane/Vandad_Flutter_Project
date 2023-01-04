// import 'package:test/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vandad_flutter_project/services/auth/auth_exceptions.dart';
import 'package:vandad_flutter_project/services/auth/auth_provider.dart';
import 'package:vandad_flutter_project/services/auth/auth_service.dart';
import 'package:vandad_flutter_project/services/auth/auth_user.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    final service = AuthService(provider);
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('Cannot log out if not initialized', () {
      expect(service.logOut(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('Should be able to be initialized ', () async {
      await service.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(service.currentUser, null);
    });

    test('Should be able to initialize in less than 2 seconds', () async {
      await service.initialize();
      expect(provider.isInitialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('Create user should delegate to logIn function', () async {
      final badEmailUser = service.createUser(
          email: 'zangane@sedi.com', password: 'anyPassword');

      expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundAuthException>()));

      final badPasswordUser =
          service.createUser(email: 'someone@sedi.com', password: '3317');

      expect(badPasswordUser, throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final user = await service.createUser(email: 'sedi', password: '3653');
      expect(service.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () {
      service.sendEmailVerification();
      final user = service.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await service.logOut();
      await service.logIn(email: 'email', password: 'password');
      final user = service.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;
  AuthUser? _user;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return logIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'zangane@sedi.com') throw UserNotFoundAuthException();
    if (password == '3317') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }
}
