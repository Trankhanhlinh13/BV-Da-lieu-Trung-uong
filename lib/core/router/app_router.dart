import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/auth_screens.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/appointments/appointments_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/change_password_screen.dart';
import '../../features/booking/booking_screen.dart';
import '../../features/booking/booking_confirm_screen.dart';
import '../../features/booking/booking_success_screen.dart';
import '../../features/today/today_screen.dart';
import '../../features/chatbot/chatbot_screen.dart';
import '../../features/about/about_screen.dart';
import '../../models/booking_draft.dart';
import '../../features/health_record/health_record_screen.dart';
import '../../features/health_record/health_visit_detail_screen.dart';
import '../../models/health_record.dart';
import '../../features/lookup/lookup_screen.dart';
import '../../features/meal/meal_screen.dart';
import '../../features/meal/meal_menu_screen.dart';
import '../../features/meal/meal_cart_screen.dart';
import '../../models/meal_order.dart';
import '../../features/map/hospital_map_screen.dart';
import '../../features/family/family_members_screen.dart';
import '../../features/family/add_member_screen.dart';
import '../state/family_members_state.dart';
import '../../features/shell/main_shell.dart';
import '../state/auth_state.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefresh(ref);
  final router = GoRouter(initialLocation: '/splash', refreshListenable: refresh, redirect: (context, state) {
    final loggedIn = ref.read(authProvider).isLoggedIn;
    const publicPaths = {
      '/splash',
      '/login',
      '/register',
      '/otp',
      '/forgot-password',
      '/reset-password',
    };
    final path = state.uri.path;
    // Splash must be visible on cold launch for both authenticated states.
    if (path == '/splash') return null;
    if (!loggedIn && !publicPaths.contains(path)) return '/login';
    if (loggedIn && publicPaths.contains(path)) return '/home';
    return null;
  }, routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(
      path: '/otp',
      builder: (_, state) => OtpScreen(
        phone: state.uri.queryParameters['phone'],
        purpose: state.uri.queryParameters['purpose'],
      ),
    ),
    GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/reset-password', builder: (_, __) => const ResetPasswordScreen()),
    GoRoute(
      path: '/change-password',
      builder: (_, __) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/booking/confirm',
      builder: (_, state) {
        final draft = state.extra;
        return draft is BookingDraft
            ? BookingConfirmScreen(draft: draft)
            : const PlaceholderScreen(title: 'Không có thông tin đặt lịch');
      },
    ),
    GoRoute(
      path: '/booking/success',
      builder: (_, state) {
        final draft = state.extra;
        return draft is BookingDraft
            ? BookingSuccessScreen(draft: draft)
            : const PlaceholderScreen(title: 'Không có thông tin lịch hẹn');
      },
    ),
    GoRoute(
      path: '/booking',
      builder: (_, state) => BookingScreen(
        patient: state.uri.queryParameters['patient'] ?? 'owner',
        selectMember: state.uri.queryParameters['selectMember'] == 'true',
        initialDepartment: state.uri.queryParameters['department'],
        initialDoctor: state.uri.queryParameters['doctor'],
        initialTime: state.uri.queryParameters['time'],
        initialDate: state.uri.queryParameters['date'],
      ),
    ),
    GoRoute(
      path: '/health-record',
      builder: (_, __) => const HealthRecordScreen(),
    ),
    GoRoute(
      path: '/health-record/detail',
      builder: (_, state) {
        final record = state.extra;
        return record is HealthRecord
            ? HealthVisitDetailScreen(record: record)
            : const PlaceholderScreen(title: 'Không tìm thấy lượt khám');
      },
    ),
    GoRoute(
      path: '/lookup',
      builder: (_, __) => const LookupScreen(),
    ),
    GoRoute(
      path: '/meal',
      builder: (_, __) => const MealMembersScreen(),
    ),
    GoRoute(
      path: '/meal-menu',
      builder: (_, state) => MealMenuScreen(
        memberName: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/meal-cart',
      builder: (_, state) {
        final payload = state.extra;
        return payload is MealCartPayload
            ? MealCartScreen(payload: payload)
            : const PlaceholderScreen(title: 'Giỏ suất ăn trống');
      },
    ),
    GoRoute(
      path: '/map',
      builder: (_, __) => const HospitalMapScreen(),
    ),
    GoRoute(
      path: '/family',
      builder: (_, __) => const FamilyMembersScreen(),
    ),
    GoRoute(
      path: '/family/add',
      builder: (_, __) => const AddMemberScreen(),
    ),
    GoRoute(
      path: '/family/edit/:id',
      builder: (_, state) {
        final id = state.pathParameters['id'];
        final members = ref.read(familyMembersProvider);
        final matchingMembers = members.where((item) => item.id == id);
        final member = matchingMembers.isEmpty ? null : matchingMembers.first;
        return member == null
            ? const PlaceholderScreen(title: 'Không tìm thấy thành viên')
            : AddMemberScreen(member: member);
      },
    ),
    StatefulShellRoute.indexedStack(builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell), branches: [
      StatefulShellBranch(routes: [GoRoute(path: '/home', builder: (_, __) => const HomeScreen())]),
      StatefulShellBranch(routes: [GoRoute(path: '/appointments', builder: (_, __) => const AppointmentsScreen())]),
      StatefulShellBranch(routes: [GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen())]),
      StatefulShellBranch(routes: [GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen())]),
    ]),
    GoRoute(path: '/today', builder: (_, __) => const TodayScreen()),
    GoRoute(path: '/chatbot', builder: (_, __) => const ChatbotScreen()),
    GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
    for (final entry in const {'/chemo': 'Hóa trị'}.entries)
      GoRoute(path: entry.key, builder: (_, __) => PlaceholderScreen(title: entry.value)),
  ]);
  ref.onDispose(() { router.dispose(); refresh.dispose(); });
  return router;
});

class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) { ref.listen<AuthState>(authProvider, (_, __) => notifyListeners()); }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title}); final String title;
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(title), centerTitle: true, backgroundColor: const Color(0xFF0B5CB5), foregroundColor: Colors.white), body: Center(child: Text(title, style: Theme.of(context).textTheme.titleLarge)));
}
