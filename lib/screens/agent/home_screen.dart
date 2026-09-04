import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../../providers/screening_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/index.dart';
import 'patient_list_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import '../shared/gait_test_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeDashboard(),
    const PatientListScreen(),
    const GaitTestScreen(),
    const ReportsScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    final screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    await patientProvider.loadPatients();
    await screeningProvider.loadScreenings();
    await settingsProvider.checkConnectivity();
    settingsProvider.startConnectivityListener();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavItem(icon: Icons.home_outlined, label: 'Home'),
          BottomNavItem(icon: Icons.people_outline, label: 'Patients'),
          BottomNavItem(icon: Icons.medical_services_outlined, label: 'Screening'),
          BottomNavItem(icon: Icons.description_outlined, label: 'Reports'),
          BottomNavItem(icon: Icons.settings_outlined, label: 'Settings'),
        ],
      ),
    );
  }
}

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
    final screeningProvider = Provider.of<ScreeningProvider>(context, listen: false);
    _riskDistributionFuture = screeningProvider.getRiskDistribution();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final patientProvider = Provider.of<PatientProvider>(context);
    final screeningProvider = Provider.of<ScreeningProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Dashboard',
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Icon(
                settingsProvider.isConnected ? Icons.cloud_done : Icons.cloud_off,
                color: settingsProvider.isConnected
                    ? AppColors.success
                    : AppColors.textTertiary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              Text(
                'Welcome back,',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                authProvider.currentUser?.fullName ?? 'Health Worker',
                style: AppTypography.headlineLarge,
              ).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: AppSpacing.xl),

              // Stats cards - animated with count-up
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Total Patients',
                      value: patientProvider.patients.length,
                      icon: Icons.people,
                      iconColor: AppColors.primary,
                      backgroundColor: AppColors.surface,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      title: 'Screenings',
                      value: screeningProvider.screenings.length,
                      icon: Icons.medical_services,
                      iconColor: AppColors.accent,
                      backgroundColor: AppColors.surface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: FutureBuilder<Map<String, int>>(
                      future: _riskDistributionFuture,
                      builder: (context, snapshot) {
                        final highRiskCount = snapshot.data?['high'] ?? 0;
                        return StatCard(
                          title: 'High Risk',
                          value: highRiskCount,
                          icon: Icons.warning,
                          iconColor: AppColors.riskHigh,
                          backgroundColor: AppColors.surface,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCard(
                      title: 'Pending Sync',
                      value: settingsProvider.pendingSyncCount,
                      icon: Icons.sync,
                      iconColor: AppColors.info,
                      backgroundColor: AppColors.surface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Quick actions
              Text(
                'Quick Actions',
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: AppSpacing.md),
              _buildQuickActionCard(
                context,
                'New Screening',
                'Start a new OA risk assessment',
                Icons.add_circle_outline,
                AppColors.primary,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PatientListScreen()),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildQuickActionCard(
                context,
                'Add Patient',
                'Register a new patient',
                Icons.person_add,
                AppColors.accent,
                () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PatientListScreen()),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Recent patients
              if (patientProvider.patients.isNotEmpty) ...[
                Text(
                  'Recent Patients',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
                const SizedBox(height: AppSpacing.md),
                ...patientProvider.patients.take(3).map((patient) {
                  return _buildPatientCard(context, patient);
                }),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: PulsingFAB(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PatientListScreen()),
          );
        },
        icon: Icons.add,
        tooltip: 'New Screening',
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      isClickable: true,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: color,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(
      begin: 0.1,
      end: 0,
      duration: 400.ms,
    );
  }

  Widget _buildPatientCard(BuildContext context, patient) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {
        // Navigate to patient profile
      },
      isClickable: true,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primarySurface,
            child: Text(
              patient.name.substring(0, 1).toUpperCase(),
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${patient.age} years • ${patient.gender}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(
      begin: 0.1,
      end: 0,
      duration: 400.ms,
    );
  }
}
