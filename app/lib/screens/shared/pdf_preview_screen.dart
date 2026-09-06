import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:printing/printing.dart';
import '../../models/screening.dart';
import '../../models/patient.dart';
import '../../services/pdf_generator_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_motion.dart';
import '../../widgets/common/index.dart';

class PdfPreviewScreen extends StatelessWidget {
  final Screening? screening;
  final Patient? patient;

  const PdfPreviewScreen({
    super.key,
    required this.screening,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final screening = this.screening;
    final patient = this.patient;
    if (screening == null || patient == null) {
      return const Scaffold(
        body: Center(child: Text('Missing screening or patient data')),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Report Preview',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => _shareReport(context),
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Download',
            onPressed: () => _downloadReport(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Header info bar
          Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.screenPaddingLg,
              AppSpacing.md,
              AppSpacing.screenPaddingLg,
              0,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.cardPaddingMd,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary, size: 16),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'OA Risk Report — ${patient.name}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: AppTypography.medium,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.getRiskColor(screening.riskLevel ?? 'low').withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    (screening.riskLevel ?? 'low').toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.getRiskColor(screening.riskLevel ?? 'low'),
                      fontWeight: AppTypography.bold,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: AppMotion.standard),

          const SizedBox(height: AppSpacing.md),

          // ── PdfPreview widget from printing package
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPaddingLg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: PdfPreview(
                  build: (_) => PdfService.generateScreeningReport(
                    screening: screening,
                    patient: patient,
                  ),
                  allowSharing: true,
                  allowPrinting: true,
                  canChangePageFormat: false,
                  canDebug: false,
                  loadingWidget: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 16),
                        Text('Generating report...'),
                      ],
                    ),
                  ),
                  pdfFileName: 'OA_Report_${patient.name.replaceAll(' ', '_')}.pdf',
                ),
              ),
            ).animate(delay: 100.ms).fadeIn(duration: AppMotion.slow),
          ),

          // ── Bottom action bar
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenPaddingLg,
              AppSpacing.md,
              AppSpacing.screenPaddingLg,
              AppSpacing.screenPaddingLg + MediaQuery.of(context).padding.bottom,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Share',
                    onPressed: () => _shareReport(context),
                    variant: ButtonVariant.outline,
                    size: ButtonSize.large,
                    icon: const Icon(Icons.share_outlined),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: CustomButton(
                    text: 'Download',
                    onPressed: () => _downloadReport(context),
                    variant: ButtonVariant.primary,
                    size: ButtonSize.large,
                    icon: const Icon(Icons.download_outlined),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: AppMotion.standard),
        ],
      ),
    );
  }

  Future<void> _shareReport(BuildContext context) async {
    final screening = this.screening;
    final patient = this.patient;
    if (screening == null || patient == null) return;
    try {
      final bytes = await PdfService.generateScreeningReport(
        screening: screening,
        patient: patient,
      );
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'OA_Report_${patient.name.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _downloadReport(BuildContext context) async {
    final screening = this.screening;
    final patient = this.patient;
    if (screening == null || patient == null) return;
    try {
      final bytes = await PdfService.generateScreeningReport(
        screening: screening,
        patient: patient,
      );
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to download: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }
}
