import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../mock/mock_data.dart';
import '../../models/user_profile.dart';

class AuthState {
  const AuthState({this.isLoggedIn = false, this.currentUser});
  final bool isLoggedIn;
  final UserProfile? currentUser;
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();
  void login() => state = AuthState(isLoggedIn: true, currentUser: MockData.user);
  void logout() => state = const AuthState();
}

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);
