import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/config/app_colors.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/labels/qlz_label.dart';

/// A chart widget for displaying study activity over time
class StudyActivityChart extends StatelessWidget {
  /// Daily study time in seconds, keyed by date string
  final Map<String, int> dailyStudyTime;

  /// Daily terms learned count, keyed by date string
  final Map<String, int> dailyTermsLearned;

  /// Selected time period in days
  final int timePeriod;

  /// Time period options for dropdown
  final List<int> periodOptions;

  /// Callback when time period changes
  final Function(int) onPeriodChanged;

  /// Creates a study activity chart
  const StudyActivityChart({
    super.key,
    required this.dailyStudyTime,
    required this.dailyTermsLearned,
    required this.timePeriod,
    this.periodOptions = const [7, 14, 30, 90],
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return QlzCard(
      backgroundColor: AppColors.darkCard,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              QlzLabel(
                'HOẠT ĐỘNG',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              _buildPeriodDropdown(context),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildChart(context),
          ),
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: timePeriod,
          icon: const Icon(Icons.arrow_drop_down,
              color: AppColors.darkTextSecondary),
          dropdownColor: AppColors.darkCard,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkText,
              ),
          onChanged: (int? newValue) {
            if (newValue != null) {
              onPeriodChanged(newValue);
            }
          },
          items: periodOptions.map<DropdownMenuItem<int>>((int value) {
            String label;
            switch (value) {
              case 7:
                label = '7 ngày';
                break;
              case 14:
                label = '14 ngày';
                break;
              case 30:
                label = '30 ngày';
                break;
              case 90:
                label = '3 tháng';
                break;
              default:
                label = '$value ngày';
            }

            return DropdownMenuItem<int>(
              value: value,
              child: Text(label),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChart(BuildContext context) {
    final sortedDates = dailyStudyTime.keys.toList()..sort();
    final displayDates = sortedDates.length > timePeriod
        ? sortedDates.sublist(sortedDates.length - timePeriod)
        : sortedDates;

    int maxStudyTime = 0;
    int maxTermsLearned = 0;

    for (final date in displayDates) {
      final studyTime = dailyStudyTime[date] ?? 0;
      final termsLearned = dailyTermsLearned[date] ?? 0;
      maxStudyTime = studyTime > maxStudyTime ? studyTime : maxStudyTime;
      maxTermsLearned =
          termsLearned > maxTermsLearned ? termsLearned : maxTermsLearned;
    }

    maxStudyTime = maxStudyTime > 0 ? maxStudyTime : 3600;
    maxTermsLearned = maxTermsLearned > 0 ? maxTermsLearned : 20;

    return Row(
      children: [
        _buildLeftAxis(context, maxStudyTime),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: displayDates.map((date) {
                    final studyTimeValue = dailyStudyTime[date] ?? 0;
                    final termsLearnedValue = dailyTermsLearned[date] ?? 0;

                    final studyTimeHeight =
                        maxStudyTime > 0 ? studyTimeValue / maxStudyTime : 0.0;
                    final termsLearnedHeight = maxTermsLearned > 0
                        ? termsLearnedValue / maxTermsLearned
                        : 0.0;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildBarGroup(
                          context,
                          studyTimeHeight,
                          termsLearnedHeight,
                          studyTimeValue,
                          termsLearnedValue,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 20,
                child: Row(
                  children: displayDates.map((date) {
                    final parts = date.split('-');
                    final label =
                        parts.length >= 3 ? '${parts[2]}/${parts[1]}' : date;

                    return Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.darkTextSecondary,
                                  ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        _buildRightAxis(context, maxTermsLearned),
      ],
    );
  }

  Widget _buildLeftAxis(BuildContext context, int maxValue) {
    final labels = List.generate(5, (index) {
      final value = (maxValue * index / 4).round();
      return value >= 3600
          ? '${(value / 3600).toStringAsFixed(1)}h'
          : '${(value / 60).round()}m';
    });

    return SizedBox(
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: labels.reversed.map((label) {
          return Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRightAxis(BuildContext context, int maxValue) {
    final labels = List.generate(5, (index) {
      return ((maxValue * index / 4).round()).toString();
    });

    return SizedBox(
      width: 30,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: labels.reversed.map((label) {
          return Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.darkTextSecondary,
                ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarGroup(
    BuildContext context,
    double studyTimeHeight,
    double termsLearnedHeight,
    int studyTimeValue,
    int termsLearnedValue,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight * studyTimeHeight;
              return Tooltip(
                message: _formatTime(studyTimeValue),
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.darkText,
                    ),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  height: height > 2 ? height : (studyTimeValue > 0 ? 2 : 0),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 1),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final height = constraints.maxHeight * termsLearnedHeight;
              return Tooltip(
                message: '$termsLearnedValue từ',
                textStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.darkText,
                    ),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  height: height > 2 ? height : (termsLearnedValue > 0 ? 2 : 0),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(context, AppColors.primary, 'Thời gian học'),
        const SizedBox(width: 24),
        _buildLegendItem(context, AppColors.success, 'Số từ đã học'),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkTextSecondary,
              ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '$seconds giây';
    } else if (seconds < 3600) {
      return '${(seconds / 60).round()} phút';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '$hours giờ ${minutes > 0 ? '$minutes phút' : ''}';
    }
  }
}
