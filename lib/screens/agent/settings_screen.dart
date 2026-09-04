import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/index.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Settings',
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Settings Section
            _buildSectionHeader('App Settings')
                .animate()
                .fadeIn(duration: 300.ms),
            const SizedBox(height: AppSpacing.md),
            _buildSettingGroup([
              _buildSettingItem(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                onTap: () => _showLanguageDialog(context, settingsProvider),
              ),
              _buildDivider(),
              _buildToggleSetting(
                icon: Icons.notifications_active,
                title: 'Notifications',
                value: settingsProvider.notificationsEnabled,
                onChanged: (value) {
                  settingsProvider.setNotificationsEnabled(value);
                },
              ),
            ]).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            const SizedBox(height: AppSpacing.xl),

            // Sync & Data Section
            _buildSectionHeader('Sync & Data')
                .animate()
                .fadeIn(duration: 300.ms, delay: 150.ms),
            const SizedBox(height: AppSpacing.md),
            _buildSettingGroup([
              _buildToggleSetting(
                icon: Icons.cloud_sync,
                title: 'Auto-Sync',
                value: settingsProvider.autoSyncEnabled,
                onChanged: (value) {
                  settingsProvider.setAutoSyncEnabled(value);
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.storage,
                title: 'Storage Usage',
                subtitle: '${(5.2).toStringAsFixed(1)} MB',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.delete_outline,
                title: 'Clear Cache',
                subtitle: 'Remove temporary files',
                onTap: () => _showClearCacheDialog(context),
              ),
            ]).animate().fadeIn(duration: 300.ms, delay: 200.ms),
            const SizedBox(height: AppSpacing.xl),

            // About Section
            _buildSectionHeader('About')
                .animate()
                .fadeIn(duration: 300.ms, delay: 250.ms),
            const SizedBox(height: AppSpacing.md),
            _buildSettingGroup([
              _buildSettingItem(
                icon: Icons.info,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.description,
                title: 'Terms of Service',
                onTap: () {},
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                onTap: () {},
              ),
            ]).animate().fadeIn(duration: 300.ms, delay: 300.ms),
            const SizedBox(height: AppSpacing.xl),

            // Danger Zone
            _buildSectionHeader('Danger Zone', isDanger: true)
                .animate()
                .fadeIn(duration: 300.ms, delay: 350.ms),
            const SizedBox(height: AppSpacing.md),
            _buildSettingGroup([
              _buildSettingItem(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                isDanger: true,
                onTap: () => _showLogoutDialog(context),
              ),
            ]).animate().fadeIn(duration: 300.ms, delay: 400.ms),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isDanger = false}) {
    return Text(
      title,
      style: AppTypography.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: isDanger ? AppColors.error : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSettingGroup(List<Widget> children) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: EdgeInsets.zero,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPaddingMd,
            vertical: AppSpacing.cardPaddingMd,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDanger
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(
                  icon,
                  color: isDanger ? AppColors.error : AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDanger ? AppColors.error : AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSetting({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.cardPaddingMd,
        vertical: AppSpacing.cardPaddingMd,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.cardPaddingMd),
      child: Divider(
        color: AppColors.border,
        height: 1,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Language',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'en', provider),
            const SizedBox(height: AppSpacing.md),
            _buildLanguageOption('हिंदी (Hindi)', 'hi', provider),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String label, String code, SettingsProvider provider) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          provider.setLanguage(code);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            label,
            style: AppTypography.bodyMedium,
          ),
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Cache?',
          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will remove temporary files. Continue?',
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
            text: 'Clear',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
              Navigator.pop(context);
            },
            variant: ButtonVariant.danger,
            size: ButtonSize.small,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
