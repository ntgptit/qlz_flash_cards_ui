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
    print('StudyActivityChart building with timePeriod: $timePeriod');

    if (timePeriod <= 0 || !periodOptions.contains(timePeriod)) {
      return const QlzCard(
        backgroundColor: AppColors.darkCard,
        padding: EdgeInsets.all(16),
        child: Text('Khoảng thời gian không hợp lệ',
            style: TextStyle(color: AppColors.error)),
      );
    }
    if (dailyStudyTime.isEmpty && dailyTermsLearned.isEmpty) {
      return const QlzCard(
        backgroundColor: AppColors.darkCard,
        padding: EdgeInsets.all(16),
        child: Text('Chưa có dữ liệu hoạt động',
            style: TextStyle(color: AppColors.darkText)),
      );
    }
    return QlzCard(
      backgroundColor: AppColors.darkCard,
      padding: const EdgeInsets.all(16),
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
                      fontSize: 16,
                    ),
              ),
              _buildPeriodDropdown(context),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: _buildChart(context),
          ),
          const SizedBox(height: 16),
          _buildLegend(context),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown(BuildContext context) {
    // Đổi sang button hiển thị dialog picker thay vì dropdown
    return InkWell(
      onTap: () => _showPeriodPicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Đảm bảo container vừa đủ với nội dung
          children: [
            Text(
              _getPeriodLabel(timePeriod),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.darkText,
                    fontSize: 14, // Giảm kích thước font
                  ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: AppColors.darkTextSecondary,
              size: 18, // Giảm kích thước icon
            ),
          ],
        ),
      ),
    );
  }

  // Hiển thị dialog chọn thời gian thay vì dropdown
  void _showPeriodPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.darkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Chọn khoảng thời gian',
                  style:
                      Theme.of(dialogContext).textTheme.titleMedium?.copyWith(
                            color: AppColors.darkText,
                            fontWeight: FontWeight.bold,
                          ),
                ),
                const SizedBox(height: 16),
                ...periodOptions.map((option) => ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      title: Text(
                        _getPeriodLabel(option),
                        style: TextStyle(
                          color: AppColors.darkText,
                          fontWeight: option == timePeriod
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: option == timePeriod
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        // Đóng dialog trước, sau đó mới cập nhật state
                        Navigator.of(dialogContext).pop();
                        // Sử dụng context ngoài để tránh gọi sau khi đã dispose
                        if (option != timePeriod) {
                          // Thêm print để debug
                          print(
                              'Changing time period from $timePeriod to $option');
                          // Chỉ thực hiện khi có sự thay đổi thực sự
                          onPeriodChanged(option);
                        }
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hàm trợ giúp lấy nhãn hiển thị cho khoảng thời gian
  String _getPeriodLabel(int days) {
    return switch (days) {
      7 => '7 ngày',
      14 => '14 ngày',
      30 => '30 ngày',
      90 => '3 tháng',
      _ => '$days ngày'
    };
  }

  Widget _buildChart(BuildContext context) {
    // Lấy danh sách ngày cần hiển thị
    final List<String> displayDates = _getDisplayDates();

    // Lấy giá trị lớn nhất để vẽ biểu đồ
    final maxStudyTime = dailyStudyTime.values.isEmpty
        ? 3600
        : dailyStudyTime.values.reduce((a, b) => a > b ? a : b);
    final maxTermsLearned = dailyTermsLearned.values.isEmpty
        ? 20
        : dailyTermsLearned.values.reduce((a, b) => a > b ? a : b);

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
                        padding: const EdgeInsets.symmetric(horizontal: 1),
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
              _buildDateLabels(context, displayDates),
            ],
          ),
        ),
        _buildRightAxis(context, maxTermsLearned),
      ],
    );
  }

  // Logic lấy danh sách ngày cần hiển thị theo khoảng thời gian
  List<String> _getDisplayDates() {
    // Lấy tất cả ngày từ dữ liệu
    final Set<String> allDates = {
      ...dailyStudyTime.keys,
      ...dailyTermsLearned.keys
    };
    final List<String> sortedDates = allDates.toList()..sort();

    // Nếu không đủ dữ liệu, tạo đủ số ngày
    if (sortedDates.length < timePeriod) {
      // Lấy ngày cuối cùng trong dữ liệu
      DateTime lastDate = sortedDates.isEmpty
          ? DateTime.now()
          : DateTime.parse(sortedDates.last);

      // Tạo đủ số ngày còn thiếu
      final List<String> filledDates = List.from(sortedDates);

      for (int i = 0; filledDates.length < timePeriod; i++) {
        // Tạo ngày mới (trừ đi 1 ngày)
        final newDate = lastDate.subtract(Duration(days: i + 1));
        final dateString = _formatDateToString(newDate);

        if (!filledDates.contains(dateString)) {
          filledDates.add(dateString);
        }
      }

      filledDates.sort();
      // Trả về timePeriod ngày gần nhất
      return filledDates.length > timePeriod
          ? filledDates.sublist(filledDates.length - timePeriod)
          : filledDates;
    }

    // Nếu đủ dữ liệu, lấy timePeriod ngày gần nhất
    return sortedDates.length > timePeriod
        ? sortedDates.sublist(sortedDates.length - timePeriod)
        : sortedDates;
  }

  // Format ngày thành chuỗi YYYY-MM-DD
  String _formatDateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Widget hiển thị nhãn ngày dưới biểu đồ - tối ưu hiển thị
  Widget _buildDateLabels(BuildContext context, List<String> dates) {
    // Tính toán số nhãn cần hiển thị dựa vào độ dài khoảng thời gian
    final int skipFactor = _calculateSkipFactor(dates.length);

    return SizedBox(
      height: 20,
      child: Row(
        children: dates.asMap().entries.map((entry) {
          final index = entry.key;
          final date = entry.value;

          // Chỉ hiển thị một số ngày nhất định để tránh vỡ giao diện
          final bool shouldShowLabel =
              index % skipFactor == 0 || index == dates.length - 1;

          final parts = date.split('-');
          // Format: DD/MM
          final label = parts.length >= 3 ? '${parts[2]}/${parts[1]}' : '';

          return Expanded(
            child: Center(
              child: shouldShowLabel
                  ? Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.darkTextSecondary,
                            fontSize: 10, // Giảm kích thước font
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : const SizedBox(), // Ô trống nếu không hiển thị nhãn
            ),
          );
        }).toList(),
      ),
    );
  }

  // Tính toán hệ số bỏ qua các nhãn để tránh vỡ giao diện
  int _calculateSkipFactor(int totalDates) {
    if (totalDates <= 7) return 1; // Hiển thị tất cả nếu ≤ 7 ngày
    if (totalDates <= 14) return 2; // Hiển thị mỗi 2 ngày nếu ≤ 14 ngày
    if (totalDates <= 30) return 5; // Hiển thị mỗi 5 ngày nếu ≤ 30 ngày
    return 10; // Hiển thị mỗi 10 ngày nếu > 30 ngày
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
                  color: AppColors.darkTextSecondary.withOpacity(0.85),
                  fontSize: 11, // Giảm kích thước font từ 13 xuống 11
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
                  fontSize: 11, // Giảm kích thước font từ 12 xuống 11
                ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarGroup(BuildContext context, double studyTimeHeight,
      double termsLearnedHeight, int studyTimeValue, int termsLearnedValue) {
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
                      fontSize: 12,
                    ),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  height: height > 2 ? height : (studyTimeValue > 0 ? 2 : 0),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(4)),
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
                      fontSize: 12,
                    ),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  height: height > 2 ? height : (termsLearnedValue > 0 ? 2 : 0),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(4)),
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
                fontSize: 13, // Giảm kích thước font
              ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    if (seconds < 60) return '$seconds giây';
    if (seconds < 3600) return '${(seconds / 60).round()} phút';
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '$hours giờ ${minutes > 0 ? '$minutes phút' : ''}';
  }
}
