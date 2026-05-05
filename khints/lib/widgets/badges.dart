import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable badge widget for document types (DS, EX, CC, CO, TD)
class TypeBadge extends StatelessWidget {
  final String type;
  final double size;

  const TypeBadge({super.key, required this.type, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.badgeColor(type),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}

/// Small inline chip badge (e.g. "DGI", "L3", "2024")
class InfoChip extends StatelessWidget {
  final String label;
  final Color? color;

  const InfoChip({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (color ?? AppColors.accent).withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? AppColors.accent,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
