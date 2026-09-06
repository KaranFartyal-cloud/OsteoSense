import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/index.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: 'What is JointSaathi?',
      answer:
          'JointSaathi is an AI-powered app designed to help healthcare workers in rural areas screen for Osteoarthritis (OA) risk. It combines patient questionnaires with gait analysis to provide accurate risk assessments.',
    ),
    FAQItem(
      question: 'How do I add a new patient?',
      answer:
          'Tap the "+" button on the home screen or patient list. Fill in the patient\'s basic information (name, age, gender, location) and submit. The patient will be saved locally and synced when online.',
    ),
    FAQItem(
      question: 'How does the screening work?',
      answer:
          'A screening has two parts: (1) Symptom questionnaire - answer questions about pain, stiffness, and swelling. (2) Gait analysis - walk naturally for 30 seconds while the phone records movement data. The AI model then calculates OA risk.',
    ),
    FAQItem(
      question: 'What do the risk levels mean?',
      answer:
          'LOW: < 3.0 score - Minimal OA risk, routine checkup recommended. MEDIUM: 3.0-5.0 score - Moderate risk, recommend specialist consultation. HIGH: ≥ 5.0 score - High OA risk, urgent referral recommended.',
    ),
    FAQItem(
      question: 'Does the app work offline?',
      answer:
          'Yes! JointSaathi works completely offline. All patient data and screenings are saved locally on your phone. When you connect to internet, the data automatically syncs to the server.',
    ),
    FAQItem(
      question: 'How is my data kept private?',
      answer:
          'All patient data is encrypted locally on your device. Personal identifiers are never sent to servers without consent. You control what data is shared and can delete patient records anytime.',
    ),
    FAQItem(
      question: 'What if the gait test fails?',
      answer:
          'If the gait test doesn\'t work (e.g., insufficient movement detected), simply retry. The app will still provide a risk assessment based on symptom questionnaire using our rule-based algorithm.',
    ),
    FAQItem(
      question: 'Can I edit a patient\'s information?',
      answer:
          'Yes. Go to the patient\'s profile and tap the edit button. You can update name, age, gender, contact info, and other details. Changes are saved locally and synced automatically.',
    ),
    FAQItem(
      question: 'How do I generate a detailed report?',
      answer:
          'After a screening, tap "View Detailed Report" on the risk results screen. You can see the full analysis, contributing factors, and AI reasoning. Reports can be downloaded as PDF.',
    ),
    FAQItem(
      question: 'Is there support for other languages?',
      answer:
          'Currently, JointSaathi supports English and Hindi. You can change the language in Settings. More regional languages will be added based on user feedback.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Help & FAQ',
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Help Section
            _buildQuickHelp()
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(
                  begin: -0.2,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOut,
                ),
            const SizedBox(height: AppSpacing.xl),

            // FAQ Header
            Text(
              'Frequently Asked Questions',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms),
            const SizedBox(height: AppSpacing.md),

            // FAQ Items
            ..._buildFAQItems(),

            const SizedBox(height: AppSpacing.xl),

            // Contact Support
            _buildContactSupport()
                .animate()
                .fadeIn(duration: 300.ms, delay: 500.ms),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickHelp() {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Quick Start Guide',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildQuickStep(1, 'Add patients', 'Tap + to register new patients'),
          const SizedBox(height: AppSpacing.md),
          _buildQuickStep(2, 'New screening', 'Select patient and start assessment'),
          const SizedBox(height: AppSpacing.md),
          _buildQuickStep(
            3,
            'Gait analysis',
            'Follow on-screen instructions for 30 sec walk',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildQuickStep(
            4,
            'View results',
            'Check risk score and AI recommendations',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStep(int step, String title, String description) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: AppTypography.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
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
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildFAQItems() {
    return List.generate(
      faqItems.length,
      (index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: _buildFAQItem(faqItems[index], index)
            .animate()
            .fadeIn(
              duration: 300.ms,
              delay: Duration(milliseconds: 150 + (index * 50)),
            )
            .slideX(
              begin: -0.1,
              end: 0,
              duration: 300.ms,
              delay: Duration(milliseconds: 150 + (index * 50)),
              curve: Curves.easeOut,
            ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem item, int index) {
    return CustomCard(
      variant: CardVariant.outlined,
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        title: Text(
          item.question,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Text(
          '${index + 1}',
          style: AppTypography.labelMedium.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        tilePadding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.cardPaddingMd,
              vertical: AppSpacing.cardPaddingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(color: AppColors.border),
                const SizedBox(height: AppSpacing.md),
                Text(
                  item.answer,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSupport() {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: const Icon(
                  Icons.headset_mic,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Still Need Help?',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Contact our support team for assistance:',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildContactOption(Icons.email, 'Email', 'support@jointsaathi.org'),
          const SizedBox(height: AppSpacing.sm),
          _buildContactOption(Icons.phone, 'Phone', '+91-XXXX-XXXX-XX'),
          const SizedBox(height: AppSpacing.sm),
          _buildContactOption(Icons.language, 'Website', 'www.jointsaathi.org'),
        ],
      ),
    );
  }

  Widget _buildContactOption(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
