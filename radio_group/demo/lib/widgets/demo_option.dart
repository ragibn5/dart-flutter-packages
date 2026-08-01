import 'package:flutter/material.dart';
import 'package:radio_group/radio_group.dart' as radio_group;

class DemoOption extends radio_group.RadioItemUiModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const DemoOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    super.shouldBeSelected = true,
  });
}

const List<DemoOption> demoOptions = [
  DemoOption(
    title: 'Free',
    subtitle: 'Great for trying things out',
    icon: Icons.rocket_launch_rounded,
    color: Color(0xFF0EA5E9),
  ),
  DemoOption(
    title: 'Pro',
    subtitle: 'The most popular plan',
    icon: Icons.workspace_premium_rounded,
    color: Color(0xFF8B5CF6),
  ),
  DemoOption(
    title: 'Team',
    subtitle: 'Collaborate with your crew',
    icon: Icons.groups_rounded,
    color: Color(0xFF10B981),
  ),
  DemoOption(
    title: 'Enterprise',
    subtitle: 'Advanced security & support',
    icon: Icons.business_center_rounded,
    color: Color(0xFFF59E0B),
  ),
  DemoOption(
    title: 'Custom',
    subtitle: 'Build your own setup',
    icon: Icons.tune_rounded,
    color: Color(0xFFF43F5E),
  ),
  DemoOption(
    title: 'Locked',
    subtitle: 'Disabled example — try me!',
    icon: Icons.lock_rounded,
    color: Color(0xFF94A3B8),
    shouldBeSelected: false,
  ),
];
