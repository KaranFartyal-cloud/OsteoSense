import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../screens/shared/splash_screen.dart';
import '../screens/shared/language_selection_screen.dart';
import '../screens/shared/role_selection_screen.dart';
import '../screens/shared/login_screen.dart';
import '../screens/shared/signup_screen.dart';
import '../screens/agent/home_screen.dart';
import '../screens/user/user_home_screen.dart';
import '../screens/shared/onboarding_screen.dart';
import '../screens/agent/add_patient_screen.dart';
import '../screens/agent/edit_patient_screen.dart';
import '../screens/shared/symptom_questionnaire_screen.dart';
import '../screens/shared/gait_test_screen.dart';
import '../screens/shared/processing_screen.dart';
import '../screens/shared/risk_result_screen.dart';
import '../screens/shared/detailed_report_screen.dart';
import '../screens/shared/pdf_preview_screen.dart';
import '../screens/shared/preventive_care_home_screen.dart';
import '../screens/shared/preventive_care_category_screen.dart';
import '../screens/shared/preventive_care_article_screen.dart';
import '../models/patient.dart';
import '../models/screening.dart';

// ========================================================================
// PREMIUM PAGE TRANSITIONS
// ========================================================================

/// Shared-axis transition matching Linear/Apple signature motion.
/// Combines slide + fade + subtle scale (0.98→1.0) over 250ms with easeOutCubic.
/// Both incoming and outgoing pages animate simultaneously for a polished layered feel.
class SharedAxisTransition extends CustomTransitionPage {
  SharedAxisTransition({
    required super.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
    transitionDuration: AppMotion.normal,
    reverseTransitionDuration: AppMotion.normal,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: AppMotion.curve,
      );

      return Stack(
        children: [
          // Outgoing page fades out
          FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
              CurvedAnimation(parent: secondaryAnimation, curve: AppMotion.curve),
            ),
          ),
          // Incoming page: slide + fade + scale
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
              child: ScaleTransition(
                scale: Tween<double>(
                  begin: AppMotion.pageScaleBegin,
                  end: AppMotion.pageScaleEnd,
                ).animate(curvedAnimation),
                child: child,
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Fade transition for simpler screens (splash, onboarding)
class FadePageTransition extends CustomTransitionPage {
  FadePageTransition({
    required super.child,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
    transitionDuration: AppMotion.moderate,
    reverseTransitionDuration: AppMotion.moderate,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: AppMotion.curveCrossFade,
        ),
        child: child,
      );
    },
  );
}

class CalmFadeTransitionPage extends CustomTransitionPage {
  CalmFadeTransitionPage({
    required super.child,
    super.key,
  }) : super(
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

class SlideUpTransitionPage extends CustomTransitionPage {
  SlideUpTransitionPage({
    required super.child,
    super.key,
  }) : super(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 0.2),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        ),
      );
    },
  );
}

class RevealTransitionPage extends CustomTransitionPage {
  RevealTransitionPage({
    required super.child,
    super.key,
  }) : super(
    transitionDuration: const Duration(milliseconds: 600),
    reverseTransitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.95, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          ),
          child: child,
        ),
      );
    },
  );
}

// ========================================================================
// ROUTER CONFIGURATION
// ========================================================================

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
      pageBuilder: (context, state) => FadePageTransition(
        key: state.pageKey,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/language',
      pageBuilder: (context, state) => CalmFadeTransitionPage(
        key: state.pageKey,
        child: const LanguageSelectionScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => CalmFadeTransitionPage(
        key: state.pageKey,
        child: const OnboardingScreen(),
      ),
    ),
    GoRoute(
      path: '/role',
      pageBuilder: (context, state) => CalmFadeTransitionPage(
        key: state.pageKey,
        child: const RoleSelectionScreen(),
      ),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'agent';
        return SharedAxisTransition(
          key: state.pageKey,
          child: LoginScreen(role: role),
        );
      },
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'agent';
        return SharedAxisTransition(
          key: state.pageKey,
          child: SignupScreen(role: role),
        );
      },
    ),
    GoRoute(
      path: '/agent/home',
      pageBuilder: (context, state) => SharedAxisTransition(
        key: state.pageKey,
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
      pageBuilder: (context, state) => SharedAxisTransition(
        key: state.pageKey,
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
    GoRoute(
      path: '/agent/add-patient',
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const AddPatientScreen(),
      ),
    ),
    GoRoute(
      path: '/agent/edit-patient',
      pageBuilder: (context, state) {
        final patient = state.extra as Patient?;
        return SlideUpTransitionPage(
          key: state.pageKey,
          child: EditPatientScreen(patient: patient),
        );
      },
    ),
    GoRoute(
      path: '/screening/symptoms',
      pageBuilder: (context, state) {
        final patientId = state.extra as int;
        return SlideUpTransitionPage(
          key: state.pageKey,
          child: SymptomQuestionnaireScreen(patientId: patientId),
        );
      },
    ),
    GoRoute(
      path: '/screening/gait',
      pageBuilder: (context, state) => SlideUpTransitionPage(
        key: state.pageKey,
        child: const GaitTestScreen(),
      ),
    ),
    GoRoute(
      path: '/screening/processing',
      pageBuilder: (context, state) => RevealTransitionPage(
        key: state.pageKey,
        child: const ProcessingScreen(),
      ),
    ),
    GoRoute(
      path: '/screening/result',
      pageBuilder: (context, state) => RevealTransitionPage(
        key: state.pageKey,
        child: RiskResultScreen(screening: state.extra as Screening?),
      ),
    ),
    GoRoute(
      path: '/screening/report',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        final screening = data?['screening'] as Screening?;
        final patient = data?['patient'] as Patient?;

        if (screening == null || patient == null) {
          return CalmFadeTransitionPage(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: Text('Report data not found')),
            ),
          );
        }

        return RevealTransitionPage(
          key: state.pageKey,
          child: DetailedReportScreen(
            screening: screening,
            patient: patient,
          ),
        );
      },
    ),
    GoRoute(
      path: '/screening/pdf',
      pageBuilder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return RevealTransitionPage(
          key: state.pageKey,
          child: PdfPreviewScreen(
            screening: data?['screening'] as Screening?,
            patient: data?['patient'] as Patient?,
          ),
        );
      },
    ),
    GoRoute(
      path: '/preventive-care/home',
      pageBuilder: (context, state) => CalmFadeTransitionPage(
        key: state.pageKey,
        child: const PreventiveCareHomeScreen(),
      ),
    ),
    GoRoute(
      path: '/preventive-care/category/:id',
      pageBuilder: (context, state) {
        final categoryId = state.pathParameters['id']!;
        return CalmFadeTransitionPage(
          key: state.pageKey,
          child: PreventiveCareCategoryScreen(categoryId: categoryId),
        );
      },
    ),
    GoRoute(
      path: '/preventive-care/article/:id',
      pageBuilder: (context, state) {
        final article = state.extra as Map<String, dynamic>?;
        if (article == null) {
          return CalmFadeTransitionPage(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: Text('Article not found')),
            ),
          );
        }
        return CalmFadeTransitionPage(
          key: state.pageKey,
          child: PreventiveCareArticleScreen(article: article),
        );
      },
    ),
  ],
);

// ========================================================================
// PLACEHOLDER SCREENS
// ========================================================================

class AgentHomeScreen extends StatelessWidget {
  const AgentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}