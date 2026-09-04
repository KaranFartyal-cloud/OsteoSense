import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/screening_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../widgets/common/index.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedTab = 0; // 0: Overview, 1: Timeline, 2: Map

  @override
  Widget build(BuildContext context) {
    final screeningProvider = Provider.of<ScreeningProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Analytics & Reports',
        centerTitle: false,
      ),
      body: screeningProvider.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Loading analytics...',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : screeningProvider.screenings.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenPaddingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tab selector
                      _buildTabSelector(),
                      const SizedBox(height: AppSpacing.xl),

                      // Overview tab
                      if (_selectedTab == 0) ...[
                        _buildRiskDistributionChart(screeningProvider)
                            .animate()
                            .fadeIn(duration: 400.ms),
                        const SizedBox(height: AppSpacing.xl),
                        _buildTrendChart(screeningProvider)
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 200.ms),
                        const SizedBox(height: AppSpacing.xl),
                        _buildStatisticsCards(screeningProvider)
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 400.ms),
                      ],

                      // Timeline tab
                      if (_selectedTab == 1)
                        _buildScreeningTimeline(screeningProvider)
                            .animate()
                            .fadeIn(duration: 400.ms),

                      // Map tab (placeholder)
                      if (_selectedTab == 2)
                        _buildLocationView(screeningProvider)
                            .animate()
                            .fadeIn(duration: 400.ms),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTabSelector() {
    return Row(
      children: [
        Expanded(
          child: FilterChip(
            label: const Text('Overview'),
            selected: _selectedTab == 0,
            onSelected: (selected) => setState(() => _selectedTab = 0),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            side: BorderSide(
              color: _selectedTab == 0 ? AppColors.primary : AppColors.border,
              width: _selectedTab == 0 ? 2 : 1,
            ),
            labelStyle: AppTypography.labelMedium.copyWith(
              color: _selectedTab == 0 ? AppColors.primary : AppColors.textSecondary,
              fontWeight: _selectedTab == 0 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilterChip(
            label: const Text('Timeline'),
            selected: _selectedTab == 1,
            onSelected: (selected) => setState(() => _selectedTab = 1),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            side: BorderSide(
              color: _selectedTab == 1 ? AppColors.primary : AppColors.border,
              width: _selectedTab == 1 ? 2 : 1,
            ),
            labelStyle: AppTypography.labelMedium.copyWith(
              color: _selectedTab == 1 ? AppColors.primary : AppColors.textSecondary,
              fontWeight: _selectedTab == 1 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: FilterChip(
            label: const Text('Locations'),
            selected: _selectedTab == 2,
            onSelected: (selected) => setState(() => _selectedTab = 2),
            backgroundColor: AppColors.surface,
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            side: BorderSide(
              color: _selectedTab == 2 ? AppColors.primary : AppColors.border,
              width: _selectedTab == 2 ? 2 : 1,
            ),
            labelStyle: AppTypography.labelMedium.copyWith(
              color: _selectedTab == 2 ? AppColors.primary : AppColors.textSecondary,
              fontWeight: _selectedTab == 2 ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskDistributionChart(ScreeningProvider provider) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Distribution',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildRiskSections(provider),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildRiskSections(ScreeningProvider provider) {
    // Calculate distribution directly from screenings (synchronously)
    final screenings = provider.screenings;
    int low = 0, medium = 0, high = 0;

    for (final screening in screenings) {
      switch (screening.riskLevel) {
        case 'low':
          low++;
          break;
        case 'medium':
          medium++;
          break;
        case 'high':
          high++;
          break;
      }
    }

    final total = low + medium + high;

    if (total == 0) {
      return [
        PieChartSectionData(
          value: 100,
          color: AppColors.surfaceVariant,
          radius: 60,
          title: 'No Data',
          titleStyle: AppTypography.labelMedium,
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: (low / total * 100).toDouble(),
        color: AppColors.riskLow,
        radius: 60,
        title: '${((low / total * 100).toInt())}%',
        titleStyle: AppTypography.labelSmall.copyWith(color: Colors.white),
      ),
      PieChartSectionData(
        value: (medium / total * 100).toDouble(),
        color: AppColors.riskMedium,
        radius: 60,
        title: '${((medium / total * 100).toInt())}%',
        titleStyle: AppTypography.labelSmall.copyWith(color: Colors.white),
      ),
      PieChartSectionData(
        value: (high / total * 100).toDouble(),
        color: AppColors.riskHigh,
        radius: 60,
        title: '${((high / total * 100).toInt())}%',
        titleStyle: AppTypography.labelSmall.copyWith(color: Colors.white),
      ),
    ];
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Low', AppColors.riskLow),
        _buildLegendItem('Medium', AppColors.riskMedium),
        _buildLegendItem('High', AppColors.riskHigh),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTrendChart(ScreeningProvider provider) {
    final screenings = provider.screenings;
    if (screenings.isEmpty) return const SizedBox.shrink();

    // Sort by date
    final sortedScreenings = List.from(screenings)
      ..sort((a, b) => (a.screeningDate ?? DateTime.now())
          .compareTo(b.screeningDate ?? DateTime.now()));

    // Take last 10 screenings
    final recentScreenings = sortedScreenings.take(10).toList();

    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risk Trend (Last 10 Screenings)',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      recentScreenings.length,
                      (index) {
                        final screening = recentScreenings[index];
                        final riskValue =
                            screening.riskLevel == 'high'
                                ? 3.0
                                : screening.riskLevel == 'medium'
                                    ? 2.0
                                    : 1.0;
                        return FlSpot(index.toDouble(), riskValue);
                      },
                    ),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.3),
                        AppColors.primary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: AppColors.surface,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(ScreeningProvider provider) {
    final screenings = provider.screenings;

    // Calculate distribution directly
    int low = 0, medium = 0, high = 0;
    for (final screening in screenings) {
      switch (screening.riskLevel) {
        case 'low':
          low++;
          break;
        case 'medium':
          medium++;
          break;
        case 'high':
          high++;
          break;
      }
    }

    final avgConfidence = screenings.isEmpty
        ? 0.0
        : screenings
                .map((s) => s.confidence ?? 0.0)
                .reduce((a, b) => a + b) /
            screenings.length;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Screenings',
                value: screenings.length,
                icon: Icons.assignment,
                iconColor: AppColors.primary,
                backgroundColor: AppColors.surface,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'Avg Confidence',
                value: (avgConfidence * 100).toInt(),
                subtitle: '%',
                icon: Icons.trending_up,
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
              child: CustomCard(
                variant: CardVariant.riskHigh,
                padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'High Risk',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.riskHigh,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$high',
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.riskHigh,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: CustomCard(
                variant: CardVariant.riskMedium,
                padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medium Risk',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.riskMedium,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$medium',
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.riskMedium,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: CustomCard(
                variant: CardVariant.riskLow,
                padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Low Risk',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.riskLow,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$low',
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.riskLow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScreeningTimeline(ScreeningProvider provider) {
    final screenings = List.from(provider.screenings)
      ..sort((a, b) => (b.screeningDate ?? DateTime.now())
          .compareTo(a.screeningDate ?? DateTime.now()));

    if (screenings.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: List.generate(
        screenings.length,
        (index) {
          final screening = screenings[index];
          final riskColor = AppColors.getRiskColor(screening.riskLevel ?? 'low');

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: CustomCard(
              variant: screening.riskLevel == 'high'
                  ? CardVariant.riskHigh
                  : screening.riskLevel == 'medium'
                      ? CardVariant.riskMedium
                      : CardVariant.riskLow,
              padding: const EdgeInsets.all(AppSpacing.cardPaddingMd),
              onTap: () {
                // Navigate to detailed report
              },
              isClickable: true,
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: riskColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy hh:mm a')
                              .format(screening.screeningDate ?? DateTime.now()),
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${(screening.confidence ?? 0).toInt()}% confidence • ${screening.riskLevel?.toUpperCase() ?? 'LOW'}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
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
          ).animate().slideX(
            begin: -0.2,
            end: 0,
            duration: 300.ms,
            delay: Duration(milliseconds: 50 * index),
            curve: Curves.easeOut,
          );
        },
      ),
    );
  }

  Widget _buildLocationView(ScreeningProvider provider) {
    return CustomCard(
      variant: CardVariant.elevated,
      padding: const EdgeInsets.all(AppSpacing.cardPaddingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location-wise Analysis',
            style: AppTypography.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 64,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Map View Coming Soon',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Location data will be displayed here',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: const Icon(
              Icons.assessment,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No Reports Yet',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Complete screenings to see analytics',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
