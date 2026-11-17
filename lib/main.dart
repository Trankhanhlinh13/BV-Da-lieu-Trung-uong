import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() => runApp(const ProviderScope(child: HospitalBookingApp()));

class HospitalBookingApp extends ConsumerWidget {
  const HospitalBookingApp({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(title: 'Bệnh viện Da liễu trung ương', debugShowCheckedModeBanner: false, theme: AppTheme.light, routerConfig: ref.watch(appRouterProvider));
}
