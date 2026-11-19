import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/auth_notifier.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/nop/presentation/nop_list_screen.dart';
import '../../features/akun/presentation/akun_screen.dart';
import '../../features/pengajuan/presentation/objek_baru_screen.dart';
import '../../features/pengajuan/presentation/pilih_mutasi_screen.dart';
import '../../features/pengajuan/presentation/mutasi_penuh_screen.dart';
import '../../features/pengajuan/presentation/mutasi_sebagian_screen.dart';
import '../../features/pengajuan/presentation/mutasi_penggabungan_screen.dart';
import '../../features/pengajuan/presentation/sket_lokasi_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (authState.status == AuthStatus.initial) {
        return null;
      }

      if (!isAuth && !isLoggingIn) {
        return '/login';
      }

      if (isAuth && isLoggingIn) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/nop',
                builder: (context, state) => const NopListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/akun',
                builder: (context, state) => const AkunScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/pengajuan/objek-baru',
        builder: (context, state) => const ObjekBaruScreen(),
      ),
      GoRoute(
        path: '/pengajuan/pilih-mutasi',
        builder: (context, state) => const PilihMutasiScreen(),
      ),
      GoRoute(
        path: '/pengajuan/mutasi-penuh',
        builder: (context, state) => const MutasiPenuhScreen(),
      ),
      GoRoute(
        path: '/pengajuan/mutasi-sebagian',
        builder: (context, state) => const MutasiSebagianScreen(),
      ),
      GoRoute(
        path: '/pengajuan/mutasi-penggabungan',
        builder: (context, state) => const MutasiPenggabunganScreen(),
      ),
      GoRoute(
        path: '/pengajuan/sket-lokasi',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SketLokasiScreen(
            initialGeoJson: extra?['geometry'] as String?,
            onSave: extra?['onSave'] as void Function(String geoJson)?,
          );
        },
      ),
    ],
  );
});

class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'NOP',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
