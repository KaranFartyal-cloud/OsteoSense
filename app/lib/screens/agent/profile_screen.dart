import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/index.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Profile',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon')),
              );
            },
          ),
        ],
      ),
      body: user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Not Logged In',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  CustomButton(
                    text: 'Sign In',
                    onPressed: () {
                      // TODO: Navigate to login
                    },
                    variant: ButtonVariant.primary,
                    size: ButtonSize.medium,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  _buildProfileHeader(user)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeOut,
                      ),
                  const SizedBox(height: AppSpacing.xl),

                  // Quick Stats
                  Text(
                    'Quick Stats',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
                  const SizedBox(height: AppSpacing.md),
                  _buildStatsGrid()
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 150.ms),
                  const SizedBox(height: AppSpacing.xl),

                  // About Section
                  Text(
                    'About',
                    style: AppTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms),
                  const SizedBox(height: AppSpacing.md),
                  _buildAboutSection(user)
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 250.ms),
                  const SizedBox(height: AppSpacing.xl),

                  // Actions
                  _buildActionButtons()
                      .animate()
                      .fadeIn(duration: 300.ms, delay: 300.ms),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(user) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              (user.name?.substring(0, 1) ?? 'A').toUpperCase(),
              style: AppTypography.displayLarge.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ?? 'Health Worker',
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Health Care Agent',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Active',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      children: [
        _buildStatTile('Screenings', '24', Icons.assignment, AppColors.primary),
        _buildStatTile('Patients', '18', Icons.people, AppColors.accent),
        _buildStatTile(
          'High Risk',
          '5',
          Icons.warning,
          AppColors.riskHigh,
        ),
        _buildStatTile(
          'Avg Confidence',
          '94%',
          Icons.trending_up,
          AppColors.riskLow,
        ),
      ],
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return CustomCard(
      variant: CardVariant.outlined,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(user) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
      child: Column(
        children: [
          _buildAboutRow('Worker ID:', 'HW-${user.id ?? '00001'}'),
          const SizedBox(height: AppSpacing.md),
          _buildAboutRow('Phone:', user.phone ?? 'N/A'),
          const SizedBox(height: AppSpacing.md),
          _buildAboutRow('Region:', 'Northeast India'),
          const SizedBox(height: AppSpacing.md),
          _buildAboutRow('Joined:', 'Sept 3, 2026'),
        ],
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Download My Data',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Preparing download...')),
            );
          },
          variant: ButtonVariant.secondary,
          size: ButtonSize.large,
          icon: const Icon(Icons.download),
        ),
        const SizedBox(height: AppSpacing.md),
        CustomButton(
          text: 'Logout',
          onPressed: () => _showLogoutConfirm(),
          variant: ButtonVariant.danger,
          size: ButtonSize.large,
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  void _showLogoutConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout?',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'You will be signed out of your account.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          CustomButton(
            text: 'Cancel',
            onPressed: () => Navigator.pop(context),
            variant: ButtonVariant.secondary,
            size: ButtonSize.small,
          ),
          CustomButton(
            text: 'Logout',
            onPressed: () {
              // TODO: Implement logout logic
              Navigator.pop(context);
            },
            variant: ButtonVariant.danger,
            size: ButtonSize.small,
          ),
        ],
      ),
    );
  }
}
