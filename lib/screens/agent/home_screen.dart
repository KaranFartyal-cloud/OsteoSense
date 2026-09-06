import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../../providers/screening_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';
import '../../widgets/common/index.dart';

import 'patient_list_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import '../shared/gait_test_screen.dart';

// ─── Nav item model with outline/filled icon pair ────────────────────────────
class _NavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeDashboard(),
      const PatientListScreen(),
      const GaitTestScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final patientProvider = Provider.of<PatientProvider>(context, listen: false);
      final screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      await patientProvider.loadPatients();
      await screeningProvider.loadScreenings();
      await settingsProvider.checkConnectivity();
      settingsProvider.startConnectivityListener();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: AppMotion.fast,
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: IndexedStack(
          key: ValueKey<int>(_currentIndex),
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: _PremiumGlassNav(
        currentIndex: _currentIndex,
        // Outline ↔ filled icon pairs — the premium "attention-to-detail" swap
        items: const [
          _NavItemData(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Home',
          ),
          _NavItemData(
            icon: Icons.people_outline_rounded,
            selectedIcon: Icons.people_rounded,
            label: 'Patients',
          ),
          _NavItemData(
            icon: Icons.medical_services_outlined,
            selectedIcon: Icons.medical_services_rounded,
            label: 'Screen',
          ),
          _NavItemData(
            icon: Icons.bar_chart_outlined,
            selectedIcon: Icons.bar_chart_rounded,
            label: 'Reports',
          ),
          _NavItemData(
            icon: Icons.settings_outlined,
            selectedIcon: Icons.settings_rounded,
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HOME DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  late Future<Map<String, int>> _riskDistributionFuture;

  @override
  void initState() {
    super.initState();
    _loadRiskDistribution();
  }

  void _loadRiskDistribution() {
    final screeningProvider =
        Provider.of<ScreeningProvider>(context, listen: false);
    _riskDistributionFuture = screeningProvider.getRiskDistribution();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final patientProvider = Provider.of<PatientProvider>(context);
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── SIGNATURE CURVED HEADER ───────────────────────────────
            _buildCurvedHeader(context, authProvider, settingsProvider)
                .animate()
                .fadeIn(duration: 800.ms)
                .slideY(begin: -0.15, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

            const SizedBox(height: AppSpacing.lg),

            // ─── BENTO STAT CARDS + AMBIENT ORBS ──────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingLg),
              child: AmbientOrbs(
                primaryColor: AppColors.primary,
                secondaryColor: AppColors.accent,
                child: Column(
                  children: [
                    // Hero card — full width, Total Patients + sparkline
                    // (HeroStatCard has its own entrance animation built-in)
                    HeroStatCard(
                      title: 'Total Patients',
                      value: patientProvider.patients.length,
                      icon: Icons.people_rounded,
                      color: AppColors.primary,
                      sparklineData: const [2, 5, 3, 8, 6, 11, 9],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Asymmetric bento row: tall left | 2-stacked right
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Tall left card — Screenings
                          Expanded(
                            flex: 5,
                            child: CompactStatCard(
                              title: 'Screenings',
                              value: screeningProvider.screenings.length,
                              color: AppColors.accent,
                              subtitle: 'Total sessions',
                            ),
                          ),

                          const SizedBox(width: AppSpacing.md),

                          // Right column — 2 stacked smaller cards with extra delay
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                Expanded(
                                  child: FutureBuilder<Map<String, int>>(
                                    future: _riskDistributionFuture,
                                    builder: (context, snapshot) {
                                      final highRiskCount =
                                          snapshot.data?['high'] ?? 0;
                                      return CompactStatCard(
                                        title: 'High Risk',
                                        value: highRiskCount,
                                        color: AppColors.riskHigh,
                                      )
                                          .animate(delay: 150.ms)
                                          .fadeIn(duration: 800.ms)
                                          .slideX(begin: 0.15, end: 0, duration: 800.ms, curve: Curves.easeOutCubic);
                                    },
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Expanded(
                                  child: CompactStatCard(
                                    title: 'Pending Sync',
                                    value: settingsProvider.pendingSyncCount,
                                    color: AppColors.info,
                                  )
                                      .animate(delay: 250.ms)
                                      .fadeIn(duration: 800.ms)
                                      .slideX(begin: 0.15, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ─── QUICK ACTIONS ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPaddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeader(title: 'Quick Actions')
                      .animate(delay: 350.ms)
                      .fadeIn(duration: 800.ms)
                      .slideX(begin: -0.15, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: AppSpacing.md),

                  PremiumActionCard(
                    title: 'New Screening',
                    subtitle: 'Start an OA risk assessment',
                    icon: Icons.add_circle_outline_rounded,
                    color: AppColors.primary,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientListScreen()),
                    ),
                  )
                      .animate(delay: 450.ms)
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: 0.20, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

                  const SizedBox(height: AppSpacing.sm),

                  PremiumActionCard(
                    title: 'Add Patient',
                    subtitle: 'Register a new patient record',
                    icon: Icons.person_add_rounded,
                    color: AppColors.accent,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PatientListScreen()),
                    ),
                  )
                      .animate(delay: 550.ms)
                      .fadeIn(duration: 800.ms)
                      .slideY(begin: 0.20, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // ─── RECENT PATIENTS ───────────────────────────────────────
            if (patientProvider.patients.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenPaddingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(
                      title: 'Recent Patients',
                      accentColor: AppColors.accent,
                    )
                        .animate(delay: 650.ms)
                        .fadeIn(duration: 800.ms)
                        .slideX(begin: -0.15, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

                    const SizedBox(height: AppSpacing.md),

                    ...patientProvider.patients
                        .take(3)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final i = entry.key;
                      final patient = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _buildPatientCard(context, patient)
                            .animate(delay: Duration(milliseconds: 750 + i * 100))
                            .fadeIn(duration: 800.ms)
                            .slideY(
                              begin: 0.20,
                              end: 0,
                              duration: 800.ms,
                              curve: Curves.easeOutCubic,
                            ),
                      );
                    }),
                  ],
                ),
              ),

            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CURVED HEADER with S-curve clip + geometric deco + editorial typography
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCurvedHeader(
    BuildContext context,
    AuthProvider authProvider,
    SettingsProvider settingsProvider,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, amplitude, child) {
        return ClipPath(
          clipper: HeaderClipper(amplitude: amplitude),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        // Extra bottom padding to account for the curve overhang
        padding: const EdgeInsets.only(bottom: 52),
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: Stack(
          children: [
            // ── Geometric deco overlay ────────────────────────────────
            const Positioned.fill(
              child: CustomPaint(painter: HeaderDecoPainter()),
            ),

            // ── Content ───────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPaddingLg,
                  AppSpacing.screenPaddingLg,
                  AppSpacing.screenPaddingLg,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: app label + connection indicator (NO pill)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'OsteoSense',
                          style: AppTypography.labelMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.65),
                            letterSpacing: 1.4,
                            fontWeight: AppTypography.semiBold,
                          ),
                        ),
                        // Pill-less connection indicator — just icon + text
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              settingsProvider.isConnected
                                  ? Icons.cloud_done_outlined
                                  : Icons.cloud_off_outlined,
                              size: 15,
                              color: settingsProvider.isConnected
                                  ? AppColors.riskLowLight
                                  : AppColors.gray400,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              settingsProvider.isConnected ? 'Synced' : 'Offline',
                              style: AppTypography.labelSmall.copyWith(
                                color: settingsProvider.isConnected
                                    ? AppColors.riskLowLight
                                    : Colors.white.withValues(alpha: 0.5),
                                fontWeight: AppTypography.medium,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Greeting line — light weight, secondary feel
                    Text(
                      _getGreeting(),
                      style: AppTypography.bodyLarge.copyWith(
                        color: Colors.white.withValues(alpha: 0.70),
                        fontWeight: AppTypography.light,
                        letterSpacing: 0.2,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Name — magazine headline scale, tight tracking
                    Text(
                      authProvider.currentUser?.fullName ?? 'Health Worker',
                      style: AppTypography.displaySmall.copyWith(
                        color: Colors.white,
                        fontWeight: AppTypography.extraBold,
                        letterSpacing: -1.2,
                        fontSize: 38,
                        height: 1.1,
                      ),
                    ).animate().fadeIn(duration: AppMotion.slow).slideX(begin: -0.06),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PATIENT CARD — Gradient avatar + risk-level left-edge glow
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPatientCard(BuildContext context, patient) {
    String riskLevel = 'low';
    if (patient.lastScreening != null) {
      riskLevel = patient.lastScreening!.riskLevel ?? 'low';
    }
    final riskColor = AppColors.getRiskColor(riskLevel);
    final isHighRisk = riskLevel.toLowerCase() == 'high';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        // High-risk gets a 3px left-edge color accent to signal at a glance
        border: isHighRisk
            ? Border(
                left: BorderSide(color: riskColor, width: 3),
                top: const BorderSide(color: AppColors.border),
                right: const BorderSide(color: AppColors.border),
                bottom: const BorderSide(color: AppColors.border),
              )
            : Border.all(color: AppColors.border),
        boxShadow: [
          // Standard lift
          const BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
          // Risk-tinted ambient glow — stronger for high risk
          if (isHighRisk)
            BoxShadow(
              color: riskColor.withValues(alpha: 0.14),
              blurRadius: 16,
              offset: const Offset(-2, 4),
              spreadRadius: -1,
            ),
        ],
      ),
      child: Row(
        children: [
          // Deterministic gradient avatar
          GradientAvatar(name: patient.name, size: 44),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: AppTypography.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${patient.age} yrs • ${patient.gender}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: AppTypography.light,
                  ),
                ),
              ],
            ),
          ),

          // Risk badge
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Text(
              riskLevel.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: riskColor,
                fontWeight: AppTypography.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PREMIUM GLASS BOTTOM NAV
// Floating capsule · sliding gradient pill · outline↔filled icon swap
// ═══════════════════════════════════════════════════════════════════════════

class _PremiumGlassNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItemData> items;
  final void Function(int) onTap;

  const _PremiumGlassNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding > 0 ? bottomPadding : 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: AppColors.surface.withValues(alpha: 0.88),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.6), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowDark.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 32,
                  spreadRadius: -4,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / items.length;
                return Stack(
                  children: [
                    // Sliding gradient pill
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      left: currentIndex * itemWidth + (itemWidth * 0.12),
                      top: 8,
                      bottom: 8,
                      width: itemWidth * 0.76,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Icons row — outline when unselected, filled when selected
                    Row(
                      children: List.generate(items.length, (i) {
                        final isSelected = currentIndex == i;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onTap(i),
                            child: SizedBox(
                              height: double.infinity,
                              child: Center(
                                child: AnimatedScale(
                                  scale: isSelected ? 1.15 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutBack,
                                  // AnimatedSwitcher for the icon swap
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    switchInCurve: Curves.easeOutCubic,
                                    switchOutCurve: Curves.easeInCubic,
                                    transitionBuilder: (child, animation) =>
                                        FadeTransition(
                                          opacity: animation,
                                          child: ScaleTransition(
                                            scale: Tween<double>(begin: 0.7, end: 1.0)
                                                .animate(animation),
                                            child: child,
                                          ),
                                        ),
                                    child: Icon(
                                      isSelected
                                          ? items[i].selectedIcon
                                          : items[i].icon,
                                      key: ValueKey(isSelected),
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textTertiary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}