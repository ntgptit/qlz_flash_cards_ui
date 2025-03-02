import 'package:flutter/material.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/utils/qlz_avatar.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/buttons/qlz_button.dart';
import 'package:qlz_flash_cards_ui/shared/widgets/cards/qlz_card.dart';

final class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A092D),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              const Center(
                child: QlzAvatar(
                  assetPath: 'assets/images/user_avatar.jpg',
                  size: 100,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'giapnguyen1994',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 28),
              _buildSettingsButton(context),
              const SizedBox(height: 36),
              _buildAchievementSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: QlzCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        onTap: () {},
        child: Row(
          children: [
            const Icon(Icons.settings, color: Colors.blue),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Cài đặt của bạn',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành tựu',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              QlzButton.ghost(
                label: 'Xem tất cả',
                onPressed: () {},
              ),
            ],
          ),
        ),
        QlzCard(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            children: [
              Image.asset(
                'assets/icons/achievement_streak.png',
                width: 80,
                height: 80,
              ),
              const SizedBox(height: 20),
              const Text(
                'Chuỗi 11 tuần',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Hãy học vào tuần tới để duy trì chuỗi của bạn!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  7,
                  (index) => Column(
                    children: [
                      Text(
                        ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? const Color.fromARGB(255, 229, 93, 43)
                              : const Color(0xFF1A1D3D),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            ['23', '24', '25', '26', '27', '28', '1'][index],
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                    ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
