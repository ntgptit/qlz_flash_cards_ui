// lib/features/library/presentation/screens/class_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_empty_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/feedback/qlz_loading_state.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/navigation/qlz_app_bar.dart';

/// Màn hình hiển thị chi tiết lớp học
class ClassDetailScreen extends StatefulWidget {
  final String classId;
  final String className;

  const ClassDetailScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  bool _isLoading = true;
  final bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadClassDetails();
  }

  Future<void> _loadClassDetails() async {
    // Giả lập tải dữ liệu
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
        // Đối với màn hình này, hiện chưa có dữ liệu thực tế
        // nên chúng ta hiển thị trạng thái "đang phát triển"
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      appBar: QlzAppBar(
        title: widget.className,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: QlzLoadingState(
          message: 'Đang tải thông tin lớp học...',
          type: QlzLoadingType.circular,
        ),
      );
    }

    if (_hasError) {
      return QlzEmptyState.error(
        title: 'Không thể tải thông tin lớp học',
        message: _errorMessage ?? 'Đã xảy ra lỗi khi tải dữ liệu',
        onAction: _loadClassDetails,
      );
    }

    // Hiển thị giao diện "đang phát triển"
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.construction,
            size: 72,
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tính năng đang phát triển',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Màn hình chi tiết lớp học "${widget.className}" \nđang được xây dựng',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Quay lại'),
          ),
        ],
      ),
    );
  }
}
