import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../screens/shared/splash_screen.dart';
import '../screens/shared/language_selection_screen.dart';
import '../screens/shared/role_selection_screen.dart';
import '../screens/shared/login_screen.dart';
import '../screens/shared/signup_screen.dart';
import '../screens/agent/home_screen.dart';

// Custom page transitions
class CustomTransition extends CustomTransitionPage {
  CustomTransition({
    required super.child,
    super.key,
  }) : super(
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

class FadeTransitionPage extends CustomTransitionPage {
  FadeTransitionPage({
    required super.child,
    super.key,
  }) : super(
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

// Router configuration
final appRouter = GoRouter(
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Page not found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(state.uri.toString()),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/splash'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => FadeTransitionPage(
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/language',
      pageBuilder: (context, state) => FadeTransitionPage(
        child: const LanguageSelectionScreen(),
      ),
    ),
    GoRoute(
      path: '/role',
      pageBuilder: (context, state) => FadeTransitionPage(
        child: const RoleSelectionScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'agent';
        return CustomTransition(
          child: LoginScreen(role: role),
        );
      },
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'agent';
        return CustomTransition(
          child: SignupScreen(role: role),
        );
      },
    ),
    GoRoute(
      path: '/agent/home',
      pageBuilder: (context, state) => FadeTransitionPage(
        child: const AgentHomeScreen(),
      ),
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        if (!authProvider.isAuthenticated) {
          return '/role';
        }
        if (authProvider.userRole != 'agent') {
          return '/user/home';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/user/home',
      pageBuilder: (context, state) => FadeTransitionPage(
        child: const UserHomeScreen(),
      ),
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        if (!authProvider.isAuthenticated) {
          return '/role';
        }
        if (authProvider.userRole != 'user') {
          return '/agent/home';
        }
        return null;
      },
    ),
  ],
);

// Placeholder screens for user flow
class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Home')),
      body: const Center(child: Text('User Home - Coming Soon')),
    );
  }
}

// Renamed agent home screen
class AgentHomeScreen extends StatelessWidget {
  const AgentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}