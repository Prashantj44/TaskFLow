import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryChip extends StatelessWidget {
  final String category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    Key? key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  static IconData getIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'work':
        return Icons.work_outline_rounded;
      case 'personal':
        return Icons.person_outline_rounded;
      case 'study':
        return Icons.menu_book_rounded;
      case 'health':
        return Icons.favorite_outline_rounded;
      case 'dev':
        return Icons.code_rounded;
      case 'creative':
        return Icons.palette_outlined;
      default:
        return Icons.label_outline_rounded;
    }
  }

  static Color getColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'work':
        return Color(0xFF6366F1); // Indigo
      case 'personal':
        return Color(0xFFEC4899); // Pink
      case 'study':
        return Color(0xFF8B5CF6); // Purple
      case 'health':
        return Color(0xFF10B981); // Emerald
      case 'dev':
        return Color(0xFF06B6D4); // Cyan
      case 'creative':
        return Color(0xFFF59E0B); // Amber
      default:
        return Color(0xFF6B7280); // Gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getColor(category);
    final icon = getIcon(category);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : color,
            ),
            SizedBox(width: 6),
            Text(
              category,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
