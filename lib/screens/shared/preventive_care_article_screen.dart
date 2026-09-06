import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';

// The _Article type from the category screen is passed as dynamic here to
// avoid circular dependency — it has id, title, summary, icon, readTime, content.
class PreventiveCareArticleScreen extends StatelessWidget {
  final dynamic article; // _Article from preventive_care_category_screen, or Map for deep links
  final LinearGradient? gradient;

  const PreventiveCareArticleScreen({
    super.key,
    required this.article,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ??
        const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Compact effectiveGradient app bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: effectiveGradient.colors.first,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: effectiveGradient),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.screenPaddingLg, 50, AppSpacing.screenPaddingLg, AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(article.icon as IconData, color: Colors.white, size: 18),
                            const SizedBox(width: 6),
                            Row(
                              children: [
                                const Icon(Icons.schedule_outlined, color: Colors.white70, size: 12),
                                const SizedBox(width: 4),
                                Text(article.readTime as String, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title: Text(
                article.title as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
            ),
          ),

          // ── Article content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
                    decoration: BoxDecoration(
                      color: effectiveGradient.colors.first.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: effectiveGradient.colors.first.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      article.summary as String,
                      style: AppTypography.bodyMedium.copyWith(
                        color: effectiveGradient.colors.first,
                        fontWeight: AppTypography.medium,
                        height: 1.5,
                      ),
                    ),
                  ).animate().fadeIn(duration: AppMotion.standard).slideY(begin: 0.08, end: 0, duration: AppMotion.standard, curve: AppMotion.curve),

                  const SizedBox(height: AppSpacing.xl),

                  // Full content — parse basic markdown-like text
                  ..._parseContent(article.content as String, effectiveGradient)
                      .asMap()
                      .entries
                      .map((e) => e.value
                          .animate(delay: (e.key * 40 + 100).ms)
                          .fadeIn(duration: AppMotion.standard)),

                  const SizedBox(height: AppSpacing.xxl),

                  // Action card at bottom
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.share_outlined, color: AppColors.primary, size: 20),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'Share this tip with your patient or community',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('Share', style: AppTypography.labelMedium.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ).animate(delay: 400.ms).fadeIn(duration: AppMotion.standard),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _parseContent(String content, LinearGradient effectiveGradient) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (final line in lines) {
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: AppSpacing.sm));
      } else if (line.startsWith('**') && line.endsWith('**')) {
        // Bold heading
        final text = line.replaceAll('**', '');
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs, top: AppSpacing.sm),
          child: Text(text, style: AppTypography.bodyMedium.copyWith(fontWeight: AppTypography.semiBold)),
        ));
      } else if (line.startsWith('- ')) {
        // Bullet point
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4, left: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(width: 5, height: 5, decoration: BoxDecoration(color: effectiveGradient.colors.first, shape: BoxShape.circle)),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(line.substring(2), style: AppTypography.bodySmall.copyWith(height: 1.5))),
            ],
          ),
        ));
      } else if (RegExp(r'^\d+\.').hasMatch(line)) {
        // Numbered list
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4, left: AppSpacing.sm),
          child: Text(line, style: AppTypography.bodySmall.copyWith(height: 1.5)),
        ));
      } else {
        // Normal paragraph
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: Text(line, style: AppTypography.bodySmall.copyWith(height: 1.6, color: AppColors.textPrimary)),
        ));
      }
    }

    return widgets;
  }
}
