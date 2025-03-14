import 'package:flutter/material.dart';

class HomeMenuItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String route;

  const HomeMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.route,
  });
}
